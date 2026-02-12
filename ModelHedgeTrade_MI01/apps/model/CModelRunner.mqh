//+------------------------------------------------------------------+
//|                                                    CModelCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"


#include "../header/model/CHeader.mqh"
#include "../share/CShareCtl.mqh"
#include "CModelRunnerI.mqh"
#include "CModelI.mqh"
#include "CModel.mqh"

class CModelRunner: public CModelRunnerI
  {
public:
      CShareCtl*                                shareCtl;
      
      //--- hedge group info
      CHedgeGroup*                              hedgeGroup;           
      
      //--- model control
      int                                       modelKind;
      int                                       signalKind;
      int                                       symbolModelTypeMaxCount;
      int                                       modelMaxCount;
      double                                    baseLot;
      double                                    hedgeBaseLot;
      bool                                      hedgeFlg;
      
public:
                                                CModelRunner();
                     
                                                ~CModelRunner();                                                
     //--- methods of initilize
     void                                       init(CShareCtl *shareCtl);
     //--- load   model when init
     void                                        reLoadModels(){};
     //--- open models
     int                                         openModels();          
     //--- open/run model
     //void                                       run();
     //--- run model list
     void                                       runModels();
     //--- start model and open order by signal
     void                                       openModel(CModel *model,CSignal* signal);     
     //--- create model
     void                                       addModel(CModel *model);
     //--- get signal list
     CSignalList*                               getSignalList(int signalKindId); 
     //--- get model kind
     int                                        getModelKind();      
     //--- set model kind
     void                                       setModelKind(int value);
     //--- filter model open conditions by singal
     bool                                       openFilter(CSignal* signal);
     //--- get signal Kind
     int                                        getSignalKind();      
     //--- set signal kind
     void                                       setSignalKind(int value);  
     //--- get symbol max count
     int                                        getSymbolModelTypeMaxCount();      
     //--- set symbol max count
     void                                       setSymbolModelTypeMaxCount(int value); 
     //--- get active model max count
     int                                        getModelMaxCount();
     //--- set active model max count
     void                                       setModelMaxCount(int value);
     //--- set base unit lot size
     void                                       setBaseLot(double value);
     //--- set base unit lot size
     void                                       setHedgeBaseLot(double value);     
     //--- hedge correlation
     bool                                       hedgeCorrelation(int symbolIndex,ENUM_ORDER_TYPE type,double lot); 
     //--- refresh hedge orders data
     void                                       hedgeOrders();
     //--- get hedge Group Info
     CHedgeGroupInfo*                           getHedgeGroupInfo();
     //--- add symbol list  
     //void                                       addSymbol(string symbol);
     //--- clean models(when models no orders)
     void                                       clean();
     //--- get active model count
     int                                        getModelCount();
     //--- get active model count by symbol and order type
     int                                        getSymbolModelTypeCount(int symbolIndex,ENUM_ORDER_TYPE type);
     //--- set hedge flag
     void                                       setHedgeFlg(bool value);
     //--- get hedge flag
     bool                                       getHedgeFlg();
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CModelRunner::init(CShareCtl *shareCtl){
   this.baseLot=Comm_Unit_LotSize;
   this.shareCtl=shareCtl;
   this.hedgeGroup=this.shareCtl.getHedgeShare().getHedgeGroup(this.modelKind);
   this.initModels();
}


//+------------------------------------------------------------------+
//|  add model to the model list
//+------------------------------------------------------------------+
void CModelRunner::addModel(CModel *model)
{   
   this.shareCtl.getModelShare().addModel(model);  
}

//+------------------------------------------------------------------+
//|  get hedge group info
//+------------------------------------------------------------------+
CHedgeGroupInfo*  CModelRunner::getHedgeGroupInfo(){
   return this.hedgeGroup.getHedgeGroupInfo();
}

//+------------------------------------------------------------------+
//|  filter conditions to create model
//+------------------------------------------------------------------+
bool  CModelRunner::openFilter(CSignal* signal){
    return this.shareCtl.getFilterShare().openFilter(signal);
}

//+------------------------------------------------------------------+
//|  run the muti model by signal
//+------------------------------------------------------------------+
int CModelRunner::openModels()
{  
   CSignalList *signalList=this.shareCtl.getSignalShare().getRealSignalList();       
   if(signalList==NULL)return 0;
   
   int singleCount=signalList.Count();
   int openModelCount=0;   
   for(int i=0;i<singleCount;i++){
      
      //filter conditions and judge signal
      CSignal* signal=signalList.getSignal(i);       
      if(!this.openFilter(signal))continue;

      //open model 
      CModel* model=this.createModel();
      this.openModel(model,signal);
      
      //refresh hedge data
      this.hedgeOrders();
      openModelCount++;
    }
    return openModelCount;
}

//+------------------------------------------------------------------+
//|  start model
//+------------------------------------------------------------------+  
void  CModelRunner::openModel(CModel *model,CSignal* signal){   
   
   rkeeLog.writeLmtLog("CModelRunner: openModel1 " + this.getModelKind());  

   model.init(this.shareCtl,
               this.hedgeGroup,
               this.getModelKind(),
               comFunc.createModelId(this.getModelKind()),
               signal.getSymbol(),
               signal.getTradeType());
   model.setStatusFlg(signal.getStatusFlg()); 
   model.setStatusIndex(signal.getStatusIndex());                   
   this.addModel(model);
   model.openModel();
   model.refresh();
}

//+------------------------------------------------------------------+
//|  hedge orders
//+------------------------------------------------------------------+
void CModelRunner::hedgeOrders(){
   //refresh hedge data
   this.hedgeGroup.hedgeOrders(); 
   //test begin
   this.shareCtl.getHedgeShare().getHedgeGroupPool().hedgeOrders(); 
}

//+------------------------------------------------------------------+
//|  judge the hedge correlation
//+------------------------------------------------------------------+
bool CModelRunner::hedgeCorrelation(int symbolIndex,ENUM_ORDER_TYPE type,double lot){
   return this.hedgeGroup.ifGroupHedge(this.modelKind,symbolIndex,type,lot);
}

//+------------------------------------------------------------------+
//|  get active model count
//+------------------------------------------------------------------+
int CModelRunner::getModelCount(){
   return this.hedgeGroup.getHedgeGroupInfo().getModelCount();
}

//+------------------------------------------------------------------+
//|  get active model count by symbol and order type
//+------------------------------------------------------------------+
int CModelRunner::getSymbolModelTypeCount(int symbolIndex,ENUM_ORDER_TYPE type){
   return this.hedgeGroup.getHedgeGroupInfo().getSymbolModelTypeCount(symbolIndex,type);
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelRunner::CModelRunner(){
   this.hedgeFlg=false;
}
CModelRunner::~CModelRunner(){
   delete this.hedgeGroup;
}


//+------------------------------------------------------------------+
//|  parameter get/set
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  get signl list
//+------------------------------------------------------------------+
CSignalList* CModelRunner::getSignalList(int signalKindId)
{
   return this.shareCtl.getSignalShare().getSignalList(signalKindId);   
}

//+------------------------------------------------------------------+
//|  get model kind
//+------------------------------------------------------------------+  
int   CModelRunner::getModelKind(void){
   return this.modelKind;
}

//+------------------------------------------------------------------+
//|  set model kind
//+------------------------------------------------------------------+  
void   CModelRunner::setModelKind(int value){
   rkeeLog.writeLmtLog("CModelRunner: setModelKind1 " + value);   
   this.modelKind=value;
}

//+------------------------------------------------------------------+
//|  get signal kind
//+------------------------------------------------------------------+  
int   CModelRunner::getSignalKind(void){
   return this.signalKind;
}

//+------------------------------------------------------------------+
//|  set signal kind
//+------------------------------------------------------------------+  
void   CModelRunner::setSignalKind(int value){
   this.signalKind=value;
}

//+------------------------------------------------------------------+
//|  set symbol max count
//+------------------------------------------------------------------+  
void   CModelRunner::setSymbolModelTypeMaxCount(int value){
   this.symbolModelTypeMaxCount=value;
}

//+------------------------------------------------------------------+
//|  get symbol max count
//+------------------------------------------------------------------+  
int   CModelRunner::getSymbolModelTypeMaxCount(){
   return this.symbolModelTypeMaxCount;
}

//+------------------------------------------------------------------+
//|  get active model max count
//+------------------------------------------------------------------+  
int   CModelRunner::getModelMaxCount(void){
   return this.modelMaxCount;
}

//+------------------------------------------------------------------+
//|  set symbol max count
//+------------------------------------------------------------------+  
void   CModelRunner::setModelMaxCount(int value){
   this.modelMaxCount=value;
}

//+------------------------------------------------------------------+
//|  set base unit lot size
//+------------------------------------------------------------------+  
void   CModelRunner::setBaseLot(double value){
   this.baseLot=value;
}

//+------------------------------------------------------------------+
//|  set hedge base unit lot size
//+------------------------------------------------------------------+  
void   CModelRunner::setHedgeBaseLot(double value){
   this.hedgeBaseLot=value;
}

//+------------------------------------------------------------------+
//|  set hedge flag
//+------------------------------------------------------------------+  
void   CModelRunner::setHedgeFlg(bool value){
   this.hedgeFlg=value;
}

//+------------------------------------------------------------------+
//|  get hedge flag
//+------------------------------------------------------------------+  
bool   CModelRunner::getHedgeFlg(){
   return this.hedgeFlg;
}
