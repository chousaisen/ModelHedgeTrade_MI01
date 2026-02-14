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

      string symbol = "EURUSD";                 // 货币对
      int short_term = 10;                      // 短期：10根K线
      int mid_term = 50;                        // 中期：50根K线
      int long_term = 100;                      // 长期：100根K线
      int bars = 150;                           // 至少需要长周期根数的数据
   
      double short_avg, mid_avg, long_avg;      
   
      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, PERIOD_M1, bars,short_term, mid_term, long_term, short_avg, mid_avg, long_avg);   
      // 判断速度趋势
      string trend1 = DetermineSpeedTrend(short_avg, mid_avg, long_avg);

      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, PERIOD_M5, bars,short_term, mid_term, long_term, short_avg, mid_avg, long_avg);   
      // 判断速度趋势
      string trend2 = DetermineSpeedTrend(short_avg, mid_avg, long_avg);
      
      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, PERIOD_M15, bars,short_term, mid_term, long_term, short_avg, mid_avg, long_avg);   
      // 判断速度趋势
      string trend3 = DetermineSpeedTrend(short_avg, mid_avg, long_avg); 
      
      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, PERIOD_M30, bars,short_term, mid_term, long_term, short_avg, mid_avg, long_avg);   
      // 判断速度趋势
      string trend4 = DetermineSpeedTrend(short_avg, mid_avg, long_avg);   
      
      // 计算短期、中期和长期的速度均值
      CalculateSpeedAverages(symbol, PERIOD_H1, bars,short_term, mid_term, long_term, short_avg, mid_avg, long_avg);   
      // 判断速度趋势
      string trend5 = DetermineSpeedTrend(short_avg, mid_avg, long_avg);               

      printf("  " + trend1
            + " | " + trend2
            + " | " + trend3 
            + " | " + trend4
            + " | " + trend5);      
      
      printLastTime=curTime;      
  }          
      
}
// 计算单个货币对在指定周期和时间框架下的变化速度
void CalculateSpeed(string symbol, ENUM_TIMEFRAMES timeframe, int bars,double &speeds[])
{

   ArrayResize(speeds,bars);   
   for (int i = 1; i < bars; i++)
   {
      double close_prev = iClose(symbol, timeframe, i);
      double close_curr = iClose(symbol, timeframe, i - 1);
      double delta_time = PeriodSeconds(timeframe); // 时间间隔（秒）
      double symbol_point=SymbolInfoDouble(symbol,SYMBOL_POINT);
      speeds[i] = MathAbs((close_curr - close_prev)/symbol_point) / delta_time;
   }
   //return speed / (bars - 1); // 平均波动速度
}

// 计算速度的指数移动平均（EMA）
double CalculateEMA(double &values[], int period)
{
   if (ArraySize(values) < period) return 0.0; // 数据不足
   double ema = values[0]; // 初始化为第一个值
   double k = 2.0 / (period + 1); // 平滑系数
   for (int i = 0; i < ArraySize(values); i++) // 从0开始遍历
   {
      if (i == 0) continue; // 跳过第一个数据点，避免重复初始化
      ema = values[i] * k + ema * (1 - k);
   }
   return ema;
}

// 计算速度的加权移动平均（WMA）
double CalculateWMA(double &values[], int period)
{
   if (ArraySize(values) < period) return 0.0; // 数据不足
   double sum_weighted = 0.0;
   double sum_weights = 0.0;
   for (int i = 0; i < period; i++)
   {
      int weight = period - i; // 权重线性递减
      sum_weighted += values[i] * weight;
      sum_weights += weight;
   }
   return sum_weighted / sum_weights;
}


// 计算短期、中期和长期的速度均值
void CalculateSpeedAverages(string symbol, ENUM_TIMEFRAMES timeframe, 
                              int bars,
                              int short_term, 
                              int mid_term, 
                              int long_term, 
                              double &short_avg, 
                              double &mid_avg, 
                              double &long_avg)
{
   double speeds[];                          // 存储速度数组
   // 计算速度数组
   CalculateSpeed(symbol, timeframe, bars,speeds);
      
   short_avg = CalculateWMA(speeds, short_term); // 短期速度
   mid_avg = CalculateWMA(speeds, mid_term);     // 中期速度
   long_avg = CalculateWMA(speeds, long_term);   // 长期速度
}

// 计算短期、中期和长期的速度均值
void CalculateSpeedAveragesWMA(string symbol, ENUM_TIMEFRAMES timeframe, 
                              int bars,
                              int short_term, 
                              int mid_term, 
                              int long_term, 
                              double &short_avg, 
                              double &mid_avg, 
                              double &long_avg)
{
   double speeds[];                          // 存储速度数组
   // 计算速度数组
   CalculateSpeed(symbol, timeframe, bars,speeds);
      
   short_avg = CalculateWMA(speeds, short_term); // 短期速度
   mid_avg = CalculateWMA(speeds, mid_term);     // 中期速度
   long_avg = CalculateWMA(speeds, long_term);   // 长期速度
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