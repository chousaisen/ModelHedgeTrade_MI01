//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  order trade status define 
//+------------------------------------------------------------------+ 
#define TRADE_STATUS_TRADE_PENDING       (0)                        // 0:order pending(when future time trade/before trade)
#define TRADE_STATUS_TRADE_READY         (1)                        // 1:order ready to trade
#define TRADE_STATUS_TRADE               (2)                        // 2:order trade begin
#define TRADE_STATUS_CLOSE_READY         (3)                        // 3:order ready to close
#define TRADE_STATUS_CLOSE_PART_READY    (4)                        // 4:order ready to close part 
#define TRADE_STATUS_CLOSE               (5)                        // 5:order close
#define TRADE_STATUS_CLEAR               (6)                        // 6:order clear(clear by model)
#define TRADE_STATUS_ERROR               (7)                        // 7:order trade error comm
#define TRADE_STATUS_ERROR_OPEN          (8)                        // 8:order trade error to open order
#define TRADE_STATUS_ERROR_CLOSE         (9)                        // 9:order trade error to close order
#define TRADE_STATUS_ERROR_CLOSE_PART    (10)                        // 10:order trade error to close part order 


//+------------------------------------------------------------------+
//|  order trade type
//+------------------------------------------------------------------+ 
#define TRADE_TYPE_MARKET                (0)                        // 0:Market Buy.Sell order
#define TRADE_TYPE_LIMIT_PENDING         (1)                        // 1:Buy.Sell Limit pending order
#define TRADE_TYPE_STOP_PENDING          (2)                        // 2:Buy.Sell Stop pending order
#define TRADE_TYPE_STOP_LIMIT            (3)                        // 3:Upon reaching the order price, a pending Buy.Sell Limit order is placed at the StopLimit price
#define TRADE_TYPE_CLOSE_BY              (4)                        // 4:Order to close a position by an opposite one
#define TRADE_TYPE_TIME_LIMIT            (5)                        // 5:Buy.Sell Time Limit pending order

