//+------------------------------------------------------------------+
//|                                                CFilterClose01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../../../share/Indicator/CHeader.mqh"
#include "../CModelFilter.mqh"

class CFilterClose01: public CModelFilter 
{
      public:
                      CFilterClose01();
                      ~CFilterClose01();                      
               bool   closeFilter(CModelI* model);
               bool   closeFilter(COrder* order);
};
  

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter(CModelI* model)
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
//|  filter the close order
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter(COrder* order)
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
 