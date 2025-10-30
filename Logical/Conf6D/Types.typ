
TYPE
	Segment_typ : 	STRUCT 
		x : INT;
		y : INT;
		IsMaster : BOOL;
		Name : STRING[20];
	END_STRUCT;
	Layout_typ : 	STRUCT 
		Segments : ARRAY[0..99]OF Segment_typ;
		SegmentCount : USINT;
		Xcount : USINT;
		Ycount : USINT;
	END_STRUCT;
END_TYPE
