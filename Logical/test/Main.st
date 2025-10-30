
PROGRAM _INIT
	(* Insert code here *)
	
	FOR i := 0 TO 7 DO
		shuttles[i].index := i;
		shuttles[i].position.value.X := 0.120 + (i MOD 4) * 0.120;
		IF i < 4 THEN
			shuttles[i].position.value.Y := 0.120;  
		ELSE
			shuttles[i].position.value.Y := 0.240;  
		END_IF;
	END_FOR;
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	count := brfiShuttleSelect(ADR(shuttles), ADR(selection), X0, Y0, X1, Y1);
	
//	IF point1.x = point2.x THEN
//		slope := 0;
//	ELSE
//		slope := (point2.y-point1.y) / (point2.x - point1.x);
//	END_IF;
//	
	line1.a := point2.y - point1.y;
	line1.b := point1.x - point2.x;
	line1.c := -(line1.a * point1.x + line1.b * point1.y);
	
	line2.a := point3.y - point2.y;
	line2.b := point2.x - point3.x;
	line2.c := -(line2.a * point2.x + line2.b * point2.y);
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

