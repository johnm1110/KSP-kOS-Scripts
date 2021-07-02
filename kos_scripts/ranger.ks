// Set the ship to a known configuration
sas off.
rcs off.
lights off.
lock throttle to 0. 						// Throttle is a decimal from 0.0 to 1.0
gear off.
set ship:control:pilotmainthrottle to 0.	// set throttle to zero when exiting program
AG1 off.


// intial pitch over maneuver
set pitchOverVelocity to 50.				// velocity for intial pitch over

// gravity turn pitch settings (deg/s), twr and dPitch are inverse proportions
set dPitchStage3 to 0.20.
set dPitchStage2 to 0.975.
set dPitchStage1 to 0.82.

// Engine ISP, set manually until I can extract it in the script
set stage3Isp to 330.
set stage2Isp to 320.
set stage1Isp to 280.
		
// set up engine parameters
set twrUpperAtmo to 0.8.
set twrMidAtmo to 1.0.
set twrLowerAtmo to 1.4.

// intial throttle and steering
set throttleLimit to 0.
set steeringPitch to 90.	// start pointing up
set steeringDir to 90.		// head east
set steeringRoll to 0.	// start so the booster doesn't hit the launch tower, we'll roll later

// Set these variables before the flight begins
set targetApoapsis to  100000. 	// Target apoapsis in meters
set targetPeriapsis to 100000. 	// Target periapsis in meters
set errorAp to 0.980.			// allowable deviation from desired apoapsis
set inclinationFinal to 0.

// Target variables
set targetObject to BODY("Mun").
set inclinationTarget to 0.0.
set apoapsisTarget to  250000. 	// Target apoapsis in meters
set periapsisTarget to 55000. 	// Target periapsis in meters
set radiusTMI to 11500000.  // document this

// impact site
//set landingSite to WAYPOINT("East Crater Anomaly").

set program to 2.	// no launch window

// set mission parameters
set mission to 1.	// mission 0 is orbit the current body, 1 is escape burn for Mun or Minmus flyby

set SHIP:SHIPNAME to "Ranger 1".

// load functions
run launch_window. 
run functions.

// Set some variables
set currentStage to 0.
set targetRoll to 180.
set orbitInsertionAlt to 70000.

// set up steering and throttle
lock throttle to throttleLimit.
lock steering to heading(steeringDir,steeringPitch,steeringRoll).

// if we are launching to intercept, set a target
//set targetObject to VESSEL("Agena").
//set targetObject to BODY("Mun").

// Variables for selected craft (move to functions)
lock Fg to ship:mass * body:mu /((ship:altitude + body:radius)^2).
lock currentTWR to SHIP:AVAILABLETHRUST / Fg.
// Set some variables

clearscreen.

// activate antenna and solar panels when free of atmosphere 
when ship:altitude > 75000 then { // fairings
    AG1 on.
}
when ship:altitude > 80000 then { // antenna and solar panels
    AG2 on.
}

// Launch program
until program = 0 {
    if program = 1 { 
        set launch to launchWindow(targetObject).
        if launch = 0 {	
            print "Target is moving at the same velocity as the ship, rendezvous calculation is not possible".
            print "Launching in one minute".
            wait 60.
            clearscreen.
            set program to 2.
        }
        if launch = 1 { 
            clearscreen.
            set program to 2.
        }
    }
    
    if program = 2 {
        lock steering to heading(steeringDir,steeringPitch,steeringRoll).
        set countdown to 10.
        print "Counting down:".
        until countdown = 5 {
            print "..." + countdown.
            set countdown to countdown - 1.
            wait 1.
        }.
        print "Main throttle up. Two seconds to stabilize it.".
        set throttleLimit to twrLowerAtmo / twrStage1.
        wait 1.
        print "...4".
        wait 1.
        print "...3".
        print "Engine sequence start.".	
        stage.  // ignite engine 
        //set totalDeltaV to totalDeltaV + stageDeltaV.  // TODO: make this a for list to run throgh stages
        wait 1.
        print "...1".
        wait 1.
        print "Liftoff at " + time:clock + " UT!".
        set launchTime to time.
        stage.					// release docking clamps 
        set currentStage to 1.
        wait until ship:VERTICALSPEED > pitchOverVelocity.
        print "Begining pitch and roll program.".
        set program to 3.
    }	

    if program = 3 {
        if currentStage = 1 {
            until SHIP:MAXTHRUST < 0.001 {
                wait 0.1.
                if(steeringPitch>5){ set steeringPitch to steeringPitch - dPitchStage1 * 0.1. }
                //if(steeringRoll<360){ set steeringRoll to steeringRoll + 0.5. } // roll to 0 degrees at 5 degrees per second
            }
            print "Stage " + currentStage + " seperation at: " + time:clock + " UT!".
            set throttleLimit to 0.
            wait 0.2.
            stage.
            kuniverse:pause.	// this allows me to record the data just at staging
            wait 0.5.
            set throttleLimit to twrMidAtmo / twrStage2.
            set steeringRoll to 0.
            set currentStage to 2. // TODO: launcher files need to tell how many stages
        }
        if currentStage = 2 {
            set ve to stage2Isp * 9.81. // convert specific impulse to exhaust velocity
            until ship:apoapsis > (targetApoapsis * errorAp) {
                wait 0.1.
                if(steeringPitch>2){ set steeringPitch to steeringPitch - dPitchStage2 * 0.1. }
                if SHIP:MAXTHRUST < 0.001 {
                    print "Stage " + currentStage + " seperation at: " + time:clock + " UT!".
                    set throttleLimit to 0.
                    wait 0.2.
                    stage.
                    kuniverse:pause.	// this allows me to record the data just at staging
                    wait 0.5.
                    set throttleLimit to twrUpperAtmo / twrStage3.
                    set currentStage to 3.			// TODO: launcher files need to tell how many stages
                }
            }
        }
        if currentStage = 3 {
            set ve to stage3Isp * 9.81. // convert specific impulse to exhaust velocity
            until ship:apoapsis > (targetApoapsis * errorAp) {
                wait 0.1.
                //if eta:apoapsis < 30 and steeringPitch > -2 { set steeringPitch to steeringPitch - dPitchStage3 * 0.1. }
                //if eta:apoapsis > 30 and steeringPitch < 2 { set steeringPitch to steeringPitch + dPitchStage3 * 0.1. }
                    if(steeringPitch > 2){ set steeringPitch to steeringPitch - dPitchStage3 * 0.1. }
            }
        }
        set throttleLimit to 0.
        wait 0.1.
        kuniverse:pause.	// this allows me to record the data just at staging
        set program to 5.
    }

    if program = 4 { // clear second stage for overpowered tests
        rcs on.
        if currentStage = 2 {
            print "Stage " + currentStage + " seperation at: " + time:clock + " UT!".
            set throttleLimit to 0.
            wait 0.2.
            stage.
            wait 0.5.
            set throttleLimit to 1.
            set currentStage to 3.			// TODO: launcher files need to tell how many stages
        }
        set program to 5.
    }

    if program = 5 { // increase periapsis and correct inclination, this doesn't work when inclination is not zero
        // the burn will rotate around the line of apsides and only change the LAN
        clearscreen.
        //set ve to stage2Isp * 9.81. // convert specific impulse to exhaust velocity
        lock STEERING to SHIP:PROGRADE.
        //SET steeringDir TO VANG(SHIP:PROGRADE:VECTOR, SHIP:UP:VECTOR). // point prograde
        set shipPitch TO 0.
        // calculate the time of the circulization burn; burning too far past apoapsis will raise it
        
        RCS on.
        //SET steeringDir TO VANG(SHIP:RETROGRADE:VECTOR, SHIP:UP:VECTOR). // point retrograde
        
        //wait 60.  // let any steering changes settle, probably don't need this if we start well before the burn

        set rAp to SHIP:APOAPSIS + BODY:RADIUS.
        set rPe to targetPeriapsis + BODY:RADIUS.
        //set dInclination to inclinationFinal - SHIP:ORBIT:INCLINATION.
        
        set dVHohmann to deltaV(rAp,rPe).
        //set dVCombined to combinedPlaneChange(rAp,rPe,dInclination).	
            
        //set shipPitch to ARCCOS(dVHohmann / dVCombined).
        //local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVCombined / Ve))) / SHIP:AVAILABLETHRUST.  
        local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVHohmann / Ve))) / SHIP:AVAILABLETHRUST.  

        lock timeUntilBurn to ETA:APOAPSIS - burnTime / 2.
        
        until timeUntilBurn < 0 {
            //set steeringDir TO VANG(SHIP:RETROGRADE:VECTOR, SHIP:UP:VECTOR). // point retrograde
            //lock STEERING to SHIP:PROGRADE + R(-shipPitch,0,0).  // TODO: find out why I need to make this negative
            lock STEERING to SHIP:PROGRADE.
            // necasue the burn was so long the steering turned, do I need to prevent this? TODO: test
            //lock steering to steeringDir. // will the retrograde vector change?
            print "Waiting for orbital insertion burn (program 5)" at (0,0).
            print "Burn delta v (m/s)                : " + dVHohmann + "          " at (0,3).
            //print "Inclination change (degs)         : " + dInclination + "          " at (0,4).
            //print "Ship pitch (degs)                 : " + shipPitch + "          " at (0,5).
            //print "Total delta V required (m/s)      : " + round(dVCombined,2) + "          " at (0,6).
            print "Total time of burn (s)            : " + round(burnTime,2) + "          " at (0,7).
            print "Burn ETA (s)                      : " + round(timeUntilBurn,2) + "     " at (0,8).
            wait 0.001.
        }
        set t0 to TIME:SECONDS.
        
        //orbital insertion burn
        until (TIME:SECONDS - t0) > burnTime {
            set throttleLimit to 1.
            if SHIP:MAXTHRUST < 0.001 {
                print "Stage " + currentStage + " seperation at: " + time:clock + " UT!".
                set throttleLimit to 0.
                wait 0.1.
                stage.
                wait 0.1.
                set throttleLimit to 1.
                set currentStage to 3.			// TODO: launcher files need to tell how many stages
            }
        }
        set throttleLimit to 0.
        wait 0.1.
        kuniverse:pause.	// this allows me to record the data just at staging
        if mission=0 set program to 0.
        if mission>0 set program to 11.
    }
    
    if program = 6 { // for now we need a final inclination burn, fix this
        // this is a simple function, the burn at a 90 degree angle will change other orbital parameters

        //lock STEERING to VCRS(ship:velocity:orbit,-body:position). // steer to normal vector
        //wait 30. // wait for steering to settle since the burn begins ASAP
        
        local dInclination to inclinationFinal - SHIP:ORBIT:INCLINATION.
        local dVsimple is 2 * SHIP:VELOCITY:ORBIT:MAG * SIN(dInclination/2).
        if dVsimple < 0 local dVsimple is dVsimple * -1. // this needs to be positive for burntime calculations
        local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVsimple / Ve))) / SHIP:AVAILABLETHRUST.  
        //set timeUntilBurn to -1. // burn ASAP for now
        
        // calculate ascending and descending nodes
        local AN is 360 - SHIP:ORBIT:ARGUMENTOFPERIAPSIS.
        local DN is AN - 180.
        if DN < 0 local DN is DN + 360.
        
        set timeUntilBurn to 1. // intial value to enter loop, this feels like a hack
        until timeUntilBurn < 0 {		
            // calculate time until nodes
            // convert everything to radians
            local theta is SHIP:ORBIT:TRUEANOMALY * CONSTANT:DEGTORAD.
            local ANRad is AN * CONSTANT:DEGTORAD.
            local DNRad is DN * CONSTANT:DEGTORAD.
            
            local EInitial is arccos (( SHIP:ORBIT:ECCENTRICITY + cos (theta)) / ( 1 + SHIP:ORBIT:ECCENTRICITY *  cos (theta) )).
            local MInitial is EInitial - SHIP:ORBIT:ECCENTRICITY * sin (EInitial).
            local n is SQRT ( BODY:MU / SHIP:ORBIT:SEMIMAJORAXIS ^ 3).
                    
            local EAN is arccos (( SHIP:ORBIT:ECCENTRICITY + cos (ANRad)) / ( 1 + SHIP:ORBIT:ECCENTRICITY *  cos (ANRad) )).
            local MAN is EAN - SHIP:ORBIT:ECCENTRICITY * sin (EAN).
            
            local EDN is arccos (( SHIP:ORBIT:ECCENTRICITY + cos (DNRad)) / ( 1 + SHIP:ORBIT:ECCENTRICITY *  cos (DNRad) )).
            local MDN is EDN - SHIP:ORBIT:ECCENTRICITY * sin (EDN).
            
            local timeUntilAN is 0 + ( MAN - MInitial ) / n.
            local timeUntilDN is 0 + ( MDN - MInitial ) / n.

            if timeUntilAN < timeUntilDN { set timeUntilBurn to timeUntilAN.}
                else { set timeUntilBurn to timeUntilDN.}
        
            //set steeringDir TO VANG(SHIP:RETROGRADE:VECTOR, SHIP:UP:VECTOR). // point retrograde
            lock STEERING to -1 * VCRS(ship:velocity:orbit,-body:position). // steer to normal vector, negating is a hack, determine from telemetry
            //set steeringDir to SHIP:RETROGRADE.
            //lock steering to steeringDir. // will the retrograde vector change?
            print "Waiting for inclination burn (program 6)" at (0,0).
            print "Simple delta v (m/s)              : " + dVsimple + "          " at (0,3).
            print "Inclination change (degs)         : " + dInclination + "          " at (0,4).
            //print "Ship pitch (degs)                 : " + shipPitch + "          " at (0,5).
            //print "Total delta V required (m/s)      : " + round(dVCombined,2) + "          " at (0,6).
            print "Total time of burn (s)            : " + round(burnTime,2) + "          " at (0,7).
            print "Burn ETA (s)                      : " + round(timeUntilBurn,2) + "     " at (0,8).
            wait 0.001.
        }
        set t0 to TIME:SECONDS.
        
        //orbital insertion burn
        until (TIME:SECONDS - t0) > burnTime {
                set throttleLimit to 1.
        }
        set throttleLimit to 0.
        set program to 7.
    }
    
    if program = 7 { // fine tune periapsis
        // the burn will rotate around the line of apsides and only change the LAN
        lock STEERING to SHIP:PROGRADE.
        //SET steeringDir TO VANG(SHIP:PROGRADE:VECTOR, SHIP:UP:VECTOR). // point prograde
        set shipPitch TO 0.
        // calculate the time of the circulization burn; burning too far past apoapsis will raise it
        
        RCS on.
        //SET steeringDir TO VANG(SHIP:RETROGRADE:VECTOR, SHIP:UP:VECTOR). // point retrograde
        
        //wait 60.  // let any steering changes settle, probably don't need this if we start well before the burn

        //set rAp to targetApoapsis + BODY:RADIUS.
        set rAp to SHIP:APOAPSIS + BODY:RADIUS.
        //set rPe to SHIP:PERIAPSIS + BODY:RADIUS.
        set rPe to targetPeriapsis + BODY:RADIUS.

        set dVHohmann to deltaV(rAp,rPe).
            
        local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVHohmann / Ve))) / SHIP:AVAILABLETHRUST.  

        lock timeUntilBurn to ETA:APOAPSIS - burnTime / 2.
        
        until timeUntilBurn < 0 {
            //set steeringDir TO VANG(SHIP:RETROGRADE:VECTOR, SHIP:UP:VECTOR). // point retrograde
            //lock STEERING to SHIP:PROGRADE + R(-shipPitch,0,0).  // TODO: find out why I need to make this negative
            lock STEERING to SHIP:PROGRADE.
            // necasue the burn was so long the steering turned, do I need to prevent this? TODO: test
            //lock steering to steeringDir. // will the retrograde vector change?
            print "Waiting for orbital insertion burn (program 7)                " at (0,0).
            print "Delta v (m/s)                     : " + dVHohmann + "          " at (0,3).
            print "Total time of burn (s)            : " + round(burnTime,2) + "          " at (0,7).
            print "Burn ETA (s)                      : " + round(timeUntilBurn,2) + "     " at (0,8).
            wait 0.001.
        }
        set t0 to TIME:SECONDS.
        
        set throttleLimit to 0.
        if mission=0 set program to 8.
        if mission>0 set program to 7.
    }	
    
    if program = 8 { // fine tune periapsis
        // the burn will rotate around the line of apsides and only change the LAN
        lock STEERING to SHIP:RETROGRADE.
        //SET steeringDir TO VANG(SHIP:PROGRADE:VECTOR, SHIP:UP:VECTOR). // point prograde
        set shipPitch TO 0.
        // calculate the time of the circulization burn; burning too far past apoapsis will raise it
        
        RCS on.
        //SET steeringDir TO VANG(SHIP:RETROGRADE:VECTOR, SHIP:UP:VECTOR). // point retrograde
        
        //wait 60.  // let any steering changes settle, probably don't need this if we start well before the burn

        //set rAp to targetApoapsis + BODY:RADIUS.
        set rAp to SHIP:APOAPSIS + BODY:RADIUS.
        set rPe to targetPeriapsis + BODY:RADIUS.
        //set rPe to SHIP:PERIAPSIS + BODY:RADIUS.

        
        set dVHohmann to deltaV(rAp,rPe).
            
        local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVHohmann / Ve))) / SHIP:AVAILABLETHRUST.  

        //lock timeUntilBurn to ETA:APOAPSIS - burnTime / 2.
        lock timeUntilBurn to ETA:PERIAPSIS - burnTime / 2.

        until timeUntilBurn < 0 {
            //set steeringDir TO VANG(SHIP:RETROGRADE:VECTOR, SHIP:UP:VECTOR). // point retrograde
            //lock STEERING to SHIP:PROGRADE + R(-shipPitch,0,0).  // TODO: find out why I need to make this negative
            lock STEERING to SHIP:RETROGRADE.
            // necasue the burn was so long the steering turned, do I need to prevent this? TODO: test
            //lock steering to steeringDir. // will the retrograde vector change?
            print "Waiting for orbital insertion burn (program 7)                " at (0,0).
            print "Delta v (m/s)                     : " + dVHohmann + "          " at (0,3).
            print "Total time of burn (s)            : " + round(burnTime,2) + "          " at (0,7).
            print "Burn ETA (s)                      : " + round(timeUntilBurn,2) + "     " at (0,8).
            wait 0.001.
        }
        set t0 to TIME:SECONDS.
        
        set throttleLimit to 0.
        if mission=0 set program to 0.
        if mission>0 set program to 0.
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

    if program = 32 { // Decent Orbit Injection (DOI) 180 degrees from powered descent initiation (PDI) position
        // this whole routine needs to be better, it needs to be converted into orbital parameters
        clearscreen.
        RCS off.
        lock STEERING TO LOOKDIRUP( SHIP:PROGRADE:VECTOR, SUN:POSITION ). // + R(0,0,-45).
        // Descent Orbit Insertion (DOI) algorithm
        // choose desired landing zone and convert it to BODY relative position
        set LZD to WAYPOINT("East Crater Anomaly").
        set LZDPos to LZD:POSITION - SHIP:BODY:POSITION.
        // get ship position vector and convert it to BODY relative position
        lock ShipPos to -SHIP:BODY:POSITION.
        // set Powered Descent Initiation (PDI) burn longitude and convert it to BODY relative position
        // for now we assume a latitude the same as the landing zone
        set mPerDegSurface to 2 * CONSTANT:pi * BODY:RADIUS / 360. // equatorial distance per degree (m)
        // TODO: take into account that the m per degree will change with latitude
        // check for orbit direction, this determines whether we add or subtract the longitude offset
        // if the inclination is less then 90 degrees we are prograde and subtract to move PDI west
        // otherwise we are retrograde and add to move PDI east
        if SHIP:ORBIT:INCLINATION < 90 { set PDILng to LZD:GEOPOSITION:LNG - downRangeDistance / mPerDegSurface. }
            else { set PDILng to LZD:GEOPOSITION:LNG + downRangeDistance / mPerDegSurface. }
        set PDIGeo to LATLNG(LZD:GEOPOSITION:LAT,PDILng).
        set PDIPos to PDIGeo:POSITION - SHIP:BODY:POSITION.
        // test position of PDI to determine DOI, this is to keep the DOI between -180 and 180 degrees
        if PDILng < 0 { set DOILng to PDILng + 180. }
            else { set DOILng to PDILng - 180. }
        if DOILng < 0 { set phiDOI to 360 + DOILng. } // put DOI in 360 degree range for time calculation
        // again we assume ship latitude for now TODO: find a better way
        lock DOIGeo to LATLNG(SHIP:GEOPOSITION:LAT,DOILng).
        set DOIPos to DOIGeo:POSITION - SHIP:BODY:POSITION.
        // calculate distance (in degrees) to DOI, relative mean angular motion, and wait time
        set nShip to 360 / SHIP:ORBIT:PERIOD.
        set nDOI to 360 / BODY:ROTATIONPERIOD. 
        set waitTime to VANG(DOIPos,ShipPos) / (nShip - nDOI).
        // waitTime is off, either the relative velocities are wrong or the Y difference is too large
        // i think the time differece is because of the 3D vectors I am not considering, so the angle is wrong?
        // in other words the angle will never go to 0; when the ship passes the 0 point it is north or south of it
        set proc to 0. // 0 stay in loop, 1 go for DOI
        set t0 to TIME:SECONDS.
        // TODO: what happens if lngDPI is negative
        //if lngBurn > 180 { set lngBurn to 180 - lngBurn. }
        until proc = 1 { // this will trigger twice, TODO: test for that
            on AG10 { set proc to 1. } // on action group 10 (zero key) we are go for DOI
            set phi to VANG(DOIPos,ShipPos).
            if SHIP:GEOPOSITION:LNG > 0 { set phi to phiDOI - SHIP:GEOPOSITION:LNG. }
                else { set phi to DOILng - SHIP:GEOPOSITION:LNG. }
            set check to VCRS(ShipPos,DOIPos).
            if check:Y > 0 { set phi to 360 - phi. } // if positive we are moving away
            set waitTime to phi / (nShip - nDOI).
            //set waitTime to (phiDOI - SHIP:GEOPOSITION:LNG) / (nShip - nDOI).
            //set check to DOIPos * ShipPos.
            print "Waiting for proceed for DOI burn (P11); go for burn on action group 10." at (0,0).
            print "Landing Zone        : " + LZD + "         " at (0,1).
            print "PDI longitude (deg) : " + ROUND(PDILng,2) + "       " at (0,2).
            print "DOI longitude (deg) : " + ROUND(DOILng,2) + "       " at (0,3).
            print "Ship longitude (deg): " + ROUND(SHIP:GEOPOSITION:LNG,2) + "      " at (0,4).
            print "Angle to DOI (deg)  : " + ROUND(phi,2) + "          " at (0,5).
            print "Wait Time (s)       : " + ROUND(waitTime,2) + "          " at (0,6).
        }
        set rA to SHIP:ALTITUDE + BODY:RADIUS.
        set rB to radiusPDI + BODY:RADIUS.
        
        set dVHohmann to ABS(deltaV(rA,rB)).  // order matters, first radius is the burn position
        // change this away from ABS, sign determines prograde vs retrograde
        set Ve to stage3ISP * 9.81. // convert specific impulse to exhaust velocity
        
        local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVHohmann / Ve))) / SHIP:AVAILABLETHRUST.  

        set timeUntilBurn to waitTime - burnTime / 2.
        
        clearscreen.
        lock STEERING TO SHIP:RETROGRADE.
        until waitTime <  burnTime * 2 { 
            set phi to VANG(DOIPos,ShipPos).
            if SHIP:GEOPOSITION:LNG > 0 { set phi to phiDOI - SHIP:GEOPOSITION:LNG. }
                else { set phi to DOILng - SHIP:GEOPOSITION:LNG. }
            //set check to VCRS(ShipPos,DOIPos).
            //if check:Y > 0 { set phi to 360 - phi. } // if positive we are moving away
            set waitTime to phi / (nShip - nDOI).
            //set waitTime to (phiDOI - SHIP:GEOPOSITION:LNG) / (nShip - nDOI).
            //set check to DOIPos * ShipPos.
            print "Waiting for DOI burn (P11)" at (0,0).
            print "Landing Zone        : " + LZD + "         " at (0,1).
            print "PDI longitude (deg) : " + ROUND(PDILng,2) + "       " at (0,2).
            print "DOI longitude (deg) : " + ROUND(DOILng,2) + "       " at (0,3).
            print "Ship longitude (deg): " + ROUND(SHIP:GEOPOSITION:LNG,2) + "      " at (0,4).
            print "Angle to DOI (deg)  : " + ROUND(phi,2) + "          " at (0,5).
            print "Time until burn (s) : " + ROUND(waitTime,2) + "          " at (0,6).
            print "Est. Delta V (m/s)  : " + ROUND(dVHohmann,2) + "            " at (0,7).
            print "Est. burn time (s)  : " + ROUND(burnTime,2) + "         " at (0,8).
        }

        set rA to SHIP:ALTITUDE + BODY:RADIUS.
        set rB to radiusPDI + BODY:RADIUS.
        
        set dVHohmann to ABS(deltaV(rA,rB)).  // order matters, first radius is the burn position
        // change this away from ABS, sign determines prograde vs retrograde
        set Ve to stage3ISP * 9.81. // convert specific impulse to exhaust velocity
        
        local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVHohmann / Ve))) / SHIP:AVAILABLETHRUST.
        
        clearscreen.
        until waitTime <  burnTime / 2 { 
            set phi to VANG(DOIPos,ShipPos).
            if SHIP:GEOPOSITION:LNG > 0 { set phi to phiDOI - SHIP:GEOPOSITION:LNG. }
                else { set phi to DOILng - SHIP:GEOPOSITION:LNG. }
            set waitTime to phi / (nShip - nDOI).
            //set waitTime to (phiDOI - SHIP:GEOPOSITION:LNG) / (nShip - nDOI).
            //set check to DOIPos * ShipPos.
            print "DOI burn final approach (P11)" at (0,0).
            print "Landing Zone        : " + LZD + "         " at (0,1).
            print "PDI longitude (deg) : " + ROUND(PDILng,2) + "       " at (0,2).
            print "DOI longitude (deg) : " + ROUND(DOILng,2) + "       " at (0,3).
            print "Ship longitude (deg): " + ROUND(SHIP:GEOPOSITION:LNG,2) + "      " at (0,4).
            print "Angle to DOI (deg)  : " + ROUND(phi,2) + "          " at (0,5).
            print "Time until burn (s) : " + ROUND(waitTime,2) + "          " at (0,6).
            print "Delta V (m/s)       : " + ROUND(dVHohmann,2) + "            " at (0,7).
            print "Burn time (s)       : " + ROUND(burnTime,2) + "         " at (0,8).
        }
        
        set t0 to TIME:SECONDS.
        
        // DOI burn
        until (TIME:SECONDS - t0) > burnTime {
                set throttleLimit to 1.
        }
        set throttleLimit to 0.
        set program to 12. // for now until go/no go decision for landing
    }

    if program = 33 { // inclination change 
        // this whole routine needs to be better, it needs to be converted into orbital parameters
            clearscreen.
        RCS off.
        // set inclination differnece
        set theta to landingSite:GEOPOSITION:LAT - SHIP:ORBIT:INCLINATION.
        // check dtermine which way we need to burn
        if theta > 0 { 	lock STEERING to normalSteeringVector. }
            else { 	lock STEERING to -normalSteeringVector. }
        // Descent Orbit Insertion (DOI) algorithm
        // choose desired landing zone and convert it to BODY relative position
        set LZD to WAYPOINT("East Crater Anomaly").
        set LZDPos to LZD:POSITION - SHIP:BODY:POSITION.
        // get ship position vector and convert it to BODY relative position
        lock ShipPos to -SHIP:BODY:POSITION.
        // set Powered Descent Initiation (PDI) burn longitude and convert it to BODY relative position
        // for now we assume a latitude the same as the landing zone
        set mPerDegSurface to 2 * CONSTANT:pi * BODY:RADIUS / 360. // equatorial distance per degree (m)
        // TODO: take into account that the m per degree will change with latitude
        // check for orbit direction, this determines whether we add or subtract the longitude offset
        // if the inclination is less then 90 degrees we are prograde and subtract to move PDI west
        // otherwise we are retrograde and add to move PDI east
        if SHIP:ORBIT:INCLINATION < 90 { set PDILng to LZD:GEOPOSITION:LNG - downRangeDistance / mPerDegSurface. }
            else { set PDILng to LZD:GEOPOSITION:LNG + downRangeDistance / mPerDegSurface. }
        set PDIGeo to LATLNG(LZD:GEOPOSITION:LAT,PDILng).
        set PDIPos to PDIGeo:POSITION - SHIP:BODY:POSITION.
        // test position of PDI to determine DOI, this is to keep the DOI between -180 and 180 degrees
        if PDILng < 0 { set incLng to PDILng + 90. }
            else { set incLng to PDILng - 90. }
        if incLng < 0 { set phiInc to 360 + incLng. } // put DOI in 360 degree range for time calculation
        // again we assume ship latitude for now TODO: find a better way
        lock incGeo to LATLNG(SHIP:GEOPOSITION:LAT,incLng).
        set incPos to incGeo:POSITION - SHIP:BODY:POSITION.
        // calculate distance (in degrees) to DOI, relative mean angular motion, and wait time
        set nShip to 360 / SHIP:ORBIT:PERIOD.
        set nMun to 360 / BODY:ROTATIONPERIOD. 
        set waitTime to VANG(incPos,ShipPos) / (nShip - nMun).
        // waitTime is off, either the relative velocities are wrong or the Y difference is too large
        // i think the time differece is because of the 3D vectors I am not considering, so the angle is wrong?
        // in other words the angle will never go to 0; when the ship passes the 0 point it is north or south of it
        set proc to 0. // 0 stay in loop, 1 go for DOI
        set t0 to TIME:SECONDS.
        // TODO: what happens if lngDPI is negative
        //if lngBurn > 180 { set lngBurn to 180 - lngBurn. }
        until proc = 1 { // this will trigger twice, TODO: test for that
            on AG10 { set proc to 1. } // on action group 10 (zero key) we are go for DOI
            set phi to VANG(incPos,ShipPos).
            set phi to incLng - SHIP:GEOPOSITION:LNG.
            set waitTime to phi / (nShip - nMun).
            //set waitTime to (phiDOI - SHIP:GEOPOSITION:LNG) / (nShip - nMun).
            //set check to DOIPos * ShipPos.
            print "Waiting for proceed for inclination change (P12); go for burn on action group 10." at (0,0).
            print "Landing Zone             : " + landingSite + "         " at (0,1).
            print "INC longitude (deg)      : " + ROUND(incLng,2) + "       " at (0,2).
            print "Angle to INC (deg)       : " + ROUND(phi,2) + "          " at (0,3).
            print "Wait Time (s)            : " + ROUND(waitTime,2) + "          " at (0,4).
            print "Inclination Change (deg) : " + ROUND(theta,2) + "     " at (0,5).
        }
        
        set dVPlane to simplePlaneChange((SHIP:ALTITUDE + BODY:RADIUS),theta).
        set Ve to stage3ISP * 9.81. // convert specific impulse to exhaust velocity
            
        local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVPlane / Ve))) / ( SHIP:AVAILABLETHRUST / 10).
        
        clearscreen.
        until waitTime <  burnTime * 2 { 
            set phi to VANG(PDIPos,ShipPos).
            set phi to incLng - SHIP:GEOPOSITION:LNG.
            set waitTime to phi / (nShip - nMun).
            //set waitTime to (phiDOI - SHIP:GEOPOSITION:LNG) / (nShip - nMun).
            //set check to DOIPos * ShipPos.
            print "Waiting for Inc (P12)" at (0,0).
            print "Landing Zone             : " + landingSite + "         " at (0,1).
            print "Inc longitude (deg)      : " + ROUND(incLng,2) + "       " at (0,2).
            print "Angle to Inc (deg)       : " + ROUND(phi,2) + "          " at (0,3).
            print "Time until burn (s)      : " + ROUND(waitTime,2) + "          " at (0,4).
            print "Inclination Change (deg) : " + ROUND(theta,2) + "     " at (0,5).
            print "Est. Delta V (m/s)       : " + ROUND(dVPlane,2) + "            " at (0,6).
            print "Est. burn time (s)       : " + ROUND(burnTime,2) + " " at (0,7).
        }
        clearscreen.
        
        set dVPlane to simplePlaneChange((SHIP:ALTITUDE + BODY:RADIUS),theta).
        set Ve to stage3ISP * 9.81. // convert specific impulse to exhaust velocity
            
        local burnTime is (SHIP:MASS * Ve * (1 - CONSTANT:e ^ (-dVPlane / Ve))) / (SHIP:AVAILABLETHRUST / 10).
        
        until waitTime <  burnTime / 2 { 
            //set phi to VANG(DOIPos,ShipPos).
            set phi to incLng - SHIP:GEOPOSITION:LNG.
            set waitTime to phi / (nShip - nMun).
            //set waitTime to (phiDOI - SHIP:GEOPOSITION:LNG) / (nShip - nMun).
            //set check to DOIPos * ShipPos.
            print "Waiting for inclination change burn (P12)" at (0,0).
            print "Landing Zone             : " + LZD + "         " at (0,1).
            print "Inc longitude (deg)      : " + ROUND(incLng,2) + "       " at (0,2).
            print "Angle to Inc (deg)       : " + ROUND(phi,2) + "          " at (0,3).
            print "Time until burn (s)      : " + ROUND(waitTime,2) + "          " at (0,4).
            print "Inclination Change (deg) : " + ROUND(theta,2) + "     " at (0,5).
            print "Delta V (m/s)            : " + ROUND(dVPlane,2) + "            " at (0,6).
            print "Est. burn time (s)       : " + ROUND(burnTime,2) + " " at (0,7).
        }
        
        set t0 to TIME:SECONDS.
        
        // inc burn
        until (TIME:SECONDS - t0) > burnTime {
                set throttleLimit to 1 / 10.
        }
        set throttleLimit to 0.
        
        set landingZoneTerrainHeight to 4500. // this is based on in game data, trying to avoid data I should not know
        set program to 13. // for now until go/no go decision for landing
    }

    if program = 34 { // powered descent initiation (PDI)
        // this whole routine needs to be better, it needs to be converted into orbital parameters
        clearscreen.
        RCS off.
        GEAR ON.
        lock STEERING TO SHIP:RETROGRADE.
        // Descent Orbit Insertion (DOI) algorithm
        // choose desired landing zone and convert it to BODY relative position
        set LZD to WAYPOINT("East Crater Anomaly").
        set LZDPos to LZD:POSITION - SHIP:BODY:POSITION.
        // get ship position vector and convert it to BODY relative position
        lock ShipPos to -SHIP:BODY:POSITION.
        // set Powered Descent Initiation (PDI) burn longitude and convert it to BODY relative position
        // for now we assume a latitude the same as the landing zone
        set mPerDegSurface to 2 * CONSTANT:pi * BODY:RADIUS / 360. // equatorial distance per degree (m)
        // TODO: take into account that the m per degree will change with latitude
        // check for orbit direction, this determines whether we add or subtract the longitude offset
        // if the inclination is less then 90 degrees we are prograde and subtract to move PDI west
        // otherwise we are retrograde and add to move PDI east
        if SHIP:ORBIT:INCLINATION < 90 { set PDILng to LZD:GEOPOSITION:LNG - downRangeDistance / mPerDegSurface. }
            else { set PDILng to LZD:GEOPOSITION:LNG + downRangeDistance / mPerDegSurface. }
        set PDIGeo to LATLNG(LZD:GEOPOSITION:LAT,PDILng).
        set PDIPos to PDIGeo:POSITION - SHIP:BODY:POSITION.
        // test position of PDI to determine DOI, this is to keep the DOI between -180 and 180 degrees
        set nShip to 360 / SHIP:ORBIT:PERIOD.
        set nMun to 360 / BODY:ROTATIONPERIOD. 
        set waitTime to VANG(PDIPos,ShipPos) / (nShip - nMun).
        // waitTime is off, either the relative velocities are wrong or the Y difference is too large
        // i think the time differece is because of the 3D vectors I am not considering, so the angle is wrong?
        // in other words the angle will never go to 0; when the ship passes the 0 point it is north or south of it
        set proc to 0. // 0 stay in loop, 1 go for DOI
        set t0 to TIME:SECONDS.
        // TODO: what happens if lngDPI is negative
        //if lngBurn > 180 { set lngBurn to 180 - lngBurn. }
        //until proc = 1 { // this will trigger twice, TODO: test for that
            //on AG10 { set proc to 1. } // on action group 10 (zero key) we are go for DOI
            //set phi to VANG(PDIPos,ShipPos).
            //set phi to PDILng - SHIP:GEOPOSITION:LNG.
            //set waitTime to phi / (nShip - nMun).
            //set waitTime to (phiDOI - SHIP:GEOPOSITION:LNG) / (nShip - nMun).
            //set check to DOIPos * ShipPos.
            //print "Waiting for go/no go for PDI (P13); go for burn on action group 10." at (0,0).
            //print "Landing Zone        : " + LZD + "         " at (0,1).
            //print "PDI longitude (deg) : " + ROUND(PDILng,2) + "       " at (0,2).
            //print "Angle to PDI (deg)  : " + ROUND(phi,2) + "          " at (0,3).
            //print "Wait Time (s)       : " + ROUND(waitTime,2) + "          " at (0,4).
        //}
        
        clearscreen.
        until waitTime < 1 { 
            set phi to VANG(PDIPos,ShipPos).
            set phi to PDILng - SHIP:GEOPOSITION:LNG.
            set waitTime to phi / (nShip - nMun).
            //set waitTime to (phiDOI - SHIP:GEOPOSITION:LNG) / (nShip - nMun).
            //set check to PDIPos * ShipPos.
            print "Waiting for PDI (P13)" at (0,0).
            print "Landing Zone        : " + LZD + "         " at (0,1).
            print "PDI longitude (deg) : " + ROUND(PDILng,2) + "       " at (0,2).
            print "Angle to PDI (deg)  : " + ROUND(phi,2) + "          " at (0,3).
            print "Time until burn (s) : " + ROUND(waitTime,2) + "          " at (0,4).
        }
        set program to 14. // for now until go/no go decision for landing
    }
    
    if program = 35 { // Braking
        clearscreen.
        lock STEERING TO SHIP:RETROGRADE.
        GEAR ON.
        until SHIP:VELOCITY:SURFACE:MAG < 200 {
        //until ALT:RADAR < 1000 { 
            set throttleLimit to 1.0.
            set theta to landingSite:GEOPOSITION:LAT - SHIP:GEOPOSITION:LAT.
            set steeringDir to landingSite:GEOPOSITION:HEADING.
            lock STEERING TO SHIP:RETROGRADE + R(5,0,0).
            print "Braking (P14)"                                                                          at (0,0).
            print "Landing Zone                 : " + landingSite + "         "                            at (0,1).
            print "Altitude above terrain (m)   : " + ROUND(ALT:RADAR,2) + "       "                       at (0,2).
            print "Distance to landing site (m) : " + ROUND(landingSite:GEOPOSITION:DISTANCE,2) + "      " at (0,3).
            print "Surface velocity (m/s)       : " + ROUND(SHIP:VELOCITY:SURFACE:MAG,2) + "      "        at (0,4).
            print "Vertical speed (m/s)         : " + round(ship:verticalspeed,2) + "           "          at (0,5).
            print "Ship latitude                : " + ROUND(SHIP:GEOPOSITION:LAT,2) + "            "       at (0,6).
            print "LZ Latitude                  : " + ROUND(landingSite:GEOPOSITION:LAT,2) + "           " at (0,7).
            print "Bearing                      : " + ROUND(steeringDir,2) + "           "                 at (0,8).
            print "Heading                      : " + ROUND(landingSite:GEOPOSITION:HEADING,2) + "    "    at (0,9).
            //print "Delta V (m/s)       : " + ROUND(dVHohmann,2) + "            " at (0,6).
        }
        set throttleLimit to 0.
        set program to 15.
    }
    
    if program = 36 { // Approach phase guidance
        clearscreen.
        set steeringDir to 0.
        set steeringPitch to body:direction:pitch.
        lock Fg to SHIP:MASS * BODY:MU /((SHIP:ALTITUDE + BODY:RADIUS)^2).
        lock am to vang(up:vector, ship:facing:vector).
        local eVect is vcrs(up:vector, north:vector).
        local eComp is vdot(ship:velocity:surface,eVect) * (1 / eVect:mag).
        local nComp is vdot(ship:velocity:surface,north:vector) * (1 / north:vector:mag).
        lock steering to heading(steeringDir,steeringPitch).
        local surfaceVelocity is sqrt(ecomp^2 + nComp^2).
        set steeringDir to 180 + (90 - arccos(eComp / surfaceVelocity)).
        until ALT:RADAR < 500 {
            // be careful here, a pitch of 90 degrees will result in divide by 0
            // this part will never go beyond 85 degrees so we are safe for now
            set throttleLimit to Fg / (SHIP:AVAILABLETHRUST * sin(steeringPitch)) * 0.8.
            local eVect is vcrs(up:vector, north:vector).
            local eComp is vdot(ship:velocity:surface,eVect) * (1 / eVect:mag).
            local nComp is vdot(ship:velocity:surface,north:vector) * (1 / north:vector:mag).
            local surfaceVelocity is sqrt(ecomp^2 + nComp^2).
            if surfaceVelocity > 1 and steeringPitch < 85 { set steeringPitch to steeringPitch + 0.2. }
            print "Approach (P15)" at (0,0).
            print "Landing Zone                 : " + landingSite + "         "								at (0,1).
            print "Altitude above terrain (m)   : " + ROUND(ALT:RADAR,2) + "       " 						at (0,2).
            print "Distance to landing site (m) : " + ROUND(landingSite:GEOPOSITION:DISTANCE,2) + "       " at (0,3).
            print "Ground distance (m)          : " + "      " at                                              (0,4).
            print "Surface velocity (m/s)       : " + ROUND(SHIP:VELOCITY:SURFACE:MAG,2) + "      "         at (0,5).
            print "Vertical speed (m/s)         : " + round(ship:verticalspeed,2) + "           " at           (0,6).
            print "Steering direction           : " + round(steeringDir,2) + "           " at                  (0,7).
            print "Fg (N)                       : " + round(Fg,2) + "           " 							at (0,8).
            print "surface 2d                   : " + ROUND(surfaceVelocity,2) + "           " 				at (0,9).
            print "Throttle                     : " + round(throttleLimit,2) + "       " 					at (0,10).
            wait 0.1.
        }
        set throttleLimit to 0.
        set program to 16.
    }
    if program = 37 { // Landing
        clearscreen.
        lock STEERING TO SHIP:UP.

        until ship:verticalspeed > -10 {
            lock Fg to ship:mass * body:mu /((ship:altitude + body:radius)^2).
            lock am to vang(up:vector, ship:facing:vector).
            set throttleLimit to 1.0.
            print "Landing (P16)" at (0,0).
            print "Landing Zone                 : " + landingSite + "         " at (0,1).
            print "Altitude above terrain (m)   : " + ROUND(ALT:RADAR,2) + "       " at (0,2).
            print "Distance to landing site (m) : " + ROUND(landingSite:GEOPOSITION:DISTANCE,2) + "       " at (0,3).
            print "Ground distance (m)          : " + "      " at (0,4).
            print "Surface velocity (m/s)       : " + ROUND(SHIP:VELOCITY:SURFACE:MAG,2) + "      " at (0,5).
            print "Vertical speed (m/s)         : " + round(ship:verticalspeed,2) + "           " at (0,6).
            print "LZ Latitude                  : " + ROUND(landingSite:GEOPOSITION:LAT,2) + "           " at (0,7).
            print "Fg (N)                       : " + round(Fg,2) + "           " at (0,8).
            print "Fg * cos(am)                 : " + ROUND((Fg * cos(am)),2) + "           " at (0,9).
        }
        until ALT:RADAR < 1 {
            lock Fg to ship:mass * body:mu /((ship:altitude + body:radius)^2).
            lock am to vang(up:vector, ship:facing:vector).
            set throttleLimit to Fg / ship:availablethrust * 0.95.
            print "Landing (P16)" at (0,0).
            print "Landing Zone                 : " + landingSite + "         " at (0,1).
            print "Altitude above terrain (m)   : " + ROUND(ALT:RADAR,2) + "       " at (0,2).
            print "Distance to landing site (m) : " + ROUND(landingSite:GEOPOSITION:DISTANCE,2) + "       " at (0,3).
            print "Ground distance (m)          : " + "      " at (0,4).
            print "Surface velocity (m/s)       : " + ROUND(SHIP:VELOCITY:SURFACE:MAG,2) + "      " at (0,5).
            print "Vertical speed (m/s)         : " + round(ship:verticalspeed,2) + "           " at (0,6).
            print "LZ Latitude                  : " + ROUND(landingSite:GEOPOSITION:LAT,2) + "           " at (0,7).
            print "Fg (N)                       : " + round(Fg,2) + "           " at (0,8).
            print "Fg * cos(am)                 : " + ROUND((Fg * cos(am)),2) + "           " at (0,9).
        }
        set throttleLimit to 0.
        set program to 0.
    }
wait 0.001.
}

print "Orbit!" at (0,6).
lock throttle to 0.
set ship:control:pilotmainthrottle to 0.

// end program