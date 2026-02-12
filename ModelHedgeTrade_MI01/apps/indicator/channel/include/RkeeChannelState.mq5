//+------------------------------------------------------------------+
//|                                               TrendStrengthEA.mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//--- 输入参数
 int    InpPeriods[] = {2, 6, 9,12,16,24,64};    // 各个周期
//input double N = 100.0;                            // 最大趋势强度
 double Weights[] = {2, 1, 1, 1, 1,0.5,0.3};    // 各周期权重
 double Weights2[] = {3, 1, 0.5, 0.5,0.5,2,2};    // 各周期权重
input string PriceChannelIndicator = "RkeeChannel"; // 指标名称
//input double TradeThreshold = 50.0;               // 交易阈值（绝对值大于此值时可考虑交易）
input double strengthUnitPips = 2000.0;               // 交易阈值（绝对值大于此值时可考虑交易）
//--- 全局变量
double TrendStrength = 0.0;                        // 趋势强度
int Handles[ArraySize(InpPeriods)];                // 保存指标句柄
double UpperBuffer[], LowerBuffer[];               // 缓存最大周期的通道值


//+------------------------------------------------------------------+
//| EA初始化函数                                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   // 初始化 PriceChannel 指标句柄
   for(int i = 0; i < ArraySize(InpPeriods); i++)
     {
      Handles[i] = iCustom(_Symbol, PERIOD_CURRENT, PriceChannelIndicator, InpPeriods[i]);
      if(Handles[i] == INVALID_HANDLE)
        {
         PrintFormat("Failed to create handle for period %d. Error: %d", InpPeriods[i], GetLastError());
         return INIT_FAILED;
        }
     }
   // 设置缓冲区为时间序列
   ArraySetAsSeries(UpperBuffer, true);
   ArraySetAsSeries(LowerBuffer, true);

   Print("TrendStrength EA initialized.");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| 每个Tick的主函数                                                 |
//+------------------------------------------------------------------+
void OnTick()
  {
   // 计算趋势强度
   TrendStrength = CalculateTrendStrength();

   // 输出日志
   //PrintFormat("Time: %s, TrendStrength: %.2f", TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES), TrendStrength);


  }

//+------------------------------------------------------------------+
//| EA去初始化函数                                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // 释放指标句柄
   for(int i = 0; i < ArraySize(Handles); i++)
      if(Handles[i] != INVALID_HANDLE)
         IndicatorRelease(Handles[i]);

   Print("TrendStrength EA deinitialized.");
  }

double CalculateTrendStrength()
  {
   double UpAlignment = 0.0;
   double DownAlignment = 0.0;
   double strengthSumPips=0.0;
   double stressRate=0.0;   
   double point=Point();
   
   bool   upperFlag=true;

   // 获取最大周期的通道值
   if(CopyBuffer(Handles[ArraySize(InpPeriods) - 1], 0, 0, 1, UpperBuffer) <= 0 ||
      CopyBuffer(Handles[ArraySize(InpPeriods) - 1], 1, 0, 1, LowerBuffer) <= 0)
     {
      Print("Failed to copy buffer for max period channel. Error: ", GetLastError());
      return 0.0;
     }   

   double max_channel_upper = UpperBuffer[0];
   double max_channel_lower = LowerBuffer[0];
   
   //printf("channel64_upper:" + max_channel_upper + "   channel64_lower:" + max_channel_lower);

   if(max_channel_upper <= max_channel_lower){
      Print("Invalid max channel values. Upper <= Lower.");
      return 0.0;
   }

   double PeriodUpper[1], PeriodLower[1];
   // 从缓冲区中获取当前周期的通道值
   if(CopyBuffer(Handles[0], 0, 0, 1, PeriodUpper) <= 0 ||
      CopyBuffer(Handles[0], 1, 0, 1, PeriodLower) <= 0){
      PrintFormat("Failed to copy buffer for period %d. Error: %d", InpPeriods[0], GetLastError());
      return 0.0;
   }
   
   double beginUpperEdgeRate=0,beginLowerEdgeRate=0;
   double begin_channel_upper = PeriodUpper[0];
   double begin_channel_lower = PeriodLower[0];
   double begin_channel_range=begin_channel_upper-begin_channel_lower;
   double begin_channel_up_edge_diff=max_channel_upper-begin_channel_lower;
   double begin_channel_up_edge_diff2=begin_channel_upper-max_channel_upper;
   double begin_channel_lower_edge_diff=begin_channel_upper-max_channel_lower;
   double begin_channel_lower_edge_diff2=begin_channel_lower-max_channel_lower;
   strengthSumPips+=(begin_channel_up_edge_diff2+begin_channel_lower_edge_diff2)*Weights2[0]/point;   
   
   if(begin_channel_up_edge_diff>0){  
      beginUpperEdgeRate=begin_channel_range/begin_channel_up_edge_diff; 
      UpAlignment+=beginUpperEdgeRate*Weights[0];     
   }   
   if(begin_channel_lower_edge_diff>0){
      beginLowerEdgeRate=begin_channel_range/begin_channel_lower_edge_diff;
      DownAlignment-=beginLowerEdgeRate*Weights[0];
   }
   
   //printf("channel_begin_upper:" + begin_channel_upper + "  Rate:" + beginUpperEdgeRate 
   //         + "    channel_begin_lower:" + begin_channel_lower + "   Rate:" + beginLowerEdgeRate);

   if(beginUpperEdgeRate>beginLowerEdgeRate){
      upperFlag=true;
   }else{
      upperFlag=false;
   }   

   for(int p = 1; p < ArraySize(InpPeriods) - 1; p++) // 忽略最大周期64本身
     {
           

      // 从缓冲区中获取当前周期的通道值
      if(CopyBuffer(Handles[p], 0, 0, 1, PeriodUpper) <= 0 ||
         CopyBuffer(Handles[p], 1, 0, 1, PeriodLower) <= 0)
        {
         PrintFormat("Failed to copy buffer for period %d. Error: %d", InpPeriods[p], GetLastError());
         continue;
        }

      // 归一化计算靠近上边缘和下边缘的贴合程度
      double channel_distance = PeriodUpper[0] - PeriodLower[0];
      double channel_up_edge_diff=max_channel_upper-PeriodLower[0];
      double channel_up_edge_diff2=PeriodUpper[0]-max_channel_upper;
      double channel_lower_edge_diff=PeriodUpper[0]-max_channel_lower;
      double channel_lower_edge_diff2=PeriodLower[0]-max_channel_lower;
      
      strengthSumPips+=((channel_up_edge_diff2+channel_lower_edge_diff2)*Weights2[p])/point; 
      
      double upper_ratio=0,lower_ratio=0;   
      if(channel_up_edge_diff>0){  
         upper_ratio=channel_distance/channel_up_edge_diff;      
         UpAlignment+=upper_ratio*Weights[p];
      }   
      if(channel_lower_edge_diff>0){
         lower_ratio=channel_distance/channel_lower_edge_diff;
         DownAlignment-=lower_ratio*Weights[p];
      }
       
      //printf("channel" + InpPeriods[p] + "_upper:" + PeriodUpper[0]  + " ratio:" + upper_ratio
      //         + "    channel" + InpPeriods[p] + "_lower:" + PeriodLower[0]   + " ratio:" + lower_ratio);                         
      
   }
   
   static datetime openLastTime = 0; 
   datetime curTime=TimeCurrent();        
   if((curTime-openLastTime)>600){ 
      if(upperFlag){
         //if(UpAlignment>4)
         printf("sumEdgeRate: " + UpAlignment 
                  //+ " strengthSumPips:" + strengthSumPips 
                  + " strengthRate:" + strengthSumPips/strengthUnitPips
                  + " sumRate:" + (UpAlignment+strengthSumPips/strengthUnitPips));
      }else{
         //if(DownAlignment<-4)
         printf("sumEdgeRate: " + DownAlignment
                  //+ " strengthSumPips:" + strengthSumPips 
                  + " strengthRate:" + strengthSumPips/strengthUnitPips
                  + " sumRate:" + (DownAlignment+strengthSumPips/strengthUnitPips));
      }
      openLastTime = curTime;
   }

   // 计算最终的 N 值
   return 0; // 确保范围为 -N 到 N
  }

//+------------------------------------------------------------------+
//| 开仓函数                                                         |
//+------------------------------------------------------------------+
void OpenTrade(int order_type)
  {

  }

//+------------------------------------------------------------------+
