

*! mynormal v1.0.1  CFBaum 11aug2008
program mynormal
	version 10.1
	if replay()  {
		if ("`e(cmd)'" != "mynormal") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Replay
	syntax [, Level(cilevel) ]
	ml display, level(`level')
end

program Estimate, eclass sortpreserve
	syntax varlist [if] [in]  [,  vce(passthru) Level(cilevel) * ]
	mlopts mlopts, `options'
	gettoken lhs rhs: varlist
	marksample touse
	local diparm diparm(lnsigma, exp label("sigma"))
	ml model lf  mynormal_lf (mu: `lhs' = `rhs') /lnsigma  ///
	if `touse', `vce' `mlopts' maximize `diparm'
	ereturn local cmd "mynormal"
	ereturn scalar k_aux = 1
	Replay, level(`level') 
end
