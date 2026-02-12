//+------------------------------------------------------------------+
//|                                                     CModel01.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "../../share/CShareCtl.mqh"
#include "../../share/filter/CFilterI.mqh"

class CSignalFilter : public CFilterI
{
      private:
         CShareCtl*            shareCtl;
         CIndicatorShare*      indShare;
      public:
                          CSignalFilter();
                          ~CSignalFilter(); 
                     
        void              init(CShareCtl *shareCtl); 
        bool              signalFilter(int symbolIndex,ENUM_ORDER_TYPE type);     
        bool              openFilter(CSignal* signal);     
        bool              extendFilter(CModelI* model);
        bool              closeFilter(CModelI* model);
        bool              closeFilter(COrder* order);
        CIndicatorShare*  getIndShare();
};
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CSignalFilter::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.indShare=shareCtl.getIndicatorShare();
}

//+------------------------------------------------------------------+
//|  get indicator share
//+------------------------------------------------------------------+
CIndicatorShare* CSignalFilter::getIndShare(){
   return this.indShare;
}

//+------------------------------------------------------------------+
//|  filter the open model
//+------------------------------------------------------------------+
bool CSignalFilter::openFilter(CSignal* signal)
{      
   return true;
}

//+------------------------------------------------------------------+
//|  filter the extne model
//+------------------------------------------------------------------+
bool CSignalFilter::extendFilter(CModelI *model)
{      
   return true;
}

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CSignalFilter::closeFilter(CModelI* model)
{    
   return true;
}

//+------------------------------------------------------------------+
//|  filter the close order
//+------------------------------------------------------------------+
bool CSignalFilter::closeFilter(COrder* model)
{    
   return true;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSignalFilter::CSignalFilter(){}
CSignalFilter::~CSignalFilter(){
}