
PROGRAM _INIT
	(* Insert code here *)
	BrAbbRwsCore_0.Enable := TRUE;
	BrAbbRwsCore_0.Parameters.UserName := 'Admin';
	BrAbbRwsCore_0.Parameters.Password := 'robotics';
	BrAbbRwsCore_0.Parameters.WebServerVersion := BR_ABB_RWS_VERSION_V2;
	BrAbbRwsCore_0.Parameters.HostPort := 443;
	BrAbbRwsCore_0.Parameters.Timeout := 0;
	BrAbbRwsCore_0.Parameters.SecureConfigName := 'mySSLConfig';
	
	IF DiagCpuIsSimulated() THEN
		BrAbbRwsCore_0.Parameters.ServerIP := '127.0.0.1';
	ELSE
		BrAbbRwsCore_0.Parameters.ServerIP := '192.168.125.1';
	END_IF;
	
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	BrAbbRwsCore_0;
	
	
	IF NOT BrAbbRwsCore_0.Error THEN 
		BrAbbRwsVariable_0.Ident := BrAbbRwsCore_0.Ident;
	END_IF;
	
	
	
	BrAbbRwsVariable_0.Parameters.Module := 'TeknologiaDemo25';
	BrAbbRwsVariable_0.Parameters.Task := 'T_ROB1';
	
	
	CASE state OF
		0:
			BrAbbRwsVariable_0.Enable := TRUE;
			TON_0.IN := TRUE;
			TON_0.PT := TIME#1s;
			TON_0;
			
			IF TON_0.Q THEN
				TON_0.IN := FALSE;
				TON_0;
				state := 1;
			END_IF;
			
		1:
			IF NOT BrAbbRwsVariable_0.Error THEN
				BrAbbRwsVariable_0.Parameters.Variable := 'bRobotPhaseDone';
				BrAbbRwsVariable_0.Value.DataAdress := ADR(gRobot.Status.phaseOK);
				BrAbbRwsVariable_0.Value.DataType := BR_ABB_RWS_VAR_BOOL;
				BrAbbRwsVariable_0.GetValue := TRUE;
				returnState := 2;
				state := 100;
			END_IF;
			
		2:
			IF NOT BrAbbRwsVariable_0.Error THEN
				BrAbbRwsVariable_0.Parameters.Variable := 'nRobotPhase';
				BrAbbRwsVariable_0.Value.DataAdress := ADR(gRobot.Status.phaseNum);
				BrAbbRwsVariable_0.Value.DataType := BR_ABB_RWS_VAR_NUM;
				BrAbbRwsVariable_0.GetValue := TRUE;
				returnState := 5;
				state := 100;
			END_IF;
			
		5:
			TON_0.IN := NOT (gRobot.liftCup OR gRobot.placeCup OR gRobot.moveRobotHome);
			TON_0.PT := TIME#500ms;
			TON_0;
			
			IF TON_0.Q THEN
				TON_0.IN := FALSE;
				TON_0;
				state := 1;
			ELSE
				IF gRobot.liftCup THEN
					BrAbbRwsVariable_0.Value.DataAdress := ADR(gRobot.CupCoordinate.X);
					BrAbbRwsVariable_0.Value.DataType := BR_ABB_RWS_VAR_NUM;
					BrAbbRwsVariable_0.Parameters.Variable := 'nPos_X';
					BrAbbRwsVariable_0.SetValue := TRUE;
					returnState := 6;
					state := 200;
					
				ELSIF gRobot.moveRobotHome THEN
					
					state := 7;	
				ELSIF gRobot.placeCup THEN
					BrAbbRwsVariable_0.Value.DataAdress := ADR(gRobot.CupCoordinate.X);
					BrAbbRwsVariable_0.Value.DataType := BR_ABB_RWS_VAR_NUM;
					BrAbbRwsVariable_0.Parameters.Variable := 'nPos_X';
					BrAbbRwsVariable_0.SetValue := TRUE;
					returnState := 6;
					state := 200;
				ELSIF gRobot.AcoposWin THEN
					gRobot.AcoposWin := FALSE;
					writeValue := TRUE;
					BrAbbRwsVariable_0.Value.DataAdress := ADR(writeValue);
					BrAbbRwsVariable_0.Value.DataType := BR_ABB_RWS_VAR_BOOL;
					BrAbbRwsVariable_0.Parameters.Variable := 'bAcoposWin';
					BrAbbRwsVariable_0.SetValue := TRUE;
					returnState := 5;
					state := 200;
				END_IF;
			END_IF;
			
		6:
			BrAbbRwsVariable_0.Value.DataAdress := ADR(gRobot.CupCoordinate.Y);
			BrAbbRwsVariable_0.Value.DataType := BR_ABB_RWS_VAR_NUM;
			BrAbbRwsVariable_0.Parameters.Variable := 'nPos_Y';
			BrAbbRwsVariable_0.SetValue := TRUE;
			returnState := 7;
			state := 200;
		7:
			IF gRobot.liftCup THEN
				gRobot.liftCup := FALSE;
				BrAbbRwsVariable_0.Parameters.Variable := 'nAcoposCmd';
				nWriteValue := 2;
			ELSIF gRobot.placeCup THEN
				gRobot.placeCup := FALSE;
				BrAbbRwsVariable_0.Parameters.Variable := 'nAcoposCmd';
				nWriteValue := 3;
			ELSIF gRobot.moveRobotHome THEN
				gRobot.moveRobotHome := FALSE;
				BrAbbRwsVariable_0.Parameters.Variable := 'nAcoposCmd';
				nWriteValue := 1;
			END_IF;
			
			
			BrAbbRwsVariable_0.Value.DataAdress := ADR(nWriteValue);
			BrAbbRwsVariable_0.Value.DataType := BR_ABB_RWS_VAR_NUM;
			BrAbbRwsVariable_0.SetValue := TRUE;
			returnState := 5;
			state := 200;
		100:
			IF BrAbbRwsVariable_0.Done THEN
				BrAbbRwsVariable_0.GetValue := FALSE;
				state := returnState;
			END_IF;
		
		200:
			IF BrAbbRwsVariable_0.Done THEN
				writeValue := FALSE;
				BrAbbRwsVariable_0.SetValue := FALSE;
				state := returnState;
			END_IF;
		
	END_CASE;
	
	
	BrAbbRwsVariable_0;
	
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

