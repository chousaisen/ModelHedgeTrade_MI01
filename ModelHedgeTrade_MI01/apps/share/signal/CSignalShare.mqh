//+------------------------------------------------------------------+
//|                                                  CSignalShare.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

//common define
#include "..\..\header\CDefine.mqh"
#include "..\..\comm\ComFunc.mqh"

//signal include
#include "CSignal.mqh"
#include "CSignalList.mqh"
#include "CSignalKindSet.mqh"
#include "CSignalTimeSet.mqh"

class CSignalShare
  {
private: 
      // signal kind set(signalKind-> day-> signalList)           
      CSignalKindSet      signalKindSet; 
      //key(SourceId-->ticket)
      CHashMap<ulong,CSignal*> signalMap; 
      //key list(signal sourceId list)
      CArrayList<ulong> signalSourceIdList;      
      //real signal list
      CSignalList*             realSignalList;        
public:
                     CSignalShare();
                    ~CSignalShare();
     
     //--- methods of initilize
     void            init(); 
     //--- refresh
     void            refresh(); 
     //--- run CSignalShare
     void            run();    
     
     //--- add signal to signal list
     void            addSignal(int kind,int day,CSignal *signal);

     //--- add signal to signal list
     void            addSignal(CSignal *signal);
     
     //--- get signal list
     CSignalList*    getSignalList(int kind);
     //--- set real current signal list
     void            setRealSignalList(CSignalList* signalList);
     //--- get real current signal list
     CSignalList*    getRealSignalList();
            
     //--- get signal
     CSignal*        getSignal(ulong sourceId);            
                
     //---clear order share when order not use
     void            clear();
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CSignalShare::init()
  {
   
  }
//+------------------------------------------------------------------+
//|  run the share control
//+------------------------------------------------------------------+
void CSignalShare::run()
  {
   
  }   
  

//+------------------------------------------------------------------+
//|  add signal list
//+------------------------------------------------------------------+
void CSignalShare::addSignal(int kind,int day,CSignal *signal)
{
   this.signalKindSet.addSignalList(kind,day,signal);
   this.signalMap.Add(signal.getSourceId(),signal);
}  


//+------------------------------------------------------------------+
//|  add signal list
//+------------------------------------------------------------------+
void CSignalShare::addSignal(CSignal *signal)
{   
   this.signalKindSet.addSignalList(signal.getSignalKind(),
                                       comFunc.timeToYearDay(signal.getStartTime()),
                                       signal);
   this.signalMap.Add(signal.getSourceId(),signal);
}  


//+------------------------------------------------------------------+
//|  add signal list
//+------------------------------------------------------------------+
CSignalList* CSignalShare::getSignalList(int kind)
{

   //comFunc.printfs("CSignalShare::getSignalList--> kind:" + kind + "  day:" + comFunc.timeToYearDay(TimeCurrent()));
   return signalKindSet.getSignalList(kind,comFunc.timeToYearDay(TimeCurrent()));
}    

//+------------------------------------------------------------------+
//|  add signal list
//+------------------------------------------------------------------+
void  CSignalShare::setRealSignalList(CSignalList* signalList){
   this.realSignalList=signalList;
}
//--- get real current signal list
CSignalList*  CSignalShare::getRealSignalList(){
   return this.realSignalList;
}

//+------------------------------------------------------------------+
//|  add signal list
//+------------------------------------------------------------------+
CSignal*  CSignalShare::getSignal(ulong sourceId){

   CSignal *signal;            
   if(this.signalMap.TryGetValue(sourceId,signal)){
      return signal;      
   }
   return NULL;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSignalShare::CSignalShare(){}
CSignalShare::~CSignalShare(){
   for (int i = 0; i < this.signalSourceIdList.Count(); i++) {
      ulong sourceId;
      this.signalSourceIdList.TryGetValue(i,sourceId);
      CSignal* signal;      
      //printf("delete signal source id:" + sourceId);      
      this.signalMap.TryGetValue(sourceId,signal);
      delete signal;
   }       
}