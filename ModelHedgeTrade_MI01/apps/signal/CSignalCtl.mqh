//+------------------------------------------------------------------+
//|                                                   CSignalCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../share/CShareCtl.mqh"
#include "../indicator/CIndicatorCtl.mqh"
#include "../share/signal/CSignalList.mqh"
#include "model/base/CSignalModel.mqh"

class CSignalCtl
  {
   private:
      CIndicatorCtl  *indicatorCtl;
      CShareCtl      *shareCtl;
      CSignalModel   signalModel;
   public:
                     CSignalCtl();
                    ~CSignalCtl();
     //--- methods of initilize
     void           init(CIndicatorCtl *indicatorCtl,CShareCtl* shareCtl);  
     //--- run indicator
     void           run(); 
     //--- get signal list
     CSignalList*   getSignalList();
 };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CSignalCtl::init(CIndicatorCtl *indicatorCtl,CShareCtl* shareCtl){
   this.indicatorCtl=indicatorCtl;
   this.shareCtl=shareCtl;
      
   //make signal list
   this.signalModel.init(shareCtl);
   //this.signalModel.addExceptSymbol("GBPNZD");       
   //this.signalModel.addExceptSymbol("XAUUSD"); 
   this.signalModel.makeSignalList();
   this.shareCtl.getSignalShare().setRealSignalList(this.signalModel.getSignalList());
   
}

//+------------------------------------------------------------------+
//|  run the muti signals
//+------------------------------------------------------------------+
void CSignalCtl::run(){}
//+------------------------------------------------------------------+
//|  run the muti signals
//+------------------------------------------------------------------+
CSignalList*  CSignalCtl::getSignalList(){
   return this.signalModel.getSignalList();
}
 
//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSignalCtl::CSignalCtl(){}
CSignalCtl::~CSignalCtl(){}
