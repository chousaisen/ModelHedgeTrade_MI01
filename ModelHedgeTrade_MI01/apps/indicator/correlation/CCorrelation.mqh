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
#include "CHeader.mqh"

class CCorrelation{
   private:
      CSymbolShare*     symbolShare;      
      double            closes[IND_CORRELATION_PERIOD][SYMBOL_MAX_COUNT]; 
      double            correlation_matrix[SYMBOL_MAX_COUNT][SYMBOL_MAX_COUNT]; 
      datetime          refreshTime;
   public:
                        CCorrelation();
                       ~CCorrelation();
        //--- init 
        void            init(CSymbolShare* shareCtl);
        //--- refresh relation data
        void            refresh();
        //--- run indicator
        void            run();
        
        //--- calculate correlation
        double          CalculateCorrelation(double &data[][SYMBOL_MAX_COUNT], int pair1, int pair2, int period);
        //--- array average
        double          ArrayAverage(double &data[][SYMBOL_MAX_COUNT], int period, int pair); 
        //--- Draw Heat map
        //void            getRelation();           
  };
  
//+------------------------------------------------------------------+
//|  init the correlation class
//+------------------------------------------------------------------+
void CCorrelation::init(CSymbolShare* symbolShare)
{
   this.symbolShare=symbolShare;
}
    
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CCorrelation::refresh()
  {
     
      int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
      if(refreshDiffSeconds<IND_CORRELATION_DIFF_SECONDS)return;
      
      // 获取历史数据
      for (int i = 0; i < ArraySize(SYMBOL_LIST); i++)
      {
         if(!this.symbolShare.runable(i))continue;
         for (int j = 0; j < Ind_Correlation_Period; j++){
            string symbol=comFunc.addSuffix(SYMBOL_LIST[i]);
            closes[j][i] = iClose(symbol, Ind_Correlation_TimeFrame, j);
         }
      }
      // 计算相关系数矩阵
      for (int i = 0; i < ArraySize(SYMBOL_LIST); i++){
         if(!this.symbolShare.runable(i))continue;
         for (int j = 0; j < ArraySize(SYMBOL_LIST); j++){
            if(!this.symbolShare.runable(j))continue;
            correlation_matrix[i][j] = CalculateCorrelation(closes, i, j, Ind_Correlation_Period);
            symbolShare.setSymbolCorrelation(i,j,correlation_matrix[i][j]);
            //printf(SYMBOL_LIST[i] + "-" + SYMBOL_LIST[j] + ":" + correlation_matrix[i][j]);
         }         
      }      
      //set the refresh time
      this.refreshTime=TimeCurrent(); 
  }
//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CCorrelation::run(){
    rkeeLog.writeLmtLog("CCorrelation: run");
    this.refresh();
}
  
//+------------------------------------------------------------------+
//| Calculate correlation                                            |
//+------------------------------------------------------------------+
double CCorrelation::CalculateCorrelation(double &data[][SYMBOL_MAX_COUNT], int pair1, int pair2, int period)
{
   double mean1 = ArrayAverage(data, period, pair1);
   double mean2 = ArrayAverage(data, period, pair2);
   
   double sum1 = 0, sum2 = 0, sum3 = 0;
   for (int i = 0; i < period; i++)
     {
      sum1 += (data[i][pair1] - mean1) * (data[i][pair2] - mean2);
      sum2 += (data[i][pair1] - mean1) * (data[i][pair1] - mean1);
      sum3 += (data[i][pair2] - mean2) * (data[i][pair2] - mean2);
     }
   
   return (sum1 / MathSqrt(sum2 * sum3));
}
//+------------------------------------------------------------------+
//| Array average                                                    |
//+------------------------------------------------------------------+
double CCorrelation::ArrayAverage(double &data[][SYMBOL_MAX_COUNT], int period, int pair)
{
   double sum = 0;
   for (int i = 0; i < period; i++)
      sum += data[i][pair];
   
   return (sum / period);
}  

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CCorrelation::CCorrelation()
{
   this.refreshTime=0;
}
CCorrelation::~CCorrelation(){}