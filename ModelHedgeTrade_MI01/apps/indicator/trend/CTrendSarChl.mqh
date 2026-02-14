//+------------------------------------------------------------------+
//|                                                 IndicatorCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../share/symbol/CSymbolShare.mqh"
#include "../../share/analysis/CAnalysisShare.mqh"
#include "../../share/analysis/status/CChannel.mqh"

class CTrendSarChl{
   private:
   
      CSymbolShare*          symbolShare;
      CAnalysisShare*        analysisShare;
      
      //channel info
      CChannel               curChannel;
      CChannel               breakChannel;

      //--- handle list
      int    Handles[3000]; 
      int    chlHandle;
      string chlIndName;
      int    chlPeriod;
                     
      //--- time frame
      ENUM_TIMEFRAMES  sarTimeFrame;
      double           sarMaxStep;
      double           sarStartStep;
      double           sarStepUnit;
      
      //--- symbol
      int              symbolIndex;
      string           symbol;
      
      //--- current handle index
      int              curHandleIndex;
      int              maxHandleIndex;
      
      //--- currrent status
      int              curStatus;
      int              preStatus; 
      int              preBreakStatus;
      datetime         preBreakPosTime;
      
      //--- support line
      double           topSupportLine;
      double           downSupportLine;
      
   public:
                        CTrendSarChl();
                       ~CTrendSarChl();
        //--- init 
        void            init(int symbolIndex,
                              CSymbolShare*  symbolShare,
                              CAnalysisShare*  analysisShare,
                                 ENUM_TIMEFRAMES  timeFrame,
                                 double sarStepUnit,
                                 double sarStartStep,
                                 double sarMaxStep);
        //-- make indicators handle
        void            makeIndicators();

        //--- run indicator
        void            run();
        
        //--- init previous break shift pos(time by sar timeFrame)   
        void            initPreBreakPos();
        
        //--- get current shift status
        int            getShiftStatus(int shift);
        
        //---  get break previous shift
        int            getPreBreakShift(); 
        
        //---  refresh channel info
        void           refreshChannel(int shift,CChannel* chl);
        
        //--- get channel info
        CChannel*     getChannel(){return &this.curChannel;};              
        CChannel*     getBreakChannel(){return &this.breakChannel;}; 
        
        //--- make break info
        void          makeBreakInfo();
        
        //--- adjust data
        void          adjustChannel(CChannel* chl);
  };
  
//+------------------------------------------------------------------+
//|  init the correlation class
//+------------------------------------------------------------------+
void CTrendSarChl::init(int symbolIndex,
                        CSymbolShare*  symbolShare,
                        CAnalysisShare*  analysisShare,
                        ENUM_TIMEFRAMES  timeFrame,
                        double sarStepUnit,
                        double sarStartStep,
                        double sarMaxStep)
{
   this.symbolIndex=symbolIndex;
   this.symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);
   this.symbolShare=symbolShare;  
   this.analysisShare=analysisShare;  
   this.sarTimeFrame=timeFrame;
   this.sarStepUnit=sarStepUnit;
   this.sarMaxStep=sarMaxStep;
   this.sarStartStep=sarStartStep;
   this.curHandleIndex=0;
   this.maxHandleIndex=0;
   this.chlIndName=Ind_Channel_Name;
   this.chlPeriod=Ind_Channel_Period;
   
   this.curStatus=IND_TREND_NONE;
   this.preStatus=IND_TREND_NONE;
   this.preBreakStatus=IND_TREND_NONE;
   
   this.topSupportLine=0;
   this.downSupportLine=0;
   
   this.curChannel.init(symbolIndex,this.symbolShare.getSymbolPoint(this.symbol));
   //this.breakChannel.init(symbolIndex,this.symbolShare.getSymbolPoint(this.symbol));
   this.analysisShare.setChannel(&this.curChannel);
   
   //init indicator   
   this.makeIndicators();
}

//+------------------------------------------------------------------+
//|  make multi channel
//+------------------------------------------------------------------+
void CTrendSarChl::makeIndicators(){      
   
   //make SAR(trend indicator) list   
   for(int i = 0; i < 100; i++){
      double step=((double)(i))*this.sarStepUnit+this.sarStartStep;  
      Handles[i] = iSAR(this.symbol, this.sarTimeFrame, step, this.sarMaxStep);
      if(Handles[i] == INVALID_HANDLE){
         rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                              + " CTrendSarChl Failed to create handle for period");
         return;
      }
      if(step>this.sarMaxStep){
         this.maxHandleIndex=i;
         break;
      }          
    }
    
    //make channel indicator
    this.chlHandle=iCustom(this.symbol, this.sarTimeFrame, this.chlIndName, this.chlPeriod);     

}



//+------------------------------------------------------------------+
//|  make sar support line data
//+------------------------------------------------------------------+
void  CTrendSarChl::run(void){ 
   
   rkeeLog.writeLmtLog("CTrendSarChl: run");   
   
   //refresh status and channel info(pos shift 0)
   this.curStatus=this.getShiftStatus(0);
   this.curChannel.setStatus(this.curStatus);
   this.refreshChannel(0,&this.curChannel);
   this.adjustChannel(&this.curChannel);   
   
   //refresh break status and channel info   
   if(this.curStatus!=this.preStatus){
      
      //refresh break pos(break time info)
      this.initPreBreakPos(); 
   
      //refresh break channel info
      int breakPosShift=this.getPreBreakShift();
      this.refreshChannel(breakPosShift,&this.breakChannel);
      
      //record previous shift status to judge if status changed
      this.preStatus=this.curStatus;      
   }  
   
   //make break info(break height)
   this.makeBreakInfo();
   
   //******* test begin ****************
    
   rkeeLog.printDiffTimeLog(0,30,
                           " cur:" + rkeeLog.indTrendStatusName(this.curChannel.getStatus())
                           + " pre:" + rkeeLog.indTrendStatusName(this.curChannel.getPreBreakStatus()) 
                           + " break time:" +this.preBreakPosTime
                           + " Height:" + StringFormat("%.2f",this.curChannel.getChlHeight())
                           + " breakHeight:" + StringFormat("%.2f",this.curChannel.getChlBreakHeight())
                           + " uRate:" + StringFormat("%.2f",this.curChannel.getUpperRate())
                           + " dRate:" + StringFormat("%.2f",this.curChannel.getDownRate())
                           + " topEdge:" + StringFormat("%.2f",this.curChannel.getUpperEdge()) 
                           + " downEdge:" + StringFormat("%.2f",this.curChannel.getDownEdge())  
                           + " breakTopEdge:" + StringFormat("%.2f",this.breakChannel.getUpperEdge()) 
                           + " breakDownEdge:" + StringFormat("%.2f",this.breakChannel.getDownEdge()));  
                           
   rkeeLog.writeStatusLog(0,this.curStatus,
                           rkeeLog.indTrendStatusName(this.curChannel.getStatus()) 
                           + " pre:" + rkeeLog.indTrendStatusName(this.curChannel.getPreBreakStatus()) 
                           + " break time:" +this.preBreakPosTime
                           + " topEdge:" + this.curChannel.getUpperEdge() 
                           + " downEdge:" + this.curChannel.getDownEdge());   
   //******** test end ****************
}


//+------------------------------------------------------------------+
//|  get current shift status
//+------------------------------------------------------------------+
int  CTrendSarChl::getShiftStatus(int shift){ 

   string symbol=comFunc.addSuffix(SYMBOL_LIST[this.symbolIndex]);
   int    curStatus=IND_TREND_NONE;
   
   //shift price
   double priceClose = iClose(symbol, this.sarTimeFrame,shift);
   int curTopSupportCount=0,curDownSupportCount=0;
   double curTopSupportLine=100000,curDownSupportLine=0;
   for(int i=0;i<this.maxHandleIndex;i++){

      double sarBuffer[];
      int curHandle=this.Handles[i];
      if (CopyBuffer(curHandle, 0, shift, 1, sarBuffer) > 0) {         
         if (sarBuffer[0] > priceClose) {
            if(curTopSupportLine>sarBuffer[0])curTopSupportLine=sarBuffer[0];
            curTopSupportCount++;
         } else if (sarBuffer[0] < priceClose) {
            if(curDownSupportLine<sarBuffer[0])curDownSupportLine=sarBuffer[0];
            curDownSupportCount++;
         }
      } else {
         rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                        + " SAR data failed to copy buffer data! " + GetLastError());         
         continue;
      }   
    }
    
    if(curTopSupportCount>0 && curDownSupportCount>0){
      curStatus=IND_TREND_RANGE;
    }
    else if(curTopSupportCount>0){
      curStatus=IND_TREND_DOWN;
    }
    else if(curDownSupportCount>0){
      curStatus=IND_TREND_UP;
    }
        
    //record the current support line
    if(shift==0){
      this.topSupportLine=curTopSupportLine;
      this.downSupportLine=curDownSupportLine;    
    }
       
    return curStatus;
}


//+------------------------------------------------------------------+
//|  get init previous shift pos(time by sar timeFrame)
//+------------------------------------------------------------------+
void  CTrendSarChl::initPreBreakPos(){ 

   int skipPreCount=0;
   if(this.curStatus==IND_TREND_RANGE){
      skipPreCount=1;
   }
   
   //get previous trend pos(shift) and time   
   int curSkipCount=0,preBreakPos=0;
   int preShiftStatus=this.curStatus;
   for(int curShift=1;curShift<10000;curShift++){ 
      int curShitStatus=this.getShiftStatus(curShift);   
      if(curShitStatus!=preShiftStatus){
         preShiftStatus=curShitStatus;
         preBreakPos=curShift;
         curSkipCount++;
      }

      //record previous break status
      if(curSkipCount==1){
         this.preBreakStatus=curShitStatus;
         this.curChannel.setPreBreakStatus(this.preBreakStatus);
      }

      //range ship 2 time and trend skip 1 time
      if(curSkipCount>skipPreCount){
         break;
      }
            
   }   
   this.preBreakPosTime=iTime(this.symbol,this.sarTimeFrame,preBreakPos);
}

//+------------------------------------------------------------------+
//|  get break previous shift
//+------------------------------------------------------------------+
int  CTrendSarChl::getPreBreakShift(){
   return iBarShift(this.symbol,this.sarTimeFrame,this.preBreakPosTime);
}

//+------------------------------------------------------------------+
//|  refresh current channel info
//+------------------------------------------------------------------+
void CTrendSarChl::refreshChannel(int shift,CChannel* chl){

   double channelUpper[1],channelLower[1];        
   if(CopyBuffer(this.chlHandle, 0, shift, 1, channelUpper) <= 0 
      || CopyBuffer(this.chlHandle, 1, shift, 1, channelLower) <= 0){
      rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                        + " CTrendSarChl.refreshChannel Failed to copy buffer data to channel." + GetLastError());
      return;
   }
   
   chl.setUpperEdge(channelUpper[0]);
   chl.setDownEdge(channelLower[0]); 
   
   //record current shift channel info
   if(shift==0){
      if(chl.getStatus()==IND_TREND_UP){
         //chl.setSupportLine(this.downSupportLine);
         chl.setDownEdge(this.downSupportLine);
      }else if(chl.getStatus()==IND_TREND_DOWN){
         //chl.setSupportLine(this.topSupportLine);
         chl.setUpperEdge(this.topSupportLine);
      }      
   }  
   
   //shift price
   double shiftClosePrice = iClose(this.symbol, this.sarTimeFrame,shift); 
   chl.makeChannelInfo(shiftClosePrice);
}

//+------------------------------------------------------------------+
//|  make break info
//+------------------------------------------------------------------+
void CTrendSarChl::makeBreakInfo(){   
   double breakHeight=0;   
   if(this.curChannel.getStatus()==IND_TREND_RANGE){      
      if(this.curChannel.getPreBreakStatus()==IND_TREND_UP){
         breakHeight=this.curChannel.getUpperEdge()-this.breakChannel.getUpperEdge();
      }        
      if(this.curChannel.getPreBreakStatus()==IND_TREND_DOWN){
         breakHeight=this.breakChannel.getDownEdge()-this.curChannel.getDownEdge();
      }                    
   }else if(this.curChannel.getStatus()==IND_TREND_UP){
      breakHeight=this.curChannel.getUpperEdge()-this.breakChannel.getUpperEdge();      
   }else if(this.curChannel.getStatus()==IND_TREND_DOWN){
      breakHeight=this.breakChannel.getDownEdge()-this.curChannel.getDownEdge();
   }     
   this.curChannel.setBreakHeight(breakHeight);
   this.curChannel.setBreakUpperEdge(this.breakChannel.getUpperEdge());
   this.curChannel.setBreakDownEdge(this.breakChannel.getDownEdge());
}


//--- adjust data
void CTrendSarChl::adjustChannel(CChannel* chl){

   double curHighPrice=iHigh(this.symbol,this.sarTimeFrame,0);
   double curLowPrice=iHigh(this.symbol,this.sarTimeFrame,0);
   
   if(chl.getUpperEdge()<curHighPrice){
      chl.setUpperEdge(curHighPrice);
   }
   if(chl.getDownEdge()>curLowPrice){
      chl.setDownEdge(curLowPrice);
   }
}


//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CTrendSarChl::CTrendSarChl(){
}
CTrendSarChl::~CTrendSarChl(){}