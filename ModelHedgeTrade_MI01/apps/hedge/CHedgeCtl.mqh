//+------------------------------------------------------------------+
//|                                                    CHedgeCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\share\CShareCtl.mqh"

#include "..\share\hedge\CRiskHedgePair.mqh"

#include "input\CRiskPairInput.mqh"
#include "output\CRiskPairOutput.mqh"

class CHedgeCtl
  {
   private:
         int                modelKind;
         CShareCtl          *shareCtl;
         CRiskPairInput     riskPairInput;
         CRiskPairOutput    riskPairOutput;
   public:
                            CHedgeCtl();
                            ~CHedgeCtl();
         //--- methods of initilize
         void               init(CShareCtl *shareCtl); 
         //--- run hedge control
         void               refresh();
         //--- refresh risk hedge pairs
         void               refreshRiskHedgePair();         
         //--- input risk hedge pairs
         void               inputRiskHedgePair();         
         //--- output risk hedge pairs
         void               outputRiskHedgePair();
         //--- hedge orders
         void               hedgeOrders();
         //--- hedge orders by hedge group id
         void               hedgeOrders(int hedgeGroupId);
         
         //--- set model kind
         void               setModelKind(int modelKind);
         //--- get model kind
         int                getModelKind();                                   
            
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CHedgeCtl::init(CShareCtl *shareCtl)
{
   this.shareCtl=shareCtl;
   this.setModelKind(this.shareCtl.getModelKind());
   
   //init input/output risk pair
   this.riskPairInput.init(this.shareCtl);
   this.riskPairOutput.init(this.shareCtl);
}
//+------------------------------------------------------------------+
//|  run the muti signals
//+------------------------------------------------------------------+
void CHedgeCtl::refresh()
{
   this.hedgeOrders();
}

//+------------------------------------------------------------------+
//|  refresh risk hedge pairs
//+------------------------------------------------------------------+
void CHedgeCtl::refreshRiskHedgePair(){
   this.shareCtl.getHedgeShare().getRiskHedgePair().refresh();
}

//+------------------------------------------------------------------+
//| input risk hedge pairs
//+------------------------------------------------------------------+
void CHedgeCtl::inputRiskHedgePair(){
   this.riskPairInput.inputRiskPairs();
}

//+------------------------------------------------------------------+
//|  output risk hedge pairs
//+------------------------------------------------------------------+
void CHedgeCtl::outputRiskHedgePair(){
   this.riskPairOutput.outRiskPairs();
}

//+------------------------------------------------------------------+
//|  refresh hedge orders
//+------------------------------------------------------------------+
void CHedgeCtl::hedgeOrders(){

   this.shareCtl.getHedgeShare().getHedgeGroupPool().setExceptMode(false);
   this.shareCtl.getHedgeShare().getHedgeGroupPool().hedgeOrders(); 
   
}

//+------------------------------------------------------------------+
//|  refresh hedge orders
//+------------------------------------------------------------------+
void CHedgeCtl::hedgeOrders(int hedgeGroupId){      
   CHedgeGroup *hedgeGroup=this.shareCtl.getHedgeShare().getHedgeGroup(hedgeGroupId);
   CArrayList<COrder*>* orderList=this.shareCtl.getModelShare().getOrders();  
   hedgeGroup.hedgeOrders();      
}

//+------------------------------------------------------------------+
//|  set modelKind
//+------------------------------------------------------------------+
void CHedgeCtl::setModelKind(int modelKind){
   rkeeLog.writeLmtLog("CRunner: setModelKind1 " + modelKind);   
   this.modelKind=modelKind;   
}

//+------------------------------------------------------------------+
//|  set modelKind
//+------------------------------------------------------------------+
int CHedgeCtl::getModelKind(){
   return this.modelKind;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CHedgeCtl::CHedgeCtl(){}
CHedgeCtl::~CHedgeCtl(){}