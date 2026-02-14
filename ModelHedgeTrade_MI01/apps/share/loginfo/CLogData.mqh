//+------------------------------------------------------------------+
//|                                                    CHedgeGroup.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>

#include "..\model\order\COrder.mqh"
#include "..\..\comm\comFunc.mqh"

class CLogData
{
   private:
      CHashMap<string,string> checkValues;
      CHashMap<string,double> checkNValues;
      CHashMap<string,double> checkTimeDiffNValues;
      CHashMap<string,string> logLines;
      CArrayList<string>      debugLines;
      string                  tempLine;
      int                     countValue[100];
      datetime                checkTime;
                              
   public:         
      CLogData(){
         this.checkTime=TimeCurrent();
      };
      ~CLogData(){};
      
      //+------------------------------------------------------------------+
      //| begin log info
      //+------------------------------------------------------------------+     
      void begin(){
         this.reset();
      }  
      
      //+------------------------------------------------------------------+
      //| clear log info
      //+------------------------------------------------------------------+     
      void reset(){
         this.tempLine="";
         this.checkValues.Clear(); 
         this.checkNValues.Clear(); 
         this.logLines.Clear(); 
         ArrayInitialize(this.countValue,0);    
      }        
      
      //+------------------------------------------------------------------+
      //| begin temp string line
      //+------------------------------------------------------------------+           
      void beginLine(string line){
         this.tempLine=line;
      }      

      //+------------------------------------------------------------------+
      //| add long temp string line
      //+------------------------------------------------------------------+           
      void addLine(string line){
         this.tempLine=this.tempLine + line;
      }      
      
      //+------------------------------------------------------------------+
      //| add open order line info
      //+------------------------------------------------------------------+           
      void addOpenOrderLine(COrder* order){
         logData.addLine("<open:" + order.getTicket()                            
                           + "-modelKind:" + order.getModelKind()
                           + "-symbol:" + order.getSymbol()
                            + "-" + comFunc.getOrderType(order)
                           //+ "-Id:" + order.getMagic()
                           + ">@R"); 
      }   
            
      //+------------------------------------------------------------------+
      //| add close order line info
      //+------------------------------------------------------------------+           
      void addCloseOrderLine(COrder* order){
         logData.addLine("<close:" + order.getTicket()                            
                           + "-profit:" + StringFormat("%.2f",comFunc.getUnitProfitCurrency(order)) 
                           + "-modelKind:" + order.getModelKind()
                           + "-symbol:" + order.getSymbol() 
                           + "-" + comFunc.getOrderType(order)
                           //+ "-Id:" + order.getMagic()
                           + ">@R"); 
      } 
      
      //+------------------------------------------------------------------+
      //| add clear order line info
      //+------------------------------------------------------------------+           
      void addClearOrderLine(COrder* order){
         logData.addLine("<clear:" + order.getTicket()                            
                           + "-profit:" + StringFormat("%.2f",comFunc.getUnitProfitCurrency(order)) 
                           + "-modelKind:" + order.getModelKind()
                           + "-symbol:" + order.getSymbol()
                            + "-" + comFunc.getOrderType(order)                     
                           //+ "-Id:" + order.getMagic()
                           + ">@R"); 
      }                
            
      //+------------------------------------------------------------------+
      //|  save line to hashtable
      //+------------------------------------------------------------------+
      void saveLine(string lineName,int maxLineCount){
         //if(!this.logFlg)return;
         if(this.logLines.Count()>=maxLineCount)return;
         if(StringLen(this.tempLine)<=0)return;
         this.logLines.Remove(lineName);
         this.logLines.Add(lineName,this.tempLine);
         this.tempLine="";
      } 
      
      //+------------------------------------------------------------------+
      //|  get log line count
      //+------------------------------------------------------------------+      
      int lineCount(){
         return this.logLines.Count();
      }
                    
      //+------------------------------------------------------------------+
      //|  get line from  hashtable
      //+------------------------------------------------------------------+
      string getLine(string lineName){
         string line;
         if(this.logLines.TryGetValue(lineName,line)){
            return line;
         }
         return "";
      }        
                  
      //+------------------------------------------------------------------+
      //|  get log info check value by check name
      //+------------------------------------------------------------------+
      string getCheckValue(string checkName){
         string checkValue;
         if(this.checkValues.TryGetValue(checkName,checkValue)){
            return checkValue;
         }
         return "";
      }   
      
      //+------------------------------------------------------------------+
      //|  set log info check value by check name
      //+------------------------------------------------------------------+
      void addCheckValue(string checkName,string value){
         //if(!this.logFlg)return;
         this.checkValues.Remove(checkName);
         this.checkValues.Add(checkName,value);
      }                      
           
      //+------------------------------------------------------------------+
      //|  set log info check value by check name and limit max count
      //+------------------------------------------------------------------+
      void addCheckValue(string checkName,string value,int maxCount){
         //if(!this.logFlg)return;
         if(this.checkValues.Count()>=maxCount)return;
         this.checkValues.Add(checkName,value);
      }            
      
      //+------------------------------------------------------------------+
      //|  get log info check value by check name
      //+------------------------------------------------------------------+
      double getCheckNValue(string checkName){
         double checkValue;
         if(this.checkNValues.TryGetValue(checkName,checkValue)){
            return checkValue;
         }
         return 0;
      }   
      
      //+------------------------------------------------------------------+
      //|  set log info check value by check name
      //+------------------------------------------------------------------+
      void addCheckNValue(string checkName,double value){  
         this.checkNValues.Remove(checkName);       
         this.checkNValues.Add(checkName,value);
      }      
      
      //+------------------------------------------------------------------+
      //| plus the count value  by index
      //+------------------------------------------------------------------+      
      void addPlusCount(int index,int value){
         if(index<0 || index>=ArraySize(this.countValue))return;
         this.countValue[index]+=value;
      }   

      //+------------------------------------------------------------------+
      //|  get log info check value by check name(time diff set)
      //+------------------------------------------------------------------+
      double getCheckTimeDiffNValue(string checkName,int diffSeconds,double resetValue){
      
         datetime curTime=TimeCurrent();
         int passedSeconds=curTime-this.checkTime;
         if(passedSeconds>diffSeconds){
            this.checkTime=curTime;
            this.addCheckTimeDiffNValue(checkName,resetValue);
            return resetValue;
         } 
      
         double checkValue;
         if(this.checkTimeDiffNValues.TryGetValue(checkName,checkValue)){
            return checkValue;
         }
         return resetValue;
      }  

      //+------------------------------------------------------------------+
      //|  set log info check value by check name(time diff set)
      //+------------------------------------------------------------------+
      void addCheckTimeDiffNValue(string checkName,double value){  
         this.checkTimeDiffNValues.Remove(checkName);       
         this.checkTimeDiffNValues.Add(checkName,value);
      }      
      
      //+------------------------------------------------------------------+
      //| get the plus count value  by index
      //+------------------------------------------------------------------+      
      int getPlusCount(int index){         
         if(index<0 || index>=ArraySize(this.countValue))return 0;
         return this.countValue[index];
      }

      //+------------------------------------------------------------------+
      //| add debug info
      //+------------------------------------------------------------------+            
      void  addDebugInfo(string info){      
         if(rkeeLog.debugPeriod()){
            this.debugLines.Add(info);
         }
      }
      void addDebugInfo(COrder* order,string info){
         if(rkeeLog.debugPeriod()){
            this.debugLines.Add("<" + info
                                 + ":" + order.getTicket()                            
                                 + "-id:" + order.getModelId()
                                 + "-mKind:" + order.getModelKind()
                                 + " " + order.getSymbol()
                                 + "-" + comFunc.getOrderType(order)
                                 + "-openPrice:" + order.getOpenPrice()
                                 + " profit:" + order.getProfit()
                                 + ">");
         }                            
      }       
      //+------------------------------------------------------------------+
      //| clear debug info
      //+------------------------------------------------------------------+            
      void  clearDebugInfo(){      
         if(rkeeLog.debugPeriod()){
            this.debugLines.Clear();
         }
      }
      //+------------------------------------------------------------------+
      //| clear debug info
      //+------------------------------------------------------------------+            
      CArrayList<string>*  getDebugInfo(){               
         return &this.debugLines;         
      }            
};

CLogData logData;  // Create an instance of ComFunc