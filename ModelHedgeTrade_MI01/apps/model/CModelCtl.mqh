//+------------------------------------------------------------------+
//|                                                   CModelCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../header/model/CHeader.mqh"
#include "../share/CShareCtl.mqh"
#include "../share/filter/CFilterShare.mqh"
#include "filter/CModelFilter.mqh"
#include "protect/CModelProtect.mqh"
//#include "protect/CModelClearPlus.mqh"
//#include "protect/CModelClearMinus.mqh"
#include "protect/CModelClearExceed.mqh"
#include "protect/CModelClearPreExceed.mqh"
#include "protect/CModelClearOver.mqh"
#include "CModelRunnerI.mqh"
#include "CModelRunner.mqh"

class CModelCtl
  {
      private:
            CShareCtl                  *shareCtl;
            CFilterShare               *filterShare;
            CArrayList<CModelRunnerI*> runnerList;
            //CModelClearMinus           modelClearMinus;
            //CModelClearPlus            modelClearPlus;
            CModelClearExceed          modelClearExceed;
            CModelClearPreExceed       modelClearPreExceed;
            CModelClearOver            modelClearOver;
      public:
                           CModelCtl();
                          ~CModelCtl();
           //--- methods of initilize
           void            init(CShareCtl *shareCtl);            
           //--- add runner
           void            addRunner(CModelRunnerI *runner);  
           //--- refresh model list
           void            refresh(); 
           //--- open/run model list
           void            openModels(); 
           //--- extend/run model list
           void            extendModels();
           //--- extend/run model list
           void            closeModels(); 
           //--- protect models clear risk model
           void            clearRiskModels();
           //--- protect models clear plus model
           void            clearPlusModels();
           //--- protect models clear minus model
           void            clearMinusModels();
           //--- protect models clear exceed model
           void            clearExceedModels();   
           //--- protect models clear previous exceed model
           void            clearPreExceedModels();   
           //--- protect models clear over model
           void            clearOverModels();                     
           //--- reload models
           void            reLoadModels();
           //--- get runner list
           CArrayList<CModelRunnerI*>* getRunnerList(); 
           //--- get runner
           CModelRunnerI* getRunner(int modelKind); 
           //--- set hedge except mode
           void            setHedgeExceptMode(bool value);         
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CModelCtl::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.filterShare=shareCtl.getFilterShare();
   //this.modelClearMinus.init(shareCtl);
   //this.modelClearPlus.init(shareCtl);
   this.modelClearExceed.init(shareCtl);
   this.modelClearPreExceed.init(shareCtl);
   this.modelClearOver.init(shareCtl);
}
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CModelCtl::addRunner(CModelRunnerI *runner)
{
   runner.init(this.shareCtl);
   this.runnerList.Add(runner);      
   
}

//+------------------------------------------------------------------+
//|   get runner list
//+------------------------------------------------------------------+           
CArrayList<CModelRunnerI*>* CModelCtl::getRunnerList(){
   return &this.runnerList;
}

//+------------------------------------------------------------------+
//|  refresh models
//+------------------------------------------------------------------+
void CModelCtl::refresh()
{     
   //this.shareCtl.getModelShare().refresh();
   CArrayList<CModelI*> modelList=this.shareCtl.getModelShare().getModels();
   int modelCount=modelList.Count();
   //clean model list
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){                  
         model.refresh();
      }
   }    
   this.shareCtl.getModelShare().refresh();   
} 

//+------------------------------------------------------------------+
//|  open run the models by muti signals
//+------------------------------------------------------------------+
void CModelCtl::openModels()
{  
   
   rkeeLog.writeLmtLog("CModelCtl: openModels_1");   

   rkeeLog.writeLmtLog("CModelCtl: openModels_2 " + runnerList.Count());
   
   //this.shareCtl.getModelShare().refresh();
   for (int i = 0; i < runnerList.Count(); i++) {   
      rkeeLog.writeLmtLog("CModelCtl: openModels_3");   
      CModelRunnerI* runner;
      runnerList.TryGetValue(i,runner);
      if(runner.openModels()>0)break;
   }     
}    

//+------------------------------------------------------------------+
//|  extend run the models by muti signals
//+------------------------------------------------------------------+
void CModelCtl::extendModels()
{  
   //this.shareCtl.getModelShare().refresh();
   CArrayList<CModelI*> modelList=this.shareCtl.getModelShare().getModels();
   int modelCount=modelList.Count();
   //clean model list
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){
         model.refresh();
         if(model.enableExtend() && this.filterShare.extendFilter(model)){            
            if(model.extendModel())break;   //modify 20250522
         }
      }
   }   
}  

//+------------------------------------------------------------------+
//|  extend run the models by muti signals
//+------------------------------------------------------------------+
void CModelCtl::closeModels()
{  
   //this.shareCtl.getModelShare().refresh();
   this.setHedgeExceptMode(true);
   CArrayList<CModelI*> modelList=this.shareCtl.getModelShare().getModels();
   int modelCount=modelList.Count();
   //clean model list
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){         
         model.refresh();
         if(model.enableClose() && this.filterShare.closeFilter(model)){
            if(model.closeModel()){
               model.markClearFlag(true);
               this.shareCtl.getHedgeShare().getHedgeGroupPool().hedgeOrders();
               if(GRID_CLOSE_ANALYSIS_REFRESH){
                  this.shareCtl.getModelShare().getModelAnalysisPre().makeAnalysisData(model.getSymbolIndex(),&modelList);
               }
            }
         }
      }
   }  
   this.setHedgeExceptMode(false); 
}  

//+------------------------------------------------------------------+
//|  protect models
//+------------------------------------------------------------------+
void CModelCtl::clearRiskModels(){   
   //other risk clear
   this.filterShare.refresh();
   this.setHedgeExceptMode(true);
   CArrayList<CModelI*> modelList=this.shareCtl.getModelShare().getModels();
   int modelCount=modelList.Count();
   //clean model list
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){         
         model.refresh();
         if(this.filterShare.clearFilter(model)){
            model.clearModel();            
         }
      }
   }
   this.setHedgeExceptMode(false);  
}           

//+------------------------------------------------------------------+
//|  protect models clear plus models
//+------------------------------------------------------------------+
/*
void CModelCtl::clearPlusModels(){  
   this.setHedgeExceptMode(true);   
   modelClearPlus.clearPlusModels();
   this.setHedgeExceptMode(false);    
} */  

//+------------------------------------------------------------------+
//|  protect models clear minus models
//+------------------------------------------------------------------+
/*
void CModelCtl::clearMinusModels(){
   this.setHedgeExceptMode(true);   
   if(modelClearMinus.clearRiskModels()<=0){
      modelClearMinus.clearMinusModels(); 
   }   
   this.setHedgeExceptMode(false);   
}*/

//+------------------------------------------------------------------+
//|  protect models clear exceed models
//+------------------------------------------------------------------+
void CModelCtl::clearExceedModels(){
   this.setHedgeExceptMode(true);   
   modelClearExceed.clearExceedModels();
   this.setHedgeExceptMode(false);  
}

//+------------------------------------------------------------------+
//|  protect models clear previous exceed models
//+------------------------------------------------------------------+
void CModelCtl::clearPreExceedModels(){
   this.setHedgeExceptMode(true);   
   modelClearPreExceed.clearExceedModels();
   this.setHedgeExceptMode(false);  
}

//+------------------------------------------------------------------+
//|  protect models clear over models
//+------------------------------------------------------------------+
void CModelCtl::clearOverModels(){
   this.setHedgeExceptMode(true);   
   modelClearOver.clearOverModels();
   this.setHedgeExceptMode(false);  
}

//+------------------------------------------------------------------+
//|  set hedge except mode
//+------------------------------------------------------------------+
void  CModelCtl::setHedgeExceptMode(bool value){
   this.shareCtl.getHedgeShare().getHedgeGroupPool().setExceptMode(value);
}
           
//+------------------------------------------------------------------+
//|  get runner by model kind
//+------------------------------------------------------------------+
CModelRunnerI* CModelCtl::getRunner(int modelKind)
{  
   for (int i = 0; i < runnerList.Count(); i++) {   
      CModelRunnerI* runner;
      runnerList.TryGetValue(i,runner);
      if(runner.getModelKind()==modelKind){
         return runner;
      }
   }
   return NULL;  
}    
           
//+------------------------------------------------------------------+
//|  reload models
//+------------------------------------------------------------------+
void CModelCtl::reLoadModels(){
   for (int i = 0; i < this.runnerList.Count(); i++) {   
      CModelRunnerI* runner;
      if(runnerList.TryGetValue(i,runner)){
         runner.reLoadModels();
      }      
   }
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelCtl::CModelCtl(){}
CModelCtl::~CModelCtl(){
   for (int i = 0; i < this.runnerList.Count(); i++) {
      CModelRunnerI* runner;
      this.runnerList.TryGetValue(i,runner);
      delete runner;
   }
}