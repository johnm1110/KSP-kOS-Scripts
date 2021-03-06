// replace later but here now for script testing, keep solar panels facing Kerbol
lock steering to lookdirup(v(0,1,0),sun:position).

//set initial parameters to just inside of the patch point
set timeImpactEstimate to timestamp() + ship:orbit:NEXTPATCHETA + 100.

local positionShipPatch is positionat(ship,timeImpactEstimate).
local positionTargetPatch is positionat(ship:orbit:nextpatch:body,timeImpactEstimate).
local positionShipRelTargetPatch is positionTargetPatch - positionShipPatch.  // position of ship relative to the taget body
// calculate the distance from the surface of the target body, incorporate any scanned surface data if possible
set altitudeDelta to positionShipRelTargetPatch:mag - ship:orbit:nextpatch:body:radius.

function impactRecursion {
    parameter timeEstimate.
    parameter timeOffset.
    
    local timeEstimate to timeEstimate + timeOffset.

    local positionShip is positionat(ship,timeEstimate).
    local positionTarget is positionat(ship:orbit:nextpatch:body,timeEstimate).
    local shipPositionRelTarget is positionTarget - positionShip.

    local altitudeImpact to shipPositionRelTarget:mag - ship:orbit:nextpatch:body:radius.
    return altitudeImpact.
}

from {local x is 100.} 
until impactRecursion(timeImpactEstimate,x) < 0 
step {set x to x + 100.}
do {

}

until (altitudeDelta) < 0 { // check until the altitude is negative
    set timeImpactEstimate to timeImpactEstimate + 100.

    local shipPositionCheck is positionat(ship,timeImpactEstimate).
    local targetPositionCheck is positionat(ship:orbit:nextpatch:body,timeImpactEstimate).
    local shipPositionCheckRel is targetPositionCheck - shipPositionCheck.

    set altitudeDelta to shipPositionCheckRel:mag - ship:orbit:nextpatch:body:radius.
    //print altitudeDelta.
    //print timeImpactEstimate.
}
// turn back time by 100 seconds and begin checking every 10 seconds
set timeImpactEstimate to timeImpactEstimate - 100. 
local positionShipPatch is positionat(ship,timeImpactEstimate).
local positionTargetPatch is positionat(ship:orbit:nextpatch:body,timeImpactEstimate).
local positionShipRelTargetPatch is positionTargetPatch - positionShipPatch.

set altitudeDelta to positionShipRelTargetPatch:mag - ship:orbit:nextpatch:body:radius.

until (altitudeDelta) < 0 { // check until the altitude is negative
    set timeImpactEstimate to timeImpactEstimate + 10.
    
    local shipPositionCheck is positionat(ship,timeImpactEstimate).
    local targetPositionCheck is positionat(ship:orbit:nextpatch:body,timeImpactEstimate).
    local shipPositionCheckRel is targetPositionCheck - shipPositionCheck.

    set altitudeDelta to shipPositionCheckRel:mag - ship:orbit:nextpatch:body:radius.
    //print altitudeDelta.
    //print timeImpactEstimate.
}
// turn back time by 10 seconds and begin checking every 1 second
set timeImpactEstimate to timeImpactEstimate - 10. 
local positionShipPatch is positionat(ship,timeImpactEstimate).
local positionTargetPatch is positionat(ship:orbit:nextpatch:body,timeImpactEstimate).
local positionShipRelTargetPatch is positionTargetPatch - positionShipPatch.

set altitudeDelta to positionShipRelTargetPatch:mag - ship:orbit:nextpatch:body:radius.
until (altitudeDelta) < 0 { // check until the altitude is negative
    set timeImpactEstimate to timeImpactEstimate + 1.

    local shipPositionCheck is positionat(ship,timeImpactEstimate).
    local targetPositionCheck is positionat(ship:orbit:nextpatch:body,timeImpactEstimate).
    local shipPositionCheckRel is targetPositionCheck - shipPositionCheck.

    set altitudeDelta to shipPositionCheckRel:mag - ship:orbit:nextpatch:body:radius.
    //print altitudeDelta.
    //print timeImpactEstimate.
}

//set timeImpactEstimate to timeImpactEstimate - 1. // may need to recurse even further, this 1 second results in a ~4000m difference!

//local positionShipPatch is positionat(ship,timeImpactEstimate).
//local positionTargetPatch is positionat(ship:orbit:nextpatch:body,timeImpactEstimate).
//local positionShipRelTargetPatch is positionTargetPatch - positionShipPatch.

//set altitudeDelta to positionShipRelTargetPatch:mag - ship:orbit:nextpatch:body:radius.

// recursion finished, positions at time of impact
local targetPositionImpactEstimate is positionat(ship:orbit:nextpatch:body,timeImpactEstimate).  // target body position
local shipPositionImpactEstimate is positionat(ship,timeImpactEstimate).                         // ship position
local shipPositionImpactEstimateRel is targetPositionImpactEstimate - shipPositionImpactEstimate.  //ship position realtive to taget body

// calculate the spacecraft patch position at the estimated impact point, not sure if estimate use patch info or impact time info
set patchTime to timestamp() + ship:orbit:NEXTPATCHETA + 100.

// estimate impact location on Mun surface, this likly calculates the future position of the spacecraft onto the current position of Mun 
local impactSiteEstimate is mun:geopositionof(shipPositionImpactEstimate).
//local impactPositionPatch is positionat(impactSiteEstimatePrePatch:position,patchTime).

// calculate impact target position
//local positionTargetPatch is positionat(impactSite:position,patchTime).


local impactSite is waypoint("Site T3-P").
local impactSiteSurfaceCoords is impactSite:geoposition.
local impactSitePosition is impactSite:position. // this is likely returning a position realtive to the current ship position

// shady deltav calulation to burn correction, test here, move to inside patch (or leave here to test for large difference)
// this burn will happen just past the patch
local deltav is velocityat(ship,timeImpactEstimate):orbit:mag * sin (vang(shipPositionImpactEstimate,impactSitePosition)).

// calculate time until impact, this results in a timespan
local impactETA is timeImpactEstimate - timestamp(). // this results in a timespan

clearscreen.
print "ETA to impact (s)                     : " + impactETA:full.
print "Alttiude (m)                          : " + altitudeDelta.
print "Impact surface coords                 : " + impactSiteEstimate.
print "Impact target                         : " + impactSite.
print "Location                              : " + impactSite:geoposition.
print "Estimate deltav                       : " + deltav.
print "Estimated impact position angle (deg) : " + vang(shipPositionImpactEstimate,impactSitePosition).


// get impact geoposition, then get the patch position to it
// get waypoint geoposition, then get ship patch position
// local deltav is velocityat(ship,patchTime) * sin (vang(impactPositionPatch,positionTargetPatch))
// use patch velocity of ship * sin of previous angle
// us that as delta v for a radial burn just past patch point
// do more research on vectors and orbits, this probably isn't correct

//local positionShipPatch is positionat(ship,patchTime).
//local positionTargetPatch is positionat(ship:orbit:nextpatch:body,patchTime).
//local positionShipRelTargetPatch is positionTargetPatch - positionShipPatch.

// print position of impact as differnce to desired impact point
// as meters to N/S and E/W

//print "velocity relative to this body is: " + shipVelocityPatch:mag.
//print "velocity relative to the Mun is:   " + shipVelocityPatchRel:mag.
//print "Distance to Mun at patch point     " + positionShipRelTargetPatch:mag.
//print "Loose time to Mun                  " + timeToImpact.
//print "Distance to Mun at guess point     " + positionShipRelTargetPatch:mag.
//print "Loose time to Mun                  " + timeToImpact.

// calculate poistion of ship 60 seconds past SOI patch point
// calculate position of ship 

//pause here on end since we are getting close and need access to KSP information of this orbit for testing
kuniverse:pause.