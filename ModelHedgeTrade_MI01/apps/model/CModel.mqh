//+------------------------------------------------------------------+
//|                                                     CModel01.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../header/model/CHeader.mqh"
#include "../share/CShareCtl.mqh"
#include "CModelI.mqh"

class CModel: public CModelI 
{
      private:
         //base parameter
         string           symbol;  
         int              symbolIndex;          
         int              modelKind;
         ulong            modelId;
         int              modelStatus;
         ENUM_ORDER_TYPE  tradeType;
         //int              orderStatus;
         //CArrayList<int>  orderErrors;
         
         //order control parameter
         CShareCtl         *shareCtl; 
         COrderSet         orderSet;
         CHedgeGroup*      hedgeGroup;
         datetime          startTime;
         datetime          tradeTime;
         datetime          lastTradeTime;
         
         //log info
         string            actionFlg;
         //clear flag
         bool              clearFlg;
         //model status flag(range status/trend status)
         int               statusIndex;
         int               statusFlg;
         int               lastStatusIndex;
         int               lastStatusFlg;

         //int               statusSubFlg;
         //extend rate
         double            extendRate;
          
      public:
                     CModel();
                     ~CModel(); 
            //--- interface function
            void     init(CShareCtl *shareCtl,
                          CHedgeGroup* hedgeGroup,
                          int modelKind,
                          long modelId,
                          string symbol,
                          ENUM_ORDER_TYPE tradeType);
            void     reload(); //reload order from the market
            void     run();  //model run           
            void     refresh(); //refresh order status(time limit)
            void     clean(); //clean order set
            COrder*  createOrder();   //create order            
            void     addOrder(COrder* order);         //add order             
            void     removeOrder(COrder* order);       //remove order by order index
            CArrayList<int>*     getOrderKeys(); //get order status list
            bool     clearModel();     //clear model (risk protect)
            
            //+------------------------------------------------------------------+
            //|  get/set model param
            //+------------------------------------------------------------------+
            string   getSymbol();                //get model symbol
            int      getSymbolIndex();                //get model symbol index
            double   getSymbolPrice();           //get trade symbol price by trade type
            double   getSymbolPoint();           //get trade symbol point
            int      getModelKind();             //get model kind
            ulong    getModelId();               //get model id  
            int      getModelStatus();           //get model status              
            ulong    getSignalId();               //get signal id                
            ENUM_ORDER_TYPE      getTradeType();             //get trade type
            int      getOrderStatus();           //get order status(order index.. 0..1..2..X)
            int      getOrderCount();            //get order count
            int      getOrderIndex();            //get order index
            COrder*  getOrder(int index);         //get order by order index
            double   getOrderProfitPips(COrder* order);         //get order profit by pips
            void     setSymbol(string value);            //set model symbol
            void     setSymbolIndex(int symbolIndex);                //set model symbol index
            void     setModel(int modelKind,CSignal* signal);            //set model base info            
            void     setModelKind(int value);            //set model kind            
            void     setModelId(ulong value);              //set model id             
            void     setModelStatus(int value);           //set model status
            CSymbolShare* getSymbolShare();               //get symbol share 
            void     setTradeType(ENUM_ORDER_TYPE value);  //set trade type
            void     setOrderStatus(int value);            //set order status(order index.. 0..1..2..X)
            COrderSet*     getOrderSet();                  //get orderSet
            CHedgeGroup*   getHedgeGroup();                //get hedge group
            int      closeOrders();                        //close orders
            void     makeComment(COrder *order);
            
            // Getter and Setter for action flag
            string   getActionFlg();
            void     setActionFlg(string value);
            // mark the clear flag of all the orders
            int      markClearFlag(bool value); 
            // get model clear flag
            bool     getClearFlag();
            // get trade time(last order)
            datetime  getTradeTime();
            void      setTradeTime(datetime value){this.tradeTime=value;}
            datetime  getStartTime(){return this.startTime;}
            void      setStartTime(datetime value){this.startTime=value;}
            
            // get status index
            int  getStatusIndex(){return this.statusIndex;}
            void setStatusIndex(int value){this.statusIndex=value;}  
            int  getLastStatusIndex(){return this.lastStatusIndex;}
            void setLastStatusIndex(int value){this.lastStatusIndex=value;}                       
            // get status flag
            int  getStatusFlg(){return this.statusFlg;}
            void setStatusFlg(int value){this.statusFlg=value;}
            int  getLastStatusFlg(){return this.lastStatusFlg;}
            void setLastStatusFlg(int value){this.lastStatusFlg=value;}
            // get status flag
            //int  getStatusSubFlg(){return this.statusSubFlg;}
            //void setStatusSubFlg(int value){this.statusSubFlg=value;}  
            // get/set extend rate
            void    setExtendRate(double value){this.extendRate=value;}
            double  getExtendRate(){return this.extendRate;}
            CShareCtl* getShareCtl(){return this.shareCtl;};
};
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CModel::init(CShareCtl *shareCtl,
                        CHedgeGroup* hedgeGroup,
                        int modelKind,
                        long modelId,
                        string symbol,
                        ENUM_ORDER_TYPE tradeType)
{
   this.shareCtl=shareCtl;
   this.hedgeGroup=hedgeGroup;
   this.setModelKind(modelKind);
   this.setSymbol(symbol);
   this.setSymbolIndex(this.shareCtl.getSymbolShare().getSymbolIndex(symbol));
   this.setTradeType(tradeType);
   this.setModelId(modelId);  
   
   this.orderSet.setModelKind(this.modelKind);
   this.orderSet.setModelId(this.getModelId());
   this.orderSet.setSymbol(symbol);
   this.clearFlg=false;
   this.tradeTime=0;
   this.extendRate=1;
}


//+------------------------------------------------------------------+
//|  create order by model info
//+------------------------------------------------------------------+
COrder* CModel::createOrder(void)
{   
   
   //create order
   COrder *order=new COrder();
   order.setSymbol(this.getSymbol()); 
   order.setSymbolIndex(this.getSymbolIndex());  
   order.setTradeStatus(TRADE_STATUS_TRADE_PENDING);
   order.setModelKind(this.getModelKind());
   order.setModelId(this.getModelId());
   order.setOrderType(this.getTradeType());
   
   order.setOrderIndex(this.orderSet.count());  //order status
   ulong magicId=comFunc.createOrderId(order.getModelId(),order.getOrderIndex());
   order.setMagic(magicId);     
   //set symbol info
   order.setPoint(this.shareCtl.getSymbolShare().getSymbolInfos().getSymbolPoint(this.getSymbol()));   
   comFunc.makeComment(order);
   
   this.addOrder(order);
   this.shareCtl.getModelShare().addOrder(order);
   
   //refresh hedge data
   this.hedgeGroup.hedgeOrders(); 
   //test begin
   this.shareCtl.getHedgeShare().getHedgeGroupPool().hedgeOrders();
   //this.tradeTime=TimeCurrent();
   this.setTradeTime(TimeCurrent());
   
   return order;
}

//+------------------------------------------------------------------+
//|  add order to the orderSet
//+------------------------------------------------------------------+
void CModel::addOrder(COrder* order){
   this.orderSet.add(order);
}

//+------------------------------------------------------------------+
//|  remove order to the orderSet
//+------------------------------------------------------------------+
void CModel::removeOrder(COrder* order){
   this.orderSet.remove(order);
}

//+------------------------------------------------------------------+
//|  get order status list
//+------------------------------------------------------------------+
CArrayList<int>* CModel::getOrderKeys()
{   
   return this.orderSet.getKeys();
}

//+------------------------------------------------------------------+
//|  run model
//+------------------------------------------------------------------+  
void CModel::run(){
   this.refresh();
}

//+------------------------------------------------------------------+
//|  refresh model's orders status
//+------------------------------------------------------------------+  
void CModel::refresh(){
    this.markClearFlag(false);
    this.extendRate=1;
}


//+------------------------------------------------------------------+
//|  clean close order
//+------------------------------------------------------------------+
void CModel::clean(){   
     this.orderSet.clean();
}

//+------------------------------------------------------------------+
//|  clean close order
//+------------------------------------------------------------------+
int  CModel::getOrderCount(){
    return this.orderSet.count();
}

//+------------------------------------------------------------------+
//|  clean close order
//+------------------------------------------------------------------+
int  CModel::getOrderIndex(){
    int orderCount=this.getOrderCount();
    if(orderCount>0)return orderCount-1;
    return -1;
}

//+------------------------------------------------------------------+
//| get order by order index
//+------------------------------------------------------------------+
COrder*  CModel::getOrder(int index){
    return this.orderSet.getOrder(index);
}

//+------------------------------------------------------------------+
//|  get symbol share
//+------------------------------------------------------------------+
CSymbolShare* CModel::getSymbolShare(){
   return this.shareCtl.getSymbolShare();
}

//+------------------------------------------------------------------+
//|  get symbol price
//+------------------------------------------------------------------+
double  CModel::getSymbolPrice(){
   return this.getSymbolShare().getSymbolPrice(this.getSymbol(),this.getTradeType());
}

//+------------------------------------------------------------------+
//|  get symbol point
//+------------------------------------------------------------------+
double  CModel::getSymbolPoint(){
   return this.shareCtl.getSymbolShare().getSymbolInfos().getSymbolPoint(this.getSymbol());      
}

//+------------------------------------------------------------------+
//|  get order profit pips
//+------------------------------------------------------------------+
double  CModel::getOrderProfitPips(COrder* order){
   double curSymbolPrice=this.getSymbolPrice();
   double point=this.getSymbolPoint();
   double profitPips=(curSymbolPrice-order.getOpenPrice())/point;
   if(order.getOrderType()==ORDER_TYPE_SELL){
      profitPips=-profitPips;
   }
   return profitPips;
}

//+------------------------------------------------------------------+
//|  get hedge group
//+------------------------------------------------------------------+
CHedgeGroup*  CModel::getHedgeGroup(){
   return this.hedgeGroup;
}

//+------------------------------------------------------------------+
//|  close orders
//+------------------------------------------------------------------+
int  CModel::closeOrders(){   
   int closeCount=0;
   for (int i = 0; i < this.getOrderKeys().Count(); i++) {       
      int orderKey;
      this.getOrderKeys().TryGetValue(i,orderKey);         
      COrder *order=this.orderSet.getOrder(orderKey);
      if(CheckPointer(order)==POINTER_INVALID)continue;
      if(order.getTradeStatus()==TRADE_STATUS_TRADE){           
         order.setTradeStatus(TRADE_STATUS_CLOSE_READY);
         order.setActionFlg(this.getActionFlg());
         closeCount++;
      }
   } 
   return closeCount;
}

//+------------------------------------------------------------------+
//|  set model orders clear flag
//+------------------------------------------------------------------+
int  CModel::markClearFlag(bool value){
   int orderCount=this.getOrderKeys().Count();
   for (int i = 0; i < orderCount; i++) {       
      int orderKey;
      this.getOrderKeys().TryGetValue(i,orderKey);         
      COrder *order=this.orderSet.getOrder(orderKey);
      if(CheckPointer(order)==POINTER_INVALID)continue;
      order.setClearFlg(value);
   }
   if(orderCount>0)this.clearFlg=value; 
   return orderCount;
}

//+------------------------------------------------------------------+
//|  get model clear flag
//+------------------------------------------------------------------+
bool  CModel::getClearFlag(){
   return  this.clearFlg;
}

//+------------------------------------------------------------------+
//|  clear model(risk protect)
//+------------------------------------------------------------------+    
bool  CModel::clearModel(){
   this.setActionFlg("clearModel");
   if(this.closeOrders()>0)return true;
   return false;
}

//+------------------------------------------------------------------+
//| Getter and Setter for action flag
//+------------------------------------------------------------------+
string  CModel::getActionFlg(){return actionFlg;}
void  CModel::setActionFlg(string value) { actionFlg = value; }

//+------------------------------------------------------------------+
//|  getter/setter
//+------------------------------------------------------------------+    
string CModel::getSymbol(){return this.symbol;}    
int    CModel::getSymbolIndex(){return this.symbolIndex;}    
int    CModel::getModelKind(void){return this.modelKind;}    
ulong  CModel::getModelId(void){return this.modelId;}
int    CModel::getModelStatus(void){return this.modelStatus;}     
ENUM_ORDER_TYPE CModel::getTradeType(void){return this.tradeType;} 
// get trade time(last order)
datetime  CModel::getTradeTime(){return this.tradeTime;} 
   

void CModel::setSymbol(string value){this.symbol=value;} 
void CModel::setSymbolIndex(int value){this.symbolIndex=value;} 
void CModel::setModelKind(int value){this.modelKind=value;}
void CModel::setModelId(ulong value){this.modelId=value;}
void CModel::setModelStatus(int value){this.modelStatus=value;}
void CModel::setTradeType(ENUM_ORDER_TYPE value){this.tradeType=value;}
COrderSet* CModel::getOrderSet(){return &this.orderSet;}
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModel::CModel(){}
CModel::~CModel(){}