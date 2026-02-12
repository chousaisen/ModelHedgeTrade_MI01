//+------------------------------------------------------------------+
//|                                                     CModel01.mqh |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include "data\\CMarketInfo.mqh"

class CMarketShare 
{
private:
   CMarketInfo  marketInfo;

public:
               CMarketShare();
               ~CMarketShare(); 
               
         void  init();

   //--- getter
   CMarketInfo* getMarketInfo();
};

//+------------------------------------------------------------------+
//| initialize the class
//+------------------------------------------------------------------+
void CMarketShare::init()
{
   this.marketInfo.init();
}

//+------------------------------------------------------------------+
//| getter / setter implementations
//+------------------------------------------------------------------+
CMarketInfo* CMarketShare::getMarketInfo()
{
   return &this.marketInfo;
}

//+------------------------------------------------------------------+
//| class constructor / destructor
//+------------------------------------------------------------------+
CMarketShare::CMarketShare(){
   this.init();
}

CMarketShare::~CMarketShare(){
}
