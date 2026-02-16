//+------------------------------------------------------------------+
//|                                                   CRunnerCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../comm/CLog.mqh"
#include "../client/CClientCtl.mqh"
#include "../indicator/CIndicatorCtl.mqh"
#include "runner/master/CRunnerMaster01.mqh"

class CRunnerCtl
{
   private:
     
      CClientCtl            clientCtl;      
      CIndicatorCtl         indicatorCtl; 

      //Master runner and slave runner
      CRunnerMaster01       masterRunner;
      bool                  featureSyncEnabled;

   public:
   
         //--- methods of initilize
         void                init(); 
         //--- refresh common
         void                refreshCommon(void);
         //--- refresh
         void                run();   
         
         //--- constructor
         CRunnerCtl();
         ~CRunnerCtl();
     
};

//+------------------------------------------------------------------+
//|  init runner control
//|  (client,indicator,master/slave runner)
//+------------------------------------------------------------------+
void CRunnerCtl::init(void){
   this.clientCtl.init();
   this.indicatorCtl.init();
   this.masterRunner.init(&this.indicatorCtl,&this.clientCtl);

   this.featureSyncEnabled=this.clientCtl.initFeatureDbContext((ERunnerMode)FEATURE_DB_RUNNER_MODE);

   //create tables
   this.clientCtl.initTables(); 
}

//+------------------------------------------------------------------+
//|  commom refresh
//+------------------------------------------------------------------+
void CRunnerCtl::refreshCommon(void){
   //indicator refresh
   rkeeLog.writeLmtLog("CRunnerCtl: refreshCommon1");   
   this.indicatorCtl.refresh();
}

//+------------------------------------------------------------------+
//|  reset the runner control
//+------------------------------------------------------------------+
void CRunnerCtl::run(void)
{
   //commom refresh(etc.indicator)
   rkeeLog.writeLmtLog("CRunnerCtl: Run1");
   this.refreshCommon();

   //master runner
   rkeeLog.writeLmtLog("CRunnerCtl: Run2");   
   this.masterRunner.run();

   //feature01 db association flow(Put/Pull/Close)
   if(this.featureSyncEnabled){
      CHedgeSyncService *sync=this.clientCtl.getFeatureDbContext().Sync();
      if(sync!=NULL && CheckPointer(sync)!=POINTER_INVALID){
         if(FEATURE_DB_RUNNER_MODE==RUNNER_MASTER_ONLY || FEATURE_DB_RUNNER_MODE==RUNNER_HYBRID){
            sync.SyncPutRiskToProtect(DB_MASTER1,DB_SLAVE1,FEATURE_MASTER_MODEL_KIND,FEATURE_SLAVE_MODEL_KIND);
            sync.SyncPullProtectToRisk(DB_SLAVE1,DB_MASTER1,FEATURE_MASTER_MODEL_KIND,FEATURE_SLAVE_MODEL_KIND);
            sync.SyncCloseHedge(DB_SLAVE1,FEATURE_SLAVE_MODEL_KIND,FEATURE_CLOSE_STATUS);
         }

         if(FEATURE_DB_RUNNER_MODE==RUNNER_SLAVE_ONLY || FEATURE_DB_RUNNER_MODE==RUNNER_HYBRID){
            sync.SyncPutRiskToProtect(DB_MASTER1,DB_SLAVE2,FEATURE_MASTER_MODEL_KIND,FEATURE_SLAVE_MODEL_KIND);
            sync.SyncPullProtectToRisk(DB_SLAVE2,DB_MASTER1,FEATURE_MASTER_MODEL_KIND,FEATURE_SLAVE_MODEL_KIND);
            sync.SyncCloseHedge(DB_SLAVE2,FEATURE_SLAVE_MODEL_KIND,FEATURE_CLOSE_STATUS);
         }
      }
   }
} 

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CRunnerCtl::CRunnerCtl(){}
CRunnerCtl::~CRunnerCtl(){
}
