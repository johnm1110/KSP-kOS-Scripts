function moho {

	// intial throttle and steering
	set throttleLimit to 0.
	set steeringPitch to 90.	// start pointing up
	set steeringDir to 90.		// head east
	set steeringRoll to 270.	// start so the booster doesn't hit the launch tower, we'll roll later

	// Set these variables before the flight begins
	set initialAltitude to 3000.	// Altitude (m) at the start of the gravity turn
	set finalAltitude to 37500.		// Altitude in meters at the end of the gravity turn
	set targetApoapsis to  100000. 	// Target apoapsis in meters
	set targetPeriapsis to 100000. 	// Target periapsis in meters
	set errorAp to 0.98.			// allowable deviation from desired apoapsis
	set staging to 0.
	set targetInclination to 0.

	set program to 2.	// no launch window

	// set mission parameters
	set mission to 0.	// mission 0 is orbit the current body
}

function muna {
	// intial throttle and steering
	set throttleLimit to 0.
	set steeringPitch to 90.	// start pointing up
	set steeringDir to 90.		// head east
	set steeringRoll to 0.	// start so the booster doesn't hit the launch tower, we'll roll later

	// Set these variables before the flight begins
	set targetApoapsis to  100000. 	// Target apoapsis in meters
	set targetPeriapsis to 100000. 	// Target periapsis in meters
	set errorAp to 0.980.			// allowable deviation from desired apoapsis
	set staging to 0.
	set inclinationFinal to 0.

	// Target variables
	set targetObject to BODY("Mun").
	set inclinationTarget to 0.0.
	set apoapsisTarget to  250000. 	// Target apoapsis in meters
	set periapsisTarget to 55000. 	// Target periapsis in meters
	set radiusTMI to 11500000.  // document this
}

function explorer {
	
	// intial throttle and steering
	set throttleLimit to 0.
	set steeringPitch to 90.	// start pointing up
	set steeringDir to 90.		// head east
	set steeringRoll to 0.	// start so the booster doesn't hit the launch tower, we'll roll later

	// Set these variables before the flight begins
	set targetApoapsis to  500000. 	// Target apoapsis in meters
	set targetPeriapsis to 100000. 	// Target periapsis in meters
	set errorAp to 0.99.			// allowable deviation from desired apoapsis
	set staging to 0.
	set targetInclination to 0.

	set program to 2.	// no launch window

	// set mission parameters
	set mission to 0.	// mission 0 is orbit the current body
}

function maxwell {
	set launchSite to WAYPOINT("Woomerang Launch Site").

	// intial throttle and steering
	set throttleLimit to 0.
	set steeringPitch to 90.		// start pointing up
	set steeringDir to 90.		// head east
	set steeringRoll to 0.		// 0 means the ship is rotated prior to launch

	// Set these variables before the flight begins
	set targetApoapsis to  100000. 	// Target apoapsis in meters
	set targetPeriapsis to 100000. 	// Target periapsis in meters
	set errorAp to 0.97.			// allowable deviation from desired apoapsis
	set staging to 0.
	set inclinationDesired to 87.

	// desired orbital parameters
	set GM to KERBIN:MU.
	set radiusOrbit to 496000.
	set velocityOrbitDesired to SQRT( GM / ( KERBIN:RADIUS + radiusOrbit )).

	// launch azimuth calculations
	set launchAzimuthInertial to ARCSIN ( COS (inclinationDesired) / COS (launchSite:GEOPOSITION:LAT) ).
	set velocityRotation to (2 * CONSTANT:PI * KERBIN:RADIUS) / KERBIN:ROTATIONPERIOD.
	set velocityXRotation to velocityOrbitDesired * SIN (launchAzimuthInertial) - velocityRotation * COS (launchSite:GEOPOSITION:LAT).
	set velocityYRotation to velocityOrbitDesired * COS (launchAzimuthInertial).
	set launchAzimuthRotation to ARCTAN ( velocityXRotation/velocityYRotation ).
	set steeringDir to launchAzimuthRotation.

	set program to 2.	// no launch window

	// set mission parameters
	set mission to 0.	// mission 0 is orbit the current body
}

function commSat {
	//set launchSite to WAYPOINT("Woomerang Launch Site").
	set launchSite to WAYPOINT("KSC").

	// intial throttle and steering
	set throttleLimit to 0.
	set steeringPitch to 90.		// start pointing up
	set steeringDir to 90.		// head east
	set steeringRoll to 0.		// 0 means the ship is rotated prior to launch

	// Set these variables before the flight begins
	set targetApoapsis to  100000. 	// Target apoapsis in meters
	set targetPeriapsis to 100000. 	// Target periapsis in meters
	set errorAp to 0.99.			// allowable deviation from desired apoapsis
	set staging to 0.
	set inclinationDesired to 0.

	// desired orbital parameters
	set GM to KERBIN:MU.
	set orbitAltitudePlanned to 100000.

	// launch azimuth calculations
	if inclinationDesired > 0 {
		set velocityOrbitDesired to SQRT( GM / ( KERBIN:RADIUS + orbitAltitudePlanned )).
		set launchAzimuthInertial to ARCSIN ( COS (inclinationDesired) / COS (launchSite:GEOPOSITION:LAT) ).
		set velocityRotation to (2 * CONSTANT:PI * KERBIN:RADIUS) / KERBIN:ROTATIONPERIOD.
		set velocityXRotation to velocityOrbitDesired * SIN (launchAzimuthInertial) - velocityRotation * COS (launchSite:GEOPOSITION:LAT).
		set velocityYRotation to velocityOrbitDesired * COS (launchAzimuthInertial).
		set launchAzimuthRotation to ARCTAN ( velocityXRotation/velocityYRotation ).
		set steeringDir to launchAzimuthRotation.
	}
	set program to 2.	// no launch window

	// set mission parameters
	set mission to 0.	// mission 0 is orbit the current body
}