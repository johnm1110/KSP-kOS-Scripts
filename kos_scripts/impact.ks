//
set impactTimeStamp to timestamp() + ship:orbit:NEXTPATCHETA + 100.

local shipPositionPatch is positionat(ship,impactTimeStamp).
local targetPositionPatch is positionat(ship:orbit:nextpatch:body,impactTimeStamp).
local shipPositionPatchRel is targetPositionPatch - shipPositionPatch.

set altitudeDelta to shipPositionPatchRel:mag - ship:orbit:nextpatch:body:radius.

until (altitudeDelta) < 0 { // check until the altitude is negative
    set impactTimeStamp to impactTimeStamp + 100.

    local shipPositionCheck is positionat(ship,impactTimeStamp).
    local targetPositionCheck is positionat(ship:orbit:nextpatch:body,impactTimeStamp).
    local shipPositionCheckRel is targetPositionCheck - shipPositionCheck.

    set altitudeDelta to shipPositionCheckRel:mag - ship:orbit:nextpatch:body:radius.
    //print altitudeDelta.
    //print impactTimeStamp.
}
// turn back time by 100 seconds and begin checking every 10 seconds
set impactTimeStamp to impactTimeStamp - 100. 
local shipPositionPatch is positionat(ship,impactTimeStamp).
local targetPositionPatch is positionat(ship:orbit:nextpatch:body,impactTimeStamp).
local shipPositionPatchRel is targetPositionPatch - shipPositionPatch.

set altitudeDelta to shipPositionPatchRel:mag - ship:orbit:nextpatch:body:radius.

until (altitudeDelta) < 0 { // check until the altitude is negative
    set impactTimeStamp to impactTimeStamp + 10.
    
    local shipPositionCheck is positionat(ship,impactTimeStamp).
    local targetPositionCheck is positionat(ship:orbit:nextpatch:body,impactTimeStamp).
    local shipPositionCheckRel is targetPositionCheck - shipPositionCheck.

    set altitudeDelta to shipPositionCheckRel:mag - ship:orbit:nextpatch:body:radius.
    //print altitudeDelta.
    //print impactTimeStamp.
}
// turn back time by 10 seconds and begin checking every 1 second
set impactTimeStamp to impactTimeStamp - 10. 
local shipPositionPatch is positionat(ship,impactTimeStamp).
local targetPositionPatch is positionat(ship:orbit:nextpatch:body,impactTimeStamp).
local shipPositionPatchRel is targetPositionPatch - shipPositionPatch.

set altitudeDelta to shipPositionPatchRel:mag - ship:orbit:nextpatch:body:radius.
until (altitudeDelta) < 0 { // check until the altitude is negative
    set impactTimeStamp to impactTimeStamp + 1.

    local shipPositionCheck is positionat(ship,impactTimeStamp).
    local targetPositionCheck is positionat(ship:orbit:nextpatch:body,impactTimeStamp).
    local shipPositionCheckRel is targetPositionCheck - shipPositionCheck.

    set altitudeDelta to shipPositionCheckRel:mag - ship:orbit:nextpatch:body:radius.
    //print altitudeDelta.
    //print impactTimeStamp.
}

local shipPositionPatch is positionat(ship,impactTimeStamp).
local targetPositionPatch is positionat(ship:orbit:nextpatch:body,impactTimeStamp).
local shipPositionPatchRel is targetPositionPatch - shipPositionPatch.
local spot is mun:geopositionof(shipPositionPatch).
set impactSite to waypoint("Site T3-P").

clearscreen.
local impactETA is impactTimeStamp - timestamp().
print "ETA to impact (s): " + impactETA.
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
