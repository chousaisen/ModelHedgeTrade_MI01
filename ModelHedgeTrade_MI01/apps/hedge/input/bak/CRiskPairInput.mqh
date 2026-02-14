//+------------------------------------------------------------------+
//|                                                 CRiskPairInput.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>

#include "..\..\header\lib\CHeader.mqh"
#include "..\..\client\CClientCtl.mqh"
#include "..\..\share\CShareCtl.mqh"

class CRiskPairInput
  {
   private:
         
        int                           modelKind;
        CHashMap<ulong,CHedgePair*>   hedgePairSet;
        CArrayList<ulong>             hedgePairIds;       //keys--orderIndex 
        
        CShareCtl*                    shareCtl;        
   public:
                            CRiskPairInput();
                            ~CRiskPairInput();
         //--- methods of initilize
         void               init(CShareCtl*   shareCtl);         
         
         //--- input risk pairs
         void               inputRiskPairs();    
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CRiskPairInput::init(CShareCtl*  shareCtl)
{
   this.modelKind=10001;
   this.shareCtl=shareCtl;
}

//+------------------------------------------------------------------+
//| HedgePairList からデータを取得し内部構造を更新
//+------------------------------------------------------------------+
void CRiskPairInput::inputRiskPairs()
{
    CDatabase* db = this.shareCtl.getClientCtl().getDB();
    int conn = db.getConnect();
    
    if(conn == INVALID_HANDLE){
        Print("データベースオープン失敗");
        return;
    }

   // SQL作成
   string sql;
   sql = "SELECT mOrderId, hOrderId, hOrderStatus "
         "FROM HedgePairList "
         "WHERE modelKind = " + IntegerToString(this.modelKind);

   CRecordSet* rs = shareCtl.getClientCtl().executeQuery(sql);
   if(rs == NULL)
      return(false);

   // レコード走査
   while(rs.next())
   {
      ulong  mOrderId     = (ulong)rs.getULong("mOrderId");
      ulong  hOrderId     = (ulong)rs.getULong("hOrderId");
      int    hOrderStatus = rs.getInt("hOrderStatus");

      // -------------------------------------------------
      // 2.1 mOrderId が hedgePairSet に存在するか？
      // -------------------------------------------------
      if(hedgePairSet.containsKey(mOrderId))
      {
         // 2.2 既存要素を更新
         CHedgePair* pair = hedgePairSet.get(mOrderId);
         if(pair != NULL)
         {
            pair.setHOrderId(hOrderId);
            pair.setHOrderStatus(hOrderStatus);
         }
      }
      else
      {
         // 2.3 新規追加
         CHedgePair* pair = new CHedgePair();
         pair.setMOrderId(mOrderId);
         pair.setHOrderId(hOrderId);
         pair.setHOrderStatus(hOrderStatus);

         hedgePairSet.put(mOrderId, pair);
         hedgePairIds.add(mOrderId);
      }
   }

   rs.close();
   delete rs;

   return(true);
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CRiskPairInput::CRiskPairInput(){}
CRiskPairInput::~CRiskPairInput(){}