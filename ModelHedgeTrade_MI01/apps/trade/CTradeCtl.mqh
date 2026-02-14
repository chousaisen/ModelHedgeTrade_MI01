//+------------------------------------------------------------------+
//|                                                    CTradeCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Trade\Trade.mqh>

#include "..\share\loginfo\CLogData.mqh"
#include "..\share\CShareCtl.mqh"
#include "..\share\filter\CFilterShare.mqh"
#include "..\logger\CLogger.mqh"

class CTradeCtl
  {
   private:
        CTrade       trade;  
        CShareCtl    *shareCtl;
        CFilterShare *filterShare;
        //test begin
        int          orderCloseCount;
        double       sumCloseProfit;
        double       orderCloseCountRate;
        double       orderClearCountRate;
        
        //order count
        int          diffTimeOpenOrderCount;
        bool         tradeAction;
        
        //test end
   public:
                        CTradeCtl();
                       ~CTradeCtl();
        //--- init methods
        void            init(CShareCtl *shareCtl);  
        //--- execute trade
        int             openTrade();
        int             closeTrade();                
        void            clearTrade();   
        void            closeAllTrade();  
        void            resetTradeAction();
        bool            getTradeAction();
        //--- make trade request
        MqlTradeRequest makeRequest(COrder* order);
                    
  };
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CTradeCtl::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.filterShare=shareCtl.getFilterShare();
}

//+------------------------------------------------------------------+
//|  run the open trade control
//+------------------------------------------------------------------+
int CTradeCtl::openTrade(void)
{
   CArrayList<COrder*>* orders=this.shareCtl.getModelShare().getOrders();
   int orderCount=orders.Count();
   int openOrderCount=0;
   logData.beginLine("openTrade>@R");
   for (int i = 0; i < orderCount; i++) {  
      COrder *order;
      orders.TryGetValue(i,order); 
      if(CheckPointer(order)==POINTER_INVALID)continue;        
      if (order.getTradeStatus()==TRADE_STATUS_TRADE_READY) {
          ENUM_ORDER_TYPE tradeType = order.getOrderType();  
          if (tradeType == ORDER_TYPE_BUY || tradeType == ORDER_TYPE_SELL) {                                                                  
              trade.SetExpertMagicNumber(order.getMagic());
              double tradePrice=shareCtl.getSymbolShare().getSymbolPrice(order.getSymbol(),tradeType);
              order.setOpenPrice(tradePrice);               
              //trade result
              MqlTradeResult result;
              ZeroMemory(result);
              if(OrderSend(this.makeRequest(order),result)){              
                 order.setTradeStatus(TRADE_STATUS_TRADE); 
                 order.setTicket(result.order);
                 //this.shareCtl.getModelShare().addOpenOrderCount(1); 
                 this.tradeAction=true;
                 openOrderCount++;
                 logData.addOpenOrderLine(order);   //---logData test
                 logData.addDebugInfo(order,"open"+openOrderCount);
              }else{              
                 if(order.getReTryCount()>Comm_Order_Max_ReTry_Count){
                     order.setTradeStatus(TRADE_STATUS_ERROR_OPEN);
                     order.setErrorCode(GetLastError());
                     rkeeLog.printOrderError(order, "error open cancel-> ");                    
                 }else{
                     rkeeLog.printOrderError(order, "   error open > retry-" + order.getReTryCount() + ">");
                     order.setReTryCount();                                                                
                 }                                   
              }          
          }
      }           
   }
   logData.saveLine("openTradeOrders",1000);
   logData.addCheckNValue("openTradeOrdersCount",openOrderCount);  //---logData test
   return openOrderCount;
}

//+------------------------------------------------------------------+
//|  run the close trade control
//+------------------------------------------------------------------+
int CTradeCtl::closeTrade(void)
{

   int closeCount=0;
   CArrayList<COrder*>* orders=this.shareCtl.getModelShare().getOrders();             
   for (int i = 0; i < orders.Count(); i++) {  
      COrder *order;
      orders.TryGetValue(i,order); 
      if(CheckPointer(order)==POINTER_INVALID)continue;
      //filter order
      if(!this.filterShare.closeFilter(order))continue;
      //close order
      if (order.getTradeStatus()==TRADE_STATUS_CLOSE_READY 
            || order.getTradeStatus()==TRADE_STATUS_ERROR_CLOSE){                   
         ulong deviation = 5;  // 假设偏差值是5
         // 关闭订单
         if(trade.PositionClose(order.getTicket(), deviation)){         
            order.setTradeStatus(TRADE_STATUS_CLOSE);
            order.setTicket(0);
            //this.shareCtl.getModelShare().addCloseOrderCount(1);
            closeCount++;
            logData.addDebugInfo(order,"close" + closeCount);
         }else{
            order.setTradeStatus(TRADE_STATUS_ERROR_CLOSE);
            order.setErrorCode(GetLastError());
            rkeeLog.printOrderError(order, "error close---PositionClose> ");
         }                  
      }
   }                                       
   return closeCount;   
}

//+------------------------------------------------------------------+
//|  run the close all trade control
//+------------------------------------------------------------------+
void CTradeCtl::closeAllTrade(void)
{
   CArrayList<COrder*>* orders=this.shareCtl.getModelShare().getOrders();
   for (int i = 0; i < orders.Count(); i++) {  
      COrder *order;
      orders.TryGetValue(i,order);  
      if(CheckPointer(order)==POINTER_INVALID)continue;                 
      if (order.getTicket()>0){
         ulong deviation = 5;  // deviaion 5
         // close order
         if(trade.PositionClose(order.getTicket(), deviation)){         
            order.setTradeStatus(TRADE_STATUS_CLOSE);
            order.setTicket(0);
            //this.shareCtl.getModelShare().addCloseOrderCount(1);
         }else{
            order.setTradeStatus(TRADE_STATUS_ERROR_CLOSE);
            order.setErrorCode(GetLastError());
            rkeeLog.printOrderError(order, "error close---PositionClose closeAll> ");              
         }                                                     
       }else{
         order.setTradeStatus(TRADE_STATUS_CLOSE);
       }
   }      
}

//+------------------------------------------------------------------+
//|  make trade request
//+------------------------------------------------------------------+
MqlTradeRequest CTradeCtl::makeRequest(COrder* order){
   MqlTradeRequest request;
   ZeroMemory(request);
   request.action = TRADE_ACTION_DEAL;    // 即时执行交易
   //request.symbol = order.getSymbol();
   request.symbol = comFunc.addSuffix(order.getSymbol());
   request.volume = order.getLot();
   request.type = order.getOrderType();
   request.price = order.getOpenPrice();
   //request.sl = order.getSlLine();
   //request.tp = order.getTpLine();
   request.deviation = 50;    //order define
   request.magic = order.getMagic();
   request.comment = order.getComment();
   request.type_filling = Comm_Trade_Order_Filling;
   request.type_time = ORDER_TIME_GTC;
   //request.expiration = expiration;
   
   return request;
}

//+------------------------------------------------------------------+
//| reset trade action flag
//+------------------------------------------------------------------+
void  CTradeCtl::resetTradeAction(){
   this.tradeAction=false;
}
bool  CTradeCtl::getTradeAction(){
   return this.tradeAction;
}
        
//+------------------------------------------------------------------+
//| class constructor
//+------------------------------------------------------------------+
CTradeCtl::CTradeCtl()
  {
   this.tradeAction=false;
  }
//+------------------------------------------------------------------+
//| class constructor                                                                 |
//+------------------------------------------------------------------+
CTradeCtl::~CTradeCtl()
  {
  }
//+------------------------------------------------------------------+