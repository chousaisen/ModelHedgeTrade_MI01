//+------------------------------------------------------------------+
//|                                                   CLogSimulationCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "CHeader.mqh"
#include "../share/CShareCtl.mqh"
#include "log/CEaLogSignal.mqh"


input string comment_ea_simulation_begin="-----------------------";
input string EaSignalKindList="101,102";
input double EaSignalFixLot=0;
input double EaSignalLotRate=1;
input string comment_ea_simulation_end="-----------------------";

class CLogSimulationCtl
  {
      private:
            CShareCtl      *shareCtl;
            CEaLogSignal   logToSignal;
      public:
                           CLogSimulationCtl();
                          ~CLogSimulationCtl();
           //--- methods of initilize
           void            init(CShareCtl *shareCtl); 
           //--- run CLogSimulationCtl
           void            run(); 
           //--- load Simulation Info 
           void            load(); 
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CLogSimulationCtl::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.logToSignal.init(shareCtl);
   this.logToSignal.setLotRate(EaSignalLotRate);
}
//+------------------------------------------------------------------+
//|  read ea log  to make muti signals
//+------------------------------------------------------------------+
void CLogSimulationCtl::load()
{
   int signalKindList[];
   comFunc.StringToIntArray(EaSignalKindList,signalKindList);   
   int count=ArraySize(signalKindList);
   for(int i=0;i<count;i++){   
      //run EA log to signal 
      this.logToSignal.readMutiLogToSignal(signalKindList[i]);
   }
}    

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CLogSimulationCtl::CLogSimulationCtl(){}
CLogSimulationCtl::~CLogSimulationCtl(){
   delete GetPointer(this.logToSignal);
}
