//+------------------------------------------------------------------+
//|                                                     CModelGrid0101.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../../../../share/CShareCtl.mqh"
#include "../../../CModel.mqh"


class CModelGrid01: public CModel 
{
      private:            
         //datetime          startTime;
         
         //grid set parameter(input)
         int               gridMaxOrderCount;  //set parameter
         double            gridDistance[];     //set parameter
         double            gridProfit[];       //set parameter
         double            gridStopLoss;       //set parameter
         double            protectPips;        //set parameter
         double            protectDiffPips;    //set parameter
         
         //grid check line by calculate order status
         double            gridStartLine;       //check line
         double            gridEdgeLine;        //check line
         double            gridAvgLine;         //check line
         
         //risk control
         bool              riskModel;
         double            riskLine;             //check line
         double            riskClearLine;        //check line
         double            riskSumLot;           //risk sum lot
         
         //close control 
         double            profitPips;           //profit pips(all orders)
         double            profitMaxPips;        //profit max pips(all orders)
         double            profitMinPips;        //profit min pips(all orders)
         int               orderCount;           //order Count
         datetime          profitMaxTime;        //the time of profit max pips(all orders) 
         datetime          profitMinTime;        //the time of profit max pips(all orders) 
         
      public:
           CModelGrid01();
           ~CModelGrid01(); 
         
         //--- interface function
         void     reloadOrders();    //reload orders when restart
         void     openModel();      //open model
         bool     extendModel();    //extend model
         bool     enableExtend();   //if enable extend model
         bool     closeModel();     //close model
         bool     enableClose();    //if enable close model                
         COrder*  createOrder(void);
         void     protectOrder();
         void     run();  //model run
         void     refresh();
         double   getProfitPips();             //get model profit pips
         double   getProfitMaxPips();          //get model profit max pips
         double   getProfitMinPips();          //get model profit min pips
         datetime getProfitMaxTime();          //the time of model profit max pips
         datetime getProfitMinTime();          //the time of model profit min pips         
         double   getStopLossPips();           //get model stop loss pips
         double   getCloseProfitPips();        //get model close profit pips
         double   getAvgPrice();               //get grid model avg price(all orders)
         
         //--- grid function
         bool     extendCondition();  
         bool     extendGrid();  
         bool     closeGrid(); 
         double   getEdgeDistance();
         double   getStartLine();
         
         //--- risk control
         bool     riskProtect();
         void     riskCheck();
         void     riskLotCheck();
         double   getRiskPips();     //distance between the startLine and riskLine
         
         //--- set parameter
         void     setParameters(int maxOrderCount, 
                                const double &distance[], 
                                const double &profit[], 
                                double stopLoss, 
                                double protect, 
                                double protectDiff);
        
        //--- model info
        string     modelInfo();
        //--- get profit
        double     getProfit();
        //--- get lot
        double     getLot();
};


//+------------------------------------------------------------------+
//|  run model
//+------------------------------------------------------------------+  
void CModelGrid01::run(){}

//+------------------------------------------------------------------+
//|  open model
//+------------------------------------------------------------------+
void  CModelGrid01::openModel(){
   //rkeeLog.writeLog("CModelGrid01::openModel---modelId:" + this.getModelId());   
   this.createOrder();
   this.refresh();   
}

//+------------------------------------------------------------------+
//|  open model
//+------------------------------------------------------------------+
bool  CModelGrid01::extendModel(){
   if(this.extendGrid()){
      this.refresh();
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//|  open model
//+------------------------------------------------------------------+
bool  CModelGrid01::closeModel(){
   return this.closeGrid();
}


//+------------------------------------------------------------------+
//|  create order
//+------------------------------------------------------------------+  
COrder*  CModelGrid01::createOrder(void){
   this.setActionFlg("createOrder");
   datetime curTime=TimeCurrent();
   COrder* order=CModel::createOrder();      
   order.setTradeStatus(TRADE_STATUS_TRADE_READY);        
   order.setLot(Comm_Unit_LotSize);   
   //same start time to order
   //order.setStartTime(this.startTime);
   order.setStartTime(curTime);
   double tradePrice=this.getSymbolPrice();
   order.setOpenPrice(tradePrice);
   
   //set grid edge line
   if(order.getOrderIndex()==0){
      this.gridStartLine=tradePrice;
      this.setStartTime(curTime);
   }   
   this.gridEdgeLine=tradePrice;
   //rkeeLog.writeLog("CModelGrid01::createOrder---orderId:" + order.getMagic());
   return order;   
}


//+------------------------------------------------------------------+
//|  judge if enable extend grid by distance
//+------------------------------------------------------------------+  
bool CModelGrid01::enableExtend(){
   this.setActionFlg("enableExtend");
   
   rkeeLog.writeLmtLog("CModelGrid01: enableExtend1");  
   
   if(this.getModelStatus()!=MODEL_STATUS_OPEN)return false;
   //com check
   if(this.getOrderCount()>=this.gridMaxOrderCount)return false;
   int orderIndex=this.getOrderIndex();
   if(orderIndex<0)return false;
   if(orderIndex>=(ArraySize(this.gridDistance)-1)){
      orderIndex=ArraySize(this.gridDistance)-1;
   }         
   rkeeLog.writeLmtLog("CModelGrid01: enableExtend2");  
   double extendRate=1;
   int statusFlg=this.getStatusFlg();
   if(statusFlg==STATUS_RANGE_BREAK_UP || statusFlg==STATUS_RANGE_BREAK_DOWN){
      //extendRate=Trend_Grid_Grow_Rate;
      extendRate=this.getExtendRate();
   }
   
   int edgeDistancePips=this.getEdgeDistance();   
   
   rkeeLog.writeLmtLog("CModelGrid01: enableExtend3  edgeDistancePips:" + edgeDistancePips);
   rkeeLog.writeLmtLog("CModelGrid01: enableExtend3  edgeDistancePips2:" + this.gridDistance[orderIndex]*extendRate);
   if(edgeDistancePips>this.gridDistance[orderIndex]*extendRate){
      //judge extend conditions
      if(!this.extendCondition())return false; 
      rkeeLog.writeLmtLog("CModelGrid01: enableExtend3  extendOrder");
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//|  extend grid by distance
//+------------------------------------------------------------------+  
bool CModelGrid01::extendGrid(){
   this.setActionFlg("extendGrid");
   
   rkeeLog.writeLmtLog("CModelGrid01: extendGrid1");  
   
   if(this.getModelStatus()!=MODEL_STATUS_OPEN)return false;
   //com check
   if(this.getOrderCount()>=this.gridMaxOrderCount)return false;
   int orderIndex=this.getOrderIndex();
   if(orderIndex<0)return false;
   if(orderIndex>=(ArraySize(this.gridDistance)-1)){
      orderIndex=ArraySize(this.gridDistance)-1;
   }         
   rkeeLog.writeLmtLog("CModelGrid01: extendGrid2");  
   double extendRate=1;
   int statusFlg=this.getStatusFlg();
   if(statusFlg==STATUS_RANGE_BREAK_UP || statusFlg==STATUS_RANGE_BREAK_DOWN){
      //extendRate=Trend_Grid_Grow_Rate;
      extendRate=this.getExtendRate();
   }
   
   int edgeDistancePips=this.getEdgeDistance();   
   
   rkeeLog.writeLmtLog("CModelGrid01: extendGrid3  edgeDistancePips:" + edgeDistancePips);
   rkeeLog.writeLmtLog("CModelGrid01: extendGrid3  edgeDistancePips2:" + this.gridDistance[orderIndex]*extendRate);
   if(edgeDistancePips>this.gridDistance[orderIndex]*extendRate){
      //judge extend conditions
      if(!this.extendCondition())return false; 
      rkeeLog.writeLmtLog("CModelGrid01: extendGrid3  extendOrder");
      this.createOrder();
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//|  judge if extend grid by condition
//+------------------------------------------------------------------+  
bool CModelGrid01::extendCondition(){
 
   //judge hedge correlation 
   /*   
   bool ifHedge=this.getHedgeGroup().ifGroupHedge(this.getModelKind(),
                                    this.getSymbolIndex(),
                                    this.getTradeType(),
                                    Comm_Unit_LotSize);
   
   if(!ifHedge)return false;*/
   this.getShareCtl().getFilterShare().extendFilter(&this);
      
   return true;
}

//+------------------------------------------------------------------+
//|  if enable close grid by takeProfit/stopLoss
//+------------------------------------------------------------------+  
bool CModelGrid01::enableClose(){
   this.setActionFlg("closeGrid");
   if(this.getModelStatus()==MODEL_STATUS_CLOSE_READY
      || this.getModelStatus()==MODEL_STATUS_CLOSE){
      return false;
   }
   
   double   closeProfit=this.getCloseProfitPips();
   double   closeStopLoss=-this.getStopLossPips();
   
   rkeeLog.writeLmtLog("CModelGrid01: enableClose1 closeProfit:" + closeProfit);   
   rkeeLog.writeLmtLog("CModelGrid01: enableClose1 closeStopLoss:" + closeStopLoss);  
   
   if(closeProfit<0)return false;
   
   //take profit
   if(this.profitPips>closeProfit){
      return true;         
   }
   //stop loss
   else if(this.profitPips<closeStopLoss){
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//|  close grid by takeProfit/stopLoss
//+------------------------------------------------------------------+  
bool CModelGrid01::closeGrid(){
   this.setActionFlg("closeGrid");
   if(this.getModelStatus()==MODEL_STATUS_CLOSE_READY
      || this.getModelStatus()==MODEL_STATUS_CLOSE){
      return false;
   }
   
   double   closeProfit=this.getCloseProfitPips();
   double   closeStopLoss=-this.getStopLossPips();
   
   rkeeLog.writeLmtLog("CModelGrid01: closeGrid1 closeProfit:" + closeProfit);   
   rkeeLog.writeLmtLog("CModelGrid01: closeGrid1 closeStopLoss:" + closeStopLoss);  
   
   if(closeProfit<0)return false;
   
   //take profit
   if(this.profitPips>closeProfit){
      if(this.closeOrders()>0){
         this.setModelStatus(MODEL_STATUS_CLOSE_READY);
         return true;         
      }
   }
   //stop loss
   else if(this.profitPips<closeStopLoss){
      if(this.closeOrders()>0){
         this.setModelStatus(MODEL_STATUS_CLOSE_READY);
         return true;
      }   
   }

   return false;
}

//+------------------------------------------------------------------+
//|  refresh status and check line
//+------------------------------------------------------------------+  
void CModelGrid01::refresh(){   
   //CModel refresh
   CModel::refresh();
   
   //clean order set
   this.clean();   
   this.orderCount=this.getOrderCount();
   if(this.orderCount<=0){
      if(this.getModelStatus()==MODEL_STATUS_CLOSE_READY){
         this.setModelStatus(MODEL_STATUS_CLOSE);
      }
      this.profitPips=0;
      this.profitMaxPips=0.0;
      this.profitMinPips=0.0;
      return;
   }   
   double sumPrice=0;
   int positionCount=0;
   int errorOpenCount=0;
   for (int i = 0; i < this.orderCount; i++) {
      COrder* order=this.getOrder(i);      
      if(CheckPointer(order)==POINTER_INVALID)continue;
      sumPrice+=order.getOpenPrice();
      //set grid edge line
      if(i==0){
         this.gridStartLine=order.getOpenPrice();
      }   
      else if(i==(orderCount-1)){
         this.gridEdgeLine=order.getOpenPrice();
      }
      //judge if model close
      if(order.getTradeStatus()==TRADE_STATUS_CLOSE){
         this.removeOrder(order);
      }
      //judge if order error open
      if(order.getTradeStatus()==TRADE_STATUS_ERROR_OPEN){
         this.removeOrder(order);
         errorOpenCount++;
      }
      //check order positions
      if(order.getTicket()>0)positionCount++;      
   }
   
   //close model
   if(positionCount>0){
      this.setModelStatus(MODEL_STATUS_OPEN); 
   }else{
      if(this.getModelStatus()==MODEL_STATUS_OPEN){
         this.setModelStatus(MODEL_STATUS_CLOSE);
         return;
      }
      if(errorOpenCount==this.orderCount){
         this.setModelStatus(MODEL_STATUS_CLOSE);
         return;      
      }
   }
      
   this.gridAvgLine=sumPrice/orderCount;   
   //make risk/clear line
   double point=this.getSymbolPoint();      
   double protectDiff=(this.protectPips/orderCount)*point;
   double protectClearDiff=((this.protectPips-this.protectDiffPips)/orderCount)*point;
   if(protectClearDiff<0)protectClearDiff=protectDiff;
   
   if(this.getTradeType()==ORDER_TYPE_BUY){
      this.riskLine=this.gridAvgLine-protectDiff;
      this.riskClearLine=this.gridAvgLine-protectClearDiff;
   }else{
      this.riskLine=this.gridAvgLine+protectDiff;
      this.riskClearLine=this.gridAvgLine+protectClearDiff;      
   }
   
   //make profit pips
   double curTradePrice=this.getSymbolPrice();     
   this.profitPips=((curTradePrice-this.gridAvgLine)/point)*this.orderCount;   
   if(this.getTradeType()==ORDER_TYPE_SELL){
      this.profitPips=-this.profitPips;
   }   
   
   if(this.profitMaxPips<this.profitPips){
      this.profitMaxPips=this.profitPips;
      this.profitMaxTime=TimeCurrent();
   }
   if(this.profitMinPips>this.profitPips){
      this.profitMinPips=this.profitPips;
      this.profitMinTime=TimeCurrent();
   }
   
   //risk check
   this.riskCheck();   
}

//+------------------------------------------------------------------+
//|  get model profit pips
//+------------------------------------------------------------------+ 
double CModelGrid01::getProfitPips(){
   return this.profitPips;
}

//+------------------------------------------------------------------+
//|  get model profit max pips
//+------------------------------------------------------------------+ 
double CModelGrid01::getProfitMaxPips(){
   return this.profitMaxPips;
}

//+------------------------------------------------------------------+
//|  get model profit min pips
//+------------------------------------------------------------------+ 
double CModelGrid01::getProfitMinPips(){
   return this.profitMinPips;
}

//+------------------------------------------------------------------+
//|  get time of model profit max pips
//+------------------------------------------------------------------+ 
datetime CModelGrid01::getProfitMaxTime(){
   return this.profitMaxTime;
}

//+------------------------------------------------------------------+
//|  get time of model profit min pips
//+------------------------------------------------------------------+ 
datetime CModelGrid01::getProfitMinTime(){
   return this.profitMinTime;
}

//+------------------------------------------------------------------+
//|  get model stop loss pips
//+------------------------------------------------------------------+ 
double CModelGrid01::getStopLossPips(){
   return this.gridStopLoss;
}

//+------------------------------------------------------------------+
//|  get model close profit pips 
//+------------------------------------------------------------------+ 
double CModelGrid01::getCloseProfitPips(){

   int    maxOrderIndex=this.getOrderCount();
   if(maxOrderIndex<0)return 0;
   if(maxOrderIndex>=(ArraySize(this.gridProfit)-1)){
      maxOrderIndex=ArraySize(this.gridProfit)-1;
   }
   //take profit
   return this.gridProfit[maxOrderIndex];
}

//+------------------------------------------------------------------+
//|  model risk check
//+------------------------------------------------------------------+  
void CModelGrid01::riskCheck(){
   //judge to risk model
   double curTradePrice=this.getSymbolPrice();
   if(this.riskModel){
      if(this.getTradeType()==ORDER_TYPE_BUY){
         if(curTradePrice>this.riskClearLine)this.riskModel=false;
      }else{
         if(curTradePrice<this.riskClearLine)this.riskModel=false;
      }
   }else{
      if(this.getTradeType()==ORDER_TYPE_BUY){
         if(curTradePrice<this.riskLine)this.riskModel=true;
      }else{
         if(curTradePrice>this.riskLine)this.riskModel=true;
      }   
   }
   
   //risk lot check
   this.riskLotCheck();
}

//+------------------------------------------------------------------+
//|  risk lot check
//+------------------------------------------------------------------+  
void CModelGrid01::riskLotCheck(){
   
   //if(!this.riskProtect())return;
   int orderCount=this.getOrderCount();
   if(orderCount<=0)return;
   double riskPips=this.getRiskPips();
   if(riskPips<=0)return;
   this.riskSumLot=0;
   for (int i = 0; i < orderCount; i++) {
      COrder* order=this.getOrder(i);
      if(CheckPointer(order)==POINTER_INVALID)continue;
      order.setProtectlot(0);
      double profitPips=this.getOrderProfitPips(order);
      if(profitPips<0){
         double riskRate=1;         
         if(riskPips>MathAbs(profitPips)){
            riskRate=MathAbs(profitPips)/riskPips;
         }         
         order.setProtectlot(order.getLot()*riskRate);
         this.riskSumLot+=order.getProtectlot();
      }      
   }   
}

//+------------------------------------------------------------------+
//|  get risk pips
//+------------------------------------------------------------------+  
double  CModelGrid01::getRiskPips(){
   double point=this.getSymbolPoint();
   double riskPips=MathAbs(this.riskLine-this.gridStartLine)/point;
   return riskPips;   
}

//+------------------------------------------------------------------+
//|  model risk protect
//+------------------------------------------------------------------+ 
bool  CModelGrid01::riskProtect(){
   return this.riskModel;
}

//+------------------------------------------------------------------+
//|  get grid distance
//+------------------------------------------------------------------+  
double CModelGrid01::getEdgeDistance(){
   double curTradePrice=this.getSymbolPrice();
   double point=this.getSymbolPoint();
   double diffEdgePips=0;
   if(this.getTradeType()==ORDER_TYPE_BUY){
      diffEdgePips=this.gridEdgeLine-curTradePrice;
   }else{
      diffEdgePips=curTradePrice-this.gridEdgeLine;
   }
   if(point>0)return diffEdgePips/point;
   return -1;
}

//+------------------------------------------------------------------+
//|  get model start line
//+------------------------------------------------------------------+  
double CModelGrid01::getStartLine(){
   return this.gridStartLine;
}

//+------------------------------------------------------------------+
//|  get grid model avg price(all orders)         
//+------------------------------------------------------------------+  
double CModelGrid01::getAvgPrice(){
   return this.gridAvgLine;
}

//+------------------------------------------------------------------+
//| Set parameters(add symbol rate)
//+------------------------------------------------------------------+
void CModelGrid01::setParameters(int maxOrderCount, 
                     const double &distance[], 
                     const double &profit[], 
                     double stopLoss, 
                     double protect, 
                     double protectDiff)
{
   gridMaxOrderCount = maxOrderCount;
   
   // Copy gridDistance
   ArrayResize(gridDistance, ArraySize(distance));
   ArrayCopy(gridDistance, distance);
   
   // Copy gridProfit
   ArrayResize(gridProfit, ArraySize(profit));
   ArrayCopy(gridProfit, profit);
   
   gridStopLoss = stopLoss;
   protectPips = protect;
   protectDiffPips = protectDiff;
}

//+------------------------------------------------------------------+
//|  output model info
//+------------------------------------------------------------------+        
string CModelGrid01::modelInfo(){

   string temp="  ";   
   //sum info
   temp +=" <Kind>:" + this.getModelKind();
   temp +=" <Id>:" + this.getModelId();
   temp +=" <status>:" + this.getModelStatus();
   temp +=" <order>:" + this.getOrderCount();

   return temp;
}

//+------------------------------------------------------------------+
//|  get model profit pips
//+------------------------------------------------------------------+
double CModelGrid01::getProfit(){
   return this.profitPips;
}

//+------------------------------------------------------------------+
//|  get model profit pips
//+------------------------------------------------------------------+
double CModelGrid01::getLot(){
   return this.getOrderCount()*Comm_Unit_LotSize;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelGrid01::CModelGrid01(){
   this.gridStartLine=0;
   //this.startTime=0;
   this.setStartTime(0);
   this.riskModel=false;
   this.profitPips=0.0;
   this.profitMaxPips=0.0;
   this.profitMinPips=0.0;
   this.profitMaxTime=0;        //the time of profit max pips(all orders) 
   this.profitMinTime=0;        //the time of profit max pips(all orders) 
   
}
CModelGrid01::~CModelGrid01(){}