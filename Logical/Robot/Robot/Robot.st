PROGRAM _INIT
	
    // Access the task interface
	task ACCESS ADR(gRobot);

	// Check for simulator
	task.IsSimulated := DiagCpuIsSimulated();
	
	fb.BrAbbRwsCore_0.Parameters.UserName := 'Admin';
	fb.BrAbbRwsCore_0.Parameters.Password := 'robotics';
	fb.BrAbbRwsCore_0.Parameters.WebServerVersion := BR_ABB_RWS_VERSION_V2;
	fb.BrAbbRwsCore_0.Parameters.HostPort := 443;
	fb.BrAbbRwsCore_0.Parameters.Timeout := 0;
	fb.BrAbbRwsCore_0.Parameters.SecureConfigName := 'mySSLConfig';
	
	IF DiagCpuIsSimulated() THEN
		fb.BrAbbRwsCore_0.Parameters.ServerIP := '127.0.0.1';
	ELSE
		fb.BrAbbRwsCore_0.Parameters.ServerIP := '192.168.125.1';
	END_IF;
	
	fb.BrAbbRwsVariable_poll.Parameters.Module := 'TeknologiaDemo25';
	fb.BrAbbRwsVariable_poll.Parameters.Task := 'T_ROB1';
	fb.BrAbbRwsVariable_write.Parameters.Module := 'TeknologiaDemo25';
	fb.BrAbbRwsVariable_write.Parameters.Task := 'T_ROB1';
	
END_PROGRAM
	
PROGRAM _CYCLIC
	
    // Access task interface
    // =================================================================================================================
    task ACCESS ADR(gRobot);


    // Inputs
    // =================================================================================================================
    IF NOT task.Input.Force THEN
		task.Input.Command.Home := gMain.Output.Command.robHome;
		task.Input.Command.GetCandy := gMain.Output.Command.robGetPrize;
		task.Input.Command.Dance := gMain.Output.Command.robDance;
		task.Input.Command.GiveCandy := gMain.Output.Command.robGivePrize;
		task.Input.Command.PickUp := gMain.Output.Command.robPickup;
	END_IF
	
	task.Error.Active := fb.BrAbbRwsCore_0.Error OR fb.BrAbbRwsGetState_0.Error;
	
	IF gRobot.Input.Command.HardReset THEN
		gRobot.Input.Command.HardReset := FALSE;
		task.State := ROBOT_IDLE;
		task.SubState := 0;
	END_IF;
	
	// Task state machine
    // =================================================================================================================
    CASE task.State OF
        ROBOT_INITIALIZE:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Initializing';
					// ---------------------------------------------------------------------------------	
					fb.BrAbbRwsCore_0.Enable := FALSE;    
					brsmemset(ADR(local), 0, SIZEOF(local));
					task.SubState := 10;
				10:
					task.StateInfo := 'Connecting to robot';
					// ---------------------------------------------------------------------------------	
					fb.BrAbbRwsCore_0.Enable := TRUE;
				
					IF fb.BrAbbRwsCore_0.Active THEN
						task.State := ROBOT_IDLE;	
						fb.BrAbbRwsGetState_0.Ident := fb.BrAbbRwsCore_0.Ident;	
						fb.BrAbbRwsVariable_poll.Ident := fb.BrAbbRwsCore_0.Ident;	
						fb.BrAbbRwsVariable_write.Ident := fb.BrAbbRwsCore_0.Ident;	
						local.readRobotValues := TRUE;
						fb.BrAbbRwsVariable_write.Enable := TRUE;
					ELSIF fb.BrAbbRwsCore_0.Error THEN
						task.Error.Code := fb.BrAbbRwsCore_0.StatusID;
						task.SubState := 30;
					END_IF;
			END_CASE;
				
		ROBOT_IDLE:
			task.StateInfo := 'Ready for commands';
			// ---------------------------------------------------------------------------------
			local.actions.state.ready_for_next_command := TRUE;
			
			IF task.Input.Command.Home THEN
				task.Input.RobCommandNum := 1;
				task.State := ROBOT_CMD_NORMAL;
				
			ELSIF task.Input.Command.Dance THEN
				task.Input.RobCommandNum := 3;
				task.State := ROBOT_CMD_NORMAL;
				
			ELSIF task.Input.Command.GetCandy THEN
				task.Input.RobCommandNum := 4;
				task.State := ROBOT_CMD_NORMAL;
				
			ELSIF task.Input.Command.PickUp THEN
				task.Input.RobCommandNum := 2;
				task.State := ROBOT_CMD_TARGET;
	  
			ELSIF task.Input.Command.GiveCandy THEN
				task.Input.RobCommandNum := 5;
				task.State := ROBOT_CMD_TARGET;		
			END_IF;

		ROBOT_CMD_NORMAL:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Execute command';
					// ---------------------------------------------------------------------------------
					fb.BrAbbRwsVariable_write.Parameters.Variable := 'nAcoposCmd';
					fb.BrAbbRwsVariable_write.Value.DataAdress := ADR(task.Input.RobCommandNum);
					fb.BrAbbRwsVariable_write.Value.DataType := BR_ABB_RWS_VAR_NUM;
					
					local.actions.substate.write := TRUE;
					
					IF fb.BrAbbRwsVariable_write.Done THEN
	  					task.SubState := 10;
					ELSIF fb.BrAbbRwsVariable_write.Error THEN
						task.State := ROBOT_COMMAND_ERROR;
					END_IF;
				
				10:
					task.StateInfo := 'Wait robot to complete';
					// ---------------------------------------------------------------------------------
					IF task.Output.Status.RobPhaseDone AND (task.Output.Status.RobPhaseNum = task.Input.RobCommandNum) THEN
						task.State := ROBOT_COMMAND_DONE;
					END_IF;
			END_CASE;
				
		ROBOT_CMD_TARGET:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Write X';
					// ---------------------------------------------------------------------------------
					local.robTargetX_mm := 1000 * task.Input.RobTargetX;
					
					fb.BrAbbRwsVariable_write.Parameters.Variable := 'nPos_X';
					fb.BrAbbRwsVariable_write.Value.DataAdress := ADR(local.robTargetX_mm);
					fb.BrAbbRwsVariable_write.Value.DataType := BR_ABB_RWS_VAR_NUM;
					
					local.actions.substate.write := TRUE;
					
					IF fb.BrAbbRwsVariable_write.Done THEN
						task.SubState := 10;
					ELSIF fb.BrAbbRwsVariable_write.Error THEN
						task.State := ROBOT_COMMAND_ERROR;
					END_IF;
					
				10:
					task.StateInfo := 'Write Y';
					// ---------------------------------------------------------------------------------
					local.robTargetY_mm := 1000 * task.Input.RobTargetY;
					
					fb.BrAbbRwsVariable_write.Parameters.Variable := 'nPos_Y';
					fb.BrAbbRwsVariable_write.Value.DataAdress := ADR(local.robTargetY_mm);
					fb.BrAbbRwsVariable_write.Value.DataType := BR_ABB_RWS_VAR_NUM;
					
					local.actions.substate.write := TRUE;
					
					IF fb.BrAbbRwsVariable_write.Done THEN
						task.SubState := 20;
					ELSIF fb.BrAbbRwsVariable_write.Error THEN
						task.State := ROBOT_COMMAND_ERROR;
					END_IF;
					
				20:
					task.StateInfo := 'Write command num';
					// ---------------------------------------------------------------------------------
					fb.BrAbbRwsVariable_write.Parameters.Variable := 'nAcoposCmd';
					fb.BrAbbRwsVariable_write.Value.DataAdress := ADR(task.Input.RobCommandNum);
					fb.BrAbbRwsVariable_write.Value.DataType := BR_ABB_RWS_VAR_NUM;
					
					local.actions.substate.write := TRUE;
					
					IF fb.BrAbbRwsVariable_write.Done THEN
						task.SubState := 30;
					ELSIF fb.BrAbbRwsVariable_write.Error THEN
						task.State := ROBOT_COMMAND_ERROR;
					END_IF;
				
				30:
					task.StateInfo := 'Wait robot to complete';
					// ---------------------------------------------------------------------------------
					IF task.Output.Status.RobPhaseDone AND (task.Output.Status.RobPhaseNum = task.Input.RobCommandNum) THEN
						task.State := ROBOT_COMMAND_DONE;
					END_IF;
			END_CASE;
			
		ROBOT_COMMAND_DONE:
			CASE task.SubState OF
				0:
					task.StateInfo := 'Write robot nAcoposCmd to 0';
					// ---------------------------------------------------------------------------------
					task.Input.RobCommandNum := 0;
					
					fb.BrAbbRwsVariable_write.Parameters.Variable := 'nAcoposCmd';
					fb.BrAbbRwsVariable_write.Value.DataAdress := ADR(task.Input.RobCommandNum);
					fb.BrAbbRwsVariable_write.Value.DataType := BR_ABB_RWS_VAR_NUM;
					
					local.actions.substate.write := TRUE;
					
					IF fb.BrAbbRwsVariable_write.Done THEN
						task.SubState := 10;
					ELSIF fb.BrAbbRwsVariable_write.Error THEN
						task.State := ROBOT_COMMAND_ERROR;
					END_IF;
					
				10:
					task.StateInfo := 'Waiting robot to indicate it is idle again';
					// ---------------------------------------------------------------------------------	
					IF task.Output.Status.RobReady AND (NOT task.Output.Status.RobPhaseDone) AND (task.Input.RobCommandNum = 0) THEN
						task.SubState := 20;
					END_IF;
		  
				20:
					task.StateInfo := 'Command done - waiting command input reset';
					// ---------------------------------------------------------------------------------		
					local.actions.substate.command_done := TRUE;
			
					IF brsmemcmp(ADR(task.Input.Command), ADR(no_command), SIZEOF(no_command)) = 0 THEN
						task.State := ROBOT_IDLE;
					END_IF;
			END_CASE;
			
		ROBOT_COMMAND_ERROR:
			task.StateInfo := 'Command error';
			// ---------------------------------------------------------------------------------
			local.actions.substate.command_error := TRUE;
			local.actions.substate.write_reset := TRUE;
			
			IF brsmemcmp(ADR(task.Input.Command), ADR(no_command), SIZEOF(no_command)) = 0 THEN
				task.State := ROBOT_IDLE;
			END_IF;
			
			
		ROBOT_ERROR:
			// Error occured during execution
            // ---------------------------------------------------------------------------------
            IF task.Error.Acknowledge THEN
                brsmemset(ADR(task.Error), 0, SIZEOF(task.Error));
                task.State := ROBOT_INITIALIZE;
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
		task.StateInfo := '';
    END_IF

    // Reset current state actions also when substate changes
    IF task.SubState <> local.lastSubState THEN
        local.lastSubState := task.SubState;
		brsmemset(ADR(local.actions.substate), 0, SIZEOF(local.actions.substate));
		task.StateInfo := '';
    END_IF


	// Robot state poll
	// =================================================================================================================
	CASE task.robReadState OF
		0:
			// ---------------------------------------------------------------------------------
			IF local.readRobotValues THEN
				fb.BrAbbRwsGetState_0.Enable := TRUE;
				fb.BrAbbRwsVariable_poll.Enable := TRUE;
				
				IF fb.BrAbbRwsGetState_0.Active AND fb.BrAbbRwsVariable_poll.Active THEN
					
					task.robReadState := 10;
					local.robReadNum := 0;
				END_IF;
			END_IF;
		
		10:
			// ---------------------------------------------------------------------------------
			fb.TON_ReadDelay.IN := TRUE;
			fb.TON_ReadDelay.PT := T#0ms;
		
			IF local.readRobotValues = FALSE THEN
				task.robReadState := 0;
			ELSIF fb.TON_ReadDelay.Q THEN
				fb.TON_ReadDelay.IN := FALSE;
				task.robReadState := 100 + local.robReadNum;
				local.robReadNum := local.robReadNum + 1;
			END_IF;
			
		50:
			// ---------------------------------------------------------------------------------
			fb.TON_ReadDelay.IN := TRUE;
			fb.TON_ReadDelay.PT := T#2s;
		
			task.Output.Status.CommunicationOk := FALSE;
			
			fb.BrAbbRwsGetState_0.Enable := FALSE;
			fb.BrAbbRwsVariable_poll.Enable := FALSE;
			
			IF fb.TON_ReadDelay.Q THEN
				fb.TON_ReadDelay.IN := FALSE;
				IF fb.BrAbbRwsCore_0.Error THEN
	  				task.robReadState := 60;	
				ELSE
					task.robReadState := 0;	
				END_IF;
			END_IF;
			
		60:
			// ---------------------------------------------------------------------------------
			fb.BrAbbRwsCore_0.ErrorReset := TRUE;
			
			IF NOT fb.BrAbbRwsCore_0.Error THEN
				fb.BrAbbRwsCore_0.ErrorReset := FALSE;
				task.robReadState := 0;	
			END_IF;
		
		100:
			// ---------------------------------------------------------------------------------
			fb.BrAbbRwsGetState_0.Parameters.MechUnit := 'ROB1';
			fb.BrAbbRwsGetState_0.Parameters.Enable.ActPosCart := FALSE;
			fb.BrAbbRwsGetState_0.GetState := TRUE;
			
			IF fb.BrAbbRwsGetState_0.Done THEN
				task.Output.Status.CommunicationOk := TRUE;
				task.Output.Status.RobRapidState := fb.BrAbbRwsGetState_0.RapidState;
				task.Output.Status.RobMotorState := fb.BrAbbRwsGetState_0.MotorState;
				task.Output.Status.RobActiveMode := fb.BrAbbRwsGetState_0.ActiveMode;
				task.robReadState := 10;	
			ELSIF fb.BrAbbRwsGetState_0.Error THEN
				task.Output.Status.RobRapidState := fb.BrAbbRwsGetState_0.RapidState;
				task.Output.Status.RobMotorState := fb.BrAbbRwsGetState_0.MotorState;
				task.Output.Status.RobActiveMode := fb.BrAbbRwsGetState_0.ActiveMode;
				task.robReadState := 50;
			END_IF;
		
		101:
			// ---------------------------------------------------------------------------------
			fb.BrAbbRwsVariable_poll.Parameters.Variable := 'bRobotPhaseDone';
			fb.BrAbbRwsVariable_poll.Value.DataAdress := ADR(gRobot.Output.Status.RobPhaseDone);
			fb.BrAbbRwsVariable_poll.Value.DataType := BR_ABB_RWS_VAR_BOOL;
			fb.BrAbbRwsVariable_poll.GetValue := TRUE;
			
			IF fb.BrAbbRwsVariable_poll.Done THEN
				task.robReadState := 10;
			ELSIF fb.BrAbbRwsVariable_poll.Error THEN
				task.robReadState := 50;
			END_IF;
			
		102:
			// ---------------------------------------------------------------------------------
			fb.BrAbbRwsVariable_poll.Parameters.Variable := 'bRobotReady';
			fb.BrAbbRwsVariable_poll.Value.DataAdress := ADR(gRobot.Output.Status.RobReady);
			fb.BrAbbRwsVariable_poll.Value.DataType := BR_ABB_RWS_VAR_BOOL;
			fb.BrAbbRwsVariable_poll.GetValue := TRUE;
			
			IF fb.BrAbbRwsVariable_poll.Done THEN
				task.robReadState := 10;
			ELSIF fb.BrAbbRwsVariable_poll.Error THEN
				task.robReadState := 50;
			END_IF;
			
		103:
			// ---------------------------------------------------------------------------------
			fb.BrAbbRwsVariable_poll.Parameters.Variable := 'bRobotError';
			fb.BrAbbRwsVariable_poll.Value.DataAdress := ADR(gRobot.Output.Status.RobError);
			fb.BrAbbRwsVariable_poll.Value.DataType := BR_ABB_RWS_VAR_BOOL;
			fb.BrAbbRwsVariable_poll.GetValue := TRUE;
			
			IF fb.BrAbbRwsVariable_poll.Done THEN
				task.robReadState := 10;
			ELSIF fb.BrAbbRwsVariable_poll.Error THEN
				task.robReadState := 50;
			END_IF;
			
		104:
			// ---------------------------------------------------------------------------------
			fb.BrAbbRwsVariable_poll.Parameters.Variable := 'nRobotPhase';
			fb.BrAbbRwsVariable_poll.Value.DataAdress := ADR(gRobot.Output.Status.RobPhaseNum);
			fb.BrAbbRwsVariable_poll.Value.DataType := BR_ABB_RWS_VAR_NUM;
			fb.BrAbbRwsVariable_poll.GetValue := TRUE;
			
			IF fb.BrAbbRwsVariable_poll.Done THEN
				task.robReadState := 1000;
			ELSIF fb.BrAbbRwsVariable_poll.Error THEN
				task.robReadState := 50;
			END_IF;
		
		1000:
			task.robReadState := 10;
			local.robReadNum := 0;
	END_CASE;
	
	IF task.robReadState <> local.robReadStateLast THEN
		local.robReadStateLast := task.robReadState;
		fb.BrAbbRwsGetState_0.GetState := FALSE;
		fb.BrAbbRwsVariable_poll.GetValue := FALSE;
		fb.BrAbbRwsVariable_poll.SetValue := FALSE;
		fb.BrAbbRwsVariable_poll.SetValue := FALSE;
	END_IF;
	
	
    // Function calls
    // =================================================================================================================
    fb.BrAbbRwsCore_0();
	fb.TON_ReadDelay();
	fb.BrAbbRwsGetState_0();
	fb.BrAbbRwsVariable_poll();
	
	fb.BrAbbRwsVariable_read.Enable := local.actions.substate.rws_read;
	fb.BrAbbRwsVariable_read.GetValue := TRUE;
	fb.BrAbbRwsVariable_read.SetValue := TRUE;
	fb.BrAbbRwsVariable_read();
	
	fb.BrAbbRwsVariable_write.GetValue := FALSE;
	fb.BrAbbRwsVariable_write.SetValue := local.actions.substate.write;
	fb.BrAbbRwsVariable_write.ErrorReset := local.actions.substate.write_reset;
	fb.BrAbbRwsVariable_write();
	
	fb.TON_DoneDelay.IN := local.actions.substate.delay;
	fb.TON_DoneDelay.PT := T#1s;
	fb.TON_DoneDelay();

    // Task outputs
    // =================================================================================================================
	task.Output.Status.CommandDone := local.actions.substate.command_done;
	task.Output.Status.CommandError := local.actions.substate.command_error;
	task.Output.Status.ReadyForNextCommand := local.actions.state.ready_for_next_command;
	
	
END_PROGRAM
	
PROGRAM _EXIT
	
//	WHILE fb.BrAbbRwsGetState_0.Active DO
//		fb.BrAbbRwsGetState_0(Enable := FALSE);
//	END_WHILE
//		
//	WHILE fb.BrAbbRwsVariable_poll.Active DO
//		fb.BrAbbRwsVariable_poll(Enable := FALSE);
//	END_WHILE
//	
//	task.robReadState := 100;
//	task.robReadState := 0;

END_PROGRAM