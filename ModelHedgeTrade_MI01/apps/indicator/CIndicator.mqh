//+------------------------------------------------------------------+
//|                                                   CIndicator.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

class CIndicator{
   private:
      //debug info (use to database table)
      string                debugDBInfo;                       
   public:
                           CIndicator();
                          ~CIndicator();        
         
      //--- debug info(database)
      void                 setDebugDBInfo(string info);                     
      string               getDebugDBInfo();
};

//+------------------------------------------------------------------+
//|   debug info(database)
//+------------------------------------------------------------------+
void CIndicator::setDebugDBInfo(string info){
   this.debugDBInfo=info;
}
string CIndicator::getDebugDBInfo(){
   return this.debugDBInfo;
}
  
//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CIndicator::CIndicator(){}
CIndicator::~CIndicator(){}