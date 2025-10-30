PROGRAM _INIT
    //Variables must be called once to be created
	gCommInput;
	gCommOutput;
	gAssembly6D_1;

	AssemblyReadInfo.Assembly := ADR(gAssembly6D_1);
	AssemblyPowerOn.Assembly := ADR(gAssembly6D_1);
	AssemblyPowerOff.Assembly := ADR(gAssembly6D_1);
	AssemblyReset.Assembly := ADR(gAssembly6D_1);
	AssemblyGetShuttle.Assembly := ADR(gAssembly6D_1);

	//Take the first element for testing
	ShuttleMoveXY.Shuttle := ADR(gShuttleList[0].Ref);
	ShuttleMoveXY.Parameters.Velocity := 0.2; //[m/s]
	ShuttleMoveXY.Parameters.Acceleration := 2.0; //[m/s²]
	ShuttleMoveXY.Parameters.Position.X := 1.14; //[m]
	ShuttleMoveXY.Parameters.Position.Y := 0.66; //[m] 
	ShuttleMoveXY.Parameters.Path := mcACP6D_PATH_DIRECT;
	ShuttleMoveXY.Parameters.Mode := mcACP6D_MOVE_ABSOLUTE;
	
	
	brsstrcpy(ADR(gHMI.Teach.moveString),ADR('[[{"x":60,"y":900,"type":0},{"x":60,"y":300,"type":0},{"x":180,"y":300,"type":0},{"x":180,"y":420,"type":0},{"x":60,"y":420,"type":0},{"x":60,"y":540,"type":0},{"x":180,"y":540,"type":0},{"x":180,"y":660,"type":0},{"x":60,"y":660,"type":0},{"x":60,"y":780,"type":0},{"x":600,"y":840,"type":0}]]'));
	gZones;
END_PROGRAM

//TYPE
//gMainType : 	STRUCT  (*Main control variable datatype*)
//Cmd : gMainCmdType; (*Main commands*)
//Par : gMainParType; (*Main parameter*)
//Status : gMainStatusType; (*Main status*)
//	END_STRUCT;
//gMainCmdType : 	STRUCT  (*Main commands type*)
//Power : BOOL; (*Power on the system*)
//Recover : BOOL; (* Recover the system*)
//ErrorReset : BOOL; (*Reset any active error*)
//	END_STRUCT;
//gMainParType : 	STRUCT  (*Main parameter type*)
//Velocity : REAL;
//Acceleration : REAL;
//	END_STRUCT;
//gMainStatusType : 	STRUCT  (*Main status type*)
//AssemblyState : McAcp6dPLCopenStateEnum; (*Assembly state*)
//ShuttlesPresent : UINT; (*Number of shuttles present on the assembly*)
//	END_STRUCT;
//	END_TYPE


PROGRAM _CYCLIC
	
	
	IF gHMI.General.PlayButton THEN
		IF MAIN_DISABLED = MainState THEN
			gMain.Cmd.Power := TRUE;
		END_IF;
	ELSIF gHMI.General.StopButton THEN
		gMain.Cmd.Power := FALSE;
	ELSIF gHMI.General.ResetButton THEN
		IF MainState = MAIN_ERROR THEN
			gMain.Cmd.ErrorReset := TRUE;
		END_IF;
	END_IF;
	IF gHMI.General.BackToHome THEN
		TON_WaitPageChange.IN := TRUE;
		TON_WaitPageChange.PT := TIME#100ms;
		TON_WaitPageChange;
		IF TON_WaitPageChange.Q THEN
			TON_WaitPageChange.IN := FALSE;
			TON_WaitPageChange;
			gHMI.General.BackToHome := FALSE;
		END_IF;
	END_IF;	
	
	
	IF gHMI.Game.NewGame OR gHMI.Game.ExitGame THEN
		brsmemset(ADR(gHMI.Game),0,SIZEOF(gHMI.Game));
	END_IF;
	
	TON_Reset.IN := gHMI.General.ResetPLC;
	TON_Reset.PT := TIME#5s;
	TON_Reset;
	
	IF TON_Reset.Q THEN
		SYSreset(1,1);
	END_IF;
	
	
	gHMI.Status.Error := BOOL_TO_USINT(MainState = MAIN_ERROR);
	gHMI.Status.ReadyToRun := BOOL_TO_USINT(((MainState = MAIN_READY) OR (MainState = MAIN_DISABLED)) AND NOT USINT_TO_BOOL(gHMI.Status.Running));
	gHMI.Status.Running := BOOL_TO_USINT((MainState = MAIN_READY) AND gFeatureDemo.Active);
	gHMI.Status.Stopped := BOOL_TO_USINT((NOT gFeatureDemo.Active) AND (MainState = MAIN_READY));
	
	
	CASE MainState OF
		MAIN_STARTUP:
			AssemblyReadInfo.Enable := TRUE;
			//Wait for the startup phase to be finished
			IF AssemblyReadInfo.Valid THEN
				IF (AssemblyReadInfo.AssemblyInfo.AssemblyState = mcACP6D_ERRORSTOP) THEN
					MainState := MAIN_ERROR;
				ELSIF (AssemblyReadInfo.AssemblyInfo.AssemblyState <> mcACP6D_STARTUP) THEN
					MainState := MAIN_POWER_OFF;
				END_IF
			END_IF

		MAIN_POWER_OFF:
			AssemblyPowerOff.Execute := TRUE;

			IF AssemblyPowerOff.Done THEN
				AssemblyPowerOff.Execute := FALSE;
				MainState := MAIN_DISABLED;
			ELSIF AssemblyPowerOff.Error OR AssemblyPowerOff.CommandAborted THEN
				MainState := MAIN_ERROR;
			END_IF

		MAIN_DISABLED:
			IF gMain.Cmd.Power THEN
				MainState := MAIN_POWER_ON;
			END_IF

		MAIN_POWER_ON:
			AssemblyPowerOn.Execute := TRUE;

			IF AssemblyPowerOn.Done THEN
				AssemblyPowerOn.Execute := FALSE;
				MainState := MAIN_GET_SHUTTLE;
			ELSIF AssemblyPowerOn.Error OR AssemblyPowerOn.CommandAborted THEN
				MainState := MAIN_ERROR;
			END_IF

		MAIN_GET_SHUTTLE:
			AssemblyGetShuttle.Enable := TRUE;

			IF AssemblyGetShuttle.Valid THEN
				gMain.Status.ShuttlesPresent := AssemblyGetShuttle.TotalCount;

				IF (AssemblyGetShuttle.TotalCount = 0) THEN
					AssemblyGetShuttle.Enable := FALSE;
					MainState := MAIN_READY;
				ELSE
					//Prevent access to wrong memory area
					ShIndex := LIMIT(0, AssemblyGetShuttle.TotalCount - AssemblyGetShuttle.RemainingCount - 1, MAX_INDEX_SHUTTLE);
					//Store information to use it in global commands
					gShuttleList[ShIndex].ID := AssemblyGetShuttle.AdditionalInfo.ShuttleID;
					gShuttleList[ShIndex].Ref := AssemblyGetShuttle.Shuttle;

					IF (AssemblyGetShuttle.RemainingCount > 0) THEN
						AssemblyGetShuttle.Next := TRUE;
						MainState := MAIN_GET_SHUTTLE_WAIT;
					ELSE
						AssemblyGetShuttle.Enable := FALSE;
						MainState := MAIN_READY; 
					END_IF
				END_IF
			ELSIF AssemblyGetShuttle.Error THEN
				MainState := MAIN_ERROR;
			END_IF

		MAIN_GET_SHUTTLE_WAIT:
			AssemblyGetShuttle.Next := FALSE;
			MainState := MAIN_GET_SHUTTLE;

		MAIN_READY:
			IF NOT(gMain.Cmd.Power) THEN
				MainState := MAIN_POWER_OFF;
			END_IF

		MAIN_ERROR:
			IF gMain.Cmd.ErrorReset THEN
				AssemblyReset.Execute := FALSE;
				MainState := MAIN_RESET;
			END_IF

		MAIN_RESET:
			AssemblyReset.Execute := TRUE;

			IF AssemblyReset.Done THEN
				gMain.Cmd.ErrorReset := FALSE;
				AssemblyReset.Execute := FALSE;
				MainState := MAIN_POWER_OFF;
				//Commands which caused error are not reset yet
				AssemblyPowerOff.Execute := FALSE;
				AssemblyPowerOn.Execute := FALSE;
				AssemblyGetShuttle.Enable := FALSE;
				AssemblyGetShuttle.Next := FALSE;
			ELSIF AssemblyReset.Error OR AssemblyReset.CommandAborted THEN
				gMain.Cmd.ErrorReset := FALSE;
				MainState := MAIN_ERROR;
			END_IF
	END_CASE
	
	
	IF gMain.Status.ShuttlesPresent > 0 THEN
	
		FOR i := 0 TO 7 DO 
		
			IF gShuttleList[i].Ref.controlif <> 0 THEN
				gFeatureDemo.FB.ReadInfo[i].Enable := TRUE;
				gFeatureDemo.FB.ReadInfo[i].Shuttle := ADR(gShuttleList[i].Ref);
				gFeatureDemo.FB.ReadInfo[i];
				
				IF gFeatureDemo.FB.ReadInfo[i].Valid THEN
					brsmemcpy(ADR(gShuttles[i]),ADR(gFeatureDemo.FB.ReadInfo[i].ShuttleInfo.Position),SIZEOF(gShuttles[0]));
					gHMI.shuttles[i].X := gFeatureDemo.FB.ReadInfo[i].ShuttleInfo.Position.X;
					gHMI.shuttles[i].Y := gFeatureDemo.FB.ReadInfo[i].ShuttleInfo.Position.Y;
					gHMI.shuttles[i].RZ := gFeatureDemo.FB.ReadInfo[i].ShuttleInfo.Position.Rz;
					gFeatureDemo.FB.ReadInfo[i].Enable := FALSE;
					gFeatureDemo.FB.ReadInfo[i];
				END_IF;
			END_IF;
			
		END_FOR;
		
		
	END_IF;

	
	FeatureAction;
	
	
	
	IF gameTest THEN
		GameAction;
	END_IF;	
	
	R_TRIG_1.CLK := calibrate;
	R_TRIG_1;
	
	IF R_TRIG_1.Q THEN
		FOR z := 0 TO 7 DO
			FeatureShuttles[z].Status.Calibrated := FALSE;	
		END_FOR;
	END_IF;		
	
	IF calibrate THEN
		getShuttleWeights;
		calibrate := NOT done;
	END_IF;
	
	
	IF jsonTest THEN
		jsonTest := FALSE;
		my6Ddata;
		
		
	END_IF;
	


	//Provide the assembly status globally
	gMain.Status.AssemblyState := AssemblyReadInfo.AssemblyInfo.AssemblyState;
	//Call all used function blocks
	AssemblyReadInfo();
	AssemblyPowerOn();
	AssemblyPowerOff();
	AssemblyReset();
	AssemblyGetShuttle();
	ShuttleMoveXY();

END_PROGRAM