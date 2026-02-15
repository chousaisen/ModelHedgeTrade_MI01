//+------------------------------------------------------------------+
//|                                                 CDbConnFactory.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "enums.mqh"
#include "IDbConn.mqh"
#include "CSqliteConn.mqh"

class CDbConnFactory {
   public:
      static IDbConn* Create(EDbDriver driver){
         switch(driver){
            case DB_DRIVER_SQLITE:
               return new CSqliteConn();
            case DB_DRIVER_MYSQL:
               Print("DB driver mysql is not implemented yet. Fallback to sqlite.");
               return new CSqliteConn();
            default:
               Print("Unknown DB driver. Fallback to sqlite.");
               return new CSqliteConn();
         }
      }
};
