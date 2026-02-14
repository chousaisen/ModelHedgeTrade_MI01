//+------------------------------------------------------------------+
//|                                             CModelClearOver.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "../../comm/ComFunc2.mqh"
#include "../../share/CShareCtl.mqh"
#include "../CModelI.mqh"
#include "CModelProtect.mqh"

class CModelClearOver: public CModelProtect 
{
      private:
           string         debugLog;
      public:
                          CModelClearOver();
                          ~CModelClearOver(); 
      //--- clear Exceed return models
      //--- clear Exceed return models
      void                clearOverModels();      
      void                clearOverSymbolModels(int symbolIndex,int maxOrderCount);
                                             
};

//+------------------------------------------------------------------+
//|  clear over symbol models
//+------------------------------------------------------------------+
void CModelClearOver::clearOverModels(){
   
   if(!Clear_Model_Over)return;
   
   int total_symbols = ArraySize(SYMBOL_LIST);   
   // Output weights for each symbol      
   for (int i = 0; i < total_symbols; i++){ 
      if(this.getSymbolShare().runable(i)){
           this.clearOverSymbolModels(i,Clear_Model_Max_Order_Count);         
      }
   }   
}

//+------------------------------------------------------------------+
//|  clear over symbol models
//+------------------------------------------------------------------+
void CModelClearOver::clearOverSymbolModels(int symbolIndex,int maxOrderCount){
   
   this.debugLog="<clearOverModels><symbol>" + SYMBOL_LIST[symbolIndex]
                  + "<maxOrderCount>" + maxOrderCount;
     
   // Sort models by their distance from edges (we'll close farthest first)
   CArrayList<CModelI*> modelList;    
   // Add models to list 
   for (int i = 0; i < this.getModels().Count(); i++) {
     CModelI *model;
     if (this.getModels().TryGetValue(i, model)) {
         if(symbolIndex!=model.getSymbolIndex())continue;
         modelList.Add(model);
     }
   }
   // get modles count
   int modelCount = modelList.Count();   
   if (modelCount == 0) return;   
   
   // 计算所有订单总数
   int totalOrderCount = 0;
   for (int i = 0; i < modelCount; i++) {
      CModelI *model;
      if (modelList.TryGetValue(i, model)) {         
         totalOrderCount += model.getOrderCount();
      }
   }
   
   this.debugLog +="<totalOrderCount>" + totalOrderCount;   
   logData.addDebugInfo(this.debugLog);
   
   // 如果订单总数未超过 maxOrderCount，则无需清理
   if (totalOrderCount <= maxOrderCount) return;   
   
   double curPrice = this.getCurPrice(symbolIndex);
   double point = this.getPoint(symbolIndex);
   CModelCostLine* modelCostLine=this.getModelAnalysis().getModelCostLine();
   //double costCenter = totalWeightedPrice / totalLots;
   double costCenter = modelCostLine.getCostCenter();
   double highestAvgPrice = modelCostLine.getUpperEdge();
   double lowestAvgPrice = modelCostLine.getDownEdge(); 
   modelCostLine.calculateEdge(curPrice,point,0);
   double costEdgeRate = modelCostLine.getCostEdgeRate(); 
   
   if(costEdgeRate>Clear_Model_Over_Limit_Cost_EdgeRate)return;
   
   double overOrderCount = (totalOrderCount-maxOrderCount) 
                           + ((double)totalOrderCount)*Clear_Model_Over_Order_DiffRate;
   this.debugLog = "<overOrderCount>" + overOrderCount
                  + "<maxOrderCount>" + maxOrderCount
                  + "<highestAvgPrice>" + highestAvgPrice
                  + "<lowestAvgPrice>" + lowestAvgPrice;
                     
   logData.addDebugInfo(this.debugLog);
   int limitOrderCount=totalOrderCount-overOrderCount;
   // 关闭超额订单
   int highestIndex=0,lowestIndex=0;
   for (int i = modelCount - 1; i >limitOrderCount; i--) {
      CModelI *model;
      highestIndex=i;
      if (modelList.TryGetValue(i, model)) {
         //double avgPrice = model.getAvgPrice(); 
         if(model.getProfitPips()<Clear_Model_Over_Order_LossPips){
            model.markClearFlag(true);
            if (model.clearModel()) {
               overOrderCount -= model.getOrderCount();         
            }   
         }
      }
      lowestIndex=(modelCount - 1)-i;
      if (modelList.TryGetValue(lowestIndex, model)) {
         //double avgPrice = model.getAvgPrice();   
         if(model.getProfitPips()<Clear_Model_Over_Order_LossPips){
            model.markClearFlag(true);
            if (model.clearModel()) {
               overOrderCount -= model.getOrderCount();         
            }
         }      
      }
      if(overOrderCount<=0)break;      
   }
   /*
   // 关闭超额订单
   for (int i = modelCount - 1; i >= 0 && overOrderCount > 0; i--) {
      CModelI *model;
      if (modelList.TryGetValue(i, model)) {
         double avgPrice = model.getAvgPrice();
         
         // 优先关闭高价卖单和低价买单
         if ((curPrice >= costCenter && avgPrice >= highestAvgPrice) || 
             (curPrice <= costCenter && avgPrice <= lowestAvgPrice)) {
            model.markClearFlag(true);
            if (model.clearModel()) {
               
               this.debugLog ="<clearModel>" + model.getModelId()
                              + "<orderCount>" + model.getOrderCount()
                              + "<curPrice>" + curPrice
                              + "<costCenter>" + costCenter
                              + "<avgPrice>" + avgPrice
                              + "<highestAvgPrice>" + highestAvgPrice
                              + "<lowestAvgPrice>" + lowestAvgPrice;  
                               
               logData.addDebugInfo(this.debugLog);               
               
               overOrderCount -= model.getOrderCount();
               highestAvgPrice = -DBL_MAX;
               lowestAvgPrice = DBL_MAX;
               
               // 重新计算边界
               for (int j = 0; j < modelCount; j++) {
                  CModelI *m;
                  if (modelList.TryGetValue(j, m)) {
                     if(m.getClearFlag())continue;
                     double avg = m.getAvgPrice();
                     if (avg > highestAvgPrice) highestAvgPrice = avg;
                     if (avg < lowestAvgPrice) lowestAvgPrice = avg;
                  }
               }
            }
         }
      }
   }*/
}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelClearOver::CModelClearOver(){

}
CModelClearOver::~CModelClearOver(){
}