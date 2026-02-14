//+------------------------------------------------------------------+
//|                                                CEaLogSignal.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"

#include <Files\File.mqh>
#include <Generic\ArrayList.mqh>

#include "..\..\header\signal\CHeader.mqh"
#include "..\..\share\signal\CSignal.mqh"
#include "..\..\share\CShareCtl.mqh"

class CEaLogSignal
  {
   private:
         CShareCtl*      shareCtl; 
         double          lotRate;     
   public:
                        CEaLogSignal();
                        ~CEaLogSignal();
        
        //--- methods of initilize
        void            init(CShareCtl *shareCtl); 
        //--- set lot rate
        void            setLotRate(double value);     
        //--- read log to csv
        void            readLogToSignal(int signalKind,int indexNo);
        //--- read log to csv
        void            readMutiLogToSignal(int signalKind);
        //--- line to signal
        CSignal*        createSignal(int signalKind,int indexNo,string line);          
        //--- add signal action
        void            addSignalAction(int signalKind,int indexNo,string line,int signalActionType);
        //--- get left lot
        double          getLeftLot(CSignal* signal);
  };
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CEaLogSignal::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.lotRate=1;
} 

//+------------------------------------------------------------------+
//|  set lot rate
//+------------------------------------------------------------------+
void CEaLogSignal::setLotRate(double value)
  {            
      this.lotRate=value;
  } 
  
//+------------------------------------------------------------------+
//| read  log to csv file
//+------------------------------------------------------------------+  
void CEaLogSignal::readMutiLogToSignal(int signalKind){

   string filePath="EA\\" + signalKind + "\\*";
   string fileIndexs[];
   comFunc.getFileNamesFromFolder(filePath,fileIndexs);
   for(int i=0;i<fileIndexs.Size();i++){      
      StringReplace(fileIndexs[i],".log","");
      printf("fileIndex" + i + ":" + fileIndexs[i]);
      this.readLogToSignal(signalKind,StringToInteger(fileIndexs[i]));   
   }
}
 
//+------------------------------------------------------------------+
//| read  log to csv file
//+------------------------------------------------------------------+  
void CEaLogSignal::readLogToSignal(int signalKind,int indexNo){
   
   CArrayList<CSignal*> signalList;
          
   string fileName="EA\\" + signalKind + "\\" + indexNo + ".log";  
   
   printf("CEaLogSignal::readLogToSignal:" + fileName);
          
   int handle = FileOpen(fileName, FILE_SHARE_READ|FILE_CSV|FILE_ANSI|FILE_COMMON);
   
   if(handle < 0)
   {
      printf("文件打开失败: ", GetLastError());
      return;
   }          
   
   string line,preLine;
   while(!FileIsEnding(handle))
   {            
      string line = FileReadString(handle,-1);
      
      //printf(line);
      if(line != NULL 
         && StringFind(line,"deal #",0)>=0){         
         //close.modify order
         if(StringFind(preLine,"close #",0)>0){            
            this.addSignalAction(signalKind,indexNo,preLine,SIGNAL_TYPE_CLOSE);
            preLine="";
          //trigger close.modify order
          }else if(StringFind(preLine,"take profit triggered #",0)>0){          
            this.addSignalAction(signalKind,indexNo,preLine,SIGNAL_TYPE_CLOSE);
            preLine="";                      
          //new order
          }else{
            CSignal* signal=this.createSignal(signalKind,indexNo,line);
            this.shareCtl.getSignalShare().addSignal(signal);            
          }
      }else if(line != NULL 
          && ( StringFind(line,"close #",0)>0
               || StringFind(line,"take profit triggered #",0)>0)){               
         preLine=line;                           
      }else continue;      
   }          
   FileClose(handle);                    
}  

//+------------------------------------------------------------------+
//| create signal by new line
//+------------------------------------------------------------------+  
CSignal* CEaLogSignal::createSignal(int signalKind,int indexNo,string line){
          
   int deal_number;
   string trade_type;
   string currency_pair;
   datetime trade_time;   
   
   CSignal*  curSignal=new CSignal(); 
   curSignal.setSignalType(SIGNAL_TYPE_OPEN);
   curSignal.setSignalKind(signalKind);
   
   // get trade time
   //int time_pos = StringFind(line, "Trades") + 7;
   //string time_string = StringSubstr(line, time_pos, 19);
   //trade_time = StringToTime(time_string);
   //curSignal.setStartTime(trade_time);
   
   // Get trade time
   string trade_time_str = StringSubstr(line, 0, 19);
   trade_time = StringToTime(trade_time_str);   
   curSignal.setStartTime(trade_time);
      
   // create sourceId.ticket
   int deal_pos = StringFind(line, "deal #") + 6;
   int space_after_deal = StringFind(line, " ", deal_pos);
   deal_number = StringToInteger(StringSubstr(line, deal_pos, space_after_deal - deal_pos));
   curSignal.setSourceId(comFunc.makeSignalSourceId(signalKind,indexNo,deal_number));   
   
   // create trade type
   int type_pos = StringFind(line, "buy");
   if (type_pos == -1){     
     curSignal.setTradeType(ORDER_TYPE_SELL);
     type_pos = StringFind(line, "sell");
     trade_type = "sell";
   }else{
     curSignal.setTradeType(ORDER_TYPE_BUY);
     trade_type = "buy";
   }

   // Find and extract lot size
   int lot_pos = type_pos + StringLen(trade_type) + 1;
   int space_after_lot = StringFind(line, " ", lot_pos);
   double lot_size = StringToDouble(StringSubstr(line, lot_pos, space_after_lot - lot_pos));
   lot_size=lot_size*this.lotRate;   
   curSignal.setLot(lot_size);
   
   // Find and extract currency pair
   int currency_pos = space_after_lot + 1;
   int space_after_currency = StringFind(line, " ", currency_pos);
   currency_pair = StringSubstr(line, currency_pos, space_after_currency - currency_pos);
   curSignal.setSymbol(currency_pair);
   
   /*     
      printf(line);
      printf(curSignal.getSourceId() + " | "
            + curSignal.getStartTime() + " | "
            + curSignal.getTradeType() + " | "
            + curSignal.getSymbol() + " | "
            + curSignal.getLot() + " | createSignal");
   */

   CSignalAction* signalAction=new CSignalAction();
   signalAction.setSignalType(SIGNAL_TYPE_OPEN);
   signalAction.setDealTime(trade_time);
   signalAction.setLot(lot_size);
   curSignal.addAction(signalAction);

   return curSignal;
}

//+------------------------------------------------------------------+
//| add signal action
//+------------------------------------------------------------------+  
void  CEaLogSignal::addSignalAction(int signalKind,int indexNo,string line,int signalActionType){
   
   // Get trade time
   string trade_time_str = StringSubstr(line, 0, 19);
   datetime trade_time = StringToTime(trade_time_str);
   
   // Get deal number (order number)
   int deal_pos = StringFind(line, "#") + 1;
   int space_after_deal = StringFind(line, " ", deal_pos);
   int deal_number = StringToInteger(StringSubstr(line, deal_pos, space_after_deal - deal_pos));
   
   // Get lot size
   int buy_pos = StringFind(line, "buy ");
   int lot_pos = buy_pos + 4;
   if (buy_pos == -1){
     buy_pos = StringFind(line, "sell ");
     lot_pos = buy_pos + 5;
   }  
   
   int space_after_lot = StringFind(line, " ", lot_pos);
   double lot_size = StringToDouble(StringSubstr(line, lot_pos, space_after_lot - lot_pos));
   lot_size=lot_size*this.lotRate;
   
   ulong sourceId=comFunc.makeSignalSourceId(signalKind,indexNo,deal_number);
   CSignal* curSignal=this.shareCtl.getSignalShare().getSignal(sourceId);
   
   if(curSignal==NULL)return;   
   double curLot=curSignal.getLot(); 
   CSignalAction* signalAction=new CSignalAction();
   signalAction.setDealTime(trade_time);
   signalAction.setSignalType(signalActionType);
   signalAction.setLot(lot_size);
   signalAction.setSignalType(signalActionType);
   //close
   //printf(line);
   if(signalActionType==SIGNAL_TYPE_CLOSE){
      if(this.getLeftLot(curSignal)>lot_size){
         signalAction.setSignalType(SIGNAL_TYPE_CLOSE_PART);
         /* 
         printf(sourceId + " | "
                  + trade_time + " | "
                  + curSignal.getTradeType() + " | "
                  + curSignal.getSymbol() + " | "
                  + lot_size + " | addSignalAction Close Part"); */
      }else{
         signalAction.setSignalType(SIGNAL_TYPE_CLOSE_PART);
         /*
         printf(sourceId + " | "
                  + trade_time + " | "
                  + curSignal.getTradeType() + " | "
                  + curSignal.getSymbol() + " | "
                  + lot_size + " | addSignalAction Close"); */
      }
   }
   curSignal.addAction(signalAction);         
}

//+------------------------------------------------------------------+
//| get left lot
//+------------------------------------------------------------------+ 
double CEaLogSignal::getLeftLot(CSignal* signal){
   
   CArrayList<CSignalAction*>* actionList=signal.getActionList();
   double currentLot=signal.getLot();
   for(int i=0;i<actionList.Count();i++){
      CSignalAction* action; 
      actionList.TryGetValue(i,action);        
      if(action.getSignalType()==SIGNAL_TYPE_CLOSE
         || action.getSignalType()==SIGNAL_TYPE_CLOSE_PART
         || action.getSignalType()==SIGNAL_TYPE_CLOSE_TRIGGER){            
          currentLot-=action.getLot();  
         }        
    }                
    return currentLot;
}

//+------------------------------------------------------------------+
//|    class constructor                                                      
//+------------------------------------------------------------------+
CEaLogSignal::CEaLogSignal(){}   
CEaLogSignal::~CEaLogSignal(){}


//CEaLogSignal logToSignal;