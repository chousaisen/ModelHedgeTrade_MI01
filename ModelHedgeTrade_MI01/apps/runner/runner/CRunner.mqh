//+------------------------------------------------------------------+
//|                                                  ModelsRun01.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../comm/CLog.mqh"
#include "../../share/CShareCtl.mqh"
#include "../../market/CMarketCtl.mqh"
#include "../../indicator/CIndicatorCtl.mqh"
#include "../../signal/CSignalCtl.mqh"
#include "../../model/CModelCtl.mqh"
#include "../../trade/CTradeCtl.mqh"
#include "../../hedge/CHedgeCtl.mqh"
//#include "../../logger/CLogger.mqh"

 //+------------------------------------------------------------------+
//|  model logic custermlize 
//+------------------------------------------------------------------+

class CRunner
  {
   public:
            
         //+------------------------------------------------------------------+
         //|    comm parameter
         //+------------------------------------------------------------------+   
         // modelKind(groupId)
         int                   modelKind;
         
         CClientCtl*           clientCtl;
         CIndicatorCtl*        indicatorCtl;     
         CMarketCtl            marketCtl;      
         CShareCtl             shareCtl;
         CSignalCtl            signalCtl;
         CModelCtl             modelCtl;
         CTradeCtl             tradeCtl;
         CHedgeCtl             hedgeCtl;         
         //+------------------------------------------------------------------+
         //|    class constructor   
         //+------------------------------------------------------------------+   
                        CRunner();
                       ~CRunner();
         
         //+------------------------------------------------------------------+
         //|  comm methods
         //+------------------------------------------------------------------+       
         void            init(CIndicatorCtl* indicatorCtl,CClientCtl*  clientCtl);
         void            refresh();
         void            marketRefresh();
         void            modelRefresh();
         void            hedgeRefresh();
         void            run();
         void            setModelKind(int modelKind);
         int             getModelKind();
         
         //+------------------------------------------------------------------+
         //|  open orders
         //+------------------------------------------------------------------+       
         void            openModels();    //open models
         void            extendModels();  //open models         
         
         //+------------------------------------------------------------------+
         //|  close orders
         //+------------------------------------------------------------------+       
         void            closeModels();         
         
         //+------------------------------------------------------------------+
         //|  clear risk models
         //+------------------------------------------------------------------+
         void           clearRiskModels();         
         void           clearPlusModels(); 
         void           clearMinusModels();
         void           clearExceedModels();
         void           clearPreExceedModels();
         void           clearOverModels();
         
         //+------------------------------------------------------------------+
         //|  reload info by market and indicator analysis
         //+------------------------------------------------------------------+ 
         void           reLoad();        
         

};

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CRunner::init(CIndicatorCtl* indicatorCtl,CClientCtl*  clientCtl)
  {
  
   //init logger
   logger.init(&this.shareCtl,&this.marketCtl);
   
   this.indicatorCtl=indicatorCtl;
   this.clientCtl=clientCtl;
   
   //init parameters
   this.shareCtl.init(indicatorCtl);
   this.shareCtl.setModelKind(this.modelKind);
   this.signalCtl.init(indicatorCtl,&this.shareCtl);
   this.marketCtl.init(&this.shareCtl);
   this.modelCtl.init(&this.shareCtl);
   this.tradeCtl.init(&this.shareCtl);
   this.hedgeCtl.init(&this.shareCtl);
   
   this.shareCtl.setClientCtl(this.clientCtl); 
   
   //load orders
   this.marketCtl.loadOrders();     
}

//+------------------------------------------------------------------+
//|  refresh indicator
//+------------------------------------------------------------------+
void CRunner::refresh(){
}

//+------------------------------------------------------------------+
//|  market status refresh(refresh must be done after trade deal)
//+------------------------------------------------------------------+
void CRunner::marketRefresh(){
   this.marketCtl.refresh();
}

//+------------------------------------------------------------------+
//|  model status refresh(refresh must be done after trade deal)
//+------------------------------------------------------------------+
void CRunner::modelRefresh(){
   this.modelCtl.refresh();
}

//+------------------------------------------------------------------+
//|  model status refresh(refresh must be done after trade deal)
//+------------------------------------------------------------------+
void CRunner::hedgeRefresh(){
   this.hedgeCtl.refresh();
}

//+------------------------------------------------------------------+
//|  comm run function(create detail by child class)
//+------------------------------------------------------------------+
void CRunner::run(){

}

//+------------------------------------------------------------------+
//|  set modelKind
//+------------------------------------------------------------------+
void CRunner::setModelKind(int modelKind){
   rkeeLog.writeLmtLog("CRunner: setModelKind1 " + modelKind);   
   this.modelKind=modelKind;   
}

//+------------------------------------------------------------------+
//|  set modelKind
//+------------------------------------------------------------------+
int CRunner::getModelKind(){
   return this.modelKind;
}


//+------------------------------------------------------------------+
//|  open orders /models
//+------------------------------------------------------------------+
void CRunner::openModels()
{    
   logger.debugReset();
   
   rkeeLog.writeLmtLog("CRunner: openModels_1");   
   
   //commom refresh
   this.marketRefresh();
   this.modelRefresh();
   this.hedgeRefresh();
   
   //open models    
   this.modelCtl.openModels(); 
   
   //trade open
   int openCount=this.tradeCtl.openTrade(); 
   
   //logger.log_ModelsStatus();                  //-- log info(model status)
   logger.log_OrdersStatus("orderStatus");     //-- log info(order status)
   
   //debug info   
   if(openCount>0){
      if(Debug_Open)logger.printDebugInfo("openModels");
   }
} 

//+------------------------------------------------------------------+
//|  extend orders /models
//+------------------------------------------------------------------+
void CRunner::extendModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.marketRefresh();
   this.modelRefresh();
   this.hedgeRefresh();
   
   //extend models
   this.modelCtl.extendModels();
   
   //trade open
   int openCount=this.tradeCtl.openTrade(); 
   //debug info   
   if(openCount>0){
      if(Debug_Extend)logger.printDebugInfo("extendModels");
   }       
} 

//+------------------------------------------------------------------+
//|  close orders /models
//+------------------------------------------------------------------+
void CRunner::closeModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.marketRefresh();
   this.modelRefresh();
   this.hedgeRefresh();
      
   //close models
   this.modelCtl.closeModels();
   
   //trade close
   int closeCount=this.tradeCtl.closeTrade(); 
   
   //debug info
   if(closeCount>0){
      if(Debug_Close)logger.printDebugInfo("closeModels");
   }    
} 


//+------------------------------------------------------------------+
//|  close orders /models---clear exceed model
//+------------------------------------------------------------------+
void CRunner::clearExceedModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.marketRefresh();
   this.modelRefresh();
   this.hedgeRefresh();
   
   //protect models
   this.modelCtl.clearExceedModels();
   
   //trade close
   int closeCount=this.tradeCtl.closeTrade(); 
   //debug info
   if(closeCount>0){
      if(Debug_Clear_Exceed)logger.printDebugInfo("clearExceedModels");
   }        
}


//+------------------------------------------------------------------+
//|  close orders /models---clear previous exceed model
//+------------------------------------------------------------------+
void CRunner::clearPreExceedModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.marketRefresh();
   this.modelRefresh();
   this.hedgeRefresh();
   
   //protect models
   this.modelCtl.clearPreExceedModels();
   
   //trade close
   int closeCount=this.tradeCtl.closeTrade(); 
   //debug info
   if(closeCount>0){
      if(Debug_Clear_PreExceed)logger.printDebugInfo("clearPreExceedModels");
   }        
}

//+------------------------------------------------------------------+
//|  close orders /models---clear over model
//+------------------------------------------------------------------+
void CRunner::clearOverModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.marketRefresh();
   this.modelRefresh();
   this.hedgeRefresh();
   
   //protect models
   this.modelCtl.clearOverModels();
   
   //trade close
   int closeCount=this.tradeCtl.closeTrade(); 
   //debug info
   if(closeCount>0){
      if(Debug_Clear_Over)logger.printDebugInfo("clearOverModels");
   }        
}

//+------------------------------------------------------------------+
//|  close orders /models
//+------------------------------------------------------------------+
void CRunner::reLoad(void){

   //load market orders(when exist orders)
   int modelKindCount=this.marketCtl.loadOrders();
   if(modelKindCount>0){
      //this.hedgeModel01.reload(modelKindCount);      
      this.shareCtl.reload();
      this.modelCtl.reLoadModels();
   }else{
      this.shareCtl.getRecoveryShare().clearRangeReData();
   }

}


//+------------------------------------------------------------------+
//|    class constructor   
//+------------------------------------------------------------------+
CRunner::CRunner(){
}
CRunner::~CRunner(){
}