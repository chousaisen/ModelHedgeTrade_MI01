//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+

input  string  FILTER_EXTEND_SETTING="------ filter extend model ------";

input  bool    GRID_OPEN_EXTEND_HEDGE=true;
input  bool    GRID_OPEN_EXTEND_EXCEED_ADJUST_DIFF=true;
input  int     GRID_OPEN_EXTEND_EXCEED_MIN_MODEL=1;
input  int     GRID_OPEN_EXTEND_EXCEED_MAX_MODEL=10;
input  int     GRID_OPEN_EXTEND_EXCEED_MIN_ORDER=1;
input  int     GRID_OPEN_EXTEND_EXCEED_MAX_ORDER=6;
input  double  GRID_OPEN_EXTEND_EXT_ADJUST_GROW_RATE=1.2;
input  double  GRID_OPEN_EXTEND_EXT_ADJUST_MIN_RATE=1;
input  double  GRID_OPEN_EXTEND_EXT_ADJUST_MAX_RATE=5;
input  double  GRID_OPEN_EXTEND_EXT_ADJUST_BEGIN_COUNT=6;
input  double  GRID_OPEN_EXTEND_EXT_ADJUST_END_COUNT=20;
input  double  GRID_OPEN_EXTEND_MIN_RISK_EXCEED_PROFIT=0;
input  double  GRID_OPEN_EXTEND_MAX_RISK_EXCEED_PROFIT=-20000;
input  double  GRID_OPEN_EXTEND_MIN_RISK_HEDGE_RATE=0;
input  double  GRID_OPEN_EXTEND_MAX_RISK_HEDGE_RATE=1;
input  double  GRID_OPEN_EXTEND_RISK_HEDGE_GROW_RATE=1;