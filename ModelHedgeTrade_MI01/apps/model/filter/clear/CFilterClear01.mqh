//+------------------------------------------------------------------+
//|                                                CFilterClear01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "..\..\..\header\CHeader.mqh"
#include "..\CModelHedgeFilter.mqh"

class CFilterClear01: public CModelHedgeFilter 
{
      private:
              //int          chlEdgeIndexs[];
              string       debugLog;              
      public:
                           CFilterClear01();
                           ~CFilterClear01();                      
               bool        clearFilter(CModelI* model);
               bool        clearFilter_checkStatus(CModelI* model);
               
};


//+------------------------------------------------------------------+
//|  filter the clear model 
//+------------------------------------------------------------------+
bool CFilterClear01::clearFilter(CModelI* model){   
   
   if(!GRID_CLEAR_FLG)return false;
   
   this.debugLog="";
   
   bool reValue=false;   
   
   // check clear status
   if(this.clearFilter_checkStatus(model)){
      reValue=true;
   }   
         
   //if(reValue || rkeeLog.debugPeriod(9126,3000)){
      this.debugLog= "<rangeStatus>" + this.getRangeStatus()
                      + "<filterClear>" + reValue 
                      + "<orderCount>" + this.getHedgePoolInfo().getHedgeOrderCount()
                      + "<buy>" + this.getHedgePoolInfo().getBuyOrderCount()
                      + "<sell>" + this.getHedgePoolInfo().getSellOrderCount()
                      + "<orderType>"+ comFunc.getOrderType(model.getTradeType())
                      + "---" +  this.debugLog;
      if(reValue)logData.addDebugInfo(this.debugLog);
      //rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + this.debugLog,
      //                  "CFilterClear01");
   //}    
   
   
   return reValue;
}
  
//+------------------------------------------------------------------+
//|  filter the clear model
//+------------------------------------------------------------------+
bool CFilterClear01::clearFilter_checkStatus(CModelI* model)
{  
      
   debugLog+="<<clearFilter_checkStatus>>";
   
   //check indicator ready
   if(!this.indicatorReady()){
      debugLog+="<indicatorReady>false";
      return false;
   }     
   
   int symbolIndex=model.getSymbolIndex();
   string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);
   int trendFlg=comFunc2.getSarTrendFlg(symbol);    
   int curStatusIndex=this.getRange().getStatusIndex();
   int modelStatusIndex=model.getStatusIndex();
   int diffStatusIndex=curStatusIndex-modelStatusIndex;      
   
   debugLog+="<diffStatusIndex>" + diffStatusIndex
               + "<trendFlg>" + trendFlg;
   
   if(diffStatusIndex>0){ 
         
      if(GRID_CLEAR_BREAK && this.range()){
         if(model.getProfitPips()<-GRID_CLEAR_BREAK_DIFF_PIPS){
            if(model.getStatusFlg()==STATUS_RANGE_BREAK_UP 
               || model.getStatusFlg()==STATUS_RANGE_BREAK_DOWN){
               return true;
            }                     
         }
      }      
   
      //int diffSeconds=TimeCurrent()-model.getTradeTime();         
      if(GRID_CLEAR_RANGE && this.rangeBreakUp()){      
         debugLog+="<rangeBreakUp>";
         double trendPips=this.getAnalysisShare().getChannel().getChlBreakHeight();
         debugLog+="<rangeBreakUp><trendPips>"+trendPips;
         if(model.getTradeType()==ORDER_TYPE_SELL){
            debugLog+="<getProfitPips>" + model.getProfitPips();
            if(model.getProfitPips()<-GRID_CLEAR_RANGE_DIFF_PIPS){
               debugLog+="<reValue>true";
               return true;                    
            }
         }
      }
      if(GRID_CLEAR_RANGE && this.rangeBreakDown()){
         double trendPips=this.getAnalysisShare().getChannel().getChlBreakHeight();
         debugLog+="<rangeBreakDown><trendPips>"+trendPips;
         if(model.getTradeType()==ORDER_TYPE_BUY){
            debugLog+="<getProfitPips>" + model.getProfitPips();
            if(model.getProfitPips()<-GRID_CLEAR_BREAK_DIFF_PIPS){ 
               debugLog+="<reValue>true";
               return true;    
            }
         }
      }
      
      /*
      debugLog+="<trendPips>"+ this.getTrend().getTrendPips();                      
      if(this.rangeBreakUp() 
         && this.getTrend().getTrendPips()>500
         && trendFlg == IND_SAR_TREND_DOWN){ 
         
         debugLog+="<IND_SAR_TREND_DOWN>";          
         if(model.getTradeType()==ORDER_TYPE_BUY){            
            debugLog+="<reValue>true";
            return true;
         }
      }
      if(this.rangeBreakDown() 
         && this.getTrend().getTrendPips()>500
         && trendFlg ==IND_SAR_TREND_UP){
         debugLog+="<IND_SAR_TREND_UP>";             
         if(model.getTradeType()==ORDER_TYPE_SELL){
            debugLog+="<reValue>true";
            return true;
         }
      }*/
   }
   debugLog+="<reValue>false";      
   return false;
}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterClear01::CFilterClear01(){
   //comFunc.StringToIntArray(GRID_CLEAR_CHL_EDGE_INDEXS,chlEdgeIndexs);
}
CFilterClear01::~CFilterClear01(){
}
 