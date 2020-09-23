// Set the ship to a known configuration
sas off.
rcs off.
lights off.
lock throttle to 0. 						// Throttle is a decimal from 0.0 to 1.0
gear off.
set ship:control:pilotmainthrottle to 0.	// set throttle to zero when exiting program
AG1 on.

clearscreen.
//set rentryBurnLng to 175. // land in water off of coast (short burn at 170)
set rentryBurnLng to 150. // land before KSC, needed because probes sink


print "Begin reentry sequence.".
rcs on.
lock steering to ship:retrograde + r(0,0,90).

until ROUND(SHIP:GEOPOSITION:LNG) = rentryBurnLng {
	print "Waiting for deorbit burn " at (0,1).
	print "Burn longitude (deg) : " + ROUND(rentryBurnLng,2)         + "      " at (0,2).
	print "Ship longitude (deg) : " + ROUND(SHIP:GEOPOSITION:LNG,2) + "      " at (0,3).
}
clearscreen.
print "Burn longitude (deg) : " + round(ship:geoposition:lng,2) + "      " at (0,0).
print "Burn altitude (m)    : " + round(ship:altitude)          + "      " at (0,1).
print "Burn periapsis (m)   : " + round(ship:periapsis)         + "      " at (0,2).
kuniverse:pause.	// this allows me to record the data just at burn, and pause in case I walk away
print "Burn to lower periapsis to 20,000 km.".
until SHIP:PERIAPSIS < 20000 {
	lock THROTTLE to 1.0.
}.

lock THROTTLE to 0.0.
print "Cutoff longitude (deg) : " + round(ship:geoposition:lng,2).
print "Cutoff altitude (m)    : " + round(ship:altitude).
print "Cutoff periapsis (m)   : " + round(ship:periapsis).
kuniverse:pause.	// this allows me to record the data just after burn
//until eta:periapsis < 30 {
//    print "Burn complete, coasting to deorbit burn in " + round(eta:periapsis) + "s." at (0,4).
//    wait 1.
//}.
wait until altitude < 70000.
print "Entering atmosphere, steering to surface retrograde.".
kuniverse:pause.		// pause if not paying attention
lock steering to ship:srfretrograde.
wait 10.

//print "Deorbit burn.".
//until SHIP:APOAPSIS < 71000 {
//	lock THROTTLE to 1.0.
//}.
lock THROTTLE to 0.0.

//wait until ROUND(SHIP:GEOPOSITION:LNG) = rentryBurnLng.
//until SHIP:PERIAPSIS < 0 {
//    lock THROTTLE to 1.0.
//}
wait until alt:radar < 2500.
unlock steering.
stage. // diploy chutes
wait until ship:verticalspeed = 0.
print "Landing longitude (deg) : " + round(ship:geoposition:lng,2).
print "Splashdown, returning to manual control for recovery.".
AG1 off.
lock throttle to 0.
set ship:control:pilotmainthrottle to 0.

// end program