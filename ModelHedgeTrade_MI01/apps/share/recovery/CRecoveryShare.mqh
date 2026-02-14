//+------------------------------------------------------------------+
//|                                           CRecoveryShare.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>

#include "..\..\client\database\CDatabase.mqh"
#include "..\..\comm\ComFunc.mqh"
#include "..\..\comm\ComFunc2.mqh"
#include "analysis\CRangeRe.mqh"

class CRecoveryShare{
   private: 
            datetime                      curRangeTime;
            CRangeRe*                     curRangeRe;
            CArrayList<datetime>          rangeChangeTime;
            CHashMap<datetime,CRangeRe*>  rangeMap; 
            //int                           runnerCount;
            //recovery database
            CDatabase*                    database;
            //account info
            int                           accountNo;
   public:            
                                          CRecoveryShare();
                                          ~CRecoveryShare();                                          
            void                          setRecoveryDB(CDatabase* db){this.database=db;}
            void                          setAccountNo(int value){this.accountNo=value;}
            //int                           getRunnerCount(){return this.runnerCount;}
            //void                          setRunnerCount(int value){this.runnerCount=value;}
            //void                          addRunnerCount(){this.runnerCount++;}
            CRangeRe*                     makeRangeRe(datetime changeTime);
            CRangeRe*                     getCurRangeRe(datetime changeTime);
            CRangeRe*                     getCurRangeRe();
            void                          saveCurRangeRe();
            void                          clearRangeReData();
            void                          loadRangeInfo();
            void                          loadRangeInfo(CModelI* model);
};

//+------------------------------------------------------------------+
//|  make Range recovery data  
//+------------------------------------------------------------------+
CRangeRe* CRecoveryShare::makeRangeRe(datetime changeTime){   
   this.curRangeRe=new CRangeRe();
   this.curRangeTime=changeTime;
   this.rangeMap.Add(changeTime,curRangeRe);
   this.rangeChangeTime.Add(changeTime);
   return this.curRangeRe;
}

//+------------------------------------------------------------------+
//|  get current Range recovery data  
//+------------------------------------------------------------------+
CRangeRe* CRecoveryShare::getCurRangeRe(datetime changeTime){
   
   CRangeRe* rangeRe;
   int rangeCount=this.rangeChangeTime.Count();
   //get current change time
   for (int i = rangeCount-1; i >=0 ; i--) {
      datetime curDateTime;
      if(this.rangeChangeTime.TryGetValue(i,curDateTime)){
        if(curDateTime<=changeTime){           
           if(this.rangeMap.ContainsKey(curDateTime)){
             this.rangeMap.TryGetValue(curDateTime,rangeRe);                             
           }
           break;
        }
      }
   }   
   if(CheckPointer(rangeRe)==POINTER_INVALID)return NULL;    
   return rangeRe;
}

//+------------------------------------------------------------------+
//|  get current Range recovery data  
//+------------------------------------------------------------------+
CRangeRe* CRecoveryShare::getCurRangeRe(){
   
   CRangeRe* rangeRe; 
   this.rangeMap.TryGetValue(this.curRangeTime,rangeRe);
   if(CheckPointer(rangeRe)==POINTER_INVALID)return NULL;    
   return rangeRe;
}

//+------------------------------------------------------------------+
//| save range recovery
//+------------------------------------------------------------------+
void CRecoveryShare::saveCurRangeRe(){
   
   string tableName="RangeRe_" + this.accountNo; 
   string saveSql="<StatusIndex_i>" + this.curRangeRe.getStatusIndex()
                     + "<StatusStartTime_t>" + comFunc.getDate_YYYYMMDDHHMMSS(this.curRangeRe.getStatusStartTime())
                     + "<StatusFlg_i>" + this.curRangeRe.getStatusFlg()
                     + "<StatusDetailFlg_i>" + this.curRangeRe.getStatusDetailFlg()
                     + "<UpperBreakLine_d>" + this.curRangeRe.getUpperBreakLine()
                     + "<DownBreakLine_d>" + this.curRangeRe.getDownBreakLine();
                     
   this.database.saveData(tableName,saveSql);                     
}

//+------------------------------------------------------------------+
//| load range info from recovery
//+------------------------------------------------------------------+
void CRecoveryShare::loadRangeInfo(){

   string tableName="RangeRe_" + this.accountNo;
   string selectSql="select StatusIndex,StatusStartTime,StatusFlg,StatusDetailFlg,UpperBreakLine,DownBreakLine from " 
                  + tableName + " order by StatusIndex";                     
   
   int request = DatabasePrepare(this.database.getConnect(), selectSql);
    if (request == INVALID_HANDLE)
    {
        Print("SQL error, code:", GetLastError());
        DatabaseClose(this.database.getConnect());
        return;
    }

    // read request
    while (DatabaseRead(request)){
         
         int                    statusIndex;
         string                 statusStartTime;
         int                    statusFlg;         
         int                    statusDetailFlg;
         double                 upperBreakLine;
         double                 downBreakLine;                
         
         // 获取每列的值
         if (!DatabaseColumnInteger(request, 0, statusIndex) ||
            !DatabaseColumnText(request, 1, statusStartTime) ||
            !DatabaseColumnInteger(request, 2, statusFlg) ||
            !DatabaseColumnInteger(request, 3, statusDetailFlg) ||
            !DatabaseColumnDouble(request, 4, upperBreakLine) ||
            !DatabaseColumnDouble(request, 5, downBreakLine)){
               Print("database read error, code:", GetLastError());
               break;
         }

         datetime curStatusChangeTime=comFunc.getDate_YYYYMMDDHHMMSS(statusStartTime);

         CRangeRe* curRangeRe=new CRangeRe();
         curRangeRe.setStatusIndex(statusIndex);
         curRangeRe.setStatusStartTime(curStatusChangeTime);
         curRangeRe.setStatusFlg(statusFlg);
         curRangeRe.setStatusDetailFlg(statusDetailFlg);
         curRangeRe.setUpperBreakLine(upperBreakLine);
         curRangeRe.setDownBreakLine(downBreakLine);         

         this.rangeMap.Add(curStatusChangeTime,curRangeRe);
         this.rangeChangeTime.Add(curStatusChangeTime);
         this.curRangeTime=curStatusChangeTime;
         // 输出读取的数据
         //PrintFormat("ID: %d, Name: %s, Age: %d", id, name, age);
    }

    // release request handle
    DatabaseFinalize(request);   
}

//+------------------------------------------------------------------+
//| Clear all records from a specified table in the SQLite database  |
//+------------------------------------------------------------------+
void CRecoveryShare::clearRangeReData()
{
    string tableName="RangeRe_" + this.accountNo;   
    string saveSql="<StatusIndex_i>0"
                     + "<StatusStartTime_t>0"
                     + "<StatusFlg_i>0"
                     + "<StatusDetailFlg_i>0"
                     + "<UpperBreakLine_d>0"
                     + "<DownBreakLine_d>0";
    this.database.saveData(tableName,saveSql);
    
    // Construct the SQL statement to delete all records from the table
    string clearSql = "DELETE FROM " + tableName + ";";

    // Execute the delete operation
    if (!DatabaseExecute(this.database.getConnect(), clearSql))
    {
        PrintFormat("Failed to delete data from table '%s'. Error code: %d", tableName, GetLastError());
        return;
    }

    //PrintFormat("All records from table '%s' have been successfully deleted.", table_name);
    // Close the database connection
    //DatabaseClose(db);
}

//+------------------------------------------------------------------+
//| load model range info from recovery
//+------------------------------------------------------------------+
void CRecoveryShare::loadRangeInfo(CModelI* model){

   datetime startTime=model.getStartTime();   
   CRangeRe* rangeRe=this.getCurRangeRe(startTime);
   if(CheckPointer(rangeRe)!=POINTER_INVALID){
      model.setStatusIndex(rangeRe.getStatusIndex());
      model.setStatusFlg(rangeRe.getStatusFlg());
   }

   datetime tradeTime=model.getTradeTime();
   CRangeRe* lastRangeRe=this.getCurRangeRe(tradeTime);
   if(CheckPointer(lastRangeRe)!=POINTER_INVALID){
      model.setLastStatusIndex(lastRangeRe.getStatusIndex());
      model.setLastStatusFlg(lastRangeRe.getStatusFlg());
   }
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CRecoveryShare::CRecoveryShare(){   
   this.accountNo=AccountInfoInteger(ACCOUNT_LOGIN);
}
CRecoveryShare::~CRecoveryShare(){}