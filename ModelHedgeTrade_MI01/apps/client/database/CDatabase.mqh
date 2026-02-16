//+------------------------------------------------------------------+
//|                                                   CDatabase.mqh  |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../header/database/CHeader.mqh"

class CDatabase
  {
private:
     int      dbConnect;
public:
                     CDatabase();
                    ~CDatabase();
     void            init();
     void            saveData(string tableName, string dataList);
     int             getConnect(){return this.dbConnect;}
  };

void CDatabase::init(){
    this.dbConnect = DatabaseOpen(DEBUG_DB_NAME, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
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

void CDatabase::saveData(string tableName, string dataList) {
    string checkTableSql = "SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';";
    int request = DatabasePrepare(this.dbConnect, checkTableSql);
    bool tableExists = false;

    if (request != INVALID_HANDLE) {
        if (DatabaseRead(request)) {
            tableExists = true;
        }
        DatabaseFinalize(request);
    }

    if (!tableExists) {
        string fieldsSql = "";
        int pos = 0;
        while (pos < StringLen(dataList)) {
            int start = StringFind(dataList, "<", pos);
            if (start == -1) break;

            int end = StringFind(dataList, ">", start);
            if (end == -1) break;

            string fieldDef = StringSubstr(dataList, start + 1, end - start - 1);
            string fieldName = "";
            string fieldType = "";

            if (StringFind(fieldDef, "_i") != -1) {
                fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_i"));
                fieldType = "INTEGER";
            } else if (StringFind(fieldDef, "_d") != -1) {
                fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_d"));
                fieldType = "NUMERIC";
            } else if (StringFind(fieldDef, "_t") != -1) {
                fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_t"));
                fieldType = "TEXT";
            }

            if (fieldName != "" && fieldType != "") {
                if (fieldsSql != "") fieldsSql += ", ";
                fieldsSql += fieldName + " " + fieldType;
            }

            pos = end + 1;
        }

        string createTableSql = "CREATE TABLE " + tableName + " (" + fieldsSql + ");";
        if (!DatabaseExecute(this.dbConnect, createTableSql)) {
            Print("Create table failed: ", GetLastError());
            DatabaseClose(this.dbConnect);
            return;
        }
        Print("Table created: ", tableName);
    }

    string insertSql = "INSERT INTO " + tableName + " (";
    string valuesSql = "VALUES (";

    int pos = 0;
    while (pos < StringLen(dataList)) {
        int start = StringFind(dataList, "<", pos);
        if (start == -1) break;

        int end = StringFind(dataList, ">", start);
        if (end == -1) break;

        string fieldDef = StringSubstr(dataList, start + 1, end - start - 1);
        string fieldName = "";

        if (StringFind(fieldDef, "_i") != -1) {
            fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_i"));
        } else if (StringFind(fieldDef, "_d") != -1) {
            fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_d"));
        } else if (StringFind(fieldDef, "_t") != -1) {
            fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_t"));
        }

        if (fieldName != "") {
            if (insertSql != "INSERT INTO " + tableName + " (") insertSql += ", ";
            insertSql += fieldName;

            int valueStart = end + 1;
            int valueEnd = StringFind(dataList, "<", valueStart);
            if (valueEnd == -1) valueEnd = StringLen(dataList);

            string fieldValue = StringSubstr(dataList, valueStart, valueEnd - valueStart);
            if (valuesSql != "VALUES (") valuesSql += ", ";

            if (StringFind(fieldDef, "_t") != -1) {
               valuesSql += "'" + fieldValue + "'";
            } else {
               valuesSql += fieldValue;
            }
        }

        pos = end + 1;
    }

    insertSql += ") " + valuesSql + ");";

    if (!DatabaseExecute(this.dbConnect, insertSql)) {
        Print("Insert data failed: ", GetLastError());
        DatabaseClose(this.dbConnect);
        return;
    }
    Print("Data inserted successfully.");
}

CDatabase::CDatabase(){}
CDatabase::~CDatabase(){
    DatabaseClose(this.dbConnect);
    Print("Database operation completed.");
}
