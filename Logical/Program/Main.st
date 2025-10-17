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
END_PROGRAM

PROGRAM _CYCLIC
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
				MC_BR_ShReadInfo_Acp6D_0.Enable := TRUE;
				MC_BR_ShReadInfo_Acp6D_0.Shuttle := ADR(gShuttleList[i].Ref);
				MC_BR_ShReadInfo_Acp6D_0;
				
				IF MC_BR_ShReadInfo_Acp6D_0.Valid THEN
					brsmemcpy(ADR(gShuttles[i]),ADR(MC_BR_ShReadInfo_Acp6D_0.ShuttleInfo.Position),SIZEOF(gShuttles[0]));
					MC_BR_ShReadInfo_Acp6D_0.Enable := FALSE;
					MC_BR_ShReadInfo_Acp6D_0;
				END_IF;
			END_IF;
			
		END_FOR;
		
		
	END_IF;
	

	
	IF jkiTest THEN
		MC_BR_ShReadInfo_Acp6D_0.Enable := TRUE;
		MC_BR_ShReadInfo_Acp6D_0.Shuttle := ADR(gShuttleList[0].Ref);
		MC_BR_ShReadInfo_Acp6D_0;
		
		IF MC_BR_ShReadInfo_Acp6D_0.Valid THEN
			jkiTest := FALSE;
			MC_BR_ShReadInfo_Acp6D_0.Enable := FALSE;
			jkiTest1 := TRUE;
			X := MC_BR_ShReadInfo_Acp6D_0.ShuttleInfo.Position.X;
			Y := MC_BR_ShReadInfo_Acp6D_0.ShuttleInfo.Position.Y;
		END_IF;
		
	END_IF;
	
	
	IF jkiTest1 THEN
		IF start THEN
			IF dir = 0 THEN
				dir := 1;
			END_IF;
			
			MC_BR_MoveCyclicPosition_Acp6D_0.Enable := TRUE;
			MC_BR_MoveCyclicPosition_Acp6D_0.Parameters.DisableAxis.RX := TRUE;
			MC_BR_MoveCyclicPosition_Acp6D_0.Parameters.DisableAxis.RY := TRUE;
			MC_BR_MoveCyclicPosition_Acp6D_0.Parameters.DisableAxis.Z := TRUE;
			MC_BR_MoveCyclicPosition_Acp6D_0.Parameters.DisableAxis.RZ := TRUE;
			MC_BR_MoveCyclicPosition_Acp6D_0.Shuttle := ADR(gShuttleList[0].Ref);
			MC_BR_MoveCyclicPosition_Acp6D_0.CyclicPosition.X := X;
			MC_BR_MoveCyclicPosition_Acp6D_0.CyclicPosition.Y := Y;
			
			MC_BR_MoveCyclicPosition_Acp6D_0;
		ELSE
			MC_BR_MoveCyclicPosition_Acp6D_0.Enable := FALSE;
			MC_BR_MoveCyclicPosition_Acp6D_0;
		END_IF;
	ELSE
		MC_BR_MoveCyclicPosition_Acp6D_0.Enable := FALSE;
		MC_BR_MoveCyclicPosition_Acp6D_0;
	END_IF;
	
	IF jkiTest2 THEN
		jkiTest2 := FALSE;
		MoveToStartPosition;
		MC_BR_MoveInPlaneAsync_Acp6D_0.Assembly := ADR(gAssembly6D_1);
		MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := TRUE;
		MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Velocity := gMain.Par.Velocity;
		MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Acceleration := gMain.Par.Acceleration;
	END_IF;
	
	MC_BR_MoveInPlaneAsync_Acp6D_0;
	

	

	
	MoveInPlane;
	MoveArc;
	
	IF jkiShuffle THEN
		jkiShuffle := FALSE;
		Shuffle;
	END_IF;
	
	R_TRIG_0.CLK := jkiFeatureDemo;
	R_TRIG_0;
	
	IF R_TRIG_0.Q THEN
		FOR i := 0 TO 7 DO
			FeatureShuttles[i].runningFeature := i;
			
			FeatureShuttles[0].demoState := 0; // group movement
			FeatureShuttles[1].demoState := 10; // Top right corner movement
			FeatureShuttles[2].demoState := 20; // precision movement
			FeatureShuttles[3].demoState := 20; // weighing
			FeatureShuttles[3].master := TRUE; // movement commands done for this shuttle
			FeatureShuttles[4].demoState := 20; // group movement
			FeatureShuttles[4].alreadyBeenMaster := TRUE;
			FeatureShuttles[5].demoState := 30; // Top right corner movement
			FeatureShuttles[6].demoState := 40; // Top right corner movement
			FeatureShuttles[7].demoState := 50; // Rotary motion demo
			
			brsmemcpy(ADR(FeatureShuttles[i].Shuttle),ADR(gShuttleList[i]),SIZEOF(gShuttleList[0]));
		
		END_FOR;
	END_IF;
	
	IF jkiFeatureDemo THEN
		
		CASE zoneState OF
			0:
				IF demoStep = 2 THEN
					MC_BR_ZoneCreate_Acp6D_0.Assembly := ADR(gAssembly6D_1);
					MC_BR_ZoneCreate_Acp6D_0.Execute := TRUE;
					MC_BR_ZoneCreate_Acp6D_0.Parameters.Name := 'speedzone';
					MC_BR_ZoneCreate_Acp6D_0.Parameters.BottomLeft.X := 0.24;
					MC_BR_ZoneCreate_Acp6D_0.Parameters.BottomLeft.Y := 0.72;
					MC_BR_ZoneCreate_Acp6D_0.Parameters.TopRight.X := 0.48;
					MC_BR_ZoneCreate_Acp6D_0.Parameters.TopRight.Y := 0.96;
					MC_BR_ZoneCreate_Acp6D_0;
					
					IF MC_BR_ZoneCreate_Acp6D_0.Done THEN
						MC_BR_ZoneCreate_Acp6D_0.Execute := FALSE;
						MC_BR_ZoneCreate_Acp6D_0;
						zoneState := 1;
					END_IF;
					
				END_IF;
			
			1:
				MC_BR_AsmGetZone_Acp6D_0.Assembly := ADR(gAssembly6D_1);
				MC_BR_AsmGetZone_Acp6D_0.Enable := TRUE;
				MC_BR_AsmGetZone_Acp6D_0;
			
				IF MC_BR_AsmGetZone_Acp6D_0.Valid THEN
					IF MC_BR_AsmGetZone_Acp6D_0.AdditionalInfo.Name = 'speedzone' THEN
						MC_BR_ZoneOverride_Acp6D_0.Zone := ADR(MC_BR_AsmGetZone_Acp6D_0.Zone);
						zoneState := 2;
						
						MC_BR_ZoneOverride_Acp6D_0.Execute := TRUE;
					ELSE
						MC_BR_AsmGetZone_Acp6D_0.Next := TRUE;
					END_IF;
				END_IF;
			
			2:
				MC_BR_ZoneOverride_Acp6D_0.Parameters.Mode := mcACP6D_ZONE_OVERRIDE_ABSOLUTE;
				MC_BR_ZoneOverride_Acp6D_0.Parameters.MaxAcceleration := 20;
				MC_BR_ZoneOverride_Acp6D_0.Parameters.MaxVelocity := 0.1;
				MC_BR_ZoneOverride_Acp6D_0;
			
				IF MC_BR_ZoneOverride_Acp6D_0.Done THEN
					MC_BR_ZoneOverride_Acp6D_0.Execute := FALSE;
					MC_BR_ZoneOverride_Acp6D_0;
					zoneState := 3;
				END_IF;
					
		END_CASE;
		
		
		
		CASE demoStep OF
			0:
				
				MoveToFeaturePosition;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Assembly := ADR(gAssembly6D_1);
				MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := TRUE;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Velocity := 1;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.Acceleration := 10;
				demoStep := 1;
				
			1:
				IF MC_BR_MoveInPlaneAsync_Acp6D_0.Done THEN
					MC_BR_MoveInPlaneAsync_Acp6D_0.Execute := FALSE;
					MC_BR_MoveInPlaneAsync_Acp6D_0;
					demoStep := 2;
					loadCounter := 0;
					shIndex := 0;
					tempCounter := 1;
					
					
					
					
					
					
				END_IF;
				
			2:
				ready := TRUE;
				FOR i := 0 TO 7 DO
					CASE  FeatureShuttles[i].demoState OF
						0:
							CASE FeatureShuttles[i].subState OF
								0:
									FeatureShuttles[i].FB.MoveInPlane.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := 0.06;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y := 0.12;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Mode := mcACP6D_MOVE_ABSOLUTE;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Path := mcACP6D_PATH_DIRECT;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 0.5;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 0.5;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.EndVelocity := 0;
									FeatureShuttles[i].FB.MoveInPlane.Execute := TRUE;
									FeatureShuttles[i].FB.MoveInPlane;
								
									IF FeatureShuttles[i].FB.MoveInPlane.Done THEN
										FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
										FeatureShuttles[i].FB.MoveInPlane;
										FeatureShuttles[i].subState := 1;
									END_IF;
								
								
								1:
									FeatureShuttles[i].FB.TON_0.IN := TRUE;
									FeatureShuttles[i].FB.TON_0.PT := TIME#500ms;
									FeatureShuttles[i].FB.TON_0;
								
									IF FeatureShuttles[i].FB.TON_0.Q THEN
										FeatureShuttles[i].FB.TON_0.IN := FALSE;
										FeatureShuttles[i].FB.TON_0;
										FeatureShuttles[i].subState := 2;
									END_IF;
								
								2:
									FeatureShuttles[i].FB.MoveInPlane.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := 0.06;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y := 0.059;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Mode := mcACP6D_MOVE_ABSOLUTE;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Path := mcACP6D_PATH_DIRECT;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 0.5;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 0.5;
									FeatureShuttles[i].FB.MoveInPlane.Parameters.EndVelocity := 0;
									FeatureShuttles[i].FB.MoveInPlane.Execute := TRUE;
									FeatureShuttles[i].FB.MoveInPlane;
								
									IF FeatureShuttles[i].FB.MoveInPlane.Done THEN
										FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
										FeatureShuttles[i].FB.MoveInPlane;
										FeatureShuttles[i].subState := 3;
									END_IF;
								
								3:
									FeatureShuttles[i].FB.TON_0.IN := TRUE;
									FeatureShuttles[i].FB.TON_0.PT := TIME#500ms;
									FeatureShuttles[i].FB.TON_0;
								
									IF FeatureShuttles[i].FB.TON_0.Q THEN
										FeatureShuttles[i].FB.TON_0.IN := FALSE;
										FeatureShuttles[i].FB.TON_0;
										FeatureShuttles[i].counter := FeatureShuttles[i].counter + 1;
										IF FeatureShuttles[i].counter > 2 THEN
											FeatureShuttles[i].subState := 4;
										ELSE
											FeatureShuttles[i].subState := 0;
										END_IF;
									END_IF;
								
								4:
									FeatureShuttles[i].ready := TRUE;
								
							END_CASE;
							
						
						10:
							FeatureShuttles[i].ready := TRUE;
						
						20:
							IF FeatureShuttles[i].master THEN
								
								CASE FeatureShuttles[i].subState OF
									0:
										MC_BR_ShGroupCreate_Acp6D_0.Assembly := ADR(gAssembly6D_1);
										MC_BR_ShGroupCreate_Acp6D_0.Execute := TRUE;
										MC_BR_ShGroupCreate_Acp6D_0;
						
										IF MC_BR_ShGroupCreate_Acp6D_0.Done THEN
											MC_BR_ShGroupAddShuttle_Acp6D_0.ShuttleGroup := ADR(MC_BR_ShGroupCreate_Acp6D_0.ShuttleGroup);
											MC_BR_ShGroupCoupleCtrl_Acp6D_0.ShuttleGroup := ADR(MC_BR_ShGroupCreate_Acp6D_0.ShuttleGroup);
											MC_BR_ShGroupDelete_Acp6D_0.ShuttleGroup := ADR(MC_BR_ShGroupCreate_Acp6D_0.ShuttleGroup);
											//MC_BR_ShGroupCreate_Acp6D_0.Execute := FALSE;
											//MC_BR_ShGroupCreate_Acp6D_0;
											counter := 0;
											FOR j := 0 TO 7 DO
												// shuttles which are on the state
												IF FeatureShuttles[j].demoState = 20 THEN
													MC_BR_ShGroupAddShuttle_Acp6D_0.Parameters.ShuttleList[counter].Shuttle := ADR(FeatureShuttles[j].Shuttle.Ref);
													counter := counter + 1;
												END_IF;
											END_FOR;			
											FeatureShuttles[i].subState := 1;
											MC_BR_ShGroupAddShuttle_Acp6D_0.Execute := TRUE;
										END_IF;
									
									1:
										MC_BR_ShGroupAddShuttle_Acp6D_0;
			
										IF MC_BR_ShGroupAddShuttle_Acp6D_0.Done THEN
											MC_BR_ShGroupAddShuttle_Acp6D_0.Execute := FALSE;
											MC_BR_ShGroupAddShuttle_Acp6D_0;
											FeatureShuttles[i].subState := 2;
										END_IF;
									
									2: 
										MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := mcACP6D_SH_GROUP_COUPLE;
										MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Mode := mcACP6D_SH_GROUP_CMN_ROT_REF;
										MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
										MC_BR_ShGroupCoupleCtrl_Acp6D_0;
			
										IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
											MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
											MC_BR_ShGroupCoupleCtrl_Acp6D_0;
											FeatureShuttles[i].subState := 3;
										END_IF;
									
									3:
										FeatureShuttles[i].FB.MoveArc.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveArc.Parameters.Acceleration := 5;
										FeatureShuttles[i].FB.MoveArc.Parameters.Velocity := 0.5;
										FeatureShuttles[i].FB.MoveArc.Parameters.EndVelocity := 0.5;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.Radius := 0.03;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.Position.X := 0.720;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.Position.Y := 0.180;
										FeatureShuttles[i].FB.MoveArc.Parameters.Option := mcACP6D_ARC_RADIUS;
										FeatureShuttles[i].FB.MoveArc.Parameters.Direction := mcACP6D_ARC_COUNTER_CLOCKWISE;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.ArcType := mcACP6D_ARC_MINOR;
										FeatureShuttles[i].FB.MoveArc.Execute := TRUE;
										FeatureShuttles[i].FB.MoveArc;
				
										IF FeatureShuttles[i].FB.MoveArc.Acknowledge OR FeatureShuttles[i].FB.MoveArc.Done THEN
											FeatureShuttles[i].FB.MoveArc.Execute := FALSE;
											FeatureShuttles[i].FB.MoveArc;
											FeatureShuttles[i].subState := 4;
										END_IF;
									
									4:
										FeatureShuttles[i].FB.MoveArc.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveArc.Parameters.Acceleration := 5;
										FeatureShuttles[i].FB.MoveArc.Parameters.Velocity := 0.5;
										FeatureShuttles[i].FB.MoveArc.Parameters.EndVelocity := 0.5;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.Radius := 0.06;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.Position.X := 0.720;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.Position.Y := 0.060;
										FeatureShuttles[i].FB.MoveArc.Parameters.Option := mcACP6D_ARC_RADIUS;
										FeatureShuttles[i].FB.MoveArc.Parameters.Direction := mcACP6D_ARC_COUNTER_CLOCKWISE;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.ArcType := mcACP6D_ARC_MINOR;
										FeatureShuttles[i].FB.MoveArc.Execute := TRUE;
										FeatureShuttles[i].FB.MoveArc;
				
										IF FeatureShuttles[i].FB.MoveArc.Acknowledge OR FeatureShuttles[i].FB.MoveArc.Done THEN
											FeatureShuttles[i].FB.MoveArc.Execute := FALSE;
											FeatureShuttles[i].FB.MoveArc;
											FeatureShuttles[i].subState := 5;
										END_IF;
										
										
									5:
										FeatureShuttles[i].FB.MoveArc.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveArc.Parameters.Acceleration := 5;
										FeatureShuttles[i].FB.MoveArc.Parameters.Velocity := 0.5;
										FeatureShuttles[i].FB.MoveArc.Parameters.EndVelocity := 0.5;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.Radius := 0.03;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.Position.X := 0.720;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.Position.Y := 0.120;
										FeatureShuttles[i].FB.MoveArc.Parameters.Option := mcACP6D_ARC_RADIUS;
										FeatureShuttles[i].FB.MoveArc.Parameters.Direction := mcACP6D_ARC_COUNTER_CLOCKWISE;
										FeatureShuttles[i].FB.MoveArc.Parameters.Radius.ArcType := mcACP6D_ARC_MINOR;
										FeatureShuttles[i].FB.MoveArc.Execute := TRUE;
										FeatureShuttles[i].FB.MoveArc;
				
										IF FeatureShuttles[i].FB.MoveArc.Done THEN
											FeatureShuttles[i].FB.MoveArc.Execute := FALSE;
											FeatureShuttles[i].FB.MoveArc;
											FeatureShuttles[i].subState := 6;
											FeatureShuttles[i].counter := 0;
											FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Mode := mcACP6D_MOVE_ABSOLUTE;
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Rotation.Type := mcACP6D_SHORT_AX_ROT_ONLY;
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Rz := (9*brmPI/180);
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.001;
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Rz := 0.3;
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.002;
										END_IF;
									
									6:
										
										FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
										FeatureShuttles[i].FB.MoveShortAxis;
									
										IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
											FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
											FeatureShuttles[i].FB.MoveShortAxis;
											FeatureShuttles[i].counter := FeatureShuttles[i].counter + 1;
											IF FeatureShuttles[i].counter > 2 THEN
												FeatureShuttles[i].subState := 7;
											ELSIF FeatureShuttles[i].counter = 1 THEN
												FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Rz := -9*brmPI/180;
											ELSE
												FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Rz := 0;
											END_IF;
										END_IF;										
									
									7:
										MC_BR_ShGroupCoupleCtrl_Acp6D_0.Parameters.Option := mcACP6D_SH_GROUP_DECOUPLE;
										MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := TRUE;
										MC_BR_ShGroupCoupleCtrl_Acp6D_0;
			
										IF MC_BR_ShGroupCoupleCtrl_Acp6D_0.Done THEN
											MC_BR_ShGroupCoupleCtrl_Acp6D_0.Execute := FALSE;
											MC_BR_ShGroupCoupleCtrl_Acp6D_0;
											FeatureShuttles[i].subState := 8;
										END_IF;
									
									8:
										MC_BR_ShGroupDelete_Acp6D_0.Execute := TRUE;
										MC_BR_ShGroupDelete_Acp6D_0;
			
										IF MC_BR_ShGroupDelete_Acp6D_0.Done THEN
											MC_BR_ShGroupDelete_Acp6D_0.Execute := FALSE;
											MC_BR_ShGroupDelete_Acp6D_0;
											MC_BR_ShGroupCreate_Acp6D_0.Execute := FALSE;
											MC_BR_ShGroupCreate_Acp6D_0;
											FeatureShuttles[i].subState := 9;
										END_IF;
									
									9:
										FeatureShuttles[i].ready := TRUE;
									
								END_CASE;
							ELSE
								FeatureShuttles[i].ready := TRUE;
							END_IF;
						
						30:
							FeatureShuttles[i].ready := TRUE;
						
						40:
							FeatureShuttles[i].ready := TRUE;
						
						50:
							FeatureShuttles[i].ready := TRUE;
						
					END_CASE;	
					
					IF NOT FeatureShuttles[i].ready THEN
						ready := FALSE;
					END_IF;
				END_FOR;
				
				IF ready THEN
					FOR i := 0 TO 7 DO
						FeatureShuttles[i].subState := 0;
						FeatureShuttles[i].ready := FALSE;
						FeatureShuttles[i].counter := 0;
						FeatureShuttles[i].master := FALSE;
						FeatureShuttles[i].alreadyBeenMaster := FALSE;
						FeatureShuttles[i].runningFeature := FeatureShuttles[i].runningFeature + 1;
						IF FeatureShuttles[i].runningFeature > 7 THEN
							FeatureShuttles[i].runningFeature := 0;
						END_IF;
						CASE FeatureShuttles[i].runningFeature OF
							0:
								FeatureShuttles[i].demoState := 0; // group movement
							1:
								FeatureShuttles[i].demoState := 10; // Top right corner movement
							2:
								FeatureShuttles[i].demoState := 20; // precision movement
							3:	
								FeatureShuttles[i].demoState := 20; // weighing
								FeatureShuttles[i].master := TRUE; // movement commands done for this shuttle
							4:	
								FeatureShuttles[i].demoState := 20; // group movement
								FeatureShuttles[i].alreadyBeenMaster := TRUE;
							5:	
								FeatureShuttles[i].demoState := 30; // Top right corner movement
							6:
								FeatureShuttles[i].demoState := 40; // Top right corner movement
							7:
								FeatureShuttles[i].demoState := 50; // Rotary motion demo
						END_CASE;
					END_FOR;
					demoStep := 0;
				END_IF;
				
			
		END_CASE;		
		
	END_IF;
	
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
	
	
	IF jkiTestPayload THEN
		jkiTestPayload := FALSE;
		FOR z := 0 TO 7 DO
			weightOffsets[z].Payload.Shuttle := ADR(gShuttleList[z].Ref);
			weightOffsets[z].Payload.Execute := TRUE;
			weightOffsets[z].Payload.Duration := 0.02;
			weightOffsets[z].Payload.Mode := mcACP6D_PAYLOAD_DURATION;
			weightOffsets[z].Payload;	
			
			IF NOT weightOffsets[z].Payload.Done THEN
				jkiTestPayload := TRUE;
			ELSE
				weightOffsets[z].CurrentPayload := weightOffsets[z].Payload.Payload - weightOffsets[z].Offset;
				IF weightOffsets[z].CurrentPayload > 0.015 THEN
					cubeID := gShuttleList[z].ID;
				END_IF;
			END_IF;
		END_FOR;
		
		IF NOT jkiTestPayload THEN
			FOR z := 0 TO 7 DO
				weightOffsets[z].Payload.Shuttle := ADR(gShuttleList[z].Ref);
				weightOffsets[z].Payload.Execute := FALSE;
				weightOffsets[z].Payload;				
			END_FOR;
		END_IF;
		
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