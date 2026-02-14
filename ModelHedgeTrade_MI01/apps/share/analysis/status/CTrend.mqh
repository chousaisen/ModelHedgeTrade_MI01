//+------------------------------------------------------------------+
//|                                                       CTrend.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\..\..\comm\CBase.mqh"
#include "..\..\symbol\CSymbolInfos.mqh"
#include "CWave.mqh"
#include "CRange.mqh"

class CTrend: public CBase{
  private:   
         CArrayList<CWave*>  waveList;          //wave list
         CWave               curWave;           //current wave
         double              beginLine;         //begin price
         double              peakLine;          //peak price 
         double              returnRate;        //current return rate
         double              returnMaxRate;     //current max return rate
         double              returnCurMaxRate;  //current max return rate
         double              returnPips;        //current return pips 
         double              returnMaxPips;     //current max return pips 
         double              returnCurMaxPips;  //current max return pips 
         double              trendPips;         //current trend pips
         double              trendProfitPips;   //trend profit pips(when trend end)
         bool                trendWaveFlg;      //trend wave flag
         int                 trendWaveCount;    //trend wave count
         double              trendWaveSumPips;  //trend wave pips sum
         double              curPrice;
         int                 symbolIndex;
         double              point;
         int                 statusFlg;
         CSymbolInfos*       symbolInfos;
         int                 trendIndex;         
         //CClientCtl*         clientCtl;
         
         //debug info (use to database table)
         string              debugDBInfo;
         string              debugDBInfoSlopeBegin;
         string              debugDBInfoWaveBegin;
         datetime            trendBeginTime;
         
         //break flg
         bool                breakFlg;
         //trend name
         string              trendName; 
         //
         //--- trend grid line
         double                 trendGridLine[];
         bool                   trendGridHit;
                  
  public:
                             CTrend();
                             ~CTrend();
         //--- init 
         void              init(CSymbolInfos* symbolInfos);
         //--- reset data         
         void              reSet(int symbolIndex);
         //--- refresh trend
         void              refresh();
         //--- begin trend
         void              begin(int symbolIndex,int statusFlg);
         //--- add wave
         void              addWave();
         //--- end trend  
         void              end();
         //--- make status
         void              makeStatus(int symbolIndex,CRange* range); 
         //--- make trend grid
         void              makeTrendGrid(int symbolIndex,
                                             double beginLine,
                                             double peakLine,
                                             double &trendGridLine[],
                                             double startPips,
                                             double gridDiffPips,
                                             double growRate,
                                             bool   &trendGridHit,
                                             int    statusFlg);
                                             
         //--- commom function -------------------         
         ENUM_ORDER_TYPE   getTradeType(int curStatusFlg);
         int               getStatusFlg(){return this.statusFlg;}         
         void              setDebugDBInfo(string tableInfo);          
         void              setBreak();         
         bool              getBreak();                  
         void              setTrendName(string trendName); 
         
         //--- commom fuction(getter/setter)
         bool              getTrendGridHit(){return this.trendGridHit;}
         double            getReturnRate(){return this.returnRate;}
         double            getTrendPips(){return this.trendPips;}  
};


//+------------------------------------------------------------------+
//| make trend grid line
//+------------------------------------------------------------------+
void CTrend::makeTrendGrid(int symbolIndex,
                           double beginLine,
                           double peakLine,
                           double &trendGridLine[],
                           double startPips,
                           double gridDiffPips,
                           double growRate,
                           bool   &trendGridHit,
                           int    statusFlg) {
    
    if(this.statusFlg==STATUS_RANGE_BREAK_UP 
            || this.statusFlg==STATUS_RANGE_BREAK_DOWN){
       
       // Get the symbol point value and current price
       //this.point = this.symbolInfos.getSymbolPoint(SYMBOL_LIST[symbolIndex]);
       double curPrice = this.symbolInfos.getSymbolPrice(SYMBOL_LIST[symbolIndex], ORDER_TYPE_BUY);
       
       // Initialize grid step size
       double currentStep = startPips * point;       
       // Initialize indices for upper and lower grid arrays
       int upperIndex = 0;           
       // Initialize hit flags
       trendGridHit = false;       
       // Generate grid prices starting from the upper boundary
       //double currentUpperPrice = beginLine - currentStep;
       double currentUpperPrice = beginLine;
       //if(statusFlg == STATUS_RANGE_BREAK_UP){
       //   currentUpperPrice = beginLine + currentStep;
       //}      
      if(statusFlg == STATUS_RANGE_BREAK_UP){      
         while (currentUpperPrice <= peakLine) {
              // Save the current price to the trendGridLine array
              ArrayResize(trendGridLine, upperIndex + 1);
              trendGridLine[upperIndex] = currentUpperPrice;              
              // Check if the current price is within gridDiffPips range of any upper grid line
              if (MathAbs(curPrice - trendGridLine[upperIndex]) <= gridDiffPips * point) {
                  trendGridHit = true;
              }
              // Calculate the next grid step size
              currentStep = comFunc2.getNextGridStep(upperIndex+ 1, startPips * point, growRate);              
              // Calculate the next grid price                      
              currentUpperPrice += currentStep;                            
              // Increment index
              upperIndex++;
          } 
       }else if(statusFlg == STATUS_RANGE_BREAK_DOWN){
         while (currentUpperPrice >= peakLine) {
              // Save the current price to the trendGridLine array
              ArrayResize(trendGridLine, upperIndex + 1);
              trendGridLine[upperIndex] = currentUpperPrice;              
              // Check if the current price is within gridDiffPips range of any upper grid line
              if (MathAbs(curPrice - trendGridLine[upperIndex]) <= gridDiffPips * point) {
                  trendGridHit = true;
              }              
              // Calculate the next grid step size
              currentStep = comFunc2.getNextGridStep(upperIndex+ 1, startPips * point, growRate);              
              // Calculate the next grid price        
              currentUpperPrice -= currentStep;
              // Increment index
              upperIndex++;
          }               
       }
   }       
}

//+------------------------------------------------------------------+
//| make status
//+------------------------------------------------------------------+
void CTrend::makeStatus(int symbolIndex,CRange* range){
      
   if(range.getStatusFlg()==STATUS_RANGE_BREAK_UP 
      && this.getStatusFlg()!=STATUS_RANGE_BREAK_UP){
      if(this.getStatusFlg()==STATUS_RANGE_BREAK_DOWN){
         this.refresh();
         this.end();
      }
      this.begin(symbolIndex,STATUS_RANGE_BREAK_UP);
   }else if(range.getStatusFlg()==STATUS_RANGE_BREAK_DOWN 
            && this.getStatusFlg()!=STATUS_RANGE_BREAK_DOWN){
      if(this.getStatusFlg()==STATUS_RANGE_BREAK_UP){
         this.refresh();
         this.end();
      }
      this.begin(symbolIndex,STATUS_RANGE_BREAK_DOWN);
   }else if(range.getStatusFlg()==STATUS_RANGE_BREAK_UP 
            && this.getStatusFlg()==STATUS_RANGE_BREAK_UP){
      this.refresh();      
   }else if(range.getStatusFlg()==STATUS_RANGE_BREAK_DOWN 
            && this.getStatusFlg()==STATUS_RANGE_BREAK_DOWN){
      this.refresh();
   }   
} 

//+------------------------------------------------------------------+
//|   debug info(database)
//+------------------------------------------------------------------+
void CTrend::setDebugDBInfo(string tableInfo){
   this.debugDBInfo=tableInfo;
}

//+------------------------------------------------------------------+
//|   set breal flag
//+------------------------------------------------------------------+
void CTrend::setBreak(void){
   this.breakFlg=true;
}

//+------------------------------------------------------------------+
//|   get breal flag
//+------------------------------------------------------------------+
bool CTrend::getBreak(void){
   return this.breakFlg;
}

//+------------------------------------------------------------------+
//|   debug info(database)
//+------------------------------------------------------------------+
void CTrend::setTrendName(string trendName){
   this.trendName=trendName;
}

//+------------------------------------------------------------------+
//|  init
//+------------------------------------------------------------------+
void CTrend::init(CSymbolInfos* symbolInfos){
   this.symbolInfos=symbolInfos;  
   this.statusFlg=STATUS_NONE; 
   this.trendIndex=0;
   this.debugDBInfo="";
   this.trendBeginTime=TimeCurrent();
   this.trendProfitPips=0;
   this.trendPips=0;
   this.breakFlg=false;
}

//+------------------------------------------------------------------+
//|  reset trend data
//+------------------------------------------------------------------+
void CTrend::reSet(int symbolIndex){
   this.symbolIndex=symbolIndex;
   this.curPrice=this.symbolInfos.getSymbolPrice(SYMBOL_LIST[this.symbolIndex],
                                                   this.getTradeType(statusFlg));
   this.point=this.symbolInfos.getSymbolPoint(SYMBOL_LIST[this.symbolIndex]);
   this.beginLine=this.curPrice; 
   this.peakLine=this.beginLine;
   this.trendPips=0;  
   this.trendProfitPips=0;
   this.returnRate=0;
   this.returnMaxRate=0;
   this.returnCurMaxRate=0;
   this.returnPips=0;
   this.returnMaxPips=0;
   this.returnCurMaxPips=0;
   this.trendWaveFlg=false;
   this.trendWaveSumPips=0;
   this.trendWaveCount=0;
   //clear wave list
   this.waveList.Clear();
   this.statusFlg=STATUS_NONE;
   this.trendBeginTime=TimeCurrent();
   this.breakFlg=false;
}

//+------------------------------------------------------------------+
//|  begin trend
//+------------------------------------------------------------------+
void CTrend::begin(int symbolIndex,int statusFlg){ 
   //reset data
   this.reSet(symbolIndex);
   this.symbolIndex=symbolIndex;
   this.statusFlg=statusFlg;
   this.trendIndex++; 
   this.debugDBInfoSlopeBegin=this.debugDBInfo;   
}

//+------------------------------------------------------------------+
//|  refresh trend
//+------------------------------------------------------------------+
void CTrend::refresh(){
   this.curPrice=this.symbolInfos.getSymbolPrice(SYMBOL_LIST[symbolIndex],
                                                   this.getTradeType(statusFlg));
   if(this.statusFlg==STATUS_RANGE_BREAK_UP){
      if(this.curPrice>this.peakLine){
         if(this.trendWaveFlg 
            && this.trendWaveCount>0){            
            this.addWave();            
         }      
         this.peakLine=this.curPrice;
         this.trendPips=(this.peakLine-this.beginLine)/point;
         this.trendWaveFlg=false;
         this.returnPips=0;
         this.returnCurMaxPips=0;
         this.returnRate=0;
         this.returnCurMaxRate=0;
      }else{
         this.returnPips=(this.peakLine-this.curPrice)/point;
      }
   }else if(this.statusFlg==STATUS_RANGE_BREAK_DOWN){
      if(this.curPrice<this.peakLine){
         if(this.trendWaveFlg 
            && this.trendWaveCount>0){
            this.addWave();
         }          
         this.peakLine=this.curPrice;
         this.trendPips=(this.beginLine-this.peakLine)/point;
         this.trendWaveFlg=false;
         this.returnPips=0;
         this.returnCurMaxPips=0;
         this.returnRate=0;
         this.returnCurMaxRate=0;     
      }else{
         this.returnPips=(this.curPrice-this.peakLine)/point;
      }     
   }   
   
   //wave return rate
   if(this.trendPips>0){
      this.returnRate=this.returnPips/this.trendPips;
      if(this.returnRate>this.returnCurMaxRate){
         this.returnCurMaxRate=this.returnRate;
         this.returnCurMaxPips=this.returnPips;         
         if(this.trendWaveFlg){
            if(this.returnCurMaxRate>this.returnMaxRate){
               this.returnMaxRate=this.returnCurMaxRate;
            }         
            if(this.returnCurMaxPips>this.returnMaxPips){
               this.returnMaxPips=this.returnCurMaxPips;
            }
         }
      }
   }   
   
   //trend wave judge
   if(!this.trendWaveFlg && this.trendPips>Trend_Begin_Min_Pips 
         && this.returnRate>Trend_Wave_Min_Return_Rate){         
         //if(this.trendWaveCount>0){            
         //   this.addWave();            
         //}          
         this.trendWaveFlg=true;
         this.trendWaveCount++;
         this.debugDBInfoWaveBegin=this.debugDBInfo;          
   }
   
   //make grid line
   this.makeTrendGrid(symbolIndex,
                           this.beginLine,
                           this.peakLine,
                           this.trendGridLine,
                           Trend_Grid_Start_Pips,
                           Trend_Grid_Diff_Pips,
                           Trend_Grid_Grow_Rate,
                           this.trendGridHit,
                           this.statusFlg);    
}

//+------------------------------------------------------------------+
//|  add wave
//+------------------------------------------------------------------+
void CTrend::addWave(void){
   if(!this.trendWaveFlg)return;
   CWave* wave=new CWave();   
   wave.setPeakLine(this.peakLine);
   wave.setReturnMaxPips(this.returnCurMaxPips);
   wave.setReturnMaxRate(this.returnCurMaxRate);
   wave.setSlopePips(this.trendPips); 
   wave.setWaveIndex(this.trendWaveCount);         
   this.waveList.Add(wave); 
   this.trendWaveSumPips+=this.returnCurMaxPips;
   
   string logTemp="<date_t>" + comFunc.getDate_YYYYMMDDHHMM()
                  + "<bTime_t>" + comFunc.getDate_YYYYMMDDHHMM(this.trendBeginTime)
                  + "<Status_t>" + this.getStatusInfo(this.statusFlg)
                  + "<trendIndex_i>" + this.trendIndex
                  + "<No_i>" + this.trendWaveCount
                  + "<returnMaxPips_d>" + StringFormat("%.2f",this.returnCurMaxPips)
                  + "<returnMaxRate_d>" + StringFormat("%.2f",this.returnCurMaxRate)
                  + "<trendPips_d>" + StringFormat("%.2f",this.trendPips)
                  + this.debugDBInfoWaveBegin;
      if(this.breakFlg){
         logTemp+="<breakFlg_i>1";
      }else{
         logTemp+="<breakFlg_i>0";
      }                  
   
   //this.clientCtl.getDB().saveData("WaveList" + this.trendName,logTemp);
   this.insertTable("WaveList" + this.trendName,logTemp);
   
   rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"trendList"); 
}

//+------------------------------------------------------------------+
//|  end trend
//+------------------------------------------------------------------+
void CTrend::end(){

   if(this.trendWaveFlg 
      && this.trendWaveCount>0){            
      this.addWave();            
   } 
   
   //calculate the trend profit pips
   if(this.statusFlg==STATUS_RANGE_BREAK_UP){
      this.trendProfitPips=(this.curPrice-this.beginLine)/this.point;
   }
   else if(this.statusFlg==STATUS_RANGE_BREAK_DOWN){
      this.trendProfitPips=(this.beginLine-this.curPrice)/this.point;
   }
       
   if(this.trendPips>0){
      string logTemp="<bTime_t>" + comFunc.getDate_YYYYMMDDHHMM(this.trendBeginTime)
                     + "<eTime_t>" + comFunc.getDate_YYYYMMDDHHMM()
                     + "<trendIndex_i>" + this.trendIndex
                     + "<WaveCount_i>" + this.trendWaveCount
                     + "<SlopePips_i>" + StringFormat("%.2f",this.trendPips)                     
                     + "<SlopeProfitPips_i>" + StringFormat("%.2f",this.trendProfitPips)
                     + "<returnMaxPips_i>" + StringFormat("%.2f",this.returnMaxPips)
                     + "<returnMaxRate_d>" + StringFormat("%.2f",this.returnMaxRate)
                     + "<beginLine_d>" + StringFormat("%.2f",this.beginLine)
                     + "<peakLine_d>" + StringFormat("%.2f",this.peakLine)
                     + "<WaveSumPips_d>" + StringFormat("%.2f",this.trendWaveSumPips)
                     + this.debugDBInfoSlopeBegin;
                     
      if(this.breakFlg){
         logTemp+="<breakFlg_i>1";
      }else{
         logTemp+="<breakFlg_i>0";
      }
      //this.clientCtl.getDB().saveData("SlopeList"+ this.trendName,logTemp);
      this.insertTable("SlopeList"+ this.trendName,logTemp);
      rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"trendList");
   }

   this.reSet(this.symbolIndex);
}

//+------------------------------------------------------------------+
// get trade type by trend type
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE CTrend::getTradeType(int curStatusFlg){
   if(curStatusFlg==STATUS_RANGE_BREAK_UP){
      return ORDER_TYPE_BUY;
   }
   else if(curStatusFlg==STATUS_RANGE_BREAK_DOWN){
      return ORDER_TYPE_SELL;
   }
   return NULL;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CTrend::CTrend(){
   this.trendWaveFlg=false;
}

CTrend::~CTrend(){}