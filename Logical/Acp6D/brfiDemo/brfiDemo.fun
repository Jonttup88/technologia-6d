
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
(**)

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK brfiMove6DQueue (* *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Shuttle : REFERENCE TO Mc6DShuttleType;
		Execute : {REDUND_UNREPLICABLE} BOOL;
		Parameters : {REDUND_UNREPLICABLE} brfiMove6DQueueParamType;
		Targets : {REDUND_UNREPLICABLE} ARRAY[0..gMAX_INDEX_TARGETS] OF brfiMove6DQueueTargetType;
	END_VAR
	VAR_OUTPUT
		Done : {REDUND_UNREPLICABLE} BOOL;
		Ready : {REDUND_UNREPLICABLE} BOOL;
		Error : {REDUND_UNREPLICABLE} BOOL;
		LastStatusCode : {REDUND_UNREPLICABLE} DINT;
		LastExecutedState : {REDUND_UNREPLICABLE} brfiMove6DQueueStateEnum;
	END_VAR
	VAR
		refTarget : REFERENCE TO brfiMove6DQueueTargetType;
		state : {REDUND_UNREPLICABLE} brfiMove6DQueueStateEnum;
		subState : {REDUND_UNREPLICABLE} DINT;
		Move6D : {REDUND_UNREPLICABLE} MC_BR_Move6D_Acp6D;
		ShGetInfo : {REDUND_UNREPLICABLE} MC_BR_ShGetInfo_Acp6D;
		internal : {REDUND_UNREPLICABLE} brfiMove6DQueueIrnalType;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION AddTarget6D_xyz : BOOL
	VAR_INPUT
		TargetList : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfiMove6DQueueTargetType;
		axisSelect : brfiMoveAxisSelectionEnum;
		x : REAL;
		y : REAL;
		z : REAL;
		velocity_xy : REAL;
		velocity_short : REAL;
		acceleration : REAL;
		mode : brfiMove6DQueueModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddTarget6D_Rxyz : BOOL
	VAR_INPUT
		TargetList : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfiMove6DQueueTargetType;
		axisSelect : brfiMoveAxisSelectionEnum;
		Rx : REAL;
		Ry : REAL;
		Rz : REAL;
		velocity_short : REAL;
		mode : brfiMove6DQueueModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddTarget6D_all : BOOL
	VAR_INPUT
		TargetList : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfiMove6DQueueTargetType;
		axisSelect : brfiMoveAxisSelectionEnum;
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
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION
(**)

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK brfiMoveXYQueue (* *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Shuttle : REFERENCE TO Mc6DShuttleType;
		Execute : {REDUND_UNREPLICABLE} BOOL;
		Parameters : {REDUND_UNREPLICABLE} brfiMoveXYQueueParamType;
		Targets : {REDUND_UNREPLICABLE} ARRAY[0..gMAX_INDEX_TARGETS] OF brfiMoveXYQueueTargetType;
	END_VAR
	VAR_OUTPUT
		Done : {REDUND_UNREPLICABLE} BOOL;
		Ready : {REDUND_UNREPLICABLE} BOOL;
		Error : {REDUND_UNREPLICABLE} BOOL;
		LastStatusCode : {REDUND_UNREPLICABLE} DINT;
		LastExecutedState : {REDUND_UNREPLICABLE} brfiMoveXYQueueStateEnum;
	END_VAR
	VAR
		refTarget : REFERENCE TO brfiMoveXYQueueTargetType;
		state : {REDUND_UNREPLICABLE} brfiMoveXYQueueStateEnum;
		subState : {REDUND_UNREPLICABLE} DINT;
		MoveXY : {REDUND_UNREPLICABLE} MC_BR_MoveInPlane_Acp6D;
		ShGetInfo : {REDUND_UNREPLICABLE} MC_BR_ShGetInfo_Acp6D;
		internal : {REDUND_UNREPLICABLE} brfiMoveXYQueueIrnalType;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION AddTargetDIR : BOOL
	VAR_INPUT
		TargetList : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfiMoveXYQueueTargetType;
		axisSelect : brfiMoveAxisSelectionEnum;
		x : REAL;
		y : REAL;
		velocity : REAL;
		acceleration : REAL;
		radius : REAL;
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddTargetXY : BOOL
	VAR_INPUT
		TargetList : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfiMoveXYQueueTargetType;
		axisSelect : brfiMoveAxisSelectionEnum;
		x : REAL;
		y : REAL;
		velocity : REAL;
		acceleration : REAL;
		radius : REAL;
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION

FUNCTION AddTargetYX : BOOL
	VAR_INPUT
		TargetList : REFERENCE TO ARRAY[0..gMAX_INDEX_TARGETS] OF brfiMoveXYQueueTargetType;
		axisSelect : brfiMoveAxisSelectionEnum;
		x : REAL;
		y : REAL;
		velocity : REAL;
		acceleration : REAL;
		radius : REAL;
		mode : McAcp6DMoveModeEnum;
	END_VAR
	VAR
		i : DINT;
	END_VAR
END_FUNCTION
