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
#include "..\..\comm\CLog.mqh"
#include "..\..\header\hedge\CHeader.mqh"
#include "..\..\header\symbol\CHeader.mqh"
#include "..\..\share\model\order\COrder.mqh"
#include "..\..\share\symbol\CSymbolCorrelation.mqh"
#include "..\..\share\hedge\CProtectGroupInfo.mqh"
#include "..\..\share\loginfo\CLogData.mqh"

class CProtectGroup
  {
   private:
         CSymbolCorrelation*                 symbolCorrelation;
         CProtectGroupInfo                   protectGroupInfo;
         int                                 hedgeCorrelationType;
         CArrayList<int>                     protectModelKinds;        //protect model
         CArrayList<int>                     hedgeModelKinds;          //hedge model
         CArrayList<COrder*>                 groupOrders;
         //key(modelKind)
         //CHashMap<int,double>                modelKindStartLot;         
         bool                                curSymbolsProtectModel[SYMBOL_MAX_COUNT];
         int                                 curSymbolsType[SYMBOL_MAX_COUNT];
         double                              curSymbolLots[SYMBOL_MAX_COUNT];
         double                              curSymbolHedgeLots[SYMBOL_MAX_COUNT];
         double                              minCorrelationRate;
         double                              riskLotRate;
         double                              riskHedgeLotRate;
         double                              sumLots;
         double                              riskHedgeSumLots;
         double                              riskSumLots;
         bool                                useSymbolLotRate;                   
   public:         
   
                        CProtectGroup();
                       ~CProtectGroup();             
                       
         //--- methods of initilize
         void            setSymbolCorrelation(CSymbolCorrelation* symbolCorrelation); 
         //--- set min correlation rate
         void            setMinCorrelationRate(double value); 
         //--- set hedge correlation type
         void            setHedgeCorrelationType(int value);         
         //--- set symbol free/no hedge lot
         void            setSymbolFreeLots(double value);
         //--- set use symbol lot rate
         void            setUseSymbolLotRate(bool value); 
         //--- add model kind
         void            addProtectModelKind(int modelKind);                 
         //--- add model kind
         void            addHedgeModelKind(int modelKind); 
         //--- set model kind start lot
         void            setStartLot(int modelKind,double value); 
         //--- get model kind start lot
         double          getStartLot(int modelKind);
         //--- hedge init
         void            HedgeInit();
         //--- put hedge init data
         void            putHedgeInitData(COrder* order);
         //--- hedge orders
         void            hedgeOrders();
         //--- get hedge symbol lot
         double          getHedgeSymbolLots(int symbolIndex);
         //--- get symbol lot
         double          getSymbolLots(int symbolIndex);
         //--- get risk hedge sum lot
         double          getRiskHedgeSumLots();
         //--- get risk sum lot
         double          getRiskSumLots();         
         //--- get sum lot
         double          getSumLots();
         //--- get ext risk sum lot
         double          getExtRiskSumLots();         
         //--- get ext sum lot
         double          getExtSumLots();         
         //--- get sum symbol rate lot
         double          getSumSymbolRateLots();
         //--- get risk hedge lot rate
         double          getRiskHedgeLotRate();
         //--- get risk lot rate
         double          getRiskLotRate();
         //--- get risk order count
         int             getRiskOrderCount();
         //--- get ext risk order count
         int             getExtRiskOrderCount();
         //---get hedge protect group info
         CProtectGroupInfo* getProtectGroupInfo();
               
         //--- get enable hedge lot
         double          getEnableHedgeLot(int symbolIndex,ENUM_ORDER_TYPE type);
         //--- get enable hedge lot adjust
         double          getEnableHedgeLotAdjust(int symbolIndex,ENUM_ORDER_TYPE type);  
         //--- judge order have right symbol pair correlation
         bool            ifRiskProtect(int symbolIndex,ENUM_ORDER_TYPE type,double lot);
         
         //+------------------------------------------------------------------+
         //|  fuction about the managment of hedge orders
         //+------------------------------------------------------------------+        
         //--- refresh hedge orders
         void            refreshHedgeOrders(CArrayList<COrder*>* orderList);
         //--- clean hedge orders
         void            cleanHedgeOrders(CArrayList<COrder*>* orderList);
      
};

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CProtectGroup::setSymbolCorrelation(CSymbolCorrelation* symbolCorrelation)
{
   this.symbolCorrelation=symbolCorrelation;
}

//--- set min correlation rate define
void CProtectGroup::setMinCorrelationRate(double value){
   this.minCorrelationRate=value;
} 

//+------------------------------------------------------------------+
//|  set hedge correlation type
//+------------------------------------------------------------------+  
void   CProtectGroup::setHedgeCorrelationType(int value){
   this.hedgeCorrelationType=value;   
}

//+------------------------------------------------------------------+
//--- set use symbol lot rate
//+------------------------------------------------------------------+
void CProtectGroup::setUseSymbolLotRate(bool value){
   this.useSymbolLotRate=value;
}

//+------------------------------------------------------------------+
//|  add model kind
//+------------------------------------------------------------------+
void CProtectGroup::addProtectModelKind(int modelKind)
{
      if(this.protectModelKinds.Contains(modelKind))return;
      this.protectModelKinds.Add(modelKind);
}

//+------------------------------------------------------------------+
//|  get hedge group info
//+------------------------------------------------------------------+
CProtectGroupInfo* CProtectGroup::getProtectGroupInfo(void)
{
      return &this.protectGroupInfo;      
}


//+------------------------------------------------------------------+
//|  add hedge model kind
//+------------------------------------------------------------------+
void CProtectGroup::addHedgeModelKind(int modelKind)
{
      if(this.hedgeModelKinds.Contains(modelKind))return;
      this.hedgeModelKinds.Add(modelKind);
}      

//hedge data initialize
void CProtectGroup::HedgeInit(){
   ArrayInitialize(curSymbolsProtectModel,false);
   ArrayInitialize(curSymbolsType,0);
   ArrayInitialize(curSymbolLots,0.00);
   ArrayInitialize(curSymbolHedgeLots,0.00);
	//get risk rate
	this.riskLotRate=0;
	this.riskHedgeLotRate=0;
	this.riskHedgeSumLots=0;
	this.sumLots=0; 
   this.riskSumLots=0;
   
   //init hedge info
   this.protectGroupInfo.init();  
}

/**
 * putHedgeData
 * if have same symbol then hedge itself
 * @param symbol
 * @param type
 * @param lots
 */
void CProtectGroup::putHedgeInitData(COrder* order){
	
	int symbolIndex=order.getSymbolIndex();
	bool protectFlg=false;
	if(this.protectModelKinds.Contains(order.getModelKind()))protectFlg=true;
	this.protectGroupInfo.addRiskOrderInfo(symbolIndex,order,protectFlg);
	
	int preSymbolsType=curSymbolsType[symbolIndex];
	double orderHedgeLot=order.getProtectlot();    //modify to protect lot	
	if(this.useSymbolLotRate){
	   orderHedgeLot=orderHedgeLot*SYMBOL_RATE[symbolIndex];	   
	}
	this.riskSumLots+=orderHedgeLot;
	
	//if have same symbol then hedge itself
	if(curSymbolsType[symbolIndex]==ORDER_TYPE_BUY 
			|| curSymbolsType[symbolIndex]==ORDER_TYPE_SELL){
		if(order.getOrderType()==curSymbolsType[symbolIndex]){
			curSymbolHedgeLots[symbolIndex]+=orderHedgeLot;
		}else{
			if(orderHedgeLot<=curSymbolHedgeLots[symbolIndex])
				curSymbolHedgeLots[symbolIndex]-=orderHedgeLot;
			else if(orderHedgeLot>curSymbolHedgeLots[symbolIndex]){
				curSymbolHedgeLots[symbolIndex]=orderHedgeLot-curSymbolHedgeLots[symbolIndex];
				curSymbolsType[symbolIndex]=order.getOrderType();
			}				
		}			
	}else{
		curSymbolsType[symbolIndex]=order.getOrderType();
		curSymbolHedgeLots[symbolIndex]=orderHedgeLot;
	}
	curSymbolLots[symbolIndex]+=order.getLot();		
		
	//protect model order	
	if(curSymbolsProtectModel[symbolIndex]){
	   if(!protectFlg && preSymbolsType!=curSymbolsType[symbolIndex]){
	      curSymbolsProtectModel[symbolIndex]=false;
	   }	
	}
	else{
	   if(protectFlg && preSymbolsType!=curSymbolsType[symbolIndex]){
	      curSymbolsProtectModel[symbolIndex]=true;
	   }
	}
}

//+------------------------------------------------------------------+
//|  hedge the orders
//+------------------------------------------------------------------+
void CProtectGroup::hedgeOrders()
{
   //init hedge data
   this.HedgeInit();
   //check order pool size
   if(this.groupOrders.Count()==0)return;
   //Initialize the symbol lot array
   ArrayInitialize(curSymbolLots,0);
   ArrayInitialize(curSymbolHedgeLots,0);
   //make data before hedge
   for (int i = 0; i < this.groupOrders.Count(); i++) {
      COrder *order;
      if(this.groupOrders.TryGetValue(i,order)){
         if(CheckPointer(order)==POINTER_INVALID)continue;
         this.putHedgeInitData(order);      
      }   
   }   
   //create hedge data when strong hedge mode
   if(this.hedgeCorrelationType == HEDGE_CORRLELATION_INNER_STRONG
      || this.hedgeCorrelationType == HEDGE_CORRLELATION_OUTER_STRONG){       
           
   	for(int i=0;i<SYMBOL_MAX_COUNT;i++){
   		if(curSymbolHedgeLots[i]==0)continue;
   		for(int j=0;j<SYMBOL_MAX_COUNT;j++){
   			if(i==j)continue;
   			if(curSymbolHedgeLots[j]==0)continue;
   			double curCorrelationValue=this.symbolCorrelation.getSymbolCorrelation(i,j);
            
   			if((curCorrelationValue>=this.minCorrelationRate && curSymbolsType[i]!=curSymbolsType[j])
   					|| (curCorrelationValue<=-this.minCorrelationRate && curSymbolsType[i]==curSymbolsType[j])){				
   				if(curSymbolHedgeLots[i]>=curSymbolHedgeLots[j]){
   					curSymbolHedgeLots[i]-=curSymbolHedgeLots[j];
   					curSymbolHedgeLots[j]=0;
   				}else if(curSymbolHedgeLots[i]<curSymbolHedgeLots[j]){	
   					curSymbolHedgeLots[j]-=curSymbolHedgeLots[i];
   					curSymbolHedgeLots[i]=0;						
   				}   				
   			}
   		}
   	}
	}
	
	//get sum lot(hedge sum lot)	
	this.riskHedgeSumLots=-1;
	this.sumLots=-1;	
	this.sumLots=this.getSumLots();
	this.riskHedgeSumLots=this.getRiskHedgeSumLots();
	
	//get hedge rate
	this.riskLotRate=0;
	this.riskHedgeLotRate=0;
	if(this.sumLots>0){
	   if(this.useSymbolLotRate){
	      double sumSymbolRateLots=this.getSumSymbolRateLots();
	      this.riskHedgeLotRate=this.riskHedgeSumLots/sumSymbolRateLots;	
	      this.riskLotRate=this.riskSumLots/sumSymbolRateLots;
	   }else{
	      this.riskHedgeLotRate=this.riskHedgeSumLots/this.sumLots;
	      this.riskLotRate=this.riskSumLots/this.sumLots;
	   }
	}
	
	this.protectGroupInfo.riskHedgeSumLots=this.riskHedgeSumLots;
	this.protectGroupInfo.riskHedgeLotRate=this.riskHedgeLotRate;	
	this.protectGroupInfo.riskLotRate=this.riskLotRate;	
}

//+------------------------------------------------------------------+
//|  get Hedge Symbol Lots
//+------------------------------------------------------------------+
double  CProtectGroup::getHedgeSymbolLots(int symbolIndex){	
	return curSymbolHedgeLots[symbolIndex];
}

//+------------------------------------------------------------------+
//|  get Symbol Lots
//+------------------------------------------------------------------+ 
double CProtectGroup::getSymbolLots(int symbolIndex){
	return curSymbolLots[symbolIndex];
}	

//+------------------------------------------------------------------+
//|  get risk hedge sum lot
//+------------------------------------------------------------------+ 
double  CProtectGroup::getRiskHedgeSumLots(){	
	if(this.riskHedgeSumLots<0){	
	   this.riskHedgeSumLots=0;
	   for(int i=0;i<SYMBOL_MAX_COUNT;i++)
		   this.riskHedgeSumLots+=curSymbolHedgeLots[i];
		   
	}	
	return this.riskHedgeSumLots;
}

//+------------------------------------------------------------------+
//|  get risk sum lot
//+------------------------------------------------------------------+ 
double  CProtectGroup::getRiskSumLots(){	
	return this.riskSumLots;
}

//+------------------------------------------------------------------+
//|  get ext risk sum lot
//+------------------------------------------------------------------+ 
double  CProtectGroup::getExtRiskSumLots(){	
	return this.protectGroupInfo.getExtRiskSumLots();
}

//+------------------------------------------------------------------+
//|  get sum lot
//+------------------------------------------------------------------+  
double  CProtectGroup::getSumLots(){
	if(this.sumLots<0){
	   this.sumLots=0;
	   for(int i=0;i<SYMBOL_MAX_COUNT;i++)
		   this.sumLots+=curSymbolLots[i];
	}	   
	return this.sumLots;	
}

//+------------------------------------------------------------------+
//|  get ext sum lot
//+------------------------------------------------------------------+  
double  CProtectGroup::getExtSumLots(){
	return this.protectGroupInfo.getExtSumLots();	
}

//+------------------------------------------------------------------+
//|  get sum lot
//+------------------------------------------------------------------+  
double  CProtectGroup::getSumSymbolRateLots(){
	double sumSymbolRateLot=0;	   
	for(int i=0;i<SYMBOL_MAX_COUNT;i++){
		   sumSymbolRateLot+=curSymbolLots[i]*SYMBOL_RATE[i];
	}	   
	return sumSymbolRateLot;	
}

//+------------------------------------------------------------------+
//|  get hedge rate
//+------------------------------------------------------------------+   
double  CProtectGroup::getRiskHedgeLotRate(){	
	return this.riskHedgeLotRate;
}

//+------------------------------------------------------------------+
//|  get hedge rate
//+------------------------------------------------------------------+   
double  CProtectGroup::getRiskLotRate(){	
	return this.riskLotRate;
}

//+------------------------------------------------------------------+
//|  get risk order count
//+------------------------------------------------------------------+   
int  CProtectGroup::getRiskOrderCount(){
   return  this.protectGroupInfo.getRiskOrderCount();
}

//+------------------------------------------------------------------+
//|  get ext risk order count
//+------------------------------------------------------------------+   
int  CProtectGroup::getExtRiskOrderCount(){
   return  this.protectGroupInfo.getExtRiskOrderCount();
}

//+------------------------------------------------------------------+
//|  get enable hedge lot
//+------------------------------------------------------------------+ 
double  CProtectGroup::getEnableHedgeLot(int symbolIndex,ENUM_ORDER_TYPE type){
	double needHedgeLots=0;	
	for(int i=0;i<SYMBOL_MAX_COUNT;i++){
		if(curSymbolLots[i]==0 || curSymbolHedgeLots[i]==0)continue;
		double curCorrelationValue=this.symbolCorrelation.getSymbolCorrelation(symbolIndex,i);		
		if((curCorrelationValue>=this.minCorrelationRate && type!=curSymbolsType[i])
				|| (curCorrelationValue<=-(this.minCorrelationRate) && type==curSymbolsType[i])){
   	   needHedgeLots+=curSymbolHedgeLots[i];
		}
		
	}
	return needHedgeLots;
}

//+------------------------------------------------------------------+
//|  judge order have symbol pair correlation
//+------------------------------------------------------------------+ 
bool  CProtectGroup::ifRiskProtect(int symbolIndex,
                                    ENUM_ORDER_TYPE type,
                                    double lot){    
   logData.addLine("<ifRiskProtect>"); 
   double enableHedgeLot=this.getEnableHedgeLot(symbolIndex,type);
	double orderHedgeLot=lot;
	if(this.useSymbolLotRate){
	   orderHedgeLot=orderHedgeLot*SYMBOL_RATE[symbolIndex];
   	logData.addLine("<useSymbolLotRate>" + this.useSymbolLotRate ); 
	   logData.addLine("<SYMBOL_RATE>" + SYMBOL_RATE[symbolIndex] );	   
	}
	logData.addLine("<hedgeLot>" + orderHedgeLot);    
	logData.addLine("<enableHedgeLot>" + enableHedgeLot); 	
   if(enableHedgeLot>=orderHedgeLot){
      logData.addLine("<ifRiskProtect>true"); 
      return true;
   }   
   return false;
}

//+------------------------------------------------------------------+
//|  get enable hedge lot adjust
//+------------------------------------------------------------------+  
double  CProtectGroup::getEnableHedgeLotAdjust(int symbolIndex,ENUM_ORDER_TYPE type){
   double needHedgeLots=0,adjustLots=0;
   if(type==ORDER_TYPE_BUY){
      needHedgeLots=getEnableHedgeLot(symbolIndex,type);
      adjustLots=getEnableHedgeLot(symbolIndex,ORDER_TYPE_SELL);
   }
   else if(type==ORDER_TYPE_SELL){
      needHedgeLots=getEnableHedgeLot(symbolIndex,type);
      adjustLots=getEnableHedgeLot(symbolIndex,ORDER_TYPE_BUY);      
   } 
   if(adjustLots>0){
		needHedgeLots=needHedgeLots-adjustLots;
		if(needHedgeLots<0)needHedgeLots=0;   
   }   
	return needHedgeLots;
}

//+------------------------------------------------------------------+
//|  refresh hedge orders
//+------------------------------------------------------------------+  
void  CProtectGroup::refreshHedgeOrders(CArrayList<COrder*>* orderList){   
   this.cleanHedgeOrders(orderList);
   for (int i = 0; i < orderList.Count(); i++) {
      COrder *order;
      orderList.TryGetValue(i,order);
      if(CheckPointer(order)==POINTER_INVALID)continue;
      if(this.groupOrders.Contains(order))continue; 
      if(this.hedgeModelKinds.Contains(order.getModelKind())
         || this.protectModelKinds.Contains(order.getModelKind())){
                 
         // hedge correlation inner weak
         if(this.hedgeCorrelationType==HEDGE_CORRLELATION_INNER_WEAK){
            if(order.getTradeStatus()==TRADE_STATUS_TRADE_PENDING
               || order.getTradeStatus()==TRADE_STATUS_TRADE_READY
               || order.getTradeStatus()==TRADE_STATUS_TRADE
            ){
               this.groupOrders.Add(order);    
            }
         }
         // hedge correlation inner strong
         else if(this.hedgeCorrelationType==HEDGE_CORRLELATION_INNER_STRONG){            
            if(order.getTradeStatus()==TRADE_STATUS_TRADE_PENDING
               || order.getTradeStatus()==TRADE_STATUS_TRADE_READY
               || order.getTradeStatus()==TRADE_STATUS_TRADE
               || order.getTradeStatus()==TRADE_STATUS_CLOSE_READY){
               this.groupOrders.Add(order);    
            }
         }
         // hedge correlation outer strong
         else if(this.hedgeCorrelationType==HEDGE_CORRLELATION_OUTER_STRONG){
            if(order.getTradeStatus()==TRADE_STATUS_TRADE 
               || order.getTradeStatus()==TRADE_STATUS_CLOSE_READY){
               this.groupOrders.Add(order);    
            }
         }
      }   
   }                                
}

//+------------------------------------------------------------------+
//|  clean hedge orders(1.close order  2.changed loss order)
//+------------------------------------------------------------------+  
void  CProtectGroup::cleanHedgeOrders(CArrayList<COrder*>* orderList){
   
   for (int i = this.groupOrders.Count()-1; i>=0; i--) {
      COrder *order;      
      bool ret=this.groupOrders.TryGetValue(i,order);       
      if(!orderList.Contains(order)){ 
         this.groupOrders.Remove(order);
      }
   }
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CProtectGroup::CProtectGroup(){
   this.useSymbolLotRate=false;
   this.hedgeCorrelationType=HEDGE_CORRLELATION_INNER_STRONG;  
}
CProtectGroup::~CProtectGroup(){}