
ACTION GameAction: 

	
	CASE gameState OF
		
		0:
			Shuffle;

			FOR i := 0 TO 7 DO
				brsmemcpy(ADR(FeatureShuttles[i].Shuttle),ADR(gShuttleList[shuffled[i]]),SIZEOF(gShuttleList[0]));
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Shuttle := ADR(gShuttleList[shuffled[i]].Ref);
				FeatureShuttles[i].FB.TON_0.PT := REAL_TO_TIME(USINT_TO_REAL(i MOD 2)*250);
				FOR z := 0 TO 7 DO
					IF FeatureShuttles[i].Shuttle.ID = weightOffsets[z].ID THEN
						FeatureShuttles[i].Parameters.PayloadOffset := weightOffsets[z].Offset;
						EXIT;
					END_IF;
				END_FOR;
			END_FOR;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].X		:= 0.300;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].Y		:= 0.660;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].X		:= 0.300;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].Y		:= 0.540;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].X		:= 0.420;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].Y		:= 0.660;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].X		:= 0.420;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].Y		:= 0.540;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].X		:= 0.540;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].Y		:= 0.660;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].X		:= 0.540;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].Y		:= 0.540;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].X		:= 0.660;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].Y		:= 0.660;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].X		:= 0.660;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].Y		:= 0.540;	
			gameState := 1;
			
		1:
			
			MC_BR_MoveInPlaneAsync_Acp6D_0.Assembly := ADR(gAssembly6D_1);
			MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := TRUE;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Velocity := 1;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Acceleration := 10;
			gameState := 2;
		
					
		2:
			MC_BR_MoveInPlaneAsync_Acp6D_0;
			IF MC_BR_MoveInPlaneAsync_Acp6D_0.Done THEN
				MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := FALSE;
				MC_BR_MoveInPlaneAsync_Acp6D_0;
				gameState := 3;	
				
				// reset
				FOR i := 0 TO 7 DO
					FeatureShuttles[i].counter := 0;
					FeatureShuttles[i].subState := 0;
				END_FOR;
			END_IF;
		
		
		3:
			//Wait for robot
			FOR i := 0 TO 7 DO
				CASE FeatureShuttles[i].subState OF
					0:
						FeatureShuttles[i].FB.TON_0.IN := TRUE;
						FeatureShuttles[i].FB.TON_0;
						IF FeatureShuttles[i].FB.TON_0.Q THEN
							FeatureShuttles[i].FB.TON_0.IN := FALSE;
							FeatureShuttles[i].FB.TON_0;
							FeatureShuttles[i].subState := 1;
						END_IF;
						
						
					1:
						FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
						brsmemset(ADR(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position),0,SIZEOF(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position));
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.004;
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.01;
						FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
						FeatureShuttles[i].FB.MoveShortAxis;
						IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
							FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
							FeatureShuttles[i].FB.MoveShortAxis;
							FeatureShuttles[i].subState := 2;
							IF FeatureShuttles[i].Parameters.UseTime THEN
								FeatureShuttles[i].subState := 100;
								FeatureShuttles[i].Parameters.Time := USINT_TO_REAL(7-i)*250;
								FeatureShuttles[i].returnState := 2;
							END_IF;
							
						END_IF;
						
					2:
						FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
						brsmemset(ADR(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position),0,SIZEOF(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position));
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.0005;
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.005;
						FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
						FeatureShuttles[i].FB.MoveShortAxis;
						IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
							FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
							FeatureShuttles[i].FB.MoveShortAxis;
							
							FeatureShuttles[i].counter := FeatureShuttles[i].counter + 1;
							IF FeatureShuttles[i].counter > 3 THEN
								FeatureShuttles[i].subState := 3;
							ELSE
								FeatureShuttles[i].subState := 1;
								IF FeatureShuttles[i].Parameters.UseTime THEN
									FeatureShuttles[i].subState := 100;
									FeatureShuttles[i].Parameters.Time := USINT_TO_REAL(i)*250;
									FeatureShuttles[i].returnState := 1;
								END_IF;
							END_IF;
						END_IF;
					
					3:
						FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
						brsmemset(ADR(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position),0,SIZEOF(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position));
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.001;
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.005;
						FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
						FeatureShuttles[i].FB.MoveShortAxis;
						IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
							FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
							FeatureShuttles[i].FB.MoveShortAxis;
							FeatureShuttles[i].subState := 4;
						END_IF;
					
					4:
						IF cubeID > 0 THEN
							IF FeatureShuttles[i].Shuttle.ID = cubeID THEN
								FeatureShuttles[i].subState := 5;
								FeatureShuttles[i].counter := 0;
							ELSE
								FeatureShuttles[i].subState := 8;
							END_IF;
						ELSE
							FeatureShuttles[i].subState := 8;
						END_IF;
							
						
					5:
						FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.004;
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.01;
						FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
						FeatureShuttles[i].FB.MoveShortAxis;
						IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
							FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
							FeatureShuttles[i].FB.MoveShortAxis;
							FeatureShuttles[i].subState := 6;
						END_IF;
						
					6: // only single shuttle should be in this state
						FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
						brsmemset(ADR(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position),0,SIZEOF(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position));
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.0005;
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.005;
						FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
						FeatureShuttles[i].FB.MoveShortAxis;
						IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
							FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
							FeatureShuttles[i].FB.MoveShortAxis;
							
							FeatureShuttles[i].counter := FeatureShuttles[i].counter + 1;
							IF FeatureShuttles[i].counter > 3 THEN
								FeatureShuttles[i].subState := 7;
							ELSE
								FeatureShuttles[i].subState := 5;
							END_IF;
						END_IF;
					
					7:
						FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
						brsmemset(ADR(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position),0,SIZEOF(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position));
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.001;
						FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.005;
						FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
						FeatureShuttles[i].FB.MoveShortAxis;
						IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
							FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
							FeatureShuttles[i].FB.MoveShortAxis;
							FeatureShuttles[i].subState := 10;
							gRobot.CupCoordinate.X :=  gShuttles[(FeatureShuttles[i].Shuttle.ID-1)].X*1000;
							gRobot.CupCoordinate.Y :=  gShuttles[(FeatureShuttles[i].Shuttle.ID-1)].Y*1000;
							gRobot.liftCup := TRUE;
						END_IF;
						
					8:
						
						
					10:
						IF gRobot.Status.phaseNum = 2 AND gRobot.Status.phaseOK THEN
							gRobot.placeCup := TRUE;
							FeatureShuttles[i].subState := 11;
						END_IF;
						
					11:
						IF gRobot.Status.phaseNum = 3 AND gRobot.Status.phaseOK THEN
							FeatureShuttles[i].subState := 12;
						END_IF;
						
						
					12:
						//
						FOR z := 0 TO 7 DO 
							FeatureShuttles[i].subState := 13;
							gRobot.moveRobotHome := TRUE;
							gameState := 4;
						END_FOR;
						EXIT;
						
					13:
						
						
						
					100:
						FeatureShuttles[i].FB.TON_0.IN := TRUE;
						FeatureShuttles[i].FB.TON_0.PT := REAL_TO_TIME(FeatureShuttles[i].Parameters.Time);
						FeatureShuttles[i].FB.TON_0;
					
						IF FeatureShuttles[i].FB.TON_0.Q THEN
							FeatureShuttles[i].FB.TON_0.IN := FALSE;
							FeatureShuttles[i].FB.TON_0;
							FeatureShuttles[i].subState := FeatureShuttles[i].returnState;
						END_IF;
					
					
				END_CASE;
			END_FOR;				
	
	
		4:
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].X		:= 0.48 - COS(brmPI*45/180)*0.42;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].Y		:= 0.480 + SIN(brmPI*45/180)*0.42;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].X		:= 0.06;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].Y		:= 0.480;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].X		:= 0.480;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].Y		:= 0.900;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].X		:= 0.480 - COS(brmPI*45/180)*0.42;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].Y		:= 0.480 - SIN(brmPI*45/180)*0.42;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].X		:= 0.480 + COS(brmPI*45/180)*0.42;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].Y		:= 0.480 - SIN(brmPI*45/180)*0.42;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].X		:= 0.480;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].Y		:= 0.060;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].X		:= 0.900;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].Y		:= 0.480;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].X		:= 0.480 + COS(brmPI*45/180)*0.42;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].Y		:= 0.480 + SIN(brmPI*45/180)*0.42;	
			
			
			
			MC_BR_MoveInPlaneAsync_Acp6D_0.Assembly := ADR(gAssembly6D_1);
			MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := TRUE;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Velocity := 2;
			MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Acceleration := 10;
			gameState := 5;

			
		5:
			MC_BR_MoveInPlaneAsync_Acp6D_0;
			IF MC_BR_MoveInPlaneAsync_Acp6D_0.Done THEN
				MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := FALSE;
				MC_BR_MoveInPlaneAsync_Acp6D_0;
				gameState := 6;	
				
				// reset
				FOR i := 0 TO 7 DO
					FeatureShuttles[i].counter := 0;
					FeatureShuttles[i].subState := 0;
				END_FOR;
			END_IF;
		
		
		6:
			tempDone := TRUE;
			FOR i := 0 TO 7 DO
				CASE FeatureShuttles[i].subState OF
					0:
						FeatureShuttles[i].FB.MoveArc.Execute := TRUE;
					
						FeatureShuttles[i].FB.MoveArc.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
						FeatureShuttles[i].FB.MoveArc.Parameters.Option := mcACP6D_ARC_ANGULAR;
						FeatureShuttles[i].FB.MoveArc.Parameters.Direction := mcACP6D_ARC_COUNTER_CLOCKWISE;
						
						FeatureShuttles[i].FB.MoveArc.Parameters.Angular.Center.X := 0.48;
						FeatureShuttles[i].FB.MoveArc.Parameters.Angular.Center.Y := 0.48;
						FeatureShuttles[i].FB.MoveArc.Parameters.Angular.Angle := (45*brmPI/180);
				
						FeatureShuttles[i].FB.MoveArc.Parameters.Acceleration := 5;
						FeatureShuttles[i].FB.MoveArc.Parameters.Velocity := 0.25;
						FeatureShuttles[i].FB.MoveArc.Parameters.EndVelocity := 0.25;
						
						FeatureShuttles[i].FB.MoveArc;
					
						IF FeatureShuttles[i].FB.MoveArc.Acknowledge OR FeatureShuttles[i].FB.MoveArc.Done THEN
							FeatureShuttles[i].FB.MoveArc.Execute := FALSE;
							FeatureShuttles[i].FB.MoveArc;
							FeatureShuttles[i].subState := 1;
						END_IF;
					
					1:
						FeatureShuttles[i].FB.MoveArc.Execute := TRUE;
					
						FeatureShuttles[i].FB.MoveArc.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
						FeatureShuttles[i].FB.MoveArc.Parameters.Option := mcACP6D_ARC_ANGULAR;
						FeatureShuttles[i].FB.MoveArc.Parameters.Direction := mcACP6D_ARC_COUNTER_CLOCKWISE;
						
						FeatureShuttles[i].FB.MoveArc.Parameters.Angular.Center.X := 0.48;
						FeatureShuttles[i].FB.MoveArc.Parameters.Angular.Center.Y := 0.48;
						FeatureShuttles[i].FB.MoveArc.Parameters.Angular.Angle := 2*3*brmPI;
				
						FeatureShuttles[i].FB.MoveArc.Parameters.Acceleration := 5;
						FeatureShuttles[i].FB.MoveArc.Parameters.Velocity := 2;
						FeatureShuttles[i].FB.MoveArc.Parameters.EndVelocity := 0;
						
						FeatureShuttles[i].FB.MoveArc;
					
						IF FeatureShuttles[i].FB.MoveArc.Acknowledge OR FeatureShuttles[i].FB.MoveArc.Done THEN
							FeatureShuttles[i].FB.MoveArc.Execute := FALSE;
							FeatureShuttles[i].FB.MoveArc;
							FeatureShuttles[i].subState := 2;
						END_IF;
				END_CASE;
				IF FeatureShuttles[i].subState < 2 THEN
					tempDone := FALSE;
				END_IF;
			END_FOR;						
					
		
			IF tempDone THEN
				gameState := 7;
			END_IF;
					
			
	
	END_CASE;
	
	
	
	
		
END_ACTION
