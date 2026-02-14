//+------------------------------------------------------------------+
//|                                                  ATR_FI_Weighted |
//|                        Calculate weighted ATR and Force Index    |
//+------------------------------------------------------------------+
int ATR_Period = 64;               // ATR 周期
int ForceIndex_Period = 64;        // Force Index 周期
int EMA_Period = 64;               // 标准化用的 EMA 周期
double ATR_Weight = 1;           // ATR 权重
double ForceIndexRule = 100;    // Force Index 权重
double SmoothCount = 3;               // smooth Count

double maxATR=0;
double minATR=1000;

double maxForceIndex=0;
double minForceIndex=1000;

double maxSum=0;
double minSum=1000;

int curShiftN=-1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // 设置EA或初始化时输出一条信息
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Main Program Entry Point                                         |
//+------------------------------------------------------------------+
void OnTick()
{
    // 获取 ATR 和 Force Index 的值
    double atr = GetATR(0); // 当前 K 线的 ATR 值
    double forceIndex = GetForceIndex(0); // 当前 K 线的 Force Index 值

    if(atr<0)atr=0;

    // 计算 ATR 和 Force Index 的标准化值
    double atrStandardized = StandardizeATR(atr);
    double forceIndexStandardized = StandardizeForceIndex(forceIndex);

    // 取绝对值
    double atrAbsolute = MathAbs(atrStandardized);
    double forceIndexAbsolute = MathAbs(forceIndexStandardized);

    // 加权相加
    //double weightedValue = (ATR_Weight * atrAbsolute) + (ForceIndex_Weight * forceIndexAbsolute);
    
    double curAtr=ATR_Weight * atr;
    //double curForceIndex=ForceIndex_Weight * forceIndexAbsolute;
    double curForceIndex=MathAbs(forceIndex)/ForceIndexRule;
    
    if(curAtr>maxATR)maxATR=curAtr;
    if(curAtr<minATR)minATR=curAtr; 
    if(curForceIndex>maxForceIndex)maxForceIndex=curForceIndex;
    if(curForceIndex<minForceIndex)minForceIndex=curForceIndex;        
    
    double weightedValue = curAtr + curForceIndex;
    if(weightedValue>maxSum)maxSum=weightedValue;
    if(weightedValue<minSum)minSum=weightedValue;     
    
   static datetime openLastTime = 0; 
   datetime curTime=TimeCurrent();        
   if((curTime-openLastTime)>300) 
   {       
       openLastTime = curTime; 
       curShiftN= ShiftGear(curShiftN, weightedValue, 1, 12, 5, 0.5);
         
       printf("curShiftN:" + curShiftN            
               +  "  sum:" + weightedValue  
               +  "  atr:" + curAtr
               +  "  forceIndex:" + curForceIndex               
               +  "  minS:" + minSum
               +  "  maxS:" + maxSum               
               +  "  minA:" + minATR
               +  "  maxA:" + maxATR
               +  "  minI:" + minForceIndex
               +  "  maxI:" + maxForceIndex);
               
               
   }
        
}

//+------------------------------------------------------------------+
//| 获取 ATR 值                                                     |
//+------------------------------------------------------------------+
double GetATR(int shift)
{
    double atrBuffer[];
    ArraySetAsSeries(atrBuffer, true);
    int atrHandle = iATR(_Symbol, PERIOD_M5, ATR_Period);
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
double GetForceIndex(int shift)
{
    double forceIndexBuffer[];
    ArraySetAsSeries(forceIndexBuffer, true);
    int forceIndexHandle = iForce(_Symbol, PERIOD_M5, ForceIndex_Period, MODE_EMA, VOLUME_TICK);
    CopyBuffer(forceIndexHandle, 0, 0, ForceIndex_Period + 1, forceIndexBuffer);
    double sumforceIndex=0;
    for(int i=0;i<SmoothCount;i++){
      sumforceIndex+=forceIndexBuffer[i];
    }    
    return sumforceIndex/SmoothCount;
}

//+------------------------------------------------------------------+
//| 标准化 ATR 函数                                                  |
//+------------------------------------------------------------------+
double StandardizeATR(double atrValue)
{
    // 获取 ATR 的历史数据
    double atrBuffer[];
    ArraySetAsSeries(atrBuffer, true);
    int atrHandle = iATR(_Symbol, PERIOD_M15, ATR_Period);
    CopyBuffer(atrHandle, 0, 0, EMA_Period + 1, atrBuffer);

    // 计算 ATR 的移动平均值 (EMA)
    double emaATR = CalculateEMA(atrBuffer, EMA_Period);

    // 计算 ATR 的标准差
    double sumSquaredDiffATR = 0;
    for (int i = 0; i < EMA_Period; i++)
    {
        double diff = atrBuffer[i] - emaATR;
        sumSquaredDiffATR += diff * diff;
    }
    double stdDevATR = MathSqrt(sumSquaredDiffATR / EMA_Period);

    // 标准化 ATR
    if (stdDevATR != 0)
        return (atrValue - emaATR) / stdDevATR;
    else
        return 0;
}

//+------------------------------------------------------------------+
//| 标准化 Force Index 函数                                          |
//+------------------------------------------------------------------+
double StandardizeForceIndex(double forceIndexValue)
{
    // 获取 Force Index 的历史数据
    double forceIndexBuffer[];
    ArraySetAsSeries(forceIndexBuffer, true);
    int forceIndexHandle = iForce(_Symbol, PERIOD_M15, ForceIndex_Period, MODE_EMA, VOLUME_TICK);
    CopyBuffer(forceIndexHandle, 0, 0, EMA_Period + 1, forceIndexBuffer);

    // 计算 Force Index 的移动平均值 (EMA)
    double emaForceIndex = CalculateEMA(forceIndexBuffer, EMA_Period);

    // 计算 Force Index 的标准差
    double sumSquaredDiffForceIndex = 0;
    for (int i = 0; i < EMA_Period; i++)
    {
        double diff = forceIndexBuffer[i] - emaForceIndex;
        sumSquaredDiffForceIndex += diff * diff;
    }
    double stdDevForceIndex = MathSqrt(sumSquaredDiffForceIndex / EMA_Period);

    // 标准化 Force Index
    if (stdDevForceIndex != 0)
        return (forceIndexValue - emaForceIndex) / stdDevForceIndex;
    else
        return 0;
}

//+------------------------------------------------------------------+
//| 计算 EMA 的函数                                                  |
//+------------------------------------------------------------------+
double CalculateEMA(double& buffer[], int period)
{
    double alpha = 2.0 / (period + 1);
    double ema = buffer[0]; // 初始值为第一个数据点

    for (int i = 1; i < period; i++)
    {
        ema = (buffer[i] * alpha) + (ema * (1 - alpha));
    }

    return ema;
}

//+------------------------------------------------------------------+
//| 换挡函数                                                         |
//+------------------------------------------------------------------+
int ShiftGear(int shiftN, double speed, double minSpeed, double maxSpeed, int N, double downshiftDiff)
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