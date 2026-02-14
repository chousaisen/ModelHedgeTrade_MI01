//+------------------------------------------------------------------+
//|                                                   CCsvSimulationCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "CHeader.mqh"
#include "../share/CShareCtl.mqh"
#include "csv/CsvToSignal.mqh"

input string comment_signal_simulation_begin="-----------------------";
input string SignalKindList="101,102";
input double SignalLotRate=1;
input double SignalFixLot=0;
input string comment_signal_simulation_end="-----------------------";

class CCsvSimulationCtl
  {
      private:
            CShareCtl *shareCtl;
            CsvToSignal csvToSignal;
      public:
                           CCsvSimulationCtl();
                          ~CCsvSimulationCtl();
           //--- methods of initilize
           void            init(CShareCtl *shareCtl); 
           //--- run CCsvSimulationCtl
           void            run(); 
           //--- load Simulation Info 
           void            load(); 
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CCsvSimulationCtl::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.csvToSignal.init(shareCtl);
   this.csvToSignal.setLotRate(SignalLotRate);
   if(SignalFixLot>0)this.csvToSignal.setFixLot(SignalFixLot);
}
//+------------------------------------------------------------------+
//|  load csv file data to signal list
//+------------------------------------------------------------------+
void CCsvSimulationCtl::load()
{
   
   int signalKindList[];
   comFunc.StringToIntArray(SignalKindList,signalKindList);   
   int count=ArraySize(signalKindList);
   for(int i=0;i<count;i++){   
      //run EA log to signal 
      this.csvToSignal.readCsvToSignal(signalKindList[i]);
   }   
}    

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CCsvSimulationCtl::CCsvSimulationCtl(){}
CCsvSimulationCtl::~CCsvSimulationCtl(){
   delete GetPointer(csvToSignal);
}
