//+------------------------------------------------------------------+
//|                                                CFilterOpen01I.mqh |
//+------------------------------------------------------------------+
#property version   "1.00"

#include "../CModelFilter.mqh"
#include "../../../header/CHeader.mqh"

class CFilterOpen01: public CModelFilter 
{
      public:
                CFilterOpen01();
                ~CFilterOpen01();                      
         bool   openFilter(CSignal* signal);
         bool   diffOtherSymbolModels(CSignal* signal);
};

//+------------------------------------------------------------------+
//|  filter the close model
//+------------------------------------------------------------------+
bool CFilterOpen01::openFilter(CSignal* signal)
{
   return this.diffOtherSymbolModels(signal);
}

//+------------------------------------------------------------------+
//|  judge grid diff pips
//+------------------------------------------------------------------+
bool CFilterOpen01::diffOtherSymbolModels(CSignal* signal){
   
   //get param
   int symbolIndex=signal.getSymbolIndex();
   ENUM_ORDER_TYPE type=signal.getTradeType();
   double  diffPips=signal.getSignalDiffPips();

   //CIndicatorShare* indShare=this.getIndShare();
   CPriceChannelStatus* priceChlStatus=this.getIndShare().getDiffPriceChannelStatus(symbolIndex,GRID_OPEN_CHL_SHIFT_DIFF);
   //double strengthRate=indShare.getStrengthRate(symbolIndex);
   double strengthRate=priceChlStatus.getStrengthRate();
   //double edgeRate=indShare.getEdgeRate(symbolIndex);
   double edgeRate=priceChlStatus.getEdgeRate();   
   
   double sumRate=strengthRate+edgeRate;
   double extendRate=(MathAbs(sumRate)-GRID_OPEN_DIFF_EXTEND_BEGIN_RATE)+1;
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
            logData.addLine("<curDiffPips>" + curDiffPips);
            if(curDiffPips<diffPips){
               return false;
            }            
          }                  
      }
   } 
   logData.addLine(")");
   return true;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CFilterOpen01::CFilterOpen01(){}
CFilterOpen01::~CFilterOpen01(){
}
 