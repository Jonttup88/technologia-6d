
ACTION linkMovementProgram: 
	//Setup 
	positionContainerLinkMovement[0].Shuttle1.xPos := 0.120;
	positionContainerLinkMovement[0].Shuttle1.yPos := 0.120;
	positionContainerLinkMovement[0].Shuttle2.xPos := 0.360;
	positionContainerLinkMovement[0].Shuttle2.yPos := 0.360;
	positionContainerLinkMovement[0].Shuttle3.xPos := 0.360;
	positionContainerLinkMovement[0].Shuttle3.yPos := 0.120;
	positionContainerLinkMovement[0].Shuttle4.xPos := 0.120;
	positionContainerLinkMovement[0].Shuttle4.yPos := 0.360;
			
	positionContainerLinkMovement[1].Shuttle1.xPos := 0.060;
	positionContainerLinkMovement[1].Shuttle1.yPos := 0.060;
	positionContainerLinkMovement[1].Shuttle2.xPos := 0.180;
	positionContainerLinkMovement[1].Shuttle2.yPos := 0.180;
	positionContainerLinkMovement[1].Shuttle3.xPos := 0.180;
	positionContainerLinkMovement[1].Shuttle3.yPos := 0.060;
	positionContainerLinkMovement[1].Shuttle4.xPos := 0.060;
	positionContainerLinkMovement[1].Shuttle4.yPos := 0.180;
			
	positionContainerLinkMovement[2].Shuttle1.xPos := 0.120;
	positionContainerLinkMovement[2].Shuttle1.yPos := 0.120;
	positionContainerLinkMovement[2].Shuttle2.xPos := 0.360;
	positionContainerLinkMovement[2].Shuttle2.yPos := 0.360;
	positionContainerLinkMovement[2].Shuttle3.xPos := 0.360;
	positionContainerLinkMovement[2].Shuttle3.yPos := 0.120;
	positionContainerLinkMovement[2].Shuttle4.xPos := 0.120;
	positionContainerLinkMovement[2].Shuttle4.yPos := 0.360;
			
	positionContainerLinkMovement[3].Shuttle1.xPos := 0.300;
	positionContainerLinkMovement[3].Shuttle1.yPos := 0.060;
	positionContainerLinkMovement[3].Shuttle2.xPos := 0.420;
	positionContainerLinkMovement[3].Shuttle2.yPos := 0.180;
	positionContainerLinkMovement[3].Shuttle3.xPos := 0.420;
	positionContainerLinkMovement[3].Shuttle3.yPos := 0.060;
	positionContainerLinkMovement[3].Shuttle4.xPos := 0.300;
	positionContainerLinkMovement[3].Shuttle4.yPos := 0.180;
			
	positionContainerLinkMovement[4].Shuttle1.xPos := 0.120;
	positionContainerLinkMovement[4].Shuttle1.yPos := 0.120;
	positionContainerLinkMovement[4].Shuttle2.xPos := 0.360;
	positionContainerLinkMovement[4].Shuttle2.yPos := 0.360;
	positionContainerLinkMovement[4].Shuttle3.xPos := 0.360;
	positionContainerLinkMovement[4].Shuttle3.yPos := 0.120;
	positionContainerLinkMovement[4].Shuttle4.xPos := 0.120;
	positionContainerLinkMovement[4].Shuttle4.yPos := 0.360;
			
	positionContainerLinkMovement[5].Shuttle1.xPos := 0.300;
	positionContainerLinkMovement[5].Shuttle1.yPos := 0.300;
	positionContainerLinkMovement[5].Shuttle2.xPos := 0.420;
	positionContainerLinkMovement[5].Shuttle2.yPos := 0.420;
	positionContainerLinkMovement[5].Shuttle3.xPos := 0.420;
	positionContainerLinkMovement[5].Shuttle3.yPos := 0.300;
	positionContainerLinkMovement[5].Shuttle4.xPos := 0.300;
	positionContainerLinkMovement[5].Shuttle4.yPos := 0.420;
			
	positionContainerLinkMovement[6].Shuttle1.xPos := 0.120;
	positionContainerLinkMovement[6].Shuttle1.yPos := 0.120;
	positionContainerLinkMovement[6].Shuttle2.xPos := 0.360;
	positionContainerLinkMovement[6].Shuttle2.yPos := 0.360;
	positionContainerLinkMovement[6].Shuttle3.xPos := 0.360;
	positionContainerLinkMovement[6].Shuttle3.yPos := 0.120;
	positionContainerLinkMovement[6].Shuttle4.xPos := 0.120;
	positionContainerLinkMovement[6].Shuttle4.yPos := 0.360;
	
	CASE em.substate OF
		3000:
			em.description := 'Move all shuttles to prePos';
			tempShuttleCounter := 0;
			tempCounter := 0;
			em.substate := 3010;
			
		3010:
			em.description := 'Move all shuttles to prePos';
			IF tempShuttleCounter > NUM_SHUTTLES THEN
				tempShuttleCounter := 0;
				em.substate := 3030;
			ELSE
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Abs
				MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[tempShuttleCounter].shuttleRef);
				CASE tempShuttleCounter OF
					0:
						MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.060;
						MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
					1:
						MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.180;
						MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
					2:
						MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.300;
						MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
					3:
						MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.420;
						MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
				END_CASE
				
				MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
				IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
					MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
					tempShuttleCounter := tempShuttleCounter + 1;
					em.substate := 3020;
				END_IF
			END_IF

		3020:
			em.description := 'DummyScan';
			em.substate := 3010;
			
		3030:
			em.description := 'check shuttle state idle';
			IF gAcp6DCtrl.Status.ShuttleInfo[0].State = mcACP6D_SH_STATE_IDLING AND gAcp6DCtrl.Status.ShuttleInfo[1].State = mcACP6D_SH_STATE_IDLING 
				AND gAcp6DCtrl.Status.ShuttleInfo[2].State = mcACP6D_SH_STATE_IDLING AND gAcp6DCtrl.Status.ShuttleInfo[3].State = mcACP6D_SH_STATE_IDLING AND MC_BR_AsmReadStatus_Acp6D_0.AssemblyReady THEN
				em.substate := 3035;
			END_IF
			
		3035:
			em.description := 'Couple ShuttleGroup1_2';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle1_2;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 1; //Couple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 3040;
			ELSIF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Error THEN
				em.cmd.abort := TRUE;
			END_IF
		
		3040:
			em.description := 'Couple ShuttleGroup1_2';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle3_4;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 1; //Couple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 3050;
			ELSIF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Error THEN
				em.cmd.abort := TRUE;
			END_IF

		3050:
			em.description := 'Move group 10 of shuttle around';
			em.cmd.sc := FALSE;
			IF tempCounter >= 3 THEN
				tempCounter := 0;
				em.substate := 3070;
			ELSE
				MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[0].shuttleRef);
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.300;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //Y then X
				MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
				IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
					MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
					em.substate := 3060;
				END_IF
			END_IF
		
		3060:
			em.description := 'Move group of shuttle around';
			em.cmd.sc := FALSE;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[0].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //Y then X
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				tempCounter := tempCounter + 1;
				em.substate := 3050;
			END_IF
			
		3070:
			em.description := 'Move group 11 of shuttle around';
			em.cmd.sc := FALSE;
			IF tempCounter >= 3 THEN
				tempCounter := 0;
				em.substate := 3090;
			ELSE
				MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.060;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //Y then X
				MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
				IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
					MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
					em.substate := 3080;
				END_IF
			END_IF
		
		3080:
			em.description := 'Move group of shuttle around';
			em.cmd.sc := FALSE;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.300;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //Y then X
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				tempCounter := tempCounter + 1;
				em.substate := 3070;
			END_IF
		
		3090:
			em.description := 'DeCouple ShuttleGroup1_2';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle1_2;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 0; //DeCouple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 3100;
			ELSIF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Error THEN
				em.cmd.abort := TRUE;
			END_IF
			
		3100:
			em.description := 'Wait for shuttle to reach pos';
			em.cmd.sc := FALSE;
			IF((gAcp6DCtrl.Status.ShuttleInfo[2].Position.X > 0.300 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[2].Position.X < 0.300 + MARGIN) AND
				gAcp6DCtrl.Status.ShuttleInfo[2].Position.Y > 0.060 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[2].Position.Y < 0.060 + MARGIN) THEN
				IF gAcp6DCtrl.Status.ShuttleInfo[2].State = mcACP6D_SH_STATE_IDLING THEN
					em.substate := 3110;
				END_IF
			END_IF
		
		3110:
			em.description := 'Move right group up';
			em.cmd.sc := FALSE;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.300;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; //Direct
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3120;
			END_IF
		
		3120:			
			em.description := 'Couple ShuttleGroup1_2';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle3_4;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 0; //DeCouple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 3130;
			ELSIF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Error THEN
				em.cmd.abort := TRUE;
			END_IF
		
		3130:
			em.description := 'rotationMove part 1';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[1].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //Y then X
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3140;
			END_IF
		
		3140:
			em.description := 'rotationMove part 2';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[3].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //Y then X
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3150;
			END_IF
		
		3150:
			em.description := 'rotationMove part 3';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[3].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; //direct
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3160;
			END_IF
			
		3160:
			em.description := 'Check switch is done part 1';
			IF((gAcp6DCtrl.Status.ShuttleInfo[3].Position.X > 0.180 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[3].Position.X < 0.180 + MARGIN) AND
				gAcp6DCtrl.Status.ShuttleInfo[3].Position.Y > 0.180 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[3].Position.Y < 0.180 + MARGIN) THEN
				IF gAcp6DCtrl.Status.ShuttleInfo[3].State = mcACP6D_SH_STATE_IDLING THEN
					em.substate := 3170;
				END_IF
			END_IF
			
		3170:
			em.description := 'rotationMove part 4';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[1].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.420;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //X then Y
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3180;
			END_IF
		
		3180:
			em.description := 'Check switch is done part 2';
			IF((gAcp6DCtrl.Status.ShuttleInfo[1].Position.X > 0.420 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[1].Position.X < 0.420 + MARGIN) AND
				gAcp6DCtrl.Status.ShuttleInfo[1].Position.Y > 0.180 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[1].Position.Y < 0.180 + MARGIN) THEN
				IF gAcp6DCtrl.Status.ShuttleInfo[1].State = mcACP6D_SH_STATE_IDLING THEN
					em.substate := 3190;
				END_IF
			END_IF

		
		3190:
			em.description := 'Couple ShuttleGroup1_4';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle1_4;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 1; //Couple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 3200;
			ELSIF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Error THEN
				em.cmd.abort := TRUE;
			END_IF
		
		3200:
			em.description := 'Couple ShuttleGroup2_3';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle2_3;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 1; //Couple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 3210;
			ELSIF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Error THEN
				em.cmd.abort := TRUE;
			END_IF
			
		3210:
			em.description := 'Move right side down';
			em.cmd.sc := FALSE;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.300;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; //direct
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3230;
			END_IF
		
		3230:
			em.description := 'Move group 12 of shuttle around';
			em.cmd.sc := FALSE;
			IF tempCounter >= 3 THEN
				tempCounter := 0;
				em.substate := 3250;
			ELSE
				MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[0].shuttleRef);
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.300;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //X then Y
				MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
				IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
					MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
					em.substate := 3240;
				END_IF
			END_IF
		
		3240:
			em.description := 'Move group of shuttle around';
			em.cmd.sc := FALSE;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[0].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //X then Y
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				tempCounter := tempCounter + 1;
				em.substate := 3230;
			END_IF
		
		3250:
			em.description := 'Move group 13 of shuttle around';
			em.cmd.sc := FALSE;
			IF tempCounter >= 3 THEN
				tempCounter := 0;
				em.substate := 3270;
			ELSE
				MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.060;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
				MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //X then Y
				MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
				IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
					MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
					em.substate := 3260;
				END_IF
			END_IF
		
		3260:
			em.description := 'Move group of shuttle around';
			em.cmd.sc := FALSE;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.300;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //X then Y
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				tempCounter := tempCounter + 1;
				em.substate := 3250;
			END_IF
		
		3270:
			em.cmd.sc := FALSE;
			IF((gAcp6DCtrl.Status.ShuttleInfo[2].Position.X > 0.300 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[2].Position.X < 0.300 + MARGIN) AND
				gAcp6DCtrl.Status.ShuttleInfo[2].Position.Y > 0.060 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[2].Position.Y < 0.060 + MARGIN) THEN
				IF gAcp6DCtrl.Status.ShuttleInfo[2].State = mcACP6D_SH_STATE_IDLING THEN
					em.substate := 3280;
				END_IF
			END_IF
		
		3280:
			em.description := 'Move right group up';
			em.cmd.sc := FALSE;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.300;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; //Direct
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3290;
			END_IF
		
		3290:
			em.description := 'DeCouple ShuttleGroup1_4';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle1_4;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 0; //DeCouple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 3300;
			ELSIF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Error THEN
				em.cmd.abort := TRUE;
			END_IF
		
		3300:
			em.description := 'DeCouple ShuttleGroup2_3';
			em.cmd.sc := FALSE;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := shGroupShuttle2_3;
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := 0; //DeCouple
			MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
			IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
				MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
				em.substate := 3310;
			ELSIF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Error THEN
				em.cmd.abort := TRUE;
			END_IF
		
		3310:
			em.description := 'rotationMove part 1';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[3].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //Y then X
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3320;
			END_IF
		
		3320:
			em.description := 'rotationMove part 2';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[1].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //Y then X
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3330;
			END_IF
		
		3330:
			em.description := 'rotationMove part 3';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[1].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; //direct
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3340;
			END_IF
		
		3340:
			IF((gAcp6DCtrl.Status.ShuttleInfo[1].Position.X > 0.180 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[1].Position.X < 0.180 + MARGIN) AND
				gAcp6DCtrl.Status.ShuttleInfo[1].Position.Y > 0.180 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[1].Position.Y < 0.180 + MARGIN) THEN
				IF gAcp6DCtrl.Status.ShuttleInfo[1].State = mcACP6D_SH_STATE_IDLING THEN
					em.substate := 3350;
				END_IF
			END_IF
		
		3350:
			em.description := 'rotationMove part 4';
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[3].shuttleRef);
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.420;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //X then Y
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 3360;
			END_IF
		
		3360:
			IF((gAcp6DCtrl.Status.ShuttleInfo[3].Position.X > 0.420 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[3].Position.X < 0.420 + MARGIN) AND
				gAcp6DCtrl.Status.ShuttleInfo[3].Position.Y > 0.180 - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[3].Position.Y < 0.180 + MARGIN) THEN
				IF gAcp6DCtrl.Status.ShuttleInfo[3].State = mcACP6D_SH_STATE_IDLING THEN
					em.substate := 3030;
				END_IF
			END_IF

	END_CASE
	
	TON_0();

END_ACTION
