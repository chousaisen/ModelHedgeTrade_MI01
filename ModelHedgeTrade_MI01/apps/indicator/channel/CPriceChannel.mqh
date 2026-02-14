//+------------------------------------------------------------------+
//|                                                 IndicatorCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../header/symbol/CHeader.mqh"
#include "../../share/symbol/CSymbolShare.mqh"
#include "../../share/indicator/CIndicatorShare.mqh"
#include "../../comm/CLog.mqh"
#include "../../comm/ComFunc.mqh"

#include "CHeader.mqh"

class CPriceChannel{
   private:      
      CSymbolShare*          symbolShare;
      CIndicatorShare*       indicatorShare;      
      datetime               refreshTime; 
      
      //--- indicator parameter
      int    InpPeriods[];             // 各个周期
      double edgeRateWeights[];        // 各周期权重(edge rate)
      double strengthWeights[];        // 各周期权重(strength rate)
      string indicatorName;            // 指标名称
      double strengthUnitPips;         // 强度标准尺
      //--- 全局变量
      int    Handles[SYMBOL_MAX_COUNT][IND_PCHANNEL_PERIOD_COUNT];                   // 保存指标句柄
      double UpperBuffer[];            // 缓存最大周期的通道值      
      double LowerBuffer[];            // 缓存最大周期的通道值      
           
   public:
                        CPriceChannel();
                       ~CPriceChannel();
        //--- init 
        void            init(CSymbolShare* symbolShare,CIndicatorShare* indicatorShare);
        void            makeIndicators(int symbolIndex);
        void            makeIndicatorData(int symbolIndex);
        //--- refresh relation data
        void            refresh();
        //--- run indicator
        void            run();
  };
  
//+------------------------------------------------------------------+
//|  init the correlation class
//+------------------------------------------------------------------+
void CPriceChannel::init(CSymbolShare* symbolShare,CIndicatorShare* indicatorShare)
{
   this.symbolShare=symbolShare;
   this.indicatorShare=indicatorShare;
   comFunc.StringToIntArray(Ind_Price_Chl_Period_lv1,InpPeriods);
   comFunc.StringToDoubleArray(Ind_Price_Chl_EWeight,edgeRateWeights,',');
   comFunc.StringToDoubleArray(Ind_Price_Chl_SWeight,strengthWeights,',');   
   this.strengthUnitPips=Ind_Price_Chl_Strength_UnitPips;
   this.indicatorName=Ind_Price_Chl_Name;

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
void CPriceChannel::makeIndicators(int symbolIndex){
   if(this.symbolShare.runable(symbolIndex)){
      // 初始化 PriceChannel 指标句柄
      for(int i = 0; i < ArraySize(InpPeriods); i++){         
         string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);      
         Handles[symbolIndex][i] = iCustom(symbol, Ind_Price_Chl_TimeFrame, indicatorName, InpPeriods[i]);
         if(Handles[symbolIndex][i] == INVALID_HANDLE){
            rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                                 + " CPriceChannel.makeChannels Failed to create handle for period");
            return;
         }
       }
    }
}

//+------------------------------------------------------------------+
//|  make indicator data
//+------------------------------------------------------------------+
void  CPriceChannel::makeIndicatorData(int symbolIndex)
  {
  
   double UpAlignment = 0.0;
   double DownAlignment = 0.0;
   double strengthSumPips=0.0;
   double stressRate=0.0;
   //double sumUpEdge=0,avgUpEdge=0;   
   //double sumDownEdge=0,avgDownEdge=0;   
   //double point=Point();
   double point=this.symbolShare.getSymbolPoint(SYMBOL_LIST[symbolIndex]);
   
   bool   upperFlag=true;
   int    periodCount=ArraySize(InpPeriods);
   // 获取最大周期的通道值
   if(CopyBuffer(Handles[symbolIndex][periodCount-1], 0, Ind_Price_Chl_Shift, 1, UpperBuffer) <= 0 ||
      CopyBuffer(Handles[symbolIndex][periodCount-1], 1, Ind_Price_Chl_Shift, 1, LowerBuffer) <= 0){
      rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                        + " CPriceChannel.makeChannels Failed to copy buffer for max period channel.");     
   }   

   double max_channel_upper = UpperBuffer[0];
   double max_channel_lower = LowerBuffer[0];   
   this.indicatorShare.getPriceChannelStatus(symbolIndex)
   .setEdgePrice(periodCount-1,max_channel_upper,max_channel_lower); 
   this.indicatorShare.getPriceChannelStatus(symbolIndex)
   .setUpperEdgeOuter(max_channel_upper);
   this.indicatorShare.getPriceChannelStatus(symbolIndex)
   .setLowerEdgeOuter(max_channel_lower);
   
   //printf("channel64_upper:" + max_channel_upper + "   channel64_lower:" + max_channel_lower);

   if(max_channel_upper <= max_channel_lower){
      rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                        + " CPriceChannel.makeChannels Invalid max channel values. Upper <= Lower.");     
   }

   double PeriodUpper[1], PeriodLower[1];
   // 从缓冲区中获取当前周期的通道值
   if(CopyBuffer(Handles[symbolIndex][0], 0, Ind_Price_Chl_Shift, 1, PeriodUpper) <= 0 ||
      CopyBuffer(Handles[symbolIndex][0], 1, Ind_Price_Chl_Shift, 1, PeriodLower) <= 0){
      rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                        + " CPriceChannel.makeChannels Failed to copy buffer for period.");     

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
   this.indicatorShare.getPriceChannelStatus(symbolIndex)
   .setEdgePrice(0,begin_channel_upper,begin_channel_lower);
   
   if(begin_channel_up_edge_diff>0){  
      beginUpperEdgeRate=begin_channel_range/begin_channel_up_edge_diff; 
      UpAlignment+=beginUpperEdgeRate*this.edgeRateWeights[0];     
   }   
   if(begin_channel_lower_edge_diff>0){
      beginLowerEdgeRate=begin_channel_range/begin_channel_lower_edge_diff;
      DownAlignment-=beginLowerEdgeRate*this.edgeRateWeights[0];
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
      if(CopyBuffer(Handles[symbolIndex][p], 0, Ind_Price_Chl_Shift, 1, PeriodUpper) <= 0 ||
         CopyBuffer(Handles[symbolIndex][p], 1, Ind_Price_Chl_Shift, 1, PeriodLower) <= 0){
         PrintFormat("Failed to copy buffer for period %d. Error: %d", InpPeriods[p], GetLastError());
         continue;
      }

      // 归一化计算靠近上边缘和下边缘的贴合程度
      double channel_distance = PeriodUpper[0] - PeriodLower[0];
      double channel_up_edge_diff=max_channel_upper-PeriodLower[0];
      double channel_up_edge_diff2=PeriodUpper[0]-max_channel_upper;
      double channel_lower_edge_diff=PeriodUpper[0]-max_channel_lower;
      double channel_lower_edge_diff2=PeriodLower[0]-max_channel_lower;
      
      strengthSumPips+=((channel_up_edge_diff2+channel_lower_edge_diff2)*this.strengthWeights[p])/point; 
      
      double upper_ratio=0,lower_ratio=0;   
      if(channel_up_edge_diff>0){  
         upper_ratio=channel_distance/channel_up_edge_diff;      
         UpAlignment+=upper_ratio*this.edgeRateWeights[p];
      }   
      if(channel_lower_edge_diff>0){
         lower_ratio=channel_distance/channel_lower_edge_diff;
         DownAlignment-=lower_ratio*this.edgeRateWeights[p];
      }
      
      this.indicatorShare.getPriceChannelStatus(symbolIndex)
      .setEdgePrice(p,PeriodUpper[0],PeriodLower[0]);      
   }
   
   if(upperFlag){
      this.indicatorShare.setEdgeRate(symbolIndex,UpAlignment);
      double strengthRate=strengthSumPips/this.strengthUnitPips;      
      this.indicatorShare.setStrengthRate(symbolIndex,strengthRate);
   }else{
      this.indicatorShare.setEdgeRate(symbolIndex,DownAlignment);
      double strengthRate=strengthSumPips/this.strengthUnitPips;
      this.indicatorShare.setStrengthRate(symbolIndex,strengthRate);
   }   
   /*
   static datetime openLastTime = 0; 
   datetime curTime=TimeCurrent();        
   if((curTime-openLastTime)>60){ 
      double sumRate=this.indicatorShare.getEdgeRate(symbolIndex)
                     + this.indicatorShare.getStrengthRate(symbolIndex);
      printf("sumEdgeRate: " + this.indicatorShare.getEdgeRate(symbolIndex)
               + " strengthRate:" + this.indicatorShare.getStrengthRate(symbolIndex)
               + " sumRate:" + sumRate);
      openLastTime = curTime;
   }*/

}

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CPriceChannel::refresh(){

   //refresh diff time setting
   int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
   if(refreshDiffSeconds<IND_PCHANNEL_DIFF_SECONDS)return;
      
   int total_symbols = ArraySize(SYMBOL_LIST);   
   // Output weights for each symbol      
   for (int i = 0; i < total_symbols; i++){ 
      if(this.symbolShare.runable(i)){       
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
void CPriceChannel::run(){
    rkeeLog.writeLmtLog("CPriceChannel: run");   
    this.refresh();
}
  

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CPriceChannel::CPriceChannel(){
   this.refreshTime=0;
}
CPriceChannel::~CPriceChannel(){}