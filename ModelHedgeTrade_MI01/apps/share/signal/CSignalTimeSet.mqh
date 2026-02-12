//+------------------------------------------------------------------+
//|                                                SignalTimeSet.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>
#include "CSignal.mqh"
#include "CSignalList.mqh"

class CSignalTimeSet
  {
private:
      int signalKind;
      CHashMap<int,CSignalList*> signalTimeSet;
      //time list(YYYYMMDD)
      CArrayList<int> signalDayList;  
            
      bool getSignalList(int curHour,CSignalList *&signalList){
         return this.signalTimeSet.TryGetValue(curHour,signalList);
      }
            
public:
      CSignalTimeSet();
      CSignalTimeSet(int signalKind);
     ~CSignalTimeSet();
                              
      CSignalList* getSignalList(int day){         
         CSignalList *signalList;
         if(!getSignalList(day,signalList)){
            signalList=new CSignalList();   
            this.signalTimeSet.Add(day,signalList);  
            this.signalDayList.Add(day); 
         }
         return signalList;
      }
      
      void addSignal(int day,CSignal *signal){
         CSignalList *signalList=getSignalList(day);
         signalList.add(signal);
      }           
      
      //+------------------------------------------------------------------+
      //| Clear the entire signalTimeSet
      //+------------------------------------------------------------------+      
      void clear(){
         this.signalTimeSet.Clear();
      }                
  };
//+------------------------------------------------------------------+
//|     Constructor: initializes 
//+------------------------------------------------------------------+
CSignalTimeSet::CSignalTimeSet()
  {
   this.signalKind=0;
  }
CSignalTimeSet::CSignalTimeSet(int signalKind)
  {
   this.signalKind=signalKind;
  }

//+------------------------------------------------------------------+
//|    Destructor: deletes objects
//+------------------------------------------------------------------+
CSignalTimeSet::~CSignalTimeSet()
{
   for (int i = 0; i < this.signalDayList.Count(); i++) {
      int signalDay;
      this.signalDayList.TryGetValue(i,signalDay);
      CSignalList* signalList;
      //printf("delete signal source id:" + sourceId);      
      this.signalTimeSet.TryGetValue(signalDay,signalList);
      delete signalList;
   }
}
//+------------------------------------------------------------------+
