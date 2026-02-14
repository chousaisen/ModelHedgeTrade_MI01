//+------------------------------------------------------------------+
//|                                           CRange.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\..\..\comm\CBase.mqh"
#include "..\..\..\client\CClientCtl.mqh"
#include "..\..\symbol\CSymbolInfos.mqh"
#include "..\..\indicator\CIndicatorShare.mqh"

class CRange: public CBase{
  private: 
         CSymbolInfos*          symbolInfos;
         CIndicatorShare*       indicatorShare;          
         double                 upperBreakLine;
         double                 downBreakLine;
         double                 upperRate;
         double                 downRate;
         double                 channelUpperLine;
         double                 channelUpperRate;
         double                 channelDownLine;
         double                 channelDownRate;
         datetime               statusStartTime;
         double                 statusPassedSeconds;         
         double                 point;
         double                 rangePips;
         double                 rangeDiffPips;
         double                 breakPips;
         double                 breakMaxPips;
         //--- range grid line
         //double                 upperGridLine[];
         //bool                   upperGridHit;
         //double                 downGridLine[];
         //bool                   downGridHit;         
         //--- range status
         int                    statusFlg;
         int                    statusDetailFlg;
         int                    statusIndex;         
         int                    preStatusFlg;
         //--- reload flag
         bool                   reloadFlg;
  public:
                        CRange();
                        ~CRange();
         
          //--- init 
          void          init(CSymbolInfos* symbolInfos);    
          
          //---------------------------------------------
          //--- parameter set functions
          //---------------------------------------------
          void       setIndShare(CIndicatorShare* indShare){this.indicatorShare=indShare;}
          int        getStatusFlg(){return this.statusFlg;}
          int        getStatusDetailFlg(){return this.statusDetailFlg;}
          int        getStatusIndex(){return this.statusIndex;}
          double     getUpperRate(){return this.upperRate;}
          double     getDownRate(){return this.downRate;}   
          double     getChannelUpperRate(){return this.channelUpperRate;}
          double     getChannelDownRate(){return this.channelDownRate;}
          double     getRangePips(){return this.rangePips;}  
          double     getBreakPips(){return this.breakPips;}  
          int        getStatusPassedSeconds(){return this.statusPassedSeconds;}              
          //--- make range status
          void       makeStatus(int symbolIndex); 
          //--- reload status when revoery data
          void       reload();
          void       markReload();         
};
  
//+------------------------------------------------------------------+
//|  init
//+------------------------------------------------------------------+
void CRange::init(CSymbolInfos* symbolInfos){
   this.symbolInfos=symbolInfos;
   this.rangePips=0;
   this.breakPips=0;
   this.breakMaxPips=0;
   this.statusPassedSeconds=0;
}


//+------------------------------------------------------------------+
//|  make status
//+------------------------------------------------------------------+
void CRange::makeStatus(int symbolIndex){
   
   double curPrice=this.symbolInfos.getSymbolPrice(SYMBOL_LIST[symbolIndex],ORDER_TYPE_BUY);
   this.point=this.symbolInfos.getSymbolPoint(SYMBOL_LIST[symbolIndex]);
   
   CChannel* curChannel=this.indicatorShare.getChannel();
   
   if(curChannel.getStatus()==IND_TREND_NONE)return;   
   
   this.channelUpperLine=curChannel.getUpperEdge();   
   this.channelDownLine=curChannel.getDownEdge();
   
   double channelHeight=curChannel.getChlHeight();
   double priceClose = iClose(SYMBOL_LIST[symbolIndex],PERIOD_M1,0);    // 获取当前收盘价

   this.channelUpperRate=curChannel.getUpperRate();
   this.channelDownRate=curChannel.getDownRate();

   this.upperBreakLine=curChannel.getBreakUpperEdge();
   this.downBreakLine=curChannel.getBreakDownEdge();

   this.rangeDiffPips=curChannel.getChlBreakHeight();   
   int curPreStatusFlg=this.statusFlg;
   this.breakPips=0;      
   
   /*   
   if(this.statusFlg==STATUS_NONE || this.statusFlg==STATUS_RANGE_INNER){
      if(curChannel.getStatus()==IND_TREND_UP && this.rangeDiffPips>Range_Edge_Break_Diff_Pips){
         this.statusFlg=STATUS_RANGE_BREAK_UP;
         this.statusDetailFlg=STATUS_RANGE_BREAK_UP;  
      }else if(curChannel.getStatus()==IND_TREND_DOWN && this.rangeDiffPips>Range_Edge_Break_Diff_Pips){
         this.statusFlg=STATUS_RANGE_BREAK_DOWN;
         this.statusDetailFlg=STATUS_RANGE_BREAK_DOWN;
      }else{
         this.statusFlg=STATUS_RANGE_INNER;
         this.statusDetailFlg=STATUS_RANGE_INNER;
      }
   }else if(this.statusFlg==STATUS_RANGE_BREAK_UP 
            || this.statusFlg==STATUS_RANGE_BREAK_DOWN){
      if(curChannel.getStatus()==IND_TREND_RANGE){
         this.statusFlg=STATUS_RANGE_INNER;
         this.statusDetailFlg=STATUS_RANGE_INNER;
      }      
   }*/
   
   
   if(curChannel.getStatus()==IND_TREND_UP && this.rangeDiffPips>Range_Edge_Break_Diff_Pips){
      this.statusFlg=STATUS_RANGE_BREAK_UP;
      this.statusDetailFlg=STATUS_RANGE_BREAK_UP;  
   }else if(curChannel.getStatus()==IND_TREND_DOWN && this.rangeDiffPips>Range_Edge_Break_Diff_Pips){
      this.statusFlg=STATUS_RANGE_BREAK_DOWN;
      this.statusDetailFlg=STATUS_RANGE_BREAK_DOWN;
   }else{
      this.statusFlg=STATUS_RANGE_INNER;
      this.statusDetailFlg=STATUS_RANGE_INNER;
   }
      
   
   //break pips
   if(this.statusFlg==STATUS_RANGE_BREAK_UP){
      this.rangePips=0;
      if(this.upperBreakLine>0){
         this.breakPips=(curPrice-this.upperBreakLine)/this.point;
      }   
      // range break up return
      if(this.statusDetailFlg==STATUS_RANGE_BREAK_UP){
         if(this.breakPips<Trend_To_Range_Less_Pips){
            this.statusDetailFlg=STATUS_RANGE_BREAK_UP_RE;
         } 
      }else if(this.statusDetailFlg==STATUS_RANGE_BREAK_UP_RE){
         if(this.breakPips>Trend_To_Range_Recover_Pips){
            this.statusDetailFlg=STATUS_RANGE_BREAK_UP;
         }
      }            
   }
   else if(this.statusFlg==STATUS_RANGE_BREAK_DOWN){
      this.rangePips=0;
      if(this.downBreakLine>0){
         this.breakPips=(this.downBreakLine-curPrice)/this.point;
      }        
      // range break up return
      if(this.statusDetailFlg==STATUS_RANGE_BREAK_DOWN){
         if(this.breakPips<Trend_To_Range_Less_Pips){
            this.statusDetailFlg=STATUS_RANGE_BREAK_DOWN_RE;
         } 
      }else if(this.statusDetailFlg==STATUS_RANGE_BREAK_DOWN_RE){
         if(this.breakPips>Trend_To_Range_Recover_Pips){
            this.statusDetailFlg=STATUS_RANGE_BREAK_DOWN;
         }
      }            
   }else{
      //range 
      this.breakPips=0;           
      this.rangePips=curChannel.getChlHeight();
   }   
   
   //max break pips
   if(this.breakMaxPips<this.breakPips){
      this.breakMaxPips=this.breakPips;
   }
   
   //when status change
   if(curPreStatusFlg!=this.statusFlg){                   
                        
      //******* test begin ****************                  
      string logTemp ="<rangeStatus change>" + rkeeLog.rangeStatusName(this.statusFlg)
                     + "<rangeStatusDetail>" + rkeeLog.rangeStatusName(this.statusDetailFlg)
                     + "<preStatusFlg>" + rkeeLog.rangeStatusName(curPreStatusFlg)
                     + "<rangeDiffPips>" + this.rangeDiffPips
                     + "<breakPips>" + this.breakPips 
                     + "<upperRate>" + this.upperRate
                     + "<downRate>" + this.downRate
                     + "<upperBreakLine>" + this.upperBreakLine
                     + "<downBreakLine>" + this.downBreakLine;

      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"rangeStatus");       
      //******** test end ****************
      
      this.statusIndex++;
      this.breakMaxPips=0;
      this.preStatusFlg=curPreStatusFlg;
      this.statusStartTime=TimeCurrent();       
            
   }
   
   //status pased seconds
   this.statusPassedSeconds=TimeCurrent()-this.statusStartTime;
   
   
   //******* test begin ****************
   rkeeLog.printDiffTimeLog(1,1000,
                           " CRange>>  cur:" + rkeeLog.indTrendStatusName(curChannel.getStatus())
                           + " pre:" + rkeeLog.indTrendStatusName(curChannel.getPreBreakStatus()) 
                           + " rangeStatus:" + rkeeLog.rangeStatusName(this.statusFlg)
                           + " dStatus:" + rkeeLog.rangeStatusName(this.statusDetailFlg)                           
                           + " breakHeight:" + StringFormat("%.2f",curChannel.getChlBreakHeight())
                           + " -------"
                           + " uRate:" + StringFormat("%.2f",curChannel.getUpperRate())
                           + " dRate:" + StringFormat("%.2f",curChannel.getDownRate())
                           + " Height:" + StringFormat("%.2f",curChannel.getChlHeight())
                           + " topEdge:" + StringFormat("%.2f",curChannel.getUpperEdge()) 
                           + " downEdge:" + StringFormat("%.2f",curChannel.getDownEdge()));     
      
   
   if(rkeeLog.debugPeriod(9211,300)){
                                          
      string logTemp ="<rangeStatus>" + rkeeLog.rangeStatusName(this.statusFlg)
                     + "<dStatus>" + rkeeLog.rangeStatusName(this.statusDetailFlg) 
                     + "<chlStatus>" + rkeeLog.indTrendStatusName(curChannel.getStatus())                      
                     + "<rangeDiffPips>" + this.rangeDiffPips
                     + "<breakPips>" + this.breakPips 
                     + "<upperRate>" + this.upperRate
                     + "<downRate>" + this.downRate
                     + "<upperBreakLine>" + this.upperBreakLine
                     + "<downBreakLine>" + this.downBreakLine;

      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"rangeStatus");
   }
   
   //******** test end ****************
}

 
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CRange::CRange(){
   this.statusIndex=0;
   this.statusFlg=STATUS_NONE; 
   this.statusDetailFlg=STATUS_NONE;
   this.preStatusFlg=STATUS_NONE; 
   this.statusStartTime=TimeCurrent();
   this.upperRate=0;
   this.downRate=0; 
   this.rangePips=0; 
}
CRange::~CRange(){
}