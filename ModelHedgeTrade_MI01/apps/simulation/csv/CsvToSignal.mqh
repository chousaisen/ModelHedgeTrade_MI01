//+------------------------------------------------------------------+
//|                                                CsvToSignal.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"

#include <Files\File.mqh>
#include "..\..\header\signal\CHeader.mqh"
#include "..\..\share\CShareCtl.mqh"
#include "..\..\share\signal\CSignal.mqh"
#include "..\..\share\signal\CSignalList.mqh"
#include "..\..\share\signal\CSignalTimeSet.mqh"
#include "..\..\share\signal\CSignalKindSet.mqh"

class CsvToSignal
  {
   private:
         CShareCtl* shareCtl;
         int        signalIndex;
         double     lotRate;
         double     fixLot;
   public:
         CsvToSignal();
        ~CsvToSignal();
        
        //--- methods of initilize
        void            init(CShareCtl *shareCtl); 
        //--- set lot rate
        void            setLotRate(double value); 
        //--- set lot rate
        void            setFixLot(double value);                
        //--- load csv simulation info
        void            readCsvToSignal(int signalKind);       
        //--- add  signal
        void            readCsvToSignal(int signalKindNo,int signalKind);
        //--- add  signal
        void            addSignal(ulong signalSourceId,int signalKind,
                                    string beginTime1,string tradeType1,
                                    string lot1,string symbol1,
                                    string beginPrice1,string endLot1,
                                    string endTime1,string endPrice1);         
  };
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CsvToSignal::init(CShareCtl *shareCtl)
  {
      this.shareCtl=shareCtl;
      this.signalIndex=1;
      this.lotRate=1;
      this.fixLot=0;
  } 
  
//+------------------------------------------------------------------+
//|  set lot rate
//+------------------------------------------------------------------+
void CsvToSignal::setLotRate(double value)
  {            
      this.lotRate=value;
  } 
 
//+------------------------------------------------------------------+
//|  set fix lot
//+------------------------------------------------------------------+
void CsvToSignal::setFixLot(double value)
  {            
      this.fixLot=value;
  }   
  
//+------------------------------------------------------------------+
//|  read csv data to signal
//+------------------------------------------------------------------+
void CsvToSignal::readCsvToSignal(int signalKind)
  { 
   
   string filePath="signal\\csv\\" + signalKind + "\\*";
   string fileIndexs[];
   comFunc.getFileNamesFromFolder(filePath,fileIndexs);
   for(int i=0;i<fileIndexs.Size();i++){      
      StringReplace(fileIndexs[i],".positions.csv","");
      //printf("fileIndex" + i + ":" + fileIndexs[i]);
      this.readCsvToSignal(signalKind,StringToInteger(fileIndexs[i]));   
   } 
}    

//+------------------------------------------------------------------+
//| readSingles
//+------------------------------------------------------------------+  
void CsvToSignal::readCsvToSignal(int signalKind,int indexNo){                                       
          
   string fileName="signal\\csv\\" + signalKind + "\\" + indexNo  + ".csv";      
   //printf("read file:" + fileName);       
  
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
         if(StringFind(line,"Balance",0)>=0)continue;
         if(StringFind(line,"Time",0)>=0)continue;
         if(StringFind(line,"Limit",0)>=0)continue;
         
         //printf("line:" + line);         
         string data[];
         int count=StringSplit(line,';',data);
         ulong signalSourceId=comFunc.makeSignalSourceId(signalKind,indexNo,this.signalIndex);
         this.signalIndex++;
         addSignal(signalSourceId,signalKind,data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]);
      }
   }          
   FileClose(handle);                    
}  

//+------------------------------------------------------------------+
//| add Signal to the signal list
//+------------------------------------------------------------------+
void CsvToSignal::addSignal(ulong signalSourceId,int signalKind,
                                    string beginTime1,string tradeType1,string lot1,
                                    string symbol1,string beginPrice1,string endLot1,
                                    string endTime1,string endPrice1){
      
   datetime beginTime=StringToTime(beginTime1);
   datetime endTime=StringToTime(endTime1);
   
   //except the error data
   if(beginTime>=endTime)return;
   
   //int beginDay=StringToInteger(TimeToString(beginTime,TIME_DATE)); 
   //int endDay=TimeToString(endTime,TIME_DATE); 
   
   MqlDateTime mqlBeginTime,mqlEndTime; 
   TimeToStruct(beginTime,mqlBeginTime);
   //TimeToStruct(endTime,mqlEndTime);
   
   int beginDay=mqlBeginTime.year*10000+mqlBeginTime.mon*100+mqlBeginTime.day; 
   //int endDay=mqlEndTime.year*10000+mqlEndTime.mon*100+mqlEndTime.day; 
       
   ENUM_ORDER_TYPE tradeType=-1;
   if(tradeType1=="Buy")tradeType=ORDER_TYPE_BUY;
   else if(tradeType1=="Sell")tradeType=ORDER_TYPE_SELL;
   else return;
   
   double lot=StringToDouble(lot1)*this.lotRate;
   if(this.fixLot>0)lot=this.fixLot;
   string symbol=symbol1;
   double beginPrice=StringToDouble(beginPrice1);
   double endPrice=StringToDouble(endPrice1);
   
   if(tradeType>=0){
      CSignal *signal=new CSignal(signalKind,symbol,tradeType,lot,beginPrice,beginTime,endTime);
      signal.setSourceId(signalSourceId); 
      
      CSignalAction* signalAction=new CSignalAction();
      signalAction.setSignalType(SIGNAL_TYPE_OPEN_TIME_LIMIT);
      signalAction.setDealTime(beginTime);
      signalAction.setLot(lot);
      signal.addAction(signalAction); 
       
      /*
      printf("|" + signal.getSourceId() 
               + "|" + signal.getSignalKind() 
               + "|" + signal.getStartTime()
               + "|" + signal.getEndTime());*/
      shareCtl.getSignalShare().addSignal(signalKind,beginDay,signal);      
   }
}                

//+------------------------------------------------------------------+
//|    class constructor                                                                |
//+------------------------------------------------------------------+
CsvToSignal::CsvToSignal(){}   
CsvToSignal::~CsvToSignal(){}