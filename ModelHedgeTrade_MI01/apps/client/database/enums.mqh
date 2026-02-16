//+------------------------------------------------------------------+
//|                                                          enums.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

enum EDbNode {
   DB_MASTER1 = 1, // 主库节点1
   DB_SLAVE1  = 2, // 从库节点1
   DB_SLAVE2  = 3  // 从库节点2
};

enum ERunnerMode {
   RUNNER_MASTER_ONLY = 1, // 仅使用主库运行
   RUNNER_SLAVE_ONLY  = 2, // 仅使用从库运行
   RUNNER_HYBRID      = 3  // 主从混合运行
};

enum EDbDriver {
   DB_DRIVER_SQLITE = 1, // SQLite 驱动
   DB_DRIVER_MYSQL  = 2, // MySQL 驱动（预留）
   DB_DRIVER_OTHER  = 9  // 其他驱动类型
};
