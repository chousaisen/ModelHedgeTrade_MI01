//+------------------------------------------------------------------+
//|                                                     CModel01.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "../../share/CShareCtl.mqh"
#include "../CModelI.mqh"

class CModelProtect 
{
      private:
         CShareCtl*            shareCtl;
         CIndicatorShare*      indShare;
         CArrayList<ulong>     clearModelList;
      public:
                              CModelProtect();
                              ~CModelProtect(); 
        void                  init(CShareCtl *shareCtl);
        CArrayList<CModelI*>* getModels();
        CIndicatorShare*      getIndicatorShare();
        void                  refresh();
        double                clearHedgeLot(CModelI* model);
        int                   clearModels();
        CHedgeGroup*          getHedgeGroupPool();
         
};
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CModelProtect::init(CShareCtl *shareCtl){
   this.shareCtl=shareCtl;
   this.indShare=shareCtl.getIndicatorShare();
}

//+------------------------------------------------------------------+
//|  get model list
//+------------------------------------------------------------------+
CArrayList<CModelI*>* CModelProtect::getModels(){
   return this.shareCtl.getModelShare().getModels();
}

//+------------------------------------------------------------------+
//|  get indicator share 
//+------------------------------------------------------------------+
CIndicatorShare*  CModelProtect::getIndicatorShare(){
   return this.indShare;
}

//+------------------------------------------------------------------+
//|  get indicator share 
//+------------------------------------------------------------------+
CHedgeGroup*  CModelProtect::getHedgeGroupPool(){
   return this.shareCtl.getHedgeShare().getHedgeGroupPool();
}

//+------------------------------------------------------------------+
//|  refresh protect info
//+------------------------------------------------------------------+
void CModelProtect::refresh(void){
   this.clearModelList.Clear();   
}

//+------------------------------------------------------------------+
//|  clear minus models
//+------------------------------------------------------------------+
double CModelProtect::clearHedgeLot(CModelI* model){

   //CHedgeGroup* modelGroup=model.getHedgeGroup();
   CHedgeGroup* modelGroup=this.getHedgeGroupPool();
   modelGroup.setExceptMode(true);
   modelGroup.setExceptModels(&this.clearModelList);
   int symbolIndex=model.getSymbolIndex();
   ENUM_ORDER_TYPE type=model.getTradeType();
   if(type==ORDER_TYPE_SELL){
      type=ORDER_TYPE_BUY;
   }else{
      type=ORDER_TYPE_SELL;
   }
   double lot=model.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){
      this.clearModelList.Add(model.getModelId());
      modelGroup.hedgeOrders();
      return lot;
   }
   return 0;
}

//+------------------------------------------------------------------+
//|  clear models
//+------------------------------------------------------------------+
int CModelProtect::clearModels(){
   //clear model
   CArrayList<CModelI*> modelList=this.shareCtl.getModelShare().getModels();
   int modelCount=modelList.Count();
   //clean model list
   int clearCount=0;
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){                          
         if(this.clearModelList.Contains(model.getModelId())){
            model.setActionFlg("clearMinusModels.clearModels");
            clearCount+=model.closeOrders();         
         }
      }
   }
   return clearCount;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelProtect::CModelProtect(){}
CModelProtect::~CModelProtect(){
}