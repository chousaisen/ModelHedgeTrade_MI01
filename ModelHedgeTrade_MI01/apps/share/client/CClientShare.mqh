//+------------------------------------------------------------------+
//|                                                     CModel01.mqh |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include "db\CDatabaseInfo.mqh"

class CClientShare 
{
private:
   CDatabaseInfo  dbInfo;
public:
               CClientShare();
               ~CClientShare(); 
               
         void  init();

   //--- getter
   CDatabaseInfo* getDbInfo();
};

//+------------------------------------------------------------------+
//| initialize the class
//+------------------------------------------------------------------+
void CClientShare::init(){
}

//+------------------------------------------------------------------+
//| getter / setter implementations
//+------------------------------------------------------------------+
CDatabaseInfo* CClientShare::getDbInfo()
{
   return &this.dbInfo;
}

//+------------------------------------------------------------------+
//| class constructor / destructor
//+------------------------------------------------------------------+
CClientShare::CClientShare(){
   this.init();
}

CClientShare::~CClientShare(){
}
