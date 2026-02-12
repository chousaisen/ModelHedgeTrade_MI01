//+------------------------------------------------------------------+
//|                                                       Signal.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../../header/CDefine.mqh"
#include "CSignalAction.mqh"

class CSignal
  {
   private:
      
      ulong  sourceId;  //eg.ticketId, indicatorId
      bool   active;
      string symbol;
      int    symbolIndex;
      int    signalKind;
      int    modelKind;
      ulong sequence;
      int   signalType;
      ENUM_ORDER_TYPE tradeType;
      double price;
      double point;
      datetime startTime;
      datetime endTime;
      double   lot;
      ulong    signalId;
      
      //signal control parameter
      double   signalDiffPips;
            
      //+------------------------------------------------------------------+
      //| action control parameters
      //+------------------------------------------------------------------+        
      int actionIndex;     
      CArrayList<CSignalAction*> actionList;
      
      //status flag
      int      statusIndex;
      int      statusFlg;
      
   public:
         CSignal();
         CSignal(int signalKind,string symbol,ENUM_ORDER_TYPE tradeType,double lot,double price,datetime startTime,datetime endTime);
        ~CSignal();
                
      // Getter and Setter for sourceId
      int getSourceId() { return sourceId; }
      void setSourceId(int value) { sourceId = value; }
      
      // Getter and Setter for signalKind
      int getSignalKind() { return signalKind; }
      void setSignalKind(int value) { signalKind = value; }
      
      // Getter and Setter for modelKind
      int getModelKind() { return this.modelKind; }
      void setModelKind(int value) { this.modelKind = value; }      
      
      // Getter and Setter for signalType
      int getSignalType() { return signalType; }
      void setSignalType(int value) { signalType = value; }
      
      // Getter for signalId
      ulong getSignalId() { return signalId; }
      void  setSignalId(ulong value) { this.signalId=value; }
      
      // Getter for ActionIndex
      int getActionIndex() { return actionIndex; }
      
      // Getter and Setter for sequence
      ulong getSequence() { return sequence; }
      void setSequence(ulong value) { sequence = value; }
      
      // Getter and Setter for tradeType
      ENUM_ORDER_TYPE getTradeType() { return tradeType; }
      void setTradeType(ENUM_ORDER_TYPE value) { tradeType = value; }
      
      // Getter and Setter for lot
      double getLot() { return lot; }
      void setLot(double value) { lot = value; }
      
      // Getter and Setter for startTime
      datetime getStartTime() { return startTime; }
      void setStartTime(datetime value) { startTime = value; }
      
      // Getter and Setter for endTime
      datetime getEndTime() { return endTime; }
      void setEndTime(datetime value) { endTime = value; }
      
      // Getter and Setter for symbol
      string getSymbol() { return symbol; }
      void setSymbol(string value) { symbol = value; }
      
      // Getter and Setter for symbol index
      int getSymbolIndex() { return symbolIndex; }
      void setSymbolIndex(int value) { symbolIndex = value; }      

      // Getter and Setter for symbol signal Diff Pips
      double getSignalDiffPips() { return signalDiffPips; }
      void setSignalDiffPips(int value) { signalDiffPips = value; } 
      
      // get status index
      int  getStatusIndex(){return this.statusIndex;}
      void setStatusIndex(int value){this.statusIndex=value;} 
      
      // get status flag
      int  getStatusFlg(){return this.statusFlg;}
      void setStatusFlg(int value){this.statusFlg=value;}                      
      
      //+------------------------------------------------------------------+
      //|  define the signal control funtion
      //+------------------------------------------------------------------+      
      // Getter Setter for price
      double getPrice() { return this.price; }
      void   setPrice(double value){this.price=value;} 
      // Getter Setter for point
      double getPoint() { return this.point; }
      void   setPoint(double value){this.point=value;} 
      
      //get the actived seconds
      int   activeSeconds();
      
      //judge is active
      bool  isActive();
      
      //add signal action 
      void addAction(CSignalAction* signalAction);
      
      //get Action List
      CArrayList<CSignalAction*>* getActionList();
  };
  
//+------------------------------------------------------------------+
//|  get the actived seconds
//+------------------------------------------------------------------+
int CSignal::activeSeconds(){
   if(this.startTime>0 && TimeCurrent()>=this.startTime){
      return (TimeCurrent()-this.startTime);
   }
   return -1;
}        

//+------------------------------------------------------------------+
//|  judge is active
//+------------------------------------------------------------------+
bool CSignal::isActive(){                        
   int activeSeconds=this.activeSeconds();            
   if(activeSeconds>=0 && activeSeconds<SIGNAL_ACTIVE_SECONDS){
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//|  add signal action 
//+------------------------------------------------------------------+
void CSignal::addAction(CSignalAction* signalAction){      
   this.actionList.Add(signalAction);
   this.actionIndex=this.actionList.Count()-1;
}

//+------------------------------------------------------------------+
//|  get action list
//+------------------------------------------------------------------+
CArrayList<CSignalAction*>* CSignal::getActionList(){      
   return &this.actionList;
}
  
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSignal::CSignal()
{
   this.active=false;
   //control param
   this.actionIndex=0;
   //status flag
   this.statusFlg=STATUS_NONE;
}
  
CSignal::CSignal(int signalKind,string symbol,ENUM_ORDER_TYPE tradeType,
                  double lot,double price,datetime startTime,datetime endTime)
{
   this.active=false;
   this.signalKind=signalKind;   
   this.symbol=symbol;
   this.tradeType=tradeType;
   this.lot=lot;
   this.price=price;
   this.startTime=startTime;
   this.endTime=endTime;   
   ulong timestamp = GetTickCount();
   this.signalId = (timestamp << 16) | (MathRand() & 0xFFFF);             
   this.sourceId=this.signalId;
   //control param
   this.actionIndex=0;
}  
CSignal::~CSignal(){
   //CArrayList<CSignalAction*> actionList;
   for (int i = 0; i < this.actionList.Count(); i++) {
      CSignalAction* action;
      this.actionList.TryGetValue(i,action);
      delete action;
   }
}
