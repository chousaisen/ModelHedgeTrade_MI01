//+------------------------------------------------------------------+
//|                                                CFilterClose02I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../CModelFilter.mqh"

class CFilterClose02: public CModelFilter 
{
      public:
                      CFilterClose02();
                      ~CFilterClose02();                      
               bool   closeFilter(CModelI* model);
               bool   closeFilter(COrder* order);               
               bool   edgeBreakClose(CModelI* model,
                                          int symbolIndex,
                                          ENUM_ORDER_TYPE type,
                                          int chlIndex,
                                          double maxEdgeRate,
                                          double limitBreakPips);
};
  

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterClose02::closeFilter(CModelI* model)
{
   logData.addDebugInfo("<CFilterClose02-model>");
   int symbolIndex=model.getSymbolIndex();
   CIndicatorShare* indShare=this.getIndShare();
   double strengthRate=indShare.getStrengthRate(symbolIndex);
   double edgeRate=indShare.getEdgeRate(symbolIndex);
   double sumRate=strengthRate+edgeRate;   
   
   /*
   if(sumRate<GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE){
      if(model.getTradeType()==ORDER_TYPE_BUY)return true;
   }else if(sumRate>-GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE){
      if(model.getTradeType()==ORDER_TYPE_SELL)return true;
   } */  
   
   //double sumEdgeRate=indShare.getPriceChlSumEdgeRate(symbolIndex);
   double closeDiffExtendRate=GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE;
   /*
   if(MathAbs(sumEdgeRate)<=0.3)closeDiffExtendRate=9;   
   else if(MathAbs(sumEdgeRate)<=0.6)closeDiffExtendRate=8.5;
   else if(MathAbs(sumEdgeRate)<=0.9)closeDiffExtendRate=8;
   else if(MathAbs(sumEdgeRate)<=1.2)closeDiffExtendRate=7;
   else if(MathAbs(sumEdgeRate)<=1.5)closeDiffExtendRate=6.5;
   else if(MathAbs(sumEdgeRate)<=1.8)closeDiffExtendRate=6;
   else if(MathAbs(sumEdgeRate)<=2.1)closeDiffExtendRate=5;
   else if(MathAbs(sumEdgeRate)<=2.4)closeDiffExtendRate=4.5;
   else if(MathAbs(sumEdgeRate)<=2.7)closeDiffExtendRate=4;
   else if(MathAbs(sumEdgeRate)<=3)closeDiffExtendRate=3.5;
   else if(MathAbs(sumEdgeRate)<=3.3)closeDiffExtendRate=3;
   else if(MathAbs(sumEdgeRate)<=3.6)closeDiffExtendRate=2.5;
   else closeDiffExtendRate=2;   
   */
   
   /*
   if(MathAbs(sumEdgeRate)<=1.2)closeDiffExtendRate=12;
   else if(MathAbs(sumEdgeRate)<=1.5)closeDiffExtendRate=9;
   else if(MathAbs(sumEdgeRate)<=1.8)closeDiffExtendRate=7;
   else if(MathAbs(sumEdgeRate)<=2.1)closeDiffExtendRate=5;
   else if(MathAbs(sumEdgeRate)<=2.4)closeDiffExtendRate=4;
   else if(MathAbs(sumEdgeRate)<=2.7)closeDiffExtendRate=3;
   else if(MathAbs(sumEdgeRate)<=3)closeDiffExtendRate=3;
   else closeDiffExtendRate=2;   
   
   double extendRate=(MathAbs(sumRate)-closeDiffExtendRate)+1;   
   if(extendRate<1)extendRate=1;  
   extendRate=comFunc.extendValue(extendRate,GRID_CLOSE_DIFF_EXTEND_PLUS_RATE);
   double modelProfit=model.getProfit();   
   double modelCloseProfit=model.getCloseProfitPips();
   if(extendRate>1){
      modelCloseProfit=(modelCloseProfit*GRID_CLOSE_BREAK_EXTEND_RATE)*extendRate;
   }*/

   //logData.addCheckNValue("extendRate",extendRate);  //---logData test 
   //logData.addCheckNValue("sumRate",sumRate);  //---logData test 
   //logData.addCheckNValue("edgeRate",edgeRate);  //---logData test 
   //logData.addCheckNValue("strengthRate",strengthRate);  //---logData test       
      
   //string typeTemp="sell";
   //if(model.getTradeType()==ORDER_TYPE_BUY)typeTemp="buy";            
   
   /*   
   printf("closeFilter02>> "
             + "<lv>" + indShare.getPriceChlShiftLevel(symbolIndex)
             + "<sRate>" + StringFormat("%.2f",sumEdgeRate)
             + "<eRate>" + StringFormat("%.2f",sumRate)             
             + "<eBeginRate>" + closeDiffExtendRate
             + "<extendRate>" + StringFormat("%.2f",extendRate)
             + "<type>" + typeTemp             
             + "<mProfit>" + StringFormat("%.2f",modelProfit)
             + "<mCloseProfit>" + StringFormat("%.2f",modelCloseProfit));*/
   
   /*
   logData.beginLine("<type>" + typeTemp
                   + "<shiftLv>" + indShare.getPriceChlShiftLevel(symbolIndex)
                   + "<mProfit>" + StringFormat("%.2f",modelProfit)
                   + "<mCloseProfit>" + StringFormat("%.2f",modelCloseProfit)
                   + "<extendBegin>" + closeDiffExtendRate);      */
   
   double modelProfit=model.getProfit();   
   double modelCloseProfit=model.getCloseProfitPips();
   double edgeDiffPips=indShare.getPriceChlSumEdgeDiffPips(symbolIndex);
   
   double sumJumpPips=indShare.getPriceChlSumEdgeDiffPips(symbolIndex);
   double sumEdgeRate=indShare.getPriceChlSumEdgeRate(symbolIndex);     
   
   double strengthRate2=MathAbs(sumJumpPips/100);
   double extendRate=MathAbs((sumJumpPips/100)+sumEdgeRate)-GRID_CLOSE_DIFF_EXTEND_BEGIN_RATE;
   
   if(strengthRate2>3){
      modelCloseProfit=(modelCloseProfit*GRID_CLOSE_BREAK_EXTEND_RATE);
      if(extendRate>1){
         extendRate=comFunc.extendValue(extendRate,GRID_CLOSE_DIFF_EXTEND_PLUS_RATE);
         modelCloseProfit=modelCloseProfit*extendRate;
      }   
   }

   if(rkeeLog.debugPeriod(9091,60)){   
      //rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"debugLog01");
      //printf(logTemp);
      datetime t1=TimeCurrent();
      double a=0;
   }

   logData.addDebugInfo("<modelId>" + model.getModelId()
                           + "<sumJumpPips>" + StringFormat("%.2f",sumJumpPips)                              
                           + "<modelProfit>" + StringFormat("%.2f",modelProfit)
                           + "<modelCloseProfit>" + StringFormat("%.2f",modelCloseProfit)
                           + "<extendRate>" + StringFormat("%.2f",extendRate));

   bool retValue=true;      
   if(modelProfit<modelCloseProfit){
      if(sumJumpPips>100 && model.getTradeType()==ORDER_TYPE_BUY){         
         retValue=false;
      }else if(sumJumpPips<-100 && model.getTradeType()==ORDER_TYPE_SELL){
         retValue=false;
      }
   }
   
   /*
   bool retValue=true;      
   if(modelProfit<modelCloseProfit){
      if(sumRate>closeDiffExtendRate && model.getTradeType()==ORDER_TYPE_BUY){         
         retValue=false;
      }else if(sumRate<-closeDiffExtendRate && model.getTradeType()==ORDER_TYPE_SELL){
         retValue=false;
      }
   }
   logData.addCheckNValue("retValue",retValue);  //---logData test       
   logData.addLine("<close>" + retValue + "@@"); //---logData test       
   logData.saveLine("closeFilter02-" + logData.lineCount(),1000); //---logData test       
   */
   
   logData.addDebugInfo("<return>"+retValue+"</CFilterClose02-model>");
   
   return retValue;   
   
}


//+------------------------------------------------------------------+
//|  judge if edge break close
//+------------------------------------------------------------------+
bool  CFilterClose02::edgeBreakClose(CModelI* model,
                                             int symbolIndex,
                                             ENUM_ORDER_TYPE type,
                                             int chlIndex,
                                             double maxEdgeRate,
                                             double limitBreakPips){
   
   CPriceChlStatus*  priceChlStatus=this.getIndShare().getPriceChannelStatus2(symbolIndex);
   double edgeRate=priceChlStatus.getEdgeRate(chlIndex,0);   
   double edgeDiffPips=priceChlStatus.getEdgeBrkDiffPips(chlIndex);   
   double closeProfitRate=MathAbs(edgeDiffPips)/50;
   double modelCloseProfit=model.getCloseProfitPips()*closeProfitRate;
   if(type==ORDER_TYPE_BUY){
       if(edgeRate>=maxEdgeRate 
            && edgeDiffPips>limitBreakPips){         
         if(model.getProfitPips()<modelCloseProfit){
            return false;
         }
       }
   }else{
      if(edgeRate<=-maxEdgeRate 
         && edgeDiffPips<-limitBreakPips){
         if(model.getProfitPips()<modelCloseProfit){
            return false;   
         }
      }
   } 
   return true;   
}

//+------------------------------------------------------------------+
//|  filter the close order
//+------------------------------------------------------------------+
bool CFilterClose02::closeFilter(COrder* order)
{
   return true;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterClose02::CFilterClose02(){}
CFilterClose02::~CFilterClose02(){
}
 