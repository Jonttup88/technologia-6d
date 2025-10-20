
TYPE
	gMain_par_typ : 	STRUCT 
		itemsPrShuttle : INT;
		controlLight : BOOL;
	END_STRUCT;
	gMain_status_typ : 	STRUCT 
		powerOff : INT;
		running : INT;
		powerOn : INT;
		itemsPrHour : INT;
		itemsPrMin : INT;
		error : INT;
	END_STRUCT;
	gMain_cmd_typ : 	STRUCT 
		powerOff : BOOL;
		powerOn : BOOL;
		start : BOOL;
		pause : BOOL;
		reset : BOOL;
		stop : BOOL;
		restartCtrl : BOOL; (*WARNING: restarts 6D controller and PLC*)
		forceError : BOOL;
		resetStart : BOOL; (*Reset & start the program *)
		advanced : BOOL; (*Show advance options*)
		unlockPrgSelect : BOOL; (*Unlock the option to select different program*)
	END_STRUCT;
	gMain_typ : 	STRUCT 
		par : gMain_par_typ;
		status : gMain_status_typ;
		cmd : gMain_cmd_typ;
	END_STRUCT;
END_TYPE
