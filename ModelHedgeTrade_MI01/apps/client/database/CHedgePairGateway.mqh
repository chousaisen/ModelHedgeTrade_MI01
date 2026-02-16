//+------------------------------------------------------------------+
//|                                               CHedgePairGateway.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "CDbPool.mqh"

class CHedgePairGateway {
   private:
      CDbPool *m_pool;

      //+------------------------------------------------------------------+
      //|  获取指定节点的数据库句柄
      //|  @node    数据库节点类型
      //+------------------------------------------------------------------+
      int GetHandle(EDbNode node){
         if(this.m_pool==NULL) return INVALID_HANDLE;
         IDbConn *conn=this.m_pool.Get(node);
         if(conn==NULL || CheckPointer(conn)==POINTER_INVALID) return INVALID_HANDLE;
         return conn.Handle();
      }

   public:
      //+------------------------------------------------------------------+
      //|  构造函数
      //+------------------------------------------------------------------+
      CHedgePairGateway(){
         this.m_pool=NULL;
      }

      //+------------------------------------------------------------------+
      //|  初始化网关并注入连接池
      //|  @pool    数据库连接池对象
      //+------------------------------------------------------------------+
      void Init(CDbPool *pool){
         this.m_pool=pool;
      }

      //+------------------------------------------------------------------+
      //|  确保对冲相关数据表存在
      //|  @node    数据库节点类型
      //+------------------------------------------------------------------+
      bool EnsureTables(EDbNode node){
         int h=GetHandle(node);
         if(h==INVALID_HANDLE) return false;

         string riskSql=
            "CREATE TABLE IF NOT EXISTS risk_hedgePair ("
            "modelKind INTEGER, mOrderId INTEGER, mOrderStatus INTEGER, "
            "hModelKind INTEGER, hOrderId INTEGER, hOrderStatus INTEGER);";

         string protectSql=
            "CREATE TABLE IF NOT EXISTS protect_hedgePair ("
            "modelKind INTEGER, mOrderId INTEGER, mOrderStatus INTEGER, "
            "hModelKind INTEGER, hOrderId INTEGER, hOrderStatus INTEGER);";

         if(!DatabaseExecute(h,riskSql)) return false;
         if(!DatabaseExecute(h,protectSql)) return false;
         return true;
      }

      //+------------------------------------------------------------------+
      //|  更新风险表中的对冲字段
      //|  @node          数据库节点类型
      //|  @modelKind     策略模型类型
      //|  @mOrderId      主单编号
      //|  @hModelKind    对冲模型类型
      //|  @hOrderId      对冲单编号
      //|  @hOrderStatus  对冲单状态
      //+------------------------------------------------------------------+
      bool UpdateRiskHedgeFields(EDbNode node, int modelKind, long mOrderId,
                                 int hModelKind, long hOrderId, int hOrderStatus){
         int h=GetHandle(node);
         if(h==INVALID_HANDLE) return false;

         string sql="UPDATE risk_hedgePair SET "
                    "hModelKind="+IntegerToString(hModelKind)+","
                    "hOrderId="+(string)hOrderId+","
                    "hOrderStatus="+IntegerToString(hOrderStatus)+
                    " WHERE modelKind="+IntegerToString(modelKind)+
                    " AND mOrderId="+(string)mOrderId+";";

         return DatabaseExecute(h,sql);
      }

      //+------------------------------------------------------------------+
      //|  将风险单数据写入或覆盖保护表记录
      //|  @node          数据库节点类型
      //|  @modelKind     策略模型类型
      //|  @mOrderId      主单编号
      //|  @mOrderStatus  主单状态
      //+------------------------------------------------------------------+
      bool UpsertProtectFromRisk(EDbNode node, int modelKind, long mOrderId, int mOrderStatus){
         int h=GetHandle(node);
         if(h==INVALID_HANDLE) return false;

         string delSql="DELETE FROM protect_hedgePair WHERE modelKind="+IntegerToString(modelKind)+
                       " AND mOrderId="+(string)mOrderId+";";
         if(!DatabaseExecute(h,delSql)) return false;

         string insSql="INSERT INTO protect_hedgePair (modelKind,mOrderId,mOrderStatus,hModelKind,hOrderId,hOrderStatus) VALUES ("+
                       IntegerToString(modelKind)+","+(string)mOrderId+","+IntegerToString(mOrderStatus)+",0,0,0);";
         return DatabaseExecute(h,insSql);
      }

      //+------------------------------------------------------------------+
      //|  清空保护表中的对冲字段
      //|  @node       数据库节点类型
      //|  @modelKind  策略模型类型
      //|  @mOrderId   主单编号
      //+------------------------------------------------------------------+
      bool ClearProtectHedgeFields(EDbNode node, int modelKind, long mOrderId){
         int h=GetHandle(node);
         if(h==INVALID_HANDLE) return false;

         string sql="UPDATE protect_hedgePair SET hModelKind=0,hOrderId=0,hOrderStatus=0"
                    " WHERE modelKind="+IntegerToString(modelKind)+" AND mOrderId="+(string)mOrderId+";";
         return DatabaseExecute(h,sql);
      }
};
