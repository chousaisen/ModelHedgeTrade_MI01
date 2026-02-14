//+------------------------------------------------------------------+
//| calculate the Volatility
//+------------------------------------------------------------------+


#include "../apps/header/symbol/CHeader.mqh"
//#include "../apps/comm/ComFunc.mqh"

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+

input int N_Days = 30;                                              // 当前时间范围的天数
input ENUM_TIMEFRAMES Timeframe = PERIOD_H1;                        // 分析的时间周期（如日线）
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
     
   if((curTime-printLastTime)>3600*24) 
   {
      testAverageVolatility();
      printLastTime=curTime;
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Script Start Function                                            |
//+------------------------------------------------------------------+
void testAverageVolatility()
{
   double yearly_avg_volatility = CalculateYearlyAverageVolatility(SYMBOL_LIST, Timeframe);
   if (yearly_avg_volatility == 0)
   {
      Print("Unable to calculate yearly average volatility.");
      return;
   }
   
   double recent_avg_volatility = CalculateRecentAverageVolatility(SYMBOL_LIST, Timeframe, N_Days);
   if (recent_avg_volatility == 0)
   {
      Print("Unable to calculate recent average volatility.");
      return;
   }

   double ratio = recent_avg_volatility / yearly_avg_volatility;
   

   printf(//comFunc.getDate_YYYYMMDDHHMM2() 
               TimeCurrent()+ "  Yearly Average Volatility: " + yearly_avg_volatility
               + "  Days Average Volatility: " + recent_avg_volatility
               + "  Volatility Ratio (Recent / Yearly): " + ratio);      
    
   
}

//+------------------------------------------------------------------+
//| Calculate Yearly Average Volatility                              |
//+------------------------------------------------------------------+
double CalculateYearlyAverageVolatility(string &symbols[], ENUM_TIMEFRAMES timeframe)
{
   int total_days = 365; // 一年的天数
   double total_volatility = 0.0;
   int symbol_count = ArraySize(symbols);
   
   for (int i = 0; i < symbol_count; i++)
   {
      string symbol = symbols[i];
      int bars = iBars(symbol, timeframe);
      if (bars < total_days)
      {
         Print("Not enough data for symbol: ", symbol);
         return 0.0;
      }

      double symbol_volatility = 0.0;
      for (int j = 0; j < total_days; j++)
      {
         double high = iHigh(symbol, timeframe, j);
         double low = iLow(symbol, timeframe, j);
         symbol_volatility += high - low;
      }
      
      total_volatility += symbol_volatility / (double)total_days; // 平均波动
   }
   
   //return total_volatility / (double)symbol_count; // 总体平均波动
   return total_volatility; // 总体平均波动
}

//+------------------------------------------------------------------+
//| Calculate Recent Average Volatility                              |
//+------------------------------------------------------------------+
double CalculateRecentAverageVolatility(string &symbols[], ENUM_TIMEFRAMES timeframe, int days)
{
   double total_volatility = 0.0;
   int symbol_count = ArraySize(symbols);
   
   for (int i = 0; i < symbol_count; i++)
   {
      string symbol = symbols[i];
      int bars = iBars(symbol, timeframe);
      if (bars < days)
      {
         Print("Not enough data for symbol: ", symbol);
         return 0.0;
      }

      double symbol_volatility = 0.0;
      for (int j = 0; j < days; j++)
      {
         double high = iHigh(symbol, timeframe, j);
         double low = iLow(symbol, timeframe, j);
         symbol_volatility += high - low;
      }
      
      total_volatility += symbol_volatility / (double)days; // 平均波动
   }
   
   //return total_volatility / (double)symbol_count; // 总体平均波动
   return total_volatility; // 总体平均波动
}
