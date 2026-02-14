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
#include "CHeader.mqh"

class CVolatility{
   private:
      CShareCtl*        shareCtl;
      datetime          refreshTime;      
   public:
                        CVolatility();
                       ~CVolatility();
        //--- init 
        void            init(CShareCtl* shareCtl);
        //--- refresh relation data
        void            refresh();
        //--- run indicator
        void            run();
        //--- calculate volatility
        double          calculateVolatility(string symbol, int periods);
        //--- array average
        double          arrayAverage(const double &arr[]);
        //--- calculate volatility 
        double          calculateVolatility(double &data[][SYMBOL_MAX_COUNT], int pair1, int pair2, int period);  
        //--- calculate volatility weight
        void            calculateVolatilityWeights(string &symbols[], int total_symbols, double &weights[], int period);
  };
  
//+------------------------------------------------------------------+
//|  init the correlation class
//+------------------------------------------------------------------+
void CVolatility::init(CShareCtl* shareCtl)
{
   this.shareCtl=shareCtl;
}

//+------------------------------------------------------------------+
//|  calculate volatility
//+------------------------------------------------------------------+
double CVolatility::calculateVolatility(string symbol, int period)
{
   double prices[];
   string curSymbol=comFunc.addSuffix(symbol);
   int copied = CopyClose(curSymbol, Ind_Volatility_TimeFrame, 0, period, prices); // Get daily closing prices
   if (copied < period) return 0.0;

   double sum = 0.0, mean = arrayAverage(prices);

   for (int i = 0; i < period; i++){
      double symbol_point=SymbolInfoDouble(curSymbol,SYMBOL_POINT);      
      double pipsDiff=(prices[i] - mean)/symbol_point;
      sum += MathPow(pipsDiff, 2);
   }   

   return MathSqrt(sum / period); // Standard deviation as volatility
}  


//+------------------------------------------------------------------+
//|  Calculate normalized weights for multiple currencies
//+------------------------------------------------------------------+
void CVolatility::calculateVolatilityWeights(string &symbols[], int total_symbols, double &weights[], int period)
{
   double volatilities[];
   ArrayResize(volatilities, total_symbols);

   double total_volatility = 0.0;

   // Calculate volatility for each symbol
   for (int i = 0; i < total_symbols; i++)
   {
      if(!this.shareCtl.getSymbolShare().runable(i))continue;
      double tickValue=SYMBOL_TICK_VALUE[i];      
      if(Ind_Volatility_ExtSymbol_FixRate){
         if(symbols[i]=="XAUUSD")tickValue=1;         
      }
      volatilities[i] = this.calculateVolatility(symbols[i], period)*tickValue;
      total_volatility += volatilities[i];
   }

   // Normalize volatility to weights
   for (int i = 0; i < total_symbols; i++)
   {
      if(!this.shareCtl.getSymbolShare().runable(i))continue;
      if (total_volatility > 0)
         weights[i] = volatilities[i] / total_volatility;
      else
         weights[i] = 0.0;
   }
}

//+------------------------------------------------------------------+
//|  array Average
//+------------------------------------------------------------------+
double CVolatility::arrayAverage(const double &arr[])
{
   int size = ArraySize(arr);
   if (size == 0) return 0.0; // 避免除零错误

   double sum = 0.0;
   for (int i = 0; i < size; i++)
      sum += arr[i];
   return sum / size;
}

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CVolatility::refresh(){

   //refresh diff time setting
   int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
   if(refreshDiffSeconds<IND_VOLATILITY_DIFF_SECONDS)return;
      
   int total_symbols = ArraySize(SYMBOL_LIST);
   double weights[];
   ArrayResize(weights, total_symbols);

   // Calculate weights based on volatility
   this.calculateVolatilityWeights(SYMBOL_LIST, total_symbols, weights, Ind_Volatility_Period);

   // Output weights for each symbol
   double minWeight=weights[0];
   for (int i = 0; i < total_symbols; i++)
   {
      //PrintFormat("Symbol: %s, Weight: %.5f", SYMBOL_LIST[i], weights[i]);
      if(!this.shareCtl.getSymbolShare().runable(i))continue;
      if(minWeight>weights[i])minWeight=weights[i];
   }
   
   string logTempStr="";   
   // Output weights for each symbol   
   for (int i = 0; i < total_symbols; i++)
   {
      if(!this.shareCtl.getSymbolShare().runable(i))continue;
      
      double adjustWeight=1; 
      if(minWeight>0){
         adjustWeight=weights[i]/minWeight; 
         SYMBOL_RATE[i]=adjustWeight;
         //PrintFormat("Symbol: %s, symbolRate: %.1f, tickValue: %.1f", SYMBOL_LIST[i], SYMBOL_RATE[i],SYMBOL_TICK_VALUE[i]);      
      }else{
         rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()+" CVolatility.refresh error minWeight:" + minWeight);
      }
      this.shareCtl.getIndicatorShare().setSymbolVolatilityWeight(i,adjustWeight);           
      //PrintFormat("Symbol: %s, Weight: %.1f", SYMBOL_LIST[i], adjustWeight);
      //SYMBOL_RATE[i]= weights[i];     
      logTempStr+="<" + SYMBOL_LIST[i] + ":" + StringFormat("%.3f", SYMBOL_RATE[i]) + ">";
   } 
   
   //rkeeLog.printLogLine("indicator",9002,3600, comFunc.getDate_YYYYMMDDHHMM2() + "  " +  logTempStr);
   
   //set the refresh time
   this.refreshTime=TimeCurrent();        
      
}


//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CVolatility::run(){
    this.refresh();
}
  

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CVolatility::CVolatility(){
   this.refreshTime=0;
}
CVolatility::~CVolatility(){}