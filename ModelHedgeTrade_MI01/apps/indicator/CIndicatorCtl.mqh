//+------------------------------------------------------------------+
//|                                                 IndicatorCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "correlation/CCorrelation.mqh"
//#include "channel/CPriceChannel.mqh"
//#include "trend/CTrendSar.mqh"
#include "trend/CTrendSarChl.mqh"
#include "../share/symbol/CSymbolShare.mqh"
#include "../share/analysis/CAnalysisShare.mqh"
#include "../share/indicator/CIndicatorShare.mqh"
#include "../share/recovery/CRecoveryShare.mqh"
#include "../share/symbol/CSymbolShare.mqh"

class CIndicatorCtl{
   private:            
            CSymbolShare          symbolShare;
            CIndicatorShare       indicatorShare;
            CAnalysisShare        analysisShare;
            //recovery share
            CRecoveryShare        recoveryShare;            
            CCorrelation          correlation;    
            //CPriceChannel         priceChannel;
            //CTrendSar             trendSar;
            CTrendSarChl          trendSarChl;          
   public:
                                CIndicatorCtl();
                                ~CIndicatorCtl();        
            //--- methods of initilize
            void                init();       
            //--- refresh indicator
            void                refresh(); 
           
            //--- get signal share
            CSymbolShare*       getSymbolShare(); 
            //--- get indicator share
            CIndicatorShare*    getIndicatorShare(); 
            //--- get analysis share  
            CAnalysisShare*     getAnalysisShare();
            //--- get recovery share
            CRecoveryShare*     getRecoveryShare();               
                    
};
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CIndicatorCtl::init()
{
   this.symbolShare.init();
   this.analysisShare.init(&symbolShare,
                            &indicatorShare); 
   this.correlation.init(&symbolShare);
   //this.priceChannel.init(&this.symbolShare,&this.indicatorShare);
   /*
   this.trendSar.init(&this.symbolShare,
                        &this.analysisShare,
                        Ind_Sar_TimeFrame,
                        Ind_Sar_Step_Unit,
                        Ind_Sar_Step_Begin,
                        Ind_Sar_Step_Max);*/
   
   int symbolCount=ArraySize(SYMBOL_LIST);
   for(int symbolIndex=0;symbolIndex<symbolCount;symbolIndex++){     
      if(!this.symbolShare.runable(symbolIndex))continue;                     
      this.trendSarChl.init(symbolIndex,
                              &this.symbolShare,
                              &this.analysisShare,
                              Ind_Sar_TimeFrame,
                              Ind_Sar_Step_Unit,
                              Ind_Sar_Step_Begin,
                              Ind_Sar_Step_Max);
      this.indicatorShare.setChannel(this.trendSarChl.getChannel());                        
   }                     
}
  
//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CIndicatorCtl::refresh()
{     
   rkeeLog.writeLmtLog("CIndicatorCtl: refresh");   
   //0: symbol share reset
   this.symbolShare.reSet();
   this.analysisShare.refresh();
   //1: correlation
   this.correlation.run();
   //this.priceChannel.run();
   
   //2:sar trend 
   //this.trendSar.run();
   
   //3:sar channel trend 
   this.trendSarChl.run();
   
}    


//+------------------------------------------------------------------+
//|  get order share data
//+------------------------------------------------------------------+
CSymbolShare* CIndicatorCtl::getSymbolShare(void)
{
   return &this.symbolShare;
}

//+------------------------------------------------------------------+
//|  get signal share data
//+------------------------------------------------------------------+
CIndicatorShare* CIndicatorCtl::getIndicatorShare(void)
{
   return &this.indicatorShare;
} 

//+------------------------------------------------------------------+
//|  get analysis share 
//+------------------------------------------------------------------+ 
CAnalysisShare* CIndicatorCtl::getAnalysisShare()
{
   return &this.analysisShare;
}

//+------------------------------------------------------------------+
//|  get recovery share 
//+------------------------------------------------------------------+ 
CRecoveryShare* CIndicatorCtl::getRecoveryShare(void)
{
   return &this.recoveryShare;
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CIndicatorCtl::CIndicatorCtl()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CIndicatorCtl::~CIndicatorCtl()
  {
  }
//+------------------------------------------------------------------+
