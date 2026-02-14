//+------------------------------------------------------------------+
//|                                              CModelClearPlus.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "../../comm/ComFunc2.mqh"
#include "../../share/CShareCtl.mqh"
#include "../CModelI.mqh"
#include "CModelProtect.mqh"

class CModelClearPlus: public CModelProtect 
{

      public:
                          CModelClearPlus();
                          ~CModelClearPlus(); 
        void              clearPlusModels(); 
        bool              indFilter01(CModelI* model);
        bool              indFilter02(CModelI* model);
};
  
//+------------------------------------------------------------------+
//|  clear plus models
//+------------------------------------------------------------------+
void CModelClearPlus::clearPlusModels(){   
   
   if(!Clear_Model_Plus)return;
   logData.addDebugInfo("<clearPlusModels>");
   this.refresh();
   CHedgeGroup* modelGroup=this.getHedgeGroupPool();
   //clear plus model
   CArrayList<CModelI*>* modelList=this.getModels();
   int modelCount=modelList.Count();
   
   
   CModelAnalysis* mAnalysis=this.getShareCtl().getModelShare().getModelAnalysis();
   mAnalysis.makeAnalysisData(28,this.getModels());
   
   ENUM_ORDER_TYPE curModelsExceedType=mAnalysis.getExceedType();
   double curModelsProfit=mAnalysis.getExceedCurProfit();
   double curModelsLossProfit=mAnalysis.getExceedCurLossProfit();
   double curModelsMaxProfit=mAnalysis.getExceedMaxProfit();
   double curModelsExceedRate=mAnalysis.getExceedRate();
   datetime topModelTime=mAnalysis.getExceedMaxTime();
   datetime rootModelTime=mAnalysis.getExceedRootTime();   
   double lossRate=0;
   if(curModelsMaxProfit>3000){
      lossRate=(curModelsMaxProfit-curModelsProfit)/curModelsMaxProfit;
   }
   
   //clean model list
   double clearSumLot=0;
   for (int i =0; i <modelCount ; i++) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){          
         //indicator filter
         //if(!this.indFilter02(model))continue;
         //judge clear condition
         model.refresh();
         double modelProfit=model.getProfit();
         
         if(modelProfit<Clear_Model_Plus_Min_ProfitPips)break;
         
         double sumJumpPips=this.getIndicatorShare().getPriceChlSumEdgeDiffPips(model.getSymbolIndex());
         double sumEdgeRate=this.getIndicatorShare().getPriceChlSumEdgeRate(model.getSymbolIndex());         
         double sumAdjustEdgeRate=MathAbs((sumJumpPips/100)+sumEdgeRate);
         double sumStrengthRate=this.getIndicatorShare().getPriceChlSumStrengthRate2(model.getSymbolIndex());         
         double hedgeRate=this.getHedgeGroupPool().getHedgeRate();
         
         double extendRate=comFunc2.mapValue(sumAdjustEdgeRate,1,40,0.5,6);
         double shiftRate=comFunc2.mapValue(sumStrengthRate,1,15,0.5,6);
         
         double hedgeAdjust=1;         
         if(this.clearHedgeLot(model,modelGroup)>0){
            hedgeAdjust=comFunc2.mapValue(hedgeRate,0,1,0.5,1);
         }else{
            //continue;
            hedgeAdjust=comFunc2.mapValue(hedgeRate,0,1,3,1);
         }
         
         double adjustRate=shiftRate*hedgeAdjust*extendRate;
         if(adjustRate<1)adjustRate=1;         
         double clearMinProfitPips=Clear_Model_Plus_Min_ProfitPips*adjustRate; 
         
         if(curModelsExceedType == model.getTradeType()){
            if(lossRate>0.3)clearMinProfitPips=Clear_Model_Plus_Min_ProfitPips; 
         }
                 
         if(modelProfit>=clearMinProfitPips){
            this.addClearModel(model);
            clearSumLot+=model.getLot();
            modelGroup.hedgeOrders();
         }
         //clear lot hedge (reverse order type)                  
      }
   }
   //clear model
   if(clearSumLot>(Clear_Model_Plus_Min_SumUnitLot*Comm_Unit_LotSize)){
      double positionsLot=((double)PositionsTotal())*Comm_Unit_LotSize;
      double clearLotRate=0;
      if(positionsLot>0){
         clearLotRate=clearSumLot/positionsLot;
      }   
      // clear models
      if(clearLotRate>Clear_Model_Plus_Min_SumLotRate){
         this.clearModels();
      }
   }
   this.refresh();
   logData.addDebugInfo("</clearPlusModels>");
}  

//+------------------------------------------------------------------+
//|  indicator filter
//+------------------------------------------------------------------+
bool CModelClearPlus::indFilter01(CModelI* model){

   return true;
}
//+------------------------------------------------------------------+
//|  indicator filter
//+------------------------------------------------------------------+
bool CModelClearPlus::indFilter02(CModelI* model){

   logData.addDebugInfo("<indFilter>");
   
   int symbolIndex=model.getSymbolIndex();
   CIndicatorShare* indicatorShare=this.getIndicatorShare();     
   if(Clear_Model_Plus_Speed_Acc){
      if(!indicatorShare.getPriceSpeedAcceleration(symbolIndex,PRICE_SPEED_LEVEL_1))return false;         
      ENUM_TICK_STATE tickStatus=indicatorShare.getTickStatus(symbolIndex);
      if(model.getTradeType()==ORDER_TYPE_BUY){
         if(tickStatus==TICK_STATE_ACC_UP)return false;
      } 
      else if(model.getTradeType()==ORDER_TYPE_SELL){
         if(tickStatus==TICK_STATE_ACC_DOWN)return false;
      }          
   }      
         
   double strengthRate=indicatorShare.getStrengthRate(symbolIndex);
   double sumRate=indicatorShare.getPriceChlSumEdgeRate(symbolIndex);
   double curShift=indicatorShare.getPriceChlShiftLevel(symbolIndex);
   //printf("CModelClearPlus curShift:" + curShift);
   if(curShift<Clear_Model_Plus_Min_StrengthRate)return false;
   //double sumRate=strengthRate+edgeRate;
   
   //if(MathAbs(sumRate)<Clear_Model_Plus_Min_StrengthRate)return false;
   
   /*
   double extendRate=(MathAbs(sumRate)-GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE)+1;   
   if(extendRate<1)extendRate=1;  
   extendRate=comFunc.extendValue(extendRate,GRID_CLOSE_DIFF_EXTEND_PLUS_RATE);
   double modelProfit=model.getProfit();
   double modelCloseProfit=model.getCloseProfitPips();
   if(extendRate>1){
      modelCloseProfit=(modelCloseProfit*GRID_CLOSE_BREAK_EXTEND_RATE)*extendRate;
   }      
         
   if(modelProfit>Clear_Model_Plus_Min_ProfitPips
         && modelProfit<modelCloseProfit){
      if(sumRate>GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE && model.getTradeType()==ORDER_TYPE_BUY){         
         return true;
      }else if(sumRate<-GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE && model.getTradeType()==ORDER_TYPE_SELL){
         return true;
      }
   }               
   return false;
   */
   int diffShift=0;
   //if(curShift>3)diffShift=3-curShift;
   CPriceChannelStatus* priceChlStatus=this.getIndicatorShare().getDiffPriceChannelStatus(symbolIndex,diffShift);
   
   double curPrice=model.getSymbolPrice();
   double point=model.getSymbolPoint();
   double upperEdgePrice=priceChlStatus.getUpperEdgePrice(0);
   double lowerEdgePrice=priceChlStatus.getLowerEdgePrice(0);   
   double strengthUnitPips=priceChlStatus.getStrengthUnitPips();
   double edgeBrkDiffPips=priceChlStatus.getEdgeBrkDiffPips();
   
   double adjustDiffPips=0;
   if(edgeBrkDiffPips>0){
      adjustDiffPips=(upperEdgePrice-curPrice)/point;
      edgeBrkDiffPips=edgeBrkDiffPips-adjustDiffPips;
      if(edgeBrkDiffPips<0)edgeBrkDiffPips=0;
   }else if(edgeBrkDiffPips<0){
      adjustDiffPips=(curPrice-lowerEdgePrice)/point;
      edgeBrkDiffPips=edgeBrkDiffPips-adjustDiffPips;
      if(edgeBrkDiffPips>0)edgeBrkDiffPips=0;
   }
   double jumpRate=edgeBrkDiffPips/(strengthUnitPips-MathAbs(edgeBrkDiffPips));   
   //printf("jumpRate" + jumpRate);
   logData.addDebugInfo("<jumpRate>" + StringFormat("%.2f",jumpRate));
   if(MathAbs(jumpRate)>0.35){
      logData.addDebugInfo("<return>true</indFilter>");
      return true; 
   }   
   logData.addDebugInfo("<return>false</indFilter>");
   return false;
      
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelClearPlus::CModelClearPlus(){}
CModelClearPlus::~CModelClearPlus(){
}