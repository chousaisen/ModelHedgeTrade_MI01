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
#include "..\share\model\order\COrder.mqh"
#include "..\share\indicator\data\CPriceChannelStatus.mqh"
#include "..\model\CModelI.mqh"
#include "CLog.mqh"

class ComFunc
{
   private:
      datetime    refreshTime[100];  // Array to store refresh times for logging
      int         randomIndex;
   public:
      // Constructor
      ComFunc();

      // Destructor
      ~ComFunc();          

      //+------------------------------------------------------------------+
      //| time to year day                                                 |
      //+------------------------------------------------------------------+          
      int timeToYearDay(datetime dayTime)
      {
         MqlDateTime mqlCurTime; 
         TimeToStruct(dayTime,mqlCurTime); 
         return mqlCurTime.year*10000+mqlCurTime.mon*100+mqlCurTime.day;     
      }
      
      //+------------------------------------------------------------------+
      //| get unique number                                                |
      //+------------------------------------------------------------------+        
      ulong getUniqueNumber()
      {
          // Generate a unique number using tick count and a random component
          ulong timestamp = GetTickCount();
          ulong uniqueNumber = (timestamp << 16) | (MathRand() & 0xFFFF);
          return uniqueNumber;
      } 
      
      //+------------------------------------------------------------------+
      //| get unique number(fix length 9 number)
      //+------------------------------------------------------------------+         
      ulong getFixUniqueN6()
      {
          // 生成一个固定长度的9位随机数
          //ulong uniqueNumber = (ulong)(100000000 + MathRand() % 900000000);
          ulong uniqueNumber1 = (ulong)(1000 + getUniqueNumber() % 9000);
          ulong uniqueNumber2 = (ulong)(1000 + getUniqueNumber() % 9000);
          ulong uniqueNumber3 = uniqueNumber1*uniqueNumber2;
          
          ulong uniqueNumber = (ulong)(100000 + uniqueNumber3 % 900000);
          //ulong uniqueNumber = (ulong)(100000 + getUniqueNumber() % 900000);
          return uniqueNumber;
      }
      
      //+------------------------------------------------------------------+
      //| get unique number(fix length 9 number)
      //+------------------------------------------------------------------+               
      ulong getFixUniqueN9()
      {
          ulong uniqueNumber1 = (ulong)(1000 + getUniqueNumber() % 9000);
          ulong uniqueNumber2 = (ulong)(100000 + getUniqueNumber() % 900000);
          ulong uniqueNumber3 = uniqueNumber1*uniqueNumber2;
          
          ulong uniqueNumber = (ulong)(100000000 + uniqueNumber3 % 900000000);
          return uniqueNumber;
      }             
      
      //+------------------------------------------------------------------+
      //| get unique int number
      //+------------------------------------------------------------------+        
      int getUniqueInt()
      {
          // Generate a unique integer using the local time and a random component
          int timestamp = (int)TimeLocal();
          int randomPart = MathRand();
          return timestamp ^ randomPart;
      } 
      
      //+------------------------------------------------------------------+
      //| create model id (unique number) by model kind
      //+------------------------------------------------------------------+              
      ulong createModelId(int modelKind) {
         // Ensure modelKind is a 4-digit number
         if (modelKind < 1000 || modelKind > 9999) {
            Print("Error: modelKind must be a 4-digit number.");
            return 0; // Return 0 if the input is invalid
         }      
         // Generate a 9-digit random number
         ulong randomPart = getFixUniqueN6();
         randomPart=randomPart*1000+this.randomIndex;
         this.randomIndex++;
         // Combine modelKind and randomPart, ensuring format AAAABBBBBBBBB00
         ulong result = ((ulong)modelKind * 100000000000) + (randomPart * 100);
      
         return result;
      }
      
      //+------------------------------------------------------------------+
      //| create order id (unique number) by model id and order index
      //+------------------------------------------------------------------+              
      ulong createOrderId(long modelId,int orderIndex) {      
         return modelId+orderIndex;      
      }

      //+------------------------------------------------------------------+
      //| Extract the modelId from orderId                                 |
      //+------------------------------------------------------------------+
      long getModelId(long orderId) {
         // Since orderId = modelId + orderIndex
         // Extract modelId by removing the orderIndex part (orderIndex is at the least significant digits)
         return orderId - (orderId % 100);
      }
      
      //+------------------------------------------------------------------+
      //| Extract the modelKind from orderId                               |
      //+------------------------------------------------------------------+
      int getModelKind(long orderId) {
         // Extract modelId first
         long modelId = getModelId(orderId);
      
         // modelId format: AAAABBBBBBBBB00
         // Extract the first 4 digits (AAAA) which represent modelKind
         return (int)(modelId / 100000000000);
      }
      
      //+------------------------------------------------------------------+
      //| Extract the orderIndex from orderId                              |
      //+------------------------------------------------------------------+
      int getOrderIndex(long orderId) {
         // The last 2 digits of orderId represent the orderIndex
         return (int)(orderId % 100);
      }

      //+------------------------------------------------------------------+
      //| get unit profit                                                  |
      //+------------------------------------------------------------------+        
      double getUnitProfit(double profit, double lot)
      {
         // Calculate the profit per standard lot
         double lotSize = lot / Comm_Unit_LotSize;
         return profit / lotSize;
      }  
      
      //+------------------------------------------------------------------+
      //| get unit profit by order info                                    |
      //+------------------------------------------------------------------+        
      double getUnitProfit(COrder* order)
      {
         // Calculate the profit per standard lot based on order information
         double lotSize = order.getLot() / Comm_Unit_LotSize;
         return order.getProfit() / lotSize;
      }
      //+------------------------------------------------------------------+
      //| get unit currency profit by order info                                    |
      //+------------------------------------------------------------------+        
      double getUnitProfitCurrency(COrder* order)
      {
         // Calculate the profit per standard lot based on order information
         double lotSize = order.getLot() / Comm_Unit_LotSize;
         return order.getProfitCurrency() / lotSize;
      }      
      
      //+------------------------------------------------------------------+
      //| Print log message if within specified time range                 |
      //+------------------------------------------------------------------+
      void printfs(string log)
      {
          datetime currentTime = TimeCurrent();
          if(currentTime > StringToTime(Log_Begin_Time)
            && currentTime < StringToTime(Log_End_Time))
          {
               printf(log); 
          }
      }
      
      //+------------------------------------------------------------------+
      //| get order type name
      //+------------------------------------------------------------------+      
      string getOrderType(COrder* order){         
         //get order type   
         switch(order.getOrderType()){
            case ORDER_TYPE_BUY:return "buy";
            case ORDER_TYPE_BUY_LIMIT:
            case ORDER_TYPE_BUY_STOP:
            case ORDER_TYPE_BUY_STOP_LIMIT:
               return "";
            case ORDER_TYPE_SELL:return "sell";
            case ORDER_TYPE_SELL_LIMIT:
            case ORDER_TYPE_SELL_STOP:
            case ORDER_TYPE_SELL_STOP_LIMIT:
               return "";
         }   
         return "";
      }
      
      //+------------------------------------------------------------------+
      //| get order type name
      //+------------------------------------------------------------------+      
      string getOrderType(ENUM_ORDER_TYPE orderType){         
         //get order type   
         switch(orderType){
            case ORDER_TYPE_BUY:return "buy";
            case ORDER_TYPE_BUY_LIMIT:
            case ORDER_TYPE_BUY_STOP:
            case ORDER_TYPE_BUY_STOP_LIMIT:
               return "";
            case ORDER_TYPE_SELL:return "sell";
            case ORDER_TYPE_SELL_LIMIT:
            case ORDER_TYPE_SELL_STOP:
            case ORDER_TYPE_SELL_STOP_LIMIT:
               return "";
         }   
         return "";
      }      
      
      //+------------------------------------------------------------------+
      //| Print log message with time-based refresh control                |
      //+------------------------------------------------------------------+
      void printfs(int logIndex, string log)
      {
          datetime currentTime = TimeCurrent();
          int refreshDiffSeconds = currentTime - this.refreshTime[logIndex];
          if(refreshDiffSeconds > Log_Diff_Seconds)
          {
             if(currentTime > StringToTime(Log_Begin_Time)
               && currentTime < StringToTime(Log_End_Time))
             {
                  printf(log); 
             }
             this.refreshTime[logIndex] = currentTime;
          }
      } 
      
      //+------------------------------------------------------------------+
      //| Print log message with custom refresh interval                   |
      //+------------------------------------------------------------------+
      void printfs(int logIndex, int diffSeconds, string log)
      {
          datetime currentTime = TimeCurrent();
          int refreshDiffSeconds = currentTime - this.refreshTime[logIndex];
          if(refreshDiffSeconds > diffSeconds)
          {
             if(currentTime > StringToTime(Log_Begin_Time)
               && currentTime < StringToTime(Log_End_Time))
             {
                  printf(log); 
             }
             this.refreshTime[logIndex] = currentTime;
          }
      }  
      
      //+------------------------------------------------------------------+
      //| Function to split a comma-separated string into an int array     |
      //+------------------------------------------------------------------+
      int StringToArray(string temp, string &strArray[])
      {         
         // Split the string into a string array using comma as separator
         int count = StringSplit(temp, '|', strArray);
         
         return count;
      }       
            
      //+------------------------------------------------------------------+
      //| Function to convert comma-separated string to array
      //+------------------------------------------------------------------+      
      bool StringToDoubleArray(const string &inputStr, double &output[], char separator = ',')
        {
         string temp[];
         int count = StringSplit(inputStr, separator, temp);
      
         if (count <= 0) return false;
      
         ArrayResize(output, count);
         for (int i = 0; i < count; i++)
         {
            output[i] = StringToDouble(temp[i]); // Convert each string to double
         }
         return true;
        }      
         
      //+------------------------------------------------------------------+
      //| Function to split a comma-separated string into an int array     |
      //+------------------------------------------------------------------+
      void StringToIntArray(string temp, int &intArray[])
      {
         string strArray[];  // Temporary array to hold split string elements
         
         // Split the string into a string array using comma as separator
         int count = StringSplit(temp, ',', strArray);
         
         // Resize the integer array to match the number of elements
         ArrayResize(intArray, count);
         
         // Convert each string element to an integer and store in the integer array
         for(int i = 0; i < count; i++)
         {
           intArray[i] = StringToInteger(strArray[i]);
         }
      }                                 
      
      //+------------------------------------------------------------------+
      //| Function to split a comma-separated string into an int array     |
      //+------------------------------------------------------------------+
      void StringToDoubleArray(string temp, double &doubleArray[])
      {
         string strArray[];  // Temporary array to hold split string elements
         
         // Split the string into a string array using comma as separator
         int count = StringSplit(temp, ',', strArray);
         
         // Resize the integer array to match the number of elements
         ArrayResize(doubleArray, count);
         
         // Convert each string element to an integer and store in the integer array
         for(int i = 0; i < count; i++)
         {            
           doubleArray[i] = StringToDouble(strArray[i]);
         }
      }       
      
      //+------------------------------------------------------------------+
      //| make sourceId                                                    |
      //+------------------------------------------------------------------+
      ulong makeSignalSourceId(int signalKind,int indexNo, int dealNo)
      {
         // Generate a unique source ID using the index number and deal number
         ulong sourceId = (signalKind * 100 + indexNo)*100000 + dealNo;
         return sourceId;
      }                           
          
      //+------------------------------------------------------------------+
      //| Get File Names From Folder                                                  |
      //+------------------------------------------------------------------+          
      void getFileNamesFromFolder(string folderPath, string &fileNames[])
      {
          string fileName;
          int handle = FileFindFirst(folderPath, fileName,FILE_COMMON);
      
          if(handle != INVALID_HANDLE)
          {
              int count = 0;
              do
              {
                  // 动态增加数组大小以容纳新的文件名
                  ArrayResize(fileNames, count + 1);
                  fileNames[count] = fileName;
                  count++;
              } while(FileFindNext(handle, fileName));
              
              FileFindClose(handle);
          }
          else
          {
              Print("No files found in the folder: ", folderPath);
          }
      } 
      //+------------------------------------------------------------------+
      //| Get formart date time string                                     |
      //+------------------------------------------------------------------+                    
      string getDate_YYYYMMDDHHMM2(){
         MqlDateTime local_dt={}; 
         datetime dt = TimeCurrent(local_dt);                       
         return StringFormat("%04d.%02d.%02d %02d:%02d", local_dt.year, local_dt.mon, local_dt.day, local_dt.hour, local_dt.min);        
      }      
      //+------------------------------------------------------------------+
      //| Get formart date time string                                     |
      //+------------------------------------------------------------------+                    
      string getDate_YYYYMMDDHHMM(){
         MqlDateTime local_dt={}; 
         datetime dt = TimeCurrent(local_dt);                       
         return StringFormat("%04d%02d%02d%02d%02d", local_dt.year, local_dt.mon, local_dt.day, local_dt.hour, local_dt.min);        
      }
      //+------------------------------------------------------------------+
      //| Get formart date time string                                     |
      //+------------------------------------------------------------------+                    
      string getDate_YYYYMMDDHHMM(datetime curTime){
         MqlDateTime local_dt={}; 
         TimeToStruct(curTime,local_dt);                  
         return StringFormat("%04d%02d%02d%02d%02d", local_dt.year, local_dt.mon, local_dt.day, local_dt.hour, local_dt.min);        
      }   
      
      //+------------------------------------------------------------------+
      //| Get formatted date time string with seconds                      |
      //+------------------------------------------------------------------+
      string getDate_YYYYMMDDHHMMSS(datetime curTime)
      {
          MqlDateTime local_dt = {};
          TimeToStruct(curTime, local_dt);
          return StringFormat("%04d%02d%02d%02d%02d%02d",
                              local_dt.year,
                              local_dt.mon,
                              local_dt.day,
                              local_dt.hour,
                              local_dt.min,
                              local_dt.sec);
      } 
      
      //+------------------------------------------------------------------+
      //| Convert 'YYYYMMDDHHMMSS' formatted string to datetime            |
      //+------------------------------------------------------------------+
      datetime getDate_YYYYMMDDHHMMSS(string curTime)
      {
          // 验证输入字符串的长度是否为14位
          if(StringLen(curTime) != 14)
          {
              Print("输入的时间字符串长度不正确，应为14位。");
              return 0; // 返回0表示无效的datetime
          }
      
          // 提取日期和时间部分
          string datePart = StringSubstr(curTime, 0, 8);   // YYYYMMDD
          string timePart = StringSubstr(curTime, 8, 6);   // HHMMSS
      
          // 将日期和时间部分组合为支持的格式：'YYYYMMDD HHMMSS'
          string formattedTime = datePart + " " + timePart;
      
          // 使用StringToTime函数转换为datetime
          datetime result = StringToTime(formattedTime);
      
          // 检查转换是否成功
          if(result == 0)
          {
              Print("时间字符串转换失败，请检查格式是否正确。");
          }
      
          return result;
      }      
              
      //+------------------------------------------------------------------+
      //| Get formart date time string                                     |
      //+------------------------------------------------------------------+                    
      string getDate_YYYYMMDDHH(){
         MqlDateTime local_dt={}; 
         datetime dt = TimeCurrent(local_dt);                       
         return StringFormat("%04d%02d%02d%02d", local_dt.year, local_dt.mon, local_dt.day, local_dt.hour);        
      }      
        
        
      //+------------------------------------------------------------------+
      //| get log folder name and kind list
      //+------------------------------------------------------------------+
      bool getLogNameAndKindList(const string inputStr, string &strBeforeAt, int &numArray[])
      {
         if(StringLen(inputStr)<3)return false;
         int atIndex = StringFind(inputStr, "@");
         if(atIndex == -1)
         {            
            return false;
         }
                
         strBeforeAt = StringSubstr(inputStr, 0, atIndex);                  
         string strAfterAt = StringSubstr(inputStr, atIndex + 1);
                  
         string strParts[];
         int count = StringSplit(strAfterAt, ',', strParts);
               
         ArrayResize(numArray, count);
         for(int i = 0; i < count; i++)
         {
            numArray[i] = StringToInteger(strParts[i]);
         }         
         return true;
      }   
      
      //+------------------------------------------------------------------+
      //| remove suffix from the inputstr 
      //+------------------------------------------------------------------+
      string removeSuffix(const string inputStr,string suffix){
                  
         int lenSuffix = StringLen(suffix); // Get the length of the suffix
         int lenInputStr = StringLen(inputStr); // Get the length of the input string
         
         // Check if the input string ends with the given suffix
         if (StringSubstr(inputStr, lenInputStr - lenSuffix, lenSuffix) == suffix) {
            // If true, remove the suffix by returning the substring excluding the suffix
            return StringSubstr(inputStr, 0, lenInputStr - lenSuffix);
         }
         
         // If the suffix is not found, return the original string
         return inputStr;         
      }
      
      //+------------------------------------------------------------------+
      //| remove suffix from the inputstr 
      //+------------------------------------------------------------------+
      string removeSuffix(const string inputStr){
                  
         int lenSuffix = StringLen(Comm_Order_Suffix); // Get the length of the suffix
         if(lenSuffix>0){
            return  removeSuffix(inputStr,Comm_Order_Suffix);           
         }                  
         // If the suffix is not found, return the original string
         return inputStr;         
      }      
      
      //+------------------------------------------------------------------+
      //| remove suffix from the inputstr 
      //+------------------------------------------------------------------+
      string addSuffix(const string inputStr,string suffix){                  
         // If the suffix is not found, return the original string
         return inputStr+suffix;         
      }
      
      //+------------------------------------------------------------------+
      //| remove suffix from the inputstr 
      //+------------------------------------------------------------------+
      string addSuffix(const string inputStr){   
         int lenSuffix = StringLen(Comm_Order_Suffix); // Get the length of the suffix
         if(lenSuffix>0){
            return inputStr+Comm_Order_Suffix;
         }                  
         // If the suffix is not found, return the original string
         return inputStr;                                
      }  
      
      //+------------------------------------------------------------------+
      //| Function to sort orderList by profit                             |
      //+------------------------------------------------------------------+
      void SortOrderListByProfit(CArrayList<COrder*> &orders)
      {
         COrderComparer comparer;  // Create an instance of the comparer
         orders.Sort(&comparer);  // Sort the list using the comparer
      }   
      
      //+------------------------------------------------------------------+
      //| Function to get symbol trade tick value
      //+------------------------------------------------------------------+      
      void  convertProfitToPips(COrder* order){      
                    
          double pointValue=0;
          if (!SymbolInfoDouble(order.getSymbol()+Comm_Order_Suffix, SYMBOL_TRADE_TICK_VALUE, pointValue))
          {
              pointValue=1;
              printf("-------------------->error to get pointValue!!!");
          }
          double lot=order.getLot();
          double profit=order.getProfit()-order.getSwap();
          if(lot<=0)lot=Comm_Unit_LotSize;
          //profitInPips = (profit/ pointValue) * lot;          
          //profitInPips = (profit/ pointValue)*5;
          double profitInPips = (profit / (pointValue * lot))/100 + ((double)order.getSpread())*order.getPoint();
          order.setProfit(profitInPips);          
      }      
            
      //+------------------------------------------------------------------+
      //| get random number
      //+------------------------------------------------------------------+             
      int getRandomNumber(int N) {
          // check N
          if (N <= 0) {
              Print("number error!");
              return 0;
          }
          
          // get seed random
          MathSrand(GetTickCount());
          
          // get 1-n random number
          return MathRand() % N + 1;
      } 
      
      //+------------------------------------------------------------------+
      //|  create order by model info
      //+------------------------------------------------------------------+
      void makeComment(COrder *order){
         //string comment=order.getModelKind() + "-" + order.getMagic();
         string comment="" + order.getMagic();
         comment=this.FormatNumber(comment);
         order.setComment(comment);
      }  
      
      //+------------------------------------------------------------------+
      //| Format Number Function                                           |
      //+------------------------------------------------------------------+
      string FormatNumber(string number) {
         // Ensure the number has at least 6 digits
         if(StringLen(number) < 6) {
            Print("Error: Number must have at least 6 digits.");
            return "";
         }
         
         // Insert "-" after the first 4 digits
         string part1 = StringSubstr(number, 0, 4);
         string part2 = StringSubstr(number, 4, StringLen(number) - 6);
         string part3 = StringSubstr(number, StringLen(number) - 2);
      
         // Combine parts with "-"
         string formatted = part1 + "-" + part2 + "-" + part3;
         return formatted;
      }
      
      //+------------------------------------------------------------------+
      //| Function to sort orderList by profit                             |
      //+------------------------------------------------------------------+      
      void SortModelsListByProfit(CArrayList<CModelI*> &modelList)
      {
         CModelComparer comparer;  // Create an instance of the comparer
         modelList.Sort(&comparer);  // Sort the list using the comparer
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
      double doubleExtendValue(double value,
                                 double extendRate,
                                 double doubleBeginValue,
                                 double extendRate2){
         if(value<doubleBeginValue){
            return(MathPow(value, extendRate));
         }   
         double extendValue1=MathPow(value, extendRate);
         double doubleValue=value-doubleBeginValue;
         double extendValue2=MathPow(doubleValue, extendRate2);   
         return extendValue1+extendValue2;      
      } 
            
      //+------------------------------------------------------------------+
      //| 换挡函数                                                         |
      //+------------------------------------------------------------------+
      int  ShiftGear(int shiftN, 
                           double speed, 
                           double minSpeed, 
                           double maxSpeed, 
                           int N, 
                           double downshiftDiffRate)
      {
          // 1. 计算每个档位的速度区间
          double speedRange = maxSpeed - minSpeed; // 速度范围
          double gearRange = speedRange / (double(N));       // 每个档位的速度区间
      
          // 2. 如果当前档位未初始化 (shiftN <= 0)，根据速度计算初始档位
          if (shiftN < 0)
          {
              if(speed>=maxSpeed){
                shiftN=N;
              }
              else if(speed<=minSpeed){
                shiftN=1;
              }  
              else{   
                 for (int i = 1; i <= N; i++){
                     if (speed <= minSpeed + (double(i)) * gearRange)
                     {
                         shiftN = i;
                         break;
                     }
                 }                 
              }   
              return shiftN;
          }
      
          // 3. 如果当前档位已初始化 (shiftN > 0)，判断是否需要换挡
          double currentGearMin = minSpeed + (double(shiftN - 1)) * gearRange; // 当前档位的最小速度
          double currentGearMax = minSpeed + (double(shiftN)) * gearRange;       // 当前档位的最大速度
      
         //--- test begin
         /*
         if(rkeeLog.debugPeriod(9007,60)){   
            string logTemp="<speed>" + StringFormat("%.2f",speed)
                           + "<preShiftN>" + shiftN   
                           + "<minSpeed>" + StringFormat("%.2f",minSpeed)   
                           + "<gearRange>" + StringFormat("%.2f",gearRange)
                           + "<currentGearMin>" + StringFormat("%.2f",currentGearMin)
                           + "<currentGearMax>" + StringFormat("%.2f",currentGearMax);
            for(int i=1;i<=N;i++){
               double curEdge=minSpeed + i * gearRange;
               logTemp+="<" + i + ">" + StringFormat("%.2f",curEdge);
            }
            
            rkeeLog.writeLog(comFunc.getDate_YYYYMMDDHHMM2()+logTemp,"debugLog02");
            printf(logTemp);
         }*/
         //--- test end      
      
          // 3.1 如果速度超过当前档位的上限，升档
          if (speed > currentGearMax)
          {
              shiftN = shiftN + 1;
              if (shiftN > N) // 确保档位不超过最大档位
                  shiftN = N;
              return shiftN;
          }
      
          // 3.2 如果速度低于当前档位的下限，并超过降档阈值，降档
          double downshiftThreshold = currentGearMin - (gearRange * downshiftDiffRate); // 降档阈值
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
      //| get channel jump rate
      //+------------------------------------------------------------------+      
      double getJumpRate(CPriceChannelStatus* priceChlStatus,
                                    double curPrice,
                                    double point){

         double strengthUnitPips=priceChlStatus.getStrengthUnitPips();
         double jumpPips=this.getJumpPips(priceChlStatus,curPrice,point);         
         double jumpRate=jumpPips/(strengthUnitPips-MathAbs(jumpPips));      
         return jumpRate;
      }
      
     //+------------------------------------------------------------------+
      //| get channel jump pips
      //+------------------------------------------------------------------+      
      double getJumpPips(CPriceChannelStatus* priceChlStatus,
                                    double curPrice,
                                    double point){

         double upperEdgePrice=priceChlStatus.getUpperEdgePrice(0);
         double lowerEdgePrice=priceChlStatus.getLowerEdgePrice(0);   
         //double strengthUnitPips=priceChlStatus.getStrengthUnitPips();
         double edgeBrkDiffPips=priceChlStatus.getEdgeBrkDiffPips();
         
         double adjustDiffPips=0;
         if(edgeBrkDiffPips>0){
            adjustDiffPips=(upperEdgePrice-curPrice)/point;
            edgeBrkDiffPips=edgeBrkDiffPips-adjustDiffPips;
            if(edgeBrkDiffPips<0)edgeBrkDiffPips=0;
         }else if(edgeBrkDiffPips<0){
            adjustDiffPips=(curPrice-lowerEdgePrice)/point;
            edgeBrkDiffPips=edgeBrkDiffPips+adjustDiffPips;
            if(edgeBrkDiffPips>0)edgeBrkDiffPips=0;
         }
         
         return edgeBrkDiffPips;
      }      
                                    
};



//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
ComFunc::ComFunc()
{
   ArrayInitialize(this.refreshTime, 0);  // Initialize refreshTime array to zero
   this.randomIndex=0;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
ComFunc::~ComFunc()
{
    // Destructor implementation (currently empty)
}

//+------------------------------------------------------------------+
//| IComparer class for sorting by profit                            |
//+------------------------------------------------------------------+
class COrderComparer : public IComparer<COrder*>{
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

//+------------------------------------------------------------------+
//| IComparer class for sorting by profit                            |
//+------------------------------------------------------------------+
class CModelComparer : public IComparer<CModelI*>{
   public:
      // Implement the Compare function to compare two COrder objects by profit
      virtual  int Compare(CModelI* left, CModelI* right) override
      {
         if(left.getProfit() > right.getProfit())
            return -1; // Return -1 if the first order's profit is greater
         else if(left.getProfit() < right.getProfit())
            return 1;  // Return 1 if the first order's profit is smaller
         return 0;     // Return 0 if both orders have the same profit
      }
};

ComFunc comFunc;  // Create an instance of ComFunc
