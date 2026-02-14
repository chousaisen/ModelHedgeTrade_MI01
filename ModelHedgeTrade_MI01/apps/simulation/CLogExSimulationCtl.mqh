//+------------------------------------------------------------------+
//|                                                   CLogExSimulationCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "CHeader.mqh"
#include "../share/CShareCtl.mqh"
#include "log/CEaLogSignalEx.mqh"


input  string   SIMULATION_LOG_SETTING="------ simulation Log data setting ------";

input string EaSignalKindList1="EAGoldStuff1@101,102,103,104,105,106,107,108";
input string EaSignalKindList2="";
input string EaSignalKindList3="";
input string EaSignalKindList4="";
input string EaSignalKindList5="";
input string EaSignalKindList6="";
input double EaSignalFixLot=0;
input string EaSignalLotRateList="1,1";
input string EaSignalExtSymbolList="";
input string EaSignalOnlySymbolList="";
input string EaSignalOnlySymbolList1="";
input string EaSignalOnlySymbolList2="";
input string EaSignalOnlySymbolList3="";
input string EaSignalOnlySymbolList4="";
input string EaSignalOnlySymbolList5="";
input string EaSignalOnlySymbolList6="";
input string EaSignalExpCountry="";

class CLogExSimulationCtl
  {
      private:
            CShareCtl         *shareCtl;
            CEaLogSignalEx    logToSignal;
      public:
                           CLogExSimulationCtl();
                          ~CLogExSimulationCtl();
           //--- methods of initilize
           void            init(CShareCtl *shareCtl); 
           //--- run CLogExSimulationCtl
           void            run(); 
           //--- load Simulation Info 
           void            load(); 
           //--- load Simulation Info by ea signal list
           void            load(string eaSignalKindList,double &signalLotRateList[]);
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CLogExSimulationCtl::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.logToSignal.init(shareCtl);
   this.logToSignal.setExtSymbolList(EaSignalExtSymbolList);
   this.logToSignal.setOnlySymbolList(EaSignalOnlySymbolList);
   this.logToSignal.setExpCountry(EaSignalExpCountry);
   this.logToSignal.setFixLot(EaSignalFixLot);      
}

//+------------------------------------------------------------------+
//|  read ea log  to make muti signals
//+------------------------------------------------------------------+
void CLogExSimulationCtl::load()
{
   double signalLotRateList[];      
   comFunc.StringToDoubleArray(EaSignalLotRateList,signalLotRateList);    
   this.load(EaSignalKindList1,signalLotRateList);
   this.load(EaSignalKindList2,signalLotRateList);
   this.load(EaSignalKindList3,signalLotRateList);
   this.load(EaSignalKindList4,signalLotRateList);
   this.load(EaSignalKindList5,signalLotRateList);
   this.load(EaSignalKindList6,signalLotRateList);
}
//+------------------------------------------------------------------+
//|  read ea log  to make muti signals by EA Signal Kind List
//+------------------------------------------------------------------+
void CLogExSimulationCtl::load(string eaSignalKindList,double &signalLotRateList[])
{   
   if(StringLen(eaSignalKindList)<5)return;
   string eaFolderName;
   int signalKindList[];   
   comFunc.getLogNameAndKindList(eaSignalKindList,eaFolderName,signalKindList);         
   int count=ArraySize(signalKindList);
   
   for(int i=0;i<count;i++){   
      //run EA log to signal 
      this.logToSignal.setLotRate(signalLotRateList[i]);
            
      if(i==1 && StringLen(EaSignalOnlySymbolList1)>0){
         this.logToSignal.setOnlySymbolList(EaSignalOnlySymbolList1);
      }
      if(i==2 && StringLen(EaSignalOnlySymbolList2)>0){
         this.logToSignal.setOnlySymbolList(EaSignalOnlySymbolList2);
      }
      if(i==3 && StringLen(EaSignalOnlySymbolList3)>0){
         this.logToSignal.setOnlySymbolList(EaSignalOnlySymbolList3);
      }
      if(i==4 && StringLen(EaSignalOnlySymbolList4)>0){
         this.logToSignal.setOnlySymbolList(EaSignalOnlySymbolList4);
      }
      if(i==5 && StringLen(EaSignalOnlySymbolList5)>0){
         this.logToSignal.setOnlySymbolList(EaSignalOnlySymbolList5);
      }
      if(i==6 && StringLen(EaSignalOnlySymbolList6)>0){
         this.logToSignal.setOnlySymbolList(EaSignalOnlySymbolList6);
      }      
      this.logToSignal.readMutiLogToSignal(eaFolderName,signalKindList[i]);
   }
}    

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CLogExSimulationCtl::CLogExSimulationCtl(){}
CLogExSimulationCtl::~CLogExSimulationCtl(){
   delete GetPointer(this.logToSignal);
}
