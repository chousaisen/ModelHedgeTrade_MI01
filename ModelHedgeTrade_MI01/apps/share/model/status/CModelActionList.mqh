//+------------------------------------------------------------------+
//|                                                 CModelActionList.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\HashMap.mqh>

#include "..\..\..\header\symbol\CHeader.mqh"
#include "CModelAction.mqh"

class CModelActionList
  {
   private:
      //model status
      int                               actionIndex;
      CHashMap<int,CModelAction*>       actionMap;   
   public:
                                        CModelActionList();
                                        ~CModelActionList(); 
      //--- new action
      void                              nextAction(int action);
      void                              nextAction(int actionIndex,int action);
      //--- get current action
      CModelAction*                     currentAction();
      //--- get pre action
      CModelAction*                     preAction();
      //--- get pre action
      CModelAction*                     getAction(int actionIndex); 
      //--- get action index
      int                               getActionIndex();                                                         
};

//+------------------------------------------------------------------+
//|  next action
//+------------------------------------------------------------------+
void CModelActionList::nextAction(int actionIndex,int action){
   CModelAction* modelAction=new CModelAction();
   this.actionMap.Add(actionIndex,modelAction);
}

//+------------------------------------------------------------------+
//|  next action by current action index
//+------------------------------------------------------------------+
void CModelActionList::nextAction(int action){
   this.actionIndex++;
   this.nextAction(this.actionIndex,action);
}

//+------------------------------------------------------------------+
//|  get current action
//+------------------------------------------------------------------+
CModelAction* CModelActionList::currentAction(){   
   CModelAction *modelAction;
   if(this.actionMap.TryGetValue(this.actionIndex,modelAction)){
      return modelAction;      
   }
   return NULL;
}

//+------------------------------------------------------------------+
//|  get previous action
//+------------------------------------------------------------------+
CModelAction* CModelActionList::preAction(){
   int preActionIndex=this.actionIndex-1;
   if(preActionIndex>=0){
      CModelAction *modelAction;
      if(this.actionMap.TryGetValue(preActionIndex,modelAction)){
         return modelAction;      
      }
   }
   return NULL;
}

//+------------------------------------------------------------------+
//|  get action by action index
//+------------------------------------------------------------------+
CModelAction* CModelActionList::getAction(int actionIndex){   
   CModelAction *modelAction;
   if(this.actionMap.TryGetValue(actionIndex,modelAction)){
      return modelAction;      
   }
   return NULL;
}

//+------------------------------------------------------------------+
//|  get action index
//+------------------------------------------------------------------+
int CModelActionList::getActionIndex(){
   return this.actionIndex;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelActionList::CModelActionList(){
   this.actionIndex=0;
}
CModelActionList::~CModelActionList(){

}