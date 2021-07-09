//Copyright 2007 by Daniel Lawson
program bitobit
	version 9.2
	if replay(){
		if ("`e(cmd)'" != "bitobit") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass sortpreserve
	syntax namelist [if] [in] [fweight], y1(varname) x1(varlist) y2(varname) x2(varlist) censor1(varname) censor2(varname) [Level(cilevel)]
	marksample touse
	global bitobit_1censor `censor1'
	global bitobit_2censor `censor2'
	ml model lf bitobit_ll (`y1'=`x1') (`y2'=`x2') /sigma1 /sigma2 /atan_rho [`weight' `emp'] if `touse'
	ml maximize, tolerance(1e-4) ltolerance(1e-4) 
	ereturn local cmd "bitobit"
*	Replay, level(`level')
	macro drop bitobit_1censor
	macro drop bitobit_2censor
end

program Replay
	syntax [, Level(cilevel)]
	ml display, level(`level')
end
