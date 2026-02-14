//+------------------------------------------------------------------+
//|                                                  CIndicatorShare.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "..\..\header\symbol\CHeader.mqh"
#include "..\..\indicator\strength\CHeader.mqh"
#include "..\..\comm\ComFunc.mqh"
#include "data\CPriceSpeed.mqh"
#include "data\CBandStatus.mqh"
#include "data\CTickStatus.mqh"
#include "data\CPriceChannelStatus.mqh"
#include "data\CPriceChannelStatusList.mqh"
#include "data\CPriceChlStatus.mqh"
#include "..\analysis\status\CChannel.mqh"

class CIndicatorShare
  {
private:      
       double                    symbolCorrelationMatrix[SYMBOL_MAX_COUNT][SYMBOL_MAX_COUNT]; // correlation matrix
       double                    symbolVolatilityWeight[SYMBOL_MAX_COUNT];                    //volatility weight 
       CPriceSpeed               symbolPriceSpeed[SYMBOL_MAX_COUNT];                          //price speed
       CBandStatus               symbolBandStatus[SYMBOL_MAX_COUNT];                          //band status
       CTickStatus               symbolTickStatus[SYMBOL_MAX_COUNT];                          //tick status
       CPriceChannelStatus       symbolPriceChlStatus[SYMBOL_MAX_COUNT];                      //price channel status
       CPriceChlStatus           symbolPriceChlStatus2[SYMBOL_MAX_COUNT];                     //price channel2 status
       CPriceChannelStatusList   symbolPriceChannelStatusList[SYMBOL_MAX_COUNT];              //price channel status List
       int                       symbolPriceChannelShiftLevel[SYMBOL_MAX_COUNT];              //price channel status shift level
       double                    symbolPriceChannelSumEdgeRate[SYMBOL_MAX_COUNT];             //price channel sum edge rate
       double                    symbolPriceChannelSumStrengthRate[SYMBOL_MAX_COUNT];         //price channel sum stength rate
       double                    symbolPriceChannelSumStrengthRate2[SYMBOL_MAX_COUNT];        //price channel sum stength rate2
       double                    symbolPriceChannelSumEdgeDiffPips[SYMBOL_MAX_COUNT];         //price channel sum edge diff pips       
       
       //--- share indicator
       CChannel*              curChannel;
       
public:
                     CIndicatorShare();
                    ~CIndicatorShare();
     
     //--- methods of initilize
     void            init(); 
     //--- refresh
     void            refresh(); 
     //--- run CIndicatorShare
     void            run();
     //--- set symbol correlation
     void            setSymbolCorrelation(int symbolIndex1,int symbolIndex2,double value);
     //--- get symbol correlation
     double          getSymbolCorrelation(int symbolIndex1,int symbolIndex2);
     //--- set symbol volatility weight
     void            setSymbolVolatilityWeight(int symbolIndex,double value);
     //--- get symbol volatility weight
     double          getSymbolVolatilityWeight(int symbolIndex);
     //--- set price speed
     void            setPriceSpeed(int symbolIndex,int level,int status);
     //--- get price speed
     int             getPriceSpeed(int symbolIndex,int level); 
     //--- get price speed stable
     bool            getPriceSpeedStable(int symbolIndex);
     //--- get price speed acceleration
     bool            getPriceSpeedAcceleration(int symbolIndex);
     //--- get price speed acceleration by speed level
     bool            getPriceSpeedAcceleration(int symbolIndex,int speedLevel);
     //--- set band status
     void            setBandStatus(int symbolIndex,int level,ENUM_STATE status);
     //--- get band status
     ENUM_STATE      getBandStatus(int symbolIndex,int level);     
     //--- set tick status
     void            setTickStatus(int symbolIndex,ENUM_TICK_STATE status);
     //--- get tick status
     ENUM_TICK_STATE getTickStatus(int symbolIndex);
     //--- set edge rate
     void            setEdgeRate(int symbolIndex,double value);
     //--- get edge rate
     double          getEdgeRate(int symbolIndex);
     //--- set edge strengthRate
     void            setStrengthRate(int symbolIndex,double value);
     //--- get edge strengthRate
     double          getStrengthRate(int symbolIndex);
     //--- get price channel status
     CPriceChannelStatus* getPriceChannelStatus(int symbolIndex);  
     //--- get price channel status by level
     //CPriceChannelStatus* getDiffPriceChannelStatus(int symbolIndex,int diffShift);
     //--- get price channel status by level
     CPriceChannelStatus* getPriceChannelStatus(int symbolIndex,int level);
     //--- get price channel status2
     CPriceChlStatus*     getPriceChannelStatus2(int symbolIndex);     
     //--- get current price  channel shift level
     int                  getPriceChlShiftLevel(int symbolIndex);
     //--- set current price  channel shift level
     void                 setPriceChlShiftLevel(int symbolIndex,int value);
     //--- get current price  channel sum edge rate
     double               getPriceChlSumEdgeRate(int symbolIndex);
     //--- set current price  channel sum edge rate
     void                 setPriceChlSumEdgeRate(int symbolIndex,double value);
     //--- get current price  channel sum Strength rate
     double               getPriceChlSumStrengthRate(int symbolIndex);
     //--- set current price  channel sum Strength rate
     void                 setPriceChlSumStrengthRate(int symbolIndex,double value);   
     //--- get current price  channel sum Strength rate
     double               getPriceChlSumStrengthRate2(int symbolIndex);
     //--- set current price  channel sum Strength rate
     void                 setPriceChlSumStrengthRate2(int symbolIndex,double value);        
     //--- get current price  channel sum edge diff pips
     double               getPriceChlSumEdgeDiffPips(int symbolIndex);
     //--- set current price  channel sum edge diff pips
     void                 setPriceChlSumEdgeDiffPips(int symbolIndex,double value); 
     //--- set channel
     void                 setChannel(CChannel*  channel){this.curChannel=channel;};
     //--- get channel
     CChannel*            getChannel(){return this.curChannel;};
           
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CIndicatorShare::init()
  {
   
  }
//+------------------------------------------------------------------+
//|  run the share control
//+------------------------------------------------------------------+
void CIndicatorShare::run()
  {
   
  }   

//+------------------------------------------------------------------+
//|  set symbol correlation value
//+------------------------------------------------------------------+
void CIndicatorShare::setSymbolCorrelation(int symbolIndex1,
                                             int symbolIndex2,
                                             double value){
   this.symbolCorrelationMatrix[symbolIndex1][symbolIndex2]=value;
}

//+------------------------------------------------------------------+
//|  get symbol correlation value
//+------------------------------------------------------------------+
double CIndicatorShare::getSymbolCorrelation(int symbolIndex1,
                                             int symbolIndex2){
   return this.symbolCorrelationMatrix[symbolIndex1][symbolIndex2];

}

//+------------------------------------------------------------------+
//|  set symbol volatility weight
//+------------------------------------------------------------------+
void CIndicatorShare::setSymbolVolatilityWeight(int symbolIndex,double value){
   this.symbolVolatilityWeight[symbolIndex]=value;
}

//+------------------------------------------------------------------+
//|  get symbol volatility weight
//+------------------------------------------------------------------+
double CIndicatorShare::getSymbolVolatilityWeight(int symbolIndex){
   return this.symbolVolatilityWeight[symbolIndex];
}

//+------------------------------------------------------------------+
//|  set price speed
//+------------------------------------------------------------------+
void CIndicatorShare::setPriceSpeed(int symbolIndex,int level,int status){
   this.symbolPriceSpeed[symbolIndex].setPriceSpeed(level,status);
}

//+------------------------------------------------------------------+
//|  get price speed
//+------------------------------------------------------------------+
int CIndicatorShare::getPriceSpeed(int symbolIndex,int level){
   return this.symbolPriceSpeed[symbolIndex].getPriceSpeed(level);
}

//+------------------------------------------------------------------+
//|  get price speed stable
//+------------------------------------------------------------------+
bool CIndicatorShare::getPriceSpeedStable(int symbolIndex){
   int lv1=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_1);
   int lv2=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_2);
   int lv3=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_3);
   int lv4=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_4);
   int lv5=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_5);
   if(lv1<PRICE_SPEED_ACCELERATING
       && lv2<PRICE_SPEED_ACCELERATING
       && lv3<PRICE_SPEED_ACCELERATING
       && lv4<PRICE_SPEED_ACCELERATING
       && lv5<PRICE_SPEED_ACCELERATING){
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//|  get price speed Acceleration
//+------------------------------------------------------------------+
bool CIndicatorShare::getPriceSpeedAcceleration(int symbolIndex){
   int lv1=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_1);
   int lv2=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_2);
   int lv3=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_3);
   int lv4=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_4);
   int lv5=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(PRICE_SPEED_LEVEL_5);
   if(lv1>PRICE_SPEED_STABLE ||
         ( lv2>PRICE_SPEED_STABLE
             || lv3>PRICE_SPEED_STABLE
             || lv4>PRICE_SPEED_STABLE
             || lv5>PRICE_SPEED_STABLE)
      ){
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//|  get price speed Acceleration
//+------------------------------------------------------------------+
bool CIndicatorShare::getPriceSpeedAcceleration(int symbolIndex,int speedLevel){
   int lv5=this.symbolPriceSpeed[symbolIndex].getPriceSpeed(speedLevel);
   if(lv5==PRICE_SPEED_ACCELERATING){
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//|  set band status
//+------------------------------------------------------------------+
void CIndicatorShare::setBandStatus(int symbolIndex,int level,ENUM_STATE status){
   this.symbolBandStatus[symbolIndex].setStatus(level,status);
}

//+------------------------------------------------------------------+
//|  get price speed
//+------------------------------------------------------------------+
ENUM_STATE CIndicatorShare::getBandStatus(int symbolIndex,int level){
   return this.symbolBandStatus[symbolIndex].getStatus(level);
}

//+------------------------------------------------------------------+
//|  set tick status
//+------------------------------------------------------------------+
void CIndicatorShare::setTickStatus(int symbolIndex,ENUM_TICK_STATE status){
   this.symbolTickStatus[symbolIndex].setTickStatus(status);
}

//+------------------------------------------------------------------+
//|  get tick status
//+------------------------------------------------------------------+
ENUM_TICK_STATE CIndicatorShare::getTickStatus(int symbolIndex){
   return this.symbolTickStatus[symbolIndex].getTickStatus();
}

//+------------------------------------------------------------------+
// set edge rate
//+------------------------------------------------------------------+
void CIndicatorShare::setEdgeRate(int symbolIndex,double value){
   this.symbolPriceChlStatus[symbolIndex].setEdgeRate(value);
}

//+------------------------------------------------------------------+
//  get edge rate
//+------------------------------------------------------------------+
double CIndicatorShare::getEdgeRate(int symbolIndex){
   CPriceChannelStatus* chlStatus=this.getPriceChannelStatus(symbolIndex);
   return chlStatus.getEdgeRate();
   //return this.symbolPriceChlStatus[symbolIndex].getEdgeRate();
}

//+------------------------------------------------------------------+
//  set edge strengthRate
//+------------------------------------------------------------------+
void CIndicatorShare::setStrengthRate(int symbolIndex,double value){   
   this.symbolPriceChlStatus[symbolIndex].setStrengthRate(value);
}

//+------------------------------------------------------------------+
//  get edge strengthRate
//+------------------------------------------------------------------+
double CIndicatorShare::getStrengthRate(int symbolIndex){
   CPriceChannelStatus* chlStatus=this.getPriceChannelStatus(symbolIndex);
   return chlStatus.getStrengthRate();
   //return this.symbolPriceChlStatus[symbolIndex].getStrengthRate();
}

//+------------------------------------------------------------------+
//  get price channel status
//+------------------------------------------------------------------+
CPriceChannelStatus*  CIndicatorShare::getPriceChannelStatus(int symbolIndex){
   //int curShiftLevel=this.symbolPriceChannelShiftLevel[symbolIndex]-1;
   //if(curShiftLevel<0)curShiftLevel=0;   
   //return this.symbolPriceChannelStatusList[symbolIndex].getChannelStatus(curShiftLevel);   
   return &this.symbolPriceChlStatus[symbolIndex];
}

//+------------------------------------------------------------------+
//  get price channel status
//+------------------------------------------------------------------+
/*
CPriceChannelStatus*  CIndicatorShare::getDiffPriceChannelStatus(int symbolIndex,int diffShift){
   int curShiftLevel=this.symbolPriceChannelShiftLevel[symbolIndex]+diffShift-1;
   if(curShiftLevel<0)curShiftLevel=0;
   if(curShiftLevel>(Ind_Strength_Shift_Count-1))curShiftLevel=Ind_Strength_Shift_Count-1;   
   return this.symbolPriceChannelStatusList[symbolIndex].getChannelStatus(curShiftLevel);      
   //return &this.symbolPriceChlStatus[symbolIndex];
}*/

//+------------------------------------------------------------------+
//  get price channel status
//+------------------------------------------------------------------+
CPriceChannelStatus*  CIndicatorShare::getPriceChannelStatus(int symbolIndex,int level){
   return this.symbolPriceChannelStatusList[symbolIndex].getChannelStatus(level);
}

//+------------------------------------------------------------------+
//--- get current price  channel shift level
//+------------------------------------------------------------------+
int  CIndicatorShare::getPriceChlShiftLevel(int symbolIndex){
   return this.symbolPriceChannelShiftLevel[symbolIndex];
}

//+------------------------------------------------------------------+
//--- set current price  channel shift level
//+------------------------------------------------------------------+
void  CIndicatorShare::setPriceChlShiftLevel(int symbolIndex,int value){
   this.symbolPriceChannelShiftLevel[symbolIndex]=value;
}

//+------------------------------------------------------------------+
//--- get current price  channel sum edge rate
//+------------------------------------------------------------------+
double  CIndicatorShare::getPriceChlSumEdgeRate(int symbolIndex){
   return this.symbolPriceChannelSumEdgeRate[symbolIndex];
}

//+------------------------------------------------------------------+
//--- set current price  channel sum edge rate
//+------------------------------------------------------------------+
void  CIndicatorShare::setPriceChlSumEdgeRate(int symbolIndex,double value){
   this.symbolPriceChannelSumEdgeRate[symbolIndex]=value;
}

//+------------------------------------------------------------------+
//--- get current price  channel sum Strength rate
//+------------------------------------------------------------------+
double  CIndicatorShare::getPriceChlSumStrengthRate(int symbolIndex){
   return this.symbolPriceChannelSumStrengthRate[symbolIndex];
}

//+------------------------------------------------------------------+
//--- set current price  channel sum Strength rate
//+------------------------------------------------------------------+
void  CIndicatorShare::setPriceChlSumStrengthRate(int symbolIndex,double value){
   this.symbolPriceChannelSumStrengthRate[symbolIndex]=value;
}

//+------------------------------------------------------------------+
//--- get current price  channel sum Strength rate
//+------------------------------------------------------------------+
double  CIndicatorShare::getPriceChlSumStrengthRate2(int symbolIndex){
   return this.symbolPriceChannelSumStrengthRate2[symbolIndex];
}

//+------------------------------------------------------------------+
//--- set current price  channel sum Strength rate
//+------------------------------------------------------------------+
void  CIndicatorShare::setPriceChlSumStrengthRate2(int symbolIndex,double value){
   this.symbolPriceChannelSumStrengthRate2[symbolIndex]=value;
}

//+------------------------------------------------------------------+
//--- get current price  channel sum edge diff pips
//+------------------------------------------------------------------+
double  CIndicatorShare::getPriceChlSumEdgeDiffPips(int symbolIndex){
   return this.symbolPriceChannelSumEdgeDiffPips[symbolIndex];
}

//+------------------------------------------------------------------+
//--- set current price  channel sum edge diff pips
//+------------------------------------------------------------------+
void  CIndicatorShare::setPriceChlSumEdgeDiffPips(int symbolIndex,double value){
   this.symbolPriceChannelSumEdgeDiffPips[symbolIndex]=value;
}

//+------------------------------------------------------------------+
//  get price channel2 status
//+------------------------------------------------------------------+
CPriceChlStatus*  CIndicatorShare::getPriceChannelStatus2(int symbolIndex){
   return &this.symbolPriceChlStatus2[symbolIndex];
} 

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CIndicatorShare::CIndicatorShare(){
   ArrayInitialize(this.symbolPriceChannelShiftLevel,-1);
}
CIndicatorShare::~CIndicatorShare(){}