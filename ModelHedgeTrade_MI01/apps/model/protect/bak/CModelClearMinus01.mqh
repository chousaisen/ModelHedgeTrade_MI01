//+------------------------------------------------------------------+
//|                                             CModelClearMinus.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

input  string   CLEAR_Minus_MODEL_SETTING="------ Clear Minus Setting ------";

input   bool       Clear_Model_Minus=true;
input   bool       Clear_Model_Minus_Speed_Acc=true;
input   bool       Clear_Model_Minus_Break=true;

input   double     Clear_Model_Minus_Group_Risk_HRate=0.95;
input   double     Clear_Model_Minus_Group_Min_Order=2;
input   double     Clear_Model_Minus_Min_ProfitPips=1;
input   double     Clear_Model_Minus_Min_SumUnitLot=3;
input   double     Clear_Model_Minus_Min_SumLotRate=0.2;
input   double     Clear_Model_Minus_Max_StrengthRate=3;



#include <Generic\ArrayList.mqh>

#include "../../share/CShareCtl.mqh"
#include "../CModelI.mqh"
#include "CModelProtect.mqh"

class CModelClearMinus: public CModelProtect 
{

      public:
                          CModelClearMinus();
                          ~CModelClearMinus(); 
        void              clearMinusModels(); 
        bool              indFilter(CModelI* model);
        bool              indFilter2(CModelI* model);
};
  
//+------------------------------------------------------------------+
//|  clear minus models
//+------------------------------------------------------------------+
void CModelClearMinus::clearMinusModels(){   
   
   if(!Clear_Model_Minus)return;
   
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
         double clearProfit=model.getProfit();
         //int groupHedgeOrderCount=model.getHedgeGroup().getHedgeOrderCount();
         int groupHedgeOrderCount=modelGroup.getHedgeOrderCount();
         //double groupHedgeRate=model.getHedgeGroup().getHedgeRate();         
         double groupHedgeRate=modelGroup.getHedgeRate();         
         if(groupHedgeRate>Clear_Model_Minus_Group_Risk_HRate)continue;
         //if(groupHedgeOrderCount<Clear_Model_Minus_Group_Min_Order)continue;         
         if(clearProfit>Clear_Model_Minus_Min_ProfitPips)break;
         //clear lot hedge (reverse order type)
         double clearLot=this.clearHedgeLot(model);
         clearSumLot+=clearLot;
         //model.getHedgeGroup().setExceptMode(false);  
         
      }
   }
   modelGroup.setExceptMode(false);
   //clear model
   if(clearSumLot>(Clear_Model_Minus_Min_SumUnitLot*Comm_Unit_LotSize)){
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
   this.refresh();
   
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
   
   double curShift=indicatorShare.getPriceChlShiftLevel(symbolIndex);
   printf("CModelClearMinus curShift:" + curShift);
   if(curShift<Clear_Model_Minus_Max_StrengthRate)return false;   
   
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
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelClearMinus::CModelClearMinus(){}
CModelClearMinus::~CModelClearMinus(){
}