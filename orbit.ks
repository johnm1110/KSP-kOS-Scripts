// Set the ship to a known configuration
sas off.
rcs off.
lights off.
lock throttle to 0. 						// Throttle is a decimal from 0.0 to 1.0
gear off.
list engines in elist.						// engine list for staging
set ship:control:pilotmainthrottle to 0.	// set throttle to zero when exiting program


// Set some variables
set currentStage to 0.
set targetPitch to 0.
set targetRoll to 180.

set throttleLimit to 0.
lock throttle to throttleLimit.

set prog to 2. 				// Safety in case we start mid-flight

// Set these variables before the flight begins
set initialAltitude to 3000.	// Altitude (m) at the start of the gravity turn
set finalAltitude to 37500.		// Altitude in meters at the end of the gravity turn
set finalPitch to 88.			// Absolute pitch angle in degrees at the end of the gravity turn
set targetApoapsis to  100000. 	// Target apoapsis in meters
set targetPeriapsis to 100000. 	// Target periapsis in meters
set finalRoll to 90.0.			// Roll angle in degrees at the end of the gravity turn

// Variables for slected craft (move to functions)
set mohoFuelStage1 to 360.0.
set mohoFuelStage2 to   0.0.
set mohoFuelStage3 to   0.0.

set beta3FuelStage1 to 360.0.
set beta3FuelStage2 to   0.0.
set beta3FuelStage3 to   0.0.

// Standard local variables
set fuelStage1 to beta3FuelStage1.
set fuelStage2 to beta3FuelStage2.
set fuelStage3 to beta3FuelStage3.

set twrStage3 to 3.64.					// see if these twr variables can be pulled from API
set twrStage2 to 2.22.
set twrStage1 to 2.60.
set twrAtmo to 1.4.
set twrUpperAtmo to 1.4.

// PI loop variables
set Kp to .05.
set Ki to 0.006.
set I to 0.0.
lock currentPitch to -1.0 * vang(ship:up:vector,ship:facing:vector).
lock P to targetPitch - currentPitch.
lock dPitch to Kp * P.


clearscreen.
 
// This is a cheat to activate the antenna until custom groups are avaialbe.
when ship:altitude > 70000 then 
	{
	lights on.
	preserve.
	}


// Same for solar panel deployment
when ship:altitude > 70000 then
	{
	abort on.
	preserve.
	}
	
// Launch program
set countdown to 10.
print "Counting down:".
until countdown = 5 {
	print "..." + countdown.
	set countdown to countdown - 1.
	wait 1.
}.
print "Main throttle up. Two seconds to stabilize it.".
set throttleLimit to twrAtmo / twrStage1.	// set throttle to a max of a TWR of 1.2
// lock throttle to 1.					// hack for another bug
lock STEERING to UP + R(0,0,targetRoll) + R(0,targetPitch,0).
// lock steering to up + heading(90,targetPitch).
wait 1.
print "...4".
wait 1.
print "...3".
print "Igniting main engine.".	// uncomment if docking clamps are used
stage.  // ignite engine if docking clamps present
wait 1.
print "...1".
wait 1.
print "Liftoff at " + time:clock + " UT!".
set launchTime to time.
stage.					// release docking clamps or ignite main engine
set currentStage to 1.

// Hack for another bug
// wait until ship:altitude > 100.
// lock throttle to 1.2 / twrStage1.

// Pitch over to 5 degrees
wait until ship:altitude > 500.
	set missionTime to time - launchTime.
	print "Pitching over 5 degrees at :" + missionTime + "." at (0,15).
	set targetPitch to -1.
	wait 1.
	set targetPitch to -2.
	wait 1.
	set targetPitch to -3.
	wait 1.
	set targetPitch to -4.
	wait 1.
	set targetPitch to -5.
	set prog to 3.
	
// Begin gradual turn in lower atmo (from 85 to 65)
wait until ship:altitude > initialAltitude.
print "Beginning turn.".
set pitchRange to -1 * ( finalPitch - 5 ).	// convert pitch to negative and allow for initial pitchover
set rollRange to finalRoll.
set t0 to time:seconds.
until ship:altitude > finalAltitude {
	set pitchRatio to ( ship:altitude - initialAltitude ) / ( finalAltitude - initialAltitude ).
	set targetRoll to 180 + ( pitchRatio * rollRange).
	set targetPitch to pitchRatio * pitchRange - 5.
	print "Pitch target at : " + targetPitch at (0,18).
	print "Pitch angle     : " + currentPitch at (0,17).
	print "Stage " + currentStage + " fuel : " + stage:liquidfuel at (0,20).	// Added for apparent kOS bug
	set targetPitch to targetPitch + dpitch.
	wait 0.1.	// update P loop every 0.1 seconds
	print "Pitch setpoint at : " + targetPitch at (0,19).
	if stage:liquidfuel < (fuelStage1 + 0.1) and currentStage = 1 {
		// print "Stage 1 fuel         : " + stage:liquidfuel at (0,20).	// Added for apparent kOS bug
		print "Stage " + currentStage + " seperation at: " + ship:altitude +"m" at (0,21).
		print "Stage 1 seperation at: " + time:clock + " UT!".
		set throttleLimit to 0.
		wait 0.2.
		stage.
		wait 0.5.
		set throttleLimit to twrUpperAtmo / twrStage2.
		set currentStage to 2.
		// wait 1.0.
		// set currentStage to 2.
		// wait 1.
	}
	if stage:liquidfuel < (fuelStage2 + 0.1) and currentStage = 2 {
		print "Stage 2 fuel         : " + stage:liquidfuel at (0,20).	// Added for apparent kOS bug
		print "Stage 2 seperation at: " + ship:altitude +"m" at (0,21).
		print "Stage 2 seperation at: " + time:clock + " UT!".
		set throttleLimit to 0.
		wait 0.2.
		stage.
		wait 0.5.
		set throttleLimit to 1.0 / twrStage3.
		set currentStage to 3.
	}
}

// Coast to apoapsis
until ship:apoapsis > (targetApoapsis * 1.005) {
	print "Stage " + currentStage + " fuel : " + stage:liquidfuel at (0,20).	// Added for apparent kOS bug
	if stage:liquidfuel < (fuelStage2 + 0.1) and currentStage = 2 {
		print "Stage 2 fuel         : " + stage:liquidfuel at (0,20).	// Added for apparent kOS bug
		print "Stage 2 seperation at: " + ship:altitude +"m" at (0,21).
		print "Stage 2 seperation at: " + time:clock + " UT!".
		set throttleLimit to 0.
		wait 0.2.
		stage.
		wait 0.5.
		set throttleLimit to 1.2 / twrStage3.
		set currentStage to 3.
	}
}

lock throttle to 0.0.
wait 1.
print "Shutdown complete, coasting to apoapsis.".
lock STEERING to ship:prograde.
// if stage:liquidfuel < 1 and currentStage = 2 then {
if currentStage = 2 {
	print "Stage 2 seperation at: " + ship:altitude +"m" at (0,22).
	stage.
	set currentStage to 3.
}

wait until ETA:APOAPSIS < 5.
Print "Circulization burn.".
lock throttle to 1.0.

wait until ship:periapsis > (targetPeriapsis * 0.995).
print "Orbit!".
lock throttle to 0.
set ship:control:pilotmainthrottle to 0.

// end program