//+------------------------------------------------------------------+
//|                                                  CHedgeShare.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>

#include "..\..\comm\CLog.mqh"
#include "..\model\order\COrder.mqh"
#include "..\indicator\CIndicatorShare.mqh"
#include "..\client\CClientShare.mqh"
#include "..\market\CMarketShare.mqh"
#include "..\symbol\CSymbolShare.mqh"
#include "CRiskHedgePair.mqh"

#include "CHedgeGroup.mqh"

class CHedgeShare
  {
   private:
   
      //model kind
      int                                modelKind;   
      //hedge level&orders hedge group(group by model kind: order list)   
      CIndicatorShare*                   indicatorShare;
      CSymbolShare*                      symbolShare; 
      CArrayList<int>                    hedgeGroupIdList;   
      CHashMap<int,CHedgeGroup*>         hedgeGroupList;
      //CSymbolCorrelation*                symbolCorrelation;
      CArrayList<COrder*>*               orderList;
      //hedge group with the all orders in the trade pool
      CHedgeGroup                        hedgeGroupPool;
      //clear count
      int                                clearOrderCount;
      bool                               clearOrderMinus;
      bool                               clearOrderPlus;

      //risk hedge pair share
      CRiskHedgePair                      riskHedgePair;

      
   public:
                     CHedgeShare();
                    ~CHedgeShare();     
      //--- methods of initilize
      void            init(CArrayList<COrder*>* orderList,
                              CIndicatorShare* indicatorShare,
                              CSymbolShare*   symbolShare,
                              CMarketShare*   marketShare,
                              CClientShare*   clientShare);
      //--- run CHedgeShare
      void            run();
      //--- get symbol correlation by symbol index
      double          getSymbolCorrelation(int symbolIndex1,int symbolIndex2); 
      //--- set symbol correlation
      //void            setSymbolCorrelation(int symbolIndex1,int symbolIndex2,double value); 
      //--- get hedge group
      CHedgeGroup*    getHedgeGroup(int hedgeGroupId);      
      //--- get last hedge group
      CHedgeGroup*    getCurHedgeGroup();      
      //--- add hedge group
      //void            addHedgeGroup(int hedgeGroupId,int modelKind);
      //--- set min correlation rate
      void            setMinCorrelationRate(int hedgeGroupId,double value); 
      //--- set hedge correlation type
      void            setHedgeCorrelationType(int hedgeGroupId,int value);  
      //--- set symbol free/no hedge lot
      void            setSymbolFreeLots(int hedgeGroupId,double value);
      //--- get hedge group id list
      CArrayList<int>*  getHedgeGroupIdList();
      
      //--- get hedge group pool
      CHedgeGroup*    getHedgeGroupPool(); 
      
      //--- get risk hedge share pair
      CRiskHedgePair*   getRiskHedgePair();     
      //--- set model kind
      void              setModelKind(int modelKind);
      //--- get model kind
      int               getModelKind();        
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CHedgeShare::init(CArrayList<COrder*>* orderList,
                           CIndicatorShare* indicatorShare,
                           CSymbolShare*   symbolShare,
                           CMarketShare*   marketShare,
                           CClientShare*   clientShare)
  {
     this.orderList=orderList;
     this.indicatorShare=indicatorShare;
     this.symbolShare=symbolShare;
     this.hedgeGroupPool.init(this.symbolShare,this.orderList);
     this.riskHedgePair.init(orderList,
                              marketShare.getMarketInfo(),
                              clientShare.getDbInfo());
  }
//+------------------------------------------------------------------+
//|  run the share control
//+------------------------------------------------------------------+
void CHedgeShare::run(){
   
}   

//+------------------------------------------------------------------+
//|  get hedge group
//+------------------------------------------------------------------+
CHedgeGroup* CHedgeShare::getHedgeGroup(int hedgeGroupId){
   CHedgeGroup *hedgeGroup;
   if(this.hedgeGroupList.ContainsKey(hedgeGroupId)){
      this.hedgeGroupList.TryGetValue(hedgeGroupId,hedgeGroup);      
   }else{
      hedgeGroup=new CHedgeGroup();
      hedgeGroup.init(this.symbolShare,this.orderList);
      this.hedgeGroupList.Add(hedgeGroupId,hedgeGroup); 
      this.hedgeGroupIdList.Add(hedgeGroupId);  
   }
   return hedgeGroup;
}

//+------------------------------------------------------------------+
//|  get current hedge group(last hedge group)
//+------------------------------------------------------------------+
CHedgeGroup* CHedgeShare::getCurHedgeGroup(){

   int lastIndex=this.hedgeGroupIdList.Count()-1;
   if(lastIndex<0)return NULL;   
   int lastGroupId;
   if(this.hedgeGroupIdList.TryGetValue(lastIndex, lastGroupId))
   {
      CHedgeGroup *hedgeGroup;      
      if(this.hedgeGroupList.TryGetValue(lastGroupId,hedgeGroup)){
         return hedgeGroup;
      }
   }   
   return NULL;
}

//+------------------------------------------------------------------+
//|  set min correlation rate
//+------------------------------------------------------------------+
void CHedgeShare::setMinCorrelationRate(int hedgeGroupId,double value){
   CHedgeGroup *hedgeGroup=this.getHedgeGroup(hedgeGroupId);
   hedgeGroup.setMinCorrelationRate(value);
}

//+------------------------------------------------------------------+
//|  set hedge correlation type
//+------------------------------------------------------------------+  
void   CHedgeShare::setHedgeCorrelationType(int hedgeGroupId,int value){
   CHedgeGroup *hedgeGroup=this.getHedgeGroup(hedgeGroupId);
}

//+------------------------------------------------------------------+
//|  set symbol free/no hedge lot
//+------------------------------------------------------------------+  
void   CHedgeShare::setSymbolFreeLots(int hedgeGroupId,double value){
   CHedgeGroup *hedgeGroup=this.getHedgeGroup(hedgeGroupId);
   hedgeGroup.setSymbolFreeLots(value);
}

//+------------------------------------------------------------------+
//|  get the hedge group id list
//+------------------------------------------------------------------+
CArrayList<int>*  CHedgeShare::getHedgeGroupIdList(){
   return &this.hedgeGroupIdList;
}

//+------------------------------------------------------------------+
//|  get the hedge group pool with all the orders
//+------------------------------------------------------------------+
CHedgeGroup*   CHedgeShare::getHedgeGroupPool(){
   return &this.hedgeGroupPool;
}

//+------------------------------------------------------------------+
//|  get the hedge risk pair
//+------------------------------------------------------------------+
CRiskHedgePair*   CHedgeShare::getRiskHedgePair(){
   return &this.riskHedgePair;
}

//+------------------------------------------------------------------+
//|  set modelKind
//+------------------------------------------------------------------+
void CHedgeShare::setModelKind(int modelKind){
   this.modelKind=modelKind;
   
   //set other object's model kind
   this.getRiskHedgePair().setModelKind(this.modelKind);
    
}

//+------------------------------------------------------------------+
//|  set modelKind
//+------------------------------------------------------------------+
int CHedgeShare::getModelKind(){
   return this.modelKind;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CHedgeShare::CHedgeShare(){   
   this.clearOrderMinus=true;
}
CHedgeShare::~CHedgeShare(){}