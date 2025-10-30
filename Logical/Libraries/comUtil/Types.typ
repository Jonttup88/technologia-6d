
TYPE
	monitor_var_typ : 	STRUCT 
		variables : ARRAY[0..MAX_MONITOR_VAR_MINUS1]OF var_typ;
		count : USINT;
		active : BOOL;
		init : BOOL;
	END_STRUCT;
	var_typ : 	STRUCT 
		name : STRING[80];
		queryName : STRING[80];
		crc : UDINT;
		pv_addr : UDINT;
		datatype : UINT;
		size : UDINT;
		clientIdent : UDINT;
	END_STRUCT;
	ws_server_clients_typ : 	STRUCT 
		client : ARRAY[0..MAX_CLIENT_COUNT_MINUS1]OF ws_server_client_typ;
		count : USINT;
	END_STRUCT;
	ws_server_client_data_typ : 	STRUCT 
		recvbuf : ARRAY[0..9999]OF USINT;
		sendbuf : ARRAY[0..99999]OF USINT;
		recvlen : UDINT;
	END_STRUCT;
	ws_server_client_fb_typ : 	STRUCT 
		TcpSend_0 : TcpSend;
		TcpRecv_0 : TcpRecv;
		TcpClose_0 : TcpClose;
		TON_0 : TON;
	END_STRUCT;
	ws_server_client_typ : 	STRUCT 
		FB : ws_server_client_fb_typ;
		data : ws_server_client_data_typ;
		monitor : monitor_var_typ;
		ip_addr : STRING[20];
		commState : USINT;
		status : INT;
		ident : UDINT;
		monitorActive : BOOL;
	END_STRUCT;
	ws_server_data_typ : 	STRUCT 
		ip_addr : STRING[20];
		monitorData : ARRAY[0..99999]OF USINT;
		latestData1 : ARRAY[0..99999]OF USINT;
		latestData : ARRAY[0..99999]OF USINT;
		prevError : UDINT;
	END_STRUCT;
	ws_server_fb_typ : 	STRUCT 
		TcpOpen_0 : TcpOpen;
		TcpServer_0 : TcpServer;
		TcpClose_0 : TcpClose;
		TON_0 : TON;
		TcpIoctl_0 : TcpIoctl;
		PLC_var_info_0 : PLC_var_info;
	END_STRUCT;
	ws_server_int_typ : 	STRUCT 
		FB : ws_server_fb_typ;
		data : ws_server_data_typ;
		clients : ws_server_clients_typ;
		read : monitor_var_typ;
		serverState : USINT;
	END_STRUCT;
	plc_var_info_typ : 	STRUCT 
		plc : Plc_typ;
		var_typ : PV_xList_typ;
		module_typ : MO_List_typ;
		MO_info_0 : MO_info;
		browse_module_state : USINT;
		browse_var_state : USINT;
		prev_index : UINT;
		datatype : UDINT;
		datalen : UDINT;
		datadim : UINT;
		browse : BOOL;
		status : UINT;
		index : UINT;
		found : BOOL;
		localVarFound : BOOL;
		i : UINT;
		j : UINT;
		tempSTRING : STRING[80];
	END_STRUCT;
	Task_typ : 	STRUCT 
		Name : STRING[20];
		StartAddress : UDINT;
		Size : UDINT;
		Version : ARRAY[0..9]OF USINT;
		Date : RTCtime_typ;
		Variables : ARRAY[0..200]OF Variable_typ;
		VariableCount : UINT;
	END_STRUCT;
	Plc_typ : 	STRUCT 
		TaskCount : UINT;
		Tasks : ARRAY[0..20]OF Task_typ;
		GlobalVars : ARRAY[0..100]OF Variable_typ;
		GlobalVarCount : UINT;
	END_STRUCT;
	Variable_typ : 	STRUCT 
		Name : STRING[32];
		Type : UINT;
	END_STRUCT;
END_TYPE
