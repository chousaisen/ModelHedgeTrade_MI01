//+------------------------------------------------------------------+
//|                                                LogToCsv.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"

#include <Files\File.mqh>


class LogToCsv
  {
   private:
         
   public:
                        LogToCsv();
                        ~LogToCsv();
        
        //--- methods of initilize
        void            init();   
        //--- read log to csv
        void            readLogToCsv(string logFileName);
  };
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void LogToCsv::init(){}
 
//+------------------------------------------------------------------+
//| read  log to csv file
//+------------------------------------------------------------------+  
void LogToCsv::readLogToCsv(string logFileName){
          
   string fileName="fxlog\\" + logFileName + ".log";       
  
   int handle = FileOpen(fileName, FILE_SHARE_READ|FILE_CSV|FILE_ANSI|FILE_COMMON);
   
   if(handle < 0)
   {
      printf("文件打开失败: ", GetLastError());
      return;
   }          
   
   string line;
   while(!FileIsEnding(handle))
   {            
      line = FileReadString(handle,-1);
      if(line != NULL)
      {
         
         if(StringLen(line)<=0)continue;
         
         if(StringFind(line,"instant sell",0)>=0
             )
         
         //printf("line:" + line);
         string data[];
         int count=StringSplit(line,';',data);
         addSignal(signalKind,data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]);
      }
   }          
   FileClose(handle);                    
}  
  
//+------------------------------------------------------------------+
//|    class constructor                                                                |
//+------------------------------------------------------------------+
LogToCsv::LogToCsv(){}   
LogToCsv::~LogToCsv(){}