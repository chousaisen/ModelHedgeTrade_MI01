//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+

#include <Generic\ArrayList.mqh>

//+------------------------------------------------------------------+
//|  band define
//+------------------------------------------------------------------+
#define IND_BAND_PERIOD         (32)                   // band indicator period
#define IND_BAND_TIMEFRAME      (PERIOD_M15)             // band indicator time frame
#define IND_BAND_DIFF_SECONDS   (10)                    // band status refresh diff seconds
#define IND_BAND_DIFF_RATE      (0.15)                   // judge band status diff point
#define IND_BAND_LV0            (0)                     // judge band level 0 (time frame M15)
#define IND_BAND_LV1            (1)                     // judge band level 1 (time frame M30)
#define IND_BAND_LV2            (2)                     // judge band level 2 (time frame H1)

//+------------------------------------------------------------------+
//|  price channel define
//+------------------------------------------------------------------+
#define IND_PCHANNEL_DIFF_SECONDS     (3)                    // band status refresh diff seconds
#define IND_PCHANNEL_PERIOD_COUNT     (7)                     // price channel period count


//+------------------------------------------------------------------+
//|  strength shift define
//+------------------------------------------------------------------+
#define IND_STRENGTH_SHIFT_DIFF_SECONDS   (60)                  // strength shift refresh diff seconds

//+------------------------------------------------------------------+
//|  trend define(SAR Indicator)
//+------------------------------------------------------------------+
#define IND_TREND_NONE               (0)                       // indicator trend status none
#define IND_TREND_RANGE              (1)                       // indicator  trend range
#define IND_TREND_UP                 (2)                       // indicator  trend up
#define IND_TREND_DOWN               (3)                       // indicator  trend down

//+------------------------------------------------------------------+
//|  range status
//+------------------------------------------------------------------+ 
#define STATUS_NONE                (0)                       // status none
#define STATUS_RANGE_INNER         (100)                     // range inner status
#define STATUS_RANGE_BREAK_UP      (200)                     // range break up status 
#define STATUS_RANGE_BREAK_UP_RE   (201)                     // range break up status return
#define STATUS_RANGE_BREAK_DOWN    (300)                     // range break down status
#define STATUS_RANGE_BREAK_DOWN_RE (301)                     // range break down status return