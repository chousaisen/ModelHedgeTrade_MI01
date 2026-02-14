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
         string  debugLog;
         string  debugLogTemp;
         bool    riskHedge;      
      public:
                CFilterOpen01();
                ~CFilterOpen01();                      
         bool   openFilter(CSignal* signal);
         
         //check status
         bool   openFilter_checkStatus(CSignal* signal);         
         //diff other model pips
         bool   openFilter_diffGrid(CSignal* signal);
         //check hedge rate
         bool   openFilter_hedgeRate(CSignal* signal); 
         bool   openFilter_hedgeRate2(CSignal* signal);
         //trend judge
         bool   openFilter_checkTrend(CSignal* signal);          
         //check exceed
         bool   openFilter_checkExceed(CSignal* signal);
         //check range pass time
         bool   openFilter_checkPassTime(CSignal* signal);         
                   
};

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter(CSignal* signal){

   this.debugLog="";
   this.riskHedge=false;
   
   bool reValue=true;
   
   // check pass time
   if(reValue && !this.openFilter_checkPassTime(signal)){
      reValue=false;
   }      
   
   // range status
   if(reValue && !this.openFilter_checkStatus(signal)){
      reValue=false;
   }   

   if(rkeeLog.debugPeriod(9122,300)){
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.debugLogTemp,
                        "CFilterOpen01");
   } 

   //check hedge rate
   if(reValue && !this.openFilter_hedgeRate(signal)){
      reValue=false;
   }   
   
   //check hedge rate
   if(reValue && !this.openFilter_hedgeRate2(signal)){
      reValue=false;
   }

   if(rkeeLog.debugPeriod(9123,300)){
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.debugLogTemp,
                        "CFilterOpen01");
   } 

   //diff grid pips
   if(reValue && !this.openFilter_diffGrid(signal)){
      reValue=false;
   } 
   
   if(rkeeLog.debugPeriod(9124,300)){
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.debugLogTemp,
                        "CFilterOpen01");
   }    
   
   //check trend   
   if(reValue && !this.openFilter_checkTrend(signal)){
      reValue=false;
   }
   
   if(rkeeLog.debugPeriod(9125,300)){
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.debugLogTemp,
                        "CFilterOpen01");
   }    
   
   //check exceed status   
   if(reValue && !this.openFilter_checkExceed(signal)){
      reValue=false;
   }   
   
   if(rkeeLog.debugPeriod(9126,300)){
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.debugLogTemp,
                        "CFilterOpen01");
   }    
   
   //datetime curTime=TimeCurrent();   
   if(reValue || rkeeLog.debugPeriod(9121,300)){
      this.debugLog= "<openFilter>" + reValue 
                      + "<type>"+ comFunc.getOrderType(signal.getTradeType())
                      + "<count-buy>" + this.getHedgePoolInfo().getBuyOrderCount()
                      + "<count-sell>" + this.getHedgePoolInfo().getSellOrderCount()                      
                      + "---" +  this.debugLog;
      if(reValue)logData.addDebugInfo(this.debugLog);                      
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.debugLog,
                        "CFilterOpen01");
   } 
   
   return reValue;
}


//+------------------------------------------------------------------+
//|  filter the open model check pass time
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_checkPassTime(CSignal *signal){

   debugLogTemp="<<checkPassTime>>";
   
   //range status
   if(this.range()){   
      int statusIndex=this.getRange().getStatusIndex();
      // check after statusIndex begin
      if(statusIndex>1){
         double upperRate=this.getRange().getUpperRate();
         double downRate=this.getRange().getDownRate();
         int rangePassSeconds=this.getRange().getStatusPassedSeconds();            
         ENUM_ORDER_TYPE type=signal.getTradeType();
         
         debugLogTemp+="<type>" + type
                        + "<upperRate>" + upperRate
                        + "<downRate>" + downRate
                        + "<rangePassSeconds>" + rangePassSeconds;
                        
         if(rangePassSeconds<1800){         
            if(type==ORDER_TYPE_SELL){
               if(upperRate<0.5){
                  return false;                                 
               }  
            }else{
               if(downRate<0.5){
                  return false;                                 
               }            
            }
         }
      }         
   }
   
   return true;
}   

//+------------------------------------------------------------------+
//|  filter the open model check status
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_checkStatus(CSignal* signal){

   debugLogTemp="<<checkStatus>>";
   signal.setStatusFlg(this.getRangeStatus()); 
   signal.setStatusIndex(this.getRange().getStatusIndex());     
   
   //check indicator ready
   if(!this.indicatorReady()){
      debugLogTemp+="<indicatorReady>false";
      //logData.addDebugInfo(debugLogTemp); 
      return false;
   }
   
   //range status
   if(this.range()){
      //string logTemp="<openTime_t>" + comFunc.getDate_YYYYMMDDHHMM(TimeCurrent());      
      //this.insertTable("TradeOpenTimeLine",logTemp);      
      debugLogTemp+="<range>true";
      logData.addDebugInfo(debugLogTemp); 
      return true;
   }else if(this.sameTrend(signal)){
      //string logTemp="<openTime_t>" + comFunc.getDate_YYYYMMDDHHMM(TimeCurrent());      
      //this.insertTable("TradeOpenTimeLine",logTemp);
      if(this.rangeBreakUp()){           
         debugLogTemp+="<rangeBreakUp>true";
      }else if(this.rangeBreakDown()){           
         debugLogTemp+="<rangeBreakDown>true";
      }      
      logData.addDebugInfo(debugLogTemp);       
      return true;       
   }
   /*
   else if(this.rangeBreak() && !this.sameTrend(signal)){
      //string logTemp="<openTime_t>" + comFunc.getDate_YYYYMMDDHHMM(TimeCurrent());      
      //this.insertTable("TradeOpenTimeLine",logTemp); 
      debugLog+="<rangeBreak><No sameTrend>";
      double returnRate=this.getTrend().getReturnRate();
      double trendPips=this.getTrend().getTrendPips();
      double protectReturnRate=comFunc2.mapValue(trendPips,100,1000,1.5,0.618);
      debugLog+="<returnRate>"+StringFormat("%.2f",returnRate)
               + "<trendPips>"+StringFormat("%.2f",trendPips)
               + "<protectReturnRate>"+StringFormat("%.2f",protectReturnRate);
               
      if(returnRate>protectReturnRate){
         return true; 
      }      
   }*/
   
   return false;
}

//+------------------------------------------------------------------+
//|  filter the open model hedge rate
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_hedgeRate(CSignal* signal){
   
   if(!GRID_OPEN_HEDGE)return true;
      
   debugLogTemp="<<hedgeRate>>";   
   bool   reValue=true;
   int orderCount=this.getOrderCount();
   if(orderCount>GRID_OPEN_HEDGE_MIN_ORDER_COUNT){      
      if(this.range()){                  
         double hedgeRate=this.hedgeRate();       
         double upperRate=this.getRange().getUpperRate();
         double downRate=this.getRange().getDownRate();
         double adjustRate=upperRate;
         if(signal.getTradeType()==ORDER_TYPE_SELL){
             adjustRate=downRate;
         }      
         double adjustHedgeRate=0.6;
         if(adjustRate<=0.5){
              adjustHedgeRate=comFunc2.mapValue(adjustRate,
                                                GRID_OPEN_HEDGE_BEGIN_DIFF_RATE,
                                                GRID_OPEN_HEDGE_END_DIFF_RATE,
                                                GRID_OPEN_HEDGE_BEGIN_HEDGE_RATE,
                                                GRID_OPEN_HEDGE_END_HEDGE_RATE);   
         }else if(adjustRate>=0.5){
              adjustHedgeRate=comFunc2.mapValue(adjustRate,
                                                GRID_OPEN_HEDGE_END_DIFF_RATE,
                                                1-GRID_OPEN_HEDGE_BEGIN_DIFF_RATE,
                                                GRID_OPEN_HEDGE_END_HEDGE_RATE,
                                                GRID_OPEN_HEDGE_BEGIN_HEDGE_RATE);
         }
         
         debugLogTemp+="<orderCount>"+ orderCount
                  + "<hedgeRate>"+ StringFormat("%.2f",hedgeRate)
                  + "<upperRate>"+ StringFormat("%.2f",upperRate)
                  + "<downRate>"+ StringFormat("%.2f",downRate)
                  + "<adjustRate>"+ StringFormat("%.2f",adjustRate)
                  + "<adjustHedgeRate>"+ StringFormat("%.2f",adjustHedgeRate);   
   
         //if(hedgeRate<0.6){
         debugLogTemp+="<range>";
         if(hedgeRate<adjustHedgeRate){
            debugLogTemp+="<if1>true";
            double hedgeLot=this.openHedgeLot(signal);
            debugLogTemp+="<hedgeLot>" + StringFormat("%.2f",hedgeLot);
            if(hedgeLot<=0){
               reValue=false;
            }else{
               this.riskHedge=true;
            }   
         }   
      }
   }     
   
   debugLogTemp+="<reValue>" + reValue;
   if(reValue)logData.addDebugInfo(debugLogTemp);    
     
   return reValue;
}


//+------------------------------------------------------------------+
//|  filter the open model hedge rate
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_hedgeRate2(CSignal* signal){
   
   if(!GRID_OPEN_HEDGE2)return true;
      
   debugLogTemp="<<hedgeRate>>";   
   bool   reValue=true;  
   int orderCount=this.getOrderCount(); 
   if(orderCount>GRID_OPEN_HEDGE_MIN_ORDER_COUNT){      
      if(this.range()){  
                
         double hedgeRate=this.hedgeRate();             
         CModelCostLine* modelCostLine=this.getModelAnalysis().getModelCostLine();
         double adjustRate=0;
         if(modelCostLine.isCostExist()){
            double curPrice=this.getCurPrice(signal.getSymbolIndex(),signal.getTradeType());
            double point=this.getPoint(signal.getSymbolIndex());
            modelCostLine.calculateEdge(curPrice,
                                        point,
                                        GRID_OPEN_COST_EDGE_EXT_PIPS);
            adjustRate=modelCostLine.getCostEdgeRate();
         }
         
         
         double adjustHedgeRate=comFunc2.mapValue(adjustRate,
                                                   GRID_OPEN_HEDGE_BEGIN_DIFF_COSTCENTER_RATE,
                                                   GRID_OPEN_HEDGE_END_DIFF_COSTCENTER_RATE,
                                                   GRID_OPEN_HEDGE_BEGIN_HEDGE_RATE,
                                                   GRID_OPEN_HEDGE_END_HEDGE_RATE);   
         
         debugLogTemp+="<orderCount>"+ orderCount
                  + "<hedgeRate>"+ StringFormat("%.2f",hedgeRate)
                  + "<adjustRate>"+ StringFormat("%.2f",adjustRate)
                  + "<adjustHedgeRate>"+ StringFormat("%.2f",adjustHedgeRate);   
   
         debugLogTemp+="<range>";
         if(hedgeRate<adjustHedgeRate){
            debugLogTemp+="<if1>true";
            double hedgeLot=this.openHedgeLot(signal);
            debugLogTemp+="<hedgeLot>" + StringFormat("%.2f",hedgeLot);
            if(hedgeLot<=0){
               reValue=false;
            }else{
               this.riskHedge=true;
            }   
         }   
      }
   }     
   
   debugLogTemp+="<reValue>" + reValue;
   if(reValue)logData.addDebugInfo(debugLogTemp);    
     
   return reValue;
}

//+------------------------------------------------------------------+
//|  filter the open model diff pips
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_diffGrid(CSignal* signal){
   
   debugLogTemp="<<diffGrid>><riskHedge>" + this.riskHedge;
   bool reValue=false;         
   double gridDiffRate=1;
   if(this.range()){
      gridDiffRate=Range_Grid_Diff_Rate;            
      if(!this.riskHedge){
         double rangePips=this.getRange().getRangePips();
         double unitRangePips=Range_Grid_Unit_RangePips;
         double adjustRate=rangePips/unitRangePips;
         if(adjustRate>1){
            gridDiffRate=Range_Grid_Diff_Rate*adjustRate;
         }
         debugLogTemp+="<rangePips>" + this.getRange().getRangePips()
                   + "<unitRangePips>" + unitRangePips
                   + "<adjustRate>" + adjustRate
                   + "<gridDiffRate>" + gridDiffRate;
      }          
   }else{
      if(GRID_OPEN_EXCEED_ADJUST_DIFF && this.exceedSameTrend()){
         gridDiffRate=GRID_OPEN_EXCEED_ADJUST_MIN_RATE;
         int currentExceedIndex=this.getCurrentExceedIndex(signal.getSymbolIndex());
         gridDiffRate=comFunc2.getCurvedValue(GRID_OPEN_EXCEED_ADJUST_GROW_RATE,
                                                currentExceedIndex,
                                                GRID_OPEN_EXCEED_ADJUST_BEGIN_COUNT,
                                                GRID_OPEN_EXCEED_ADJUST_END_COUNT,
                                                GRID_OPEN_EXCEED_ADJUST_MIN_RATE,
                                                GRID_OPEN_EXCEED_ADJUST_MAX_RATE);
      }
   }   
   
   //diff grid pips
   if(this.diffGrid(signal,signal.getSignalDiffPips()*gridDiffRate)){
      reValue=true;
   }
      
   debugLogTemp+="<<reValue>>"+ reValue;
   
   if(reValue)logData.addDebugInfo(debugLogTemp);    
   
   return reValue;
}

//+------------------------------------------------------------------+
//|  check trend
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_checkTrend(CSignal* signal){

   if(!GRID_OPEN_TREND)return true;
   debugLogTemp="<<checkTrend>>";
   
   if(this.range()){
      debugLogTemp+="<range>";
      int symbolIndex=signal.getSymbolIndex();
      string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);
      int trendFlg=comFunc2.getSarTrendFlg(symbol,
                                           GRID_OPEN_TREND_SAR_TF,                                             
                                           GRID_OPEN_TREND_SAR_STEP);
      debugLogTemp+="<trendFlg>" + trendFlg
                     + "<tradeType>" + signal.getTradeType();
      logData.addDebugInfo(debugLogTemp);
      if(signal.getTradeType()==ORDER_TYPE_BUY){
         if(trendFlg==IND_SAR_TREND_UP){
            return true;
         }
      }else{
         if(trendFlg==IND_SAR_TREND_DOWN){
            return true;
         }   
      }
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//|  check exceed status
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter_checkExceed(CSignal* signal){
   debugLogTemp="<<checkExceed>>";
   
   //break out
   if(this.exceedSameTrend()){
      debugLogTemp+="<exceedSameTrend>";
      double reSumLot=this.getModelAnalysis().getExceedReSumLot();
      double sumLot=this.getModelAnalysis().getExceedSumLot();
      debugLogTemp+="<exceed sumLot>" + StringFormat("%.2f",sumLot);
      debugLogTemp+="<exceed reSumLot>" + StringFormat("%.2f",reSumLot);
      if(reSumLot>GRID_OPEN_LIMIT_EXCEED_RELOT){
         debugLogTemp+="<reValue>false1";
         return false;
      }
      double reSumLotRate=this.getModelAnalysis().getExceedReSumLotRate();
      debugLogTemp+="<reSumLotRate>" + StringFormat("%.2f",reSumLotRate);
      if(reSumLotRate>GRID_OPEN_LIMIT_EXCEED_RELOT_RATE){
         debugLogTemp+="<reValue>false2";
         return false;
      }      
   }
   debugLogTemp+="<reValue>true"; 
   logData.addDebugInfo(debugLogTemp);  
   return true;
}
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterOpen01::CFilterOpen01(){}
CFilterOpen01::~CFilterOpen01(){
}
 