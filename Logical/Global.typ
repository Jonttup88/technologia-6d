(*Main control datatype*)
(*Global shuttle array datatype*)

TYPE
	gShuttleListType : 	STRUCT  (*Global shuttle list datatype*)
		ID : UINT; (*ID of the shuttle*)
		Ref : Mc6DShuttleType; (*Reference to the shuttle*)
	END_STRUCT;
	gRobotTyp : 	STRUCT 
		liftCup : BOOL;
		placeCup : BOOL;
		moveRobotHome : BOOL;
		AcoposWin : BOOL;
		CupCoordinate : gRobotParTyp;
		CupSelection : gRobotParTyp;
		Status : gRobotStatusTyp;
	END_STRUCT;
	gRobotParTyp : 	STRUCT 
		X : REAL;
		Y : REAL;
	END_STRUCT;
	gRobotStatusTyp : 	STRUCT 
		phaseOK : BOOL;
		phaseNum : REAL;
	END_STRUCT;
	gHMI_typ : 	STRUCT 
		Precision : HMI_Precision_typ;
		Weight : HMI_Weight_typ;
		Stereotype : HMI_Stereotype_typ;
		Teach : HMI_Teach_typ;
		Zone : HMI_Zone_typ;
		ZoneDataProvider : ARRAY[0..49]OF STRING[40];
		ZoneDataIndex : USINT;
		ActivateZone : BOOL;
		shuttles : ARRAY[0..7]OF HMI_Shuttle_pos_typ;
		General : HMI_general_typ;
		Status : HMI_status_typ;
		Data : Motion6D_data_typ;
		Game : HMI_game_typ;
		Force : HMI_force_typ;
	END_STRUCT;
	HMI_Shuttle_pos_typ : 	STRUCT 
		X : REAL;
		Y : REAL;
		RZ : REAL;
	END_STRUCT;
	HMI_Precision_typ : 	STRUCT 
		Position : McAcp6DShPositionType;
		TargetPosition : McAcp6DShPositionType;
		Acceleration : REAL;
		Velocity : REAL;
	END_STRUCT;
	HMI_Teach_typ : 	STRUCT 
		moveString : STRING[2000];
		update : BOOL;
	END_STRUCT;
	HMI_Weight_typ : 	STRUCT 
		Position : McAcp6DShPositionType;
		Payload : REAL;
		StoreOffset : BOOL;
		NoMoveAllowed : BOOL;
	END_STRUCT;
	HMI_Stereotype_typ : 	STRUCT 
		Size : McAcp6DPayloadSizeType;
	END_STRUCT;
	HMI_Zone_typ : 	STRUCT 
		Active : HMI_zone_detail_typ;
		Preview : HMI_zone_detail_typ;
	END_STRUCT;
	HMI_zone_detail_typ : 	STRUCT 
		BottomLeft : McAcp6DInPlaneAxesType;
		TopRight : McAcp6DInPlaneAxesType;
	END_STRUCT;
	gFeatureDemo_typ : 	STRUCT 
		Active : BOOL;
		newZoneData : HMI_zone_detail_typ;
		newStereotypeData : McAcp6DPayloadSizeType;
		featureState : USINT;
		featureDemoState : USINT;
		zoneIndex : USINT;
		FB : gFeatureFB_typ;
		Cmd : gFeatureDemoCmds_typ;
		Int : gFeatureInternal_typ;
		Addition : gFeatureDemoAddition_typ;
	END_STRUCT;
	gFeatureDemoCmds_typ : 	STRUCT 
		newZone : BOOL;
		newStereotype : BOOL;
		StopDemo : BOOL;
		StartDemo : BOOL;
	END_STRUCT;
	gFeatureFB_typ : 	STRUCT 
		ZoneCreate : MC_BR_ZoneCreate_Acp6D;
		GetZone : MC_BR_AsmGetZone_Acp6D;
		ZoneOverride : MC_BR_ZoneOverride_Acp6D;
		StereoTypeDefine : MC_BR_ShStereotypeDefine_Acp6D;
		StereoTypeDelete : MC_BR_ShStereotypeDelete_Acp6D;
		GroupDelete : MC_BR_ShGroupDelete_Acp6D;
		GroupCreate : MC_BR_ShGroupCreate_Acp6D;
		GroupCoupleCtrl : MC_BR_ShGroupCoupleCtrl_Acp6D;
		GroupAddShuttle : MC_BR_ShGroupAddShuttle_Acp6D;
		R_TRIG_0 : R_TRIG;
		MoveInPlaneAsync : MC_BR_MoveInPlaneAsync_Acp6D;
		ReadInfo : ARRAY[0..7]OF MC_BR_ShReadInfo_Acp6D;
		StopAll : MC_BR_AsmStop_Acp6D;
		PowerOff : MC_BR_AsmPowerOff_Acp6D;
		PowerOn : MC_BR_AsmPowerOn_Acp6D;
		TON_0 : TON;
	END_STRUCT;
	gFeatureInternal_typ : 	STRUCT 
		ready : BOOL;
		z : USINT;
		i : USINT;
		tempSTR : STRING[20];
		tempSTR1 : STRING[20];
		zoneReset : BOOL;
		FirstRun : BOOL;
	END_STRUCT;
	HMI_general_typ : 	STRUCT 
		PlayButton : BOOL;
		StopButton : BOOL;
		ResetButton : BOOL;
		BackToHome : BOOL;
		ResetPLC : BOOL;
	END_STRUCT;
	HMI_status_typ : 	STRUCT 
		Running : USINT;
		ReadyToRun : USINT;
		Stopped : USINT;
		Error : USINT;
		AllowPlay : BOOL;
		AllowStop : BOOL;
		AllowReset : BOOL;
	END_STRUCT;
	HMI_game_typ : 	STRUCT 
		Mode : USINT;
		Selection : USINT;
		CorrectShuttle : USINT;
		EndUserSelection : USINT;
		GameShuffleFinished : BOOL;
		GameFinished : BOOL;
		NewGame : BOOL;
		ExitGame : BOOL;
		GameRequested : BOOL;
		OpenGamePage : BOOL;
		GameState : USINT;
	END_STRUCT;
	gFeatureDemoAddition_typ : 	STRUCT 
		Levitate : BOOL;
		Rotate : BOOL;
		Force : BOOL;
	END_STRUCT;
	HMI_force_typ : 	STRUCT 
		mode : USINT;
		prevMode : USINT;
	END_STRUCT;
END_TYPE
