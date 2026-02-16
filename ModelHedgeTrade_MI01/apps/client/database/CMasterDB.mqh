//+------------------------------------------------------------------+
//|                                                   CMasterDB.mqh  |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../header/database/CHeader.mqh"

class CMasterDB
  {
private:
     string   dbName;
     int      dbConnect;
public:
                     CMasterDB();
                    ~CMasterDB();
     void            init();
     int             getConnect(){return this.dbConnect;}
  };

void CMasterDB::init(){
    this.dbName="master_01";
    this.dbConnect = DatabaseOpen(this.dbName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
    if (this.dbConnect != INVALID_HANDLE) {
        DatabaseExecute(this.dbConnect, "PRAGMA journal_mode=WAL;");
        DatabaseExecute(this.dbConnect, "PRAGMA synchronous=NORMAL;");
        DatabaseExecute(this.dbConnect, "PRAGMA busy_timeout=3000;");
    }
    if (this.dbConnect == INVALID_HANDLE) {
        Print("Failed to open or create database file");
        return;
    }
}

CMasterDB::CMasterDB(){}
CMasterDB::~CMasterDB(){
    DatabaseClose(this.dbConnect);
    Print("Database operation completed.");
}
