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
					IF gRobot.Output.Status.CommunicationOk AND gRobot.Output.Status.RobReady THEN
						task.SubState := 10;	
					END_IF;
					
					IF task.IsSimulated THEN
						task.State := MAIN_IDLE;
					END_IF;
				
				10:
					task.StateInfo := 'Command robot to home';
					// ---------------------------------------------------------------------------------		
					local.actions.substate.robHome := TRUE;
					
					IF gRobot.Output.Status.RobPhaseDone THEN
						task.SubState := 20;
					END_IF;
					
				20:
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
					task.StateInfo := '6D Shuttles to home';
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
				
			ELSIF task.Input.Command.StartGame THEN
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
						task.SubState := 10;
					END_IF;
					
				10:
					task.StateInfo := 'Wait 6D controller to startup';
					// ---------------------------------------------------------------------------------			
					IF gAcp6D.Output.Status.Initialized THEN
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
						task.SubState := 200;
					END_IF;
				
				200:
					task.StateInfo := 'Shuffle';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.br6dSimpleShuffle := TRUE;
					
					IF gAcp6D.Output.Status.CommandDone THEN
						task.SubState := 210;
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
						IF gAcp6D.Output.ShuttleUserSelected.index = gAcp6D.Output.ShuttleWithPayload.index THEN
							// WIN!!
							task.SubState := 300;
						ELSE
							// LOSE!
							task.SubState := 400;
						END_IF;
					END_IF;
				
				400: 
					task.StateInfo := 'Robot pickup cup from payload shuttle';
					// ---------------------------------------------------------------------------------			
					gRobot.Input.RobTargetX := gAcp6D.Output.ShuttleWithPayload.X;
					gRobot.Input.RobTargetY := gAcp6D.Output.ShuttleWithPayload.Y;
					local.actions.substate.robPickup := TRUE;
					
					IF gRobot.Output.Status.CommandDone THEN
						task.SubState := 420;
					END_IF;
				
				420: 
					task.StateInfo := 'Robot pickup cup from payload shuttle';
					// ---------------------------------------------------------------------------------			
					local.actions.substate.robHome := TRUE;
					local.actions.substate.br6dHome := TRUE;
					
					IF gRobot.Output.Status.CommandDone AND gAcp6D.Output.Status.CommandDone THEN
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

	brsmemset(ADR(task.Input.Command), 0, SIZEOF((task.Input.Command)));

    
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
	task.Output.Command.br6dWinDance := local.actions.substate.br6dWinDance;
	task.Output.Command.br6dLoseDance := local.actions.substate.br6dLoseDance;
	task.Output.Command.br6dSelectShuttle := local.actions.substate.br6dSelectShuttle;
	
END_PROGRAM
	
PROGRAM _EXIT
	
END_PROGRAM