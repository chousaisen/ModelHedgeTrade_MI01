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
} 

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CRunnerCtl::CRunnerCtl(){}
CRunnerCtl::~CRunnerCtl(){
}