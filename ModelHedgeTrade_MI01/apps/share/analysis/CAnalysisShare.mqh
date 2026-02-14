//+------------------------------------------------------------------+
//|                                           CAnalysisShare.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\..\comm\ComFunc2.mqh"
#include "..\..\client\CClientCtl.mqh"
#include "..\symbol\CSymbolShare.mqh"
#include "..\indicator\CIndicatorShare.mqh"
//#include "..\recovery\CRecoveryShare.mqh"
#include "status\CRange.mqh"
//#include "status\CTrend.mqh"
//#include "status\CSupportLine.mqh"
#include "status\CChannel.mqh"

class CAnalysisShare{
  private: 

        CChannel*             channelInfo;
        CRange                curRange;
        CIndicatorShare*      indShare;        
        CSymbolShare*         symbolShare;
        CClientCtl*           clientCtl;
        int                   sarTrendFlg[SYMBOL_MAX_COUNT];
        double                upperEdge[SYMBOL_MAX_COUNT];
        double                downEdge[SYMBOL_MAX_COUNT];
        //debug info (use to database table)
        string                debugDBInfo;
  public:
                              CAnalysisShare();
                              ~CAnalysisShare();
         
         //--- init 
         void                 init(CSymbolShare* symbolShare,
                                       CIndicatorShare* indShare);
         //--- reset data         
         void                 reSet();
         //--- make Analysis Data
         void                 refresh(); 
         //--- analysis trend data
         //void                 trendAnalysis(int symbolIndex);
         //--- set client control
         void                 setClientCtl(CClientCtl* clientCtl);
         //--- set sar trend flag
         //void                 setSarTrendFlg(int symbolIndex,int trendFlg);
         //--- set upper edge
         void                 setUpperEdge(int symbolIndex,double edgePrice);
         //--- set down edge
         void                 setDownEdge(int symbolIndex,double edgePrice);
         //--- debug info(database)
         void                 setDebugDBInfo(string tableInfo);
         
         //--- commom function(getter/setter)
         CRange*              getCurRange(){return &this.curRange;}
         //CTrend*              getCurTrend(){return &this.curTrend;}
         //int                  getSarTrendFlg(int symbolIndex){return this.sarTrendFlg[symbolIndex];}
         void                 setChannel(CChannel* channel){this.channelInfo=channel;}
         CChannel*            getChannel(){return this.channelInfo;}
};

//+------------------------------------------------------------------+
//|   debug info(database)
//+------------------------------------------------------------------+
void CAnalysisShare::setDebugDBInfo(string tableInfo){
   this.debugDBInfo=tableInfo;
}

//+------------------------------------------------------------------+
//|  init indicator analysis
//+------------------------------------------------------------------+
void CAnalysisShare::init(CSymbolShare* symbolShare,
                           CIndicatorShare* indShare){
   this.symbolShare=symbolShare;
   this.indShare=indShare;

   this.curRange.init(symbolShare.getSymbolInfos());
   this.curRange.setIndShare(this.indShare);
   this.debugDBInfo="<curATR_d>0<curStdDev_d>0<sumAtrStdDev_d>0<adjustStep_d>0<trendFlg_t>NONE";
}

//+------------------------------------------------------------------+
//|  make AnalysisData data
//+------------------------------------------------------------------+
void CAnalysisShare::refresh(){

   rkeeLog.writeLmtLog("CAnalysisShare: refresh");
   int total_symbols = ArraySize(SYMBOL_LIST);   
   // Output weights for each symbol      
   for (int i = 0; i < total_symbols; i++){ 
      if(this.symbolShare.runable(i)){      
         this.curRange.makeStatus(i);
         //this.curTrend.makeStatus(i,&this.curRange);
      }
   }      
}

//+------------------------------------------------------------------+
//| set client control
//+------------------------------------------------------------------+
void CAnalysisShare::setClientCtl(CClientCtl* clientCtl){
   this.clientCtl=clientCtl;
   this.curRange.setClientCtl(this.clientCtl);
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CAnalysisShare::CAnalysisShare(){}
CAnalysisShare::~CAnalysisShare(){}