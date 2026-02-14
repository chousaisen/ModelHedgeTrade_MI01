//+------------------------------------------------------------------+
//|                                                    TradeLine.mqh |
//|                                  Copyright 2024, RkeeCom Ltd.    |
//|                                             
//+------------------------------------------------------------------+


#include <Object.mqh>

class CHedgePair : public CObject
  {
   private:

   //+------------------------------------------------------------------+
   //|  main order info
   //+------------------------------------------------------------------+      
   ulong   mOrderId;           //main order magic.orderId
   int     mOrderStatus;       //main order status

   //+------------------------------------------------------------------+
   //|  hedge order info
   //+------------------------------------------------------------------+      
   ulong   hOrderId;          //hedge order magic.orderId
   int     hOrderStatus;        //hedge order status
       
   public:      
      CHedgePair();
     ~CHedgePair();      
       
       
     // Getter / Setter
     //==================================================================

     //--- Main Order
     ulong getMainOrderId()          { return mOrderId; }
     void  setMainOrderId(ulong v)   { mOrderId = v; }

     int   getMainOrderStatus()      { return mOrderStatus; }
     void  setMainOrderStatus(int v) { mOrderStatus = v; }

     //--- Hedge Order
     ulong getHedgeOrderId()         { return hOrderId; }
     void  setHedgeOrderId(ulong v)  { hOrderId = v; }

     int   getHedgeOrderStatus()     { return hOrderStatus; }
     void  setHedgeOrderStatus(int v){ hOrderStatus = v; }       
       
};

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CHedgePair::CHedgePair(){}
CHedgePair::~CHedgePair(){}