*!version 1.1 Helmut Farbmacher

program define ztnbp
	version 9.0
	if replay() {
		if (`"`e(cmd)'"'!= "ztnbp") error 301
			Replay `0'
	}
	else 	Estimate `0'
end

***********************************************************************

program define Estimate, eclass

	syntax varlist [if] [in], [vce(passthru)			///
			CLuster(varname) 							///
			Robust										///
			NOCONstant									///
			STARTing 									///
			SEARCH * ]				
	gettoken yvar xvars : varlist

	mlopts mlopts, `options'

	marksample touse

/* Count obs and check for negative values of `yvar'. */

	summarize `yvar' if `touse', meanonly

	if r(N) == 0  error 2000 
	if r(N) == 1  error 2001 

	if r(min) <= 0 {
		di as err "`yvar' must be greater than zero"
		exit 459
	}
	if r(min) == r(max) & r(min) == 0 {
		di in red "`yvar' is zero for all observations"
		exit 498
	}

/* Check whether `yvar' is integer-valued. */

	capture assert `yvar' == int(`yvar') if `touse'
		if _rc {
			di in blu "note: you are responsible for " /*
			*/ "interpretation of noncount dep. variable"
		}

/* Estimation */
	
	local s "search"
	if "`search'"=="" {
		local o "off"
	}
	else {
		local o "on" 
	}

	dis as txt _n "Getting starting values from zero-truncated NB2:"
	qui ztnb `yvar' `xvars' if `touse', `noconstant' `mlopts' 
	tempname b0
	mat `b0' = (e(b),2)
		
	if "`starting'"!="" {
		mat li `b0'
	}

	dis as txt _n "Fitting zero-truncated Negbin-P:"
	ml model lf ztnbp_ll (`yvar' = `xvars', `noconstant') /lnalpha /P 	///
		if `touse', `mlopts' `vce' cluster(`cluster')  	///
		`robust' init(`b0',copy) max difficult `s'(`o')
	
	ereturn local title "Zero-truncated Negbin-P model"
	ereturn scalar k_aux = 2	
	ereturn local cmd "ztnbp"
	
	Replay
end

***********************************************************************

program define Replay
			ml display /*, neq(1)*/
			_diparm lnalpha, exp pr label("alpha")
end



