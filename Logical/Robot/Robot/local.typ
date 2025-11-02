
TYPE
	RobotFbType : 	STRUCT 
		BrAbbRwsCore_0 : BrAbbRwsCore;
		BrAbbRwsVariable_read : BrAbbRwsVariable;
		BrAbbRwsVariable_write : BrAbbRwsVariable;
		BrAbbRwsGetState_0 : BrAbbRwsGetState;
		TON_RobState : TON;
		TON_ReadDelay : TON;
		TON_DoneDelay : TON;
	END_STRUCT;
	RobotLocalType : 	STRUCT 
		lastState : DINT;
		lastSubState : DINT;
		actions : RobotActionsType;
		readRobotValues : BOOL;
		robReadStateLast : DINT;
		robReadNum : DINT;
		robTargetX_mm : REAL;
		robTargetY_mm : REAL;
	END_STRUCT;
	RobotActionsType : 	STRUCT 
		task : RobotTaskActionsType; (*Task actions are not automatically reset*)
		state : RobotStateActionsType; (*State actions are automatically reset whenever major task changes*)
		substate : RobotSubstateActionsType; (*Substate actions are automatically reset whenever major or substate changes*)
	END_STRUCT;
	RobotTaskActionsType : 	STRUCT 
		task_action : BOOL;
	END_STRUCT;
	RobotStateActionsType : 	STRUCT 
		ready_for_next_command : BOOL;
	END_STRUCT;
	RobotSubstateActionsType : 	STRUCT 
		command_done : BOOL;
		command_error : BOOL;
		write : BOOL;
		write_reset : BOOL;
		delay : BOOL;
		hard_reset_done : BOOL;
	END_STRUCT;
	RobotHmiType : 	STRUCT 
		isRunning : BOOL;
	END_STRUCT;
END_TYPE
