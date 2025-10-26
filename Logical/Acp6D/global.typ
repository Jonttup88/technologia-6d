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
		ACP6D_FIND_PAYLOAD
		);
	Acp6DCyclicModeEnum : 
		(
		a6dCYCLIC_DISABLED := -1,
		a6dCYCLIC_READ_POSITION,
		a6dCYCLIC_READ_FORCE,
		a6dCYCLIC_MOVE_POSITION,
		a6dCYCLIC_RELEASE_CHANNELS
		);
END_TYPE

(*========== INPUTS ==========*)

TYPE
	Acp6DInputCommandType : 	STRUCT 
		Reinitialize : BOOL;
		MoveToHome : BOOL;
		MoveToUser : BOOL;
		MoveToPickup : BOOL;
		MoveToShuffle : BOOL;
		MoveToClockface : BOOL;
		MoveToDance : BOOL;
		FindPayload : BOOL;
		SelectShuttle : BOOL;
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
	END_STRUCT;
	Acp6DOutputType : 	STRUCT 
		Status : Acp6DOutputStatusType;
		TotalShuttleCount : DINT;
		AssemblyInfo : McAcp6DAsmInfoType;
		ShuttleWithPayload : DINT;
		SelectedShuttle : DINT;
	END_STRUCT;
END_TYPE

(*========== ERRORS ==========*)

TYPE
	Acp6DErrorType : 	STRUCT 
		Active : BOOL;
		Acknowledge : BOOL;
		Code : DINT;
		Description : STRING[80];
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
		CyclicMode : Acp6DCyclicModeEnum;
	END_STRUCT;
END_TYPE
