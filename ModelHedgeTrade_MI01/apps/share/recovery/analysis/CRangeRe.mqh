//+------------------------------------------------------------------+
//|                                                     CRangeRe.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

class CRangeRe{

     private: 
         int                    statusFlg;
         int                    statusDetailFlg;
         int                    statusIndex;         
         int                    preStatusFlg;
         datetime               statusStartTime;
         double                 upperBreakLine;
         double                 downBreakLine;                     
     public:
                  CRangeRe();
                  ~CRangeRe();
                  
          // getters
          int getStatusFlg()              { return statusFlg; }
          int getStatusDetailFlg()        { return statusDetailFlg; }
          int getStatusIndex()            { return statusIndex; }
          int getPreStatusFlg()           { return preStatusFlg; }
          datetime getStatusStartTime()   { return statusStartTime; }
          double getUpperBreakLine()      { return upperBreakLine; }
          double getDownBreakLine()       { return downBreakLine; }
      
          // setters
          void setStatusFlg(int value)             { statusFlg = value; }
          void setStatusDetailFlg(int value)       { statusDetailFlg = value; }
          void setStatusIndex(int value)           { statusIndex = value; }
          void setPreStatusFlg(int value)          { preStatusFlg = value; }
          void setStatusStartTime(datetime value)  { statusStartTime = value; }
          void setUpperBreakLine(double value)     { upperBreakLine = value; }
          void setDownBreakLine(double value)      { downBreakLine = value; }                             
                    
};

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CRangeRe::CRangeRe(){}
CRangeRe::~CRangeRe(){}