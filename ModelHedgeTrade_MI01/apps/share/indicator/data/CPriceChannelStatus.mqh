//+------------------------------------------------------------------+
//|                                          CPriceChannelStatus.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "..\CHeader.mqh"

class CPriceChannelStatus
  {
private: 
      double      edgeRate;
      double      edgeBrkDiffPips;
      double      strengthRate;
      double      strengthUnitPips;
      double      upperEdge[30];
      double      lowerEdge[30];
      double      upperEdgeOuter;
      double      lowerEdgeOuter;
public:
                     CPriceChannelStatus();
                    ~CPriceChannelStatus();
     
     //--- methods of initilize
     void            init(); 
     //--- set edge rate
     void            setEdgeRate(double value);
     //--- get edge rate
     double          getEdgeRate();
     //--- set edge strengthRate
     void            setStrengthRate(double value);
     //--- get edge strengthRate
     double          getStrengthRate();
     //--- set edge price value
     void            setEdgePrice(int index,
                                    double upperEdgePrice,
                                    double lowerEdgePrice);
     //--- get strength UnitPips
     double          getStrengthUnitPips();
     //--- set strength UnitPips
     void            setStrengthUnitPips(double value);
     //--- get upper edge price value
     double          getUpperEdgePrice(int index);                                    
     //--- get lower edge price value
     double          getLowerEdgePrice(int index); 
     //--- get edge Break DiffPips
     double          getEdgeBrkDiffPips();
     //--- set edge Break DiffPips
     void            setEdgeBrkDiffPips(double value);
     //--- set upper Edge Outer
     void            setUpperEdgeOuter(double edgePrice);     
     //--- set upper Edge Outer
     void            setLowerEdgeOuter(double edgePrice);     
     //--- get upper Edge Outer
     double          getUpperEdgeOuter();
     //--- get upper Edge Outer
     double          getLowerEdgeOuter();
  };

//+------------------------------------------------------------------+
//|  initialize the class
//+------------------------------------------------------------------+
void CPriceChannelStatus::init()
{

}

//+------------------------------------------------------------------+
// set edge rate
//+------------------------------------------------------------------+
void CPriceChannelStatus::setEdgeRate(double value){
   this.edgeRate=value;
}

//+------------------------------------------------------------------+
//  get edge rate
//+------------------------------------------------------------------+
double CPriceChannelStatus::getEdgeRate(){
   return this.edgeRate;
}

//+------------------------------------------------------------------+
//  set edge strengthRate
//+------------------------------------------------------------------+
void CPriceChannelStatus::setStrengthRate(double value){
   this.strengthRate=value;  
}

//+------------------------------------------------------------------+
//  get edge strengthRate
//+------------------------------------------------------------------+
double CPriceChannelStatus::getStrengthRate(){
   return this.strengthRate;
}

//+------------------------------------------------------------------+
//  get strength UnitPips
//+------------------------------------------------------------------+
double CPriceChannelStatus::getStrengthUnitPips(){
   return this.strengthUnitPips;
}

//+------------------------------------------------------------------+
//  set strength UnitPips
//+------------------------------------------------------------------+
void CPriceChannelStatus::setStrengthUnitPips(double value){
      this.strengthUnitPips=value;
}

//+------------------------------------------------------------------+
//  set edge price value
//+------------------------------------------------------------------+
void CPriceChannelStatus::setEdgePrice(int index,
                                    double upperEdgePrice,
                                    double lowerEdgePrice){
   if(index>=0){
      this.upperEdge[index]=upperEdgePrice;
      this.lowerEdge[index]=lowerEdgePrice;
   }   
}

//+------------------------------------------------------------------+
// get upper edge price value
//+------------------------------------------------------------------+
double CPriceChannelStatus::getUpperEdgePrice(int index){
   return this.upperEdge[index];
}

//+------------------------------------------------------------------+           
// get lower edge price value
//+------------------------------------------------------------------+
double CPriceChannelStatus::getLowerEdgePrice(int index){
   return this.lowerEdge[index];
}

//+------------------------------------------------------------------+
// get edge Break DiffPips
//+------------------------------------------------------------------+
double CPriceChannelStatus::getEdgeBrkDiffPips(){
   return this.edgeBrkDiffPips;
}

//+------------------------------------------------------------------+           
// set edge Break DiffPips
//+------------------------------------------------------------------+
void CPriceChannelStatus::setEdgeBrkDiffPips(double value){
   this.edgeBrkDiffPips=value;
}

//+------------------------------------------------------------------+           
// set upper Edge Outer
//+------------------------------------------------------------------+
void CPriceChannelStatus::setUpperEdgeOuter(double edgePrice){
   this.upperEdgeOuter=edgePrice;
}    

//+------------------------------------------------------------------+           
// set lower Edge Outer
//+------------------------------------------------------------------+
void CPriceChannelStatus::setLowerEdgeOuter(double edgePrice){
   this.lowerEdgeOuter=edgePrice;
}

//+------------------------------------------------------------------+           
// get upper Edge Outer
//+------------------------------------------------------------------+           
double CPriceChannelStatus::getUpperEdgeOuter(){
   return this.upperEdgeOuter;
}

//+------------------------------------------------------------------+           
// get upper Edge Outer
//+------------------------------------------------------------------+           
double CPriceChannelStatus::getLowerEdgeOuter(){
   return this.lowerEdgeOuter;
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CPriceChannelStatus::CPriceChannelStatus(){
   this.edgeRate=0;
   this.strengthRate=0;
   this.upperEdgeOuter=0;
   this.lowerEdgeOuter=0;
   ArrayInitialize(this.upperEdge,0);
   ArrayInitialize(this.lowerEdge,0);
}
CPriceChannelStatus::~CPriceChannelStatus(){}