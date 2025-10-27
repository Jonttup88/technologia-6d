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
END_TYPE
