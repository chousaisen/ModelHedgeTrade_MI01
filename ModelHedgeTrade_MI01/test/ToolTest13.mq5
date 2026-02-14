//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   //DbTest();
   
   saveData("test1","<slopeIndex_i>1<SlopePips_i>100<WaveCount_i>3<returnMaxPips_i>10<returnMaxRate_D>10.2<beginLine_D>10.2");
   saveData("test1","<slopeIndex_i>1<SlopePips_i>100<WaveCount_i>3<returnMaxPips_i>10<returnMaxRate_D>10.2<beginLine_D>10.2");
   saveData("test1","<slopeIndex_i>1<SlopePips_i>100<WaveCount_i>3<returnMaxPips_i>10<returnMaxRate_D>10.2<beginLine_D>10.2");
   saveData("test1","<slopeIndex_i>1<SlopePips_i>100<WaveCount_i>3<returnMaxPips_i>10<returnMaxRate_D>10.2<beginLine_D>10.2");
   saveData("test1","<slopeIndex_i>1<SlopePips_i>100<WaveCount_i>3<returnMaxPips_i>10<returnMaxRate_D>10.2<beginLine_D>10.2");
   saveData("test1","<slopeIndex_i>1<SlopePips_i>100<WaveCount_i>3<returnMaxPips_i>10<returnMaxRate_D>10.2<beginLine_D>10.2");
   saveData("test1","<slopeIndex_i>1<SlopePips_i>100<WaveCount_i>3<returnMaxPips_i>10<returnMaxRate_D>10.2<beginLine_D>10.2");
   
   // 设置EA或初始化时输出一条信息
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Main Program Entry Point                                         |
//+------------------------------------------------------------------+
void OnTick()
{
}
//+------------------------------------------------------------------+
//| Main Program Entry Point                                         |
//+------------------------------------------------------------------+
void DbTest()
{
    // 1. 打开或创建数据库文件
    int db = DatabaseOpen("test.sqlite", DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
    if (db == INVALID_HANDLE) {
        Print("无法打开或创建数据库文件");
        return;
    }

    // 2. 创建表
    string sql = "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER);";
    if (!DatabaseExecute(db, sql)) {
        Print("创建表失败: ", GetLastError());
        DatabaseClose(db);
        return;
    }

    // 3. 插入数据
    sql = "INSERT INTO users (name, age) VALUES ('Alice', 30);";
    if (!DatabaseExecute(db, sql)) {
        Print("插入数据失败: ", GetLastError());
        DatabaseClose(db);
        return;
    }

    // 4. 查询数据
    sql = "SELECT * FROM users;";
    int stmt = DatabasePrepare(db, sql);
    if (stmt == INVALID_HANDLE) {
        Print("准备查询失败: ", GetLastError());
        DatabaseClose(db);
        return;
    }
      
    // 读取查询结果
    /*
    while (DatabaseRead(stmt)) {
        int id = DatabaseGetInteger(stmt, 0); // 获取第 1 列（id）
        string name = DatabaseGetText(stmt, 1); // 获取第 2 列（name）
        int age = DatabaseGetInteger(stmt, 2); // 获取第 3 列（age）
        Print("id: ", id, ", name: ", name, ", age: ", age);
    }*/

    // 5. 关闭数据库连接
    DatabaseClose(db);
    Print("数据库操作完成。");
}

// 函数：saveData
void saveData(string tableName, string dataList) {
    // 1. 打开或创建数据库文件
    int db = DatabaseOpen("data.sqlite", DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE);
    if (db == INVALID_HANDLE) {
        Print("无法打开或创建数据库文件");
        return;
    }

    // 2. 检查表是否存在
    string checkTableSql = "SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';";
    int request = DatabasePrepare(db, checkTableSql);
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
            } else if (StringFind(fieldDef, "_D") != -1) {
                fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_D"));
                fieldType = "REAL";
            }

            if (fieldName != "" && fieldType != "") {
                if (fieldsSql != "") fieldsSql += ", ";
                fieldsSql += fieldName + " " + fieldType;
            }

            pos = end + 1;
        }

        // 构建创建表的 SQL 语句
        string createTableSql = "CREATE TABLE " + tableName + " (" + fieldsSql + ");";
        if (!DatabaseExecute(db, createTableSql)) {
            Print("创建表失败: ", GetLastError());
            DatabaseClose(db);
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
        } else if (StringFind(fieldDef, "_D") != -1) {
            fieldName = StringSubstr(fieldDef, 0, StringFind(fieldDef, "_D"));
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
            valuesSql += fieldValue;
        }

        pos = end + 1;
    }

    insertSql += ") " + valuesSql + ");";

    // 执行插入操作
    if (!DatabaseExecute(db, insertSql)) {
        Print("插入数据失败: ", GetLastError());
        DatabaseClose(db);
        return;
    }
    Print("数据插入成功。");

    // 5. 关闭数据库连接
    DatabaseClose(db);
}