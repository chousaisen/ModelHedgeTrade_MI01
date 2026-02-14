//+------------------------------------------------------------------+
//|                                                   CDatabase.mqh |
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
     //--- methods of initilize
     void            init(); 
     //--- save CDatabase
     void            saveData(string tableName, string dataList);
     //--- get database connect
     int             getConnect(){return this.dbConnect;}
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CDatabase::init(){
    // 1. 打开或创建数据库文件
    this.dbConnect = DatabaseOpen(DEBUG_DB_NAME, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
    if (this.dbConnect == INVALID_HANDLE) {
        Print("无法打开或创建数据库文件");
        return;
    }   
}
//+------------------------------------------------------------------+
//|  save data to database
//+------------------------------------------------------------------+
void CDatabase::saveData(string tableName, string dataList) {
    
    //if(!DEBUG_DB_SAVE)return;
    
    //tableName+=DEBUG_DB_TABLE_IDX;
    /*
    // 1. 打开或创建数据库文件
    int db = DatabaseOpen("data.sqlite", DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
    if (this.dbConnect == INVALID_HANDLE) {
        Print("无法打开或创建数据库文件");
        return;
    }*/

    // 2. 检查表是否存在
    string checkTableSql = "SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';";
    int request = DatabasePrepare(this.dbConnect, checkTableSql);
    bool tableExists = false;

    if (request != INVALID_HANDLE) {
        if (DatabaseRead(request)) {
            tableExists = true; // 表存在
        }
        DatabaseFinalize(request); // 释放查询句柄
    }

    // 3. 如果表不存在，创建表
    if (!tableExists) {
        // 解析字段名和类型
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

            // 解析字段名和类型
            if (StringFind(fieldDef, "_i") != -1) {
                fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_i"));
                fieldType = "INTEGER";
            } else if (StringFind(fieldDef, "_d") != -1) {
                fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_d"));
                fieldType = "NUMERIC";
            }else if (StringFind(fieldDef, "_t") != -1) {
                fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_t"));
                fieldType = "TEXT";
            }

            if (fieldName != "" && fieldType != "") {
                if (fieldsSql != "") fieldsSql += ", ";
                fieldsSql += fieldName + " " + fieldType;
            }

            pos = end + 1;
        }

        // 构建创建表的 SQL 语句
        string createTableSql = "CREATE TABLE " + tableName + " (" + fieldsSql + ");";
        if (!DatabaseExecute(this.dbConnect, createTableSql)) {
            Print("创建表失败: ", GetLastError());
            DatabaseClose(this.dbConnect);
            return;
        }
        Print("表 ", tableName, " 创建成功。");
    }

    // 4. 插入数据
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

        // 解析字段名
        if (StringFind(fieldDef, "_i") != -1) {
            fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_i"));
        } else if (StringFind(fieldDef, "_d") != -1) {
            fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_d"));
        }else if (StringFind(fieldDef, "_t") != -1) {
            fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_t"));
        }

        if (fieldName != "") {
            if (insertSql != "INSERT INTO " + tableName + " (") insertSql += ", ";
            insertSql += fieldName;

            // 解析字段值
            int valueStart = end + 1;
            int valueEnd = StringFind(dataList, "<", valueStart);
            if (valueEnd == -1) valueEnd = StringLen(dataList);

            string fieldValue = StringSubstr(dataList, valueStart, valueEnd - valueStart);
            if (valuesSql != "VALUES (") valuesSql += ", ";
            
            if (StringFind(fieldDef, "_t") != -1) {
               valuesSql += "'" + fieldValue + "'";
            }else{
               valuesSql += fieldValue;
            }                                    
        }

        pos = end + 1;
    }

    insertSql += ") " + valuesSql + ");";

    // 执行插入操作
    if (!DatabaseExecute(this.dbConnect, insertSql)) {
        Print("插入数据失败: ", GetLastError());
        DatabaseClose(this.dbConnect);
        return;
    }
    Print("数据插入成功。");

    // 5. 关闭数据库连接
    //DatabaseClose(this.dbConnect);
}  
   
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CDatabase::CDatabase(){}
CDatabase::~CDatabase(){
    // 5. 关闭数据库连接
    DatabaseClose(this.dbConnect);
    Print("数据库操作完成。");
}
