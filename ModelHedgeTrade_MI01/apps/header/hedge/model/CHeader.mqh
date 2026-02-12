//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+

input  string  MODEL_RUNNER_SETTING="------ model runner setting ------";

input  bool    GRID_MODEL_HEDGE=false;
input  int     GRID_MODEL_MAX_COUNT=10;   
input  int     GRID_MODEL_MAX_SYMBOL_TYPE_COUNT=3;
input  int     GRID_MAX_ORDER_COUNT=3;   
input  string  GRID_EXTEND_LIST="300,300,300";
input  double  GRID_DISTANCE_DIFF_PIPS=2000;
input  string  GRID_PROFIT_LIST="300,400,500";
input  double  GRID_STOP_LOSS_PIPS=1200;
input  double  HEDGE_GRID_PROTECT_PIPS=1200;
input  double  HEDGE_GRID_PROTECT_DIFF_PIPS=100;


input  bool    S1_GRID_MODEL_HEDGE=true;
input  int     S1_GRID_MODEL_MAX_COUNT=10;   
input  int     S1_GRID_MODEL_MAX_SYMBOL_TYPE_COUNT=3;
input  int     S1_GRID_MAX_ORDER_COUNT=3;   
input  string  S1_GRID_EXTEND_LIST="300,300,300"; 
input  double  S1_GRID_DISTANCE_DIFF_PIPS=2000;  
input  string  S1_GRID_PROFIT_LIST="300,400,500";
input  double  S1_GRID_STOP_LOSS_PIPS=1200;
input  double  S1_HEDGE_GRID_PROTECT_PIPS=1200;
input  double  S1_HEDGE_GRID_PROTECT_DIFF_PIPS=100;

input  double  P_GROUP_RUNNER_MAX_COUNT=1;
input  bool    P_GROUP_RUNNER_PROTECT_ALL=true;