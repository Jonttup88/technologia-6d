
ACTION MoveToStartPosition: 

	FOR i := 0 TO 7 DO
		original[i] := i;
		count := 0;
	END_FOR;
	
	Shuffle;
	
	FOR i := 0 TO 7 DO
		MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Shuttle := ADR(gShuttleList[shuffled[i]].Ref);
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
		
END_ACTION


ACTION MoveToFeaturePosition: 

	FOR i := 0 TO 7 DO
		MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[FeatureShuttles[i].runningFeature].Shuttle := ADR(FeatureShuttles[i].Shuttle.Ref);
		
		CASE FeatureShuttles[i].runningFeature OF
			
			0:
		
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].X		:= 0.12;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].Y		:= 0.060;
				
			1:
				
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].X		:= 0.360;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].Y		:= 0.120;
			
			2:
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].X		:= 0.600;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].Y		:= 0.120;
			
			3:
				
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].X		:= 0.720;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].Y		:= 0.120;
				
			4:
				
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].X		:= 0.840;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].Y		:= 0.120;
				
			5:
				
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].X		:= 0.660;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].Y		:= 0.660;
				
			6:
				
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].X		:= 0.720;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].Y		:= 0.780;
				
			7:
				
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].X		:= 0.780;
				MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].Y		:= 0.900;
				
		END_CASE;
		
		
		
		
	END_FOR;

	

		
	
	
END_ACTION


ACTION MoveToLoadPosition: 

	FOR i := 0 TO 7 DO
		MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Shuttle := ADR(gShuttleList[i].Ref);
	END_FOR;

	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].X		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].Y		:= 0.540;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].X		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].Y		:= 0.660;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].X		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].Y		:= 0.780;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].X		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].Y		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].X		:= 0.180;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].Y		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].X		:= 0.300;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].Y		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].X		:= 0.420;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].Y		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].X		:= 0.540;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].Y		:= 0.900;
		
END_ACTION

ACTION MoveToExtremePosition: 

	FOR i := 0 TO 7 DO
		original[i] := i;
	END_FOR;
	
	Shuffle;
	
	FOR i := 0 TO 7 DO
		MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Shuttle := ADR(gShuttleList[shuffled[i]].Ref);
	END_FOR;

	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].X		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].Y		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].X		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].Y		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].X		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].Y		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].X		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].Y		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].X		:= 0.300;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].Y		:= 0.660;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].X		:= 0.300;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].Y		:= 0.300;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].X		:= 0.660;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].Y		:= 0.300;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].X		:= 0.660;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].Y		:= 0.660;
		
END_ACTION

ACTION MoveToExtremeInvPosition: 

	FOR i := 0 TO 7 DO
		original[i] := i;
	END_FOR;
	
	Shuffle;
	
	FOR i := 0 TO 7 DO
		MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[i].Shuttle := ADR(gShuttleList[shuffled[7-i]].Ref);
	END_FOR;

	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].X		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[0].Y		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].X		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[1].Y		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].X		:= 0.060;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[2].Y		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].X		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[3].Y		:= 0.900;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].X		:= 0.300;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[4].Y		:= 0.660;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].X		:= 0.300;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[5].Y		:= 0.300;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].X		:= 0.660;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[6].Y		:= 0.300;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].X		:= 0.660;
	MC_BR_MoveInPlaneAsync_Acp6D_0.Parameters.AsyncPar[7].Y		:= 0.660;
		
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
