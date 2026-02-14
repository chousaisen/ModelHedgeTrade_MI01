//+------------------------------------------------------------------+
//|                                           CModelCostLine.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"


class CModelCostLine{
  private: 
         bool           costExist;         
         double         upperEdge;
         double         downEdge;
         double         costCenter;
         double         costUpperCenter;
         double         costDownCenter;
         double         costUpperEdge;
         double         costDownEdge;
         double         costUpperEdgeRate;
         double         costDownEdgeRate;
         double         costEdgeRate;
  public:
                        CModelCostLine();
                        ~CModelCostLine();
                        
         // Getters
         bool   isCostExist() const { return this.costExist; }
         double getUpperEdge() const { return upperEdge; }
         double getDownEdge() const { return downEdge; }             
         double getCostCenter() const { return costCenter; }
         double getCostUpperCenter() const { return costUpperCenter; }
         double getCostDownCenter() const { return costDownCenter; }
         double getCostUpperEdge() const { return costUpperEdge; }
         double getCostDownEdge() const { return costDownEdge; }
         double getCostUpperEdgeRate() const { return costUpperEdgeRate; }
         double getCostDownEdgeRate() const { return costDownEdgeRate; }
         double getCostEdgeRate() const { return costEdgeRate; }
         
         // Setters
         void setCostExist(double value) { this.costExist = value; }
         void setUpperEdge(double value) { upperEdge = value; }
         void setDownEdge(double value) { downEdge = value; }         
         void setCostCenter(double value) { costCenter = value; }
         void setCostUpperCenter(double value) { costUpperCenter = value; }
         void setCostDownCenter(double value) { costDownCenter = value; }
         void setCostUpperEdge(double value) { costUpperEdge = value; }
         void setCostDownEdge(double value) { costDownEdge = value; }
         void setCostUpperEdgeRate(double value) { costUpperEdgeRate = value; }
         void setCostDownEdgeRate(double value) { costDownEdgeRate = value; }   
         
         // calculate data 
         void calculateEdge(double curPrice,double point,double extendPips);
               
};

//+------------------------------------------------------------------+
// calculate edge line
//+------------------------------------------------------------------+
void CModelCostLine::calculateEdge(double curPrice,double point,double extendPips){
   
   this.costUpperEdge=this.costUpperCenter+extendPips*point;
   this.costDownEdge=this.costDownCenter-extendPips*point;
      
   double costUpperEdgePips=(this.costUpperEdge-this.costCenter)/point;
   double costDownEdgePips=(this.costCenter-this.costDownEdge)/point;   
   
   this.costUpperEdgeRate=0;
   this.costDownEdgeRate=0; 
   this.costEdgeRate=0;  
   if(curPrice>=this.costCenter){
      double curUpperCenterPips=(curPrice-this.costCenter)/point;
      if(costUpperEdgePips>0){
         this.costUpperEdgeRate=curUpperCenterPips/costUpperEdgePips;
         this.costEdgeRate=this.costUpperEdgeRate;
      }            
   }else if(curPrice<this.costCenter){
      double curDownCenterPips=(this.costCenter-curPrice)/point;
      if(costDownEdgePips>0){
         this.costDownEdgeRate=curDownCenterPips/costDownEdgePips;
         this.costEdgeRate=this.costDownEdgeRate;
      }            
   }
} 

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelCostLine::CModelCostLine(){
   this.costExist=false;
}
CModelCostLine::~CModelCostLine(){
}