PROGRAM _INIT
	
    // Access the task interface
	task ACCESS ADR(gAcp6D);

	// Check for simulator
	task.IsSimulated := DiagCpuIsSimulated();
	
	gCommInput;
	gCommOutput;
	gAssembly6D_1;
	
	// Fill in index of the shuttle element for easier access later on
	FOR i:=0 TO gMAX_INDEX_SHUTTLE DO
		local.shuttleOrder[i] := DINT_TO_UINT(i);  
	END_FOR;
	
	acInitializePositions;
		
	moveQueueParamDefault.acceleration := 15.0;
	moveQueueParamDefault.acceleration_rotary := 0.1;
	moveQueueParamDefault.velocity_rotary := 0.1;
	moveQueueParamDefault.velocity_short := 0.1;
	moveQueueParamDefault.velocity_xy := 2.0;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		fb.MoveQueue[i].Parameters := moveQueueParamDefault;
	END_FOR;
	
	// soundwave liikerata
	// Victory dance logiikka aalto z-aalto aalto -> vanhoihin asemmin -> keskellä spin ja z pomppuja -> kehällä arc movella kiertoradalle ja muutamak ierros ympäri -> paririviin keinahtelemaan ja kumartamaan pelaajalle
	// pelilogiikka mainiin loppuun
	// warm restartg mainiin
	// pelikäyttöliittymäsekvenssi
	// Circular shuffle loppuun -> group -> arc move -> sun planet -> asyncillä user selectiin
	// sun plenet tarkistus ja fb
	// pyöristyksiä liikeratoihin simple suffleen
	// circular shufflen loppuosa
	// win asento
	
	
END_PROGRAM
	
PROGRAM _CYCLIC	
    // Access task interface
    // =================================================================================================================
	task ACCESS ADR(gAcp6D);
	
	test.SunShuttle := ADR(shuttles[4].Ref);
	test.PlanetShuttles[0] := shuttles[3].Ref;
	test();
	
	// Inputs
	// =================================================================================================================
	IF NOT task.Input.Force THEN
		task.Input.Command.MoveTo.Home := gMain.Output.Command.br6dHome;
		task.Input.Command.Shuffle.Circular := gMain.Output.Command.br6dcircularShuffle;
		task.Input.Command.FindPayload := gMain.Output.Command.br6dFindPayload;
		task.Input.Command.Victory := gMain.Output.Command.br6dLoseDance;
		task.Input.Command.ForceReset := gMain.Output.Command.br6dReset;
		task.Input.Command.SelectShuttle := gMain.Output.Command.br6dSelectShuttle;
		task.Input.Command.Shuffle.Simple := gMain.Output.Command.br6dSimpleShuffle;
		task.Input.Command.Victory := gMain.Output.Command.br6dWinDance;
	END_IF

	// Task state machine
	// =================================================================================================================
	CASE task.State OF
		ACP6D_INITIALIZE:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Wait assembly to boot up';
					// ---------------------------------------------------------------------------------
					local.actions.state.cyclicModeRequest := a6dCYCLIC_DISABLED;
					
					fb.AssemblyReadInfo.Enable := TRUE;
					//Wait for the startup phase to be finished
					IF fb.AssemblyReadInfo.Valid THEN
						IF (fb.AssemblyReadInfo.AssemblyInfo.AssemblyState = mcACP6D_ERRORSTOP) THEN
							task.State := ACP6D_ERROR;
						ELSIF (fb.AssemblyReadInfo.AssemblyInfo.AssemblyState <> mcACP6D_STARTUP) THEN
							task.SubState := 10;
						END_IF
					END_IF
					
				10:
					task.StateInfo := 'Power off assembly';
					// ---------------------------------------------------------------------------------	
					local.actions.substate.assemblyPowerOff := TRUE;
					
					IF fb.AssemblyPowerOff.Done THEN
						task.SubState := 20;
					ELSIF fb.AssemblyPowerOff.Error THEN
						task.Error.Code := fb.AssemblyPowerOff.ErrorID;
						task.State := ACP6D_ERROR;
					END_IF
				
				20:
					task.StateInfo := 'Power on assembly';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brsmemset(ADR(shuttles), 0, SIZEOF(shuttles));
					END_IF;
					
					local.actions.substate.assemblyPowerOn := TRUE;
					
					IF fb.AssemblyPowerOn.Done THEN
						task.SubState := 100;
					ELSIF fb.AssemblyPowerOn.Error THEN
						task.Error.Code := fb.AssemblyPowerOn.ErrorID;
						task.State := ACP6D_ERROR;
					END_IF
				
				100:
					task.StateInfo := 'Read shuttle info - Read';
					// ---------------------------------------------------------------------------------	
					local.actions.state.assemblyGetShuttles := TRUE;
						
					IF fb.AssemblyGetShuttle.Valid THEN
						task.Output.TotalShuttleCount := fb.AssemblyGetShuttle.TotalCount;
						local.actions.state.assemblyGetNextShuttle := FALSE;
		
						IF (fb.AssemblyGetShuttle.TotalCount = 0) THEN
							task.SubState := 1000;
							RETURN;
						END_IF;
							
						// Read shuttle information
						// Prevent access to wrong memory area
						i := LIMIT(0, UINT_TO_DINT(fb.AssemblyGetShuttle.TotalCount - fb.AssemblyGetShuttle.RemainingCount - 1), gMAX_INDEX_SHUTTLE);
						
						shuttles[i].ID := fb.AssemblyGetShuttle.AdditionalInfo.ShuttleID;
						shuttles[i].Ref := fb.AssemblyGetShuttle.Shuttle;
						shuttles[i].index := i;
						
						task.SubState := 110;
					END_IF
					
				110:
					task.StateInfo := 'Read shuttle info - Get next';
					// ---------------------------------------------------------------------------------
					IF (fb.AssemblyGetShuttle.RemainingCount > 0) THEN
						local.actions.state.assemblyGetNextShuttle := TRUE;
						task.SubState := 100;
					ELSE
						IF local.virtualShuttleCount >= MAX_NUM_SHUTTLE_VIRTUAL THEN
	  						task.State := ACP6D_COMMAND_DONE; 
						ELSE
							task.SubState := 200;
						END_IF;
					END_IF
					
				200:
					task.StateInfo := 'Create virtual shuttle';
					// ---------------------------------------------------------------------------------
					local.actions.substate.createShuttleVirtual := TRUE;
					
					IF fb.virtualShCreate.Done THEN
						shuttlesVirtual[local.virtualShuttleCount] := fb.virtualShCreate.VirtualShuttle;
						local.virtualShuttleCount := local.virtualShuttleCount + 1;
						task.SubState := 210;
					ELSIF fb.virtualShCreate.Error THEN
						task.Error.Code := fb.virtualShCreate.ErrorID;
						task.State := ACP6D_ERROR;
					END_IF
			
				210:
					task.StateInfo := 'Check if enough virtual shuttles have been created';
					// ---------------------------------------------------------------------------------
					IF local.virtualShuttleCount >= MAX_NUM_SHUTTLE_VIRTUAL THEN
						task.State := ACP6D_COMMAND_DONE; 
					ELSE
						task.SubState := 200;
					END_IF;
	
				1000:
					task.StateInfo := 'No shuttles';
				// ---------------------------------------------------------------------------------
			
			END_CASE;
				
		ACP6D_IDLE:	
			task.StateInfo := 'Waiting for command';
			task.Output.Status.Initialized := TRUE;
			
			IF task.Input.Command.Reinitialize THEN
				task.State := ACP6D_INITIALIZE;
				
			ELSIF task.Input.Command.StartDemoMode THEN
				task.State := ACP6D_DEMO;
			
			ELSIF task.Input.Command.FindPayload THEN
				task.State := ACP6D_FIND_PAYLOAD;
				
			ELSIF task.Input.Command.SelectShuttle THEN
				task.State := ACP6D_SELECT_SHUTTLE;
			
			ELSIF task.Input.Command.StopAll THEN
				task.State := ACP6D_STOP_ALL;
				
			ELSIF task.Input.Command.ForceReset THEN
				task.State := ACP6D_FORCE_RESET;
				
			ELSIF task.Input.Command.Victory THEN
				task.State := ACP6D_VICTORY;
			
			ELSIF task.Input.Command.Lose THEN
				task.State := ACP6D_LOSE;
				
			ELSIF task.Input.Command.Animate THEN
				task.State := ACP6D_ANIMATE;
			
				// Move commands	
			ELSIF task.Input.Command.MoveTo.Home THEN
				local.targetPos := positions.home;
				task.State := ACP6D_MOVE_TO;	
				
			ELSIF task.Input.Command.MoveTo.User THEN
				local.targetPos := positions.user;
				task.State := ACP6D_MOVE_TO;
				
			ELSIF task.Input.Command.MoveTo.Dance THEN
				local.targetPos := positions.dance;
				task.State := ACP6D_MOVE_TO;
				
			ELSIF task.Input.Command.MoveTo.Clockface THEN
				local.targetPos := positions.clockface;
				task.State := ACP6D_MOVE_TO;
				
			ELSIF task.Input.Command.MoveTo.Pickup THEN
				local.targetPos := positions.pickup;
				task.State := ACP6D_MOVE_TO;
				
			ELSIF task.Input.Command.MoveTo.Shuffle THEN
				local.targetPos := positions.shuffle;
				task.State := ACP6D_MOVE_TO;
			
			ELSIF task.Input.Command.MoveTo.Side THEN
				local.targetPos := positions.side;
				task.State := ACP6D_MOVE_TO;
				
			// Shuffle commands	
			ELSIF task.Input.Command.Shuffle.Simple THEN
				task.State := ACP6D_SHUFFLE_SIMPLE;
				
			ELSIF task.Input.Command.Shuffle.Circular THEN
				task.State := ACP6D_SHUFFLE_CIRCULAR;
			END_IF;
			
		ACP6D_DEMO:
			task.StateInfo := 'Running Acopos 6D feature demo';
			// ---------------------------------------------------------------------------------
			IF task.Input.Command.StopDemoMode THEN
				/// ..... Tähän kohtaan sit oma käsittely ja kun on demo taas inaktiviisiena niin hyppy COMMAND_DONE stateen
//				//IF FEATUREMODE INACTIEV THEN
//					task.State := ACP6D_COMMAND_DONE;
//				END_IF
			END_IF;
				
			//task.Output.Status.DemoModeActive := // MIKÄLIE LOGIIKKA ET MILLON ON PÄÄLLÄ!
		
		ACP6D_LOSE:
			CASE task.SubState OF
				0:
					task.StateInfo := 'L';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN	
						// Configure shuttle targets 
						fb.MoveInPlaneAsync.Parameters.Velocity := 2;
						fb.MoveInPlaneAsync.Parameters.Acceleration := 14;
							
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_UNSORTED;
							
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO	
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[i].Ref);
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].X := positions._L[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Y := positions._L[i].Y;
						END_FOR;
					END_IF;
						
					local.actions.substate.moveInPlaneAsync := TRUE;
						
					IF fb.MoveInPlaneAsync.Done THEN
						task.SubState := 10;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				10:
					task.StateInfo := 'Wait';
					// ---------------------------------------------------------------------------------
					local.actions.substate.delay := TRUE;
					fb.TON_delay.PT := T#0.5s;

					IF fb.TON_delay.Q THEN
						task.SubState := 20;
					END_IF;
				
				20:
					task.StateInfo := 'O';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN	
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_UNSORTED;
							
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO	
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[i].Ref);
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].X := positions._O[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Y := positions._O[i].Y;
						END_FOR;
					END_IF;
						
					local.actions.substate.moveInPlaneAsync := TRUE;
						
					IF fb.MoveInPlaneAsync.Done THEN
						task.SubState := 30;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				30:
					task.StateInfo := 'Wait';
					// ---------------------------------------------------------------------------------
					local.actions.substate.delay := TRUE;
					fb.TON_delay.PT := T#0.5s;

					IF fb.TON_delay.Q THEN
						task.SubState := 40;
					END_IF;	
					
				40:
					task.StateInfo := 'S';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN		
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_UNSORTED;
							
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO	
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[i].Ref);
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].X := positions._S[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Y := positions._S[i].Y;
						END_FOR;
					END_IF;
						
					local.actions.substate.moveInPlaneAsync := TRUE;
						
					IF fb.MoveInPlaneAsync.Done THEN
						task.SubState := 50;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
					
				50:
					task.StateInfo := 'Wait';
					// ---------------------------------------------------------------------------------
					local.actions.substate.delay := TRUE;
					fb.TON_delay.PT := T#0.5s;

					IF fb.TON_delay.Q THEN
						task.SubState := 60;
					END_IF;	
				
				60:
					task.StateInfo := 'E';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN						
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_UNSORTED;
							
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO	
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[i].Ref);
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].X := positions._E[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Y := positions._E[i].Y;
						END_FOR;
					END_IF;
						
					local.actions.substate.moveInPlaneAsync := TRUE;
						
					IF fb.MoveInPlaneAsync.Done THEN
						task.SubState := 70;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				70:
					task.StateInfo := 'Wait';
					// ---------------------------------------------------------------------------------
					local.actions.substate.delay := TRUE;
					fb.TON_delay.PT := T#2s;

					IF fb.TON_delay.Q THEN
						task.State := ACP6D_COMMAND_DONE;
					END_IF;	
				
			END_CASE;
			
		ACP6D_STOP_ALL:
			task.StateInfo := 'Stopping all shuttles';
			// ---------------------------------------------------------------------------------
			local.actions.substate.assemblyStop := TRUE;
			
			IF fb.assemblyStop.Done THEN
				task.State := ACP6D_COMMAND_DONE;
			ELSIF fb.assemblyStop.Done THEN
				task.Error.Code := fb.assemblyStop.ErrorID;
				task.State := ACP6D_COMMAND_ERROR;
			END_IF;
			
		ACP6D_FORCE_RESET:
			task.StateInfo := 'Stopping all shuttles';
			// ---------------------------------------------------------------------------------
			local.actions.substate.assemblyStop := TRUE;
			
			IF fb.assemblyStop.Done THEN
				task.State := ACP6D_INITIALIZE;
			ELSIF fb.assemblyStop.Done THEN
				task.Error.Code := fb.assemblyStop.ErrorID;
				task.State := ACP6D_COMMAND_ERROR;
			END_IF;
			
			
		ACP6D_MOVE_TO:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Make sure assembly in correct state';
					// ---------------------------------------------------------------------------------
					task.SubState := 10;
				
				10:
					task.StateInfo := 'Move shuttles to target position';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuffle(ADR(local.shuttleOrder));
						
						// Configure shuttle targets 
						fb.MoveInPlaneAsync.Parameters.Velocity := 2;
						fb.MoveInPlaneAsync.Parameters.Acceleration := 15;
						
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_SORTED;
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							x := local.shuttleOrder[i];
							
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[i].Ref);
							fb.MoveInPlaneAsync.Parameters.AsyncPar[x].X := local.targetPos[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[x].Y := local.targetPos[i].Y;
						END_FOR;
					END_IF;
					
					local.actions.substate.moveInPlaneAsync := TRUE;
					
					IF fb.MoveInPlaneAsync.Done THEN
						task.State := ACP6D_COMMAND_DONE;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
			END_CASE;
			
		ACP6D_FIND_PAYLOAD:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Initialize';
					// ---------------------------------------------------------------------------------	
					// Wait a moment before starting the force reading process so the movement has totally stopped
					local.actions.substate.delay := TRUE;
					fb.TON_delay.PT := T#1s;
					
					local.actions.state.cyclicModeRequest := a6dCYCLIC_READ_FORCE;
					
					// Also wait until all force readings are valid
					IF fb.TON_delay.Q AND cyclic.allForceValuesValid THEN
						task.SubState := 20;
					END_IF;
				
				20:
					task.StateInfo := 'Calculcate average Fz for shuttles';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						local.measurement_index := 0;
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							shuttle ACCESS ADR(shuttles[i]);
							brsmemset(ADR(shuttle.force.readings), 0, SIZEOF(shuttle.force.readings));
						END_FOR;
					END_IF;
										
					// Check if enough measurements have been recorder already
					IF local.measurement_index >= gMAX_INDEX_MEASUREMENT THEN
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							shuttle ACCESS ADR(shuttles[i]);
							
							shuttle.force.Z_avg := 0;
						
							FOR x := 0 TO gMAX_INDEX_MEASUREMENT DO
								shuttle.force.Z_avg := shuttle.force.Z_avg + shuttle.force.readings[x].Fz;
							END_FOR;
							
							shuttle.force.Z_avg := shuttle.force.Z_avg / MEASUREMENT_COUNT;
						END_FOR;
						task.SubState := 30;
				
					ELSIF shuttles[0].force.readings[local.measurement_index].Fz <> fb.ReadCyclicForce[0].CyclicForce.Fz THEN
						// Wait for next new value until measurement index is increased
						// Assume all channels received updates when first index of the cyclic force function block has new values
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							// Record received force values
							shuttle ACCESS ADR(shuttles[i]);
							shuttle.force.readings[local.measurement_index] := fb.ReadCyclicForce[shuttle.index].CyclicForce;
						END_FOR;
						
						local.measurement_index := local.measurement_index + 1;
					END_IF;
					
				30:
					task.StateInfo := 'Find which shuttle holds the payload';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						local.Fz_highest := 0;
					END_IF;
					
					FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
						shuttle ACCESS ADR(shuttles[i]);
						
						IF shuttle.force.Z_avg > local.Fz_highest THEN
							local.Fz_highest := shuttle.force.Z_avg;
							task.Output.ShuttleWithPayload.index := i;
						END_IF;
					END_FOR;
				
					task.SubState := 40;
					
				40:
					task.StateInfo := 'Indicate which has payload';
					// ---------------------------------------------------------------------------------
					shuttle ACCESS ADR(shuttles[task.Output.ShuttleWithPayload.index]);
					refMoveQueue ACCESS ADR(fb.MoveQueue[shuttle.index]);
					
					IF task.OnStateEntry THEN
						refMoveQueue.Parameters.acceleration := 10;
						refMoveQueue.Parameters.velocity_short := 0.02;
						refMoveQueue.Parameters.velocity_xy := 1.0;
						
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						
						refMoveQueue.Commands := commandQueue;
					END_IF;
				
					shuttle.command.moveQueue := TRUE;
					
					IF refMoveQueue.Done THEN
						task.State := ACP6D_COMMAND_DONE;
					ELSIF refMoveQueue.Error THEN
						task.Error.Code := refMoveQueue.ErrorID;
						task.State := ACP6D_COMMAND_ERROR;	
					END_IF;
			END_CASE
			
		ACP6D_SELECT_SHUTTLE:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Move shuttles to the front of the table';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						local.selectedCount := brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.24, 1, 1, TRUE);
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							fb.MoveQueue[i].Parameters.velocity_short := 0.05;
						END_FOR;
						
						AddCommand6D_wait(ADR(commandQueue), 0);
						
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						
						AddCommand6D_xy(ADR(commandQueue), sY, 0, 0.900, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
						
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.003, 0, 0.1, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_Rxyz(ADR(commandQueue), sRx, -0.03, 0, 0, 0.3, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_Rxyz(ADR(commandQueue), sRx, 0.00, 0, 0, 0.3, mcACP6D_MOVE_ABSOLUTE);
																		
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						
						IF local.selectedCount > 0 THEN
							FOR i := 0 TO local.selectedCount - 1 DO
								fb.MoveQueue[selected1[i].index].Commands := commandQueue;
								fb.MoveQueue[selected1[i].index].Commands[0].waitTime := random.delays[i];
								shuttles[selected1[i].index].command.moveQueue := TRUE;
							END_FOR;
						END_IF;
					END_IF;
						
					IF queueStatus.allDone THEN
						task.SubState := 10;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
					
				10:
					task.StateInfo := 'Say hello to the player';
					// ---------------------------------------------------------------------------------	
					IF task.OnStateEntry THEN
	  					local.selectedCount := brfiShuttleSelect(ADR(shuttles), ADR(selected1), 1, 1, 0, 0.240 * 3, TRUE);
						
						AddCommand6D_wait(ADR(commandQueue), 0);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_wait(ADR(commandQueue), 0.1);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						
						IF local.selectedCount > 0 THEN
							FOR i := 0 TO local.selectedCount - 1 DO
								fb.MoveQueue[selected1[i].index].Parameters.velocity_short := 0.03;
							
								fb.MoveQueue[selected1[i].index].Commands := commandQueue;
								fb.MoveQueue[selected1[i].index].Commands[0].waitTime := i * 0.1;
								shuttles[selected1[i].index].command.moveQueue := TRUE;
							END_FOR;
						END_IF;
					END_IF;
					
					IF queueStatus.allDone THEN
						task.SubState := 20;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				20:
					task.StateInfo := 'Start force reading';
					// ---------------------------------------------------------------------------------
					local.actions.state.cyclicModeRequest := a6dCYCLIC_READ_FORCE;
					
					IF cyclic.allForceValuesValid THEN
						task.SubState := 30;
					END_IF;
				
				30:
					task.StateInfo := 'Wait user to select shuttle';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							shuttle ACCESS ADR(shuttles[i]);
							shuttle.force.Fz_baseline := shuttle.force.value.Fz;
						END_FOR;	
					END_IF
				
					FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
						shuttle ACCESS ADR(shuttles[i]);
						// Detect shuttle press from force increase over treshold from baseline
						IF shuttle.force.value.Fz > (shuttle.force.Fz_baseline + 3.0) THEN
							task.SubState := 40;
							task.Output.ShuttleUserSelected.index := i;
						END_IF;
					END_FOR;	
									
				40:
					task.StateInfo := 'Move selected shuttle';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						shuttle ACCESS ADR(shuttles[task.Output.ShuttleUserSelected.index]);
						refMoveQueue ACCESS ADR(fb.MoveQueue[shuttle.index]);
						
						refMoveQueue.Parameters.velocity_xy := 1.5;
						refMoveQueue.Parameters.acceleration := 5.0;
						
						AddCommand6D_xy(ADR(commandQueue), sX + sY, 0.0, -0.2, 0.5, 0.5, 0, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);
						AddCommand6D_xy(ADR(commandQueue), sX + sY, positions.pickup[0].X, positions.pickup[0].Y, 0, 15, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
					
						refMoveQueue.Commands := commandQueue;
						
						shuttle.command.moveQueue := TRUE;
					END_IF;
						
					IF refMoveQueue.Done THEN
						task.SubState := 50;
					ELSIF refMoveQueue.Error THEN
						task.Error.Code := refMoveQueue.ErrorID;
						task.SubState := ACP6D_COMMAND_ERROR;
					END_IF;
				
				50:
					task.StateInfo := 'Move all other shuttles to pickup';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						// Configure shuttle targets 
						fb.MoveInPlaneAsync.Parameters.Velocity := 2;
						fb.MoveInPlaneAsync.Parameters.Acceleration := 15;
						
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_UNSORTED;
						
						x := 1;
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							IF i <> task.Output.ShuttleUserSelected.index THEN
								fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[i].Ref);
								fb.MoveInPlaneAsync.Parameters.AsyncPar[i].X := positions.pickup[x].X;
								fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Y := positions.pickup[x].Y;
								x := x + 1;
							END_IF;
						END_FOR;
					END_IF;
					
					local.actions.substate.moveInPlaneAsync := TRUE;
					
					IF fb.MoveInPlaneAsync.Done THEN
						task.SubState := 100;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				100:
					task.StateInfo := 'Transfer back to reading position values';
					// ---------------------------------------------------------------------------------
					local.actions.state.cyclicModeRequest := a6dCYCLIC_READ_POSITION;
					
					IF cyclic.allPositionsValid THEN
						task.State := ACP6D_COMMAND_DONE;
					END_IF;
					
			END_CASE;
			
		ACP6D_SHUFFLE_SIMPLE:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Move shuttles to start position';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuffle(ADR(local.shuttleOrder));
						
						brsmemset(ADR(shuffle), 0, SIZEOF(shuffle));
						
						// Configure shuttle targets 
						fb.MoveInPlaneAsync.Parameters.Velocity := 2;
						fb.MoveInPlaneAsync.Parameters.Acceleration := 15;
						
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_SORTED;
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							x := local.shuttleOrder[i];
							IF x = shuttles[task.Output.ShuttleWithPayload.index].index THEN
	  							shuffle.payloadPos := i;
							END_IF;
							
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[x].Ref);
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].X := positions.shuffle_simple[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Y := positions.shuffle_simple[i].Y;
						END_FOR;
						
						shuffle.randNum := RandValueDINT(0, 3);
						
						IF shuffle.payloadPos > 3 THEN
							fb.MoveInPlaneAsync.Parameters.AsyncPar[shuffle.payloadPos].Shuttle := fb.MoveInPlaneAsync.Parameters.AsyncPar[shuffle.randNum].Shuttle;	
							fb.MoveInPlaneAsync.Parameters.AsyncPar[shuffle.randNum].Shuttle := ADR(shuttles[task.Output.ShuttleWithPayload.index].Ref);	
						END_IF;
					
					END_IF;
					
					local.actions.substate.moveInPlaneAsync := TRUE;
					
					IF fb.MoveInPlaneAsync.Done THEN
						task.SubState := 10;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
					
				10:
					task.StateInfo := 'Prepare for shuffle';
					// ---------------------------------------------------------------------------------
					brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.480, 1, 1, TRUE);
					fb.MoveQueue[selected1[0].index].Parameters := moveQueueParamDefault;
					fb.MoveQueue[selected1[1].index].Parameters := moveQueueParamDefault;
					fb.MoveQueue[selected1[2].index].Parameters := moveQueueParamDefault;
					fb.MoveQueue[selected1[3].index].Parameters := moveQueueParamDefault;
					shuffle.sequence := random.shuffleSequence; 
					task.SubState := 20;
					
				20:
					task.StateInfo := 'Select next shuffle sequence';
					// ---------------------------------------------------------------------------------
					IF shuffle.step > gMAX_INDEX_SHUFFLE THEN
						task.SubState := 200;
					ELSE
						shuffle.invertedMove := shuffle.sequence[shuffle.step] < 0;
						shuffle.invertedDirection := SEL(shuffle.invertedMove, 1, -1);	
						task.SubState := 100 + ABS(shuffle.sequence[shuffle.step]);
						shuffle.step := shuffle.step + 1;
					END_IF;
					
				
				100:
					task.StateInfo := 'Sides shift rotate';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.480, 1, 1, TRUE);
						
						IF shuffle.invertedMove THEN
							AddCommand6D_arcAngularCW(ADR(fb.MoveQueue[selected1[0].index].Commands),  0.12, 0, brmPI, 0, 10, 0, mcACP6D_MOVE_RELATIVE);  
							AddCommand6D_arcAngularCW(ADR(fb.MoveQueue[selected1[1].index].Commands), -0.12, 0, brmPI, 0, 10, 0, mcACP6D_MOVE_RELATIVE);  

							AddCommand6D_arcAngularCW(ADR(fb.MoveQueue[selected1[2].index].Commands), 0.12, 0, brmPI, 0, 10, 0, mcACP6D_MOVE_RELATIVE);  
							AddCommand6D_arcAngularCW(ADR(fb.MoveQueue[selected1[3].index].Commands), -0.12, 0, brmPI, 0, 10, 0, mcACP6D_MOVE_RELATIVE);  
						ELSE
							AddCommand6D_arcAngularCCW(ADR(fb.MoveQueue[selected1[0].index].Commands),  0.12, 0, brmPI, 0, 10, 0, mcACP6D_MOVE_RELATIVE);  
							AddCommand6D_arcAngularCCW(ADR(fb.MoveQueue[selected1[1].index].Commands), -0.12, 0, brmPI, 0, 10, 0, mcACP6D_MOVE_RELATIVE);  

							AddCommand6D_arcAngularCCW(ADR(fb.MoveQueue[selected1[2].index].Commands), 0.12, 0, brmPI, 0, 10, 0, mcACP6D_MOVE_RELATIVE);  
							AddCommand6D_arcAngularCCW(ADR(fb.MoveQueue[selected1[3].index].Commands), -0.12, 0, brmPI, 0, 10, 0, mcACP6D_MOVE_RELATIVE);  	
						END_IF;
					END_IF;
				
					shuttles[selected1[0].index].command.moveQueue := TRUE;
					shuttles[selected1[1].index].command.moveQueue := TRUE;
					shuttles[selected1[2].index].command.moveQueue := TRUE;
					shuttles[selected1[3].index].command.moveQueue := TRUE;
					
					IF queueStatus.allDone THEN
						task.SubState := 20;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				101:
					task.StateInfo := 'Mid shift rotate';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.480, 1, 1, TRUE);
					
						IF shuffle.invertedMove THEN
							AddCommand6D_arcAngularCW(ADR(commandQueue), 2 * 0.24, 3 * 0.24, brmPI, 0, 10, 0, mcACP6D_MOVE_ABSOLUTE);  
						
							fb.MoveQueue[selected1[1].index].Commands := commandQueue;
							fb.MoveQueue[selected1[2].index].Commands := commandQueue;
						ELSE
							AddCommand6D_arcAngularCCW(ADR(commandQueue), 2 * 0.24, 3 * 0.24, brmPI, 0, 10, 0, mcACP6D_MOVE_ABSOLUTE);  
						
							fb.MoveQueue[selected1[1].index].Commands := commandQueue;
							fb.MoveQueue[selected1[2].index].Commands := commandQueue;	
						END_IF;	
					END_IF;
				
					shuttles[selected1[1].index].command.moveQueue := TRUE;
					shuttles[selected1[2].index].command.moveQueue := TRUE;
						
					IF queueStatus.allDone THEN
						task.SubState := 20;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				102:
					task.StateInfo := 'Sides shift';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.480, 1, 1, TRUE);
					
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 0, shuffle.invertedDirection  * -0.120, 0, 0, 0, pathY_X, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 3 * 0.240, 0, 0, 0, 0, pathY_X, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 0, shuffle.invertedDirection * 0.120, 0, 0, 0, pathY_X, 0, mcACP6D_MOVE_RELATIVE);  
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, 0, shuffle.invertedDirection  * 0.120, 0, 0, 0, pathY_X, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, -3 * 0.240, 0, 0, 0, 0, pathY_X, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, 0, shuffle.invertedDirection  * -0.120, 0, 0, 0, pathY_X, 0, mcACP6D_MOVE_RELATIVE);  
					END_IF;
				
					shuttles[selected1[0].index].command.moveQueue := TRUE;
					shuttles[selected1[3].index].command.moveQueue := TRUE;
					
					IF queueStatus.allDone THEN
						task.SubState := 20;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				103:
					task.StateInfo := 'Middle to outside shift';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.480, 1, 1, TRUE);
				
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 0.240, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, -0.240, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY, 0, shuffle.invertedDirection * 0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY, -0.240, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY, 0, shuffle.invertedDirection * -0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY, 0, shuffle.invertedDirection * 0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY, 0.240, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY, 0, shuffle.invertedDirection * -0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
					END_IF;
				
					shuttles[selected1[0].index].command.moveQueue := TRUE;
					shuttles[selected1[1].index].command.moveQueue := TRUE;
					shuttles[selected1[2].index].command.moveQueue := TRUE;
					shuttles[selected1[3].index].command.moveQueue := TRUE;
					
					IF queueStatus.allDone THEN
						task.SubState := 20;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				104:
					task.StateInfo := 'Twin shift';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.480, 1, 1, TRUE);
														
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 0, shuffle.invertedDirection * 0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY, 0, shuffle.invertedDirection * 0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 0.240, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY, 0.240, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 0, shuffle.invertedDirection * -0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY, 0, shuffle.invertedDirection * -0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY, 0, shuffle.invertedDirection * -0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, 0, shuffle.invertedDirection * -0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY, -0.240, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, -0.240, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY, 0, shuffle.invertedDirection * 0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, 0, shuffle.invertedDirection * 0.120, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
					END_IF;
				
					shuttles[selected1[0].index].command.moveQueue := TRUE;
					shuttles[selected1[1].index].command.moveQueue := TRUE;
					shuttles[selected1[2].index].command.moveQueue := TRUE;
					shuttles[selected1[3].index].command.moveQueue := TRUE;
					
					IF queueStatus.allDone THEN
						task.SubState := 20;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
					
				200:
					task.StateInfo := 'Star shift 1';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.480, 1, 1, TRUE);
														
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY,  0.360, 0.140, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY,  -0.360, -0.140, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY,  -0.020, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY,  0.020, 0, 0, 0, 0, pathY_X, 0.00, mcACP6D_MOVE_RELATIVE);  
					END_IF;
				
					shuttles[selected1[0].index].command.moveQueue := TRUE;
					shuttles[selected1[1].index].command.moveQueue := TRUE;
					shuttles[selected1[2].index].command.moveQueue := TRUE;
					shuttles[selected1[3].index].command.moveQueue := TRUE;
					
					IF queueStatus.allDone THEN
						task.SubState := 201;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
					
				201:
					task.StateInfo := 'Star shift 2';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						shuttle ACCESS ADR(shuttles[selected1[0].index]);
						
						shuffle.angle := brmPI_2 * RandValueDINT(3 * 4, 5 * 4);
						
						brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
						
						AddCommand6D_waitCmdLb(ADR(commandQueue), shuttle.ID, mcACP6D_SH_WAIT_CMDLB_START, 0, mcACP6D_SH_WAIT_CMDLB_REGULAR);
						AddCommand6D_arcAngularCW(ADR(commandQueue), 2 * 0.24, 3 * 0.24, shuffle.angle, 1.0, 15.0, 0, mcACP6D_MOVE_ABSOLUTE);  
						
						fb.MoveQueue[selected1[1].index].Commands := commandQueue;
						fb.MoveQueue[selected1[2].index].Commands := commandQueue;
						fb.MoveQueue[selected1[3].index].Commands := commandQueue;
					END_IF;
				
					shuttles[selected1[1].index].command.moveQueue := TRUE;
					shuttles[selected1[2].index].command.moveQueue := TRUE;
					shuttles[selected1[3].index].command.moveQueue := TRUE;
					
					IF fb.MoveQueue[selected1[1].index].Acknowledge AND fb.MoveQueue[selected1[2].index].Acknowledge AND fb.MoveQueue[selected1[3].index].Acknowledge THEN
						task.SubState := 202;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
					
				202:
					task.StateInfo := 'Star shift 3';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						shuttle ACCESS ADR(shuttles[selected1[0].index]);
												
						AddCommand6D_arcAngularCW(ADR(commandQueue), 2 * 0.24, 3 * 0.24, shuffle.angle, 1.0, 15.0, 0, mcACP6D_MOVE_ABSOLUTE);  
						
						fb.MoveQueue[selected1[0].index].Commands := commandQueue;
					END_IF;
				
					shuttles[selected1[0].index].command.moveQueue := TRUE;
					
					IF queueStatus.allDone THEN
						task.SubState := 203;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				203:
					task.StateInfo := 'Star shift end';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.480, 1, 1, TRUE);
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, positions.shuffle_simple[0].X, positions.shuffle_simple[0].Y, 0, 0, 0, pathDIRECT, 0.00, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY, positions.shuffle_simple[1].X, positions.shuffle_simple[1].Y, 0, 0, 0, pathDIRECT, 0.00, mcACP6D_MOVE_ABSOLUTE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY, positions.shuffle_simple[2].X, positions.shuffle_simple[2].Y, 0, 0, 0, pathDIRECT, 0.00, mcACP6D_MOVE_ABSOLUTE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, positions.shuffle_simple[3].X, positions.shuffle_simple[3].Y, 0, 0, 0, pathDIRECT, 0.00, mcACP6D_MOVE_ABSOLUTE);  
					END_IF;
				
					shuttles[selected1[0].index].command.moveQueue := TRUE;
					shuttles[selected1[1].index].command.moveQueue := TRUE;
					shuttles[selected1[2].index].command.moveQueue := TRUE;
					shuttles[selected1[3].index].command.moveQueue := TRUE;
					
					IF queueStatus.allDone THEN
						task.SubState := 204;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
						
						
				204:
					task.StateInfo := 'End of simple shuffle - move to select';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0.480, 1, 1, TRUE);
				
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, positions.user[2].X, positions.user[2].Y, 1.5, 0, 0, pathDIRECT, 0.00, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY, positions.user[3].X, positions.user[3].Y, 1.5, 0, 0, pathDIRECT, 0.00, mcACP6D_MOVE_ABSOLUTE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY, positions.user[4].X, positions.user[4].Y, 1.5, 0, 0, pathDIRECT, 0.00, mcACP6D_MOVE_ABSOLUTE);  
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, positions.user[5].X, positions.user[5].Y, 1.5, 0, 0, pathDIRECT, 0.00, mcACP6D_MOVE_ABSOLUTE);  
					END_IF;
		
					shuttles[selected1[0].index].command.moveQueue := TRUE;
					shuttles[selected1[1].index].command.moveQueue := TRUE;
					shuttles[selected1[2].index].command.moveQueue := TRUE;
					shuttles[selected1[3].index].command.moveQueue := TRUE;
			
					IF queueStatus.allDone THEN
						task.State := ACP6D_COMMAND_DONE;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;	
						
			END_CASE;
		
		ACP6D_SHUFFLE_CIRCULAR:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Move shuttles to start position';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuffle(ADR(local.shuttleOrder));
							
						// Configure shuttle targets 
						fb.MoveInPlaneAsync.Parameters.Velocity := 2;
						fb.MoveInPlaneAsync.Parameters.Acceleration := 15;
							
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_SORTED;
							
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							x := local.shuttleOrder[i];
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[x].Ref);
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].X := positions.clockface[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Y := positions.clockface[i].Y;
						END_FOR;
					END_IF;
						
					local.actions.substate.moveInPlaneAsync := TRUE;
						
					IF fb.MoveInPlaneAsync.Done THEN
						task.SubState := 200;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
	
				100:
					task.StateInfo := 'Add commands to queue';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						shuttle ACCESS ADR(shuttles[0]);
						
						shuffle.angle := (brmPI/8) * RandValueDINT(6 * 8, 9 * 8);
						
						brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
						
						AddCommand6D_waitCmdLb(ADR(commandQueue), shuttle.ID, mcACP6D_SH_WAIT_CMDLB_START, 0, mcACP6D_SH_WAIT_CMDLB_REGULAR);
						AddCommand6D_arcAngularCW(ADR(commandQueue), 0.48, 0.48, shuffle.angle, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE); 
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							fb.MoveQueue[i].Parameters := moveQueueParamDefault;
							fb.MoveQueue[i].Parameters.acceleration := 14.0;
						END_FOR;
						
						FOR i := 1 TO gMAX_INDEX_SHUTTLE DO
							fb.MoveQueue[i].Commands := commandQueue;
							shuttles[i].command.moveQueue := TRUE;
						END_FOR;
					END_IF
					
					IF queueStatus.allAcknowledge THEN
						task.SubState := 110;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				110:
					task.StateInfo := 'Wait to finish circular CW';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN						
						brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
						
						AddCommand6D_arcAngularCW(ADR(commandQueue), 0.48, 0.48, shuffle.angle, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE); 
						
						fb.MoveQueue[0].Commands := commandQueue;
						shuttles[0].command.moveQueue := TRUE;
					END_IF
					
					IF queueStatus.allDone THEN
						task.SubState := 120;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				120:
					task.StateInfo := 'Add commands to queue';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						shuttle ACCESS ADR(shuttles[0]);
						
						shuffle.angle := (brmPI/8) * RandValueDINT(6 * 8, 9 * 8);
						
						brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
						
						AddCommand6D_waitCmdLb(ADR(commandQueue), shuttle.ID, mcACP6D_SH_WAIT_CMDLB_START, 0, mcACP6D_SH_WAIT_CMDLB_REGULAR);
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0.48, 0.48, shuffle.angle, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE); 
						
						FOR i := 1 TO gMAX_INDEX_SHUTTLE DO
							fb.MoveQueue[i].Commands := commandQueue;
							shuttles[i].command.moveQueue := TRUE;
						END_FOR;
					END_IF
					
					IF queueStatus.allAcknowledge THEN
						task.SubState := 130;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				130:
					task.StateInfo := 'wait to finish circular CCW';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN						
						brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
						
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0.48, 0.48, shuffle.angle, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE); 
						
						fb.MoveQueue[0].Commands := commandQueue;
						shuttles[0].command.moveQueue := TRUE;
					END_IF
					
					IF queueStatus.allDone THEN
						task.SubState := 200;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				200:
					task.StateInfo := 'Move shuttles to kongo line';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuffle(ADR(local.shuttleOrder));
							
						// Configure shuttle targets 
						fb.MoveInPlaneAsync.Parameters.Velocity := 2;
						fb.MoveInPlaneAsync.Parameters.Acceleration := 15;
							
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_SORTED;
							
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							x := local.shuttleOrder[i];
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[x].Ref);
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].X := positions.kongo_lines[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Y := positions.kongo_lines[i].Y;
						END_FOR;
					END_IF;
						
					local.actions.substate.moveInPlaneAsync := TRUE;
						
					IF fb.MoveInPlaneAsync.Done THEN
						task.SubState := 210;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				210:
					task.StateInfo := 'Move shuttles to start position';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN						
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0, 2 * 0.240, 1, TRUE);
						brfiShuttleSelect(ADR(shuttles), ADR(selected2), 2 * 0.240, 0, 1, 1, TRUE);
						
						AddCommand6D_xy(ADR(commandQueue), sX, 0.240 + 0.120, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, 0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_xy(ADR(commandQueue), sX, -0.480, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, -0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE);
						AddCommand6D_xy(ADR(commandQueue), sX, 0.120, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);
						
						AddCommand6D_xy(ADR(commandQueue), sX, 0.240 + 0.120, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, 0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_xy(ADR(commandQueue), sX, -0.480, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, -0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE);
						
						// Stop to middle with absolute position
						AddCommand6D_xy(ADR(commandQueue), sX, 2 * 0.240, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
						
						AddCommand6D_xy(ADR(commandQueue), sX, 0.240, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, 0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_xy(ADR(commandQueue), sX, -0.480, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, -0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE);
						AddCommand6D_xy(ADR(commandQueue), sX, 0.120, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);
						
						AddCommand6D_xy(ADR(commandQueue), sX, 0.240 + 0.120, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, 0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_xy(ADR(commandQueue), sX, -0.480, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, -0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE);
						
						// Stop to middle with absolute position
						AddCommand6D_xy(ADR(commandQueue), sX, 2 * 0.240, 0, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
												
						FOR i := 0 TO 3 DO
							fb.MoveQueue[selected1[i].index].Commands := commandQueue;
							shuttles[selected1[i].index].command.moveQueue := TRUE;;
						END_FOR;
						
						brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
						
						AddCommand6D_xy(ADR(commandQueue), sX, -(0.240 + 0.120), 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, -0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_xy(ADR(commandQueue), sX, 0.4800, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, 0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE);
						AddCommand6D_xy(ADR(commandQueue), sX, -0.120, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);
						
						AddCommand6D_xy(ADR(commandQueue), sX, -(0.240 + 0.120), 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, -0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_xy(ADR(commandQueue), sX, 0.480, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, 0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE);
						
						// Stop middle
						AddCommand6D_xy(ADR(commandQueue), sX, 2 * 0.240, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
					
						AddCommand6D_xy(ADR(commandQueue), sX, -(0.240 + 0.120), 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, -0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_xy(ADR(commandQueue), sX, 0.4800, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, 0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE);
						AddCommand6D_xy(ADR(commandQueue), sX, -0.120, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);
						
						AddCommand6D_xy(ADR(commandQueue), sX, -(0.240 + 0.120), 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);  
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, -0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_xy(ADR(commandQueue), sX, 0.480, 0, 0, 0, 1, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE); 
						AddCommand6D_arcAngularCCW(ADR(commandQueue), 0, 0.060, brmPI, 0, 0, 1, mcACP6D_MOVE_RELATIVE);
						
						AddCommand6D_xy(ADR(commandQueue), sX, 2 * 0.240, 0, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
						
						FOR i := 0 TO 3 DO
							fb.MoveQueue[selected2[i].index].Commands := commandQueue;
							shuttles[selected2[i].index].command.moveQueue := TRUE;;
						END_FOR;
						
					END_IF
					
					IF queueStatus.allDone THEN
						task.SubState := 220;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				220:
					task.StateInfo := 'Move shuttles';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN						
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0, 4 * 0.240, 2 * 0.240, FALSE);
						brfiShuttleSelect(ADR(shuttles), ADR(selected2), 0, 2 * 0.240, 1, 1, FALSE);
												
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 0.120, 0, 0, 0, 0, pathX_Y, 0, mcACP6D_MOVE_RELATIVE); 
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX, 0.120, 0, 0, 0, 0, pathX_Y, 0, mcACP6D_MOVE_RELATIVE); 
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX, -0.120, 0, 0, 0, 0, pathX_Y, 0, mcACP6D_MOVE_RELATIVE);
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX, -0.120, 0, 0, 0, 0, pathX_Y, 0, mcACP6D_MOVE_RELATIVE); 

																		
						AddCommand6D_xy(ADR(fb.MoveQueue[selected2[0].index].Commands), sX + sY, -0.120, 0, 0, 0, 0, pathX_Y, 0, mcACP6D_MOVE_RELATIVE); 

						AddCommand6D_xy(ADR(fb.MoveQueue[selected2[1].index].Commands), sX, 0.120, 0, 0, 0, 0, pathX_Y, 0, mcACP6D_MOVE_RELATIVE);
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected2[2].index].Commands), sX, -0.120, 0, 0, 0, 0, pathX_Y, 0, mcACP6D_MOVE_RELATIVE); 

						AddCommand6D_xy(ADR(fb.MoveQueue[selected2[3].index].Commands), sX, 0.120, 0, 0, 0, 0, pathX_Y, 0, mcACP6D_MOVE_RELATIVE); 

						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							shuttles[i].command.moveQueue := TRUE;
						END_FOR;
						
					END_IF
					
					IF queueStatus.allDone THEN
						task.SubState := 230;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				230:
					task.StateInfo := 'Move shuttles';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN						
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0, 4 * 0.240, 2 * 0.240, FALSE);
						brfiShuttleSelect(ADR(shuttles), ADR(selected2), 0, 2 * 0.240, 1, 1, FALSE);
					
						AddCommand6D_waitCmdLb(ADR(commandQueue), shuttles[selected1[0].index].ID, mcACP6D_SH_WAIT_CMDLB_START, 0, mcACP6D_SH_WAIT_CMDLB_REGULAR);
						
						fb.MoveQueue[selected1[1].index].Commands := commandQueue;
						fb.MoveQueue[selected1[2].index].Commands := commandQueue;
						fb.MoveQueue[selected1[3].index].Commands := commandQueue;
						
						//AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 0.720, 0.1, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE); 
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[1].index].Commands), sX + sY, 0.58, 0.24, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE); 
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[2].index].Commands), sX + sY, 0.860, 0.24, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE); 
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[3].index].Commands), sX + sY, 0.720, 0.380, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
						
						brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
						AddCommand6D_waitCmdLb(ADR(commandQueue), shuttles[selected2[0].index].ID, mcACP6D_SH_WAIT_CMDLB_START, 0, mcACP6D_SH_WAIT_CMDLB_REGULAR);
						
						fb.MoveQueue[selected2[1].index].Commands := commandQueue;
						fb.MoveQueue[selected2[2].index].Commands := commandQueue;
						fb.MoveQueue[selected2[3].index].Commands := commandQueue;
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected2[1].index].Commands), sX + sY, 0.380, 0.24 * 3, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE); 
						AddCommand6D_xy(ADR(fb.MoveQueue[selected2[2].index].Commands), sX + sY, 0.100, 3*0.240, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE); 
						AddCommand6D_xy(ADR(fb.MoveQueue[selected2[3].index].Commands), sX + sY, 0.24, 4 * 0.24 - 0.100, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
						
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							shuttles[i].command.moveQueue := TRUE;
						END_FOR;
						
					END_IF
					
					IF queueStatus.allAcknowledge THEN
						task.SubState := 240;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				240:
					task.StateInfo := 'Move shuttles';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN						
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0, 4 * 0.240, 2 * 0.240, FALSE);
						brfiShuttleSelect(ADR(shuttles), ADR(selected2), 0, 2 * 0.240, 1, 1, FALSE);
						
						AddCommand6D_xy(ADR(fb.MoveQueue[selected1[0].index].Commands), sX + sY, 0.720, 0.1, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE); 
						AddCommand6D_xy(ADR(fb.MoveQueue[selected2[0].index].Commands), sX + sY, 0.240, 0.580, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE); 

						fb.virMoveInPlane[0].Parameters.Acceleration := 20;
						fb.virMoveInPlane[0].Parameters.Velocity := 2;
						fb.virMoveInPlane[0].Parameters.Position.X := 3 * 0.24;
						fb.virMoveInPlane[0].Parameters.Position.Y := 0.24;
						
						local.actions.substate.virMoveInPlane[0] := TRUE;
						
						fb.virMoveInPlane[1].Parameters.Acceleration := 20;
						fb.virMoveInPlane[1].Parameters.Velocity := 2;
						fb.virMoveInPlane[1].Parameters.Position.X := 0.24;
						fb.virMoveInPlane[1].Parameters.Position.Y := 3 * 0.24;
						
						local.actions.substate.virMoveInPlane[1] := TRUE;
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							shuttles[i].command.moveQueue := TRUE;
						END_FOR;
						
					END_IF
					
					IF queueStatus.allDone AND fb.virMoveInPlane[0].Done AND fb.virMoveInPlane[1].Done THEN
						task.SubState := 300;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				300:
					task.StateInfo := 'Create sun planet 1';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN						
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0, 4 * 0.240, 2 * 0.240, FALSE);
						brfiShuttleSelect(ADR(shuttles), ADR(selected2), 0, 2 * 0.240, 1, 1, FALSE);
						
						FOR i := 0 TO 3 DO
	  						fb.brfiSunPlanet[0].PlanetShuttles[i] := shuttles[selected1[i].index].Ref;
						END_FOR;						
						
						fb.brfiSunPlanet[0].SunShuttle := ADR(shuttlesVirtual[0]);
						
						FOR i := 0 TO 3 DO
							fb.brfiSunPlanet[1].PlanetShuttles[i] := shuttles[selected2[i].index].Ref;
						END_FOR;						
						
						fb.brfiSunPlanet[1].SunShuttle := ADR(shuttlesVirtual[1]);
					END_IF
					
					local.actions.state.sunPlanetEnable[0] := TRUE;
					local.actions.state.sunPlanetEnable[1] := TRUE;
					
					IF fb.brfiSunPlanet[0].Active AND fb.brfiSunPlanet[1].Active THEN
						task.SubState := 400;
					ELSIF fb.brfiSunPlanet[0].Error THEN
						local.actions.state.sunPlanetEnable[0] := FALSE;
					ELSIF fb.brfiSunPlanet[1].Error THEN
						local.actions.state.sunPlanetEnable[1] := FALSE;
					END_IF;

				400:
					task.StateInfo := 'Move shuttles';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0, 4 * 0.240, 2 * 0.240, FALSE);
						brfiShuttleSelect(ADR(shuttles), ADR(selected2), 0, 2 * 0.240, 1, 1, FALSE);
						
						brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
						
						AddCommand6D_waitCmdLb(ADR(commandQueue), 100, mcACP6D_SH_WAIT_CMDLB_START, 0, mcACP6D_SH_WAIT_CMDLB_REGULAR);
						AddCommand6D_arcAngularCW(ADR(commandQueue), 0, 0, brmPI * 30, 1.0, 15.0, 0, mcACP6D_MOVE_ABSOLUTE);  
						
						fb.MoveQueue[selected1[0].index].Commands := commandQueue;	
						fb.MoveQueue[selected1[1].index].Commands := commandQueue;
						fb.MoveQueue[selected1[2].index].Commands := commandQueue;
						fb.MoveQueue[selected1[3].index].Commands := commandQueue;	
						
						brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
						AddCommand6D_waitCmdLb(ADR(commandQueue), 101, mcACP6D_SH_WAIT_CMDLB_START, 0, mcACP6D_SH_WAIT_CMDLB_REGULAR);
						AddCommand6D_arcAngularCW(ADR(commandQueue), 0, 0, brmPI * 30, 1.0, 15.0, 0, mcACP6D_MOVE_ABSOLUTE);  
						
						fb.MoveQueue[selected2[0].index].Commands := commandQueue;	
						fb.MoveQueue[selected2[1].index].Commands := commandQueue;
						fb.MoveQueue[selected2[2].index].Commands := commandQueue;
						fb.MoveQueue[selected2[3].index].Commands := commandQueue;	
					END_IF
					
					FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
						shuttles[i].command.moveQueue := TRUE;
					END_FOR;
					
					IF queueStatus.allAcknowledge THEN
						task.SubState := 410;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;

						
				410:
					IF task.OnStateEntry THEN						
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0, 4 * 0.240, 2 * 0.240, FALSE);
						brfiShuttleSelect(ADR(shuttles), ADR(selected2), 0, 2 * 0.240, 1, 1, FALSE);

						fb.virMoveInPlane[0].Parameters.Acceleration := 5;
						fb.virMoveInPlane[0].Parameters.Velocity := 0.5;
						fb.virMoveInPlane[0].Parameters.Position.X := 3 * 0.24;
						fb.virMoveInPlane[0].Parameters.Position.Y := 2 * 0.24;
						
						local.actions.substate.virMoveInPlane[0] := TRUE;
						
						fb.virMoveInPlane[1].Parameters.Acceleration := 5;
						fb.virMoveInPlane[1].Parameters.Velocity := 0.5;
						fb.virMoveInPlane[1].Parameters.Position.X := 0.24;
						fb.virMoveInPlane[1].Parameters.Position.Y := 2 * 0.24;
						
						local.actions.substate.virMoveInPlane[1] := TRUE;
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							shuttles[i].command.moveQueue := TRUE;
						END_FOR;
						
					END_IF
					
					IF fb.virMoveInPlane[0].Done AND fb.virMoveInPlane[1].Done THEN
						task.SubState := 420;
					ELSIF fb.virMoveInPlane[0].Error THEN
						task.Error.Code := fb.virMoveInPlane[0].ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					ELSIF fb.virMoveInPlane[1].Error THEN
						task.Error.Code := fb.virMoveInPlane[1].ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
					
				420:
					task.StateInfo := 'Move shuttles';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN						
						brfiShuttleSelect(ADR(shuttles), ADR(selected1), 0, 0, 4 * 0.240, 2 * 0.240, FALSE);
						brfiShuttleSelect(ADR(shuttles), ADR(selected2), 0, 2 * 0.240, 1, 1, FALSE);
						
						fb.virMoveArc[0].Parameters.Acceleration := 5;
						fb.virMoveArc[0].Parameters.Velocity := 0.5;
						fb.virMoveArc[0].Parameters.Direction :=  mcACP6D_ARC_COUNTER_CLOCKWISE;
						fb.virMoveArc[0].Parameters.Option :=  mcACP6D_ARC_ANGULAR;
						fb.virMoveArc[0].Parameters.Angular.Center.X := 0.48;
						fb.virMoveArc[0].Parameters.Angular.Center.Y := 0.48;
						fb.virMoveArc[0].Parameters.Angular.Angle := brmPI * 10;
						local.actions.substate.virMoveArc[0] := TRUE;
						
						fb.virMoveArc[1].Parameters.Acceleration := 5;
						fb.virMoveArc[1].Parameters.Velocity := 0.5;
						fb.virMoveArc[1].Parameters.Direction :=  mcACP6D_ARC_COUNTER_CLOCKWISE;
						fb.virMoveArc[1].Parameters.Option :=  mcACP6D_ARC_ANGULAR;
						fb.virMoveArc[1].Parameters.Angular.Center.X := 0.48;
						fb.virMoveArc[1].Parameters.Angular.Center.Y := 0.48;
						fb.virMoveArc[1].Parameters.Angular.Angle := brmPI * 10;
						local.actions.substate.virMoveArc[1] := TRUE;
					END_IF
					
					IF fb.virMoveArc[0].Done AND fb.virMoveArc[0].Done THEN
						task.SubState := 420;
					ELSIF fb.virMoveArc[0].Error THEN
						task.Error.Code := fb.virMoveArc[0].ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					ELSIF fb.virMoveArc[1].Error THEN
						task.Error.Code := fb.virMoveArc[1].ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
			END_CASE;
			
		ACP6D_VICTORY:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Move shuttles to start position';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						// Configure shuttle targets 
						fb.MoveInPlaneAsync.Parameters.Velocity := 2;
						fb.MoveInPlaneAsync.Parameters.Acceleration := 15;
						
						fb.MoveInPlaneAsync.Parameters.Mode := mcACP6D_SHUTTLE_UNSORTED;
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(shuttles[i].Ref);
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].X := positions.dance[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[i].Y := positions.dance[i].Y;
						END_FOR;
					END_IF;
					
					local.actions.substate.moveInPlaneAsync := TRUE;
					
					IF fb.MoveInPlaneAsync.Done THEN
						task.State := ACP6D_COMMAND_DONE;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;	
			END_CASE
			
		ACP6D_COMMAND_DONE:
			task.StateInfo := 'Command done';
			// ---------------------------------------------------------------------------------
			// Check that all commands are reset
			IF brsmemcmp(ADR(no_command), ADR(task.Input.Command), SIZEOF(no_command)) = 0 THEN
				task.State := ACP6D_IDLE;
			END_IF;	
			
		ACP6D_COMMAND_ERROR:
			task.StateInfo := 'Command failed';
			// ---------------------------------------------------------------------------------
			// Check that all commands are reset
			IF brsmemcmp(ADR(no_command), ADR(task.Input.Command), SIZEOF(no_command)) = 0 THEN
				brsmemset(ADR(task.Error), 0, SIZEOF(task.Error));
				task.State := ACP6D_IDLE;
			END_IF;	
			
		ACP6D_ERROR:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Wait for error acknowledge command';
					// ---------------------------------------------------------------------------------
					local.actions.state.cyclicModeRequest := a6dCYCLIC_DISABLED;
					
					IF task.Error.Acknowledge THEN
						task.SubState := 10;
					END_IF;
				
				10:
					task.StateInfo := 'Resetting assembly errors';
					// ---------------------------------------------------------------------------------
					local.actions.substate.assemblyReset := TRUE;
					IF task.Output.AssemblyInfo.AssemblyState <> mcACP6D_ERRORSTOP THEN
						brsmemset(ADR(task.Error), 0, SIZEOF(task.Error));
						task.State := ACP6D_INITIALIZE;
					END_IF;
			END_CASE;
	END_CASE // End of main task logic
  
	task.Error.Acknowledge := FALSE; 
      
	// Detect state change events
	// =================================================================================================================
	task.OnStateEntry := (task.State <> local.lastState) OR (task.SubState <> local.lastSubState);

	IF task.State <> local.lastState THEN
		IF (task.State = ACP6D_ERROR) OR (task.State = ACP6D_COMMAND_ERROR) THEN
	  		task.Error.State := task.State;
			task.Error.SubState := task.SubState;
		END_IF;
		
		task.SubState := 0;
		local.lastState := task.State;
		brsmemset(ADR(local.actions.state), 0, SIZEOF(local.actions.state));
		brsmemset(ADR(local.actions.substate), 0, SIZEOF(local.actions.substate));
		task.StateInfo := '';
		
		// Reset to default on every major task change
		moveQueueParamTask := moveQueueParamDefault;
	END_IF

	// Reset current state actions also when substate changes
	IF task.SubState <> local.lastSubState THEN
		local.lastSubState := task.SubState;
		brsmemset(ADR(local.actions.substate), 0, SIZEOF(local.actions.substate));
		task.StateInfo := '';
	END_IF
	
	IF task.OnStateEntry THEN
		brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
		
		IF task.State <> ACP6D_COMMAND_ERROR THEN
			FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
				brsmemset(ADR(shuttles[i].command), 0, SIZEOF(shuttles[i].command));
				brsmemset(ADR(fb.MoveInPlaneAsync.Parameters.AsyncPar), 0, SIZEOF(fb.MoveInPlaneAsync.Parameters.AsyncPar));
				brsmemset(ADR(fb.MoveQueue[i].Commands), 0, SIZEOF(fb.MoveQueue[i].Commands));
			END_FOR;
		END_IF; 
	END_IF;


    
	// Function calls
	// =================================================================================================================
	fb.AssemblyReadInfo.Assembly := ADR(gAssembly6D_1);
	fb.AssemblyReadInfo();
	
	fb.AssemblyPowerOn.Assembly := ADR(gAssembly6D_1);
	fb.AssemblyPowerOn.Execute := local.actions.substate.assemblyPowerOn;
	fb.AssemblyPowerOn();
	
	fb.AssemblyPowerOff.Assembly := ADR(gAssembly6D_1);
	fb.AssemblyPowerOff.Execute := local.actions.substate.assemblyPowerOff;
	fb.AssemblyPowerOff();

	fb.AssemblyReset.Assembly := ADR(gAssembly6D_1);
	fb.AssemblyReset.Execute := local.actions.substate.assemblyReset;
	fb.AssemblyReset();
	
	fb.AssemblyGetShuttle.Assembly := ADR(gAssembly6D_1);
	fb.AssemblyGetShuttle.Enable := local.actions.state.assemblyGetShuttles;
	fb.AssemblyGetShuttle.Next := local.actions.state.assemblyGetNextShuttle;
	fb.AssemblyGetShuttle();
	
	fb.MoveInPlaneAsync.Assembly := ADR(gAssembly6D_1);
	fb.MoveInPlaneAsync.Execute := local.actions.substate.moveInPlaneAsync;
	fb.MoveInPlaneAsync();
	
	fb.TON_delay.IN := local.actions.substate.delay;
	fb.TON_delay();
	
	fb.assemblyStop.Assembly := ADR(gAssembly6D_1);
	fb.assemblyStop.Execute := local.actions.substate.assemblyStop;
	fb.assemblyStop();
	
	fb.assemblyGetVirtualSh.Assembly := ADR(gAssembly6D_1);
	fb.assemblyGetVirtualSh();
	
	fb.virtualShCreate.Assembly := ADR(gAssembly6D_1);
	fb.virtualShCreate.Execute := local.actions.substate.createShuttleVirtual;
	fb.virtualShCreate();
	
	// Call shuttle functions
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO		
		fb.Move6D[i].Shuttle := ADR(shuttles[i].Ref);
		fb.Move6D[i].Execute := shuttles[i].command.move6D;
		fb.Move6D[i]();
		
		fb.MoveQueue[i].Shuttle := ADR(shuttles[i].Ref);
		fb.MoveQueue[i].Execute := shuttles[i].command.moveQueue;
		fb.MoveQueue[i]();
	END_FOR;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE_VIRTUAL DO
		fb.virMoveInPlane[i].Shuttle := ADR(shuttlesVirtual[i]);
		fb.virMoveInPlane[i].Execute := local.actions.substate.virMoveInPlane[i];
		fb.virMoveInPlane[i]();
		
		fb.virMoveArc[i].Shuttle := ADR(shuttlesVirtual[i]);
		fb.virMoveArc[i].Execute := local.actions.substate.virMoveArc[i];
		fb.virMoveArc[i]();
	
		fb.brfiSunPlanet[i].Enable := local.actions.state.sunPlanetEnable[i];
		fb.brfiSunPlanet[i]();
	END_FOR;
	
	// 6D Cyclic channel handling
	// =================================================================================================================
	acCyclicChannelHandling;
	
	// Update shuttle statuses by polling them one by one
	// =================================================================================================================
    acShuttleStatusPolling;
	
	// Move Queue status handling
	// =================================================================================================================
	acMoveQueueStatusHandling;

	// Generate random numbers
	// =================================================================================================================
	random.delays[random.delaysIndex] := RandValueREAL(100, 2000) / 1000;
	random.delaysIndex := random.delaysIndex + 1;  
	IF random.delaysIndex > gMAX_INDEX_SHUTTLE THEN
		random.delaysIndex := 0;  
	END_IF;
	
	random.shuffleSequence[random.shuffleSequenceIndex] := RandValueDINT(-1000, 1000) MOD 5;
	random.shuffleSequenceIndex := random.shuffleSequenceIndex + 1;  
	IF random.shuffleSequenceIndex > gMAX_INDEX_SHUFFLE THEN
		random.shuffleSequenceIndex := 0;  
	END_IF;
	
	
	
	// Task outputs
	// =================================================================================================================
	task.Output.AssemblyInfo := fb.AssemblyReadInfo.AssemblyInfo;
	task.Output.Status.CommandDone := (task.State = ACP6D_COMMAND_DONE);
	task.Error.Active := (task.State = ACP6D_ERROR) OR (task.State = ACP6D_COMMAND_ERROR);
	
	task.Output.ShuttleUserSelected.X := shuttles[task.Output.ShuttleUserSelected.index].position.value.X;
	task.Output.ShuttleUserSelected.Y := shuttles[task.Output.ShuttleUserSelected.index].position.value.Y;
	
	task.Output.ShuttleWithPayload.X := shuttles[task.Output.ShuttleWithPayload.index].position.value.X;
	task.Output.ShuttleWithPayload.Y := shuttles[task.Output.ShuttleWithPayload.index].position.value.Y;

END_PROGRAM
	
PROGRAM _EXIT
	
END_PROGRAM