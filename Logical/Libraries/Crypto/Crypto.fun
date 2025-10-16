(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SafetyExt
 * File: SafetyExt.fun
 * Author: raymom
 * Created: March 06, 2013
 ********************************************************************
 * Functions and function blocks of library SafetyExt
 ********************************************************************)

FUNCTION px32Md5Calc : UINT (*calculation of the hash key*)
	VAR_INPUT
		ulDataLen : UDINT;
	END_VAR
	VAR_IN_OUT
		pucDataIn : USINT;
		pucHashKeyOut : USINT;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION hex2str : BOOL (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		hashCode : ARRAY[0..15] OF USINT;
		adr_md5Code : UDINT;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION newNonce : BOOL (* *) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		adrNonce : REFERENCE TO STRING[32];
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION_BLOCK ExtrDelStr (*This function block extracts from "StrTotal" the string delimited by "StrLeft" and "StrRight", starting to search from "StartSearchIdx"*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pStrDest : UDINT; (*Address of the destination string where the delimited string has to be copied to.*)
		StrDestDim : UDINT; (*Dimension of the destination string (SIZEOF).*)
		pStrTotal : UDINT; (*Address of the string where the delimited string has to be looked for. It has to be a null terminated string.*)
		pStrLeft : UDINT; (*Left limit string. It has to be a null terminated string.*)
		pStrRight : UDINT; (*Right limit string. It has to be a null terminated string.*)
		StartSearchIdx : UDINT; (*Position from which the delimited string has to be searched inside the total string. Numeration starts from 0.*)
	END_VAR
	VAR_OUTPUT
		StartIdx : UDINT; (*Start position of the delimited string inside the total string. Numeration starts from 1. If StartIdx = 0, execution of the function block failed.*)
		EndIdx : UDINT; (*End position of the delimited string inside the total string. Numeration starts from 1. If EndIdx = 0, execution of the function block failed.*)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} FUNCTION Real2Str : UDINT (*This function converts a REAL value into a STRING, returning the powers with the following form: e+10 -> e10, e-10 -> e-10. The function returns the address of the "+" character, if present, otherwise 0.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		RealVar : REAL; (*Real variable to be converted into a string.*)
		pString : UDINT; (*Address of the string where the converted value has to be copied. The user is responsible for making sure that there is enough memory available in the target memory.*)
	END_VAR
END_FUNCTION
