//+------------------------------------------------------------------+
//|                                                   CSignalModel.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

//common define
#include "..\..\..\header\CDefine.mqh"
#include "..\..\..\comm\ComFunc.mqh"

#include "..\..\..\share\CShareCtl.mqh"
#include "..\..\..\share\signal\CSignal.mqh"
#include "..\..\..\share\signal\CSignalList.mqh"
#include "..\..\..\header\symbol\CHeader.mqh"

class CSignalModel{
  
      private:
            CShareCtl            *shareCtl;
            CSignalList          signalList;
            CArrayList<string>   exceptSymbolList;            
      public:
      
                     CSignalModel();
                    ~CSignalModel();
     //--- methods of initilize
     void           init(CShareCtl* shareCtl);  
     //--- run indicator
     void           run();
     //--- get signal list
     CSignalList*   getSignalList();
     //--- make signal list
     void           makeSignalList();
     //--- create signal
     CSignal*       createSignal(/*int signalKind,*/string symbol,ENUM_ORDER_TYPE type,double lot);    
     //--- add except symbol
     void           addExceptSymbol(string symbol); 
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CSignalModel::init(CShareCtl* shareCtl){
   this.shareCtl=shareCtl;
   //this.makeSignalList();
}

//+------------------------------------------------------------------+
//|  add except symbol
//+------------------------------------------------------------------+  
void CSignalModel::addExceptSymbol(string symbol){
   this.exceptSymbolList.Add(symbol);
}  
  
//+------------------------------------------------------------------+
//|  run the muti signals
//+------------------------------------------------------------------+
void CSignalModel::run()
{

}    

//+------------------------------------------------------------------+
//| get signal list
//+------------------------------------------------------------------+  
CSignalList*   CSignalModel::getSignalList(){
   return &this.signalList;
}

//+------------------------------------------------------------------+
//| set signal id
//+------------------------------------------------------------------+  
void  makeSignalId(CSignal* signal){
   ulong fixUniqueNumber=comFunc.getFixUniqueN9();
   signal.setSourceId(fixUniqueNumber);
   signal.setSignalId(fixUniqueNumber);
}

//+------------------------------------------------------------------+
//| create signal list
//+------------------------------------------------------------------+  
void   CSignalModel::makeSignalList(){   
   int symbolCount=ArraySize(SYMBOL_LIST);
   bool  customSymbol=false;
   string symbolList=Symbol_Trade_List1 + "," + Symbol_Trade_List2 + "," + Symbol_Trade_List3;
   if(StringLen(symbolList)>2)customSymbol=true;   
   
   for(int i=0;i<symbolCount;i++){      
      if(exceptSymbolList.Contains(SYMBOL_LIST[i]))continue;
      if(customSymbol && StringFind(symbolList,SYMBOL_LIST[i])<0)continue;
      CSignal* signal=this.createSignal(SYMBOL_LIST[i],ORDER_TYPE_BUY,Comm_Unit_LotSize);
      this.signalList.add(signal);
   }   
   for(int i=0;i<symbolCount;i++){      
      if(exceptSymbolList.Contains(SYMBOL_LIST[i]))continue;
      if(customSymbol && StringFind(symbolList,SYMBOL_LIST[i])<0)continue;
      CSignal* signal=this.createSignal(SYMBOL_LIST[i],ORDER_TYPE_SELL,Comm_Unit_LotSize);
      this.signalList.add(signal);
   }
      
}
//+------------------------------------------------------------------+
//| create signal by defined parameter
//+------------------------------------------------------------------+  
CSignal* CSignalModel::createSignal(//int signalKind,
                                    string symbol,
                                    ENUM_ORDER_TYPE type,
                                    double lot){
          
   datetime trade_time=TimeCurrent();   
   
   CSignal*  curSignal=new CSignal(); 
   curSignal.setSignalType(SIGNAL_TYPE_OPEN);
   //curSignal.setSignalKind(signalKind);
   
   // Get trade time
   curSignal.setStartTime(trade_time);
      
   // create sourceId.ticket
   //deal_number = StringToInteger(StringSubstr(line, deal_pos, space_after_deal - deal_pos));
   //curSignal.setSourceId(comFunc.makeSignalSourceId(signalKind,this.SymbolIndex,deal_number));   

   // set trade type
   curSignal.setTradeType(type);

   // set lot size
   curSignal.setLot(lot);
   
   // Find and extract currency pair      
   int    symbolIndex=this.shareCtl.getSymbolShare().getSymbolIndex(symbol);
   curSignal.setSymbol(symbol);
   curSignal.setSymbolIndex(symbolIndex);
   //double curPrice=this.shareCtl.getSymbolShare().getSymbolPrice(symbol,type);
   //double curPoint=this.shareCtl.getSymbolShare().getSymbolPoint(symbol);
   //curSignal.setPrice(curPrice);
   //curSignal.setPoint(curPoint);

   CSignalAction* signalAction=new CSignalAction();
   signalAction.setSignalType(SIGNAL_TYPE_OPEN);
   signalAction.setDealTime(trade_time);
   signalAction.setLot(lot);
   curSignal.addAction(signalAction);

   return curSignal;
}
   
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSignalModel::CSignalModel(){
}
CSignalModel::~CSignalModel(){}