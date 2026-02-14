//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+

input  string  FILTER_OPEN_SETTING="------ filter open model ------";

input  bool    GRID_OPEN_FILTER_CHECK_PASS=false;
input  bool    GRID_OPEN_FILTER_CHECK_STATUS=true;
input  bool    GRID_OPEN_FILTER_CHECK_HEDGE=false;
input  bool    GRID_OPEN_FILTER_CHECK_DIFF=true;
input  bool    GRID_OPEN_FILTER_CHECK_EDGE_RATE=false;


input  double  GRID_OPEN_FILTER_RNG_MIN_EDGE_RATE=0.5;
input  double  GRID_OPEN_FILTER_TND_MAX_EDGE_RATE=0.5;

input  double  GRID_OPEN_RANGE_DIFF_BASE_RATE =2;
input  int     GRID_OPEN_HEDGE_MIN_ORDER_COUNT=5;
input  double  GRID_OPEN_LIMIT_EXCEED_RELOT=0.02;
input  double  GRID_OPEN_LIMIT_EXCEED_RELOT_RATE=0.1;
input  bool    GRID_OPEN_EXCEED_JUMP=true;
input  double  GRID_OPEN_EXCEED_JUMP_MIN_PIPS=5000;
input  bool    GRID_OPEN_EXCEED_CUR_JUMP=true;
input  double  GRID_OPEN_EXCEED_JUMP_CUR_MIN_PIPS=1000;
input  bool    GRID_OPEN_EXCEED_ADJUST_DIFF=true;
input  bool    GRID_OPEN_EXCEED_ADJUST_ONLY_CUR_DIFF=true;
input  double  GRID_OPEN_EXCEED_ADJUST_GROW_RATE=1.2;
input  double  GRID_OPEN_EXCEED_ADJUST_MIN_RATE=0.5;
input  double  GRID_OPEN_EXCEED_ADJUST_MAX_RATE=5;
input  double  GRID_OPEN_EXCEED_ADJUST_BEGIN_COUNT=6;
input  double  GRID_OPEN_EXCEED_ADJUST_END_COUNT=20;

input  double  GRID_OPEN_MIN_RISK_EXCEED_PROFIT=0;
input  double  GRID_OPEN_MAX_RISK_EXCEED_PROFIT=-9000;
input  double  GRID_OPEN_MIN_RISK_HEDGE_RATE=0;
input  double  GRID_OPEN_MAX_RISK_HEDGE_RATE=1;
input  double  GRID_OPEN_RISK_HEDGE_GROW_RATE=1;
input  double  GRID_OPEN_MIN_RISK_DIFF_RATE=1;
input  double  GRID_OPEN_MAX_RISK_DIFF_RATE=0;
input  double  GRID_OPEN_RISK_DIFF_GROW_RATE=1;

input  double  GRID_OPEN_RANGE_PASS_SECONDS=3600;