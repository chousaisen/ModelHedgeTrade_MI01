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
      void                clearOverSymbolModels(int symbolIndex,
                                          int maxOrderCount,
                                          double diffCenterPips);
                                             
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
           this.clearOverSymbolModels(i,
                                      Clear_Model_Max_Order_Count,
                                      Clear_Model_Diff_Center_Pips);         
      }
   }   
}

//+------------------------------------------------------------------+
//|  clear over symbol models
//+------------------------------------------------------------------+
void CModelClearOver::clearOverSymbolModels(int symbolIndex,int maxOrderCount, double diffCenterPips){
   
   this.debugLog="<clearOverModels><symbol>" + SYMBOL_LIST[symbolIndex]
                  + "<maxOrderCount>" + maxOrderCount
                  + "<diffCenterPips>" + diffCenterPips;
     
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
   double overOrderCount = totalOrderCount - maxOrderCount;
   overOrderCount=overOrderCount+overOrderCount*Clear_Model_Diff_Order_Rate;
   double curPrice = this.getSymbolShare().getSymbolPrice(SYMBOL_LIST[symbolIndex],ORDER_TYPE_BUY);
   
   // 计算成本重心
   double totalWeightedPrice = 0;
   double totalLots = 0;
   double highestAvgPrice = -DBL_MAX;
   double lowestAvgPrice = DBL_MAX;
   
   for (int i = 0; i < modelCount; i++) {
      CModelI *model;
      if (modelList.TryGetValue(i, model)) {

         double avgPrice = model.getAvgPrice();
         double lots = model.getLot();
         
         totalWeightedPrice += avgPrice * lots;
         totalLots += lots;
         
         if (avgPrice > highestAvgPrice) highestAvgPrice = avgPrice;
         if (avgPrice < lowestAvgPrice) lowestAvgPrice = avgPrice;
      }
   }
   
   if (totalLots == 0) return;
   
   double costCenter = totalWeightedPrice / totalLots;
   double priceUpper = costCenter + diffCenterPips * this.getSymbolShare().getSymbolPoint(SYMBOL_LIST[symbolIndex]);
   double priceLower = costCenter - diffCenterPips * this.getSymbolShare().getSymbolPoint(SYMBOL_LIST[symbolIndex]);
   
   // 如果当前价格不在成本重心上下 M PIPS 内，则退出
   if (curPrice > priceUpper || curPrice < priceLower) return;
   
   this.debugLog = "<overOrderCount>" + overOrderCount
                  + "<totalLots>" + totalLots
                  + "<highestAvgPrice>" + highestAvgPrice
                  + "<lowestAvgPrice>" + lowestAvgPrice
                  + "<priceUpper>" + priceUpper
                  + "<priceLower>" + priceLower;
                     
   logData.addDebugInfo(this.debugLog);
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
                     double avg = m.getAvgPrice();
                     if (avg > highestAvgPrice) highestAvgPrice = avg;
                     if (avg < lowestAvgPrice) lowestAvgPrice = avg;
                  }
               }
            }
         }
      }
   }
}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelClearOver::CModelClearOver(){

}
CModelClearOver::~CModelClearOver(){
}