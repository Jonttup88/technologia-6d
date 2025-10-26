
(*  *)
FUNCTION AddTarget6D_xyz
		
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF TargetList[i].axisMask = 0 THEN 
			TargetList[i].axisMask := DINT_TO_USINT(axisSelect);
			TargetList[i].x := x;
			TargetList[i].y := y;
			TargetList[i].z := z;
			TargetList[i].velocity_xy := velocity_xy;
			TargetList[i].velocity_short := velocity_short;
			TargetList[i].acceleration := acceleration;	
			TargetList[i].mode := mode;
			RETURN;
		END_IF;
	END_FOR;
	
END_FUNCTION

FUNCTION AddTarget6D_Rxyz
	
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF TargetList[i].axisMask = 0 THEN 
			TargetList[i].axisMask := DINT_TO_USINT(axisSelect);
			TargetList[i].Rx := Rx;
			TargetList[i].Ry := Ry;
			TargetList[i].Rz := Rz;
			TargetList[i].velocity_short := velocity_short;
			TargetList[i].mode := mode;
			RETURN;
		END_IF;
	END_FOR;	
			
END_FUNCTION

FUNCTION AddTarget6D_all
	
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF TargetList[i].axisMask = 0 THEN 
			TargetList[i].axisMask := DINT_TO_USINT(axisSelect);
			TargetList[i].x := x;
			TargetList[i].y := y;
			TargetList[i].z := z;
			TargetList[i].Rx := Rx;
			TargetList[i].Ry := Ry;
			TargetList[i].Rz := Rz;
			TargetList[i].velocity_xy := velocity_xy;
			TargetList[i].velocity_short := velocity_short;
			TargetList[i].acceleration := acceleration;	
			TargetList[i].mode := mode;
			RETURN;
		END_IF;
	END_FOR;	
			
END_FUNCTION


FUNCTION_BLOCK brfiMove6DQueue

    // Execution control
    // ========================================================================================================
	IF Execute = FALSE THEN
		IF internal.initialized THEN
			brsmemset(ADR(internal), 0, SIZEOF(internal));
		END_IF
		state := brfiMOVE6DQUEUE_DISABLED;
	END_IF
        
    
	// Program code
	// ========================================================================================================
	CASE state OF			
		brfiMOVE6DQUEUE_DISABLED:
			// 
			// ------------------------------------------------------
			Move6D.Execute := FALSE;
			
			IF Execute THEN
				internal.initialized := TRUE;
				state := brfiMOVE6DQUEUE_RUN;
			END_IF;
			
		brfiMOVE6DQUEUE_RUN:	
			CASE subState OF
				0:
					// Read current position of the shuttle
					// ------------------------------------------------------
					internal.actions.executeReadPosition := TRUE;
			
					IF ShGetInfo.Done THEN
						internal.position := ShGetInfo.ShuttleInfo.Position;
						subState := 10;
					ELSIF ShGetInfo.Error THEN
						LastStatusCode := ShGetInfo.ErrorID;
						state := brfiMOVE6DQUEUE_ERROR;
					END_IF;
					
				10:	
					// Find next target that has masked axes
					// ------------------------------------------------------
					IF internal.i > gMAX_INDEX_TARGETS THEN
						state := brfiMOVE6DQUEUE_DONE;
					END_IF;
					
					WHILE internal.i <= gMAX_INDEX_TARGETS DO
						refTarget ACCESS ADR(Targets[internal.i]);
				
						IF refTarget.axisMask > 0 THEN
							internal.i := internal.i + 1;
							Move6D.Execute := FALSE;
							brsmemset(ADR(Move6D.Parameters), 0, SIZEOF(Move6D.Parameters));
							
							// Use target velocity/acceleration when available. Use values from parameters as fallback values
							Move6D.Parameters.InPlane.Velocity := SEL(refTarget.velocity_xy > 0, Parameters.velocity_xy, refTarget.velocity_xy);
							Move6D.Parameters.InPlane.Acceleration := SEL(refTarget.acceleration > 0, Parameters.acceleration, refTarget.acceleration);
					
							IF refTarget.velocity_short > 0 THEN
								Move6D.Parameters.ShortAxis.Velocity.Z := refTarget.velocity_short;
								Move6D.Parameters.ShortAxis.Velocity.Rx := refTarget.velocity_short;
								Move6D.Parameters.ShortAxis.Velocity.Ry := refTarget.velocity_short;
								Move6D.Parameters.ShortAxis.Velocity.Rz := refTarget.velocity_short;
							ELSE
								Move6D.Parameters.ShortAxis.Velocity.Z := Parameters.velocity_short;
								Move6D.Parameters.ShortAxis.Velocity.Rx := Parameters.velocity_short;
								Move6D.Parameters.ShortAxis.Velocity.Ry := Parameters.velocity_short;
								Move6D.Parameters.ShortAxis.Velocity.Rz := Parameters.velocity_short;
							END_IF;

							IF refTarget.mode = brfiMOVE6D_ABSOLUTE THEN
								// Set absolute target
								Move6D.Parameters.InPlane.Position.X := SEL(refTarget.axisMask.0,  internal.position.X, refTarget.x);
								Move6D.Parameters.InPlane.Position.Y := SEL(refTarget.axisMask.1,  internal.position.Y, refTarget.y);
								Move6D.Parameters.ShortAxis.Position.Z := SEL(refTarget.axisMask.2,  internal.position.Z, refTarget.z);
								Move6D.Parameters.ShortAxis.Position.Rx := SEL(refTarget.axisMask.3,  internal.position.Rx, refTarget.Rx);
								Move6D.Parameters.ShortAxis.Position.Ry := SEL(refTarget.axisMask.4,  internal.position.Ry, refTarget.Ry);
								Move6D.Parameters.ShortAxis.Position.Rz := SEL(refTarget.axisMask.5,  internal.position.Rz, refTarget.Rz);
							ELSE
								// Calculate relative target
								Move6D.Parameters.InPlane.Position.X := SEL(refTarget.axisMask.0,  internal.position.X, internal.position.X + refTarget.x);
								Move6D.Parameters.InPlane.Position.Y := SEL(refTarget.axisMask.1,  internal.position.Y, internal.position.Y + refTarget.y);
								Move6D.Parameters.ShortAxis.Position.Z := SEL(refTarget.axisMask.2,  internal.position.Z, internal.position.Z + refTarget.z);
								Move6D.Parameters.ShortAxis.Position.Rx := SEL(refTarget.axisMask.3,  internal.position.Rx, internal.position.Rx + refTarget.Rx);
								Move6D.Parameters.ShortAxis.Position.Ry := SEL(refTarget.axisMask.4,  internal.position.Ry, internal.position.Ry + refTarget.Ry);
								Move6D.Parameters.ShortAxis.Position.Rz := SEL(refTarget.axisMask.5,  internal.position.Rz, internal.position.Rz + refTarget.Rz);
							END_IF;
							subState := 20;
							EXIT;
						END_IF;
				
						internal.i := internal.i + 1;
					END_WHILE;
					
				20:
					// Add to queue
					// ------------------------------------------------------
					Move6D.Execute := TRUE;
			
					IF Move6D.Acknowledge THEN
						// Update current position with the target we just added to the command queue
						internal.position.X := Move6D.Parameters.InPlane.Position.X;
						internal.position.Y := Move6D.Parameters.InPlane.Position.Y;
						internal.position.Z := Move6D.Parameters.ShortAxis.Position.Z;
						internal.position.Rx := Move6D.Parameters.ShortAxis.Position.Rx;
						internal.position.Ry := Move6D.Parameters.ShortAxis.Position.Ry;
						internal.position.Rz := Move6D.Parameters.ShortAxis.Position.Rz;			
						subState := 10;
					ELSIF Move6D.Error THEN
						LastStatusCode := Move6D.ErrorID;
						state := brfiMOVE6DQUEUE_ERROR;
					END_IF;
			END_CASE;


		brfiMOVE6DQUEUE_DONE:	
			// 
			// ------------------------------------------------------
			internal.actions.ready := TRUE;
   
            
		brfiMOVE6DQUEUE_ERROR:	
			// 
			// ------------------------------------------------------
			Move6D.Execute := FALSE;
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
	Move6D.Shuttle := ADR(Shuttle);
	Move6D();
	
	ShGetInfo.Shuttle := ADR(Shuttle);
	ShGetInfo.Execute := internal.actions.executeReadPosition;
	ShGetInfo();

	// Outputs
	// ========================================================================================================
	Done := Move6D.Done;
	Ready := internal.actions.ready;
	Error := internal.actions.error;

END_FUNCTION_BLOCK

