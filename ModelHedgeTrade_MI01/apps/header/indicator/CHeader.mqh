//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
input  string   INDICATOR1_SETTING="------indicator  Setting ------";
input  int             Ind_Correlation_Period=120;
input  ENUM_TIMEFRAMES Ind_Correlation_TimeFrame =PERIOD_H4;
input  string   INDICATOR2_SETTING="------indicator  Setting ------";
input ENUM_TIMEFRAMES  Ind_Sar_TimeFrame = PERIOD_M1; 
input double           Ind_Sar_Step_Begin = 0.001;     
input double           Ind_Sar_Step_Max = 0.01;  
input double           Ind_Sar_Step_Unit = 0.0001;
input  string   INDICATOR3_SETTING="------indicator  Setting ------";
input  string          Ind_Channel_Name = "RkeeChannel";
input  int             Ind_Channel_Period = 12;
input  string   INDICATOR4_SETTING="------indicator  Setting ------";
input  double  Range_Edge_Break_Diff_Pips =100;
input  double  Trend_To_Range_Less_Pips =300;
input  double  Trend_To_Range_Recover_Pips =300;