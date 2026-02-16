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
     //+------------------------------------------------------------------+
     //|  构造函数
     //+------------------------------------------------------------------+
                     CDatabase();
     //+------------------------------------------------------------------+
     //|  析构函数
     //+------------------------------------------------------------------+
                    ~CDatabase();
     //+------------------------------------------------------------------+
     //|  初始化数据库连接
     //+------------------------------------------------------------------+
     void            init();
     //+------------------------------------------------------------------+
     //|  保存数据到数据库
     //|  @tableName    目标表名
     //|  @dataList     字段和数据列表
     //+------------------------------------------------------------------+
     void            saveData(string tableName, string dataList);
     //+------------------------------------------------------------------+
     //|  获取数据库连接句柄
     //+------------------------------------------------------------------+
     int             getConnect(){return this.dbConnect;}
  };

//+------------------------------------------------------------------+
//|  初始化数据库连接
//+------------------------------------------------------------------+
void CDatabase::init(){
    this.dbConnect = DatabaseOpen(DEBUG_DB_NAME, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
    if (this.dbConnect == INVALID_HANDLE) {
        Print("无法打开或创建数据库文件");
        return;
    }
}

//+------------------------------------------------------------------+
//|  保存数据到数据库
//|  @tableName    目标表名
//|  @dataList     字段和数据列表
//+------------------------------------------------------------------+
void CDatabase::saveData(string tableName, string dataList) {
    //if(!DEBUG_DB_SAVE)return;
    //tableName+=DEBUG_DB_TABLE_IDX;

    // 1. 检查表是否存在
    string checkTableSql = "SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';";
    int request = DatabasePrepare(this.dbConnect, checkTableSql);
    bool tableExists = false;

    if (request != INVALID_HANDLE) {
        if (DatabaseRead(request)) {
            tableExists = true;
        }
        DatabaseFinalize(request);
    }

    // 2. 如果表不存在，创建表
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
            Print("创建表失败: ", GetLastError());
            DatabaseClose(this.dbConnect);
            return;
        }
        Print("表 ", tableName, " 创建成功。");
    }

    // 3. 插入数据
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
        Print("插入数据失败: ", GetLastError());
        DatabaseClose(this.dbConnect);
        return;
    }
    Print("数据插入成功。");
}

//+------------------------------------------------------------------+
//|  构造函数
//+------------------------------------------------------------------+
CDatabase::CDatabase(){}

//+------------------------------------------------------------------+
//|  析构函数
//+------------------------------------------------------------------+
CDatabase::~CDatabase(){
    DatabaseClose(this.dbConnect);
    Print("数据库操作完成。");
}
