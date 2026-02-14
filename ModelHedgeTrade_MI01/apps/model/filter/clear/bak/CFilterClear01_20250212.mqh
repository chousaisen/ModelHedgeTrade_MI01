//+------------------------------------------------------------------+
//|                                                CFilterClear01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../CModelHedgeFilter.mqh"

class CFilterClear01: public CModelHedgeFilter 
{
      private:
              int     chlEdgeIndexs[];
      public:
                      CFilterClear01();
                      ~CFilterClear01();                      
               bool   clearFilter(CModelI* model);
               
               //---Function to calculate diff edge pips
               double  getDiffByRate(ENUM_ORDER_TYPE type,double rate);
               //double  clearHedgeLot(CModelI* model);
};
  
//+------------------------------------------------------------------+
//|  filter the clear model
//+------------------------------------------------------------------+
bool CFilterClear01::clearFilter(CModelI* model)
{  
   
   logData.addDebugInfo("<CFilterClear01>");
   int symbolIndex=model.getSymbolIndex();   
   CPriceChannelStatus* priceChlStatus=this.getIndShare().getDiffPriceChannelStatus(symbolIndex,GRID_CLEAR_CHL_SHIFT_DIFF);
   int chlEdgeCount=ArraySize(this.chlEdgeIndexs);
   double avgUpEdge=0,avgLowerEdge=0;
   double gridAvgLine=model.getAvgPrice();
   int chlCount=0;
   for(int i=chlEdgeCount-2;i<chlEdgeCount;i++){
      avgUpEdge+=priceChlStatus.getUpperEdgePrice(chlEdgeIndexs[i]);
      avgLowerEdge+=priceChlStatus.getLowerEdgePrice(chlEdgeIndexs[i]);
      chlCount++;
   }
   
   avgUpEdge=avgUpEdge/chlCount;
   avgLowerEdge=avgLowerEdge/chlCount;
   
   //double strengthRate=this.getIndShare().getStrengthRate(symbolIndex);
   double strengthRate=priceChlStatus.getStrengthRate();
   //double edgeRate=this.getIndShare().getEdgeRate(symbolIndex);
   double edgeRate=priceChlStatus.getEdgeRate();
   //double sumRate=strengthRate+edgeRate;
   double sumRate=this.getIndShare().getPriceChlSumEdgeRate(symbolIndex);
   
   if(sumRate>0 && model.getTradeType()==ORDER_TYPE_BUY)return false;
   else if(sumRate<0 && model.getTradeType()==ORDER_TYPE_SELL)return false;
   
   //not clear when orders in the channel   
   double diffEdgePips=0;   
   if(model.getTradeType()==ORDER_TYPE_BUY){
      if(gridAvgLine<avgUpEdge)return false;
      diffEdgePips=(gridAvgLine-avgUpEdge)/model.getSymbolPoint();      
   }else{
      if(gridAvgLine>avgLowerEdge)return false;
      diffEdgePips=(avgLowerEdge-gridAvgLine)/model.getSymbolPoint();
   }
   
   double limitDiffEdgePips=this.getDiffByRate(model.getTradeType(),MathAbs(sumRate));
   if(diffEdgePips>limitDiffEdgePips){
      double clearLot=this.clearHedgeLot(model);
      if(clearLot>0){
         logData.addDebugInfo("<diffEdgePips>"+diffEdgePips);
         logData.addDebugInfo("<limitDiffEdgePips>"+limitDiffEdgePips);
         logData.addDebugInfo("<clearLot>"+clearLot);
         logData.addDebugInfo("<return>true");
         logData.addDebugInfo("</CFilterClear01>");
         return true;
      }
   }
   logData.addDebugInfo("<diffEdgePips>"+diffEdgePips);
   logData.addDebugInfo("<limitDiffEdgePips>"+limitDiffEdgePips);
   logData.addDebugInfo("<return>false");
   logData.addDebugInfo("</CFilterClear01>");
   return false;
}

//+------------------------------------------------------------------+
//| Function to calculate diff edge pips                             |
//+------------------------------------------------------------------+
double CFilterClear01::getDiffByRate(ENUM_ORDER_TYPE type,double rate)
{

   double adjustRate=rate;
   if(rate>GRID_CLEAR_DIFF_EXTEND_MAX_RATE)rate=GRID_CLEAR_DIFF_EXTEND_MAX_RATE;
   if(rate<GRID_CLEAR_DIFF_EXTEND_MIN_RATE)rate=GRID_CLEAR_DIFF_EXTEND_MIN_RATE;
   double minRate=GRID_CLEAR_DIFF_EXTEND_MIN_RATE;
   double maxRate=GRID_CLEAR_DIFF_EXTEND_MAX_RATE;   
      
   if(type==ORDER_TYPE_BUY){
      minRate=GRID_CLEAR_DIFF_EXTEND_MAX_RATE;
      maxRate=GRID_CLEAR_DIFF_EXTEND_MIN_RATE;
   }   
   double slopeRate=(GRID_CLEAR_DIFF_EDGE_MIN_PIPS-GRID_CLEAR_DIFF_EDGE_MAX_PIPS)/(maxRate-minRate);   
   double offSetDiff=GRID_CLEAR_DIFF_EDGE_MAX_PIPS-(slopeRate)*minRate; 
   
   double reValue=slopeRate*rate+offSetDiff;
   
   //if(reValue<0){
   //   printf("test");
   //}
     
   return slopeRate*rate+offSetDiff;
}

/*
//+------------------------------------------------------------------+
//|  clear minus models
//+------------------------------------------------------------------+
double CFilterClear01::clearHedgeLot(CModelI* model){

   CHedgeGroup* modelGroup=model.getHedgeGroup();
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
}*/

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterClear01::CFilterClear01(){
   comFunc.StringToIntArray(GRID_CLEAR_CHL_EDGE_INDEXS,chlEdgeIndexs);
}
CFilterClear01::~CFilterClear01(){
}
 