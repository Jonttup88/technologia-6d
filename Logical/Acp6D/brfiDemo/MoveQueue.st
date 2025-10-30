FUNCTION_BLOCK brfi6DMoveQueue

    // Execution control
    // ========================================================================================================
	IF Execute = FALSE THEN
		IF internal.initialized THEN
			brsmemset(ADR(internal), 0, SIZEOF(internal));
			brsmemset(ADR(actions), 0, SIZEOF(actions));
		END_IF
		state := brfi6DMOVEQUEUE_DISABLED;
	END_IF
        
    
	// Program code
	// ========================================================================================================
	CASE state OF			
		brfi6DMOVEQUEUE_DISABLED:
			// 
			// ------------------------------------------------------
			IF Execute THEN
				internal.initialized := TRUE;
				brsmemset(ADR(FailedCommand), 0, SIZEOF(FailedCommand));
				brsmemset(ADR(cmd), 0, SIZEOF(cmd));
				FailedCommandIndex := -1;
				ErrorID := 0;
				state := brfi6DMOVEQUEUE_RUN;
			END_IF;
				
		brfi6DMOVEQUEUE_RUN:	
			CASE subState OF
				0:
					// ------------------------------------------------------
					actions.getInfo := TRUE;
			
					IF fb.ShGetInfo.Done THEN
						internal.position := fb.ShGetInfo.ShuttleInfo.Position;
						subState := 100;
					ELSIF fb.ShGetInfo.Error THEN
						ErrorID := fb.ShGetInfo.ErrorID;
						state := brfi6DMOVEQUEUE_ERROR;
					END_IF;
					
				100:	
					// Find next target that has masked axes
					// ------------------------------------------------------
					IF internal.i > gMAX_INDEX_TARGETS THEN
						state := brfi6DMOVEQUEUE_DONE;
					END_IF;
					
					WHILE internal.i <= gMAX_INDEX_TARGETS DO
						refCommand ACCESS ADR(Commands[internal.i]);
				
						IF refCommand.mask > 0 THEN
							// Select movement type based on the AxisMask for the target
							IF refCommand.mask <= 3 THEN
								cmd.moveInPlane := FALSE;
								subState := 200;
	  						ELSIF refCommand.mask <= 32 THEN
								cmd.move6D := FALSE;
								subState := 300;
							ELSIF refCommand.mask = sArc THEN
								cmd.moveArc := FALSE;
								subState := 400;
							ELSIF refCommand.mask = sRotary THEN
								cmd.moveRotary := FALSE;
								subState := 500;
							ELSIF refCommand.mask = sWait THEN
								cmd.wait := FALSE;
								subState := 600;
							ELSIF refCommand.mask = sLevitate THEN
								cmd.levitate := FALSE;
								subState := 700;
							ELSIF refCommand.mask = sSpin THEN
								cmd.spin := FALSE;
								subState := 800;
							ELSIF refCommand.mask = sWaitCmdLb THEN
								cmd.waitCmdLb := FALSE;
								subState := 900;
							ELSE
								state := brfi6DMOVEQUEUE_ERROR;
								ErrorID := 666;
								FailedCommand := refCommand;
							END_IF;
							
							internal.i := internal.i + 1;
							EXIT;
						END_IF;
				
						internal.i := internal.i + 1;
					END_WHILE;
					
				200:
					// ------------------------------------------------------------------------------------------------------------
					IF onStateEntry THEN
	  					brsmemset(ADR(fb.MoveInPlane.Parameters), 0, SIZEOF(fb.MoveInPlane.Parameters));
						
						// Use target velocity/acceleration when available. Use values from parameters as fallback values
						fb.MoveInPlane.Parameters.Velocity := SEL(refCommand.inPlane.Velocity > 0, Parameters.velocity_xy, refCommand.inPlane.Velocity);
						fb.MoveInPlane.Parameters.Acceleration := SEL(refCommand.inPlane.Acceleration > 0, Parameters.acceleration, refCommand.inPlane.Acceleration);
						fb.MoveInPlane.Parameters.EndVelocity := refCommand.inPlane.EndVelocity;
						
						fb.MoveInPlane.Parameters.Path := refCommand.inPlane.Path;
						fb.MoveInPlane.Parameters.Radius := refCommand.inPlane.Radius;
						fb.MoveInPlane.Parameters.Mode := refCommand.inPlane.Mode;
							
						IF refCommand.inPlane.Mode = mcACP6D_MOVE_ABSOLUTE THEN
							fb.MoveInPlane.Parameters.Position.X := SEL(refCommand.mask.0, internal.position.X, refCommand.inPlane.Position.X);
							fb.MoveInPlane.Parameters.Position.Y := SEL(refCommand.mask.1, internal.position.Y, refCommand.inPlane.Position.Y);
							
							// Update shuttles current position for next command
							internal.position.X := fb.MoveInPlane.Parameters.Position.X;
							internal.position.Y := fb.MoveInPlane.Parameters.Position.Y;
						ELSE
							fb.MoveInPlane.Parameters.Position.X := SEL(refCommand.mask.0, 0, refCommand.inPlane.Position.X);
							fb.MoveInPlane.Parameters.Position.Y := SEL(refCommand.mask.1, 0, refCommand.inPlane.Position.Y);
							
							// Update shuttles current position for next command
							internal.position.X := internal.position.X + fb.MoveInPlane.Parameters.Position.X;
							internal.position.Y := internal.position.Y + fb.MoveInPlane.Parameters.Position.Y;
						END_IF;
					END_IF;
					
					cmd.moveInPlane := TRUE;
			
					IF fb.MoveInPlane.Acknowledge THEN
						refAllCommandsDone ACCESS ADR(fb.MoveInPlane.Done);
						subState := 100;
					ELSIF fb.MoveInPlane.Error THEN
						ErrorID := fb.MoveInPlane.ErrorID;
						FailedCommand.inPlane := fb.MoveInPlane.Parameters;
						state := brfi6DMOVEQUEUE_ERROR;
					END_IF;
				
				300:
					// ------------------------------------------------------------------------------------------------------------
					IF onStateEntry THEN
						
						brsmemset(ADR(fb.Move6D.Parameters), 0, SIZEOF(fb.Move6D.Parameters));
						fb.Move6D.Parameters := refCommand.inSpace;
						
						// Use target velocity/acceleration when available. Use values from parameters as fallback values
						IF fb.Move6D.Parameters.InPlane.Velocity = 0 THEN fb.Move6D.Parameters.InPlane.Velocity := Parameters.velocity_xy; END_IF;
						IF fb.Move6D.Parameters.InPlane.Acceleration = 0 THEN fb.Move6D.Parameters.InPlane.Acceleration := Parameters.acceleration; END_IF;
						
						IF fb.Move6D.Parameters.ShortAxis.Velocity.Z = 0 THEN fb.Move6D.Parameters.ShortAxis.Velocity.Z := Parameters.velocity_short; END_IF;
						IF fb.Move6D.Parameters.ShortAxis.Velocity.Rx = 0 THEN fb.Move6D.Parameters.ShortAxis.Velocity.Rx := Parameters.velocity_short; END_IF;
						IF fb.Move6D.Parameters.ShortAxis.Velocity.Ry = 0 THEN fb.Move6D.Parameters.ShortAxis.Velocity.Ry := Parameters.velocity_short; END_IF;
						IF fb.Move6D.Parameters.ShortAxis.Velocity.Rz = 0 THEN fb.Move6D.Parameters.ShortAxis.Velocity.Rz := Parameters.velocity_short; END_IF;
						
						IF refCommand.moveMode6D = mcACP6D_MOVE_ABSOLUTE THEN
							// Set absolute target
							fb.Move6D.Parameters.InPlane.Position.X := SEL(refCommand.mask.0,  internal.position.X, refCommand.inSpace.InPlane.Position.X);
							fb.Move6D.Parameters.InPlane.Position.Y := SEL(refCommand.mask.1,  internal.position.Y, refCommand.inSpace.InPlane.Position.Y);
							fb.Move6D.Parameters.ShortAxis.Position.Z := SEL(refCommand.mask.2,  internal.position.Z, refCommand.inSpace.ShortAxis.Position.Z);
							fb.Move6D.Parameters.ShortAxis.Position.Rx := SEL(refCommand.mask.3,  internal.position.Rx, refCommand.inSpace.ShortAxis.Position.Rx);
							fb.Move6D.Parameters.ShortAxis.Position.Ry := SEL(refCommand.mask.4,  internal.position.Ry, refCommand.inSpace.ShortAxis.Position.Ry);
							fb.Move6D.Parameters.ShortAxis.Position.Rz := SEL(refCommand.mask.5,  internal.position.Rz, refCommand.inSpace.ShortAxis.Position.Rz);
						END_IF
						
						IF refCommand.moveMode6D = mcACP6D_MOVE_RELATIVE THEN
							// Calculate relative target
							fb.Move6D.Parameters.InPlane.Position.X := SEL(refCommand.mask.0,  internal.position.X, internal.position.X + refCommand.inSpace.InPlane.Position.X);
							fb.Move6D.Parameters.InPlane.Position.Y := SEL(refCommand.mask.1,  internal.position.Y, internal.position.Y + refCommand.inSpace.InPlane.Position.Y);
							fb.Move6D.Parameters.ShortAxis.Position.Z := SEL(refCommand.mask.2,  internal.position.Z, internal.position.Z + refCommand.inSpace.ShortAxis.Position.Z);
							fb.Move6D.Parameters.ShortAxis.Position.Rx := SEL(refCommand.mask.3,  internal.position.Rx, internal.position.Rx + refCommand.inSpace.ShortAxis.Position.Rx);
							fb.Move6D.Parameters.ShortAxis.Position.Ry := SEL(refCommand.mask.4,  internal.position.Ry, internal.position.Ry + refCommand.inSpace.ShortAxis.Position.Ry);
							fb.Move6D.Parameters.ShortAxis.Position.Rz := SEL(refCommand.mask.5,  internal.position.Rz, internal.position.Rz + refCommand.inSpace.ShortAxis.Position.Rz);
						END_IF;
							
						// Update current shuttle position based on latest move command. 6D move moves always naturally to absolute
						// positions so we can just set the parameter positions as our current position now
						internal.position.X := fb.Move6D.Parameters.InPlane.Position.X;
						internal.position.Y := fb.Move6D.Parameters.InPlane.Position.Y;
						internal.position.Z := fb.Move6D.Parameters.ShortAxis.Position.Z;
						internal.position.Rx := fb.Move6D.Parameters.ShortAxis.Position.Rx;
						internal.position.Ry := fb.Move6D.Parameters.ShortAxis.Position.Ry;
						internal.position.Rz := fb.Move6D.Parameters.ShortAxis.Position.Rz;			
					END_IF;
				
					cmd.move6D := TRUE;
						
					IF fb.Move6D.Acknowledge THEN
						refAllCommandsDone ACCESS ADR(fb.Move6D.Done);
						subState := 100;
					ELSIF fb.Move6D.Error THEN
						ErrorID := fb.Move6D.ErrorID;
						FailedCommand.inSpace := fb.Move6D.Parameters;
						state := brfi6DMOVEQUEUE_ERROR;
					END_IF;
				
				400:
					// ------------------------------------------------------------------------------------------------------------
					IF onStateEntry THEN
						fb.MoveArc.Parameters := refCommand.arc;
						fb.MoveArc.Parameters.Velocity := SEL(refCommand.arc.Velocity > 0, Parameters.velocity_xy, refCommand.arc.Velocity);
						fb.MoveArc.Parameters.Acceleration := SEL(refCommand.arc.Acceleration > 0, Parameters.acceleration, refCommand.arc.Acceleration);
						
						// Radius move mode
						IF fb.MoveArc.Parameters.Option = mcACP6D_ARC_RADIUS THEN
							IF fb.MoveArc.Parameters.Mode = mcACP6D_MOVE_ABSOLUTE THEN
								internal.position.X := fb.MoveArc.Parameters.Radius.Position.X;
								internal.position.Y := fb.MoveArc.Parameters.Radius.Position.Y;	
							END_IF
							
							IF fb.MoveArc.Parameters.Mode = mcACP6D_MOVE_RELATIVE THEN
								internal.position.X := internal.position.X + fb.MoveArc.Parameters.Radius.Position.X;
								internal.position.Y := internal.position.Y + fb.MoveArc.Parameters.Radius.Position.Y;	
							END_IF
						END_IF
						
						// Angular move mode
						IF fb.MoveArc.Parameters.Option = mcACP6D_ARC_ANGULAR THEN
							IF fb.MoveArc.Parameters.Mode = mcACP6D_MOVE_ABSOLUTE THEN
								internal.Xc := fb.MoveArc.Parameters.Angular.Center.X;
								internal.Yc := fb.MoveArc.Parameters.Angular.Center.Y;
							END_IF
							
							IF fb.MoveArc.Parameters.Mode = mcACP6D_MOVE_RELATIVE THEN
								internal.Xc := internal.position.X + fb.MoveArc.Parameters.Angular.Center.X;
								internal.Yc := internal.position.Y + fb.MoveArc.Parameters.Angular.Center.Y;
							END_IF
						END_IF
						
						internal.dx := internal.position.X - internal.Xc;
						internal.dy := internal.position.Y - internal.Yc;
						
						// Calculate end position after arc move
						internal.radius := SQRT(EXPT(internal.position.X - internal.Xc, 2) + EXPT(internal.position.Y - internal.Yc, 2));
						internal.angle := brmatan2(internal.dy, internal.dx);
						
						// Natural rotation direction for trigonometric functions is CCW so if we are
						// moving CW then we need to invert the angle value before summing
						IF fb.MoveArc.Parameters.Direction = mcACP6D_ARC_COUNTER_CLOCKWISE THEN
							internal.angle := internal.angle + fb.MoveArc.Parameters.Angular.Angle;	
						ELSE
	  						internal.angle := internal.angle - fb.MoveArc.Parameters.Angular.Angle;	
						END_IF;
						
						internal.position.X := internal.Xc + internal.radius * COS(internal.angle);
						internal.position.Y := internal.Yc + internal.radius * SIN(internal.angle);
					END_IF
						
					cmd.moveArc := TRUE;
					
					IF fb.MoveArc.Acknowledge THEN
						refAllCommandsDone ACCESS ADR(fb.MoveArc.Done);
						subState := 100;
					ELSIF fb.MoveArc.Error THEN
						ErrorID := fb.MoveArc.ErrorID;
						FailedCommand.arc := fb.MoveArc.Parameters;
						state := brfi6DMOVEQUEUE_ERROR;
					END_IF;

				500:
					// ------------------------------------------------------------------------------------------------------------
					IF onStateEntry THEN
						fb.RotaryMotion.Parameters := refCommand.rotary;
						fb.RotaryMotion.Parameters.Velocity := SEL(refCommand.rotary.Velocity > 0, Parameters.velocity_rotary, refCommand.rotary.Velocity);
						fb.RotaryMotion.Parameters.Acceleration := SEL(refCommand.rotary.Acceleration > 0, Parameters.acceleration_rotary, refCommand.rotary.Acceleration);
					END_IF;
					
					cmd.moveRotary := TRUE;
				
					IF fb.RotaryMotion.Acknowledge THEN
						refAllCommandsDone ACCESS ADR(fb.RotaryMotion.Done);
						subState := 100;
					ELSIF fb.RotaryMotion.Error THEN
						ErrorID := fb.RotaryMotion.ErrorID;
						FailedCommand.rotary := fb.RotaryMotion.Parameters;
						state := brfi6DMOVEQUEUE_ERROR;
					END_IF;
				
				600:
					// ------------------------------------------------------------------------------------------------------------
					IF onStateEntry THEN
						fb.ShWaitTime.Delay := refCommand.waitTime;	
					END_IF;
				
					cmd.wait := TRUE;
					
					IF fb.ShWaitTime.Acknowledge THEN
						refAllCommandsDone ACCESS ADR(fb.ShWaitTime.Done);
						subState := 100;
					ELSIF fb.ShWaitTime.Error THEN
						ErrorID := fb.ShWaitTime.ErrorID;
						FailedCommand.waitTime := fb.ShWaitTime.Delay;
						state := brfi6DMOVEQUEUE_ERROR;
					END_IF;
				
				700:
					// ------------------------------------------------------------------------------------------------------------
					IF onStateEntry THEN
						fb.ShLevitation.Parameters := refCommand.levitation;
					END_IF;
					
					cmd.levitate := TRUE;
				
					IF fb.ShLevitation.Acknowledge THEN
						refAllCommandsDone ACCESS ADR(fb.ShLevitation.Done);
						subState := 100;
					ELSIF fb.ShLevitation.Error THEN
						ErrorID := fb.ShLevitation.ErrorID;
						FailedCommand.levitation := fb.ShLevitation.Parameters;
						state := brfi6DMOVEQUEUE_ERROR;
					END_IF;
				
				800:
					// ------------------------------------------------------------------------------------------------------------
					IF onStateEntry THEN
						fb.RotaryMotionSpin.Parameters := refCommand.spin;
						fb.RotaryMotionSpin.Parameters.Velocity := SEL(refCommand.spin.Velocity > 0, Parameters.velocity_rotary, refCommand.spin.Velocity);
						fb.RotaryMotionSpin.Parameters.Acceleration := SEL(refCommand.spin.Acceleration > 0, Parameters.acceleration_rotary, refCommand.spin.Acceleration);
					END_IF;
					
					cmd.spin := TRUE;
				
					IF fb.RotaryMotionSpin.Acknowledge THEN
						refAllCommandsDone ACCESS ADR(fb.RotaryMotionSpin.Done);
						subState := 100;
					ELSIF fb.RotaryMotionSpin.Error THEN
						ErrorID := fb.RotaryMotionSpin.ErrorID;
						FailedCommand.spin := fb.RotaryMotionSpin.Parameters;
						state := brfi6DMOVEQUEUE_ERROR;
					END_IF;
				
				900:
					// ------------------------------------------------------------------------------------------------------------
					IF onStateEntry THEN
						fb.ShWaitCmdLb.TriggerXID := refCommand.waitCmdLb.monitoredShuttleID;
						fb.ShWaitCmdLb.CommandLabel := refCommand.waitCmdLb.commandLabel;
						fb.ShWaitCmdLb.LabelType := refCommand.waitCmdLb.labelType;
						fb.ShWaitCmdLb.TriggerType := refCommand.waitCmdLb.triggerType;
					END_IF;
					
					cmd.waitCmdLb := TRUE;
				
					IF fb.ShWaitCmdLb.Acknowledge THEN
						refAllCommandsDone ACCESS ADR(fb.ShWaitCmdLb.Done);
						subState := 100;
					ELSIF fb.ShWaitCmdLb.Error THEN
						ErrorID := fb.ShWaitCmdLb.ErrorID;
						FailedCommand.waitCmdLb := refCommand.waitCmdLb;
						state := brfi6DMOVEQUEUE_ERROR;
					END_IF;
			END_CASE;


		brfi6DMOVEQUEUE_DONE:	
			// 
			// ------------------------------------------------------
			actions.acknowledge := TRUE;
			
			// If pointer is not set then just indicate all done as this means queue contained
			// no valid commands and nothing was queued to 6D controller. 
			// Otherwise wait for the last called function block to finish to indicate shuttles has
			// executed all of its queued commands
			IF ADR(refAllCommandsDone) = 0 THEN
				actions.done := TRUE;
			ELSE
				actions.done := refAllCommandsDone;
			END_IF;
			
		brfi6DMOVEQUEUE_ERROR:	
			// 
			// ------------------------------------------------------
			FailedCommandIndex := internal.i - 1;
			actions.error := TRUE;
                                
	END_CASE;	

	// State change events
	// -------------------------------------------------------------------	
	onStateEntry := (state <> internal.lastState) OR (subState <> internal.lastSubState);
	
	IF state <> internal.lastState THEN
		subState := 0;
		brsmemset(ADR(actions), 0, SIZEOF(actions));
		internal.lastState := state;
	END_IF;

	// Reset current state actions also when substate changes
	IF subState <> internal.lastSubState THEN
		internal.lastSubState := subState;
		LastExecutedState := internal.lastSubState;
		brsmemset(ADR(actions), 0, SIZEOF(actions));
	END_IF

    
	// Function calls
	// ========================================================================================================
	fb.ShGetInfo.Shuttle := ADR(Shuttle);
	fb.ShGetInfo.Execute := actions.getInfo;
	fb.ShGetInfo();
	
	fb.MoveInPlane.Shuttle := ADR(Shuttle);
	fb.MoveInPlane.Execute := cmd.moveInPlane;
	fb.MoveInPlane();
	
	fb.Move6D.Shuttle := ADR(Shuttle);
	fb.Move6D.Execute := cmd.move6D;
	fb.Move6D();
	
	fb.MoveArc.Shuttle := ADR(Shuttle);
	fb.MoveArc.Execute := cmd.moveArc;
	fb.MoveArc();
	
	fb.RotaryMotion.Shuttle := ADR(Shuttle);
	fb.RotaryMotion.Execute := cmd.moveRotary;
	fb.RotaryMotion();
	
	fb.ShWaitTime.Shuttle := ADR(Shuttle);
	fb.ShWaitTime.Execute := cmd.wait;
	fb.ShWaitTime();
	
	fb.ShLevitation.Shuttle := ADR(Shuttle);
	fb.ShLevitation.Execute := cmd.levitate;
	fb.ShLevitation();
	
	fb.RotaryMotionSpin.Shuttle := ADR(Shuttle);
	fb.RotaryMotionSpin.Execute := cmd.spin;
	fb.RotaryMotionSpin();
	
	fb.ShWaitCmdLb.Shuttle := ADR(Shuttle);
	fb.ShWaitCmdLb.Execute := cmd.waitCmdLb;
	fb.ShWaitCmdLb();
	
	// Outputs
	// ========================================================================================================
	Done := actions.done;
	Acknowledge := actions.acknowledge;
	Error := actions.error;

END_FUNCTION_BLOCK

