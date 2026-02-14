//+------------------------------------------------------------------+
//|                                                CEaLogSignalEx.mqh |
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

class CEaLogSignalEx
  {
   private:
         CShareCtl*      shareCtl; 
         double          fixLot;
         double          lotRate;
         int             SymbolIndex;
         string          extSymbolList;     
         string          onlySymbolList; 
         string          expCountry;
   public:
                        CEaLogSignalEx();
                        ~CEaLogSignalEx();
        
        //--- methods of initilize
        void            init(CShareCtl *shareCtl); 
        //--- set lot rate
        void            setLotRate(double value);
        //--- set except symbol list
        void            setExtSymbolList(string value);     
        //--- set only symbol list
        void            setOnlySymbolList(string value);  
        //--- set except country symbol
        void            setExpCountry(string value);  
        //--- read log to csv
        void            readLogToSignal(string eaFolderName,int signalKind,string logFile);
        //--- read log to csv
        void            readMutiLogToSignal(string eaFolderName,int signalKind);
        //--- line to signal
        CSignal*        createSignal(int signalKind,string line);          
        //--- add signal action
        void            addSignalAction(int signalKind,string line,int signalActionType);
        //--- get left lot
        double          getLeftLot(CSignal* signal);
        //--- set fix lot
        void          setFixLot(double value);        
  };
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CEaLogSignalEx::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.lotRate=1;
   this.expCountry="";  
   this.fixLot=0;
} 

//+------------------------------------------------------------------+
//|  set lot rate
//+------------------------------------------------------------------+
void CEaLogSignalEx::setLotRate(double value)
  {            
      this.lotRate=value;
  } 
  
//+------------------------------------------------------------------+
//|  set fix lot
//+------------------------------------------------------------------+
void CEaLogSignalEx::setFixLot(double value)
  {            
      this.fixLot=value;
  } 
    
  
//+------------------------------------------------------------------+
//|  set except symbol list
//+------------------------------------------------------------------+
void CEaLogSignalEx::setExtSymbolList(string value)
  {            
      this.extSymbolList=value;
  }   
  
//+------------------------------------------------------------------+
//|  set only symbol list
//+------------------------------------------------------------------+
void CEaLogSignalEx::setOnlySymbolList(string value)
  {            
      this.onlySymbolList=value;
  }   

//+------------------------------------------------------------------+
//|  set only symbol list
//+------------------------------------------------------------------+
void CEaLogSignalEx::setExpCountry(string value)
  {            
      this.expCountry=value;
  }   
    
//+------------------------------------------------------------------+
//| read  log to csv file
//+------------------------------------------------------------------+  
void CEaLogSignalEx::readMutiLogToSignal(string eaFolderName,int signalKind){

   this.SymbolIndex=0;
   string filePath="EA\\" + eaFolderName + "\\*";
   string logFiles[];
   comFunc.getFileNamesFromFolder(filePath,logFiles);
   for(int i=0;i<logFiles.Size();i++){      
      //StringReplace(fileIndexs[i],".log","");
      printf("logFile" + i + ":" + logFiles[i]);
      this.readLogToSignal(eaFolderName,signalKind,logFiles[i]);   
   }
}
 
//+------------------------------------------------------------------+
//| read  log to csv file
//+------------------------------------------------------------------+  
void CEaLogSignalEx::readLogToSignal(string eaFolderName,int signalKind,string logFile){
   
   CArrayList<CSignal*> signalList;
          
   string fileName="EA\\" + eaFolderName + "\\" + logFile;  
   
   printf("CEaLogSignalEx::readLogToSignal:" + fileName);
          
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
      
      
      if(line!=NULL){      
         //if(StringFind(line,"___Graphics___",0)>0){
         //   this.SymbolIndex++;
         //}   
         if(StringFind(line,"symbol to be synchronized",0)>0){
            this.SymbolIndex++;
         }   
      }
      
      //printf(line);
      if(line != NULL 
         && StringFind(line,"deal #",0)>=0){         
         //close.modify order
         if(StringFind(preLine,"close #",0)>0){            
            this.addSignalAction(signalKind,preLine,SIGNAL_TYPE_CLOSE);
            preLine="";
          //trigger close.modify order
          }else if(StringFind(preLine,"take profit triggered #",0)>0){          
            this.addSignalAction(signalKind,preLine,SIGNAL_TYPE_CLOSE);
            preLine="";                      
          //stop loss triggered
          }else if(StringFind(preLine,"stop loss triggered #",0)>0){          
            this.addSignalAction(signalKind,preLine,SIGNAL_TYPE_CLOSE);
            preLine="";                      
          //new order
          }else{
            //printf("preLine:"+ preLine);
            CSignal* signal=this.createSignal(signalKind,line);
            if(StringFind(this.extSymbolList,signal.getSymbol(),0)>=0)continue;
            if(StringLen(this.onlySymbolList)>0 && StringFind(this.onlySymbolList,signal.getSymbol(),0)<0)continue;
            if(StringLen(this.expCountry)>0){
               string curSymbol=signal.getSymbol();
               string curCountry1=StringSubstr(curSymbol,0,3);
               string curCountry2=StringSubstr(curSymbol,3,3);
                                             
               if(StringFind(this.expCountry,curCountry1,0)>=0)continue;
               if(StringFind(this.expCountry,curCountry2,0)>=0)continue;
               
            }             
            this.shareCtl.getSignalShare().addSignal(signal);            
          }
      }else if(line != NULL 
          && ( StringFind(line,"close #",0)>0
               || StringFind(line,"take profit triggered #",0)>0
               || StringFind(line,"stop loss triggered #",0)>0)){               
         preLine=line;                           
      }else continue;      
   }          
   FileClose(handle);                    
}  

//+------------------------------------------------------------------+
//| create signal by new line
//+------------------------------------------------------------------+  
CSignal* CEaLogSignalEx::createSignal(int signalKind,string line){
          
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
   curSignal.setSourceId(comFunc.makeSignalSourceId(signalKind,this.SymbolIndex,deal_number));   
   //printf("makeSignalSourceId:" + curSignal.getSourceId());
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
   //printf("lot_size:" + lot_size + "  lotRate:" + this.lotRate);  
   lot_size=lot_size*this.lotRate;    
   if(this.fixLot>0)lot_size=this.fixLot*this.lotRate; 
   
   curSignal.setLot(lot_size);
   
   // Find and extract currency pair
   int currency_pos = space_after_lot + 1;
   int space_after_currency = StringFind(line, " ", currency_pos);
   currency_pair = StringSubstr(line, currency_pos, space_after_currency - currency_pos);
   StringReplace(currency_pair,".","");
   curSignal.setSymbol(currency_pair);
      
      //printf(line);
      /*
      printf(curSignal.getSourceId() + " | "
            + curSignal.getStartTime() + " | "
            + curSignal.getTradeType() + " | "
            + curSignal.getSymbol() + " | "
            + curSignal.getLot() + " | createSignal");*/

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
void  CEaLogSignalEx::addSignalAction(int signalKind,string line,int signalActionType){
   
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
   
   ulong sourceId=comFunc.makeSignalSourceId(signalKind,this.SymbolIndex,deal_number);
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
         
         /*printf(sourceId + " | "
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
double CEaLogSignalEx::getLeftLot(CSignal* signal){
   
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
CEaLogSignalEx::CEaLogSignalEx(){
   this.SymbolIndex=1;
}   
CEaLogSignalEx::~CEaLogSignalEx(){}


//CEaLogSignalEx logToSignal;