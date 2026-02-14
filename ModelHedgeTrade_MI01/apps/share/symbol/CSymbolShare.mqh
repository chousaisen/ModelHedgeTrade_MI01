//+------------------------------------------------------------------+
//|                                                  CSymbolShare.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"


//#include "..\..\comm\ComFunc.mqh"

//order
#include "..\..\header\symbol\CHeader.mqh"
#include "CSymbolInfos.mqh"
#include "CSymbolCorrelation.mqh"

class CSymbolShare
  {
private:           
      CSymbolInfos            symbolInfos;
      CArrayList<int>         runSymbols;
      CSymbolCorrelation      symbolCorrelation;
public:
                     CSymbolShare();
                    ~CSymbolShare();
     
      //--- methods of initilize
      void            init(); 
      void            initSymbols(); 
      bool            runable(int symbolIndex);
      //--- reset
      void            reSet();        
      //--- refresh
      void            refresh(); 
      //--- run CSymbolShare
      void            run(); 
      //--- clear order share when order not use
      void            clear();
      //--- get symbol price
      double          getSymbolPrice(string symbol,const ENUM_ORDER_TYPE tradeType);
      //--- get symbol index
      int             getSymbolIndex(string symbol);
      //--- get symbol point
      double          getSymbolPoint(string symbol);
      //--- get symbol infos
      CSymbolInfos*   getSymbolInfos();
      //--- get symbol correlation by symbol index
      double          getSymbolCorrelation(int symbolIndex1,int symbolIndex2); 
      //--- set symbol correlation
      void            setSymbolCorrelation(int symbolIndex1,int symbolIndex2,double value);       
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CSymbolShare::init()
{
   this.symbolInfos.initSymbolRate();
   this.initSymbols();
}

//+------------------------------------------------------------------+
//|  initialize the runable symbols
//+------------------------------------------------------------------+
void CSymbolShare::initSymbols(){
   int symbolCount=ArraySize(SYMBOL_LIST);
   bool  customSymbol=false;
   string symbolList=Symbol_Trade_List1 + "," + Symbol_Trade_List2 + "," + Symbol_Trade_List3;
   if(StringLen(symbolList)>2)customSymbol=true;   
   for(int i=0;i<symbolCount;i++){  
      if(customSymbol && StringFind(symbolList,SYMBOL_LIST[i])<0)continue;
      this.runSymbols.Add(i);   
   }
}

//+------------------------------------------------------------------+
//|  symbol runable
//+------------------------------------------------------------------+
bool CSymbolShare::runable(int symbolIndex){
   return this.runSymbols.Contains(symbolIndex);
}

//+------------------------------------------------------------------+
//|  reset symbol info
//+------------------------------------------------------------------+
void CSymbolShare::reSet(void)
{
   rkeeLog.writeLmtLog("CSymbolShare: reSet");   
   this.symbolInfos.reSet();   
}  
//+------------------------------------------------------------------+
//|  run the share control
//+------------------------------------------------------------------+
void CSymbolShare::run()
{

}   

//+------------------------------------------------------------------+
//|  get symbol price
//+------------------------------------------------------------------+
double CSymbolShare::getSymbolPrice(string symbol,const ENUM_ORDER_TYPE tradeType){ 
   return this.symbolInfos.getSymbolPrice(symbol,tradeType);
} 

//+------------------------------------------------------------------+
//|  get symbol index
//+------------------------------------------------------------------+
int CSymbolShare::getSymbolIndex(string symbol){ 
   return this.symbolInfos.getSymbolIndex(symbol);
}

//+------------------------------------------------------------------+
//|  get symbol point
//+------------------------------------------------------------------+
double  CSymbolShare::getSymbolPoint(string symbol){
   return this.symbolInfos.getSymbolPoint(symbol);      
}

//+------------------------------------------------------------------+
//|  get symbol infos
//+------------------------------------------------------------------+
CSymbolInfos* CSymbolShare::getSymbolInfos(){ 
   return &this.symbolInfos;
}

//+------------------------------------------------------------------+
//|  get symbol correlation value by symbol index
//+------------------------------------------------------------------+
double CSymbolShare::getSymbolCorrelation(int symbolIndex1,
                                             int symbolIndex2){
   return this.symbolCorrelation.getSymbolCorrelation(symbolIndex1,symbolIndex2);
}

//+------------------------------------------------------------------+
//|  set symbol correlation value
//+------------------------------------------------------------------+
void CSymbolShare::setSymbolCorrelation(int symbolIndex1,
                                             int symbolIndex2,
                                             double value){
   this.symbolCorrelation.setSymbolCorrelation(symbolIndex1,symbolIndex2,value);
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSymbolShare::CSymbolShare(){}
CSymbolShare::~CSymbolShare(){
   delete GetPointer(symbolInfos);
}