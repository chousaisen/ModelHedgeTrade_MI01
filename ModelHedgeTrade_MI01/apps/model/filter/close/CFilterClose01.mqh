//+------------------------------------------------------------------+
//|                                                CFilterClose01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../../../share/Indicator/CHeader.mqh"
#include "../../../comm/ComFunc2.mqh"
#include "../CModelFilter.mqh"

class CFilterClose01: public CModelFilter 
{
      private:
         //string       tradeDealLog;
         bool    riskHedge;
         bool    continueFlg;
         bool    filterResult;         
      public:
                      CFilterClose01();
                      ~CFilterClose01();                               
         //init filter
         void         initFilter();
         //close filter(model)
         bool         closeFilter(CModelI* model);
         bool         closeFilter_exceedToJump(CModelI* model);
         bool         closeFilter_exceedToCurJump(CModelI* model);
         bool         closeFilter_checkStatus(CModelI* model);
         bool         closeFilter_hedgeRate(CModelI* model);
};

//+------------------------------------------------------------------+
//|  filter init
//+------------------------------------------------------------------+
void CFilterClose01::initFilter(){
   this.continueFlg=true;
   this.filterResult=true;
   this.middleLog="";
   this.riskHedge=false;
}

//+------------------------------------------------------------------+
//|  filter the close model 
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter(CModelI* model){
   
   //init filter
   this.initFilter();   
   this.tradeDealLog="<<closeFilter>>";
   
   //check indicator ready
   if(!this.indicatorReady()){
      tradeDealLog+="<indicatorReady>";
      this.filterResult=false;
      this.continueFlg=false;
      this.addDebugInfo(this.filterResult);
   }   
     
   // check exceed Jump
   if(this.continueFlg){
      this.filterResult=this.closeFilter_exceedToJump(model);
      this.addDebugInfo(this.filterResult);
   }
   
      
   // check exceed current Jump
   if(this.continueFlg){
      this.filterResult=this.closeFilter_exceedToCurJump(model);
      this.addDebugInfo(this.filterResult);
   }   
     
   // check close status
   if(this.continueFlg){
      this.filterResult=this.closeFilter_checkStatus(model);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   }    
      
   // check close hedge rate   
   if(this.continueFlg){
      this.filterResult=this.closeFilter_hedgeRate(model);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   }   
         
   if(rkeeLog.debugPeriod(9125,3000)){
      this.middleLog= "<closeFilter>" + this.filterResult 
                      + "<orderType>"+ comFunc.getOrderType(model.getTradeType())
                      + "---" +  this.middleLog;
      //if(reValue)logData.addDebugInfo(this.tradeDealLog);
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.middleLog,
                        "CFilterClose01");
   }    
      
   return this.filterResult;
}


//+------------------------------------------------------------------+
//|  filter the close model (check exceed Jump)
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter_exceedToJump(CModelI* model){   
   
   //this.tradeDealLog="";
   tradeDealLog="<<exceedToJump>>";
   bool reValue=true;   
   
   tradeDealLog+="<ExceedProfit>" + StringFormat("%.2f",this.getModelShare().getModelAnalysisPre().getExceedCurProfit());
   tradeDealLog+="<exceedSameType>" + this.exceedSameType(model.getTradeType());
   //not close when exceed to jump
   if(GRID_CLOSE_EXCEED_JUMP
      && this.exceedToJump(GRID_CLOSE_EXCEED_JUMP_MIN_PIPS)){
      tradeDealLog+="<exceedToJump>";
      if(this.exceedSameType(model.getTradeType())){
         tradeDealLog+="<exceedSameType>";
         reValue=false;
         this.continueFlg=false;
      }
   }
  
   tradeDealLog+="<reValue>" + reValue;
   return reValue;
}


//+------------------------------------------------------------------+
//|  filter the close model (check exceed current Jump)
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter_exceedToCurJump(CModelI* model){   
   
   //this.tradeDealLog="";
   tradeDealLog="<<exceedToCurJump>>";
   bool reValue=true;
   
   tradeDealLog+="<ExceedCurProfit>" + this.getModelShare().getModelAnalysis().getExceedCurProfit();
   tradeDealLog+="<exceedSameCurType>" + this.exceedSameCurType(model.getTradeType());
   //not close when exceed to current jump
   if(GRID_CLOSE_EXCEED_CUR_JUMP
      && this.exceedToCurJump(GRID_CLOSE_EXCEED_JUMP_CUR_MIN_PIPS)){
      tradeDealLog+="<exceedToCurJump>";
      if(this.exceedSameCurType(model.getTradeType())){
         tradeDealLog+="<exceedSameCurType>";
         reValue=false;
         this.continueFlg=false;
      }
   } 
  
   tradeDealLog+="<reValue>" + reValue;
   return reValue;
}

//+------------------------------------------------------------------+
//|  filter the close model (check status)
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter_checkStatus(CModelI* model){   
   
   //this.tradeDealLog="";
   tradeDealLog="<<checkStatus>>";
   bool reValue=true;             
   
   //not close when trend jump status
   if(reValue && this.trendToJump()){
      tradeDealLog+="<trendToJump>";
      if(this.sameTrend(model.getTradeType())){                 
         double trendPips=this.getAnalysisShare().getChannel().getChlBreakHeight();
         tradeDealLog+="<modelTrend><trendPips>" + trendPips;      
         if(trendPips>GRID_CLOSE_TREND_LESS_PIPS){
            reValue=false;
         }else{
            if(model.getOrderCount()>GRID_CLOSE_TREND_MODEL_MIN_ORDER){
               tradeDealLog+="<sameTrend><modelOrderCount>" + model.getOrderCount();               
               reValue=true;
            }      
         }      
      }
   }       
  
   tradeDealLog+="<reValue>" + reValue;
   return reValue;
}

//+------------------------------------------------------------------+
//|  filter the close model(hedge rate)
//+------------------------------------------------------------------+
bool CFilterClose01::closeFilter_hedgeRate(CModelI* model){   
      
   if(!GRID_CLOSE_HEDGE)return true;
   
   tradeDealLog="<<checkHedge>>";
   bool reValue=true;
   double hedgeOrderCount=this.getOrderCount();
   
   if(hedgeOrderCount>GRID_CLOSE_HEDGE_MIN_ORDER){
         
         tradeDealLog+="<range><statusIndex>" + this.getRange().getStatusIndex();
         double hedgeRate=this.hedgeRate();      
         
         double adjustHedgeRate=this.getAdjustRiskHedgeRate(GRID_CLOSE_MIN_RISK_EXCEED_PROFIT,
                                                              GRID_CLOSE_MAX_RISK_EXCEED_PROFIT,
                                                              GRID_CLOSE_MIN_RISK_HEDGE_RATE,
                                                              GRID_CLOSE_MAX_RISK_HEDGE_RATE,
                                                              GRID_CLOSE_RISK_HEDGE_GROW_RATE);
                  
         //judge if trend protect(when privous status)
         if(GRID_CLOSE_BREAK_PROTECT_HEDGE){
            if(model.getStatusIndex()<this.getRange().getStatusIndex()){
               if(model.getStatusFlg()==STATUS_RANGE_BREAK_UP
                  || model.getStatusFlg()==STATUS_RANGE_BREAK_DOWN){
                  adjustHedgeRate=GRID_CLOSE_BREAK_PROTECT_HEDGE_RATE;               
               }
            }
         }
         
         tradeDealLog+="<hedgeRate>"+StringFormat("%.2f",hedgeRate)
                     + "<adjustHedgeRate>"+StringFormat("%.2f",adjustHedgeRate)
                     + "<modelStatusIndex>"+model.getStatusIndex()
                     + "<modelStatusFlg>"+ model.getStatusFlg();

         if(hedgeRate<adjustHedgeRate){            
            double hedgeLot=this.closeHedgeLot(model);
            tradeDealLog+="<hedgeLot>" + StringFormat("%.2f",hedgeLot);
            if(hedgeLot<=0){
               tradeDealLog+="<hedge>false";
               reValue=false;
            }   
         }   
      //}
   }   
   tradeDealLog+="<reValue>"+reValue;
   return reValue;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterClose01::CFilterClose01(){}
CFilterClose01::~CFilterClose01(){
}
 