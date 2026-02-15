//+------------------------------------------------------------------+
//|                                                    CSqliteConn.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "IDbConn.mqh"

class CSqliteConn : public IDbConn {
   private:
      string m_dbName;
      int    m_handle;

   public:
      CSqliteConn(){
         this.m_dbName="";
         this.m_handle=INVALID_HANDLE;
      }

      bool Open(string dbName){
         this.m_dbName=dbName;
         this.m_handle=DatabaseOpen(this.m_dbName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
         return this.m_handle!=INVALID_HANDLE;
      }

      void Close(){
         if(this.m_handle!=INVALID_HANDLE){
            DatabaseClose(this.m_handle);
            this.m_handle=INVALID_HANDLE;
         }
      }

      int Handle(){
         return this.m_handle;
      }

      string DriverName(){
         return "sqlite";
      }
};
