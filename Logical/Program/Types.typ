
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
		returnState : USINT;
		subState : USINT;
		ready : BOOL;
		runningFeature : USINT;
		alreadyBeenMaster : BOOL;
		Parameters : FeatureParams_typ;
		Status : FeatureStatus_typ;
	END_STRUCT;
	FeatureShuttleFBs_typ : 	STRUCT 
		MoveInPlane : MC_BR_MoveInPlane_Acp6D;
		MoveArc : MC_BR_MoveArc_Acp6D;
		MoveShortAxis : MC_BR_MoveShortAxis_Acp6D;
		RotaryMotion : MC_BR_RotaryMotion_Acp6D;
		TON_0 : TON;
		Recover : MC_BR_ShRecover_Acp6D;
		Payload : MC_BR_ShGetPayload_Acp6D;
		StereoTypeAssign : MC_BR_ShStereotypeAssign_Acp6D;
	END_STRUCT;
	FeatureParams_typ : 	STRUCT 
		UseTime : BOOL;
		Time : REAL;
		PayloadOffset : REAL;
	END_STRUCT;
	FeatureStatus_typ : 	STRUCT 
		Calibrated : BOOL;
		DetectedWeight : REAL;
	END_STRUCT;
	Weight_data_typ : 	STRUCT 
		ID : UINT;
		Offset : REAL;
		CurrentPayload : REAL;
		Payload : MC_BR_ShGetPayload_Acp6D;
	END_STRUCT;
END_TYPE
