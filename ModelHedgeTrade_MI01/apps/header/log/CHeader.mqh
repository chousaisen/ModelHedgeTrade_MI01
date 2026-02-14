//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+

input  string   LOG_AND_DEBUG_SETTING="------ Log and Debug setting ------";

input  string      Log_Begin_Time="";
input  string      Log_End_Time="";
input  int         Log_Diff_Seconds=600;
input  int         Log_Show_Orders_Passed_Hours=3600;   
input  string      Log_File_Name="Runner10";  
input int          Log_OutPut_Count=1000;

input  bool        Debug=true;
input  int         Debug_Diff_Seconds=1;
input  int         Debug_Diff_Brk_Seconds=1;
input  string      DebugFile="debug01";
input  string      Debug_Begin_Time="";
input  string      Debug_End_Time="";
input  bool        Debug_Open=true;
input  bool        Debug_Extend=true;
input  bool        Debug_Close=true;
input  bool        Debug_Clear=true;
input  bool        Debug_Clear_Plus=true;
input  bool        Debug_Clear_Minus=true;
input  bool        Debug_Clear_Exceed=true;
input  bool        Debug_Clear_PreExceed=true;
input  bool        Debug_Clear_Over=true;
input string       Debug_ReRun_Time="20290501 1000";

