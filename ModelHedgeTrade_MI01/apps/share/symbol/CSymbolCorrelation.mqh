//+------------------------------------------------------------------+
//|                                                  CSymbolCorrelation.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "..\..\header\symbol\CHeader.mqh"

class CSymbolCorrelation
  {
private:
    //-- save matrix
    double symbolCorrelationMatrix[SYMBOL_MAX_COUNT][SYMBOL_MAX_COUNT]; 
      
public:
                     CSymbolCorrelation();
                    ~CSymbolCorrelation();
     
     //--- methods of initilize
     void            init(); 
     //--- refresh
     void            refresh(); 
     //--- run CSymbolCorrelation
     void            run();
     //--- set symbol correlation
     void            setSymbolCorrelation(int symbolIndex1,int symbolIndex2,double value);
     //--- get symbol correlation
     double          getSymbolCorrelation(int symbolIndex1,int symbolIndex2);
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CSymbolCorrelation::init()
  {
   
  }
//+------------------------------------------------------------------+
//|  run the share control
//+------------------------------------------------------------------+
void CSymbolCorrelation::run()
  {
   
  }   

//+------------------------------------------------------------------+
//|  set symbol correlation value
//+------------------------------------------------------------------+
void CSymbolCorrelation::setSymbolCorrelation(int symbolIndex1,
                                             int symbolIndex2,
                                             double value){
   this.symbolCorrelationMatrix[symbolIndex1][symbolIndex2]=value;
}

//+------------------------------------------------------------------+
//|  get symbol correlation value
//+------------------------------------------------------------------+
double CSymbolCorrelation::getSymbolCorrelation(int symbolIndex1,
                                             int symbolIndex2){
   return this.symbolCorrelationMatrix[symbolIndex1][symbolIndex2];

}
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSymbolCorrelation::CSymbolCorrelation(){}
CSymbolCorrelation::~CSymbolCorrelation(){}