set program to 13.
set ve to 330 * 9.81. // convert specific impulse to exhaust velocity
set throttleLimit to 0.
lock throttle to throttleLimit.
set orbitAltitudePlanned to 11400000.
set periapsisPlanned to 11500000.
set GM to BODY:MU.


until program = 0 {
	if program = 11 { // calculate delta v for planned orbit
		clearscreen.
		RCS off.
		lock STEERING to SHIP:PROGRADE.

		local radiusA is ship:periapsis + body:radius.
		local radiusB is orbitAltitudePlanned + body:radius.
		
		local a1 is SHIP:ORBIT:SEMIMAJORAXIS.
		
		local atx is (radiusA + radiusB) / 2.		// semi-major axis of transfer ellipse
		local ViA is sqrt(GM / radiusA).			// initial velocity at point A
		local VfB is sqrt(GM / radiusB).			// final velocity at point B
		
		local VtxA is SQRT(GM * (2 / radiusA - 1 / atx)).	// velocity on transfer orbit at initial orbit (point a)
		local VtxB is SQRT(GM * (2 / radiusB - 1 / atx)).	// velocity on transfer orbit at final orbit (point B)
		set dVA to VtxA - ViA.
		set dVB to VfB - VtxB.
		set dVT to dVA + dVB.
		
		set burnTimeA to (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVA / Ve))) / SHIP:AVAILABLETHRUST.  
		set burnTimeB to (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVB / Ve))) / SHIP:AVAILABLETHRUST.  

		set timeUntilBurn to eta:periapsis - burnTimeA / 2.
		
		until timeUntilBurn < 0.01 {
			lock STEERING to SHIP:PROGRADE.
			print "Waiting for first burn (P-12)" at (0,0).
			print "Burn ETA (s)                 : " + round(timeUntilBurn,2) + "     " at (0,1).
			print "Total delta V required (m/s) : " + round(dVT,2) + "          " at (0,2).
			print "Burn A delta V (m/s)         : " + round(dVA,2) + "          " at (0,3).
			print "Burn B delta V (m/s)         : " + round(dVB,2) + "          " at (0,4).
			print "Time of burn A (s)           : " + round(burnTimeA,2) + "          " at (0,5).
			print "Time of burn B (s)           : " + round(burnTimeB,2) + "          " at (0,6).
			wait 0.001.
			set timeUntilBurn to eta:periapsis - burnTimeA / 2.
		}	
		set program to 12.
	}

	if program = 12 { // Transfer burn
		kuniverse:pause.	// pause before burn
		clearscreen.
		RCS on.
		lock STEERING to SHIP:PROGRADE.
		
		set t0 to TIME:SECONDS.
		until (TIME:SECONDS - t0) > burnTimeA {
			print "Burn (s)                         : " + ROUND((burnTimeA - TIME:SECONDS + t0),2) + "       " at (0,8).
			set throttleLimit to 1.
			wait 0.001.
		}
		set throttleLimit to 0.
		rcs off.
		wait 1.
		set program to 13.
		clearscreen.
	}
	if program = 13 { // cruise to transfer apoapsis and circulrization burn
		clearscreen.
		rcs off.
		lock steering to ship:prograde + r(90,0,0).
		
		// recalculate second burn, we most likely didn't hit our target
		
		local rAp is SHIP:APOAPSIS + BODY:RADIUS.
		local rPe is orbitAltitudePlanned + BODY:RADIUS.
		
		local Vf is sqrt(GM / rAp).											// final velocity at cutoff for circularized orbit
		local Vtx is SQRT(GM * (2 / rAp - 1 / ship:orbit:semimajoraxis)).		// velocity at apoapsis for current orbit
		local dVB is Vf - Vtx.
			
		set burnTimeB to (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVB / Ve))) / SHIP:AVAILABLETHRUST. 
		
		set timeUntilBurn to eta:apoapsis - burnTimeB / 2.
		
		until timeUntilBurn < 60 {
			lock steering to ship:prograde + r(90,0,0).
			print "Waiting for second burn (P-12)" at (0,0).
			print "Burn ETA (s)                 : " + round(timeUntilBurn,2) + "     " at (0,1).
			print "Burn B delta V (m/s)         : " + round(dVB,2) + "          " at (0,2).
			print "Time of burn B (s)           : " + round(burnTimeB,2) + "          " at (0,3).
			wait 0.001.
			set timeUntilBurn to eta:apoapsis - burnTimeB / 2.
		}
		until timeUntilBurn < 0.01 {
			lock STEERING to SHIP:PROGRADE.
			print "Waiting for second burn (P-12)" at (0,0).
			print "Burn ETA (s)                 : " + round(timeUntilBurn,2) + "     " at (0,1).
			print "Burn B delta V (m/s)         : " + round(dVB,2) + "          " at (0,2).
			print "Time of burn B (s)           : " + round(burnTimeB,2) + "          " at (0,3).
			wait 0.001.
			set timeUntilBurn to eta:apoapsis - burnTimeB / 2.
		}
		
		set program to 14.
		clearscreen.
	}
	
	if program = 14 { // second burn
		kuniverse:pause.	// pause before burn
		clearscreen.
		RCS on.
		lock STEERING to SHIP:PROGRADE.
		
		set t0 to TIME:SECONDS.
		until (TIME:SECONDS - t0) > burnTimeB {
			print "Burn (s)                         : " + ROUND((burnTimeB - TIME:SECONDS + t0),2) + "       " at (0,8).
			set throttleLimit to 1.
			wait 0.001.
		}
		set throttleLimit to 0.
		rcs off.
		wait 1.
		set program to 13.
		clearscreen.
	}
}