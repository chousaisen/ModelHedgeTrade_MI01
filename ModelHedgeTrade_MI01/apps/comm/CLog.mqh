//+------------------------------------------------------------------+
//|                                                     CommFunc.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "..\header\CHeader.mqh"
#include "..\header\symbol\CHeader.mqh"
#include "..\share\model\order\COrder.mqh"
#include "ComFunc.mqh"

class CLog
{
   private:
      datetime    refreshTime[10000];  // Array to store refresh times for logging
      int         preStatus[100];      // Array to store indicator status or trade status
      int         LOG_FILE;
      string      logFileName;
      datetime    beginTime;
      datetime    endTime;
      datetime    debugBeginTime;
      datetime    debugEndTime;      
      datetime    debugCheckTime;  
      bool        diffFlag;
      int         logOutPutCount;      
   public:
      // Constructor
      CLog();

      // Destructor
      ~CLog();          

      //+------------------------------------------------------------------+
      //| close diff
      //+------------------------------------------------------------------+
      void closeDiff(){
         this.diffFlag=false;
      }
      //+------------------------------------------------------------------+
      //| open diff
      //+------------------------------------------------------------------+
      void openDiff(){
         this.diffFlag=true;
         this.refreshTime[0] = TimeCurrent();
      }     
      
      //+------------------------------------------------------------------+
      //| Print comm log message 
      //+------------------------------------------------------------------+
      void printLog(string log)
      {
         writeLog(log,"comm"); 
      }      
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval                   |
      //+------------------------------------------------------------------+
      void printPeroidLog(string log)
      {
          datetime currentTime = TimeCurrent();
          int refreshDiffSeconds = currentTime - this.refreshTime[0];
          if(refreshDiffSeconds > Log_Diff_Seconds)
          {
             if(currentTime > this.beginTime && currentTime < this.endTime){
                  writeLog(log,"Peroid"); 
             }             
             if(this.diffFlag)this.refreshTime[0] = currentTime;
          }
      }       
            
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval                   |
      //+------------------------------------------------------------------+
      void printLog(int logIndex, int diffSeconds, string log)
      {
          datetime currentTime = TimeCurrent();
          int refreshDiffSeconds = currentTime - this.refreshTime[logIndex];
          if(refreshDiffSeconds > diffSeconds){
             if(currentTime > this.beginTime && currentTime < this.endTime){
                  writeLog(log); 
             }
             this.refreshTime[logIndex] = currentTime;
          }
      } 
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval                   |
      //+------------------------------------------------------------------+
      void printPeroidLog(int logIndex, int diffSeconds, string log)
      {
          datetime currentTime = TimeCurrent();
          int refreshDiffSeconds = currentTime - this.refreshTime[logIndex];
          if(refreshDiffSeconds > diffSeconds)
          {
             if(currentTime > this.beginTime
               && currentTime < this.endTime)
             {
                  writeLog(log,"01");
             }
             this.refreshTime[logIndex] = currentTime;
          }
      }
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval  
      //| and difine file index name
      //+------------------------------------------------------------------+      
      void printPeroidLog(string fileIndex,int logIndex, int diffSeconds, string log)
      {
          datetime currentTime = TimeCurrent();
          int refreshDiffSeconds = currentTime - this.refreshTime[logIndex];
          if(refreshDiffSeconds > diffSeconds)
          {
             if(currentTime > this.beginTime
               && currentTime < this.endTime)
             {
                  writeLog(log,fileIndex);
             }
             this.refreshTime[logIndex] = currentTime;
          }
      }  
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval  
      //| and difine file index name
      //+------------------------------------------------------------------+      
      void printLogLine(string fileIndex,int logIndex, int diffSeconds, string log)
      {
          datetime currentTime = TimeCurrent();
          int refreshDiffSeconds = currentTime - this.refreshTime[logIndex];
          if(refreshDiffSeconds > diffSeconds)
          {
             if(currentTime > this.beginTime
               && currentTime < this.endTime)
             {
                  writeLog(log,fileIndex);
             }
             
             if(this.diffFlag)this.refreshTime[logIndex] = currentTime;              
          }
      }       
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval  
      //| and difine file index name
      //+------------------------------------------------------------------+      
      void printLogLineEnd(string fileIndex,int logIndex, int diffSeconds, string log)
      {
          datetime currentTime = TimeCurrent();
          int refreshDiffSeconds = currentTime - this.refreshTime[logIndex];
          if(refreshDiffSeconds > diffSeconds)
          {
             if(currentTime > this.beginTime
               && currentTime < this.endTime)
             {
                  writeLog(log,fileIndex);
             }
             if(this.diffFlag)this.refreshTime[logIndex] = currentTime;             
          }
      }       
      
      //+------------------------------------------------------------------+
      //| Print error log to the error file
      //+------------------------------------------------------------------+        
      void printError(string log)
      {
         writeLog(log,"error");
      }                  
      
      //+------------------------------------------------------------------+
      //| print error order log
      //+------------------------------------------------------------------+
      void  printOrderError(COrder *order,string errorMsg){
            int symbolIndex=order.getSymbolIndex();    
            this.printError(comFunc.getDate_YYYYMMDDHHMM2()  
                                 + "  " + errorMsg                              
                                 + "   errorCode:" + order.getErrorCode()
                                 + "   modelId:" + order.getModelId()
                                 + "   magic:" + order.getMagic()
                                 + "   ticket:" + order.getTicket()
                                 //+ "   comProfit:" +   Clear_Order_Group_Min_Profit*SYMBOL_RATE[symbolIndex]
                                 //+ "   symbolRate:" +   SYMBOL_RATE[symbolIndex]
                                 + "   profitCurrency:" + comFunc.getUnitProfitCurrency(order)                                 
                                 + "   profit:" + order.getProfit()
                                 + "   lot:" + order.getLot()
                                 + "   Symbol:" + order.getSymbol()
                                 + "   tradeType:" + order.getOrderType()
                                 + "   tradePrice:" + order.getOpenPrice()
                                 + "   SlLine:" + order.getSlLine()
                                 + "   TpLine:" + order.getTpLine()
                                 + "   Comment:" + order.getComment());                                                 
      }          
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval                   |
      //+------------------------------------------------------------------+      
      void writeLog(string logInfo){
            
            LOG_FILE=FileOpen(this.logFileName + ".log",
            FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_COMMON);
            
            if(LOG_FILE<0) 
            { 
               Print("Failed to open the file by the absolute path "); 
               Print("Error code ",GetLastError()); 
            }      
            FileSeek(LOG_FILE,0,SEEK_END);  
            FileWrite(LOG_FILE,logInfo);                                     
            FileFlush(LOG_FILE);
            FileClose(LOG_FILE);
            LOG_FILE=-1;  
      }  
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval                   |
      //+------------------------------------------------------------------+      
      void writeLog(string logInfo,string fileIndex){            
            LOG_FILE=FileOpen(this.logFileName + "_" + fileIndex + ".log",
            FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_COMMON);            
            if(LOG_FILE<0) 
            { 
               Print("Failed to open the file by the absolute path "); 
               Print("Error code ",GetLastError()); 
            }      
            FileSeek(LOG_FILE,0,SEEK_END);  
            FileWrite(LOG_FILE,logInfo);                                     
            FileFlush(LOG_FILE);
            FileClose(LOG_FILE);
            LOG_FILE=-1;  
      }  
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval(limit Count)      |
      //+------------------------------------------------------------------+      
      void writeLmtLog(string logInfo){  
         string logInfoStr=comFunc.getDate_YYYYMMDDHHMM2() + "   " + this.logOutPutCount + "_" + logInfo;
         if(this.logOutPutCount<Log_OutPut_Count){
            this.writeLog(logInfoStr,"comm");
         }
         this.logOutPutCount++;
      } 
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval(limit Count)      |
      //+------------------------------------------------------------------+      
      void writeStatusLog(int index,int curStatus,string logInfo){           
         if(this.preStatus[index]!=curStatus){
             string logInfoStr=comFunc.getDate_YYYYMMDDHHMM2() + "   " +  logInfo;
             this.writeLog(logInfoStr,"status");
             this.preStatus[index]=curStatus;
         }
      }
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval                   |
      //+------------------------------------------------------------------+
      void printDiffTimeLog(int logIndex, int diffSeconds, string logInfo)
      {
          string logFileName="diffTimeLog_" + logIndex;
          string logInfoStr=comFunc.getDate_YYYYMMDDHHMM2() + "   " +  logInfo;
          datetime currentTime = TimeCurrent();
          int refreshDiffSeconds = currentTime - this.refreshTime[logIndex];
          if(refreshDiffSeconds > diffSeconds){
             //if(currentTime > this.beginTime && currentTime < this.endTime){
                  writeLog(logInfoStr,logFileName); 
             //}
             this.refreshTime[logIndex] = currentTime;
          }
      }       
      
      //+------------------------------------------------------------------+
      //| if debug period                                                  |
      //+------------------------------------------------------------------+
      bool debugPeriod(){
          datetime currentTime = TimeCurrent();
          if(currentTime >= this.debugBeginTime && currentTime <= this.debugEndTime){
            return true;
          }
          return false;            
      }                
      //+------------------------------------------------------------------+
      //| if debug period begin                                            |
      //+------------------------------------------------------------------+
      bool debugBegin(){
          datetime currentTime = TimeCurrent();
          if(currentTime >= this.debugBeginTime){
            return true;
          }
          return false;            
      }
      
      //+------------------------------------------------------------------+
      //| if debug period diff seconds
      //+------------------------------------------------------------------+
      bool debugPeriod(int logIndex,int diffSeconds){
          datetime currentTime = TimeCurrent();
          datetime preTime=this.refreshTime[logIndex];          
          int refreshDiffSeconds = currentTime - preTime;
          if(refreshDiffSeconds > diffSeconds)
          {                    
            this.refreshTime[logIndex] = currentTime; 
            if(currentTime > this.debugBeginTime && currentTime < this.debugEndTime){               
               return true;
            }            
          }
          return false;            
      }  
      
      //+------------------------------------------------------------------+
      //| if debug period diff seconds
      //+------------------------------------------------------------------+
      bool debugPeriod2(int logIndex,int diffSeconds){
          datetime currentTime = TimeCurrent();
          datetime preTime=this.refreshTime[logIndex];          
          int refreshDiffSeconds = currentTime - preTime;
          if(refreshDiffSeconds > diffSeconds)
          {                    
            this.refreshTime[logIndex] = currentTime; 
            return true;
          }
          return false;            
      }
      
      //+------------------------------------------------------------------+
      //| if debug check time
      //+------------------------------------------------------------------+
      bool checkDebugTime(string checkTime){
          if(this.debugCheckTime==0){
            this.debugCheckTime=StringToTime(checkTime);
          }          
          if(TimeCurrent()>=this.debugCheckTime){
            return true;
          }
          return false;
      }
      
      //+------------------------------------------------------------------+
      //| get status string name
      //+------------------------------------------------------------------+
      string indTrendStatusName(int status){
         if(status==IND_TREND_RANGE){      
            return "IND_TREND_RANGE";
         }else if(status==IND_TREND_UP){      
            return "IND_TREND_UP";
         }else if(status==IND_TREND_DOWN){      
            return "IND_TREND_DOWN";
         }else if(status==IND_TREND_NONE){      
            return "IND_TREND_NONE";
         }
         return "";
     } 
     
     string rangeStatusName(int statusFlg){
         string rangeStatus="STATUS_NONE";
         switch(statusFlg){
            case STATUS_RANGE_INNER:
               rangeStatus="RANGE_INNER";
               break;
            case STATUS_RANGE_BREAK_UP:
               rangeStatus="BREAK_UP";
               break;
            case STATUS_RANGE_BREAK_UP_RE:
               rangeStatus="BREAK_UP_RE";
               break;
            case STATUS_RANGE_BREAK_DOWN:
               rangeStatus="BREAK_DOWN";
               break;
            case STATUS_RANGE_BREAK_DOWN_RE:
               rangeStatus="BREAK_DOWN_RE";
               break;
         }
         return rangeStatus;
      }                                 
      
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CLog::CLog()
{
   ArrayInitialize(this.refreshTime, 0);  // Initialize refreshTime array to zero
   ArrayInitialize(this.preStatus, -1);  // Initialize refreshTime array to zero   
   this.LOG_FILE=-1;
   
   MqlDateTime local_dt={}; 
   datetime dt = TimeGMT(local_dt);
   string formatted_time = StringFormat("%04d%02d%02d", 
                                          local_dt.year, 
                                          local_dt.mon, 
                                          local_dt.day);     
                                          
   this.logFileName="fxlog\\" + Log_File_Name 
                              + "_" + formatted_time 
                              + "_" + MathRand() ;  
   
   this.beginTime=TimeCurrent();
   this.endTime=this.beginTime;
   if(StringLen(Log_Begin_Time)>0 && StringLen(Log_End_Time)>0){
      this.beginTime=StringToTime(Log_Begin_Time);
      this.endTime=StringToTime(Log_End_Time);  
   }
   
   this.debugBeginTime=0;
   this.debugEndTime=0;
   if(Debug && StringLen(Debug_Begin_Time)>0){
      this.debugBeginTime=StringToTime(Debug_Begin_Time);
   }   
   if(Debug && StringLen(Debug_End_Time)>0){      
      this.debugEndTime=StringToTime(Debug_End_Time);  
   }   
   this.debugCheckTime=0;
   this.diffFlag=true;
   this.logOutPutCount=0;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CLog::~CLog(){}

CLog rkeeLog;  // Create an instance of CLog