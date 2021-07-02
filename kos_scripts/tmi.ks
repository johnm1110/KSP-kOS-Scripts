	if program = 11 { // wait for Trans Munar Injection (TMI) burn
		clearscreen.
		RCS off.
		
		set TARGET to targetObject.
		local aShip is SHIP:ORBIT:SEMIMAJORAXIS.
		local aTarget is TARGET:ORBIT:SEMIMAJORAXIS - apoapsisTarget + 50000.
		
		set phaseAngleData to phaseAngle(aShip,aTarget,targetObject).
		set phaseAngleAtDeparture to phaseAngleData[0].
		set timeOfFlight to phaseAngleData[1].
		lock STEERING to SHIP:PROGRADE.


		// determine positions to calculate the current phase angle
		// get the target position in relation to the ship then transform it to the SOI body
		lock targetPosition to TARGET:POSITION - SHIP:BODY:POSITION.
		// KERBIN:POSITION returns the position of Kerbin with respect to the ship, we want the ship's position
		// with respect to Kerbin so we negate the vector
		lock kerbinPosition to -1 * KERBIN:position.
		// calculate the angle between the two position vectors, this is our current phase angle to the target
		set currentPhaseAngle to vang(kerbinPosition,targetPosition).
		// since the angle returned is between 0 and 180 degrees it needs to be checked for -180 or 180 degrees
		// with negative angles indicating the spacecraft has moved past the phase angle at departure
		// check for the sign of the cross product of positions in left handed notation
        set deltaPhaseAngle to currentPhaseAngle - phaseAngleAtDeparture.
		set checkPhaseAngle to vcrs(kerbinPosition,targetPosition).
		if checkPhaseAngle:Y > 0 { set deltaPhaseAngle to deltaPhaseAngle + 180. }
		// calculate mean angular velocity, the angular velocity difference of the spacecraft and target
		set meanAngularMotionShip to 360 / SHIP:ORBIT:PERIOD. // angular velocity of spacecraft in deg/s
		set meanAngularMotionTarget to 360 / targetObject:ORBIT:PERIOD.  // angular velocity of target in deg/s
		set meanAngularMotionTotal to ABS(meanAngularMotionShip - meanAngularMotionTarget). // mean angular velocity
		// calculate the time to the phase angle at departure in seconds
		set timeUntilPhase to deltaPhaseAngle / meanAngularMotionTotal.
			
		// TODO: add Karbal Alarm Clock alarm for burn pause game? this sill need to be out of a loop
		// maybe put prints in a loop and use locks to force update
		until timeUntilPhase < 60 {
			set currentPhaseAngle to vang(kerbinPosition,targetPosition).
            set deltaPhaseAngle to currentPhaseAngle - phaseAngleAtDeparture.
		    set checkPhaseAngle to vcrs(kerbinPosition,targetPosition).
		    if checkPhaseAngle:Y > 0 { set deltaPhaseAngle to deltaPhaseAngle + 180. }
			set timeUntilPhase to deltaPhaseAngle / meanAngularMotionTotal.
			print "Waiting for injection window" at (0,0).
			print "Phase angle at departure (deg) : " + round(phaseAngleAtDeparture,2) + "   " at (0,1).
			print "Current phase angle (deg)      : " + round(currentPhaseAngle,2) + "   " at (0,2).
			print "Time to TMI (s)                : " + round(timeUntilPhase) + "      " at (0,3).
			//print "Mun position                   : " + targetPosition + "                 " at (0,4).
			print "Kerbin position                : " + checkPhaseAngle + "                 " at (0,5).
			//print "Cross product                  : " + setBit + "       " at (0,6).
			//print "Cross product magnitude        : " + check:MAG + "        " at (0,7).
		}
		set program to 12.
	}

	if program = 12 { // Trans Munar Injection (TMI) burn
		kuniverse:pause.	// pause before burn
		clearscreen.
		RCS off.
		lock STEERING to SHIP:PROGRADE.
		
		local radiusA is ship:orbit:semimajoraxis.
		local radiusB is orbitAltitudePlanned + body:radius.
		
		set rPe to SHIP:ALTITUDE + BODY:RADIUS.
		set aTarget to TARGET:ORBIT:SEMIMAJORAXIS.
			
		set phaseAngleData to phaseAngle(rPE,aTarget,targetObject).
		set phaseAngleAtDeparture to phaseAngleData[0].
		set timeOfFlight to phaseAngleData[1].

		lock targetPosition to TARGET:POSITION - SHIP:BODY:POSITION.
		// KERBIN:POSITION returns the position of Kerbin with respect to the ship, we want the ship's position
		// with respect to Kerbin so we negate the vector
		lock kerbinPosition to -KERBIN:position.
		// as the burn is close currentPhaseAngle will be less than 180, no need for a check
		set currentPhaseAngle to vang(kerbinPosition,targetPosition).

		// calulate delta v needed for injection burn 
		local a1 is SHIP:ORBIT:SEMIMAJORAXIS.
		
		local aTransferOrbit is (radiusA + radiusB) / 2.		// semi-major axis of transfer ellipse
		local ViA is sqrt(GM / radiusA).			// initial velocity at point A
		local VfB is sqrt(GM / radiusB).			// final velocity at point B
		
		local VtxA is SQRT(GM * (2 / radiusA - 1 / aTransferOrbit)).	// velocity on transfer orbit at initial orbit (point a)
		local VtxB is SQRT(GM * (2 / radiusB - 1 / aTransferOrbit)).	// velocity on transfer orbit at final orbit (point B)
		set dVA to VtxA - ViA.
		set dVB to VfB - VtxB.
		set dVT to dVA + dVB.

		//set dVHohmann to ABS(deltaV(rPe,rAp)).  // order matters, first radius is the burn position
		// change this away from ABS, sign determines prograde vs retrograde
		set Ve to stage3ISP * 9.81. // convert specific impulse to exhaust velocity
		
		local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVA / Ve))) / SHIP:AVAILABLETHRUST.  

		set deltaPhaseAngle to currentPhaseAngle - phaseAngleAtDeparture.

		set meanAngularMotionShip to 360 / SHIP:ORBIT:PERIOD.
		set meanAngularMotionTarget to 360 / targetObject:ORBIT:PERIOD.  // angular velocity in deg/s
		set meanAngularMotionTotal to ABS(meanAngularMotionShip - meanAngularMotionTarget).

		set timeUntilPhase to deltaPhaseAngle / meanAngularMotionTotal.

		set timeUntilBurn to timeUntilPhase - burnTime / 2.
		
		until timeUntilBurn < 0 {
			lock STEERING to SHIP:PROGRADE.
			set currentPhaseAngle to vang(kerbinPosition,targetPosition).
			set deltaPhaseAngle to currentPhaseAngle - phaseAngleAtDeparture.
			set timeUntilPhase to deltaPhaseAngle / meanAngularMotionTotal.
			set timeUntilBurn to timeUntilPhase - burnTime / 2.
			print "Waiting for TMI burn (P-7)" at (0,0).
			print "Phase angle at departure (degs)  : " + round(phaseAngleAtDeparture,2) + "   " at (0,1).
			print "Current phase angle (degs)       : " + round(currentPhaseAngle,2) + "    " at (0,2).
			print "Time to phase angle (s)          : " + round(timeUntilPhase,2) + "      " at (0,3).
			print "Burn ETA (s)                     : " + round(timeUntilBurn,2) + "     " at (0,4).
			print "Total delta V required (m/s)     : " + round(dVA,2) + "          " at (0,5).
			print "Total time of burn (s)           : " + round(burnTime,2) + "          " at (0,6).
			print "Apoapsis of transfer ellipse (m) : " + radiusB at (0,7).
			wait 0.001.
		}
		set t0 to TIME:SECONDS.
		until (TIME:SECONDS - t0) > burnTime {
			print "Burn (s)                         : " + ROUND((burnTime - TIME:SECONDS + t0),2) + "       " at (0,8).
			wait 0.001.
			set throttleLimit to 1.
		}
		set throttleLimit to 0.
		wait 1.
		set program to 13.
		clearscreen.
	}
	if program = 13 { // cruise to target, maybe mid course corrections?
		// TODO: add in course correction code. maybe as program 14
		until ORBIT:TRANSITION = "ESCAPE" {
		
		//lock STEERING TO LOOKDIRUP( SHIP:PROGRADE:VECTOR, SUN:POSITION ). // + R(0,0,-45).
		//lock steering to prograde + R(-90,0,0).
		lock steering to sun:position.
		
		set transitionETA to ORBIT:NEXTPATCHETA.
		set transitionETASeconds to FLOOR(mod(transitionETA,60)).
		set transitionETAMinutes to FLOOR(mod(transitionETA / 60,60)).
		set transitionETAHours   to FLOOR(mod(transitionETA / 3600,60)).
		
		set transitionPeriapsis to ORBIT:NEXTPATCH:NEXTPATCHETA.
		set transitionPeriapsisSeconds to FLOOR(mod(transitionPeriapsis,60)).
		set transitionPeriapsisMinutes to FLOOR(mod(transitionPeriapsis / 60,60)).
		set transitionPeriapsisHours   to FLOOR(mod(transitionPeriapsis / 3600,60)).
		
		set correctionETA to ORBIT:NEXTPATCHETA - 3600.				// TODO: the correction ETA needs to be determined from telemetry
		set correctionETASeconds to FLOOR(mod(correctionETA,60)).
		set correctionETAMinutes to FLOOR(mod(correctionETA / 60,60)).
		set correctionETAHours   to FLOOR(mod(correctionETA / 3600,60)).
		
		print "Waiting for transition to " + TARGET + " SOI (P-8)" at (0,0).
		print "Time to transition (hh:mm:ss) : " + transitionETAHours + ":" +  transitionETAMinutes + ":" + transitionETASeconds + "   " at (0,1).
		print "Periapsis (m)                 : " + round(ORBIT:NEXTPATCH:PERIAPSIS) + "     " at (0,2).
		print "Time to escape (hh:mm:ss)     : " + transitionPeriapsisHours + ":" +  transitionPeriapsisMinutes + ":" + transitionPeriapsisSeconds + "     " at (0,3).
		print "Inclination (deg)             : " + round(ORBIT:NEXTPATCH:INCLINATION,2) + "     " at (0,4).
		//print "Destination high space (km)   : " + targetHighSpace/1000 + "     " at (0,5).
		//print "Destination low space (km)    : " + targetLowSpace/1000 + "     " at (0,6).
		print "Correction burn in (hh:mm:ss) : " + correctionETAHours + ":" +  correctionETAMinutes + ":" + correctionETASeconds + "     " at (0,7).
		}
		local theta is inclinationFinalMun - SHIP:ORBIT:INCLINATION.

		// TODO: make this a standard deviation calculation
		if mission = 1 { set program to 0. }
		else if SHIP:ORBIT:INCLINATION <> inclinationFinal { set program to 22. } // skip 21 for now
			else { set program to 22. }
	}
	
	if program = 14 { // course correction manuver
		// TODO: add in course correction code. maybe as program 14
		lock steering to ship:prograde.
		
		wait 30. // let steering settle
		
		until ORBIT:NEXTPATCH:PERIAPSIS < periapsisTarget {
		
		//lock STEERING TO LOOKDIRUP( SHIP:PROGRADE:VECTOR, SUN:POSITION ). // + R(0,0,-45).
		//lock steering to prograde + R(-90,0,0).
		//lock steering to sun:position.
		rcs on.
		lock throttle to 0.05.
		
		set transitionETA to ORBIT:NEXTPATCHETA.
		set transitionETASeconds to FLOOR(mod(transitionETA,60)).
		set transitionETAMinutes to FLOOR(mod(transitionETA / 60,60)).
		set transitionETAHours   to FLOOR(mod(transitionETA / 3600,60)).
		
		set transitionPeriapsis to ORBIT:NEXTPATCH:NEXTPATCHETA.
		set transitionPeriapsisSeconds to FLOOR(mod(transitionPeriapsis,60)).
		set transitionPeriapsisMinutes to FLOOR(mod(transitionPeriapsis / 60,60)).
		set transitionPeriapsisHours   to FLOOR(mod(transitionPeriapsis / 3600,60)).
		
		set correctionETA to ORBIT:NEXTPATCHETA - 3600.				// TODO: the correction ETA needs to be determined from telemetry
		set correctionETASeconds to FLOOR(mod(correctionETA,60)).
		set correctionETAMinutes to FLOOR(mod(correctionETA / 60,60)).
		set correctionETAHours   to FLOOR(mod(correctionETA / 3600,60)).
		
		print "Waiting for transition to " + TARGET + " SOI (P-8)" at (0,0).
		print "Time to transition (hh:mm:ss) : " + transitionETAHours + ":" +  transitionETAMinutes + ":" + transitionETASeconds + "   " at (0,1).
		print "Periapsis (m)                 : " + round(ORBIT:NEXTPATCH:PERIAPSIS) + "     " at (0,2).
		print "Time to escape (hh:mm:ss)     : " + transitionPeriapsisHours + ":" +  transitionPeriapsisMinutes + ":" + transitionPeriapsisSeconds + "     " at (0,3).
		print "Inclination (deg)             : " + round(ORBIT:NEXTPATCH:INCLINATION,2) + "     " at (0,4).
		//print "Destination high space (km)   : " + targetHighSpace/1000 + "     " at (0,5).
		//print "Destination low space (km)    : " + targetLowSpace/1000 + "     " at (0,6).
		print "Correction burn in (hh:mm:ss) : " + correctionETAHours + ":" +  correctionETAMinutes + ":" + correctionETASeconds + "     " at (0,7).
		}
		lock throttle to 0.0.
		rcs off.
		local theta is inclinationFinalMun - SHIP:ORBIT:INCLINATION.

		// TODO: make this a standard deviation calculation
		if mission = 1 { set program to 13. }
		else if SHIP:ORBIT:INCLINATION <> inclinationFinal { set program to 13. } // skip 21 for now
			else { set program to 13. }
	}
	
	if program = 21 { // inclination change
		clearscreen.
		RCS off.
		
		local theta is inclinationFinalMun - SHIP:ORBIT:INCLINATION.
		if theta > 0 { 	set STEERING to normalVector(). }
			else { 	set STEERING to -normalVector(). }
			
		set dV to simplePlaneChange(SHIP:ALTITUDE,theta).
		
		// change this away from ABS, sign determines prograde vs retrograde
		set Ve to stage3ISP * 9.81. // convert specific impulse to exhaust velocity
		
		local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dV / Ve))) / (SHIP:AVAILABLETHRUST / 1).  

		set t0 to TIME:SECONDS. // 60 seconds to stabilize steering
		
		until (TIME:SECONDS - t0) > 20 {
			set timeUntilBurn to 20 - TIME:SECONDS + t0.
			print "Waiting Mun orbit insertion burn (program 9)" at (0,0).
			print "Total delta V required (m/s) : " + round(dV,2) + "          " at (0,1).
			print "Total time of burn (s)       : " + round(burnTime,2) + "          " at (0,2).
			print "Burn ETA (s)                 : " + round(timeUntilBurn,2) + "     " at (0,3).
			wait 0.001.
		}
		set t0 to TIME:SECONDS.
		
		//orbital insertion burn
		until (TIME:SECONDS - t0) > burnTime {
			set throttleLimit to 1.
			print "Burn (s)                         : " + ROUND((burnTime - TIME:SECONDS + t0),2) + "       " at (0,4).
			wait 0.001.
		}
		set throttleLimit to 0.
		set program to 10.
	}
	
	if program = 31 { // Mun orbit insertion
		clearscreen.
		RCS off.
		lock STEERING to SHIP:RETROGRADE.
		
		set rA to SHIP:PERIAPSIS + BODY:RADIUS.
		set rB to apoapsisTarget + BODY:RADIUS.
		
		set dVHohmann to ABS(deltaV(rA,rB)).  // order matters, first radius is the burn position
		// change this away from ABS, sign determines prograde vs retrograde
		set Ve to stage3ISP * 9.81. // convert specific impulse to exhaust velocity
		
		local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVHohmann / Ve))) / SHIP:AVAILABLETHRUST.  

		set timeUntilBurn to ETA:PERIAPSIS - burnTime / 2.
		
		until timeUntilBurn < 0 {
			lock STEERING to SHIP:RETROGRADE.
			set timeUntilBurn to ETA:PERIAPSIS - burnTime / 2.
			print "Waiting Mun orbit insertion burn (P-10)" at (0,0).
			print "Total delta V required (m/s) : " + round(dVHohmann,2) + "          " at (0,1).
			print "Total time of burn (s)       : " + round(burnTime,2) + "          " at (0,2).
			print "Burn ETA (s)                 : " + round(timeUntilBurn,2) + "     " at (0,3).
			wait 0.001.
		}
		set t0 to TIME:SECONDS.
		
		//orbital insertion burn
		until (TIME:SECONDS - t0) > burnTime {
			set throttleLimit to 1.
			print "Burn (s)                         : " + ROUND((burnTime - TIME:SECONDS + t0),2) + "       " at (0,4).
			wait 0.001.
		}
		set throttleLimit to 0.
		set program to 11.
	}
