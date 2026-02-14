//+------------------------------------------------------------------+
//|                                            CProtectGroupInfo.mqh |
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
#include "..\..\header\hedge\CHeader.mqh"
#include "..\..\header\symbol\CHeader.mqh"

class CProtectGroupInfo
  {
   public:   
         //+------------------------------------------------------------------+
         //|  hedge rate
         //+------------------------------------------------------------------+
         double                              riskLotRate;
         double                              riskHedgeLotRate;
   
         //+------------------------------------------------------------------+
         //|  risk order count
         //+------------------------------------------------------------------+
         int                                 riskOrderCount;
         int                                 extRiskOrderCount;
                  
         //+------------------------------------------------------------------+
         //|  group lot
         //+------------------------------------------------------------------+
         double                              sumLots;
         double                              riskHedgeSumLots;     
         double                              riskSumLots;         
         double                              extSumLots;
         double                              extRiskSumLots; 
         //+------------------------------------------------------------------+
         //|  class constructor   
         //+------------------------------------------------------------------+
                                             CProtectGroupInfo();
                                             ~CProtectGroupInfo();   
         //+------------------------------------------------------------------+
         //|  init function to initialize all variables to 0
         //+------------------------------------------------------------------+
         void                                init();
         
         //+------------------------------------------------------------------+
         //|  add risk order info
         //+------------------------------------------------------------------+
         void                                addRiskOrderInfo(int symbolIndex,COrder* order,bool protectFlg);
         
         //+------------------------------------------------------------------+
         //|  get group info
         //+------------------------------------------------------------------+         
         string                              getGroupInfo();

         //+------------------------------------------------------------------+
         //|  get group detail info
         //+------------------------------------------------------------------+         
         int                                 getRiskOrderCount();
         double                              getRiskHedgeLotRate();
         double                              getRiskLotRate();
         double                              getSumLots();        
         double                              getRiskHedgeSumLots();
         double                              getRiskSumLots();
         
         //+------------------------------------------------------------------+
         //|  get extend risk info
         //+------------------------------------------------------------------+
         int                                 getExtRiskOrderCount();
         double                              getExtRiskSumLots();
         double                              getExtSumLots();
  };

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CProtectGroupInfo::CProtectGroupInfo(){}
CProtectGroupInfo::~CProtectGroupInfo(){}


//+------------------------------------------------------------------+
//|  init function to initialize all variables to 0
//+------------------------------------------------------------------+
void CProtectGroupInfo::init()
{
  // Initialize double variables
  this.riskLotRate = 0.0;
  this.riskHedgeLotRate = 0.0;
  this.sumLots = 0.0;
  this.riskHedgeSumLots=0.0;
  this.riskSumLots = 0.0;
  this.extSumLots=0.0;
  this.extRiskSumLots = 0.0;

  // Initialize int variables
  this.riskOrderCount = 0; 
  this.extRiskOrderCount = 0;  
}

//+------------------------------------------------------------------+
//|  add protect order info
//+------------------------------------------------------------------+
void   CProtectGroupInfo::addRiskOrderInfo(int symbolIndex,COrder* order,bool protectFlg){
     
   //group order count
   if(order.getProtectlot()>0){
      this.riskOrderCount++;
      if(!protectFlg)this.extRiskOrderCount++;
   }   
   //group lot
   this.sumLots+=order.getLot();
   this.riskSumLots+=order.getProtectlot();
   if(!protectFlg){
      this.extSumLots+=order.getLot();
      this.extRiskSumLots+=order.getProtectlot();
   }   
}

//+------------------------------------------------------------------+
//|  use to test -- get group info
//+------------------------------------------------------------------+
string   CProtectGroupInfo::getGroupInfo(){

   string temp="  ";   
   //sum info
   temp +=" <riskCount>:" + this.riskOrderCount;
   temp +=" <extRiskCount>:" + this.extRiskOrderCount;
   temp +=" <sumlot>:" + StringFormat("%.3f",this.sumLots);
   temp +=" <extSumlot>:" + StringFormat("%.3f",this.extSumLots);
   temp +=" <riskLotRate>:" + StringFormat("%.2f",this.riskLotRate);   
   temp +=" <risklot>:" + StringFormat("%.3f",this.riskSumLots);
   temp +=" <extRisklot>:" + StringFormat("%.3f",this.extRiskSumLots);
   temp +=" <riskHedgeLotRate>:" + StringFormat("%.2f",this.riskHedgeLotRate);   
   temp +=" <riskHedgelot>:" + StringFormat("%.3f",this.riskHedgeSumLots);   
   
   return temp;
}

//+------------------------------------------------------------------+
//|  get group detail info
//+------------------------------------------------------------------+     
int   CProtectGroupInfo::getRiskOrderCount(){
   return this.riskOrderCount;
}

double   CProtectGroupInfo::getRiskHedgeLotRate(){
   return this.riskHedgeLotRate;
}

double   CProtectGroupInfo::getRiskLotRate(){
   return this.riskLotRate;
}

double   CProtectGroupInfo::getSumLots(){
   return this.sumLots;
}

double   CProtectGroupInfo::getRiskHedgeSumLots(){
   return this.riskHedgeSumLots;
}

double   CProtectGroupInfo::getRiskSumLots(){
   return this.riskSumLots;
}

//+------------------------------------------------------------------+
//|  get extend risk info
//+------------------------------------------------------------------+
int      CProtectGroupInfo::getExtRiskOrderCount(){
   return this.extRiskOrderCount;
}
double   CProtectGroupInfo::getExtRiskSumLots(){
   return this.extRiskSumLots;
}
double   CProtectGroupInfo::getExtSumLots(){
   return this.extSumLots;
}
