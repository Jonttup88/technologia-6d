
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
		positions.user[i].Y := 1 * 0.240 + 0.120;
	END_FOR;
	
	// ---------------------------------------------------------------------------------------
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		positions.side[i].X := 4 * 0.240 - 0.060;
		positions.side[i].Y := 0.060 + i * 0.120;
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
		positions.clockface[i].X := 0.480 + COS(DINT_TO_REAL(i) * 45.0 * brmPI/180.0) * 0.300;
		positions.clockface[i].Y := 0.480 + SIN(DINT_TO_REAL(i) * 45.0 * brmPI/180.0) * 0.300;
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
		positions.pickup[i].Y := 0.310 + SIN(DINT_TO_REAL(i - 1) * (180/6) * brmPI/180.0) * 0.360;	
	END_FOR
	
	// Simple shuffle
	// ---------------------------------------------------------------------------------------
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		IF i < 4 THEN
			positions.shuffle_simple[i].X := 0.120 + i * 0.240;
			positions.shuffle_simple[i].Y := 3 * 0.240;	
		ELSE
			positions.shuffle_simple[i].X := 0.300 + (i MOD 4) * 0.120;
			positions.shuffle_simple[i].Y := 0.120;	
		END_IF;  
	END_FOR;
	
	// Kongo lines
	// ---------------------------------------------------------------------------------------
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		IF i < 4 THEN
			positions.kongo_lines[i].X := 0.120 + 0.240;
			positions.kongo_lines[i].Y := 0.060 + i * 0.240;	
		ELSE
			positions.kongo_lines[i].X := 2 * 0.240 + 0.120;
			positions.kongo_lines[i].Y := 0.180 + (i MOD 4) * 0.240;	
		END_IF;  
	END_FOR;
	
	// Letters
	// ---------------------------------------------------------------------------------------
	positions._L[0].X := 0.24 * 3 - 0.06;
	positions._L[0].Y := 0.24 + 0.12 * 0;
	positions._L[1].X := 0.24 * 3 - 0.06;
	positions._L[1].Y := 0.24 + 0.12 * 1;
	positions._L[2].X := 0.24 * 3 - 0.06;
	positions._L[2].Y := 0.24 + 0.12 * 2;
	positions._L[3].X := 0.24 * 3 - 0.06;
	positions._L[3].Y := 0.24 + 0.12 * 3;
	positions._L[4].X := 0.24 * 3 - 0.06;
	positions._L[4].Y := 0.24 + 0.12 * 4;
	positions._L[5].X := 0.24 + 0.12 * 1 - 0.06;
	positions._L[5].Y := 0.24 * 3;
	positions._L[6].X := 0.24 + 0.12 * 2 - 0.06;
	positions._L[6].Y := 0.24 * 3;
	positions._L[7].X := 0.24 + 0.12 * 3 - 0.06;
	positions._L[7].Y := 0.24 * 3;
	
	positions._O[0].X := 0.24 + 0.06;
	positions._O[0].Y := 0.24 + 0.10;
	positions._O[1].X := 0.24 + 0.06;
	positions._O[1].Y := 0.24 * 2;
	positions._O[2].X := 0.24 + 0.06;
	positions._O[2].Y := 0.24 * 3 - 0.1;
	positions._O[3].X := 0.24 * 3 - 0.06;
	positions._O[3].Y := 0.24 + 0.10;
	positions._O[4].X := 0.24 * 3 - 0.06;
	positions._O[4].Y := 0.24 * 2;
	positions._O[5].X := 0.24 * 3 - 0.06;
	positions._O[5].Y := 0.24 * 3 - 0.1;
	positions._O[6].X := 0.24 * 2;
	positions._O[6].Y := 0.24;
	positions._O[7].X := 0.24 * 2;
	positions._O[7].Y := 0.24 * 3;

	positions._S[0].X := 0.36;
	positions._S[0].Y := 0.24;
	positions._S[1].X := 0.54;
	positions._S[1].Y := 0.24;
	positions._S[2].X := 0.635;
	positions._S[2].Y := 0.365;
	positions._S[3].X := 0.53;
	positions._S[3].Y := 0.485;
	positions._S[4].X := 0.38;
	positions._S[4].Y := 0.485;
	positions._S[5].X := 0.305;	
	positions._S[5].Y := 0.61;
	positions._S[6].X := 0.41;
	positions._S[6].Y := 0.73;
	positions._S[7].X := 0.60;
	positions._S[7].Y := 0.73;

	positions._E[0].X := 2 * 0.24 + 0.12;
	positions._E[0].Y := 0.24 + 0 * 0.12;
	positions._E[1].X := 2 * 0.24 + 0.12;
	positions._E[1].Y := 0.24 + 1 * 0.12;
	positions._E[2].X := 2 * 0.24 + 0.12;
	positions._E[2].Y := 0.24 + 2 * 0.12;
	positions._E[3].X := 2 * 0.24 + 0.12;
	positions._E[3].Y := 0.24 + 3 * 0.12;
	positions._E[4].X := 2 * 0.24 + 0.12;
	positions._E[4].Y := 0.24 + 4 * 0.12;
	positions._E[5].X := 2 * 0.24 - 0.06;	
	positions._E[5].Y := 0.24;
	positions._E[6].X := 2 * 0.24 - 0.06;
	positions._E[6].Y := 0.24 + 4 * 0.12;
	positions._E[7].X := 2 * 0.24;
	positions._E[7].Y := 0.24 + 2 * 0.12;
	
	
	positions._I[0].X := 0.48;
	positions._I[0].Y := 0.30;
	positions._I[1].X := 0.36;
	positions._I[1].Y := 0.30;
	positions._I[2].X := 0.60;
	positions._I[2].Y := 0.30;
	positions._I[3].X := 0.48;
	positions._I[3].Y := 0.66;
	positions._I[4].X := 0.36;
	positions._I[4].Y := 0.66;
	positions._I[5].X := 0.60;	
	positions._I[5].Y := 0.66;
	positions._I[6].X := 0.48;
	positions._I[6].Y := 0.42;
	positions._I[7].X := 0.48;
	positions._I[7].Y := 0.54;

	positions._N[0].X := 0.30;
	positions._N[0].Y := 0.30;
	positions._N[1].X := 0.30;
	positions._N[1].Y := 0.48;
	positions._N[2].X := 0.30;
	positions._N[2].Y := 0.66;
	positions._N[3].X := 0.42;
	positions._N[3].Y := 0.54;
	positions._N[4].X := 0.54;
	positions._N[4].Y := 0.42;
	positions._N[5].X := 0.66;	
	positions._N[5].Y := 0.30;
	positions._N[6].X := 0.66;
	positions._N[6].Y := 0.48;
	positions._N[7].X := 0.66;
	positions._N[7].Y := 0.66;

	positions._W[0].X := 0.24;
	positions._W[0].Y := 0.96 - 0.66;

	positions._W[1].X := 0.29;
	positions._W[1].Y := 0.96 - 0.48;

	positions._W[2].X := 0.34;
	positions._W[2].Y := 0.96 - 0.30;

	positions._W[3].X := 0.42;
	positions._W[3].Y := 0.96 - 0.42;
	positions._W[4].X := 0.54;
	positions._W[4].Y := 0.96 - 0.42;

	positions._W[5].X := 0.62;	
	positions._W[5].Y := 0.96 - 0.30;

	positions._W[6].X := 0.67;
	positions._W[6].Y := 0.96 - 0.48;

	positions._W[7].X := 0.72;
	positions._W[7].Y := 0.96 - 0.66;
END_ACTION

ACTION acClearTargetQueues :
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		brsmemset(ADR(fb.Move6DQueue[i].Targets), 0, SIZEOF(fb.Move6DQueue[i].Targets));
		brsmemset(ADR(fb.MoveXYQueue[i].Targets), 0, SIZEOF(fb.MoveXYQueue[i].Targets));
	END_FOR;
	  
END_ACTION


ACTION acCyclicChannelHandling :
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		fb.ReadCyclicPosition[i].Enable := FALSE;
		shuttles[i].position.isValid := FALSE;
		
		fb.ReadCyclicForce[i].Enable := FALSE;
		shuttles[i].force.isValid := FALSE;
		
		fb.MoveCyclicPosition[i].Enable := FALSE;
		shuttles[i].moveCyclicActive := FALSE;
	END_FOR;
	
	// set global statuses so states can use them if required
	cyclic.allPositionsValid := TRUE;
	cyclic.allForceValuesValid := TRUE;
	cyclic.allControlReady := TRUE;
	cyclic.allChannelsReleased := FALSE;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		IF NOT fb.ReadCyclicPosition[i].Valid THEN 
			cyclic.allPositionsValid := FALSE; 
		END_IF;
		
		IF NOT fb.ReadCyclicForce[i].Valid THEN 
			cyclic.allForceValuesValid := FALSE; 
		END_IF;
		
		IF NOT fb.MoveCyclicPosition[i].Valid THEN
			cyclic.allControlReady := FALSE;
		END_IF;
	END_FOR;
	
	CASE cyclic.mode OF
		a6dCYCLIC_DISABLED:
			// ---------------------------------------------------------------------------------			
			CASE local.actions.state.cyclicModeRequest OF
				a6dCYCLIC_READ_POSITION: 
					cyclic.mode := a6dCYCLIC_READ_POSITION;
				a6dCYCLIC_READ_FORCE:
					cyclic.mode := a6dCYCLIC_READ_FORCE;
				a6dCYCLIC_MOVE_POSITION:
					cyclic.mode := a6dCYCLIC_MOVE_POSITION;
			END_CASE;
			
		a6dCYCLIC_RELEASE_CHANNELS:
			// ---------------------------------------------------------------------------------
			cyclic.allChannelsReleased := TRUE;
			
			FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
				IF fb.ReadCyclicPosition[i].Busy OR fb.ReadCyclicForce[i].Busy OR fb.MoveCyclicPosition[i].Busy THEN
					cyclic.allChannelsReleased := FALSE;
				END_IF;
			END_FOR;
			
			IF cyclic.allChannelsReleased THEN
				cyclic.mode := a6dCYCLIC_DISABLED;
			END_IF;	
		
		a6dCYCLIC_READ_POSITION:
			// ---------------------------------------------------------------------------------
			IF local.actions.state.cyclicModeRequest <> a6dCYCLIC_READ_POSITION THEN
				cyclic.mode := a6dCYCLIC_RELEASE_CHANNELS;
			ELSE
				FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
					fb.ReadCyclicPosition[i].Enable := TRUE;	
					
					IF fb.ReadCyclicPosition[i].Valid THEN
						shuttles[i].position.value := fb.ReadCyclicPosition[i].CyclicPosition;
						shuttles[i].position.isValid := TRUE;
					END_IF;
				END_FOR;
			END_IF;
			
		a6dCYCLIC_READ_FORCE:
			// ---------------------------------------------------------------------------------
			IF local.actions.state.cyclicModeRequest <> a6dCYCLIC_READ_FORCE THEN
				cyclic.mode := a6dCYCLIC_RELEASE_CHANNELS;
			ELSE
				FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
					fb.ReadCyclicForce[i].Enable := TRUE;
					fb.ReadCyclicForce[i]();
				
					IF fb.ReadCyclicForce[i].Valid THEN
						shuttles[i].force.value := fb.ReadCyclicForce[i].CyclicForce;
						shuttles[i].force.isValid := TRUE;
					END_IF;
				END_FOR;
			END_IF;
			
		a6dCYCLIC_MOVE_POSITION:
			// ---------------------------------------------------------------------------------
			IF local.actions.state.cyclicModeRequest <> a6dCYCLIC_MOVE_POSITION THEN
				cyclic.mode := a6dCYCLIC_RELEASE_CHANNELS;
			ELSE
				FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
					fb.MoveCyclicPosition[i].Enable := TRUE;
					fb.MoveCyclicPosition[i]();
				
					IF fb.MoveCyclicPosition[i].Valid THEN
						shuttles[i].moveCyclicActive := TRUE;
					END_IF;
				END_FOR;
			END_IF;
	END_CASE;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		fb.ReadCyclicPosition[i].Shuttle := ADR(shuttles[i].Ref);
		fb.ReadCyclicPosition[i]();
		
		fb.ReadCyclicForce[i].Shuttle := ADR(shuttles[i].Ref);
		fb.ReadCyclicForce[i]();

		fb.MoveCyclicPosition[i].Shuttle := ADR(shuttles[i].Ref);
		fb.MoveCyclicPosition[i]();
	END_FOR;
	  
END_ACTION

ACTION acShuttleStatusPolling :
	
	shuttleStatus.allValid := TRUE;
			
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		IF (shuttles[i].Ref.controlif > 0) AND (NOT shuttles[i].status.isValid) THEN
			shuttleStatus.allValid := FALSE;
		END_IF;
	END_FOR;
	
	shuttleStatus.allIdle := TRUE;
	
	IF shuttleStatus.allValid THEN
		FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
			IF shuttles[i].status.state <> mcACP6D_SH_STATE_IDLING THEN
				shuttleStatus.allIdle := FALSE;
			END_IF;
		END_FOR;
	ELSE
		shuttleStatus.allIdle := FALSE;
	END_IF;
	
	CASE shuttleStatus.state OF
		0:
			// ---------------------------------------------------------------------------------
			CASE task.Output.AssemblyInfo.AssemblyState OF
				mcACP6D_INVALID_CONFIGURATION, 
				mcACP6D_STARTUP:
					// Wait
				ELSE
					shuttleStatus.state := 10;
					shuttleStatus.index := 0;
			END_CASE;
			
			FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
				brsmemset(ADR(shuttles[i].status), 0, SIZEOF(shuttles[i].status));
			END_FOR;
			
			fb.ShGetInfo.Execute := FALSE;
		
		10:
			// ---------------------------------------------------------------------------------
			CASE task.Output.AssemblyInfo.AssemblyState OF
				mcACP6D_INVALID_CONFIGURATION:
				mcACP6D_STARTUP:
					shuttleStatus.state := 0;
			END_CASE;

			fb.ShGetInfo.Execute := TRUE;
		
			IF fb.ShGetInfo.Done THEN
				shuttles[shuttleStatus.index].status.isValid := TRUE;
				shuttles[shuttleStatus.index].status.state := fb.ShGetInfo.ShuttleInfo.State;
				shuttleStatus.index := shuttleStatus.index + 1;
						
			ELSIF fb.ShGetInfo.Error THEN
				brsmemset(ADR(shuttles[shuttleStatus.index].status), 0, SIZEOF(shuttles[shuttleStatus.index].status));
				shuttleStatus.index := shuttleStatus.index + 1;	
			END_IF;			 
	END_CASE;
	
	IF shuttleStatus.index > gMAX_INDEX_SHUTTLE THEN
		shuttleStatus.index := 0;
	END_IF;
	
	fb.ShGetInfo.Shuttle := ADR(shuttles[shuttleStatus.index].Ref);
	fb.ShGetInfo();
			
END_ACTION

ACTION acMoveQueueStatusHandling:
	
	queueStatus.executing := FALSE;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		IF fb.MoveQueue[i].Execute THEN
			queueStatus.executing := TRUE;
		END_IF;
	END_FOR;
	
	IF NOT queueStatus.executing THEN
		queueStatus.allDone := FALSE;
		queueStatus.allAcknowledge := FALSE;
		queueStatus.error := FALSE;
	ELSE
		queueStatus.allDone := TRUE;
		queueStatus.allAcknowledge := TRUE;
		queueStatus.error := FALSE;

		FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
			IF fb.MoveQueue[i].Execute AND (NOT fb.MoveQueue[i].Done) THEN
				queueStatus.allDone := FALSE;
			END_IF;
			
			IF fb.MoveQueue[i].Execute AND (NOT fb.MoveQueue[i].Acknowledge) THEN
				queueStatus.allAcknowledge := FALSE;
			END_IF;
			
			IF fb.MoveQueue[i].Execute AND fb.MoveQueue[i].Error THEN
				queueStatus.error := TRUE;
				queueStatus.errorID := fb.MoveQueue[i].ErrorID;
			END_IF;
		END_FOR;
	END_IF;
	
END_ACTION

