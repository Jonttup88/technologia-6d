
TYPE
	MainStateEnum : 
		(
		MAIN_STARTUP,
		MAIN_POWER_OFF,
		MAIN_DISABLED,
		MAIN_POWER_ON,
		MAIN_GET_SHUTTLE,
		MAIN_GET_SHUTTLE_WAIT,
		MAIN_READY,
		MAIN_ERROR,
		MAIN_RESET
		);
	FeatureShuttle_typ : 	STRUCT 
		Shuttle : gShuttleListType;
		demoState : USINT;
		master : BOOL;
		FB : FeatureShuttleFBs_typ;
		counter : USINT;
		subState : USINT;
		ready : BOOL;
		runningFeature : USINT;
		alreadyBeenMaster : BOOL;
	END_STRUCT;
	FeatureShuttleFBs_typ : 	STRUCT 
		MoveInPlane : MC_BR_MoveInPlane_Acp6D;
		MoveArc : MC_BR_MoveArc_Acp6D;
		MoveShortAxis : MC_BR_MoveShortAxis_Acp6D;
		RotaryMotion : MC_BR_RotaryMotion_Acp6D;
		TON_0 : TON;
	END_STRUCT;
END_TYPE
