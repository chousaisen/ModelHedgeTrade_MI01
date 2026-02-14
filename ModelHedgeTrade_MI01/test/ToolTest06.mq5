//+------------------------------------------------------------------+
//| calculate the price action speed
//+------------------------------------------------------------------+


#include "../apps/header/symbol/CHeader.mqh"
///+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   return INIT_SUCCEEDED;
}
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

// 获取状态的通用函数
ENUM_STATE GetCurrentState(string symbol, double diffPoint, ENUM_TIMEFRAMES period, ENUM_STATE currentState)
{
   // 布林带参数
   int bands_period = 128;                      // 平均线计算周期
   int bands_shift = 0;                         // 指标平移（0表示无平移）
   double deviation = 2.0;                      // 标准差数
   ENUM_APPLIED_PRICE applied_price = PRICE_WEIGHTED; // 应用价格

   // 获取布林带句柄
   int handle = iBands(symbol, period, bands_period, bands_shift, deviation, applied_price);
   if (handle == INVALID_HANDLE)
   {
      Print("iBands指标句柄获取失败");
      return STATE_UNKNOWN;
   }

   // 获取布林带数据
   double upperBand[], middleBand[], lowerBand[];
   if (CopyBuffer(handle, 1, 0, 1, upperBand) <= 0 ||
       CopyBuffer(handle, 0, 0, 1, middleBand) <= 0 ||
       CopyBuffer(handle, 2, 0, 1, lowerBand) <= 0)
   {
      Print("无法获取布林带数据");
      return STATE_UNKNOWN;
   }

   // 获取当前价格
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);

   // 获取点值
   double pointValue = SymbolInfoDouble(symbol, SYMBOL_POINT);

   // 计算加权后的diffPoint
   double weightedDiffPoint = diffPoint * pointValue;

   // 状态判断逻辑
   ENUM_STATE newState = currentState;

   if (currentState == STATE_UNKNOWN)
   {
      // 初始状态，无需考虑diffPoint
      if (currentPrice > upperBand[0])
         newState = STATE_BREAKOUT_UP;
      if (currentPrice > middleBand[0] && currentPrice<=upperBand[0])
         newState = STATE_UPPER_RANGE;
      if (currentPrice <= middleBand[0] && currentPrice>=lowerBand[0])
         newState = STATE_LOWER_RANGE;
      if (currentPrice < lowerBand[0])
         newState = STATE_BREAKOUT_DOWN;
   }
   else if (currentState == STATE_BREAKOUT_UP){
      if (currentPrice < upperBand[0]- weightedDiffPoint)
         newState = STATE_RETURN_UPPER;            
   }
   else if (currentState == STATE_BREAKOUT_DOWN){
      if (currentPrice > lowerBand[0]+ weightedDiffPoint)
         newState = STATE_RETURN_LOWER;          
   }   
   else if (currentState == STATE_UPPER_RANGE || currentState == STATE_RETURN_UPPER){
      if (currentPrice > upperBand[0] + weightedDiffPoint)
         newState = STATE_BREAKOUT_UP;
      if (currentPrice < middleBand[0] - weightedDiffPoint)
         newState = STATE_LOWER_RANGE;         
   }
   else if (currentState == STATE_LOWER_RANGE || currentState == STATE_RETURN_LOWER){
      if (currentPrice > middleBand[0] + weightedDiffPoint)
         newState = STATE_UPPER_RANGE;      
      if (currentPrice < lowerBand[0] - weightedDiffPoint)
         newState = STATE_BREAKOUT_DOWN;               
   }

   return newState;
}

// 主程序调用示例
void OnTick()
{
   static ENUM_STATE currentState = STATE_UNKNOWN; // 静态变量保存当前状态

   // 调用通用函数获取状态
   ENUM_STATE newState = GetCurrentState("XAUUSD", 150.0, PERIOD_M15, currentState);

   // 如果状态发生变化，更新并打印
   if (newState != currentState)
   {
      currentState = newState;
      switch (currentState)
      {
         case STATE_UPPER_RANGE:
            Print("当前状态：震荡上半区");
            break;
         case STATE_BREAKOUT_UP:
            Print("当前状态：上涨突破区");
            break;
         case STATE_RETURN_UPPER:
            Print("当前状态：退回震荡上半区");
            break;
         case STATE_LOWER_RANGE:
            Print("当前状态：震荡下半区");
            break;
         case STATE_BREAKOUT_DOWN:
            Print("当前状态：下跌突破区");
            break;
         case STATE_RETURN_LOWER:
            Print("当前状态：退回震荡下半区");
            break;
         default:
            Print("未知状态");
            break;
      }
   }
}
