//+------------------------------------------------------------------+
//|                                                  CPriceSpeed.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"


class CPriceSpeed
  {
private:      
      int            priceSpeed[5]; 
public:
                     CPriceSpeed();
                    ~CPriceSpeed();
     
     //--- methods of initilize
     void            init(); 
     //--- set price speed
     void            setPriceSpeed(int level,int status);
     //--- get price speed
     int             getPriceSpeed(int level);
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CPriceSpeed::init()
{

}

//+------------------------------------------------------------------+
//|  set price action 
//+------------------------------------------------------------------+
void CPriceSpeed::setPriceSpeed(int level,int status){
   this.priceSpeed[level]=status;
}

//+------------------------------------------------------------------+
//|  get price action 
//+------------------------------------------------------------------+
int CPriceSpeed::getPriceSpeed(int level){
   return this.priceSpeed[level];
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CPriceSpeed::CPriceSpeed(){
   ArrayInitialize(this.priceSpeed,0);
}
CPriceSpeed::~CPriceSpeed(){}