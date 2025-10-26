
TYPE
	brfiShuttleSelectionType : 	STRUCT 
		index : DINT;
		x : REAL;
		y : REAL;
	END_STRUCT;
END_TYPE

(*----- brfiMove6DQueue -----*)

TYPE
	brfiMove6DQueueStateEnum : 
		(
		brfiMOVE6DQUEUE_DISABLED,
		brfiMOVE6DQUEUE_RUN,
		brfiMOVE6DQUEUE_DONE,
		brfiMOVE6DQUEUE_ERROR
		);
	brfiMove6DQueueIrnalType : 	STRUCT 
		initialized : BOOL;
		actions : brfiMove6DQueueActionsType;
		lastState : brfiMove6DQueueStateEnum;
		lastSubState : DINT;
		i : DINT;
		position : McAcp6DShPositionType;
	END_STRUCT;
	brfiMove6DQueueActionsType : 	STRUCT 
		ready : BOOL;
		executeMove : BOOL;
		executeReadPosition : BOOL;
		error : BOOL;
	END_STRUCT;
	brfiMove6DQueueTargetType : 	STRUCT 
		axisMask : USINT;
		x : REAL;
		y : REAL;
		z : REAL;
		Rx : REAL;
		Ry : REAL;
		Rz : REAL;
		velocity_xy : REAL;
		velocity_short : REAL;
		acceleration : REAL;
		mode : brfiMove6DQueueModeEnum;
	END_STRUCT;
	brfiMove6DQueueParamType : 	STRUCT 
		velocity_xy : REAL;
		velocity_short : REAL;
		acceleration : REAL;
	END_STRUCT;
	brfiMove6DQueueModeEnum : 
		(
		brfiMOVE6D_ABSOLUTE,
		brfiMOVE6D_RELATIVE
		);
END_TYPE

(**)
(*----- brfiMoveXYQueue -----*)

TYPE
	brfiMoveXYQueueStateEnum : 
		(
		brfiMOVEXYQUEUE_DISABLED,
		brfiMOVEXYQUEUE_RUN,
		brfiMOVEXYQUEUE_DONE,
		brfiMOVEXYQUEUE_ERROR
		);
	brfiMoveXYQueueIrnalType : 	STRUCT 
		initialized : BOOL;
		actions : brfiMoveXYQueueActionsType;
		lastState : brfiMoveXYQueueStateEnum;
		lastSubState : DINT;
		i : DINT;
		position : McAcp6DInPlaneAxesType;
	END_STRUCT;
	brfiMoveXYQueueActionsType : 	STRUCT 
		ready : BOOL;
		executeMove : BOOL;
		executeReadPosition : BOOL;
		error : BOOL;
	END_STRUCT;
	brfiMoveXYQueueTargetType : 	STRUCT 
		axisMask : USINT;
		x : REAL;
		y : REAL;
		velocity : REAL;
		acceleration : REAL;
		mode : McAcp6DMoveModeEnum;
		path : McAcp6DInPlanePathEnum;
		radius : REAL;
	END_STRUCT;
	brfiMoveXYQueueParamType : 	STRUCT 
		velocity : REAL;
		acceleration : REAL;
	END_STRUCT;
	brfiMoveAxisSelectionEnum : 
		(
		aX := 1,
		aY := 2,
		aZ := 4,
		aRx := 8,
		aRy := 16,
		aRz := 32
		);
END_TYPE

(**)

TYPE
	Acp6dShuttleType : 	STRUCT  (*Global shuttle list datatype*)
		ID : UINT; (*ID of the shuttle*)
		Ref : Mc6DShuttleType; (*Reference to the shuttle*)
		index : DINT; (*ID of the shuttle*)
		position : Acp6dShuttlePositionType;
		force : Acp6dShuttleForceType;
		command : Acp6dShuttleCmdType;
		moveCyclicActive : BOOL;
	END_STRUCT;
	Acp6dShuttleCmdType : 	STRUCT  (*Global shuttle list datatype*)
		move6D : BOOL; (*ID of the shuttle*)
		move6DQueue : BOOL; (*ID of the shuttle*)
		moveXYQueue : BOOL; (*ID of the shuttle*)
		updateInfo : BOOL; (*ID of the shuttle*)
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
END_TYPE
