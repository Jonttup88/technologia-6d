TYPE
    MainFbType : STRUCT 
    	fb : BOOL;
    END_STRUCT;
END_TYPE
TYPE
    MainLocalType : STRUCT 
    	lastState : DINT;
	lastSubState : DINT;
	actions : MainActionsType;
    END_STRUCT;
END_TYPE
TYPE
    MainActionsType : STRUCT 
    	task : MainTaskActionsType;(*Task actions are not automatically reset*)
	state : MainStateActionsType;(*State actions are automatically reset whenever major task changes*)
	substate : MainSubstateActionsType;(*Substate actions are automatically reset whenever major or substate changes*)
    END_STRUCT;
END_TYPE
TYPE
    MainTaskActionsType : STRUCT 
    	task_action : BOOL;
    END_STRUCT;
END_TYPE
TYPE
    MainStateActionsType : STRUCT 
    	state_action : BOOL;
    END_STRUCT;
END_TYPE
TYPE
    MainSubstateActionsType : STRUCT 
    	substate_action : BOOL;
    END_STRUCT;
END_TYPE
TYPE
    MainHmiType : STRUCT 
    	isRunning : BOOL;
    END_STRUCT;
END_TYPE
