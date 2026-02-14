//+------------------------------------------------------------------+
//|                                                  CBandStatus.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "..\CHeader.mqh"

class CBandStatus
  {
private:      
      ENUM_STATE     status[10]; 
public:
                     CBandStatus();
                    ~CBandStatus();
     
     //--- methods of initilize
     void            init(); 
     //--- set price speed
     void            setStatus(int level,ENUM_STATE status);
     //--- get price speed
     ENUM_STATE      getStatus(int level);
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CBandStatus::init()
{

}

//+------------------------------------------------------------------+
//|  set price action 
//+------------------------------------------------------------------+
void CBandStatus::setStatus(int level,ENUM_STATE status){
   this.status[level]=status;
}

//+------------------------------------------------------------------+
//|  get price action 
//+------------------------------------------------------------------+
ENUM_STATE CBandStatus::getStatus(int level){
   return this.status[level];
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CBandStatus::CBandStatus(){
   ArrayInitialize(this.status,-1);
}
CBandStatus::~CBandStatus(){}