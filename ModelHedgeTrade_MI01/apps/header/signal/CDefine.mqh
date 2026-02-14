//+------------------------------------------------------------------+
//|                                                      CHeader.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|  signal define parameter
//+------------------------------------------------------------------+ 
#define SIGNAL_ACTIVE_SECONDS             (120)            // signal active seconds


//+------------------------------------------------------------------+
//|  signal define type
//+------------------------------------------------------------------+ 
#define SIGNAL_TYPE_OPEN                  (1001)            // signal open order
#define SIGNAL_TYPE_OPEN_TIME_LIMIT       (1002)            // signal open order time limit
#define SIGNAL_TYPE_CLOSE                 (2001)            // signal close order by all close
#define SIGNAL_TYPE_CLOSE_PART            (2002)            // signal close order by part close
#define SIGNAL_TYPE_CLOSE_TRIGGER         (2003)            // signal close order by trigger
#define SIGNAL_TYPE_MODIFY                (3001)            // signal close order

//+------------------------------------------------------------------+
//|  signal kind simulation
//+------------------------------------------------------------------+ 
#define SIGNAL_KIND_SIMILATION_01         (101)            // signal kind simulation 01
#define SIGNAL_KIND_SIMILATION_02         (102)            // signal kind simulation 02
#define SIGNAL_KIND_SIMILATION_03         (103)            // signal kind simulation 03
#define SIGNAL_KIND_SIMILATION_04         (104)            // signal kind simulation 04
#define SIGNAL_KIND_SIMILATION_05         (105)            // signal kind simulation 05
#define SIGNAL_KIND_SIMILATION_06         (106)            // signal kind simulation 06
#define SIGNAL_KIND_SIMILATION_07         (107)            // signal kind simulation 07
#define SIGNAL_KIND_SIMILATION_08         (108)            // signal kind simulation 08
#define SIGNAL_KIND_SIMILATION_09         (109)            // signal kind simulation 09
#define SIGNAL_KIND_SIMILATION_10         (110)            // signal kind simulation 10

//+------------------------------------------------------------------+
//|  signal kind client/copy
//+------------------------------------------------------------------+ 
#define SIGNAL_KIND_CLIENT_SIGNAL_01         (201)            // signal kind client signal copy 01
#define SIGNAL_KIND_CLIENT_SIGNAL_02         (202)            // signal kind client signal copy 02
#define SIGNAL_KIND_CLIENT_SIGNAL_03         (203)            // signal kind client signal copy 03


//+------------------------------------------------------------------+
//|  signal kind EA copy
//+------------------------------------------------------------------+ 
#define SIGNAL_KIND_CLIENT_EA_01         (301)            // signal kind client EA copy 01
#define SIGNAL_KIND_CLIENT_EA_02         (302)            // signal kind client EA copy 02
#define SIGNAL_KIND_CLIENT_EA_03         (303)            // signal kind client EA copy 03


//+------------------------------------------------------------------+
//|  signal kind indicator create signal
//+------------------------------------------------------------------+ 
#define SIGNAL_KIND_INDICATOR_01         (501)            // signal kind indicator create signal 01
#define SIGNAL_KIND_INDICATOR_02         (502)            // signal kind indicator create signal 01
#define SIGNAL_KIND_INDICATOR_03         (503)            // signal kind indicator create signal 01
