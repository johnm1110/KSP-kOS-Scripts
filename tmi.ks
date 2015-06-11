clearscreen.
set ship:control:pilotmainthrottle to 0.	// set throttle to zero when exiting program
lock steering to prograde + R(0,0,-45).		// solar panels were offset 45 degrees

function ploop {
	parameter SP.			// setpoint (target)
	parameter PV.			// measured process variable (actual)
	
	local e is SP - PV.		// current error
	local Kp is 0.05.		// proportional gain, a tuning parameter
	local P is Kp * e.		// proportional term, for P-loop this is the returned value
	
	return P.
}

lock setPoint to ship:prograde + R(0,0,-45).
lock processVariable to ship:facing.

// Intialized variables
set M2 to 0.0.
set M1 to 0.0.
set n to 0.0.		// mean motion
set tx to 0.0.
set t0 to 0.0.
set v to 0.0.		// true anomaly no velocity
set v0 to 0.0.		// ^

// Ship variables
set isp to 345.0 * 9.8.				// ISP in seconds, covnert by multiplying 9.8 m/s^2
set thrust to 60.0.					// Thrust in kN

// Hohmann transfer calculations, update this to extimate where in orbit it will occur, changes altitude
// if orbit is not exactly circular, but thses calculations may be eoonough for a small e
lock r1 to ship:altitude+kerbin:radius.		// maybe change this to semi major axis for e<1
set r2 to mun:periapsis+kerbin:radius.
set atx to (r1+r2)/2.						// semi-major axis of transfer elispse
set dv to (sqrt(kerbin:mu/r1))*(sqrt(2*r2/(r1+r2))-1). // delta-v of the burn
set ex to 1 - (r1 / atx).					// eccentricity of transfer elispse
set tx to (3.14*sqrt(((r1+r2)^3)/(8*kerbin:mu))). // lock to continue altitude samples for e<1
print "Transfer time (s) : " + tx.									// transfer time in secs
print "Estimated dv (m/s): " + dv.

// Equation is M2=n(t), mean anomaly at t
// n=sqrt(GM/(a^3))

lock M1 to mun:obt:trueanomaly. 		// Circular orbit and co-planar so mean is equal to true
set a to mun:periapsis+kerbin:radius.			// circular orbit so semi-major axis is equal to perapsis
set n to 360 / mun:obt:period.					// mean motion, average angualr velocity
set M2 to n*tx + M1.						// Mean anomaly at time t (intercept position)
if M2 > 360 {							// Normalize to keep within 360 degrees
	set M2 to M2 - 360.
}

lock theta1 to ship:position-ship:body:position.	// convert coordinates to Kerbin frame of reference
lock theta2 to mun:position-ship:body:position.
set phaseBurnAngle to 180 - ( M2 - M1).				// for the Mun ~110

// determine if phase angle is increasing
set phaseAngle1 to vang((ship:position-ship:body:position),(mun:position-ship:body:position)).
wait 0.001.
set phaseAngle to vang(theta2,theta1).					// calculate the phase angle
if phaseAngle1 - phaseAngle < 0 {					// if it is, chnage to a 0 to 360 coord
	set phaseAngle to 360 - phaseAngle.	// from two 0 to 180 systems
}

set burnAngle to phaseAngle - phaseBurnAngle.			// burn at 0 degrees, this will be 0 to 180
lock nShip to 360 / ship:obt:period.			// mean motion, degrees per sec, lock for e <> 1	
set timeUntilBurn to burnAngle / nShip.			// seconds until burn
if timeUntilBurn > 0 and timeUntilBurn < 60 {
	print "TMI window too close to current position, waiting for next window.".
	set burnAngle to phaseAngle - phaseBurnAngle.			// burn at 0 degrees, this will be 0 to 180
	print burnAngle at (0,3).
	wait until burnAngle < 0.
}

if burnAngle < 0 {  // this needs to be moved to a function until phaseangle is decreasing
	print "TMI window just passed, standy for next window.".
	until timeUntilBurn > 0 {
		print "Time to next window : " + round(phaseAngle / nShip) + "  " at (0,4).
		set phaseAngle1 to vang((ship:position-ship:body:position),(mun:position-ship:body:position)).
		wait 0.001.
		set phaseAngle to vang(theta2,theta1).					// calculate the phase angle
		if phaseAngle1 - phaseAngle < 0 {					// if it is, chnage to a 0 to 360 coord
			set phaseAngle to 360 - phaseAngle.	// from two 0 to 180 systems
		}
		set burnAngle to phaseAngle - phaseBurnAngle.			// up to date for the follow
		set timeUntilBurn to burnAngle / nShip.					// function
		print timeUntilBurn at (0,6).
		print burnAngle at (0,7).
	}
}
until timeUntilBurn < 0.001 {
	// set dSteer to ploop(setPoint,processVariable).
	// set setPoint to setPoint + dsteer.
	// wait 0.1.
	set sUB to mod(timeUntilBurn,60).
	set mUB to ((timeUntilBurn -sUB )/ 60).
	print "Time until burn (m) : " + mUB + "m " + round(sUB,1) + "s " at (0,10).
	print "Estimated dv (m/s)  : " + round(dv,2) at (0,11).
    print "Transfer time (s)   : " + tx at (0,12).
	print "Burn angle          : " + BurnAngle at (0,14).
	print "Phase angle         : " + phaseAngle at (0,16).
	print "Intercept angle     : " + interceptAngle at (0,17).
	set burnAngle to phaseAngle - phaseBurnAngle.			// burn at 0 degrees, this will be 0 to 180
	set phaseAngle1 to vang((ship:position-ship:body:position),(mun:position-ship:body:position)).
	wait 0.001.
	set phaseAngle to vang(theta2,theta1).					// calculate the phase angle
	if phaseAngle1 - phaseAngle < 0 {					// if it is, chnage to a 0 to 360 coord
		set phaseAngle to 360 - phaseAngle.	// from two 0 to 180 systems
	}
	set tx to (3.14*sqrt(((r1+r2)^3)/(8*kerbin:mu))).
	set M2 to n*tx + M1.
	set timeUntilBurn to (phaseAngle - phaseBurnAngle)/(360 / ship:obt:period).
	set dv to (sqrt(kerbin:mu/r1))*(sqrt(2*r2/(r1+r2))-1).
}

set dv to (sqrt(kerbin:mu/r1))*(sqrt(2*r2/(r1+r2))-1). // recalculate dv to account for altitude at burn
set mdot to thrust * 1000 / isp.								// mass flow rate
set massFinal to ship:mass * 1000 / (constant():e^(dv/isp)).	// mass in kg after burn
set burn to (ship:mass * 1000 - massFinal) / mdot.				// burn time in seconds
print "delta v : " + dv.

set burnStart to time:seconds.
set burnEnd to burnStart + burn.
print burnEnd.
until burnEnd < time:seconds {
	print "Burn for : " + (burnEnd - time:seconds) at (0,20).
	lock throttle to 1.0.
}
print "To da Mun!".
lock throttle to 0.0.
set ship:control:pilotmainthrottle to 0.	// set throttle to zero when exiting program
