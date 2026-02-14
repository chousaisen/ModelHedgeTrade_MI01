//+------------------------------------------------------------------+
//|                                                    CHedgeGroup.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>

#include "..\..\comm\ComFunc.mqh"
#include "..\..\header\CHeader.mqh"
#include "..\..\header\symbol\CHeader.mqh"

class CHedgeGroupInfo
  {
   public:   
         //+------------------------------------------------------------------+
         //|  hedge rate
         //+------------------------------------------------------------------+
         double                              hedgeRate;
   
         //+------------------------------------------------------------------+
         //|  order count
         //+------------------------------------------------------------------+
         int                                 orderCount;
         int                                 buyOrderCount;
         int                                 sellOrderCount;
         int                                 delayOrderCount;
         int                                 protectOrderCount;
         int                                 hedgeOrderCount;
         int                                 curSymbolOrderCount[SYMBOL_MAX_COUNT];
         int                                 curSymbolprotectOrderCount[SYMBOL_MAX_COUNT];
         int                                 curSymbolHedgeOrderCount[SYMBOL_MAX_COUNT];
         //+------------------------------------------------------------------+
         //|  model count
         //+------------------------------------------------------------------+         
         int                                 curModelCount;
         int                                 curSymbolBuyModelCount[SYMBOL_MAX_COUNT];
         int                                 curSymbolSellModelCount[SYMBOL_MAX_COUNT];
         CArrayList<ulong>                   curSymbolModelList;
         
         //+------------------------------------------------------------------+
         //|  symbol profit 
         //+------------------------------------------------------------------+
         double                              sumProfit;        
         double                              sumProtectProfit;
         double                              sumHedgeProfit;
         double                              curSymbolProfit[SYMBOL_MAX_COUNT];
         double                              curSymbolProtectProfit[SYMBOL_MAX_COUNT];
         double                              curSymbolHedgeProfit[SYMBOL_MAX_COUNT];         
         
         //+------------------------------------------------------------------+
         //|  group lot
         //+------------------------------------------------------------------+
         double                              sumLots;
         double                              protectSumLots;
         double                              hedgeSumLots;
         double                              curSymbolLots[SYMBOL_MAX_COUNT];
         double                              curSymbolProtectLots[SYMBOL_MAX_COUNT];
         double                              curSymbolHedgeLots[SYMBOL_MAX_COUNT];
         
         //+------------------------------------------------------------------+
         //|  class constructor   
         //+------------------------------------------------------------------+
                                             CHedgeGroupInfo();
                                             ~CHedgeGroupInfo();   
         //+------------------------------------------------------------------+
         //|  init function to initialize all variables to 0
         //+------------------------------------------------------------------+
         void                                init();
         
         //+------------------------------------------------------------------+
         //|  add order info
         //+------------------------------------------------------------------+
         void                                addProtectOrderInfo(int symbolIndex,COrder* order);
         void                                addHedgeOrderInfo(int symbolIndex,COrder* order);
         
         //+------------------------------------------------------------------+
         //|  get group info
         //+------------------------------------------------------------------+         
         string                              getGroupInfo();
         string                              getGroupSymbolInfo(); 

         //+------------------------------------------------------------------+
         //|  get model group info
         //+------------------------------------------------------------------+
         int                                getModelCount();
         int                                getSymbolModelTypeCount(int symbolIndex,ENUM_ORDER_TYPE orderType);
         
         //+------------------------------------------------------------------+
         //|  get group detail info
         //+------------------------------------------------------------------+         
         double                              getHedgeRate();
         double                              getSumLots();
         double                              getSumProtectLots();
         double                              getSumHedgeLots();                  
         double                              getSumProfit();
         double                              getSumProtectProfit();
         double                              getSumHedgeProfit(); 
         int                                 getProtectOrderCount();
         int                                 getHedgeOrderCount();                          
         int                                 getBuyOrderCount(){return this.buyOrderCount;} 
         int                                 getSellOrderCount(){return this.sellOrderCount;} 
  };

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CHedgeGroupInfo::CHedgeGroupInfo(){}
CHedgeGroupInfo::~CHedgeGroupInfo(){}


//+------------------------------------------------------------------+
//|  init function to initialize all variables to 0
//+------------------------------------------------------------------+
void CHedgeGroupInfo::init()
{
  // Initialize double variables
  hedgeRate = 0.0;
  sumProfit = 0.0;
  sumProtectProfit = 0.0;
  sumHedgeProfit = 0.0;
  sumLots = 0.0;
  protectSumLots = 0.0;
  hedgeSumLots = 0.0;

  // Initialize int variables
  orderCount = 0;
  buyOrderCount = 0;
  sellOrderCount = 0;
  delayOrderCount=0;
  protectOrderCount = 0;
  hedgeOrderCount = 0;
  curModelCount=0;  
  
  // Initialize arrays
  ArrayInitialize(curSymbolOrderCount, 0);
  ArrayInitialize(curSymbolprotectOrderCount, 0);
  ArrayInitialize(curSymbolHedgeOrderCount, 0);  
  ArrayInitialize(curSymbolBuyModelCount, 0);
  ArrayInitialize(curSymbolSellModelCount, 0);
  ArrayInitialize(curSymbolProfit, 0.0);
  ArrayInitialize(curSymbolProtectProfit, 0.0);
  ArrayInitialize(curSymbolHedgeProfit, 0.0);
  ArrayInitialize(curSymbolLots, 0.0);
  ArrayInitialize(curSymbolProtectLots, 0.0);
  ArrayInitialize(curSymbolHedgeLots, 0.0);
  
  this.curSymbolModelList.Clear();
}

//+------------------------------------------------------------------+
//|  add protect order info
//+------------------------------------------------------------------+
void   CHedgeGroupInfo::addProtectOrderInfo(int symbolIndex,COrder* order){
     
   //group order count
   this.orderCount++;
   this.protectOrderCount++;
   this.curSymbolOrderCount[symbolIndex]++;
   this.curSymbolprotectOrderCount[symbolIndex]++;
     
   //group profit
   this.sumProfit+=order.getProfit();
   this.sumProtectProfit+=order.getProfit();
   this.curSymbolProfit[symbolIndex]+=order.getProfit();
   this.curSymbolProtectProfit[symbolIndex]+=order.getProfit(); 
   
   //group lot
   this.sumLots+=order.getLot();
   this.protectSumLots+=order.getLot();
   this.curSymbolLots[symbolIndex]+=order.getLot();
   this.curSymbolProtectLots[symbolIndex]+=order.getLot();
   
   //delay orders
   int passedHours=(TimeCurrent()-order.getStartTime())/3600;   
   if(passedHours>Log_Show_Orders_Passed_Hours){
      this.delayOrderCount++;
   }
     
}

//+------------------------------------------------------------------+
//|  add protect order info
//+------------------------------------------------------------------+
void   CHedgeGroupInfo::addHedgeOrderInfo(int symbolIndex,COrder* order){
     
   //group order count
   this.orderCount++;
   if(order.getOrderType()==ORDER_TYPE_BUY){
      this.buyOrderCount++;
   }else if(order.getOrderType()==ORDER_TYPE_SELL){
      this.sellOrderCount++;
   }   
   this.hedgeOrderCount++;
   this.curSymbolOrderCount[symbolIndex]++;
   this.curSymbolHedgeOrderCount[symbolIndex]++;
     
   //group profit
   this.sumProfit+=order.getProfit();
   this.sumHedgeProfit+=order.getProfit();
   this.curSymbolProfit[symbolIndex]+=order.getProfit();
   this.curSymbolHedgeProfit[symbolIndex]+=order.getProfit(); 
   
   //group lot
   this.sumLots+=order.getLot();
   this.hedgeSumLots+=order.getLot();
   this.curSymbolLots[symbolIndex]+=order.getLot();
   this.curSymbolHedgeLots[symbolIndex]+=order.getLot();

   //delay orders
   int passedHours=(TimeCurrent()-order.getStartTime())/3600;   
   if(passedHours>Log_Show_Orders_Passed_Hours){
      this.delayOrderCount++;
   } 
   
   //model count
   if(!this.curSymbolModelList.Contains(order.getModelId())){
      curModelCount++;
      if(order.getOrderType()==ORDER_TYPE_BUY){
         this.curSymbolBuyModelCount[symbolIndex]++;
      }else{
         this.curSymbolSellModelCount[symbolIndex]++;
      }
      this.curSymbolModelList.Add(order.getModelId());
   }
}

//+------------------------------------------------------------------+
//|  use to test -- get group info
//+------------------------------------------------------------------+
string   CHedgeGroupInfo::getGroupInfo(){

   string temp="  ";   
   //sum info
   temp +=" <hRate>:" + StringFormat("%.2f",this.hedgeRate);
   temp +=" <order>:" + this.protectOrderCount + "|" + this.hedgeOrderCount;
   temp +=" <delay>:" + this.delayOrderCount ;
   temp +=" <profit>:" + StringFormat("%.2f",this.sumProtectProfit) + "|" 
                       + StringFormat("%.2f", this.sumHedgeProfit);
   temp +=" <lot>:" + StringFormat("%.2f",this.protectSumLots) + "|" 
                    + StringFormat("%.2f",this.hedgeSumLots);
   
   //every symbol info
   temp += this.getGroupSymbolInfo();
   
   return temp;
}


//+------------------------------------------------------------------+
//|  use to test -- get group symbol info (order count. profit .lot)
//+------------------------------------------------------------------+
string   CHedgeGroupInfo::getGroupSymbolInfo(){

   string tempProtect="<pSymbol>",temHedge="<hSymbol>";   
   for(int i=0;i<SYMBOL_MAX_COUNT;i++){
      if(this.curSymbolprotectOrderCount[i]>0){
         tempProtect +=  "|" + SYMBOL_LIST[i] + "|" + this.curSymbolprotectOrderCount[i] 
                  + "|" + StringFormat("%.2f",this.curSymbolProtectLots[i]) 
                  + "|" + StringFormat("%.2f",this.curSymbolProtectProfit[i]);         
      }      
      if(this.curSymbolHedgeOrderCount[i]>0){
         temHedge += "|" +  SYMBOL_LIST[i] + "|" + this.curSymbolHedgeOrderCount[i] 
                  + "|" + StringFormat("%.2f",this.curSymbolHedgeLots[i]) 
                  + "|" + StringFormat("%.2f",this.curSymbolHedgeProfit[i]);
      }
   }
   
   return tempProtect + " " + temHedge;
}

//+------------------------------------------------------------------+
//|  get group detail info
//+------------------------------------------------------------------+     
double   CHedgeGroupInfo::getHedgeRate(){
   return this.hedgeRate;
}

double   CHedgeGroupInfo::getSumLots(){
   return this.sumLots;
}

double   CHedgeGroupInfo::getSumProtectLots(){
   return this.protectSumLots;
}

double   CHedgeGroupInfo::getSumHedgeLots(){
   return this.hedgeSumLots;
}

double   CHedgeGroupInfo::getSumProfit(){
   return this.sumProfit;
}

double   CHedgeGroupInfo::getSumProtectProfit(){
   return this.sumProtectProfit;
}
double   CHedgeGroupInfo::getSumHedgeProfit(){
   return this.sumHedgeProfit;
}

int      CHedgeGroupInfo::getProtectOrderCount(){
   return this.protectOrderCount;
}
int      CHedgeGroupInfo::getHedgeOrderCount(){
   return this.hedgeOrderCount;
}

int      CHedgeGroupInfo::getModelCount(){
   return this.curModelCount;
}

int      CHedgeGroupInfo::getSymbolModelTypeCount(int symbolIndex,ENUM_ORDER_TYPE orderType){
   if(orderType==ORDER_TYPE_BUY){
      return this.curSymbolBuyModelCount[symbolIndex];
   }
   return this.curSymbolSellModelCount[symbolIndex];
}