
ACTION HmiAction: 
	
	TON_ResetPLC.IN := gHMI.General.ResetPLC;
	TON_ResetPLC.PT := TIME#5s;
	
	TON_ResetPLC;
	
	IF TON_ResetPLC.Q THEN
		SYSreset(1,1);
	END_IF;
	
	
	R_TRIG_0.CLK := gHMI.General.PlayButton;
	R_TRIG_0;
	
	IF R_TRIG_0.Q THEN
		task.Input.Command.StartDemoMode := TRUE;
	END_IF;
	
	R_TRIG_1.CLK := (gHMI.General.StopButton OR gHMI.Game.GameRequested) AND gFeatureDemo.Active;
	R_TRIG_1;
	
	IF R_TRIG_1.Q THEN
		task.Input.Command.StopDemoMode := TRUE;
	END_IF;
	
	gHMI.Status.AllowPlay := (task.State = ACP6D_IDLE);
	gHMI.Status.AllowStop := gFeatureDemo.Active;
//	gHMI.Status.AllowReset := 
	//
	IF gHMI.Game.NewGame OR gHMI.Game.ExitGame THEN
		brsmemset(ADR(gHMI.Game),0,SIZEOF(gHMI.Game));
	END_IF;	
	
	IF gHMI.Game.GameRequested AND gHMI.Status.AllowPlay THEN
		gHMI.Game.GameRequested := FALSE;
		gHMI.Game.OpenGamePage := TRUE;
	END_IF;
	
	
	IF gHMI.Game.GameFinished THEN
		gHMI.Game.EndUserSelection := gHMI.Game.Selection;
	END_IF;
	
	
END_ACTION
