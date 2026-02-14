//+------------------------------------------------------------------+
//| calculate the price action speed
//+------------------------------------------------------------------+


/*
换个思路，变成获取当前1000个tick的平均速度（V pips/秒），然后获取当前100tick 的速度（V pips/秒），
正值为上涨，负值为下跌，通过1000tick的平均速度，和100tick的平均速度比较，判断当前波动速度的快慢，
并获取当前100tick 的速度的加速度值（V pips/秒），以判断加速上涨还是加速下跌




*/


#include "../apps/header/symbol/CHeader.mqh"
///+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Calculate Average Speed (in pips/second) for a given tick range  |
//+------------------------------------------------------------------+
double CalculateAverageSpeed(string symbol, int tick_count)
{
   MqlTick ticks[];
   if (CopyTicks(symbol, ticks, COPY_TICKS_ALL, 0, tick_count) <= 1)
   {
      Print("Failed to retrieve ticks for ", symbol);
      return 0.0;
   }

   double total_speed = 0.0;
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT); // Point size in pips

   for (int i = 1; i < ArraySize(ticks); i++)
   {
      double delta_price = (ticks[i].last - ticks[i - 1].last) / point; // Price change in pips
      double delta_time = double(ticks[i].time_msc - ticks[i - 1].time_msc) / 1000.0; // Time difference in seconds
      if (delta_time > 0.0)
         total_speed += delta_price / delta_time; // Speed in pips/second
   }

   return total_speed / (ArraySize(ticks) - 1); // Average speed in pips/second
}

//+------------------------------------------------------------------+
//| Main Program Entry Point                                         |
//+------------------------------------------------------------------+
void OnTick()
{
   string symbol = "EURUSD"; // Current symbol
   int long_ticks = 1000;    // Long-term tick range
   int short_ticks = 100;    // Short-term tick range

   // Calculate average speeds for long-term and short-term ticks
   double long_speed = CalculateAverageSpeed(symbol, long_ticks);
   double short_speed = CalculateAverageSpeed(symbol, short_ticks);

   // Calculate acceleration (change in short-term speed relative to long-term)
   double acceleration = short_speed - long_speed;

   // Output results
   Print("Long-term Average Speed (1000 ticks): ", long_speed, " pips/sec");
   Print("Short-term Average Speed (100 ticks): ", short_speed, " pips/sec");
   Print("Acceleration: ", acceleration, " pips/sec²");

   // Determine market status based on speed and acceleration
   if (MathAbs(short_speed) < 0.001 && MathAbs(acceleration) < 0.001)
      Print("Market Status: Stable");
   else if (short_speed > 0)
   {
      if (acceleration > 0.002)
         Print("Market Status: Accelerating Upward");
      else if (acceleration > 0)
         Print("Market Status: Upward");
      else
         Print("Market Status: Decelerating Upward");
   }
   else
   {
      if (acceleration < -0.002)
         Print("Market Status: Accelerating Downward");
      else if (acceleration < 0)
         Print("Market Status: Downward");
      else
         Print("Market Status: Decelerating Downward");
   }
}
