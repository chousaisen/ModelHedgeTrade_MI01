//+------------------------------------------------------------------+
//|                                                  CMarketInfo.mqh |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>

class CMarketInfo{
   private:   
      int                        accountNo;   
      double                     sumProfit;
      double                     sumLots;
      int                        orderCount;
      CArrayList<ulong>          orderKeyList;
      //ticket list
      CArrayList<ulong>          marketTicketList;    
      
   public:
                  CMarketInfo();
                  ~CMarketInfo(); 

   // init                  
   void         init();
   //--- getter / setter
   int         getAccountNo() const;
   double      getSumProfit() const;
   void        setSumProfit(double value);

   double      getSumLots() const;
   void        setSumLots(double value);

   int         getOrderCount() const;
   void        setOrderCount(int  value);
   
   CArrayList<ulong>*    getOrderKeyList();
   void                  addOrderKey(ulong key);
   bool                  containsOrderKey(ulong key);
   void                  clearOrderKeyList();
   
   //+------------------------------------------------------------------+
   //|  market ticket list record and check
   //+------------------------------------------------------------------+ 
   void                  addMarketTicket(ulong ticket);    
   void                  clearMarketTicket();
   bool                  checkMarketTicket(ulong ticket);     
};

//+------------------------------------------------------------------+
//| initialize the class
//+------------------------------------------------------------------+
void CMarketInfo::init()
{
   this.sumProfit  = 0.0;
   this.orderCount = 0.0;
   this.accountNo=AccountInfoInteger(ACCOUNT_LOGIN);
}

//+------------------------------------------------------------------+
//| getter / setter implementations
//+------------------------------------------------------------------+
int CMarketInfo::getAccountNo() const
{
   return this.sumProfit;
}

double CMarketInfo::getSumProfit() const
{
   return this.sumProfit;
}

void CMarketInfo::setSumProfit(double value)
{
   this.sumProfit = value;
}

double CMarketInfo::getSumLots() const
{
   return this.sumLots;
}

void CMarketInfo::setSumLots(double value)
{
   this.sumLots = value;
}

int CMarketInfo::getOrderCount() const
{
   return this.orderCount;
}

void CMarketInfo::setOrderCount(int value)
{
   this.orderCount = value;
}

CArrayList<ulong>* CMarketInfo::getOrderKeyList(){
   return &this.orderKeyList;
}

void CMarketInfo::addOrderKey(ulong key){
   this.orderKeyList.Add(key);
}

bool CMarketInfo::containsOrderKey(ulong key){
   return this.orderKeyList.Contains(key);
}

void CMarketInfo::clearOrderKeyList(){
   this.orderKeyList.Clear();
}

//+------------------------------------------------------------------+
//|  market ticket list record and check
//+------------------------------------------------------------------+ 
void    CMarketInfo::addMarketTicket(ulong ticket){
   this.marketTicketList.Add(ticket);
}  
void    CMarketInfo::clearMarketTicket(){
   this.marketTicketList.Clear();
}
bool    CMarketInfo::checkMarketTicket(ulong ticket){
   return this.marketTicketList.Contains(ticket);
}

//+------------------------------------------------------------------+
//| class constructor / destructor
//+------------------------------------------------------------------+
CMarketInfo::CMarketInfo()
{
   this.init();
}

CMarketInfo::~CMarketInfo()
{
}
