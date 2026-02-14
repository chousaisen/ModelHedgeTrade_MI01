//+------------------------------------------------------------------+
//|                                                    CPriceAction.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../header/symbol/CHeader.mqh"
#include "../../share/CShareCtl.mqh"
#include "CHeader.mqh"

class CPriceAction
  {
private:
      int               refreshTime;
      CShareCtl*        shareCtl;
public:
                        CPriceAction();
                       ~CPriceAction();
      void     init(CShareCtl* shareCtl);   
      void     refresh();
      void     run();
      double   calculateSpeed(string symbol, 
                                          ENUM_TIMEFRAMES timeframe, 
                                          int bars);
      void     calculateSpeedAverages(string symbol, 
                                          ENUM_TIMEFRAMES timeframe, 
                                          int short_term, int mid_term, 
                                          int long_term, 
                                          double &short_avg, 
                                          double &mid_avg, 
                                          double &long_avg);
      int      determineSpeedTrend(double short_avg, 
                                          double mid_avg, 
                                          double long_avg);
      int      getPriceTend(int symbolIndex,ENUM_TIMEFRAMES timeframe);
};
  
//+------------------------------------------------------------------+
//|  init the price action class
//+------------------------------------------------------------------+
void CPriceAction::init(CShareCtl* shareCtl)
{
   this.shareCtl=shareCtl;
}
  
//+------------------------------------------------------------------+
//|  Refresh data and calculate RSI for each currency pair           |
//+------------------------------------------------------------------+
void CPriceAction::refresh(){

  //refresh diff time setting
   int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
   if(refreshDiffSeconds<IND_PRICE_SPEED_DIFF_SECONDS)return;
      
   int total_symbols = ArraySize(SYMBOL_LIST);
   
   // Output weights for each symbol   
   for (int i = 0; i < total_symbols; i++)
   {
      if(!this.shareCtl.getSymbolShare().runable(i))continue;
      int tendLv1=this.getPriceTend(i,IND_PRICE_SPEED_TIMEFRAME_LV1);
      this.shareCtl.getIndicatorShare().setPriceSpeed(i,PRICE_SPEED_LEVEL_1,tendLv1);
      int tendLv2=this.getPriceTend(i,IND_PRICE_SPEED_TIMEFRAME_LV2);
      this.shareCtl.getIndicatorShare().setPriceSpeed(i,PRICE_SPEED_LEVEL_2,tendLv2);
      int tendLv3=this.getPriceTend(i,IND_PRICE_SPEED_TIMEFRAME_LV3);
      this.shareCtl.getIndicatorShare().setPriceSpeed(i,PRICE_SPEED_LEVEL_3,tendLv3);
      int tendLv4=this.getPriceTend(i,IND_PRICE_SPEED_TIMEFRAME_LV4);
      this.shareCtl.getIndicatorShare().setPriceSpeed(i,PRICE_SPEED_LEVEL_4,tendLv4);            
      int tendLv5=this.getPriceTend(i,IND_PRICE_SPEED_TIMEFRAME_LV5);
      this.shareCtl.getIndicatorShare().setPriceSpeed(i,PRICE_SPEED_LEVEL_5,tendLv5);
      
   } 
   
   //set the refresh time
   this.refreshTime=TimeCurrent();   

}
  
//+------------------------------------------------------------------+
//|  Run the calculation and identify price action pairs
//+------------------------------------------------------------------+
void CPriceAction::run(){
   this.refresh();
}

//+------------------------------------------------------------------+
//|  计算单个货币对在指定周期和时间框架下的变化速度
//+------------------------------------------------------------------+
double CPriceAction::calculateSpeed(string symbol, ENUM_TIMEFRAMES timeframe, int bars)
{
   double speed = 0.0;
   for (int i = 1; i < bars; i++)
   {
      double close_prev = iClose(symbol, timeframe, i);
      double close_curr = iClose(symbol, timeframe, i - 1);
      double delta_time = PeriodSeconds(timeframe); // 时间间隔（秒）
      double symbol_point=SymbolInfoDouble(symbol,SYMBOL_POINT);
      speed += MathAbs((close_curr - close_prev)/symbol_point) / delta_time;
   }
   return speed / (bars - 1); // 平均波动速度
}

//+------------------------------------------------------------------+
//|  计算短期、中期和长期的速度均值
//+------------------------------------------------------------------+
void CPriceAction::calculateSpeedAverages(string symbol, 
                                       ENUM_TIMEFRAMES timeframe, 
                                       int short_term, int mid_term, 
                                       int long_term, 
                                       double &short_avg, 
                                       double &mid_avg, 
                                       double &long_avg)
{
   short_avg = calculateSpeed(symbol, timeframe, short_term); // 短期速度
   mid_avg = calculateSpeed(symbol, timeframe, mid_term);     // 中期速度
   long_avg = calculateSpeed(symbol, timeframe, long_term);   // 长期速度
}

//+------------------------------------------------------------------+
//| 判断速度趋势：加速、减速或平稳
//+------------------------------------------------------------------+
int CPriceAction::determineSpeedTrend(double short_avg, 
                                   double mid_avg, 
                                   double long_avg)
{
   if (short_avg > mid_avg && mid_avg > long_avg)
      return PRICE_SPEED_ACCELERATING; // 加速
   else if (short_avg < mid_avg && mid_avg < long_avg)
      return PRICE_SPEED_DECELERATING; // 减速
   else
      return PRICE_SPEED_STABLE;       // 平稳
}

//+------------------------------------------------------------------+
//| get price tend
//+------------------------------------------------------------------+
int CPriceAction::getPriceTend(int symbolIndex,ENUM_TIMEFRAMES timeframe){

   string curSymbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);   
   //ENUM_TIMEFRAMES timeframe = PERIOD_M5;   // 时间周期
   int short_term = PRICE_SPEED_PERIOD_SHORT;                      // 短期：10根K线
   int mid_term = PRICE_SPEED_PERIOD_MID;                        // 中期：50根K线
   int long_term = PRICE_SPEED_PERIOD_LONG;                      // 长期：100根K线
   
   double short_avg, mid_avg, long_avg;      
   
   // 计算短期、中期和长期的速度均值
   this.calculateSpeedAverages(curSymbol, 
                              timeframe, 
                              short_term, 
                              mid_term, 
                              long_term, 
                              short_avg, 
                              mid_avg, 
                              long_avg);   
   // 判断速度趋势
   return this.determineSpeedTrend(short_avg, mid_avg, long_avg);

}

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CPriceAction::CPriceAction()
{
   this.refreshTime=0;
}
CPriceAction::~CPriceAction(){}