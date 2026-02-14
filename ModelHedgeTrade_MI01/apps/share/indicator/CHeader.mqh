//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+


// 定义状态枚举
enum ENUM_STATE {
   STATE_UNKNOWN = -1,      // 未知状态
   STATE_UPPER_RANGE,       // 震荡上半区
   STATE_BREAKOUT_UP,       // 上涨突破区
   STATE_RETURN_UPPER,      // 退回震荡上半区
   STATE_LOWER_RANGE,       // 震荡下半区
   STATE_BREAKOUT_DOWN,     // 下跌突破区
   STATE_RETURN_LOWER       // 退回震荡下半区
};

// 定义状态枚举
enum ENUM_TICK_STATE {
   TICK_STATE_ACC_UP,           // tick state Acceleration Upward
   TICK_STATE_ACC_DOWN,         // tick state Acceleration Downward
   TICK_STATE_ACC_NONE          // tick state Acceleration none
};

#define IND_BAND_LV0            (0)                     // judge band level 0 (time frame M15)
#define IND_BAND_LV1            (1)                     // judge band level 1 (time frame M30)
#define IND_BAND_LV2            (2)                     // judge band level 2 (time frame H1)