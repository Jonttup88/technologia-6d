(*    
Program: Robot

Description
(short summary)

*)
(*========== STATES ==========*)

TYPE
	RobotStateEnum : 
		(
		ROBOT_INITIALIZE,
		ROBOT_IDLE,
		ROBOT_CMD_NORMAL,
		ROBOT_CMD_TARGET,
		ROBOT_COMMAND_DONE,
		ROBOT_COMMAND_ERROR,
		ROBOT_ERROR
		);
END_TYPE

(*========== INPUTS ==========*)

TYPE
	RobotInputCommandType : 	STRUCT 
		Home : BOOL;
		PickUp : BOOL;
		GetCandy : BOOL;
		GiveCandy : BOOL;
		Dance : BOOL;
	END_STRUCT;
	RobotInputStatusType : 	STRUCT 
		SetupComplete : BOOL;
	END_STRUCT;
	RobotInputType : 	STRUCT 
		Force : BOOL;
		Command : RobotInputCommandType;
		Status : RobotInputStatusType;
		RobCommandNum : REAL;
		RobTargetX : REAL;
		RobTargetY : REAL;
	END_STRUCT;
END_TYPE

(*========== OUTPUTS ==========*)

TYPE
	RobotOutputCommandType : 	STRUCT 
		NewCommand : BOOL;
	END_STRUCT;
	RobotOutputStatusType : 	STRUCT 
		CommunicationOk : BOOL;
		CommandDone : BOOL;
		CommandError : BOOL;
		RobReady : BOOL;
		RobPhaseDone : BOOL;
		RobError : BOOL;
		RobPhaseNum : REAL;
		RobRapidState : BrAbbRwsStateRapidStateEnum;
		RobMotorState : BrAbbRwsStateMotorStateEnum;
		RobActiveMode : BrAbbRwsStateActiveModeEnum;
	END_STRUCT;
	RobotOutputType : 	STRUCT 
		Command : RobotOutputCommandType;
		Status : RobotOutputStatusType;
	END_STRUCT;
END_TYPE

(*========== ERRORS ==========*)

TYPE
	RobotErrorType : 	STRUCT 
		Active : BOOL;
		Acknowledge : BOOL;
		Code : DINT;
		Description : STRING[80];
	END_STRUCT;
END_TYPE

(*========== SETTINGS ==========*)

TYPE
	RobotSettingsType : 	STRUCT 
		Enable : BOOL;
	END_STRUCT;
END_TYPE

(*========== INTERFACE ==========*)

TYPE
	RobotType : 	STRUCT 
		Error : RobotErrorType;
		Input : RobotInputType;
		Output : RobotOutputType;
		Settings : RobotSettingsType;
		IsSimulated : BOOL;
		State : RobotStateEnum;
		SubState : DINT;
		StateInfo : STRING[255];
		OnStateEntry : BOOL; (*True for one cycle after state change*)
		robReadState : DINT;
	END_STRUCT;
END_TYPE
