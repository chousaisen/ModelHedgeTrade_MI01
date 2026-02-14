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

#include "..\..\header\hedge\CHeader.mqh"
#include "..\..\header\symbol\CHeader.mqh"
#include "..\loginfo\CLogData.mqh"
#include "..\symbol\CSymbolShare.mqh"
#include "CHedgeGroupInfo.mqh"
//#include "CProtectGroupInfo.mqh"
//#include "CProtectGroup.mqh"

class CHedgeGroup
  {
   private:
         CSymbolShare*                       symbolShare; 
         bool                                exceptMode;
         //CArrayList<ulong>*                  exceptModels;         
         CHedgeGroupInfo                     hedgeGroupInfo;         
         int                                 hedgeCorrelationType;
         CArrayList<int>                     protectModelKinds;        //protect model
         CArrayList<int>                     hedgeModelKinds;          //hedge model
         CArrayList<int>                     symbolList;               //symbol list
         CArrayList<COrder*>                 groupOrders;
         //key(modelKind)
         CHashMap<int,double>                modelKindStartLot;         
         bool                                curSymbolsBaseModel[SYMBOL_MAX_COUNT];
         int                                 curSymbolsType[SYMBOL_MAX_COUNT];
         double                              curSymbolLots[SYMBOL_MAX_COUNT];
         double                              curSymbolHedgeLots[SYMBOL_MAX_COUNT];
         double                              minCorrelationRate;
         double                              hedgeRate;
         double                              sumLots;
         double                              hedgeSumLots;
         double                              protectSumLots;
         double                              symbolFreeLots;   //no hedge lot
         bool                                useSymbolLotRate;                   
   public:         
   
                        CHedgeGroup();
                       ~CHedgeGroup();                                   
                       
         //--- methods of initilize
         void            setSymbolShare(CSymbolShare* symbolShare); 
         //--- set min correlation rate
         void            setMinCorrelationRate(double value); 
         //--- set hedge correlation type
         void            setHedgeCorrelationType(int value);         
         //--- set symbol free/no hedge lot
         void            setSymbolFreeLots(double value);
         //--- set use symbol lot rate
         void            setUseSymbolLotRate(bool value); 
         //--- add protect model kind
         void            addProtectModelKind(int modelKind);                 
         //--- add hedge model kind
         void            addHedgeModelKind(int modelKind);          
         //--- get protect model kind list
         CArrayList<int>* getProtectModelKinds();
         //--- get hedge model kind list
         CArrayList<int>* getHedgeModelKinds();
         //---  protect hedge group
         void            protectHedgeGroup(CHedgeGroup* protectGroup,bool protectAll);         
         //--- init symbol list
         void            initSymbolList();
         //--- set symbol list
         void            setSymbolList(string symbolListStr);
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
         //--- get hedge sum lot
         double          getHedgeSumLots();
         //--- get sum lot
         double          getSumLots();
         //--- get ext sum lot
         double          getExtSumLots();
         //--- get risk hedge sum lot
         double          getRiskHedgeSumLots();
         //--- get risk sum lot
         double          getRiskSumLots();                  
         //--- get ext risk sum lot
         double          getExtRiskSumLots();                  
         //--- get sum symbol rate lot
         double          getSumSymbolRateLots();
         //--- get hedge rate
         double          getHedgeRate();
         //--- get hedge protect rate
         double          getRiskHedgeLotRate();   
         //--- get hedge protect rate
         double          getRiskLotRate();                
         //--- get protect order count
         int             getProtectOrderCount();
         //--- get hedge order count
         int             getHedgeOrderCount(); 
         //--- get risk order count
         int             getRiskOrderCount();                  
         //--- get ext risk order count
         int             getExtRiskOrderCount();                  
         //---get hedge group info
         CHedgeGroupInfo* getHedgeGroupInfo();
         //---get protect group info
         //CProtectGroupInfo* getProtectGroupInfo();
               
         //--- get enable hedge lot
         double          getEnableHedgeLot(int symbolIndex,ENUM_ORDER_TYPE type);
         //--- get enable hedge lot adjust
         double          getEnableHedgeLotAdjust(int symbolIndex,ENUM_ORDER_TYPE type);  
         //--- judge order have weak symbol pair correlation
         bool            ifCorrelationInnerWeak(int symbolIndex,ENUM_ORDER_TYPE type);
         //--- judge order have inner strong symbol pair correlation
         bool            ifCorrelationInnerStrong(int symbolIndex,ENUM_ORDER_TYPE type,double lot);
         //--- judge order have outer strong symbol pair correlation
         bool            ifCorrelationOuterStrong(int symbolIndex,ENUM_ORDER_TYPE type,double lot);
         //--- judge order have right symbol pair correlation
         bool            ifGroupHedge(int modelKind,int symbolIndex,ENUM_ORDER_TYPE type,double lot);
         //--- judge if hedge symbol type/lot
         bool            ifHedgeSymbolLot(int symbolIndex,ENUM_ORDER_TYPE type,double lot);
         
         //+------------------------------------------------------------------+
         //|  fuction about the managment of hedge orders
         //+------------------------------------------------------------------+        
         //--- refresh hedge orders
         void            refreshHedgeOrders(CArrayList<COrder*>* orderList);
         //--- clean hedge orders
         void            cleanHedgeOrders(CArrayList<COrder*>* orderList);
         //--- clear group orders
         void            clearOrders(CArrayList<COrder*>* orderList);   
         //--- set except mode
         void            setExceptMode(bool value);
         //--- set except models
         //void            setExceptModels(CArrayList<ulong>  *exceptModels);
};

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CHedgeGroup::setSymbolShare(CSymbolShare* symbolShare)
{

   this.symbolShare=symbolShare;
   //this.protectGroup.setSymbolCorrelation(symbolCorrelation);
}

//--- set min correlation rate define
void CHedgeGroup::setMinCorrelationRate(double value){
   this.minCorrelationRate=value;
   //this.protectGroup.setMinCorrelationRate(value);
} 

//+------------------------------------------------------------------+
//|  set hedge correlation type
//+------------------------------------------------------------------+  
void   CHedgeGroup::setHedgeCorrelationType(int value){
   this.hedgeCorrelationType=value;
}

//+------------------------------------------------------------------+
//--- set symbol free/no hedge lot
//+------------------------------------------------------------------+
void CHedgeGroup::setSymbolFreeLots(double value){
   this.symbolFreeLots=value;
} 

//+------------------------------------------------------------------+
//--- set use symbol lot rate
//+------------------------------------------------------------------+
void CHedgeGroup::setUseSymbolLotRate(bool value){
   this.useSymbolLotRate=value;
   //this.protectGroup.setUseSymbolLotRate(value);
}

//+------------------------------------------------------------------+
//|  add model kind
//+------------------------------------------------------------------+
void CHedgeGroup::addProtectModelKind(int modelKind)
{
      //this.protectGroup.addProtectModelKind(modelKind);
      if(this.protectModelKinds.Contains(modelKind))return;
      this.protectModelKinds.Add(modelKind);      
}

//+------------------------------------------------------------------+
//|  get hedge group info
//+------------------------------------------------------------------+
CHedgeGroupInfo* CHedgeGroup::getHedgeGroupInfo(void)
{
   return &this.hedgeGroupInfo;      
}

//+------------------------------------------------------------------+
//|  add hedge model kind
//+------------------------------------------------------------------+
void CHedgeGroup::addHedgeModelKind(int modelKind)
{
   //this.protectGroup.addHedgeModelKind(modelKind);
   if(this.hedgeModelKinds.Contains(modelKind))return;
   this.hedgeModelKinds.Add(modelKind);      
}      

//+------------------------------------------------------------------+
//|  get protect model kind List
//+------------------------------------------------------------------+
CArrayList<int>* CHedgeGroup::getProtectModelKinds(){
   return &this.protectModelKinds;
}

//+------------------------------------------------------------------+
//|  get hedge model kind list
//+------------------------------------------------------------------+         
CArrayList<int>* CHedgeGroup::getHedgeModelKinds(){
   return &this.hedgeModelKinds;
}

//+------------------------------------------------------------------+
//|  protect hedge group
//+------------------------------------------------------------------+
void CHedgeGroup::protectHedgeGroup(CHedgeGroup* protectGroup,bool protectAll)
{
   this.protectModelKinds.Clear();
   //copy protect model kind
   CArrayList<int>* protectModelKinds=protectGroup.getHedgeModelKinds();
   for(int i = 0; i < protectModelKinds.Count(); i++)
   {
      int modelKind;
      if(protectModelKinds.TryGetValue(i,modelKind)){
         this.protectModelKinds.Add(modelKind);
      }
   }   
   //protect other model kind when protect all mode
   if(!protectAll)return;   
   //copy extend protect model kind
   CArrayList<int>* extendProtectModelKinds=protectGroup.getProtectModelKinds();
   for(int i = 0; i < extendProtectModelKinds.Count(); i++)
   {
      int modelKind;
      if(extendProtectModelKinds.TryGetValue(i,modelKind)){
         this.protectModelKinds.Add(modelKind);
      }
   }
} 

//+------------------------------------------------------------------+
//|  add model kind start lot
//+------------------------------------------------------------------+
void CHedgeGroup::setStartLot(int modelKind,double value){   
   this.modelKindStartLot.Add(modelKind,value);
}

//+------------------------------------------------------------------+
//|  get model kind start lot
//+------------------------------------------------------------------+
double CHedgeGroup::getStartLot(int modelKind){
   double startLot=0;
   if(this.modelKindStartLot.TryGetValue(modelKind,startLot)){
      return startLot;      
   }
   return 0;   
}

//+------------------------------------------------------------------+
//|  init symbol list
//+------------------------------------------------------------------+
void CHedgeGroup::initSymbolList(){   
   int symbolCount=ArraySize(SYMBOL_LIST);
   for(int i=0;i<symbolCount;i++){      
         this.symbolList.Add(i);
   }
}

//+------------------------------------------------------------------+
//|  set symbol list
//+------------------------------------------------------------------+
void CHedgeGroup::setSymbolList(string symbolListStr){   
   this.symbolList.Clear();
   int symbolCount=ArraySize(SYMBOL_LIST);
   for(int i=0;i<symbolCount;i++){
      if(StringLen(symbolListStr)>0 
         && StringFind(symbolListStr,SYMBOL_LIST[i])>=0){
         this.symbolList.Add(i);   
      }
   }
}

//hedge data initialize
void CHedgeGroup::HedgeInit(){
   ArrayInitialize(curSymbolsBaseModel,false);
   ArrayInitialize(curSymbolsType,0);
   ArrayInitialize(curSymbolLots,0.00);
   ArrayInitialize(curSymbolHedgeLots,0.00);
	//get hedge rate
	this.hedgeRate=0;
	this.hedgeSumLots=0;
	this.sumLots=0; 
   this.protectSumLots=0;
   
   //init hedge info
   this.hedgeGroupInfo.init();  
}

/**
 * putHedgeData
 * if have same symbol then hedge itself
 * @param symbol
 * @param type
 * @param lots
 */
void CHedgeGroup::putHedgeInitData(COrder* order){
	int symbolIndex=order.getSymbolIndex();
	double orderHedgeLot=order.getLot();
	if(this.protectModelKinds.Contains(order.getModelKind())){
	   //orderHedgeLot=order.getProtectlot();
      this.hedgeGroupInfo.addProtectOrderInfo(symbolIndex,order);
      if(curSymbolHedgeLots[symbolIndex]==0)curSymbolsBaseModel[symbolIndex]=true;
   }else{
      this.hedgeGroupInfo.addHedgeOrderInfo(symbolIndex,order);
   }	
	
	int preSymbolsType=curSymbolsType[symbolIndex];	
	if(this.useSymbolLotRate){
	   orderHedgeLot=orderHedgeLot*SYMBOL_RATE[symbolIndex];
	}   
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
	
	//protect model
	if(this.protectModelKinds.Contains(order.getModelKind())){	   
	   this.protectSumLots+=order.getLot();
	}
	
	//protect model order	
	if(curSymbolsBaseModel[symbolIndex]){
	   if(this.hedgeModelKinds.Contains(order.getModelKind())
	      && preSymbolsType!=curSymbolsType[symbolIndex]){
	      curSymbolsBaseModel[symbolIndex]=false;
	   }	
	}
	else{
	   if(this.protectModelKinds.Contains(order.getModelKind())
	      && preSymbolsType!=curSymbolsType[symbolIndex]){
	      curSymbolsBaseModel[symbolIndex]=true;
	   }
	}
}

//+------------------------------------------------------------------+
//|  hedge the orders
//+------------------------------------------------------------------+
void CHedgeGroup::hedgeOrders()
{
   //init hedge data
   this.HedgeInit();
   //check order pool size
   if(this.groupOrders.Count()==0)return;
   //Initialize the symbol lot array
   ArrayInitialize(curSymbolLots,0);
   ArrayInitialize(curSymbolHedgeLots,0);
   
   for (int i = 0; i < this.groupOrders.Count(); i++) {
      COrder *order;
      if(this.groupOrders.TryGetValue(i,order)){
         if(CheckPointer(order)==POINTER_INVALID)continue;
         if(this.exceptMode){
            if(order.getClearFlg())continue;
         }
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
   			double curCorrelationValue=this.symbolShare.getSymbolCorrelation(i,j);
            
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
	this.hedgeSumLots=-1;
	this.sumLots=-1;	
	this.sumLots=getSumLots();
	this.hedgeSumLots=getHedgeSumLots();
	
	//get hedge rate
	this.hedgeRate=0;
	if(this.sumLots>0){
	   if(this.useSymbolLotRate){
	      double sumSymbolRateLots=this.getSumSymbolRateLots();
	      this.hedgeRate=1-(this.hedgeSumLots/sumSymbolRateLots);	
	   }else{
	      this.hedgeRate=1-(this.hedgeSumLots/this.sumLots);	
	   }
	}
	
	this.hedgeGroupInfo.hedgeRate=this.hedgeRate;
	//hedge protect group
	//this.protectGroup.hedgeOrders();
	
}

//+------------------------------------------------------------------+
//|  get Hedge Symbol Lots
//+------------------------------------------------------------------+
double  CHedgeGroup::getHedgeSymbolLots(int symbolIndex){	
	return curSymbolHedgeLots[symbolIndex];
}

//+------------------------------------------------------------------+
//|  get Symbol Lots
//+------------------------------------------------------------------+ 
double CHedgeGroup::getSymbolLots(int symbolIndex){
	return curSymbolLots[symbolIndex];
}	

//+------------------------------------------------------------------+
//|  get hedge sum lot
//+------------------------------------------------------------------+ 
double  CHedgeGroup::getHedgeSumLots(){	
	if(this.hedgeSumLots<0){	
	   this.hedgeSumLots=0;
	   for(int i=0;i<SYMBOL_MAX_COUNT;i++)
		   this.hedgeSumLots+=curSymbolHedgeLots[i];
		   
	}	
	return this.hedgeSumLots;
}

//+------------------------------------------------------------------+
//|  get sum lot
//+------------------------------------------------------------------+  
double  CHedgeGroup::getSumLots(){
	if(this.sumLots<0){
	   this.sumLots=0;
	   for(int i=0;i<SYMBOL_MAX_COUNT;i++)
		   this.sumLots+=curSymbolLots[i];
	}	   
	return this.sumLots;	
}

//+------------------------------------------------------------------+
//|  get sum lot
//+------------------------------------------------------------------+  
double  CHedgeGroup::getSumSymbolRateLots(){
	double sumSymbolRateLot=0;	   
	for(int i=0;i<SYMBOL_MAX_COUNT;i++){
		   sumSymbolRateLot+=curSymbolLots[i]*SYMBOL_RATE[i];
	}	   
	return sumSymbolRateLot;	
}

//+------------------------------------------------------------------+
//|  get hedge rate
//+------------------------------------------------------------------+   
double  CHedgeGroup::getHedgeRate(){	
	return this.hedgeRate;
}

//+------------------------------------------------------------------+
//|  get protect order count
//+------------------------------------------------------------------+   
int  CHedgeGroup::getProtectOrderCount(){
   return  this.hedgeGroupInfo.getProtectOrderCount();
}
//+------------------------------------------------------------------+
//|  get hedge order count
//+------------------------------------------------------------------+   
int  CHedgeGroup::getHedgeOrderCount(){
   return  this.hedgeGroupInfo.getHedgeOrderCount();
}

//+------------------------------------------------------------------+
//|  get enable hedge lot
//+------------------------------------------------------------------+ 
double  CHedgeGroup::getEnableHedgeLot(int symbolIndex,ENUM_ORDER_TYPE type){
	double needHedgeLots=0;	
	for(int i=0;i<SYMBOL_MAX_COUNT;i++){
		if(curSymbolLots[i]==0 || curSymbolHedgeLots[i]==0)continue;
		double curCorrelationValue=this.symbolShare.getSymbolCorrelation(symbolIndex,i);		
		if((curCorrelationValue>=this.minCorrelationRate && type!=curSymbolsType[i])
				|| (curCorrelationValue<=-(this.minCorrelationRate) && type==curSymbolsType[i])){				
		   needHedgeLots+=curSymbolHedgeLots[i];
		}
		
	}
	return needHedgeLots;
}

//+------------------------------------------------------------------+
//|  judge order have weak symbol pair correlation
//+------------------------------------------------------------------+ 
bool  CHedgeGroup::ifCorrelationInnerWeak(int symbolIndex,ENUM_ORDER_TYPE type){
      
   if(curSymbolLots[symbolIndex]==0 || curSymbolLots[symbolIndex]>this.symbolFreeLots){      
   	for(int i=0;i<SYMBOL_MAX_COUNT;i++){   	   	   	 
   		if(curSymbolLots[i]==0)continue;   		   		
   		double curCorrelationValue=this.symbolShare.getSymbolCorrelation(symbolIndex,i);
   		if(MathAbs(curCorrelationValue)>this.minCorrelationRate){		   
   			return false;
   		}
   	} 
	}
	
	return true;
}

//+------------------------------------------------------------------+
//|  judge order have inner strong symbol pair correlation
//+------------------------------------------------------------------+ 
bool  CHedgeGroup::ifCorrelationInnerStrong(int symbolIndex,ENUM_ORDER_TYPE type,double lot){
   
   logData.addLine("<ifCorrelationInnerStrong>");    
   
   //judge symbol free lot
   if(this.symbolFreeLots!=0 
         && curSymbolLots[symbolIndex]>0 
         && (curSymbolLots[symbolIndex]+lot)<=this.symbolFreeLots){ 
      logData.addLine("<if freeLot>true<symbolFreeLots>" + this.symbolFreeLots );    
      return true;
   }   
   double enableHedgeLot=this.getEnableHedgeLot(symbolIndex,type);
	double orderHedgeLot=lot;
	
	if(this.useSymbolLotRate){
	   orderHedgeLot=orderHedgeLot*SYMBOL_RATE[symbolIndex];
   	logData.addLine("<useSymbolLotRate>" + this.useSymbolLotRate ); 
	   logData.addLine("<SYMBOL_RATE>" + SYMBOL_RATE[symbolIndex] );      
	}      

	logData.addLine("<enableHedgeLot>" + enableHedgeLot );
	logData.addLine("<orderHedgeLot>" + orderHedgeLot );  
	
   if(enableHedgeLot>=orderHedgeLot){
      logData.addLine("<ifHedge>true");  
      return true;
   }   
   return false;
}


//+------------------------------------------------------------------+
//|  judge order have outer strong symbol pair correlation
//+------------------------------------------------------------------+ 
bool  CHedgeGroup::ifCorrelationOuterStrong(int symbolIndex,ENUM_ORDER_TYPE type,double lot){
   
   logData.addLine("<ifCorrelationOuterStrong>");  
   //judge symbol free lot
   if(this.symbolFreeLots!=0 
         && curSymbolLots[symbolIndex]>0 
         && (curSymbolLots[symbolIndex]+lot)<=this.symbolFreeLots){
      logData.addLine("<if freeLot>true<symbolFreeLots>" + this.symbolFreeLots);        
      return true;
   }   
   double enableHedgeLot=this.getEnableHedgeLot(symbolIndex,type);
	double orderHedgeLot=lot;
	if(this.useSymbolLotRate){
	   orderHedgeLot=orderHedgeLot*SYMBOL_RATE[symbolIndex];
   	logData.addLine("<useSymbolLotRate>" + this.useSymbolLotRate ); 
	   logData.addLine("<SYMBOL_RATE>" + SYMBOL_RATE[symbolIndex] ); 	   
	}
	logData.addLine("<enableHedgeLot>" + enableHedgeLot );
	logData.addLine("<orderHedgeLot>" + orderHedgeLot ); 	
   if(enableHedgeLot>=orderHedgeLot){
      logData.addLine("<ifHedge>true");  
      return true;
   }   
   return false;
}


//+------------------------------------------------------------------+
//|  judge order have right hedge symbol pair correlation
//+------------------------------------------------------------------+ 
bool  CHedgeGroup::ifGroupHedge(int modelKind,int symbolIndex,ENUM_ORDER_TYPE type,double lot){

   // divide the symbol list by the hedge group
   if(!this.symbolList.Contains(symbolIndex))return false;

   // hedge correlation inner weak  
   if(this.hedgeCorrelationType == HEDGE_CORRLELATION_INNER_WEAK){
      if((this.sumLots+lot)<=this.getStartLot(modelKind)){
         return true;
      }   
      return this.ifCorrelationInnerWeak(symbolIndex,type);
   }
   // hedge correlation inner strong  
   else if(this.hedgeCorrelationType == HEDGE_CORRLELATION_INNER_STRONG){         
      if((this.sumLots+lot)<=this.getStartLot(modelKind)){
         return true;
      }   
      return this.ifCorrelationInnerStrong(symbolIndex,type,lot);  
   }   
   // hedge correlation outer strong  
   else if(this.hedgeCorrelationType == HEDGE_CORRLELATION_OUTER_STRONG){            
      return this.ifCorrelationOuterStrong(symbolIndex,type,lot);
   } 
   // hedge nothing
   else if(this.hedgeCorrelationType == HEDGE_CORRLELATION_NOTHING){
      return true;
   }       
   
      
   return false;
}

//+------------------------------------------------------------------+
//|  judge order have outer strong symbol pair correlation
//+------------------------------------------------------------------+ 
bool  CHedgeGroup::ifHedgeSymbolLot(int symbolIndex,ENUM_ORDER_TYPE type,double lot){
   double enableHedgeLot=this.getEnableHedgeLot(symbolIndex,type);
	double orderHedgeLot=lot;
	if(this.useSymbolLotRate){
	   orderHedgeLot=orderHedgeLot*SYMBOL_RATE[symbolIndex];
	}
   if(enableHedgeLot>=orderHedgeLot){
      return true;
   }   
   return false;
}


//+------------------------------------------------------------------+
//|  get enable hedge lot adjust
//+------------------------------------------------------------------+  
double  CHedgeGroup::getEnableHedgeLotAdjust(int symbolIndex,ENUM_ORDER_TYPE type){
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
void  CHedgeGroup::refreshHedgeOrders(CArrayList<COrder*>* orderList){   
   this.cleanHedgeOrders(orderList);
   for (int i = 0; i < orderList.Count(); i++) {
      COrder *order;
      orderList.TryGetValue(i,order); 
      if(CheckPointer(order)==POINTER_INVALID)continue;
      if(this.groupOrders.Contains(order))continue;            
      //model order kind
      if(this.protectModelKinds.Contains(order.getModelKind())){         
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
               || order.getTradeStatus()==TRADE_STATUS_CLOSE_READY
            ){
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
      //hedge order kind
      else if(this.hedgeModelKinds.Contains(order.getModelKind())){
         if(order.getTradeStatus()==TRADE_STATUS_TRADE_PENDING
               || order.getTradeStatus()==TRADE_STATUS_TRADE_READY
               || order.getTradeStatus()==TRADE_STATUS_TRADE
               || order.getTradeStatus()==TRADE_STATUS_CLOSE_READY){
            this.groupOrders.Add(order);    
         }
      }
   }
   
   //refresh protect group
   //this.protectGroup.refreshHedgeOrders(orderList);
   
}

//+------------------------------------------------------------------+
//|  clean hedge orders(1.close order  2.changed loss order)
//+------------------------------------------------------------------+  
void  CHedgeGroup::cleanHedgeOrders(CArrayList<COrder*>* orderList){
   
   for (int i = this.groupOrders.Count()-1; i>=0; i--) {
      COrder *order;      
      bool ret=this.groupOrders.TryGetValue(i,order);       
      if(!orderList.Contains(order)){ 
         this.groupOrders.Remove(order);
      }
   }
   
   //clean protect group
   //this.protectGroup.cleanHedgeOrders(orderList);
}

//+------------------------------------------------------------------+
//|  set except mode
//+------------------------------------------------------------------+
void  CHedgeGroup::setExceptMode(bool value){
   this.exceptMode=value;
}

//+------------------------------------------------------------------+
//|  set except model mode
//+------------------------------------------------------------------+
//void  CHedgeGroup::setExceptModels(CArrayList<ulong>  *exceptModels){
//   this.exceptModels=exceptModels;
//}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CHedgeGroup::CHedgeGroup(){
   this.symbolFreeLots=0;
   this.useSymbolLotRate=false;
   this.hedgeCorrelationType=HEDGE_CORRLELATION_INNER_STRONG;
   this.initSymbolList();
}
CHedgeGroup::~CHedgeGroup(){}