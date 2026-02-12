//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+

input  string   HEDGE_GROUP_SETTING="------ Hedge Group Setting ------";

input  bool        Hedge_Use_Symbol_Profit_Rate=true;
input  double      Hedge_Group_HedgeRate=0.7;
input  double      Hedge_Group_Start_LotUnit=3;
input  double      Hedge_Group_Symbol_Free_LotUnit=3;