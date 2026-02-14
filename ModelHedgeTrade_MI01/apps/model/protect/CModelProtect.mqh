//+------------------------------------------------------------------+
//|                                                     CModel01.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "../../share/CShareCtl.mqh"
#include "../CModelI.mqh"

class CModelProtect 
{
      private:
         CShareCtl*            shareCtl;
         CIndicatorShare*      indShare;
         CArrayList<ulong>     clearModelList;
      public:
                              CModelProtect();
                              ~CModelProtect(); 
        void                  init(CShareCtl *shareCtl);
        CArrayList<CModelI*>* getModels();
        CIndicatorShare*      getIndicatorShare();
        CSymbolShare*         getSymbolShare();
        void                  refresh();        
        double                clearHedgeLot(CModelI* model);
        double                clearHedgeLot(CModelI* model,CHedgeGroup* modelGroup);
        int                   clearModels();
        void                  addClearModel(CModelI* model);
        CHedgeGroup*          getHedgeGroupPool();
        CShareCtl*            getShareCtl();
        CModelAnalysis*       getModelAnalysis();
        CModelAnalysisPre*    getModelAnalysisPre();
        CAnalysisShare*       getAnalysisShare();
        int                   getRangeStatus();
        bool                  rangeBreak();
        bool                  rangeBreakUp();
        bool                  rangeBreakDown(); 
        bool                  range();
        //bool                  exceedSameTrend();
        bool                  exceedSamePre();
        bool                  indicatorReady();
        double                getCurPrice(int symbolIndex,ENUM_ORDER_TYPE type);
        double                getCurPrice(int symbolIndex);  //default price
        double                getPoint(int symbolIndex);    
        bool                  trendToRange();
        CRange*               getRange();
        bool                  exceedToJump(double minJumpProfitPips);
        bool                  exceedToCurJump(double minJumpProfitPips);
         
};
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CModelProtect::init(CShareCtl *shareCtl){
   this.shareCtl=shareCtl;
   this.indShare=shareCtl.getIndicatorShare();
}

//+------------------------------------------------------------------+
//|  get share control
//+------------------------------------------------------------------+
CShareCtl* CModelProtect::getShareCtl(){
   return this.shareCtl;
}

//+------------------------------------------------------------------+
//|  get model list
//+------------------------------------------------------------------+
CArrayList<CModelI*>* CModelProtect::getModels(){
   return this.shareCtl.getModelShare().getModels();
}

//+------------------------------------------------------------------+
//|  get indicator share 
//+------------------------------------------------------------------+
CIndicatorShare*  CModelProtect::getIndicatorShare(){
   return this.indShare;
}

//+------------------------------------------------------------------+
//|  get Model Analysis
//+------------------------------------------------------------------+
CModelAnalysis*  CModelProtect::getModelAnalysis(){
   return this.shareCtl.getModelShare().getModelAnalysis();
}

//+------------------------------------------------------------------+
//|  get Model Analysis
//+------------------------------------------------------------------+
CModelAnalysisPre*  CModelProtect::getModelAnalysisPre(){
   return this.shareCtl.getModelShare().getModelAnalysisPre();
}

//+------------------------------------------------------------------+
//|  get indicator share 
//+------------------------------------------------------------------+
CHedgeGroup*  CModelProtect::getHedgeGroupPool(){
   return this.shareCtl.getHedgeShare().getHedgeGroupPool();
}

//+------------------------------------------------------------------+
//|  get analysis share
//+------------------------------------------------------------------+
CAnalysisShare* CModelProtect::getAnalysisShare(){
   return this.shareCtl.getAnalysisShare();
}

//+------------------------------------------------------------------+
//|  get symbol share
//+------------------------------------------------------------------+
CSymbolShare* CModelProtect::getSymbolShare(){
   return this.shareCtl.getSymbolShare();
}


//+------------------------------------------------------------------+
//|  get range status
//+------------------------------------------------------------------+
int  CModelProtect::getRangeStatus(){
   return this.getAnalysisShare().getCurRange().getStatusFlg();
}

//+------------------------------------------------------------------+
//|  judge if range break up
//+------------------------------------------------------------------+
bool  CModelProtect::rangeBreakUp(){   
   if(this.getRangeStatus()==STATUS_RANGE_BREAK_UP){
      return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if range break down
//+------------------------------------------------------------------+
bool  CModelProtect::rangeBreakDown(){   
   if(this.getRangeStatus()==STATUS_RANGE_BREAK_DOWN){
      return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if range break
//+------------------------------------------------------------------+
bool  CModelProtect::rangeBreak(){   
   if(this.rangeBreakUp() || this.rangeBreakDown()){
      return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if range 
//+------------------------------------------------------------------+
bool  CModelProtect::range(){   
   if(this.getRangeStatus()==STATUS_RANGE_INNER){
      return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if indicators ready
//+------------------------------------------------------------------+
bool  CModelProtect::indicatorReady(){
   if(this.getRangeStatus()==STATUS_NONE){
      return false;
   }    
   return true;
}

//+------------------------------------------------------------------+
//|  refresh protect info
//+------------------------------------------------------------------+
void CModelProtect::refresh(void){
   this.clearModelList.Clear();   
}

//+------------------------------------------------------------------+
//|  clear minus models
//+------------------------------------------------------------------+
double CModelProtect::clearHedgeLot(CModelI* model){

   //CHedgeGroup* modelGroup=model.getHedgeGroup();
   CHedgeGroup* modelGroup=this.getHedgeGroupPool();
   int symbolIndex=model.getSymbolIndex();
   ENUM_ORDER_TYPE type=model.getTradeType();
   if(type==ORDER_TYPE_SELL){
      type=ORDER_TYPE_BUY;
   }else{
      type=ORDER_TYPE_SELL;
   }
   double lot=model.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){
      this.addClearModel(model);
      modelGroup.hedgeOrders();
      return lot;
   }
   return 0;
}

//+------------------------------------------------------------------+
//|  clear minus models
//+------------------------------------------------------------------+
double CModelProtect::clearHedgeLot(CModelI* model,CHedgeGroup* modelGroup){
   int symbolIndex=model.getSymbolIndex();
   ENUM_ORDER_TYPE type=model.getTradeType();
   if(type==ORDER_TYPE_SELL){
      type=ORDER_TYPE_BUY;
   }else{
      type=ORDER_TYPE_SELL;
   }
   double lot=model.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){
      //modelGroup.hedgeOrders();
      return lot;
   }
   return 0;
}

//+------------------------------------------------------------------+
//|  add clear model
//+------------------------------------------------------------------+
void  CModelProtect::addClearModel(CModelI* model){
   model.markClearFlag(true);
}

//+------------------------------------------------------------------+
//|  clear models
//+------------------------------------------------------------------+
int CModelProtect::clearModels(){
   //clear model
   CArrayList<CModelI*> modelList=this.shareCtl.getModelShare().getModels();
   int modelCount=modelList.Count();
   //clean model list
   int clearCount=0;
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){                          
         //if(this.clearModelList.Contains(model.getModelId())){
         if(model.getClearFlag()){
            model.setActionFlg("clearMinusModels.clearModels");
            clearCount+=model.closeOrders();         
         }
      }
   }
   return clearCount;
}

//+------------------------------------------------------------------+
//|  get symbol price
//+------------------------------------------------------------------+
double CModelProtect::getCurPrice(int symbolIndex,ENUM_ORDER_TYPE type){
   string symbol=SYMBOL_LIST[symbolIndex];
   return this.getSymbolShare().getSymbolPrice(symbol,type);   
}

//+------------------------------------------------------------------+
//|  get symbol price(default)
//+------------------------------------------------------------------+
double CModelProtect::getCurPrice(int symbolIndex){
   string symbol=SYMBOL_LIST[symbolIndex];
   return this.getSymbolShare().getSymbolPrice(symbol,ORDER_TYPE_BUY);   
}

//+------------------------------------------------------------------+
//|  get symbol point
//+------------------------------------------------------------------+
double CModelProtect::getPoint(int symbolIndex){
   string symbol=SYMBOL_LIST[symbolIndex];
   return this.getSymbolShare().getSymbolPoint(symbol);   
}

//+------------------------------------------------------------------+
//|  judge if current trend is same to exceed 
//+------------------------------------------------------------------+
/*
bool  CModelProtect::exceedSameTrend(){   
   ENUM_ORDER_TYPE exceedType=this.getModelAnalysis().getExceedType();
   if(exceedType==ORDER_TYPE_BUY){
      if(this.rangeBreakUp()){
         return true;
      }
   }else if(exceedType==ORDER_TYPE_SELL){
      if(this.rangeBreakDown()){
         return true;
      }
   }
   return false;
}
*/
//+------------------------------------------------------------------+
//|  judge if current  exceed is same to pre exceed
//+------------------------------------------------------------------+
bool  CModelProtect::exceedSamePre(){
   ENUM_ORDER_TYPE exceedType=this.getModelAnalysis().getExceedType();
   ENUM_ORDER_TYPE exceedTypePre=this.getModelAnalysisPre().getExceedType();
   if(exceedType==exceedTypePre){
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//|  judge if trend back to range(indicator in break but return to range)
//+------------------------------------------------------------------+
bool  CModelProtect::trendToRange(){
   
   if(this.rangeBreak()){   
      int statusDetailFlg=this.getRange().getStatusDetailFlg();
      if(statusDetailFlg==STATUS_RANGE_BREAK_UP_RE
           || statusDetailFlg==STATUS_RANGE_BREAK_DOWN_RE){
         return true;     
      }
   }
   
   // return to range      
   /*
   double breakPips=this.getRange().getBreakPips();
   if(breakPips<Trend_To_Range_Less_Pips 
      && this.getModelAnalysisPre().getExceedCurProfit()<Clear_Model_Exceed_Min_SumPips){
   //if(this.getModelAnalysisPre().getExceedCurProfit()<Clear_Model_Exceed_Min_SumPips){      
       ENUM_ORDER_TYPE exceedType=this.getModelAnalysis().getExceedType();
       ENUM_ORDER_TYPE exceedPreType=this.getModelAnalysisPre().getExceedType();
       if(exceedType==exceedPreType)return true;      
   }*/
        
   return false;
}

//+------------------------------------------------------------------+
//|  judge if exceed trend to jump
//+------------------------------------------------------------------+
bool  CModelProtect::exceedToJump(double minJumpProfitPips){   
   
   CModelAnalysisPre*  modelAnalysisPre=this.getModelAnalysisPre();
   double exceedCurProfit=modelAnalysisPre.getExceedCurProfit();
   //ENUM_ORDER_TYPE exceedType=modelAnalysisPre.getExceedType();   
   if(exceedCurProfit>=minJumpProfitPips)return true;
   return false;
}

//+------------------------------------------------------------------+
//|  judge if exceed trend to jump(current jump)
//+------------------------------------------------------------------+
bool  CModelProtect::exceedToCurJump(double minJumpProfitPips){   
   
   CModelAnalysis*  modelAnalysis=this.getModelAnalysis();
   double exceedCurProfit=modelAnalysis.getExceedCurProfit();
   //ENUM_ORDER_TYPE exceedType=modelAnalysisPre.getExceedType();   
   if(exceedCurProfit>=minJumpProfitPips)return true;
   return false;
}

//+------------------------------------------------------------------+
//|  get range 
//+------------------------------------------------------------------+
CRange*  CModelProtect::getRange(){
   return this.getAnalysisShare().getCurRange();
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelProtect::CModelProtect(){}
CModelProtect::~CModelProtect(){
}