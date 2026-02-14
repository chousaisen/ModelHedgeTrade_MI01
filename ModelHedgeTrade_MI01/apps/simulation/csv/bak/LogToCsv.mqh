//+------------------------------------------------------------------+
//|                                                LogToCsv.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"

#include <Files\File.mqh>
#include <Generic\ArrayList.mqh>

#include "..\..\header\signal\CHeader.mqh"
#include "..\..\share\signal\CSignal.mqh"

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
void LogToCsv::readLogToCsv(string indexNo){
   
   CArrayList<CSignal*> signalList;
          
   string fileName="fxlog\\" + indexNo + ".log";         
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
         if(StringFind(line,"	Trade	",0)<0)continue;
         
         if(StringFind(line,"deal performed",0)>=0
             || StringFind(line,"instant buy",0)>=0
             || StringFind(line,"take profit triggered",0)>=0
             || StringFind(line,"deal performed",0)>=0){
             
             CSignal* signal=new CSignal();
             
                         
             
             
         }else continue;

         string data[];


      }
   }          
   FileClose(handle);                    
}  
  
//+------------------------------------------------------------------+
//|    class constructor                                                                |
//+------------------------------------------------------------------+
LogToCsv::LogToCsv(){}   
LogToCsv::~LogToCsv(){}