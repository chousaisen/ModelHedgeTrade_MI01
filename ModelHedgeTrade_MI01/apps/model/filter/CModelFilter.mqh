//+------------------------------------------------------------------+
//|                                                 CModelFilter.mqh |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "../../share/CShareCtl.mqh"
#include "../../share/filter/CFilterI.mqh"

class CModelFilter : public CFilterI
{
      private:
         CShareCtl*            shareCtl;
      public:
                          CModelFilter();
                          ~CModelFilter(); 
        //--- interface function             
        void              init(CShareCtl *shareCtl); 
        bool              signalFilter(int symbolIndex,ENUM_ORDER_TYPE type);     
        bool              openFilter(CSignal* signal);     
        bool              extendFilter(CModelI* model);
        bool              closeFilter(CModelI* model);
        bool              closeFilter(COrder* order);
        bool              clearFilter(CModelI* model);
        void              refresh();
        //--- open hedge lot
        double            openHedgeLot(CModelI* model,CHedgeGroup* modelGroup);
        double            openHedgeLot(CSignal* signal,CHedgeGroup* modelGroup);
        double            openHedgeLot(CSignal* signal);
        double            openHedgeLot(CModelI* model);
        double            closeHedgeLot(CModelI* model);
        double            hedgeRate();
        //--- clear hedge lot
        double            clearHedgeLot(CModelI* model);
        double            clearHedgeLot(CModelI* model,CHedgeGroup* modelGroup);
        //--- add clear model
        void              addClearModel(CModelI* model); 
        //--- judge if diff grid pips
        bool              diffGrid(CSignal* signal,double  diffPips,bool exceedFlg);
        
        //--- custom function
        CIndicatorShare*   getIndShare();
        CModelShare*       getModelShare();
        CHedgeShare*       getHedgeShare();
        CAnalysisShare*    getAnalysisShare();
        CModelAnalysis*    getModelAnalysis();
        CModelAnalysisPre* getModelAnalysisPre();
        CSymbolShare*      getSymbolShare();
        CHedgeGroup*       getHedgePool();
        CHedgeGroupInfo*   getHedgePoolInfo();
        int                getExceedIndex(int symbolIndex,ENUM_ORDER_TYPE tradeType);
        int                getCurrentExceedIndex(int symbolIndex,ENUM_ORDER_TYPE tradeType);
        int                getOrderCount();
        double             getCurPrice(int symbolIndex,ENUM_ORDER_TYPE type);
        double             getCurPrice(int symbolIndex);
        double             getPoint(int symbolIndex);
        
        //--- get status
        CRange*           getRange();
        int               getRangeStatus();
        int               getTrendStatus();
        bool              indicatorReady();
        bool              range();
        bool              rangeBreak();
        bool              rangeBreakUp();
        bool              rangeBreakDown();
        bool              sameTrend(ENUM_ORDER_TYPE tradeType);
        bool              sameTrend(CSignal* signal);
        bool              sameTrend(CModelI* model);
        bool              modelTrend(CModelI* model);
        //bool              breakModel(CModelI* model);
        //bool              rangeModel(CModelI* model);
        //bool              sarTrend(int symbolIndex);
        //bool              sarTrendUp(int symbolIndex);
        //bool              sarTrendDown(int symbolIndex);        
        //bool              curExceedSameAllExceed();
        bool              trendToRange();
        bool              trendToJump();
        bool              trendSameToJump(ENUM_ORDER_TYPE tradeType);
        bool              exceedSameTrend();
        bool              exceedToJump(double minJumpProfitPips);
        bool              exceedToCurJump(double minJumpProfitPips);
        bool              exceedSameType(ENUM_ORDER_TYPE tradeType);
        bool              exceedSameCurType(ENUM_ORDER_TYPE tradeType);
        bool              exceedToSameJump(ENUM_ORDER_TYPE tradeType,double minJumpProfitPips);
        bool              exceedToSameCurJump(ENUM_ORDER_TYPE tradeType,double minJumpProfitPips);
                
        //adjust hedge rate by risk exceed profit
        double            getAdjustRiskHedgeRate(double minRiskExceedProfit,
                                                double maxRiskExceedProfit,
                                                double minRiskHedgeRate,
                                                double maxRiskHedgeRate,
                                                double growRate = 1.0);
                                                
        //adjust diff rate by risk exceed profit
        double            getAdjustRiskDiffRate(double minRiskExceedProfit,
                                                double maxRiskExceedProfit,
                                                double minRiskDiffRate,
                                                double maxRiskDiffRate,
                                                double growRate = 1.0); 
        //get adjust exceed extend max orders                                        
        double            getAdjustExceedExtendMaxOrders(double currentExceedIndex);
        
        //--- DB Control
        void              insertTable(string tableName,
                                          string insertTemplate);
                                          
        //--- define log info                                           
        string           middleLog;
        string           tradeDealLog;         
        void             addDebugInfo(bool reValue);
               
};
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CModelFilter::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.shareCtl.getFilterShare().addOpenFilter(&this);
}

//+------------------------------------------------------------------+
//|  get indicator share
//+------------------------------------------------------------------+
CIndicatorShare* CModelFilter::getIndShare(){
   return this.shareCtl.getIndicatorShare();
}

//+------------------------------------------------------------------+
//|  get model share
//+------------------------------------------------------------------+
CModelShare* CModelFilter::getModelShare(){
   return this.shareCtl.getModelShare();
}

//+------------------------------------------------------------------+
//|  get hedge share
//+------------------------------------------------------------------+
CHedgeShare* CModelFilter::getHedgeShare(){
   return this.shareCtl.getHedgeShare();
}

//+------------------------------------------------------------------+
//|  get analysis share
//+------------------------------------------------------------------+
CAnalysisShare* CModelFilter::getAnalysisShare(){
   return this.shareCtl.getAnalysisShare();
}

//+------------------------------------------------------------------+
//|  get model analysis share
//+------------------------------------------------------------------+
CModelAnalysis* CModelFilter::getModelAnalysis(){
   return this.getModelShare().getModelAnalysis();
}

//+------------------------------------------------------------------+
//|  get model analysis share (all models)
//+------------------------------------------------------------------+
CModelAnalysisPre* CModelFilter::getModelAnalysisPre(){
   return this.getModelShare().getModelAnalysisPre();
}

//+------------------------------------------------------------------+
//|  get adjust hedge rate
//+------------------------------------------------------------------+
double CModelFilter::getAdjustRiskHedgeRate(double minRiskExceedProfit,
                                            double maxRiskExceedProfit,
                                            double minRiskHedgeRate,
                                            double maxRiskHedgeRate,
                                            double growRate = 1.0){
   CModelAnalysisPre*  modelAnalysisPre=this.getModelShare().getModelAnalysisPre();
   double exceedCurProfit=modelAnalysisPre.getExceedCurProfit();
   ENUM_ORDER_TYPE exceedType=modelAnalysisPre.getExceedType();   
   
   double adjustHedgeRate=comFunc2.mapExtValue(-exceedCurProfit,
                                             -minRiskExceedProfit,
                                             -maxRiskExceedProfit,
                                             minRiskHedgeRate,
                                             maxRiskHedgeRate,
                                             growRate);
   
   if(rkeeLog.debugPeriod(9921,300)){
      string exceedTypeStr="BUY";
      if(exceedType==ORDER_TYPE_SELL){
         exceedTypeStr="SELL";
      }
      string debugLog=  "<getAdjustHedgeRate>" + StringFormat("%.2f",adjustHedgeRate)
                      + "<exceedCurProfit>" + exceedCurProfit 
                      + "<type>" + exceedTypeStr
                      + "<buyLot>" + StringFormat("%.2f",modelAnalysisPre.getBuySumLot())
                      + "<sellLot>" + StringFormat("%.2f",modelAnalysisPre.getSellSumLot())
                      + "<exceedLot>" + StringFormat("%.2f",modelAnalysisPre.getExceedSumLot())
                      + "<exceedRate>" + StringFormat("%.2f",modelAnalysisPre.getExceedRate())
                      + "<hedgeRate>" + StringFormat("%.2f",this.getHedgePool().getHedgeRate());                      

      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + debugLog,
                        "AdjustHedgeRate");
   }                                              
                                             
   return adjustHedgeRate;                                             
}

//+------------------------------------------------------------------+
//|  get adjust diff rate
//+------------------------------------------------------------------+
double CModelFilter::getAdjustRiskDiffRate(double minRiskExceedProfit,
                                         double maxRiskExceedProfit,
                                         double minRiskDiffRate,
                                         double maxRiskDiffRate,
                                         double growRate = 1.0){
   CModelAnalysisPre*  modelAnalysisPre=this.getModelShare().getModelAnalysisPre();
   double exceedCurProfit=modelAnalysisPre.getExceedCurProfit();
   ENUM_ORDER_TYPE exceedType=modelAnalysisPre.getExceedType();   
   
   double adjustDiffRate=comFunc2.mapExtValue(-exceedCurProfit,
                                             -minRiskExceedProfit,
                                             -maxRiskExceedProfit,
                                             minRiskDiffRate,
                                             maxRiskDiffRate,
                                             growRate);
   
   if(rkeeLog.debugPeriod(9921,300)){
      string exceedTypeStr="BUY";
      if(exceedType==ORDER_TYPE_SELL){
         exceedTypeStr="SELL";
      }
      string debugLog= "<getAdjustDiffRate>" + StringFormat("%.2f",adjustDiffRate)
                      + "<exceedCurProfit>" + exceedCurProfit 
                      + "<type>" + exceedTypeStr
                      + "<buyLot>" + StringFormat("%.2f",modelAnalysisPre.getBuySumLot())
                      + "<sellLot>" + StringFormat("%.2f",modelAnalysisPre.getSellSumLot())
                      + "<exceedLot>" + StringFormat("%.2f",modelAnalysisPre.getExceedSumLot())
                      + "<exceedRate>" + StringFormat("%.2f",modelAnalysisPre.getExceedRate())
                      + "<hedgeRate>" + StringFormat("%.2f",this.getHedgePool().getHedgeRate());                      
                      
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+ "  " + debugLog,
                        "AdjustDiffRate");
   }                                              
                                             
   return adjustDiffRate;                                             
}

//+------------------------------------------------------------------+
//|  get model analysis share
//+------------------------------------------------------------------+
CSymbolShare* CModelFilter::getSymbolShare(){
   return this.shareCtl.getSymbolShare();
}

//+------------------------------------------------------------------+
//|  get symbol price
//+------------------------------------------------------------------+
double CModelFilter::getCurPrice(int symbolIndex,ENUM_ORDER_TYPE type){
   string symbol=SYMBOL_LIST[symbolIndex];
   return this.getSymbolShare().getSymbolPrice(symbol,type);   
}

//+------------------------------------------------------------------+
//|  get symbol price(default)
//+------------------------------------------------------------------+
double CModelFilter::getCurPrice(int symbolIndex){
   string symbol=SYMBOL_LIST[symbolIndex];
   return this.getSymbolShare().getSymbolPrice(symbol,ORDER_TYPE_BUY);   
}

//+------------------------------------------------------------------+
//|  get symbol point
//+------------------------------------------------------------------+
double CModelFilter::getPoint(int symbolIndex){
   string symbol=SYMBOL_LIST[symbolIndex];
   return this.getSymbolShare().getSymbolPoint(symbol);   
}

//+------------------------------------------------------------------+
//|  get order count
//+------------------------------------------------------------------+
int CModelFilter::getOrderCount(){
   return this.getHedgeShare().getHedgeGroupPool().getHedgeOrderCount();
}

//+------------------------------------------------------------------+
//|  get current exceed model index from model analysis share
//+------------------------------------------------------------------+
int CModelFilter::getExceedIndex(int symbolIndex,ENUM_ORDER_TYPE tradeType){
   
   CArrayList<CModelI*> modelList=this.getModelAnalysisPre().getExceedModelList();
   int modelCount=modelList.Count();
   if(modelCount<=0)return 0;
   ENUM_ORDER_TYPE exceedType=this.getModelAnalysisPre().getExceedType();
   if(exceedType!=tradeType)return 0;
   string symbol=SYMBOL_LIST[symbolIndex];
   double curPrice=this.getSymbolShare().getSymbolPrice(symbol,ORDER_TYPE_BUY);      
   int exceedIndex=0;
   //get current price in the exceed model index
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;
      if(modelList.TryGetValue(i,model)){                           
         if(exceedType == ORDER_TYPE_BUY
            && curPrice<model.getAvgPrice()){            
              break;                  
         }else if(exceedType == ORDER_TYPE_SELL
            && curPrice>model.getAvgPrice()){            
              break;                  
         }
         exceedIndex++;      
      }
   }
   return exceedIndex;
}

//+------------------------------------------------------------------+
//|  get current exceed model index from model analysis share
//+------------------------------------------------------------------+
int CModelFilter::getCurrentExceedIndex(int symbolIndex,ENUM_ORDER_TYPE tradeType){
   
   CArrayList<CModelI*> modelList=this.getModelAnalysis().getExceedModelList();
   int modelCount=modelList.Count();
   if(modelCount<=0)return 0;
   ENUM_ORDER_TYPE exceedType=this.getModelAnalysis().getExceedType();
   if(exceedType!=tradeType)return 0;
   string symbol=SYMBOL_LIST[symbolIndex];
   double curPrice=this.getSymbolShare().getSymbolPrice(symbol,ORDER_TYPE_BUY);      
   int exceedIndex=0;
   //get current price in the exceed model index
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;
      if(modelList.TryGetValue(i,model)){                           
         if(exceedType == ORDER_TYPE_BUY
            && curPrice<model.getAvgPrice()){            
              break;                  
         }else if(exceedType == ORDER_TYPE_SELL
            && curPrice>model.getAvgPrice()){            
              break;                  
         }
         exceedIndex++;      
      }
   }
   return exceedIndex;
}

//+------------------------------------------------------------------+
//|  get hedge pool
//+------------------------------------------------------------------+
CHedgeGroup* CModelFilter::getHedgePool(){
   return this.getHedgeShare().getHedgeGroupPool();
}

//+------------------------------------------------------------------+
//|  get hedge pool info
//+------------------------------------------------------------------+
CHedgeGroupInfo* CModelFilter::getHedgePoolInfo(){
   return this.getHedgePool().getHedgeGroupInfo();
}
        
//+------------------------------------------------------------------+
//|  filter the open model
//+------------------------------------------------------------------+
bool CModelFilter::openFilter(CSignal* signal)
{      
   return true;
}

//+------------------------------------------------------------------+
//|  filter the extne model
//+------------------------------------------------------------------+
bool CModelFilter::extendFilter(CModelI *model)
{      
   return true;
}

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CModelFilter::closeFilter(CModelI* model)
{    
   return true;
}

//+------------------------------------------------------------------+
//|  filter the close order
//+------------------------------------------------------------------+
bool CModelFilter::closeFilter(COrder* model)
{    
   return true;
}

//+------------------------------------------------------------------+
//|  filter the clear model
//+------------------------------------------------------------------+
bool CModelFilter::clearFilter(CModelI* model)
{    
   return true;
}

//+------------------------------------------------------------------+
//|  refresh filter
//+------------------------------------------------------------------+
void CModelFilter::refresh(){
}


//+------------------------------------------------------------------+
//|  clear minus models
//+------------------------------------------------------------------+
double CModelFilter::clearHedgeLot(CModelI* model){

   CHedgeGroup* modelGroup=this.shareCtl.getHedgeShare().getHedgeGroupPool();
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
double CModelFilter::clearHedgeLot(CModelI* model,CHedgeGroup* modelGroup){
   int symbolIndex=model.getSymbolIndex();
   ENUM_ORDER_TYPE type=model.getTradeType();
   if(type==ORDER_TYPE_SELL){
      type=ORDER_TYPE_BUY;
   }else{
      type=ORDER_TYPE_SELL;
   }
   double lot=model.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){
      return lot;
   }
   return 0;
}

//+------------------------------------------------------------------+
//|  open signal hedge
//+------------------------------------------------------------------+
double CModelFilter::openHedgeLot(CSignal* signal,CHedgeGroup* modelGroup){
   int symbolIndex=signal.getSymbolIndex();
   ENUM_ORDER_TYPE type=signal.getTradeType();
   double lot=signal.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){
      //modelGroup.hedgeOrders();
      return lot;
   }
   return 0;
}

//+------------------------------------------------------------------+
//|  open models hedge
//+------------------------------------------------------------------+
double CModelFilter::openHedgeLot(CModelI* model,CHedgeGroup* modelGroup){
   int symbolIndex=model.getSymbolIndex();
   ENUM_ORDER_TYPE type=model.getTradeType();
   double lot=model.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){
      //modelGroup.hedgeOrders();
      return lot;
   }
   return 0;
}

//+------------------------------------------------------------------+
//|  open signal hedge
//+------------------------------------------------------------------+
double CModelFilter::openHedgeLot(CSignal* signal){   
   CHedgeGroup* modelGroup=this.getHedgeShare().getHedgeGroupPool();
   int symbolIndex=signal.getSymbolIndex();
   ENUM_ORDER_TYPE type=signal.getTradeType();
   double lot=signal.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){
      //modelGroup.hedgeOrders();
      return lot;
   }
   return 0;
}

//+------------------------------------------------------------------+
//|  open models hedge
//+------------------------------------------------------------------+
double CModelFilter::openHedgeLot(CModelI* model){   
   CHedgeGroup* modelGroup=this.getHedgeShare().getHedgeGroupPool();
   int symbolIndex=model.getSymbolIndex();
   ENUM_ORDER_TYPE type=model.getTradeType();
   double lot=model.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){
      //modelGroup.hedgeOrders();
      return lot;
   }
   return 0;
}

//+------------------------------------------------------------------+
//|  open models hedge
//+------------------------------------------------------------------+
double CModelFilter::closeHedgeLot(CModelI* model){   
   CHedgeGroup* modelGroup=this.getHedgeShare().getHedgeGroupPool();
   int symbolIndex=model.getSymbolIndex();
   ENUM_ORDER_TYPE type=model.getTradeType();
   if(type==ORDER_TYPE_SELL){
      type=ORDER_TYPE_BUY;
   }else{
      type=ORDER_TYPE_SELL;
   }   
   double lot=model.getLot();   
   if(modelGroup.ifHedgeSymbolLot(symbolIndex,type,lot)){   
      return lot;
   }
   return 0;
}

//+------------------------------------------------------------------+
//|  open models hedge
//+------------------------------------------------------------------+
double CModelFilter::hedgeRate(){   
   CHedgeGroup* modelGroup=this.getHedgeShare().getHedgeGroupPool();
   return modelGroup.getHedgeRate();
}

//+------------------------------------------------------------------+
//|  add clear model
//+------------------------------------------------------------------+
void  CModelFilter::addClearModel(CModelI* model){
   model.markClearFlag(true);
}


//+------------------------------------------------------------------+
//|  judge grid diff pips
//+------------------------------------------------------------------+
bool CModelFilter::diffGrid(CSignal* signal,double  diffPips,bool exceedFlg){      
   
   //get param
   int symbolIndex=signal.getSymbolIndex();
   ENUM_ORDER_TYPE type=signal.getTradeType();   

   CArrayList<CModelI*> modelList=this.shareCtl.getModelShare().getModels();
   int modelCount=modelList.Count();    
   //clean model list
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){         
         if(model.getModelKind()==signal.getModelKind()
            && model.getSymbolIndex()==symbolIndex
            && model.getTradeType()==type){
            double curStartLine=model.getStartLine();
            if(curStartLine<=0)continue;
            double curSymbolPrice=model.getSymbolPrice();
            double curSymbolPoint=model.getSymbolPoint();
            double curDiffPips=MathAbs((curSymbolPrice-curStartLine)/curSymbolPoint);
            if(type!=model.getTradeType()){
               continue;
            }
            if(model.getStatusFlg()!=this.getRange().getStatusFlg()){
               continue;
            }
            
            if(exceedFlg){
               if(model.getStatusIndex()!=this.getRange().getStatusIndex())continue;            
            }
            
            if(curDiffPips<diffPips){
               return false;
            }
          }                  
      }
   } 
   return true;
}

//+------------------------------------------------------------------+
//|  get range 
//+------------------------------------------------------------------+
CRange*  CModelFilter::getRange(){
   return this.getAnalysisShare().getCurRange();
}

//+------------------------------------------------------------------+
//|  judge if range 
//+------------------------------------------------------------------+
bool  CModelFilter::range(){   
   if(this.getRangeStatus()==STATUS_RANGE_INNER){
      return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if exceed same trend 
//+------------------------------------------------------------------+
bool  CModelFilter::exceedSameTrend(){
   
   //begin time
   if(this.getModelAnalysis().getExceedSumLot()<=0)return true;
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

//+------------------------------------------------------------------+
//|  judge if current exceed same to all exceed status
//+------------------------------------------------------------------+
/*
bool  CModelFilter::curExceedSameAllExceed(){

   //begin time
   if(this.getModelAnalysis().getExceedSumLot()<=0)return true;
   if(this.getModelAnalysisPre().getExceedSumLot()<=0)return true;
         
   ENUM_ORDER_TYPE curExceedType=this.getModelAnalysis().getExceedType();
   ENUM_ORDER_TYPE allExceedType=this.getModelAnalysisPre().getExceedType();

   if(curExceedType==allExceedType){
      return true;
   }
   
   return false;
}*/

//+------------------------------------------------------------------+
//|  judge if exceed trend to range
//+------------------------------------------------------------------+
bool  CModelFilter::trendToRange(){   
   
   if(this.rangeBreak()){   
      /*
      double breakPips=this.getRange().getBreakPips();
      if(breakPips<Trend_To_Range_Less_Pips){
         return true;
      } */
      int statusDetailFlg=this.getRange().getStatusDetailFlg();
      if(statusDetailFlg==STATUS_RANGE_BREAK_UP_RE
           || statusDetailFlg==STATUS_RANGE_BREAK_DOWN_RE){
         return true;     
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
   }
   return false;
}

//+------------------------------------------------------------------+
//|  judge if trend to jump
//+------------------------------------------------------------------+
bool  CModelFilter::trendToJump(){      
   if(this.rangeBreak() && !this.trendToRange())return true;
   return false;
}

//+------------------------------------------------------------------+
//|  judge if trend to jump
//+------------------------------------------------------------------+
bool  CModelFilter::trendSameToJump(ENUM_ORDER_TYPE tradeType){      
   if(this.sameTrend(tradeType) && !this.trendToRange())return true;
   return false;
}

//+------------------------------------------------------------------+
//|  judge if exceed trend to jump
//+------------------------------------------------------------------+
bool  CModelFilter::exceedToJump(double minJumpProfitPips){   
   
   CModelAnalysisPre*  modelAnalysisPre=this.getModelShare().getModelAnalysisPre();
   double exceedCurProfit=modelAnalysisPre.getExceedCurProfit();
   //ENUM_ORDER_TYPE exceedType=modelAnalysisPre.getExceedType();   
   if(exceedCurProfit>=minJumpProfitPips)return true;
   return false;
}

//+------------------------------------------------------------------+
//|  judge if exceed trend to jump(current jump)
//+------------------------------------------------------------------+
bool  CModelFilter::exceedToCurJump(double minJumpProfitPips){   
   
   CModelAnalysis*  modelAnalysis=this.getModelShare().getModelAnalysis();
   double exceedCurProfit=modelAnalysis.getExceedCurProfit();
   //ENUM_ORDER_TYPE exceedType=modelAnalysisPre.getExceedType();   
   if(exceedCurProfit>=minJumpProfitPips)return true;
   return false;
}

//+------------------------------------------------------------------+
//|  judge if exceed same to jump
//+------------------------------------------------------------------+
bool  CModelFilter::exceedSameType(ENUM_ORDER_TYPE tradeType){
   CModelAnalysisPre*  modelAnalysisPre=this.getModelShare().getModelAnalysisPre();
   ENUM_ORDER_TYPE exceedType=modelAnalysisPre.getExceedType();
   if(tradeType==exceedType)return true;
   return false;
}

//+------------------------------------------------------------------+
//|  judge if exceed same to jump
//+------------------------------------------------------------------+
bool  CModelFilter::exceedSameCurType(ENUM_ORDER_TYPE tradeType){
   CModelAnalysis*  modelAnalysis=this.getModelShare().getModelAnalysis();
   ENUM_ORDER_TYPE exceedType=modelAnalysis.getExceedType();
   if(tradeType==exceedType)return true;
   return false;
}

//+------------------------------------------------------------------+
//|  judge if exceed trend to jump
//+------------------------------------------------------------------+
bool  CModelFilter::exceedToSameJump(ENUM_ORDER_TYPE tradeType,double minJumpProfitPips){   
   
   CModelAnalysisPre*  modelAnalysisPre=this.getModelShare().getModelAnalysisPre();
   double exceedCurProfit=modelAnalysisPre.getExceedCurProfit();
   ENUM_ORDER_TYPE exceedType=modelAnalysisPre.getExceedType();   
   if(exceedCurProfit>=minJumpProfitPips
       && exceedType==tradeType){
       return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if exceed trend to jump
//+------------------------------------------------------------------+
bool  CModelFilter::exceedToSameCurJump(ENUM_ORDER_TYPE tradeType,double minJumpProfitPips){   
   
   CModelAnalysis*  modelAnalysis=this.getModelShare().getModelAnalysis();
   double exceedCurProfit=modelAnalysis.getExceedCurProfit();
   ENUM_ORDER_TYPE exceedType=modelAnalysis.getExceedType();   
   if(exceedCurProfit>=minJumpProfitPips
       && exceedType==tradeType){
       return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if indicators ready
//+------------------------------------------------------------------+
bool  CModelFilter::indicatorReady(){   
   if(this.getRangeStatus()==STATUS_NONE){
      return false;
   }    
   return true;
}

//+------------------------------------------------------------------+
//|  judge if range break
//+------------------------------------------------------------------+
bool  CModelFilter::rangeBreak(){   
   if(this.rangeBreakUp() || this.rangeBreakDown()){
      return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if range break up
//+------------------------------------------------------------------+
bool  CModelFilter::rangeBreakUp(){   
   if(this.getRangeStatus()==STATUS_RANGE_BREAK_UP){
      return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if range break down
//+------------------------------------------------------------------+
bool  CModelFilter::rangeBreakDown(){   
   if(this.getRangeStatus()==STATUS_RANGE_BREAK_DOWN){
      return true;
   }    
   return false;
}

//+------------------------------------------------------------------+
//|  judge if sar trend 
//+------------------------------------------------------------------+
/*
bool   CModelFilter::sarTrend(int symbolIndex){
   if(this.sarTrendUp(symbolIndex) || this.sarTrendDown(symbolIndex)){
      return true;
   }
   return false;
}*/


//+------------------------------------------------------------------+
//|  judge if sar trend up
//+------------------------------------------------------------------+
/*
bool   CModelFilter::sarTrendUp(int symbolIndex){
   if(this.getAnalysisShare().getSarTrendFlg(symbolIndex)==IND_SAR_TREND_UP){
      return true;
   }
   return false;
}*/

//+------------------------------------------------------------------+
//|  judge if sar trend down
//+------------------------------------------------------------------+
/*
bool   CModelFilter::sarTrendDown(int symbolIndex){
   if(this.getAnalysisShare().getSarTrendFlg(symbolIndex)==IND_SAR_TREND_DOWN){
      return true;
   }
   return false;
}*/

//+------------------------------------------------------------------+
//|  judge if range break same trend
//+------------------------------------------------------------------+
bool  CModelFilter::sameTrend(ENUM_ORDER_TYPE tradeType){
   if(tradeType==ORDER_TYPE_BUY){
      if(this.rangeBreakUp())return true;
   }else if(tradeType==ORDER_TYPE_SELL){
      if(this.rangeBreakDown())return true;
   }
   return false;   
}


//+------------------------------------------------------------------+
//|  judge if range break same trend
//+------------------------------------------------------------------+
bool  CModelFilter::sameTrend(CSignal* signal){
   if(signal.getTradeType()==ORDER_TYPE_BUY){
      if(this.rangeBreakUp())return true;
   }else if(signal.getTradeType()==ORDER_TYPE_SELL){
      if(this.rangeBreakDown())return true;
   }
   return false;   
}

//+------------------------------------------------------------------+
//|  judge if range break same trend(model)
//+------------------------------------------------------------------+
bool  CModelFilter::sameTrend(CModelI* model){
   if(model.getTradeType()==ORDER_TYPE_BUY){
      if(this.rangeBreakUp())return true;
   }else if(model.getTradeType()==ORDER_TYPE_SELL){
      if(this.rangeBreakDown())return true;
   }
   return false;   
}

//+------------------------------------------------------------------+
//|  judge if range break same trend(model)
//+------------------------------------------------------------------+
bool  CModelFilter::modelTrend(CModelI* model){
   if(model.getStatusFlg()==STATUS_RANGE_BREAK_UP){
      if(this.rangeBreakUp())return true;
   }else if(model.getStatusFlg()==STATUS_RANGE_BREAK_DOWN){
      if(this.rangeBreakDown())return true;
   }
   return false;   
}

//+------------------------------------------------------------------+
//|  get range status
//+------------------------------------------------------------------+
int  CModelFilter::getRangeStatus(){
   return this.getAnalysisShare().getCurRange().getStatusFlg();
}

//+------------------------------------------------------------------+
//| insert info into table
//+------------------------------------------------------------------+
void CModelFilter::insertTable(string tableName,string insertTemplate){
   this.shareCtl.getClientCtl().getDB().saveData(tableName,insertTemplate);
}

//+------------------------------------------------------------------+
//| get adjust exceed extend max orders
//+------------------------------------------------------------------+
double CModelFilter::getAdjustExceedExtendMaxOrders(double currentExceedIndex){
    return comFunc2.mapExtValue(currentExceedIndex,
                                    GRID_OPEN_EXTEND_EXCEED_MIN_MODEL,
                                    GRID_OPEN_EXTEND_EXCEED_MAX_MODEL,
                                    GRID_OPEN_EXTEND_EXCEED_MIN_ORDER,
                                    GRID_OPEN_EXTEND_EXCEED_MAX_ORDER,
                                    1); 
}

//+------------------------------------------------------------------+
//| add debug info
//+------------------------------------------------------------------+
void CModelFilter::addDebugInfo(bool reValue){

   //if(reValue){
      logData.addDebugInfo(this.tradeDealLog); 
      this.middleLog = this.middleLog + this.tradeDealLog + "<" + reValue + ">";
      this.tradeDealLog="";
   //}
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelFilter::CModelFilter(){}
CModelFilter::~CModelFilter(){
}