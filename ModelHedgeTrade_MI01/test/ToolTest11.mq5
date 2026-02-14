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
      double minRate=-8,maxRate=8;
      double minDiff=500,maxDiff=2000;
      
      for(double i=-8;i<=8;i++){
         printf("rate:" + i + "  diffPips:" + getDiffByRate(i,maxRate,minRate,minDiff,maxDiff));     
      }
      
  }

//+------------------------------------------------------------------+
//| Function to calculate curved value                               |
//+------------------------------------------------------------------+
double getDiffByRate(double rate, double minRate, double maxRate, double minDiff, double maxDiff)
{
   double slopeRate=(minDiff-maxDiff)/(maxRate-minRate);   
   double offSetDiff=maxDiff-(slopeRate)*minRate;   
   return slopeRate*rate+offSetDiff;
}
