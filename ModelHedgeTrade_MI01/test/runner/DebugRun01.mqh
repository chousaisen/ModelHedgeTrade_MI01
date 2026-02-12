//+------------------------------------------------------------------+
//|                                                  ModelsRun01.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../apps/share/CShareCtl.mqh"
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
#include "../../apps/model/filter/close/CFilterClose01.mqh"
#include "../../apps/model/filter/close/CFilterClose02.mqh"
#include "../../apps/model/filter/clear/CFilterClear01.mqh"
#include "../../apps/hedge/models/m01/CHedgeModel01.mqh"

class CRunerRe
  {
   private:
      CShareCtl             shareCtl;
      CMarketCtl            marketCtl;
      CIndicatorCtl         indicatorCtl;
      CSignalCtl            signalCtl;
      CHedgeCtl             hedgeCtl;
      CModelCtl             modelCtl;
      CTradeCtl             tradeCtl;
      CHedgeModel01         hedgeModel01;
      CFilterOpen01         filterOpen01;
      CFilterClose01        filterClose01;
      CFilterClose02        filterClose02;
      CFilterClear01        filterClear01;
   public:
                        CRunerRe();
                       ~CRunerRe();
         
         //+------------------------------------------------------------------+
         //|  comm methods
         //+------------------------------------------------------------------+       
         void            init();
         void            refresh();      //commom refresh
         
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
};

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CRunerRe::init()
  {
  
   //init logger
   logger.init(&this.shareCtl,&this.marketCtl);
   
   //init parameters
   this.shareCtl.init();
   this.indicatorCtl.init(&shareCtl);   
   this.signalCtl.init(&this.indicatorCtl,&this.shareCtl);
   this.marketCtl.init(&this.shareCtl);
   this.hedgeCtl.init(&this.shareCtl);
   this.modelCtl.init(&this.shareCtl);
   this.tradeCtl.init(&this.shareCtl);
   
   //add indicator filter
   this.filterOpen01.init(&this.shareCtl);
   this.filterClose01.init(&this.shareCtl);
   this.filterClose02.init(&this.shareCtl);
   this.filterClear01.init(&this.shareCtl);
   this.shareCtl.getFilterShare().addOpenFilter(&this.filterOpen01);
   this.shareCtl.getFilterShare().addCloseFilter(&this.filterClose01);
   this.shareCtl.getFilterShare().addCloseFilter(&this.filterClose02);
   this.shareCtl.getFilterShare().addClearFilter(&this.filterClear01);
   
   //load market orders
   this.marketCtl.loadOrders(); 
   
   //make start runner
   this.hedgeModel01.init(&this.shareCtl);
   this.hedgeModel01.setStartGroupId(MODEL_KIND_01);
   this.hedgeModel01.startRunner(&this.modelCtl); 
        
}

//+------------------------------------------------------------------+
//|  commom refresh
//+------------------------------------------------------------------+
void CRunerRe::refresh(){
   
   logData.reset();
   //reset data
   this.shareCtl.refresh();      
   this.indicatorCtl.refresh();
   logger.log_Indicator("indicator01");
   //logData.begin();            //log begin
   //this.marketCtl.refresh();      
   //this.hedgeCtl.refresh();
   //this.modelCtl.refresh();
   
   //int symbolIndex=this.shareCtl.getSymbolShare().getSymbolIndex("XAUUSD");
   
   //int curShiftN=this.shareCtl.getIndicatorShare().getPriceChlShiftLevel(symbolIndex);
   
   //printf("curShiftN:" + curShiftN);
   
}

//+------------------------------------------------------------------+
//|  open orders 
//+------------------------------------------------------------------+
void CRunerRe::open()
{ 
   //this.indicatorCtl.refresh();
   //this.extendModels();
   //this.openModels();     
}   

//+------------------------------------------------------------------+
//|  close orders 
//+------------------------------------------------------------------+
void CRunerRe::close()
{   
   //this.indicatorCtl.refresh();
   //this.closeModels();
}

//+------------------------------------------------------------------+
//|  open orders /models
//+------------------------------------------------------------------+
void CRunerRe::openModels()
{    
   //commom refresh
   this.refresh();
   logger.log_GroupHedgeInfo(&this.modelCtl);
   
   //open models    
   this.modelCtl.openModels(); 
   
   logger.log_ModelsOpen(&this.modelCtl);      //-- log info(model open)
   
   //trade open
   this.tradeCtl.openTrade(); 
   
   //logger.log_ModelsStatus();                  //-- log info(model status)
   logger.log_OrdersStatus("orderStatus");     //-- log info(order status)
} 

//+------------------------------------------------------------------+
//|  extend orders /models
//+------------------------------------------------------------------+
void CRunerRe::extendModels(void)
{ 
   //commom refresh
   this.refresh();
   
   //extend models
   this.modelCtl.extendModels();
   
   //trade open
   this.tradeCtl.openTrade();     
} 

//+------------------------------------------------------------------+
//|  close orders /models
//+------------------------------------------------------------------+
void CRunerRe::closeModels(void)
{ 
   //commom refresh
   this.refresh();
   
   //close models
   this.modelCtl.closeModels();
   
   //trade close
   this.tradeCtl.closeTrade();     
} 

//+------------------------------------------------------------------+
//|  close orders /models
//+------------------------------------------------------------------+
void CRunerRe::clearRiskModels(void)
{ 
   //commom refresh
   this.refresh();
   
   //protect models
   this.modelCtl.clearRiskModels();
   
   //trade close
   this.tradeCtl.closeTrade();     
} 

//+------------------------------------------------------------------+
//|  close orders /models
//+------------------------------------------------------------------+
void CRunerRe::createProtectGroup(){

   //commom refresh
   this.refresh();
   
   //protect group
   this.hedgeModel01.protectRiskGroup(true);
   
   logger.log_RiskGroupInfo();                  //-- risk group info
}

//+------------------------------------------------------------------+
//|    class constructor   
//+------------------------------------------------------------------+
CRunerRe::CRunerRe(){
}
CRunerRe::~CRunerRe(){
}