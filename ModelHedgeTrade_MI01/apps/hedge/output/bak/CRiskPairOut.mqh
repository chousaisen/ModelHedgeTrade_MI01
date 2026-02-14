//+------------------------------------------------------------------+
//|                                                 CRiskPairOut.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "..\..\header\lib\CHeader.mqh"
#include "..\..\client\CClientCtl.mqh"
#include "..\data\CHedgePair.mqh"

class CRiskPairOut
  {
private:
     CClientCtl*     clientCtl;
public:
                     CRiskPairOut();
                    ~CRiskPairOut();
     //--- methods of initilize
     void            init(); 
     //--- out put risk pairs
     void            outRiskPairs(int modelKind,
                                  CArrayList<ulong>*            hedgePairIds,
                                  CHashMap<ulong,CHedgePair*>*  hedgePairSet);
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CRiskPairOut::init(){
}


//+------------------------------------------------------------------+
//|  out put risk pair
//+------------------------------------------------------------------+
void CRiskPairOut::outRiskPairs(int modelKind,
                                 CArrayList<ulong>*   hedgePairIds,
                                 CHashMap<ulong,CHedgePair*>*  hedgePairSet){
    CDatabase* db=this.clientCtl.getDB();
    int conn = db.getConnect();
    if(conn == INVALID_HANDLE){
        Print("数据库打开失败");
        return;
    }

    string tableName = "HedgePairList";

    //=========================================================
    // 1. 确保表已经存在（如不存在则创建）
    //=========================================================
    string checkSql = "SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';";
    int req = DatabasePrepare(conn, checkSql);
    bool exists = false;
    if(req != INVALID_HANDLE){
        if(DatabaseRead(req)) exists = true;
        DatabaseFinalize(req);
    }

    if(!exists){
        string createSql =
            "CREATE TABLE " + tableName + " ("
            "modelKind INTEGER, "
            "mOrderId INTEGER, "
            "mOrderStatus INTEGER, "
            "hOrderId INTEGER, "
            "hOrderStatus INTEGER"
            ");";

        if(!DatabaseExecute(conn, createSql)){
            Print("创建表失败: ", GetLastError());
            return;
        }
        Print("表 HedgePairList 创建成功");
    }


    //=========================================================
    // 2. 读取数据库内当前 modelKind 的全部行
    //=========================================================
    string selectSql =
        "SELECT mOrderId, mOrderStatus, hOrderId, hOrderStatus "
        "FROM " + tableName + " WHERE modelKind=" + IntegerToString(modelKind) + ";";

    req = DatabasePrepare(conn, selectSql);

    // 用于存数据库内的记录
    CArrayList<ulong> dbOrderIdList;
    //dbOrderIdList.Create();

    while(req != INVALID_HANDLE && DatabaseRead(req)){
        //ulong db_mOrderId = (ulong)DatabaseGetInteger(req, 0);
        ulong db_mOrderId = (ulong)DatabaseColumnInteger(req, 0);
        dbOrderIdList.Add(db_mOrderId);
    }
    if(req != INVALID_HANDLE) DatabaseFinalize(req);


    //=========================================================
    // 3. 对 hedgePairSet 逐个检查：插入 OR 更新
    //=========================================================
    for(int i=0; i<hedgePairIds.Total(); i++)
    {
        ulong key = hedgePairIds.At(i);
        if(!hedgePairSet.Contains(key)) continue;

        CHedgePair *hp = hedgePairSet.Get(key);
        if(hp == NULL) continue;

        ulong mOrderId     = hp.getMainOrderId();
        int   mOrderStatus = hp.getMainOrderStatus();
        ulong hOrderId     = hp.getHedgeOrderId();
        int   hOrderStatus = hp.getHedgeOrderStatus();

        bool recordExists = false;
        for(int j=0;j<dbOrderIdList.Total();j++){
            if(dbOrderIdList.At(j) == mOrderId){
                recordExists = true;
                break;
            }
        }

        //=====================================================
        // INSERT 新行
        //=====================================================
        if(!recordExists){
            string insertSql =
                "INSERT INTO " + tableName +
                " (modelKind, mOrderId, mOrderStatus, hOrderId, hOrderStatus) VALUES (" +
                IntegerToString(modelKind) + "," +
                (string)mOrderId + "," +
                IntegerToString(mOrderStatus) + "," +
                (string)hOrderId + "," +
                IntegerToString(hOrderStatus) + ");";

            if(!DatabaseExecute(conn, insertSql)){
                Print("插入失败: ", GetLastError(), " SQL=", insertSql);
            }else{
                Print("插入新 hedgePair: mOrderId=", mOrderId);
            }
        }
        //=====================================================
        // UPDATE 已存在记录（只更新 status）
        //=====================================================
        else{
            string updateSql =
                "UPDATE " + tableName +
                " SET mOrderStatus=" + IntegerToString(mOrderStatus) + ", " +
                "hOrderStatus=" + IntegerToString(hOrderStatus) +
                " WHERE modelKind=" + IntegerToString(modelKind) +
                " AND mOrderId=" + (string)mOrderId + ";";

            if(!DatabaseExecute(conn, updateSql)){
                Print("更新失败: ", GetLastError(), " SQL=", updateSql);
            }else{
                Print("更新 hedgePair: mOrderId=", mOrderId);
            }
        }
    }


    //=========================================================
    // 4. 删除数据库中有但 hedgePairIds 中没有的行
    //=========================================================
    for(int i=0; i<dbOrderIdList.Total(); i++)
    {
        ulong dbOrderId = dbOrderIdList.At(i);

        bool found = false;
        for(int k=0; k<hedgePairIds.Total(); k++){
            if(hedgePairIds.At(k) == dbOrderId){
                found = true;
                break;
            }
        }

        // DELETE
        if(!found){
            string delSql =
                "DELETE FROM " + tableName +
                " WHERE modelKind=" + IntegerToString(modelKind) +
                " AND mOrderId=" + (string)dbOrderId + ";";

            if(!DatabaseExecute(conn, delSql)){
                Print("删除失败: ", GetLastError(), " SQL=", delSql);
            }else{
                Print("删除过期 hedgePair: mOrderId=", dbOrderId);
            }
        }
    }

    Print("outPutHedgePairs 处理完成");
}
   
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CRiskPairOut::CRiskPairOut(){}
CRiskPairOut::~CRiskPairOut(){}
