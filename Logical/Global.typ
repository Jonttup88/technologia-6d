(*Main control datatype*)



(*Global shuttle array datatype*)

TYPE
	gShuttleListType : 	STRUCT  (*Global shuttle list datatype*)
		ID : UINT; (*ID of the shuttle*)
		Ref : Mc6DShuttleType; (*Reference to the shuttle*)
	END_STRUCT;
	gRobotTyp : 	STRUCT 
		AcoposResetDone : BOOL;
		AcoposStart : BOOL;
		AcoposEnd : BOOL;
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
		Ready : BOOL;
		StartPhaseOK : BOOL;
		GamePhaseOK : BOOL;
		EndPhaseOK : BOOL;
	END_STRUCT;
END_TYPE
