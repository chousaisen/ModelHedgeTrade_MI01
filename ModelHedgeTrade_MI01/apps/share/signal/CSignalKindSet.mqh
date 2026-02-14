//+------------------------------------------------------------------+
//|                                                SignalTimeSet.mqh |
//|                                   |
//|                                             
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Generic\ArrayList.mqh>
#include <Generic\HashMap.mqh>
#include "CSignal.mqh"
#include "CSignalList.mqh"
#include "CSignalTimeSet.mqh"

class CSignalKindSet
  {
public:
      int signalKind;  // Type of signal
      ulong sequence;  // Sequence number for signals
      CHashMap<int,CSignalTimeSet*> signalKindSet; // Hash map storing signal kind sets
      //signal kind list
      CArrayList<int> signalKindList;        
public:
      // Constructor: initializes signalKindSet
      CSignalKindSet();
      
      // Constructor: initializes with a specific signal kind
      CSignalKindSet(int signalKind);
      
      // Destructor: clears the signalKindSet
     ~CSignalKindSet();     
     
      //+------------------------------------------------------------------+
      //| Get the signal time set for a specific kind
      //+------------------------------------------------------------------+            
      bool getSignalTimeSet(int kind,CSignalTimeSet *&signalTimeSet){
         return this.signalKindSet.TryGetValue(kind,signalTimeSet);
      }
      
      //+------------------------------------------------------------------+
      //| Get or create a signal time set for a specific kind
      //+------------------------------------------------------------------+            
      CSignalTimeSet* getSignalTimeSet(int kind){         
         CSignalTimeSet *signalTimeSet;
         if(!getSignalTimeSet(kind,signalTimeSet)){
            signalTimeSet=new CSignalTimeSet();   // Create a new signal time set if not found
            this.signalKindSet.Add(kind,signalTimeSet);   // Add the new set to the hash map
            this.signalKindList.Add(kind);
         }
         return signalTimeSet;       
      }  
      
      //+------------------------------------------------------------------+
      //| Get the signal list for a specific kind and day
      //+------------------------------------------------------------------+      
      CSignalList* getSignalList(int kind,int day){
         CSignalTimeSet *signalTimeSet=getSignalTimeSet(day);
         if(signalTimeSet!=NULL){
            return signalTimeSet.getSignalList(day);   // Retrieve signal list if the time set is available         
         }
         return NULL; // Return NULL if not found
      }

      //+------------------------------------------------------------------+
      //| Add a signal to the signal list for a specific kind and day
      //+------------------------------------------------------------------+      
      void addSignalList(int kind,int day,CSignal *signal){
         //comFunc.printfs("addSignalList day:" + " kind:" + kind);
         CSignalList *signalList=this.getSignalList(kind,day);
         if(signalList!=NULL){
            signal.setSequence(getSignalSequence());  
            signalList.add(signal);  // Add signal to the list        
         }
      }
      
      //+------------------------------------------------------------------+
      //| Clear the entire signalKindSet hash map
      //+------------------------------------------------------------------+      
      void clear(){
       this.signalKindSet.Clear();
      }
      
      //+------------------------------------------------------------------+
      //| Generate and return a unique sequence number for the signal
      //+------------------------------------------------------------------+      
      int getSignalSequence(){         
         this.sequence=this.sequence+1; // Increment sequence
         int signalSequence=this.signalKind*10000000+this.sequence; 
         return signalSequence;
      }
      
      //+------------------------------------------------------------------+
      //| Set the signal kind
      //+------------------------------------------------------------------+      
      void setSignalKind(int kind){this.signalKind=kind;}                        
  };
  
  
//+------------------------------------------------------------------+
//| Constructor: initializes sequence to 0                           |
//+------------------------------------------------------------------+
CSignalKindSet::CSignalKindSet()
  {
      this.sequence=0;
  }
  
//+------------------------------------------------------------------+
//| Constructor: initializes with a specific signal kind              
//| and sets sequence to 0                                            
//+------------------------------------------------------------------+
CSignalKindSet::CSignalKindSet(int signalKind)
  {
   this.sequence=0;
   this.signalKind=signalKind;
  }  
  
//+------------------------------------------------------------------+
//| Destructor: deletes the signalKindSet hash map                    |
//+------------------------------------------------------------------+
CSignalKindSet::~CSignalKindSet()
{  
   for (int i = 0; i < this.signalKindList.Count(); i++) {
      int signalKind;
      this.signalKindList.TryGetValue(i,signalKind);
      CSignalTimeSet* signalTimeSet;
      this.signalKindSet.TryGetValue(signalKind,signalTimeSet);
      delete signalTimeSet;
   }  
}
//+------------------------------------------------------------------+
