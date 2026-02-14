//+------------------------------------------------------------------+
//|                                               CRiskPairInput.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>

#include "..\..\client\CClientCtl.mqh"
#include "..\..\share\CShareCtl.mqh"

class CRiskPairInput
  {
   private:
        int                            modelKind;
        CHashMap<ulong,CHedgePair*>*   hedgePairSet; 
        CArrayList<ulong>*             hedgePairIds;
        //share control data
        CShareCtl* shareCtl; // [cite: 61]
   public:
                            CRiskPairInput(); // [cite: 62]
                           ~CRiskPairInput(); // [cite: 63]
         void               init(CShareCtl* shareCtl); // [cite: 63]
         void               inputRiskPairs(); // [cite: 64]
  };

//+------------------------------------------------------------------+
//|  初始化类
//+------------------------------------------------------------------+
void CRiskPairInput::init(CShareCtl* shareCtl)
{
   this.shareCtl = shareCtl; // [cite: 65]
   this.modelKind=this.shareCtl.getModelKind();
   this.hedgePairSet=shareCtl.getHedgeShare().getRiskHedgePair().getHedgePairSet();
   this.hedgePairIds=shareCtl.getHedgeShare().getRiskHedgePair().getHedgePairIds();
}

//+------------------------------------------------------------------+
//| 从 HedgePairList 获取数据并更新内部结构
//+------------------------------------------------------------------+
void CRiskPairInput::inputRiskPairs()
{
    // 获取数据库连接 (参考 CRiskPairOutput 逻辑)
    CDatabase* db = this.shareCtl.getClientCtl().getDB(); // [cite: 66]
    int conn = db.getConnect(); // [cite: 66]

    if(conn == INVALID_HANDLE) // [cite: 67]
    {
        Print("数据库打开失败");
        return;
    }

    CDatabaseInfo* dbInfo=this.shareCtl.getClientShare().getDbInfo();
    dbInfo.clearRiskDbKeyList();

    // 1.1 构建 SQL：筛选符合 modelKind 的数据 [cite: 87]
    string sql = "SELECT mOrderId, mOrderStatus, hOrderId, hOrderStatus "
                 "FROM HedgePairList "
                 "WHERE modelKind = " + IntegerToString(this.shareCtl.getModelKind()) + ";";

    // 使用 MQL5 原生数据库函数准备查询 
    int req = DatabasePrepare(conn, sql);
    if(req == INVALID_HANDLE)
    {
        Print("SQL准备失败: ", GetLastError());
        return;
    }

    // 2. 遍历记录集 
    while(DatabaseRead(req))
    {
        long mId, hId;
        int mStatus, hStatus;

        // 从列中提取数据 
        DatabaseColumnLong(req, 0, mId);     // mOrderId
        DatabaseColumnInteger(req, 1, mStatus);  // mOrderStatus
        DatabaseColumnLong(req, 2, hId);     // hOrderId
        DatabaseColumnInteger(req, 3, hStatus);  // hOrderStatus

        ulong mOrderId = (ulong)mId;
        dbInfo.addRiskDbKey(mOrderId);
        
        CHedgePair* pair = NULL;

        // 2.1 & 2.2 判断 mOrderId 是否已存在于 hash 变量中 [cite: 72]
        if(this.hedgePairSet.TryGetValue(mOrderId, pair)) // 使用标准 TryGetValue 
        {
            if(CheckPointer(pair) != POINTER_INVALID)
            {
                // 更新该行数据的对冲信息 [cite: 73, 74]
                pair.setHedgeOrderId((ulong)hId);
                pair.setHedgeOrderStatus(hStatus);
                pair.setMainOrderStatus(mStatus);
            }
        }
        else
        {
            // 2.3 不匹配，新增 CHedgePair 元素 [cite: 74]
            pair = new CHedgePair();
            pair.setMainOrderId(mOrderId); // [cite: 75]
            pair.setMainOrderStatus(mStatus);
            pair.setHedgeOrderId((ulong)hId);
            pair.setHedgeOrderStatus(hStatus);

            // 插入新的元素到 hash 和 ID 列表 [cite: 75]
            this.hedgePairSet.Add(mOrderId, pair);
            this.hedgePairIds.Add(mOrderId);
        }
    }

    // 释放查询句柄 [cite: 92]
    DatabaseFinalize(req);
    //Print("RiskPairs 输入完成");
}

//+------------------------------------------------------------------+
//| 构造与析构
//+------------------------------------------------------------------+
CRiskPairInput::CRiskPairInput(){}
CRiskPairInput::~CRiskPairInput(){}