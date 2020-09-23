@lazyglobal off.

declare function phaseAngle { 
	declare parameter radiusA.
	declare parameter radiusB.
	declare parameter targetObject.

	local data is list().
	
	// calculate the parameters of the transfer orbit to determine time of flight
	local transferSemiMajorAxis is (radiusA + radiusB) / 2. // semi-major axis of transfer ellipse
	local transferEccentricity is 1 - radiusA / transferSemiMajorAxis.  // eccentricity of transfer ellipse
	// the next calculation is the true anomaly of the second burn, which will coincide with arrival at the target
	// as this is a transfer ellipse, the true anomaly of the departure burn is zero; the sweep angle is the
	// difference in true anomalies (nu2 - nu1) and since nu1 is zero, the angle is simply nu2
	local transferSweepAngle is ARCCOS((transferSemiMajorAxis * (1 - transferEccentricity^2) / radiusB - 1) / transferEccentricity). // true anomaly difference of transfer ellipse (nu2 - nu1)
	local E is ARCCOS((transferEccentricity + cos(transferSweepAngle)) / (1 + transferEccentricity * cos(transferSweepAngle))). // eccentric anomaly of transfer ellipse
	local eccentricAnomalyRadian is E * CONSTANT:DEGTORAD. // the next equation needs radians
	local TOF is (eccentricAnomalyRadian - transferEccentricity * sin(eccentricAnomalyRadian)) * SQRT(transferSemiMajorAxis^3/KERBIN:MU). // time of flight in seconds (t2-t1)
	local meanAngularMotionTarget is 360 / targetObject:ORBIT:PERIOD.  // angular velocity in deg/s
	local phaseAngleAtDeparture is transferSweepAngle - meanAngularMotionTarget * TOF.
	
	local data is list(phaseAngleAtDeparture,TOF).
	return data.
	//return TOF.
}



//declare function stageDeltaV {
//return stage:engine:isp * 9.81 * ln(ship:mass / (ship:mass - (stage:LQDOXYGEN + stage:LQDHYDROGEN + stage:KEROSENE + stage:Aerozine50 + stage:UDMH + stage:NTO + stage:MMH + stage:HTP + stage:IRFNA-III + stage:NitrousOxide + stage:Aniline + stage:Ethanol75 + stage:LQDAMMONIA + stage:LQDMETHANE + stage:CLF3 + stage:CLF5 + stage:DIBORANE + stage:PENTABORANE + stage:ETHANE + stage:ETHYLENE + stage:OF2 + stage:LQDFLUORINE + stage:N2F4 + stage:FurFuryl + stage:UH25 + stage:TONKA250 + stage:TONKA500 + stage:FLOX30 + stage:FLOX70 + stage: + stage:FLOX88 + stage:IWFNA + stage:IRFNA-IV + stage:AK20 + stage:AK27 + stage:CaveaB + stage:MON1 + stage:MON3 + stage:MON10 + stage:MON15 + stage:MON20 + stage:Hydyne + stage:TEATEB)))
//}. //for real fuels
//declare function stageDeltaV { // stock fuels
//  return stage:engine:isp * 9.81 * ln(ship:mass / (ship:mass - (stage:LIQUIDFUEL))).
//}

// calculate burn delta v, use of BODY:MU restricts this to local orbits for now
declare function dVHohmann {
	declare parameter radiusA.
	declare parameter radiusB.
	//declare parameter bodyGM. // saved for future if calculating predicted orbits

	local GM is BODY:MU.
	local a1 is SHIP:ORBIT:SEMIMAJORAXIS.
	
	local atx is (radiusA + radiusB) / 2.	// semi-major axis of transfer ellipse
	local ViA is sqrt(GM / radiusA).		// initial velocity at point A
	local VfB is sqrt(GM / radiusB).		// final velocity at point B
	
	local VtxA is SQRT(GM * (2 / radiusA - 1 / atx)).	// velocity on transfer orbit at initial orbit (point a)
	local VtxB is SQRT(GM * (2 / radiusB - 1 / atx)).	// velocity on transfer orbit at final orbit (point B)
	local dVA is VtxA - ViA.
	local dVb is VfB - VtxB.
	local dVT is dVA + dVB.
	return (dVA + dVB).
}

declare function launchAzimuth {
	declare parameter inclinationDesired.
	declare parameter launchSite.
	declare parameter orbitAltitudePlanned.
	local velocityOrbitDesired is SQRT( GM / ( KERBIN:RADIUS + orbitAltitudePlanned )).
	local launchAzimuthInertial is ARCSIN ( COS (inclinationDesired) / COS (launchSite:GEOPOSITION:LAT) ).
	local velocityRotation is (2 * CONSTANT:PI * KERBIN:RADIUS) / KERBIN:ROTATIONPERIOD.
	local velocityXRotation is velocityOrbitDesired * SIN (launchAzimuthInertial) - velocityRotation * COS (launchSite:GEOPOSITION:LAT).
	local velocityYRotation is velocityOrbitDesired * COS (launchAzimuthInertial).
	local launchAzimuthRotation is ARCTAN ( velocityXRotation/velocityYRotation ).
	return (launchAzimuthRotation).
}

declare function InsertionBurn {
	declare parameter radiusA.
	declare parameter radiusB.
	//declare parameter bodyGM. // saved for future if calculating predicted orbits

	local GM is BODY:MU.
	local rCurrent is SHIP:PERIAPSIS + BODY:RADIUS.
	local aCurrent is SHIP:ORBIT:SEMIMAJORAXIS.
	
	local vInitial is SQRT(GM * (2 / rCurrent - 1 / aCurrent)).
	
	
	local transferSemiMajorAxis is (radiusA + radiusB) / 2. // semi-major axis of transfer ellipse
	local vInitialA is SQRT(BODY:MU / radiusA ).
	local vTransferA is SQRT(BODY:MU * (2 / radiusA - 1 / transferSemiMajorAxis)).
	return (vTransferA - vInitialA).
}

//declare function burnTime {
//}

declare function simplePlaneChange {
	declare parameter radiusA.
	//declare parameter radiusB.
	declare parameter theta.
	
	local GM is BODY:MU.
	local a is SHIP:ORBIT:SEMIMAJORAXIS.

	local v1 is SQRT(BODY:MU * (2 / radiusA - 1 / a)).
	//local v2 is SQRT(BODY:MU * (2 / radiusA - 1 / a2)).
	
	local dV is 2 * v1 * SIN(theta/2).
	return dV.
}

declare function combinedPlaneChange {
	declare parameter radiusA.
	declare parameter radiusB.
	declare parameter theta.

	local GM is BODY:MU.
	local a1 is SHIP:ORBIT:SEMIMAJORAXIS.

	local a2 is (radiusA + radiusB) / 2. // semi-major axis of transfer ellipse
	local v1 is SQRT(BODY:MU * (2 / radiusA - 1 / a1)).
	local v2 is SQRT(BODY:MU * (2 / radiusA - 1 / a2)).
	
	local dV is SQRT(v1^2 + v2^2 - 2 * v1 * v2 * COS(theta)).
	return dV.
}

declare function pureInclinationChange {
	declare parameter theta.	// inclination change
	declare parameter e. 		//e is the orbital eccentricity
	declare parameter w. 		//w (omega) is the argument of periapsis
	declare parameter f.		//f is the true anomaly
	declare parameter n.		//n is the mean motion (in radians)
	declare parameter a.		//a is the semi-major axis

// this is a doosey, dVi = 2sin(di/2)SQRT(1-e^2)cos(w+f)na/(1+ecos(f))
}

declare function normalVector {
	return VCRS(SHIP:BODY:POSITION,SHIP:VELOCITY:ORBIT).  // Cross-product these for a normal vector
}

function getVectorRadialin{
	SET normalVec TO getVectorNormal().
	return vcrs(ship:velocity:orbit,normalVec).
}
function getVectorRadialout{
	SET normalVec TO getVectorNormal().
	return -1*vcrs(ship:velocity:orbit,normalVec).
}
function getVectorNormal{
	return vcrs(ship:velocity:orbit,-body:position).
}
function getVectorAntinormal{
	return -1*vcrs(ship:velocity:orbit,-body:position).
}
function getVectorSurfaceRetrograde{
	return -1*ship:velocity:surface.
}
function getVectorSurfacePrograde{
	return ship:velocity:surface.
}