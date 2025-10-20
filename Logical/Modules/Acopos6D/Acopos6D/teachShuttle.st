
ACTION teachShuttleProgram:
	//setup
	positionContainerFlaskProgram[0].initXPos := 0.060;
	positionContainerFlaskProgram[0].initYPos := 0.060;
	positionContainerFlaskProgram[1].initXPos := 0.060;
	positionContainerFlaskProgram[1].initYPos := 0.180;
	positionContainerFlaskProgram[2].initXPos := 0.180;
	positionContainerFlaskProgram[2].initYPos := 0.120;
	positionContainerFlaskProgram[3].initXPos := 0.360;
	positionContainerFlaskProgram[3].initYPos := 0.120;
	CASE em.substate OF
		16000:
			em.cmd.sc := FALSE;
			em.description := 'Move shuttle to pre pos';
			tempShuttleCounter := 0;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			FOR i := 0 TO UINT_TO_USINT(localCurrentNumShuttles-1) DO
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[i].shuttleRef);
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].X := positionContainerFlaskProgram[i].initXPos;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Y := positionContainerFlaskProgram[i].initYPos;
			END_FOR
			MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlaneAsync_Acp6D_0.Done THEN
				MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := FALSE;
				em.substate := 16010;
			END_IF
		
		16010:
			em.cmd.sc := FALSE;
			em.description := 'Deactivate segment 2';
			MC_BR_SegPowerOff_Acp6D_0.Segment := ADR(gAcp6DCtrl.Status.SegmentInfo[1].segmentRef);
			MC_BR_SegPowerOff_Acp6D_0.Execute := TRUE;
			IF MC_BR_SegPowerOff_Acp6D_0.Done THEN
				shuttleDeativatedLock := TRUE;
				MC_BR_SegPowerOff_Acp6D_0.Execute := FALSE;
				em.substate := 16020;
			END_IF
		
		16020:
			em.cmd.sc := FALSE;
			em.description := 'Menu';
			IF teachProgram.teachPosCmd THEN
				teachProgram.teachPosCmd := FALSE;
				em.substate := 16100;
			ELSIF teachProgram.runProgram THEN
				teachProgram.runProgram := FALSE;
				teachProgram.tmpRunPosCnt := 0;
				em.substate := 16200;
			ELSIF teachProgram.clearPositions THEN
				FOR i := 0 TO 99 DO
					teachProgram.positionArray[i].xPos := 0;
					teachProgram.positionArray[i].yPos := 0;
					teachProgram.savedPositions := 0;
				END_FOR	
			ELSIF gAcp6DCtrl.Par.modeSelector <> teachProgramEnum THEN
				em.substate := 16300;
			END_IF
			
		
		16100:
			em.cmd.sc := FALSE;
			em.description := 'Teach Position';
			IF gAcp6DCtrl.Status.ShuttleInfo[3].State = mcACP6D_SH_STATE_DISABLED THEN
				teachProgram.positionArray[teachProgram.savedPositions].xPos := gAcp6DCtrl.Status.ShuttleInfo[3].Position.X;
				teachProgram.positionArray[teachProgram.savedPositions].yPos := gAcp6DCtrl.Status.ShuttleInfo[3].Position.Y;
//				teachProgram.positionArray[teachProgram.savedPositions].zPos := gAcp6DCtrl.Status.ShuttleInfo[3].Position.Z;
//				teachProgram.positionArray[teachProgram.savedPositions].rxPos := gAcp6DCtrl.Status.ShuttleInfo[3].Position.Rx;
//				teachProgram.positionArray[teachProgram.savedPositions].ryPos := gAcp6DCtrl.Status.ShuttleInfo[3].Position.Ry;
//				teachProgram.positionArray[teachProgram.savedPositions].rzPos := gAcp6DCtrl.Status.ShuttleInfo[3].Position.Rz;
				teachProgram.savedPositions := teachProgram.savedPositions + 1;
				em.substate := 16020;
			ELSE
				em.substate := 16020;
			END_IF
		
		16200:
			em.cmd.sc := FALSE;
			MC_BR_SegPowerOn_Acp6D_0.Segment := ADR(gAcp6DCtrl.Status.SegmentInfo[1].segmentRef);
			MC_BR_SegPowerOn_Acp6D_0.Execute := TRUE;
			IF MC_BR_SegPowerOn_Acp6D_0.Done THEN
				MC_BR_SegPowerOn_Acp6D_0.Execute := FALSE;
				em.substate := 16210;
			END_IF
			
				
		16210:	
			em.cmd.sc := FALSE;
			em.description := 'Run teached program';
			IF teachProgram.tmpRunPosCnt >= teachProgram.savedPositions THEN
				em.substate := 16230;
			ELSE
				em.substate := 16220;
			END_IF
		
		16220:
			em.cmd.sc := FALSE;
			em.description := 'Run next position in program';
			MC_BR_Move6D_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[3].shuttleRef);
			MC_BR_Move6D_Acp6D_0.Parameters.InPlane.Position.X := teachProgram.positionArray[teachProgram.tmpRunPosCnt].xPos; 
			MC_BR_Move6D_Acp6D_0.Parameters.InPlane.Position.Y := teachProgram.positionArray[teachProgram.tmpRunPosCnt].yPos;
			MC_BR_Move6D_Acp6D_0.Parameters.ShortAxis.Position.Z := 0.001;
			MC_BR_Move6D_Acp6D_0.Parameters.InPlane.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_Move6D_Acp6D_0.Parameters.InPlane.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_Move6D_Acp6D_0.Parameters.ShortAxis.Velocity.Rx := 1;
			MC_BR_Move6D_Acp6D_0.Parameters.ShortAxis.Velocity.Ry := 1;
			MC_BR_Move6D_Acp6D_0.Parameters.ShortAxis.Velocity.Rz := 1;
			MC_BR_Move6D_Acp6D_0.Parameters.ShortAxis.Velocity.Z := 1;
			MC_BR_Move6D_Acp6D_0.Parameters.ShortAxis.Position.Rz := teachProgram.positionArray[teachProgram.tmpRunPosCnt].rzPos;
			MC_BR_Move6D_Acp6D_0.Execute := TRUE;
			IF MC_BR_Move6D_Acp6D_0.Done THEN
				MC_BR_Move6D_Acp6D_0.Execute := FALSE;
				teachProgram.tmpRunPosCnt := teachProgram.tmpRunPosCnt + 1;
				em.substate := 16210;
			END_IF
			
		16230:
			em.cmd.sc := FALSE;
			em.description := 'Turn off segment before reteaching';
			MC_BR_SegPowerOff_Acp6D_0.Segment := ADR(gAcp6DCtrl.Status.SegmentInfo[1].segmentRef);
			MC_BR_SegPowerOff_Acp6D_0.Execute := TRUE;
			IF MC_BR_SegPowerOff_Acp6D_0.Done THEN
				MC_BR_SegPowerOff_Acp6D_0.Execute := FALSE;
				em.substate := 16020;
			END_IF
		
		16300:
			em.cmd.sc := FALSE;
			em.description := 'Power on segment before program change';
			MC_BR_SegPowerOn_Acp6D_0.Segment := ADR(gAcp6DCtrl.Status.SegmentInfo[1].segmentRef);
			MC_BR_SegPowerOn_Acp6D_0.Execute := TRUE;
			IF MC_BR_SegPowerOn_Acp6D_0.Done THEN
				MC_BR_SegPowerOn_Acp6D_0.Execute := FALSE;
				em.substate := 16310;
			END_IF
		
		16310:
			em.description := 'Check that shuttle is rdy';
			IF gAcp6DCtrl.Status.ShuttleInfo[3].State = mcACP6D_SH_STATE_IDLING THEN
				MC_BR_SegBarrierCommand_Acp6D_0.Segment := ADR(gAcp6DCtrl.Status.SegmentInfo[1].segmentRef);
				MC_BR_SegBarrierCommand_Acp6D_0.Parameters.Command := mcACP6D_BARRIER_OPEN;
				MC_BR_SegBarrierCommand_Acp6D_0.Execute := TRUE;
				IF MC_BR_SegBarrierCommand_Acp6D_0.Done THEN
					MC_BR_SegBarrierCommand_Acp6D_0.Execute := FALSE;
					shuttleDeativatedLock := FALSE;
					em.cmd.sc := TRUE;
				END_IF
			END_IF
		
	END_CASE

END_ACTION
