//+------------------------------------------------------------------+
//|                                                  CTickStatus.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "..\CHeader.mqh"

#define TICK_STATE_LV1            (0)                     // tick state level 1
#define TICK_STATE_LV2            (1)                     // tick state level 2
#define TICK_STATE_LV3            (2)                     // tick state level 3

class CTickStatus
  {
private:      
      ENUM_TICK_STATE            tickState[5]; 
public:
                     CTickStatus();
                    ~CTickStatus();
     
     //--- methods of initilize
     void            init(); 
     //--- set tick status
     void            setTickStatus(ENUM_TICK_STATE status);
     //--- get tick status
     ENUM_TICK_STATE getTickStatus();
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CTickStatus::init(){}

//+------------------------------------------------------------------+
//|  set tick status
//+------------------------------------------------------------------+
void CTickStatus::setTickStatus(ENUM_TICK_STATE status){
   this.tickState[TICK_STATE_LV1]=status;
}

//+------------------------------------------------------------------+
//|  get tick status
//+------------------------------------------------------------------+
ENUM_TICK_STATE CTickStatus::getTickStatus(){
   return this.tickState[TICK_STATE_LV1];
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CTickStatus::CTickStatus(){
   ArrayInitialize(this.tickState,TICK_STATE_ACC_NONE);
}
CTickStatus::~CTickStatus(){}