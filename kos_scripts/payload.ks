if payload = "Moho" {

	// intial throttle and steering
	set throttleLimit to 0.
	set steeringPitch to 90.	// start pointing up
	set steeringDir to 90.		// head east
	set steeringRoll to 270.	// start so the booster doesn't hit the launch tower, we'll roll later

	// Set these variables before the flight begins
	set initialAltitude to 3000.	// Altitude (m) at the start of the gravity turn
	set finalAltitude to 37500.		// Altitude in meters at the end of the gravity turn
	set targetApoapsis to  500000. 	// Target apoapsis in meters
	set targetPeriapsis to 75000. 	// Target periapsis in meters
	set errorAp to 0.999.			// allowable deviation from desired apoapsis
	set staging to 0.
	set targetInclination to 0.

	// the stage numbers are in order of activation, not based on KSP naming conventions
	set twrStage3 to 5.07.					// see if these twr variables can be pulled from API
	set twrStage2 to 4.27.
	set twrStage1 to 1.88.

	set program to 2.	// no launch window

	// set mission parameters
	set mission to 0.	// mission 0 is orbit the current body
}