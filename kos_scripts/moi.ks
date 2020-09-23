// Munar Orbit Insertion

// TODO: This really needs to be more elegant and smaller, it almost takes the whole volume!


clearscreen.
// set the steering so it points towrads Kerbin for realism (the comm dish) also
// make sure the soalr panels can point towarsd Kerbol, may need to redisgn probes for this
// for some readon this points retrograde 
// when first tried it pointed towards Kerbin
lock steering to lookdirup( v(1,0,0), sun:position ). 

// need mid cousr correction, but how can I tell if it is needed
// and why, maybe based on epxeprince
// part of mid course correction will be inclination changes
// will be needed for altimetry scan mission

// inclination change, figure out when AN or DN is coming up and dtermine the burn needed
// use mun:distance to determine time to soi change, need to get mun soi or just note it

// try to guess the periapsis of the munar orbit if you can
// may have to wait for SOI change, then calculate the burns
// check under predictions http://ksp-kos.github.io/KOS_DOC/commands/prediction.html

if ship:body <> BODY("Mun") { 
	until eta:transition < 1 {		
		lock timeSOIsec to mod(eta:transition,60).
		lock timeSOImin to (eta:transition - timeSOIsec) / 60.
		print "Time until SOI change (min:sec): " + timeSOImin + ":" + round(timeSOIsec,1) + "     " at (0,5).
	}
}

// oribt adjust, move the variables to beginiing or convert to functions
set targetPeriapsis to 30000.0.			// these are altitudes, not true r
set targetApoapsis to  30000.0.
sas on.

// now we try to avoid the Mun, needs more math
set sasmode to "radialin".
set rb to mun:radius.			// radius of body, 200,000m
lock a to ship:obt:semimajoraxis.
lock e to ship:obt:eccentricity.
set rp to a * (1 - e).				// closets approach, true periapsis, from center of Mun
if rp - rb < 0 {		// if true, will impact surface, will require burn to increase
	print rp.			// do something here, for now i cheated, whis will reqire more understanding
}

// now that the ship will miss the body, calculate an orbit 
set sasmode to "retrograde".		// have this start later, keep soalr panels to sun
//wait until eta:periapsis < 5.		// skip until calculations are correct

//lock r1 to ship:altitude+kerbin:radius.		// maybe change this to semi major axis for e<1
set isp to 345.0 * 9.8.				// ISP in seconds, covnert by multiplying 9.8 m/s^2
set thrust to 60.0 * 1000.			// Thrust in N
set rp to ship:periapsis+mun:radius.
set r2 to mun:periapsis+kerbin:radius.
set vesc to 807.08.
set v to sqrt(mun:mu/rp).
lock timePeriapsis to eta:periapsis.
set velVectorPeriapsis to velocityat(ship,time+timePeriapsis).
set velPeriapsis to velVectorPeriapsis:orbit:mag.		// scalar velocity at periapsis
print velPeriapsis.
set dv to velPeriapsis-v.
//set dv to (sqrt(mun:mu/r1))*(sqrt(2*r2/(r1+r2))-1). // recalculate dv to account for altitude at burn
set mdot to thrust / isp.								// mass flow rate
set massFinal to ship:mass * 1000 / (constant():e^(dv/isp)).	// mass in kg after burn
set burn to (ship:mass * 1000 - massFinal) / mdot.				// burn time in seconds
print "delta v : " + dv.
print burn.

// put in a check to make sure we are pointed in the right direction, wait until stabilized
until eta:periapsis < (burn/2) {
	Print "Waiting for burn window in : " + (eta:periapsis - (burn/2)) at (0,15).
	if eta:periapsis < 120 {
		set warp to 0.					// drop out of warp if manual wraping and not paying attention
	}
	// create a function to return minutes and seconds
}

set burnStart to time:seconds.					// this seems hackish, try to be more elegant
set burnEnd to burnStart + burn.
print burnEnd.
until burnEnd < time:seconds {
	print "Burn for : " + (burnEnd - time:seconds) at (0,20).
	lock throttle to 1.0.
}

print "Orbit!".
lock throttle to 0.0.
set ship:control:pilotmainthrottle to 0.	// set throttle to zero when exiting program



