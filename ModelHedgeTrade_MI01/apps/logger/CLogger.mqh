//+------------------------------------------------------------------+
//|                                                  ModelsRun10.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../share/CShareCtl.mqh"
#include "../market/CMarketCtl.mqh"
#include "../share/loginfo/CLogData.mqh"
#include "../model/CModelCtl.mqh"

class CLogger
  {
   private:
      CShareCtl*             shareCtl;
      CMarketCtl*            marketCtl;
      string                 debugInfo;  
   public:   
   //+------------------------------------------------------------------+
   //|    class constructor   
   //+------------------------------------------------------------------+   
   CLogger(){};
   ~CLogger(){};
           
   //+------------------------------------------------------------------+
   //|  initialize the class
   //+------------------------------------------------------------------+
   void init(CShareCtl*  shareCtl,CMarketCtl*  marketCtl){
        this.shareCtl=shareCtl;
        this.marketCtl=marketCtl;    
   }      
   
   //+------------------------------------------------------------------+
   //| make hedge group log
   //+------------------------------------------------------------------+
   /*
   void  log_GroupInfo(string logFile){
    
     rkeeLog.printPeroidLog(logFile,1001,60, 
                           comFunc.getDate_YYYYMMDDHHMM2()
                           + " hedgeRate:" + shareCtl.getHedgeShare().getHedgeGroupPool().getHedgeRate()
                           //+ " avgHedgeRate:" + shareCtl.getHedgeShare().getAvgHedgeRate()
                           + " positions:" + PositionsTotal()
                           + " orders:" + shareCtl.getModelShare().getOrders().Count()
                           + " open:" + shareCtl.getModelShare().getOpenOrderCount()
                           + " close:" + shareCtl.getModelShare().getCloseOrderCount()
                           + " clear:" + shareCtl.getModelShare().getClearOrderCount()
                           + " Account-" + AccountInfoDouble(ACCOUNT_MARGIN_FREE) + "-" + AccountInfoDouble(ACCOUNT_EQUITY)                       
                        );
                        
                        
   } */                     
   
   //+------------------------------------------------------------------+
   //| make order list log
   //+------------------------------------------------------------------+  
   /*
   void  log_OrdersMarket(string logFile){  
   
     string openFlg="",closeFlg="",clearFlg="";
     if(shareCtl.getModelShare().getOpenOrderCount()>0)openFlg=" open:" + shareCtl.getModelShare().getOpenOrderCount();
     if(shareCtl.getModelShare().getCloseOrderCount()>0)openFlg=" close:" + shareCtl.getModelShare().getCloseOrderCount();
     if(shareCtl.getModelShare().getClearOrderCount()>0)openFlg=" clear:" + shareCtl.getModelShare().getClearOrderCount();
                          
     rkeeLog.printPeroidLog(logFile,2001,60, 
                           comFunc.getDate_YYYYMMDDHHMM2()
                           + " positions:" + PositionsTotal()
                           + openFlg
                           + closeFlg
                           + clearFlg
                           ); 
     
   } */ 
      
  //+------------------------------------------------------------------+
   //| make hedge group log
   //+------------------------------------------------------------------+
   void  log_GroupHedgeInfo(CModelCtl* modelCtl){
    
      CHedgeGroup* hedgeGroupPool=this.shareCtl.getHedgeShare().getHedgeGroupPool();
       
      rkeeLog.printPeroidLog("HedgeGroupInfo",1002,Log_Diff_Seconds, 
                              comFunc.getDate_YYYYMMDDHHMM2()
                              + " hedgeRate:" + StringFormat("%.2f",hedgeGroupPool.getHedgeRate())
                              + " sumlots:" + StringFormat("%.2f",hedgeGroupPool.getSumLots())
                              + " orders:" + this.shareCtl.getModelShare().getOrders().Count()
                              + " positions:" + PositionsTotal()
                              + " Account-" + AccountInfoDouble(ACCOUNT_MARGIN_FREE) 
                              + "-" + AccountInfoDouble(ACCOUNT_EQUITY)                       
                              );
                              
      rkeeLog.printPeroidLog("HedgeGroupInfo",1003,Log_Diff_Seconds, 
                              "                " 
                              + " GroupPool" 
                              + hedgeGroupPool.getHedgeGroupInfo().getGroupInfo());
                                   
      CArrayList<CModelRunnerI*>* runnerList=modelCtl.getRunnerList();
      for (int i = 0; i < runnerList.Count(); i++) {   
         CModelRunnerI* runner;
         runnerList.TryGetValue(i,runner);
         int runnerId=runner.getModelKind(); 
         rkeeLog.printPeroidLog("HedgeGroupInfo",1004+i,Log_Diff_Seconds,
                                "                "
                                + logData.getLine("GroupInfo_" + runnerId));
         rkeeLog.printPeroidLog("HedgeGroupInfo",1105+i,Log_Diff_Seconds,
                                "                " 
                                + logData.getLine("ProtectInfo_" + runnerId));         
      }                                                                            
   }         
   
   //+------------------------------------------------------------------+
   //|  risk group info
   //+------------------------------------------------------------------+ 
   void    log_RiskGroupInfo(){
   
      rkeeLog.printPeroidLog("RiskGroupInfo",1201,Log_Diff_Seconds,
                          logData.getLine("protectRiskGroup1"));
      double runnerCount=logData.getCheckNValue("runnerCount");  //---logData test
      if(runnerCount>0){
         rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2() 
                           + logData.getLine("protectRiskGroup2")
                           ,"modelsOpen");
      }
      logData.reset();                         
   
   }   
      
   //+------------------------------------------------------------------+
   //|  get model status info
   //+------------------------------------------------------------------+ 
   void    log_ModelsOpen(CModelCtl* modelCtl){
      
      CArrayList<CModelRunnerI*>* runnerList=modelCtl.getRunnerList();
      for (int i = 0; i < runnerList.Count(); i++) {   
         CModelRunnerI* runner;
         runnerList.TryGetValue(i,runner);
         int runnerId=runner.getModelKind();
         double openModelCount=logData.getCheckNValue("openModelCount_" + runnerId);  //---logData test
         if(openModelCount>0){
            rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2() 
                              + logData.getLine("GroupInfo_" + runnerId)
                              ,"modelsOpen");
            rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2() 
                              + logData.getLine("ProtectInfo_" + runnerId)
                              ,"modelsOpen");
            rkeeLog.writeLog(" <open>" + openModelCount 
                              + logData.getLine("openModels_" + runnerId)
                              ,"modelsOpen");
         }         
      }       
      logData.reset();
   }      
      
  //+------------------------------------------------------------------+
   //|  get model status info
   //+------------------------------------------------------------------+ 
   void    log_ModelsStatus(){
   
      CArrayList<CModelI*> modelList=this.shareCtl.getModelShare().getModels();
      int modelCount=modelList.Count();
      //clean model list      
      string temp="";    
      for (int i = modelCount-1; i >=0 ; i--) {
         CModelI *model;      
         if(modelList.TryGetValue(i,model)){            
            temp+=model.modelInfo() + "@R";
         }
      }
      if(modelCount>0){
         rkeeLog.printPeroidLog("modelStatus",2101,3600,
                                comFunc.getDate_YYYYMMDDHHMM2() 
                                + " <models>" + modelCount 
                                + "@R        " + temp);
      }   
      
   }
         
   //+------------------------------------------------------------------+
   //|  get order status info
   //+------------------------------------------------------------------+ 
   void    log_OrdersStatus(string logFile){
   
      //test begin
      //this.errorFlg=false;
      int  count_TRADE_STATUS_TRADE_PENDING=0;
      int  count_TRADE_STATUS_TRADE_READY=0;
      int  count_TRADE_STATUS_TRADE=0;
      int  count_TRADE_STATUS_CLOSE_READY=0;
      int  count_TRADE_STATUS_CLOSE_PART_READY=0;
      int  count_TRADE_STATUS_CLOSE=0;
      int  count_TRADE_STATUS_ERROR=0;
      int  count_TRADE_STATUS_ERROR_OPEN=0;
      int  count_TRADE_STATUS_ERROR_CLOSE=0; 
      int  count_TRADE_BUY=0; 
      int  count_TRADE_SELL=0; 
      int  clearCount=0,errorCount=0; 
      
      //test end
      //refresh error close
      CArrayList<COrder*>* orderList=this.shareCtl.getModelShare().getOrders();
      
      for (int i = 0; i < orderList.Count(); i++) {  
         COrder *order;
         orderList.TryGetValue(i,order);
         if(CheckPointer(order)==POINTER_INVALID)continue;      
         if(order.getTradeStatus()==TRADE_STATUS_ERROR_CLOSE
            || order.getTradeStatus()==TRADE_STATUS_ERROR_CLOSE_PART){
            if(!this.shareCtl.getModelShare().checkMarketTicket(order.getTicket())){
               clearCount++; 
            }           
         }
               
         if(order.getTradeStatus()==TRADE_STATUS_TRADE_PENDING)count_TRADE_STATUS_TRADE_PENDING++;
         if(order.getTradeStatus()==TRADE_STATUS_TRADE_READY)count_TRADE_STATUS_TRADE_READY++;
         if(order.getTradeStatus()==TRADE_STATUS_TRADE)count_TRADE_STATUS_TRADE++;
         if(order.getTradeStatus()==TRADE_STATUS_CLOSE_READY)count_TRADE_STATUS_CLOSE_READY++;
         if(order.getTradeStatus()==TRADE_STATUS_CLOSE_PART_READY)count_TRADE_STATUS_CLOSE_PART_READY++;
         if(order.getTradeStatus()==TRADE_STATUS_CLOSE)count_TRADE_STATUS_CLOSE++;
         if(order.getTradeStatus()==TRADE_STATUS_ERROR)count_TRADE_STATUS_ERROR++;
         if(order.getTradeStatus()==TRADE_STATUS_ERROR_OPEN)count_TRADE_STATUS_ERROR_OPEN++;
         if(order.getTradeStatus()==TRADE_STATUS_ERROR_CLOSE)count_TRADE_STATUS_ERROR_CLOSE++;
         if(order.getErrorCode()>0)errorCount++; 
         if(order.getOrderType()==ORDER_TYPE_BUY)count_TRADE_BUY++;
         if(order.getOrderType()==ORDER_TYPE_SELL)count_TRADE_SELL++;
                       
      }       
      rkeeLog.printPeroidLog(logFile,2002,600,       
                           comFunc.getDate_YYYYMMDDHHMM2()
                           + "   equity:" +  AccountInfoDouble(ACCOUNT_EQUITY)                       
                           + "   marginFree:" + AccountInfoDouble(ACCOUNT_MARGIN_FREE) 
                           + "   hedgeRate:" + StringFormat("%.3f", logData.getCheckNValue("groupPool-bfRate"))
                           + "   posions:" + PositionsTotal()                           
                           + "   orders:" + orderList.Count()
                           + "   error:" + errorCount
                           + "   TRADE_PENDING:" + count_TRADE_STATUS_TRADE_PENDING
                           + "   TRADE_READY:" + count_TRADE_STATUS_TRADE_READY
                           + "   TRADE:" + count_TRADE_STATUS_TRADE
                           + "   CLOSE_READY:" + count_TRADE_STATUS_CLOSE_READY
                           + "   CLOSE_PART_READY:" + count_TRADE_STATUS_CLOSE_PART_READY
                           + "   CLOSE:" + count_TRADE_STATUS_CLOSE
                           + "   ERROR:" + count_TRADE_STATUS_ERROR
                           + "   ERROR_OPEN:" + count_TRADE_STATUS_ERROR_OPEN
                           + "   ERROR_CLOSE:" + count_TRADE_STATUS_ERROR_CLOSE
                           + "   BUY:" + count_TRADE_BUY
                           + "   SELL:" + count_TRADE_SELL);  
   }     
   
     
   //+------------------------------------------------------------------+
   //|  get symbol list info
   //+------------------------------------------------------------------+ 
   void    log_SymbolListInfo(string logFile){
   
      int  SymbolCount[SYMBOL_MAX_COUNT][2];      
      ArrayInitialize(SymbolCount,0);
      
      //test end
      //refresh error close
      CArrayList<COrder*>* orderList=this.shareCtl.getModelShare().getOrders();
      
      for (int i = 0; i < orderList.Count(); i++) {  
         COrder *order;
         orderList.TryGetValue(i,order);                     
         int symbolIndex=order.getSymbolIndex();
         if(order.getOrderType()==ORDER_TYPE_BUY){
            SymbolCount[symbolIndex][ORDER_TYPE_BUY]++;
         }
         if(order.getOrderType()==ORDER_TYPE_SELL){
            SymbolCount[symbolIndex][ORDER_TYPE_SELL]++;
         }         
      }
      
      string tempBuyList="",tempSellList="",tempIndTendList="";
      
      for(int i=0;i<SYMBOL_MAX_COUNT;i++){
         if(SymbolCount[i][ORDER_TYPE_BUY]>0 || SymbolCount[i][ORDER_TYPE_SELL]>0){
            tempBuyList+="<" + SYMBOL_LIST[i] + "-" + SymbolCount[i][ORDER_TYPE_BUY] + ">";  
            tempSellList+="<" + SYMBOL_LIST[i] + "-" + SymbolCount[i][ORDER_TYPE_SELL] + ">";
         }
         if(this.shareCtl.getIndicatorShare().getPriceSpeedStable(i)){
            tempIndTendList+="<" + SYMBOL_LIST[i] + "-stb>" ;
         }else{
            tempIndTendList+="<" + SYMBOL_LIST[i] + "-acc>" ;
         }
         
      }            
                           
      rkeeLog.printPeroidLog(logFile,2003,600,comFunc.getDate_YYYYMMDDHHMM2() + " buyList:" + tempBuyList);
      rkeeLog.printPeroidLog(logFile,2004,600,comFunc.getDate_YYYYMMDDHHMM2() + " sellList:" + tempSellList);
      rkeeLog.printPeroidLog(logFile,2005,600,comFunc.getDate_YYYYMMDDHHMM2() + tempIndTendList);
         
   }      
   
   //+------------------------------------------------------------------+
   //| make order list log
   //+------------------------------------------------------------------+  
   void  log_Models_Clean(string logFile){ 
                                               
     //+------------------------------------------------------------------+
     //| model clean test
     //+------------------------------------------------------------------+
      rkeeLog.closeDiff();
      rkeeLog.printLogLine(logFile,3001,10, "-----------------------");        
      int lineCount=logData.lineCount();
      int activeModelCount=logData.getPlusCount(0);
      int removeModelCount=logData.getPlusCount(1);
      rkeeLog.printLogLine(logFile,3001,10, comFunc.getDate_YYYYMMDDHHMM2() 
                  + " positions:" + PositionsTotal()
                  + " orders:" + shareCtl.getModelShare().getOrders().Count()      
                  + " activeModelCount:" + activeModelCount
                  + " removeModelCount:" + removeModelCount);      
      
      //if(removeModelCount>0){      
         for(int i=0;i<lineCount;i++){
            rkeeLog.printLogLine(logFile,3001,10, comFunc.getDate_YYYYMMDDHHMM2() 
                                          + " " + logData.getLine("runnerClean"+i));                        
         }
      //}
      rkeeLog.openDiff();
   
   }
   

   //+------------------------------------------------------------------+
   //| out put the trade open log
   //+------------------------------------------------------------------+  
   /*
   void  log_TradeOpen(string logFile){
     
     double openOrdersCount=logData.getCheckNValue("openTradeOrdersCount");  //---logData test 
     if(openOrdersCount>0){
         rkeeLog.closeDiff(); 
         rkeeLog.printLogLine(logFile,3002,10, comFunc.getDate_YYYYMMDDHHMM2() + " tradeOpen---------------------------");
         rkeeLog.printLogLine(logFile,3002,10, comFunc.getDate_YYYYMMDDHHMM2() + " OpenCount:" + openOrdersCount);
         rkeeLog.printLogLine(logFile,3002,10, comFunc.getDate_YYYYMMDDHHMM2() + " GroupPool-HedgeRate:" + StringFormat("%.3f", logData.getCheckNValue("groupPool-bfRate")));
         rkeeLog.printLogLine(logFile,3002,10, comFunc.getDate_YYYYMMDDHHMM2() + " posions:" + PositionsTotal());
         rkeeLog.printLogLine(logFile,3002,10, logData.getLine("openTradeOrders"));

      }                     
      rkeeLog.openDiff();                   
                         
      shareCtl.getModelShare().reSetOrderCount();
   }*/   
   
   
   //+------------------------------------------------------------------+
   //| out put the trade close log
   //+------------------------------------------------------------------+  
   void  log_TradeClose(string logFile){
      
      double extendRate=logData.getCheckNValue("extendRate");  //---logData test 
      double sumRate=logData.getCheckNValue("sumRate");  //---logData test 
      double edgeRate=logData.getCheckNValue("edgeRate");  //---logData test 
      double strengthRate=logData.getCheckNValue("strengthRate");  //---logData test
      
      string temp1="   filterClose02--"
                     + "<extendRate>" + StringFormat("%.2f",extendRate) 
                     + "<sumRate>" + StringFormat("%.2f",sumRate)
                     + "<edgeRate>" + StringFormat("%.2f",edgeRate)
                     + "<strengthRate>" + StringFormat("%.2f",strengthRate);
      
      rkeeLog.printLogLine(logFile,3003,600, comFunc.getDate_YYYYMMDDHHMM2() +  temp1);
      
      string temp2="----->";
      int lineCount=logData.lineCount();
      for(int i=0;i<lineCount;i++){         
         temp2+=logData.getLine("closeFilter02-" + i);            
      }      
      rkeeLog.printLogLine(logFile,3004,600, temp2);
   }
   
   
   //+------------------------------------------------------------------+
   //| out put the indicator status
   //+------------------------------------------------------------------+  
   void  log_Indicator(string logFile){
      
      double sumChlHeight=logData.getCheckNValue("sumChlHeight")/10000;
      double preSumChlHeight=logData.getCheckNValue("preSumChlHeight")/10000;
      //double sumRate=logData.getCheckNValue("sumRate"); 
      double preSumRate=logData.getCheckNValue("preSumRate"); 
      int    shiftN=this.shareCtl.getIndicatorShare().getPriceChlShiftLevel(28);        
      double sumRate=this.shareCtl.getIndicatorShare().getPriceChlSumEdgeRate(28); 
     // rkeeLog.printLogLine(logFile,3005,600, comFunc.getDate_YYYYMMDDHHMM2() + "   " +  logData.getLine("StrengthShift"));
      rkeeLog.printLogLine(logFile,3006,600, comFunc.getDate_YYYYMMDDHHMM2() 
                                 + "   <shiftN>" +  shiftN
                                 + "   <sumChlHeight>" +  StringFormat("%.2f",sumChlHeight)
                                 + "   <sumRate>" +  StringFormat("%.2f",sumRate)
                                 + "   <preSumChlHeight>" +  StringFormat("%.2f",preSumChlHeight)
                                 + "   <preSumRate>" +  StringFormat("%.2f",preSumRate)
                                 );
     // rkeeLog.printLogLine(logFile,3007,600, comFunc.getDate_YYYYMMDDHHMM2() + "   " +  logData.getLine("channelLevel"));

   }
      
   
   //+------------------------------------------------------------------+
   //| out put the hedge clear group log
   //+------------------------------------------------------------------+  
   void  log_HedgeClearData(string logFile){
      
      /*
      double clearCount=logData.getCheckNValue("clearCount");  //---logData test 
      if(clearCount>Clear_Order_Min_Count){
         rkeeLog.closeDiff(); 
         rkeeLog.printLogLine(logFile,3003,600, comFunc.getDate_YYYYMMDDHHMM2() +  "  ClearHedgeOrderData  Count: " + clearCount + ">");
         CArrayList<int>* groupIdList=this.shareCtl.getHedgeShare().getHedgeGroupIdList();  
         for (int i = 0; i < groupIdList.Count(); i++) {  
            int hedgeGroupId;
            if(groupIdList.TryGetValue(i,hedgeGroupId)){     
               string line=logData.getLine("" + hedgeGroupId);
               if(StringLen(line)>0){
                  rkeeLog.printLogLine(logFile,3003,600, line);            
               }            
            }
         } 
         rkeeLog.openDiff();
      }
      
      double clearCount2=logData.getCheckNValue("groupPoolClearCount");  //---logData test 
      if(clearCount2>Clear_Order_Min_Count){
         rkeeLog.closeDiff();     
         rkeeLog.printLogLine(logFile,3003,600, comFunc.getDate_YYYYMMDDHHMM2() +  " groupPoolClearCount: " + clearCount2 );
         string line2=logData.getLine("GroupPool");
         if(StringLen(line2)>0){
            rkeeLog.printLogLine(logFile,3003,600, comFunc.getDate_YYYYMMDDHHMM2() + " clearList> ");
            rkeeLog.printLogLine(logFile,3003,600, line2);            
         }
         rkeeLog.openDiff();      
      }  
      */
      //logData.reset();         
   }   
     
   //+------------------------------------------------------------------+
   //| out put the hedge clear group log
   //+------------------------------------------------------------------+  
   void  log_TradeClear(string logFile){
      
      double clearCount=logData.getCheckNValue("tradeClearCount");  //---logData test 
      if(clearCount>0){
         rkeeLog.closeDiff(); 
         rkeeLog.printLogLine(logFile,3005,600, comFunc.getDate_YYYYMMDDHHMM2() + " tradeClear---------------------------");
         rkeeLog.printLogLine(logFile,3005,600, comFunc.getDate_YYYYMMDDHHMM2() + " tradeClear:" + clearCount );
         rkeeLog.printLogLine(logFile,3005,600, comFunc.getDate_YYYYMMDDHHMM2() 
                                                + "  groupPool-bfRate:" + StringFormat("%.3f", logData.getCheckNValue("groupPool-bfRate"))
                                                + "  clear-afRate:" + StringFormat("%.3f", logData.getCheckNValue("groupPool-afRate")));         
         rkeeLog.printLogLine(logFile,3005,600, comFunc.getDate_YYYYMMDDHHMM2() + " posions:" + PositionsTotal());
         
         rkeeLog.printLogLine(logFile,3005,600, comFunc.getDate_YYYYMMDDHHMM2() + logData.getLine("tradeClear"));            

         rkeeLog.openDiff();      
      }
   }  
   
   //+------------------------------------------------------------------+
   //| debug test function
   //+------------------------------------------------------------------+   
   void debugReset(){
      if(rkeeLog.debugPeriod()){
         logData.clearDebugInfo();
      }
   }   
   void  printDebugLine(){
      CArrayList<string>* debugLines=logData.getDebugInfo();
      int lineCount=debugLines.Count();
      for (int i = 0; i < lineCount; i++) {  
         string debugLine;
         if(debugLines.TryGetValue(i,debugLine)){
            rkeeLog.writeLog("                   " + debugLine,DebugFile);
         }
      }   
   }
   void  printDebugInfo(string title){
      if(rkeeLog.debugPeriod()){
         rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2() + "----" + title + "-----begin" ,DebugFile);
         this.printDebugLine();
         rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2() + "----" + title + "-----end",DebugFile);
         this.debugReset();
      }
   }   

   
};

CLogger  logger;