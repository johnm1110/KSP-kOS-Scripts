// Set some variables
set currentStage to 0.

// set up steering and throttle
lock throttle to throttleLimit.
lock steering to heading(steeringDir,steeringPitch,steeringRoll).

// if we are launching to intercept, set a target
//set targetObject to VESSEL("Agena").
//set targetObject to BODY("Mun").

// Variables for selected craft (move to functions)
lock Fg to ship:mass * body:mu /((ship:altitude + body:radius)^2).
lock currentTWR to SHIP:AVAILABLETHRUST / Fg.
// Set some variables

clearscreen.

// activate antenna and solar panels when free of atmosphere 
when ship:altitude > 75000 then { // fairings
	AG1 on.
}
when ship:altitude > 80000 then { // antenna and solar panels
	AG2 on.
}

// Launch program
until program = 0 {
	if program = 1 { 
		set launch to launchWindow(targetObject).
		if launch = 0 {	
			print "Target is moving at the same velocity as the ship, rendezvous calculation is not possible".
			print "Launching in one minute".
			wait 60.
			clearscreen.
			set program to 2.
		}
		if launch = 1 { 
			clearscreen.
			set program to 2.
		}
	}
	
	if program = 2 {
		lock steering to heading(steeringDir,steeringPitch,steeringRoll).
		set countdown to 10.
		print "Counting down:".
		until countdown = 4 {
			print "..." + countdown.
			set countdown to countdown - 1.
			wait 1.
		}.
		print "...4".
		wait 1.
		// the following sequence is t-3 seconds
		print "Engine sequence start.".
		print "Uncoupling umbilicals".
		AG10 on.
		print "Main throttle up. Two seconds to stabilize it.".
		stage.  // ignite engine 
		set throttleLimit to 0.20.
		if ship:maxthrust > 0.001 { // check if engines ignited and proceed
		    wait 1.
		    print "...2".
		    wait 1.
		    print "...1".
		    wait 1.
		    print "Liftoff at " + time:clock + " UT!".
		    set launchTime to time.
		    stage.					// release docking clamps 
		    set currentStage to 1.
		    set throttleLimit to twrLowerAtmo / currentTWR.
		    until ship:VERTICALSPEED > pitchOverVelocity {}
		    print "Begining pitch and roll program.".
		    set program to 3.
		} else set program to 0. // engines failed, exit before releasing socking clamps
	}	

	if program = 3 {
		if currentStage = 1 {
			until SHIP:MAXTHRUST < 0.001 {
				wait 0.1.
				if(steeringPitch>5){ set steeringPitch to steeringPitch - dPitchStage1 * 0.1. }
				//if(steeringRoll<360){ set steeringRoll to steeringRoll + 0.5. } // roll to 0 degrees at 5 degrees per second
			}
			print "Stage " + currentStage + " seperation at: " + time:clock + " UT!".
			set throttleLimit to 0.
			wait 1.0.
			stage.
			//kuniverse:pause.	// this allows me to record the data just at staging
			wait 0.5.
			set throttleLimit to twrMidAtmo / currentTWR.
			set steeringRoll to 0.
			set currentStage to 2. // TODO: launcher files need to tell how many stages
		}
		if currentStage = 2 {
			set ve to stage2Isp * 9.81. // convert specific impulse to exhaust velocity
			until ship:apoapsis > (-1 * apoapsisPlanned * errorAp + apoapsisPlanned) {
				wait 0.1.
				if(steeringPitch>2){ set steeringPitch to steeringPitch - dPitchStage2 * 0.1. }
				if SHIP:MAXTHRUST < 0.001 {
					print "Stage " + currentStage + " seperation at: " + time:clock + " UT!".
					lock throttle to 0.
					wait 0.2.
					stage.
					//kuniverse:pause.	// this allows me to record the data just at staging
					wait 0.5.
					lock throttle to 1.0.
					set currentStage to 3.			// TODO: launcher files need to tell how many stages
				}
			}
		}
		if currentStage = 3 {
			set ve to stage3Isp * 9.81. // convert specific impulse to exhaust velocity
			until ship:apoapsis > (apoapsisPlanned * errorAp) {
				wait 0.1.
				if(steeringPitch > 2){ set steeringPitch to steeringPitch - dPitchStage3 * 0.1. }
			}
		}
		set throttleLimit to 0.
		wait 0.1.
		kuniverse:pause.	// this allows me to record the data just at staging
		set program to 4.
	}

	if program = 4 { // circularization burn
		clearscreen.
		rcs on.
		lock STEERING to SHIP:PROGRADE.
		// calculate the time of the circulization burn; burning too far past apoapsis will raise it
		local rAp is SHIP:APOAPSIS + BODY:RADIUS.
		local rPe is periapsisPlanned + BODY:RADIUS.
		
		local Vf is sqrt(GM / rPe).											// final velocity at cutoff for circularized orbit
		local Vtx is SQRT(GM * (2 / rAp - 1 / ship:orbit:semimajoraxis)).		// velocity at apoapsis for current orbit
		local dVCirc is Vf - Vtx.
			
		local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVCirc / Ve))) / SHIP:AVAILABLETHRUST.  

		lock timeUntilBurn to ETA:APOAPSIS - burnTime / 2.
		
		until timeUntilBurn < 0.01 {
			lock STEERING to SHIP:PROGRADE.
			print "Waiting for orbital insertion burn (program 4)" 					 at (0,0).
			print "Burn delta v (m/s)     : " + round(dVCirc,2) 	  + "          " at (0,1).
			print "Total time of burn (s) : " + round(burnTime,2) 	  + "          " at (0,2).
			print "Burn ETA (s)           : " + round(timeUntilBurn,2) + "	       " at (0,3).
			wait 0.01.
		}
		set t0 to TIME:SECONDS.
		
		//orbital insertion burn
		until (TIME:SECONDS - t0) > burnTime { set throttleLimit to 1. }
		set throttleLimit to 0.
		wait 0.1.
		kuniverse:pause.	// this allows me to record the data just at staging
		if mission=0 set program to 0.
		if mission>0 set program to 0.	// TODO: improve this
	}
wait 0.001.
}

print "Orbit!" at (0,6).
lock throttle to 0.
set ship:control:pilotmainthrottle to 0.

// end program