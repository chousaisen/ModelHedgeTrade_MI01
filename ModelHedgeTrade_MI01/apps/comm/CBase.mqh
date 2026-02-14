//+------------------------------------------------------------------+
//|                                                       CBase.mqh |
//|                                                         rkee.rkk |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include <Generic\ArrayList.mqh>

#include "ComFunc.mqh"
#include "ComFunc2.mqh"
#include "..\header\CDefine.mqh"
#include "..\client\CClientCtl.mqh"

class CBase{
  private: 
         //client control  
         CClientCtl*         clientCtl;         
         //debug info (use to database table)
         string              debugDBInfo;              
  public:
                             CBase();
                             ~CBase();

         //--- set client control
         void              setClientCtl(CClientCtl* clientCtl); 
         
         //--- debug info(database)
         void              setDebugDBInfo(string tableInfo); 
         
         //--- insert info into table
         void              insertTable(string tableName,string insertTemplate);
         
         //--- get range status info
         string            getStatusInfo(int status);                              
};

//+------------------------------------------------------------------+
//|   debug info(database)
//+------------------------------------------------------------------+
void CBase::setDebugDBInfo(string tableInfo){
   this.debugDBInfo=tableInfo;
}

//+------------------------------------------------------------------+
//| set client control
//+------------------------------------------------------------------+
void CBase::setClientCtl(CClientCtl* clientCtl){
   this.clientCtl=clientCtl;
}

//+------------------------------------------------------------------+
//| insert info into table
//+------------------------------------------------------------------+
void CBase::insertTable(string tableName,string insertTemplate){
   this.clientCtl.getDB().saveData(tableName,insertTemplate);
}

//+------------------------------------------------------------------+
// get range status info
//+------------------------------------------------------------------+
string CBase::getStatusInfo(int status){
   switch(status){
      case STATUS_NONE:return "STATUS_NONE";
      case STATUS_RANGE_INNER:return "STATUS_RANGE_INNER";
      case STATUS_RANGE_BREAK_UP:return "STATUS_RANGE_BREAK_UP";
      case STATUS_RANGE_BREAK_DOWN:return "STATUS_RANGE_BREAK_DOWN";
   }   
   return "";
}

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CBase::CBase(){
}

CBase::~CBase(){}