//+------------------------------------------------------------------+
//|                                                 CSymbolInfos.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Generic\HashMap.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>


#include "..\..\comm\ComFunc.mqh"
#include "..\..\header\symbol\CHeader.mqh"

class CSymbolInfos: public CObject
  {
      private:
         CHashMap<string,CSymbolInfo*> symbolInfos;
         //symbol managment          
         string  symbolList[SYMBOL_MAX_COUNT];         
         double  symbolRate[SYMBOL_MAX_COUNT];
         bool    refreshSymbols[SYMBOL_MAX_COUNT];

      public:
                        CSymbolInfos();
                        ~CSymbolInfos();
                        
        //--- init symbol rate
        void            initSymbolRate();        
        //--- reset
        void            reSet();                      
        //--- get symbol info
        CSymbolInfo*    getSymbolInfo(string symbol);
        //--- get symbol price by order type
        double          getSymbolPrice(string symbol,const ENUM_ORDER_TYPE tradeType);
        //--- get symbol Ask price
        double          getSymbolAsk(string symbol);
        //--- get symbol Bid price
        double          getSymbolBid(string symbol);
        //--- get symbol Point
        double          getSymbolPoint(string symbol);
        //--- get symbol Spread
        int             getSymbolSpread(string symbol);
        //--- get symbol index
        int             getSymbolIndex(string symbol);
        //--- refresh symbol info
        void          refreshSymbolInfo(string symbol,CSymbolInfo* symbolInfo); 
        
};

//+------------------------------------------------------------------+
//| get the symbol info by symbol
//+------------------------------------------------------------------+
void CSymbolInfos::reSet(){
   ArrayInitialize(this.refreshSymbols,false);
}

//+------------------------------------------------------------------+
//| get the symbol info by symbol
//+------------------------------------------------------------------+
CSymbolInfo* CSymbolInfos::getSymbolInfo(string symbol){
   CSymbolInfo *symbolInfo;
   this.symbolInfos.TryGetValue(symbol,symbolInfo);
   if(symbolInfo==NULL){
      symbolInfo=new CSymbolInfo();
      symbolInfo.Name(comFunc.addSuffix(symbol));
      symbolInfo.Refresh();
      this.symbolInfos.Add(symbol,symbolInfo);   
   }
   return symbolInfo;
}

//+------------------------------------------------------------------+
//|  refresh symbol info
//+------------------------------------------------------------------+
void  CSymbolInfos::refreshSymbolInfo(string symbol,CSymbolInfo* symbolInfo){
   int symbolIndex=this.getSymbolIndex(symbol);
   if(!this.refreshSymbols[symbolIndex]){
      symbolInfo.RefreshRates();
      this.refreshSymbols[symbolIndex]=true;
   }   
}

//+------------------------------------------------------------------+
//|  get symbol price
//+------------------------------------------------------------------+
double CSymbolInfos::getSymbolPrice(string symbol,const ENUM_ORDER_TYPE tradeType){
   CSymbolInfo* symbolInfo=this.getSymbolInfo(symbol);   
   //refresh symbol info
   this.refreshSymbolInfo(symbol,symbolInfo);     
   //get price by order type   
   switch(tradeType){
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_STOP_LIMIT:
         return symbolInfo.Ask();
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_STOP_LIMIT:
         return symbolInfo.Bid();
   }   
   return 0;
}  

//+------------------------------------------------------------------+
//|  get symbol Ask price
//+------------------------------------------------------------------+
double CSymbolInfos::getSymbolAsk(string symbol){
   CSymbolInfo* symbolInfo=getSymbolInfo(symbol);
   //refresh symbol info
   this.refreshSymbolInfo(symbol,symbolInfo);   
   return symbolInfo.Ask();
}  

//+------------------------------------------------------------------+
//|  get symbol Bid price
//+------------------------------------------------------------------+
double CSymbolInfos::getSymbolBid(string symbol){
   CSymbolInfo* symbolInfo=getSymbolInfo(symbol);
   //refresh symbol info
   this.refreshSymbolInfo(symbol,symbolInfo);
   return symbolInfo.Bid();
}  

//+------------------------------------------------------------------+
//|  get symbol Point
//+------------------------------------------------------------------+
double CSymbolInfos::getSymbolPoint(string symbol){
   CSymbolInfo* symbolInfo=getSymbolInfo(symbol);
   //refresh symbol info
   this.refreshSymbolInfo(symbol,symbolInfo);   
   return symbolInfo.Point();
}  

//+------------------------------------------------------------------+
//|  get symbol Spread
//+------------------------------------------------------------------+
int CSymbolInfos::getSymbolSpread(string symbol){
   CSymbolInfo* symbolInfo=getSymbolInfo(symbol);
   //refresh symbol info
   this.refreshSymbolInfo(symbol,symbolInfo);   
   return symbolInfo.Spread();
} 

//+------------------------------------------------------------------+
//|  init symbol rate
//+------------------------------------------------------------------+
void CSymbolInfos::initSymbolRate(){

   for (int i = 0; i < ArraySize(this.symbolList); i++) {      
      CSymbolInfo* symbolInfo=getSymbolInfo(this.symbolList[i]);
      //refresh symbol info
      this.refreshSymbolInfo(this.symbolList[i],symbolInfo);   
      //printf(SYMBOL_LIST[i] + "_before Rate:" + SYMBOL_RATE[i]);      
      SYMBOL_TICK_VALUE[i]=symbolInfo.TickValue();
      //printf(SYMBOL_LIST[i] + "_after Rate:" + SYMBOL_RATE[i]);
   }   
}

//+------------------------------------------------------------------+
//|  get symbol index
//+------------------------------------------------------------------+
int CSymbolInfos::getSymbolIndex(string symbol){ 
   for(int i=0;i<ArraySize(symbolList);i++){
      if(this.symbolList[i]==symbol)
         return i;   
   }
   return -1;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSymbolInfos::CSymbolInfos(){                       
   ArrayCopy(this.symbolList,SYMBOL_LIST);                           
   ArrayCopy(this.symbolRate,SYMBOL_RATE);     
   ArrayInitialize(this.refreshSymbols,false);
   ArrayInitialize(this.symbolRate,1);
}
CSymbolInfos::~CSymbolInfos(){

   for (int i = 0; i < ArraySize(symbolList); i++) {
      CSymbolInfo* symbolInfo;
      CHashMap<string,CSymbolInfo*> symbolInfos;
      if(this.symbolInfos.TryGetValue(symbolList[i],symbolInfo)){
         delete symbolInfo;      
      }      
   }    
   symbolInfos.Clear();
}
//+------------------------------------------------------------------+