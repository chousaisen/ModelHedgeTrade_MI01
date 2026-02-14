//+------------------------------------------------------------------+
//|                                                     CommFunc.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include "..\header\CHeader.mqh"

class ComFunc2
{
   private:
   public:
      // Constructor
      ComFunc2();

      // Destructor
      ~ComFunc2();
         
      //+------------------------------------------------------------------+
      //| map value(out value by input value range)
      //+------------------------------------------------------------------+         
      double mapValue(double value, double inputBegin, double inputEnd, double outputBegin, double outputEnd)
      {
          // 确保inputBegin小于inputEnd
          if (inputBegin >= inputEnd)
          {
              Print("Error: inputBegin must be less than inputEnd");
              return 0.0;
          }
      
          // 如果value小于inputBegin，返回outputBegin
          if (value <= inputBegin)
          {
              return outputBegin;
          }
          // 如果value大于inputEnd，返回outputEnd
          else if (value >= inputEnd)
          {
              return outputEnd;
          }
          // 否则，计算线性映射的值
          else
          {
              // 计算输入范围的比例
              double inputRange = inputEnd - inputBegin;
              double outputRange = outputEnd - outputBegin;
              
              // 计算value在输入范围内的比例
              double scale = (value - inputBegin) / inputRange;
              
              // 返回映射到输出范围的值
              return outputBegin + (scale * outputRange);
          }
      }  

      //+------------------------------------------------------------------+
      //| map value(out value by input value range)
      //+------------------------------------------------------------------+
      double mapExtValue(double value, 
                        double inputBegin, 
                        double inputEnd, 
                        double outputBegin, 
                        double outputEnd, 
                        double acceleration = 1.0)
      {
          // 确保inputBegin小于inputEnd
          if (inputBegin >= inputEnd)
          {
              Print("Error: inputBegin must be less than inputEnd");
              return 0.0;
          }
      
          // 如果value小于inputBegin，返回outputBegin
          if (value <= inputBegin)
          {
              return outputBegin;
          }
          // 如果value大于inputEnd，返回outputEnd
          else if (value >= inputEnd)
          {
              return outputEnd;
          }
          // 否则，计算非线性映射的值
          else
          {
              // 计算输入范围的比例
              double inputRange = inputEnd - inputBegin;
              double outputRange = outputEnd - outputBegin;
              
              // 计算value在输入范围内的比例
              double scale = (value - inputBegin) / inputRange;
              
              // 使用指数函数实现加速效果
              scale = pow(scale, acceleration);
              
              // 返回映射到输出范围的值
              return outputBegin + (scale * outputRange);
          }
      }

      //+------------------------------------------------------------------+
      //| map Curved value(out value by input value range)
      //|  
      //+------------------------------------------------------------------+
      double getCurvedValue(double curvature, 
                             double inputValue,                              
                             double inputBegin, 
                             double inputEnd,
                             double outputBegin, 
                             double outputEnd)
      {
          // 确保输入范围有效
          if (outputBegin >= outputEnd || inputBegin >= inputEnd)
          {
              Print("Error: Invalid input ranges. outputBegin must be less than outputEnd, and inputBegin must be less than inputEnd.");
              return 0.0;
          }
      
          // 确保 inputValue 在 X 轴范围内
          // 确保 inputValue 在 X 轴范围内
          if (inputValue < inputBegin){
            inputValue=inputBegin;
          }
          else if (inputValue > inputEnd){
            inputValue=inputEnd;
          }
      
          // 计算直线上的 Y 值
          double linearY = outputBegin + ((inputValue - inputBegin) / (inputEnd - inputBegin)) * (outputEnd - outputBegin);
      
          // 计算弧线的 Y 值
          // 使用指数函数模拟曲率
          double scale = (inputValue - inputBegin) / (inputEnd - inputBegin); // X 轴比例
          double curvedScale = pow(scale, curvature); // 曲率调整
          double curvedY = outputBegin + (outputEnd - outputBegin) * curvedScale; // 映射到 Y 轴
      
          // 返回弧线上的 Y 值
          return curvedY;
      }
      
      //+------------------------------------------------------------------+
      //| map Curved Fibonacci value(out value by input value range)
      //+------------------------------------------------------------------+      
      double getFibonacciCurvedValue(double phi, 
      									double inputValue, 
      									double inputBegin, 
      									double inputEnd,
      									double outputBegin, 
      									double outputEnd)
      {
          // 确保输入范围有效
          if (outputBegin >= outputEnd || inputBegin >= inputEnd)
          {
              Print("Error: Invalid input ranges. a must be less than b, and c must be less than d.");
              return 0.0;
          }
      
          // 确保 x 在 X 轴范围内
          if (inputValue < inputBegin){
            inputValue=inputBegin;
          }
          else if (inputValue > inputEnd){
            inputValue=inputEnd;
          }
      
          // 计算 X 轴比例
          double scale = (inputValue - inputBegin) / (inputEnd - inputBegin);
      
          // 使用黄金比例（φ ≈ 1.618）模拟斐波那契增长
          //double phi = 1.618; // 黄金比例
          double fibonacciScale = (pow(phi, scale) - 1) / (phi - 1); // 模拟斐波那契增长
      
          // 映射到 Y 轴
          double curvedY = outputBegin + (outputEnd - outputBegin) * fibonacciScale;
      
          // 返回弧线上的 Y 值
          return curvedY;
      }     
      
      //+------------------------------------------------------------------+
      //| 计算下一个网格步长，基于斐波那契增长逻辑
      //+------------------------------------------------------------------+
      double getNextGridStep(int gridIndex,        // 当前网格的索引（从0开始）
                             double startStep,     // 初始步长
                             double growRate,      // 增长比例（例如黄金比例1.618）
                             double maxStep = 0.0) // 最大步长限制（可选，0表示无限制）
      {
      
          if(growRate<=1)return startStep;
          // 确保输入参数有效
          if (gridIndex < 0 || startStep <= 0 || growRate < 1.0) {
              Print("Error: Invalid input parameters. gridIndex(" + gridIndex + ") must be >= 0, startStep("+startStep+") > 0, and growRate("+growRate+") > 1.0.");
              return startStep; // 返回初始步长作为默认值
          }
      
          // 计算斐波那契增长比例
          double fibonacciScale = (pow(growRate, gridIndex) - 1) / (growRate - 1);
      
          // 计算下一个步长
          double nextStep = startStep * fibonacciScale;
      
          // 如果设置了最大步长限制，则确保步长不超过最大值
          if (maxStep > 0 && nextStep > maxStep) {
              nextStep = maxStep;
          }
      
          return nextStep;
      }      
      
      //+------------------------------------------------------------------+
      //| 获取指定 shift 的 ATR 值
      //+------------------------------------------------------------------+        
      double GetATR(string symbol,int shift,ENUM_TIMEFRAMES timeFrame,int period) {
         double atrBuffer[];
         int handle = iATR(symbol,timeFrame,period);
      
         if (CopyBuffer(handle, 0, shift, 1, atrBuffer) > 0) {
            return atrBuffer[0];
         } else {
            Print("ATR 数据获取失败！");
            return 0;
         }
      }
      
      //+------------------------------------------------------------------+
      //| 获取指定 shift 的 iVolumes 值
      //+------------------------------------------------------------------+        
      double getVolume(string symbol, int shift, ENUM_TIMEFRAMES timeFrame, ENUM_APPLIED_VOLUME volumeType)
      {
          // 定义缓冲区存储成交量值
          double volumeBuffer[];
          
          // 获取成交量指标的句柄
          int handle = iVolumes(symbol, timeFrame, volumeType);
          
          // 检查句柄是否有效
          if (handle == INVALID_HANDLE)
          {
              Print("错误：无法创建成交量指标句柄！错误代码：", GetLastError());
              return 0;
          }
          
          // 复制指标数据到缓冲区
          if (CopyBuffer(handle, 0, shift, 1, volumeBuffer) <= 0)
          {
              Print("成交量数据获取失败！错误代码：", GetLastError());
              return 0;
          }
          
          // 返回指定 shift 的成交量值
          return volumeBuffer[0];
      }      
      
      //+------------------------------------------------------------------+
      //| 获取指定 shift 的 ATR 值
      //+------------------------------------------------------------------+        
      double GetStdDev(string symbol,int shift,ENUM_TIMEFRAMES timeFrame,int period) {
         double stdDevBuffer[];
         int handle = iStdDev(symbol,timeFrame,period,shift,MODE_SMA,MODE_LWMA);      
         if (CopyBuffer(handle, 0, shift, 1, stdDevBuffer) > 0) {
            return stdDevBuffer[0];
         } else {
            Print("StdDev 数据获取失败！");
            return 0;
         }
      }   
               
      //+------------------------------------------------------------------+
      //| 获取从当前0位置开始，获取N个shift位置的变化量的合计（带方向性）
      //+------------------------------------------------------------------+
      double GetSumOfStdDevChanges(string symbol, int shift, ENUM_TIMEFRAMES timeFrame, int period) {
          double stdDevBuffer[]; // 存储指标值的数组
          double sumOfChanges = 0.0;
      
          // 获取 iStdDev 指标句柄
          int handle = iStdDev(symbol, timeFrame, period, 0, MODE_SMA, PRICE_CLOSE);
          if (handle == INVALID_HANDLE) {
              Print("iStdDev 指标句柄获取失败！");
              return 0;
          }
      
          // 复制指标值到数组
          if (CopyBuffer(handle, 0, 0, shift + 1, stdDevBuffer) > 0) {
              // 计算变化量的合计（带方向性）
              for (int i = 0; i < shift; i++) {
                  sumOfChanges += (stdDevBuffer[i + 1]-stdDevBuffer[i]); // 差值有方向性
              }
              return sumOfChanges;
          } else {
              Print("iStdDev 数据获取失败！");
              return 0;
          }
      }   
      
      //+------------------------------------------------------------------+
      //| 获取从当前0位置开始，获取N个shift位置的变化量的合计（基于iATR，带方向性）
      //+------------------------------------------------------------------+
      double GetSumOfATRChanges(string symbol, int shift, ENUM_TIMEFRAMES timeFrame, int period) {
          double atrBuffer[]; // 存储ATR指标值的数组
          double sumOfChanges = 0.0;
      
          // 获取 iATR 指标句柄
          int handle = iATR(symbol, timeFrame, period);
          if (handle == INVALID_HANDLE) {
              Print("iATR 指标句柄获取失败！");
              return 0;
          }
      
          // 复制ATR指标值到数组
          if (CopyBuffer(handle, 0, 0, shift + 1, atrBuffer) > 0) {
              // 计算变化量的合计（带方向性）
              for (int i = 0; i < shift; i++) {
                  sumOfChanges += (atrBuffer[i + 1]-atrBuffer[i]); // 差值有方向性
              }
              return sumOfChanges;
          } else {
              Print("iATR 数据获取失败！");
              return 0;
          }
      }    
      
     //+------------------------------------------------------------------+
      //| 获取指定 shift 的 iBullsPower 值
      //+------------------------------------------------------------------+ 
      double getBullsPower(string symbol,ENUM_TIMEFRAMES TimeFrame,int period) {
         double bullsPowerBuffer[];
         int handle = iBullsPower(symbol, TimeFrame, period);
      
         if (CopyBuffer(handle, 0, 0, 1, bullsPowerBuffer) > 0) {
            return bullsPowerBuffer[0];
         } else {
            Print("iBullsPower 数据获取失败！");
            return 0;
         }
      }        
      
      //+------------------------------------------------------------------+
      //| 获取指定 shift 的 SAR 值
      //+------------------------------------------------------------------+ 
      double GetSAR(string symbol,int shift) {
         double sarBuffer[];
         int handle = iSAR(symbol, PERIOD_M1, 0.002, 0.3);
      
         if (CopyBuffer(handle, 0, shift, 1, sarBuffer) > 0) {
            return sarBuffer[0];
         } else {
            Print("SAR 数据获取失败！");
            return 0;
         }
      }          
        
     //+------------------------------------------------------------------+
      //| 获取指定 shift 的 SAR 值
      //+------------------------------------------------------------------+        
      double GetSAR(string symbol,int shift,double step) {
         double sarBuffer[];
         int handle = iSAR(symbol, PERIOD_M1, step, 0.6);
         
         if (handle == INVALID_HANDLE) {
            Print("iSAR 初始化失败！错误代码：", GetLastError());
            return 0;
         }         
         
         if (CopyBuffer(handle, 0, shift, 1, sarBuffer) > 0) {
            return sarBuffer[0];
         } else {
            Print("SAR 数据获取失败！ " + GetLastError());
            return 0;
         }
      }         
      
     //+------------------------------------------------------------------+
      //| 获取指定 shift 的 SAR 值
      //+------------------------------------------------------------------+        
      double GetSAR(string symbol,ENUM_TIMEFRAMES TimeFrame,double step,int shift) {
         double sarBuffer[];
         //string curSymbol=symbol;
         //ENUM_TIMEFRAMES timeFrame=Ind_Sar_TimeFrame;
         //double maxStep=Ind_Sar_Max_Step;
         int handle = iSAR(symbol, TimeFrame, step, 0.6);
         
         if (handle == INVALID_HANDLE) {
            Print("iSAR 初始化失败！错误代码：", GetLastError());
            return 0;
         }         
         
         if (CopyBuffer(handle, 0, shift, 1, sarBuffer) > 0) {
            return sarBuffer[0];
         } else {
            Print("SAR 数据获取失败！ " + GetLastError());
            return 0;
         }
      }               
        
      //+------------------------------------------------------------------+
      //| 获取指定 tredn flag by SAR value
      //+------------------------------------------------------------------+        
      int getSarTrendFlg(string symbol,ENUM_TIMEFRAMES TimeFrame,double step){
      
         double sarCurrent = GetSAR(symbol,TimeFrame,step,0);  // 获取当前 SAR 值
         double sarPrevious = GetSAR(symbol,TimeFrame,step,1); // 获取上一根 K 线的 SAR 值
         double priceClose = iClose(symbol, TimeFrame, 0); // 获取当前收盘价
      
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
      //| 获取指定 tredn flag by SAR value
      //+------------------------------------------------------------------+        
      int getSarTrendFlg(string symbol){
      
         double sarCurrent = GetSAR(symbol,0);  // 获取当前 SAR 值
         double sarPrevious = GetSAR(symbol,1); // 获取上一根 K 线的 SAR 值
         double priceClose = iClose(Symbol(), PERIOD_M1, 0); // 获取当前收盘价
      
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
      //| 获取指定 tredn flag by SAR value
      //+------------------------------------------------------------------+        
      int getSarTrendFlg(string symbol,double step){
      
         double sarCurrent = GetSAR(symbol,0,step);  // 获取当前 SAR 值
         double sarPrevious = GetSAR(symbol,1,step); // 获取上一根 K 线的 SAR 值
         //double sarCurrent = GetSAR(symbol,0);  // 获取当前 SAR 值
         //double sarPrevious = GetSAR(symbol,1); // 获取上一根 K 线的 SAR 值
         
         double priceClose = iClose(Symbol(), Ind_Sar_TimeFrame, 0); // 获取当前收盘价
      
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
      //| 计算 Calculate Velocity 抛物线速度
      //+------------------------------------------------------------------+              
      double calculateVelocity(double value1, datetime t1, double value2, datetime t2, double value3, datetime t3)
      {
          // 计算时间差（秒）
          double deltaT1 = (double)(t2 - t3); // t_{N-1} - t_N
          double deltaT0 = (double)(t1 - t3); // t_{N-2} - t_N
      
          // 计算高度差
          double deltaH1 = value2 - value3; // h_{N-1} - h_N
          double deltaH0 = value1 - value3; // h_{N-2} - h_N
      
          // 计算系数 b（速度）
          double denominator = deltaT1 * deltaT1 * deltaT0 - deltaT0 * deltaT0 * deltaT1;
          if (denominator == 0) return 0; // 避免除零错误
      
          double b = (deltaH0 * deltaT1 * deltaT1 - deltaH1 * deltaT0 * deltaT0) / denominator;
      
          return b; // 返回速度
      }
      
      //+------------------------------------------------------------------+
      //| 计算 Calculate Velocity 抛物线加速度
      //+------------------------------------------------------------------+ 
      double calculateAcceleration(double value1, datetime t1, double value2, datetime t2, double value3, datetime t3)
      {
          // 计算时间差（秒）
          double deltaT1 = (double)(t2 - t3); // t_{N-1} - t_N
          double deltaT0 = (double)(t1 - t3); // t_{N-2} - t_N
      
          // 计算高度差
          double deltaH1 = value2 - value3; // h_{N-1} - h_N
          double deltaH0 = value1 - value3; // h_{N-2} - h_N
      
          // 计算系数 a（加速度的一半）
          double denominator = deltaT1 * deltaT1 * deltaT0 - deltaT0 * deltaT0 * deltaT1;
          if (denominator == 0) return 0; // 避免除零错误
      
          double a = (deltaH1 * deltaT0 - deltaH0 * deltaT1) / denominator;
      
          return 2.0 * a; // 返回加速度
      } 
      
      //+------------------------------------------------------------------+
      //| 获取指定 shift 的强力指数（Force Index）值                         |
      //+------------------------------------------------------------------+
      double getForceIndex(string symbol, int shift, ENUM_TIMEFRAMES timeFrame, int period)
      {
          // 定义缓冲区存储强力指数值
          double forceIndexBuffer[];
          
          // 获取强力指数指标的句柄
          int handle = iForce(symbol, timeFrame, period, MODE_SMA, VOLUME_TICK);
          
          // 检查句柄是否有效
          if (handle == INVALID_HANDLE)
          {
              Print("错误：无法创建强力指数指标句柄！");
              return 0;
          }
          
          // 复制指标数据到缓冲区
          if (CopyBuffer(handle, 0, shift, 1, forceIndexBuffer) > 0)
          {
              // 返回指定 shift 的强力指数值
              return forceIndexBuffer[0];
          }
          else
          {
              Print("强力指数数据获取失败！");
              return 0;
          }
      }  
      
      
      //+------------------------------------------------------------------+
      //| 获取指定 shift 的强力指数（Force Index）值                         |
      //+------------------------------------------------------------------+
      double getExtendPipsByForce(string symbol, 
                                    double startExtendPips,
                                    double endExtendPips,
                                    double forceBegin,
                                    double forceEnd){                                    
         double curForce=getForceIndex(symbol,0,PERIOD_M15,14);
         return this.mapValue(curForce,forceBegin,forceEnd,startExtendPips,endExtendPips);         
      }  
      
      //+------------------------------------------------------------------+
      //| 获取指定 shift 的强力指数（Force Index）值                         |
      //+------------------------------------------------------------------+
      double getExtendPipsByAtr(string symbol, 
                                    double startExtendPips,
                                    double endExtendPips){                                    
         double curForce=this.GetATR(symbol,0,PERIOD_M15,14);
         return this.mapValue(curForce,1,8,300,100);         
     }
     
      
      //+------------------------------------------------------------------+
      //| 检查当前是否被允许
      //+------------------------------------------------------------------+     
      bool IsTradingAllowed(string symbol = NULL){
      
       if(symbol == NULL) symbol = Symbol();          
       // 检查终端交易权限
       if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
       {
           Print("终端禁止交易!");
           return false;
       }
       
       // 检查EA交易权限
       if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
       {
           Print("EA交易被禁止!");
           return false;
       }
       
       // 检查账户交易权限
       if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
       {
           Print("账户禁止交易!");
           return false;
       }
       
       // 检查品种交易状态
       if(SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
       {
           Print(symbol, " 交易被禁止!");
           return false;
       }
       
       return true;
      }   

   //+------------------------------------------------------------------+
   //| 检查当前时间是否在交易时段内
   //+------------------------------------------------------------------+      
   bool IsMarketClosed(string symbol = NULL){
       
       if(symbol == NULL) symbol = Symbol();          
       
       // 检查当前时间是否在交易时段内
       datetime current = TimeCurrent();
       datetime start, end;
       
       // 获取当天的第一个交易时段
       MqlDateTime timeStruct;
       TimeCurrent(timeStruct);
       SymbolInfoSessionTrade(symbol, (ENUM_DAY_OF_WEEK)timeStruct.day_of_week, 0, start, end);
       
       return (start == 0 && end == 0) || (current < start) || (current >= end);
   }                      
};



//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
ComFunc2::ComFunc2(){}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
ComFunc2::~ComFunc2(){}

ComFunc2 comFunc2;  // Create an instance of ComFunc2