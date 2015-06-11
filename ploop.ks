clearscreen.
set ship:control:pilotmainthrottle to 0.	// set throttle to zero when exiting program
// lock steering to prograde + R(0,0,-45).		// solar panels were offset 45 degrees
// lock steering to retrograde.
wait 10.

function ploop {			// direction ploop.
	parameter SP.			// setpoint (target)
	parameter PV.			// measured process variable (actual)
	parameter I.
	
	local p is SP:pitch.
	local y is SP:yaw.
	local r is SP:roll.
	
	// tuning parameters
	local Kp is 0.15.		// proportional gain, 0.0015 was good in p loop 
	local Ki is 0.006.		// integral gain
	
	local ep is SP:pitch - PV:pitch.	// current error
	local ey is SP:yaw   - PV:yaw.		// current error
	local er is SP:roll  - PV:roll.		// current error

	local Pp is Kp * ep.		// proportional term, for P-loop this is the returned value
	local Py is Kp * ey.		// proportional term, for P-loop this is the returned value
	local Pr is Kp * er.		// proportional term, for P-loop this is the returned value
	
	// integral term
	local Ip is Ki * I.
	local Iy is Ki * I.
	local Ir is Ki * I.
	
	local P is R(Pp,Py,Pr).
	return P.
}

local autopilotSP is 0.

//lock autopilotSP to ship:prograde + R(0,0,-90).
lock autopilotSP to ship:prograde + R(0,0,-45).
// lock autopilotSP to ship:prograde.

lock autopilotPV to ship:facing.

set myDir to autopilotSP.
lock steering to MyDir.

until ship:apoapsis > 200000 {
	set myDir to autopilotSP + ploop(autopilotSP,autopilotPV,0).
	print autopilotSP + "    " at (0,10).
	print autopilotPV + "    " at (0,11).
	//set dpitch to autopilotSP:pitch + dx.
	//set dyaw to autopilotSP:yaw + dy.
	//set droll to autopilotSP:roll + dz.
	//print R(dpitch,dyaw,droll) at (0,13).
	wait 0.1.
	}
	
function simpleploop {			//direction ploop.
	parameter SP.			// setpoint (target)
	parameter PV.			// measured process variable (actual)
	
	local Kp is 0.0015.		// proportional gain, a tuning parameter, maybe promoted to function parameter
	
	local e is SP - PV.		// current error
	local P is Kp * e.		// proportional term, for P-loop this is the returned value
	
	return P.
}