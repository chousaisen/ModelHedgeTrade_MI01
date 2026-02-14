//+------------------------------------------------------------------+
//|                                                  ModelsRun01.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../apps/share/CShareCtl.mqh"
#include "../../apps/client/CClientCtl.mqh"
#include "../../apps/market/CMarketCtl.mqh"
#include "../../apps/indicator/CIndicatorCtl.mqh"
#include "../../apps/signal/CSignalCtl.mqh"
#include "../../apps/hedge/CHedgeCtl.mqh"
#include "../../apps/model/CModelCtl.mqh"
#include "../../apps/trade/CTradeCtl.mqh"
#include "../../apps/logger/CLogger.mqh"

 //+------------------------------------------------------------------+
//|  model logic custermlize 
//+------------------------------------------------------------------+
#include "../../apps/model/base/grid/m01/CModelGrid01Runner.mqh"
#include "../../apps/model/filter/open/CFilterOpen01.mqh"
#include "../../apps/model/filter/extend/CFilterExtend01.mqh"
#include "../../apps/model/filter/close/CFilterClose01.mqh"
#include "../../apps/model/filter/clear/CFilterClear01.mqh"
#include "../../apps/hedge/models/m01/CHedgeModel01.mqh"

class CRunerRe
  {
   private:
      CShareCtl             shareCtl;
      CClientCtl            clientCtl;
      CMarketCtl            marketCtl;
      CIndicatorCtl         indicatorCtl;
      CSignalCtl            signalCtl;
      CHedgeCtl             hedgeCtl;
      CModelCtl             modelCtl;
      CTradeCtl             tradeCtl;
      CHedgeModel01         hedgeModel01;
      CFilterOpen01         filterOpen01;
      CFilterExtend01       filterExtend01;
      CFilterClose01        filterClose01;
      CFilterClear01        filterClear01;
      
      //debug info
      int                   debugDiffSeconds;
   public:
                        CRunerRe();
                       ~CRunerRe();
         
         //+------------------------------------------------------------------+
         //|  comm methods
         //+------------------------------------------------------------------+       
         void            init();
         void            refreshIndicator();
         void            refreshOperation();      //commom refresh
         
         //+------------------------------------------------------------------+
         //|  open orders
         //+------------------------------------------------------------------+       
         void            open();        //open 
         void            openModels();    //open models
         void            extendModels();  //open models         
         
         //+------------------------------------------------------------------+
         //|  close orders
         //+------------------------------------------------------------------+       
         void            close();
         void            closeModels(); 
         
         //+------------------------------------------------------------------+
         //|  protect group(make new runner/group to protect current group orders)
         //+------------------------------------------------------------------+
         void           createProtectGroup();
         
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

         //+------------------------------------------------------------------+
         //|  debug info
         //+------------------------------------------------------------------+
         int           getDebugDiffSeconds(){return this.debugDiffSeconds;}
};

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CRunerRe::init()
  {
  
   //init logger
   logger.init(&this.shareCtl,&this.marketCtl);
   
   //init parameters
   this.clientCtl.init();
   this.shareCtl.init();   
   this.indicatorCtl.init(&shareCtl);   
   this.signalCtl.init(&this.indicatorCtl,&this.shareCtl);
   this.marketCtl.init(&this.shareCtl);
   this.hedgeCtl.init(&this.shareCtl);
   this.modelCtl.init(&this.shareCtl);
   this.tradeCtl.init(&this.shareCtl);
   
   //add indicator filter   
   this.filterOpen01.init(&this.shareCtl);
   this.filterExtend01.init(&this.shareCtl);   
   this.filterClose01.init(&this.shareCtl);
   this.filterClear01.init(&this.shareCtl);
   this.shareCtl.setClientCtl(&this.clientCtl);
   this.shareCtl.getFilterShare().addOpenFilter(&this.filterOpen01);   
   this.shareCtl.getFilterShare().addExtendFilter(&this.filterExtend01);
   this.shareCtl.getFilterShare().addCloseFilter(&this.filterClose01);   
   this.shareCtl.getFilterShare().addClearFilter(&this.filterClear01);
   
   //make start runner
   this.hedgeModel01.init(&this.shareCtl);
   this.hedgeModel01.setStartGroupId(MODEL_KIND_01);
   this.hedgeModel01.startRunner(&this.modelCtl); 
   
   //debug info
   this.debugDiffSeconds=Debug_Diff_Seconds;   
        
   //load market orders
   this.reLoad(); 
}

//+------------------------------------------------------------------+
//|  commom refresh
//+------------------------------------------------------------------+
void CRunerRe::refreshIndicator(void){
   logData.begin();            //log begin
   this.shareCtl.refresh();      
   this.indicatorCtl.refresh();   
}


void CRunerRe::refreshOperation(){
   logData.begin();            //log begin      
   this.shareCtl.refresh();
   this.marketCtl.refresh();      
   this.hedgeCtl.refresh();
   this.modelCtl.refresh();
   
   //debug set
   if(this.shareCtl.getAnalysisShare().getCurRange().getStatusFlg()==STATUS_RANGE_INNER){
      this.debugDiffSeconds=Debug_Diff_Seconds;
   }else{
      this.debugDiffSeconds=Debug_Diff_Brk_Seconds;
   }
   
}

//+------------------------------------------------------------------+
//|  open orders 
//+------------------------------------------------------------------+
void CRunerRe::open()
{ 
   //this.indicatorCtl.refresh();
   this.extendModels();
   this.openModels();     
}   

//+------------------------------------------------------------------+
//|  close orders 
//+------------------------------------------------------------------+
void CRunerRe::close()
{   
   logData.reset();   
   //this.indicatorCtl.refresh();   
   logger.log_Indicator("indicator01");
   logData.reset();
   this.closeModels();
   logger.log_TradeClose("filterClose02");
}

//+------------------------------------------------------------------+
//|  open orders /models
//+------------------------------------------------------------------+
void CRunerRe::openModels()
{    
   logger.debugReset();
   
   //commom refresh
   this.refreshOperation();
   logger.log_GroupHedgeInfo(&this.modelCtl);
   
   //open models    
   this.modelCtl.openModels(); 
   
   logger.log_ModelsOpen(&this.modelCtl);      //-- log info(model open)
   
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
void CRunerRe::extendModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.refreshOperation();
   
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
void CRunerRe::closeModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.refreshOperation();
   
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
//|  close orders /models---clear risk model
//+------------------------------------------------------------------+
void CRunerRe::clearRiskModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.refreshOperation();
   
   //protect models
   this.modelCtl.clearRiskModels();
   
   //trade close
   int closeCount=this.tradeCtl.closeTrade(); 
   //debug info
   if(closeCount>0){
      if(Debug_Clear)logger.printDebugInfo("clearRiskModels");
   }        
} 

//+------------------------------------------------------------------+
//|  close orders /models---clear plus model
//+------------------------------------------------------------------+
void CRunerRe::clearPlusModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.refreshOperation();
   
   //protect models
   this.modelCtl.clearPlusModels();
   
   //trade close
   int closeCount=this.tradeCtl.closeTrade(); 
   //debug info
   if(closeCount>0){
      if(Debug_Clear_Plus)logger.printDebugInfo("clearPlusModels");
   }        
} 

//+------------------------------------------------------------------+
//|  close orders /models---clear minus model
//+------------------------------------------------------------------+
void CRunerRe::clearMinusModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.refreshOperation();
   
   //protect models
   this.modelCtl.clearMinusModels();
   
   //trade close
   int closeCount=this.tradeCtl.closeTrade(); 
   //debug info
   if(closeCount>0){
      if(Debug_Clear_Minus)logger.printDebugInfo("clearMinusModels");
   }        
} 


//+------------------------------------------------------------------+
//|  close orders /models---clear exceed model
//+------------------------------------------------------------------+
void CRunerRe::clearExceedModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.refreshOperation();
   
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
void CRunerRe::clearPreExceedModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.refreshOperation();
   
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
void CRunerRe::clearOverModels(void)
{ 
   logger.debugReset();
   
   //commom refresh
   this.refreshOperation();
   
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
void CRunerRe::createProtectGroup(){

   //commom refresh
   this.refreshOperation();
   
   //protect group
   this.hedgeModel01.protectRiskGroup(true);
   
   logger.log_RiskGroupInfo();                  //-- risk group info
}


//+------------------------------------------------------------------+
//|  close orders /models
//+------------------------------------------------------------------+
void CRunerRe::reLoad(void){

   //load market orders(when exist orders)
   int modelKindCount=this.marketCtl.loadOrders();
   if(modelKindCount>0){
      this.hedgeModel01.reload(modelKindCount);      
      this.shareCtl.reload();
      this.modelCtl.reLoadModels();
   }else{
      this.shareCtl.getRecoveryShare().clearRangeReData();
   }

}
//+------------------------------------------------------------------+
//|    class constructor   
//+------------------------------------------------------------------+
CRunerRe::CRunerRe(){
}
CRunerRe::~CRunerRe(){
}