//+------------------------------------------------------------------+
//|                                                CSignalAction.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

class CSignalAction
{
private:
    int signalType;       // The type of signal
    double lot;           // The lot size
    datetime dealTime;    // deal time
    CArrayList<int>  dealList;    //model deal list
    
public:
   // Constructor
   CSignalAction();         
   
   // Destructor
   ~CSignalAction();
   
   // Getter and Setter for signalType
   int getSignalType() { return signalType; }
   void setSignalType(int value) { signalType = value; }
   
   // Getter and Setter for lot
   double getLot() { return lot; }
   void setLot(double value) { lot = value; }
   
   // Getter and Setter for deal time
   datetime getDealTime() { return dealTime; }
   void setDealTime(datetime value) { dealTime = value; }
   
   //+------------------------------------------------------------------+
   //|  deal ation functions
   //+------------------------------------------------------------------+
   //  add new finished deal modelId
   void  addFinishModel(ulong modelId);    
   //  get finished deal modelId
   bool  getFinishModel(ulong modelId);    

};


//+------------------------------------------------------------------+
//|  add deal finished modelId
//+------------------------------------------------------------------+
void CSignalAction::addFinishModel(ulong modelId){   
   this.dealList.Add(modelId);
}

//+------------------------------------------------------------------+
//|  get deal modelId
//+------------------------------------------------------------------+
bool CSignalAction::getFinishModel(ulong modelId){   
   return this.dealList.Contains(modelId);
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSignalAction::CSignalAction()
{
} 

//+------------------------------------------------------------------+
//|  class destructor
//+------------------------------------------------------------------+
CSignalAction::~CSignalAction()
{
}
