//+------------------------------------------------------------------+
//|                                                 CModelAction.mqh |
//|                                                         rkee.rkk |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rkee.rkk"
#property link      ""
#property version   "1.00"


//+------------------------------------------------------------------+
//|  Model action define
//+------------------------------------------------------------------+

//--- model range
#define MODEL_ACTION_RANGE                   (101)                   // model range action 01

//--- model exceed
#define MODEL_ACTION_EXCEED                  (201)                   // model exceed action 01
#define MODEL_ACTION_EXCEED_LOCK             (211)                   // model exceed lock action01

class CModelAction {
private:
    int Action;
    int actionIndex;

public:
    CModelAction();
    ~CModelAction();

    // Getter functions
    int getAction() const;
    int getActionIndex() const;

    // Setter functions
    void setAction(int action);
    void setActionIndex(int index);
};

//+------------------------------------------------------------------+
//|  class constructor   
//+------------------------------------------------------------------+
CModelAction::CModelAction() {}
CModelAction::~CModelAction() {}

// Getter function implementations
int CModelAction::getAction() const {
    return Action;
}

int CModelAction::getActionIndex() const {
    return actionIndex;
}

// Setter function implementations
void CModelAction::setAction(int action) {
    Action = action;
}

void CModelAction::setActionIndex(int index) {
    actionIndex = index;
}