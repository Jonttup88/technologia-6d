
ACTION trakModeTask: 

	CASE em.substate OF 
		17000:
			em.cmd.sc := FALSE;
			em.description := 'Move shuttle to pre pos';
			positionContainerTrakMode[0].initXPos := 0.060;
			positionContainerTrakMode[0].initYPos := 0.060;
			positionContainerTrakMode[1].initXPos := 0.060;
			positionContainerTrakMode[1].initYPos := 0.180;
			positionContainerTrakMode[2].initXPos := 0.300;
			positionContainerTrakMode[2].initYPos := 0.180;
			positionContainerTrakMode[3].initXPos := 0.420;
			positionContainerTrakMode[3].initYPos := 0.180;
			tempShuttleCounter := 0;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			FOR i := 0 TO UINT_TO_USINT(localCurrentNumShuttles-1) DO
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[i].shuttleRef);
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].X := positionContainerTrakMode[i].initXPos;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Y := positionContainerTrakMode[i].initYPos;
			END_FOR
			MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlaneAsync_Acp6D_0.Done THEN
				MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := FALSE;
				em.substate := 17010;
			END_IF
		
		17010:
		//HMI interface
			IF trakMode.bigBottle THEN
				em.substate := 17100;
				trakMode.bigBottle := FALSE;
			ELSIF trakMode.smallBottle THEN
				em.substate := 17200;
				trakMode.smallBottle := FALSE;
			END_IF
		
		17100:
			em.description := 'adjust shuttle to bigBottle';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.276;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; 
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 17500;
			END_IF
			
		17200:
			em.description := 'adjust shuttle to smallBottle';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.293;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; 
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 17500;
			END_IF
		
		17500:
			em.description := 'Couple ShuttleGroup3_4';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle3_4;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Mode := 1;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 1; //Couple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 17550;
			END_IF
			
		17550:
			em.description := 'Wait timer';
			em.cmd.sc := FALSE;
			TON_0.PT := t#3s;
			TON_0.IN := TRUE;
			IF TON_0.Q THEN
				TON_0.IN := FALSE;
				em.substate := 17600;
			END_IF
				
		17600:
			em.description := 'Move bottle';
			em.cmd.sc := FALSE;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := 0.5;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := 0.5;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; 
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 17610;
			END_IF
		
		17610:
			em.description := 'Move bottle';
			em.cmd.sc := FALSE;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[3].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.420;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := 0.5;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := 0.5;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; 
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 17700;
			END_IF
		
		17700:
			em.description := 'DeCouple ShuttleGroup3_4';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle3_4;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 0; //DeCouple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 17010;
			END_IF		
			
	END_CASE

	TON_0();
	

END_ACTION
