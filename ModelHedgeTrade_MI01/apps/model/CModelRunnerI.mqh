//+------------------------------------------------------------------+
//|                                                CModelRunnerI.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../share/CShareCtl.mqh"
//#include "CModelRunnerI.mqh"
//#include "CModelI.mqh"

interface CModelRunnerI
  {
  
   public:
     //+------------------------------------------------------------------+
     //|  interface function
     //+------------------------------------------------------------------+       
     //--- methods of initilize
     void            init(CShareCtl *shareCtl); 
     //--- methods of models
     void            initModels();      
     //--- load   model when init
     void            reLoadModels();
     //--- open models by signals
     int             openModels();
     //--- extend models
     void            extendModels();
     //--- close models
     void            closeModels();     
     //--- create model
     CModelI*        createModel(); 
     //--- hedge correlation
     //bool            hedgeCorrelation(int symbolIndex,ENUM_ORDER_TYPE type,double lot);       
     //--- refresh hedge orders data
     void            hedgeOrders();       
     //--- run model runner
     //void            run();
     //--- clean models(when models no orders)
     void            clean();
     //--- get active model count
     int             getModelCount();
     //--- get active model count by symbol and order type
     int             getSymbolModelTypeCount(int symbolIndex,ENUM_ORDER_TYPE type);
     //--- get hedge Group Info
     CHedgeGroupInfo*  getHedgeGroupInfo(); 
     //--- get model kind
     int             getModelKind(); 
     //--- set hedge flag
     void                                       setHedgeFlg(bool value);
     //--- get hedge flag
     bool                                       getHedgeFlg();     

  };

 