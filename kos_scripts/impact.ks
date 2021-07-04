//calculate velocity of ship 60 seconds past SOI patch point
// This example imagines you are on an orbit that is leaving
// the current body and on the way to transfer to another orbit:

// Later_time is 1 minute into the Mun orbit patch:
local patchETA is timestamp() + ship:orbit:NEXTPATCHETA + 60.
local shipVelocityPatch is VELOCITYAT(ship, patchETA):ORBIT.
local targetVelocityPatch is VELOCITYAT(ship:orbit:NEXTPATCH:body, patchETA):ORBIT.

// velocity of spacecraft relative to target
local shipVelocityPatchRel is shipVelocityPatch - targetVelocityPatch.

local shipPositionPatch is positionat(ship,patchETA).
local targetPositionPatch is positionat(ship:orbit:nextpatch:body,patchETA).
local shipPositionPatchRel is targetPositionPatch - shipPositionPatch.

// guess at an intial time, this will always be less due to gravity accelarting the spacecraft
//local timeInitial is shipPositionPatchRel:mag / shipVelocityPatchRel:mag.
// test if the position is within 1 meter of Mun's surface
set altitudeDelta to shipPositionPatchRel:mag - ship:orbit:nextpatch:body:radius.
local timeOffset is 0.
set impactETA to timestamp() + ship:orbit:NEXTPATCHETA.// + timeInitial + timeOffset.

until (altitudeDelta) < 1 {
    local shipPositionPatch is positionat(ship,impactETA).
    local targetPositionPatch is positionat(ship:orbit:nextpatch:body,impactETA).
    local shipPositionPatchRel is targetPositionPatch - shipPositionPatch.

    set altitudeDelta to shipPositionPatchRel:mag - ship:orbit:nextpatch:body:radius.
    //print altitudeDelta.
    local timeOffset is timeOffset + 10.    
    set impactETA to impactETA + timeOffset.
    //print impactETA.
}

local shipPositionPatch is positionat(ship,impactETA).
local targetPositionPatch is positionat(ship:orbit:nextpatch:body,impactETA).
local shipPositionPatchRel is targetPositionPatch - shipPositionPatch.
local spot is mun:geopositionof(shipPositionPatch).
set impactSite to waypoint("Site T3-P").

clearscreen.
local timeToImpact is ship:orbit:nextpatcheta + timeOffset.
print "ETA to impact (s): " + timeToImpact.
print "Alttiude (m)     : " + altitudeDelta.
print "Spot             : " + spot.
print "Impact target    : " + impactSite.
print "Location         : " + impactSite:geoposition.


//print "velocity relative to this body is: " + shipVelocityPatch:mag.
//print "velocity relative to the Mun is:   " + shipVelocityPatchRel:mag.
//print "Distance to Mun at patch point     " + shipPositionPatchRel:mag.
//print "Loose time to Mun                  " + timeToImpact.
//print "Distance to Mun at guess point     " + shipPositionPatchRel:mag.
//print "Loose time to Mun                  " + timeToImpact.

// calculate poistion of ship 60 seconds past SOI patch point
// calculate position of ship 
