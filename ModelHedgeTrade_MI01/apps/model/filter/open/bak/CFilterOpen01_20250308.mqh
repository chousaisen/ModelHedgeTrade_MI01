//+------------------------------------------------------------------+
//|                                                CFilterOpen01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../../../header/CHeader.mqh"
#include "../../../comm/ComFunc2.mqh"
#include "../CModelIndicatorFilter.mqh"

class CFilterOpen01: public CModelIndicatorFilter 
{
      public:
                CFilterOpen01();
                ~CFilterOpen01();                      
         bool   openFilter(CSignal* signal);
         
         //detail open filters         
         bool   openFilter01(CSignal* signal,CModelAnalysis* mAnalysis);
         bool   openFilter02(CSignal* signal);
         bool   openFilter03(CSignal* signal);
         bool   openFilter04(CSignal* signal);
                 
         
};

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter(CSignal* signal)
{
   
   if(rkeeLog.debugPeriod(9888,300)){   
      //rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"debugLog01");
      //printf(logTemp);
      datetime t1=TimeCurrent();
      double a=0;
   }   
   
   CModelAnalysis* mAnalysis=this.getModelShare().getModelAnalysis();
   mAnalysis.makeAnalysisData(28,this.getModelShare().getModels());
   
   ENUM_ORDER_TYPE curModelsExceedType=mAnalysis.getExtendType();
   double curModelsProfit=mAnalysis.getExceedCurProfit();
   double curModelsLossProfit=mAnalysis.getExceedCurLossProfit();
   double curModelsMaxProfit=mAnalysis.getExceedMaxProfit();
   double curModelsExceedRate=mAnalysis.getExceedRate();
   datetime topModelTime=mAnalysis.getExceedMaxTime();
   datetime rootModelTime=mAnalysis.getExceedRootTime();
   
   CArrayList<CModelI*>* extendModelList=mAnalysis.getExtendModelList();   
   
   CHedgeGroup* hedgePool=this.getHedgeShare().getHedgeGroupPool();
   double hedgeRate=hedgePool.getHedgeRate(); 
   bool   trendExtendTrade=false;  
   //if(hedgeRate>0.318){   
   /*
      int trendFlg=comFunc2.getSarTrendFlg();   
      if(trendFlg==1 || trendFlg==4){
         if(signal.getTradeType()==ORDER_TYPE_BUY)trendExtendTrade=true;
      }
      else if(trendFlg==2 || trendFlg==3){
         if(signal.getTradeType()==ORDER_TYPE_SELL)trendExtendTrade=true;
      }*/
   //}
   
   if(trendExtendTrade){
      if(curModelsMaxProfit>3000){
         double lossRate=(curModelsMaxProfit-curModelsProfit)/curModelsMaxProfit;
         if(lossRate>0.3){
            double curHedgeLot=this.openHedgeLot(signal,hedgePool);   
            if(curHedgeLot<=0)return false;          
         }
      }
      else if(rootModelTime>topModelTime){
         double curHedgeLot=this.openHedgeLot(signal,hedgePool);   
         if(curHedgeLot<=0)return false;                
      }   
      else if(curModelsExceedRate>0.3 && curModelsProfit<-1000){
         double curHedgeLot=this.openHedgeLot(signal,hedgePool);   
         if(curHedgeLot<=0)return false;
      }   
   }
   
   
   /*
   if(hedgePool.getHedgeGroupInfo().getHedgeOrderCount()>3){
      
      if(hedgeRate<0.318){
         double curHedgeLot=this.openHedgeLot(signal,hedgePool);   
         if(curHedgeLot<=0)return false;         
      }else if(hedgeRate<0.682 && !trendExtendTrade){
         double curHedgeLot=this.openHedgeLot(signal,hedgePool);   
         if(curHedgeLot<=0)return false;   
      }
      else if(hedgeRate>=0.682 && !trendExtendTrade){
         return false;
      }
   }*/
   
   //return true;
   //printf("hedgeRate:" + this.getHedgeShare().getHedgeGroupPool().getHedgeRate());
   /*
   if(this.getHedgeShare().getHedgeGroupPool().getHedgeRate()<0.9){   
      if(this.getHedgeShare().getHedgeGroupPool().ifGroupHedge(signal.getModelKind(),
                                                               signal.getSymbolIndex(),
                                                               signal.getTradeType(),
                                                               signal.getLot())){
         return true;
      }            
   }else{
      double sumJumpPips=this.getIndShare().getPriceChlSumEdgeDiffPips(signal.getSymbolIndex());
      double sumEdgeRate=this.getIndShare().getPriceChlSumEdgeRate(signal.getSymbolIndex());      
      double sumRate=sumJumpPips/100+sumEdgeRate;
      double strengthRate=sumJumpPips/100;      
      ENUM_ORDER_TYPE type=signal.getTradeType();   
      if(MathAbs(sumRate)>20){   
         if(type==ORDER_TYPE_BUY){
            if(sumRate>0)return true;
         }else{
            if(sumRate<0)return true;
         }         
      }   
   }   
   */
   if(!this.openFilter01(signal,mAnalysis))return false;   
   //if(!this.openFilter02(signal))return false; 
   //if(!this.openFilter03(signal))return false;
   //if(!this.openFilter04(signal))return false;
   return true;
}

//+------------------------------------------------------------------+
//|  judge grid diff pips
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter01(CSignal* signal,CModelAnalysis* mAnalysis){      
   
   //get param
   int symbolIndex=signal.getSymbolIndex();
   ENUM_ORDER_TYPE type=signal.getTradeType();
   double  diffPips=signal.getSignalDiffPips();

   //CIndicatorShare* indShare=this.getIndShare();
   //CPriceChannelStatus* priceChlStatus=this.getIndShare().getDiffPriceChannelStatus(symbolIndex,GRID_OPEN_CHL_SHIFT_DIFF);
   //double strengthRate=indShare.getStrengthRate(symbolIndex);
   //double strengthRate=priceChlStatus.getStrengthRate();
   //double edgeRate=indShare.getEdgeRate(symbolIndex);
   //double edgeRate=priceChlStatus.getEdgeRate();   
   
   //double sumRate=strengthRate+edgeRate;
   
   double sumJumpPips=this.getIndShare().getPriceChlSumEdgeDiffPips(symbolIndex);
   double sumEdgeRate=this.getIndShare().getPriceChlSumEdgeRate(symbolIndex);         
   double sumRate=(sumJumpPips/100)+sumEdgeRate;   
   
   //double extendRate=(MathAbs(sumRate)-GRID_OPEN_DIFF_EXTEND_BEGIN_RATE)+1;
   double extendRate=comFunc2.mapValue(MathAbs(sumRate),3,80,1,30);
   
   //double extendRate=(MathAbs(strengthRate)-GRID_OPEN_DIFF_EXTEND_BEGIN_RATE)+1;
   if(extendRate<1)extendRate=1;   
   if(type==ORDER_TYPE_BUY && sumRate<-GRID_OPEN_DIFF_EXTEND_BEGIN_RATE){
      extendRate=comFunc.extendValue(extendRate,GRID_OPEN_DIFF_EXTEND_PLUS_RATE);
      diffPips=extendRate*diffPips;
   }else if(type==ORDER_TYPE_SELL && sumRate>GRID_OPEN_DIFF_EXTEND_BEGIN_RATE){
      extendRate=comFunc.extendValue(extendRate,GRID_OPEN_DIFF_EXTEND_PLUS_RATE);
      diffPips=extendRate*diffPips;
   }

   logData.addLine("(diffOtherSymbolModels:");
   CArrayList<CModelI*> modelList=this.getModelShare().getModels();
   int modelCount=modelList.Count();   
   
   double hedgeAdjust=1;            
   double hedgeRate=this.getHedgeShare().getHedgeGroupPool().getHedgeRate();
   //double sumJumpPips=this.getIndShare().getPriceChlSumEdgeDiffPips(symbolIndex);
   logData.addLine("<hedgeRate>" + hedgeRate);
   if(this.getHedgeShare().getHedgeGroupPool().ifHedgeSymbolLot(symbolIndex,
                                                                  signal.getTradeType(),
                                                                  signal.getLot())>0){
      hedgeAdjust=comFunc2.mapValue(hedgeRate,0,1,0.1,1);
      logData.addLine("<hedge>OK<hedgeAdjust>" + hedgeAdjust);
   }
   /*
   else if(MathAbs(sumJumpPips)<=0){      
      hedgeAdjust=comFunc2.mapValue(hedgeRate,0,1,5,1);
   }*/
   else{      
      hedgeAdjust=comFunc2.mapValue(hedgeRate,0,1,5,1);
      logData.addLine("<hedge>NG<hedgeAdjust>" + hedgeAdjust);
   }
         
   double curModelsProfit=mAnalysis.getExceedCurProfit();
   double curModelsLossProfit=mAnalysis.getExceedCurLossProfit();
   double curModelsMaxProfit=mAnalysis.getExceedMaxProfit();
   double curModelsExceedRate=mAnalysis.getExceedRate();         
   
   if(curModelsExceedRate>0.2 && curModelsProfit<-500 ){
      diffPips=diffPips*hedgeAdjust;
   }else{
      diffPips=signal.getSignalDiffPips();
   }
   
   //clean model list
   for (int i = modelCount-1; i >=0 ; i--) {
      CModelI *model;      
      if(modelList.TryGetValue(i,model)){         
         if(model.getModelKind()==signal.getModelKind()
            && model.getSymbolIndex()==symbolIndex
            && model.getTradeType()==type){
            double curStartLine=model.getStartLine();
            if(curStartLine<=0)continue;
            double curSymbolPrice=model.getSymbolPrice();
            double curSymbolPoint=model.getSymbolPoint();
            double curDiffPips=MathAbs((curSymbolPrice-curStartLine)/curSymbolPoint);
            logData.addLine("<model>" + model.getModelId());
            logData.addLine("<type>" + model.getModelId());
            logData.addLine("<curDiffPips>" + curDiffPips);
            double adjustDiffPips=diffPips;
            if(type!=model.getTradeType()){
               adjustDiffPips=adjustDiffPips*2;
               //continue;
            }
            if(curDiffPips<adjustDiffPips){
               return false;
            }
          }                  
      }
   } 
   logData.addLine(")");
   return true;
}



//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter02(CSignal* signal)
{
      
   bool edgeBreakFlg= this.edgeBreakTend(signal.getSymbolIndex(),
                        signal.getTradeType(),
                        GRID_OPEN2_FILTER_EDGE_INDEX,
                        GRID_OPEN2_MAX_EDGE_RATE,
                        GRID_OPEN2_LIMIT_BRK_PIPS);
                        
   //if(rkeeLog.debugPeriod() && edgeBreakFlg){
   //   bool test1=true;
   //}  
   return edgeBreakFlg;
}


//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter03(CSignal* signal)
{
   
   double sumJumpPips=this.getIndShare().getPriceChlSumEdgeDiffPips(signal.getSymbolIndex());
   double sumEdgeRate=this.getIndShare().getPriceChlSumEdgeRate(signal.getSymbolIndex());

   double sumRate=sumJumpPips/100+sumEdgeRate;
   double strengthRate=sumJumpPips/100;
   
   ENUM_ORDER_TYPE type=signal.getTradeType();   
   if(MathAbs(sumJumpPips)<500){   
      if(type==ORDER_TYPE_BUY){
         if(sumRate<0 && sumRate>-30)return true;
      }else{
         if(sumRate>0 && sumRate<30)return true;
      }         
   }else{
      if(type==ORDER_TYPE_BUY){
         if(sumRate>25)return true;
      }else{
         if(sumRate<-25)return true;
      }      
   }
   return false;
}


//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter04(CSignal* signal)
{
   
      int    symbolIndex=signal.getSymbolIndex();
      ENUM_ORDER_TYPE type=signal.getTradeType();
 
      //judge protect symbol
      double checkRiskSumHedgeLots=Open_Order_Check_Risk_UnitNum*Comm_Unit_LotSize;
      double checkRiskHedgeLotRate=Open_Order_Check_Risk_HedgeRate;  
      logData.addLine("<checkRiskSumHedgeLots>" + checkRiskSumHedgeLots);            
      logData.addLine("<checkRiskHedgeLotRate>" + checkRiskHedgeLotRate);
      CHedgeGroup* hedgePool=this.getHedgeShare().getHedgeGroupPool();
      double sumJumpPips=this.getIndShare().getPriceChlSumEdgeDiffPips(signal.getSymbolIndex());
      if(!hedgePool.ifRiskProtect(symbolIndex,
                                    signal.getTradeType(),
                                    signal.getLot(),
                                    checkRiskSumHedgeLots,
                                    checkRiskHedgeLotRate)){
        return false;
      }
      //judge hedge correlation       
      //if(this.getHedgeFlg()){  
      if(hedgePool.getHedgeOrderCount()>12){ 
         //double sumEdgeRate=this.shareCtl.getIndicatorShare().getPriceChlSumEdgeRate(signal.getSymbolIndex());      
         if(sumJumpPips>1500 && type==ORDER_TYPE_BUY){
            return true;
         }
         else if(sumJumpPips<-1500 && type==ORDER_TYPE_SELL){
            return true;
         }
         else if(!hedgePool.ifGroupHedge(signal.getModelKind(),
                                       symbolIndex,
                                       signal.getTradeType(),
                                       signal.getLot())){
            return false;
         }
      }     
      
      return true;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterOpen01::CFilterOpen01(){}
CFilterOpen01::~CFilterOpen01(){
}
 