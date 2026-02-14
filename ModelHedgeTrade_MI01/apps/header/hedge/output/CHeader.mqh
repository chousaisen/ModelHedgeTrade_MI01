//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  define main order status
//+------------------------------------------------------------------+ 
#define MAIN_ORDER_RISK          (1001)         // main order need to hedge
#define MAIN_ORDER_CLEAR         (1002)         // main order clear to hedge

#define HEDGE_ORDER_NONE         (2000)         // hedge order none
#define HEDGE_ORDER_LOCK         (2001)         // hedge order lock to hedge
#define HEDGE_ORDER_OPEN         (2002)         // hedge order open to hedge
