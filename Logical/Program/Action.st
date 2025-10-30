ACTION FeatureAction:
	IF gFeatureDemo.Cmd.StartDemo THEN
		gFeatureDemo.Cmd.StartDemo := FALSE;
		gFeatureDemo.Active := TRUE;
		FOR i := 0 TO 7 DO
			FeatureShuttles[i].runningFeature := i;
			
			FeatureShuttles[i].master := FALSE;
			FeatureShuttles[i].subState := 0;
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
	
	IF gFeatureDemo.zoneIndex > 0 THEN
		//[{'value':'4','text':'Member1'},{'value':'2','text':'Member2'},{'value':'1','text':'Member3'}]; 
		brsmemset(ADR(gHMI.ZoneDataProvider),0,SIZEOF(gHMI.ZoneDataProvider));
		FOR i := 0 TO (gFeatureDemo.zoneIndex-1) DO
			brsstrcat(ADR(gHMI.ZoneDataProvider[i]),ADR('{"value":"'));
			brsitoa(USINT_TO_DINT(i),ADR(gFeatureDemo.Int.tempSTR1));
			brsstrcat(ADR(gHMI.ZoneDataProvider[i]),ADR(gFeatureDemo.Int.tempSTR1));
			brsstrcat(ADR(gHMI.ZoneDataProvider[i]),ADR('","text":"Speezone '));
			brsstrcat(ADR(gHMI.ZoneDataProvider[i]),ADR(gFeatureDemo.Int.tempSTR1));
			brsstrcat(ADR(gHMI.ZoneDataProvider[i]),ADR('"}'));
		END_FOR;

		IF gHMI.ZoneDataIndex < gFeatureDemo.zoneIndex THEN
			brsmemcpy(ADR(gHMI.Zone.Preview),ADR(gZones[gHMI.ZoneDataIndex].Preview),SIZEOF(gHMI.Zone.Preview));
		END_IF;		
	END_IF;
	
	
	
	
	IF gFeatureDemo.Active THEN
			
		CASE gFeatureDemo.featureState OF
			0:
				IF gFeatureDemo.featureDemoState = 2 THEN
					gFeatureDemo.FB.ZoneCreate.Assembly := ADR(gAssembly6D_1);
					gFeatureDemo.FB.ZoneCreate.Execute := TRUE;
					brsitoa(gFeatureDemo.zoneIndex,ADR(gFeatureDemo.Int.tempSTR));
					gFeatureDemo.FB.ZoneCreate.Parameters.Name := CONCAT('speedzone',gFeatureDemo.Int.tempSTR);
					IF gFeatureDemo.zoneIndex = 0 THEN
						gFeatureDemo.newZoneData.BottomLeft.X := 0.24;
						gFeatureDemo.newZoneData.BottomLeft.Y := 0.72;
						gFeatureDemo.newZoneData.TopRight.X := 0.48;
						gFeatureDemo.newZoneData.TopRight.Y := 0.96;
					END_IF;
					gFeatureDemo.FB.ZoneCreate.Parameters.BottomLeft.X := gFeatureDemo.newZoneData.BottomLeft.X;
					gFeatureDemo.FB.ZoneCreate.Parameters.BottomLeft.Y := gFeatureDemo.newZoneData.BottomLeft.Y;
					gFeatureDemo.FB.ZoneCreate.Parameters.TopRight.X := gFeatureDemo.newZoneData.TopRight.X;
					gFeatureDemo.FB.ZoneCreate.Parameters.TopRight.Y := gFeatureDemo.newZoneData.TopRight.Y;
					gFeatureDemo.FB.ZoneCreate;
					
					IF gFeatureDemo.FB.ZoneCreate.Done THEN
						gFeatureDemo.FB.ZoneCreate.Execute := FALSE;
						gFeatureDemo.FB.ZoneCreate;
						gFeatureDemo.FB.GetZone.Enable := FALSE;
						gFeatureDemo.FB.GetZone;
						gFeatureDemo.FB.ZoneOverride.Execute := FALSE;
						gFeatureDemo.FB.ZoneOverride;
						gFeatureDemo.featureState := 1;
					END_IF;
					
				END_IF;
			
			1:
				gFeatureDemo.FB.GetZone.Assembly := ADR(gAssembly6D_1);
				gFeatureDemo.FB.GetZone.Enable := TRUE;
				gFeatureDemo.FB.GetZone;
			
				IF gFeatureDemo.FB.GetZone.Valid THEN
					IF gFeatureDemo.FB.GetZone.AdditionalInfo.Name = CONCAT('speedzone',gFeatureDemo.Int.tempSTR) THEN
						IF gFeatureDemo.zoneIndex < 50 THEN
							brsmemcpy(ADR(gZones[gFeatureDemo.zoneIndex].Preview),ADR(gFeatureDemo.newZoneData),SIZEOF(gFeatureDemo.newZoneData));
						END_IF;
						gFeatureDemo.zoneIndex := gFeatureDemo.zoneIndex + 1;
						
						gFeatureDemo.FB.ZoneOverride.Zone := ADR(gFeatureDemo.FB.GetZone.Zone);
						gFeatureDemo.featureState := 2;
						gFeatureDemo.FB.ZoneOverride.Execute := TRUE;
					ELSE
						gFeatureDemo.FB.GetZone.Next := FALSE;
						gFeatureDemo.FB.GetZone;
						gFeatureDemo.FB.GetZone.Next := TRUE;
					END_IF;
				ELSIF gFeatureDemo.FB.GetZone.Error THEN
					gFeatureDemo.FB.GetZone.Enable := FALSE;
					gFeatureDemo.FB.GetZone;
					gFeatureDemo.FB.GetZone.Next := FALSE;
					gFeatureDemo.featureState := 0;
				END_IF;
			
			2:
				gFeatureDemo.FB.ZoneOverride.Parameters.Mode := mcACP6D_ZONE_OVERRIDE_ABSOLUTE;
				gFeatureDemo.FB.ZoneOverride.Parameters.MaxAcceleration := 20;
				gFeatureDemo.FB.ZoneOverride.Parameters.MaxVelocity := 0.1;
				gFeatureDemo.FB.ZoneOverride;
			
				IF gFeatureDemo.FB.ZoneOverride.Done THEN
					gFeatureDemo.FB.ZoneOverride.Execute := FALSE;
					gFeatureDemo.FB.ZoneOverride;
					brsmemcpy(ADR(gHMI.Zone.Active),ADR(gFeatureDemo.newZoneData),SIZEOF(gFeatureDemo.newZoneData));
					gFeatureDemo.featureState := 3;
				ELSIF gFeatureDemo.FB.ZoneOverride.Error THEN
					IF gFeatureDemo.FB.GetZone.AdditionalInfo.ZoneID = 0 THEN
						gFeatureDemo.FB.ZoneOverride.Execute := FALSE;
						gFeatureDemo.FB.ZoneOverride;
						gFeatureDemo.featureState := 0;
						IF gFeatureDemo.zoneIndex > 0 THEN
							gFeatureDemo.zoneIndex := gFeatureDemo.zoneIndex -1;
						END_IF;
					END_IF;
				END_IF;
			
			3:
			
				gFeatureDemo.FB.StereoTypeDefine.Assembly := ADR(gAssembly6D_1);
				gFeatureDemo.FB.StereoTypeDefine.Parameters.Name := 'default';
				gFeatureDemo.FB.StereoTypeDefine.Execute := TRUE;
				gFeatureDemo.FB.StereoTypeDefine;
			
				IF gFeatureDemo.FB.StereoTypeDefine.Done THEN
					gFeatureDemo.FB.StereoTypeDefine.Execute := FALSE;
					gFeatureDemo.FB.StereoTypeDefine;
					gFeatureDemo.featureState := 4;
				ELSIF gFeatureDemo.FB.StereoTypeDefine.Error THEN
					gFeatureDemo.FB.StereoTypeDefine.Execute := FALSE;
					gFeatureDemo.FB.StereoTypeDefine;
					gFeatureDemo.featureState := 5;
				END_IF;
			
			4:
				gFeatureDemo.FB.StereoTypeDefine.Assembly := ADR(gAssembly6D_1);
				gFeatureDemo.FB.StereoTypeDefine.Parameters.PayloadSize.XOffsetNeg := -0.120;
				gFeatureDemo.FB.StereoTypeDefine.Parameters.Type := mcACP6D_SH_STEREOTYPE_CUSTOM;
				gFeatureDemo.FB.StereoTypeDefine.Parameters.Name := 'custom';
				gFeatureDemo.FB.StereoTypeDefine.Execute := TRUE;
				gFeatureDemo.FB.StereoTypeDefine;
			
				IF gFeatureDemo.FB.StereoTypeDefine.Done THEN
					
					gHMI.Stereotype.Size.XOffsetNeg := -0.120;
					gHMI.Stereotype.Size.XOffsetPos := 0.06;
					gHMI.Stereotype.Size.YOffsetNeg := -0.06;
					gHMI.Stereotype.Size.YOffsetPos := 0.06;
					gFeatureDemo.FB.StereoTypeDefine.Execute := FALSE;
					gFeatureDemo.FB.StereoTypeDefine;
					gFeatureDemo.featureState := 5;
				END_IF;
			
			5:
				
				IF gFeatureDemo.Cmd.newZone THEN
					gFeatureDemo.Cmd.newZone := FALSE;
					gFeatureDemo.featureState := 12;
				ELSIF gHMI.ActivateZone THEN
					brsmemset(ADR(gHMI.Zone.Preview),0,SIZEOF(gHMI.Zone.Preview));
					gHMI.ActivateZone := FALSE;
					gFeatureDemo.featureState := 13;
				ELSIF gFeatureDemo.Cmd.newStereotype THEN
					gFeatureDemo.Cmd.newStereotype := FALSE;
					gFeatureDemo.featureState := 6;
				ELSIF gFeatureDemo.Cmd.StopDemo AND NOT gFeatureDemo.Int.zoneReset THEN
					gFeatureDemo.featureState := 13;
				END_IF;
				
				
			6:
				
				gFeatureDemo.FB.StereoTypeDelete.Assembly := ADR(gAssembly6D_1);
				gFeatureDemo.FB.StereoTypeDelete.Command := mcACP6D_SH_ST_DELETE_SPECIFIC;
				gFeatureDemo.FB.StereoTypeDelete.Name := 'custom';
				gFeatureDemo.FB.StereoTypeDelete.Execute := TRUE;
				gFeatureDemo.FB.StereoTypeDelete;
				
				IF gFeatureDemo.FB.StereoTypeDelete.Done THEN
					gFeatureDemo.FB.StereoTypeDelete.Execute := FALSE;
					gFeatureDemo.FB.StereoTypeDelete;
					gFeatureDemo.featureState := 7;
				END_IF;
				
			7:
				
				gFeatureDemo.FB.StereoTypeDefine.Assembly := ADR(gAssembly6D_1);
				brsmemcpy(ADR(gFeatureDemo.FB.StereoTypeDefine.Parameters.PayloadSize),ADR(gFeatureDemo.newStereotypeData),SIZEOF(gFeatureDemo.newStereotypeData));
				gFeatureDemo.FB.StereoTypeDefine.Parameters.Type := mcACP6D_SH_STEREOTYPE_CUSTOM;
				gFeatureDemo.FB.StereoTypeDefine.Parameters.Name := 'custom';
				gFeatureDemo.FB.StereoTypeDefine.Execute := TRUE;
				gFeatureDemo.FB.StereoTypeDefine;
			
				IF gFeatureDemo.FB.StereoTypeDefine.Done THEN
					brsmemcpy(ADR(gHMI.Stereotype.Size),ADR(gFeatureDemo.newStereotypeData),SIZEOF(gFeatureDemo.newStereotypeData));
					gFeatureDemo.FB.StereoTypeDefine.Execute := FALSE;
					gFeatureDemo.FB.StereoTypeDefine;
					gFeatureDemo.featureState := 8;
				END_IF;
				
			8:
				FOR z := 0 TO 7 DO
					IF (FeatureShuttles[z].demoState = 40) AND (FeatureShuttles[z].subState > 0) THEN
						FeatureShuttles[z].subState := 0;
						EXIT;
					END_IF;
				END_FOR;
				gFeatureDemo.featureState := 5;
				
			10:
				gFeatureDemo.FB.ZoneOverride.Execute := FALSE;
				gFeatureDemo.FB.ZoneOverride;
				gFeatureDemo.FB.GetZone.Enable := FALSE;
				gFeatureDemo.FB.GetZone;
				gFeatureDemo.FB.GetZone.Next := FALSE;
			
			12:
				gFeatureDemo.FB.ZoneOverride.Execute := TRUE;
				gFeatureDemo.FB.ZoneOverride.Parameters.Mode := mcACP6D_ZONE_OVERRIDE_FACTOR;
				gFeatureDemo.FB.ZoneOverride.Parameters.MaxAcceleration := 1;
				gFeatureDemo.FB.ZoneOverride.Parameters.MaxVelocity := 1;
				gFeatureDemo.FB.ZoneOverride;
			
				IF gFeatureDemo.FB.ZoneOverride.Done THEN
					gFeatureDemo.FB.ZoneOverride.Execute := FALSE;
					gFeatureDemo.FB.ZoneOverride;
					gFeatureDemo.featureState := 0;
				END_IF;
			
			
			13:
				
				gFeatureDemo.FB.ZoneOverride.Execute := TRUE;
				gFeatureDemo.FB.ZoneOverride.Parameters.Mode := mcACP6D_ZONE_OVERRIDE_FACTOR;
				gFeatureDemo.FB.ZoneOverride.Parameters.MaxAcceleration := 1;
				gFeatureDemo.FB.ZoneOverride.Parameters.MaxVelocity := 1;
				gFeatureDemo.FB.ZoneOverride;
			
				IF gFeatureDemo.FB.ZoneOverride.Done THEN
					gFeatureDemo.FB.ZoneOverride.Execute := FALSE;
					gFeatureDemo.FB.ZoneOverride;
					IF gFeatureDemo.Cmd.StopDemo THEN
						gFeatureDemo.featureState := 5;
						gFeatureDemo.Int.zoneReset := TRUE;
					ELSE
						gFeatureDemo.featureState := 14;
					END_IF;
					gFeatureDemo.FB.GetZone.Enable := FALSE;
					gFeatureDemo.FB.GetZone;
				ELSIF gFeatureDemo.FB.ZoneOverride.Error THEN
					IF gFeatureDemo.Cmd.StopDemo THEN
						gFeatureDemo.featureState := 5;
						gFeatureDemo.Int.zoneReset := TRUE;
					ELSE
						gFeatureDemo.featureState := 14;
					END_IF;
					gFeatureDemo.FB.GetZone.Enable := FALSE;
					gFeatureDemo.FB.GetZone;
				END_IF;
				
			14:
				
				gFeatureDemo.FB.GetZone.Assembly := ADR(gAssembly6D_1);
				gFeatureDemo.FB.GetZone.Enable := TRUE;
				gFeatureDemo.FB.GetZone;
			
				IF gFeatureDemo.FB.GetZone.Valid THEN
					
					brsitoa(USINT_TO_DINT(gHMI.ZoneDataIndex),ADR(gFeatureDemo.Int.tempSTR1));
					IF gFeatureDemo.FB.GetZone.AdditionalInfo.Name = CONCAT('speedzone',gFeatureDemo.Int.tempSTR1) THEN
					
						
						gFeatureDemo.FB.ZoneOverride.Zone := ADR(gFeatureDemo.FB.GetZone.Zone);
						gFeatureDemo.featureState := 15;
						gFeatureDemo.FB.ZoneOverride.Execute := TRUE;
					ELSE
						gFeatureDemo.FB.GetZone.Next := FALSE;
						gFeatureDemo.FB.GetZone;
						gFeatureDemo.FB.GetZone.Next := TRUE;
					END_IF;
				ELSIF gFeatureDemo.FB.GetZone.Error THEN
					
				END_IF;
			
			15:
			
				gFeatureDemo.FB.ZoneOverride.Parameters.Mode := mcACP6D_ZONE_OVERRIDE_ABSOLUTE;
				gFeatureDemo.FB.ZoneOverride.Parameters.MaxAcceleration := 20;
				gFeatureDemo.FB.ZoneOverride.Parameters.MaxVelocity := 0.1;
				gFeatureDemo.FB.ZoneOverride;
			
				IF gFeatureDemo.FB.ZoneOverride.Done THEN
					gFeatureDemo.FB.ZoneOverride.Execute := FALSE;
					gFeatureDemo.FB.ZoneOverride;
					brsmemcpy(ADR(gHMI.Zone.Active),ADR(gZones[gHMI.ZoneDataIndex].Preview),SIZEOF(gZones[gHMI.ZoneDataIndex].Preview));
					gFeatureDemo.featureState := 5;
					
				END_IF;
					
		END_CASE;
		
		
		CASE gFeatureDemo.featureDemoState OF
			0:
				
				MoveToFeaturePosition;
				gFeatureDemo.FB.MoveInPlaneAsync.Assembly := ADR(gAssembly6D_1);
				gFeatureDemo.FB.MoveInPlaneAsync.Execute := TRUE;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.Velocity := 1;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.Acceleration := 10;
				gFeatureDemo.featureDemoState := 1;
				
			1:
				gFeatureDemo.FB.MoveInPlaneAsync;
				IF gFeatureDemo.FB.MoveInPlaneAsync.Done THEN
					gFeatureDemo.FB.MoveInPlaneAsync.Execute := FALSE;
					gFeatureDemo.FB.MoveInPlaneAsync;
					gFeatureDemo.featureDemoState := 2;
					loadCounter := 0;
					shIndex := 0;
					tempCounter := 1;
				ELSIF gFeatureDemo.FB.MoveInPlaneAsync.Error THEN
					gFeatureDemo.FB.MoveInPlaneAsync.Execute := FALSE;
					gFeatureDemo.FB.MoveInPlaneAsync;
					gFeatureDemo.featureDemoState := 0;
				END_IF;
				
			2:
				IF gFeatureDemo.featureState > 4 THEN
					gFeatureDemo.Int.ready := TRUE;
					FOR i := 0 TO 7 DO
						CASE  FeatureShuttles[i].demoState OF
							0:
								IF gFeatureDemo.Cmd.StopDemo THEN
									IF FeatureShuttles[i].subState < 4 THEN
										FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
										FeatureShuttles[i].FB.MoveInPlane;
										FeatureShuttles[i].subState := 4;
									END_IF;
								END_IF;
								
								CASE FeatureShuttles[i].subState OF
									0:
										FeatureShuttles[i].FB.MoveInPlane.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := 0.12;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y := 0.12;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Mode := mcACP6D_MOVE_ABSOLUTE;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Path := mcACP6D_PATH_DIRECT;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 0.5;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 0.1;
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
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := 0.12;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y := 0.059;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Mode := mcACP6D_MOVE_ABSOLUTE;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Path := mcACP6D_PATH_DIRECT;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 0.1;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 0.1;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.EndVelocity := 0;
										FeatureShuttles[i].FB.MoveInPlane.Execute := TRUE;
										FeatureShuttles[i].FB.MoveInPlane;
									
										IF FeatureShuttles[i].FB.MoveInPlane.Done THEN
											FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
											FeatureShuttles[i].FB.MoveInPlane;
											FeatureShuttles[i].subState := 3;
										ELSIF  FeatureShuttles[i].FB.MoveInPlane.CommandAborted THEN
											FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
											FeatureShuttles[i].FB.MoveInPlane;
										END_IF;
									
									3:
										FeatureShuttles[i].FB.TON_0.IN := TRUE;
										FeatureShuttles[i].FB.TON_0.PT := TIME#2000ms;
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
										FeatureShuttles[i].FB.MoveInPlane.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := 0.12;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y := 0.12;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Mode := mcACP6D_MOVE_ABSOLUTE;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Path := mcACP6D_PATH_DIRECT;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 0.5;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 0.1;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.EndVelocity := 0;
										FeatureShuttles[i].FB.MoveInPlane.Execute := TRUE;
										FeatureShuttles[i].FB.MoveInPlane;
									
										IF FeatureShuttles[i].FB.MoveInPlane.Done THEN
											FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
											FeatureShuttles[i].FB.MoveInPlane;
											FeatureShuttles[i].subState := 5;
										ELSIF  FeatureShuttles[i].FB.MoveInPlane.CommandAborted THEN
											FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
											FeatureShuttles[i].FB.MoveInPlane;
										END_IF;
									5:
										
										FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
										FeatureShuttles[i].FB.MoveInPlane;
										FeatureShuttles[i].FB.TON_0.IN := FALSE;
										
										FeatureShuttles[i].FB.TON_0;
										FeatureShuttles[i].ready := TRUE;
									
								END_CASE;
								
							
							10:
								FeatureShuttles[i].ready := TRUE;
							
							20:
								IF FeatureShuttles[i].master THEN
									IF gFeatureDemo.Cmd.StopDemo THEN
										IF (FeatureShuttles[i].subState > 0) AND (FeatureShuttles[i].subState < 7) THEN
											FeatureShuttles[i].subState := 7;
										ELSIF FeatureShuttles[i].subState > 9 THEN
											FeatureShuttles[i].subState := 20;
											FeatureShuttles[i].FB.TON_0.IN := FALSE;
											FeatureShuttles[i].FB.TON_0;
										END_IF;
									END_IF;
									CASE FeatureShuttles[i].subState OF
										0:
											gFeatureDemo.FB.GroupCreate.Assembly := ADR(gAssembly6D_1);
											gFeatureDemo.FB.GroupCreate.Execute := TRUE;
											gFeatureDemo.FB.GroupCreate;
							
											IF gFeatureDemo.FB.GroupCreate.Done THEN
												gFeatureDemo.FB.GroupAddShuttle.ShuttleGroup := ADR(gFeatureDemo.FB.GroupCreate.ShuttleGroup);
												gFeatureDemo.FB.GroupCoupleCtrl.ShuttleGroup := ADR(gFeatureDemo.FB.GroupCreate.ShuttleGroup);
												gFeatureDemo.FB.GroupDelete.ShuttleGroup := ADR(gFeatureDemo.FB.GroupCreate.ShuttleGroup);
												//gFeatureDemo.FB.GroupCreate.Execute := FALSE;
												//gFeatureDemo.FB.GroupCreate;
												counter := 0;
												FOR j := 0 TO 7 DO
													// shuttles which are on the state
													IF FeatureShuttles[j].demoState = 20 THEN
														gFeatureDemo.FB.GroupAddShuttle.Parameters.ShuttleList[counter].Shuttle := ADR(FeatureShuttles[j].Shuttle.Ref);
														counter := counter + 1;
													END_IF;
												END_FOR;			
												FeatureShuttles[i].subState := 1;
												
												gFeatureDemo.FB.GroupAddShuttle.Execute := TRUE;
											END_IF;
										
										1:
											gFeatureDemo.FB.GroupAddShuttle;
				
											IF gFeatureDemo.FB.GroupAddShuttle.Done THEN
												gFeatureDemo.FB.GroupAddShuttle.Execute := FALSE;
												gFeatureDemo.FB.GroupAddShuttle;
												FeatureShuttles[i].subState := 2;
											END_IF;
										
										2: 
											gFeatureDemo.FB.GroupCoupleCtrl.Parameters.Option := mcACP6D_SH_GROUP_COUPLE;
											gFeatureDemo.FB.GroupCoupleCtrl.Parameters.Mode := mcACP6D_SH_GROUP_CMN_ROT_REF;
											gFeatureDemo.FB.GroupCoupleCtrl.Execute := TRUE;
											gFeatureDemo.FB.GroupCoupleCtrl;
				
											IF gFeatureDemo.FB.GroupCoupleCtrl.Done THEN
												gFeatureDemo.FB.GroupCoupleCtrl.Execute := FALSE;
												gFeatureDemo.FB.GroupCoupleCtrl;
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
											
											gFeatureDemo.FB.GroupCoupleCtrl.Parameters.Option := mcACP6D_SH_GROUP_DECOUPLE;
											gFeatureDemo.FB.GroupCoupleCtrl.Execute := TRUE;
											gFeatureDemo.FB.GroupCoupleCtrl;
				
											IF gFeatureDemo.FB.GroupCoupleCtrl.Done THEN
												gFeatureDemo.FB.GroupCoupleCtrl.Execute := FALSE;
												gFeatureDemo.FB.GroupCoupleCtrl;
												FeatureShuttles[i].subState := 8;
											END_IF;
										
										8:
											
											gFeatureDemo.FB.GroupDelete.Execute := TRUE;
											gFeatureDemo.FB.GroupDelete;
				
											IF gFeatureDemo.FB.GroupDelete.Done THEN
												gFeatureDemo.FB.GroupDelete.Execute := FALSE;
												gFeatureDemo.FB.GroupDelete;
												gFeatureDemo.FB.GroupCreate.Execute := FALSE;
												gFeatureDemo.FB.GroupCreate;
												IF gFeatureDemo.Cmd.StopDemo THEN
													FeatureShuttles[i].subState := 20;
												ELSE
													FeatureShuttles[i].subState := 9;
												END_IF;
											ELSIF gFeatureDemo.FB.GroupDelete.Error THEN
												gFeatureDemo.FB.GroupDelete.Execute := FALSE;
												gFeatureDemo.FB.GroupDelete;
												IF gFeatureDemo.Cmd.StopDemo THEN
													FeatureShuttles[i].subState := 20;
												ELSE
													FeatureShuttles[i].subState := 9;
												END_IF;
											END_IF;
										
										9:
											//FeatureShutt
											IF FeatureShuttles[i].Shuttle.ID = 8 THEN
												FOR z := 0 TO 7 DO
													IF FeatureShuttles[z].Shuttle.ID = 1 THEN
														FeatureShuttles[z].subState := 1;
													ELSIF FeatureShuttles[z].Shuttle.ID = 7 THEN
														FeatureShuttles[z].subState := 1;
													END_IF;
												END_FOR;
												// special case 
											ELSIF FeatureShuttles[i].Shuttle.ID = 1 THEN
												FOR z := 0 TO 7 DO
													IF FeatureShuttles[z].Shuttle.ID = 8 THEN
														FeatureShuttles[z].subState := 1;
													ELSIF FeatureShuttles[z].Shuttle.ID = 2 THEN
														FeatureShuttles[z].subState := 1;
													END_IF;
												END_FOR;
											ELSE
												// normal case
												FOR z := 0 TO 7 DO
													IF FeatureShuttles[z].Shuttle.ID = (FeatureShuttles[i].Shuttle.ID - 1) THEN
														FeatureShuttles[z].subState := 1;
													ELSIF FeatureShuttles[z].Shuttle.ID = (FeatureShuttles[i].Shuttle.ID + 1)THEN
														FeatureShuttles[z].subState := 1;
													END_IF;
												END_FOR;
											END_IF;
											FeatureShuttles[i].subState := 10;
										
											
										10:
											FeatureShuttles[i].FB.TON_0.IN := TRUE;
											FeatureShuttles[i].FB.TON_0.PT := TIME#100ms;
											FeatureShuttles[i].FB.TON_0;
											
											IF FeatureShuttles[i].FB.TON_0.Q THEN
												FeatureShuttles[i].FB.TON_0.IN := FALSE;
												FeatureShuttles[i].FB.TON_0;
												FeatureShuttles[i].subState := 11;
												FeatureShuttles[i].counter := 0;
											END_IF;
											
											
										11:
											FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
											brsmemset(ADR(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position),0,SIZEOF(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position));
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.004;
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.005;
											FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
											FeatureShuttles[i].FB.MoveShortAxis;
											IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
												FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
												FeatureShuttles[i].FB.MoveShortAxis;
												FeatureShuttles[i].subState := 12;
											END_IF;
											
										12:
											FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
											brsmemset(ADR(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position),0,SIZEOF(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position));
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.001;
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.005;
											FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
											FeatureShuttles[i].FB.MoveShortAxis;
											IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
												FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
												FeatureShuttles[i].FB.MoveShortAxis;
												FeatureShuttles[i].counter := FeatureShuttles[i].counter + 1;
												IF FeatureShuttles[i].counter > 3 THEN
													FeatureShuttles[i].subState := 20;
												ELSE
													FeatureShuttles[i].subState := 11;
												END_IF;
											END_IF;
											
											
										20:
											FeatureShuttles[i].FB.TON_0.IN := FALSE;
											FeatureShuttles[i].FB.TON_0;
											FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
											FeatureShuttles[i].FB.MoveShortAxis;
											gFeatureDemo.FB.GroupDelete.Execute := FALSE;
											gFeatureDemo.FB.GroupDelete;
											gFeatureDemo.FB.GroupCreate.Execute := FALSE;
											gFeatureDemo.FB.GroupCreate;
											gFeatureDemo.FB.GroupCoupleCtrl.Execute := FALSE;
											gFeatureDemo.FB.GroupCoupleCtrl;
											FeatureShuttles[i].ready := TRUE;
										
									END_CASE;
								ELSE
									IF gFeatureDemo.Cmd.StopDemo THEN
										IF FeatureShuttles[i].subState > 0 THEN
											FeatureShuttles[i].subState := 20;
										END_IF;
									END_IF;
									CASE FeatureShuttles[i].subState OF
										0:
											// wait for group done
											IF gFeatureDemo.Cmd.StopDemo THEN
												FeatureShuttles[i].FB.TON_0.IN := TRUE;
												FeatureShuttles[i].FB.TON_0.PT := TIME#5s;
												FeatureShuttles[i].FB.TON_0;
												IF FeatureShuttles[i].FB.TON_0.Q THEN
													FeatureShuttles[i].FB.TON_0.IN := FALSE;
													FeatureShuttles[i].FB.TON_0;
													FeatureShuttles[i].subState := 1;
												END_IF;
											END_IF;
											
										1:
											FeatureShuttles[i].FB.TON_0.IN := TRUE;
											FeatureShuttles[i].FB.TON_0.PT := TIME#350ms;
											FeatureShuttles[i].FB.TON_0;
											
											IF FeatureShuttles[i].FB.TON_0.Q THEN
												FeatureShuttles[i].FB.TON_0.IN := FALSE;
												FeatureShuttles[i].FB.TON_0;
												FeatureShuttles[i].subState := 11;
											END_IF;
											
											
										11:
											FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
											brsmemset(ADR(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position),0,SIZEOF(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position));
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.004;
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.005;
											FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
											FeatureShuttles[i].FB.MoveShortAxis;
											IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
												FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
												FeatureShuttles[i].FB.MoveShortAxis;
												FeatureShuttles[i].subState := 12;
											END_IF;
											
										12:
											FeatureShuttles[i].FB.MoveShortAxis.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
											brsmemset(ADR(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position),0,SIZEOF(FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position));
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Position.Z := 0.001;
											FeatureShuttles[i].FB.MoveShortAxis.Parameters.Velocity.Z := 0.005;
											FeatureShuttles[i].FB.MoveShortAxis.Execute := TRUE;
											FeatureShuttles[i].FB.MoveShortAxis;
											IF FeatureShuttles[i].FB.MoveShortAxis.Done THEN
												FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
												FeatureShuttles[i].FB.MoveShortAxis;
												FeatureShuttles[i].counter := FeatureShuttles[i].counter + 1;
												IF FeatureShuttles[i].counter > 3 THEN
													FeatureShuttles[i].subState := 20;
												ELSE
													FeatureShuttles[i].subState := 11;
												END_IF;
											END_IF;
											
										20:
											FeatureShuttles[i].FB.MoveShortAxis.Execute := FALSE;
											FeatureShuttles[i].FB.MoveShortAxis;
											FeatureShuttles[i].ready := TRUE;
									END_CASE;
								END_IF;
							
							30:
								IF gFeatureDemo.Cmd.StopDemo THEN
									FeatureShuttles[i].subState := 20;
								END_IF;
								CASE FeatureShuttles[i].subState OF
									
									0:
										FeatureShuttles[i].FB.RotaryMotion.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Acceleration := 10;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Angle := brmPI/2 - brmPI*BOOL_TO_REAL(FeatureShuttles[i].counter > 0)/2;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Mode := mcACP6D_ROTATE_ABSOLUTE_POS;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Velocity := 10;
										FeatureShuttles[i].FB.RotaryMotion.Execute := TRUE;
										FeatureShuttles[i].FB.RotaryMotion;
										
										IF FeatureShuttles[i].FB.RotaryMotion.Done THEN
											FeatureShuttles[i].FB.RotaryMotion.Execute := FALSE;
											FeatureShuttles[i].FB.RotaryMotion;
											FeatureShuttles[i].counter := FeatureShuttles[i].counter + 1;
											IF FeatureShuttles[i].counter > 2 THEN
												FeatureShuttles[i].subState := 20;
											ELSE
												FeatureShuttles[i].subState := 1;
											END_IF;
										END_IF;
										
									1:
										FeatureShuttles[i].FB.MoveInPlane.Execute := TRUE;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := 0.36;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y := 0.60;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 20;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 1;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.EndVelocity := 0;
										FeatureShuttles[i].FB.MoveInPlane.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveInPlane;
										
										IF FeatureShuttles[i].FB.MoveInPlane.Done THEN
											FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
											FeatureShuttles[i].FB.MoveInPlane;
											
											FeatureShuttles[i].subState := 2;
										END_IF;
										
									2:
										FeatureShuttles[i].FB.RotaryMotion.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Acceleration := 10;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Angle := brmPI;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Mode := mcACP6D_ROTATE_ABSOLUTE_POS;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Velocity := 10;
										FeatureShuttles[i].FB.RotaryMotion.Execute := TRUE;
										FeatureShuttles[i].FB.RotaryMotion;
										
										IF FeatureShuttles[i].FB.RotaryMotion.Done THEN
											FeatureShuttles[i].FB.RotaryMotion.Execute := FALSE;
											FeatureShuttles[i].FB.RotaryMotion;
											FeatureShuttles[i].subState := 3;
										END_IF;
										
									3:
										FeatureShuttles[i].FB.MoveInPlane.Execute := TRUE;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := 0.36;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y := 0.36;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 20;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 1;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.EndVelocity := 0;
										FeatureShuttles[i].FB.MoveInPlane.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveInPlane;
										
										IF FeatureShuttles[i].FB.MoveInPlane.Done THEN
											FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
											FeatureShuttles[i].FB.MoveInPlane;
											
											FeatureShuttles[i].subState := 4;
										END_IF;
										
									4:
										FeatureShuttles[i].FB.RotaryMotion.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Acceleration := 10;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Angle := 3*brmPI/2;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Mode := mcACP6D_ROTATE_ABSOLUTE_POS;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Velocity := 10;
										FeatureShuttles[i].FB.RotaryMotion.Execute := TRUE;
										FeatureShuttles[i].FB.RotaryMotion;
										
										IF FeatureShuttles[i].FB.RotaryMotion.Done THEN
											FeatureShuttles[i].FB.RotaryMotion.Execute := FALSE;
											FeatureShuttles[i].FB.RotaryMotion;
											FeatureShuttles[i].subState := 5;
										END_IF;
										
									5:
										FeatureShuttles[i].FB.MoveInPlane.Execute := TRUE;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := 0.60;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y := 0.36;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 20;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 1;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.EndVelocity := 0;
										FeatureShuttles[i].FB.MoveInPlane.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveInPlane;
										
										IF FeatureShuttles[i].FB.MoveInPlane.Done THEN
											FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
											FeatureShuttles[i].FB.MoveInPlane;
											
											FeatureShuttles[i].subState := 6;
										END_IF;
										
										
									6:
										FeatureShuttles[i].FB.RotaryMotion.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Acceleration := 10;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Angle := brmPI*2;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Mode := mcACP6D_ROTATE_ABSOLUTE_POS;
										FeatureShuttles[i].FB.RotaryMotion.Parameters.Velocity := 10;
										FeatureShuttles[i].FB.RotaryMotion.Execute := TRUE;
										FeatureShuttles[i].FB.RotaryMotion;
										
										IF FeatureShuttles[i].FB.RotaryMotion.Done THEN
											FeatureShuttles[i].FB.RotaryMotion.Execute := FALSE;
											FeatureShuttles[i].FB.RotaryMotion;
											FeatureShuttles[i].subState := 7;
										END_IF;
										
									7:
										FeatureShuttles[i].FB.MoveInPlane.Execute := TRUE;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := 0.60;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y := 0.60;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 20;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 1;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.EndVelocity := 0;
										FeatureShuttles[i].FB.MoveInPlane.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveInPlane;
										
										IF FeatureShuttles[i].FB.MoveInPlane.Done THEN
											FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
											FeatureShuttles[i].FB.MoveInPlane;
											FeatureShuttles[i].subState := 0;
										
										END_IF;
										
									20:
										FeatureShuttles[i].FB.RotaryMotion.Execute := FALSE;
										FeatureShuttles[i].FB.RotaryMotion;
										FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
										FeatureShuttles[i].FB.MoveInPlane;
										FeatureShuttles[i].ready := TRUE;
										
								END_CASE;
							
							40:
								CASE FeatureShuttles[i].subState OF
									0:
										FeatureShuttles[i].FB.StereoTypeAssign.Execute := TRUE;
										FeatureShuttles[i].FB.StereoTypeAssign.Name := 'custom';
										FeatureShuttles[i].FB.StereoTypeAssign.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.StereoTypeAssign;
									
										IF FeatureShuttles[i].FB.StereoTypeAssign.Done THEN
											FeatureShuttles[i].FB.StereoTypeAssign.Execute := FALSE;
											FeatureShuttles[i].FB.StereoTypeAssign;
											FeatureShuttles[i].subState := 1;
										ELSIF FeatureShuttles[i].FB.StereoTypeAssign.Error THEN
											FeatureShuttles[i].FB.StereoTypeAssign.Execute := FALSE;
											FeatureShuttles[i].FB.StereoTypeAssign;
										END_IF;
									
									
									1:
										FeatureShuttles[i].FB.TON_0.IN := TRUE;
										FeatureShuttles[i].FB.TON_0.PT := TIME#20s;
										FeatureShuttles[i].FB.TON_0;
									
										IF FeatureShuttles[i].FB.TON_0.Q THEN
											FeatureShuttles[i].FB.TON_0.IN := FALSE;
											FeatureShuttles[i].FB.TON_0;
											FeatureShuttles[i].subState := 2;
										END_IF;
									
									2:
										FeatureShuttles[i].FB.StereoTypeAssign.Execute := TRUE;
										FeatureShuttles[i].FB.StereoTypeAssign.Name := 'default';
										FeatureShuttles[i].FB.StereoTypeAssign.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.StereoTypeAssign;
									
										IF FeatureShuttles[i].FB.StereoTypeAssign.Done THEN
											FeatureShuttles[i].FB.StereoTypeAssign.Execute := FALSE;
											FeatureShuttles[i].FB.StereoTypeAssign;
											FeatureShuttles[i].subState := 10;
										END_IF;
								
									10:
									
										FeatureShuttles[i].ready := TRUE;
									
								END_CASE;
							
							50:
								IF gFeatureDemo.Cmd.StopDemo THEN
									FeatureShuttles[i].subState := 20;
								END_IF;
								CASE FeatureShuttles[i].subState OF
									
									0:
										brsmemset(ADR(gHMI.Data),0,SIZEOF(gHMI.Data));
										jsonTo6Ddata(ADR(gHMI.Teach.moveString),gHMI.Data);
										FeatureShuttles[i].counter := 0;
										IF gHMI.Data.count > 0 THEN
											FeatureShuttles[i].subState := 1;
										ELSE
											FeatureShuttles[i].subState := 20;
										END_IF;
										
									1:
										
										
										FeatureShuttles[i].FB.MoveInPlane.Execute := TRUE;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.X := gHMI.Data.Points[FeatureShuttles[i].counter].X/1000;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Position.Y :=  gHMI.Data.Points[FeatureShuttles[i].counter].Y/1000;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Acceleration := 20;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.Velocity := 1;
										FeatureShuttles[i].FB.MoveInPlane.Parameters.EndVelocity := 0;
										FeatureShuttles[i].FB.MoveInPlane.Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
										FeatureShuttles[i].FB.MoveInPlane;
										
										IF FeatureShuttles[i].FB.MoveInPlane.Done THEN
											FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
											FeatureShuttles[i].FB.MoveInPlane;
											FeatureShuttles[i].counter := FeatureShuttles[i].counter + 1;
											IF FeatureShuttles[i].counter >= gHMI.Data.count THEN
												FeatureShuttles[i].subState := 20;
												FeatureShuttles[i].counter := 0;
											ELSE
												FeatureShuttles[i].subState := 1;
											END_IF;
										END_IF;
									

									20:
										FeatureShuttles[i].FB.MoveArc.Execute := FALSE;
										FeatureShuttles[i].FB.MoveArc;
										FeatureShuttles[i].FB.MoveInPlane.Execute := FALSE;
										FeatureShuttles[i].FB.MoveInPlane;
										FeatureShuttles[i].ready := TRUE;
									
								END_CASE;
								
							
						END_CASE;	
						
						IF NOT FeatureShuttles[i].ready THEN
							gFeatureDemo.Int.ready := FALSE;
						END_IF;
					END_FOR;
					
					
					IF gFeatureDemo.Int.ready THEN
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
						IF gFeatureDemo.Cmd.StopDemo THEN
							gFeatureDemo.Cmd.StopDemo := FALSE;
							gFeatureDemo.featureDemoState := 3;
						ELSE
							gFeatureDemo.featureDemoState := 0;
						END_IF;
					END_IF;
					
				END_IF;
			
			3:
				gFeatureDemo.FB.StopAll.Assembly := ADR(gAssembly6D_1);
				gFeatureDemo.FB.StopAll.Execute := TRUE;
			
				gFeatureDemo.FB.StopAll;
			
				IF gFeatureDemo.FB.StopAll.Done THEN
					gFeatureDemo.FB.StopAll.Execute := FALSE;
					gFeatureDemo.FB.StopAll;
					gFeatureDemo.featureDemoState := 4;
					
					MoveToStartPosition;
					gFeatureDemo.FB.MoveInPlaneAsync.Assembly := ADR(gAssembly6D_1);
					gFeatureDemo.FB.MoveInPlaneAsync.Execute := TRUE;
					gFeatureDemo.FB.MoveInPlaneAsync.Parameters.Velocity := 1;
					gFeatureDemo.FB.MoveInPlaneAsync.Parameters.Acceleration := 10;
					
				END_IF;
			
			4:
				gFeatureDemo.FB.MoveInPlaneAsync;
				IF gFeatureDemo.FB.MoveInPlaneAsync.Done THEN
					gFeatureDemo.FB.MoveInPlaneAsync.Execute := FALSE;
					gFeatureDemo.FB.MoveInPlaneAsync;
					gFeatureDemo.featureDemoState := 0;
					gFeatureDemo.Active := FALSE; // end demo
					gFeatureDemo.Int.zoneReset := FALSE;
				ELSIF gFeatureDemo.FB.MoveInPlaneAsync.Error AND gFeatureDemo.FB.MoveInPlaneAsync.ErrorID = -1065803776 THEN
					gFeatureDemo.featureDemoState := 5;
					gFeatureDemo.FB.MoveInPlaneAsync.Execute := FALSE;
					gFeatureDemo.FB.MoveInPlaneAsync;
				END_IF;
				
			5:
				gFeatureDemo.FB.PowerOff.Assembly := ADR(gAssembly6D_1);
				gFeatureDemo.FB.PowerOff.Execute := TRUE;
				gFeatureDemo.FB.PowerOff;
			
				IF gFeatureDemo.FB.PowerOff.Done THEN
					gFeatureDemo.FB.PowerOff.Execute := FALSE;
					gFeatureDemo.FB.PowerOff;
					gFeatureDemo.featureDemoState := 6;
				END_IF;
			
			6:
				gFeatureDemo.FB.PowerOn.Assembly := ADR(gAssembly6D_1);
				gFeatureDemo.FB.PowerOn.Execute := TRUE;
				gFeatureDemo.FB.PowerOn;
			
				IF gFeatureDemo.FB.PowerOn.Done THEN
					gFeatureDemo.FB.PowerOn.Execute := FALSE;
					gFeatureDemo.FB.PowerOn;
					gFeatureDemo.featureDemoState := 4;
					gFeatureDemo.FB.MoveInPlaneAsync.Execute := TRUE;
				END_IF;
			
		END_CASE;	
		
	END_IF;
END_ACTION
	
ACTION MoveToStartPosition: 

	FOR i := 0 TO 7 DO
		original[i] := i;
		count := 0;
	END_FOR;
	
	Shuffle;
	
	FOR i := 0 TO 7 DO
		gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(gShuttleList[shuffled[i]].Ref);
	END_FOR;

	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].X		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].Y		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].X		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].Y		:= 0.540;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].X		:= 0.420;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].Y		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].X		:= 0.420;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].Y		:= 0.540;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].X		:= 0.540;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].Y		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].X		:= 0.540;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].Y		:= 0.540;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].X		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].Y		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].X		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].Y		:= 0.540;
		
END_ACTION


ACTION MoveToFeaturePosition: 

	FOR i := 0 TO 7 DO
		gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[FeatureShuttles[i].runningFeature].Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
		
		CASE FeatureShuttles[i].runningFeature OF
			
			0:
		
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].X		:= 0.12;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].Y		:= 0.12;
				
			1:
				
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].X		:= 0.360;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].Y		:= 0.120;
			
			2:
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].X		:= 0.600;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].Y		:= 0.120;
			
			3:
				
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].X		:= 0.720;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].Y		:= 0.120;
				
			4:
				
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].X		:= 0.840;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].Y		:= 0.120;
				
			5:
				
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].X		:= 0.600;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].Y		:= 0.600;
				
			6:
				
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].X		:= 0.840;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].Y		:= 0.840;
				
			7:
				
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].X		:= 0.600;
				gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].Y		:= 0.840;
				
		END_CASE;
		
		
		
		
	END_FOR;

	

		
	
	
END_ACTION


ACTION MoveToLoadPosition: 

	FOR i := 0 TO 7 DO
		gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(gShuttleList[i].Ref);
	END_FOR;

	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].X		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].Y		:= 0.540;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].X		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].Y		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].X		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].Y		:= 0.780;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].X		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].Y		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].X		:= 0.180;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].Y		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].X		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].Y		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].X		:= 0.420;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].Y		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].X		:= 0.540;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].Y		:= 0.900;
		
END_ACTION

ACTION MoveToExtremePosition: 

	FOR i := 0 TO 7 DO
		original[i] := i;
	END_FOR;
	
	Shuffle;
	
	FOR i := 0 TO 7 DO
		gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(gShuttleList[shuffled[i]].Ref);
	END_FOR;

	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].X		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].Y		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].X		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].Y		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].X		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].Y		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].X		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].Y		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].X		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].Y		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].X		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].Y		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].X		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].Y		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].X		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].Y		:= 0.660;
		
END_ACTION

ACTION MoveToExtremeInvPosition: 

	FOR i := 0 TO 7 DO
		original[i] := i;
	END_FOR;
	
	Shuffle;
	
	FOR i := 0 TO 7 DO
		gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[i].Shuttle := ADR(gShuttleList[shuffled[7-i]].Ref);
	END_FOR;

	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].X		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[0].Y		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].X		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[1].Y		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].X		:= 0.060;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[2].Y		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].X		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[3].Y		:= 0.900;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].X		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[4].Y		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].X		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[5].Y		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].X		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[6].Y		:= 0.300;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].X		:= 0.660;
	gFeatureDemo.FB.MoveInPlaneAsync.Parameters.AsyncPar[7].Y		:= 0.660;
		
END_ACTION


ACTION Shuffle:

	FOR i := 0 TO 7 DO
		// Generate random index from 0 to i-1 (not i)
		shuffled[i] := REAL_TO_INT(RandValueREAL(0.0, 10000));
	END_FOR;
	
	FOR i := 0 TO 7 DO
		minValue := shuffled[i];
		index := i;
		FOR j := 0 TO 7 DO
			IF shuffled[j] < minValue THEN
				minValue := shuffled[j];
				index := j;
			END_IF;
		END_FOR;
		shuffled1[i] := index;
		shuffled[index] := 20001;
	END_FOR;
	
	brsmemcpy(ADR(shuffled),ADR(shuffled1),SIZEOF(shuffled));
	
	
END_ACTION

ACTION getShuttleWeights:

	done := TRUE;
	FOR z := 0 TO 7 DO
		weightOffsets[z].Payload.Shuttle := ADR(gShuttleList[z].Ref);
		weightOffsets[z].Payload.Mode := mcACP6D_PAYLOAD_DURATION;
		weightOffsets[z].Payload.Duration := 0.02;
		weightOffsets[z].Payload.Execute := NOT FeatureShuttles[z].Status.Calibrated;
		weightOffsets[z].Payload;
				
		IF weightOffsets[z].Payload.Done THEN
			weightOffsets[z].ID := gShuttleList[z].ID;
			weightOffsets[z].Offset := 	weightOffsets[z].Payload.Payload;
			weightOffsets[z].Payload.Execute := FALSE;
			weightOffsets[z].Payload;
			FeatureShuttles[z].Status.Calibrated := TRUE;
		END_IF;
		
		IF NOT FeatureShuttles[z].Status.Calibrated THEN
			// not done
			done := FALSE;
		END_IF;
		
	END_FOR;

END_ACTION
