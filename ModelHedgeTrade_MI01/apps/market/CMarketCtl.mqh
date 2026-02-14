//+------------------------------------------------------------------+
//|                                                     CMarketCtl.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../share/CShareCtl.mqh"

class CMarketCtl{
      protected:
         CShareCtl     *shareCtl;
         CMarketInfo   *marketInfo;         
         
      public:
                      CMarketCtl();
                      ~CMarketCtl();
                      
        //--- methods of initilize
        void            init(CShareCtl *shareCtl); 
        //--- market load orders
        int             loadOrders();
        //--- refresh market(symbol info)
        void            refresh();             
  };
  
//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CMarketCtl::init(CShareCtl *shareCtl){
    this.shareCtl=shareCtl;
    this.marketInfo=this.shareCtl.getMarketShare().getMarketInfo();
}  

//+------------------------------------------------------------------+
//| load orders (init)                                                                 
//+------------------------------------------------------------------+
int  CMarketCtl::loadOrders(){
      
      //reset market info      
      this.marketInfo.clearMarketTicket();
      this.marketInfo.clearOrderKeyList();
   
      int     totalOrders = PositionsTotal();
      double  sumProfit=0;
      double  sumLots=0;      
      ulong   ticket;
            
      for(uint i=0;i<totalOrders;i++){
          ticket=PositionGetTicket(i);          
          if(ticket>0){   
          
            string orderComment=PositionGetString(POSITION_COMMENT);
            if(StringLen(orderComment)<10)continue;          
            
            ulong magicId=PositionGetInteger(POSITION_MAGIC);
            if(this.shareCtl.getModelKind()!=comFunc.getModelKind(magicId))continue;            
                
            COrder *order=new COrder();
            order.setTradeStatus(TRADE_STATUS_TRADE);
            order.setTicket(ticket);            
            order.setSymbol(comFunc.removeSuffix(PositionGetString(POSITION_SYMBOL)));
            order.setSymbolIndex(this.shareCtl.getSymbolShare().getSymbolIndex(order.getSymbol()));              
            order.setOrderType(ENUM_ORDER_TYPE(PositionGetInteger(POSITION_TYPE)));            
            order.setInitLot(PositionGetDouble(POSITION_VOLUME));
            order.setLot(PositionGetDouble(POSITION_VOLUME));
            order.setOpenPrice(PositionGetDouble(POSITION_PRICE_OPEN));
            order.setSlLine(PositionGetDouble(POSITION_SL));
            order.setTpLine(PositionGetDouble(POSITION_TP));
            order.setStartTime((datetime)PositionGetInteger(POSITION_TIME));
            order.setMagic(magicId);
            order.setComment(orderComment);
            
            rkeeLog.printLog("CMarketCtl loadOrders >" 
                                       + " preTicket:" + ticket
                                       + " ticket:" + order.getTicket()
                                       + " symbol:" + order.getSymbol()
                                       + " type:" + order.getOrderType()
                                       + " lot:" + order.getLot()
                                       + " openPrice:" + order.getOpenPrice()
                                       + " startTime:" + order.getStartTime()
                                       + " magic:" + order.getMagic()
                                       + " comment:" + order.getComment()
                                       );
            //summary
            sumLots+=order.getLot();
            sumProfit+=order.getProfit(); 
            
            //make maket ticket list
            this.marketInfo.addMarketTicket(ticket);
            this.marketInfo.addOrderKey(magicId); 
                      
            //load order to model share
            shareCtl.getModelShare().loadOrder(order);          
         }
      } 
     
      //save market info
      this.marketInfo.setOrderCount(totalOrders);
      this.marketInfo.setSumLots(sumLots);
      this.marketInfo.setSumProfit(sumProfit);     
         
     return totalOrders;
}  
  
//+------------------------------------------------------------------+
//| refresh orders                                                                 
//+------------------------------------------------------------------+
void CMarketCtl::refresh(void){        
  
      //refresh symbols
      //this.shareCtl.getSymbolShare().reSet();
      
      //reset market info
      this.marketInfo.clearMarketTicket();
      this.marketInfo.clearOrderKeyList();
            
      double  sumProfit=0;
      double  sumLots=0;      
      int positions=PositionsTotal();
      
      for(int i=positions-1; i>=0; i--){
      
         ulong ticket=PositionGetTicket(i);         
         ulong magicId=PositionGetInteger(POSITION_MAGIC);
         
         //make maket ticket list
         this.marketInfo.addMarketTicket(ticket);
         this.marketInfo.addOrderKey(magicId);
         
         COrder* order=shareCtl.getModelShare().getOrder(magicId);
         if(CheckPointer(order)==POINTER_INVALID)continue;
         order.setDealFlg(false);
         order.setClearFlg(false);
         order.setTicket(ticket);
         order.setOpenPrice(PositionGetDouble(POSITION_PRICE_OPEN));
         order.setProfit(PositionGetDouble(POSITION_PROFIT));
         order.setProfitCurrency(PositionGetDouble(POSITION_PROFIT));
         order.setLot(PositionGetDouble(POSITION_VOLUME));
         order.setSwap(PositionGetDouble(POSITION_SWAP)); 
         int spread=this.shareCtl.getSymbolShare().getSymbolInfos().getSymbolSpread(order.getSymbol());            
         order.setSpread(spread);         
         
         //summary
         sumLots+=order.getLot();
         sumProfit+=order.getProfit();      
      }      
      
      //save market info
      this.marketInfo.setOrderCount(positions);
      this.marketInfo.setSumLots(sumLots);
      this.marketInfo.setSumProfit(sumProfit);
      
      //sort order list 
      //comFunc.SortOrderListByProfit(this.shareCtl.getModelShare().getOrders());
      
      //sort model list
      comFunc.SortModelsListByProfit(this.shareCtl.getModelShare().getModels());
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMarketCtl::CMarketCtl()
  {
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMarketCtl::~CMarketCtl()
  {
  }
//+------------------------------------------------------------------+