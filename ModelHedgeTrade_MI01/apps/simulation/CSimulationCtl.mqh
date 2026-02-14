//+------------------------------------------------------------------+
//|                                                   CSimulationCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "CHeader.mqh"
#include "../share/CShareCtl.mqh"
#include "csv/CsvToSignal.mqh"

class CSimulationCtl
  {
      private:
            CShareCtl *shareCtl;
            CsvToSignal csvToSignal;
      public:
                           CSimulationCtl();
                          ~CSimulationCtl();
           //--- methods of initilize
           void            init(CShareCtl *shareCtl); 
           //--- run CSimulationCtl
           void            run(); 
           //--- load Simulation Info 
           void            load(); 
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CSimulationCtl::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   csvToSignal.init(shareCtl);
}
//+------------------------------------------------------------------+
//|  run the muti signals
//+------------------------------------------------------------------+
void CSimulationCtl::load()
{
   //run csv to signal 
   this.csvToSignal.load();
}    

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSimulationCtl::CSimulationCtl(){}
CSimulationCtl::~CSimulationCtl(){
   delete GetPointer(csvToSignal);
}
