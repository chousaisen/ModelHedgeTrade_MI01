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

#include "CHeader.mqh"

input  string          Ind_Price_Chl2_Period = "3,9,48"; 
input  string          Ind_Price_Chl2_Name = "RkeeChannel";
input  ENUM_TIMEFRAMES Ind_Price_Chl2_TimeFrame = PERIOD_M5;

class CPriceChannel2{
   private:
      CShareCtl*        shareCtl;
      datetime          refreshTime; 
      
      //--- indicator parameter
      int    InpPeriods[];             // 各个周期
      string indicatorName;            // 指标名称
      //--- 全局变量
      int    Handles[SYMBOL_MAX_COUNT][IND_PCHANNEL_PERIOD_COUNT];                   // 保存指标句柄
      double UpperBuffer[];            // 缓存最大周期的通道值      
      double LowerBuffer[];            // 缓存最大周期的通道值
      double upperEdgeOuter[];
      double lowerEdgeOuter[];            
           
   public:
                        CPriceChannel2();
                       ~CPriceChannel2();
        //--- init 
        void            init(CShareCtl* shareCtl);
        void            makeIndicators(int symbolIndex);
        void            makeIndicatorData(int symbolIndex);
        //--- refresh relation data
        void            refresh();
        //--- run indicator
        void            run();
        //--- set edge price
        void            setEdgePrice(int symbolIndex,
                                       int index,
                                       int count,
                                       double &upperBuffer[],
                                       double &lowerBuffer[]);
                                       
        //--- set edge rate
        void  setEdgeRate(int symbolIndex,
                                          int index,
                                          int count,
                                          double &upperBuffer[],
                                          double &lowerBuffer[],
                                          double &upperEdgeOuter[],
                                          double &lowerEdgeOuter[]);
                                                                              
        //--- create edge rate                               
        double createEdgeRate(double upperEdge,
                                          double lowerEdge,
                                          double upperEdgeOuter,
                                          double lowerEdgeOuter);
        //--- create edge strength rate                                  
        double createEdgeStengthRate(double upperEdge,
                                          double lowerEdge,
                                          double upperEdgeOuter,
                                          double lowerEdgeOuter,
                                          double point); 
        //--- get edge break diff                                  
        double  getEdgeBrkDiff(int count,
                                    double &upperBuffer[],
                                    double &lowerBuffer[]);
                                       
        //--- set edge break diff pips
        void    setEdgeBrkDiffPips(int symbolIndex,
                                       int index,
                                       int count,
                                       double &upperBuffer[],
                                       double &lowerBuffer[]);
  };
  
//+------------------------------------------------------------------+
//|  init the correlation class
//+------------------------------------------------------------------+
void CPriceChannel2::init(CShareCtl* shareCtl)
{
   this.shareCtl=shareCtl;     
   this.indicatorName=Ind_Price_Chl2_Name;
   comFunc.StringToIntArray(Ind_Price_Chl2_Period,InpPeriods);
   int symbolCount=ArraySize(SYMBOL_LIST);
   for(int i=0;i<symbolCount;i++){  
      this.makeIndicators(i);
   }   
   ArraySetAsSeries(UpperBuffer, true);
   ArraySetAsSeries(LowerBuffer, true);
   ArraySetAsSeries(upperEdgeOuter, true);
   ArraySetAsSeries(lowerEdgeOuter , true);   
   
}

//+------------------------------------------------------------------+
//|  make multi channel
//+------------------------------------------------------------------+
void CPriceChannel2::makeIndicators(int symbolIndex){
   if(this.shareCtl.getSymbolShare().runable(symbolIndex)){
      // 初始化 PriceChannel 指标句柄
      for(int i = 0; i < ArraySize(InpPeriods); i++){         
         string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);      
         Handles[symbolIndex][i] = iCustom(symbol, Ind_Price_Chl2_TimeFrame, indicatorName, InpPeriods[i]);
         if(Handles[symbolIndex][i] == INVALID_HANDLE){
            rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                                 + " CPriceChannel2.makeChannels Failed to create handle for period");
            return;
         }
       }
    }
}

//+------------------------------------------------------------------+
//|  make indicator data
//+------------------------------------------------------------------+
void  CPriceChannel2::makeIndicatorData(int symbolIndex)
  {
 
   double point=Point();   
   int    periodCount=ArraySize(InpPeriods);
     
   for(int p = periodCount-1; p >0 ; p--){      
      // 从缓冲区中获取当前周期的通道值
      if(CopyBuffer(Handles[symbolIndex][p], 0, 0, 10, upperEdgeOuter) <= 0 
         || CopyBuffer(Handles[symbolIndex][p], 1, 0, 10, lowerEdgeOuter) <= 0
         || CopyBuffer(Handles[symbolIndex][p-1], 0, 0, 10, UpperBuffer) <= 0
         || CopyBuffer(Handles[symbolIndex][p-1], 1, 0, 10, LowerBuffer) <= 0){
         PrintFormat("Failed to copy buffer for period %d. Error: %d", InpPeriods[p], GetLastError());
         continue;
      }
      if(p==(periodCount-1)){
         this.setEdgePrice(symbolIndex,p,10,upperEdgeOuter,lowerEdgeOuter);
         this.setEdgeBrkDiffPips(symbolIndex,p,10,upperEdgeOuter,lowerEdgeOuter);
      }
      this.setEdgePrice(symbolIndex,p-1,10,UpperBuffer,LowerBuffer);
      this.setEdgeRate(symbolIndex,p-1,10,UpperBuffer,LowerBuffer,upperEdgeOuter,lowerEdgeOuter);
      this.setEdgeBrkDiffPips(symbolIndex,p-1,10,UpperBuffer,LowerBuffer);     
   }
     
   /*
   static datetime openLastTime = 0; 
   datetime curTime=TimeCurrent();        
   if((curTime-openLastTime)>60){ 
      double sumRate=this.shareCtl.getIndicatorShare().getEdgeRate(symbolIndex)
                     + this.shareCtl.getIndicatorShare().getStrengthRate(symbolIndex);
      printf("sumEdgeRate: " + this.shareCtl.getIndicatorShare().getEdgeRate(symbolIndex)
               + " strengthRate:" + this.shareCtl.getIndicatorShare().getStrengthRate(symbolIndex)
               + " sumRate:" + sumRate);
      openLastTime = curTime;
   }*/

}

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CPriceChannel2::refresh(){

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
//|  set edge rate
//+------------------------------------------------------------------+
void CPriceChannel2::setEdgeRate(int symbolIndex,
                                    int index,
                                    int count,
                                    double &upperBuffer[],
                                    double &lowerBuffer[],
                                    double &upperEdgeOuter[],
                                    double &lowerEdgeOuter[]){
   for(int i=0;i<count;i++){                  
      double edgeRate=this.createEdgeRate(upperBuffer[i],
                                             lowerBuffer[i],
                                             upperEdgeOuter[i],
                                             lowerEdgeOuter[i]);
      this.shareCtl.getIndicatorShare().getPriceChannelStatus2(symbolIndex)
      .setEdgeRate(index,i,edgeRate);      

   }
}

//+------------------------------------------------------------------+
//|  set edge price
//+------------------------------------------------------------------+
void CPriceChannel2::setEdgePrice(int symbolIndex,
                                    int index,
                                    int count,
                                    double &upperBuffer[],
                                    double &lowerBuffer[]){
                           
   for(int i=0;i<count;i++){                        
      this.shareCtl.getIndicatorShare().getPriceChannelStatus2(symbolIndex)
      .setEdgePrice(index,i,upperBuffer[i],lowerBuffer[i]);
   }
}

//+------------------------------------------------------------------+
//|  create edge rate
//+------------------------------------------------------------------+
double CPriceChannel2::createEdgeRate(double upperEdge,
                                          double lowerEdge,
                                          double upperEdgeOuter,
                                          double lowerEdgeOuter){

      // 归一化计算靠近上边缘和下边缘的贴合程度
      double channel_distance = upperEdge - lowerEdge;
      double channel_up_edge_diff=upperEdgeOuter-lowerEdge;
      double channel_lower_edge_diff=upperEdge-lowerEdgeOuter;
      
      if(channel_up_edge_diff<=0
         || channel_lower_edge_diff<=0){
          rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                        + " CPriceChannel2.createEdgeRate Failed to create edge rate."); 
          return 0;               
      }
      
      double edgeRate=0;   
      if(channel_up_edge_diff<channel_lower_edge_diff){
         edgeRate=channel_distance/channel_up_edge_diff;      
      }   
      else{
         edgeRate=-channel_distance/channel_lower_edge_diff;
      }      
      return edgeRate;
}


//+------------------------------------------------------------------+
//|  create edge move strength rate
//+------------------------------------------------------------------+
double CPriceChannel2::createEdgeStengthRate(double upperEdge,
                                          double lowerEdge,
                                          double upperEdgeOuter,
                                          double lowerEdgeOuter,
                                          double point){
      
      double channel_up_edge_diff2=upperEdge-upperEdgeOuter;
      double channel_lower_edge_diff2=lowerEdge-lowerEdgeOuter;
      
      return (channel_up_edge_diff2+channel_lower_edge_diff2)/point;       
}


//+------------------------------------------------------------------+
//|  get edge break diff
//+------------------------------------------------------------------+
double CPriceChannel2::getEdgeBrkDiff(int count,
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
void  CPriceChannel2::setEdgeBrkDiffPips(int symbolIndex,
                                 int index,
                                 int count,
                                 double &upperBuffer[],
                                 double &lowerBuffer[]){
   
   double point=this.shareCtl.getSymbolShare().getSymbolPoint(SYMBOL_LIST[symbolIndex]);
   double edgeBrkDiffPips=this.getEdgeBrkDiff(count,upperBuffer,lowerBuffer)/point;
   this.shareCtl.getIndicatorShare().getPriceChannelStatus2(symbolIndex)
   .setEdgeBrkDiffPips(index,edgeBrkDiffPips);       
}

//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CPriceChannel2::run(){
    this.refresh();
}
  

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CPriceChannel2::CPriceChannel2(){
   this.refreshTime=0;
}
CPriceChannel2::~CPriceChannel2(){}