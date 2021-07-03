// Set the ship to a known configuration
sas off.
rcs off.
lights off.
lock throttle to 0. 						// Throttle is a decimal from 0.0 to 1.0
gear off.
set ship:control:pilotmainthrottle to 0.	// set throttle to zero when exiting program

// load launcher (uncomment the launcher used TODO: find a better way)
run launcher.
Atlas1().

// the stage numbers are in order of activation, not based on KSP naming conventions
set twrStage3 to 2.04.
set twrStage2 to 4.35.
set twrStage1 to 1.69.

// load payload
run payloads.
muna().

set SHIP:SHIPNAME to "Muna 6".

// load functions
//run launch_window. 
run functions.

// intial throttle and steering
set throttleLimit to 0.
set steeringPitch to 90.	// start pointing up
set steeringDir to 90.		// head east
set steeringRoll to 0.	    // start at 0 degrees so the booster doesn't hit the launch tower, we'll roll later

// Set these variables before the flight begins
set apoapsisPlanned to  100000. 	// Target apoapsis in meters
set periapsisPlanned to 100000. 	// Target periapsis in meters
set errorAp to 0.995.			// allowable deviation from desired apoapsis
set staging to 0.
set inclinationFinal to 0.
set GM to KERBIN:MU.				// Kerbin's gravitational parameter


// Target variables 
set targetObject to BODY("Mun").
set inclinationTarget to 0.0.
set apoapsisTarget to  250000. 	// Target apoapsis in meters
set periapsisTarget to 55000. 	// Target periapsis in meters
//set orbitAltitudePlanned to 11950000.  // document this
set orbitAltitudePlanned to targetObject:altitude.  // Mun's orbit altitude over Kerbin
set orbitAltitudeOffset to 0.		// over or under shoot Mun's orbit by this amount

// landing zone
set impactSite to waypoint("Site T3-P").

// launch program start point
set program to 2.	// no launch window

// set mission parameters
// mission 0 : orbit current body
// mission 1 : hohmann transfer
// 2 : local flyby
// 3 : Mun/Minmus impactor
// 4 : orbit Mun or Minmus
// 5 : interplanetary trasnfer
// 6 : interplanetary flyby

set mission to 3.	// mission 0 is orbit the current body

if program < 10 { run launch. }
if program < 20 and mission > 1 { run tmi. }