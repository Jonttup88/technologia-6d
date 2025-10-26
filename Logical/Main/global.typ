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
		MAIN_RESET,
		MAIN_DEMO,
		MAIN_GAME,
		MAIN_ERROR
		);
	MainDifficultyLevelEnum : 
		(
		DIFFICULTY_EASY,
		DIFFICULTY_NORMAL,
		DIFFICULTY_HARD
		);
END_TYPE

(*========== INPUTS ==========*)

TYPE
	MainInputCommandType : 	STRUCT 
		Start : BOOL;
		Stop : BOOL;
		Reset : BOOL;
		SetModeDemo : BOOL;
		SetModeGame : BOOL;
		SetDifficultyEasy : BOOL;
		SetDifficultyNormal : BOOL;
		SetDifficultyHard : BOOL;
	END_STRUCT;
	MainInputStatusType : 	STRUCT 
		SetupComplete : BOOL;
	END_STRUCT;
	MainInputType : 	STRUCT 
		Force : BOOL;
		Command : MainInputCommandType;
		Status : MainInputStatusType;
	END_STRUCT;
END_TYPE

(*========== OUTPUTS ==========*)

TYPE
	MainOutputStatusCmdAllowedType : 	STRUCT 
		Start : BOOL;
		Stop : BOOL;
		Reset : BOOL;
		SetModeDemo : BOOL;
		SetModeGame : BOOL;
		SetDifficultyEasy : BOOL;
		SetDifficultyNormal : BOOL;
		SetDifficultyHard : BOOL;
	END_STRUCT;
	MainOutputCommandType : 	STRUCT 
		NewCommand : BOOL;
	END_STRUCT;
	MainOutputStatusType : 	STRUCT 
		CommandAllowed : MainOutputStatusCmdAllowedType;
		DifficultyLevel : MainDifficultyLevelEnum;
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
