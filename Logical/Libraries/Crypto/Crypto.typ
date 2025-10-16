(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SafetyExt
 * File: SafetyExt.typ
 * Author: raymom
 * Created: March 06, 2013
 ********************************************************************
 * Data types of library SafetyExt
 ********************************************************************)

TYPE
	px32Md5_t : 	STRUCT  (*Structure for md5 calculation*)
		aulBuf : ARRAY[0..3]OF UDINT; (*internal buffer*)
		aulBits : ARRAY[0..1]OF UDINT; (*auxiliary*)
		aulIn : ARRAY[0..15]OF UDINT; (*auxiliary*)
	END_STRUCT;
END_TYPE
