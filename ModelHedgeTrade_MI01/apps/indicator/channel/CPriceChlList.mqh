//+------------------------------------------------------------------+
//|                                                 IndicatorCtl.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../share/CShareCtl.mqh"
#include "../../comm/CLog.mqh"
#include "../../comm/ComFunc.mqh"
#include "../../comm/ComFunc2.mqh"

#include "../../header/CHeader.mqh"
#include "CPriceChlCom.mqh"

class CPriceChlList{
   private:
      CShareCtl*                 shareCtl;
      datetime                   refreshTime; 
      CPriceChlCom               channelLevel;      
      //channel control
      ENUM_TIMEFRAMES            channelTimeFrame;
      double                     edgeDiffChlWeight[];
      
      //test
      double                     preSumRate;
      double                     preSumChlHeight;
           
   public:
                        CPriceChlList();
                       ~CPriceChlList();
        //--- init 
        void            init(CShareCtl* shareCtl);
        //--- refresh relation data
        void            refresh();
        //--- run indicator
        void            run();
        //--- make sum jump pips
        void          makeChlSumData(int symbolIndex,
                                       int curShift,
                                       int maxShift,
                                       int diffShift);
  };
  
//+------------------------------------------------------------------+
//|  init the correlation class
//+------------------------------------------------------------------+
void CPriceChlList::init(CShareCtl* shareCtl)
{
   this.shareCtl=shareCtl;  
   this.channelLevel.init(this.shareCtl,Ind_Price_Chl_TimeFrame_Shift_Lv6,0);      
   comFunc.StringToDoubleArray(Ind_Price_Chl_Edge_Diff_Channle_Weight, edgeDiffChlWeight, ',');
}

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CPriceChlList::refresh(){

   //refresh diff time setting
   int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
   if(refreshDiffSeconds<IND_PCHANNEL_DIFF_SECONDS)return;
   
   logData.beginLine("<Channel>");
   
   int total_symbols = ArraySize(SYMBOL_LIST);   
   // Output weights for each symbol      
   for (int i = 0; i < total_symbols; i++){ 
      if(this.shareCtl.getSymbolShare().runable(i)){    
         
         double sumRate=0,sumChlHeight=0;   
         this.channelLevel.makeIndicatorData(i);
         sumRate+=this.channelLevel.getSumRate();
         sumChlHeight+=this.channelLevel.getSumChlHeight(); 
         string symbol=SYMBOL_LIST[i];
         double curPrice=this.shareCtl.getSymbolShare().getSymbolPrice(symbol,ORDER_TYPE_BUY);
         double point=this.shareCtl.getSymbolShare().getSymbolPoint(symbol);         
         
         if(rkeeLog.debugPeriod(9111,60)){
            // test begin
            string symbol=comFunc.addSuffix(SYMBOL_LIST[i]);      
            double curATR=comFunc2.GetATR(symbol,0,PERIOD_M1,24);
            double curStdDev=comFunc2.GetStdDev(symbol,0,PERIOD_M1,24);
            double sumAtrStdDev=curATR+curStdDev;
            int    adjustPeriod=(int)(comFunc2.mapValue(sumAtrStdDev,0,10,32,0));            
            //test end
            datetime curTime=TimeCurrent();
            CPriceChannelStatus* channelStatus=this.shareCtl.getIndicatorShare().getPriceChannelStatus(i,0);
            double jumpPips=comFunc.getJumpPips(channelStatus,curPrice,point);
            double jumpRate=comFunc.extendValue(MathAbs(jumpPips)/100,1.618);
            if(jumpPips<0)jumpRate=-jumpRate;
            double sumRate=channelStatus.getStrengthRate() 
                              + channelStatus.getEdgeRate() 
                              + jumpRate;
            
            string logTemp ="<sumRate>" + StringFormat("%.2f",sumRate)
                              + "<channelEdgeRate>" + StringFormat("%.2f",channelStatus.getEdgeRate())
                              + "<sumChlStrengthRate>" + StringFormat("%.2f",channelStatus.getStrengthRate())                              
                              + "<jumpRate>" + StringFormat("%.2f",jumpRate)
                              + "<jumpPips>" + StringFormat("%.2f",jumpPips)
                              + "<diffPips>" + StringFormat("%.2f",channelStatus.getEdgeBrkDiffPips())
                              + "<ATR>" + StringFormat("%.2f",curATR)
                              + "<StdDev>" + StringFormat("%.2f",curStdDev)
                              + "<SumAtrStdDev>" + StringFormat("%.2f",sumAtrStdDev)
                              + "<adjustPeriod>" + adjustPeriod;
                              
            rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"debugIndChannelData02");
            
         }                           
      }      
   }       
     
    
   //set the refresh time
   this.refreshTime=TimeCurrent();              
}

//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CPriceChlList::run(){
    this.refresh();
}
  

//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CPriceChlList::CPriceChlList(){
   this.refreshTime=0;
   this.preSumRate=100000000;
   this.preSumChlHeight=100000000;
}
CPriceChlList::~CPriceChlList(){}