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
				
			ELSIF task.Input.Command.MoveToHome THEN
				local.targetPos := positions.home;
				task.State := ACP6D_MOVE_TO;	
				
			ELSIF task.Input.Command.MoveToUser THEN
				local.targetPos := positions.user;
				task.State := ACP6D_MOVE_TO;
				
			ELSIF task.Input.Command.MoveToDance THEN
				local.targetPos := positions.dance;
				task.State := ACP6D_MOVE_TO;
				
			ELSIF task.Input.Command.MoveToClockface THEN
				local.targetPos := positions.clockface;
				task.State := ACP6D_MOVE_TO;
				
			ELSIF task.Input.Command.MoveToPickup THEN
				local.targetPos := positions.pickup;
				task.State := ACP6D_MOVE_TO;
				
			ELSIF task.Input.Command.MoveToShuffle THEN
				local.targetPos := positions.shuffle;
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
					IF fb.TON_delay.Q AND group_status.cyclicForcesValid THEN
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
							task.Output.ShuttleWithPayload := i;
						END_IF;
					END_FOR;
				
					task.SubState := 40;
					
				40:
					task.StateInfo := 'Read current shuttle position';
					// ---------------------------------------------------------------------------------	
					shuttle ACCESS ADR(shuttles[task.Output.ShuttleWithPayload]);
					
					shuttle.command.updateInfo := TRUE;
					
					IF fb.ShGetInfo[shuttle.index].Done THEN
						task.SubState := 50;
					END_IF;
				
				50:
					task.StateInfo := 'Indicate which has payload';
					// ---------------------------------------------------------------------------------
					shuttle ACCESS ADR(shuttles[task.Output.ShuttleWithPayload]);
					
					IF task.OnStateEntry THEN
						fb.Move6DQueue[shuttle.index].Parameters.acceleration := 10;
						fb.Move6DQueue[shuttle.index].Parameters.velocity_short := 0.02;
						fb.Move6DQueue[shuttle.index].Parameters.velocity_xy := 1.0;
						
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.0005, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.004, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.0005, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.004, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.0005, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.004, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.0005, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.004, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.0005, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.004, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						AddTarget6D_xyz(ADR(targetList6D), aZ, 0, 0, 0.001, 0, 0, 0, brfiMOVE6D_ABSOLUTE);
						
						fb.Move6DQueue[shuttle.index].Targets := targetList6D;
					END_IF;
				
					shuttle.command.move6DQueue := TRUE;
					
					IF fb.Move6DQueue[shuttle.index].Done THEN
						task.State := ACP6D_COMMAND_DONE;
					ELSIF fb.Move6DQueue[shuttle.index].Error THEN
						task.Error.Code := fb.Move6DQueue[shuttle.index].LastStatusCode;
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
//						Target6D_z(ADR(targetList6D[0]), 0.003, 0, 0);
//						
//						Target6D_Rxyz(ADR(targetList6D[1]), 0, 0.03, 0, 0);
//						targetList6D[1].axisMask.1 := TRUE;
//						targetList6D[1].y := 0.04;
//						
//						Target6D_Rxyz(ADR(targetList6D[2]), 0, -0.06, 0, 0);
//						targetList6D[2].axisMask.1 := TRUE;
//						targetList6D[2].y := 0.04;
//						
//						Target6D_Rxyz(ADR(targetList6D[3]), 0, 0.06, 0, 0);
//						targetList6D[3].axisMask.1 := TRUE;
//						targetList6D[3].y := 0.04;
//						
//						Target6D_Rxyz(ADR(targetList6D[4]), 0, -0.06, 0, 0);
//						targetList6D[4].axisMask.1 := TRUE;
//						targetList6D[4].y := 0.04;
//						
//						Target6D_Rxyz(ADR(targetList6D[5]), 0, 0.06, 0, 0);
//						
//						Target6D_Rxyz(ADR(targetList6D[6]), 0, -0.03, 0, 0);
//						
//						Target6D_z(ADR(targetList6D[7]), -0.003, 0, 0);
//						Target6D_z(ADR(targetList6D[8]), 0.003, 0, 0);
//						Target6D_z(ADR(targetList6D[9]), -0.003, 0, 0);
//						Target6D_z(ADR(targetList6D[10]), 0.001, 0, 0);
//						
//						FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
//							fb.Move6DQueue[i].Parameters.velocity.xy := 0.1;
//							fb.Move6DQueue[i].Parameters.velocity.z := 0.02;
//							fb.Move6DQueue[i].Parameters.velocity.Ry := 0.1;
//							fb.Move6DQueue[i].Parameters.velocity.Rx := 0.1;
//							fb.Move6DQueue[i].Parameters.acceleration := 0.2;
//							fb.Move6DQueue[i].Parameters.mode := brfiMOVE_RELATIVE;
//							fb.Move6DQueue[i].Targets := targetList6D;
//							shuttles[i].command.move6DQueue := TRUE;
//						END_FOR;
					END_IF;
						
					IF group_status.Move6DQueue.AllDone THEN
						task.SubState := 20;
					ELSIF group_status.Move6DQueue.Error THEN
						task.Error.Code := group_status.Move6DQueue.LastErrorID;	
						task.State := ACP6D_COMMAND_ERROR;
					END_IF;
				
				20:
					task.StateInfo := 'Start force reading';
					// ---------------------------------------------------------------------------------
					local.actions.state.cyclicModeRequest := a6dCYCLIC_READ_FORCE;
					
					IF group_status.cyclicForcesValid THEN
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
							task.Output.SelectedShuttle := i;
						END_IF;
					END_FOR;	
									
				40:
					task.StateInfo := 'Move selected shuttle';
					// ---------------------------------------------------------------------------------
					IF task.OnStateEntry THEN
						shuttle ACCESS ADR(shuttles[task.Output.SelectedShuttle]);
						
						fb.MoveXYQueue[shuttle.index].Parameters.velocity := 1.5;
						fb.MoveXYQueue[shuttle.index].Parameters.acceleration := 5.0;
						
						AddTargetYX(ADR(targetListXY), aX + aY, 0.0, -0.2, 0.5, 0.5, 0, mcACP6D_MOVE_RELATIVE);
						AddTargetYX(ADR(targetListXY), aX + aY, positions.pickup[0].X, positions.pickup[0].Y, 2, 15, 0, mcACP6D_MOVE_ABSOLUTE);
						
						fb.MoveXYQueue[shuttle.index].Targets := targetListXY;
						
						shuttle.command.moveXYQueue := TRUE;
					END_IF;
						
					IF fb.MoveXYQueue[shuttle.index].Done THEN
						task.SubState := 50;
					ELSIF fb.MoveXYQueue[shuttle.index].Error THEN
						task.Error.Code := fb.MoveXYQueue[shuttle.index].LastStatusCode;
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
							IF i <> task.Output.SelectedShuttle THEN
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
		task.SubState := 0;
		local.lastState := task.State;
		brsmemset(ADR(local.actions.state), 0, SIZEOF(local.actions.state));
		brsmemset(ADR(local.actions.substate), 0, SIZEOF(local.actions.substate));
		task.StateInfo := '';
		brsmemset(ADR(targetList6D), 0, SIZEOF(targetList6D));
		brsmemset(ADR(targetListXY), 0, SIZEOF(targetListXY));
		
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
		brsmemset(ADR(targetList6D), 0, SIZEOF(targetList6D));
		brsmemset(ADR(targetListXY), 0, SIZEOF(targetListXY));
		
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
		fb.ShGetInfo[i].Shuttle := ADR(shuttles[i].Ref);
		fb.ShGetInfo[i].Execute := shuttles[i].command.updateInfo;
		fb.ShGetInfo[i]();
		
		IF fb.ShGetInfo[i].Done THEN
			shuttles[i].position.value := fb.ShGetInfo[i].ShuttleInfo.Position;
		END_IF;
		
		fb.Move6D[i].Shuttle := ADR(shuttles[i].Ref);
		fb.Move6D[i].Execute := shuttles[i].command.move6D;
		fb.Move6D[i]();
		
		fb.Move6DQueue[i].Shuttle := ADR(shuttles[i].Ref);
		fb.Move6DQueue[i].Execute := shuttles[i].command.move6DQueue;
		fb.Move6DQueue[i]();
		
		fb.MoveXYQueue[i].Shuttle := ADR(shuttles[i].Ref);
		fb.MoveXYQueue[i].Execute := shuttles[i].command.moveXYQueue;
		fb.MoveXYQueue[i]();
	END_FOR;
	
	// 6D Cyclic channel handling
	// =================================================================================================================
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		fb.ReadCyclicPosition[i].Enable := FALSE;
		shuttles[i].position.isValid := FALSE;
		
		fb.ReadCyclicForce[i].Enable := FALSE;
		shuttles[i].force.isValid := FALSE;
		
		fb.MoveCyclicPosition[i].Enable := FALSE;
		shuttles[i].moveCyclicActive := FALSE;
	END_FOR;
	
	// set global statuses so states can use them if required
	group_status.cyclicPositionsValid := TRUE;
	group_status.cyclicForcesValid := TRUE;
	group_status.cyclicControlActive := TRUE;
	
	FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
		IF NOT fb.ReadCyclicPosition[i].Valid THEN 
			group_status.cyclicPositionsValid := FALSE; 
		END_IF;
		
		IF NOT fb.ReadCyclicForce[i].Valid THEN 
			group_status.cyclicForcesValid := FALSE; 
		END_IF;
		
		IF NOT fb.MoveCyclicPosition[i].Valid THEN
			group_status.cyclicControlActive := FALSE;
		END_IF;
	END_FOR;
	
	CASE task.CyclicMode OF
		a6dCYCLIC_DISABLED:
			// ---------------------------------------------------------------------------------			
			CASE local.actions.state.cyclicModeRequest OF
				a6dCYCLIC_READ_POSITION: 
					task.CyclicMode := a6dCYCLIC_READ_POSITION;
				a6dCYCLIC_READ_FORCE:
					task.CyclicMode := a6dCYCLIC_READ_FORCE;
				a6dCYCLIC_MOVE_POSITION:
					task.CyclicMode := a6dCYCLIC_MOVE_POSITION;
			END_CASE;
			
		a6dCYCLIC_RELEASE_CHANNELS:
			// ---------------------------------------------------------------------------------
			group_status.cyclicChannelsReleased := TRUE;
			
			FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
				IF fb.ReadCyclicPosition[i].Busy OR fb.ReadCyclicForce[i].Busy OR fb.MoveCyclicPosition[i].Busy THEN
					group_status.cyclicChannelsReleased := FALSE;
				END_IF;
			END_FOR;
			
			IF group_status.cyclicChannelsReleased THEN
				task.CyclicMode := a6dCYCLIC_DISABLED;
			END_IF;	
		
		a6dCYCLIC_READ_POSITION:
			// ---------------------------------------------------------------------------------
			IF local.actions.state.cyclicModeRequest <> a6dCYCLIC_READ_POSITION THEN
				task.CyclicMode := a6dCYCLIC_RELEASE_CHANNELS;
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
				task.CyclicMode := a6dCYCLIC_RELEASE_CHANNELS;
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
				task.CyclicMode := a6dCYCLIC_RELEASE_CHANNELS;
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
	
	// Update function group statuses
	// =================================================================================================================
	acFunctionGroupStatus;

	// Task outputs
	// =================================================================================================================
	task.Output.AssemblyInfo := fb.AssemblyReadInfo.AssemblyInfo;
	task.Output.Status.CommandDone := (task.State = ACP6D_COMMAND_DONE);

END_PROGRAM
	
PROGRAM _EXIT
	
END_PROGRAM