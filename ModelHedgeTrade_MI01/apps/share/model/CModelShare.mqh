//+------------------------------------------------------------------+
//|                                                  CModelShare.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

//common define
#include "..\..\header\CDefine.mqh"
#include "..\..\header\model\CHeader.mqh"
#include "..\..\comm\ComFunc.mqh"
#include "..\..\comm\CLog.mqh"

//include class
#include "..\..\model\CModelI.mqh"
#include "order\COrder.mqh"
#include "order\COrderSet.mqh"

// share object
#include "..\symbol\CSymbolShare.mqh"
#include "..\market\CMarketShare.mqh"
#include "analysis\CModelAnalysis.mqh"
#include "analysis\CModelAnalysisPre.mqh"
#include "..\analysis\CAnalysisShare.mqh"

class CModelShare
  {
   private:
      
      //orders map/list
      CHashMap<ulong,COrder*>       orderMap;      
      CArrayList<COrder*>           orders;
      
      //models map/list
      CArrayList<ulong>             modelIdList;
      CArrayList<CModelI*>          modelList;
      CHashMap<ulong,CModelI*>      modelMap; 
      
      //share objects
      CModelAnalysis                modelAnalysis; 
      CModelAnalysisPre             modelAnalysisPre; 
      CAnalysisShare*               analysisShare;     
      CSymbolShare*                 symbolShare;
      CMarketShare*                 marketShare;
            
      //ticket list
      //CArrayList<ulong>             marketTicketList;
      
   public:
                     CModelShare();
                    ~CModelShare();
      
      //--- methods of initilize
      void            init(CSymbolShare* symbolShare,
                           CAnalysisShare* analysisShare,
                           CMarketShare*   marketShare); 
      //--- refresh
      void            refresh(); 
      //--- run CModelShare
      void            run();
      //--- get order list
      CArrayList<COrder*>*     getOrders();
      //--- get model list
      CArrayList<CModelI*>*  getModels();
      //--- add model
      void            addModel(CModelI* model);
      //--- get model (modelId)
      CModelI*        getModel(ulong modelId);
      //---remove model
      void            removeModel(CModelI* model); 
      //--- judge if exist model
      bool            containsModel(ulong modelId);
      //--- create order
      void            addOrder(COrder* order); 
      //--- get order by magic id
      COrder*         getOrder(ulong magicId);
      //---remove order
      void            removeOrder(COrder* order); 
      //--- add order
      void            loadOrder(COrder* order);
     
      //+------------------------------------------------------------------+
      //|  comm function
      //+------------------------------------------------------------------+      
      void           makeInfoByMagic(COrder *order); 
      
      //+------------------------------------------------------------------+
      //|  market ticket list record and check
      //+------------------------------------------------------------------+ 
      //void          addMarketTicket(ulong ticket);    
      //void          clearMarketTicket();
      bool          checkMarketTicket(ulong ticket);  
      
      //+------------------------------------------------------------------+
      //|  get market Analysis
      //+------------------------------------------------------------------+ 
      CModelAnalysis*    getModelAnalysis();
      CModelAnalysisPre* getModelAnalysisPre();
      
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CModelShare::init(CSymbolShare* symbolShare,
                        CAnalysisShare* analysisShare,
                        CMarketShare* marketShare){
   this.symbolShare=symbolShare;
   this.analysisShare=analysisShare;
   this.marketShare=marketShare;
   int total_symbols = ArraySize(SYMBOL_LIST);   
}   
      
//+------------------------------------------------------------------+
//|  run the share control
//+------------------------------------------------------------------+
void CModelShare::run(){}   

//+------------------------------------------------------------------+
//|  get order list
//+------------------------------------------------------------------+  
CArrayList<COrder*>*   CModelShare::getOrders(){
   return &this.orders;
}

//+------------------------------------------------------------------+
//|  get model list
//+------------------------------------------------------------------+  
CArrayList<CModelI*>*   CModelShare::getModels(void){
   return &this.modelList;
}

//+------------------------------------------------------------------+
//|  get order set
//+------------------------------------------------------------------+  
CModelI* CModelShare::getModel(ulong modelId){   
   CModelI *model;
   if(this.modelMap.TryGetValue(modelId,model)){
      return model;      
   }
   return NULL;
}

//+------------------------------------------------------------------+
//|  judge if exist the model by id
//+------------------------------------------------------------------+  
bool CModelShare::containsModel(ulong modelId){   
   return this.modelMap.ContainsKey(modelId);
}

//+------------------------------------------------------------------+
//|  get order by magic id
//+------------------------------------------------------------------+  
COrder* CModelShare::getOrder(ulong magicId){
   COrder *order;   
   if(this.orderMap.TryGetValue(magicId,order)){
      return order;      
   }
   return NULL;
}

//+------------------------------------------------------------------+
//|  add model to model list
//+------------------------------------------------------------------+  
void CModelShare::addModel(CModelI* model){     
   if(this.modelMap.ContainsKey(model.getModelId()))return;
   this.modelMap.Add(model.getModelId(),model);
   this.modelList.Add(model);
   this.modelIdList.Add(model.getModelId()); 
   //rkeeLog.writeLog("CModelShare::addModel---modelId:" + model.getModelId() + " count:" + this.modelList.Count());  
}
//+------------------------------------------------------------------+
//|  create order
//+------------------------------------------------------------------+
void CModelShare::addOrder(COrder *order){
   
   //add order to (orderMap,orderList)
   if(!this.orderMap.ContainsKey(order.getMagic())){
      this.orderMap.Add(order.getMagic(),order);
      this.orders.Add(order);
   }
}

//+------------------------------------------------------------------+
//|  load order from market
//+------------------------------------------------------------------+
void CModelShare::loadOrder(COrder *order){
   
   //create order   
   this.makeInfoByMagic(order);           
   //add order to (orderMap,orderList)
   this.addOrder(order);
}

//+------------------------------------------------------------------+
//|  clear order share when order not use
//+------------------------------------------------------------------+
void   CModelShare::removeOrder(COrder* order){   
   orderMap.Remove(0);
   orderMap.Remove(order.getMagic());   
   if(this.orders.Remove(order)){
      delete order;
      order=NULL;
   }
}

//+------------------------------------------------------------------+
//|  clear Model share when model not use
//+------------------------------------------------------------------+
void   CModelShare::removeModel(CModelI* model){      
   this.modelMap.Remove(0);
   this.modelMap.Remove(model.getModelId()); 
   this.modelIdList.Remove(0);
   this.modelIdList.Remove(model.getModelId());
   if(this.modelList.Remove(model)){
      delete model;
      model=NULL;
   }
}

//make order info by comment
void CModelShare::makeInfoByMagic(COrder *order){
    order.setModelKind(comFunc.getModelKind(order.getMagic()));
    order.setModelId(comFunc.getModelId(order.getMagic()));
    order.setOrderIndex(comFunc.getOrderIndex(order.getMagic()));
}

//+------------------------------------------------------------------+
//|  comm function
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  market ticket list record and check
//+------------------------------------------------------------------+ 
bool    CModelShare::checkMarketTicket(ulong ticket){
   return this.marketShare.getMarketInfo().checkMarketTicket(ticket);
}

//+------------------------------------------------------------------+
//|  refresh the new market info to the order share info
//+------------------------------------------------------------------+ 
void    CModelShare::refresh(){
   
   int modelCount=this.modelList.Count();
   //clean model list
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;
      if(this.modelList.TryGetValue(i,model)){
         if(CheckPointer(model)==POINTER_INVALID)continue;         
         if(model.getModelStatus()==MODEL_STATUS_CLOSE){
            this.removeModel(model);
         }else if(model.getModelStatus()==MODEL_STATUS_OPEN){
            if(model.getOrderCount()==0){
               this.removeModel(model);
            }
         }         
      }
   }
   
   //clean ordersList and orderMap
   for (int i = this.orders.Count()-1; i >=0 ; i--) {
      COrder *order;      
      if(this.orders.TryGetValue(i,order)){                  
         if(CheckPointer(order)==POINTER_INVALID){
            //orders.Remove(order);
            continue;
         }   
         if(order.getTradeStatus()==TRADE_STATUS_CLEAR){            
            if(order.getErrorCode()>0){
               rkeeLog.printOrderError(order," order removed(error)>");
            }
            this.removeOrder(order);            
         }
         else if(order.getTradeStatus()==TRADE_STATUS_ERROR_CLOSE){
            if(!this.checkMarketTicket(order.getTicket())){
               this.removeOrder(order);
               rkeeLog.printOrderError(order, " clear error order(close/notExist)>" );
            }
         }
         else if(order.getTradeStatus()==TRADE_STATUS_TRADE){
            if(!this.checkMarketTicket(order.getTicket())){
               order.setTradeStatus(TRADE_STATUS_CLOSE);
               rkeeLog.printOrderError(order, " clear closed order(close by other app or manual)>" );
            }
         }
      }
   }
   
   //* delete 20250913
   int total_symbols = ArraySize(SYMBOL_LIST);   
   // Output weights for each symbol      
   for (int i = 0; i < total_symbols; i++){
      if(this.symbolShare.runable(i)){
         this.getModelAnalysis().setStatusIndex(this.analysisShare.getCurRange().getStatusIndex());        
         this.getModelAnalysis().makeAnalysisData(i,&this.modelList); 
         this.getModelAnalysis().makeCostEdgeData(i,&this.modelList,this.modelAnalysis.getModelCostLine());
         
         this.getModelAnalysisPre().setStatusIndex(this.analysisShare.getCurRange().getStatusIndex());        
         this.getModelAnalysisPre().makeAnalysisData(i,&this.modelList);          
         
      }   
   }   
}

//+------------------------------------------------------------------+
//|  get market Analysis
//+------------------------------------------------------------------+
CModelAnalysis* CModelShare::getModelAnalysis(){
   return &this.modelAnalysis;
}

//+------------------------------------------------------------------+
//|  get market Analysis(privois status)
//+------------------------------------------------------------------+
CModelAnalysisPre* CModelShare::getModelAnalysisPre(){
   return &this.modelAnalysisPre;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelShare::CModelShare(){}
CModelShare::~CModelShare(){
   //delete model list
   for (int i = 0; i < this.modelIdList.Count(); i++) {
      ulong modelId;
      this.modelIdList.TryGetValue(i,modelId);
      CModelI* model;
      this.modelMap.TryGetValue(modelId,model);
      delete model;
   } 
   //delete order list
   for (int i = 0; i < this.orders.Count(); i++) {
      COrder* order;
      this.orders.TryGetValue(i,order);      
      delete order;
   }
}