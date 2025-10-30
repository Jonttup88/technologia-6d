
TYPE
	Motion6D_data_typ : 	STRUCT 
		Points : ARRAY[0..99]OF Motion6D_target_typ;
		count : USINT;
	END_STRUCT;
	Motion6D_target_typ : 	STRUCT 
		X : REAL;
		Y : REAL;
		type : USINT;
	END_STRUCT;
END_TYPE
