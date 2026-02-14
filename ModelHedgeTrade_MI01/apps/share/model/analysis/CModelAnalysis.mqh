//+------------------------------------------------------------------+
//|                                                  CModelAnalysis.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\..\..\model\CModelI.mqh"
#include "..\..\symbol\CSymbolInfos.mqh"
#include "..\..\..\comm\ComFunc2.mqh"
#include "CModelCostLine.mqh"

class CModelAnalysis
  {
private: 
         CSymbolInfos*         symbolInfos;
         CModelCostLine        modelCostLine;
         int                   symbolIndex;
         int                   statusIndex;
         double                curPrice;
         //-- buy/sell price line lot info
         double                buyUpLine;
         double                buyAvgLine;
         double                buyDownLine;        
         double                buyRiskLine;
         double                buySumLot;
         datetime              buyUpTime;
         datetime              buyDownTime;
         datetime              buyRiskTime;
         CArrayList<CModelI*>  buyModelList;
         double                sellUpLine;
         double                sellAvgLine;
         double                sellRiskLine;
         double                sellDownLine;
         double                sellSumLot;
         datetime              sellUpTime;
         datetime              sellDownTime;
         datetime              sellRiskTime;
         CArrayList<CModelI*>  sellModelList;
         //-- commom info
         ENUM_ORDER_TYPE       exceedTypePre;
         ENUM_ORDER_TYPE       exceedType;
         datetime              exceedRootTime;
         double                exceedRootProfit;
         datetime              exceedMaxTime;
         double                exceedMaxProfit;
         double                exceedMinProfit;
         //double                exceedMaxProfitSpeed;
         double                exceedCurLossProfit;
         //double                exceedCurLossProfitSpeed;
         double                exceedCurProfit;
         datetime              exceedCurTime;
         double                exceedCurPrice;         
         double                exceedSumLot;
         double                exceedReSumLot;
         double                exceedReSumLotRate;
         double                exceedRate;
         CArrayList<CModelI*>  exceedModelList;
         //curvature speed
         //double                exceedWarpSpeed;
         //double                exceedWarpAcc;
                
   
public:
                  CModelAnalysis();
                  ~CModelAnalysis();
         
         //--- init 
         void      init(CSymbolInfos* symbolInfos);
         //--- reset data         
         void      reSet();
         //--- make Analysis Data
         void      makeAnalysisData(int symbolIndex,
                                    CArrayList<CModelI*>* modelList); 
         
         //--- make Analysis cost edge Data                           
         void      makeCostEdgeData(int symbolIndex,
                                    CArrayList<CModelI*>* modelList,
                                    CModelCostLine*      modelCostLine); 
                                                                                            
         //--- 辅助函数：计算价格线（适配TryGetValue）
         void      calculateLines(CArrayList<CModelI*>* list, 
                                    double& upLine, 
                                    double& avgLine, 
                                    double& riskLine, 
                                    double& downLine,
                                    datetime& upTime,
                                    datetime& downTime,
                                    datetime& riskTime,
                                    ENUM_ORDER_TYPE type);

         // Function to sort orderList by avg price desc
         void      sortModelDesc(CArrayList<CModelI*> &modelList);

         // Function to sort orderList by avg price asce
         void      sortModelAsce(CArrayList<CModelI*> &modelList);

         //+------------------------------------------------------------------+
         //| Getter/Setter 实现                                               |
         //+------------------------------------------------------------------+         
         // Buy 部分
         double getBuyUpLine();
         void setBuyUpLine(double value);
         
         double getBuyAvgLine();
         void setBuyAvgLine(double value);
         
         double getBuyDownLine();
         void setBuyDownLine(double value);
         
         double getBuySumLot();
         void setBuySumLot(double value);         
         
         CArrayList<CModelI*>* getBuyModelList();
         //void setBuyModelList(CArrayList<CModelI*>* list);
         
         // Sell 部分
         double getSellUpLine();
         void setSellUpLine(double value);
         
         double getSellAvgLine();
         void setSellAvgLine(double value);
         
         double getSellDownLine();
         void setSellDownLine(double value);

         double getSellSumLot();
         void setSellSumLot(double value);         
         
         CArrayList<CModelI*>* getSellModelList();
         //void setSellModelList(CArrayList<CModelI*>* list);
         
         // commom data(getter/setter)
         ENUM_ORDER_TYPE       getExceedType();
         double                getExceedSumLot();         
         double                getExceedRate(); 
         CArrayList<CModelI*>* getExceedModelList();         
         datetime              getExceedRootTime();
         double                getExceedRootProfit();
         datetime              getExceedMaxTime();
         double                getExceedMaxProfit();
         double                getExceedMinProfit();
         double                getExceedCurLossProfit();
         double                getExceedCurProfit();
         datetime              getExceedCurTime();
         double                getExceedCurPrice();
         double                getExceedReSumLot();
         double                getExceedReSumLotRate();
         CModelCostLine*       getModelCostLine(){return &this.modelCostLine;}
         // getter/setter status index
         int                   getStatusIndex(){return this.statusIndex;}
         void                  setStatusIndex(int value){this.statusIndex=value;}
  };

//+------------------------------------------------------------------+
//|  init
//+------------------------------------------------------------------+
void CModelAnalysis::init(CSymbolInfos* symbolInfos){
   this.symbolInfos=symbolInfos;
   this.exceedMaxProfit=0.0;
   this.exceedMaxTime=0;
   this.exceedTypePre=NULL;
   this.exceedRootTime=0;
   this.exceedRootProfit=0.0; 
   this.exceedCurTime=0;
   this.exceedCurPrice=0.0; 
   this.exceedCurLossProfit=0.0; 
   //this.exceedMaxProfitSpeed=0.0;
   //this.exceedCurLossProfitSpeed=0.0; 
   //this.exceedWarpSpeed=0.0;
   //this.exceedWarpAcc=0.0;
}


//+------------------------------------------------------------------+
//|  make AnalysisData line
//+------------------------------------------------------------------+
void CModelAnalysis::makeAnalysisData(int symbolIndex,
                                       CArrayList<CModelI*>* modelList){

   this.symbolIndex=symbolIndex;   
   // 清空现有数据
   this.reSet();
   
   // 逆序遍历并分类（适配MQL5的CArrayList特性）
   int modelCount = modelList.Count();
   int limitStatusIndex=this.getStatusIndex();
   for (int i = modelCount-1; i >= 0; i--) {
     CModelI *model = NULL;      
     if(modelList.TryGetValue(i, model)){ 
         if(model.getOrderCount()<=0)continue; 
         if(CheckPointer(model)==POINTER_INVALID)continue; 
         if(model.getStatusIndex()<limitStatusIndex)continue;   
         ENUM_ORDER_TYPE type = model.getTradeType();
         if (type == ORDER_TYPE_BUY) {
             buyModelList.Add(model);
             this.buySumLot+=model.getLot();
         } else if (type == ORDER_TYPE_SELL) {
             sellModelList.Add(model);
             this.sellSumLot+=model.getLot();
         }
     }
   }

   exceedType=NULL;
   if(buySumLot>sellSumLot){
      exceedType=ORDER_TYPE_BUY;
      exceedSumLot=buySumLot-sellSumLot;
      exceedRate=exceedSumLot/buySumLot;
      this.curPrice=this.symbolInfos.getSymbolPrice(SYMBOL_LIST[symbolIndex],ORDER_TYPE_BUY);
      exceedCurPrice=this.curPrice;
      exceedCurTime=TimeCurrent();
   }
   else if(buySumLot<sellSumLot){
      exceedType=ORDER_TYPE_SELL;
      exceedSumLot=sellSumLot-buySumLot;      
      exceedRate=exceedSumLot/sellSumLot;
      this.curPrice=this.symbolInfos.getSymbolPrice(SYMBOL_LIST[symbolIndex],ORDER_TYPE_SELL);
      exceedCurPrice=this.curPrice;
      exceedCurTime=TimeCurrent();
   }
      
   // 排序和计算
   this.sortModelDesc(buyModelList);
   this.sortModelAsce(sellModelList);
   calculateLines(&buyModelList, buyUpLine, buyAvgLine, buyRiskLine, buyDownLine,buyUpTime,buyDownTime,buyRiskTime,ORDER_TYPE_BUY);
   calculateLines(&sellModelList, sellUpLine, sellAvgLine, sellRiskLine, sellDownLine,sellUpTime,sellDownTime,sellRiskTime,ORDER_TYPE_SELL);
   
   //exceed return rate
   if(this.exceedSumLot>0){
      this.exceedReSumLotRate=this.exceedReSumLot/this.exceedSumLot;
      if(this.exceedTypePre != this.exceedType){
         this.exceedTypePre = this.exceedType;
         this.exceedCurLossProfit=0.0;
      }else{
         if(this.exceedMaxProfit < this.exceedCurProfit){
            this.exceedMaxProfit = this.exceedCurProfit;
            this.exceedMaxTime =this.exceedCurTime;
         }
         this.exceedCurLossProfit=this.exceedCurProfit-this.exceedMaxProfit;
      }
   }
   
    //make cost edge data
    //this.makeCostEdgeData(symbolIndex,modelList,this.getModelCostLine());
   
}
                               
//+------------------------------------------------------------------+
// 辅助函数：计算价格线（适配TryGetValue）
//+------------------------------------------------------------------+
void CModelAnalysis::calculateLines(CArrayList<CModelI*>* list, 
                                       double&  upLine, 
                                       double&  avgLine, 
                                       double&  riskLine,
                                       double&  downLine,
                                       datetime& upTime,
                                       datetime& downTime,
                                       datetime& riskTime,
                                       ENUM_ORDER_TYPE type) {
    int count = list.Count();
    if (count == 0) {
        upLine = avgLine = downLine = 0.0;
        return;
    }

    CModelI* firstModel = NULL;
    CModelI* lastModel = NULL;
    list.TryGetValue(0, firstModel);
    list.TryGetValue(count-1, lastModel);
    
    if(type == ORDER_TYPE_BUY){
      upLine = firstModel.getAvgPrice();    
      upTime = firstModel.getTradeTime();   
      downLine =lastModel.getAvgPrice();       
      downTime = lastModel.getTradeTime(); 
    }else{
      upLine =lastModel.getAvgPrice();       
      upTime = lastModel.getTradeTime();   
      downLine =firstModel.getAvgPrice(); 
      downTime = firstModel.getTradeTime(); 
    }
    
    double sumPrice = 0.0; 
    double curSumLot=0.0;
    for (int i = 0; i < count; i++) {
        CModelI* model = NULL;
        if (list.TryGetValue(i, model)) {
           if(model.getOrderCount()<=0)continue; 
           if(CheckPointer(model)==POINTER_INVALID)continue;           
           if(type == this.exceedType){
             if(sumPrice == 0.0){
                this.exceedMaxTime=model.getProfitMaxTime();
             }
             sumPrice += model.getAvgPrice();
             if(curSumLot<exceedSumLot){
                this.exceedModelList.Add(model);
                riskLine=model.getAvgPrice();
                this.exceedCurProfit+=model.getProfitPips();
                this.exceedMaxProfit+=model.getProfitMaxPips();
                this.exceedMinProfit+=model.getProfitMinPips();
             }else if(this.exceedRootTime == 0){
               this.exceedRootTime=model.getTradeTime();
               this.exceedRootProfit=model.getProfitMinPips();
             }
             curSumLot+=model.getLot();
             if(type == ORDER_TYPE_BUY){
               if(this.curPrice<=model.getAvgPrice()){
                  this.exceedReSumLot=curSumLot;
               }
             }else if(type == ORDER_TYPE_SELL){
               if(this.curPrice>=model.getAvgPrice()){
                  this.exceedReSumLot=curSumLot;
               }             
             }
           }
        }
    }
    avgLine = (count > 0) ? (sumPrice / count) : 0.0;        
}   


//+------------------------------------------------------------------+
// make cost edge
//+------------------------------------------------------------------+
void CModelAnalysis::makeCostEdgeData(int symbolIndex,
                           CArrayList<CModelI*>* modelList,
                           CModelCostLine*       modelCostLine){
                           
   
   int modelCount=modelList.Count();
   
   if(modelCount<=0){
      this.modelCostLine.setCostExist(false);
      return;
   }
   this.modelCostLine.setCostExist(true);
   // 计算成本重心
   double totalWeightedPrice = 0;
   double totalLots = 0;
   double highestAvgPrice = -DBL_MAX;
   double lowestAvgPrice = DBL_MAX;
   
   for (int i = 0; i < modelCount; i++) {
      CModelI *model;
      if (modelList.TryGetValue(i, model)) {

         double avgPrice = model.getAvgPrice();
         double lots = model.getLot();
         
         totalWeightedPrice += avgPrice * lots;
         totalLots += lots;
         
         if (avgPrice > highestAvgPrice) highestAvgPrice = avgPrice;
         if (avgPrice < lowestAvgPrice) lowestAvgPrice = avgPrice;
      }
   }
   
   //if (totalLots == 0) return;   
   double costCenter =0;
   if(totalLots > 0){
      costCenter=totalWeightedPrice / totalLots;
   }

   modelCostLine.setCostCenter(costCenter);
   modelCostLine.setUpperEdge(highestAvgPrice);
   modelCostLine.setDownEdge(lowestAvgPrice);
   
   // 计算成本重心
   double totalUpperWeightedPrice = 0,totalDownWeightedPrice = 0;
   double totalUpperLots = 0,totalDownLots = 0;
      
   for (int i = 0; i < modelCount; i++) {
      CModelI *model;
      if (modelList.TryGetValue(i, model)) {

         double avgPrice = model.getAvgPrice();
         double lots = model.getLot();         
         if(model.getAvgPrice()>=costCenter){
            totalUpperWeightedPrice += avgPrice * lots;
            totalUpperLots += lots;         
         }
         if(model.getAvgPrice()<=costCenter){
            totalDownWeightedPrice += avgPrice * lots;
            totalDownLots += lots;                           
         }                  
      }
   }   
   
   double costUpperCenter =0;
   double costDownCenter =0;
   if(totalUpperLots>0){
      costUpperCenter = totalUpperWeightedPrice / totalUpperLots;
   }
   if(totalDownLots>0){
      costDownCenter = totalDownWeightedPrice / totalDownLots;
   }   
   
   modelCostLine.setCostUpperCenter(costUpperCenter);
   modelCostLine.setCostDownCenter(costDownCenter);
   
   //this.curPrice=this.symbolInfos.getSymbolPrice(SYMBOL_LIST[symbolIndex],ORDER_TYPE_BUY);
   //double point=this.symbolInfos.getSymbolPoint(SYMBOL_LIST[symbolIndex]);
      
}

//+------------------------------------------------------------------+
//| Function to sort orderList by avg price desc
//+------------------------------------------------------------------+      
void CModelAnalysis::sortModelDesc(CArrayList<CModelI*> &modelList)
{
   CModelComparerDes comparer;  // Create an instance of the comparer
   modelList.Sort(&comparer);  // Sort the list using the comparer
}

//+------------------------------------------------------------------+
//| Function to sort orderList by avg price asce
//+------------------------------------------------------------------+      
void CModelAnalysis::sortModelAsce(CArrayList<CModelI*> &modelList)
{
   CModelComparerAsc comparer;  // Create an instance of the comparer
   modelList.Sort(&comparer);  // Sort the list using the comparer
}

//+------------------------------------------------------------------+
//|  reset data
//+------------------------------------------------------------------+
void CModelAnalysis::reSet(){
    buyModelList.Clear();
    sellModelList.Clear();
    exceedModelList.Clear();
    buyUpLine = buyAvgLine = buyDownLine = buyRiskLine= 0.0;
    sellUpLine = sellAvgLine = sellDownLine = sellRiskLine = 0.0;
    buySumLot = sellSumLot = exceedSumLot = exceedRate = 0.0;
    buyUpTime = buyDownTime = buyRiskTime =0;    
    sellUpTime = sellDownTime = sellRiskTime =0;
    exceedRootTime = exceedMaxTime = 0;  
    exceedCurProfit = exceedReSumLot  = exceedReSumLotRate = 0.0; 
    exceedMaxProfit = exceedMinProfit = 0.0; 
}

//+------------------------------------------------------------------+
//| Getter/Setter 实现                                               |
//+------------------------------------------------------------------+

// Buy 部分
double CModelAnalysis::getBuyUpLine()  { return buyUpLine; }
void CModelAnalysis::setBuyUpLine(double value) { buyUpLine = value; }

double CModelAnalysis::getBuyAvgLine()  { return buyAvgLine; }
void CModelAnalysis::setBuyAvgLine(double value) { buyAvgLine = value; }

double CModelAnalysis::getBuyDownLine()  { return buyDownLine; }
void CModelAnalysis::setBuyDownLine(double value) { buyDownLine = value; }

double CModelAnalysis::getBuySumLot(void)  { return buySumLot; }
void CModelAnalysis::setBuySumLot(double value) { buySumLot = value; }

CArrayList<CModelI*>* CModelAnalysis::getBuyModelList()  { return &buyModelList; }
//void CModelAnalysis::setBuyModelList(CArrayList<CModelI*>* list) { buyModelList = list; }

// Sell 部分
double CModelAnalysis::getSellUpLine()  { return sellUpLine; }
void CModelAnalysis::setSellUpLine(double value) { sellUpLine = value; }

double CModelAnalysis::getSellAvgLine()  { return sellAvgLine; }
void CModelAnalysis::setSellAvgLine(double value) { sellAvgLine = value; }

double CModelAnalysis::getSellDownLine()  { return sellDownLine; }
void CModelAnalysis::setSellDownLine(double value) { sellDownLine = value; }

double CModelAnalysis::getSellSumLot(void)  { return sellSumLot; }
void CModelAnalysis::setSellSumLot(double value) { sellSumLot = value; }

CArrayList<CModelI*>* CModelAnalysis::getSellModelList()  { return &sellModelList; }
//void CModelAnalysis::setSellModelList(CArrayList<CModelI*>* list) { sellModelList = list; }


// Exceed 部分
CArrayList<CModelI*>* CModelAnalysis::getExceedModelList()  { return &this.exceedModelList; }
ENUM_ORDER_TYPE CModelAnalysis::getExceedType(){return this.exceedType;}
double CModelAnalysis::getExceedSumLot(){return this.exceedSumLot;}
double CModelAnalysis::getExceedRate(){return this.exceedRate;}
datetime CModelAnalysis::getExceedRootTime() { return exceedRootTime; }
double CModelAnalysis::getExceedRootProfit() { return exceedRootProfit; }
datetime CModelAnalysis::getExceedMaxTime() { return exceedMaxTime; }
double CModelAnalysis::getExceedMaxProfit() { return exceedMaxProfit; }
double CModelAnalysis::getExceedMinProfit() { return exceedMinProfit; }
double CModelAnalysis::getExceedCurLossProfit() { return exceedCurLossProfit; }
double CModelAnalysis::getExceedCurProfit() { return exceedCurProfit; }
datetime CModelAnalysis::getExceedCurTime() { return exceedCurTime; }
double CModelAnalysis::getExceedCurPrice() { return exceedCurPrice; }
double CModelAnalysis::getExceedReSumLot() { return exceedReSumLot; }
double CModelAnalysis::getExceedReSumLotRate() { return exceedReSumLotRate; }

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelAnalysis::CModelAnalysis(){  
}
CModelAnalysis::~CModelAnalysis(){
}

//+------------------------------------------------------------------+
//| IComparer class for sorting by avg price(降序)
//+------------------------------------------------------------------+
class CModelComparerDes : public IComparer<CModelI*>{
   public:
      // Implement the Compare function to compare two COrder objects by profit
      virtual  int Compare(CModelI* left, CModelI* right) override
      {
         if(left.getAvgPrice() > right.getAvgPrice())
            return -1; // Return -1 if the first order's avg price is greater
         else if(left.getAvgPrice() < right.getAvgPrice())
            return 1;  // Return 1 if the first order's avg price is smaller
         return 0;     // Return 0 if both orders have the same profit
      }
};

//+------------------------------------------------------------------+
//| IComparer class for sorting by avg price (升序)
//+------------------------------------------------------------------+
class CModelComparerAsc : public IComparer<CModelI*>{
   public:
      // Implement the Compare function to compare two COrder objects by profit
      virtual  int Compare(CModelI* left, CModelI* right) override
      {
         if(left.getAvgPrice() < right.getAvgPrice())
            return -1; // Return -1 if the first order's avg price is greater
         else if(left.getAvgPrice() > right.getAvgPrice())
            return 1;  // Return 1 if the first order's avg price is smaller
         return 0;     // Return 0 if both orders have the same profit
      }
};