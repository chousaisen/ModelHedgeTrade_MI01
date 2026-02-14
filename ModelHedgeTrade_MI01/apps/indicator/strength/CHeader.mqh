//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  price speed diff
//+------------------------------------------------------------------+
#define IND_PRICE_SPEED_DIFF_SECONDS   (60)                  // strength refresh diff seconds
#define IND_TICK_SPEED_DIFF_SECONDS   (5)                    // strength refresh diff seconds

//+------------------------------------------------------------------+
//|  price speed tend define
//+------------------------------------------------------------------+
#define PRICE_SPEED_ACCELERATING   (1)                  // price speed accelerating
#define PRICE_SPEED_DECELERATING   (-1)                 // price speed decelerating
#define PRICE_SPEED_STABLE         (0)                  // price speed stable

//+------------------------------------------------------------------+
//|  price speed level and timeframe level
//+------------------------------------------------------------------+
#define PRICE_SPEED_LEVEL_1        (0)                  // price speed level 1
#define PRICE_SPEED_LEVEL_2        (1)                  // price speed level 2
#define PRICE_SPEED_LEVEL_3        (2)                  // price speed level 3
#define PRICE_SPEED_LEVEL_4        (3)                  // price speed level 4
#define PRICE_SPEED_LEVEL_5        (4)                  // price speed level 5

#define IND_PRICE_SPEED_TIMEFRAME_LV1      (PERIOD_M1)             // price speed time frame level1
#define IND_PRICE_SPEED_TIMEFRAME_LV2      (PERIOD_M5)             // price speed time frame level2
#define IND_PRICE_SPEED_TIMEFRAME_LV3      (PERIOD_M15)             // price speed time frame level2
#define IND_PRICE_SPEED_TIMEFRAME_LV4      (PERIOD_M30)             // price speed time frame level3
#define IND_PRICE_SPEED_TIMEFRAME_LV5      (PERIOD_H1)             // price speed time frame level4

//+------------------------------------------------------------------+
//|  price speed calculate time frame and period
//+------------------------------------------------------------------+
#define PRICE_SPEED_PERIOD_SHORT        (10)                  // short period  10根K线
#define PRICE_SPEED_PERIOD_MID          (50)                  // midium period
#define PRICE_SPEED_PERIOD_LONG         (100)                  // long period

