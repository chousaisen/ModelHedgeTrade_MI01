//+------------------------------------------------------------------+
//|                                                        CDbPool.mqh|
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"

#include "enums.mqh"
#include "CDbConnFactory.mqh"

class CDbPool {
   private:
      EDbDriver m_driver;
      IDbConn  *m_master1;
      IDbConn  *m_slave1;
      IDbConn  *m_slave2;

   public:
      CDbPool(){
         this.m_driver=DB_DRIVER_SQLITE;
         this.m_master1=NULL;
         this.m_slave1=NULL;
         this.m_slave2=NULL;
      }

      bool Init(EDbDriver driver,
                bool useMaster1,bool useSlave1,bool useSlave2,
                string masterDbName,string slave1DbName,string slave2DbName){
         this.m_driver=driver;

         if(useMaster1){
            this.m_master1=CDbConnFactory::Create(this.m_driver);
            if(CheckPointer(this.m_master1)==POINTER_INVALID || !this.m_master1->Open(masterDbName)) return false;
         }
         if(useSlave1){
            this.m_slave1=CDbConnFactory::Create(this.m_driver);
            if(CheckPointer(this.m_slave1)==POINTER_INVALID || !this.m_slave1->Open(slave1DbName)) return false;
         }
         if(useSlave2){
            this.m_slave2=CDbConnFactory::Create(this.m_driver);
            if(CheckPointer(this.m_slave2)==POINTER_INVALID || !this.m_slave2->Open(slave2DbName)) return false;
         }

         return true;
      }

      IDbConn* Get(EDbNode node){
         if(node==DB_MASTER1) return this.m_master1;
         if(node==DB_SLAVE1) return this.m_slave1;
         if(node==DB_SLAVE2) return this.m_slave2;
         return NULL;
      }

      void Shutdown(){
         if(CheckPointer(this.m_master1)!=POINTER_INVALID && this.m_master1!=NULL){ this.m_master1->Close(); delete this.m_master1; }
         if(CheckPointer(this.m_slave1)!=POINTER_INVALID && this.m_slave1!=NULL){ this.m_slave1->Close(); delete this.m_slave1; }
         if(CheckPointer(this.m_slave2)!=POINTER_INVALID && this.m_slave2!=NULL){ this.m_slave2->Close(); delete this.m_slave2; }
         this.m_master1=NULL;
         this.m_slave1=NULL;
         this.m_slave2=NULL;
      }
};
