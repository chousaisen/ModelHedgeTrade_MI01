//+------------------------------------------------------------------+
//|                                                        IDbConn.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

class IDbConn {
   public:
      virtual bool   Open(string dbName) = 0;
      virtual void   Close() = 0;
      virtual int    Handle() = 0;
      virtual string DriverName() = 0;
};
