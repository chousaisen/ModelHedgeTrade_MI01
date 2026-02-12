//+------------------------------------------------------------------+
//|                                                CModelFilterI.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../../model/CModelI.mqh"

interface CFilterI
  {

public:
//+------------------------------------------------------------------+
//|  interface function
//+------------------------------------------------------------------+
//--- interface function
//void   init(CShareCtl *shareCtl);
   bool   signalFilter(int symbolIndex,ENUM_ORDER_TYPE type);
   bool   openFilter(CSignal* signal);
   bool   extendFilter(CModelI* model);
   bool   closeFilter(CModelI* model);
   bool   closeFilter(COrder* order);
   bool   clearFilter(CModelI* model);
   void   refresh();
  };

//+------------------------------------------------------------------+
