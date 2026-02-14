//+------------------------------------------------------------------+
//|                                                 CModelHedgeFilter.mqh |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "CModelFilter.mqh"

class CModelHedgeFilter : public CModelFilter
{
      private:         
         //CArrayList<ulong>     clearModelList;
      public:
                              CModelHedgeFilter();
                              ~CModelHedgeFilter();
                    
        CArrayList<CModelI*>* getModels();        
        void                  refresh();
        double                clearHedgeLot(CModelI* model);
        int                   clearModels();   
        void                  addClearModel(CModelI* model);                  
                     
};

//+------------------------------------------------------------------+
//|  get model list
//+------------------------------------------------------------------+
CArrayList<CModelI*>* CModelHedgeFilter::getModels(){
   return this.getModelShare().getModels();
}

//+------------------------------------------------------------------+
//|  refresh protect info
//+------------------------------------------------------------------+
void CModelHedgeFilter::refresh(void){
   //this.clearModelList.Clear();   
}

//+------------------------------------------------------------------+
//|  add clear model
//+------------------------------------------------------------------+
void CModelHedgeFilter::addClearModel(CModelI* model){
   model.markClearFlag(true);
}

//+------------------------------------------------------------------+
//|  clear minus models
//+------------------------------------------------------------------+
double CModelHedgeFilter::clearHedgeLot(CModelI* model){

   CHedgeGroup* modelGroup=this.getHedgeShare().getHedgeGroupPool();
   int symbolIndex=model.getSymbolIndex();
   ENUM_ORDER_TYPE type=model.getTradeType();
   if(type==ORDER_TYPE_SELL){
      type=ORDER_TYPE_BUY;
   }else{
      type=ORDER_TYPE_SELL;
   }
   double lot=model.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){
      //this.clearModelList.Add(model.getModelId());
      this.addClearModel(model);
      modelGroup.hedgeOrders();
      return lot;
   }
   return 0;
}
  
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelHedgeFilter::CModelHedgeFilter(){}
CModelHedgeFilter::~CModelHedgeFilter(){
}