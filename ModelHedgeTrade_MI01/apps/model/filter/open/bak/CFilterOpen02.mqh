//+------------------------------------------------------------------+
//|                                                CFilterOpen02I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../CModelIndicatorFilter.mqh"

class CFilterOpen02: public CModelIndicatorFilter 
{
      public:
                CFilterOpen02();
                ~CFilterOpen02();                      
         bool   openFilter(CSignal* signal);
         bool   openFilter01(CSignal* signal);
         bool   openFilter02(CSignal* signal);

};

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen02::openFilter(CSignal* signal)
{
      
      
   return true;
   
   if(!this.openFilter01(signal))return false;
   if(!this.openFilter02(signal))return false;
   
   return true;
}


//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen02::openFilter01(CSignal* signal)
{
      
   bool edgeBreakFlg= this.edgeBreakTend(signal.getSymbolIndex(),
                        signal.getTradeType(),
                        GRID_OPEN2_FILTER_EDGE_INDEX,
                        GRID_OPEN2_MAX_EDGE_RATE,
                        GRID_OPEN2_LIMIT_BRK_PIPS);
                        
   //if(rkeeLog.debugPeriod() && edgeBreakFlg){
   //   bool test1=true;
   //}  
   return edgeBreakFlg;
}


//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen02::openFilter02(CSignal* signal)
{
   
   double sumJumpPips=this.getIndShare().getPriceChlSumEdgeDiffPips(signal.getSymbolIndex());
   double sumEdgeRate=this.getIndShare().getPriceChlSumEdgeRate(signal.getSymbolIndex());

   double sumRate=sumJumpPips/100+sumEdgeRate;
   double strengthRate=sumJumpPips/100;
   
   ENUM_ORDER_TYPE type=signal.getTradeType();   
   if(MathAbs(sumJumpPips)<500){   
      if(type==ORDER_TYPE_BUY){
         if(sumRate<0 && sumRate>-30)return true;
      }else{
         if(sumRate>0 && sumRate<30)return true;
      }         
   }else{
      if(type==ORDER_TYPE_BUY){
         if(sumRate>25)return true;
      }else{
         if(sumRate<-25)return true;
      }      
   }
   return false;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterOpen02::CFilterOpen02(){}
CFilterOpen02::~CFilterOpen02(){
}
 