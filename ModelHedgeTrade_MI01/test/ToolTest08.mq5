//+------------------------------------------------------------------+
//| calculate the price action speed
//+------------------------------------------------------------------+


#include "../apps/header/symbol/CHeader.mqh"
#include "../apps/indicator/strength/CTickSpeed.mqh"
///+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


CTickSpeed tickSpeed;

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
   string symbol = _Symbol;      // Current symbol
   ENUM_TIMEFRAMES timeframe = PERIOD_M1; // Timeframe for visualization
   //int long_ticks = 3000;        // Long-term tick range
   //int short_ticks = 300;        // Short-term tick range
   //double acceleration_threshold = 0.5; // Acceleration threshold for marking arrows

   ENUM_TICK_STATE tickState=tickSpeed.getTickState(symbol,
                                                      Ind_Tick_Speed_Long_Ticks,
                                                      Ind_Tick_Speed_Short_Ticks,
                                                      Ind_Tick_Speed_Acceleration_Threshold);
   
   // Determine the last bar for marking
   int last_bar = iBarShift(symbol, timeframe, TimeCurrent());
   double arrow_price = iClose(symbol, timeframe, 0);

   // Add arrows to chart
   long chart_id = 0; // Current chart ID
   string arrow_name = "Arrow_" + TimeToString(TimeCurrent(), TIME_MINUTES|TIME_SECONDS) + "_" + IntegerToString(last_bar);

   if (tickState==TICK_STATE_ACC_UP)
   {
      // Mark accelerating upward
      if (!ObjectCreate(chart_id, arrow_name, OBJ_ARROW_UP, 0, TimeCurrent(), arrow_price))
      {
         Print("Failed to create upward arrow object.");
         return;
      }
      ObjectSetInteger(chart_id, arrow_name, OBJPROP_COLOR, clrYellow);
      ObjectSetInteger(chart_id, arrow_name, OBJPROP_WIDTH, 2);
      Print("Acceleration Upward Arrow Added");
   }
   else if (tickState==TICK_STATE_ACC_DOWN)
   {
      // Mark accelerating downward
      if (!ObjectCreate(chart_id, arrow_name, OBJ_ARROW_DOWN, 0, TimeCurrent(), arrow_price))
      {
         Print("Failed to create downward arrow object.");
         return;
      }
      ObjectSetInteger(chart_id, arrow_name, OBJPROP_COLOR, clrRed);
      ObjectSetInteger(chart_id, arrow_name, OBJPROP_WIDTH, 2);
      Print("Acceleration Downward Arrow Added");
   }
}