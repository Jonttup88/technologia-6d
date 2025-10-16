
TYPE
	BrAbbRwsStatusIDEnum : 
		( (*Type including the Status ID of the function blocks*)
		RWS_ERROR_NONE, (*Everything works fine*)
		RWS_CORE_INVALID_HOSTPORT, (*Invalid host port*)
		RWS_CORE_INVALID_SERVERIP, (*Invalid server IP*)
		RWS_CORE_INVALID_USERNAME, (*Invalid user name*)
		RWS_CORE_INVALID_PASSWORD, (*Invalid password*)
		RWS_CORE_INVALID_WS_VERSION, (*Invalid robot ware version*)
		RWS_CORE_SSL_EMPTY, (*SSL is empty*)
		RWS_CORE_INVALID_SSL, (*Invalid SSL*)
		RWS_BAD_HTTP_REQEST, (*Bad http request*)
		RWS_FORBIDDEN_HTTP_REQEST, (*Forbidden http request*)
		RWS_AUTHENTICATION_FAILURE, (*Authentication failure*)
		RWS_GENERIC_HTTP_REQEST_ERROR, (*Request error*)
		RWS_HTTP_REQEST_TIMEOUT, (*Request timeout*)
		RWS_ERROR_ON_CORE_FB, (*Core function block is in error state*)
		RWS_INVALID_IDENT, (*Invalid ident number*)
		RWS_MULTIPLE_COMMANDS, (*Multiple commands are given at one time*)
		RWS_INVALID_MECHUNIT, (*Invalid "mechunit"*)
		RWS_INVALID_SIGNAL, (*Invalid signal name*)
		RWS_INVALID_DATA_ADR, (*Invalid data address*)
		RWS_INVALID_SIGNAL_MODE, (*Invalid signal mode*)
		RWS_LOG_CREATE_ERROR, (*Error during creating log*)
		RWS_LOG_GET_IDENT_ERROR, (*Error duringgetting ident*)
		RWS_LOG_GET_LAST_RECORD_ERROR, (*Error during getting last record*)
		RWS_LOG_READ_ERROR, (*Error during reading log*)
		RWS_LOG_WRITE_ERROR, (*Error during writing log*)
		RWS_INVALID_VARIABLE, (*Invalid variable name*)
		RWS_INVALID_TASK, (*Invalid task name*)
		RWS_INVALID_MODULE, (*Invalid module name*)
		RWS_STRING_TOO_SHORT, (*String is to short*)
		RWS_INVALID_PARAMETER, (*Invalid parameter*)
		RWS_INVALID_CMD_IN_CURRENT_STATE, (*Invalid command in current state*)
		RWS_TCP_CONNECTION_CLOSED (*Tcp connection is closed*)
		);
	BrAbbRwsCommonResponseType : 	STRUCT  (*Response type*)
		ResponseHeader : httpResponseHeader_t; (*Response header*)
		ResponseData : STRING[BR_ABB_RWS_MAX_RESPONSE_LEN]; (*Response data*)
		ResponseRawHeaderData : STRING[BR_ABB_RWS_MAX_HEADER_LEN]; (*Response raw data*)
		Error : BOOL; (*Response error*)
		ErrorInfo : BrAbbRwsErrorInfoType; (*Response error info*)
		Done : BOOL; (*Indicate if response process is done*)
		StatusID : BrAbbRwsStatusIDEnum; (*Status ID of response process*)
	END_STRUCT;
	BrAbbRwsCommonReqestBufferType : 	STRUCT  (*Type of request buffer*)
		AddrServiceResponse : UDINT; (*Address of the variable to which the response for services is assigned*)
		Uri : STRING[200]; (*Inquiry - URI*)
		Method : UINT; (*Inquiry - METHOD*)
		ReqData : STRING[500]; (*Inquiry - REQUEST PARAMETERS*)
	END_STRUCT;
	BrAbbRwsCommonCoreSrvLinkType : 	STRUCT  (*Type containing variables that are used for communication between Core function block and the  others function block.*)
		ReqBuffer : ARRAY[0..BR_ABB_RWS_MAX_BUFFER_LENGTH]OF BrAbbRwsCommonReqestBufferType; (*Request buffer*)
		WebServerVersion : BrAbbRwsCommonRWVersionEnum; (*Robot ware version*)
	END_STRUCT;
	BrAbbRwsErrorInfoType : 	STRUCT  (*Error info type*)
		Status : UINT; (*Function block status*)
		HttpStatus : UINT; (*Http status*)
		TcpStatus : UINT; (*Tcp status*)
	END_STRUCT;
	BrAbbRwsCommonRWVersionEnum : 
		( (*Robot ware version (controller type)*)
		BR_ABB_RWS_VERSION_V1, (*IRC5*)
		BR_ABB_RWS_VERSION_V2 (*OMNICORE*)
		);
END_TYPE

(*
**** CORE types *****)

TYPE
	BrAbbRwsCoreInternalType : 	STRUCT  (*Internal structure*)
		Step : BrAbbRwsCoreInternalStepEnum; (*Actual step*)
		OldStep : BrAbbRwsCoreInternalStepEnum; (*Actual step old*)
		OldEnable : BOOL; (*Enable old*)
		OldErrorReset : BOOL; (*Error reset old*)
		Parameters : BrAbbRwsCoreParametersType; (*Internal parameters*)
		FBSslOpen : ArSslOpen; (*Instance of ArSslOpen function block*)
		FBHttpsClient : httpsClient; (*Instance of Https client function block*)
		FBHttpClient : httpClient; (*Instance of Http client function block*)
		Response : BrAbbRwsCommonResponseType; (*Response *)
		ReqHeader : httpRequestHeader_t; (*Request header*)
		ReqRawHeaderData : STRING[BR_ABB_RWS_MAX_HEADER_LEN]; (*Request raw header*)
		CoreSrvLink : BrAbbRwsCommonCoreSrvLinkType; (*Core and other function blocks connection structure*)
		BufferIdx : USINT; (*Actual buffer index*)
		Nonce : BrAbbRwsCoreInternalNonceType; (*Type containing parameters for server response processing*)
		Authorization : BrAbbRwsCoreInternalAutType; (*Authorization structure*)
		PendingRequests : USINT; (*Number of pending requests*)
		FBTimerSending : TON; (*Time of sending*)
		Cookie : BrAbbRwsCoreInternalCookieType; (*Cookie structure*)
		OldCookie : BrAbbRwsCoreInternalCookieType; (*Old cookie structure*)
		fbExtrDelStr : ExtrDelStr; (*Instance of the function block to analyze responses from the server*)
		FBStatus : UINT; (*Internal status of the function block*)
		Phase : UINT;
		tcpStatus : UINT; (*Internal status of the tcp communication *)
		httpStatus : UINT; (*Internal http status*)
		FBEncode : httpEncodeBase64; (*Instance of the httpEncodeBase64 function block*)
		EncodedPW : STRING[255]; (*Encoded PW*)
		NewAuthAttemptRequired : BOOL; (*New authorization attemt is required*)
		AuthorizationAttempts : USINT; (*Number of authorization attempts*)
	END_STRUCT;
	BrAbbRwsCoreParametersType : 	STRUCT  (*Core parameter structure*)
		HostPort : UINT; (*Port number that should be used for the connection 
*)
		ServerIP : STRING[15]; (*Robot controller IP address (e.g. “10.39.10.227”) 
*)
		UserName : STRING[50]; (*User name for accessing services. (defined in robot controller – default: “Default User”) 
*)
		Password : STRING[50]; (*Password for accessing services. (defined in robot controller – default: “robotics”) 
*)
		Timeout : UDINT; (*Connection timeout in milliseconds 
*)
		WebServerVersion : BrAbbRwsCommonRWVersionEnum; (*Version of RobotWare (IRC5/Omnicore)*)
		SecureConfigName : STRING[255];
	END_STRUCT;
	BrAbbRwsCoreInternalNonceType : 	STRUCT  (*Internal type used for server response processing*)
		StartIdx : UDINT; (*Start index of the string being searched for*)
		EndIdx : UDINT; (*End index of the string being searched for*)
		Nonce : STRING[100]; (*The string to be found inside server respone*)
	END_STRUCT;
	BrAbbRwsCoreInternalAutType : 	STRUCT 
		A1 : STRING[255];
		A1Usint : ARRAY[0..254]OF USINT;
		HA1Usint : ARRAY[0..15]OF USINT;
		HA1 : STRING[32];
		A2 : STRING[255];
		A2Usint : ARRAY[0..254]OF USINT;
		HA2Usint : ARRAY[0..15]OF USINT;
		HA2 : STRING[32];
		NcUdint : UDINT := 0;
		NcArrUsint : ARRAY[0..15]OF USINT := [4(0)];
		NcArrUsintInv : ARRAY[0..15]OF USINT := [4(0)];
		NcTemp : STRING[80];
		Nc : STRING[10];
		cnonce : STRING[32];
		RES : STRING[255];
		RESUsint : ARRAY[0..254]OF USINT;
		HRESUsint : ARRAY[0..15]OF USINT;
		Response : STRING[32];
	END_STRUCT;
	BrAbbRwsCoreInternalCookieType : 	STRUCT  (*Internal cookie type*)
		StartSessionIdx : UDINT; (*Index of the started session*)
		EndSessionIdx : UDINT; (*Closed session index*)
		StartABBCXIdx : UDINT; (*Start ABBC index*)
		EndABBCXIdx : UDINT; (*End ABBC index*)
		Session : STRING[150]; (*Session name*)
		ABBCX : STRING[150]; (*ABBC name*)
	END_STRUCT;
	BrAbbRwsCoreInternalStepEnum : 
		( (*Internal step of the core function block*)
		STEP_CORE_WAIT_ENABLE, (*Waiting for the enable function block*)
		STEP_CORE_GET_SSL_IDENT, (*Get SSL ident*)
		STEP_CORE_SCAN_REQUEST_BUFFER, (*Scanning the buffer containing requests to the server*)
		STEP_CORE_PROCESS_REQUEST, (*Sending a request*)
		STEP_CORE_PROCESS_RESPONSE, (*Analysis of responses*)
		STEP_CORE_UPDATE_REQUEST_BUFFER, (*Request buffor update*)
		STEP_CORE_ERROR (*Error state*)
		);
END_TYPE

(*
**** SERVICE types *****)
(***** Rapid Commands*)

TYPE
	BrAbbRwsRapidCmdInternalType : 	STRUCT  (*Internal structure*)
		Step : BrAbbRwsRapidCmdStepEnum; (*Actual step*)
		OldEnable : BOOL; (*Enable old*)
		OldErrorReset : BOOL; (*Error reset old*)
		OldPowerOn : BOOL; (*Power On old*)
		OldPowerOff : BOOL; (*Power Off old*)
		OldStart : BOOL; (*Start old*)
		OldStop : BOOL; (*Stop old*)
		OldContinue : BOOL; (*Continue old*)
		OldResetPointer : BOOL; (*Reset pointer old*)
		OldChangeSpeedRatio : BOOL; (*Change speed ratio old*)
		OldWarmstart : BOOL; (*Warm restart old*)
		Parameters : BrAbbRwsRapidCmdParameterType; (*Internal parameter structure*)
		BufferIdx : USINT; (*Actual buffer index*)
		Response : BrAbbRwsCommonResponseType; (*Internal response type*)
		SpeedRatioStr : STRING[80]; (*Set speed ratio (string value)*)
	END_STRUCT;
	BrAbbRwsRapidCmdStopModeType : 	STRUCT  (*Type containing various stop modes.*)
		StopMode : BrAbbRwsRapidCmdStopModeEnum := BR_ABB_RWS_CMD_STOPMODE_STOP; (*Stop mode*)
		USetSp : BrAbbRwsRapidCmdStopUsetEnum;
	END_STRUCT;
	BrAbbRwsRapidCmdParameterType : 	STRUCT  (*RapidCmd parameter type*)
		Continue : BrAbbRwsRapidCmdContinueModeType; (*Define options for Continue command 
*)
		Stop : BrAbbRwsRapidCmdStopModeType; (*Define options for Stop command 
*)
		RestartMode : BrAbbRwsRapidCmdRestartModeEnum; (*Define options for Restart command 
*)
		SpeedRatio : USINT := 100; (*Set speed ratio (override)*)
	END_STRUCT;
	BrAbbRwsRapidCmdContinueModeType : 	STRUCT  (*Type containing various continue modes.*)
		Regain : BrAbbRwsRapidCmdRegainEnum := BR_ABB_RWS_CMD_REGAIN_CONTINUE; (*Continue mode -regain*)
		Execmode : BrAbbRwsRapidCmdExecuteModeEnum := RWS_CMD_EXEMODE_CONTINUE; (*Continue mode -execmode*)
		Cycle : BrAbbRwsRapidCmdCycleEnum := BR_ABB_RWS_CMD_CYCLE_FOREVER; (*Continue mode -cycle*)
		Condition : BrAbbRwsRapidCmdConditionEnum := BR_ABB_RWS_CMD_CONDITION_NONE; (*Continue mode -condition*)
		StopAtBp : BrAbbRwsRapidCmdStopBPEnum := BR_ABB_RWS_CMD_STOP_BP_DISABLED;
		AllTaskByTsp : BrAbbRwsRapidCmdTskByTSPEnum := BR_ABB_RWS_CMD_ALL_TASK_FALSE;
	END_STRUCT;
	BrAbbRwsRapidCmdStopModeEnum : 
		( (*Type containing various stop modes.*)
		BR_ABB_RWS_CMD_STOPMODE_STOP, (*Normal stop procedure. Immediately after the command is given.*)
		BR_ABB_RWS_CMD_STOPMODE_QSTOP, (*Stops the robot on the path as fast as possible.
*)
		BR_ABB_RWS_CMD_STOPMODE_CYCLE, (*Stop after cycle*)
		BR_ABB_RWS_CMD_STOPMODE_INSTR (*Stop after instruction is done*)
		);
	BrAbbRwsRapidCmdStopUsetEnum : 
		(
		BR_ABB_RWS_CMD_STOP_USET_NORMAL,
		BR_ABB_RWS_CMD_STOP_USET_ALL_TSK (*Stop the movement of all mechanical units in the system.
*)
		);
	BrAbbRwsRapidCmdRegainEnum : 
		(
		BR_ABB_RWS_CMD_REGAIN_CONTINUE,
		BR_ABB_RWS_CMD_REGAIN_REGAIN,
		BR_ABB_RWS_CMD_REGAIN_CLEAR,
		BR_ABB_RWS_CMD_REGAIN_ENTCONSUME (*RWS V2 only!*)
		);
	BrAbbRwsRapidCmdExecuteModeEnum : 
		(
		RWS_CMD_EXEMODE_CONTINUE,
		RWS_CMD_EXEMODE_STEP_IN,
		RWS_CMD_EXEMODE_STEP_OVER,
		RWS_CMD_EXEMODE_STEP_OUT,
		RWS_CMD_EXEMODE_STEP_BACK,
		RWS_CMD_EXEMODE_STEP_LAST,
		RWS_CMD_EXEMODE_STEP_MOTION
		);
	BrAbbRwsRapidCmdCycleEnum : 
		( (*Cycle mode enum type*)
		BR_ABB_RWS_CMD_CYCLE_FOREVER,
		BR_ABB_RWS_CMD_CYCLE_AS_IS,
		BR_ABB_RWS_CMD_CYCLE_ONCE
		);
	BrAbbRwsRapidCmdConditionEnum : 
		(
		BR_ABB_RWS_CMD_CONDITION_NONE,
		BR_ABB_RWS_CMD_CONDITION_CHAIN
		);
	BrAbbRwsRapidCmdStopBPEnum : 
		(
		BR_ABB_RWS_CMD_STOP_BP_DISABLED,
		BR_ABB_RWS_CMD_STOP_BP_ENABLED
		);
	BrAbbRwsRapidCmdTskByTSPEnum : 
		(
		BR_ABB_RWS_CMD_ALL_TASK_FALSE,
		BR_ABB_RWS_CMD_ALL_TASK_TRUE
		);
	BrAbbRwsRapidCmdRestartModeEnum : 
		(
		BR_ABB_RWS_CMD_MODE_RESTART,
		BR_ABB_RWS_CMD_MODE_ISTART,
		BR_ABB_RWS_CMD_MODE_PSTART,
		BR_ABB_RWS_CMD_MODE_BSTART
		);
	BrAbbRwsRapidCmdStepEnum : 
		( (*Type containing function block steps*)
		BR_ABB_RWS_CMD_WAIT_ENABLE, (*Waiting for enable command*)
		BR_ABB_RWS_CMD_WAIT_REQUEST, (*Waiting for command*)
		BR_ABB_RWS_CMD_WRITE_REQUEST, (*Writing request to the core function block*)
		BR_ABB_RWS_CMD_PROCESS_RESPONSE, (*Processing the response from the serwer*)
		BR_ABB_RWS_CMD_COMMAND_RESET, (*Waiting until given command is reseted*)
		BR_ABB_RWS_CMD_ERROR (*Error state*)
		);
END_TYPE

(***** State*)

TYPE
	BrAbbRwsStateInternalType : 	STRUCT  (*Internal type*)
		Step : BrAbbRwsStateInternalStepEnum; (*Actual step*)
		Parameters : BrAbbRwsStateParametersType; (*Internal parameter structure*)
		OldEnable : BOOL; (*Enable old*)
		OldErrorReset : BOOL; (*Error reset old*)
		OldGetState : BOOL; (*Get state old*)
		BufferIdx : USINT; (*Actual buffer index*)
		Response : ARRAY[0..BR_ABB_RWS_MAX_STATE_RESPONSE]OF BrAbbRwsCommonResponseType; (*Internal response type*)
		State : ARRAY[0..BR_ABB_RWS_MAX_STATE_RESPONSE]OF BrAbbRwsStateStringStateType;
		RequestNumber : USINT; (*Number of state requests*)
		ReqIdx : USINT; (*Request index*)
		MotorStateIdx : USINT; (*Motor state index*)
		RapidStateIdx : USINT; (*Rapid state index*)
		ActiveModeIdx : USINT; (*Acrive mode index*)
		ActPosCartIdx : USINT; (*Actual position index(translation)*)
		ActPosJointsIdx : USINT; (*Actual position index(joint)*)
		ActSpeedRatioIdx : USINT; (*Actual speed ratio inxex*)
		fbExtrDelStr : ExtrDelStr; (*Instance of  ExtrDelStr function block*)
		AuxResponseError : BOOL; (*Internal response error*)
		AuxErrorInfo : BrAbbRwsErrorInfoType; (*Internal error info*)
		AuxStatusID : BrAbbRwsStatusIDEnum; (*Internal status ID*)
		OptIn : BOOL;
	END_STRUCT;
	BrAbbRwsStateParEnableType : 	STRUCT  (*Enable reading particular status*)
		MotorState : BOOL := TRUE; (*Enable reading the motor status*)
		RapidState : BOOL := TRUE; (*Enable reading the RAPID status*)
		ActiveMode : BOOL := TRUE; (*Enable reading the active controller mode*)
		ActPosCart : BOOL := TRUE; (*Enable reading the robot position*)
		ActSpeedRatio : BOOL := TRUE; (*Enable reading the actual speed ratio*)
	END_STRUCT;
	BrAbbRwsStateParOptType : 	STRUCT  (*Status readout options*)
		Tool : STRING[80]; (*Name of selected tool*)
		WObj : STRING[80]; (*Name of selected coordintation system (Work Object)*)
		CoordSys : BrAbbRwsCoordSystemEnum; (*Coordination system*)
	END_STRUCT;
	BrAbbRwsStateParametersType : 	STRUCT  (*State parameter type*)
		Enable : BrAbbRwsStateParEnableType; (*Enable reading a particular type of status*)
		MechUnit : STRING[50]; (*State of which robot unit has to be read*)
		Options : BrAbbRwsStateParOptType; (*Status readout options*)
	END_STRUCT;
	BrAbbRwsStatePosCartType : 	STRUCT  (*Robot position type*)
		X : REAL; (*Translation in  X direction*)
		Y : REAL; (*Translation in  Y direction*)
		Z : REAL; (*Translation in  Z direction*)
		A : REAL; (*Rotation X*)
		B : REAL; (*Rotation Y*)
		C : REAL; (*Rotation Z*)
		Q1 : REAL; (*Quaternion1*)
		Q2 : REAL; (*Quaternion2*)
		Q3 : REAL; (*Quaternion3*)
		Q4 : REAL; (*Quaternion4*)
	END_STRUCT;
	BrAbbRwsStateStringStateType : 	STRUCT  (*Internal type used for server response processing*)
		StartIdx : UDINT; (*Start index of the string being searched for*)
		EndIdx : UDINT; (*End index of the string being searched for*)
		State : STRING[50]; (*The string to be found inside server respone*)
	END_STRUCT;
	BrAbbRwsCoordSystemEnum : 
		( (*Coordination system enum type*)
		BR_ABB_RWS_STATE_CS_DEFAULT,
		BR_ABB_RWS_STATE_CS_BASE, (*Base coordination system*)
		BR_ABB_RWS_STATE_CS_WORLD, (*World coordination system*)
		BR_ABB_RWS_STATE_CS_TOOL, (*Tool coordination system*)
		BR_ABB_RWS_STATE_CS_WOBJ (*Particular work object*)
		);
	BrAbbRwsStateInternalStepEnum : 
		( (*Type containing function block steps*)
		STEP_STATE_WAIT_ENABLE, (*Waiting for enable command*)
		STEP_STATE_WAIT_REQUEST, (*Waiting for command*)
		STEP_STATE_WRITE_REQUEST, (*Writing request to the core function block*)
		STEP_STATE_PROCESS_RESPONSE, (*Processing the response from the serwer*)
		STEP_STATE_WAIT_COMMANDS_RESET, (*Waiting until given command is reseted*)
		STEP_STATE_ERROR (*Error state*)
		);
	BrAbbRwsStateRapidStateEnum : 
		( (*RAPID state enum type*)
		RWS_STATE_RAPID_UNDEFINED, (*RAPID state is unknown*)
		RWS_STATE_RAPID_RUNNING, (*RAPID is running*)
		RWS_STATE_RAPID_STOPPED (*RAPID is stopped*)
		);
	BrAbbRwsStateMotorStateEnum : 
		( (*Motors state enum type*)
		RWS_STATE_MOTORS_UNDEFINED, (*Motors state is unknown*)
		RWS_STATE_MOTORS_INIT, (*Motors init state*)
		RWS_STATE_MOTORS_OFF, (*Motors off state*)
		RWS_STATE_MOTORS_ON, (*Motors on state*)
		RWS_STATE_MOTORS_GUARDSTOP, (*Motor guard stop state*)
		RWS_STATE_MOTORS_ESTOP, (*Motor e stop state*)
		RWS_STATE_MOTORS_ESTOP_RESET, (*Motor wait for e stop reset state*)
		RWS_STATE_MOTORS_SYSFAIL (*Motot system fail state*)
		);
	BrAbbRwsStateActiveModeEnum : 
		( (*Active mode state enum type*)
		RWS_STATE_MODE_UNDEFINED, (*Active mode is unknown*)
		RWS_STATE_MODE_MANUAL_SLOW, (*Active mode manual slow*)
		RWS_STATE_MODE_MANUAL_FAST, (*Active mode manual fast*)
		RWS_STATE_MODE_MANUAL_FAST_REQ, (*Active mode manual fast*)
		RWS_STATE_MODE_AUTOMAT, (*Active mode auto*)
		RWS_STATE_MODE_AUTOMAT_REQ, (*Active mode auto*)
		RWS_STATE_MODE_INIT (*Active mode init*)
		);
END_TYPE

(***** Signals*)

TYPE
	BrAbbRwsSignalInternalType : 	STRUCT  (*Internal type*)
		Step : BrAbbRwsSignalInternalStepEnum; (*Actual step*)
		Parameters : BrAbbRwsSignalParType; (*Internal parameter structure*)
		SetPar : BrAbbRwsSignalParSetType; (*Internal set parameter structure*)
		GetPar : BrAbbRwsSignalParGetType; (*Internal get parameter structure*)
		OldEnable : BOOL; (*Enable old*)
		OldErrorReset : BOOL; (*Error reset old*)
		OldSetValue : BOOL; (*Set signal value old*)
		OldGetValue : BOOL; (*Get signal value old*)
		AuxSetValue : BOOL; (*Internal set signal value command*)
		AuxSetDigitalValue : BOOL; (*Internal set digital value command*)
		AuxSetGroupValue : UDINT; (*Internal set group value command*)
		AuxSetAnalogValue : REAL; (*Internal set analog value command*)
		AuxPulsesString : STRING[15]; (*Internal pulses value (converted to string)*)
		AuxPulseOnString : STRING[15]; (*Internal pulse on value (converted to string)*)
		AuxPulseOffString : STRING[15]; (*Internal pulse off value (converted to string)*)
		AuxGetValue : BOOL; (*Internal get signal value command*)
		GetValue : BrAbbRwsSignalInternalGetValType; (*Internal get value parameter structure*)
		BufferIdx : USINT; (*Actual buffer index*)
		Response : BrAbbRwsCommonResponseType; (*Internal response type*)
		fbExtrDelStr : ExtrDelStr; (*Instance of  ExtrDelStr function block*)
		AuxStringLeft : STRING[200]; (*An auxiliary variable to analyze responses from the server. It is a string located to the left of the desired value.*)
		SetValueString : STRING[15]; (*Set value converted to string*)
		SignalIndex : UDINT; (*Index of the signal*)
	END_STRUCT;
	BrAbbRwsSignalInternalGetValType : 	STRUCT  (*Internal type used for server response processing*)
		StartIdx : UDINT; (*Start index of the string being searched for*)
		EndIdx : UDINT; (*End index of the string being searched for*)
		Value : STRING[15]; (*The string to be found inside server respone*)
	END_STRUCT;
	BrAbbRwsSignalParType : 	STRUCT  (*Signal parameter structure*)
		SetPar : UDINT; (*Parameters of set signal procedure*)
		GetPar : UDINT; (*Parameters of get signal procedure*)
		SignalsNumber : UDINT := 1; (*Number of signals to be read*)
	END_STRUCT;
	BrAbbRwsSignalParSetType : 	STRUCT  (*Parameters of set signal procedure*)
		Network : STRING[80]; (*Network name*)
		Device : STRING[80]; (*Device name*)
		SignalName : STRING[80]; (*Signal name*)
		SetMode : BrAbbRwsSignalParSetModeEnum := BR_ABB_RWS_SIGNAL_MODE_VALUE; (*Set mode*)
		Pulses : UDINT := 10; (*Pusles number*)
		PulseOn : UDINT := 1000; (*Pulse on time[ms]*)
		PulseOff : UDINT := 1000; (*Pulse off time[ms]*)
		Value : BrAbbRwsSignalValuesType; (*The address of the variable to be assigned to a given signal*)
		SignalType : BrAbbRwsSignalSignalsTypesEnum; (*Signal type to which the new value is assigned*)
	END_STRUCT;
	BrAbbRwsSignalParGetType : 	STRUCT  (*Parameters of get signal procedure*)
		SignalName : STRING[80]; (*Name of the signal*)
		SignalType : BrAbbRwsSignalSignalsTypesEnum; (*Type of the signal*)
		Category : STRING[80]; (*Category of the signal (in robot controller signal can be assigned to the particular category)*)
		Value : BrAbbRwsSignalValuesType; (*Value of the signal (depending on the type of signal)*)
	END_STRUCT;
	BrAbbRwsSignalValuesType : 	STRUCT  (*Signal type*)
		DigitalValue : BOOL; (*Digital signal type*)
		AnalogValue : REAL; (*Analog signal type*)
		GroupValue : UDINT; (*Group signal type (sequence of the bits)*)
	END_STRUCT;
	BrAbbRwsSignalSignalsTypesEnum : 
		( (*Signal type (the following signal types can be assigned to the signal on the robot controller side)*)
		BR_ABB_RWS_SIGNALTYPE_DI, (*Digital input*)
		BR_ABB_RWS_SIGNALTYPE_DO, (*Digital output*)
		BR_ABB_RWS_SIGNALTYPE_GI, (*Group input*)
		BR_ABB_RWS_SIGNALTYPE_GO, (*Group output*)
		BR_ABB_RWS_SIGNALTYPE_AI, (*Analog input*)
		BR_ABB_RWS_SIGNALTYPE_AO (*Analog output*)
		);
	BrAbbRwsSignalInternalStepEnum : 
		( (*Type containing function block steps*)
		BR_ABB_RWS_STEP_WAIT_ENABLE, (*Waiting for enable command*)
		BR_ABB_RWS_STEP_WAIT_REQUEST, (*Waiting for command*)
		BR_ABB_RWS_STEP_WRITE_REQUEST, (*Writing request to the core function block*)
		BR_ABB_RWS_STEP_PROCESS_RESPONSE, (*Processing the response from the serwer*)
		BR_ABB_RWS_STEP_COMMANDS_RESET, (*Waiting until given command is reseted*)
		BR_ABB_RWS_STEP_ERROR (*Error state*)
		);
	BrAbbRwsSignalParSetModeEnum : 
		( (*Type of signal assignment*)
		BR_ABB_RWS_SIGNAL_MODE_VALUE, (*The specified value is assigned to the signal*)
		BR_ABB_RWS_SIGNAL_MODE_INVERT, (*The inverse of the specified value is assigned to the signal*)
		BR_ABB_RWS_SIGNAL_MODE_PULSE (*The given value of IO is in the shape of impulses*)
		);
END_TYPE

(***** Variables*)

TYPE
	BrAbbRwsVariableInternalType : 	STRUCT  (*Internal type*)
		Step : BrAbbRwsVariableInternalStepEnum; (*Actual step*)
		OldEnable : BOOL; (*Enable old*)
		OldErrorReset : BOOL; (*Error reset old*)
		OldSetValue : BOOL; (*Set value old*)
		OldGetValue : BOOL; (*Get value old*)
		AuxSetValue : BOOL; (*Internal set value command*)
		AuxGetValue : BOOL; (*Internal get value command*)
		Parameters : BrAbbRwsVariableParameterType; (*Internal parameter structure*)
		BufferIdx : USINT; (*Actual buffer index*)
		Response : BrAbbRwsCommonResponseType; (*Internal response structure*)
		AuxValueBool : BOOL; (*Internal bool value*)
		AuxValueNum : REAL; (*Internal numeric value*)
		AuxValueString : STRING[300]; (*Internal string value*)
		AuxValueRobTarget : BrAbbRwsVariableRobTarget; (*Internal RobTarget value (RobTarget is an ABB internal type)*)
		AuxValueJointTarget : BrAbbRwsVariableJointTargetType; (*Internal JointTarget value (JointTarget is an ABB internal type)*)
		AuxValueToolData : BrAbbRwsVariableToolDataType; (*Internal ToolData value (ToolData is an ABB internal type)*)
		AuxValueWObjData : BrAbbRwsVariableWObjectDataType; (*Internal WObjData value (WObjData is an ABB internal type)*)
		AuxValuePose : BrAbbRwsVariablePositionType; (*Internal Pose value (Pose is an ABB internal type)*)
		AuxString : STRING[300]; (*Internal string*)
		GetValue : BrAbbRwsVariableGetValType; (*Internal type used for server response processing*)
		fbExtrDelStr : ExtrDelStr; (*Instance of  ExtrDelStr function block*)
	END_STRUCT;
	BrAbbRwsVariableTranslationType : 	STRUCT  (*Robot position type (translation)*)
		X : REAL; (*Position X*)
		Y : REAL; (*Position Y*)
		Z : REAL; (*Position Z*)
	END_STRUCT;
	BrAbbRwsVariableRotationType : 	STRUCT  (*Robot position type (rotation)*)
		Q1 : REAL; (*Quaternion 1*)
		Q2 : REAL; (*Quaternion 2*)
		Q3 : REAL; (*Quaternion 3*)
		Q4 : REAL; (*Quaternion 4*)
	END_STRUCT;
	BrAbbRwsVariableRobotCfgType : 	STRUCT  (*Robot configuration type*)
		Cf1 : REAL; (*Configuration in which the robot achieves a particular position*)
		Cf4 : REAL; (*Configuration in which the robot achieves a particular position*)
		Cf6 : REAL; (*Configuration in which the robot achieves a particular position*)
		Cfx : REAL; (*Configuration in which the robot achieves a particular position*)
	END_STRUCT;
	BrAbbRwsVariableExtaxType : 	STRUCT 
		ExtAx1 : REAL;
		ExtAx2 : REAL;
		ExtAx3 : REAL;
		ExtAx4 : REAL;
		ExtAx5 : REAL;
		ExtAx6 : REAL;
	END_STRUCT;
	BrAbbRwsVariableRobTarget : 	STRUCT  (*Robot target type*)
		Translation : BrAbbRwsVariableTranslationType; (*Robot position type (translation)*)
		Rotation : BrAbbRwsVariableRotationType; (*Robot position type (rotation)*)
		RobotCfg : BrAbbRwsVariableRobotCfgType; (*Robot configuration type*)
		ExtAx : BrAbbRwsVariableExtaxType;
	END_STRUCT;
	BrAbbRwsVariableRobAxisType : 	STRUCT  (*Robot position type (axis position)*)
		RobAxis1 : REAL; (*Axis 1 position*)
		RobAxis2 : REAL; (*Axis 2 position*)
		RobAxis3 : REAL; (*Axis 3 position*)
		RobAxis4 : REAL; (*Axis 4 position*)
		RobAxis5 : REAL; (*Axis 5 position*)
		RobAxis6 : REAL; (*Axis 6 position*)
	END_STRUCT;
	BrAbbRwsVariableJointTargetType : 	STRUCT  (*Robot position type (joint target)*)
		RobAxis : BrAbbRwsVariableRobAxisType;
		ExtAx : BrAbbRwsVariableExtaxType;
	END_STRUCT;
	BrAbbRwsVariableGetValType : 	STRUCT  (*Internal type used for server response processing*)
		StartIdx : UDINT; (*Start index of the string being searched for*)
		EndIdx : UDINT; (*End index of the string being searched for
*)
		Value : STRING[300]; (*Value desired*)
	END_STRUCT;
	BrAbbRwsVariableTLoadType : 	STRUCT  (*Tool load type*)
		Mass : REAL; (*Mass*)
		CenterOfGravity : BrAbbRwsVariableTranslationType; (*Center of gravity*)
		AxesOfMoment : BrAbbRwsVariableRotationType; (*axes of moment
*)
		InertiaX : REAL; (*inertia x
*)
		InertiaY : REAL; (*inertia y*)
		InertiaZ : REAL; (*inertia z*)
	END_STRUCT;
	BrAbbRwsVariablePositionType : 	STRUCT  (*Robot position type*)
		Translation : BrAbbRwsVariableTranslationType; (*Translation *)
		Rotation : BrAbbRwsVariableRotationType; (*Rotation*)
	END_STRUCT;
	BrAbbRwsVariableToolDataType : 	STRUCT  (*Tool data type*)
		RobHold : BOOL; (*Robot hoold the tool*)
		Tframe : BrAbbRwsVariablePositionType; (*Tool frame position*)
		Tload : BrAbbRwsVariableTLoadType; (*Tool load*)
	END_STRUCT;
	BrAbbRwsVariableWObjectDataType : 	STRUCT  (*Work object type*)
		RobHold : BOOL; (*Defines whether or not the robot in the actual program task is holding the work object:
*)
		UfProg : BOOL; (*Defines whether or not a fixed user coordinate system is used
*)
		UfMec : STRING[80]; (*user frame mechanical unit
*)
		Uframe : BrAbbRwsVariablePositionType; (*User frame*)
		Oframe : BrAbbRwsVariablePositionType; (*object frame
*)
	END_STRUCT;
	BrAbbRwsVariableParameterType : 	STRUCT  (*Variable parameter type*)
		Task : STRING[80]; (*Name of the task in which the variable is located (RobotStudio task)*)
		Module : STRING[80]; (*Name of the module in which the variable is located (RobotStudio module)*)
		Variable : STRING[200]; (*Name of the variable (RobotStudio)*)
	END_STRUCT;
	BrAbbRwsVariableValueType : 	STRUCT  (*Variable value parameter type*)
		DataAdress : UDINT; (*The address of the variable that is assigned to the variable in RobotStudio (set command)) or to which the current value of the variable is assigned (get command).*)
		DataType : BrAbbRwsVariableValueTypeEnum; (*Variable type. The variable on the PLC side must be of the same type as the variable on the robot controller side.*)
		StringSize : UDINT;
	END_STRUCT;
	BrAbbRwsVariableValueTypeEnum : 
		( (*Variable type enum type*)
		BR_ABB_RWS_VAR_BOOL, (*Bool value*)
		BR_ABB_RWS_VAR_NUM, (*Numeric value*)
		BR_ABB_RWS_VAR_STRING, (*String value*)
		BR_ABB_RWS_VAR_ROBTARGET, (*RobTrarget value*)
		BR_ABB_RWS_VAR_JOINTTARGET, (*Joint target value*)
		BR_ABB_RWS_VAR_TOOLDATA, (*Tool data value*)
		BR_ABB_RWS_VAR_WOBJDATA, (*Work object data value*)
		BR_ABB_RWS_VAR_POSE (*Pose value*)
		);
	BrAbbRwsVariableInternalStepEnum : 
		( (*Type containing function block steps*)
		STEP_VAR_WAIT_ENABLE, (*Waiting for enable command*)
		STEP_VAR_WAIT_REQUEST, (*Waiting for command*)
		STEP_VAR_WRITE_REQUEST, (*Writing request to the core function block*)
		STEP_VAR_PROCESS_RESPONSE, (*Processing the response from the serwer*)
		STEP_VAR_WAIT_COMMANDS_RES, (*Waiting until given command is reseted*)
		STEP_VAR_ERROR (*Error state*)
		);
END_TYPE

(***** Elog messages*)

TYPE
	BrAbbRwsGetElogInternalType : 	STRUCT  (*Internal type*)
		Step : BrAbbRwsGetElogInternalStepType; (*Actual step*)
		OldEnable : BOOL; (*Enable old*)
		OldErrorReset : BOOL; (*Error reset old*)
		OldGetElog : BOOL; (*Get elog command old*)
		Parameters : BrAbbRwsGetElogParametersType; (*Internal parameter structure*)
		BufferIdx : USINT; (*Actual buffer index*)
		Response : BrAbbRwsCommonResponseType; (*Internal response structure*)
		SeqNumString : STRING[15];
		DomainDint : DINT; (*Domain number*)
		DomainString : STRING[3]; (*Domain string*)
		Elog : BrAbbRwsGetElogInternalElogType; (*Internal elog type*)
		TmpElogIdx : USINT;
		fbLogCreate : ArEventLogCreate; (*Instance of  ArEventLogCreate function block*)
		fbLogGetIdent : ArEventLogGetIdent; (*Instance of  ArEventLogGetIdent function block*)
		fbLogGetLastRecID : ArEventLogGetLatestRecordID; (*Instance of ArEventLogGetLatestRecordID function block*)
		fbLogRead : ArEventLogRead; (*Instance of ArEventLogRead function block*)
		fbLogWrite : ArEventLogWrite; (*Instance of ArEventLogWrite function block*)
		LogIdent : ArEventLogIdentType; (*Instance of ArEventLogIdentType function block*)
		LastRecordID : ArEventLogRecordIDType; (*Instance of ArEventLogRecordIDType function block*)
		LastRecordDateTime : DATE_AND_TIME; (*Date and time*)
		ElogIdx : INT; (*Elog index*)
		LogEventID : DINT; (*Log event ID*)
		TypeDint : DINT; (*Internal Dint type*)
		LogTimeStamp : ArEventLogTimeStampType; (*Log time stamp*)
		CodeString : STRING[15]; (*Log code (converted to string)*)
		LogDescription : STRING[200]; (*Log description*)
		LastRecordEventID : DINT; (*Last record event ID*)
		LastRecordIdx : INT; (*Last record index*)
		NewLogger : BOOL; (*New looger *)
		fbExtrDelStr : ExtrDelStr; (*Instance of ExtrDelStr function block*)
	END_STRUCT;
	BrAbbRwsGetElogParFilterType : 	STRUCT  (*Elog filter type*)
		Information : BOOL := TRUE; (*Enable information log*)
		Warning : BOOL := TRUE; (*Enable warning log*)
		Error : BOOL := TRUE; (*Enable error log*)
	END_STRUCT;
	BrAbbRwsGetElogParametersType : 	STRUCT  (*Elog  parameter type*)
		Domain : BrAbbRwsGetElogParDomainEnum; (*Domain*)
		Filter : BrAbbRwsGetElogParFilterType; (*Filter*)
		Logger : BrAbbRwsGetElogParLoggerType; (*AR logger*)
	END_STRUCT;
	BrAbbRwsGetElogParLoggerType : 	STRUCT  (*AR logger type*)
		Enable : BOOL; (*Enable AR logger*)
		Persistence : BrAbbRwsGetElogParLogPersEnum := (0); (*Persistance*)
		RobotName : STRING[4] := ''; (*Name of the robot (is attached to the AR logger filter)*)
	END_STRUCT;
	BrAbbRwsGetElogElogType : 	STRUCT  (*Elog type*)
		Type : BrAbbRwsGetElogElogTypeEnum; (*Type of the log*)
		Code : UDINT; (*Code of the log*)
		Title : STRING[200]; (*Title of the log*)
		DateTime : DATE_AND_TIME; (*Time stamp of the log*)
	END_STRUCT;
	BrAbbRwsGetElogInternalElogType : 	STRUCT  (*Internal type used for server response processing*)
		StartIdx : UDINT; (*Start index*)
		EndIdx : UDINT; (*End index*)
		Type : STRING[3]; (*Log type*)
		Code : STRING[15]; (*Log code*)
		Title : STRING[200]; (*Log title*)
		DateTime : STRING[50]; (*Log timestamp*)
		TmpDateTime : STRING[5];
		DateTimeDTstruct : DTStructure;
		Idx : USINT; (*Internal index*)
		Elog : ARRAY[0..BR_ABB_RWS_MAX_ELOG]OF BrAbbRwsGetElogElogType; (*Elog type*)
	END_STRUCT;
	BrAbbRwsGetElogErrorInfoType : 	STRUCT  (*Error info*)
		Http : BrAbbRwsErrorInfoType; (*http error info*)
		Logger : BrAbbRwsGetElogErrInfoLogType; (*logger error info*)
	END_STRUCT;
	BrAbbRwsGetElogErrInfoLogType : 	STRUCT  (*Logger error info*)
		Status : DINT; (*Logger status*)
	END_STRUCT;
	BrAbbRwsGetElogParLogPersEnum : 
		( (*Log persistance enum type*)
		RWS_GETELOG_PERSISTENCE_VOLATILE,
		RWS_GETELOG_PERSISTENCE_REMANENT,
		RWS_GETELOG_PERSISTENCE_PERSIST
		);
	BrAbbRwsGetElogParDomainEnum : 
		(
		RWS_GETELOG_DOMAIN_COMMON := 0,
		RWS_GETELOG_DOMAIN_OPERATIONAL := 1,
		RWS_GETELOG_DOMAIN_SYSTEM := 2,
		RWS_GETELOG_DOMAIN_HARDWARE := 3,
		RWS_GETELOG_DOMAIN_PROGRAM := 4,
		RWS_GETELOG_DOMAIN_MOTION := 5,
		RWS_GETELOG_DOMAIN_IO_COMM := 7,
		RWS_GETELOG_DOMAIN_USER := 8,
		RWS_GETELOG_DOMAIN_SAFETY := 9,
		RWS_GETELOG_DOMAIN_INTERNAL := 10,
		RWS_GETELOG_DOMAIN_PROCESS := 11,
		RWS_GETELOG_DOMAIN_CONFIGURATION := 12,
		RWS_GETELOG_DOMAIN_RAPID := 15,
		RWS_GETELOG_DOMAIN_CONN_SERV := 17
		);
	BrAbbRwsGetElogInternalStepType : 
		( (*Type containing function block steps*)
		STEP_GETELOG_WAIT_ENABLE, (*Waiting for enable command*)
		STEP_GETELOG_WAIT_REQUEST, (*Waiting for command*)
		STEP_GETELOG_WRITE_REQUEST, (*Writing request to the core function block*)
		STEP_GETELOG_PROCESS_RESPONSE, (*Processing the response from the serwer*)
		STEP_GETELOG_LOG_CREATE, (*Creating the log*)
		STEP_GETELOG_LOG_GET_IDENT, (*Getting ident*)
		STEP_GETELOG_LOG_GET_LAST_REC, (*Getting las record*)
		STEP_GETELOG_LOG_READ, (*Reading the log*)
		STEP_GETELOG_LOG_WRITE, (*Writing the log*)
		STEP_GETELOG_WAIT_COMMANDS_RESET, (*Waiting until given command is reseted*)
		STEP_GETELOG_ERROR (*Error state*)
		);
	BrAbbRwsGetElogElogTypeEnum : 
		( (*Log type*)
		BR_ABB_RWS_ELOG_MSGTYPE_NONE := 0, (*Unknown*)
		BR_ABB_RWS_ELOG_MSGTYPE_INFO := 1, (*Information*)
		BR_ABB_RWS_ELOG_MSGTYPE_WARNING := 2, (*Warning*)
		BR_ABB_RWS_ELOG_MSGTYPE_ERROR := 3 (*Error*)
		);
END_TYPE
