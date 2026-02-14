//+------------------------------------------------------------------+
//|                                                     CModel01.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "CFilterI.mqh"
#include "..\indicator\CIndicatorShare.mqh"

class CFilterShare 
{
      private:
         CIndicatorShare*      indShare;         
         CArrayList<CFilterI*> signalFilters;
         CArrayList<CFilterI*> openFilters;
         CArrayList<CFilterI*> extendFilters;
         CArrayList<CFilterI*> closeFilters;         
         CArrayList<CFilterI*> clearFilters; 
      public:
                      CFilterShare();
                      ~CFilterShare(); 
                     
               void   init(CIndicatorShare*  indShare); 
               
               //--- open.extend.close filter func
               bool   signalFilter(int symbolIndex,ENUM_ORDER_TYPE type);
               bool   openFilter(CSignal* signal);
               bool   extendFilter(CModelI* model);
               bool   closeFilter(CModelI* model);
               bool   closeFilter(COrder* order);
               bool   clearFilter(CModelI* model);
               void   refresh();
               
               //--- add filters
               void   addSignalFilter(CFilterI* filter);
               void   addOpenFilter(CFilterI* filter);
               void   addExtendFilter(CFilterI* filter);
               void   addCloseFilter(CFilterI* filter);
               void   addClearFilter(CFilterI* filter);
};
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CFilterShare::init(CIndicatorShare*  indShare)
{
   this.indShare=indShare;
}

//+------------------------------------------------------------------+
//|  filter the signal
//+------------------------------------------------------------------+
bool CFilterShare::signalFilter(int symbolIndex,ENUM_ORDER_TYPE type)
{   
   int filterCount=this.signalFilters.Count();
   //clean model list
   for (int i = filterCount-1; i >=0 ; i--) {
      CFilterI *filter;      
      if(this.signalFilters.TryGetValue(i,filter)){         
         if(!filter.signalFilter(symbolIndex,type)){
            return false;
         }
      }
   }      
   return true;
}

//+------------------------------------------------------------------+
//|  filter the open model
//+------------------------------------------------------------------+
bool CFilterShare::openFilter(CSignal* signal)
{   
   int filterCount=this.openFilters.Count();
   //clean model list
   for (int i = filterCount-1; i >=0 ; i--) {
      CFilterI *filter;      
      if(this.openFilters.TryGetValue(i,filter)){         
         if(!filter.openFilter(signal)){
            return false;
         }
      }
   }      
   return true;
}

//+------------------------------------------------------------------+
//|  filter the extend model
//+------------------------------------------------------------------+
bool CFilterShare::extendFilter(CModelI* model)
{   
   int filterCount=this.extendFilters.Count();
   //clean model list
   for (int i = filterCount-1; i >=0 ; i--) {
      CFilterI *filter;      
      if(this.extendFilters.TryGetValue(i,filter)){         
         if(!filter.extendFilter(model)){
            return false;
         }
      }
   }      
   return true;
}

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterShare::closeFilter(CModelI* model)
{   
   int filterCount=this.closeFilters.Count();
   //clean model list
   for (int i = filterCount-1; i >=0 ; i--) {
      CFilterI *filter;      
      if(this.closeFilters.TryGetValue(i,filter)){         
         if(!filter.closeFilter(model)){
            return false;
         }
      }
   }      
   return true;
}

//+------------------------------------------------------------------+
//|  filter the close order
//+------------------------------------------------------------------+
bool CFilterShare::closeFilter(COrder* order)
{   
   int filterCount=this.closeFilters.Count();
   //clean model list
   for (int i = filterCount-1; i >=0 ; i--) {
      CFilterI *filter;      
      if(this.closeFilters.TryGetValue(i,filter)){         
         if(!filter.closeFilter(order)){
            return false;
         }
      }
   }      
   return true;
}

//+------------------------------------------------------------------+
//|  filter the clear model
//+------------------------------------------------------------------+
bool CFilterShare::clearFilter(CModelI* model)
{   
   int filterCount=this.clearFilters.Count();
   if(filterCount==0)return false;
   //clean model list
   for (int i = filterCount-1; i >=0 ; i--) {
      CFilterI *filter;      
      if(this.clearFilters.TryGetValue(i,filter)){         
         if(!filter.clearFilter(model)){
            return false;
         }
      }
   }      
   return true;
}

//+------------------------------------------------------------------+
//|  refresh filter
//+------------------------------------------------------------------+
void CFilterShare::refresh(void)
{
   int filterCount=this.clearFilters.Count();
   if(filterCount==0)return;
   //refresh filter list
   for (int i = filterCount-1; i >=0 ; i--) {
      CFilterI *filter;      
      if(this.clearFilters.TryGetValue(i,filter)){         
         filter.refresh();
      }
   }     
}


//--------------------------------------------------------------------
// add filter(signal.modelOpen.modelClose)
//--------------------------------------------------------------------

//+------------------------------------------------------------------+
//|  add open filter
//+------------------------------------------------------------------+
void   CFilterShare::addSignalFilter(CFilterI *filter){
   this.signalFilters.Add(filter);
}

//+------------------------------------------------------------------+
//|  add open filter
//+------------------------------------------------------------------+
void   CFilterShare::addOpenFilter(CFilterI* filter){
   this.openFilters.Add(filter);
}

//+------------------------------------------------------------------+
//|  add extend filter
//+------------------------------------------------------------------+
void   CFilterShare::addExtendFilter(CFilterI* filter){
   this.extendFilters.Add(filter);
}

//+------------------------------------------------------------------+
//|  add close filter
//+------------------------------------------------------------------+
void   CFilterShare::addCloseFilter(CFilterI* filter){
   this.closeFilters.Add(filter);
}

//+------------------------------------------------------------------+
//|  add clear filter
//+------------------------------------------------------------------+
void   CFilterShare::addClearFilter(CFilterI* filter){
   this.clearFilters.Add(filter);
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterShare::CFilterShare(){}
CFilterShare::~CFilterShare(){
}