//+------------------------------------------------------------------+
//|                                           CStatus.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\..\..\comm\ComFunc2.mqh"
#include "..\..\..\client\CClientCtl.mqh"
#include "..\..\symbol\CSymbolInfos.mqh"

class CStatus{
  private: 
         double         peakLine;
         double         returnRate;
         double         returnPips;
         double         returnMaxRate;
         double         returnMaxPips;         
         double         slopePips;
         int            waveIndex;        
  public:
                        CStatus();
                        ~CStatus();
         
          //--- init 
          void          init(CSymbolInfos* symbolInfos);

          //---------------------------------------------
          //--- parameter get functions
          //---------------------------------------------
          double getPeakLine() const { return peakLine; }
          double getReturnRate() const { return returnRate; }
          double getReturnPips() const { return returnPips; }
          double getReturnMaxRate() const { return returnMaxRate; }
          double getReturnMaxPips() const { return returnMaxPips; }
          double getSlopePips() const { return slopePips; }
          int    getWaveIndex() const { return waveIndex; }          
          
          //---------------------------------------------
          //--- parameter set functions
          //---------------------------------------------
          void setPeakLine(double value) { peakLine = value; }
          void setReturnRate(double value) { returnRate = value; }
          void setReturnPips(double value) { returnPips = value; }
          void setReturnMaxRate(double value) { returnMaxRate = value; }
          void setReturnMaxPips(double value) { returnMaxPips = value; }
          void setSlopePips(double value) { slopePips = value; }
          void setWaveIndex(int value) { waveIndex = value; }         
    
  };

//+------------------------------------------------------------------+
//|  init
//+------------------------------------------------------------------+
void CStatus::init(CSymbolInfos* symbolInfos){}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CStatus::CStatus(){  
}
CStatus::~CStatus(){
}