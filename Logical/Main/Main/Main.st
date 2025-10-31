PROGRAM _INIT
	
    // Access the task interface
	task ACCESS ADR(gMain);

	// Check for simulator
	task.IsSimulated := DiagCpuIsSimulated();
  
	
END_PROGRAM
	
PROGRAM _CYCLIC
	
    // Access task interface
    // =================================================================================================================
	task ACCESS ADR(gMain);

//	R_TRIG_0.CLK := (gHMI.Game.Mode > 0);
//	R_TRIG_0;
//	
//	IF R_TRIG_0.Q THEN
//		task.Input.Command.StartGame := TRUE;
//	END_IF;
	// Inputs
	// =================================================================================================================
	IF NOT task.Input.Force THEN

	END_IF

	// Task state machine
	// =================================================================================================================
	CASE task.State OF
		MAIN_INITIALIZE:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Wait robot communication';
					// ---------------------------------------------------------------------------------
					IF (gRobot.Output.Status.CommunicationOk AND gRobot.Output.Status.RobReady) OR task.IsSimulated THEN
						task.SubState := 10;	
					END_IF;
				
				10:
					task.StateInfo := 'Command robot to home';
					// ---------------------------------------------------------------------------------		
					local.actions.substate.robHome := TRUE;
					
					IF gRobot.Output.Status.RobPhaseDone OR task.IsSimulated THEN
						task.SubState := 20;
					END_IF;
					
				20:
					task.StateInfo := 'Wait 6D controller to startup';
					// ---------------------------------------------------------------------------------			
					IF gAcp6D.Output.Status.Initialized THEN
						task.SubState := 30;
					END_IF;
					
				30:
					task.StateInfo := '6D Shuttles to home';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.br6dHome := TRUE;
					
					IF gAcp6D.Output.Status.CommandDone THEN
						task.State := MAIN_IDLE;
					END_IF;
			END_CASE;


		MAIN_RESET:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Wait robot communication';
					// ---------------------------------------------------------------------------------
					IF gRobot.Output.Status.CommunicationOk AND gRobot.Output.Status.RobReady THEN
						task.SubState := 10;	
					END_IF;
				
				10:
					task.StateInfo := 'Command robot to home';
					// ---------------------------------------------------------------------------------		
					local.actions.substate.robHome := TRUE;
					
					IF gRobot.Output.Status.RobPhaseDone THEN
						task.SubState := 20;
					END_IF;
					
				20:
					task.StateInfo := 'Wait 6D assmebly to reset';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.br6dReset := TRUE;
					
					IF gAcp6D.Output.Status.CommandDone THEN
						task.SubState := 30;
					END_IF;
					
				30:
					task.StateInfo := '6D Shuttles to home';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.br6dHome := TRUE;
					
					IF gAcp6D.Output.Status.CommandDone THEN
						task.State := MAIN_IDLE;
					END_IF;
			END_CASE;
			
		MAIN_IDLE:
			task.StateInfo := 'Waiting for command';
			// ---------------------------------------------------------------------------------
			IF task.Input.Command.Reset THEN
				task.State := MAIN_RESET;
				
			ELSIF task.Input.Command.StartGame OR gHMI.Game.Mode > 0 THEN
				task.Input.GameMode := gHMI.Game.Mode;
				task.Input.Command.StartGame := FALSE; // dummy - reset caller
			
				task.State := MAIN_GAME;
					
				//			ELSIF task.Input.Command. THEN
				//				task.State := MAIN_;
				//	  
			END_IF;

			
		MAIN_GAME:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Robot to home';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.robHome := TRUE;
					
					IF gRobot.Output.Status.CommandDone THEN
						task.SubState := 20;
					END_IF;

				20:
					task.StateInfo := '6D Shuttles to home';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.br6dHome := TRUE;
					
					IF gAcp6D.Output.Status.CommandDone THEN
						task.SubState := 100;
					END_IF;
				
				100:
					task.StateInfo := 'Find and indicate payload location';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.br6dFindPayload := TRUE;
					
					IF gAcp6D.Output.Status.CommandDone THEN
						task.SubState := 110;
					END_IF;
				
				110:
					task.StateInfo := 'Command robot to pickup payload location';
					// ---------------------------------------------------------------------------------
					gRobot.Input.RobTargetX := gAcp6D.Output.ShuttleWithPayload.X;
					gRobot.Input.RobTargetY := gAcp6D.Output.ShuttleWithPayload.Y;
					local.actions.substate.robPickup := TRUE;
					
					IF gRobot.Output.Status.CommandDone THEN
						task.SubState := 120;
					END_IF;
					
				120:
					task.StateInfo := 'Wait robot to be ready for next command';
					// ---------------------------------------------------------------------------------			
					IF gRobot.Output.Status.ReadyForNextCommand THEN
						task.SubState := 200;
					END_IF;
				
				200:
					task.StateInfo := 'Shuffle';
					// ---------------------------------------------------------------------------------
					CASE task.Input.GameMode OF
						1:
							local.actions.substate.br6dSimpleShuffle := TRUE;	
						2:
		  					local.actions.substate.br6dcircularShuffle := TRUE;
					END_CASE;
					
					local.actions.substate.robDance := TRUE;
					
					IF gAcp6D.Output.Status.CommandDone AND gRobot.Output.Status.CommandDone THEN
						task.SubState := 210;
						gHMI.Game.GameShuffleFinished := TRUE;
					END_IF;
				
				210:
					task.StateInfo := 'Let user select the shuttle';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.br6dSelectShuttle := TRUE;
					
					IF gAcp6D.Output.Status.CommandDone THEN
						task.SubState := 220;
					END_IF;
				
				220: 
					task.StateInfo := 'Robot pickup cup from selected shuttle';
					// ---------------------------------------------------------------------------------			
					gRobot.Input.RobTargetX := gAcp6D.Output.ShuttleUserSelected.X;
					gRobot.Input.RobTargetY := gAcp6D.Output.ShuttleUserSelected.Y;
					local.actions.substate.robPickup := TRUE;
					
					IF gRobot.Output.Status.CommandDone THEN
						gHMI.Game.GameFinished := TRUE;
						IF gAcp6D.Output.ShuttleUserSelected.index = gAcp6D.Output.ShuttleWithPayload.index THEN
							// WIN!!
							task.SubState := 300;
						ELSE
							// LOSE!
							task.SubState := 400;
						END_IF;
					END_IF;
				
					
				300: 
					task.StateInfo := 'Wait robot to be ready for next command';
					// ---------------------------------------------------------------------------------			
					IF gRobot.Output.Status.ReadyForNextCommand THEN
						task.SubState := 310;
					END_IF;
					
				310: 
					task.StateInfo := 'Wait robot to be ready for next command';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.robGetPrize := TRUE;
					local.actions.substate.br6dSpellWin := TRUE;
					
					IF gRobot.Output.Status.CommandDone AND gAcp6D.Output.Status.CommandDone THEN
						task.SubState := 320;
					END_IF;
				
				320:
					task.StateInfo := 'Wait robot to be ready for next command';
					// ---------------------------------------------------------------------------------			
					IF gRobot.Output.Status.ReadyForNextCommand THEN
						task.SubState := 330;
					END_IF;
					
				330: 
					task.StateInfo := 'Wait robot to be ready for next command';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.robGivePrize := TRUE;
					
					IF gRobot.Output.Status.CommandDone THEN
						task.SubState := 1000;
					END_IF;
				
					
				400: 
					task.StateInfo := 'Wait robot to be ready for next command';
					// ---------------------------------------------------------------------------------			
					IF gRobot.Output.Status.ReadyForNextCommand THEN
						task.SubState := 410;
					END_IF;
					
				410: 
					task.StateInfo := 'Robot pickup cup from payload shuttle';
					// ---------------------------------------------------------------------------------			
					gRobot.Input.RobTargetX := gAcp6D.Output.ShuttleWithPayload.X;
					gRobot.Input.RobTargetY := gAcp6D.Output.ShuttleWithPayload.Y;
					local.actions.substate.robPickup := TRUE;
					
					IF gRobot.Output.Status.CommandDone THEN
						task.SubState := 500;
					END_IF;
				
				420: 
					task.StateInfo := 'Robot pickup cup from payload shuttle';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.br6dSpellLose := TRUE;
					
					IF gAcp6D.Output.Status.CommandDone THEN
						task.SubState := 1000;
					END_IF;
				
				1000: 
					task.StateInfo := 'Game end';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.br6dHome := TRUE;
					gHMI.Game.Mode := 0;
					
					IF gAcp6D.Output.Status.CommandDone THEN
						task.State := MAIN_IDLE;
					END_IF;
			END_CASE;
			
		MAIN_ERROR:
			// Error occured during execution
			// ---------------------------------------------------------------------------------
			IF task.Error.Acknowledge THEN
				brsmemset(ADR(task.Error), 0, SIZEOF(task.Error));
				task.State := MAIN_INITIALIZE;
			END_IF;
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
	END_IF

	// Reset current state actions also when substate changes
	IF task.SubState <> local.lastSubState THEN
		local.lastSubState := task.SubState;
		brsmemset(ADR(local.actions.substate), 0, SIZEOF(local.actions.substate));
	END_IF
	
	IF task.OnStateEntry THEN
		task.StateInfo := '';  
	END_IF;


	// Function calls
	// =================================================================================================================
	// fb.FUNCTION_NAME.Enable := local.actions.executeFunction;


	// Task outputs
	// =================================================================================================================
	task.Output.Command.robHome	:= local.actions.substate.robHome;
	task.Output.Command.robPickup := local.actions.substate.robPickup;
	task.Output.Command.robGivePrize := local.actions.substate.robGivePrize;
	task.Output.Command.robGetPrize := local.actions.substate.robGetPrize;
	task.Output.Command.robDance := local.actions.substate.robDance;
	task.Output.Command.br6dReset := local.actions.substate.br6dReset;
	task.Output.Command.br6dHome := local.actions.substate.br6dHome;
	task.Output.Command.br6dFindPayload := local.actions.substate.br6dFindPayload;
	task.Output.Command.br6dSimpleShuffle := local.actions.substate.br6dSimpleShuffle;
	task.Output.Command.br6dcircularShuffle := local.actions.substate.br6dcircularShuffle;
	task.Output.Command.br6dSpellWin := local.actions.substate.br6dSpellWin;
	task.Output.Command.br6dSpellLose := local.actions.substate.br6dSpellLose;
	task.Output.Command.br6dSelectShuttle := local.actions.substate.br6dSelectShuttle;
	task.Output.Command.br6dDance := local.actions.substate.br6dDance;
	
END_PROGRAM
	
PROGRAM _EXIT
	
END_PROGRAM