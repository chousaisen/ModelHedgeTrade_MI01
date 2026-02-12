//+------------------------------------------------------------------+
//|                                                   SignalList.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include "CSignal.mqh"

class CSignalList
  {
private:
      CArrayList<CSignal*> signalList;
public:
      CSignalList();
     ~CSignalList();
     
     void add(CSignal *signal){
         this.signalList.Add(signal);
     }
     
     void clear(){
      this.signalList.Clear();
     }
     
     int Count(){
      return this.signalList.Count();
     }
     
     //sample code
     void add(){
         CSignal* signal=new CSignal();
         this.add(signal);
     }
     
     CSignal* getSignal(int index){
         CSignal* signal;
         if(this.signalList.TryGetValue(index,signal)){
            return signal;
         }
         return NULL;   
     }
        
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalList::CSignalList()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalList::~CSignalList()
  {
   for (int i = 0; i < signalList.Count(); i++) {
      CSignal* signal;
      signalList.TryGetValue(i,signal);
      delete signal;      
   }
  }
//+------------------------------------------------------------------+
