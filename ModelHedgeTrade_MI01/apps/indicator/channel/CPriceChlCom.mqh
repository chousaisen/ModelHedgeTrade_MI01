//+------------------------------------------------------------------+
//|                                                 IndicatorCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../header/symbol/CHeader.mqh"
#include "../../share/CShareCtl.mqh"
#include "../../comm/CLog.mqh"
#include "../../comm/ComFunc.mqh"
#include "../../comm/ComFunc2.mqh"

#include "../../header/CHeader.mqh"

class CPriceChlCom{
   private:
      CShareCtl*        shareCtl;
      datetime          refreshTime; 
      
      //--- indicator parameter
      int    InpPeriods[];             // 各个周期
      double edgeRateWeights[];        // 各周期权重(edge rate)
      double strengthWeights[];        // 各周期权重(strength rate)
      string indicatorName;            // 指标名称
      double strengthUnitPips;         // 强度标准尺
      //--- 全局变量
      //int    Handles[SYMBOL_MAX_COUNT][IND_PCHANNEL_PERIOD_COUNT];                   // 保存指标句柄
      int    Handles[SYMBOL_MAX_COUNT][300];                   // 保存指标句柄
      double UpperBuffer[];            // 缓存最大周期的通道值      
      double LowerBuffer[];            // 缓存最大周期的通道值   
      
      //channel control
      int              channelLevel;
      ENUM_TIMEFRAMES  channelTimeFrame;
      
      //channel current value
      double           sumRate;
      double           sumChlHeight;
      // price channel edge diff past count
      int              chlEdgeDiffPastCount;
         
           
   public:
                        CPriceChlCom();
                       ~CPriceChlCom();
        //--- init 
        void            init(CShareCtl* shareCtl,ENUM_TIMEFRAMES  timeFrame,int chlLevel);
        void            makeIndicators(int symbolIndex);
        void            makeIndicatorData(int symbolIndex);
        //--- refresh relation data
        void            refresh();
        //--- run indicator
        void            run();
        //--- get sum rate
        double          getSumRate();
        //--- get sum Channel Height
        double          getSumChlHeight();
        
        //--- get edge break diff                                  
        double  getEdgeBrkDiff(int count,
                                    double &upperBuffer[],
                                    double &lowerBuffer[]);
                                       
        //--- set edge break diff pips
        void    setEdgeBrkDiffPips(int symbolIndex,
                                       int count,
                                       double &upperBuffer[],
                                       double &lowerBuffer[]);
  };
  
//+------------------------------------------------------------------+
//|  init the correlation class
//+------------------------------------------------------------------+
void CPriceChlCom::init(CShareCtl* shareCtl,ENUM_TIMEFRAMES  timeFrame,int chlLevel)
{
   this.shareCtl=shareCtl;  
   this.chlEdgeDiffPastCount=Ind_Price_Chl_Edge_Diff_Past_Count;
   if(timeFrame==Ind_Price_Chl_TimeFrame_Shift_Lv1
      || timeFrame==Ind_Price_Chl_TimeFrame_Shift_Lv2){
      comFunc.StringToIntArray(Ind_Price_Chl_Period_lv1,InpPeriods);
   }else if(timeFrame==Ind_Price_Chl_TimeFrame_Shift_Lv3
      || timeFrame==Ind_Price_Chl_TimeFrame_Shift_Lv4){
      comFunc.StringToIntArray(Ind_Price_Chl_Period_lv2,InpPeriods);
      this.chlEdgeDiffPastCount=this.chlEdgeDiffPastCount+2;
   }else{
      comFunc.StringToIntArray(Ind_Price_Chl_Period_lv3,InpPeriods);
      this.chlEdgeDiffPastCount=this.chlEdgeDiffPastCount+3;
   }
   
   comFunc.StringToDoubleArray(Ind_Price_Chl_EWeight,edgeRateWeights,',');
   comFunc.StringToDoubleArray(Ind_Price_Chl_SWeight,strengthWeights,',');   
   this.strengthUnitPips=Ind_Price_Chl_Strength_UnitPips;
   this.indicatorName=Ind_Price_Chl_Name;
   this.channelTimeFrame=timeFrame;
   this.channelLevel=chlLevel;

   int symbolCount=ArraySize(SYMBOL_LIST);
   for(int i=0;i<symbolCount;i++){  
      this.makeIndicators(i);
   }
   // 设置缓冲区为时间序列
   ArraySetAsSeries(UpperBuffer, true);
   ArraySetAsSeries(LowerBuffer, true); 
}

//+------------------------------------------------------------------+
//|  make multi channel
//+------------------------------------------------------------------+
void CPriceChlCom::makeIndicators(int symbolIndex){
   if(this.shareCtl.getSymbolShare().runable(symbolIndex)){
      // 初始化 PriceChannel 指标句柄      
      /*
      for(int i = 0; i < ArraySize(InpPeriods); i++){                
         int curPeriod=InpPeriods[i]+adjustPeriod;  
         Handles[symbolIndex][i] = iCustom(symbol, this.channelTimeFrame, indicatorName, curPeriod);
         if(Handles[symbolIndex][i] == INVALID_HANDLE){
            rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                                 + " CPriceChlCom.makeChannels Failed to create handle for period");
            return;
         }
       }*/
     string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);        
     for(int i = 1; i < 300; i++){                
         //int curPeriod=InpPeriods[i]+adjustPeriod;  
         Handles[symbolIndex][i] = iCustom(symbol, this.channelTimeFrame, indicatorName, i);
         if(Handles[symbolIndex][i] == INVALID_HANDLE){
            rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                                 + " CPriceChlCom.makeChannels Failed to create handle for period");
            return;
         }
       }       
    }
}

//+------------------------------------------------------------------+
//|  make indicator data
//+------------------------------------------------------------------+
void  CPriceChlCom::makeIndicatorData(int symbolIndex){
  
   string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);      
   double curATR=comFunc2.GetATR(symbol,0,this.channelTimeFrame,12);
   double curStdDev=comFunc2.GetStdDev(symbol,0,this.channelTimeFrame,12);
   double sumDiffStdDev=comFunc2.GetSumOfStdDevChanges(symbol,10,this.channelTimeFrame,12);
   double sumDiffAtr=comFunc2.GetSumOfATRChanges(symbol,10,this.channelTimeFrame,12);
   double sumDiff=comFunc.extendValue(sumDiffStdDev+sumDiffAtr,2);
   double sumAtrStdDev=curATR+curStdDev+sumDiff;
   int    diffPeriod=(int)(comFunc2.mapValue(sumAtrStdDev,0,10,130,0));  
  
   int    adjustPeriod[];
   int    periodCount=ArraySize(InpPeriods);
   ArrayResize(adjustPeriod,periodCount);
   ArrayInitialize(adjustPeriod,0);
   double adjustRate=0.8;
   adjustPeriod[0]=(int)(comFunc2.mapValue(sumAtrStdDev,0,10,16*adjustRate,2)); 
   adjustPeriod[1]=(int)(comFunc2.mapValue(sumAtrStdDev,0,10,24*adjustRate,6)); 
   adjustPeriod[2]=(int)(comFunc2.mapValue(sumAtrStdDev,0,10,32*adjustRate,9)); 
   adjustPeriod[3]=(int)(comFunc2.mapValue(sumAtrStdDev,0,10,48*adjustRate,12)); 
   adjustPeriod[4]=(int)(comFunc2.mapValue(sumAtrStdDev,0,10,72*adjustRate,16)); 
   adjustPeriod[5]=(int)(comFunc2.mapValue(sumAtrStdDev,0,10,96*adjustRate,24)); 
   adjustPeriod[6]=(int)(comFunc2.mapValue(sumAtrStdDev,0,10,180*adjustRate,32)); 
   
   /*
   for(int i=0;i<periodCount;i++){
      adjustPeriod[i]=InpPeriods[i]+diffPeriod;   
   } */  
  
   double UpAlignment = 0.0;
   double DownAlignment = 0.0;
   double strengthSumPips=0.0;
   double stressRate=0.0;
   this.sumChlHeight=0.0;
   //double sumUpEdge=0,avgUpEdge=0;   
   //double sumDownEdge=0,avgDownEdge=0;   
   //double point=Point();
   double point=this.shareCtl.getSymbolShare().getSymbolPoint(SYMBOL_LIST[symbolIndex]);
   
   bool   upperFlag=true;
   //int    periodCount=ArraySize(InpPeriods);
   // 获取最大周期的通道值
   if(CopyBuffer(Handles[symbolIndex][adjustPeriod[periodCount-1]], 0, 0, 30, UpperBuffer) <= 0 ||
      CopyBuffer(Handles[symbolIndex][adjustPeriod[periodCount-1]], 1, 0, 30, LowerBuffer) <= 0){
      rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                        + " CPriceChlCom.makeChannels Failed to copy buffer for max period channel."); 
      return;                      
   }   

   this.setEdgeBrkDiffPips(symbolIndex,this.chlEdgeDiffPastCount,UpperBuffer,LowerBuffer);
   double max_channel_upper = UpperBuffer[0];
   double max_channel_lower = LowerBuffer[0]; 
   this.strengthUnitPips=(max_channel_upper-max_channel_lower)/point;
   this.sumChlHeight+=this.strengthUnitPips;
   
   //this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex)
   this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex,this.channelLevel)
   .setStrengthUnitPips(this.strengthUnitPips);

   this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex,this.channelLevel)
   .setEdgePrice(periodCount-1,UpperBuffer[1],LowerBuffer[1]);      
   
   //printf("channel64_upper:" + max_channel_upper + "   channel64_lower:" + max_channel_lower);

   if(max_channel_upper <= max_channel_lower){
      rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                        + " CPriceChlCom.makeChannels Invalid max channel values. Upper <= Lower.");     
   }

   double PeriodUpper[1], PeriodLower[1];
   // 从缓冲区中获取当前周期的通道值
   if(CopyBuffer(Handles[symbolIndex][adjustPeriod[0]], 0, 0, 1, PeriodUpper) <= 0 ||
      CopyBuffer(Handles[symbolIndex][adjustPeriod[0]], 1, 0, 1, PeriodLower) <= 0){
      rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                        + " CPriceChlCom.makeChannels Failed to copy buffer for period.");     
      return;
   }
      
   double beginUpperEdgeRate=0,beginLowerEdgeRate=0;
   double begin_channel_upper = PeriodUpper[0];
   double begin_channel_lower = PeriodLower[0];
   double begin_channel_range=begin_channel_upper-begin_channel_lower;
   double begin_channel_up_edge_diff=max_channel_upper-begin_channel_lower;
   double begin_channel_up_edge_diff2=begin_channel_upper-max_channel_upper;
   double begin_channel_lower_edge_diff=begin_channel_upper-max_channel_lower;
   double begin_channel_lower_edge_diff2=begin_channel_lower-max_channel_lower;
   strengthSumPips+=(begin_channel_up_edge_diff2+begin_channel_lower_edge_diff2)*this.strengthWeights[0]/point;
   this.sumChlHeight+=(begin_channel_upper-begin_channel_lower)/point;
   
   //this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex)
   this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex,this.channelLevel)
   .setEdgePrice(0,begin_channel_upper,begin_channel_lower);
   
   if(begin_channel_up_edge_diff>0){  
      beginUpperEdgeRate=begin_channel_range/begin_channel_up_edge_diff; 
      UpAlignment+=beginUpperEdgeRate*this.edgeRateWeights[0];     
      //UpAlignment+=beginUpperEdgeRate;     
   }   
   if(begin_channel_lower_edge_diff>0){
      beginLowerEdgeRate=begin_channel_range/begin_channel_lower_edge_diff;
      DownAlignment-=beginLowerEdgeRate*this.edgeRateWeights[0];
      //DownAlignment-=beginLowerEdgeRate;
   }
   
   //printf("channel_begin_upper:" + begin_channel_upper + "  Rate:" + beginUpperEdgeRate 
   //         + "    channel_begin_lower:" + begin_channel_lower + "   Rate:" + beginLowerEdgeRate);

   if(beginUpperEdgeRate>beginLowerEdgeRate){
      upperFlag=true;
   }else{
      upperFlag=false;
   }   

   // 忽略最大周期64本身
   for(int p = 1; p < ArraySize(InpPeriods) - 1; p++){      
      // 从缓冲区中获取当前周期的通道值
      if(CopyBuffer(Handles[symbolIndex][adjustPeriod[p]], 0, 0, 1, PeriodUpper) <= 0 ||
         CopyBuffer(Handles[symbolIndex][adjustPeriod[p]], 1, 0, 1, PeriodLower) <= 0){
         PrintFormat("Failed to copy buffer for period %d. Error: %d", adjustPeriod[p], GetLastError());
         continue;
      }

      // 归一化计算靠近上边缘和下边缘的贴合程度
      double channel_distance = PeriodUpper[0] - PeriodLower[0];
      double channel_up_edge_diff=max_channel_upper-PeriodLower[0];
      double channel_up_edge_diff2=PeriodUpper[0]-max_channel_upper;
      double channel_lower_edge_diff=PeriodUpper[0]-max_channel_lower;
      double channel_lower_edge_diff2=PeriodLower[0]-max_channel_lower;
      
      strengthSumPips+=((channel_up_edge_diff2+channel_lower_edge_diff2)*this.strengthWeights[p])/point; 
      this.sumChlHeight+=(PeriodUpper[0]-PeriodLower[0])/point; 
      
      double upper_ratio=0,lower_ratio=0;   
      if(channel_up_edge_diff>0){  
         upper_ratio=channel_distance/channel_up_edge_diff;      
         UpAlignment+=upper_ratio*this.edgeRateWeights[p];
         //UpAlignment+=upper_ratio;
      }   
      if(channel_lower_edge_diff>0){
         lower_ratio=channel_distance/channel_lower_edge_diff;
         DownAlignment-=lower_ratio*this.edgeRateWeights[p];
         //DownAlignment-=lower_ratio;
      }
      
      //this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex)
      //.setEdgePrice(p,PeriodUpper[0],PeriodLower[0]);
      
      this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex,this.channelLevel)
      .setEdgePrice(p,PeriodUpper[0],PeriodLower[0]);
            
   }
   
   double edgeRate=0,strengthRate=0;
   this.sumRate=0;   
   //logData.addLine("<<level" + this.channelLevel + ">><shiftLv>" 
   //                  + this.shareCtl.getIndicatorShare().getPriceChlShiftLevel(symbolIndex)); //---logData test   
   if(upperFlag){
      //this.shareCtl.getIndicatorShare().setEdgeRate(symbolIndex,UpAlignment);
      this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex,this.channelLevel)
      .setEdgeRate(UpAlignment);
      strengthRate=strengthSumPips/this.strengthUnitPips;
      //strengthRate=strengthSumPips;
      //this.shareCtl.getIndicatorShare().setStrengthRate(symbolIndex,strengthRate);
      this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex,this.channelLevel)
      .setStrengthRate(strengthRate);
      
      edgeRate=UpAlignment;
      //this.sumRate=strengthRate+UpAlignment;
      this.sumRate=UpAlignment;       
   }else{
      //this.shareCtl.getIndicatorShare().setEdgeRate(symbolIndex,DownAlignment);
      this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex,this.channelLevel)
      .setEdgeRate(DownAlignment);      
      strengthRate=strengthSumPips/this.strengthUnitPips;
      //strengthRate=strengthSumPips;
      //this.shareCtl.getIndicatorShare().setStrengthRate(symbolIndex,strengthRate);
      this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex,this.channelLevel)
      .setStrengthRate(strengthRate); 
      
      edgeRate=DownAlignment;
      //this.sumRate=strengthRate+DownAlignment;
      this.sumRate=DownAlignment;
   }         
   
   if(rkeeLog.debugPeriod(9112,60)){     
      datetime curTime=TimeCurrent();

      string logTemp = "<sumAtrStdDev>" + StringFormat("%.2f",sumAtrStdDev)
                        + "<curATR>" + StringFormat("%.2f",curATR)
                        + "<curStdDev>" + StringFormat("%.2f",curStdDev)
                        + "<sumDiffStdDev>" + StringFormat("%.2f",sumDiffStdDev)
                        + "<sumDiffAtr>" + StringFormat("%.2f",sumDiffAtr)
                        + "<adjustPeriod>" + adjustPeriod[0]
                        + "-" + adjustPeriod[1]
                        + "-" + adjustPeriod[2]
                        + "-" + adjustPeriod[3]
                        + "-" + adjustPeriod[4]
                        + "-" + adjustPeriod[5]
                        + "-" + adjustPeriod[6];
                        
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"debugIndChannelData03");
      
   }
}


//+------------------------------------------------------------------+
//|  get edge break diff
//+------------------------------------------------------------------+
double CPriceChlCom::getEdgeBrkDiff(int count,
                                       double &upperBuffer[],
                                       double &lowerBuffer[]){
   double sumUpperEdgeBrkDiff=0;
   double sumLowerEdgeBrkDiff=0;
   for(int i=0;i<count-1;i++){
      if(i>0 && upperBuffer[i]<upperBuffer[i+1])break;
      sumUpperEdgeBrkDiff+=upperBuffer[i]-upperBuffer[i+1];      
   }                                    
   for(int i=0;i<count-1;i++){      
      if(i>0 && lowerBuffer[i]>lowerBuffer[i+1])break;
      sumLowerEdgeBrkDiff+=lowerBuffer[i]-lowerBuffer[i+1];
   }
   
   if(sumUpperEdgeBrkDiff>0 && sumLowerEdgeBrkDiff<0){
      if(sumUpperEdgeBrkDiff>MathAbs(sumLowerEdgeBrkDiff)){
         return sumUpperEdgeBrkDiff;
      }   
      return sumLowerEdgeBrkDiff;
   }else if(sumUpperEdgeBrkDiff>0){
      return sumUpperEdgeBrkDiff;
   }else if(sumLowerEdgeBrkDiff<0){
      return sumLowerEdgeBrkDiff;
   }   
   return 0;
}      

//+------------------------------------------------------------------+
//|  set edge break diff pips
//+------------------------------------------------------------------+
void  CPriceChlCom::setEdgeBrkDiffPips(int symbolIndex,
                                          int count,
                                          double &upperBuffer[],
                                          double &lowerBuffer[]){
   
   double point=this.shareCtl.getSymbolShare().getSymbolPoint(SYMBOL_LIST[symbolIndex]);
   double edgeBrkDiffPips=this.getEdgeBrkDiff(count,upperBuffer,lowerBuffer)/point;
   this.shareCtl.getIndicatorShare().getPriceChannelStatus(symbolIndex,this.channelLevel)
   .setEdgeBrkDiffPips(edgeBrkDiffPips);       
}

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CPriceChlCom::refresh(){

   //refresh diff time setting
   int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
   if(refreshDiffSeconds<IND_PCHANNEL_DIFF_SECONDS)return;
      
   int total_symbols = ArraySize(SYMBOL_LIST);   
   // Output weights for each symbol      
   for (int i = 0; i < total_symbols; i++){ 
      if(this.shareCtl.getSymbolShare().runable(i)){       
         this.makeIndicatorData(i);
      }
   }           
   //rkeeLog.printLogLine("indicator",9001,300, comFunc.getDate_YYYYMMDDHHMM2() + "  " +  logTempStr);   
   //set the refresh time
   this.refreshTime=TimeCurrent();              
}

//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CPriceChlCom::run(){
    this.refresh();
}

//+------------------------------------------------------------------+
// get sum rate
//+------------------------------------------------------------------+
double CPriceChlCom::getSumRate(){
   return this.sumRate;
}

//+------------------------------------------------------------------+
// get sum Channel Height
//+------------------------------------------------------------------+
double CPriceChlCom::getSumChlHeight(){
   return this.sumChlHeight;
}

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CPriceChlCom::CPriceChlCom(){
   this.refreshTime=0;
}
CPriceChlCom::~CPriceChlCom(){}