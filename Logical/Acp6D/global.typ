(*    
Program: Acp6D

Description
(short summary)

*)
(*========== STATES ==========*)

TYPE
	Acp6DStateEnum : 
		(
		ACP6D_INITIALIZE,
		ACP6D_IDLE,
		ACP6D_MOVE_TO,
		ACP6D_ERROR,
		ACP6D_COMMAND_ERROR,
		ACP6D_COMMAND_DONE,
		ACP6D_SELECT_SHUTTLE,
		ACP6D_FIND_PAYLOAD,
		ACP6D_SHUFFLE_SIMPLE,
		ACP6D_SHUFFLE_CIRCULAR,
		ACP6D_STOP_ALL,
		ACP6D_FORCE_RESET,
		ACP6D_VICTORY,
		ACP6D_LOSE,
		ACP6D_ANIMATE,
		ACP6D_DEMO
		);
END_TYPE

(*========== INPUTS ==========*)

TYPE
	Acp6DInputCommandType : 	STRUCT 
		Reinitialize : BOOL;
		ForceReset : BOOL;
		StopAll : BOOL;
		Victory : BOOL;
		Lose : BOOL;
		Animate : BOOL;
		MoveTo : Acp6DMoveToCommandType;
		FindPayload : BOOL;
		SelectShuttle : BOOL;
		Shuffle : Acp6DShuffleCommandType;
		StartDemoMode : BOOL;
		StopDemoMode : BOOL;
	END_STRUCT;
	Acp6DMoveToCommandType : 	STRUCT 
		Home : BOOL;
		User : BOOL;
		Pickup : BOOL;
		Shuffle : BOOL;
		Clockface : BOOL;
		Dance : BOOL;
		Side : BOOL;
	END_STRUCT;
	Acp6DShuffleCommandType : 	STRUCT 
		Simple : BOOL;
		Circular : BOOL;
	END_STRUCT;
	Acp6DInputStatusType : 	STRUCT 
		test : BOOL;
	END_STRUCT;
	Acp6DInputType : 	STRUCT 
		Force : BOOL;
		Command : Acp6DInputCommandType;
		Status : Acp6DInputStatusType;
	END_STRUCT;
END_TYPE

(*========== OUTPUTS ==========*)

TYPE
	Acp6DOutputStatusType : 	STRUCT 
		Initialized : BOOL;
		CommandDone : BOOL;
		DemoModeActive : BOOL;
	END_STRUCT;
	Acp6DOutputType : 	STRUCT 
		Status : Acp6DOutputStatusType;
		TotalShuttleCount : DINT;
		AssemblyInfo : McAcp6DAsmInfoType;
		ShuttleWithPayload : Acp6DOutputShuttleType;
		ShuttleUserSelected : Acp6DOutputShuttleType;
	END_STRUCT;
	Acp6DOutputShuttleType : 	STRUCT 
		index : DINT;
		X : REAL;
		Y : REAL;
	END_STRUCT;
END_TYPE

(*========== ERRORS ==========*)

TYPE
	Acp6DErrorType : 	STRUCT 
		Active : BOOL;
		Acknowledge : BOOL;
		Code : DINT;
		State : Acp6DStateEnum;
		SubState : DINT;
	END_STRUCT;
END_TYPE

(*========== INTERFACE ==========*)

TYPE
	Acp6DType : 	STRUCT 
		Error : Acp6DErrorType;
		Input : Acp6DInputType;
		Output : Acp6DOutputType;
		IsSimulated : BOOL;
		State : Acp6DStateEnum;
		SubState : DINT;
		StateInfo : STRING[255];
		OnStateEntry : BOOL; (*True for one cycle after state change*)
	END_STRUCT;
END_TYPE
