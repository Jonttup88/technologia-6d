
TYPE
	MainFbType : 	STRUCT 
		fb : BOOL;
	END_STRUCT;
	MainLocalType : 	STRUCT 
		lastState : DINT;
		lastSubState : DINT;
		actions : MainActionsType;
	END_STRUCT;
	MainActionsType : 	STRUCT 
		task : MainTaskActionsType; (*Task actions are not automatically reset*)
		state : MainStateActionsType; (*State actions are automatically reset whenever major task changes*)
		substate : MainSubstateActionsType; (*Substate actions are automatically reset whenever major or substate changes*)
	END_STRUCT;
	MainTaskActionsType : 	STRUCT 
		task_action : BOOL;
	END_STRUCT;
	MainStateActionsType : 	STRUCT 
		state_action : BOOL;
	END_STRUCT;
	MainSubstateActionsType : 	STRUCT 
		robHome : BOOL;
		robPickup : BOOL;
		robGivePrize : BOOL;
		robGetPrize : BOOL;
		robDance : BOOL;
		br6dReset : BOOL;
		br6dHome : BOOL;
		br6dFindPayload : BOOL;
		br6dSelectShuttle : BOOL;
		br6dSimpleShuffle : BOOL;
		br6dcircularShuffle : BOOL;
		br6dSpellWin : BOOL;
		br6dSpellLose : BOOL;
		br6dDance : BOOL;
	END_STRUCT;
	MainHmiType : 	STRUCT 
		isRunning : BOOL;
	END_STRUCT;
END_TYPE
