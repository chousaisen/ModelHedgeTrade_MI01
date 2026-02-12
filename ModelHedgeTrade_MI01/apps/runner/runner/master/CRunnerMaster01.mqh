//+------------------------------------------------------------------+
//|                                                  ModelsRun01.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../CRunner.mqh"

 //+------------------------------------------------------------------+
//|  model logic custermlize 
//+------------------------------------------------------------------+
#include "../../../model/base/grid/m01/CModelGrid01Runner.mqh"
#include "../../../model/filter/open/CFilterOpen01.mqh"
#include "../../../model/filter/extend/CFilterExtend01.mqh"
#include "../../../model/filter/close/CFilterClose01.mqh"
//#include "../../../model/filter/clear/CFilterClear01.mqh"

class CRunnerMaster01: public CRunner
  {
   private:
      CFilterOpen01         filterOpen01;
      CFilterExtend01       filterExtend01;
      CFilterClose01        filterClose01;
      //CFilterClear01        filterClear01;

   public:
                        CRunnerMaster01();
                       ~CRunnerMaster01();
         
         //+------------------------------------------------------------------+
         //|  comm methods
         //+------------------------------------------------------------------+       
         void            init(CIndicatorCtl* indicatorCtl,CClientCtl* clientCtl);
         void            initRunner();
         void            initFilter();
         void            initHedgeGroup();
         void            initHedgeGroup(double minCorrelationRate,                            
                                       double startLot,                            
                                       double symbolFreeLot);
         // refresh runner(refresh the condition(include indicator))
         void            refresh();
         void            refreshRisk();
         //input/output risk order pair
         void            inputRisk();
         void            outputRisk();
         
         // trade run
         void            run();

};

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CRunnerMaster01::init(CIndicatorCtl* indicatorCtl,CClientCtl* clientCtl)
{
   
   //set model kind
   this.setModelKind(MODEL_KIND_01);   
   
   //init logger
   logger.init(&this.shareCtl,&this.marketCtl);
   
   //base init 
   CRunner::init(indicatorCtl,clientCtl);
   
   //init runner
   this.initRunner();
   
   //init filter
   this.initFilter();
}        

//+------------------------------------------------------------------+
//|  refresh runner(refresh the condition(include indicator))
//+------------------------------------------------------------------+
void CRunnerMaster01::refresh(){
   //base refresh
   CRunner::refresh();
   //master01 refresh begin   
   //master01 refresh end
}

//+------------------------------------------------------------------+
//|  refresh master risk orders
//+------------------------------------------------------------------+
void CRunnerMaster01::refreshRisk(void){
   this.hedgeCtl.refreshRiskHedgePair(); 
}

//+------------------------------------------------------------------+
//| input risk hedge pairs
//+------------------------------------------------------------------+
void CRunnerMaster01::inputRisk(){
   this.hedgeCtl.inputRiskHedgePair();
}

//+------------------------------------------------------------------+
//|  output risk hedge pairs
//+------------------------------------------------------------------+
void CRunnerMaster01::outputRisk(){
   this.hedgeCtl.outputRiskHedgePair();
}

//+------------------------------------------------------------------+
//|  run the trade
//+------------------------------------------------------------------+
void CRunnerMaster01::run(){

   //common refresh(indicator)
   //this.refresh();   
   rkeeLog.writeLmtLog("CRunnerMaster01: run1"); 
   
   //input risk order pair
   this.inputRisk();
   
   //master01 trade run begin
   this.closeModels();
   this.extendModels();
   this.openModels();
   this.clearExceedModels();
   
   //refresh and output risk orders
   this.refreshRisk();
   this.outputRisk();
   //master01 trade run end
}

//+------------------------------------------------------------------+
//|  init group runner
//+------------------------------------------------------------------+
void CRunnerMaster01::initRunner(){

   //init base hedge group
   this.initHedgeGroup(Hedge_Group_HedgeRate,
                             Hedge_Group_Start_LotUnit,
                             Hedge_Group_Symbol_Free_LotUnit); 
   
   CModelGrid01Runner* runner=new CModelGrid01Runner();
   runner.setModelKind(this.getModelKind());   
   runner.setModelMaxCount(GRID_MODEL_MAX_COUNT);
   runner.setSymbolModelTypeMaxCount(GRID_MODEL_MAX_SYMBOL_TYPE_COUNT);
   
   runner.setHedgeFlg(GRID_MODEL_HEDGE);  
   runner.setModelMaxCount(GRID_MODEL_MAX_COUNT);
   runner.setSymbolModelTypeMaxCount(GRID_MODEL_MAX_SYMBOL_TYPE_COUNT); 
   runner.setParameters(GRID_MAX_ORDER_COUNT,
                            GRID_EXTEND_LIST,
                            GRID_DISTANCE_DIFF_PIPS,
                            GRID_PROFIT_LIST,
                            GRID_STOP_LOSS_PIPS,
                            HEDGE_GRID_PROTECT_PIPS,
                            HEDGE_GRID_PROTECT_DIFF_PIPS);     
   
       
   this.modelCtl.addRunner(runner); 
}

//+------------------------------------------------------------------+
//|  init runner filter
//+------------------------------------------------------------------+
void CRunnerMaster01::initFilter(){

   //add indicator filter   
   this.filterOpen01.init(&this.shareCtl);
   this.filterExtend01.init(&this.shareCtl);   
   this.filterClose01.init(&this.shareCtl);
   //this.filterClear01.init(&this.shareCtl);

   this.shareCtl.getFilterShare().addOpenFilter(&this.filterOpen01);   
   this.shareCtl.getFilterShare().addExtendFilter(&this.filterExtend01);
   this.shareCtl.getFilterShare().addCloseFilter(&this.filterClose01);   
   //this.shareCtl.getFilterShare().addClearFilter(&this.filterClear01);

}

//+------------------------------------------------------------------+
//|  make hedge group
//+------------------------------------------------------------------+
void CRunnerMaster01::initHedgeGroup(double minCorrelationRate,                            
                                       double startLot,                            
                                       double symbolFreeLot){
                            
   CHedgeGroup* hedgeGroupPool=this.shareCtl.getHedgeShare().getHedgeGroupPool();   
   hedgeGroupPool.setMinCorrelationRate(minCorrelationRate);
   //hedgeGroupPool.setUseSymbolLotRate(Hedge_Use_Symbol_Lot_Rate);   
   //hedgeGroupPool.addHedgeModelKind(this.getModelKind());
   
}

//+------------------------------------------------------------------+
//|    class constructor   
//+------------------------------------------------------------------+
CRunnerMaster01::CRunnerMaster01(){
}
CRunnerMaster01::~CRunnerMaster01(){
}