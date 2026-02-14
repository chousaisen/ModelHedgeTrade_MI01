//+------------------------------------------------------------------+
//|                                                       Test01.mq5 |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Generic\ArrayList.mqh>
#include "..\apps\comm\ComFunc.mqh"
#include "..\apps\share\signal\CSignal.mqh"
#include "..\apps\share\order\COrder.mqh"

//CArrayList<CSignal*>  signalList;
CArrayList<COrder*>  orderList;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
   //+------------------------------------------------------------------+
   //| CommFun test                                   |
   //+------------------------------------------------------------------+
  
   /*
   //---
   // 定义一个数字
   //ulong number = 1234567890102;
   int ticket = 123456789;
   int modelKind=2101;
   int modelKind2=5101;
   int signalKind=103;
   int signalKind2=105;
   int copyIndex=1;
   
   // 定义要变成 0 的位数
   //int last_n_digits = 4;
   
   // 将最后 N 位变成 0000
   //ulong modified_number = (number / (ulong)MathPow(10, last_n_digits)) * (ulong)MathPow(10, last_n_digits);
   //ulong modified_number = comFunc.makeModelIdBySourceId(2001,number);
   
   ulong sourceId = comFunc.makeTicketSourceId(signalKind,copyIndex,ticket);
   // 输出结果到日志
   Print("The modified SourceId is: ", sourceId);
   
   
   ulong modelId = comFunc.makeModelIdBySourceId(modelKind,sourceId);
   // 输出结果到日志
   Print("The modified modelId is: ", modelId);
   
   //signal source id
   sourceId = comFunc.makeSourceIdByModelId(signalKind2,modelId);
   // 输出结果到日志
   Print("The modified SourceId2 is: ", sourceId);
   
   //model id
   modelId = comFunc.makeModelIdBySourceId(modelKind2,sourceId);
   // 输出结果到日志
   Print("The modified modelId2 is: ", modelId);
   
   //kind id
   int kindId=comFunc.getKindById(modelId);
   Print("The modified kindId is: ", kindId);
   
   //ticket id
   int ticketId=comFunc.getTicketById(modelId);
   Print("The modified ticketId is: ", ticketId);
   
   
   //magic id
   ulong modelId=59896294002102;
   ulong magicId=comFunc.makeOrderMagicId(1,modelId);
   Print("The modelId is: ", modelId);
   Print("The modified magicId is: ", magicId);
     
   ulong sourceId=comFunc.getIdByMagic(magicId);
   Print("The modified sourceId is: ", sourceId);
   */
   //+------------------------------------------------------------------+
   //| String func test01                                   |
   //+------------------------------------------------------------------+

   /*
   // 输入字符串
   string inputStr = "12345678@101,102,103";
   
   // 保存 @ 符号前的部分
   string strBeforeAt;
   
   // 保存转换后的整数数组
   int numArray[];
   
   // 调用函数
   comFunc.getServerAndKindList(inputStr, strBeforeAt, numArray);
   
   // 输出结果
   Print("String before '@': ", strBeforeAt);
   Print("Numbers after '@': ");
   
   // 输出数组内容
   for(int i = 0; i < ArraySize(numArray); i++)
   {
      Print("numArray[", i, "] = ", numArray[i]);
   }

   */
   
   //+------------------------------------------------------------------+
   //| CArrayList Test
   //+------------------------------------------------------------------+
   /*
   printf("signal list count:" + signalList.Count());
   
   CSignal*  signal;
   CSignal*  signal1=new CSignal();
   
   signalList.Add(signal1);
   //signalList.TryGetValue(0,signal);
   
   if(signal==NULL){   
      printf("signal is null!");
   }else{
      printf("signal is not null!");
   }   
   
   delete signal1;
   signal1=NULL;
   signalList.TrySetValue(0,NULL);
   
   
   signalList.TryGetValue(0,signal);
   //signalList.Remove(signal1);
   
   if(signal==NULL){   
      printf("signal is null!");
   }else{
      printf("signal is not null!");
   }      
   
   printf("signal list count:" + signalList.Count());
   
   delete signal1;
   */
   
   //+------------------------------------------------------------------+
   //| test to send order
   //+------------------------------------------------------------------+
   /*
   MqlTradeRequest request;
   MqlTradeResult result;
   
   // 初始化请求和结果
   ZeroMemory(request);
   ZeroMemory(result);
   
   // 设置交易请求的属性
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = 0.01;
   request.type = ORDER_TYPE_BUY;
   request.sl = 0.0;   // 不设置止损
   request.tp = 0.0;   // 不设置止盈
   
   // 设置价格为当前的ASK价格
   request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   // 设置滑点
   request.deviation = 10;
   
   // 发送交易请求
   if(!OrderSend(request, result))
   {
      Print("交易请求失败，错误代码：", GetLastError());
   }
   else
   {
      Print("交易请求成功，订单号：", result.order);
   }   */
   
   //+------------------------------------------------------------------+
   //| test to remove and add suffix
   //+------------------------------------------------------------------+   
   //printf("remove suffix result:" + comFunc.removeSuffix("USDJPY#"));   
   //printf("add suffix result:" + comFunc.addSuffix("USDJPY"));
   
   //+------------------------------------------------------------------+
   //| test lot rate Array
   //+------------------------------------------------------------------+    
   /*
   double arrayList[10];
   ArrayInitialize(arrayList,1);   
   comFunc.getDoubleArrayList("3,2,1",arrayList);
   for(int i=0;i<ArraySize(arrayList);i++){
      printf("arrayList" + i + ":" + arrayList[i]);
   }*/
   
   //int count1=10,count2=30;
   //double rate=((double)count1)/((double)count2);
   
   //printf("rate:" +rate);


   //+------------------------------------------------------------------+
   //| Order list sort test
   //+------------------------------------------------------------------+ 
   /* 
   CArrayList<COrder*>  orderList;
     
   COrder*  order1=new COrder();
   order1.setProfit(100);

   orderList.Add(order1);

   COrder*  order2=new COrder();
   order2.setProfit(300);
   orderList.Add(order2);

   COrder*  order3=new COrder();
   order3.setProfit(200);
   orderList.Add(order3);

   COrder*  order4=new COrder();
   order4.setProfit(500);
   orderList.Add(order4);

   COrder*  order5=new COrder();
   order5.setProfit(150);
   orderList.Add(order5);

   Print("before---------------------------------------before");
    // Output the sorted profits
    for (int i = 0; i < orderList.Count(); i++)
    {
        COrder *order;
        orderList.TryGetValue(i,order);     
        Print("Before Order Profit: ", order.getProfit());
    }

   SortOrderListByProfit(orderList);
   
   Print("after---------------------------------------after");
   
   
    // Output the sorted profits
    for (int i = 0; i < orderList.Count(); i++)
    {
        COrder *order;
        orderList.TryGetValue(i,order);     
        Print("After Order Profit: ", order.getProfit());
    }
   */
   
   
   //+------------------------------------------------------------------+
   //| test to create max orders                                 |
   //+------------------------------------------------------------------+
   //makeOrders(200);     


   //+------------------------------------------------------------------+
   //| test to create unique number
   //+------------------------------------------------------------------+   
   /*
   Print("number1:" + comFunc.getFixUniqueN9());
   Print("number2:" + comFunc.getFixUniqueN9());
   Print("number3:" + comFunc.getFixUniqueN9());
   Print("number4:" + comFunc.getFixUniqueN9());
   Print("number5:" + comFunc.getFixUniqueN9());
   
    
   Print("number1:" + comFunc.getUnique(1100));
   Print("number2:" + comFunc.getUnique(2100));
   Print("number3:" + comFunc.getUnique(2101));
   Print("number4:" + comFunc.getUnique(2102));
   Print("number5:" + comFunc.getUnique(2103));
   Print("number6:" + comFunc.getUnique(3000));
   Print("number7:" + comFunc.getUnique(3001));
   */

   //+------------------------------------------------------------------+
   //| test tick value. tick value profit. tick value loss 
   //+------------------------------------------------------------------+   

   double tickValue=0,tickValueProfit=0,tickValueLoss=0;   
   string m_name="EURAUD";
   SymbolInfoDouble(m_name,SYMBOL_TRADE_TICK_VALUE,tickValue);
   SymbolInfoDouble(m_name,SYMBOL_TRADE_TICK_VALUE_PROFIT,tickValueProfit);
   SymbolInfoDouble(m_name,SYMBOL_TRADE_TICK_VALUE_LOSS,tickValueLoss);
   
   printf(m_name + "_" + "tickValue:" + tickValue);
   printf(m_name + "_" + "tickValueProfit:" + tickValueProfit);
   printf(m_name + "_" + "tickValueLoss:" + tickValueLoss);
   
   m_name="EURCHF";
   SymbolInfoDouble(m_name,SYMBOL_TRADE_TICK_VALUE,tickValue);
   SymbolInfoDouble(m_name,SYMBOL_TRADE_TICK_VALUE_PROFIT,tickValueProfit);
   SymbolInfoDouble(m_name,SYMBOL_TRADE_TICK_VALUE_LOSS,tickValueLoss);
   
   printf(m_name + "_" + "tickValue:" + tickValue);
   printf(m_name + "_" + "tickValueProfit:" + tickValueProfit);
   printf(m_name + "_" + "tickValueLoss:" + tickValueLoss);
   
   m_name="EURCAD";
   SymbolInfoDouble(m_name,SYMBOL_TRADE_TICK_VALUE,tickValue);
   SymbolInfoDouble(m_name,SYMBOL_TRADE_TICK_VALUE_PROFIT,tickValueProfit);
   SymbolInfoDouble(m_name,SYMBOL_TRADE_TICK_VALUE_LOSS,tickValueLoss);
   
   printf(m_name + "_" + "tickValue:" + tickValue);
   printf(m_name + "_" + "tickValueProfit:" + tickValueProfit);
   printf(m_name + "_" + "tickValueLoss:" + tickValueLoss);      
   


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  
}
//+------------------------------------------------------------------+


void ExtractStringAndNumbers(const string inputStr, string &strBeforeAt, int &numArray[])
{
   // 找到 @ 符号的位置
   int atIndex = StringFind(inputStr, "@");
   if(atIndex == -1)
   {
      Print("Error: '@' symbol not found in the input string.");
      return;
   }
   
   // 提取 @ 符号前的字符串
   strBeforeAt = StringSubstr(inputStr, 0, atIndex);
   
   // 提取 @ 符号后的字符串
   string strAfterAt = StringSubstr(inputStr, atIndex + 1);
   
   // 用逗号分割字符串
   string strParts[];
   int count = StringSplit(strAfterAt, ',', strParts);

   // 分配数组大小
   ArrayResize(numArray, count);
   
   // 将分割后的每个字符串转换为整数并存入数组
   for(int i = 0; i < count; i++)
   {
      numArray[i] = StringToInteger(strParts[i]);
   }
}

//+------------------------------------------------------------------+
//| IComparer class for sorting by profit                            |
//+------------------------------------------------------------------+
/*
class COrderComparer : public IComparer<COrder*>
  {
   public:
      // Implement the Compare function to compare two COrder objects by profit
      virtual  int Compare(COrder* left, COrder* right) override
      {
         if(left.getProfit() > right.getProfit())
            return -1; // Return -1 if the first order's profit is greater
         else if(left.getProfit() < right.getProfit())
            return 1;  // Return 1 if the first order's profit is smaller
         return 0;     // Return 0 if both orders have the same profit
      }
  };
*/
//+------------------------------------------------------------------+
//| Function to sort orderList by profit                             |
//+------------------------------------------------------------------+
void SortOrderListByProfit(CArrayList<COrder*> &orders)
{
   COrderComparer comparer;  // Create an instance of the comparer
   orders.Sort(&comparer);  // Sort the list using the comparer
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
CTrade trade;
void makeOrders(int orderCount)
  {
   // 打开200单，每单0.01手
   
   for(int i = 0; i < orderCount; i++)
     {
      if(!trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, 0.01, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0))
        {
         Print("开单失败，错误: ", GetLastError());
         break;
        }
      Sleep(10); // 每单间隔1秒
     }

   // 等待1分钟（60000毫秒）
   //Sleep(60000);
   
   // 关闭所有订单 
   /*
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
     
      ulong ticket=PositionGetTicket(i);
      trade.PositionClose(ticket, 5);     
     }
   */
  }