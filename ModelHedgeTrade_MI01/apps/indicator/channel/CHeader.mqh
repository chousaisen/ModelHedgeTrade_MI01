//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+


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
#define IND_PCHANNEL_DIFF_SECONDS     (10)                    // band status refresh diff seconds
#define IND_PCHANNEL_PERIOD_COUNT     (7)                     // price channel period count