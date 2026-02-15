//+------------------------------------------------------------------+
//|                                                CRunnerDbContext.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "enums.mqh"
#include "CDbPool.mqh"
#include "CHedgePairGateway.mqh"
#include "CHedgeSyncService.mqh"
#include "../../header/database/CHeader.mqh"

class CRunnerDbContext {
   private:
      ERunnerMode       m_mode;
      CDbPool           m_pool;
      CHedgePairGateway m_gateway;
      CHedgeSyncService m_sync;

   public:
      //+------------------------------------------------------------------+
      //|  构造函数
      //+------------------------------------------------------------------+
      CRunnerDbContext(){
         this.m_mode=RUNNER_MASTER_ONLY;
      }

      //+------------------------------------------------------------------+
      //|  初始化数据库运行上下文
      //|  @mode    运行模式
      //+------------------------------------------------------------------+
      bool Init(ERunnerMode mode){
         this.m_mode=mode;
         bool useMaster=(mode==RUNNER_MASTER_ONLY || mode==RUNNER_HYBRID);
         bool useSlave1=(mode==RUNNER_MASTER_ONLY || mode==RUNNER_SLAVE_ONLY || mode==RUNNER_HYBRID);
         bool useSlave2=(mode==RUNNER_SLAVE_ONLY || mode==RUNNER_HYBRID);

         bool ok=this.m_pool.Init((EDbDriver)DB_DRIVER_TYPE,
                                  useMaster,useSlave1,useSlave2,
                                  DB_MASTER1_NAME,DB_SLAVE1_NAME,DB_SLAVE2_NAME);
         if(!ok) return false;

         this.m_gateway.Init(&this.m_pool);
         this.m_sync.Init(&this.m_pool,&this.m_gateway);

         if(useMaster) this.m_gateway.EnsureTables(DB_MASTER1);
         if(useSlave1) this.m_gateway.EnsureTables(DB_SLAVE1);
         if(useSlave2) this.m_gateway.EnsureTables(DB_SLAVE2);
         return true;
      }

      //+------------------------------------------------------------------+
      //|  获取同步服务对象
      //+------------------------------------------------------------------+
      CHedgeSyncService* Sync(){
         return &this.m_sync;
      }

      //+------------------------------------------------------------------+
      //|  获取数据网关对象
      //+------------------------------------------------------------------+
      CHedgePairGateway* Gateway(){
         return &this.m_gateway;
      }

      //+------------------------------------------------------------------+
      //|  关闭数据库运行上下文
      //+------------------------------------------------------------------+
      void Shutdown(){
         this.m_pool.Shutdown();
      }
};
