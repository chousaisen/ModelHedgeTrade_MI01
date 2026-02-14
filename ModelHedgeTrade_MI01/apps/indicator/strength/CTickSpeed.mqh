//+------------------------------------------------------------------+
//|                                                    CTickSpeed.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../header/symbol/CHeader.mqh"
#include "../../share/CShareCtl.mqh"
#include "CHeader.mqh"

class CTickSpeed
  {
private:
      int               refreshTime;
      CShareCtl*        shareCtl;
public:
                        CTickSpeed();
                       ~CTickSpeed();
      void              init(CShareCtl* shareCtl);   
      void              refresh();
      void              run();
      double            calculateAverageSpeed(string curSymbol, int seconds);
      ENUM_TICK_STATE   getTickState(string curSymbol,int longTicks,int shortTicks,double accelerationThreshold);

};

//+------------------------------------------------------------------+
//|  init the tick speed
//+------------------------------------------------------------------+
void CTickSpeed::init(CShareCtl* shareCtl)
{
   this.shareCtl=shareCtl;
}

//+------------------------------------------------------------------+
//| Calculate Average Speed (in pips/second) for a given tick range  |
//+------------------------------------------------------------------+
double CTickSpeed::calculateAverageSpeed(string curSymbol, int tick_count)
{
   MqlTick ticks[];
   if (CopyTicks(curSymbol, ticks, COPY_TICKS_ALL, 0, tick_count) <= 1)
   {
      Print("Failed to retrieve ticks for ", curSymbol);
      return 0.0;
   }

   double total_speed = 0.0;
   double point = SymbolInfoDouble(curSymbol, SYMBOL_POINT); // Point size in pips

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
ENUM_TICK_STATE CTickSpeed::getTickState(string curSymbol,int longTicks,int shortTicks,double accelerationThreshold)
{
   string symbol = curSymbol;      // Current symbol
   int    long_ticks = longTicks;        // Long-term tick range
   int    short_ticks = shortTicks;        // Short-term tick range
   double acceleration_threshold = accelerationThreshold; // Acceleration threshold for marking arrows

   // Calculate average speeds
   double long_speed = this.calculateAverageSpeed(symbol, long_ticks);
   double short_speed = this.calculateAverageSpeed(symbol, short_ticks);

   // Calculate acceleration
   double acceleration = short_speed - long_speed;

   if (acceleration > acceleration_threshold)
   {
      return TICK_STATE_ACC_UP;
   }
   else if (acceleration < -acceleration_threshold)
   {
      return TICK_STATE_ACC_DOWN;
   }   
   return TICK_STATE_ACC_NONE;
}

//+------------------------------------------------------------------+
//|  refresh indicator data
//+------------------------------------------------------------------+
void CTickSpeed::refresh(){

   //refresh diff time setting
   int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
   if(refreshDiffSeconds<IND_TICK_SPEED_DIFF_SECONDS)return;
      
   int total_symbols = ArraySize(SYMBOL_LIST);
   
   // Output weights for each symbol   
   string logTempStr="";
   for (int i = 0; i < total_symbols; i++)
   {      
   
      if(!this.shareCtl.getSymbolShare().runable(i))continue;
     
      string symbol=comFunc.addSuffix(SYMBOL_LIST[i]);
      double curTickSpeedAccelerationThreshold=Ind_Tick_Speed_Acceleration_Threshold*SYMBOL_RATE[i];
      ENUM_TICK_STATE tickState=this.getTickState(symbol,
                                                      Ind_Tick_Speed_Long_Ticks,
                                                      Ind_Tick_Speed_Short_Ticks,
                                                      curTickSpeedAccelerationThreshold);      

      this.shareCtl.getIndicatorShare().setTickStatus(i,tickState);
      
      logTempStr+="<"+SYMBOL_LIST[i] + "|" + this.shareCtl.getIndicatorShare().getTickStatus(i)+">";
   }        
   
   //rkeeLog.printLogLine("indicator",9009,300, comFunc.getDate_YYYYMMDDHHMM2() + "  " +  logTempStr);
   
   //set the refresh time
   this.refreshTime=TimeCurrent();        
      
}

//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CTickSpeed::run(){
    this.refresh();
}

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CTickSpeed::CTickSpeed()
{
   this.refreshTime=0;
}
CTickSpeed::~CTickSpeed(){}