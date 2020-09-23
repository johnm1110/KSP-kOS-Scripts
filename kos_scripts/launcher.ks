if booster = "Juno1" {
	// intial pitch over maneuver
	set pitchOverVelocity to 50.				// velocity for intial pitch over

	// gravity turn pitch settings (deg/s)
	set dPitchStage1 to 0.5. // change in pitch (deg/s)
	set dPitchStage2 to 0.94. // a little more aggressive at this stage
	set dPitchStage3 to 0.94. // a little more aggressive at this stage
}

if booster = "Juno2" {
	// intial pitch over maneuver
	set pitchOverVelocity to 50.				// velocity for intial pitch over

	// gravity turn pitch settings (deg/s)
	set dPitchStage1 to 0.5. // change in pitch (deg/s)
	set dPitchStage2 to 0.94. // a little more aggressive at this stage
	set dPitchStage3 to 0.94. // a little more aggressive at this stage
	
	// the stage numbers are in order of activation, not based on KSP naming conventions
	set twrStage2 to 4.27.
	set twrStage1 to 1.88.
	
	// Engine ISP, set manually until I can extract it in the script
	set stage2Isp to 320.
	set stage1Isp to 265.

	// set up engine parameters
	set twrLowerAtmo to 1.4.
	set twrMidAtmo to   1.0.
	set twrUpperAtmo to 0.8.
}

if booster = "Juno3" {
	// intial pitch over maneuver
	set pitchOverVelocity to 50.				// velocity for intial pitch over

	// gravity turn pitch settings (deg/s), twr and dPitch are inverse proportions
	set dPitchStage1 to 0.70.
	set dPitchStage2 to 0.90.
	set dPitchStage3 to 0.20.

	// the stage numbers are in order of activation, not based on KSP naming conventions
	set twrStage3 to 0.29.					// see if these twr variables can be pulled from API
	set twrStage2 to 3.48.
	set twrStage1 to 1.72.
	
	// Engine ISP, set manually until I can extract it in the script
	set stage3Isp to 315.
	set stage2Isp to 270.
	set stage1Isp to 240.

	// set up engine parameters
	set twrLowerAtmo to 1.4.
	set twrMidAtmo to   1.0.
	set twrUpperAtmo to 0.8.
}

if booster = "Juno4" {
	// intial pitch over maneuver
	set pitchOverVelocity to 50.				// velocity for intial pitch over

	// gravity turn pitch settings (deg/s), twr and dPitch are inverse proportions
	set dPitchStage1 to 0.80.
	set dPitchStage2 to 0.90.
	set dPitchStage3 to 0.20.
	
	 // Engine ISP, set manually until I can extract it in the script
	set stage3Isp to 295.
	set stage2Isp to 320.
	set stage1Isp to 265.

	// the stage numbers are in order of activation, not based on KSP naming conventions
	set twrStage3 to 3.48.					// see if these twr variables can be pulled from API
	set twrStage2 to 3.21.
	set twrStage1 to 2.72.

	// set up engine parameters
	set twrLowerAtmo to 1.4.
	set twrMidAtmo to 1.0.
	set twrUpperAtmo to 0.8.
}

if booster = "Redstone1" {
	// intial pitch over maneuver
	set pitchOverVelocity to 50.				// velocity for intial pitch over

	// gravity turn pitch settings (deg/s), twr and dPitch are inverse proportions
	set dPitchStage3 to 0.20.
	set dPitchStage2 to 0.90.
	set dPitchStage1 to 0.70.

	
	 // Engine ISP, set manually until I can extract it in the script
	set stage3Isp to 295.
	set stage2Isp to 320.
	set stage1Isp to 265.
}

if booster = "Redstone2" {
	// intial pitch over maneuver
	set pitchOverVelocity to 50.				// velocity for intial pitch over

	// gravity turn pitch settings (deg/s), twr and dPitch are inverse proportions
	set dPitchStage1 to 0.60.
	set dPitchStage2 to 0.80.
	set dPitchStage3 to 0.20.

	// Engine ISP, set manually until I can extract it in the script
	set stage3Isp to 295.
	set stage2Isp to 320.
	set stage1Isp to 265.
	
	// set up engine parameters
	set twrLowerAtmo to 1.4.
	set twrMidAtmo to 1.0.
	set twrUpperAtmo to 0.8.
}

if booster = "Redstone2a" {
	// intial pitch over maneuver
	set pitchOverVelocity to 50.				// velocity for intial pitch over

	// gravity turn pitch settings (deg/s), twr and dPitch are inverse proportions
	set dPitchStage1 to 0.80.
	set dPitchStage2 to 0.95.
	set dPitchStage3 to 0.20.

	// Engine ISP, set manually until I can extract it in the script
	set stage3Isp to 315.
	set stage2Isp to 320.
	set stage1Isp to 265.

	// the stage numbers are in order of activation, not based on KSP naming conventions
	set twrStage3 to 0.44.					// see if these twr variables can be pulled from API
	set twrStage2 to 5.48.
	set twrStage1 to 1.87.
	
	// set up engine parameters
	set twrLowerAtmo to 1.5.
	set twrMidAtmo to 1.4.
	set twrUpperAtmo to 0.8.
}

if booster = "Atlas1" {
	// intial pitch over maneuver
	set pitchOverVelocity to 50.				// velocity for intial pitch over

	// gravity turn pitch settings (deg/s), twr and dPitch are inverse proportions
	set dPitchStage3 to 0.20.
	set dPitchStage2 to 0.90.
	set dPitchStage1 to 0.65.

	// Engine ISP, set manually until I can extract it in the script
	set stage3Isp to 330.
	set stage2Isp to 320.
	set stage1Isp to 285.
	
	// the stage numbers are in order of activation, not based on KSP naming conventions
	set twrStage3 to 1.25.					// see if these twr variables can be pulled from API
	set twrStage2 to 3.64.
	set twrStage1 to 1.56.
	
	// set up engine parameters
	set twrLowerAtmo to 1.4.
	set twrMidAtmo to 1.0.
	set twrUpperAtmo to 0.8.
}

if booster = "Atlas2" {
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
}