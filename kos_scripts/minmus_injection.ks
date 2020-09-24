	if program = 11 { // Trans Munar Injection (TMI) burn guidance calculations
		clearscreen.
		RCS off.
		
        // transmunar trajectory up to Mun’s SOI
			// Choose values for the independent variables of the problem
				// Select the date for Mun’s position at SOI intercept
				// Select the value for the arrival angle λ
				// Select the probe’s radius r0 , right ascension αL , declination δL , and flight path angle γ0 at TMI
			// Determine Mun’s kerbocentric equatorial state vector (rm ,vm ) on the date at SOI intercept
			// Calculate s-hat, the unit vector along the Kerbin-to-Mun radial
			// Calculate ω m , the instantaneous angular velocity of Mun at the time of SOI intercept
			// Calculatethegeocentricpositionvectorr 0 atTMIusingEqs.(4.4)and(4.5)andthedatainI.1.c
			//  Calculate ^ w 1 , the unit normal to the plane of the transmunar trajectory
			//  Calculate ^ b, the unit normal to the plane of ^ s and ^ w 1 . ^ b lies in the plane of the transmunar trajectory (see Fig. 9.10):
			// 8. Calculate ^ n, the unit vector from the center of Mun to the SOI patch point:
			// 9. Calculate r 2 , the position vector of the patch point relative to Mun:
			// 10. Calculate r 1 , the position vector of the patch point relative to the earth:
			// 11. Use Eq. (9.14) to calculate the sweep angle Δθ:
			// 12. Calculate the angular momentum h 1 of the transmunar trajectory using Eq. (9.18):
			// 13. Calculate the Lagrange coefficients f, g, and _ g from Eqs. (9.13a)–(9.13c):
			// 14. Calculatethevelocityv 0 atTMIandthevelocityv 1 atthepatchpointbymeansofEqs.(9.12a) and (9.12b):
			// 15. Calculate the radial component of velocity v r 0 at TMI:
			// 16. Using the TMI state vector (r 0 ,v 0 ), calculate the eccentricity vector e 1 of the transmunar trajectory from Eq. (2.40). The eccentricity, e 1 = ke 1 k, must be less than 1:
			// 17. Calculatethesemimajoraxisa 1 andtheperiodT 1 ofthetransmunartrajectoryfromEqs.(9.24) and (9.25), respectively:
			// 18. Calculate the triad of perifocal unit vectors ^ p 1 , ^ q 1 , and ^ w 1 for the transmunar trajectory:
			// 19. Calculate the true anomaly θ 0 at the TMI point using Eq. (9.27) and noting from Step I.16 that
			// 20. Calculate the time t 0 since perigee at the TMI point using Eq. (9.28):
			// 21. Calculate the true anomaly θ 1 at the patch point, θ 1 = θ 0 + Δθ, where we found the sweep angle Δθ in Step I.11:
			// 22. Calculate the time t 1 since perigee at the patch point using Eq. (9.30):
			// 23. Calculate the flight time Δt 1 from TMI to the patch point, Δt 1 = t 1 ? t 0 :
        local radiusInitial is ship:orbit:semimajoraxis.            // radius of LKO (Low Kerbin Orbit) at TMI; r0
		local radiusFinal is orbitAltitudePlanned + body:radius.    // apoapsis of transfer orbit (Mun orbit); rF
		
        local aTransferOrbit is (radiusInitial + radiusFinal) / 2.		// semi-major axis of transfer ellipse
		
		local velocityInitial is SQRT(GM * (2 / radiusInitial - 1 / aTransferOrbit)).	// velocity at TMI after the burn, calculate from Hohman transfer veloctiy to Mun orbit
        
        local flightPathAngleInitial is 0. // flight path angle (degrees) after TMI (always 0 degrees because it's after the burn)
        local trajectoryAngleAtMun is 30. // the angle of the transfer trjectory at Mun's SOI (Sphere of Influence)

        // Calculate arrival conditions at Mun SOI; r1, v1, phi1, gamma1
        local EnergyInitial is (velocityInitial ^ 2 / 2) - (GMKerbin / radiusInitial). // Intial energy of trasnfer trejectory (E0)
        local angularMomentumInitial is radiusInitial * velocityInitial * cos(flightPathAngleInitial). // Initisl angular momentum of transfer trajectory (h0)
        
        local D is target:orbit:altitude + body:radius.
        local RS is target:soiradius.
        local radiusSOI is sqrt ( D^2 + RS^2 - (2*D*RS*cos(trajectoryAngleAtMun))). // Radius of the orbit at Mun SOI arrival for given arrival angle (r1)
        local angularMomentumSOI is angularMomentumInitial. // Angular momentum at Mun SOI arrival; equal to initial angulare momentum due to consrvation of momentum (h1)
        local velocitySOI is sqrt( 2*(EnergyInitial+(GMKerbin/radiusSOI))). // Velocity at Mun SOI arrival (v1)
        local flightPathAngleSOI is arccos (angularMomentumSOI/(radiusSOI*velocitySOI)). // Flight path angle at Mun SOI arrival: phi1

        // Calculate Time of Flight (TOF); need p, a, e, E0 and E1 of the trasnfer trajectory
        local semiLatusRectum is angularMomentumInitial / GMKerbin. // Semi-latus rectum; p
        local eccentricityTransfer is sqrt ( 1 - semiLatusRectum / aTransferOrbit ).    // Eccentricity, e
        local phaseAngleSOI is arcsin ( RS/radiusSOI * sin (flightPathAngleSOI)).  // phase angle at SOI
        local ecentricAnomalyInitial is 0. // Initial Eccentric Anonmaly; EcA0: true anomaly is 0 at periapsis of trasnfer elipse
        local trueAnomalySOI is arccos((semiLatusRectum-radiusSOI)/(eccentricityTransfer*radiusSOI)). // true anomaly v(p,r,e).
        local ecentricAnomalySOI is arccos ( (eccentricityTransfer + cos(trueAnomalySOI)) / ( 1 + eccentricityTransfer * cos(trueAnomalySOI))). // Ecentric anomaly at Mun SOI
        local TOF is sqrt (eccentricityTransfer^3/GMKerbin)*((ecentricAnomalySOI-eccentricityTransfer*sin(ecentricAnomalySOI))-(ecentricAnomalyInitial-eccentricityTransfer*sin(angularMomentumInitial))). // Time of flight; TOF 
        // Anomaly; 

		set TARGET to targetObject.
		local aShip is SHIP:ORBIT:SEMIMAJORAXIS.
		local aTarget is TARGET:ORBIT:SEMIMAJORAXIS - apoapsisTarget + 50000.
		
		set phaseAngleData to phaseAngle(aShip,aTarget,targetObject).
		set phaseAngleAtDeparture to phaseAngleData[0].
		set timeOfFlight to phaseAngleData[1].
		lock STEERING to SHIP:PROGRADE.


		// determine positions to calculate the current phase angle
		lock targetPosition to TARGET:POSITION - SHIP:BODY:POSITION.
		// KERBIN:POSITION returns the position of Kerbin with respect to the ship, we want the ship's position
		// with respect to Kerbin so we negate the vector
		lock kerbinPosition to -KERBIN:position.
		set currentPhaseAngle to vang(kerbinPosition,targetPosition).
		
		// the angle to the Mun can not be over 180 degrees, so we need to test if we are movng away
		// from the Mun and subtract the angle from 360, once we cross 180 degrees the phase angle
		// will be as calculated.
		// TODO: make this better, i.e. use position vector signs to remove need for test
		// test if we are heading towards the Mun
		//set distToTarget1 to targetObject:DISTANCE.
		//wait 0.01. // no need for a large wait, only need a single physics tick
		//set distToTarget2 to targetObject:DISTANCE.
		//if (distToTarget2 - distToTarget1) > 0 { set currentPhaseAngle to 360 - currentPhaseAngle. }

		// calculate time to burn
		// a phase angle less than gamma results in negative time to burn
		if currentPhaseAngle > phaseAngleAtDeparture { set deltaPhaseAngle to currentPhaseAngle - phaseAngleAtDeparture. } 
			else { set deltaPhaseAngle to currentPhaseAngle - phaseAngleAtDeparture + 360. }
		set meanAngularMotionShip to 360 / SHIP:ORBIT:PERIOD.
		set meanAngularMotionTarget to 360 / targetObject:ORBIT:PERIOD.  // angular velocity in deg/s
		set meanAngularMotionTotal to ABS(meanAngularMotionShip - meanAngularMotionTarget).
		set timeUntilPhase to deltaPhaseAngle / meanAngularMotionTotal.
			
		// TODO: add Karbal Alarm Clock alarm for burn pause game? this sill need to be out of a loop
		// maybe put prints in a loop and use locks to force update
		until timeUntilPhase < 60 {
			set currentPhaseAngle to vang(kerbinPosition,targetPosition).
			set check to VCRS(kerbinPosition,targetPosition).
			if check:Y > 0 { set currentPhaseAngle to 360 - currentPhaseAngle. } // if positive we are moving away
			set timeUntilPhase to deltaPhaseAngle / meanAngularMotionTotal.
				if currentPhaseAngle > phaseAngleAtDeparture {
					set deltaPhaseAngle to currentPhaseAngle - phaseAngleAtDeparture. } 
					else { set deltaPhaseAngle to currentPhaseAngle - phaseAngleAtDeparture + 360. }
			print "Waiting for injection window" at (0,0).
			print "Phase angle at departure (deg) : " + round(phaseAngleAtDeparture,2) + "   " at (0,1).
			print "Current phase angle (deg)      : " + round(currentPhaseAngle,2) + "   " at (0,2).
			print "Time to TMI (s)                : " + round(timeUntilPhase) + "      " at (0,3).
			//print "Mun position                   : " + targetPosition + "                 " at (0,4).
			//print "Kerbin position                : " + check + "                 " at (0,5).
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
