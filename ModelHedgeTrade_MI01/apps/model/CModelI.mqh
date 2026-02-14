//+------------------------------------------------------------------+
//|                                                      CModelI.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

//#include "../share/hedge/CHedgeGroup.mqh"
#include "../share/model/order/COrder.mqh"
#include "../share/signal/CSignal.mqh"

interface CModelI
  {
  
   public:
     //+------------------------------------------------------------------+
     //|  interface function
     //+------------------------------------------------------------------+       
      //--- interface function  
      void     reload();         //reload order from the market
      void     run();            //model run
      void     refresh();        //model re-calculate
      void     clean();          //clean model
      COrder*  createOrder();    //create order      
      void     openModel();      //open model
      bool     extendModel();    //extend model
      bool     enableExtend();   //if enable extend model
      bool     closeModel();     //close model
      bool     enableClose();    //if enable close model
      bool     clearModel();     //clear model (risk protect)
      int      closeOrders();    //close orders
      bool     riskProtect();    //judge if need to protect
      
      //+------------------------------------------------------------------+
      //|  get.set model param
      //+------------------------------------------------------------------+
      string     getSymbol();          //get model symbol
      int        getSymbolIndex();     //get model symbol Index
      ENUM_ORDER_TYPE getTradeType();  //get model trade type
      double     getStartLine();       //get model start price line
      int        getModelKind();       //get model kind
      ulong      getModelId();         //get model id  
      int        getModelStatus();     //get model status          
      int        getOrderCount();      //get order count
      COrder*    getOrder(int index);         //get order by order index 
      void       addOrder(COrder* order);     //add order to the orderSet
      void       setSymbol(string value);     //set model symbol
      void       setModelKind(int value);     //set model kind
      void       setModelId(ulong value);     //set model id
      void       setModelStatus(int value);   //set model status
      double     getSymbolPrice();            //get model symbol price
      double     getSymbolPoint();            //get model symbol point
      double     getProfitPips();             //get model profit pips
      double     getProfitMaxPips();          //get model profit max pips
      double     getProfitMinPips();          //get model profit min pips      
      datetime   getProfitMaxTime();          //the time of model profit max pips
      datetime   getProfitMinTime();          //the time of model profit min pips               
      double     getStopLossPips();           //get model stop loss pips
      double     getCloseProfitPips();        //get model close profit pips
      double     getAvgPrice();               //get grid model avg price(all orders)        
      string     getActionFlg();              //get action flag
      void       setActionFlg(string value);  //set action flag 
      int        markClearFlag(bool value);   // mark the clear flag of all the orders 
      bool       getClearFlag();              // get model clear flag
      //+------------------------------------------------------------------+
      //|  model info
      //+------------------------------------------------------------------+      
      //CHedgeGroup*   getHedgeGroup();  //get hedge group  
      string         modelInfo();
      double         getProfit();
      double         getLot();
      datetime       getTradeTime();
      void           setTradeTime(datetime value);
      datetime       getStartTime();
      void           setStartTime(datetime value);
      
      // get status index
      int  getStatusIndex();
      void setStatusIndex(int value);
      int  getLastStatusIndex();
      void setLastStatusIndex(int value);
      
      // get/set status flag
      int  getStatusFlg();
      void setStatusFlg(int value);      
      int  getLastStatusFlg();
      void setLastStatusFlg(int value);
      
      //set extend Rate
      void    setExtendRate(double value);
      double  getExtendRate();
  };