#include <MQL5Converter\Converter.mqh>
//+------------------------------------------------------------------+
//|                                                    RkeeInd01.mqh |
//|                                    Copyright 2019,  NIHHO ROKKI. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, NIHHO ROKKI."
#property link      "https://www.rkee.co.jp"
#property strict
//+------------------------------------------------------------------+
//| v10   rkee tick data calculate                                   |
//+------------------------------------------------------------------+
#include "..\\..\\comm\\RkeeSymbolList.mqh"
#include "..\\rkee\\comm\\RkeeData.mqh"

class RkeeChannel{   
   
   int    timeFrame;
   string indName;
   int    period;
   
   int periodList[];
   int maxPeriodCount;      
   int iCustom_handle[HG_SYMBOL_NUM][30];
   
   public:   
   RkeeChannel(){      
      timeFrame=PERIOD_H4;
      indName="RkeeIndChannel"; 
      period=50;      
      maxPeriodCount=30;
      ArrayInitialize(iCustom_handle,-1);
   }; 
   
   //set parameter  
   void setParam(int pTimeFrame,int sPeriod){
      timeFrame=pTimeFrame;
      period=sPeriod;
      for(int symbolIndex=SYMBOL.startIndex();symbolIndex<=SYMBOL.endIndex();symbolIndex++){
         if(!SYMBOL.activeSymbol(symbolIndex))continue;   
         if(iCustom_handle[symbolIndex][0]<0){
            string symbol=SYMBOL.getSymbol(symbolIndex);
            iCustomParam(symbol,pTimeFrame,sPeriod);    
         }
      }
   }   
   
   //make channel info
   void makeChannelInfo(string symbol,int bShift,CHANNEL_INFO &channleInfo){ 

      double middleLine=getIndValue(symbol,2,bShift);
      double topLineEdge=getIndValue(symbol,0,bShift);
      double lowLineEdge=getIndValue(symbol,1,bShift);  

      if(middleLine>0)channleInfo.middleLine=middleLine;
      if(topLineEdge>0)channleInfo.topLineEdge=topLineEdge;
      if(lowLineEdge>0)channleInfo.lowLineEdge=lowLineEdge;  
      
      channleInfo.topLine1=channleInfo.topLineEdge;
      channleInfo.lowLine1=channleInfo.lowLineEdge;
   
      channleInfo.topLine2=channleInfo.topLineEdge;
      channleInfo.lowLine2=channleInfo.lowLineEdge;   
      
      //if(timeFrame==240)
      //printf("timeFrame:" + timeFrame + " period:" + period +  " topLine:" + channleInfo.topLineEdge + " lowLine:" + channleInfo.lowLineEdge + " middleLine:" + channleInfo.middleLine);    
   }   
   
   int getRangePips(string symbol,int period,int shift){

      double topLine2=getIndValue(symbol,0,shift);
      double lowLine2=getIndValue(symbol,1,shift);      
      double point=MarketInfo(symbol,MODE_POINT); 
      return MathAbs(topLine2-lowLine2)/point;
   }      
   
   ///////////////////////////////////////////////////////////////
   //get indicator value
   ///////////////////////////////////////////////////////////////
   double getIndValue(string symbol,int indIndex,int shift){   
      return rkeeICustom(symbol,
                           timeFrame,
                           period,
                           indIndex,
                           shift); 
   }   
    
   double rkeeICustom(string symbol,
                         int timeFrame,
                         int sPeriod,                        
                         int indIndex,
                         int shift){
      if(shift>=30)shift=29;
      int curHandle=iCustomParam(symbol,timeFrame,sPeriod);              
      double buffer[1];
      if(CopyBuffer(curHandle, indIndex, shift, 1, buffer) < 0) {
         return(0);
      }
      return(buffer[0]);                                 
   }   
   
   
   //custom indicator interface
   int iCustomParam(string symbol,
                         int timeFrame,
                         int sPeriod){
      
      int symbolIndex=SYMBOL.getSymbolIndex(symbol);
      int pIndex=getPeriodIndex(period);
      if(iCustom_handle[symbolIndex][pIndex]<0 && pIndex>=0){
         iCustom_handle[symbolIndex][pIndex]=iCustom(symbol,IntegerToTimeframe(timeFrame),indName,sPeriod); 
           if(iCustom_handle[symbolIndex][pIndex]<0){
            printf(indName + "| error = " + GetLastError());
           }                                           
       } 
       //default indicator
       if(pIndex<0)return iCustom_handle[symbolIndex][0]; 
       return iCustom_handle[symbolIndex][pIndex]; 
   }
   
   //get period index
   int getPeriodIndex(int indPeriod){      
      int periodCount=ArraySize(periodList);
      int pIndex=-1;
      if(periodCount>0){
         for(int index=0;index<periodCount;index++){
            if(periodList[index]==indPeriod){
               pIndex=index;
               break;
            }   
         }
      }      
      if(pIndex!=-1)return pIndex;
      else if(periodCount<maxPeriodCount){
         ArrayResize(periodList,periodCount+1);
         periodList[periodCount]=indPeriod;
         pIndex=periodCount;
      }      
      return pIndex; 
   }   
       
   
};