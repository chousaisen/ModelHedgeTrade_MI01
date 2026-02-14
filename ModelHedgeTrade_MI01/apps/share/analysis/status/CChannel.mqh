//+------------------------------------------------------------------+
//|                                           CChannel.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\..\..\comm\ComFunc2.mqh"
#include "..\..\..\client\CClientCtl.mqh"
#include "..\..\symbol\CSymbolInfos.mqh"

class CChannel{
  private: 
         int            status;
         int            preBreakStatus;
         //double         supportLine;
         double         upperEdge;      
         double         downEdge;
         
         //double         supportLine;
         double         breakUpperEdge;      
         double         breakDownEdge;         
         
         double         upperRate;
         double         downRate;
         //additional parameter
         double         height;
         double         breakHeight;
         
         //symbol info
         int            symbolIndex;
         double         point;
         
  public:
                        CChannel();
                        ~CChannel();
         
         
          //init function
          void         init(int symbolIndex,double point){this.symbolIndex=symbolIndex;this.point=point;};
          
          //---------------------------------------------
          //--- parameter get functions
          //---------------------------------------------
          int    getStatus() const { return this.status;}
          int    getPreBreakStatus() const { return this.preBreakStatus;}
          double getUpperEdge() const { return this.upperEdge; }
          double getDownEdge() const { return this.downEdge; } 
          double getBreakUpperEdge() const { return this.breakUpperEdge; }
          double getBreakDownEdge() const { return this.breakDownEdge; }           
          double getUpperRate() const { return this.upperRate; }
          double getDownRate() const { return this.downRate; }
          //double getSupportLine() const { return this.supportLine;} 
                  
          void   setStatus(int value) { this.status = value; }
          void   setPreBreakStatus(int value) { this.preBreakStatus = value;}
          void   setUpperEdge(double value) { this.upperEdge = value; }
          void   setDownEdge(double value) { this.downEdge = value; } 
          void   setBreakUpperEdge(double value) { this.breakUpperEdge = value; }
          void   setBreakDownEdge(double value) { this.breakDownEdge = value; }
          //void   setSupportLine(double value) { this.supportLine = value; } 

          //get channel height pips
          double setBreakHeight(double value){
            return this.breakHeight=value;
          }          
          
          //make channel info
          void makeChannelInfo(double price);
          
          //get channel height pips
          double getChlHeight(){
            return this.height/this.point;
          }
          //get channel height pips
          double getChlBreakHeight(){
            return this.breakHeight/this.point;
          }          
                  
};

//+------------------------------------------------------------------+
//|  make channel info
//+------------------------------------------------------------------+
void CChannel::makeChannelInfo(double price){
   this.height=this.upperEdge-this.downEdge;
   double topEdgeHeight=this.upperEdge-price;
   if(this.height>0){
      this.upperRate=(this.height-topEdgeHeight)/this.height;
      if(this.upperRate<0)this.upperRate=0;
      this.downRate=1-this.upperRate;
   }
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CChannel::CChannel(){
   this.upperEdge=0;
   this.downEdge=0; 
   this.height=0;
   this.upperRate=0;
   this.downRate=0;
}
CChannel::~CChannel(){
}