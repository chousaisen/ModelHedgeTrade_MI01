//+------------------------------------------------------------------+
//|                                                       Test01.mq5 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../apps/runner/CRunnerCtl.mqh"

CRunnerCtl* runerCtl;

//+------------------------------------------------------------------+
//| demo test parameter(not use in the real account)
//+------------------------------------------------------------------+
datetime          reRunTime;
datetime          startTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
   EventSetMillisecondTimer(100);

   rkeeLog.writeLmtLog("Demo: OnInit");
   runerCtl=new CRunnerCtl();
   runerCtl.init();
   
   startTime=TimeCurrent();
   if(StringLen(Comm_App_Start_Time)>0){
      startTime=StringToTime(Comm_App_Start_Time);
   }
   
   //set rerun time
   reRunTime=StringToTime(Debug_ReRun_Time);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    EventKillTimer();
    delete runerCtl;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   
   TimerRun(runerCtl);

}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTimer(){}

//+------------------------------------------------------------------+
//| Run function - 未来功能实现                                       |
//+------------------------------------------------------------------+
void TimerRun(CRunnerCtl* runner)
{

   static datetime openLastTime = 0; 
   static datetime closeLastTime = 0; 
   static datetime clearLastTime = 0; 
   datetime curTime=TimeCurrent(); 
   
   if(Debug){
      //rkeeLog.writeLmtLog("Demo: OnTick_TimerRun_Debug");        
      if((curTime-openLastTime)>=Debug_Diff_Seconds) 
      {       
          openLastTime = curTime;
          rkeeLog.writeLmtLog("Demo: OnTick_TimerRun_Debug_Run");
          runner.run();
      }  
   }else{
      rkeeLog.writeLmtLog("Demo: OnTick_TimerRun_Run");   
      runner.run();
   }
}