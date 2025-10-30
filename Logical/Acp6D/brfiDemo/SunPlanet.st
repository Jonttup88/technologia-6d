FUNCTION_BLOCK brfiSunPlanet
			  
	ShPlanet.Execute := FALSE;
	
	Active := FALSE;
	Error := FALSE;
	
	// Program code
	// ========================================================================================================
	CASE state OF			
		0:
			// Inactive
			// -------------------------------------------------------------------
			ErrorID := 0;
			
			IF Enable THEN
				state := 10;	
			END_IF;
		
		10:
			// Create sun planet system
			// -------------------------------------------------------------------	
			ShPlanet.Execute := TRUE;
			ShPlanet.Parameters.Option := mcACP6D_PLANET_ADD_SH;
			
			ShPlanet.Shuttle := ADR(SunShuttle);
			
			brsmemset(ADR(ShPlanet.Parameters.ShuttleList), 0, SIZEOF(ShPlanet.Parameters.ShuttleList));
			
			FOR i := 0 TO gMAX_INDEX_SHUTTLE DO
				IF PlanetShuttles[i].controlif > 0 THEN
					ShPlanet.Parameters.ShuttleList[i].Shuttle := ADR(PlanetShuttles[i]);
				END_IF;
			END_FOR;
			
			IF ShPlanet.Done THEN
				state := 20;
			ELSIF ShPlanet.Error THEN
				ErrorID := ShPlanet.ErrorID;
	  			state := 100;
			END_IF;
			
		20:
			// Sun planet system active and coupled
			// -------------------------------------------------------------------
			Active := TRUE;
			
			IF NOT Enable THEN
	  			state := 30;
			END_IF;
		
			
		30:
			// Decouple sun planet system
			// -------------------------------------------------------------------	
			ShPlanet.Execute := TRUE;
			ShPlanet.Parameters.Option := mcACP6D_PLANET_REMOVE_SH;
			
			IF ShPlanet.Done THEN
				state := 0;
			ELSIF ShPlanet.Error THEN
				ErrorID := ShPlanet.ErrorID;
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
	ShPlanet();

	Busy := ShPlanet.Busy;
	
END_FUNCTION_BLOCK

