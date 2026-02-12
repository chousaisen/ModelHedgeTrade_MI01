//+------------------------------------------------------------------+
//|                                                    CModelCtl.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"

#include "../../../../header/model/CHeader.mqh"
#include "../../../../share/CShareCtl.mqh"
#include "../../../CModelI.mqh"
#include "../../../CModelRunner.mqh"
#include "CModelGrid01.mqh"

class CModelGrid01Runner : public CModelRunner 
  {
private:
      //grid set parameter
      int               gridMaxOrderCount;    //set parameter
      double            gridDistance[];       //set parameter
      double            gridProfit[];         //set parameter
      double            gridStopLoss;         //set parameter
      double            protectPips;          //set parameter
      double            protectDiffPips;      //set parameter
      double            gridDistanceDiffPips; //set parameter
public:
                        CModelGrid01Runner();
                        ~CModelGrid01Runner();
      //--- init   models when init               
      void              initModels();                    
      //--- run model runner
      //void            run();   
      //--- reload   models when init
      void              reLoadModels();
      //--- open conditions to create model
      bool              openCondition(CSignal* signal);
      //--- create model
      CModelI*          createModel();
      //--- clean models(when models no orders)
      int               openModels();
      //--- extend/run model list
      void              extendModels(); 
      //--- close/run model list
      void              closeModels();            
      //--- set parameters
      void              setParameters(int maxOrderCount, 
                                       string distanceList, 
                                       double gridDistanceDiffPips,
                                       string profitList, 
                                       double stopLoss, 
                                       double protect, 
                                       double protectDiff); 
                                       
      //--- set parameter by customize
      void              setGridMaxOrderCount(int value);
      
      //--- judge if diff other symbol models
      //bool           diffOtherSymbolModels(int symbolIndex,ENUM_ORDER_TYPE type);
                                            
  };   

//+------------------------------------------------------------------+
//|  load models
//+------------------------------------------------------------------+
void CModelGrid01Runner::initModels(void)
{  
   this.reLoadModels();
}

//+------------------------------------------------------------------+
//|  create the model01
//+------------------------------------------------------------------+
CModelI* CModelGrid01Runner::createModel()
{     
   CModelGrid01* model=new CModelGrid01();
   model.setParameters(this.gridMaxOrderCount,
                        this.gridDistance,
                        this.gridProfit,
                        this.gridStopLoss,
                        this.protectPips,
                        this.protectDiffPips);
   model.setModelStatus(MODEL_STATUS_READY);
   return model;
} 

//+------------------------------------------------------------------+
//|  filter conditions to create model
//+------------------------------------------------------------------+
bool  CModelGrid01Runner::openCondition(CSignal* signal){
            
      // parent conditions
      if(!CModelRunner::openFilter(signal))return false;
      
      int    symbolIndex=signal.getSymbolIndex();
      ENUM_ORDER_TYPE type=signal.getTradeType();
      if(symbolIndex<0)return false;      
      
      //max hedge group order 
      int curModelCount=this.getModelCount();  
      if(this.getModelCount()>this.getModelMaxCount())return false;
      int curSymbolModelCount=this.getSymbolModelTypeCount(symbolIndex,type);  
      if(this.getSymbolModelTypeCount(symbolIndex,type)>=this.getSymbolModelTypeMaxCount()){
         return false;
      }   
            
      logData.addLine("<Count>" + curModelCount);
      logData.addLine("<Symbol>" + SYMBOL_LIST[symbolIndex]);
      logData.addLine("<SymbolTypeCount>" + curSymbolModelCount);
      
      //judge protect symbol
      //double checkRiskSumHedgeLots=Open_Order_Check_Risk_UnitNum*Comm_Unit_LotSize;
      //double checkRiskHedgeLotRate=Open_Order_Check_Risk_HedgeRate;  
      //logData.addLine("<checkRiskSumHedgeLots>" + checkRiskSumHedgeLots);            
      //logData.addLine("<checkRiskHedgeLotRate>" + checkRiskHedgeLotRate);
      
      return true;
}

//+------------------------------------------------------------------+
//|  run the muti model by signal
//+------------------------------------------------------------------+
int CModelGrid01Runner::openModels()
{  

   rkeeLog.writeLmtLog("CModelGrid01Runner: openModels_1");   

   CSignalList *signalList=this.shareCtl.getSignalShare().getRealSignalList();       
   if(signalList==NULL)return 0;
   
   int singleCount=signalList.Count();   
   int openModelCount=0;
   logData.beginLine("<Runnner>" + this.getModelKind() + "@R        ");
   for(int i=0;i<singleCount;i++){
   
      //filter conditions and judge signal
      CSignal* signal=signalList.getSignal(i);       
      signal.setModelKind(this.modelKind); 
      signal.setSignalDiffPips(this.gridDistanceDiffPips); 
      if(!this.openCondition(signal))continue;
   
      //open model 
      CModelI* model=this.createModel();
      CModelRunner::openModel(model,signal);
      
      //if(this.getModelKind()==(MODEL_KIND_01+1)){      
      //   printf("new runnner begin!!!");
      //}
      logData.addLine("<modelId>" + model.getModelId() + "@R        "); 
      openModelCount++;
      //refresh hedge data
      //CModelRunner::hedgeOrders();   -->20250217  modify to hedge orders in the model
   }
    
   logData.saveLine("openModels_" + this.getModelKind(),1000);
   logData.addCheckNValue("openModelCount_" + this.getModelKind(),openModelCount);  //---logData test  
   
   return openModelCount;       
}

//+------------------------------------------------------------------+
//|  load models by market orders
//+------------------------------------------------------------------+
void CModelGrid01Runner::reLoadModels(void)
{  
   //reload models by market orders   
   CArrayList<COrder*>*  orderList=this.shareCtl.getModelShare().getOrders();
   for (int i = 0; i < orderList.Count(); i++) {  
      COrder *order;
      orderList.TryGetValue(i,order);
      if(CheckPointer(order)==POINTER_INVALID)continue;
      if(this.getModelKind()==order.getModelKind()){
         CModelGrid01* model;
         if(!this.shareCtl.getModelShare().containsModel(order.getModelId())){
            model=this.createModel();
            model.init(this.shareCtl,
                           this.hedgeGroup,
                           this.getModelKind(),
                           order.getModelId(),
                           order.getSymbol(),
                           order.getOrderType());
                           
           model.setStartTime(order.getStartTime());
           model.setTradeTime(order.getStartTime());
           this.shareCtl.getModelShare().addModel(model);           
         }else{
            model=this.shareCtl.getModelShare().getModel(order.getModelId());
            if(order.getStartTime()<model.getStartTime()){
               model.setStartTime(order.getStartTime());
            }
            if(order.getStartTime()>model.getTradeTime()){
               model.setTradeTime(order.getStartTime());
            }            
         }
         model.addOrder(order);
         printf("CModelRunner reLoadModels> "
                  + " modelKind:" + model.getModelKind()
                  + " modelId:" + model.getModelId()
                  + " symbol:" + model.getSymbol());                  
      }
   }
   
   // make models check line
   CArrayList<CModelI*>*   modelList=this.shareCtl.getModelShare().getModels();
   for (int i = 0; i < modelList.Count(); i++) { 
      CModelI *model;
      modelList.TryGetValue(i,model);
      if(model==NULL)continue;
      if(this.getModelKind()==model.getModelKind()){
         this.shareCtl.getRecoveryShare().loadRangeInfo(model);
         model.refresh();      
      }      
   }
}

//+------------------------------------------------------------------+
//| Set parameters
//+------------------------------------------------------------------+
void CModelGrid01Runner::setParameters(int maxOrderCount, 
                                          string distanceList,
                                          double gridDistanceDiffPips,
                                          string profitList, 
                                          double stopLoss, 
                                          double protect, 
                                          double protectDiff)
{
   // Set max order count
   gridMaxOrderCount = maxOrderCount;
   
   // Parse distance list
   comFunc.StringToDoubleArray(distanceList, gridDistance, ',');
   this.gridDistanceDiffPips=gridDistanceDiffPips;
   
   // Parse profit list
   comFunc.StringToDoubleArray(profitList, gridProfit, ',');
   
   // Set other parameters
   gridStopLoss = stopLoss;
   protectPips = protect;
   protectDiffPips = protectDiff;
}

//+------------------------------------------------------------------+
//| set parameter by customize
//+------------------------------------------------------------------+
void  CModelGrid01Runner::setGridMaxOrderCount(int value){
   this.gridMaxOrderCount=value;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelGrid01Runner::CModelGrid01Runner(){
   this.setParameters(GRID_MAX_ORDER_COUNT,
                        GRID_EXTEND_LIST,
                        GRID_DISTANCE_DIFF_PIPS,
                        GRID_PROFIT_LIST,
                        GRID_STOP_LOSS_PIPS,
                        HEDGE_GRID_PROTECT_PIPS,
                        HEDGE_GRID_PROTECT_DIFF_PIPS);

}
CModelGrid01Runner::~CModelGrid01Runner(){}
