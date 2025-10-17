(*Main control datatype*)

TYPE
	gMainType : 	STRUCT  (*Main control variable datatype*)
		Cmd : gMainCmdType; (*Main commands*)
		Par : gMainParType; (*Main parameter*)
		Status : gMainStatusType; (*Main status*)
	END_STRUCT;
	gMainCmdType : 	STRUCT  (*Main commands type*)
		Power : BOOL; (*Power on the system*)
		Recover : BOOL; (* Recover the system*)
		ErrorReset : BOOL; (*Reset any active error*)
	END_STRUCT;
	gMainParType : 	STRUCT  (*Main parameter type*)
		Velocity : REAL;
		Acceleration : REAL;
	END_STRUCT;
	gMainStatusType : 	STRUCT  (*Main status type*)
		AssemblyState : McAcp6dPLCopenStateEnum; (*Assembly state*)
		ShuttlesPresent : UINT; (*Number of shuttles present on the assembly*)
	END_STRUCT;
END_TYPE

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
