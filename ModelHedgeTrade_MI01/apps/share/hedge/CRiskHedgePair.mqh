//+------------------------------------------------------------------+
//|                                            CRiskHedgePair.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>

#include "..\..\header\database\CHeader.mqh"
#include "..\..\header\hedge\risk\CHeader.mqh"
#include "..\..\header\hedge\output\CHeader.mqh"
#include "..\client\db\CDatabaseInfo.mqh"
#include "..\market\data\CMarketInfo.mqh"
#include "..\model\order\COrder.mqh"
#include "data\CHedgePair.mqh"

class CRiskHedgePair
  {
   private:
        CMarketInfo*                  marketInfo;
        CDatabaseInfo*                dbInfo;
        CArrayList<COrder*>*          orderList; 
        CArrayList<COrder*>           riskOrderList; 
        CArrayList<ulong>             riskOrderKeyList; 
        //CArrayList<CHedgePair*>       hedgePairList;
        CHashMap<ulong,CHedgePair*>   hedgePairSet;
        CArrayList<ulong>             hedgePairIds;       //keys--orderIndex 
        
        //out put model parameter
        int                           modelKind;
        
        //risk order level
        bool                          reloadRiskFlg;
        bool                          riskControlBegin;
        double                        beginRiskControlSumProfit;
        double                        addRiskOrderProfit;
        double                        removeRiskOrderProfit;                       
   public:
                            CRiskHedgePair();
                            ~CRiskHedgePair();
         //--- methods of initilize
         void               init(CArrayList<COrder*>* orderList,
                                    CMarketInfo* marketInfo,
                                    CDatabaseInfo* dbInfo);
         //--- set model kind
         void               setModelKind(int modelKind);
         //--- run hedge control
         void               refresh();
         //--- make risk orders
         void               makeRiskOrders();
         
         //--- output Risk orders
         void               makeHedgePairs();
         
         //add risk order
         void               addHedgePair(COrder *order);
         //get hedge pair count(out put)
         int                hedgePairCount();
         //judge if contains Hedge Pair
         bool               containsHedgePair(ulong key);         
         //get risk order
         CHedgePair*        getHedgePair(ulong key);
         //remove hedge pair
         void               removeHedgePair(CHedgePair *hedgePair);   
         //clean hedge pair
         void               cleanHedgePairs();         
         //get hedge Pair Set 
         CHashMap<ulong,CHedgePair*>* getHedgePairSet(){return &this.hedgePairSet;};
         //get hedge Pair id list 
         CArrayList<ulong>* getHedgePairIds(){return &this.hedgePairIds;};
         //reload risk orders
         void               reloadRiskOrders();
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CRiskHedgePair::init(CArrayList<COrder*>* orderList,
                              CMarketInfo* marketInfo,
                              CDatabaseInfo* dbInfo)
{
   this.modelKind=modelKind;
   this.orderList=orderList;
   this.marketInfo=marketInfo;
   this.dbInfo=dbInfo;
   this.reloadRiskFlg=false;
   this.riskControlBegin=false;
   this.beginRiskControlSumProfit=RISK_BEGIN_CONTROL_SUM_PROFIT;
   this.addRiskOrderProfit=RISK_ADD_ORDER_PROFIT;
   this.removeRiskOrderProfit=RISK_REMOVE_ORDER_PROFIT;   
}

//+------------------------------------------------------------------+
//|  set model Kind
//+------------------------------------------------------------------+
void CRiskHedgePair::setModelKind(int modelKind)
{
   this.modelKind=modelKind;
}


//+------------------------------------------------------------------+
//|  refresh risk hedge pairs
//+------------------------------------------------------------------+
void CRiskHedgePair::refresh(){

   //1.make risk orders
   this.makeRiskOrders();
   
   //2.make hedge pairs
   this.makeHedgePairs();

   //3.clean hedge pairs
   this.cleanHedgePairs();
   
}

//+------------------------------------------------------------------+
//| reload risk orders
//+------------------------------------------------------------------+
void CRiskHedgePair::reloadRiskOrders(){
   if(DB_DATA_RESET)return;   
   if(this.reloadRiskFlg)return;
   //reload risk order from db
   for (int i = 0; i < this.orderList.Count(); i++) {
      COrder *order;
      this.riskOrderList.TryGetValue(i,order);      
      if(this.hedgePairIds.Contains(order.getMagic())){
         this.riskOrderList.Add(order);
         this.riskOrderKeyList.Add(order.getMagic());      
      }   
   }
   this.reloadRiskFlg=true;
}

//+------------------------------------------------------------------+
//|  out put risk orders
//+------------------------------------------------------------------+
void CRiskHedgePair::makeRiskOrders(){
   
   //reload risk orders
   this.reloadRiskOrders();
   
   //judge if risk control
   if(!this.riskControlBegin){
      if(this.marketInfo.getSumProfit()<this.beginRiskControlSumProfit){
         this.riskControlBegin=true;
      }   
   }
   
   //begin risk control
   if(!this.riskControlBegin)return;   
   
   //remove closed orders and unlocked order
   for (int i = this.riskOrderList.Count()-1; i >=0 ; i--) {         
      COrder *order;
      this.riskOrderList.TryGetValue(i,order);      
      //remove closed orders
      if(CheckPointer(order)==POINTER_INVALID){
         this.riskOrderList.RemoveAt(i);
         continue;
      }
      //remove unlocked order
      else if(order.getHedgeLock()){
         this.riskOrderList.Remove(order);
         this.riskOrderKeyList.Remove(order.getMagic());
      }
   }   
   for (int i = this.riskOrderKeyList.Count()-1; i >=0 ; i--) {         
      ulong key;
      this.riskOrderKeyList.TryGetValue(i,key);
      if(!this.marketInfo.containsOrderKey(key)){
         this.riskOrderKeyList.RemoveAt(i);
      }
   }
   
   //add and remove risk order
   for (int i = 0; i < this.orderList.Count(); i++) {
      COrder *order;
      this.orderList.TryGetValue(i,order); 
      
      //check order pointer
      if(CheckPointer(order)==POINTER_INVALID)continue;
      
      //remove risk clear order
      if(this.riskOrderKeyList.Contains(order.getMagic())){
         if(order.getProfit()>this.removeRiskOrderProfit){
            this.riskOrderList.Remove(order);
            this.riskOrderKeyList.Remove(order.getMagic());                        
         }      
      }
      //add risk order
      else{
         if(order.getTradeStatus()==TRADE_STATUS_TRADE 
            || order.getTradeStatus()==TRADE_STATUS_CLOSE_READY){         
            if(!order.getHedgeLock()
               && order.getProfit()<this.addRiskOrderProfit){                        
               this.riskOrderList.Add(order);
               this.riskOrderKeyList.Add(order.getMagic());            
            }
         }
      }     
   }
}
//+------------------------------------------------------------------+
//|  out put risk orders
//+------------------------------------------------------------------+
void CRiskHedgePair::makeHedgePairs(){
   
   for (int i = 0; i < this.orderList.Count(); i++) {
      COrder *order;
      this.riskOrderList.TryGetValue(i,order); 
      if(CheckPointer(order)==POINTER_INVALID)continue;
      
      //add new hedge pair
      if(!this.containsHedgePair(order.getMagic())){
         this.addHedgePair(order);      
      }         
   }
}


//+------------------------------------------------------------------+
//|  clean hedage pairs
//+------------------------------------------------------------------+
void CRiskHedgePair::cleanHedgePairs(){

   for (int i = this.hedgePairIds.Count()-1; i >=0 ; i--) {         
      ulong key;
      this.hedgePairIds.TryGetValue(i,key);
      CHedgePair *hedgePair;
      if(this.hedgePairSet.TryGetValue(key,hedgePair)){
         if(CheckPointer(hedgePair)==POINTER_INVALID)continue; 
         
         //clear by risk order list 
         if(!this.riskOrderKeyList.Contains(hedgePair.getMainOrderId())){
            //clear hedge pair when not lock
            //if(hedgePair.getHedgeOrderStatus()!=HEDGE_ORDER_LOCK){
               hedgePair.setMainOrderStatus(MAIN_ORDER_CLEAR);
            //}
         }
           
         if(hedgePair.getMainOrderStatus()==MAIN_ORDER_CLEAR
            && hedgePair.getHedgeOrderStatus()==HEDGE_ORDER_NONE){
            //if(!dbInfo.containsRiskDbKey(key)){
               this.removeHedgePair(hedgePair);
            //}
         }
      }
   }
}

//+------------------------------------------------------------------+
//|  add hedge pair
//+------------------------------------------------------------------+
void CRiskHedgePair::addHedgePair(COrder *order){

   //重複防止
   if(this.hedgePairIds.Contains(order.getMagic()))return;

   this.hedgePairIds.Add(order.getMagic());
   
    // add new hedge order Pair            
   CHedgePair* hedgePair=new CHedgePair();
   hedgePair.setMainOrderId(order.getMagic());
   hedgePair.setMainOrderStatus(MAIN_ORDER_RISK);
   hedgePair.setHedgeOrderStatus(HEDGE_ORDER_NONE);
   //this.hedgePairList.Add(hedgePair);  
   
   this.hedgePairSet.Add(order.getMagic(),hedgePair);
}

//+------------------------------------------------------------------+
//|  remove hedge pair
//+------------------------------------------------------------------+
void CRiskHedgePair::removeHedgePair(CHedgePair *hedgePair){   
   this.hedgePairIds.Remove(hedgePair.getMainOrderId());
   if(this.hedgePairSet.Remove(hedgePair.getMainOrderId())){
      delete hedgePair;
      hedgePair=NULL;
   }   
   if(this.hedgePairIds.Count()==0){
      this.hedgePairSet.Clear();   
      this.hedgePairIds.Clear();
   }
}

//+------------------------------------------------------------------+
//|  get order count
//+------------------------------------------------------------------+
int CRiskHedgePair::hedgePairCount(){
   return this.hedgePairIds.Count();
}

//+------------------------------------------------------------------+
//|  judge if contains Hedge Pair
//+------------------------------------------------------------------+
bool   CRiskHedgePair::containsHedgePair(ulong key){
   return this.hedgePairIds.Contains(key);
}


//+------------------------------------------------------------------+
//|  get risk hedge pair by key
//+------------------------------------------------------------------+
CHedgePair* CRiskHedgePair::getHedgePair(ulong key){
   CHedgePair *hedgePair;
   if(this.hedgePairSet.TryGetValue(key,hedgePair)){
      return hedgePair;
   }
   return NULL;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CRiskHedgePair::CRiskHedgePair(){}
CRiskHedgePair::~CRiskHedgePair(){}