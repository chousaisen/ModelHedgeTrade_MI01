//+------------------------------------------------------------------+
//|                                                CFilterExtend01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../CModelIndicatorFilter.mqh"
#include "../../../comm/ComFunc2.mqh"

class CFilterExtend01: public CModelIndicatorFilter 
{
      public:
                      CFilterExtend01();
                      ~CFilterExtend01();                      
    bool              extendFilter(CModelI* model);
};
  

//+------------------------------------------------------------------+
//|  filter the extend model
//+------------------------------------------------------------------+
bool CFilterExtend01::extendFilter(CModelI* model){
   
   logData.addDebugInfo("<CFilterExtend01>");
   int symbolIndex=model.getSymbolIndex();
   CHedgeGroup* hedgePool=this.getHedgeShare().getHedgeGroupPool();
   double hedgeRate=hedgePool.getHedgeRate();   
   if(hedgeRate>0.618){     
      string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);
      int trendFlg=comFunc2.getSarTrendFlg(symbol);   
      if(trendFlg==1 || trendFlg==4){
         if(model.getTradeType()==ORDER_TYPE_BUY)return false;
      }
      else if(trendFlg==2 || trendFlg==3){
         if(model.getTradeType()==ORDER_TYPE_SELL)return false;
      }      
      return true;
   }
   
   double curHedgeLot=this.openHedgeLot(model,hedgePool);   
   if(curHedgeLot<=0)return false;   
   
   double sumJumpPips=this.getIndShare().getPriceChlSumEdgeDiffPips(model.getSymbolIndex());
   //double sumEdgeRate=this.getIndicatorShare().getPriceChlSumEdgeRate(model.getSymbolIndex());         
   //double sumAdjustEdgeRate=MathAbs((sumJumpPips/100)+sumEdgeRate);   
   
   if(MathAbs(sumJumpPips)>100)return false;
   
   
   bool edgeBreakFlg=  this.edgeBreakTend(model.getSymbolIndex(),
                        model.getTradeType(),
                        GRID_EXTEND01_FILTER_EDGE_INDEX,
                        GRID_EXTEND01_MAX_EDGE_RATE,
                        GRID_EXTEND01_LIMIT_BRK_PIPS);     
   
   if(rkeeLog.debugPeriod() && edgeBreakFlg){
      bool test1=true;
   }   
   logData.addDebugInfo("<return>" + edgeBreakFlg + "</CFilterExtend01>");
   
   if(edgeBreakFlg){
   
      double sumJumpPips=this.getIndShare().getPriceChlSumEdgeDiffPips(model.getSymbolIndex());
      double sumEdgeRate=this.getIndShare().getPriceChlSumEdgeRate(model.getSymbolIndex());
   
      double sumRate=sumJumpPips/100+sumEdgeRate;
      
      ENUM_ORDER_TYPE type=model.getTradeType();
      if(type==ORDER_TYPE_SELL && sumRate>10)return false;
      else if(type==ORDER_TYPE_BUY && sumRate<-10)return false;
      return true;   
   }
   
      
   return edgeBreakFlg;
}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterExtend01::CFilterExtend01(){}
CFilterExtend01::~CFilterExtend01(){
}
 