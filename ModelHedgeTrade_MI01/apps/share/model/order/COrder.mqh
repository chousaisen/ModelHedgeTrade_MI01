//+------------------------------------------------------------------+
//|                                                    TradeLine.mqh |
//|                                  Copyright 2024, RkeeCom Ltd.    |
//|                                             
//+------------------------------------------------------------------+


#include <Object.mqh>
#include "..\..\..\header\CDefine.mqh"

class COrder : public CObject
  {
   private:

   //+------------------------------------------------------------------+
   //|  symbol param   
   //+------------------------------------------------------------------+      
      int                symbolIndex;
      string             symbol;
      ENUM_ORDER_TYPE    orderType;      
   //+------------------------------------------------------------------+    

   //+------------------------------------------------------------------+
   //|  trade control param
   //+------------------------------------------------------------------+  
      int tradeStatus;
      int tradeType;
      
      // test begin
      bool dealFlg;
      bool clearFlg;
      string actionFlg;
      // test end

   //+------------------------------------------------------------------+
   
   //+------------------------------------------------------------------+
   //|  order control param
   //+------------------------------------------------------------------+  
      int   modelKind;        //model kind
      ulong   modelId;          //model id (getUniqueInt())
      int   orderIndex;       //order index or order status
      datetime startTime;     //startTime
      datetime endTime;       //endTime
      int      reTryCount;    // retry count when error happen
      int      errorCode;     // trade error code
   //+------------------------------------------------------------------+                         

   //+------------------------------------------------------------------+
   //|  market info   
   //+------------------------------------------------------------------+   
      ulong   ticket;         //ticket
      double  openPrice;      //open price
      double  tpLine;         //tpLine
      double  slLine;         //slLine
      double  initLot;        //init lot
      double  lot;            //lot
      double  protectlot;     //risk protect lot
      double  profit;         //pips profit
      double  profitCurrency;         //money profit
      double  swap;             //swap
      int     spread;           //spread
      ulong   magic;          //magic
      string  comment;        //comment
   //+------------------------------------------------------------------+ 
   
   //+------------------------------------------------------------------+
   //|  symbol perperties
   //+------------------------------------------------------------------+   
      double  point;            //symbol point
      
   //+------------------------------------------------------------------+
   //|  hedge perperties
   //+------------------------------------------------------------------+   
      bool    hedgeLock;
      
       
   public:      
      COrder();
     ~COrder();      
     
     //test begin
     // Getter and Setter for deal flag
    bool getDealFlg() { return dealFlg; }
    void setDealFlg(bool value) { dealFlg = value; } 
    
    bool getClearFlg() { return clearFlg; }
    void setClearFlg(bool value) { clearFlg = value; }     
             
     //test end
             
     // Getter and Setter for symbol
    string getSymbol() { return symbol; }
    void setSymbol(string value) { symbol = value; }

     // Getter and Setter for symbol index
    int getSymbolIndex() { return symbolIndex; }
    void setSymbolIndex(int value) { symbolIndex = value; }

    // Getter and Setter for orderType
    ENUM_ORDER_TYPE getOrderType() { return orderType; }
    void setOrderType(ENUM_ORDER_TYPE value) { orderType = value; }

    // Getter and Setter for tradeStatus
    int getTradeStatus() { return tradeStatus; }
    void setTradeStatus(int value) { tradeStatus = value; }
    
    // Getter and Setter for tradeType
    int getTradeType() { return tradeType; }
    void setTradeType(int value) { tradeType = value; }    

    // Getter and Setter for modelKind
    int getModelKind() { return modelKind; }
    void setModelKind(int value) { modelKind = value; }

    // Getter and Setter for modelId
    ulong getModelId() { return modelId; }
    void setModelId(ulong value) { modelId = value; }

    // Getter and Setter for orderIndex
    int getOrderIndex() { return orderIndex; }
    void setOrderIndex(int value) { orderIndex = value; }

    // Getter and Setter for startTime
    datetime getStartTime() { return startTime; }
    void setStartTime(datetime value) { startTime = value; }

    // Getter and Setter for endTime
    datetime getEndTime() { return endTime; }
    void setEndTime(datetime value) { endTime = value; }

    // Getter and Setter for reTryCount
    int getReTryCount() { return reTryCount; }
    void setReTryCount() { this.reTryCount++; } 
    
    // Getter and Setter for errorCode
    int getErrorCode() { return errorCode; }
    void setErrorCode(int value) { this.errorCode=value; }     

    // Getter and Setter for ticket
    ulong getTicket() { return ticket; }
    void setTicket(ulong value) { ticket = value; }

    // Getter and Setter for openPrice
    double getOpenPrice() { return openPrice; }
    void setOpenPrice(double value) { openPrice = value; }

    // Getter and Setter for tpLine
    double getTpLine() { return tpLine; }
    void setTpLine(double value) { tpLine = value; }

    // Getter and Setter for slLine
    double getSlLine() { return slLine; }
    void setSlLine(double value) { slLine = value; }

    // Getter and Setter for lot
    double getInitLot() { return initLot; }
    void setInitLot(double value) { initLot = value; }
    
    // Getter and Setter for lot
    double getLot() { return lot; }
    void setLot(double value) { lot = value; }  

    // Getter and Setter for protect lot
    double getProtectlot() { return protectlot; }
    void setProtectlot(double value) { protectlot = value; }  

    // Getter and Setter for profit
    double getProfit() { return profit; }
    void setProfit(double value) { profit = value; }  
    
    // Getter and Setter for currency profit
    double getProfitCurrency() { return profitCurrency; }
    void setProfitCurrency(double value) { profitCurrency = value; }      
    
    // Getter and Setter for swap
    double  getSwap(){return this.swap;}             
    void    setSwap(double value){this.swap=value;}             
     
    // Getter and Setter for spread
    double  getSpread(){return this.spread;}             
    void    setSpread(int value){this.spread=value;}             
    
    // Getter and Setter for magic
    ulong getMagic() { return magic; }
    void setMagic(ulong value) { magic = value; }

    // Getter and Setter for comment
    string getComment() { return comment; }
    void setComment(string value) { comment = value; }  
    
    // Getter and Setter for symbol point
    double getPoint() { return point; }
    void setPoint(double value) { point = value; }
    
    // Getter and Setter for action flag
    string getActionFlg(){return actionFlg;}
    void setActionFlg(string value) { actionFlg = value; }
    
    // Getter and Setter for hedgeLock flag
    bool getHedgeLock(){return hedgeLock;}
    void setHedgeLock(bool value) { hedgeLock = value; }    
       
};

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
COrder::COrder(){
   this.ticket=0;
   this.clearFlg=false;
   this.errorCode=0;
   this.profit=0;
   this.profitCurrency=0;
   this.tradeStatus=TRADE_STATUS_TRADE_PENDING;
   this.hedgeLock=false;
}
COrder::~COrder(){}