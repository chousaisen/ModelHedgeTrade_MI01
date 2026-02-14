//+------------------------------------------------------------------+
//|                                                 CModelIndicatorFilter.mqh |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "CModelFilter.mqh"

class CModelIndicatorFilter : public CModelFilter
{
      private:
         CShareCtl*            shareCtl;
      public:
                    CModelIndicatorFilter();
                    ~CModelIndicatorFilter(); 
                          
              //--- edge break tend   
              bool    edgeBreakTend(int symbolIndex,
                                    ENUM_ORDER_TYPE type,
                                    int chlIndex,
                                    double maxEdgeRate,
                                    double limitBreakPips); 
                                    
              //--- edge break reverse   
              bool    edgeBreakReverse(int symbolIndex,
                                    ENUM_ORDER_TYPE type,
                                    int chlIndex,
                                    double maxEdgeRate,
                                    double limitBreakPips);                                                                    
                     
};
  
//+------------------------------------------------------------------+
//|  judge if edge break tend
//+------------------------------------------------------------------+
bool  CModelIndicatorFilter::edgeBreakTend(int symbolIndex,
                                             ENUM_ORDER_TYPE type,
                                             int chlIndex,
                                             double maxEdgeRate,
                                             double limitBreakPips){
   
   CPriceChlStatus*  priceChlStatus=this.getIndShare().getPriceChannelStatus2(symbolIndex);
   double edgeRate=priceChlStatus.getEdgeRate(chlIndex,0);
   if(MathAbs(edgeRate)<maxEdgeRate)return true;
   if(type==ORDER_TYPE_BUY){
       if(priceChlStatus.getEdgeBrkDiffPips(chlIndex)<-limitBreakPips){
         return false;
       }
   }else{
      if(priceChlStatus.getEdgeBrkDiffPips(chlIndex)>limitBreakPips){
         return false;   
      }   
   } 
   return true;   
}

//+------------------------------------------------------------------+
//|  judge if edge break reverse
//+------------------------------------------------------------------+
bool  CModelIndicatorFilter::edgeBreakReverse(int symbolIndex,
                                             ENUM_ORDER_TYPE type,
                                             int chlIndex,
                                             double maxEdgeRate,
                                             double limitBreakPips){   
   return true;   
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelIndicatorFilter::CModelIndicatorFilter(){}
CModelIndicatorFilter::~CModelIndicatorFilter(){
}