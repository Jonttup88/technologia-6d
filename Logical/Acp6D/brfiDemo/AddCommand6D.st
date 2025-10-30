// XY plane move
// ========================================================================================================
FUNCTION AddCommand6D_xy
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(axisSelect);
			Commands[i].inPlane.Position.X := x;
			Commands[i].inPlane.Position.Y := y;
			Commands[i].inPlane.Velocity := velocity;
			Commands[i].inPlane.EndVelocity := endVelocity;
			Commands[i].inPlane.Acceleration := acceleration;
			Commands[i].inPlane.Radius := radius;
			Commands[i].inPlane.Mode := mode;
			
			CASE path OF
				pathDIRECT:
					Commands[i].inPlane.Path := mcACP6D_PATH_DIRECT;
				pathX_Y:
					Commands[i].inPlane.Path := mcACP6D_PATH_X_THEN_Y;		
				pathY_X:
		  			Commands[i].inPlane.Path := mcACP6D_PATH_Y_THEN_X;
			END_CASE;
			
			AddCommand6D_xy := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION

// 6D move
// ========================================================================================================
FUNCTION AddCommand6D_xyz
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(axisSelect);
			Commands[i].inSpace.InPlane.Position.X := x;
			Commands[i].inSpace.InPlane.Position.Y := y;
			Commands[i].inSpace.ShortAxis.Position.Z := z;
			Commands[i].inSpace.InPlane.Velocity := velocity;
			Commands[i].inSpace.InPlane.Acceleration := acceleration;
			Commands[i].inSpace.ShortAxis.Velocity.Z := velocity_short;
			Commands[i].moveMode6D := mode;
			AddCommand6D_xyz := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION

FUNCTION AddCommand6D_Rxyz
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(axisSelect);
			Commands[i].inSpace.ShortAxis.Position.Rx := Rx;
			Commands[i].inSpace.ShortAxis.Position.Ry := Ry;
			Commands[i].inSpace.ShortAxis.Position.Rz := Rz;
			Commands[i].inSpace.ShortAxis.Velocity.Z := velocity_short;
			Commands[i].inSpace.ShortAxis.Velocity.Rx := velocity_short;
			Commands[i].inSpace.ShortAxis.Velocity.Ry := velocity_short;
			Commands[i].inSpace.ShortAxis.Velocity.Rz := velocity_short;
			Commands[i].moveMode6D := mode;
			AddCommand6D_Rxyz := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION

// Wait
// ========================================================================================================
FUNCTION AddCommand6D_wait
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sWait);
			Commands[i].waitTime := time;
			AddCommand6D_wait := TRUE;
			RETURN;
		END_IF;
	END_FOR;	
END_FUNCTION

FUNCTION AddCommand6D_waitCmdLb
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sWaitCmdLb);
			Commands[i].waitCmdLb.monitoredShuttleID := monitoredShuttleID;
			Commands[i].waitCmdLb.triggerType := triggerType;
			Commands[i].waitCmdLb.commandLabel := commandLabel;
			Commands[i].waitCmdLb.labelType := labelType;
			AddCommand6D_waitCmdLb := TRUE;
			RETURN;
		END_IF;
	END_FOR;	
END_FUNCTION


// Rotary
// ========================================================================================================
FUNCTION AddCommand6D_rotateAbs
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sRotary);
			Commands[i].rotary.Angle := angle;
			Commands[i].rotary.Velocity := velocity;
			Commands[i].rotary.Acceleration := acceleration;
			Commands[i].rotary.Mode := mcACP6D_ROTATE_ABSOLUTE_POS;
			AddCommand6D_rotateAbs := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION

FUNCTION AddCommand6D_rotateCW
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sRotary);
			Commands[i].rotary.Angle := angle;
			Commands[i].rotary.Velocity := velocity;
			Commands[i].rotary.Acceleration := acceleration;
			Commands[i].rotary.Mode := mcACP6D_ROTATE_CLOCKWISE;
			AddCommand6D_rotateCW := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION

FUNCTION AddCommand6D_rotateCCW
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sRotary);
			Commands[i].rotary.Angle := angle;
			Commands[i].rotary.Velocity := velocity;
			Commands[i].rotary.Acceleration := acceleration;
			Commands[i].rotary.Mode := mcACP6D_ROTATE_COUNTER_CLOCKWISE;
			AddCommand6D_rotateCCW := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION


// Arc
// ========================================================================================================
FUNCTION AddCommand6D_arcAngularCW
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sArc);
			Commands[i].arc.Velocity := velocity;
			Commands[i].arc.EndVelocity := endVelocity;
			Commands[i].arc.Acceleration := acceleration;
			Commands[i].arc.Angular.Angle := angle;
			Commands[i].arc.Angular.Center.X := x;
			Commands[i].arc.Angular.Center.Y := y;
			Commands[i].arc.Mode := mode;
			Commands[i].arc.Direction := mcACP6D_ARC_CLOCKWISE;
			Commands[i].arc.Option := mcACP6D_ARC_ANGULAR;
			AddCommand6D_arcAngularCW := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION

FUNCTION AddCommand6D_arcAngularCCW
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sArc);
			Commands[i].arc.Velocity := velocity;
			Commands[i].arc.EndVelocity := endVelocity;
			Commands[i].arc.Acceleration := acceleration;
			Commands[i].arc.Angular.Angle := angle;
			Commands[i].arc.Angular.Center.X := x;
			Commands[i].arc.Angular.Center.Y := y;
			Commands[i].arc.Mode := mode;
			Commands[i].arc.Direction := mcACP6D_ARC_COUNTER_CLOCKWISE;
			Commands[i].arc.Option := mcACP6D_ARC_ANGULAR;
			AddCommand6D_arcAngularCCW := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION

FUNCTION AddCommand6D_arcRadialCW
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sArc);
			Commands[i].arc.Velocity := velocity;
			Commands[i].arc.EndVelocity := endVelocity;
			Commands[i].arc.Acceleration := acceleration;
			Commands[i].arc.Radius.Position.X := x;
			Commands[i].arc.Radius.Position.Y := y;
			Commands[i].arc.Radius.Radius := radius;
			Commands[i].arc.Radius.ArcType := type;
			Commands[i].arc.Mode := mode;
			Commands[i].arc.Direction := mcACP6D_ARC_CLOCKWISE;
			Commands[i].arc.Option := mcACP6D_ARC_RADIUS;
			AddCommand6D_arcRadialCW := TRUE;
			RETURN;
		END_IF;
	END_FOR;	
END_FUNCTION

FUNCTION AddCommand6D_arcRadialCCW
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sArc);
			Commands[i].arc.Velocity := velocity;
			Commands[i].arc.EndVelocity := endVelocity;
			Commands[i].arc.Acceleration := acceleration;
			Commands[i].arc.Radius.Position.X := x;
			Commands[i].arc.Radius.Position.Y := y;
			Commands[i].arc.Radius.Radius := radius;
			Commands[i].arc.Radius.ArcType := type;
			Commands[i].arc.Mode := mode;
			Commands[i].arc.Direction := mcACP6D_ARC_COUNTER_CLOCKWISE;
			Commands[i].arc.Option := mcACP6D_ARC_RADIUS;
			AddCommand6D_arcRadialCCW := TRUE;
			RETURN;
		END_IF;
	END_FOR;	
END_FUNCTION


// Spin
// ========================================================================================================
FUNCTION AddCommand6D_spin
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sSpin);
			Commands[i].spin.Duration := duration;
			Commands[i].spin.Angle := angle;
			Commands[i].spin.Velocity := velocity;
			Commands[i].spin.Acceleration := acceleration;
			AddCommand6D_spin := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION

// Levitation
// ========================================================================================================
FUNCTION AddCommand6D_levitate
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sLevitate);
			Commands[i].levitation.Level := mcACP6D_LEVEL_LEVITATE;
			Commands[i].levitation.Speed := speed;
			Commands[i].levitation.ZForce := Fz;
			AddCommand6D_levitate := TRUE;
			RETURN;
		END_IF;
	END_FOR;
END_FUNCTION

FUNCTION AddCommand6D_land
	FOR i := 0 TO gMAX_INDEX_TARGETS DO
		IF Commands[i].mask = 0 THEN 
			Commands[i].mask := DINT_TO_UINT(sLevitate);
			Commands[i].levitation.Level := mcACP6D_LEVEL_LAND;
			Commands[i].levitation.Speed := speed;
			Commands[i].levitation.ZForce := Fz;
			AddCommand6D_land := TRUE;
			RETURN;
		END_IF;
	END_FOR;	
END_FUNCTION


