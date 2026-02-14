//+------------------------------------------------------------------+
//| calculate the price action speed
//+------------------------------------------------------------------+


#include "../apps/header/symbol/CHeader.mqh"
//#include "../apps/comm/ComFunc.mqh"

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+

//input int N_Days = 30;                                              // 当前时间范围的天数
//input ENUM_TIMEFRAMES Timeframe = PERIOD_H1;                        // 分析的时间周期（如日线）
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{


   static datetime printLastTime = 0; 
   datetime curTime=TimeCurrent();   
     
   if((curTime-printLastTime)>300) 
   {

      string symbol = "XAUUSD";                 // 货币对
      ENUM_TIMEFRAMES timeframe = PERIOD_M5;   // 时间周期
      int short_term = 10;                      // 短期：10根K线
      int mid_term = 50;                        // 中期：50根K线
      int long_term = 100;                      // 长期：100根K线
   
      double short_avg, mid_avg, long_avg;      
   
      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, timeframe, short_term, mid_term, long_term, short_avg, mid_avg, long_avg);   
      // 判断速度趋势
      string trend2 = DetermineSpeedTrend(short_avg, mid_avg, long_avg);

      ENUM_TIMEFRAMES timeframe2 = PERIOD_M1;   // 时间周期
      int short_term2 = 10;                      // 短期：10根K线
      int mid_term2 = 50;                        // 中期：50根K线
      int long_term2 = 100;                      // 长期：100根K线
   
      double short_avg2, mid_avg2, long_avg2;


      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, timeframe2, short_term2, mid_term2, long_term2, short_avg2, mid_avg2, long_avg2);   
      // 判断速度趋势
      string trend1 = DetermineSpeedTrend(short_avg2, mid_avg2, long_avg2);
      
      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, PERIOD_M15, short_term2, mid_term2, long_term2, short_avg2, mid_avg2, long_avg2);   
      // 判断速度趋势
      string trend3 = DetermineSpeedTrend(short_avg2, mid_avg2, long_avg2); 
      
      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, PERIOD_M30, short_term2, mid_term2, long_term2, short_avg2, mid_avg2, long_avg2);   
      // 判断速度趋势
      string trend4 = DetermineSpeedTrend(short_avg2, mid_avg2, long_avg2);   
      
      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, PERIOD_H1, short_term2, mid_term2, long_term2, short_avg2, mid_avg2, long_avg2);   
      // 判断速度趋势
      string trend5 = DetermineSpeedTrend(short_avg2, mid_avg2, long_avg2);               

      printf("  " + trend5
            + " | " + trend4 
            + " | " + trend3 
            + " | " + trend2
            + " | " + trend1);
   
      // 输出结果
      /*
      printf("speedS:" + StringFormat("%.3f", short_avg)
            + " speedM:" +  StringFormat("%.3f", mid_avg)
            + " speedL: " + StringFormat("%.3f", long_avg)
            + " Trend: " + trend 
            + " | " + trend2 );*/
      
      
      printLastTime=curTime;      
  }          
      
}
// 计算单个货币对在指定周期和时间框架下的变化速度
double CalculateSpeed(string symbol, ENUM_TIMEFRAMES timeframe, int bars)
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

// 计算短期、中期和长期的速度均值
void CalculateSpeedAverages(string symbol, ENUM_TIMEFRAMES timeframe, int short_term, int mid_term, int long_term, double &short_avg, double &mid_avg, double &long_avg)
{
   short_avg = CalculateSpeed(symbol, timeframe, short_term); // 短期速度
   mid_avg = CalculateSpeed(symbol, timeframe, mid_term);     // 中期速度
   long_avg = CalculateSpeed(symbol, timeframe, long_term);   // 长期速度
}

// 判断速度趋势：加速、减速或平稳
string DetermineSpeedTrend(double short_avg, double mid_avg, double long_avg)
{
   if (short_avg > mid_avg && mid_avg > long_avg)
      return "Accelerating"; // 加速
   else if (short_avg < mid_avg && mid_avg < long_avg)
      return "Decelerating"; // 减速
   else
      return "Stable";       // 平稳
}