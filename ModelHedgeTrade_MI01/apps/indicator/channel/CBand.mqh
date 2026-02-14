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

class CBand{
   private:
      CShareCtl*        shareCtl;
      datetime          refreshTime;      
   public:
                        CBand();
                       ~CBand();
        //--- init 
        void            init(CShareCtl* shareCtl);
        //--- refresh relation data
        void            refresh();
        //--- run indicator
        void            run();
        //--- get band status
        ENUM_STATE      getCurrentState(string symbol, 
                                          double diffRate, 
                                          ENUM_TIMEFRAMES timeFrame, 
                                          ENUM_STATE currentState);
        //--- test                                  
        string          getStatus(ENUM_STATE currentState);
  };
  
//+------------------------------------------------------------------+
//|  init the correlation class
//+------------------------------------------------------------------+
void CBand::init(CShareCtl* shareCtl)
{
   this.shareCtl=shareCtl;
}

//+------------------------------------------------------------------+
//|  get the band status
//+------------------------------------------------------------------+
ENUM_STATE CBand::getCurrentState(string symbol, 
                                    double diffRate, 
                                    ENUM_TIMEFRAMES timeFrame, 
                                    ENUM_STATE currentState)
{
   // 布林带参数
   int bands_period = Ind_Band_Period;          // 平均线计算周期
   int bands_shift = 0;                         // 指标平移（0表示无平移）
   double deviation = 2.0;                      // 标准差数
   ENUM_APPLIED_PRICE applied_price = PRICE_WEIGHTED; // 应用价格

   // 获取布林带句柄
   int handle = iBands(symbol, timeFrame, bands_period, bands_shift, deviation, applied_price);
   if (handle == INVALID_HANDLE)
   {
      //iBands指标句柄获取失败
      rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()+" CBand.getCurrentState iBands error");
      return STATE_UNKNOWN;
   }

   // 获取布林带数据
   double upperBand[], middleBand[], lowerBand[];
   if (CopyBuffer(handle, 1, 0, 1, upperBand) <= 0 ||
       CopyBuffer(handle, 0, 0, 1, middleBand) <= 0 ||
       CopyBuffer(handle, 2, 0, 1, lowerBand) <= 0)
   {
      //无法获取布林带数据
      rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()+" CBand.getCurrentState error iBands handle");
      return STATE_UNKNOWN;
   }

   // 获取当前价格
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   double bandHeight=MathAbs(upperBand[0]-lowerBand[0]);

   // 计算加权后的diffPoint
   double weightedDiffPoint = diffRate * bandHeight;
   // 状态判断逻辑
   ENUM_STATE newState = currentState;

   if (currentState == STATE_UNKNOWN)
   {
      // 初始状态，无需考虑diffPoint
      if (currentPrice > upperBand[0])
         newState = STATE_BREAKOUT_UP;
      if (currentPrice > middleBand[0] && currentPrice<=upperBand[0])
         newState = STATE_UPPER_RANGE;
      if (currentPrice <= middleBand[0] && currentPrice>=lowerBand[0])
         newState = STATE_LOWER_RANGE;
      if (currentPrice < lowerBand[0])
         newState = STATE_BREAKOUT_DOWN;
   }
   else if (currentState == STATE_BREAKOUT_UP){
      if (currentPrice < upperBand[0]- weightedDiffPoint)
         newState = STATE_RETURN_UPPER;            
   }
   else if (currentState == STATE_BREAKOUT_DOWN){
      if (currentPrice > lowerBand[0]+ weightedDiffPoint)
         newState = STATE_RETURN_LOWER;          
   }   
   else if (currentState == STATE_UPPER_RANGE || currentState == STATE_RETURN_UPPER){
      if (currentPrice > upperBand[0] + weightedDiffPoint)
         newState = STATE_BREAKOUT_UP;
      if (currentPrice < middleBand[0] - weightedDiffPoint)
         newState = STATE_LOWER_RANGE;         
   }
   else if (currentState == STATE_LOWER_RANGE || currentState == STATE_RETURN_LOWER){
      if (currentPrice > middleBand[0] + weightedDiffPoint)
         newState = STATE_UPPER_RANGE;      
      if (currentPrice < lowerBand[0] - weightedDiffPoint)
         newState = STATE_BREAKOUT_DOWN;               
   }

   return newState;
}
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CBand::refresh(){

   //refresh diff time setting
   int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
   if(refreshDiffSeconds<IND_BAND_DIFF_SECONDS)return;
      
   int total_symbols = ArraySize(SYMBOL_LIST);
   
   // Output weights for each symbol   
   // string logTempStr="";
   for (int i = 0; i < total_symbols; i++)
   {        
      if(!this.shareCtl.getSymbolShare().runable(i))continue;
      string symbol=comFunc.addSuffix(SYMBOL_LIST[i]);
      ENUM_STATE preState=this.shareCtl.getIndicatorShare().getBandStatus(i,IND_BAND_LV0);
      ENUM_STATE currentState=getCurrentState(symbol, Ind_Band_Diff_Rate, Ind_Band_TimeFrame, preState);
      this.shareCtl.getIndicatorShare().setBandStatus(i,IND_BAND_LV0,currentState);
      
      //logTempStr+="<"+SYMBOL_LIST[i] + "|" + this.getStatus(currentState)+">";
   }        
   
   //rkeeLog.printLogLine("indicator",9001,300, comFunc.getDate_YYYYMMDDHHMM2() + "  " +  logTempStr);
   
   //set the refresh time
   this.refreshTime=TimeCurrent();        
      
}

// test
string CBand::getStatus(ENUM_STATE currentState)
{

   switch (currentState)
   {
      case STATE_UPPER_RANGE:
         return "up";
         break;
      case STATE_BREAKOUT_UP:
         return "bUp";
         break;
      case STATE_RETURN_UPPER:
         return "reUp";
         break;
      case STATE_LOWER_RANGE:
         return "down";
         break;
      case STATE_BREAKOUT_DOWN:
         return "bDown";
         break;
      case STATE_RETURN_LOWER:
         return "reDown";
         break;
      default:
         return "error";
         break;
   }
   
   return "error";
   
}

//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CBand::run(){
    this.refresh();
}
  

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CBand::CBand(){
   this.refreshTime=0;
}
CBand::~CBand(){}