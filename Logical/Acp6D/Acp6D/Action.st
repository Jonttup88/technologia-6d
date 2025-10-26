
ACTION acInitializePositions: 

	// ---------------------------------------------------------------------------------------
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		positions.home[i].X := i MOD 4 * 0.120 + 0.240 + 0.060;  
		IF i < 4 THEN
			positions.home[i].Y := 0.180 + 0.240;
		ELSE
			positions.home[i].Y := 0.180 + 0.240 + 0.120;
		END_IF;
	END_FOR;
	
	// ---------------------------------------------------------------------------------------
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		positions.user[i].X := i * 0.120 + 0.060;
		positions.user[i].Y := 3 * 0.240;
	END_FOR;
	
	// ---------------------------------------------------------------------------------------
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		IF (i MOD 2) = 0 THEN
			positions.shuffle[i].X := 0.480 + COS(DINT_TO_REAL(i) * 45.0 * brmPI/180.0) * 0.420;
			positions.shuffle[i].Y := 0.480 + SIN(DINT_TO_REAL(i) * 45.0 * brmPI/180.0) * 0.420;
		ELSE
			positions.shuffle[i].X := 0.480 + COS(DINT_TO_REAL(i) * 45.0 * brmPI/180.0) * 0.240;
			positions.shuffle[i].Y := 0.480 + SIN(DINT_TO_REAL(i) * 45.0 * brmPI/180.0) * 0.240;
		END_IF;
	END_FOR;
	
	// ---------------------------------------------------------------------------------------
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		positions.clockface[i].X := 0.480 + COS(DINT_TO_REAL(i) * 45.0 * brmPI/180.0) * 0.420;
		positions.clockface[i].Y := 0.480 + SIN(DINT_TO_REAL(i) * 45.0 * brmPI/180.0) * 0.420;
	END_FOR;
	
	// ---------------------------------------------------------------------------------------
	positions.dance[0].X := 0 * 0.24 + 0.12;
	positions.dance[0].Y := 0 * 0.24 + 0.12;
	positions.dance[1].X := 3 * 0.24 + 0.12;
	positions.dance[1].Y := 0 * 0.24 + 0.12;
	positions.dance[2].X := 0 * 0.24 + 0.12;
	positions.dance[2].Y := 3 * 0.24 + 0.12;
	positions.dance[3].X := 3 * 0.24 + 0.12;
	positions.dance[3].Y := 3 * 0.24 + 0.12;
	
	positions.dance[4].X := 1 * 0.24 + 0.12;
	positions.dance[4].Y := 1 * 0.24 + 0.12;
	positions.dance[5].X := 1 * 0.24 + 0.12;
	positions.dance[5].Y := 2 * 0.24 + 0.12;
	positions.dance[6].X := 2 * 0.24 + 0.12;
	positions.dance[6].Y := 1 * 0.24 + 0.12;
	positions.dance[7].X := 2 * 0.24 + 0.12;
	positions.dance[7].Y := 2 * 0.24 + 0.12;
	
	// ---------------------------------------------------------------------------------------
	positions.pickup[0].X := 0.480;
	positions.pickup[0].Y := 0.480;	
	
	FOR i := 1 TO gMAX_INDEX_SHUTTLE DO
		positions.pickup[i].X := 0.480 + COS(DINT_TO_REAL(i - 1) * (180/6) * brmPI/180.0) * 0.360;
		positions.pickup[i].Y := 0.480 + SIN(DINT_TO_REAL(i - 1) * (180/6) * brmPI/180.0) * 0.360;	
	END_FOR
	
END_ACTION

ACTION acClearTargetQueues :
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		brsmemset(ADR(fb.Move6DQueue[i].Targets), 0, SIZEOF(fb.Move6DQueue[i].Targets));
		brsmemset(ADR(fb.MoveXYQueue[i].Targets), 0, SIZEOF(fb.MoveXYQueue[i].Targets));
	END_FOR;
	  
END_ACTION

ACTION acFunctionGroupStatus :
	
	// 6D Queue
	// Check if any of the FBs are executing
	local.executing := FALSE;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		local.executing := (local.executing OR fb.Move6DQueue[i].Execute);	
	END_FOR
	
	IF NOT local.executing THEN
		brsmemset(ADR(group_status.Move6DQueue), 0, SIZEOF(group_status.Move6DQueue));
	ELSE
		group_status.Move6DQueue.AllDone := TRUE;
		
		FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
			IF NOT fb.Move6DQueue[i].Done THEN
				group_status.Move6DQueue.AllDone := FALSE;
			ELSIF fb.Move6DQueue[i].Error THEN
				group_status.Move6DQueue.LastErrorID := fb.Move6DQueue[i].LastStatusCode;	
				group_status.Move6DQueue.Error := TRUE;
			END_IF;
		END_FOR;	
	END_IF;
	
	// XY Queue
	// Check if any of the FBs are executing
	local.executing := FALSE;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		local.executing := (local.executing OR fb.MoveXYQueue[i].Execute);	
	END_FOR
	
	IF NOT local.executing THEN
		brsmemset(ADR(group_status.MoveXYQueue), 0, SIZEOF(group_status.MoveXYQueue));
	ELSE
		group_status.MoveXYQueue.AllDone := TRUE;
		
		FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
			IF NOT fb.MoveXYQueue[i].Done THEN
				group_status.MoveXYQueue.AllDone := FALSE;
			ELSIF fb.MoveXYQueue[i].Error THEN
				group_status.MoveXYQueue.LastErrorID := fb.MoveXYQueue[i].LastStatusCode;	
				group_status.MoveXYQueue.Error := TRUE;
			END_IF;
		END_FOR;	
	END_IF;
	  
END_ACTION