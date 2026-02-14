//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+

//symbol managment 
#define SYMBOL_MAX_COUNT         (30)            // symbol max count


//define the symbol list
string SYMBOL_LIST[]={"AUDNZD","AUDJPY","AUDUSD",
                      "AUDCAD","AUDCHF","CADJPY",
                      "CHFJPY","CADCHF","EURGBP",
                      "EURUSD","EURAUD","EURCHF",
                      "EURCAD","EURJPY","EURNZD",
                      "GBPCHF","GBPJPY","GBPAUD",
                      "GBPNZD","GBPCAD","GBPUSD",
                      "USDCHF","USDJPY","USDCAD",
                      "NZDJPY","NZDUSD","NZDCAD",
                      "NZDCHF","XAUUSD","BITCOIN"};  
                      
                      
double SYMBOL_RATE[]={1.1,  //AUDNZD
                      2,  //AUDJPY
                      1,    //AUDUSD
                      1.1,  //AUDCAD
                      1,    //AUDCHF
                      2,  //CADJPY
                      2,  //CHFJPY
                      1,    //CADCHF
                      1,   //EURGBP
                      1.2,   //EURUSD
                      1.7,   //EURAUD
                      1,   //EURCHF
                      1.7,   //EURCAD
                      2,   //EURJPY
                      2,   //EURNZD
                      1.5,   //GBPCHF
                      2,   //GBPJPY
                      2.5,   //GBPAUD
                      2.5,   //GBPNZD
                      2.2,   //GBPCAD
                      1.5,   //GBPUSD
                      1,   //USDCHF
                      2,   //USDJPY
                      1.5,   //USDCAD
                      1.1,   //NZDJPY
                      1,   //NZDUSD
                      1.1,   //NZDCAD
                      1,   //NZDCHF
                      20,   //XAUUSD
                      10   //XAGUSD
                      };     
                      
double SYMBOL_TICK_VALUE[]={1,  //AUDNZD
                      1,  //AUDJPY
                      1,    //AUDUSD
                      1,  //AUDCAD
                      1,    //AUDCHF
                      1,  //CADJPY
                      1,  //CHFJPY
                      1,    //CADCHF
                      1,   //EURGBP
                      1,   //EURUSD
                      1,   //EURAUD
                      1,   //EURCHF
                      1,   //EURCAD
                      1,   //EURJPY
                      1,   //EURNZD
                      1,   //GBPCHF
                      1,   //GBPJPY
                      1,   //GBPAUD
                      1,   //GBPNZD
                      1,   //GBPCAD
                      1,   //GBPUSD
                      1,   //USDCHF
                      1,   //USDJPY
                      1,   //USDCAD
                      1,   //NZDJPY
                      1,   //NZDUSD
                      1,   //NZDCAD
                      1,   //NZDCHF
                      20,   //XAUUSD
                      10   //XAGUSD
                      };                    