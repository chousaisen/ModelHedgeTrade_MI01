//+------------------------------------------------------------------+
//|                                                 IndicatorCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../share/symbol/CSymbolShare.mqh"
#include "../../share/analysis/CAnalysisShare.mqh"

class CTrendSar{
   private:
      CSymbolShare*          symbolShare;
      CAnalysisShare*        analysisShare;  
      datetime               refreshTime; 
      //--- handle list
      int    Handles[SYMBOL_MAX_COUNT][3000];                
      //--- time frame
      ENUM_TIMEFRAMES  sarTimeFrame;
      double           sarMaxStep;
      double           sarStartStep;
      double           sarStepUnit;
      
      //--- current handle index
      int              curHandleIndex;
      int              maxHandleIndex;
      
   public:
                        CTrendSar();
                       ~CTrendSar();
        //--- init 
        void            init(CSymbolShare*  symbolShare,
                              CAnalysisShare*  analysisShare,
                                 ENUM_TIMEFRAMES  timeFrame,
                                 double sarStepUnit,
                                 double sarStartStep,
                                 double sarMaxStep);
        //-- make indicators handle
        void            makeIndicators(int symbolIndex);
        //--- get sar trend flag
        int             getSarTrendFlg(int symbolIndex,double step);
        //--- get sar data
        double          getSar(int symbolIndex,double step,int shift);
        
        //--- refresh relation data
        void            refresh();
        //--- run indicator
        void            run();
        
        //--- make sar support line data
        void            makeSarSupportLine(int symbolIndex);
        

  };
  
//+------------------------------------------------------------------+
//|  init the correlation class
//+------------------------------------------------------------------+
void CTrendSar::init(CSymbolShare*  symbolShare,
                        CAnalysisShare*  analysisShare,
                        ENUM_TIMEFRAMES  timeFrame,
                        double sarStepUnit,
                        double sarStartStep,
                        double sarMaxStep)
{
   this.symbolShare=symbolShare;  
   this.analysisShare=analysisShare;  
   this.sarTimeFrame=timeFrame;
   this.sarStepUnit=sarStepUnit;
   this.sarMaxStep=sarMaxStep;
   this.sarStartStep=sarStartStep;
   this.curHandleIndex=0;
   this.maxHandleIndex=0;
   
   int symbolCount=ArraySize(SYMBOL_LIST);
   for(int i=0;i<symbolCount;i++){  
      this.makeIndicators(i);
   }
 
}

//+------------------------------------------------------------------+
//|  make multi channel
//+------------------------------------------------------------------+
void CTrendSar::makeIndicators(int symbolIndex){
   if(this.symbolShare.runable(symbolIndex)){
     string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);  
     for(int i = 0; i < 1000; i++){
         double step=((double)(i))*this.sarStepUnit+this.sarStartStep;  
         Handles[symbolIndex][i] = iSAR(symbol, this.sarTimeFrame, step, this.sarMaxStep);
         if(Handles[symbolIndex][i] == INVALID_HANDLE){
            rkeeLog.printError(comFunc.getDate_YYYYMMDDHHMM2()
                                 + " CTrendSar Failed to create handle for period");
            return;
         }
         if(step>this.sarMaxStep){
            this.maxHandleIndex=i;
            break;
         }          
       }       
    }
}

//+------------------------------------------------------------------+
//|  get sar trend flag
//+------------------------------------------------------------------+
int  CTrendSar::getSarTrendFlg(int symbolIndex,double step){ 
   
   double sarCurrent = this.getSar(symbolIndex,step,0);        // 获取当前 SAR 值
   double sarPrevious = this.getSar(symbolIndex,step,1);       // 获取上一根 K 线的 SAR 值
   string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);
   double priceClose = iClose(symbol, this.sarTimeFrame,0);    // 获取当前收盘价
   
   // 判断趋势方向
   if (sarCurrent < priceClose && sarPrevious < priceClose) {
      return IND_TREND_UP;
   } else if (sarCurrent > priceClose && sarPrevious > priceClose) {
      return IND_TREND_DOWN;
   } else {
      if(sarCurrent > priceClose){
         return IND_TREND_DOWN;
      }else{
         return IND_TREND_UP;
      }
   }            
   return -1;    

}

//+------------------------------------------------------------------+
//|  get sar data
//+------------------------------------------------------------------+
double  CTrendSar::getSar(int symbolIndex,double step,int shift){ 
   
   this.curHandleIndex=(int)((step-this.sarStartStep)/this.sarStepUnit);
   int curHandle=this.Handles[symbolIndex][this.curHandleIndex];
   double sarBuffer[];   
   if (CopyBuffer(curHandle, 0, shift, 1, sarBuffer) > 0) {
      return sarBuffer[0];
   } else {
      Print("SAR 数据获取失败！ " + GetLastError());
      return 0;
   }
   
}

//+------------------------------------------------------------------+
//|  make sar support line data
//+------------------------------------------------------------------+
void  CTrendSar::makeSarSupportLine(int symbolIndex){ 
   
}

//+------------------------------------------------------------------+
//|  refresh
//+------------------------------------------------------------------+
void CTrendSar::refresh(){
   int total_symbols = ArraySize(SYMBOL_LIST);   
   // Output weights for each symbol      
   for (int i = 0; i < total_symbols; i++){ 
      if(this.symbolShare.runable(i)){      
         this.makeSarSupportLine(i);      
      }
   }       
}

//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CTrendSar::run(){
    rkeeLog.writeLmtLog("CTrendSar: run");   
    this.refresh();
}

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CTrendSar::CTrendSar(){
   this.refreshTime=0;
}
CTrendSar::~CTrendSar(){}