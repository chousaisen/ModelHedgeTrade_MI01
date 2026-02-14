//+------------------------------------------------------------------+
//|                                                CFilterClose02I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../CModelFilter.mqh"

class CFilterClose02: public CModelFilter 
{
      public:
                      CFilterClose02();
                      ~CFilterClose02();                      
               bool   closeFilter(CModelI* model);
               bool   closeFilter(COrder* order);               
               bool   edgeBreakClose(CModelI* model,
                                          int symbolIndex,
                                          ENUM_ORDER_TYPE type,
                                          int chlIndex,
                                          double maxEdgeRate,
                                          double limitBreakPips);
};
  

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterClose02::closeFilter(CModelI* model)
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
//|  judge if edge break close
//+------------------------------------------------------------------+
bool  CFilterClose02::edgeBreakClose(CModelI* model,
                                             int symbolIndex,
                                             ENUM_ORDER_TYPE type,
                                             int chlIndex,
                                             double maxEdgeRate,
                                             double limitBreakPips){
   
   CPriceChlStatus*  priceChlStatus=this.getIndShare().getPriceChannelStatus2(symbolIndex);
   double edgeRate=priceChlStatus.getEdgeRate(chlIndex,0);   
   double edgeDiffPips=priceChlStatus.getEdgeBrkDiffPips(chlIndex);   
   double closeProfitRate=MathAbs(edgeDiffPips)/50;
   double modelCloseProfit=model.getCloseProfitPips()*closeProfitRate;
   if(type==ORDER_TYPE_BUY){
       if(edgeRate>=maxEdgeRate 
            && edgeDiffPips>limitBreakPips){         
         if(model.getProfitPips()<modelCloseProfit){
            return false;
         }
       }
   }else{
      if(edgeRate<=-maxEdgeRate 
         && edgeDiffPips<-limitBreakPips){
         if(model.getProfitPips()<modelCloseProfit){
            return false;   
         }
      }
   } 
   return true;   
}

//+------------------------------------------------------------------+
//|  filter the close order
//+------------------------------------------------------------------+
bool CFilterClose02::closeFilter(COrder* order)
{
   return true;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterClose02::CFilterClose02(){}
CFilterClose02::~CFilterClose02(){
}
 