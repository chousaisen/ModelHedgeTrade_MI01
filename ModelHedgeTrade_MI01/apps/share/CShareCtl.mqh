//+------------------------------------------------------------------+
//|                                                    CShareCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"


#include "..\comm\ComFunc.mqh"
#include "..\comm\CLog.mqh"
#include "..\client\CClientCtl.mqh"

//share data
#include "..\indicator\CIndicatorCtl.mqh"
#include "client\CClientShare.mqh"
#include "indicator\CIndicatorShare.mqh"
#include "filter\CFilterShare.mqh"
#include "hedge\CHedgeShare.mqh"
#include "symbol\CSymbolShare.mqh"
#include "model\CModelShare.mqh"
#include "signal\CSignalShare.mqh"
#include "analysis\CAnalysisShare.mqh"
#include "recovery\CRecoveryShare.mqh"
#include "market\CMarketShare.mqh"

class CShareCtl{

   private:
      
      //common info
      int               modelKind;      
      
      //control share
      CClientCtl*       clientCtl;
      CIndicatorCtl*    indicatorCtl;   
      
      //outside object share
      CSymbolShare*     symbolShare;
      CIndicatorShare*  indicatorShare;
      CAnalysisShare*   analysisShare;
      CRecoveryShare*   recoveryShare;
      
      //local object share
      CFilterShare      filterShare;       
      CModelShare       modelShare;
      CHedgeShare       hedgeShare;  
      CSignalShare      signalShare;
      CMarketShare      marketShare;
      CClientShare      clientShare;     
      
   public:
                          CShareCtl();
                         ~CShareCtl();
     
         //--- methods of initilize
         void                init(CIndicatorCtl* indicatorCtl); 
         //--- refresh
         void                refresh();
         //--- get filter share
         CFilterShare*       getFilterShare();
         //--- get hedge share
         CHedgeShare*        getHedgeShare();
         //--- get model share
         CModelShare*        getModelShare();
         //--- get signal share
         CSignalShare*       getSignalShare(); 
         //--- get signal share
         CSymbolShare*       getSymbolShare(); 
         //--- get indicator share
         CIndicatorShare*    getIndicatorShare(); 
         //--- get analysis share  
         CAnalysisShare*     getAnalysisShare();         
         //--- get recovery share
         CRecoveryShare*     getRecoveryShare();
         //--- get market share
         CMarketShare*       getMarketShare();
         //--- get client share
         CClientShare*       getClientShare();
         //+------------------------------------------------------------------+
         //|  get share properties  function
         //+------------------------------------------------------------------+
         
         //--- get symbol correlation by symbol 
         double              getSymbolCorrelation(string symbol1,string symbol2);
         
         //--- get client control
         CClientCtl*         getClientCtl();
         void                setClientCtl(CClientCtl* clientCtl); 
         
         //reload recovery info
         void                reload(); 
         //--- set model kind
         void            setModelKind(int modelKind);
         //--- get model kind
         int             getModelKind();             
};

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CShareCtl::init(CIndicatorCtl* indicatorCtl){

   this.indicatorCtl=indicatorCtl;
   this.symbolShare=this.indicatorCtl.getSymbolShare();
   this.indicatorShare=this.indicatorCtl.getIndicatorShare();
   this.analysisShare=this.indicatorCtl.getAnalysisShare();
   this.recoveryShare=this.indicatorCtl.getRecoveryShare();

   this.modelShare.init(this.symbolShare,this.analysisShare,&this.marketShare);
   this.hedgeShare.init(this.modelShare.getOrders(),
                        this.indicatorShare,
                        this.symbolShare,
                        this.getMarketShare(),
                        this.getClientShare());
                        
   this.getModelShare().getModelAnalysis().init(this.getSymbolShare().getSymbolInfos());
   this.getModelShare().getModelAnalysisPre().init(this.getSymbolShare().getSymbolInfos());  
}
  
//+------------------------------------------------------------------+
//|  reset the share control
//+------------------------------------------------------------------+
void CShareCtl::refresh(void)
{
   //this.symbolShare.reSet();
   //this.analysisShare.refresh(); 
}  

//+------------------------------------------------------------------+
//|  get filter share
//+------------------------------------------------------------------+
CFilterShare* CShareCtl::getFilterShare(){
   return &this.filterShare;
}


//+------------------------------------------------------------------+
//|  get hedge share data
//+------------------------------------------------------------------+
CHedgeShare* CShareCtl::getHedgeShare(void)
{
   return &this.hedgeShare;
}
 
//+------------------------------------------------------------------+
//|  get signal share data
//+------------------------------------------------------------------+
CSignalShare* CShareCtl::getSignalShare(void)
{
   return &this.signalShare;
}  
  
//+------------------------------------------------------------------+
//|  get model share data
//+------------------------------------------------------------------+
CModelShare* CShareCtl::getModelShare(void)
{
   return &this.modelShare;
}

//+------------------------------------------------------------------+
//|  get order share data
//+------------------------------------------------------------------+
CSymbolShare* CShareCtl::getSymbolShare(void)
{
   return this.symbolShare;
}

//+------------------------------------------------------------------+
//|  get signal share data
//+------------------------------------------------------------------+
CIndicatorShare* CShareCtl::getIndicatorShare(void)
{
   return this.indicatorShare;
} 

//+------------------------------------------------------------------+
//|  get analysis share 
//+------------------------------------------------------------------+ 
CAnalysisShare* CShareCtl::getAnalysisShare()
{
   return this.analysisShare;
}

//+------------------------------------------------------------------+
//|  get recovery share 
//+------------------------------------------------------------------+ 
CRecoveryShare* CShareCtl::getRecoveryShare(void)
{
   return this.recoveryShare;
}

//+------------------------------------------------------------------+
//|  get market share 
//+------------------------------------------------------------------+ 
CMarketShare*  CShareCtl::getMarketShare(){
   return &this.marketShare;
}

//+------------------------------------------------------------------+
//|  get client share 
//+------------------------------------------------------------------+ 
CClientShare*  CShareCtl::getClientShare(){
   return &this.clientShare;
}

//+------------------------------------------------------------------+
//|  get symbol correlation value by symbol
//+------------------------------------------------------------------+
double CShareCtl::getSymbolCorrelation(string symbol1,
                                             string symbol2){
   int symbolIndex1=this.getSymbolShare().getSymbolIndex(symbol1);
   int symbolIndex2=this.getSymbolShare().getSymbolIndex(symbol2);
   return this.hedgeShare.getSymbolCorrelation(symbolIndex1,symbolIndex2);
}

//+------------------------------------------------------------------+
//|  get client control
//+------------------------------------------------------------------+
CClientCtl* CShareCtl::getClientCtl(){
   return this.clientCtl;
}

//+------------------------------------------------------------------+
//|  get client control
//+------------------------------------------------------------------+
void CShareCtl::setClientCtl(CClientCtl* clientCtl){
   this.clientCtl=clientCtl;
   this.analysisShare.setClientCtl(this.clientCtl);
   this.recoveryShare.setRecoveryDB(this.clientCtl.getDB());
}      

//+------------------------------------------------------------------+
//| reload recovery info
//+------------------------------------------------------------------+
void CShareCtl::reload(){
   this.recoveryShare.loadRangeInfo();
   this.analysisShare.getCurRange().markReload();
}

//+------------------------------------------------------------------+
//|  set modelKind
//+------------------------------------------------------------------+
void CShareCtl::setModelKind(int modelKind){
   this.modelKind=modelKind;
   
   //set other object's model kind
   this.getHedgeShare().setModelKind(this.modelKind);
    
}

//+------------------------------------------------------------------+
//|  set modelKind
//+------------------------------------------------------------------+
int CShareCtl::getModelKind(){
   return this.modelKind;
}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CShareCtl::CShareCtl(){
   //this.accountNo=AccountInfoInteger(ACCOUNT_LOGIN);
   //this.reloadFlg=false;
}
CShareCtl::~CShareCtl(){}