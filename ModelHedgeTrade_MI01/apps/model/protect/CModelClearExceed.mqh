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
   
   //check indicator ready
   if(!this.indicatorReady()){
      debugLog+="<indicatorReady>false";
      return;
   }     
      
   if(this.range())return;      
   //if(!this.exceedSameTrend())return;
   if(this.trendToRange())return;
   
   logData.addDebugInfo("<<CModelClearExceed>>");
   
   int    clearCount=0;   
   double clearTopDiffPips=Clear_Model_Exceed_Diff_PeakPips;
   double clearModelDiffAvgPips=Clear_Model_Exceed_Diff_AvgPips;
   double clearHedgeLessProfit=Clear_Model_Exceed_Hedge_LessProfit;
   double clearExceedMinCount=Clear_Model_Exceed_Min_Count;
   double clearExceedLessProfit=Clear_Model_Exceed_LessProfit;
      
   ENUM_ORDER_TYPE exceedType=this.getModelAnalysis().getExceedType();
   ENUM_ORDER_TYPE exceedPreType=this.getModelAnalysisPre().getExceedType();
   CArrayList<CModelI*>* exceedModelList;
   //ENUM_ORDER_TYPE exceedTrendType=false;
   if(exceedType!=exceedPreType){
      exceedModelList=this.getModelAnalysis().getExceedModelList();
      //return;
   }else{      
      CModelI* curPeakModel=this.getPeakModel(this.getModelAnalysis().getExceedModelList());
      CModelI* prePeakModel=this.getPeakModel(this.getModelAnalysisPre().getExceedModelList());      
      if(CheckPointer(curPeakModel)!=POINTER_INVALID
          && CheckPointer(prePeakModel)!=POINTER_INVALID){
         if(exceedType == ORDER_TYPE_BUY 
               && curPeakModel.getAvgPrice()>=prePeakModel.getAvgPrice()){
            exceedModelList=this.getModelAnalysisPre().getExceedModelList();
            //exceedSameTrend=true;
         }else if(exceedType == ORDER_TYPE_SELL
               && curPeakModel.getAvgPrice()<=prePeakModel.getAvgPrice()){
            exceedModelList=this.getModelAnalysisPre().getExceedModelList();
            //exceedSameTrend=true;
         }else{
            exceedModelList=this.getModelAnalysis().getExceedModelList();
         }
      }else{
         //exceedModelList=this.getModelAnalysis().getExceedModelList();
         return;
      }            
   }
   
   logData.addDebugInfo("<rangeStatus>" + this.getRangeStatus()); 
   logData.addDebugInfo("<<CurExceed>><Type>" + this.getModelAnalysis().getExceedType()
                         + "<buyUpLine>" + this.getModelAnalysis().getBuyUpLine()
                         + "<sellDownLine>" + this.getModelAnalysis().getSellDownLine()
                         + "<lot>" + StringFormat("%.2f",this.getModelAnalysis().getExceedSumLot())
                         + "<reLot>" + StringFormat("%.2f",this.getModelAnalysis().getExceedReSumLot())
                         + "<reLotRate>" + StringFormat("%.2f",this.getModelAnalysis().getExceedReSumLotRate())
                         + "<exceedRate>" + StringFormat("%.2f",this.getModelAnalysis().getExceedRate())                         
                         + "<curProfit>" + StringFormat("%.2f",this.getModelAnalysis().getExceedCurProfit())
                         + "<curLoss>" + StringFormat("%.2f",this.getModelAnalysis().getExceedCurLossProfit())
                         + "<maxProfit>" + StringFormat("%.2f",this.getModelAnalysis().getExceedMaxProfit())
                         + "<minProfit>" + StringFormat("%.2f",this.getModelAnalysis().getExceedMinProfit())
                         );
   logData.addDebugInfo("<<AllExceed>><Type>" + this.getModelAnalysisPre().getExceedType()
                         + "<buyUpLine>" + this.getModelAnalysisPre().getBuyUpLine()
                         + "<sellDownLine>" + this.getModelAnalysisPre().getSellDownLine()
                         + "<lot>" + StringFormat("%.2f",this.getModelAnalysisPre().getExceedSumLot())
                         + "<reLot>" + StringFormat("%.2f",this.getModelAnalysisPre().getExceedReSumLot())
                         + "<reLotRate>" + StringFormat("%.2f",this.getModelAnalysisPre().getExceedReSumLotRate())
                         + "<exceedRate>" + StringFormat("%.2f",this.getModelAnalysisPre().getExceedRate())                         
                         + "<curProfit>" + StringFormat("%.2f",this.getModelAnalysisPre().getExceedCurProfit())
                         + "<curLoss>" + StringFormat("%.2f",this.getModelAnalysisPre().getExceedCurLossProfit())
                         + "<maxProfit>" + StringFormat("%.2f",this.getModelAnalysisPre().getExceedMaxProfit())
                         + "<minProfit>" + StringFormat("%.2f",this.getModelAnalysisPre().getExceedMinProfit())
                         );                         
                            
   
   int modelCount=exceedModelList.Count();
   if(modelCount<=clearExceedMinCount){
      //clear signal risk
      if(Clear_Model_Exceed_SignalRisk){
         //if(!exceedSameTrend)return;
         if(clearCount>0)return;
         //clear min profit model
         for (int i = 0; i <modelCount ; i++) {
            CModelI *model;
            if(exceedModelList.TryGetValue(i,model)){
               if(model.getClearFlag())continue;
               if(model.getProfitPips()<clearExceedLessProfit){
                  model.clearModel();
                  clearCount++;
               }         
            }
         }
      }    
      if(clearCount>0){
         logData.addDebugInfo("<ClearSignalRisk><modelCount>" + modelCount);
         return;
      }
      return;
   }

   //if(modelCount<2)return;
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
         double currentPrice = iClose(peakModel.getSymbol(),PERIOD_M1,0);    // 获取当前收盘价
         double modelAvgPrice =(peakModel.getAvgPrice()+model.getAvgPrice())/2;
         double modelDiffPeakPips=(peakModel.getAvgPrice()-model.getAvgPrice())/model.getSymbolPoint();
         double modelDiffAvgPips=(currentPrice-modelAvgPrice)/model.getSymbolPoint();
         if(exceedType==ORDER_TYPE_SELL){
             modelDiffPeakPips=(model.getAvgPrice()-peakModel.getAvgPrice())/model.getSymbolPoint();                              
             modelDiffAvgPips=(modelAvgPrice-currentPrice)/model.getSymbolPoint();
         }
                                                                    
         if(modelDiffPeakPips>=clearTopDiffPips 
            && modelDiffAvgPips<=clearModelDiffAvgPips){
            //|| curDiffPeakPips>=clearModelMaxLossPips){
            hedgeModel=model;            
            double hedgeProfitPips=peakModel.getProfitPips()+hedgeModel.getProfitPips();
            if(hedgeProfitPips<clearHedgeLessProfit){
               logData.addDebugInfo("<peakModel>" + peakModel.getAvgPrice()
                                    + "<hedgeModel>" + hedgeModel.getAvgPrice());            
               peakModel.markClearFlag(true);
               hedgeModel.markClearFlag(true);
               peakModel.clearModel();
               hedgeModel.clearModel();
               clearCount++;
               peakModel=this.getPeakModel(exceedModelList);
               if(CheckPointer(peakModel)==POINTER_INVALID)break;                      
               
            }
            break;
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