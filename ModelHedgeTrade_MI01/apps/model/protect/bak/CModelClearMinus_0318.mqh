//+------------------------------------------------------------------+
//|                                             CModelClearMinus.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "../../comm/ComFunc2.mqh"
#include "../../share/CShareCtl.mqh"
#include "../CModelI.mqh"
#include "CModelProtect.mqh"

class CModelClearMinus: public CModelProtect 
{
      private:
         double           preEdgeRate;                     
      public:
                          CModelClearMinus();
                          ~CModelClearMinus(); 
        void              clearMinusModels(); 
        double            clearRiskModels(); 
        bool              indFilter(CModelI* model);
        bool              indFilter2(CModelI* model);
        double            getSumJumpRate(int symbolIndex,
                                       int maxShift,
                                       int diffShift,                                       
                                       double curPrice,
                                       double point,
                                       CIndicatorShare* indShare);  
        double            getSumJumpPips(int symbolIndex,
                                       int maxShift,
                                       int diffShift,                                       
                                       double curPrice,
                                       double point,
                                       CIndicatorShare* indShare);                                              
};

//+------------------------------------------------------------------+
//|  clear risk models
//+------------------------------------------------------------------+
double   CModelClearMinus::clearRiskModels(){
   
   double clearLots=0.0;
   //refresh market models info
   logData.addDebugInfo("<clearRiskModels>");
   
   if(rkeeLog.debugPeriod(9887,60)){   
      //rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"debugLog01");
      datetime t1=TimeCurrent();
   }   
   
   //datetime t2=TimeCurrent();
   //CModelAnalysis* mAnalysis=this.getShareCtl().getModelShare().getModelAnalysis();
   //mAnalysis.makeAnalysisData(28,this.getModels());   
   //CArrayList<CModelI*>* extendModelList=mAnalysis.getExtendModelList();
   
   /*   
   int modelCount=extendModelList.Count();
   //clean model list
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(extendModelList.TryGetValue(i,model)){         



      }
   }   
   */
   
   
   return clearLots;
} 

//+------------------------------------------------------------------+
//|  clear minus models
//+------------------------------------------------------------------+
void CModelClearMinus::clearMinusModels(){   
   
   if(!Clear_Model_Minus)return;
   if(this.getShareCtl().getModelShare().getOpenOrderCount()<Clear_Model_Minus_Min_SumUnitLot)return;
   logData.addDebugInfo("<CModelClearMinus>");
   
   this.refresh();
   //clear minus model
   CArrayList<CModelI*>* modelList=this.getModels();
   CHedgeGroup* modelGroup=this.getHedgeGroupPool();  
   int modelCount=modelList.Count();
   //clean model list
   double clearSumLot=0;
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){          
         //indicator filter
         if(!this.indFilter(model))continue;
         if(!this.indFilter2(model))continue;                              
         //judge clear condition
         model.refresh();
         
         double modelProfit=model.getProfit();
         if(modelProfit>Clear_Model_Minus_Min_ProfitPips)break;
         
         double sumJumpPips=this.getIndicatorShare().getPriceChlSumEdgeDiffPips(model.getSymbolIndex());
         double sumEdgeRate=this.getIndicatorShare().getPriceChlSumEdgeRate(model.getSymbolIndex());         
         double sumAdjustEdgeRate=MathAbs((sumJumpPips/100)+sumEdgeRate);
         double sumStrengthRate=this.getIndicatorShare().getPriceChlSumStrengthRate2(model.getSymbolIndex());
         double hedgeRate=this.getHedgeGroupPool().getHedgeRate();         
                           
         double extendRate=comFunc2.mapValue(sumAdjustEdgeRate,1,80,3,1);
         double shiftRate=comFunc2.mapValue(sumStrengthRate,1,25,10,0.1);
         
         double hedgeAdjust=1;         
         if(this.clearHedgeLot(model,modelGroup)>0){
            hedgeAdjust=comFunc2.mapValue(hedgeRate,0,1,0.3,1);
         }else{
            hedgeAdjust=comFunc2.mapValue(hedgeRate,0,1,2,1);
         }
         
         double adjustRate=shiftRate*hedgeAdjust*extendRate;
         if(adjustRate<1)adjustRate=1;  
         double clearMinProfitPips=Clear_Model_Minus_Min_ProfitPips*adjustRate;         
         
         double clearProfit=model.getProfit();
         //int groupHedgeOrderCount=model.getHedgeGroup().getHedgeOrderCount();
         int groupHedgeOrderCount=modelGroup.getHedgeOrderCount();
         //if(hedgeRate>Clear_Model_Minus_Group_Risk_HRate)continue;         
         //clear lot hedge (reverse order type)         
         if(modelProfit<=clearMinProfitPips){
            this.addClearModel(model);
            clearSumLot+=model.getLot();
            modelGroup.hedgeOrders();
         } 
      }
   }
   //clear model
   if(clearSumLot>(Clear_Model_Minus_Min_SumUnitLot*Comm_Unit_LotSize)){
      if(clearSumLot>0){
         double positionsLot=((double)PositionsTotal())*Comm_Unit_LotSize;
         double clearLotRate=0;
         if(positionsLot>0){
            clearLotRate=clearSumLot/positionsLot;
         }   
         //clear models
         if(clearLotRate>Clear_Model_Minus_Min_SumLotRate){
            this.clearModels();
         }
      }   
   }
   this.refresh();
   logData.addDebugInfo("</CModelClearMinus>");
}  

//+------------------------------------------------------------------+
//|  indicator filter
//+------------------------------------------------------------------+
bool CModelClearMinus::indFilter(CModelI* model){

   int symbolIndex=model.getSymbolIndex();
   CIndicatorShare* indicatorShare=this.getIndicatorShare();
       
   double strengthRate=indicatorShare.getStrengthRate(symbolIndex);
   double sumRate=indicatorShare.getPriceChlSumEdgeRate(symbolIndex);
   //double sumRate=strengthRate+edgeRate;
   
   //if(MathAbs(sumRate)<Clear_Model_Minus_Max_StrengthRate)return false;     
          
   if(Clear_Model_Minus_Speed_Acc){
      if(!indicatorShare.getPriceSpeedAcceleration(symbolIndex,PRICE_SPEED_LEVEL_1))return false;
      //if(!indicatorShare.getPriceSpeedAcceleration(symbolIndex,PRICE_SPEED_LEVEL_2))continue;
      //if(!indicatorShare.getPriceSpeedAcceleration(symbolIndex,PRICE_SPEED_LEVEL_3))continue;
      
      ENUM_TICK_STATE tickStatus=indicatorShare.getTickStatus(symbolIndex);
      if(model.getTradeType()==ORDER_TYPE_BUY){
         if(tickStatus==TICK_STATE_ACC_UP)return false;
      } 
      else if(model.getTradeType()==ORDER_TYPE_SELL){
         if(tickStatus==TICK_STATE_ACC_DOWN)return false;
      }               
      
   }
   
   if(Clear_Model_Minus_Break){
      ENUM_STATE bandStatus=indicatorShare.getBandStatus(symbolIndex,IND_BAND_LV0);
      ENUM_TICK_STATE tickStatus=indicatorShare.getTickStatus(symbolIndex);
      
      /*
         STATE_UNKNOWN = -1,      // 未知状态
         STATE_UPPER_RANGE,       // 震荡上半区
         STATE_BREAKOUT_UP,       // 上涨突破区
         STATE_RETURN_UPPER,      // 退回震荡上半区
         STATE_LOWER_RANGE,       // 震荡下半区
         STATE_BREAKOUT_DOWN,     // 下跌突破区
         STATE_RETURN_LOWER       // 退回震荡下半区         
      */
      
      if(model.getTradeType()==ORDER_TYPE_BUY){
         if(bandStatus==STATE_BREAKOUT_DOWN)return true;
         else return false;
      } 
      else if(model.getTradeType()==ORDER_TYPE_SELL){
         if(bandStatus==STATE_BREAKOUT_UP)return true;
         else return false;
      }
   }
   return true;
}

//+------------------------------------------------------------------+
//|  filter the clear model
//+------------------------------------------------------------------+
/*
bool CModelClearMinus::indFilter2(CModelI* model)
{  
   
   int symbolIndex=model.getSymbolIndex();   
   CPriceChannelStatus* priceChlStatus=this.getIndicatorShare().getDiffPriceChannelStatus(symbolIndex,0);   
   double avgUpEdge=0,avgLowerEdge=0;
   double gridAvgLine=model.getAvgPrice();   
   avgUpEdge=priceChlStatus.getUpperEdgePrice(5);
   avgLowerEdge=priceChlStatus.getLowerEdgePrice(5);
   
   //not clear when orders in the channel      
   if(gridAvgLine>avgUpEdge || gridAvgLine<avgLowerEdge)return true;
   return true;
}*/

bool CModelClearMinus::indFilter2(CModelI* model)
{  
   
   logData.addDebugInfo("<indFilter2>");
   int symbolIndex=model.getSymbolIndex();      
   double curShift=this.getIndicatorShare().getPriceChlShiftLevel(symbolIndex);
   //printf("CModelClearMinus curShift:" + curShift);
   //if(curShift<Clear_Model_Minus_Max_StrengthRate)return false;    
         
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
   
   //double jumpRate=ComFunc.getJumpRate(priceChlStatus,curPrice,point);
   //double sumJumpRate=this.getSumJumpRate(symbolIndex,6,4,curPrice,point,this.getIndicatorShare());   
   //double sumJumpPips=this.getSumJumpPips(symbolIndex,6,3,curPrice,point,this.getIndicatorShare());   
   double sumJumpPips=this.getIndicatorShare().getPriceChlSumEdgeDiffPips(symbolIndex);
   double sumEdgeRate=this.getIndicatorShare().getPriceChlSumEdgeRate(symbolIndex);    
   double sumStrengthRate=this.getIndicatorShare().getPriceChlSumStrengthRate(symbolIndex);    
   
   double strengthRate=this.getIndicatorShare().getStrengthRate(symbolIndex);
   double edgeRate=this.getIndicatorShare().getEdgeRate(symbolIndex);
   double sumRate=strengthRate+edgeRate;
   
   //if(this.preEdgeRate<1000){
   //   sumRate=sumRate+(sumRate-this.preEdgeRate)*2;
   //}
   this.preEdgeRate=sumRate;
           
   string logTemp = "<curShift>" + curShift
                   + "<curSumRate>" + StringFormat("%.2f",(sumEdgeRate+(sumJumpPips/100)))
                   + "<sumStrengthRate>" + StringFormat("%.2f",sumStrengthRate)
                   + "<sumEdgeRate>" + StringFormat("%.2f",sumEdgeRate)
                   + "<sumJumpPips>" + StringFormat("%.2f",sumJumpPips)
                   //+ "<jumpRate>" + StringFormat("%.2f",jumpRate)
                   //+ "<sumJumpRate>" + StringFormat("%.2f",sumJumpRate)                     
                   //+ "<edgeBrkDiffPips>" + priceChlStatus.getEdgeBrkDiffPips()
                   //+ "<adjustDiffPips>" + adjustDiffPips
                   + "<strengthUnitPips>" + StringFormat("%.2f",strengthUnitPips);
   
   
   logData.addDebugInfo(logTemp);
   logData.addDebugInfo("</indFilter2>");
   
   if(rkeeLog.debugPeriod(9108,30)){   
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"debugLog01");
      printf(logTemp);
   }


   sumRate=sumJumpPips/100+sumEdgeRate;            
        
        
   if(MathAbs(sumRate)>30 && MathAbs(sumJumpPips)>1000){      
      logData.addDebugInfo("<return>true</indFilter2>");
      return true;   
   }   
   //if(jumpRate>0 && model.getTradeType()==ORDER_TYPE_BUY){      
   //}
   
   //not clear when orders in the channel      
   logData.addDebugInfo("<return>false</indFilter2>");
   return false;
}

double CModelClearMinus::getSumJumpRate(int symbolIndex,
                                       int maxShift,
                                       int diffShift,                                       
                                       double curPrice,
                                       double point,
                                       CIndicatorShare* indShare)
{ 
   double startShift=indShare.getPriceChlShiftLevel(symbolIndex);   
   if((maxShift-startShift)>diffShift){
      startShift=maxShift-diffShift;
   }   
   double endShift=startShift+diffShift;
   if(endShift>maxShift)endShift=maxShift;
   double sumJumpRate=0;
   double weight=3;
   for(int i=startShift-1;i<endShift;i++){   
      CPriceChannelStatus* priceChlStatus=indShare.getPriceChannelStatus(symbolIndex,i);   
      double jumpRate=comFunc.getJumpRate(priceChlStatus,curPrice,point)*weight;
      sumJumpRate+=jumpRate;
      weight-=1;
   }
   return sumJumpRate;
}


double CModelClearMinus::getSumJumpPips(int symbolIndex,
                                       int maxShift,
                                       int diffShift,                                       
                                       double curPrice,
                                       double point,
                                       CIndicatorShare* indShare)
{ 
   double startShift=indShare.getPriceChlShiftLevel(symbolIndex);   
   if((maxShift-startShift)<diffShift){
      startShift=maxShift-diffShift;
   }   
   double endShift=startShift+diffShift;
   if(endShift>maxShift)endShift=maxShift;
   double sumJumpPips=0;
   double weight=4;
   for(int i=startShift-1;i<endShift;i++){   
      CPriceChannelStatus* priceChlStatus=indShare.getPriceChannelStatus(symbolIndex,i);   
      double jumpPips=comFunc.getJumpPips(priceChlStatus,curPrice,point)*weight;
      sumJumpPips+=jumpPips;
      weight-=1;
   }
   return sumJumpPips;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelClearMinus::CModelClearMinus(){
   this.preEdgeRate=10000;
}
CModelClearMinus::~CModelClearMinus(){
}