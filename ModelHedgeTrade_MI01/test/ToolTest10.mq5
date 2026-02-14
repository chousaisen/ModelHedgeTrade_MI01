//+------------------------------------------------------------------+
//|                                                       Test09.mq5 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // 设置EA或初始化时输出一条信息
   test();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void test()
  {
   // 参数定义
   double a = 1;    // 弯曲程度
   double c = 0;    // 中心位置
   double n = 0.8;    // 幂次
   int curve_points = 30; // 点数量

   // 定义 x 值范围
   double x_min = -10.0;
   double x_max = 10.0;
   double step = (x_max - x_min) / curve_points;

   // 数组保存生成的点
   double x_array[], y_array[];
   ArrayResize(x_array, curve_points);
   ArrayResize(y_array, curve_points);

   // 生成曲线数据
   /* test1
   for(int i = 0; i < curve_points; i++){
      double x = i;
      double y = CalculateCurvedValue(x, a, c, n);
      x_array[i] = x; // x 值
      y_array[i] = y; // y 值
      
      printf("y:" + y
               + " x:" + x
               + " a:" + a
               + " c:" + c
               + " n:" + n
               );
      
   }*/

   double rate1=1.2,rate2=2;
   double doubleBeginValue=5;

   for(int i = 1; i < curve_points; i++){
      double x = ((double)i)*0.3;
      double y = doubleExtendValue(x, rate1, doubleBeginValue, rate2);
      x_array[i] = x; // x 值
      y_array[i] = y; // y 值
      
      printf("extendValue:" + StringFormat("%.2f",y) 
               + " value:" + x
               + " rate1:" + rate1
               + " doubleBegin:" + doubleBeginValue
               + " rate2:" + rate2               
               );
      
   }


    // 绘制曲线到主图上
    //DrawCurve(x_array, y_array, curve_points, "CustomCurve");
  }

//+------------------------------------------------------------------+
//| Function to calculate curved value                               |
//+------------------------------------------------------------------+
double CalculateCurvedValue(double x, double a, double c, double n)
  {
   if(n <= 0) return(EMPTY_VALUE); // 防止无效参数
   return(a * MathPow(x - c, n));
  }
  
//+------------------------------------------------------------------+
//| Function to calculate curved value                               |
//+------------------------------------------------------------------+
double extendValue(double value,double extendRate){
   return(MathPow(value, extendRate));
} 

//+------------------------------------------------------------------+
//| Function to calculate curved value                               |
//+------------------------------------------------------------------+
double doubleExtendValue(double value,double extendRate,double doubleBeginValue,double extendRate2){
   if(value<doubleBeginValue){
      return(MathPow(value, extendRate));
   }   
   double extendValue1=MathPow(value, extendRate);
   double doubleValue=value-doubleBeginValue;
   double extendValue2=MathPow(doubleValue, extendRate2);   
   return extendValue1+extendValue2;      
}

//+------------------------------------------------------------------+
//| Function to draw the curve on the chart                          |
//+------------------------------------------------------------------+
void DrawCurve(const double &x_array[], const double &y_array[], int points, string curve_name)
  {
   // 删除旧的曲线
   ObjectDelete(0, curve_name);

   // 创建一个趋势线来表示曲线
   for(int i = 1; i < points; i++)
     {
      // 每两个点之间创建一段线段
      string segment_name = curve_name + "_" + IntegerToString(i);
      ObjectCreate(0, segment_name, OBJ_TREND, 0, x_array[i - 1], y_array[i - 1], x_array[i], y_array[i]);
      ObjectSetInteger(0, segment_name, OBJPROP_COLOR, clrBlue);  // 曲线颜色
      ObjectSetInteger(0, segment_name, OBJPROP_WIDTH, 2);        // 线宽
     }
  }

