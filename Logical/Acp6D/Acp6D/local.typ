
TYPE
	Acp6DActionsType : 	STRUCT 
		task : Acp6DTaskActionsType; (*Task actions are not automatically reset*)
		state : Acp6DStateActionsType; (*State actions are automatically reset whenever major task changes*)
		substate : Acp6DSubstateActionsType; (*Substate actions are automatically reset whenever major or substate changes*)
	END_STRUCT;
	Acp6DFbType : 	STRUCT 
		AssemblyReadInfo : MC_BR_AsmReadInfo_Acp6D;
		AssemblyPowerOn : MC_BR_AsmPowerOn_Acp6D;
		AssemblyPowerOff : MC_BR_AsmPowerOff_Acp6D;
		AssemblyReset : MC_BR_AsmReset_Acp6D;
		AssemblyGetShuttle : MC_BR_AsmGetShuttle_Acp6D;
		assemblyStop : MC_BR_AsmStop_Acp6D;
		MoveInPlaneAsync : MC_BR_MoveInPlaneAsync_Acp6D;
		TON_delay : TON;
		Move6D : ARRAY[0..gMAX_INDEX_SHUTTLE]OF MC_BR_Move6D_Acp6D;
		ReadCyclicForce : ARRAY[0..gMAX_INDEX_SHUTTLE]OF MC_BR_ReadCyclicForce_Acp6D;
		ReadCyclicPosition : ARRAY[0..gMAX_INDEX_SHUTTLE]OF MC_BR_ReadCyclicPosition_Acp6D;
		MoveCyclicPosition : ARRAY[0..gMAX_INDEX_SHUTTLE]OF MC_BR_MoveCyclicPosition_Acp6D;
		MoveQueue : ARRAY[0..gMAX_INDEX_SHUTTLE]OF brfi6DMoveQueue;
		ShGetInfo : MC_BR_ShGetInfo_Acp6D;
		virtualShCreate : MC_BR_VirtualShCreate_Acp6D;
		assemblyGetVirtualSh : MC_BR_AsmGetVirtualSh_Acp6D;
	END_STRUCT;
	Acp6DHmiType : 	STRUCT 
		isRunning : BOOL;
	END_STRUCT;
	Acp6DLocalType : 	STRUCT 
		lastState : DINT;
		lastSubState : DINT;
		actions : Acp6DActionsType;
		allValid : BOOL;
		measurement_index : DINT;
		targetPos : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
		shuttleOrder : ARRAY[0..gMAX_INDEX_SHUTTLE]OF DINT;
		Fz_highest : REAL;
		executing : BOOL;
		selectedCount : DINT;
		virtualShuttleCount : DINT;
	END_STRUCT;
	Acp6DTaskActionsType : 	STRUCT 
		dummy : BOOL;
	END_STRUCT;
	Acp6DStateActionsType : 	STRUCT 
		assemblyGetShuttles : BOOL;
		assemblyGetNextShuttle : BOOL;
		cyclicModeRequest : Acp6DCyclicModeEnum;
	END_STRUCT;
	Acp6DSubstateActionsType : 	STRUCT 
		assemblyPowerOff : BOOL;
		assemblyPowerOn : BOOL;
		assemblyReset : BOOL;
		assemblyStop : BOOL;
		createShuttleVirtual : BOOL;
		moveInPlaneAsync : BOOL;
		delay : BOOL;
	END_STRUCT;
	Acp6DTablePositionType : 	STRUCT 
		home : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
		user : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
		side : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
		pickup : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
		shuffle : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
		clockface : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
		dance : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
		shuffle_simple : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
		kongo_lines : ARRAY[0..gMAX_INDEX_SHUTTLE]OF McAcp6DShPositionType;
	END_STRUCT;
END_TYPE

(**)

TYPE
	Acp6DCyclicChannelsType : 	STRUCT 
		mode : Acp6DCyclicModeEnum;
		allChannelsReleased : BOOL;
		allPositionsValid : BOOL;
		allForceValuesValid : BOOL;
		allControlReady : BOOL;
	END_STRUCT;
	Acp6DCyclicModeEnum : 
		(
		a6dCYCLIC_DISABLED := -1,
		a6dCYCLIC_READ_POSITION,
		a6dCYCLIC_READ_FORCE,
		a6dCYCLIC_MOVE_POSITION,
		a6dCYCLIC_RELEASE_CHANNELS
		);
END_TYPE

(**)

TYPE
	Acp6DMoveQueueStatusType : 	STRUCT 
		executing : BOOL;
		allDone : BOOL;
		allAcknowledge : BOOL;
		error : BOOL;
		errorID : DINT;
	END_STRUCT;
END_TYPE

(**)

TYPE
	Acp6DShuttleStatusPollType : 	STRUCT 
		state : DINT;
		index : DINT;
		allValid : BOOL;
		allIdle : BOOL;
	END_STRUCT;
	Acp6DShuffleType : 	STRUCT 
		invertedMove : BOOL;
		invertedDirection : DINT;
		randNum : DINT;
		payloadPos : DINT;
		angle : REAL;
		step : DINT;
		sequence : ARRAY[0..gMAX_INDEX_SHUFFLE]OF DINT;
	END_STRUCT;
	Acp6DRandomType : 	STRUCT 
		delaysIndex : DINT;
		delays : ARRAY[0..gMAX_INDEX_SHUTTLE]OF REAL;
		shuffleSequenceIndex : DINT;
		shuffleSequence : ARRAY[0..gMAX_INDEX_SHUFFLE]OF DINT;
	END_STRUCT;
END_TYPE
