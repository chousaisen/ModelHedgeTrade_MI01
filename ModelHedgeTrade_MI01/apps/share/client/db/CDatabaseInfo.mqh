//+------------------------------------------------------------------+
//|                                                  CDatabaseInfo.mqh |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

class CDatabaseInfo{
   private:   
      CArrayList<ulong>         riskDbKeyList;          
   public:
                        CDatabaseInfo();
                        ~CDatabaseInfo(); 

   // init                  
   void                  init();
   
   CArrayList<ulong>*    getRiskDbKeyList();
   void                  addRiskDbKey(ulong key);
   bool                  containsRiskDbKey(ulong key);
   void                  clearRiskDbKeyList();
      
};

//+------------------------------------------------------------------+
//| initialize the class
//+------------------------------------------------------------------+
void CDatabaseInfo::init(){
}

CArrayList<ulong>* CDatabaseInfo::getRiskDbKeyList(){
   return &this.riskDbKeyList;
}

void CDatabaseInfo::addRiskDbKey(ulong key){
   this.riskDbKeyList.Add(key);
}

bool CDatabaseInfo::containsRiskDbKey(ulong key){
   return this.riskDbKeyList.Contains(key);
}

void CDatabaseInfo::clearRiskDbKeyList(){
   this.riskDbKeyList.Clear();
}


//+------------------------------------------------------------------+
//| class constructor / destructor
//+------------------------------------------------------------------+
CDatabaseInfo::CDatabaseInfo(){
}

CDatabaseInfo::~CDatabaseInfo(){
}
