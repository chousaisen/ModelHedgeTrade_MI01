//+------------------------------------------------------------------+
//|                                                   CClientCtl.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "database\CDatabase.mqh"

class CClientCtl
  {
private:
      CDatabase      db;
public:
                     CClientCtl();
                    ~CClientCtl();
     //--- methods of initilize
     void            init(); 
     //--- get database
     CDatabase*      getDB();
     
     //--- create table
     void            initTables();
      
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CClientCtl::init(){
      this.db.init();
}

//+------------------------------------------------------------------+
//|  get database
//+------------------------------------------------------------------+
CDatabase* CClientCtl::getDB(){
   return &this.db;   
}

//+------------------------------------------------------------------+
//|  init tables
//+------------------------------------------------------------------+
void  CClientCtl::initTables(){

    int conn = this.db.getConnect();    
    if(conn == INVALID_HANDLE){
        Print("データベースオープン失敗");
        return;
    }

    string tableName = "HedgePairList";

    //=========================================================
    // 1. テーブルの存在確認と作成
    //=========================================================
    // MQL5標準関数 DatabaseTableExists を使用
    if(!DatabaseTableExists(conn, tableName)){
        string createSql =
            "CREATE TABLE " + tableName + " ("
            "modelKind INTEGER, "
            "mOrderId INTEGER, "      // SQLite INTEGER (up to 64-bit)
            "mOrderStatus INTEGER, "
            "hOrderId INTEGER, "
            "hOrderStatus INTEGER"
            ");";
        
        if(!DatabaseExecute(conn, createSql)){
            Print("テーブル作成失敗: ", GetLastError());
            return;
        }
        Print("表 HedgePairList 作成成功");
    }else{
      if(DB_DATA_RESET){
         string delSql ="DELETE FROM " + tableName + ";";
         if(!DatabaseExecute(conn, delSql)){
             Print("DB Reset失敗: ", GetLastError(), " SQL=", delSql);
         }else{
             Print("DB Reset削除完了!");
         }            
      }    
    }

}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CClientCtl::CClientCtl(){}
CClientCtl::~CClientCtl(){}
