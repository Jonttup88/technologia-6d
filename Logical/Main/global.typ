(*    
Program: Main

Description
(short summary)

*)
(*========== STATES ==========*)

TYPE
	MainStateEnum : 
		(
		MAIN_INITIALIZE,
		MAIN_IDLE,
		MAIN_DEMO,
		MAIN_GAME,
		MAIN_ERROR,
		MAIN_RESET
		);
	MainDifficultyLevelEnum : 
		(
		DIFFICULTY_EASY,
		DIFFICULTY_HARD
		);
END_TYPE

(*========== INPUTS ==========*)

TYPE
	MainInputCommandType : 	STRUCT 
		Reset : BOOL;
		StartGame : BOOL;
		ReleasePrize : BOOL;
	END_STRUCT;
	MainInputStatusType : 	STRUCT 
		SetupComplete : BOOL;
	END_STRUCT;
	MainInputType : 	STRUCT 
		Force : BOOL;
		Command : MainInputCommandType;
		Status : MainInputStatusType;
		GameMode : DINT;
	END_STRUCT;
END_TYPE

(*========== OUTPUTS ==========*)

TYPE
	MainOutputStatusCmdAllowedType : 	STRUCT 
		StartGame : BOOL;
		Reset : BOOL;
	END_STRUCT;
	MainOutputCommandType : 	STRUCT 
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
		br6dDance : BOOL;
		br6dSpellLose : BOOL;
		br6dSpellWin : BOOL;
	END_STRUCT;
	MainOutputStatusType : 	STRUCT 
		CommandAllowed : MainOutputStatusCmdAllowedType;
	END_STRUCT;
	MainOutputType : 	STRUCT 
		Command : MainOutputCommandType;
		Status : MainOutputStatusType;
	END_STRUCT;
END_TYPE

(*========== ERRORS ==========*)

TYPE
	MainErrorType : 	STRUCT 
		Active : BOOL;
		Acknowledge : BOOL;
		Code : DINT;
		Description : STRING[80];
	END_STRUCT;
END_TYPE

(*========== SETTINGS ==========*)

TYPE
	MainSettingsType : 	STRUCT 
		Enable : BOOL;
	END_STRUCT;
END_TYPE

(*========== INTERFACE ==========*)

TYPE
	MainType : 	STRUCT 
		Error : MainErrorType;
		Input : MainInputType;
		Output : MainOutputType;
		Settings : MainSettingsType;
		IsSimulated : BOOL;
		State : MainStateEnum;
		SubState : DINT;
		StateInfo : STRING[255];
		OnStateEntry : BOOL; (*True for one cycle after state change*)
	END_STRUCT;
END_TYPE
