(*This function block is managing the http based communication between robot controller and PLC. Is also mandatory for all the services. 
This function block provides an "Ident" number which allow to communicate with  the other function blocks. It receive the request from the RWS server and provide the response to each service function block. *)

{REDUND_ERROR} FUNCTION_BLOCK BrAbbRwsCore (*This function block is managing the http based communication between robot controller and PLC. Is also mandatory for all the services. 
This function block provides an "Ident" number which allow to communicate with  the other function blocks. It receive the request from the RWS server and provide the response to each service function block. *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Executes the action of the function block
*) (* *) (*#PAR*)
		ErrorReset : BOOL; (*Resets function block errors 
*) (* *) (*#PAR*)
		Parameters : BrAbbRwsCoreParametersType; (*Function block parameters 
*) (* *) (*#PAR*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Indicates whether the function block is active and the communication with the robot active 
*) (* *) (*#PAR*)
		Busy : BOOL; (*The function block is enabled and must continue to be called 
*) (* *) (*#PAR*)
		Ident : UDINT; (*Link for all services for communication to core block 
*) (* *) (*#PAR*)
		StatusID : BrAbbRwsStatusIDEnum; (*Status information about the function block 
*) (* *) (*#PAR*)
		Error : BOOL; (*Indicates that the function block is in an error state 
*) (* *) (*#PAR*)
		ErrorInfo : BrAbbRwsErrorInfoType; (*Provides additional information in case an error has occurred 
*) (* *) (*#PAR*)
	END_VAR
	VAR
		Internal : BrAbbRwsCoreInternalType; (*Internal structure*)
	END_VAR
END_FUNCTION_BLOCK
(*


****************************************
************ SERVICES  ************
*****************************************)
(*
This function block is responsible for reading the ABB robot controller logger. It provides logs with code information, severity and timestamp. It is also possible to store the logs in B&R logger. *)

{REDUND_ERROR} FUNCTION_BLOCK BrAbbRwsGetElog (*
This function block is responsible for reading the ABB robot controller logger. It provides logs with code information, severity and timestamp. It is also possible to store the logs in B&R logger. *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enables the function block 
*) (* *) (*#PAR*)
		ErrorReset : BOOL; (*Resets function block errors 
*) (* *) (*#PAR*)
		Ident : UDINT; (*Connector provided by BrAbbRwsCore function block
*) (* *) (*#PAR*)
		Parameters : BrAbbRwsGetElogParametersType; (*Function block parameters 
*) (* *) (*#PAR*)
		GetElog : BOOL; (*Command to get logs from robot controller according to parameters. 
*) (* *) (*#CMD*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Indicates whether the function block is active and can handle commands 
*) (* *) (*#PAR*)
		Busy : BOOL; (*The function block is enabled and must continue to be called 
*) (* *) (*#PAR*)
		Done : BOOL; (*The function block successfully completed the request 
*) (* *) (*#PAR*)
		StatusID : BrAbbRwsStatusIDEnum; (*Status information about the func-tion block 
*) (* *) (*#PAR*)
		Error : BOOL; (*Indicates that the function block is in an error state 
*) (* *) (*#PAR*)
		ErrorInfo : BrAbbRwsGetElogErrorInfoType; (*Provides additional information in case an error has occurred 
*) (* *) (*#PAR*)
		Elog : ARRAY[0..BR_ABB_RWS_MAX_ELOG] OF BrAbbRwsGetElogElogType; (*Logs read from robot controller 
*) (* *) (*#CMD*)
	END_VAR
	VAR
		Internal : BrAbbRwsGetElogInternalType; (*Internal structure*)
		CoreSrvLink : REFERENCE TO BrAbbRwsCommonCoreSrvLinkType;
	END_VAR
END_FUNCTION_BLOCK
(*This function block is mainly aiming at managing variables. It is possible to read and write variables already existing in the robot controller. *)

{REDUND_ERROR} FUNCTION_BLOCK BrAbbRwsVariable (*This function block is mainly aiming at managing variables. It is possible to read and write variables already existing in the robot controller. *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enables the function block 
*) (* *) (*#PAR*)
		ErrorReset : BOOL; (*Resets function block errors 
*) (* *) (*#PAR*)
		Ident : UDINT; (*Connector provided by BrAbbRwsCore function block
*) (* *) (*#PAR*)
		Parameters : BrAbbRwsVariableParameterType; (*Function block parameters 
*) (* *) (*#PAR*)
		SetValue : BOOL; (*Command to set variable*) (* *) (*#CMD*)
		GetValue : BOOL; (*Command to get variable*) (* *) (*#CMD*)
		Value : BrAbbRwsVariableValueType; (*Parameters of source / destination vairable*) (* *) (*#PAR*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Indicates whether the function block is active and can handle commands 
*) (* *) (*#PAR*)
		Busy : BOOL; (*The function block is enabled and must continue to be called 
*) (* *) (*#PAR*)
		Done : BOOL; (*The function block successfully completed the request 
*) (* *) (*#PAR*)
		StatusID : BrAbbRwsStatusIDEnum; (*Status information about the function block 
*) (* *) (*#PAR*)
		Error : BOOL; (*Indicates that the function block is in an error state 
*) (* *) (*#PAR*)
		ErrorInfo : BrAbbRwsErrorInfoType; (*Provides additional information in case an error has occurred 
*) (* *) (*#PAR*)
	END_VAR
	VAR
		Internal : BrAbbRwsVariableInternalType; (*Internal structure*)
		CoreSrvLink : REFERENCE TO BrAbbRwsCommonCoreSrvLinkType;
	END_VAR
END_FUNCTION_BLOCK
(*This function block  is responsible for managing I/O signals connected to robot controller. It allows to force outputs with different modes and to read the inputs .*)

{REDUND_ERROR} FUNCTION_BLOCK BrAbbRwsSignal (*This function block  is responsible for managing I/O signals connected to robot controller. It allows to force outputs with different modes and to read the inputs .*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enables the function block 
*) (* *) (*#PAR*)
		ErrorReset : BOOL; (*Resets function block errors 
*) (* *) (*#PAR*)
		Ident : UDINT; (*Connector provided by BrAbbRwsCore function block
*) (* *) (*#PAR*)
		Parameters : BrAbbRwsSignalParType; (*Function block parameters 
*) (* *) (*#PAR*)
		SetValue : BOOL; (*Command to get input/output value*) (* *) (*#CMD*)
		GetValue : BOOL; (*Command to set input/output value 
*) (* *) (*#CMD*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Indicates whether the function block is active and can handle commands 
*) (* *) (*#PAR*)
		Busy : BOOL; (*The function block is enabled and must continue to be called 
*) (* *) (*#PAR*)
		Done : BOOL; (*The function block successfully completed the request 
*) (* *) (*#PAR*)
		StatusID : BrAbbRwsStatusIDEnum; (*Status information about the function block 
*) (* *) (*#PAR*)
		Error : BOOL; (*Indicates that the function block is in an error state 
*) (* *) (*#PAR*)
		ErrorInfo : BrAbbRwsErrorInfoType; (*Provides additional information in case an error has occurred 
*) (* *) (*#PAR*)
	END_VAR
	VAR
		Internal : BrAbbRwsSignalInternalType; (*Internal structure*)
		CoreSrvLink : REFERENCE TO BrAbbRwsCommonCoreSrvLinkType;
	END_VAR
END_FUNCTION_BLOCK
(*This function block provides the commands for controller. We can control RAPID(motion program) and controller (e.g. motor power , warm restart). Only one command can be used in one PLC cycle.*)

{REDUND_ERROR} FUNCTION_BLOCK BrAbbRwsRapidCmd (*This function block provides the commands for controller. We can control RAPID(motion program) and controller (e.g. motor power , warm restart). Only one command can be used in one PLC cycle.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enables the function block 
*) (* *) (*#PAR*)
		ErrorReset : BOOL; (*Resets function block errors 
*) (* *) (*#PAR*)
		Ident : UDINT; (*Connector provided by BrAbbRwsCore function block
*) (* *) (*#PAR*)
		Parameters : BrAbbRwsRapidCmdParameterType; (*Function block parameters 
*) (* *) (*#PAR*)
		PowerOn : BOOL; (*Command to power on all motors 
*) (* *) (*#CMD*)
		PowerOff : BOOL; (*Command to power off all motors 
*) (* *) (*#CMD*)
		Start : BOOL; (*Command to start the rapid execution. It correspond to StartProdEntry command, and therefore reset also the rapid pointer to the first program line 
*) (* *) (*#CMD*)
		Stop : BOOL; (*Command to stop program execution. It does not affect the rapid pointer position 
*) (* *) (*#CMD*)
		Continue : BOOL; (*Command to start the rapid execution. It correspond to Start command, and therefore does not affect the rapid pointer position 
*) (* *) (*#CMD*)
		ChangeSpeedRatio : BOOL; (*Command to change the speed ratio (override)*) (* *) (*#CMD*)
		ResetPointer : BOOL; (*Command to reset also the rapid pointer to the first program line. Correspond to ResetPP command. 
*) (* *) (*#CMD*)
		Warmstart : BOOL; (*Command to perform a warm restart of the robot controller 
*) (* *) (*#CMD*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Indicates whether the function block is active and can handle commands 
*) (* *) (*#PAR*)
		Busy : BOOL; (*The function block is enabled and must continue to be called 
*) (* *) (*#PAR*)
		Done : BOOL; (*The function block successfully completed the request 
*) (* *) (*#PAR*)
		StatusID : BrAbbRwsStatusIDEnum; (*Status information about the function block 
*) (* *) (*#PAR*)
		Error : BOOL; (*Indicates that the function block is in an error state 
*) (* *) (*#PAR*)
		ErrorInfo : BrAbbRwsErrorInfoType; (*Provides additional information in case an error has occurred 
*) (* *) (*#PAR*)
	END_VAR
	VAR
		Internal : BrAbbRwsRapidCmdInternalType; (*Internal structure*)
		CoreSrvLink : REFERENCE TO BrAbbRwsCommonCoreSrvLinkType;
	END_VAR
END_FUNCTION_BLOCK
(*This function block provides the actual robot status. It allows to read several information, such as RAPID state, motors state, actual mode and robot position. *)

{REDUND_ERROR} FUNCTION_BLOCK BrAbbRwsGetState (*This function block provides the actual robot status. It allows to read several information, such as RAPID state, motors state, actual mode and robot position. *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL; (*Enables the function block 
*) (* *) (*#PAR*)
		ErrorReset : BOOL; (*Resets function block errors 
*) (* *) (*#PAR*)
		Ident : UDINT; (*Connector provided by BrAbbRwsCore function block
*) (* *) (*#PAR*)
		Parameters : BrAbbRwsStateParametersType; (*Function block parameters 
*) (* *) (*#PAR*)
		GetState : BOOL; (*Command to get informations from robot controller according to parameters. 
*) (* *) (*#CMD*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*Indicates whether the function block is active and can handle commands 
*) (* *) (*#PAR*)
		Busy : BOOL; (*The function block is enabled and must continue to be called 
*) (* *) (*#PAR*)
		Done : BOOL; (*The function block successfully completed the request 
*) (* *) (*#PAR*)
		StatusID : BrAbbRwsStatusIDEnum; (*Status information about the function block 
*) (* *) (*#PAR*)
		Error : BOOL; (*Indicates that the function block is in an error state 
*) (* *) (*#PAR*)
		ErrorInfo : BrAbbRwsErrorInfoType; (*Provides additional information in case an error has occurred 
*) (* *) (*#PAR*)
		RapidState : BrAbbRwsStateRapidStateEnum; (*Current rapid state 
*) (* *) (*#CMD*)
		MotorState : BrAbbRwsStateMotorStateEnum; (*Current motor state 
*) (* *) (*#CMD*)
		ActiveMode : BrAbbRwsStateActiveModeEnum; (*Active controller mode 
*) (* *) (*#CMD*)
		ActPosition : BrAbbRwsStatePosCartType; (*Current Robot position 
*) (* *) (*#CMD*)
		ActSpeedRatio : USINT; (*Actual speed ratio*) (* *) (*#CMD*)
	END_VAR
	VAR
		Internal : BrAbbRwsStateInternalType; (*Internal structure*)
		CoreSrvLink : REFERENCE TO BrAbbRwsCommonCoreSrvLinkType;
	END_VAR
END_FUNCTION_BLOCK
