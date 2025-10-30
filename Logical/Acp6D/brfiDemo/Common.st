
(*  *)
FUNCTION brfiShuffle
	
	count := gMAX_INDEX_SHUTTLE;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		rand := RandValueDINT(0, count);  
		ordinal := 0;
		
		FOR x := 0 TO gMAX_INDEX_SHUTTLE DO
			IF NOT added[x] THEN
				ordinal := ordinal + 1;		
			END_IF;
			
			IF (rand + 1) = ordinal THEN
				EXIT;
			END_IF;
		END_FOR;
		
		added[x] := TRUE;
		newOrder[x] := refArray[i];
		count := count - 1;
		
	END_FOR;
	
	brsmemcpy(ADR(refArray), ADR(newOrder), SIZEOF(refArray));
			
END_FUNCTION


FUNCTION brfiShuttleSelect
	
	// First find shuttles that are in the selection area
	maxX := MAX(X0, X1);
	maxY := MAX(Y0, Y1);
	minX := MIN(X0, X1);
	minY := MIN(Y0, Y1);
	brsmemset(ADR(Selection), 0, SIZEOF(Selection));
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		IF Shuttles[i].position.value.X < maxX AND Shuttles[i].position.value.X > minX THEN
			IF Shuttles[i].position.value.Y < maxY AND Shuttles[i].position.value.Y > minY THEN
				Selection[count].index := Shuttles[i].index;
				Selection[count].ID := Shuttles[i].ID;
				Selection[count].x := Shuttles[i].position.value.X;
				Selection[count].y := Shuttles[i].position.value.Y;
				count := count + 1;	
			END_IF;
		END_IF;  
	END_FOR;
	
	brfiShuttleSelect := count;
	
	IF count < 2 THEN
		RETURN;  
	END_IF;
	
	// Sort selection array by X
	FOR i := 1 TO count - 1 DO
		key := Selection[i];
		j := i - 1;
		
		// Compare key with each element on the LEFT OF it UNTIL an element smaller than it is found
		WHILE j >= 0 AND brfiSortCompare(key, Selection[j], (X0 < X1), (Y0 < Y1)) DO
			Selection[j + 1] := Selection[j];
			j := j - 1;
			Selection[j + 1] := key;
		END_WHILE;
	END_FOR
	
END_FUNCTION

FUNCTION brfiShuttleSelectClosest
	
	dist_min := 1000000;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		dist := SQRT(EXPT(X - Shuttles[i].position.value.X, 2) + EXPT(Y - Shuttles[i].position.value.Y, 2));
		
		IF  dist < dist_min THEN
			dist_min := dist;
	  		index_min := i;
		END_IF;
	END_FOR;
	
	brfiShuttleSelectClosest := index_min;
	
END_FUNCTION


FUNCTION brfiSortCompare
	// Comparison function for two pairs (A, B)
	
	IF AscendingX THEN
		// X needs to be sorted in ascending order
		IF A.x < B.x THEN
			brfiSortCompare := TRUE;
			RETURN;
		END_IF;  
	ELSE
		// X needs to be sorted in descending order
		IF A.x > B.x THEN
			brfiSortCompare := TRUE;
			RETURN;
		END_IF;  
	END_IF;
	
	isEqualX := ABS(A.x - B.x) < 0.001;
	
	IF isEqualX THEN
		// Only sort by Y if X is equal as we primarily sort by X
		IF AscendingY THEN
			// Y needs to be sorted in ascending order
			IF A.y < B.y THEN
				brfiSortCompare := TRUE;
				RETURN;
			END_IF;  
		ELSE
			// Y needs to be sorted in descending order
			IF A.y > B.y THEN
				brfiSortCompare := TRUE;
				RETURN;
			END_IF;  
		END_IF;  
	END_IF;
		
END_FUNCTION

FUNCTION brfiToRAD
	
	brfiToRAD := degrees * brmPI / 180.0;
	  
END_FUNCTION

FUNCTION brfiToDEG
	
	brfiToDEG := radians / brmPI * 180.0;
	  
END_FUNCTION




