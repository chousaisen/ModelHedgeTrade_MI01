//+------------------------------------------------------------------+
//|                                               CHedgeSyncService.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "CHedgePairGateway.mqh"

class CHedgeSyncService {
   private:
      CHedgePairGateway *m_gw;
      CDbPool           *m_pool;

      int GetHandle(EDbNode node){
         if(this.m_pool==NULL) return INVALID_HANDLE;
         IDbConn *conn=this.m_pool->Get(node);
         if(conn==NULL || CheckPointer(conn)==POINTER_INVALID) return INVALID_HANDLE;
         return conn->Handle();
      }

   public:
      CHedgeSyncService(){
         this.m_gw=NULL;
         this.m_pool=NULL;
      }

      void Init(CDbPool *pool,CHedgePairGateway *gw){
         this.m_pool=pool;
         this.m_gw=gw;
      }

      bool SyncPutRiskToProtect(EDbNode masterNode, EDbNode slaveNode,
                                int masterModelKind, int slaveModelKind){
         int src=GetHandle(masterNode);
         if(src==INVALID_HANDLE || this.m_gw==NULL) return false;

         string sql="SELECT mOrderId,mOrderStatus FROM risk_hedgePair WHERE modelKind="+IntegerToString(masterModelKind)+";";
         int req=DatabasePrepare(src,sql);
         if(req==INVALID_HANDLE) return false;

         while(DatabaseRead(req)){
            long mOrderId=0;
            int mOrderStatus=0;
            DatabaseColumnLong(req,0,mOrderId);
            DatabaseColumnInteger(req,1,mOrderStatus);
            this.m_gw->UpsertProtectFromRisk(slaveNode,slaveModelKind,mOrderId,mOrderStatus);
         }
         DatabaseFinalize(req);
         return true;
      }

      bool SyncPullProtectToRisk(EDbNode slaveNode, EDbNode masterNode,
                                 int masterModelKind, int slaveModelKind){
         int src=GetHandle(slaveNode);
         if(src==INVALID_HANDLE || this.m_gw==NULL) return false;

         string sql="SELECT mOrderId,hModelKind,hOrderId,hOrderStatus FROM protect_hedgePair WHERE modelKind="+
                    IntegerToString(slaveModelKind)+";";
         int req=DatabasePrepare(src,sql);
         if(req==INVALID_HANDLE) return false;

         while(DatabaseRead(req)){
            long mOrderId=0;
            int hModelKind=0;
            long hOrderId=0;
            int hOrderStatus=0;
            DatabaseColumnLong(req,0,mOrderId);
            DatabaseColumnInteger(req,1,hModelKind);
            DatabaseColumnLong(req,2,hOrderId);
            DatabaseColumnInteger(req,3,hOrderStatus);
            this.m_gw->UpdateRiskHedgeFields(masterNode,masterModelKind,mOrderId,hModelKind,hOrderId,hOrderStatus);
         }
         DatabaseFinalize(req);
         return true;
      }

      bool SyncCloseHedge(EDbNode slaveNode, int slaveModelKind, int clearStatus){
         int src=GetHandle(slaveNode);
         if(src==INVALID_HANDLE || this.m_gw==NULL) return false;

         string sql="SELECT mOrderId FROM protect_hedgePair WHERE modelKind="+IntegerToString(slaveModelKind)+
                    " AND hOrderStatus="+IntegerToString(clearStatus)+";";
         int req=DatabasePrepare(src,sql);
         if(req==INVALID_HANDLE) return false;

         while(DatabaseRead(req)){
            long mOrderId=0;
            DatabaseColumnLong(req,0,mOrderId);
            this.m_gw->ClearProtectHedgeFields(slaveNode,slaveModelKind,mOrderId);
         }
         DatabaseFinalize(req);
         return true;
      }
};
