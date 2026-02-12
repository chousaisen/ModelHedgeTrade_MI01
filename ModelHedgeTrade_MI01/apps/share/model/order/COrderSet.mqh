//+------------------------------------------------------------------+
//|                                                 orderset.mqh |
//|                                  Copyright 2024, RkeeCom Ltd.    |
//|                                             
//+------------------------------------------------------------------+
#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>

#include "COrder.mqh"
#include "..\..\..\comm\CLog.mqh"

class COrderSet
  {
   private:
      CHashMap<int,COrder*> orderset;
      CArrayList<int> keys;     //keys--orderIndex
      
      //+------------------------------------------------------------------+
      //|  model control param
      //+------------------------------------------------------------------+  
      int     modelKind;        //model kind
      ulong   modelId;          //model id (magicId--getUniqueInt()) 
      int     symbolIndex;  
      string  symbol;          //model symbol
      
   public:
       COrderSet(void);
      ~COrderSet(void);
      
      //add/remove order to order set
      void    add(COrder *order);
      void    remove(COrder *order);
      
      //get order Count
      int     count();
      
      //clean the order set
      void    clean();
      
      //get the order by key
      COrder* getOrder(int key);
      
      //get the order keys
      CArrayList<int>* getKeys();      
      
      //+------------------------------------------------------------------+
      //|  Getters and Setters
      //+------------------------------------------------------------------+            
      // get modelKind
      int getModelKind() const;
      
      // set modelKind
      void setModelKind(int value);
      
      // get modelId
      ulong getModelId() const;
      
      // set modelId
      void setModelId(ulong value);  
      
      // get symbol
      string getSymbol() const;
      
      // set symbol
      void setSymbol(string value);    
      
      // get symbol index
      int getSymbolIndex() const;
      
      // set symbol index
      void setSymbolIndex(int value);                
};


//+------------------------------------------------------------------+
//|  add order
//+------------------------------------------------------------------+
void COrderSet::add(COrder *order){

   this.keys.Add(order.getOrderIndex());
   this.orderset.Add(order.getOrderIndex(),order);
}

//+------------------------------------------------------------------+
//|  remove order by order index
//+------------------------------------------------------------------+
void COrderSet::remove(COrder *order){
   this.orderset.Remove(order.getOrderIndex());
   this.keys.Remove(order.getOrderIndex());
   if(this.keys.Count()==0){
      this.orderset.Clear();   
      this.keys.Clear();
   }
}

//+------------------------------------------------------------------+
//|  get order count
//+------------------------------------------------------------------+
int COrderSet::count(){
   return this.keys.Count();
}

//+------------------------------------------------------------------+
//|  clean order
//+------------------------------------------------------------------+
void COrderSet::clean(){
   for (int i = this.keys.Count()-1; i >=0 ; i--) {         
      int key;
      this.keys.TryGetValue(i,key);
      COrder *order;
      if(this.orderset.TryGetValue(key,order)){
         if(order.getTradeStatus()==TRADE_STATUS_CLOSE
            || order.getTradeStatus()==TRADE_STATUS_ERROR_OPEN){
            this.orderset.Remove(key);
            this.keys.Remove(key);
            if(order.getErrorCode()>0){               
               rkeeLog.printOrderError(order," OrderSet remove order> orderCount:" + this.count()); 
            }
            order.setTradeStatus(TRADE_STATUS_CLEAR);
         }
      }
   }
}

//+------------------------------------------------------------------+
//|  get order by key
//+------------------------------------------------------------------+
COrder* COrderSet::getOrder(int key){
   COrder *order;
   if(this.orderset.TryGetValue(key,order)){
      return order;
   }
   return NULL;
}

//+------------------------------------------------------------------+
//|  get order keys
//+------------------------------------------------------------------+
CArrayList<int>* COrderSet::getKeys(){
   return &this.keys;
}

//+------------------------------------------------------------------+
//|  get modelKind
//+------------------------------------------------------------------+
int COrderSet::getModelKind() const
{
    return modelKind;
}

//+------------------------------------------------------------------+
//|  set modelKind
//+------------------------------------------------------------------+
void COrderSet::setModelKind(int value)
{
    modelKind = value;
}

//+------------------------------------------------------------------+
//|  get modelId
//+------------------------------------------------------------------+
ulong COrderSet::getModelId() const
{
    return modelId;
}

//+------------------------------------------------------------------+
//|  set modelId
//+------------------------------------------------------------------+
void COrderSet::setModelId(ulong value)
{
    modelId = value;
}

//+------------------------------------------------------------------+
//|  get symbol
//+------------------------------------------------------------------+
string COrderSet::getSymbol() const
{
    return symbol;
}

//+------------------------------------------------------------------+
//|  set symbol
//+------------------------------------------------------------------+
void COrderSet::setSymbol(string value)
{
    symbol = value;
}

//+------------------------------------------------------------------+
//|  get symbol index
//+------------------------------------------------------------------+
int COrderSet::getSymbolIndex(void) const
{
    return symbolIndex;
}

//+------------------------------------------------------------------+
//|  set symbol index
//+------------------------------------------------------------------+
void COrderSet::setSymbolIndex(int value)
{
    symbolIndex = value;
}
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
COrderSet::COrderSet(){}
COrderSet::~COrderSet(){
   for (int i = 0; i < this.keys.Count(); i++) {
      int key;
      this.keys.TryGetValue(i,key);
      COrder* order;
      //printf("delete signal source id:" + sourceId);      
      this.orderset.TryGetValue(key,order);
      delete order;
   } 
   this.keys.Clear();
   this.orderset.Clear();
}