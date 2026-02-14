//+------------------------------------------------------------------+
//|                                             CModelClearExceed.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "../../comm/ComFunc2.mqh"
#include "../../share/CShareCtl.mqh"
#include "../CModelI.mqh"
#include "CModelProtect.mqh"

class CModelClearExceed: public CModelProtect 
{
      private:
           string         debugLog;
      public:
                          CModelClearExceed();
                          ~CModelClearExceed(); 
      //--- clear Exceed return models
      void                clearExceedModels();
      //--- get exceed peak model
      CModelI*            getPeakModel(CArrayList<CModelI*>* exceedModelList);
                                             
};

//+------------------------------------------------------------------+
//|  clear exceed models
//+------------------------------------------------------------------+
void CModelClearExceed::clearExceedModels(){
   
   if(!Clear_Model_Exceed)return;
   
   //if(Clear_Model_Exceed_OnlyBreak && this.range())return;      
   if(this.range())return;
   if(this.trendToRange())return;
      
   double clearTopDiffPips=Clear_Model_Exceed_DiffTop_Pips;
   //double clearModelMaxLossPips=Clear_Model_Exceed_Max_Loss_Pips;
   double clearHedgeLessProfit=Clear_Model_Exceed_Hedge_LessProfit;
   double clearExceedMinCount=Clear_Model_Exceed_Min_Count;
   double clearExceedMinProfit=Clear_Model_Exceed_Min_Pips;
   
   //ENUM_ORDER_TYPE exceedPreType=this.getModelAnalysisPre().getExceedType();
   //CArrayList<CModelI*>* exceedModelList=this.getModelAnalysisPre().getExceedModelList();   

   ENUM_ORDER_TYPE exceedPreType=this.getModelAnalysis().getExceedType();
   CArrayList<CModelI*>* exceedModelList=this.getModelAnalysis().getExceedModelList();   
   
   int modelCount=exceedModelList.Count();
   if(modelCount<clearExceedMinCount)return;
   if(this.getModelAnalysis().getExceedCurProfit()<Clear_Model_Exceed_Min_SumPips)return;

   logData.addDebugInfo("<<CModelClearExceed>>" 
                         + "<rangeStatus>" + this.getRangeStatus()                         
                         + "<exceedCount>" + modelCount
                         + "<Type>" + this.getModelAnalysis().getExceedType()
                         + "<buyUpLine>" + this.getModelAnalysis().getBuyUpLine()                         
                         + "<sellDownLine>" + this.getModelAnalysis().getSellDownLine()
                         + "<lot>" + StringFormat("%.2f",this.getModelAnalysis().getExceedSumLot())
                         + "<reLot>" + StringFormat("%.2f",this.getModelAnalysis().getExceedReSumLot())
                         + "<reLotRate>" + StringFormat("%.2f",this.getModelAnalysis().getExceedReSumLotRate()));
                         
   logData.addDebugInfo("<exceedRate>" + StringFormat("%.2f",this.getModelAnalysis().getExceedRate())                         
                         + "<ClearExceedCurProfit>" + StringFormat("%.2f",this.getModelAnalysis().getExceedCurProfit())
                         + "<curLoss>" + StringFormat("%.2f",this.getModelAnalysis().getExceedCurLossProfit())
                         + "<maxProfit>" + StringFormat("%.2f",this.getModelAnalysis().getExceedMaxProfit())
                         + "<minProfit>" + StringFormat("%.2f",this.getModelAnalysis().getExceedMinProfit())
                         
   //only one model
   /*
   if(modelCount==1){
      peakModel=this.getPeakModel(exceedModelList);
      if(peakModel.getProfitPips()<clearHedgeLessProfit*2){
         peakModel.markClearFlag(true);
         peakModel.clearModel();
      }
      return;
   }*/
      
   CModelI* peakModel;
   CModelI* hedgeModel;
   for (int i = 0; i <modelCount ; i++) {
      CModelI *model;
      if(exceedModelList.TryGetValue(i,model)){
         if(i==0){
            peakModel=model;            
            continue;
         }            
         
         //skip when current model is peak
         if(model.getModelId()==peakModel.getModelId())continue;
         //diff peak pips         
         //double modelDiffPeakPips=MathAbs(peakModel.getAvgPrice()-model.getAvgPrice())/model.getSymbolPoint();
         //double curDiffPeakPips=MathAbs(model.getAvgPrice()-model.getSymbolPrice())/model.getSymbolPoint(); 
         double modelDiffPeakPips=(peakModel.getAvgPrice()-model.getAvgPrice())/model.getSymbolPoint();
         if(exceedPreType==ORDER_TYPE_BUY){
             modelDiffPeakPips=(model.getAvgPrice()-peakModel.getAvgPrice())/model.getSymbolPoint();                              
             //curDiffPeakPips=(model.getSymbolPrice()-model.getAvgPrice())/model.getSymbolPoint();          
         }
                                                                    
         if(modelDiffPeakPips<=clearTopDiffPips){
            //|| curDiffPeakPips>=clearModelMaxLossPips){
            hedgeModel=model;            
            double hedgeProfitPips=peakModel.getProfitPips()+hedgeModel.getProfitPips();
            if(hedgeProfitPips<clearHedgeLessProfit){
               peakModel.markClearFlag(true);
               hedgeModel.markClearFlag(true);
               peakModel.clearModel();
               hedgeModel.clearModel();
               peakModel=this.getPeakModel(exceedModelList);
               if(CheckPointer(peakModel)==POINTER_INVALID)break;                      
               logData.addDebugInfo("<peakModel>" + peakModel.getAvgPrice()
                                    + "<hedgeModel>" + hedgeModel.getAvgPrice());
               
            }
            break;
         }
      }
   }  
   
   if(Clear_Model_Exceed_SignalRisk){
      //clear min profit model
      for (int i = 0; i <modelCount ; i++) {
         CModelI *model;
         if(exceedModelList.TryGetValue(i,model)){
            if(model.getClearFlag())continue;
            if(model.getProfitPips()<clearExceedMinProfit){
               model.clearModel();
            }         
         }
      }
   }
}

//+------------------------------------------------------------------+
//|  get peak model
//+------------------------------------------------------------------+
CModelI* CModelClearExceed::getPeakModel(CArrayList<CModelI*>* exceedModelList){
   CModelI* peakModel;
   //CArrayList<CModelI*>* exceedModelList=this.getModelAnalysis().getExceedModelList();
   int modelCount=exceedModelList.Count();   
   for (int i = 0; i <modelCount ; i++) {
      CModelI *model;
      if(exceedModelList.TryGetValue(i,model)){         
         if(!model.getClearFlag()){
            peakModel=model;
            break;
         }
      }
   }
   return peakModel;
}
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelClearExceed::CModelClearExceed(){

}
CModelClearExceed::~CModelClearExceed(){
}