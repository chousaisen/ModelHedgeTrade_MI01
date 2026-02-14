//+------------------------------------------------------------------+
//|                                                   CSlaveDB.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../header/database/CHeader.mqh"

class CSlaveDB
  {
private:
     string   dbName;
     int      dbConnect; 
public:
                     CSlaveDB();
                    ~CSlaveDB();
     //--- methods of initilize
     void            init(); 
     //--- get database connect
     int             getConnect(){return this.dbConnect;}
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CSlaveDB::init(){

    // 1. 打开或创建数据库文件
    this.dbConnect = DatabaseOpen(this.dbName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
    if (this.dbConnect == INVALID_HANDLE) {
        Print("无法打开或创建数据库文件");
        return;
    }
}
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSlaveDB::CSlaveDB(){}
CSlaveDB::~CSlaveDB(){
    // 5. 关闭数据库连接
    DatabaseClose(this.dbConnect);
    Print("数据库操作完成。");
}
