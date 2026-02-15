//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+

input  string     DATABASE_SETTING="------database  Setting ------";

input  bool       DB_DATA_RESET=true;
input  bool       DEBUG_DB_SAVE=true;
input  string     DEBUG_DB_NAME="data.sqlite";
input  string     DEBUG_DB_TABLE_IDX="8";

input  int        DB_DRIVER_TYPE=1; //1:sqlite 2:mysql(未来)
input  string     DB_MASTER1_NAME="master1.sqlite";
input  string     DB_SLAVE1_NAME="slave1.sqlite";
input  string     DB_SLAVE2_NAME="slave2.sqlite";
input  int        FEATURE_DB_RUNNER_MODE=3; //1:master-only 2:slave-only 3:hybrid
input  int        FEATURE_MASTER_MODEL_KIND=1001;
input  int        FEATURE_SLAVE_MODEL_KIND=1002;
input  int        FEATURE_CLOSE_STATUS=2001;
