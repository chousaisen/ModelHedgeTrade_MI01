//+------------------------------------------------------------------+
//|                                           CChannel.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\..\..\comm\ComFunc2.mqh"
#include "..\..\..\client\CClientCtl.mqh"
#include "..\..\symbol\CSymbolInfos.mqh"
#include "CChannel.mqh"

class CBreak{
  private: 
  
         //channel info
         CChannel*               curChannel;
         CChannel*               breakChannel;
         
         //break info
         double         point;
         double         rangePips;
         double         breakPips;      
  public:
                        CBreak();
                        ~CBreak();
                        
         //---------------------------------------------
         //--- getter functions
         //---------------------------------------------
         CChannel*   getCurChannel()       { return curChannel; }
         CChannel*   getBreakChannel()     { return breakChannel; }
         double      getRangePips()        { return rangePips; }
         double      getBreakPips()        { return breakPips; }

         //---------------------------------------------
         //--- setter functions
         //---------------------------------------------
         void        setCurChannel(CChannel* ch)   { curChannel = ch; }
         void        setBreakChannel(CChannel* ch) { breakChannel = ch; }
         void        setPoint(double value)        { point = value; }
         void        setRangePips(double value)    { rangePips = value; }
         void        setBreakPips(double value)    { breakPips = value; }  
         
         //---------------------------------------------
         //--- calculate functions
         //---------------------------------------------
         void        makeBreakInfo(double price,int status);
                 
                  
};

//+------------------------------------------------------------------+
//|  calculate functions
//+------------------------------------------------------------------+
void  CBreak::makeBreakInfo(double price,int curStatus,int preBreakStatus){

   

}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CBreak::CBreak(){
   this.point=0;
   this.rangePips=0; 
   this.breakPips=0;   
}
CBreak::~CBreak(){
}