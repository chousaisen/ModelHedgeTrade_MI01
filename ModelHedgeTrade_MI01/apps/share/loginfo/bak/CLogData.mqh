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

#include "..\order\COrder.mqh"

class CLogData
{
   private:
      //log info step orders 
      CHashMap<int,COrder*> stepOrder;
      CHashMap<string,string> checkValues;
      CHashMap<string,string> logLines;
      bool                    logFlg;
      string                  tempLine;
                              
   public:         
      CLogData(){};
      ~CLogData(){};
      
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
      //|  save line to hashtable
      //+------------------------------------------------------------------+
      void saveLine(string lineName,int maxLineCount){
         //if(!this.logFlg)return;
         if(this.logLines.Count()>=maxLineCount)return;
         this.logLines.Add(lineName,this.tempLine);
         this.tempLine="";
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
      //| clear log info
      //+------------------------------------------------------------------+     
      void clear(){
         this.logFlg=false;
         this.stepOrder.Clear();                        
         this.checkValues.Clear(); 
         this.logLines.Clear();     
      }  
      
      //+------------------------------------------------------------------+
      //| begin log info
      //+------------------------------------------------------------------+     
      void begin(){
         this.clear();
         this.logFlg=true;      
      }                 
       
       //+------------------------------------------------------------------+
      //| end log info
      //+------------------------------------------------------------------+     
      void endLog(int limitOrderCount){
         if(this.stepOrder.Count()>limitOrderCount){
            this.logFlg=true;      
         }
      }         
         
      //+------------------------------------------------------------------+
      //|  get log info step order by index
      //+------------------------------------------------------------------+
      COrder* getStepOrder(int index){
         COrder *order;
         if(this.stepOrder.TryGetValue(index,order)){
            return order;
         }
         return NULL;
      }  
      //+------------------------------------------------------------------+
      //|  get log info step order by index
      //+------------------------------------------------------------------+
      double getStepOrderProfit(int index){
         COrder *order=this.getStepOrder(index);
         if(CheckPointer(order)!=POINTER_INVALID){
            return order.getProfitCurrency();
         }
         return 0;
      }        
      
      //+------------------------------------------------------------------+
      //|  set log info step order by index
      //+------------------------------------------------------------------+
      void addStepOrder(int index,COrder *order){
         if(!this.logFlg)return;
         this.stepOrder.Add(index,order);
      }
      
      //+------------------------------------------------------------------+
      //|  set log info step order by index and limit max step
      //+------------------------------------------------------------------+
      void addStepOrder(COrder *order,int maxStep){
         if(!this.logFlg)return;
         if(this.stepOrder.Count()>=maxStep)return;
         int orderIndex=this.stepOrder.Count();
         this.stepOrder.Add(orderIndex,order);
      }        
      
      //+------------------------------------------------------------------+
      //|  set log info step order by index and limit max step
      //+------------------------------------------------------------------+
      void addStepOrder(int index,COrder *order,int maxStep){
         if(!this.logFlg)return;
         if(this.stepOrder.Count()>=maxStep)return;
         this.stepOrder.Add(index,order);
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
         if(!this.logFlg)return;
         this.checkValues.Add(checkName,value);
      }
           
      //+------------------------------------------------------------------+
      //|  set log info check value by check name and limit max count
      //+------------------------------------------------------------------+
      void addCheckValue(string value,int maxCount){
         if(!this.logFlg)return;
         if(this.checkValues.Count()>=maxCount)return;
         string checkNameIndex=(string)(this.checkValues.Count());
         this.checkValues.Add(checkNameIndex,value);
      }            
           
      //+------------------------------------------------------------------+
      //|  set log info check value by check name and limit max count
      //+------------------------------------------------------------------+
      void addCheckValue(string checkName,string value,int maxCount){
         if(!this.logFlg)return;
         if(this.checkValues.Count()>=maxCount)return;
         this.checkValues.Add(checkName,value);
      }
      
};

CLogData logData;  // Create an instance of ComFunc