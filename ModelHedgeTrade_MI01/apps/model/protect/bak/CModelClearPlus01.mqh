//+------------------------------------------------------------------+
//|                                              CModelClearPlus.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

input  string   CLEAR_Plus_MODEL_SETTING="------ Clear Plus Setting ------";

input   bool       Clear_Model_Plus=true;
input   bool       Clear_Model_Plus_Speed_Acc=true;
//input   bool       Clear_Model_Plus_Break=true;

input   double     Clear_Model_Plus_Group_Risk_HRate=0.95;
//input   double     Clear_Model_Plus_Group_Min_Order=3;
input   double     Clear_Model_Plus_Min_ProfitPips=300;
input   double     Clear_Model_Plus_Min_SumUnitLot=3;
input   double     Clear_Model_Plus_Min_SumLotRate=0.2;
input   double     Clear_Model_Plus_Min_StrengthRate=9;


#include <Generic\ArrayList.mqh>

#include "../../share/CShareCtl.mqh"
#include "../CModelI.mqh"
#include "CModelProtect.mqh"

class CModelClearPlus: public CModelProtect 
{

      public:
                          CModelClearPlus();
                          ~CModelClearPlus(); 
        void              clearPlusModels(); 
        bool              indFilter(CModelI* model);
};
  
//+------------------------------------------------------------------+
//|  clear plus models
//+------------------------------------------------------------------+
void CModelClearPlus::clearPlusModels(){   
   
   if(!Clear_Model_Plus)return;
   
   this.refresh();
   CHedgeGroup* modelGroup=this.getHedgeGroupPool();
   //clear plus model
   CArrayList<CModelI*>* modelList=this.getModels();
   int modelCount=modelList.Count();
   //clean model list
   double clearSumLot=0;
   for (int i =0; i <modelCount ; i++) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){          
         //indicator filter
         if(!this.indFilter(model))continue;                       
         //judge clear condition
         model.refresh();
         double clearProfit=model.getProfit();         
         double groupHedgeRate=modelGroup.getHedgeRate();         
         if(groupHedgeRate>Clear_Model_Plus_Group_Risk_HRate)continue;
         //if(groupHedgeOrderCount<Clear_Model_Plus_Group_Min_Order)continue;         
         if(clearProfit<Clear_Model_Plus_Min_ProfitPips)break;
         //clear lot hedge (reverse order type)
         double clearLot=this.clearHedgeLot(model);
         clearSumLot+=clearLot;
         //model.getHedgeGroup().setExceptMode(false);         
      }
   }
   modelGroup.setExceptMode(false);
   //clear model
   if(clearSumLot>(Clear_Model_Plus_Min_SumUnitLot*Comm_Unit_LotSize)){
      double positionsLot=((double)PositionsTotal())*Comm_Unit_LotSize;
      double clearLotRate=0;
      if(positionsLot>0){
         clearLotRate=clearSumLot/positionsLot;
      }   
      //clear models
      if(clearLotRate>Clear_Model_Plus_Min_SumLotRate){
         this.clearModels();
      }
   }
   this.refresh();
   
}  

//+------------------------------------------------------------------+
//|  indicator filter
//+------------------------------------------------------------------+
bool CModelClearPlus::indFilter(CModelI* model){
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
      printf("CModelClearPlus curShift:" + curShift);
      if(curShift<Clear_Model_Plus_Min_StrengthRate)return false;
      //double sumRate=strengthRate+edgeRate;
      
      //if(MathAbs(sumRate)<Clear_Model_Plus_Min_StrengthRate)return false;
      
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
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelClearPlus::CModelClearPlus(){}
CModelClearPlus::~CModelClearPlus(){
}