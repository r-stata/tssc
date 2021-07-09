*capture program drop isa_est

*********************************************************************
*	CORE SYNTAX OF IMBENS(2003)

program define isa_est
	version 9
	syntax varlist [if] [in] [fw aw], alpha(real) delta(real) [vce(passthru)] [ml_iterate(int 50)] 
	marksample touse
	gettoken y rhs : varlist
	gettoken t X :rhs
	scalar alpha = `alpha'
	scalar delta = `delta'
	ml model lf isa_mle (`y' = `t' `X') (`t' = `X') (`y' = ) if `touse' [`weight'`exp'], `vce'
	ml trace off
	ml init from, copy
	ml search, norescale
	ml maximize, iterate(`ml_iterate') difficult
	scalar drop alpha delta
end

