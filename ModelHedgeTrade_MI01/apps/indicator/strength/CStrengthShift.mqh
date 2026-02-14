//+------------------------------------------------------------------+
//|                                                    CStrengthShift.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "../../header/CHeader.mqh"
#include "../../share/CShareCtl.mqh"

class CStrengthShift
  {
private:
      int               refreshTime;
      CShareCtl*        shareCtl;
      
      int ATR_Period;               // ATR 周期
      int ForceIndex_Period;        // Force Index 周期
      double ATR_Weight;           // ATR 权重
      double ForceIndexRule;    // Force Index 权重
      double SmoothCount;               // smooth Count
      //int curShiftN; 
           
public:
                        CStrengthShift();
                       ~CStrengthShift();
      void              init(CShareCtl* shareCtl);   
      void              refresh();
      void              run();
      
      //--- indicator function 
      void              makeIndicatorData(int symbolIndex);
      double            GetATR(string symbol);
      double            GetForceIndex(string symbol);
      
      //--- 换挡函数
      int               ShiftGear(int shiftN, 
                                 double speed, 
                                 double minSpeed, 
                                 double maxSpeed, 
                                 int N, 
                                 double downshiftDiff);

};

//+------------------------------------------------------------------+
//|  init the tick speed
//+------------------------------------------------------------------+
void CStrengthShift::init(CShareCtl* shareCtl)
{
   this.shareCtl=shareCtl;
   this.ATR_Period = Ind_Strength_Shift_Atr_Period;               // ATR 周期
   this.ForceIndex_Period = Ind_Strength_Shift_Force_Idx_Period;        // Force Index 周期
   this.ATR_Weight = Ind_Strength_Shift_Atr_Weight;           // ATR 权重
   this.ForceIndexRule = Ind_Strength_Shift_Force_Idx_Rule;    // Force Index 权重标尺
   this.SmoothCount = Ind_Strength_Shift_Avg_Smooth_Num;               // smooth Count
   //this.curShiftN=-1;       
}


//+------------------------------------------------------------------+
//|  refresh indicator data
//+------------------------------------------------------------------+
void CStrengthShift::refresh(){

   //refresh diff time setting
   int refreshDiffSeconds=TimeCurrent()-this.refreshTime;
   if(refreshDiffSeconds<IND_STRENGTH_SHIFT_DIFF_SECONDS)return;
   
   int total_symbols = ArraySize(SYMBOL_LIST);   
   // Output weights for each symbol      
   for (int i = 0; i < total_symbols; i++){ 
      if(this.shareCtl.getSymbolShare().runable(i)){       
         this.makeIndicatorData(i);
      }
   }
   //set the refresh time
   this.refreshTime=TimeCurrent();      
}

//+------------------------------------------------------------------+
//|  make multi indicator data 
//+------------------------------------------------------------------+
void CStrengthShift::makeIndicatorData(int symbolIndex){

   if(this.shareCtl.getSymbolShare().runable(symbolIndex)){
       string symbol=comFunc.addSuffix(SYMBOL_LIST[symbolIndex]);      
       // 获取 ATR 和 Force Index 的值
       double atr = GetATR(symbol); // 当前 K 线的 ATR 值
       double forceIndex = GetForceIndex(symbol); // 当前 K 线的 Force Index 值
   
       if(atr<0)atr=0;
       
       double curAtr=ATR_Weight * atr;
       //double curForceIndex=ForceIndex_Weight * forceIndexAbsolute;
       double curForceIndex=MathAbs(forceIndex)/ForceIndexRule;        
       double weightedValue = curAtr + curForceIndex;
       
       //if(rkeeLog.debugPeriod(9991,100)){
       //  int a=1;
       //}
              
       int preShiftN=this.shareCtl.getIndicatorShare().getPriceChlShiftLevel(symbolIndex);            
       int curShiftN= ShiftGear(preShiftN, 
                                 weightedValue, 
                                 Ind_Strength_Shift_Min_Speed, 
                                 Ind_Strength_Shift_Max_Speed, 
                                 Ind_Strength_Shift_Count, 
                                 Ind_Strength_Shift_Diff_Rate); 
                              
       //printf("curShiftN:" + curShiftN 
       //           + " preShiftN:" + preShiftN 
       //           + " weightedValue:" + weightedValue);  
       
       logData.beginLine("<StrengthShift>" 
                           + "<curShift>" + curShiftN
                           + "<sum>" + weightedValue
                           + "<curAtr>" + curAtr
                           + "<forceIndex>" + MathAbs(forceIndex));
                                   
       logData.saveLine("StrengthShift",100);
       
       this.shareCtl.getIndicatorShare().setPriceChlShiftLevel(symbolIndex,curShiftN);

   }
}

//+------------------------------------------------------------------+
//|  run the muti indicators
//+------------------------------------------------------------------+
void CStrengthShift::run(){
    this.refresh();
}



//+------------------------------------------------------------------+
//| 获取 ATR 值                                                     |
//+------------------------------------------------------------------+
double CStrengthShift::GetATR(string symbol)
{
    double atrBuffer[];
    ArraySetAsSeries(atrBuffer, true);
    int atrHandle = iATR(symbol, PERIOD_M5, ATR_Period);
    CopyBuffer(atrHandle, 0, 0, ATR_Period + 1, atrBuffer);
    double sumAtr=0;
    for(int i=0;i<SmoothCount;i++){
      sumAtr+=atrBuffer[i];
    }
    return sumAtr/SmoothCount;
}

//+------------------------------------------------------------------+
//| 获取 Force Index 值                                             |
//+------------------------------------------------------------------+
double CStrengthShift::GetForceIndex(string symbol)
{
    double forceIndexBuffer[];
    ArraySetAsSeries(forceIndexBuffer, true);
    int forceIndexHandle = iForce(symbol, PERIOD_M5, ForceIndex_Period, MODE_EMA, VOLUME_TICK);
    CopyBuffer(forceIndexHandle, 0, 0, ForceIndex_Period + 1, forceIndexBuffer);
    double sumforceIndex=0;
    for(int i=0;i<SmoothCount;i++){
      sumforceIndex+=forceIndexBuffer[i];
    }    
    return sumforceIndex/SmoothCount;
}


//+------------------------------------------------------------------+
//| 换挡函数                                                         |
//+------------------------------------------------------------------+
int  CStrengthShift::ShiftGear(int shiftN, 
                                 double speed, 
                                 double minSpeed, 
                                 double maxSpeed, 
                                 int N, 
                                 double downshiftDiff)
{
    // 1. 计算每个档位的速度区间
    double speedRange = maxSpeed - minSpeed; // 速度范围
    double gearRange = speedRange / N;       // 每个档位的速度区间

    // 2. 如果当前档位未初始化 (shiftN <= 0)，根据速度计算初始档位
    if (shiftN <= 0)
    {
        for (int i = 1; i <= N; i++)
        {
            if (speed <= minSpeed + i * gearRange)
            {
                shiftN = i;
                break;
            }
        }
        return shiftN;
    }

    // 3. 如果当前档位已初始化 (shiftN > 0)，判断是否需要换挡
    double currentGearMin = minSpeed + (shiftN - 1) * gearRange; // 当前档位的最小速度
    double currentGearMax = minSpeed + shiftN * gearRange;       // 当前档位的最大速度

    // 3.1 如果速度超过当前档位的上限，升档
    if (speed > currentGearMax)
    {
        shiftN = shiftN + 1;
        if (shiftN > N) // 确保档位不超过最大档位
            shiftN = N;
        return shiftN;
    }

    // 3.2 如果速度低于当前档位的下限，并超过降档阈值，降档
    double downshiftThreshold = currentGearMin - (gearRange * downshiftDiff / 100.0); // 降档阈值
    if (speed < downshiftThreshold)
    {
        shiftN = shiftN - 1;
        if (shiftN < 1) // 确保档位不低于最小档位
            shiftN = 1;
        return shiftN;
    }

    // 4. 如果不需要换挡，返回当前档位
    return shiftN;
}
//+------------------------------------------------------------------+
//|  class constructor                                         
//+------------------------------------------------------------------+
CStrengthShift::CStrengthShift()
{
   this.refreshTime=0;
}
CStrengthShift::~CStrengthShift(){}