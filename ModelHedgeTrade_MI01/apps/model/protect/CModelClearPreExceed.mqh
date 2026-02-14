//+------------------------------------------------------------------+
//|                                             CModelClearPreExceed.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "../../comm/ComFunc2.mqh"
#include "../../share/CShareCtl.mqh"
#include "../CModelI.mqh"
#include "CModelProtect.mqh"

class CModelClearPreExceed: public CModelProtect 
{
      private:
           string         debugLog;
      public:
                          CModelClearPreExceed();
                          ~CModelClearPreExceed();
      //--- clear Exceed models
      void                clearExceedModels();                     
      //--- clear Exceed return models
      void                clearPreExceedModels();
      //--- clear Exceed return models(reverse model)
      void                clearPreExceedReModels();      
      //--- clear Exceed models by limit lots                                          
      void                clearExceedModels(CArrayList<CModelI*>* modelList,
                                            double limitLots,
                                            double minProfit);
};

//+------------------------------------------------------------------+
//|  clear exceed models
//+------------------------------------------------------------------+
void CModelClearPreExceed::clearExceedModels(){

   //clear exceed previous models
   this.clearPreExceedModels();
   //clear exceed previous models(reverse model)
   //this.clearPreExceedReModels();
}

//+------------------------------------------------------------------+
//|  clear exceed previous models
//+------------------------------------------------------------------+
void CModelClearPreExceed::clearPreExceedModels(){
   
   if(!Clear_Model_PreExceed)return;
   
   //check indicator ready
   if(!this.indicatorReady()){
      return;
   }   
   
   datetime curTime;
   if(rkeeLog.debugPeriod(9621,300)){
      curTime=TimeCurrent();
   }
   
   //when break out
   if(this.range())return;
   if(this.trendToRange())return;
   //exceed to jump
   if(!this.exceedToCurJump(Clear_Model_PreExceed_Jump_Min_Pips))return;

   //same trend with current exceed
   //if(!this.exceedSameTrend() || this.exceedSamePre()){
   if(this.exceedSamePre()){
      return;
   }   
   
   logData.addDebugInfo("<<clearPreExceedModels>>");
      
   double preExceedSumLot=this.getModelAnalysisPre().getExceedSumLot();
   double preExceedSumProfitPips=this.getModelAnalysisPre().getExceedCurProfit();
   
   double limitpreExceedSumLot=Clear_Model_PreExceed_Min_Lot;
   double limitpreExceedSumProfitPips=Clear_Model_PreExceed_Less_SumProfit;
   
   if(preExceedSumLot<Clear_Model_PreExceed_Min_Lot)return;         
   //if(preExceedSumProfitPips>Clear_Model_PreExceed_Less_SumProfit)return;  
   
   double curExceedSumLot=this.getModelAnalysis().getExceedSumLot();
   double curExceedReSumLotRate=this.getModelAnalysis().getExceedReSumLotRate();
   //if(curExceedReSumLotRate>0.05)return;
   //double clearPreExceedLot=curExceedSumLot*(1-curExceedReSumLotRate);
   //double clearPreExceedLot=curExceedSumLot;
   double lotExceedRate=Clear_Model_PreExceed_GrowRate;
   double clearLimitPreExceedLot=comFunc2.mapExtValue(curExceedSumLot,
                                                      Clear_Model_PreExceed_Begin_Lot,
                                                      1,
                                                      0.01,
                                                      1,
                                                      lotExceedRate);                                                                                  
   
   ENUM_ORDER_TYPE curExceedType=this.getModelAnalysis().getExceedType();
   ENUM_ORDER_TYPE preExceedType=this.getModelAnalysisPre().getExceedType();
   
   CArrayList<CModelI*>* preExceedModelList=this.getModelAnalysisPre().getExceedModelList();    
   
   if(curExceedType!=preExceedType){   
      this.clearExceedModels(preExceedModelList,
                              clearLimitPreExceedLot,
                              Clear_Model_PreExceed_Min_Profit); 
                            
         logData.addDebugInfo("<ExceedType>" 
                               + "<rangeStatus>" + this.getRangeStatus()                         
                               + "<exceedCount>" + preExceedModelList.Count()
                               + "<curExceedSumLot>" + curExceedSumLot
                               + "<lotExceedRate>" + lotExceedRate
                               //+ "<clearPreExceedLot>" + clearPreExceedLot
                               + "<clearLimitPreExceedLot>" + clearLimitPreExceedLot);
                               
   }
          
}


//+------------------------------------------------------------------+
//|  clear exceed models
//+------------------------------------------------------------------+
void CModelClearPreExceed::clearPreExceedReModels(){
   
   if(!Clear_Model_PreExceedRe)return;
   //when break out
   if(this.range())return;      
   //same trend with current exceed
   //if(!this.exceedSameTrend())return;
   
   logData.addDebugInfo("<<clearPreExceedReModels>>");
      
   double preExceedSumLot=this.getModelAnalysisPre().getExceedSumLot();
   double preExceedSumProfitPips=this.getModelAnalysisPre().getExceedCurProfit();
   
   if(preExceedSumLot<Clear_Model_PreExceedRe_Min_Lot)return;
   if(preExceedSumProfitPips>Clear_Model_PreExceedRe_Less_SumProfit)return;
   
   double curExceedSumLot=this.getModelAnalysis().getExceedSumLot();
   double curExceedReSumLotRate=this.getModelAnalysis().getExceedReSumLotRate();
   
   if(curExceedReSumLotRate>0.05)return;
   
   //double clearPreExceedLot=curExceedSumLot*(1-curExceedReSumLotRate);
   //double clearPreExceedLot=curExceedSumLot;
   double lotExceedRate=Clear_Model_PreExceedRe_GrowRate;
   double clearLimitPreExceedLot=comFunc2.mapExtValue(curExceedSumLot,
                                                      Clear_Model_PreExceedRe_Begin_Lot,
                                                      1,
                                                      0.01,
                                                      1,
                                                      lotExceedRate);                                                                                  
   
   ENUM_ORDER_TYPE curExceedType=this.getModelAnalysis().getExceedType();
   ENUM_ORDER_TYPE preExceedType=this.getModelAnalysisPre().getExceedType();
   
   CArrayList<CModelI*>* preExceedModelList=this.getModelAnalysisPre().getExceedModelList();    
   
   if(curExceedType==preExceedType){   
      this.clearExceedModels(preExceedModelList,
                              clearLimitPreExceedLot,
                              Clear_Model_PreExceedRe_Min_Profit);  
      logData.addDebugInfo("<Reverse ExceedType>" 
                               + "<rangeStatus>" + this.getRangeStatus()                         
                               + "<exceedCount>" + preExceedModelList.Count()
                               + "<curExceedSumLot>" + curExceedSumLot
                               + "<lotExceedRate>" + lotExceedRate
                               + "<lotExceedReRate>" + curExceedReSumLotRate 
                               + "<clearLimitPreExceedLot>" + clearLimitPreExceedLot);
   }else{
   
   
   }
          
}

//+------------------------------------------------------------------+
//|  clear exceed models
//+------------------------------------------------------------------+
void CModelClearPreExceed::clearExceedModels(CArrayList<CModelI*>* modelList,
                                                   double limitLots,
                                                   double minProfit){

   double clearSumLot=0;
   int    modelCount=modelList.Count();
   for (int i = 0; i <modelCount ; i++) {
      CModelI *model;
      if(modelList.TryGetValue(i,model)){
         if(model.getProfitPips()>minProfit)continue;
         clearSumLot+=model.getLot();
         if(clearSumLot<=limitLots){
            model.markClearFlag(true);
            model.clearModel();            
            logData.addDebugInfo("<model>" + i
                                 + "<status>" + model.getStatusFlg()
                                 + "<statusIndex>" + model.getStatusIndex()
                                 + "<clearLot>" + model.getLot()
                                 + "<avgPrice>" + model.getAvgPrice());                       
         }              
      }
   }
   logData.addDebugInfo("<clearSumLot>" + clearSumLot);
}
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelClearPreExceed::CModelClearPreExceed(){

}
CModelClearPreExceed::~CModelClearPreExceed(){
}