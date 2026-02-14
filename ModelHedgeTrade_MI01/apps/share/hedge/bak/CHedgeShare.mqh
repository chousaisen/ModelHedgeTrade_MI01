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
#include "..\..\header\hedge\CHeader.mqh"
#include "..\model\order\COrder.mqh"
#include "..\indicator\CIndicatorShare.mqh"
#include "..\symbol\CSymbolShare.mqh"
//#include "..\indicator\data\CSymbolCorrelation.mqh"
#include "CHedgeGroup.mqh"

class CHedgeShare
  {
   private:
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
      //test begin
      double                             sumHedgeRate;
      int                                hedgeCount;
      double                             avgHedgeRate;
      //test end
      
   public:
                     CHedgeShare();
                    ~CHedgeShare();     
      //--- methods of initilize
      void            init(CArrayList<COrder*>* orderList,
                              CIndicatorShare* indicatorShare);
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
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CHedgeShare::init(CArrayList<COrder*>* orderList,CIndicatorShare* indicatorShare)
  {
     this.orderList=orderList;
     this.indicatorShare=indicatorShare;
  }
//+------------------------------------------------------------------+
//|  run the share control
//+------------------------------------------------------------------+
void CHedgeShare::run()
  {
   
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
      hedgeGroup.setSymbolShare(this.symbolShare);
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
   hedgeGroup.setHedgeCorrelationType(value);
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
//|  class constructor   
//+------------------------------------------------------------------+
CHedgeShare::CHedgeShare(){
   this.hedgeGroupPool.setSymbolShare(this.symbolShare);
   this.sumHedgeRate=0;
   this.hedgeCount=0;
   this.avgHedgeRate=0;
   this.clearOrderMinus=true;
}
CHedgeShare::~CHedgeShare(){}