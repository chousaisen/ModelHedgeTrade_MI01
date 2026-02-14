//+------------------------------------------------------------------+
//|                                                    CHedgeModel01.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\..\..\header\hedge\CHeader.mqh"
#include "..\..\..\share\CShareCtl.mqh"
#include "..\..\..\model\CModelCtl.mqh"

#include "../../../model/base/grid/m01/CModelGrid01Runner.mqh"

class CHedgeModel01
  {
   private:
         CShareCtl          *shareCtl;
         CModelCtl          *modelCtl;
         int                startGroupId; 
         int                curGroupId;
         int                runnerCount;
   public:
                            CHedgeModel01();
                            ~CHedgeModel01();
         //--- methods of initilize
         void               init(CShareCtl *shareCtl); 
         //--- run hedge control
         void               run(); 
         //--- set base start group id
         void               setStartGroupId(int groupId);
         //--- create runnner
         void               startRunner(CModelCtl* modelCtl);
         //--- create hedge group
         void               makeStartHedgeGroup(int hedgeGroupId,
                                                 double minCorrelationRate,                            
                                                 double startLot,                            
                                                 double symbolFreeLot);
         //--- create runnner to protect risk group
         void               createProtectRunner(CHedgeGroup* riskGroup,bool protectAll);
         //--- judge if protect current group
         bool               protectRiskGroup(bool protectAll);   
         //--- reload runner
         void               reload(int modelKindCount);      
                    
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CHedgeModel01::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
}

//+------------------------------------------------------------------+
//|  set base start group id
//+------------------------------------------------------------------+
void CHedgeModel01::setStartGroupId(int groupId){
   this.startGroupId=groupId;
   this.curGroupId=this.startGroupId;
}

//+------------------------------------------------------------------+
//|  make group runner(one group/multi-runner)
//+------------------------------------------------------------------+
void CHedgeModel01::startRunner(CModelCtl* modelCtl){                            

   this.modelCtl=modelCtl;
   //start base group
   this.makeStartHedgeGroup(this.startGroupId,
                       Hedge_Inner_HedgeRate,
                       Hedge_Group_Start_LotUnit,
                       Hedge_Group_Symbol_Free_LotUnit); 
   
   CModelGrid01Runner* runner=new CModelGrid01Runner();    
   runner.setHedgeGroup(this.startGroupId);   
   runner.setModelKind(this.startGroupId);   
   runner.setModelMaxCount(GRID_MODEL_MAX_COUNT);
   runner.setSymbolModelTypeMaxCount(GRID_MODEL_MAX_SYMBOL_TYPE_COUNT); 
   
   this.modelCtl.addRunner(runner); 
   this.runnerCount++;
}

//+------------------------------------------------------------------+
//|  make hedge group
//+------------------------------------------------------------------+
void CHedgeModel01::makeStartHedgeGroup(int hedgeGroupId,
                            double minCorrelationRate,                            
                            double startLot,                            
                            double symbolFreeLot){
                            
   CHedgeGroup* hedgeGroupPool=this.shareCtl.getHedgeShare().getHedgeGroupPool();
   CHedgeGroup* hedgeGroup=this.shareCtl.getHedgeShare().getHedgeGroup(hedgeGroupId);   
   
   hedgeGroupPool.setHedgeCorrelationType(HEDGE_CORRLELATION_INNER_STRONG);
   hedgeGroupPool.setMinCorrelationRate(minCorrelationRate);
   hedgeGroupPool.setUseSymbolLotRate(Hedge_Use_Symbol_Lot_Rate);
   
   hedgeGroup.setHedgeCorrelationType(HEDGE_CORRLELATION_INNER_STRONG);
   hedgeGroup.setMinCorrelationRate(minCorrelationRate); 
   hedgeGroup.setUseSymbolLotRate(Hedge_Use_Symbol_Lot_Rate);

   hedgeGroup.addHedgeModelKind(hedgeGroupId);
   hedgeGroupPool.addHedgeModelKind(hedgeGroupId);

   hedgeGroup.setStartLot(hedgeGroupId,startLot*Comm_Unit_LotSize);   
   hedgeGroup.setSymbolFreeLots(symbolFreeLot*Comm_Unit_LotSize);
   
   //set hedge group
   hedgeGroup.setSymbolList(Symbol_Trade_List1 + "," + Symbol_Trade_List2 + "," + Symbol_Trade_List3);   
   
}

//+------------------------------------------------------------------+
//|  judge if protect current group
//+------------------------------------------------------------------+
bool  CHedgeModel01::protectRiskGroup(bool protectAll){
   
   if(this.runnerCount>=P_GROUP_RUNNER_MAX_COUNT)return false;
   
   CHedgeGroup* curHedgeGroup=this.shareCtl.getHedgeShare().getCurHedgeGroup();
   if(curHedgeGroup==NULL)return false;
   
   //define the protect group condition
   bool   protectGroupFlg=false;
   
   double hedgeRate=curHedgeGroup.getHedgeRate();
   double riskLotRate=curHedgeGroup.getProtectGroupInfo().getRiskLotRate();
   double riskHedgeLotRate=curHedgeGroup.getProtectGroupInfo().getRiskHedgeLotRate();
   double riskHedgeSumLots=curHedgeGroup.getProtectGroupInfo().getRiskHedgeSumLots();
   double extSumLots=curHedgeGroup.getExtSumLots();
   double extRiskSumLots=curHedgeGroup.getExtRiskSumLots();
   int    extRiskOrderCount=curHedgeGroup.getExtRiskOrderCount();
      
   logData.beginLine(comFunc.getDate_YYYYMMDDHHMM2() 
                        + " <curGroupId>" + this.curGroupId
                        + " <hedgeRate>" + hedgeRate
                        + " <riskLotRate>" + riskLotRate
                        + " <riskHedgeLotRate>" + riskHedgeLotRate
                        + " <riskHedgeSumLots>" + riskHedgeSumLots                         
                        + " <extSumLots>" + extSumLots
                        + " <extRiskSumLots>" + extRiskSumLots
                        + " <extRiskOrderCount>" + extRiskOrderCount);
   logData.saveLine("protectRiskGroup1",1000);
   int protrectIndex=this.curGroupId-this.startGroupId;
   
   if(protrectIndex==0 &&
       (riskHedgeSumLots>P1_Risk_Hedge_SumLots 
         && hedgeRate<P1_Less_hedge_Rate)){
       protectGroupFlg=true;
   }else if(protrectIndex==1 &&
       (riskHedgeSumLots>P2_Risk_Hedge_SumLots 
         && hedgeRate<P2_Less_hedge_Rate)){
       protectGroupFlg=true;
   }else if(protrectIndex==2 &&
       (riskHedgeSumLots>P3_Risk_Hedge_SumLots 
         && hedgeRate<P3_Less_hedge_Rate)){
       protectGroupFlg=true;
   }else{
      if(riskHedgeSumLots>P4_Risk_Hedge_SumLots 
         && hedgeRate<P4_Less_hedge_Rate){
         protectGroupFlg=true;   
      }
   }
   
   //begin new runner when model count max   
   CModelRunnerI* runner=this.modelCtl.getRunner(curGroupId);
   if(runner!=NULL){
      int gridModelMaxCount=GRID_MODEL_MAX_COUNT;
      if(protrectIndex==1){
         gridModelMaxCount=P1_GRID_MODEL_MAX_COUNT;
      }else if(protrectIndex==2){
         gridModelMaxCount=P2_GRID_MODEL_MAX_COUNT;
      }else if(protrectIndex==3){
         gridModelMaxCount=P3_GRID_MODEL_MAX_COUNT;
      }else if(protrectIndex==4){
         gridModelMaxCount=P4_GRID_MODEL_MAX_COUNT;
      }else if(protrectIndex==5){
         gridModelMaxCount=P5_GRID_MODEL_MAX_COUNT;
      }else{
         gridModelMaxCount=GRID_MODEL_MAX_COUNT;
      }
      
      if(runner.getModelCount()>=gridModelMaxCount){
         protectGroupFlg=true;
      }   
   }
   
   
   if(protectGroupFlg){         
      //limit group count
      if(protrectIndex>=P_GROUP_RUNNER_MAX_COUNT)return false;
      if(protrectIndex==0){  
         this.createProtectRunner(curHedgeGroup,true);         
      }else{
         this.createProtectRunner(curHedgeGroup,P_GROUP_RUNNER_PROTECT_ALL);
      }
      //add recovery data
      this.runnerCount++;
      //this.shareCtl.getRecoveryShare().addRunnerCount();
      
      logData.beginLine(comFunc.getDate_YYYYMMDDHHMM2() 
                           + " createProtectRunner: "
                           + " <curGroupId>" + this.curGroupId
                           + " <riskLotRate>" + riskLotRate
                           + " <riskHedgeLotRate>" + riskHedgeLotRate
                           + " <riskHedgeSumLots>" + riskHedgeSumLots                           
                           + " <extSumLots>" + extSumLots
                           + " <extRiskSumLots>" + extRiskSumLots
                           + " <extRiskOrderCount>" + extRiskOrderCount);   
      logData.saveLine("protectRiskGroup2",1000);      
      
   }
   logData.addCheckNValue("runnerCount",this.runnerCount);  //---logData test 
   return true;
}

//+------------------------------------------------------------------+
//|  create runnner to protect risk group
//+------------------------------------------------------------------+
void  CHedgeModel01::createProtectRunner(CHedgeGroup* riskGroup,bool protectAll){   
   //make next group
   this.curGroupId++;
   int groupIndex=this.curGroupId-this.startGroupId;
   CHedgeGroup* hedgeGroupPool=this.shareCtl.getHedgeShare().getHedgeGroupPool();
   CHedgeGroup* nextHedgeGroup=this.shareCtl.getHedgeShare().getHedgeGroup(this.curGroupId);
   nextHedgeGroup.protectHedgeGroup(riskGroup,protectAll);
   hedgeGroupPool.addHedgeModelKind(this.curGroupId);
   nextHedgeGroup.addHedgeModelKind(this.curGroupId);
   nextHedgeGroup.setHedgeCorrelationType(HEDGE_CORRLELATION_OUTER_STRONG);
   nextHedgeGroup.setMinCorrelationRate(Hedge_Outer_HedgeRate); 
   nextHedgeGroup.setUseSymbolLotRate(Hedge_Use_Symbol_Lot_Rate);
   nextHedgeGroup.setSymbolList(Symbol_Trade_List1 + "," + Symbol_Trade_List2 + "," + Symbol_Trade_List3);      
     
   CModelGrid01Runner* runner=new CModelGrid01Runner();    
   runner.setHedgeGroup(this.curGroupId);   
   runner.setModelKind(this.curGroupId);      
   
   if(groupIndex==1){ 
      runner.setHedgeFlg(P1_GRID_MODEL_HEDGE);  
      runner.setModelMaxCount(P1_GRID_MODEL_MAX_COUNT);
      runner.setSymbolModelTypeMaxCount(P1_GRID_MODEL_MAX_SYMBOL_TYPE_COUNT); 
      runner.setParameters(P1_GRID_MAX_ORDER_COUNT,
                         P1_GRID_DISTANCE_LIST,
                         P1_GRID_DISTANCE_DIFF_PIPS,
                         P1_GRID_PROFIT_LIST,
                         P1_GRID_STOP_LOSS_PIPS,
                         P1_HEDGE_GRID_PROTECT_PIPS,
                         P1_HEDGE_GRID_PROTECT_DIFF_PIPS);   
  }
  else if(groupIndex==2){
      runner.setHedgeFlg(P2_GRID_MODEL_HEDGE);  
      runner.setModelMaxCount(P2_GRID_MODEL_MAX_COUNT);
      runner.setSymbolModelTypeMaxCount(P2_GRID_MODEL_MAX_SYMBOL_TYPE_COUNT); 
      runner.setParameters(P2_GRID_MAX_ORDER_COUNT,
                         P2_GRID_DISTANCE_LIST,
                         P2_GRID_DISTANCE_DIFF_PIPS,
                         P2_GRID_PROFIT_LIST,
                         P2_GRID_STOP_LOSS_PIPS,
                         P2_HEDGE_GRID_PROTECT_PIPS,
                         P2_HEDGE_GRID_PROTECT_DIFF_PIPS);   
  }
  else if(groupIndex==3){
      runner.setHedgeFlg(P3_GRID_MODEL_HEDGE);   
      runner.setModelMaxCount(P3_GRID_MODEL_MAX_COUNT);
      runner.setSymbolModelTypeMaxCount(P3_GRID_MODEL_MAX_SYMBOL_TYPE_COUNT); 
      runner.setParameters(P3_GRID_MAX_ORDER_COUNT,
                         P3_GRID_DISTANCE_LIST,
                         P3_GRID_DISTANCE_DIFF_PIPS,
                         P3_GRID_PROFIT_LIST,
                         P3_GRID_STOP_LOSS_PIPS,
                         P3_HEDGE_GRID_PROTECT_PIPS,
                         P3_HEDGE_GRID_PROTECT_DIFF_PIPS);   
  }
  else if(groupIndex==4){
      runner.setHedgeFlg(P4_GRID_MODEL_HEDGE);  
      runner.setModelMaxCount(P4_GRID_MODEL_MAX_COUNT);
      runner.setSymbolModelTypeMaxCount(P4_GRID_MODEL_MAX_SYMBOL_TYPE_COUNT); 
      runner.setParameters(P4_GRID_MAX_ORDER_COUNT,
                         P4_GRID_DISTANCE_LIST,
                         P4_GRID_DISTANCE_DIFF_PIPS,
                         P4_GRID_PROFIT_LIST,
                         P4_GRID_STOP_LOSS_PIPS,
                         P4_HEDGE_GRID_PROTECT_PIPS,
                         P4_HEDGE_GRID_PROTECT_DIFF_PIPS);   
  }
  else if(groupIndex==5){
      runner.setHedgeFlg(P5_GRID_MODEL_HEDGE);        
      runner.setModelMaxCount(P5_GRID_MODEL_MAX_COUNT);
      runner.setSymbolModelTypeMaxCount(P5_GRID_MODEL_MAX_SYMBOL_TYPE_COUNT); 
      runner.setParameters(P5_GRID_MAX_ORDER_COUNT,
                         P5_GRID_DISTANCE_LIST,
                         P5_GRID_DISTANCE_DIFF_PIPS,
                         P5_GRID_PROFIT_LIST,
                         P5_GRID_STOP_LOSS_PIPS,
                         P5_HEDGE_GRID_PROTECT_PIPS,
                         P5_HEDGE_GRID_PROTECT_DIFF_PIPS);   
  }      
  else{
      runner.setHedgeFlg(P1_GRID_MODEL_HEDGE);  
      runner.setModelMaxCount(P1_GRID_MODEL_MAX_COUNT);
      runner.setSymbolModelTypeMaxCount(P1_GRID_MODEL_MAX_SYMBOL_TYPE_COUNT); 
      runner.setParameters(P1_GRID_MAX_ORDER_COUNT,
                         P1_GRID_DISTANCE_LIST,
                         P1_GRID_DISTANCE_DIFF_PIPS,
                         P1_GRID_PROFIT_LIST,
                         P1_GRID_STOP_LOSS_PIPS,
                         P1_HEDGE_GRID_PROTECT_PIPS,
                         P1_HEDGE_GRID_PROTECT_DIFF_PIPS);     
  }                       
   
   this.modelCtl.addRunner(runner);      
     
}

//+------------------------------------------------------------------+
//|  reload all runnner where rerun
//+------------------------------------------------------------------+
void  CHedgeModel01::reload(int modelKindCount){

   //int runnerCount=this.shareCtl.getRecoveryShare().getRunnerCount();
   for(int i=1;i<modelKindCount;i++){
      CHedgeGroup* curHedgeGroup=this.shareCtl.getHedgeShare().getCurHedgeGroup();
      this.createProtectRunner(curHedgeGroup,P_GROUP_RUNNER_PROTECT_ALL);   
   }
}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CHedgeModel01::CHedgeModel01(){}
CHedgeModel01::~CHedgeModel01(){}