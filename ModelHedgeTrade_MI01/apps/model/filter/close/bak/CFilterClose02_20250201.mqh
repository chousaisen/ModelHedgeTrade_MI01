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
      
   
   logData.beginLine(comFunc.getDate_YYYYMMDDHHMM2() + " <closeFilter2>--");   
   
   int symbolIndex=model.getSymbolIndex();
   CIndicatorShare* indShare=this.getIndShare();
   double strengthRate=indShare.getStrengthRate(symbolIndex);
   double edgeRate=indShare.getEdgeRate(symbolIndex);
   double sumRate=strengthRate+edgeRate;   
   
   logData.addLine("<sumRate>" + StringFormat("%.2f",sumRate)
                   + "<edgeRate>" + StringFormat("%.2f",edgeRate)
                   + "<edgeRate>" + StringFormat("%.2f",edgeRate)
                   + "<extendBegin>" + GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE  );
   
   if(sumRate<GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE){
      if(model.getTradeType()==ORDER_TYPE_BUY)return true;
   }else if(sumRate>-GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE){
      if(model.getTradeType()==ORDER_TYPE_SELL)return true;
   }   
   
   double extendRate=(MathAbs(sumRate)-GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE)+1;   
   if(extendRate<1)extendRate=1;  
   extendRate=comFunc.extendValue(extendRate,GRID_CLOSE_DIFF_EXTEND_PLUS_RATE);
   double modelProfit=model.getProfit();   
   double modelCloseProfit=model.getCloseProfitPips();
   if(extendRate>1){
      modelCloseProfit=(modelCloseProfit*GRID_CLOSE_BREAK_EXTEND_RATE)*extendRate;
   }   
   if(modelProfit<modelCloseProfit)return false;
   
   return true;
   
   /*
   bool edgeBreakCloseFlg= this.edgeBreakClose(model,
                                                model.getSymbolIndex(),
                                                model.getTradeType(),
                                                0,
                                                0.95,
                                                10);
                        
   if(rkeeLog.debugPeriod(9091,60) && edgeBreakCloseFlg){
      bool test1=true;
   }
  
   return edgeBreakCloseFlg; 
   */  
   
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
 