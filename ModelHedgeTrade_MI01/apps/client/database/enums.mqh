//+------------------------------------------------------------------+
//|                                                          enums.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

enum EDbNode {
   DB_MASTER1 = 1,
   DB_SLAVE1  = 2,
   DB_SLAVE2  = 3
};

enum ERunnerMode {
   RUNNER_MASTER_ONLY = 1,
   RUNNER_SLAVE_ONLY  = 2,
   RUNNER_HYBRID      = 3
};

enum EDbDriver {
   DB_DRIVER_SQLITE = 1,
   DB_DRIVER_MYSQL  = 2,
   DB_DRIVER_OTHER  = 9
};
