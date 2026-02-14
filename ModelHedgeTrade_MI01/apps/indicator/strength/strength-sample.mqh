//+------------------------------------------------------------------+
//|  Class for calculating relative strength                        |
//+------------------------------------------------------------------+
class CRelativeStrength
  {
private:
   int      refreshTime;
   double   rsiValues[];
   
public:
   void     refresh();
   void     run();
   double   CalculateRSI(double &data[], int period);
   void     findVolatilePairs();
  };
//+------------------------------------------------------------------+
//|  Refresh data and calculate RSI for each currency pair           |
//+------------------------------------------------------------------+
void CRelativeStrength::refresh()
  {
      int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
      if(refreshDiffSeconds<IND_RSI_DIFF_SECONDS)return;

      // 获取历史数据并计算RSI值
      for (int i = 0; i < ArraySize(SYMBOL_LIST); i++)
      {
         double closePrices[];
         ArrayResize(closePrices, IND_RSI_PERIOD);
         
         for (int j = 0; j < IND_RSI_PERIOD; j++)
         {
            closePrices[j] = iClose(SYMBOL_LIST[i], IND_RSI_TIMEFRAME, j);
         }
         
         rsiValues[i] = CalculateRSI(closePrices, IND_RSI_PERIOD);
         printf(SYMBOL_LIST[i] + " RSI: " + rsiValues[i]);
      }

      // 更新刷新时间
      this.refreshTime=TimeCurrent();
  }
//+------------------------------------------------------------------+
//|  Run the calculation and identify volatile pairs                 |
//+------------------------------------------------------------------+
void CRelativeStrength::run()
  {
    this.refresh();
    this.findVolatilePairs();
  }
//+------------------------------------------------------------------+
//|  Calculate RSI                                                    |
//+------------------------------------------------------------------+
double CRelativeStrength::CalculateRSI(double &data[], int period)
{
   double gain = 0, loss = 0;
   
   for (int i = 1; i < period; i++)
   {
      double change = data[i] - data[i - 1];
      if (change > 0)
         gain += change;
      else
         loss -= change;
   }
   
   double avgGain = gain / period;
   double avgLoss = loss / period;
   
   double rs = avgGain / avgLoss;
   return 100 - (100 / (1 + rs));
}
//+------------------------------------------------------------------+
//|  Find volatile and less volatile pairs based on RSI               |
//+------------------------------------------------------------------+
void CRelativeStrength::findVolatilePairs()
{
   double maxRSI = -1, minRSI = 101;
   string mostVolatilePair, leastVolatilePair;
   
   for (int i = 0; i < ArraySize(SYMBOL_LIST); i++)
   {
      if (rsiValues[i] > maxRSI)
      {
         maxRSI = rsiValues[i];
         mostVolatilePair = SYMBOL_LIST[i];
      }
      
      if (rsiValues[i] < minRSI)
      {
         minRSI = rsiValues[i];
         leastVolatilePair = SYMBOL_LIST[i];
      }
   }
   
   printf("Most Volatile Pair: " + mostVolatilePair + " RSI: " + maxRSI);
   printf("Least Volatile Pair: " + leastVolatilePair + " RSI: " + minRSI);
}
//+------------------------------------------------------------------+

解释：
CRelativeStrength类：用于计算货币对的相对强度指数（RSI）。
refresh()方法：刷新数据并为每个货币对计算RSI值。
CalculateRSI()方法：计算指定时间周期内的RSI值。
findVolatilePairs()方法：根据RSI值找到波动性最大和最小的货币对。
run()方法：刷新数据并调用筛选波动性货币对的函数。

通过该程序，你可以计算各个货币对的RSI值，并筛选出相对波动较大的和较小的货币对。