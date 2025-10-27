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
		
	// alustukset group movejuttuille
	// Shuttle grouppaus ja groupin purkukomennot ja logiikka
	// move queuelle logiikka joka tarkistaa että kaikki on  valmistuneet suorituksestaan
	// Line shufflet ja testaus
	// Box shuttlet ja testaus
	// Circle shuffleen tietorakennetta
	// Victory dance logiikka
	// robotin taski ja rajapintatestaus
	// VNC testaus
	// Cyclic prosessoinnille oma rakenne ja kaikki liittyvä kama sinne
	
END_PROGRAM
	
PROGRAM _CYCLIC	
    // Access task interface
    // =================================================================================================================
	task ACCESS ADR(gAcp6D);

	// Inputs
	// =================================================================================================================
	IF NOT task.Input.Force THEN

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
						task.State := ACP6D_COMMAND_DONE; 
					END_IF
					
				
				1000:
					task.StateInfo := 'No shuttles';
				// ---------------------------------------------------------------------------------
			
			END_CASE;
				
		ACP6D_IDLE:	
			task.StateInfo := 'Waiting for command';
			IF task.Input.Command.Reinitialize THEN
				task.State := ACP6D_INITIALIZE;
				
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
				
			ELSIF task.Input.Command.FindPayload THEN
				task.State := ACP6D_FIND_PAYLOAD;
				
			ELSIF task.Input.Command.SelectShuttle THEN
				task.State := ACP6D_SELECT_SHUTTLE;
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
					task.StateInfo := 'Move shuttles to user approach point';
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
							fb.MoveInPlaneAsync.Parameters.AsyncPar[x].X := positions.user[i].X;
							fb.MoveInPlaneAsync.Parameters.AsyncPar[x].Y := positions.user[i].Y;
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
					task.StateInfo := 'Move shuttles to selection position';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							fb.MoveQueue[i].Parameters.velocity_xy := 2.0;
							fb.MoveQueue[i].Parameters.velocity_short := 0.05;
							fb.MoveQueue[i].Parameters.acceleration := 15.0;
						END_FOR;
						
						AddCommand6D_wait(ADR(commandQueue), 0);
						
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.003, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						
						AddCommand6D_xy(ADR(commandQueue), sY, 0, 0.900, 0, 0, 0, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
						
						AddCommand6D_Rxyz(ADR(commandQueue), sRx, -0.03, 0, 0, 0.3, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_Rxyz(ADR(commandQueue), sRx, 0.00, 0, 0, 0.3, mcACP6D_MOVE_ABSOLUTE);
												
						//						AddCommand6D_Rxyz(ADR(commandQueue), sRy, 0, 0.03, 0, 0.3, mcACP6D_MOVE_ABSOLUTE);
//						AddCommand6D_Rxyz(ADR(commandQueue), sRy, 0, -0.03, 0, 0.3, mcACP6D_MOVE_ABSOLUTE);
//						AddCommand6D_Rxyz(ADR(commandQueue), sRy, 0, 0.03, 0, 0.3, mcACP6D_MOVE_ABSOLUTE);
//						AddCommand6D_Rxyz(ADR(commandQueue), sRy, 0, 0.00, 0, 0.3, mcACP6D_MOVE_ABSOLUTE);
						
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							fb.MoveQueue[i].Commands := commandQueue;
							fb.MoveQueue[i].Commands[0].waitTime := RandValueREAL(0.5, 2);
							shuttles[i].command.moveQueue := TRUE;
						END_FOR;
	
					END_IF;
						
					IF queueStatus.allDone THEN
						task.SubState := 20;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
					
				20:
					task.StateInfo := 'Say hello to the player';
					// ---------------------------------------------------------------------------------	
					IF task.OnStateEntry THEN
	  					brfiShuttleSelect(ADR(shuttles), ADR(local.selectionList), 0.960, 0.960, 0, 0);
						
						AddCommand6D_wait(ADR(commandQueue), 0);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.004, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						AddCommand6D_wait(ADR(commandQueue), 0.1);
						AddCommand6D_xyz(ADR(commandQueue), sZ, 0, 0, 0.001, 0, 0, 0, mcACP6D_MOVE_ABSOLUTE);
						
						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
							fb.MoveQueue[i].Parameters.velocity_short := 0.03;
							
							fb.MoveQueue[local.selectionList[i].index].Commands := commandQueue;
							fb.MoveQueue[local.selectionList[i].index].Commands[0].waitTime := i * 0.1;
							shuttles[local.selectionList[i].index].command.moveQueue := TRUE;
						END_FOR;
					END_IF;
					
					IF queueStatus.allDone THEN
						task.SubState := 30;
					ELSIF queueStatus.error THEN
						task.Error.Code := queueStatus.errorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				30:
					task.StateInfo := 'Start force reading';
					// ---------------------------------------------------------------------------------
					local.actions.state.cyclicModeRequest := a6dCYCLIC_READ_FORCE;
					
					IF cyclic.allForceValuesValid THEN
						task.SubState := 40;
					END_IF;
				
				40:
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
							task.SubState := 50;
							task.Output.ShuttleUserSelected.index := i;
						END_IF;
					END_FOR;	
									
				50:
					task.StateInfo := 'Move selected shuttle';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						shuttle ACCESS ADR(shuttles[task.Output.ShuttleUserSelected.index]);
						refMoveQueue ACCESS ADR(fb.MoveQueue[shuttle.index]);
						
						refMoveQueue.Parameters.velocity_xy := 1.5;
						refMoveQueue.Parameters.acceleration := 5.0;
						
						AddCommand6D_xy(ADR(commandQueue), sX + sY, 0.0, -0.2, 0.5, 0, 0.5, pathDIRECT, 0, mcACP6D_MOVE_RELATIVE);
						AddCommand6D_xy(ADR(commandQueue), sX + sY, positions.pickup[0].X, positions.pickup[0].Y, 2, 0, 15, pathDIRECT, 0, mcACP6D_MOVE_ABSOLUTE);
					
						refMoveQueue.Commands := commandQueue;
						
						shuttle.command.moveQueue := TRUE;
					END_IF;
						
					IF refMoveQueue.Done THEN
						task.SubState := 60;
					ELSIF refMoveQueue.Error THEN
						task.Error.Code := refMoveQueue.ErrorID;
						task.SubState := ACP6D_COMMAND_ERROR;
					END_IF;
				
				60:
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
						task.State := ACP6D_COMMAND_DONE;
					ELSIF fb.MoveInPlaneAsync.Error THEN
						task.Error.Code := fb.MoveInPlaneAsync.ErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
					
			END_CASE;
			
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
		brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
		
		FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
			brsmemset(ADR(shuttles[i].command), 0, SIZEOF(shuttles[i].command));
			brsmemset(ADR(fb.MoveInPlaneAsync.Parameters.AsyncPar), 0, SIZEOF(fb.MoveInPlaneAsync.Parameters.AsyncPar));
		END_FOR;
	END_IF

	// Reset current state actions also when substate changes
	IF task.SubState <> local.lastSubState THEN
		local.lastSubState := task.SubState;
		brsmemset(ADR(local.actions.substate), 0, SIZEOF(local.actions.substate));
		task.StateInfo := '';
		brsmemset(ADR(commandQueue), 0, SIZEOF(commandQueue));
		
		FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
			brsmemset(ADR(shuttles[i].command), 0, SIZEOF(shuttles[i].command));
			brsmemset(ADR(fb.MoveInPlaneAsync.Parameters.AsyncPar), 0, SIZEOF(fb.MoveInPlaneAsync.Parameters.AsyncPar));
		END_FOR;
	END_IF


    
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
	
	// Call shuttle functions
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO		
		fb.Move6D[i].Shuttle := ADR(shuttles[i].Ref);
		fb.Move6D[i].Execute := shuttles[i].command.move6D;
		fb.Move6D[i]();
		
		fb.MoveQueue[i].Shuttle := ADR(shuttles[i].Ref);
		fb.MoveQueue[i].Execute := shuttles[i].command.moveQueue;
		fb.MoveQueue[i]();
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