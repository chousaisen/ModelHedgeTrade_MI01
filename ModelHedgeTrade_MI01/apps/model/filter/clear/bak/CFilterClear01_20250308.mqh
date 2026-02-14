//+------------------------------------------------------------------+
//|                                                CFilterClear01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../CModelHedgeFilter.mqh"

class CFilterClear01: public CModelHedgeFilter 
{
      private:
              int     chlEdgeIndexs[];
      public:
                      CFilterClear01();
                      ~CFilterClear01();                      
               bool   clearFilter(CModelI* model);
               
};
  
//+------------------------------------------------------------------+
//|  filter the clear model
//+------------------------------------------------------------------+
bool CFilterClear01::clearFilter(CModelI* model)
{  
   
   return false;
}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterClear01::CFilterClear01(){
   comFunc.StringToIntArray(GRID_CLEAR_CHL_EDGE_INDEXS,chlEdgeIndexs);
}
CFilterClear01::~CFilterClear01(){
}
 