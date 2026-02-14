//+------------------------------------------------------------------+
//|                                                 CRiskPairOutput.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "..\..\client\CClientCtl.mqh"
#include "..\..\share\CShareCtl.mqh"

class CRiskPairOutput
  {
private:
     int                            modelKind;
     CHashMap<ulong,CHedgePair*>*   hedgePairSet; 
     CArrayList<ulong>*             hedgePairIds;
     //share control data
     CShareCtl*         shareCtl;
public:
                     CRiskPairOutput();
                    ~CRiskPairOutput();
     //--- methods of initilize
     void            init(CShareCtl*   shareCtl);
     //--- out put risk pairs
     void            outRiskPairs();
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CRiskPairOutput::init(CShareCtl*  shareCtl){
   this.shareCtl=shareCtl;  
   this.modelKind=this.shareCtl.getModelKind();
   this.hedgePairSet=shareCtl.getHedgeShare().getRiskHedgePair().getHedgePairSet();
   this.hedgePairIds=shareCtl.getHedgeShare().getRiskHedgePair().getHedgePairIds();    
}

//+------------------------------------------------------------------+
//| out put risk pair
//+------------------------------------------------------------------+
void CRiskPairOutput::outRiskPairs(){
    
    CDatabase* db = this.shareCtl.getClientCtl().getDB();
    int conn = db.getConnect();
    
    if(conn == INVALID_HANDLE){
        Print("データベースオープン失敗");
        return;
    }

    string tableName = "HedgePairList";
    //=========================================================
    // 2. データベースから現在の modelKind の全行を取得
    //=========================================================
    string selectSql =
        "SELECT mOrderId, mOrderStatus, hOrderId, hOrderStatus "
        "FROM " + tableName + " WHERE modelKind=" + IntegerToString(this.shareCtl.getModelKind()) + ";";
    
    int req = DatabasePrepare(conn, selectSql);
    if(req == INVALID_HANDLE){
        Print("SQL準備失敗: ", GetLastError());
        return;
    }

    // DB内のレコードを保存するリスト
    CArrayList<ulong> dbOrderIdList;

    while(DatabaseRead(req)){
        // 【修正】DatabaseColumnLongは第3引数で値を受け取ります
        long val;
        if(DatabaseColumnLong(req, 0, val)){
             dbOrderIdList.Add((ulong)val);
        }
    }
    DatabaseFinalize(req);

    //=========================================================
    // トランザクション開始（大量データの処理を高速化）
    //=========================================================
    DatabaseTransactionBegin(conn);

    //=========================================================
    // 3. hedgePairSet をループして INSERT または UPDATE
    //=========================================================
    // 【修正】Total() ではなく Count() を使用
    for(int i = 0; i < this.hedgePairIds.Count(); i++)
    {
        // 【修正】At(i) ではなく TryGetValue を使用
        ulong key;
        if(!this.hedgePairIds.TryGetValue(i, key)) continue;

        // 【修正】Contains ではなく ContainsKey を推奨
        if(!hedgePairSet.ContainsKey(key)) continue;

        // 【修正】Get(key) ではなく TryGetValue を使用
        CHedgePair *hp = NULL;
        if(!this.hedgePairSet.TryGetValue(key, hp) || hp == NULL) continue;

        ulong mOrderId     = hp.getMainOrderId();
        int   mOrderStatus = hp.getMainOrderStatus();
        ulong hOrderId     = hp.getHedgeOrderId();
        int   hOrderStatus = hp.getHedgeOrderStatus();

        // 修正後：Containsメソッドを使用
        bool recordExists = dbOrderIdList.Contains(mOrderId);

        //=====================================================
        // INSERT 新規
        //=====================================================
        if(!recordExists){
            string insertSql =
                "INSERT INTO " + tableName +
                " (modelKind, mOrderId, mOrderStatus, hOrderId, hOrderStatus) " +
                "VALUES (" +
                IntegerToString(modelKind) + "," +
                (string)mOrderId + "," +
                IntegerToString(mOrderStatus) + "," +
                (string)hOrderId + "," +
                IntegerToString(hOrderStatus) + ");";
            
            if(!DatabaseExecute(conn, insertSql)){
                Print("INSERT失敗: ", GetLastError(), " SQL=", insertSql);
            }
        }
        //=====================================================
        // UPDATE 更新
        //=====================================================
        else{
            string updateSql =
                "UPDATE " + tableName +
                " SET mOrderStatus=" + IntegerToString(mOrderStatus) + ", " +
                "hOrderStatus=" + IntegerToString(hOrderStatus) +
                " WHERE modelKind=" + IntegerToString(modelKind) +
                " AND mOrderId=" + (string)mOrderId + ";";
            
            if(!DatabaseExecute(conn, updateSql)){
                Print("UPDATE失敗: ", GetLastError(), " SQL=", updateSql);
            }
        }
    }

    //=========================================================
    // 4. DBにはあるが hedgePairIds にはない行を削除
    //=========================================================
    for(int i = 0; i < dbOrderIdList.Count(); i++)
    {
        ulong dbOrderId;
        // 【修正】At(i) ではなく TryGetValue
        if(!dbOrderIdList.TryGetValue(i, dbOrderId)) continue;

        bool found = false;
        for(int k = 0; k < this.hedgePairIds.Count(); k++){
            ulong hId;
            // 【修正】At(k) ではなく TryGetValue
            if(this.hedgePairIds.TryGetValue(k, hId)){
                if(hId == dbOrderId){
                    found = true;
                    break;
                }
            }
        }

        // DELETE
        if(!found){
            string delSql =
                "DELETE FROM " + tableName +
                " WHERE modelKind=" + IntegerToString(modelKind) +
                " AND hOrderStatus=" + IntegerToString(HEDGE_ORDER_NONE) +
                //" AND hOrderStatus<>" + IntegerToString(HEDGE_ORDER_LOCK) +
                " AND mOrderId=" + (string)dbOrderId + ";";

            if(!DatabaseExecute(conn, delSql)){
                Print("DELETE失敗: ", GetLastError(), " SQL=", delSql);
            }else{
                Print("削除完了: mOrderId=", dbOrderId);
            }
        }
    }

    // トランザクションコミット
    if(!DatabaseTransactionCommit(conn)){
        Print("トランザクションコミット失敗: ", GetLastError());
    }

    //Print("outPutHedgePairs 処理完了");
}
   
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CRiskPairOutput::CRiskPairOutput(){}
CRiskPairOutput::~CRiskPairOutput(){}