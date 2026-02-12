//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+

/*
input  string   CLEAR_Minus_MODEL_SETTING="------ Risk Clear Minus Setting ------";

input   bool       Clear_Model_Minus=true;
input   bool       Clear_Model_Minus_Speed_Acc=true;
input   bool       Clear_Model_Minus_Break=true;

input   double     Clear_Model_Minus_Group_Risk_HRate=0.95;
input   double     Clear_Model_Minus_Group_Min_Order=2;
input   double     Clear_Model_Minus_Min_ProfitPips=1;
input   double     Clear_Model_Minus_Min_SumUnitLot=3;
input   double     Clear_Model_Minus_Min_SumLotRate=0.2;
input   double     Clear_Model_Minus_Max_StrengthRate=3;


input  string   CLEAR_Plus_MODEL_SETTING="------ Risk Clear Plus Setting ------";

input   bool       Clear_Model_Plus=true;
input   bool       Clear_Model_Plus_Speed_Acc=true;
input   double     Clear_Model_Plus_Group_Risk_HRate=0.95;
input   double     Clear_Model_Plus_Min_ProfitPips=300;
input   double     Clear_Model_Plus_Min_SumUnitLot=3;
input   double     Clear_Model_Plus_Min_SumLotRate=0.2;
input   double     Clear_Model_Plus_Min_StrengthRate=9;
*/
input  string   CLEAR_Exceed_MODEL_SETTING="------ Risk Clear Exceed Setting ------";

input   bool       Clear_Model_Exceed=true;

input   double     Clear_Model_Exceed_Min_Count=2;
//input   bool       Clear_Model_Exceed_OnlyBreak=true;
//input   double     Clear_Model_Exceed_Min_SumPips=0;
//input   double     Clear_Model_Exceed_Max_Loss_Pips=600;

input   double     Clear_Model_Exceed_Diff_PeakPips=300;
input   double     Clear_Model_Exceed_Diff_AvgPips=-100;
input   double     Clear_Model_Exceed_Hedge_LessProfit=50;

input   bool       Clear_Model_Exceed_SignalRisk=true;
input   double     Clear_Model_Exceed_LessProfit=-1200;
input   bool       Clear_Model_PreExceed=true;
input   double     Clear_Model_PreExceed_Jump_Min_Pips=1000;
input   double     Clear_Model_PreExceed_GrowRate=1.1;
input   double     Clear_Model_PreExceed_Min_Profit=0;
input   double     Clear_Model_PreExceed_Begin_Lot=0.03;
input   double     Clear_Model_PreExceed_Min_Lot=0.03;
input   double     Clear_Model_PreExceed_Less_SumProfit=-3000;

input   bool       Clear_Model_PreExceedRe=true;
input   double     Clear_Model_PreExceedRe_GrowRate=1.1;
input   double     Clear_Model_PreExceedRe_Min_Profit=0;
input   double     Clear_Model_PreExceedRe_Begin_Lot=0.03;
input   double     Clear_Model_PreExceedRe_Min_Lot=0.03;
input   double     Clear_Model_PreExceedRe_Less_SumProfit=-3000;



input  string   CLEAR_Over_MODEL_SETTING="------ Risk Clear Over Models Setting ------";

input   bool       Clear_Model_Over=true;
input   int        Clear_Model_Max_Order_Count=60;
//input   double     Clear_Model_Diff_Order_Rate=2;
input   double     Clear_Model_Over_Order_LossPips=-3600;
input   double     Clear_Model_Over_Order_DiffRate=0.1;
input   double     Clear_Model_Over_Limit_Cost_EdgeRate=0.1;
//input   double     Clear_Model_Diff_Center_Pips=100;