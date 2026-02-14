//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|comm define setting 
//+------------------------------------------------------------------+

input  string   COMM_SETTING="------ Common Setting ------";

input  string                 Comm_App_Start_Time="";
input  int                    Comm_App_Start_Hour=9;
input  int                    Comm_App_Start_Minute=30;
input  double                 Comm_Unit_LotSize=0.01;
input  double                 Comm_Unit_RangePips =150;
input  string                 Comm_Order_Suffix="";
input  int                    Comm_Order_Max_ReTry_Count=10;
input  double                 Comm_Grid_Begin_ExtendRate=0.5;
input  double                 Comm_Grid_ExtendRate=1;
input ENUM_ORDER_TYPE_FILLING Comm_Trade_Order_Filling = ORDER_FILLING_IOC; 
input  bool                   Comm_Trade_Single_Type=false;
input  ENUM_ORDER_TYPE        Comm_Trade_Single_Order_Type=ORDER_TYPE_BUY;