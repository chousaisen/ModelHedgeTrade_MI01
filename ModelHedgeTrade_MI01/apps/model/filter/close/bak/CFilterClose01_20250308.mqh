//+------------------------------------------------------------------+
//|                                                CFilterClose01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../../../share/Indicator/CHeader.mqh"
#include "../../../comm/ComFunc2.mqh"
#include "../CModelFilter.mqh"

class CFilterClose01: public CModelFilter 
{
      public:
                      CFilterClose01();
                      ~CFilterClose01();                      
               //close filter(model)
               bool   closeFilter(CModelI* model);                              
               //detail filters(judge model)
               bool   closeFilter01(CModelI* model);
               bool   closeFilter02(CModelI* model);
               //close filter(order)
               bool   closeFilter(COrder* order);
               //detail filters(judge order)
               bool   closeFilter01(COrder* order);
};
  
//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter(CModelI* model)
{

   if(!GRID_CLOSE_FLG)return false;
   //return true;
   //if(this.getIndShare().getPriceChlShiftLevel(model.getSymbolIndex())>2)return false;
   
   //if(this.getHedgeShare().getHedgeGroupPool().getHedgeRate()>0.9)return true;
   //if(this.getHedgeShare().getHedgeGroupPool().getHedgeRate()<0.7)return false;
   int symbolIndex=model.getSymbolIndex();
   CHedgeGroup* hedgePool=this.getHedgeShare().getHedgeGroupPool();
   double hedgeRate=hedgePool.getHedgeRate();   
   if(hedgeRate>0.918){          
      string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);
      int trendFlg=comFunc2.getSarTrendFlg(symbol);   
      if(trendFlg==1 || trendFlg==4){
         if(model.getTradeType()==ORDER_TYPE_SELL)return true;
      }
      else if(trendFlg==2 || trendFlg==3){
         if(model.getTradeType()==ORDER_TYPE_BUY)return true;
      }   
      //return false;
   }
   
   //if(this.clearHedgeLot(model,hedgePool)>0)return true;
   
   return false;


   double sumJumpPips=this.getIndShare().getPriceChlSumEdgeDiffPips(model.getSymbolIndex());
   double sumEdgeRate=this.getIndShare().getPriceChlSumEdgeRate(model.getSymbolIndex());
   double extendRate=MathAbs((sumJumpPips/100)+sumEdgeRate);
   if(extendRate<20)return true;   
   
   //return false;
   //if(!this.closeFilter01(model))return false;   
   //if(!this.closeFilter02(model))return false; 
   //if(!this.closeFilter03(model))return false;
   return false;

}
//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter01(CModelI* model)
{

   logData.addDebugInfo("<CFilterClose01-model>");

   ENUM_STATE bandStatus=this.getIndShare().getBandStatus(model.getSymbolIndex(),IND_BAND_LV0);
   if(model.getTradeType()==ORDER_TYPE_BUY){
      if(bandStatus==STATE_BREAKOUT_UP){
         logData.addDebugInfo("<return>false</CFilterClose01-model>");
         return false;
      }
   } 
   else if(model.getTradeType()==ORDER_TYPE_SELL){
      if(bandStatus==STATE_BREAKOUT_DOWN){
         logData.addDebugInfo("<return>false</CFilterClose01-model>");
         return false;
      }   
   }   
   logData.addDebugInfo("<return>true</CFilterClose01-model>");
   return true;
}

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter02(CModelI* model)
{
   logData.addDebugInfo("<CFilterClose02-model>");
   int symbolIndex=model.getSymbolIndex();
   CIndicatorShare* indShare=this.getIndShare();
   double strengthRate=indShare.getStrengthRate(symbolIndex);
   double edgeRate=indShare.getEdgeRate(symbolIndex);
   double sumRate=strengthRate+edgeRate;   
  
   double closeDiffExtendRate=GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE;
   
   double modelProfit=model.getProfit();   
   double modelCloseProfit=model.getCloseProfitPips();
   double edgeDiffPips=indShare.getPriceChlSumEdgeDiffPips(symbolIndex);
   
   double sumJumpPips=indShare.getPriceChlSumEdgeDiffPips(symbolIndex);
   double sumEdgeRate=indShare.getPriceChlSumEdgeRate(symbolIndex);     
   
   //if(indShare.getPriceChlShiftLevel(symbolIndex)>2 || MathAbs((sumJumpPips/100)+sumEdgeRate)>8)return false;
   if(this.getHedgeShare().getHedgeGroupPool().getHedgeRate()>0.99)return true;
   if(this.getHedgeShare().getHedgeGroupPool().getHedgeRate()<0.66)return false;
   
   double strengthRate2=MathAbs(sumJumpPips/100);
   double extendRate=MathAbs((sumJumpPips/100)+sumEdgeRate)-GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE;
   
   if(strengthRate2>3){
      modelCloseProfit=(modelCloseProfit*GRID_CLOSE_BREAK_EXTEND_RATE);
      if(extendRate>1){
         extendRate=comFunc.extendValue(extendRate,GRID_CLOSE_DIFF_EXTEND_PLUS_RATE);
         modelCloseProfit=modelCloseProfit*extendRate;
      }   
   }

   if(rkeeLog.debugPeriod(9091,60)){   
      //rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"debugLog01");
      //printf(logTemp);
      datetime t1=TimeCurrent();
      double a=0;
   }

   logData.addDebugInfo("<modelId>" + model.getModelId()
                           + "<sumJumpPips>" + StringFormat("%.2f",sumJumpPips)                              
                           + "<modelProfit>" + StringFormat("%.2f",modelProfit)
                           + "<modelCloseProfit>" + StringFormat("%.2f",modelCloseProfit)
                           + "<extendRate>" + StringFormat("%.2f",extendRate));

   bool retValue=true;      
   if(modelProfit<modelCloseProfit){
      if(sumJumpPips>100 && model.getTradeType()==ORDER_TYPE_BUY){         
         retValue=false;
      }else if(sumJumpPips<-100 && model.getTradeType()==ORDER_TYPE_SELL){
         retValue=false;
      }
   }
   
   logData.addDebugInfo("<return>"+retValue+"</CFilterClose02-model>");
   
   return retValue;   
   
}

//+------------------------------------------------------------------+
//|  filter the close order
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter(COrder* order)
{
   //if(!this.closeFilter01(order))return false;   
   return true;
}

//+------------------------------------------------------------------+
//|  filter the close order
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter01(COrder* order)
{
   logData.addDebugInfo("<CFilterClose01-order>");
   ENUM_STATE bandStatus=this.getIndShare().getBandStatus(order.getSymbolIndex(),IND_BAND_LV0);
   if(order.getOrderType()==ORDER_TYPE_BUY){
      if(bandStatus==STATE_BREAKOUT_UP){
         logData.addDebugInfo("<return>false</CFilterClose01-order>");
         return false;
      }
   } 
   else if(order.getOrderType()==ORDER_TYPE_SELL){
      if(bandStatus==STATE_BREAKOUT_DOWN){
         logData.addDebugInfo("<return>false</CFilterClose01-order>");
         return false;
      }   
   }   
   logData.addDebugInfo("<return>true</CFilterClose01-order>");
   return true;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterClose01::CFilterClose01(){}
CFilterClose01::~CFilterClose01(){
}
 