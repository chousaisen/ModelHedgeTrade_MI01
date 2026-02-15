//+------------------------------------------------------------------+
//|                                                        CDbPool.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "enums.mqh"
#include "CDbConnFactory.mqh"

class CDbPool {
   private:
      EDbDriver m_driver;
      IDbConn  *m_master1;
      IDbConn  *m_slave1;
      IDbConn  *m_slave2;

   public:
      //+------------------------------------------------------------------+
      //|  构造函数
      //+------------------------------------------------------------------+
      CDbPool(){
         this.m_driver=DB_DRIVER_SQLITE;
         this.m_master1=NULL;
         this.m_slave1=NULL;
         this.m_slave2=NULL;
      }

      //+------------------------------------------------------------------+
      //|  初始化连接池并按开关创建数据库连接
      //|  @driver        数据库驱动类型
      //|  @useMaster1    是否启用 master1 连接
      //|  @useSlave1     是否启用 slave1 连接
      //|  @useSlave2     是否启用 slave2 连接
      //|  @masterDbName  master1 数据库名称
      //|  @slave1DbName  slave1 数据库名称
      //|  @slave2DbName  slave2 数据库名称
      //+------------------------------------------------------------------+
      bool Init(EDbDriver driver,
                bool useMaster1,bool useSlave1,bool useSlave2,
                string masterDbName,string slave1DbName,string slave2DbName){
         this.m_driver=driver;

         if(useMaster1){
            this.m_master1=CDbConnFactory::Create(this.m_driver);
            if(CheckPointer(this.m_master1)==POINTER_INVALID || !this.m_master1.Open(masterDbName)) return false;
         }
         if(useSlave1){
            this.m_slave1=CDbConnFactory::Create(this.m_driver);
            if(CheckPointer(this.m_slave1)==POINTER_INVALID || !this.m_slave1.Open(slave1DbName)) return false;
         }
         if(useSlave2){
            this.m_slave2=CDbConnFactory::Create(this.m_driver);
            if(CheckPointer(this.m_slave2)==POINTER_INVALID || !this.m_slave2.Open(slave2DbName)) return false;
         }

         return true;
      }

      //+------------------------------------------------------------------+
      //|  根据节点类型获取数据库连接
      //|  @node    数据库节点类型
      //+------------------------------------------------------------------+
      IDbConn* Get(EDbNode node){
         if(node==DB_MASTER1) return this.m_master1;
         if(node==DB_SLAVE1) return this.m_slave1;
         if(node==DB_SLAVE2) return this.m_slave2;
         return NULL;
      }

      //+------------------------------------------------------------------+
      //|  关闭并释放连接池内的所有连接
      //+------------------------------------------------------------------+
      void Shutdown(){
         if(CheckPointer(this.m_master1)!=POINTER_INVALID && this.m_master1!=NULL){ this.m_master1.Close(); delete this.m_master1; }
         if(CheckPointer(this.m_slave1)!=POINTER_INVALID && this.m_slave1!=NULL){ this.m_slave1.Close(); delete this.m_slave1; }
         if(CheckPointer(this.m_slave2)!=POINTER_INVALID && this.m_slave2!=NULL){ this.m_slave2.Close(); delete this.m_slave2; }
         this.m_master1=NULL;
         this.m_slave1=NULL;
         this.m_slave2=NULL;
      }
};
