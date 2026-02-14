//+------------------------------------------------------------------+
//|                                          CPriceChlStatus.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "..\CHeader.mqh"

class CPriceChlStatus
  {
private: 
      double      edgeBrkDiffPips[10]; 
      double      edgeRate[10][10];     
      double      strengthRate[10][10];
      double      upperEdge[10][10];
      double      lowerEdge[10][10];
public:
                     CPriceChlStatus();
                    ~CPriceChlStatus();
     
     //--- methods of initilize
     void            init(); 
     //--- set edge break diff pips
     void            setEdgeBrkDiffPips(int index,double value);
     //--- get edge break diff pips
     double          getEdgeBrkDiffPips(int index);
     //--- set edge rate
     void            setEdgeRate(int index,int shift,double value);
     //--- get edge rate
     double          getEdgeRate(int index,int shift);
     //--- set edge strengthRate
     void            setStrengthRate(int index,int shift,double value);
     //--- get edge strengthRate
     double          getStrengthRate(int index,int shift);
     //--- set edge price value
     void            setEdgePrice(int index,
                                    int shift,
                                    double upperEdgePrice,
                                    double lowerEdgePrice);
     //--- get upper edge price value
     double          getUpperEdgePrice(int index,int shift);                                    
     //--- get lower edge price value
     double          getLowerEdgePrice(int index,int shift);                                    
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CPriceChlStatus::init()
{

}

//+------------------------------------------------------------------+
// set edge rate
//+------------------------------------------------------------------+
void CPriceChlStatus::setEdgeRate(int index,int shift,double value){
   this.edgeRate[index][shift]=value;
}

//+------------------------------------------------------------------+
//  get edge rate
//+------------------------------------------------------------------+
double CPriceChlStatus::getEdgeRate(int index,int shift){
   return this.edgeRate[index][shift];
}

//+------------------------------------------------------------------+
//  set edge strengthRate
//+------------------------------------------------------------------+
void CPriceChlStatus::setStrengthRate(int index,int shift,double value){
   this.strengthRate[index][shift]=value;  
}

//+------------------------------------------------------------------+
//  get edge strengthRate
//+------------------------------------------------------------------+
double CPriceChlStatus::getStrengthRate(int index,int shift){
   return this.strengthRate[index][shift];
}

//+------------------------------------------------------------------+
//  set edge price value
//+------------------------------------------------------------------+
void CPriceChlStatus::setEdgePrice(int index,
                                    int shift,
                                    double upperEdgePrice,
                                    double lowerEdgePrice){
   if(index>=0){
      this.upperEdge[index][shift]=upperEdgePrice;
      this.lowerEdge[index][shift]=lowerEdgePrice;
   }   
}

//+------------------------------------------------------------------+
// get upper edge price value
//+------------------------------------------------------------------+
double CPriceChlStatus::getUpperEdgePrice(int index,int shift){
   return this.upperEdge[index][shift];
}

//+------------------------------------------------------------------+           
// get lower edge price value
//+------------------------------------------------------------------+
double CPriceChlStatus::getLowerEdgePrice(int index,int shift){
   return this.lowerEdge[index][shift];
}

//+------------------------------------------------------------------+           
// set edge break diff pips
//+------------------------------------------------------------------+
void CPriceChlStatus::setEdgeBrkDiffPips(int index,double value){
   this.edgeBrkDiffPips[index]=value;
}

//+------------------------------------------------------------------+           
// get edge break diff pips
//+------------------------------------------------------------------+
double CPriceChlStatus::getEdgeBrkDiffPips(int index){
   return this.edgeBrkDiffPips[index];
}


//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CPriceChlStatus::CPriceChlStatus(){
   ArrayInitialize(this.edgeBrkDiffPips,0);
   ArrayInitialize(this.edgeRate,0);
   ArrayInitialize(this.strengthRate,0);
   ArrayInitialize(this.upperEdge,0);
   ArrayInitialize(this.lowerEdge,0);
}
CPriceChlStatus::~CPriceChlStatus(){}