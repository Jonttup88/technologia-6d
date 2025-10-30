
{REDUND_ERROR} FUNCTION brfiShuffle : BOOL (* *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		refArray : REFERENCE TO ARRAY[0..gMAX_INDEX_SHUTTLE] OF DINT;
	END_VAR
	VAR
		newOrder : ARRAY[0..gMAX_INDEX_SHUTTLE] OF DINT;
		added : ARRAY[0..gMAX_INDEX_SHUTTLE] OF BOOL;
		rand : DINT;
		count : DINT;
		i : DINT;
		ordinal : DINT;
		x : DINT;
	END_VAR
END_FUNCTION

FUNCTION brfiShuttleSelect : DINT
	VAR_INPUT
		Shuttles : REFERENCE TO ARRAY[0..gMAX_INDEX_SHUTTLE] OF Acp6dShuttleType;
		Selection : REFERENCE TO ARRAY[0..gMAX_INDEX_SHUTTLE] OF brfiShuttleSelectionType;
		X0 : REAL;
		Y0 : REAL;
		X1 : REAL;
		Y1 : REAL;
	END_VAR
	VAR
		i : DINT;
		j : DINT;
		count : DINT;
		maxX : REAL;
		maxY : REAL;
		minX : REAL;
		minY : REAL;
		key : brfiShuttleSelectionType;
	END_VAR
END_FUNCTION

FUNCTION brfiShuttleSelectClosest : DINT
	VAR_INPUT
		Shuttles : REFERENCE TO ARRAY[0..gMAX_INDEX_SHUTTLE] OF Acp6dShuttleType;
		X : REAL;
		Y : REAL;
	END_VAR
	VAR
		i : DINT;
		dist : REAL;
		dist_min : REAL;
		index_min : DINT;
	END_VAR
END_FUNCTION

FUNCTION brfiSortCompare : BOOL
	VAR_INPUT
		A : brfiShuttleSelectionType;
		B : brfiShuttleSelectionType;
		AscendingX : BOOL;
		AscendingY : BOOL;
	END_VAR
	VAR
		isEqualX : BOOL;
	END_VAR
END_FUNCTION

FUNCTION brfiToRAD : REAL
	VAR_INPUT
		degrees : REAL;
	END_VAR
END_FUNCTION

FUNCTION brfiToDEG : REAL
	VAR_INPUT
		radians : REAL;
	END_VAR
END_FUNCTION
(**)

{REDUND_ERROR} FUNCTION_BLOCK brfi6DMoveQueue (* *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Shuttle : REFERENCE TO Mc6DShuttleType;
		Execute : {REDUND_UNREPLICABLE} BOOL;
		Parameters : {REDUND_UNREPLICABLE} brfi6DMoveQueueParamType;
		Commands : {REDUND_UNREPLICABLE} ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
	END_VAR
	VAR_OUTPUT
		Done : {REDUND_UNREPLICABLE} BOOL;
		Acknowledge : {REDUND_UNREPLICABLE} BOOL;
		Error : {REDUND_UNREPLICABLE} BOOL;
		ErrorID : {REDUND_UNREPLICABLE} DINT;
		FailedCommand : {REDUND_UNREPLICABLE} brfi6DMoveQueueCommandType;
		FailedCommandIndex : {REDUND_UNREPLICABLE} DINT;
		LastExecutedState : {REDUND_UNREPLICABLE} DINT;
	END_VAR
	VAR
		refCommand : REFERENCE TO brfi6DMoveQueueCommandType;
		refAllCommandsDone : REFERENCE TO BOOL;
		state : {REDUND_UNREPLICABLE} brfi6DMoveQueueStateEnum;
		subState : {REDUND_UNREPLICABLE} DINT;
		onStateEntry : BOOL;
		fb : {REDUND_UNREPLICABLE} brfi6DMoveQueueFbType;
		actions : {REDUND_UNREPLICABLE} brfi6DMoveQueueActionsType;
		cmd : {REDUND_UNREPLICABLE} brfi6DMoveQueueExecuteType;
		internal : {REDUND_UNREPLICABLE} brfi6DMoveQueueIrnalType;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION AddCommand6D_xy : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		axisSelect : brfi6DMoveCommandSelectionEnum;
		x : REAL;
		y : REAL;
		velocity : REAL;
		acceleration : REAL;
		endVelocity : REAL;
		path : brfi6DMoveCommandPathEnum;
		radius : REAL;
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_xyz : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		axisSelect : brfi6DMoveCommandSelectionEnum;
		x : REAL;
		y : REAL;
		z : REAL;
		velocity : REAL;
		velocity_short : REAL;
		acceleration : REAL;
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_Rxyz : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		axisSelect : brfi6DMoveCommandSelectionEnum;
		Rx : REAL;
		Ry : REAL;
		Rz : REAL;
		velocity_short : REAL;
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_wait : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		time : REAL; (*wait time in seconds*)
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_land : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		speed : USINT;
		Fz : REAL;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_levitate : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		speed : USINT;
		Fz : REAL;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_spin : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		duration : REAL; (*Duration of the rotational movement after reaching the target velocity (s)*)
		angle : REAL; (*Angle at which the shuttle stops after the rotational movement (rad)*)
		velocity : REAL; (*Rotational speed (rad/s)*)
		acceleration : REAL; (*Rotational acceleration (rad/s2)*)
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_rotateAbs : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		angle : REAL; (*Target angle (rad)*)
		velocity : REAL; (*Rotational speed (rad/s)*)
		acceleration : REAL; (*Rotational acceleration (rad/s2)*)
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_rotateCW : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		angle : REAL; (*Target angle (rad)*)
		velocity : REAL; (*Rotational speed (rad/s)*)
		acceleration : REAL; (*Rotational acceleration (rad/s2)*)
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_rotateCCW : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		angle : REAL; (*Target angle (rad)*)
		velocity : REAL; (*Rotational speed (rad/s)*)
		acceleration : REAL; (*Rotational acceleration (rad/s2)*)
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_arcAngularCW : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		x : REAL;
		y : REAL;
		angle : REAL;
		velocity : REAL;
		acceleration : REAL;
		endVelocity : REAL;
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_arcAngularCCW : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		x : REAL;
		y : REAL;
		angle : REAL;
		velocity : REAL;
		acceleration : REAL;
		endVelocity : REAL;
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_arcRadialCW : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		x : REAL;
		y : REAL;
		radius : REAL;
		type : McAcp6DArcTypeEnum; (*Rotational speed (rad/s)*)
		velocity : REAL; (*Rotational speed (rad/s)*)
		acceleration : REAL; (*Rotational acceleration (rad/s2)*)
		endVelocity : REAL; (*Target angle (rad)*)
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_arcRadialCCW : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		x : REAL;
		y : REAL;
		radius : REAL;
		type : McAcp6DArcTypeEnum; (*Rotational speed (rad/s)*)
		velocity : REAL; (*Rotational speed (rad/s)*)
		acceleration : REAL; (*Rotational acceleration (rad/s2)*)
		endVelocity : REAL; (*Target angle (rad)*)
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddCommand6D_waitCmdLb : BOOL
	VAR_INPUT
		Commands : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfi6DMoveQueueCommandType;
		monitoredShuttleID : UINT;
		triggerType : McAcp6DShWaitCmdLbTriggerEnum;
		commandLabel : UINT;
		labelType : McAcp6DShWaitCmdLbLabelEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION
(**)

{REDUND_ERROR} FUNCTION_BLOCK brfiShuttleGroup (* *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Assembly : REFERENCE TO Mc6DAssemblyType;
		Shuttles : {REDUND_UNREPLICABLE} ARRAY[0..gMAX_INDEX_SHUTTLE] OF Mc6DShuttleType;
		Enable : {REDUND_UNREPLICABLE} BOOL;
	END_VAR
	VAR_OUTPUT
		Inactive : {REDUND_UNREPLICABLE} BOOL;
		Active : {REDUND_UNREPLICABLE} BOOL;
		Busy : {REDUND_UNREPLICABLE} BOOL;
		Error : {REDUND_UNREPLICABLE} BOOL;
		ErrorID : {REDUND_UNREPLICABLE} DINT;
		NumberOfShuttles : {REDUND_UNREPLICABLE} UINT;
	END_VAR
	VAR
		shuttleGroupRef : Mc6DShuttleGroupType;
		state : {REDUND_UNREPLICABLE} DINT;
		i : {REDUND_UNREPLICABLE} DINT;
		fb : {REDUND_UNREPLICABLE} brfiShuttleGroupFbType;
	END_VAR
END_FUNCTION_BLOCK
(**)

{REDUND_ERROR} FUNCTION_BLOCK brfiSunPlanet (* *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		SunShuttle : REFERENCE TO Mc6DShuttleType;
		PlanetShuttles : {REDUND_UNREPLICABLE} ARRAY[0..gMAX_INDEX_SHUTTLE] OF Mc6DShuttleType;
		Enable : {REDUND_UNREPLICABLE} BOOL;
	END_VAR
	VAR_OUTPUT
		Active : {REDUND_UNREPLICABLE} BOOL;
		Busy : {REDUND_UNREPLICABLE} BOOL;
		Error : {REDUND_UNREPLICABLE} BOOL;
		ErrorID : {REDUND_UNREPLICABLE} DINT;
	END_VAR
	VAR
		state : {REDUND_UNREPLICABLE} DINT;
		i : {REDUND_UNREPLICABLE} DINT;
		ShPlanet : {REDUND_UNREPLICABLE} MC_BR_ShPlanet_Acp6D;
	END_VAR
END_FUNCTION_BLOCK
