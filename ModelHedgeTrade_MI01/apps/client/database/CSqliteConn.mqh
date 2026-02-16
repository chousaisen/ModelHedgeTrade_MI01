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
      //+------------------------------------------------------------------+
      //|  构造函数
      //+------------------------------------------------------------------+
      CSqliteConn(){
         this.m_dbName="";
         this.m_handle=INVALID_HANDLE;
      }

      //+------------------------------------------------------------------+
      //|  打开 sqlite 数据库连接
      //|  @dbName    数据库名称或路径
      //+------------------------------------------------------------------+
      bool Open(string dbName){
         this.m_dbName=dbName;
         this.m_handle=DatabaseOpen(this.m_dbName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
         return this.m_handle!=INVALID_HANDLE;
      }

      //+------------------------------------------------------------------+
      //|  关闭 sqlite 数据库连接
      //+------------------------------------------------------------------+
      void Close(){
         if(this.m_handle!=INVALID_HANDLE){
            DatabaseClose(this.m_handle);
            this.m_handle=INVALID_HANDLE;
         }
      }

      //+------------------------------------------------------------------+
      //|  获取 sqlite 连接句柄
      //+------------------------------------------------------------------+
      int Handle(){
         return this.m_handle;
      }

      //+------------------------------------------------------------------+
      //|  获取驱动名称
      //+------------------------------------------------------------------+
      string DriverName(){
         return "sqlite";
      }
};
