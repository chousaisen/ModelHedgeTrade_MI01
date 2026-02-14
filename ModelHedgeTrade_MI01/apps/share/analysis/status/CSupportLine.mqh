//+------------------------------------------------------------------+
//|                                           CSupportLine.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "..\..\..\comm\ComFunc2.mqh"
#include "..\..\..\client\CClientCtl.mqh"
#include "..\..\symbol\CSymbolInfos.mqh"

class CSupportLine{
  private: 
         bool           topFlg;
         double         upperEdge;      
         double         downEdge;
         double         supportCount;        
  public:
                        CSupportLine();
                        ~CSupportLine();
         
          //--- init 
          void          init(CSymbolInfos* symbolInfos);

          //---------------------------------------------
          //--- parameter get functions
          //---------------------------------------------
          double getUpperEdge() const { return upperEdge; }
          double getDownEdge() const { return downEdge; }         
          double getSupportCount() const { return supportCount; } 
          
          //---------------------------------------------
          //--- parameter set functions
          //---------------------------------------------
          void setTopFlg() { this.topFlg=true; }
          void reSet() {
            this.upperEdge=0;
            this.downEdge=0;  
            this.supportCount=0;          
          }
          
          //--- set edge price
          void setEdge(double value){
            if(this.upperEdge==0){
               this.upperEdge=value;
            }else if(this.upperEdge<value){
               this.upperEdge=value;
            }            
            if(this.downEdge==0){
               this.downEdge=value;
            }else if(this.downEdge>value){
               this.downEdge=value;
            }
            if(value>0)this.supportCount+=1;
          }          
          
          void setUpperEdge(double value) { upperEdge = value; }
          void setDownEdge(double value) { downEdge = value; }
          void setSupportCount(double value) { supportCount = value; }
};

//+------------------------------------------------------------------+
//|  init
//+------------------------------------------------------------------+
void CSupportLine::init(CSymbolInfos* symbolInfos){
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CSupportLine::CSupportLine(){
   this.upperEdge=0;
   this.downEdge=0;  
   this.supportCount=0;
   this.topFlg=false;
}
CSupportLine::~CSupportLine(){
}