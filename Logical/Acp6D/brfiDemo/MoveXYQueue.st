FUNCTION AddTargetDIR
	
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF TargetList[i].axisMask = 0 THEN 
			TargetList[i].axisMask := DINT_TO_USINT(axisSelect);
			TargetList[i].x := x;
			TargetList[i].y := y;
			TargetList[i].velocity := velocity;
			TargetList[i].acceleration := acceleration;	
			TargetList[i].mode := mode;
			TargetList[i].path := mcACP6D_PATH_DIRECT;
			TargetList[i].radius := radius;
			RETURN;
		END_IF;
	END_FOR;
	
END_FUNCTION

FUNCTION AddTargetYX
	
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF TargetList[i].axisMask = 0 THEN 
			TargetList[i].axisMask := DINT_TO_USINT(axisSelect);
			TargetList[i].x := x;
			TargetList[i].y := y;
			TargetList[i].velocity := velocity;
			TargetList[i].acceleration := acceleration;	
			TargetList[i].mode := mode;
			TargetList[i].path := mcACP6D_PATH_Y_THEN_X;
			TargetList[i].radius := radius;
			RETURN;
		END_IF;
	END_FOR;
	
END_FUNCTION

FUNCTION AddTargetXY
	
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF TargetList[i].axisMask = 0 THEN 
			TargetList[i].axisMask := DINT_TO_USINT(axisSelect);
			TargetList[i].x := x;
			TargetList[i].y := y;
			TargetList[i].velocity := velocity;
			TargetList[i].acceleration := acceleration;	
			TargetList[i].mode := mode;
			TargetList[i].path := mcACP6D_PATH_X_THEN_Y;
			TargetList[i].radius := radius;
			RETURN;
		END_IF;
	END_FOR;
	
END_FUNCTION

FUNCTION_BLOCK brfiMoveXYQueue

    // Execution control
    // ========================================================================================================
	IF Execute = FALSE THEN
		IF internal.initialized THEN
			brsmemset(ADR(internal), 0, SIZEOF(internal));
		END_IF
		state := brfiMOVEXYQUEUE_DISABLED;
	END_IF
        
    
	// Program code
	// ========================================================================================================
	CASE state OF			
		brfiMOVEXYQUEUE_DISABLED:
			// 
			// ------------------------------------------------------
			MoveXY.Execute := FALSE;
			
			IF Execute THEN
				internal.initialized := TRUE;
				state := brfiMOVEXYQUEUE_RUN;
			END_IF;
				
		brfiMOVEXYQUEUE_RUN:	
			CASE subState OF
				0:
					// ------------------------------------------------------
					internal.actions.executeReadPosition := TRUE;
			
					IF ShGetInfo.Done THEN
						internal.position.X := ShGetInfo.ShuttleInfo.Position.X;
						internal.position.Y := ShGetInfo.ShuttleInfo.Position.Y;
						subState := 10;
					ELSIF ShGetInfo.Error THEN
						LastStatusCode := ShGetInfo.ErrorID;
						state := brfiMOVEXYQUEUE_ERROR;
					END_IF;
					
				10:	
					// Find next target that has masked axes
					// ------------------------------------------------------
					IF internal.i > gMAX_INDEX_TARGETS THEN
						state := brfiMOVEXYQUEUE_DONE;
					END_IF;
					
					WHILE internal.i <= gMAX_INDEX_TARGETS DO
						refTarget ACCESS ADR(Targets[internal.i]);
				
						IF (refTarget.axisMask > 0) OR (refTarget.mode = mcACP6D_MOVE_RELATIVE) THEN
							internal.i := internal.i + 1;
							MoveXY.Execute := FALSE;
							brsmemset(ADR(MoveXY.Parameters), 0, SIZEOF(MoveXY.Parameters));
							
							// Use target velocity/acceleration when available. Use values from parameters as fallback values
							MoveXY.Parameters.Velocity := SEL(refTarget.velocity > 0, Parameters.velocity, refTarget.velocity);
							MoveXY.Parameters.Acceleration := SEL(refTarget.acceleration > 0, Parameters.acceleration, refTarget.acceleration);
							MoveXY.Parameters.Path := refTarget.path;
							MoveXY.Parameters.Radius := refTarget.radius;
							MoveXY.Parameters.Mode := refTarget.mode;
							
							IF refTarget.mode = mcACP6D_MOVE_RELATIVE THEN
								MoveXY.Parameters.Position.X := refTarget.x;
								MoveXY.Parameters.Position.Y := refTarget.y;
							ELSE
								MoveXY.Parameters.Position.X := SEL(refTarget.axisMask.0, internal.position.X, refTarget.x);
								MoveXY.Parameters.Position.Y := SEL(refTarget.axisMask.1, internal.position.Y, refTarget.y);
							END_IF;
							
							MoveXY.Parameters.EndVelocity := 0;
														
							subState := 20;
							EXIT;
						END_IF;
				
						internal.i := internal.i + 1;
					END_WHILE;
					
				20:
					// Add to queue
					// ------------------------------------------------------
					MoveXY.Execute := TRUE;
			
					IF MoveXY.Acknowledge THEN
						// Update current shuttle position
						IF refTarget.mode = mcACP6D_MOVE_RELATIVE THEN
							internal.position.X := internal.position.X + MoveXY.Parameters.Position.X;
							internal.position.Y := internal.position.Y + MoveXY.Parameters.Position.Y;
						ELSE
							internal.position.X := MoveXY.Parameters.Position.X;
							internal.position.Y := MoveXY.Parameters.Position.Y;	
						END_IF;
					
						subState := 10;
					ELSIF MoveXY.Error THEN
						LastStatusCode := MoveXY.ErrorID;
						state := brfiMOVEXYQUEUE_ERROR;
					END_IF;
			END_CASE;


		brfiMOVEXYQUEUE_DONE:	
			// 
			// ------------------------------------------------------
			internal.actions.ready := TRUE;
   
            
		brfiMOVEXYQUEUE_ERROR:	
			// 
			// ------------------------------------------------------
			MoveXY.Execute := FALSE;
			internal.actions.error := TRUE;
                                
	END_CASE;	

	// State change events
	// -------------------------------------------------------------------	
	IF state <> internal.lastState THEN
		// If function block is enabled -> update info of last executed state
		IF Execute THEN
			LastExecutedState := internal.lastState;
		END_IF;
        
		subState := 0;
		brsmemset(ADR(internal.actions), 0, SIZEOF(internal.actions));
		internal.lastState := state;
	END_IF;

	// Reset current state actions also when substate changes
	IF subState <> internal.lastSubState THEN
		internal.lastSubState := subState;
		brsmemset(ADR(internal.actions), 0, SIZEOF(internal.actions));
	END_IF

    
	// Function calls
	// ========================================================================================================
	MoveXY.Shuttle := ADR(Shuttle);
	MoveXY();
	
	ShGetInfo.Shuttle := ADR(Shuttle);
	ShGetInfo.Execute := internal.actions.executeReadPosition;
	ShGetInfo();

	// Outputs
	// ========================================================================================================
	Done := MoveXY.Done;
	Ready := internal.actions.ready;
	Error := internal.actions.error;

END_FUNCTION_BLOCK

