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
            // Initialize
            // ---------------------------------------------------------------------------------			
            IF task.Input.Status.SetupComplete THEN
                brsmemset(ADR(local), 0, SIZEOF(local));
                task.State := MAIN_IDLE;
            END_IF;


        MAIN_IDLE:
            //
            // ---------------------------------------------------------------------------------
			CASE task.SubState OF
				0:
				 task.StateInfo := 'Idling!';
		  

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


    
    // Function calls
    // =================================================================================================================
    // fb.FUNCTION_NAME.Enable := local.actions.executeFunction;


    // Task outputs
    // =================================================================================================================
    // task.Output := XXX;

END_PROGRAM
	
PROGRAM _EXIT
	
END_PROGRAM