
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	(*
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
	*)

	
	
	IF gHMI.Game.NewGame OR gHMI.Game.ExitGame THEN
		brsmemset(ADR(gHMI.Game),0,SIZEOF(gHMI.Game));
	END_IF;
	
	TON_Reset.IN := gHMI.General.ResetPLC;
	TON_Reset.PT := TIME#5s;
	TON_Reset;
	
	IF TON_Reset.Q THEN
		SYSreset(1,1);
	END_IF;
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

