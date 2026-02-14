//+------------------------------------------------------------------+
//|                                                       Test01.mq5 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "runner/Run01.mqh"

//+------------------------------------------------------------------+
//| test parameter
//+------------------------------------------------------------------+
CRunerRe* runer;
CRunerRe* runerRe;

datetime   startTime;
input string     reRunTimeStr="20290501 1000";
bool       reRunFlg=false;
datetime   reRunTime;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
   EventSetMillisecondTimer(100);

   runer=new CRunerRe();
   runer.init();
   
   startTime=TimeCurrent();
   if(StringLen(Comm_App_Start_Time)>0){
      startTime=StringToTime(Comm_App_Start_Time);
   }
   
   //set rerun time
   reRunTime=StringToTime(reRunTimeStr);
   //reRunFlg=false;

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    EventKillTimer();
    delete runer;
    if(runerRe!=NULL)delete runerRe;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   
   if(!comFunc2.IsTradingAllowed())return;
   if(!comFunc2.IsMarketClosed())return;   
   
   static bool startFlg=false;
   if(TimeCurrent()<startTime)return;

   MqlDateTime mqlCurTime; 
   TimeToStruct(TimeCurrent(),mqlCurTime);    
   if(mqlCurTime.hour>=Comm_App_Start_Hour && mqlCurTime.min>=Comm_App_Start_Minute)startFlg=true;
   if(!startFlg)return;  

   if(!reRunFlg && TimeCurrent()>reRunTime){
      reRunFlg=true;
      runerRe=new CRunerRe();
      runerRe.init(); 
   }

   if(!reRunFlg){
      TimerRun(runer);
   }else{
      TimerRun(runerRe);
   }
      
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTimer(){}

//+------------------------------------------------------------------+
//| Run function - 未来功能实现                                       |
//+------------------------------------------------------------------+
void TimerRun(CRunerRe* runer)
{

   static datetime openLastTime = 0; 
   static datetime closeLastTime = 0; 
   static datetime clearLastTime = 0; 
   datetime curTime=TimeCurrent();      
   
   if(Debug){  
      int debugDiffSeconds=runer.getDebugDiffSeconds();
      if((curTime-openLastTime)>=debugDiffSeconds) 
      {       
          openLastTime = curTime; 
          runer.refreshIndicator();
          runer.clearRiskModels();
          runer.clearExceedModels();
          runer.clearPreExceedModels();
          runer.clearOverModels();
          //runer.clearPlusModels();
          runer.clearMinusModels();
          runer.createProtectGroup();
          runer.open();
      }
      if((curTime-closeLastTime)>=debugDiffSeconds) 
      {
         closeLastTime = curTime; 
         //runer.refreshIndicator();
         runer.close();
      }   
   }else{    
       runer.refreshIndicator();
       runer.clearRiskModels();
       runer.clearExceedModels();
       runer.clearPreExceedModels();
       runer.clearOverModels();
       //runer.clearPlusModels();
       //runer.clearMinusModels();
       runer.createProtectGroup();
       runer.open();
       runer.refreshIndicator();
       runer.close();
   }
}

//+------------------------------------------------------------------+
//| Run function - 未来功能实现                                      |
//+------------------------------------------------------------------+
/*
void TimerRun2()
{

   static datetime openLastTime2 = 0; 
   static datetime closeLastTime2 = 0; 
   static datetime clearLastTime2 = 0; 
   datetime curTime2=TimeCurrent();   
     
   if((curTime2-openLastTime2)>10) 
   {
       openLastTime2 = curTime2; 
       runerRe.open();       
   }
   if((curTime2-closeLastTime2)>20) 
   {
      closeLastTime2 = curTime2; 
      runerRe.close(); 
   }   
}*/