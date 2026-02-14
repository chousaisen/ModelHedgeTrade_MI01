//+------------------------------------------------------------------+
//|                                                       Test01.mq5 |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Generic\ArrayList.mqh>
#include "..\apps\comm\ComFunc.mqh"
#include "..\apps\share\signal\CSignal.mqh"
#include "..\apps\share\order\COrder.mqh"

//CArrayList<CSignal*>  signalList;
CArrayList<COrder*>  orderList;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  

 string symbols[] = {"AUDNZD","AUDJPY","AUDUSD",
                      "AUDCAD","AUDCHF","CADJPY",
                      "CHFJPY","CADCHF","EURGBP",
                      "EURUSD","EURAUD","EURCHF",
                      "EURCAD","EURJPY","EURNZD",
                      "GBPCHF","GBPJPY","GBPAUD",
                      "GBPNZD","GBPCAD","GBPUSD",
                      "USDCHF","USDJPY","USDCAD",
                      "NZDJPY","NZDUSD","NZDCAD",
                      "NZDCHF","XAUUSD"};
    int total_symbols = ArraySize(symbols);
   double weights[];
   ArrayResize(weights, total_symbols);

   int period = 300; // Period for volatility calculation (days)

   // Calculate weights based on volatility
   CalculateVolatilityWeights(symbols, total_symbols, weights, period);

   // Output weights for each symbol
   double minWeight=weights[0];
   for (int i = 0; i < total_symbols; i++)
   {
      PrintFormat("Symbol: %s, Weight: %.5f", symbols[i], weights[i]);
      if(minWeight>weights[i])minWeight=weights[i];
   }
   
   // Output weights for each symbol   
   for (int i = 0; i < total_symbols; i++)
   {
      double adjustWeight=weights[i]/minWeight;
      PrintFormat("Symbol: %s, Weight: %.1f", symbols[i], adjustWeight);      
   }
   
   
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
  
}
//+------------------------------------------------------------------+

// Calculate volatility
double CalculateVolatility(string symbol, int period)
{
   double prices[];
   int copied = CopyClose(symbol, PERIOD_D1, 0, period, prices); // Get daily closing prices
   if (copied < period) return 0.0;

   double sum = 0.0, mean = ArrayAverage(prices);

   for (int i = 0; i < period; i++){
      double symbol_point=SymbolInfoDouble(symbol,SYMBOL_POINT);      
      double pipsDiff=(prices[i] - mean)/symbol_point;
      sum += MathPow(pipsDiff, 2);
   }   

   return MathSqrt(sum / period); // Standard deviation as volatility
}

// Calculate normalized weights for multiple currencies
void CalculateVolatilityWeights(string &symbols[], int total_symbols, double &weights[], int period)
{
   double volatilities[];
   ArrayResize(volatilities, total_symbols);

   double total_volatility = 0.0;

   // Calculate volatility for each symbol
   for (int i = 0; i < total_symbols; i++)
   {
      volatilities[i] = CalculateVolatility(symbols[i], period);
      total_volatility += volatilities[i];
   }

   // Normalize volatility to weights
   for (int i = 0; i < total_symbols; i++)
   {
      if (total_volatility > 0)
         weights[i] = volatilities[i] / total_volatility;
      else
         weights[i] = 0.0;
   }
}

double ArrayAverage(const double &arr[])
{
   int size = ArraySize(arr);
   if (size == 0) return 0.0; // 避免除零错误

   double sum = 0.0;
   for (int i = 0; i < size; i++)
      sum += arr[i];

   return sum / size;
}