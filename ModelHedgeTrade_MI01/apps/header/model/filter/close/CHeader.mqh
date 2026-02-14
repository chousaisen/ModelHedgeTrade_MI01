//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+

input  string  FILTER_CLOSE_SETTING="------ filter close model ------";

input  bool    GRID_CLOSE_HEDGE=false;
//input  bool    GRID_CLOSE_HEDGE2=false;
input  bool    GRID_CLOSE_ANALYSIS_REFRESH=false;
input  int     GRID_CLOSE_HEDGE_MIN_ORDER=3;
//input  double  GRID_CLOSE_HEDGE_BEGIN_DIFF_RATE=0.1;
//input  double  GRID_CLOSE_HEDGE_END_DIFF_RATE=0.3;
//input  double  GRID_CLOSE_HEDGE_BEGIN_HEDGE_RATE=1;
//input  double  GRID_CLOSE_HEDGE_END_HEDGE_RATE=0;
input  double  GRID_CLOSE_TREND_LESS_PIPS=100;
input  int     GRID_CLOSE_TREND_MODEL_MIN_ORDER=3;

input  bool    GRID_CLOSE_EXCEED_JUMP=true;
input  double  GRID_CLOSE_EXCEED_JUMP_MIN_PIPS=300;
input  bool    GRID_CLOSE_EXCEED_CUR_JUMP=false;
input  double  GRID_CLOSE_EXCEED_JUMP_CUR_MIN_PIPS=100;

input  double  GRID_CLOSE_MIN_RISK_EXCEED_PROFIT=0;
input  double  GRID_CLOSE_MAX_RISK_EXCEED_PROFIT=-9000;
input  double  GRID_CLOSE_MIN_RISK_HEDGE_RATE=0;
input  double  GRID_CLOSE_MAX_RISK_HEDGE_RATE=1;
input  double  GRID_CLOSE_RISK_HEDGE_GROW_RATE=1;
input  bool    GRID_CLOSE_BREAK_PROTECT_HEDGE=true;
input  double  GRID_CLOSE_BREAK_PROTECT_HEDGE_RATE=1;