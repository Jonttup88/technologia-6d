
ACTION rotationTask:
	positionContainerRotation[0].initXPos := 0.180;
	positionContainerRotation[0].initYPos := 0.060;
	positionContainerRotation[1].initXPos := 0.060;
	positionContainerRotation[1].initYPos := 0.060;
	positionContainerRotation[2].initXPos := 0.060;
	positionContainerRotation[2].initYPos := 0.180;
	positionContainerRotation[3].initXPos := 0.180;
	positionContainerRotation[3].initYPos := 0.180;

	gWorkStations[0].par.xLocation										:= 0.180;
	gWorkStations[0].par.yLocation										:= 0.060;
	gWorkStations[0].par.nextStationSelector							:= '1';
	gWorkStations[0].par.processTime									:= 0;
	gWorkStations[0].par.pathRouting									:= 1;
	gWorkStations[0].par.landBeforeProcess								:= FALSE;
	gWorkStations[0].par.ArcMovement									:= FALSE;
	
	gWorkStations[1].par.xLocation										:= 0.060;
	gWorkStations[1].par.yLocation										:= 0.180;
	gWorkStations[1].par.nextStationSelector							:= '0';
	gWorkStations[1].par.processTime									:= WorkStation2And3MovementTimer;
	gWorkStations[1].par.pathRouting									:= 2;
	gWorkStations[1].par.landBeforeProcess								:= TRUE;
	gWorkStations[1].par.ArcMovement									:= FALSE;
	
	CASE em.substate OF 
		14000:
			em.description := 'Move shuttle to pre pos';
			tempShuttleCounter := 0;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			FOR i := 0 TO UINT_TO_USINT(localCurrentNumShuttles-1) DO
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[i].shuttleRef);
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].X := positionContainerRotation[i].initXPos;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Y := positionContainerRotation[i].initYPos;
			END_FOR
			MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlaneAsync_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := FALSE;
				em.substate := 14010;
			END_IF
			
		14010:
			em.description := 'Move shuttle 2 towards workstation 0';
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[1].shuttleRef);;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := gWorkStations[0].par.xLocation;;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := gWorkStations[0].par.yLocation;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; //direct
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0;
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 14020;
			END_IF
		
		14020:
			em.description := 'Move shuttle 3 towards workstation 0';
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[2].shuttleRef);;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := gWorkStations[0].par.xLocation;;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := gWorkStations[0].par.yLocation;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //Y then X
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0;
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 14030;
			END_IF
		
		14030:
			em.description := 'Move shuttle 4 towards workstation 1';
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[3].shuttleRef);;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.060;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 0; //direct
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0;
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 14040;
			END_IF
		
		14040:
			em.description := 'Move shuttle 4 towards workstation 1';
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[3].shuttleRef);;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := gWorkStations[0].par.xLocation;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := gWorkStations[0].par.yLocation;
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //direct
			MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0;
			MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				em.substate := 14050;
			END_IF
	END_CASE
			
END_ACTION

ACTION rotationStation:
	CASE cm.state OF
		// Display station at image
		//'<foreignObject x="20" y="20" width="300" height="300"><img src="Media/statusGreen.png" height="300" width="300"/>'
		//brsstrcat(ADR(showWorkStations),ADR('<foreingObject x="')); 
		//brdkStrCat(ADR(showWorkStations), ADR(testDraw));
		//brdkStrCat(ADR(showWorkStations),'<foreingObject x="');
		
		0:
			//Check what shuttle is on top of workstation
			FOR k := 0 TO NUM_SHUTTLES DO
				IF((gAcp6DCtrl.Status.ShuttleInfo[k].Position.X > pWorkStations.par.xLocation - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[k].Position.X < pWorkStations.par.xLocation + MARGIN) AND
					gAcp6DCtrl.Status.ShuttleInfo[k].Position.Y > pWorkStations.par.yLocation - MARGIN AND gAcp6DCtrl.Status.ShuttleInfo[k].Position.Y < pWorkStations.par.yLocation + MARGIN) THEN
					IF gAcp6DCtrl.Status.ShuttleInfo[k].State = mcACP6D_SH_STATE_IDLING THEN
						pWorkStations.par.tempShuttleID := k;
						cm.state := 10;
					END_IF
				END_IF
			END_FOR
			
		10:
			//Move first workstation
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.360;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.120;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Absolute
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //0 Diagonal, 1 First X then Y, 2 First Y then X
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Done THEN
				pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				cm.state := 20;
			END_IF
			
			
		20:
			//Rotate 90 degress
			em.cmd.sc := FALSE;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.rotationAcceleration;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.rotationVelocity;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Angle := 1.57079633; //90 degress
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Mode := 0;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Done THEN
				pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Execute := FALSE;
				cm.state := 30;
			END_IF
			
		30:
			//Move
			//em.cmd.sc := FALSE;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.420;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.120;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Absolute
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //0 Diagonal, 1 First X then Y, 2 First Y then X
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				cm.state := 40;
			END_IF
			
		40:
			//em.cmd.sc := FALSE;
			pWorkStations.TON_0.IN := TRUE;
			pWorkStations.TON_0.PT := t#100ms;
			IF pWorkStations.TON_0.Q THEN
				pWorkStations.TON_0.IN := FALSE;
				cm.state := 50;
			END_IF
		
		50:
			//Move
			//em.cmd.sc := FALSE;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.360;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.120;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Absolute
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //0 Diagonal, 1 First X then Y, 2 First Y then X
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				cm.state := 60;
			END_IF
		
		60:
			//Rotate 90 degress
			em.cmd.sc := FALSE;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.rotationAcceleration;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.rotationVelocity;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Angle := 3.14159265; //180 degress
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Mode := 0;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Done THEN
				pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Execute := FALSE;
				cm.state := 70;
			END_IF
		
		70:
			//Move
			//em.cmd.sc := FALSE;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.420;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.120;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Absolute
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //0 Diagonal, 1 First X then Y, 2 First Y then X
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				cm.state := 80;
			END_IF
			
		80:
			//em.cmd.sc := FALSE;
			pWorkStations.TON_0.IN := TRUE;
			pWorkStations.TON_0.PT := t#100ms;
			IF pWorkStations.TON_0.Q THEN
				pWorkStations.TON_0.IN := FALSE;
				cm.state := 90;
			END_IF
		
		90:
			//Move
			//em.cmd.sc := FALSE;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.360;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.120;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Absolute
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //0 Diagonal, 1 First X then Y, 2 First Y then X
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				cm.state := 100;
			END_IF
		
		100:
			//Rotate 90 degress
			em.cmd.sc := FALSE;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.rotationAcceleration;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.rotationVelocity;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Angle := 4.71238898; //270 degress
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Mode := 0;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Done THEN
				pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Execute := FALSE;
				cm.state := 110;
			END_IF
		
		110:
			//Move
			//em.cmd.sc := FALSE;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.420;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.120;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Absolute
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //0 Diagonal, 1 First X then Y, 2 First Y then X
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				cm.state := 120;
			END_IF
			
		120:
			//em.cmd.sc := FALSE;
			pWorkStations.TON_0.IN := TRUE;
			pWorkStations.TON_0.PT := t#100ms;
			IF pWorkStations.TON_0.Q THEN
				pWorkStations.TON_0.IN := FALSE;
				cm.state := 130;
			END_IF
		
		130:
			//Move
			//em.cmd.sc := FALSE;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.360;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.120;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Absolute
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 1; //0 Diagonal, 1 First X then Y, 2 First Y then X
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				cm.state := 140;
			END_IF
		
		140:
			//Rotate
			em.cmd.sc := FALSE;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.rotationAcceleration;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.rotationVelocity; //RPM
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Angle := 0; //0 degress
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Parameters.Mode := 1;
			pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Done THEN
				pWorkStations.MC_BR_RotaryMotion_Acp6D_0.Execute := FALSE;
				cm.state := 145;
			END_IF
			
		145:
			em.cmd.sc := FALSE;
			pWorkStations.MC_BR_RotaryMotionSpin_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_RotaryMotionSpin_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.rotationVelocity;
			pWorkStations.MC_BR_RotaryMotionSpin_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.rotationAcceleration;
			pWorkStations.MC_BR_RotaryMotionSpin_Acp6D_0.Parameters.Duration := 5;
			pWorkStations.MC_BR_RotaryMotionSpin_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_RotaryMotionSpin_Acp6D_0.Done THEN
				pWorkStations.MC_BR_RotaryMotionSpin_Acp6D_0.Execute := FALSE;
				cm.state := 150;
			END_IF			
		
		150:
			//Move
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := 0.060;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := 0.180;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Absolute
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //0 Diagonal, 1 First X then Y, 2 First Y then X
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				cm.state := 160;
			END_IF
		
		160:
			//Move
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Shuttle := ADR(gAcp6DCtrl.Status.ShuttleInfo[pWorkStations.par.tempShuttleID].shuttleRef);
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Velocity := gAcp6DCtrl.Par.Velocity;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Acceleration := gAcp6DCtrl.Par.Acceleration;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.X := gWorkStations[0].par.xLocation;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Position.Y := gWorkStations[0].par.yLocation;
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Mode := 0; //Absolute
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Parameters.Path := 2; //0 Diagonal, 1 First X then Y, 2 First Y then X
			pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := TRUE;
			IF pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Acknowledge THEN
				pWorkStations.MC_BR_MoveInPlane_Acp6D_0.Execute := FALSE;
				cm.state := 0;
			END_IF
		
		
	END_CASE

	//Calls
	pWorkStations.MC_BR_MoveInPlane_Acp6D_0();
	pWorkStations.MC_BR_MoveArc_Acp6D_0();
	pWorkStations.MC_BR_ShLevitation_Acp6D_0();
	pWorkStations.MC_BR_RotaryMotion_Acp6D_0();
	pWorkStations.MC_BR_RotaryMotionSpin_Acp6D_0();
	pWorkStations.TON_0();
	cm();
	
END_ACTION
	

	
