FUNCTION_BLOCK brfiShuttleGroup

	fb.GroupAddShuttle.Execute := FALSE;
	fb.GroupCreate.Execute := FALSE;
	fb.GroupDelete.Execute := FALSE;
	fb.GroupGetInfo.Execute := FALSE;
	fb.GroupCoupleCtrl.Execute := FALSE;
	
	Active := FALSE;
	Error := FALSE;
	Inactive := FALSE;
	
	// Program code
	// ========================================================================================================
	CASE state OF			
		0:
			// Inactive
			// -------------------------------------------------------------------
			Inactive := TRUE;
			ErrorID := 0;
			NumberOfShuttles := 0;
			
			IF Enable THEN
				state := 10;	
			END_IF;
		
		10:
			// Create group
			// -------------------------------------------------------------------	
			fb.GroupCreate.Execute := TRUE;
			
			IF fb.GroupCreate.Done THEN
				shuttleGroupRef := fb.GroupCreate.ShuttleGroup;
				state := 20;
			ELSIF fb.GroupCreate.Error THEN
				ErrorID := fb.GroupCreate.ErrorID;
	  			state := 100;
			END_IF;
			
		20:
			// Add shuttles to the group
			// -------------------------------------------------------------------
			brsmemset(ADR(fb.GroupAddShuttle.Parameters), 0, SIZEOF(fb.GroupAddShuttle.Parameters));
			
			FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
				IF Shuttles[i].controlif > 0 THEN
	  				fb.GroupAddShuttle.Parameters.ShuttleList[i].Shuttle := ADR(Shuttles[i]);
				END_IF;
			END_FOR;
			
			fb.GroupAddShuttle.Execute := TRUE;
			
			IF fb.GroupCreate.Done THEN
				state := 30;
			ELSIF fb.GroupCreate.Error THEN
				ErrorID := fb.GroupCreate.ErrorID;
				state := 100;
			END_IF;
			
		30:
			// Read group info
			// -------------------------------------------------------------------	
			fb.GroupGetInfo.Execute := TRUE;
			
			IF fb.GroupGetInfo.Done THEN
				NumberOfShuttles := fb.GroupGetInfo.Info.NumberOfShuttles;
				state := 40;
			ELSIF fb.GroupGetInfo.Error THEN
				ErrorID := fb.GroupGetInfo.ErrorID;
				state := 100;
			END_IF;
			
		40:
			// Couple shuttles together
			// -------------------------------------------------------------------	
			fb.GroupCoupleCtrl.Parameters.Mode :=  mcACP6D_SH_GROUP_INDV_ROT_REF;
			fb.GroupCoupleCtrl.Parameters.Option := mcACP6D_SH_GROUP_COUPLE;
			
			fb.GroupCoupleCtrl.Execute := TRUE;
			
			IF fb.GroupCoupleCtrl.Done THEN
				state := 50;
			ELSIF fb.GroupCoupleCtrl.Error THEN
				ErrorID := fb.GroupGetInfo.ErrorID;
				state := 100;
			END_IF;
			
		50:
			// Group active
			// -------------------------------------------------------------------	
			Active := TRUE;
			
			IF NOT Enable THEN
				state := 60;
			END_IF;     
			
		60:
			// Delete group
			// -------------------------------------------------------------------	
			fb.GroupDelete.Execute := TRUE;
			
			IF fb.GroupDelete.Done THEN
				state := 0;
			ELSIF fb.GroupDelete.Error THEN
				ErrorID := fb.GroupCreate.ErrorID;
				state := 100;
			END_IF;
		
		100:
			// -------------------------------------------------------------------	
			Error := TRUE;
			
			IF NOT Enable THEN
	  			state := 0;
			END_IF;     
	END_CASE;	


	// Function calls
	// ========================================================================================================
	fb.GroupCreate.Assembly := ADR(Assembly);
	fb.GroupCreate();
	
	fb.GroupAddShuttle.ShuttleGroup := ADR(shuttleGroupRef);
	fb.GroupAddShuttle();
	
	fb.GroupDelete.ShuttleGroup :=  ADR(shuttleGroupRef);
	fb.GroupDelete();
	
	fb.GroupGetInfo.ShuttleGroup :=  ADR(shuttleGroupRef);
	fb.GroupGetInfo();
	
	fb.GroupCoupleCtrl.ShuttleGroup :=  ADR(shuttleGroupRef);
	fb.GroupCoupleCtrl();
	
	Busy := fb.GroupCreate.Busy OR fb.GroupAddShuttle.Busy OR fb.GroupDelete.Busy OR fb.GroupGetInfo.Busy;
	
END_FUNCTION_BLOCK

