
TYPE
	brfiShuttleSelectionType : 	STRUCT 
		index : DINT;
		x : REAL;
		y : REAL;
	END_STRUCT;
END_TYPE

(**)
(*----- brfi6DMoveQueue -----*)

TYPE
	brfi6DMoveQueueStateEnum : 
		(
		brfi6DMOVEQUEUE_DISABLED,
		brfi6DMOVEQUEUE_RUN,
		brfi6DMOVEQUEUE_DONE,
		brfi6DMOVEQUEUE_ERROR
		);
	brfi6DMoveQueueFbType : 	STRUCT 
		ShGetInfo : MC_BR_ShGetInfo_Acp6D;
		MoveInPlane : MC_BR_MoveInPlane_Acp6D;
		Move6D : MC_BR_Move6D_Acp6D;
		MoveArc : MC_BR_MoveArc_Acp6D;
		ShWaitTime : MC_BR_ShWaitTime_Acp6D;
		RotaryMotion : MC_BR_RotaryMotion_Acp6D;
		ShLevitation : MC_BR_ShLevitation_Acp6D;
		RotaryMotionSpin : MC_BR_RotaryMotionSpin_Acp6D;
	END_STRUCT;
	brfi6DMoveQueueIrnalType : 	STRUCT 
		initialized : BOOL;
		onStateEntry : BOOL;
		lastState : brfi6DMoveQueueStateEnum;
		lastSubState : DINT;
		i : DINT;
		position : McAcp6DShPositionType;
		Xc : REAL;
		Yc : REAL;
		dx : REAL;
		dy : REAL;
		radius : REAL;
		angle : REAL;
	END_STRUCT;
	brfi6DMoveQueueActionsType : 	STRUCT 
		acknowledge : BOOL;
		error : BOOL;
		done : BOOL;
		getInfo : BOOL;
	END_STRUCT;
	brfi6DMoveQueueExecuteType : 	STRUCT 
		moveInPlane : BOOL;
		move6D : BOOL;
		moveArc : BOOL;
		wait : BOOL;
		moveRotary : BOOL;
		levitate : BOOL;
		spin : BOOL;
		readInfo : BOOL;
	END_STRUCT;
	brfi6DMoveQueueCommandType : 	STRUCT 
		mask : UINT;
		inPlane : McAcp6DInPlaneParType;
		inSpace : McAcp6DMove6DParType;
		moveMode6D : McAcp6DMoveModeEnum;
		waitTime : REAL;
		rotary : McAcp6DRotaryMotionParType;
		arc : McAcp6DArcParType;
		levitation : McAcp6DLevitationParType;
		spin : McAcp6DRotaryMotionSpinParType;
	END_STRUCT;
	brfi6DMoveQueueParamType : 	STRUCT 
		velocity_xy : REAL;
		velocity_short : REAL;
		velocity_rotary : REAL;
		acceleration : REAL;
		acceleration_rotary : REAL;
	END_STRUCT;
	brfi6DMoveCommandSelectionEnum : 
		(
		sX := 1,
		sY := 2,
		sZ := 4,
		sRx := 8,
		sRy := 16,
		sRz := 32,
		sArc := 64,
		sRotary := 128,
		sWait := 256,
		sLevitate := 512,
		sSpin := 1024,
		sUpdatePosition := 2048
		);
	brfi6DMoveCommandPathEnum : 
		(
		pathDIRECT,
		pathX_Y,
		pathY_X
		);
END_TYPE

(**)

TYPE
	Acp6dShuttleType : 	STRUCT  (*Global shuttle list datatype*)
		ID : UINT; (*ID of the shuttle*)
		Ref : Mc6DShuttleType; (*Reference to the shuttle*)
		index : DINT; (*ID of the shuttle*)
		status : Acp6dShuttleStatusType; (*Reference to the shuttle*)
		position : Acp6dShuttlePositionType;
		force : Acp6dShuttleForceType;
		command : Acp6dShuttleCmdType;
		moveCyclicActive : BOOL;
	END_STRUCT;
	Acp6dShuttleCmdType : 	STRUCT  (*Global shuttle list datatype*)
		move6D : BOOL; (*ID of the shuttle*)
		moveQueue : BOOL; (*ID of the shuttle*)
	END_STRUCT;
	Acp6dShuttlePositionType : 	STRUCT  (*Global shuttle list datatype*)
		isValid : BOOL; (*ID of the shuttle*)
		value : McAcp6DShPositionType; (*ID of the shuttle*)
	END_STRUCT;
	Acp6dShuttleForceType : 	STRUCT  (*Global shuttle list datatype*)
		isValid : BOOL; (*ID of the shuttle*)
		value : McAcp6DShForceType; (*ID of the shuttle*)
		Z_avg : REAL;
		Fz_baseline : REAL;
		readings : ARRAY[0..gMAX_INDEX_MEASUREMENT]OF McAcp6DShForceType;
	END_STRUCT;
	Acp6dShuttleStatusType : 	STRUCT  (*Global shuttle list datatype*)
		isValid : BOOL; (*ID of the shuttle*)
		state : McAcp6DShStateEnum; (*ID of the shuttle*)
	END_STRUCT;
END_TYPE
