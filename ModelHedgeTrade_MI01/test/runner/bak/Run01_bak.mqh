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
#include "../../apps/model/CModelCtl.mqh"
#include "../../apps/trade/CTradeCtl.mqh"
#include "../../apps/logger/CLogger.mqh"

 //+------------------------------------------------------------------+
//|  model logic custermlize 
//+------------------------------------------------------------------+
#include "../../apps/model/base/grid/m01/CModelGrid01Runner.mqh"

class CRunerRe
  {
   private:
      CShareCtl             shareCtl;
      CMarketCtl            marketCtl;
      CIndicatorCtl         indicatorCtl;
      CSignalCtl            signalCtl;
      CModelCtl             modelCtl;
      CTradeCtl             tradeCtl;
      double                accountEquity;
      bool                  refreshAccountFlg;
   public:
                        CRunerRe();
                       ~CRunerRe();
       //--- init methods
        void            init();
       //--- run models
        void            run();
       //--- open orders
        void             open(); 
       //--- close orders 
        int             close();
       //--- clear setting
        void            clearMinus(); 
       //--- clear setting
        void            clearPlus(); 
       //--- refresh
       void             refresh(); 
       //--- make hedge group
       void makeHedgeGroup(int hedgeGroupId,
                            int hedgeCorrelationType,
                            double minCorrelationRate,
                            int protectModelKind,
                            int hedgeModelKind,
                            double startLot,                            
                            double symbolFreeLot,
                            double protectUnitProfit,
                            double removeProtectUnitProfit);
       //--- make runner                      
       void makeRunner(int signalKind,
                            int hedgeGroupId,
                            int modelKind,
                            int modelMaxCount,
                            int symbolModelMaxCount);
                            
      void makeHedgeGroupRunner(int signalKind,int groupId,
                                 int protectModelKind,int hedgeModelKind,
                                 double protectUnitProfit,double removeProtectUnitProfit,
                                 int hedgeGroupMaxCount,int hedgeGroupSymbolMaxCount);                            

      void addProtectModelToHedgeGroup(int hedgeGroupId,int protectModelKind);                            
      
      //--- confirm profit
      void confirmProfit();
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
   this.modelCtl.init(&this.shareCtl);
   this.tradeCtl.init(&this.shareCtl);
   
   //load market orders
   this.marketCtl.loadOrders();   
   
   int protectGroupMaxCount=36,baseGroupSymbolMaxCount=6;
   int hedgeGroupMaxCount=36,hedgeGroupSymbolMaxCount=3;
   
   double innerHedgeRate=Hedge_Inner_HedgeRate;
   double outHedgeRate=Hedge_Outer_HedgeRate;
   double startLotUnit=Hedge_Group_Start_LotUnit;
   double symbolFreeLotUnit=Hedge_Group_Symbol_Free_LotUnit;
   double protectUnitProfit=Hedge_Group_Protect_ProfitUnit;
   double removeProtectUnitProfit=Hedge_Group_RemoveProtect_ProfitUnit;

   CHedgeGroup* hedgeGroupPool=this.shareCtl.getHedgeShare().getHedgeGroupPool();
   hedgeGroupPool.setHedgeCorrelationType(HEDGE_CORRLELATION_OUTER_STRONG);
   hedgeGroupPool.setMinCorrelationRate(Hedge_Outer_HedgeRate); 
   hedgeGroupPool.setUseSymbolLotRate(Hedge_Use_Symbol_Lot_Rate);   

   //|   base group1
   this.makeHedgeGroup(HEDGE_GROUP_01,HEDGE_CORRLELATION_INNER_STRONG,innerHedgeRate,MODEL_KIND_01,0,
                                          startLotUnit,symbolFreeLotUnit,
                                          protectUnitProfit,removeProtectUnitProfit); 
                                           
   // base runner 01 (base model)  EA log  market signal
   this.makeRunner(SIGNAL_KIND_SIMILATION_01,HEDGE_GROUP_01,MODEL_KIND_01,protectGroupMaxCount,baseGroupSymbolMaxCount);

   double extProtectUnitProfit=protectUnitProfit*Comm_Grid_Begin_ExtendRate;
   double extRemoveProtectUnitProfit=removeProtectUnitProfit*Comm_Grid_Begin_ExtendRate;
      
   //|   hedge group1      
   this.makeHedgeGroup(HEDGE_GROUP_02,HEDGE_CORRLELATION_OUTER_STRONG,outHedgeRate,MODEL_KIND_01,MODEL_KIND_02,0,0,
                        extProtectUnitProfit,extRemoveProtectUnitProfit);
   // hedge runner 01 (hedge model)
   this.makeRunner(SIGNAL_KIND_SIMILATION_02,HEDGE_GROUP_02,MODEL_KIND_02,hedgeGroupMaxCount,hedgeGroupSymbolMaxCount);    
   
   
   int groupCount=Hedge_Group_LoopCount;
   int makeGroupId=HEDGE_GROUP_02;
   int makeBaseModelId=MODEL_KIND_02;
   int makeHedgeModelId=MODEL_KIND_02;
   int makeSignalKind=SIGNAL_KIND_SIMILATION_02;
   
   //double pre
   for(int i=1;i<=groupCount;i++){
   
      makeGroupId++;      
      makeBaseModelId=makeHedgeModelId;
      makeHedgeModelId+=100;
      makeSignalKind++;
      
      double jumpPips=(double(i+1))*Comm_Grid_ExtendRate;
      double curProtectUnitProfit=extProtectUnitProfit+jumpPips;
      double curRemoveProtectUnitProfit=extRemoveProtectUnitProfit+jumpPips;
      int remainder = (int)MathMod(i, 2);
      if(remainder==0){
         curProtectUnitProfit=curProtectUnitProfit/2;
         curRemoveProtectUnitProfit=curRemoveProtectUnitProfit/2;
      } 
      
      this.makeHedgeGroupRunner(makeSignalKind,makeGroupId,makeBaseModelId,
                                    makeHedgeModelId,curProtectUnitProfit,curRemoveProtectUnitProfit,
                                    hedgeGroupMaxCount,hedgeGroupSymbolMaxCount);
   }
   
   //add end hedge model kind to start hedge group to loop
   this.addProtectModelToHedgeGroup(HEDGE_GROUP_02,makeHedgeModelId);
   this.accountEquity=AccountInfoDouble(ACCOUNT_EQUITY);
}

//+------------------------------------------------------------------+
//|  make group runner
//+------------------------------------------------------------------+
void CRunerRe::makeHedgeGroupRunner(int signalKind,int groupId,
                                       int protectModelKind,int hedgeModelKind,
                                       double protectUnitProfit,double removeProtectUnitProfit,
                                       int hedgeGroupMaxCount,int hedgeGroupSymbolMaxCount){
   //|   hedge group9
   this.makeHedgeGroup(groupId,HEDGE_CORRLELATION_OUTER_STRONG,Hedge_Outer_HedgeRate,protectModelKind,
                           hedgeModelKind,0,0,protectUnitProfit,removeProtectUnitProfit);            
   // hedge runner 09 (hedge model)
   this.makeRunner(signalKind,groupId,hedgeModelKind,hedgeGroupMaxCount,hedgeGroupSymbolMaxCount); 

}

//+------------------------------------------------------------------+
//|  add protect model to group
//+------------------------------------------------------------------+
void  CRunerRe::addProtectModelToHedgeGroup(int hedgeGroupId,int protectModelKind){
   CHedgeGroup* hedgeGroup=this.shareCtl.getHedgeShare().getHedgeGroup(hedgeGroupId);   
   hedgeGroup.addProtectModelKind(protectModelKind);
}

//+------------------------------------------------------------------+
//|  refresh info
//+------------------------------------------------------------------+
void  CRunerRe::refresh(){
   
   //log begin
   logData.begin();              //---logData test
   
   //make indicator
   this.indicatorCtl.run(); 
   
   //this.confirmProfit();
   this.marketCtl.run();         //market info
   //logger.log_OrdersMarket();  //---log info
   
   //reset data
   this.shareCtl.refresh();   
       
   //model clean/run         
   this.modelCtl.clean();
   this.modelCtl.run();   
   //logger.log_Models_Clean();  //---log info   
      
   logger.log_OrdersStatus("orderStatus");     //-- log info
   //logger.log_SymbolListInfo("symbolList");     //-- log info
   //logger.log_HedgeClearData("tradeDeal");   //-- log info
   //logger.log_GroupInfo("groupInfo");      //-- log info
   //logger.log_GroupHedgeInfo("groupInfo"); //-- log info
   

}

//+------------------------------------------------------------------+
//|  open orders /models
//+------------------------------------------------------------------+
void CRunerRe::open()
{ 
   //refresh data
   this.refresh();   
   //open models 
   this.modelCtl.run();
   //open orders
   this.tradeCtl.resetTradeAction();
   this.tradeCtl.openTrade();
   
   logger.log_TradeOpen("tradeDeal");  //-- log info
     
}   


int CRunerRe::close()
{   
   //refresh data
   this.refresh();      
   
   //this.tradeCtl.refresh();
   int closeCount=this.tradeCtl.closeTrade(); 
   
   logger.log_TradeClose("tradeDeal");  //---log info
   
   return closeCount;
}  
  
//+------------------------------------------------------------------+
//|  clear all the class
//+------------------------------------------------------------------+
void CRunerRe::clearMinus(void)
{  
   if(!Clear_Order_Minus)return;
   this.shareCtl.getHedgeShare().setClearOrderFlg(true,false);
   //refresh data
   this.refresh();
   //this.tradeCtl.refresh();    
   this.tradeCtl.clearTrade();
   
   logger.log_TradeClear("tradeDeal");
   
}  

//+------------------------------------------------------------------+
//|  clean all the class
//+------------------------------------------------------------------+
void CRunerRe::clearPlus(void)
{  
   if(!Clear_Order_Plus)return;
   //refresh data
   this.shareCtl.getHedgeShare().setClearOrderFlg(false,true);
   this.refresh();   
   //this.tradeCtl.refresh();    
   this.tradeCtl.clearTrade();
   
   logger.log_TradeClear("tradeDeal");
   
}  

//+------------------------------------------------------------------+
//|  make hedge group
//+------------------------------------------------------------------+
void CRunerRe::makeHedgeGroup(int hedgeGroupId,
                            int hedgeCorrelationType,
                            double minCorrelationRate,
                            int protectModelKind,
                            int hedgeModelKind,
                            double startLot,                            
                            double symbolFreeLot,
                            double protectUnitProfit,
                            double removeProtectUnitProfit){
                            
   CHedgeGroup* hedgeGroupPool=this.shareCtl.getHedgeShare().getHedgeGroupPool();
   CHedgeGroup* hedgeGroup=this.shareCtl.getHedgeShare().getHedgeGroup(hedgeGroupId);   
   
   hedgeGroup.setHedgeCorrelationType(hedgeCorrelationType);
   hedgeGroup.setMinCorrelationRate(minCorrelationRate); 
   hedgeGroup.setUseSymbolLotRate(Hedge_Use_Symbol_Lot_Rate);
   if(protectModelKind>0){  
      hedgeGroup.addProtectModelKind(protectModelKind);
      hedgeGroupPool.addHedgeModelKind(protectModelKind);
   }   
   if(hedgeModelKind>0){  
      hedgeGroup.addHedgeModelKind(hedgeModelKind);
      hedgeGroupPool.addHedgeModelKind(hedgeModelKind);
   }   
   hedgeGroup.setStartLot(protectModelKind,startLot*Comm_Unit_LotSize);   
   hedgeGroup.setSymbolFreeLots(symbolFreeLot*Comm_Unit_LotSize);
   
   //set hedge group
   if(hedgeGroupId==HEDGE_GROUP_01){
      hedgeGroup.setSymbolList(Symbol_Trade_List1);      
   }else if(hedgeGroupId==HEDGE_GROUP_02){
      hedgeGroup.setSymbolList(Symbol_Trade_List2);
   }else if(hedgeGroupId==HEDGE_GROUP_03){
      hedgeGroup.setSymbolList(Symbol_Trade_List3);
   }else{
      hedgeGroup.setSymbolList(Symbol_Trade_List1
                                 + "," + Symbol_Trade_List2
                                 + "," + Symbol_Trade_List3);   
   }   
   
}

//+------------------------------------------------------------------+
//|  make group runner(one group/multi-runner)
//+------------------------------------------------------------------+
void CRunerRe::makeRunner(int signalKind,
                            int hedgeGroupId,
                            int modelKind,
                            int modelMaxCount,
                            int symbolModelMaxCount){
                            
   //+------------------------------------------------------------------+
   //|   hedge runner 02 (hedge model)
   //+------------------------------------------------------------------+   
   CModelGrid01Runner* runner=new CModelGrid01Runner();    
   runner.setSignalKind(signalKind);
   runner.setHedgeGroup(hedgeGroupId);   
   runner.setModelKind(modelKind);   
   runner.setModelMaxCount(modelMaxCount);
   runner.setSymbolModelMaxCount(symbolModelMaxCount);
   runner.reLoadModels();
   modelCtl.addRunner(runner);                                 
}

//+------------------------------------------------------------------+
//|    confirm profit when profit N then close all the orders
//+------------------------------------------------------------------+
void CRunerRe::confirmProfit(){
   
   /*
   double curEquity=AccountInfoDouble(ACCOUNT_EQUITY);
   double diffEquity=curEquity-this.accountEquity;
   if(diffEquity>3000){
      this.tradeCtl.closeAllTrade();   
      this.accountEquity= curEquity;
      this.refreshAccountFlg=true;
   }   
   if(diffEquity<-2000){
      this.tradeCtl.closeAllTrade();
      this.accountEquity= curEquity;
      this.refreshAccountFlg=true;  
   } */     
}

//+------------------------------------------------------------------+
//|    class constructor   
//+------------------------------------------------------------------+
CRunerRe::CRunerRe(){
   this.accountEquity=0;
   this.refreshAccountFlg=false;
}
CRunerRe::~CRunerRe(){
   delete &this.shareCtl;
   delete &this.marketCtl;
   delete &this.indicatorCtl;
   delete &this.signalCtl;
   delete &this.modelCtl;
   delete &this.tradeCtl;  
}