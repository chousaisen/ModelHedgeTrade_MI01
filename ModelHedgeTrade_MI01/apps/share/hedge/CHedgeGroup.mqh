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
         CHedgeGroupInfo                     hedgeGroupInfo;         
         CArrayList<COrder*>*                orderList;           
         CArrayList<COrder*>                 groupOrders;

         double                              minCorrelationRate;
         double                              hedgeRate;
         double                              sumLots;
         double                              hedgeSumLots;
   public:         
   
                        CHedgeGroup();
                       ~CHedgeGroup();                                   
         
         //--- methods of initilize
         void            init(CSymbolShare* symbolShare,CArrayList<COrder*>* orderList);                       
         //--- methods of initilize
         //void            setSymbolShare(CSymbolShare* symbolShare); 
         //--- set min correlation rate
         void            setMinCorrelationRate(double value); 
         //--- set symbol free/no hedge lot
         void            setSymbolFreeLots(double value);
         //--- set use symbol lot rate
         void            setUseSymbolLotRate(bool value); 
         //--- init symbol list
         void            initSymbolList();
         //--- set symbol list
         void            setSymbolList(string symbolListStr);
         //--- set model kind start lot
         void            setStartLot(int modelKind,double value); 
         //--- get model kind start lot
         double          getStartLot(int modelKind);
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
               
         //--- get enable hedge lot
         double          getEnableHedgeLot(int symbolIndex,ENUM_ORDER_TYPE type);
         //--- judge order have right symbol pair correlation
         bool            ifGroupHedge(int modelKind,int symbolIndex,ENUM_ORDER_TYPE type,double lot);
         //--- judge if hedge symbol type/lot
         bool            ifHedgeSymbolLot(int symbolIndex,ENUM_ORDER_TYPE type,double lot);
         
         //+------------------------------------------------------------------+
         //|  fuction about the managment of hedge orders
         //+------------------------------------------------------------------+ 
         //--- hedge init
         void            HedgeInit();
         //--- hedge orders
         void            hedgeOrders();                
         //--- refresh hedge orders
         void            initHedgeOrders();
         //--- set except mode
         void            setExceptMode(bool value);
         //--- set except models
         //void            setExceptModels(CArrayList<ulong>  *exceptModels);
};

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CHedgeGroup::init(CSymbolShare* symbolShare,CArrayList<COrder*>* orderList)
{
   this.orderList=orderList;
   this.symbolShare=symbolShare;
}

//--- set min correlation rate define
void CHedgeGroup::setMinCorrelationRate(double value){
   this.minCorrelationRate=value;
} 


//+------------------------------------------------------------------+
//|  get hedge group info
//+------------------------------------------------------------------+
CHedgeGroupInfo* CHedgeGroup::getHedgeGroupInfo(void)
{
   return &this.hedgeGroupInfo;      
}

//hedge data initialize
void CHedgeGroup::HedgeInit(){

	//get hedge rate
	this.hedgeRate=0;
	this.hedgeSumLots=0;
	this.sumLots=0; 
   
   //clear group orders
   this.groupOrders.Clear();
   
   //init hedge info
   this.hedgeGroupInfo.init();  
}


//+------------------------------------------------------------------+
//|  hedge the orders
//+------------------------------------------------------------------+
void CHedgeGroup::hedgeOrders()
{
   //init hedge orders
   this.initHedgeOrders();
   //check order pool size
   if(this.groupOrders.Count()==0)return;        
   
   for (int i = 0; i < this.groupOrders.Count(); i++) {
      COrder *order1;
      this.groupOrders.TryGetValue(i,order1); 
      if(CheckPointer(order1)==POINTER_INVALID)continue;
      if(order1.getHedgeLock())continue;
      int symbolIndex1=order1.getSymbolIndex();
      int orderType1=order1.getOrderType();
      for (int j = 0; j < this.groupOrders.Count(); j++) {
         COrder *order2;
         this.groupOrders.TryGetValue(j,order2); 
         if(CheckPointer(order2)==POINTER_INVALID)continue;
         if(order1.getMagic()==order2.getMagic())continue;   //same object
         if(order2.getHedgeLock())continue;
         int symbolIndex2=order2.getSymbolIndex();
         int orderType2=order2.getOrderType();         
   		double curCorrelationValue=this.symbolShare.getSymbolCorrelation(symbolIndex1,symbolIndex2);            
   		if((curCorrelationValue>=this.minCorrelationRate && orderType1!=orderType2)
   			|| (curCorrelationValue<=-this.minCorrelationRate && orderType1==orderType2)){
   			//set hedge lock flg
   			order1.setHedgeLock(true);
   			order2.setHedgeLock(true);   			
   			//set hedge sum lot
   			this.hedgeSumLots+=order1.getLot(); 
   			this.hedgeSumLots+=order2.getLot();
   			break;
   		}	      
      }    
   }      
         	
	//set hedge rate
	if(this.sumLots>0){
      this.hedgeRate=this.hedgeSumLots/this.sumLots;
	}
	
   if(rkeeLog.debugPeriod(9821,300)){
      string hedgeLogInfo= "<<hedgeLogInfo>>"
                            + "<sumLots>"+ this.sumLots
                            + "<hedgeSumLots>" + this.hedgeSumLots
                            + "<hedgeRate>" + this.hedgeRate;
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2() + "  " + hedgeLogInfo,"hedgeLogInfo01");
   } 	
	
	
	this.hedgeGroupInfo.hedgeRate=this.hedgeRate;
	
}


//+------------------------------------------------------------------+
//|  get hedge sum lot
//+------------------------------------------------------------------+ 
double  CHedgeGroup::getHedgeSumLots(){
	return this.hedgeSumLots;
}

//+------------------------------------------------------------------+
//|  get sum lot
//+------------------------------------------------------------------+  
double  CHedgeGroup::getSumLots(){   
	return this.sumLots;	
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

	return 0;
}

//+------------------------------------------------------------------+
//|  judge order have right hedge symbol pair correlation
//+------------------------------------------------------------------+ 
bool  CHedgeGroup::ifGroupHedge(int modelKind,int symbolIndex,ENUM_ORDER_TYPE type,double lot){

   return false;
}

//+------------------------------------------------------------------+
//|  judge order have outer strong symbol pair correlation
//+------------------------------------------------------------------+ 
bool  CHedgeGroup::ifHedgeSymbolLot(int symbolIndex,ENUM_ORDER_TYPE type,double lot){
   double enableHedgeLot=this.getEnableHedgeLot(symbolIndex,type);
	double orderHedgeLot=lot;
   if(enableHedgeLot>=orderHedgeLot){
      return true;
   }   
   return false;
}


//+------------------------------------------------------------------+
//|  refresh hedge orders
//+------------------------------------------------------------------+  
void  CHedgeGroup::initHedgeOrders(){   
   
   //init hedge data
   this.HedgeInit();      
      
   for (int i = 0; i < this.orderList.Count(); i++) {
      COrder *order;
      this.orderList.TryGetValue(i,order); 
      if(CheckPointer(order)==POINTER_INVALID)continue;
      if(this.exceptMode && order.getClearFlg())continue;
      if(order.getTradeStatus()==TRADE_STATUS_TRADE 
         || order.getTradeStatus()==TRADE_STATUS_CLOSE_READY){
         order.setHedgeLock(false);         
         this.groupOrders.Add(order);
         this.sumLots+=order.getLot();    
      }      
   }
      
   comFunc.SortOrderListByProfit(this.groupOrders);
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
}
CHedgeGroup::~CHedgeGroup(){}