//+------------------------------------------------------------------+
//|                                                CFilterOpen01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../../../header/CHeader.mqh"
#include "../../../header/indicator/CHeader.mqh"
#include "../../../comm/ComFunc2.mqh"
#include "../CModelIndicatorFilter.mqh"

class CFilterOpen01: public CModelIndicatorFilter 
{
      private:
         bool    riskHedge;
         bool    continueFlg;
         bool    filterResult;
      public:
                CFilterOpen01();
                ~CFilterOpen01();                      
         bool   openFilter(CSignal* signal);
         
         //init filter
         void initFilter();
         //check order type
         bool openFilter_orderType(CSignal *signal);
         //check Exceed To Jump
         bool openFilter_checkExceedToJump(CSignal* signal);
         //check Exceed To Current Jump
         bool openFilter_checkExceedToCurJump(CSignal* signal);
         //check status
         bool   openFilter_checkStatus(CSignal* signal);
         //diff other model pips
         bool   openFilter_diffGrid(CSignal* signal);
         //check hedge rate
         bool   openFilter_hedgeRate(CSignal* signal);         
         //check range pass time
         bool   openFilter_checkPassTime(CSignal* signal);  
         //check channel edge rate
         bool   openFilter_checkChannelEdgeRate(CSignal* signal);
};


//+------------------------------------------------------------------+
//|  filter init
//+------------------------------------------------------------------+
void CFilterOpen01::initFilter(){
   this.continueFlg=true;
   this.filterResult=true;
   this.middleLog="";
   this.riskHedge=false;
}

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter(CSignal* signal){
   
   //init filter
   this.initFilter();
   this.tradeDealLog="<<openFilter>>";   
   
   //check indicator ready
   if(!this.indicatorReady()){
      tradeDealLog+="<indicatorReady>";
      this.filterResult=false;
      this.continueFlg=false;
      this.addDebugInfo(this.filterResult);
   }   
   
   //check order type
   if(this.continueFlg){
      this.filterResult=this.openFilter_orderType(signal);
      this.addDebugInfo(this.filterResult);
   }   
   //check exceed to jump
   if(this.continueFlg){
      this.filterResult=this.openFilter_checkExceedToJump(signal);    
      this.addDebugInfo(this.filterResult);   
   }

   //check exceed to current jump
   if(this.continueFlg){      
      this.filterResult=this.openFilter_checkExceedToCurJump(signal);
      this.addDebugInfo(this.filterResult);
   }   
   //check range or trend status
   if(this.continueFlg){
      this.filterResult=this.openFilter_checkStatus(signal);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   }
   
   //check channel edge rate
   if(this.continueFlg){ 
      this.filterResult=this.openFilter_checkChannelEdgeRate(signal);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   }
      
   //check pass time
   if(this.continueFlg){
      this.filterResult=this.openFilter_checkPassTime(signal);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   }
   
   //check hedge rate
   if(this.continueFlg){
      this.filterResult=this.openFilter_hedgeRate(signal);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   }

   //diff grid pips
   if(this.continueFlg){   
      this.filterResult=this.openFilter_diffGrid(signal);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   } 
   
      
   if(this.filterResult || rkeeLog.debugPeriod(9121,300)){
      this.middleLog= "<openFilter>" + this.filterResult 
                      + "<type>"+ comFunc.getOrderType(signal.getTradeType())
                      + "---" +  this.middleLog;
      //if(reValue)logData.addDebugInfo(this.middleLog);                      
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.middleLog,
                        "CFilterOpen01");
   } 
   
   return this.filterResult;
}


//+------------------------------------------------------------------+
//|  filter the open order type
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_orderType(CSignal *signal){

   if(Comm_Trade_Single_Type){
      tradeDealLog="<<checkOrderType>>";
      if(signal.getTradeType()==Comm_Trade_Single_Order_Type){
         return true;
      }
      this.continueFlg=false;
      return false;
   }   
   return true;
}

//+------------------------------------------------------------------+
//|  filter the open model exceed jump
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_checkExceedToJump(CSignal* signal){

   if(!GRID_OPEN_EXCEED_JUMP)return true;

   bool reValue=true;
   tradeDealLog="<<checkExceedToJump>>";
   tradeDealLog+="<ExceedProfit>" + StringFormat("%.2f",this.getModelShare().getModelAnalysisPre().getExceedCurProfit());
   tradeDealLog+="<exceedSameType>" + this.exceedSameType(signal.getTradeType());   
   
   //exceed to jump
   if(this.exceedToJump(GRID_OPEN_EXCEED_JUMP_MIN_PIPS)){
      tradeDealLog+="<exceedToJump>";
      if(!this.exceedSameType(signal.getTradeType())){
         tradeDealLog+="<exceedSameType>false";
         this.continueFlg=false;
         reValue=false;
      }      
   }   
   return reValue;
}

//+------------------------------------------------------------------+
//|  filter the open model check status
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_checkExceedToCurJump(CSignal* signal){

   if(!GRID_OPEN_EXCEED_CUR_JUMP)return true;

   bool reValue=true;
   tradeDealLog="<<checkExceedToCurJump>>";
   
   //exceed to current jump
   if(this.exceedToCurJump(GRID_OPEN_EXCEED_JUMP_CUR_MIN_PIPS)){
      tradeDealLog+="<exceedToCurJump>";
      if(!this.exceedSameCurType(signal.getTradeType())){
         tradeDealLog+="<exceedSameCurType>false";
         this.continueFlg=false;
         reValue=false;
      }
   } 
   return reValue;
}

//+------------------------------------------------------------------+
//|  filter the open model check status
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_checkStatus(CSignal* signal){

   if(!GRID_OPEN_FILTER_CHECK_STATUS)return true;

   tradeDealLog="<<checkStatus>>" + rkeeLog.rangeStatusName(this.getRangeStatus());
   signal.setStatusFlg(this.getRangeStatus()); 
   signal.setStatusIndex(this.getRange().getStatusIndex());        
      
   //range status
   if(this.range()){
      tradeDealLog+="<range>";
      return true;
   }else if(this.trendToRange()){   
      tradeDealLog+="<trendToRange>";
      return true;
   }else if(this.trendToJump()){
      tradeDealLog+="<trendToJump>";
      if(this.sameTrend(signal.getTradeType())){
         return true;
      }
      return false;   
   }   
   return false;
}

//+------------------------------------------------------------------+
//|  filter the open model hedge rate
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_hedgeRate(CSignal* signal){
   
   if(!GRID_OPEN_FILTER_CHECK_HEDGE)return true;
      
   this.tradeDealLog="<<hedgeRate>>";
   
   //no hedge case
   if(this.range() || this.trendToRange()){
      int orderCount=this.getOrderCount();
      if(orderCount<=GRID_OPEN_HEDGE_MIN_ORDER_COUNT){
         tradeDealLog+="<needHedge>false";  
         return true;
      }
   }else if(this.trendToJump()){
      if(this.sameTrend(signal.getTradeType())){         
         tradeDealLog+="<needHedge>false";
         return true;
      }
   }      
      
   bool   reValue=true;         
   tradeDealLog+="<needHedgeFlg>true";
   double hedgeRate=this.hedgeRate();
   double adjustHedgeRate=this.getAdjustRiskHedgeRate(GRID_OPEN_MIN_RISK_EXCEED_PROFIT,
                                                         GRID_OPEN_MAX_RISK_EXCEED_PROFIT,
                                                         GRID_OPEN_MIN_RISK_HEDGE_RATE,
                                                         GRID_OPEN_MAX_RISK_HEDGE_RATE,
                                                         GRID_OPEN_RISK_HEDGE_GROW_RATE);
   
   tradeDealLog+="<hedgeRate>"+ StringFormat("%.2f",hedgeRate)
                  + "<adjustHedgeRate>"+ StringFormat("%.2f",adjustHedgeRate);
   
   if(hedgeRate<adjustHedgeRate){
      double hedgeLot=this.openHedgeLot(signal);
      tradeDealLog+="<hedgeLot>" + StringFormat("%.2f",hedgeLot);
      if(hedgeLot<=0){
         reValue=false;
         tradeDealLog+="<riskHedge>false";
      }else{
         this.riskHedge=true;
         tradeDealLog+="<riskHedge>true";
      }   
   }    
   return reValue;
}

//+------------------------------------------------------------------+
//|  filter the open model diff pips
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_diffGrid(CSignal* signal){
   
   if(!GRID_OPEN_FILTER_CHECK_DIFF)return true;
   
   this.tradeDealLog="<<diffGrid>><riskHedge>" + this.riskHedge;
   bool reValue=false;
   bool adjustDiff=false;
   bool exceedFlg=false;
   double gridDiffRate=GRID_OPEN_RANGE_DIFF_BASE_RATE;   
   if(this.riskHedge){      
      gridDiffRate=this.getAdjustRiskDiffRate(GRID_OPEN_MIN_RISK_EXCEED_PROFIT,
                                                GRID_OPEN_MAX_RISK_EXCEED_PROFIT,
                                                GRID_OPEN_MIN_RISK_DIFF_RATE,
                                                GRID_OPEN_MAX_RISK_DIFF_RATE,
                                                GRID_OPEN_RISK_DIFF_GROW_RATE);   
      tradeDealLog+="<if1><gridDiffRate>" + gridDiffRate;
      adjustDiff=true;
   }else if(GRID_OPEN_EXCEED_ADJUST_DIFF){
      tradeDealLog+="<exceedAdjustDiff>";
      if(this.trendToJump()){
         // judge exceed type1 and exceedPre type2(type1<>type2  need judge)
         tradeDealLog+="<trendToJump>";                  
         if(this.sameTrend(signal.getTradeType())){               
            tradeDealLog+="<sameTrend>";
            int currentExceedIndex=this.getCurrentExceedIndex(signal.getSymbolIndex(),signal.getTradeType());
            gridDiffRate=comFunc2.getCurvedValue(GRID_OPEN_EXCEED_ADJUST_GROW_RATE,
                                                   currentExceedIndex,
                                                   GRID_OPEN_EXCEED_ADJUST_BEGIN_COUNT,
                                                   GRID_OPEN_EXCEED_ADJUST_END_COUNT,
                                                   GRID_OPEN_EXCEED_ADJUST_MIN_RATE,
                                                   GRID_OPEN_EXCEED_ADJUST_MAX_RATE);
            tradeDealLog+="<currentExceedIndex>" + currentExceedIndex
                              + "<gridDiffRate>" + gridDiffRate;
            adjustDiff=true; 
            if(GRID_OPEN_EXCEED_ADJUST_ONLY_CUR_DIFF){
               exceedFlg=true;
            }   
         }
      }
   }
   
   //default adjust diff
   if(!adjustDiff){
      double rangePips=this.getRange().getRangePips();
      double unitRangePips=Comm_Unit_RangePips;
      double adjustRate=rangePips/unitRangePips;
      if(adjustRate>1){
         gridDiffRate=gridDiffRate*adjustRate;
      }
      tradeDealLog+="<!adjustDiff><rangePips>" + this.getRange().getRangePips()
                      + "<unitRangePips>" + unitRangePips
                      + "<adjustRate>" + adjustRate
                      + "<gridDiffRate>" + gridDiffRate;      
   }    

   
   //diff grid pips
   if(this.diffGrid(signal,signal.getSignalDiffPips()*gridDiffRate,exceedFlg)){
      tradeDealLog+="<diffGrid>true";
      reValue=true;
   }

   //tradeDealLog+="<<reValue>>"+ reValue;   
   //if(reValue)logData.addDebugInfo(tradeDealLog);   
   return reValue;
}


//+------------------------------------------------------------------+
//|  check channel edge rate
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_checkChannelEdgeRate(CSignal* signal){

   
   if(!GRID_OPEN_FILTER_CHECK_EDGE_RATE)return true;
   
   this.tradeDealLog="<<checkChlEdgeRate>>";
   
   if(signal.getTradeType()==ORDER_TYPE_BUY){
      tradeDealLog+="<buy>";
      if(this.range() || this.trendToRange()){
         tradeDealLog+="<range>";
         if(this.getRange().getChannelUpperRate()>GRID_OPEN_FILTER_RNG_MIN_EDGE_RATE){
            tradeDealLog+="<UpperRate>" + this.getRange().getChannelUpperRate();
            return false;   
         }
      }else{
         tradeDealLog+="<trend>";
         if(this.getRange().getChannelUpperRate()<GRID_OPEN_FILTER_TND_MAX_EDGE_RATE){
            tradeDealLog+="<UpperRate>" + this.getRange().getChannelUpperRate();
            return false;   
         }      
      }
   }
   if(signal.getTradeType()==ORDER_TYPE_SELL){
      tradeDealLog+="<sell>";
      if(this.range() || this.trendToRange()){
         tradeDealLog+="<range>";
         if(this.getRange().getChannelDownRate()>GRID_OPEN_FILTER_RNG_MIN_EDGE_RATE){
            tradeDealLog+="<DownRate>" + this.getRange().getChannelDownRate();
            return false;
         }
      }else{
         tradeDealLog+="<trend>";
         if(this.getRange().getChannelDownRate()<GRID_OPEN_FILTER_TND_MAX_EDGE_RATE){
            tradeDealLog+="<DownRate>" + this.getRange().getChannelDownRate();
            return false;   
         }      
      }
   }
   return true;
}



//+------------------------------------------------------------------+
//|  filter the open model check pass time
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_checkPassTime(CSignal *signal){

   if(!GRID_OPEN_FILTER_CHECK_PASS)return true;

   tradeDealLog="<<checkPassTime>>";
   
   //range status
   if(this.range()){   
      int statusIndex=this.getRange().getStatusIndex();
      tradeDealLog+= "<range><statusIndex>" + statusIndex;
      // check after statusIndex begin
      if(statusIndex>1){
         double upperRate=this.getRange().getUpperRate();
         double downRate=this.getRange().getDownRate();
         int rangePassSeconds=this.getRange().getStatusPassedSeconds();            
         ENUM_ORDER_TYPE type=signal.getTradeType();
         
         tradeDealLog+= "<statusIndex>" + statusIndex
                        + "<type>" + type
                        + "<upperRate>" + upperRate
                        + "<downRate>" + downRate
                        + "<rangePassSeconds>" + rangePassSeconds;
                        
         if(rangePassSeconds<GRID_OPEN_RANGE_PASS_SECONDS){                    
            if(type==ORDER_TYPE_SELL){
               if(upperRate<0.5){
                  tradeDealLog+= "<false>"; 
                  return false;                                 
               }  
            }else{
               if(downRate<0.5){
                  tradeDealLog+= "<false>"; 
                  return false;                                 
               }            
            }
         }
      }         
   }
   
   return true;
}   

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterOpen01::CFilterOpen01(){}
CFilterOpen01::~CFilterOpen01(){
}
 