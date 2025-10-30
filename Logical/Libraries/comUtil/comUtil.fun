
{REDUND_ERROR} FUNCTION_BLOCK ws_server (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Enable : BOOL;
		ServerPort : UINT;
	END_VAR
	VAR_OUTPUT
		Active : BOOL;
		httpPort : UDINT;
	END_VAR
	VAR
		Internal : ws_server_int_typ;
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} FUNCTION pvValues : BOOL (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pPvName : UDINT;
		pBuffer : UDINT;
		BufferLen : UDINT;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION pvElements : BOOL (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pPvName : UDINT;
		pBuffer : UDINT;
		pParent : UDINT;
		last : BOOL;
		first : BOOL;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION_BLOCK PLC_var_info (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		enable : BOOL;
	END_VAR
	VAR_OUTPUT
		active : BOOL;
	END_VAR
	VAR
		Internal : plc_var_info_typ;
	END_VAR
	VAR_INPUT
		browse : BOOL;
	END_VAR
	VAR_OUTPUT
		done : BOOL;
		data : Plc_typ;
	END_VAR
END_FUNCTION_BLOCK
