//+------------------------------------------------------------------+
//|                                                CFilterExtend01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../CModelIndicatorFilter.mqh"
#include "../../../comm/ComFunc2.mqh"

class CFilterExtend01: public CModelIndicatorFilter 
{
      private:
         //string            tradeDealLog;
         bool              adjustExceedDiff; 
         bool              needHedgeFlg;
         int               currentExceedIndex; 
         bool              continueFlg;
         bool              filterResult;         
      public:
                           CFilterExtend01();
                           ~CFilterExtend01(); 
         //init filter
         void              initFilter();                                                
         //extend filter
         bool              extendFilter(CModelI* model);
    
         //check Exceed To Jump
         bool              extendFilter_checkExceedToJump(CModelI* signal);
         //check Exceed To Current Jump
         bool              extendFilter_checkExceedToCurJump(CModelI* signal);         
         //check status
         bool              extendFilter_checkStatus(CModelI* model);         
         bool              extendFilter_adjustExtend(CModelI* model); 
         bool              extendFilter_hedgeRate(CModelI* model); 
         bool              extendFilter_checkTrend(CModelI* model);         
};
  

//+------------------------------------------------------------------+
//|  filter init
//+------------------------------------------------------------------+
void CFilterExtend01::initFilter(){
   this.continueFlg=true;
   this.filterResult=true;
   this.tradeDealLog="";
   this.middleLog="";
}

//+------------------------------------------------------------------+
//|  filter the extend model(check diff)
//+------------------------------------------------------------------+
bool CFilterExtend01::extendFilter(CModelI* model){

   //init filter
   this.initFilter();   
   this.tradeDealLog="<<extendFilter>>";
   
   //check indicator ready
   if(!this.indicatorReady()){
      tradeDealLog+="<indicatorReady>";
      this.filterResult=false;
      this.continueFlg=false;
      this.addDebugInfo(this.filterResult);
   } 
   
   //bool reValue=true;
   this.adjustExceedDiff=false;
   this.needHedgeFlg=false;
      
   // check Exceed To Jump 
   if(this.continueFlg){
      this.filterResult=this.extendFilter_checkExceedToJump(model);
      this.addDebugInfo(this.filterResult);
   }      
    
   // check Exceed To current Jump 
   if(this.continueFlg){
      this.filterResult=this.extendFilter_checkExceedToCurJump(model);
      this.addDebugInfo(this.filterResult);
   }      
      
   // check model status 
   if(this.continueFlg){
      this.filterResult=this.extendFilter_checkStatus(model);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   }
      
   // check extend diff
   if(this.continueFlg){
      this.filterResult=this.extendFilter_adjustExtend(model);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   }      
   
   //check hedge rate
   if(this.continueFlg){
      this.filterResult=this.extendFilter_hedgeRate(model);
      this.addDebugInfo(this.filterResult);
      this.continueFlg=this.filterResult;
   }     
   
   if(rkeeLog.debugPeriod(9122,3000)){
      this.middleLog= "<extendFilter>" + this.filterResult 
                      + "<orderType>"+ comFunc.getOrderType(model.getTradeType())
                      + "---" +  this.middleLog;
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.middleLog,
                        "CFilterExtend01");
   }      
   
   return this.filterResult;
}


//+------------------------------------------------------------------+
//|  filter the extend model check Exceed To Jump
//+------------------------------------------------------------------+
bool CFilterExtend01::extendFilter_checkExceedToJump(CModelI* model){

   tradeDealLog="<<checkExceedToJump>>";
   tradeDealLog+="<ExceedProfit>" + StringFormat("%.2f",this.getModelShare().getModelAnalysisPre().getExceedCurProfit());
   tradeDealLog+="<exceedSameType>" + this.exceedSameType(model.getTradeType());      
   //exceed to jump
   if(GRID_OPEN_EXCEED_JUMP
      && this.exceedToJump(GRID_OPEN_EXCEED_JUMP_MIN_PIPS)){
      tradeDealLog+="<exceedToJump>";
      if(this.exceedSameType(model.getTradeType())){
         tradeDealLog+="<exceedSameType>";
         this.adjustExceedDiff=true;
         this.currentExceedIndex=this.getCurrentExceedIndex(model.getSymbolIndex(),model.getTradeType());
         double extendMaxOrder=this.getAdjustExceedExtendMaxOrders(this.currentExceedIndex);
         double curOrderCount=model.getOrderCount();
         // max extend order when exceed
         if(curOrderCount<extendMaxOrder){            
            tradeDealLog+="<maxOrder>" + curOrderCount;
            this.continueFlg=false;
            return true;
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//|  filter the extend model check Exceed to current Jump
//+------------------------------------------------------------------+
bool CFilterExtend01::extendFilter_checkExceedToCurJump(CModelI* model){

   tradeDealLog="<<checkExceedToJump>>";
      
   //exceed to jump
   if(GRID_OPEN_EXCEED_CUR_JUMP
         && this.exceedToCurJump(GRID_OPEN_EXCEED_JUMP_CUR_MIN_PIPS)){
         tradeDealLog+="<exceedToCurJump>";
         if(this.exceedSameCurType(model.getTradeType())){
            tradeDealLog+="<exceedSameCurType>";
            this.adjustExceedDiff=true;
            this.currentExceedIndex=this.getCurrentExceedIndex(model.getSymbolIndex(),model.getTradeType());
            double extendMaxOrder=this.getAdjustExceedExtendMaxOrders(this.currentExceedIndex);
            double curOrderCount=model.getOrderCount();
            // max extend order when exceed
            if(curOrderCount<extendMaxOrder){            
               tradeDealLog+="<maxOrder>" + curOrderCount;
               this.continueFlg=false;
               return true;
            }
         }
   }      
   
   return false;
}


//+------------------------------------------------------------------+
//|  filter the open model check status
//+------------------------------------------------------------------+
bool CFilterExtend01::extendFilter_checkStatus(CModelI* model){

   tradeDealLog="<<checkStatus>>";
         
   //model range
   if(this.range() || this.trendToRange()){      
      tradeDealLog+="<range><needHedge>"; 
      this.needHedgeFlg=true;     
      return true;
   }else if(this.trendToJump()){  
      //model trend      
      tradeDealLog+="<trendToJump>";
      if(this.sameTrend(model.getTradeType())){
         tradeDealLog+="<sameTrend>"; 
         this.adjustExceedDiff=true;
         this.currentExceedIndex=this.getCurrentExceedIndex(model.getSymbolIndex(),model.getTradeType());         
         double extendMaxOrder=this.getAdjustExceedExtendMaxOrders(this.currentExceedIndex);
         double curOrderCount=model.getOrderCount();
         // max extend order when exceed
         if(curOrderCount<extendMaxOrder){            
            tradeDealLog+="<maxOrder>" + model.getOrderCount();
            return true;
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//|  filter the extend model(check diff)
//+------------------------------------------------------------------+
bool CFilterExtend01::extendFilter_adjustExtend(CModelI* model){
   
   if(!GRID_OPEN_EXTEND_EXCEED_ADJUST_DIFF)return true;
   
   tradeDealLog+="<<adjustExtend>>";
   // only extend by range
   if(this.adjustExceedDiff){
      //double gridDiffRate=1;
      //int currentExceedIndex=this.getCurrentExceedIndex(model.getSymbolIndex());
      double gridDiffRate=comFunc2.getCurvedValue(GRID_OPEN_EXTEND_EXT_ADJUST_GROW_RATE,
                                             this.currentExceedIndex,
                                             GRID_OPEN_EXTEND_EXT_ADJUST_BEGIN_COUNT,
                                             GRID_OPEN_EXTEND_EXT_ADJUST_END_COUNT,
                                             GRID_OPEN_EXTEND_EXT_ADJUST_MIN_RATE,
                                             GRID_OPEN_EXTEND_EXT_ADJUST_MAX_RATE);       
      model.setExtendRate(gridDiffRate);
      tradeDealLog+="<currentExceedIndex>" + this.currentExceedIndex
                + "<gridDiffRate>" + gridDiffRate;
   }
   return true;
}

//+------------------------------------------------------------------+
//|  filter the extend model hedge rate
//+------------------------------------------------------------------+
bool CFilterExtend01::extendFilter_hedgeRate(CModelI* model){
   
   tradeDealLog="<<hedgeRate>>"; 
   
   if(!GRID_OPEN_EXTEND_HEDGE)return true;           
   if(this.getOrderCount()<=GRID_OPEN_HEDGE_MIN_ORDER_COUNT){
      tradeDealLog+="<minOrderCount>"; 
      return true;
   }
        
   bool   reValue=true;  
   if(this.needHedgeFlg){
      
      tradeDealLog+="<needHedgeFlg>";        
      double hedgeRate=this.hedgeRate();     
      double adjustHedgeRate=this.getAdjustRiskHedgeRate(GRID_OPEN_EXTEND_MIN_RISK_EXCEED_PROFIT,
                                                           GRID_OPEN_EXTEND_MAX_RISK_EXCEED_PROFIT,
                                                           GRID_OPEN_EXTEND_MIN_RISK_HEDGE_RATE,
                                                           GRID_OPEN_EXTEND_MAX_RISK_HEDGE_RATE,
                                                           GRID_OPEN_EXTEND_RISK_HEDGE_GROW_RATE); 

      tradeDealLog+="<hedgeRate>"+ StringFormat("%.2f",hedgeRate)
               + "<adjustHedgeRate>"+ StringFormat("%.2f",adjustHedgeRate);   
      
      if(hedgeRate<adjustHedgeRate){
         double hedgeLot=this.openHedgeLot(model);
         tradeDealLog+="<hedgeLot>" + StringFormat("%.2f",hedgeLot);
         if(hedgeLot<=0){
            tradeDealLog+="<hedge>false";   
            reValue=false;
         }  
      }   
      
   }     
   
   tradeDealLog+="<reValue>" + reValue;
   if(reValue)logData.addDebugInfo(tradeDealLog);    
     
   return reValue;
}


//+------------------------------------------------------------------+
//|  check trend
//+------------------------------------------------------------------+
bool CFilterExtend01::extendFilter_checkTrend(CModelI* model){

   int symbolIndex=model.getSymbolIndex();
   string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);
   int trendFlg=comFunc2.getSarTrendFlg(symbol);
   if(model.getTradeType()==ORDER_TYPE_BUY){
      if(trendFlg==IND_TREND_UP){
         return true;
      }
   }else{
      if(trendFlg==IND_TREND_DOWN){
         return true;
      }   
   }

   return false;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterExtend01::CFilterExtend01(){}
CFilterExtend01::~CFilterExtend01(){
}
 