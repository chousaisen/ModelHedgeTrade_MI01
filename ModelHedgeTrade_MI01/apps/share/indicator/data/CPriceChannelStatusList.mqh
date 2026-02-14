//+------------------------------------------------------------------+
//|                                          CPriceChannelStatusList.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "..\CHeader.mqh"
#include "CPriceChannelStatus.mqh"

class CPriceChannelStatusList
  {
private: 
      CPriceChannelStatus  priceChlStatusArr[10];
public:
                     CPriceChannelStatusList();
                    ~CPriceChannelStatusList();
     
     //--- get CPriceChannelStatus
     CPriceChannelStatus*   getChannelStatus(int level);
};


//+------------------------------------------------------------------+
//  get edge strengthRate
//+------------------------------------------------------------------+
CPriceChannelStatus* CPriceChannelStatusList::getChannelStatus(int level){
   return &this.priceChlStatusArr[level];
}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CPriceChannelStatusList::CPriceChannelStatusList(){
   //for(int i=0;i<10;i++){
   //   priceChlStatusArr[i]=new CPriceChannelStatus();
   //}
}
CPriceChannelStatusList::~CPriceChannelStatusList(){}