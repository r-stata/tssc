*! version 7.1.2  26Nov2012
*     add bwidth(vector) to vce(analytic, options)
*! version 7.0.0  28Jul2012
*! Version 6.0.0 includes bandwidth selection by cross validation
*! Version 7.0.0 includes bootstrapped VCE
program define poparms, eclass byable(onecall)
	version 12.1

	if _by() {
		local BY `"by `_byvars'`_byrc0':"'
	}
	if replay() {
		if ("`e(cmd)'"!="poparms") error 301

		Replay `0'
		exit
	}
	/* preserve random number seed					*/
	local seed `c(seed)'
	cap noi `BY' Estimate `0'
	local rc = c(rc)
	set seed `seed'
	exit `rc'
end

program Estimate, eclass 
	syntax anything(name=eqlist id="equation list") [if][in],    ///
		[				///
		Quantiles(numlist) 		///
		ipw 				///
 		CVBand				///	UNDOCUMENTED
		vce(string)			///	
		trace 				///	UNDOCUMENTED
		pszero(numlist max=1 >0 <1e-3)	///	UNDOCUMENTED
		]

	local ieif = ("`ipw'"=="")

	if "`pszero'" == "" {
		local pszero = 1e-7
	}
// syntax for vce()
// vce({ANalytic|BOOTstrap|none} , [Reps(#) bwscale(#) 
// 	DENsities(matname) bwidths(matname))

	local tmp : subinstr local vce "," "," , all count(local ncommas)
	if `ncommas' > 1 {
		di in red `"{cmd:vce(`vce')} invalid"'
		exit 498
	}
	
	if `ncommas' == 1 {
		local vcep `"`vce' quantiles(`quantiles')"'
	}
	else {
		local vcep `"`vce' , quantiles(`quantiles')"'
	}

	PP_vceparse `vcep'

	local properties `r(properties)'
	local vcetype `r(vcetype)'
	local bwscale `r(bwscale)'
	local reps    `r(reps)'

	if "`r(usdensities)'" != "" {
		tempname usdensities 
		matrix `usdensities' = r(densities)
	}

	if "`r(usbwidths)'" != "" {
		tempname usbwidths 
		matrix `usbwidths' = r(bwidths)
	}

	/* undocumented options: trace - display intermediate results	*/
	local cmdline `"poparms `:list retokenize 0'"'

	_parse expand eqninfo left : eqlist  
	local k_eqs = `eqninfo_n'

	if `k_eqs' != 2 {
		di in red "{p}two equations reqired: " 			 ///
		 "{bf:({it:te_equation})}, the treatment equation, and " ///
		 "{bf:({it:mean_equation})}, the mean equation{p_end}"
		exit 198
	}
	local tmp : subinstr local eqninfo_`i' "," ",",	count(local cms)

	ParseEq3 `eqninfo_1'
	local treatvar `s(depvar)'
	local gpvars `s(indvars)'
	
	ParseEq3 `eqninfo_2'
	local depvar `s(depvar)'
	local cvars `s(indvars)'
		
	marksample touse
	markout `touse' `depvar' `gpvars' `treatvar' `cvars'
	qui count if `touse'
	if (!r(N)) error(2000)

	qui cap fvexpand `gpvars' if `touse'
	local gpvars `r(varlist)'

	qui cap fvexpand `cvars' if `touse'
	local cvars `r(varlist)'

					// kq hold number of quantile estimated
					// NOTE:
					//    If quantiles bootstrap is default
					//    only means, analytic method is
					//    default
	if "`quantiles'" != "" {
		numlist "`quantiles'", sort
		local quantiles `r(numlist)'
		local kq : word count `quantiles'

		tempname tau
		matrix `tau' = J(`kq',1,0)
		forvalues i = 1/`kq' {
			local tau`i' : word `i' of `quantiles'
			/* handle quantile(50.5) */
	                local ltau`i' = string(floor(100*`tau`i''),"%2.0f")
			matrix `tau'[`i',1] = `tau`i''
		}

	}
	else {
		local kq = 0
	}

	
	/* find the maximum treatment level				*/
	set sortseed 12345
	
					// kt holds number of treatment levels
	tempname levels
	ValidateTreatvar `treatvar', touse(`touse')
	local kt = `r(kt)'
	mat `levels' = r(levels)

	if "`quantiles'" != "" {
		if "`usdensities'" != "" {
			if colsof(`usdensities') != (`kq'*`kt') {
				di in red "{cmd:densities() must specify " ///
					"a row vector with `kq' "	///
					"columns" 

				di in red "{p 0 4}The number of columns " ///
					"in the "			///
					"the row vector specified by "	///
					"{cmd:densities()} must be "	///
					"the same as the (number of "	///
					"treatment leves)*(number of "	///
					"quantiles){p_end}"
				exit 498
			}
		}
		if "`usbwidths'" != "" {
			if colsof(`usbwidths') != (`kq'*`kt') {
				di in red "{cmd:bwidths() must specify " ///
					"a row vector with `kq' "	///
					"columns" 

				di in red "{p 0 4}The number of columns " ///
					"in the "			///
					"the row vector specified by "	///
					"{cmd:bwidths()} must be "	///
					"the same as the (number of "	///
					"treatment leves)*(number of "	///
					"quantiles){p_end}"
				exit 498
			}
		}
	}
	
	/* find the number of independent variables			*/
	local k : word count `cvars'

	/* Estimate propensity scores via -mlogit-			*/
	local base = `levels'[1,1]
	qui mlogit `treatvar' `gpvars' if `touse', b(`base') 
	if !e(converge) {
		di in red "{p}{bf:mlogit} did not converge{p_end}" ///
		exit 430
	}
	else if c(rc) {
		di in red "{p}{bf:mlogit} failed; estimation " ///
		 "cannot proceed without propensity scores{p_end}"
		exit 498
	}

// e(sample) differs from original touse		
// only when some probs are very small and there is no identification
	qui count if `touse'
	local n1 = r(N)

	qui replace `touse' = e(sample)
	qui count if `touse'
	local n = r(N)

	if `n1' != `n' {
		di "{cmd:mlogit} sample differs from original sample"
		di "  Some propensities scores may be too close to zero or one"
		di "  The parameters may not be identified"
	}

					// propensity scores	
	forvalues t=1/`kt' {
		tempvar phat`t'
		local phat `phat' `phat`t''
	}
	qui predict double ( `phat' ) if `touse', pr

	foreach v of local phat {
		qui summarize `v'
		local min  = r(min)
		local max  = r(max)
		if `min' < `pszero' | `max'>1-`pszero' {
di in red "Some propensity scores are too close to zero or one"
di in red "The parameters are not identified."
exit 498
		}
	}

// Make weight variables wt*, wtm1*, and treatment indicators ti*
// 	treament indicators are adjusted for touse

	local j = 0
	forvalues t = 1/`kt' {
		tempvar wt`t' wtm1`t' ti`t'
		local s = `levels'[`t',1]
		qui gen double `wt`t'' = 			///
			cond(`treatvar'==`s', 1/`phat`t'', 0) if `touse'
		local wlist `wlist' `wt`t''
		qui gen byte `ti`t'' = (`treatvar'==`s' & `touse')
		local tilist `tilist' `ti`t''

		qui gen double `wtm1`t'' = `wt`t''-1 if `touse'
	}

// make names
	
	forvalues t=1/`kt' {
		local s    = `levels'[`t',1]
		local names "`names' mean:`s'.`treatvar'"
	}
	
	forvalues i=1/`kq' {
		forvalues t=1/`kt' {
			local s    = `levels'[`t',1]
			local names "`names' q`ltau`i'':`s'.`treatvar'"

			local dnames "`dnames' q`ltau`i'':`s'.`treatvar'"
		}
	}

	tempname b
	local kpar = `kt'*(1+`kq')
	matrix `b' = J(1,`kpar',0)

// Get point estimates
	if `ieif' {
					// EIF means estimated here
		tempvar  xb_meif eif_tmp
		tempname eif_a eif_c
		forvalues t = 1/`kt' {
			local s = `levels'[`t',1]
			qui regress `depvar' `cvars'  if `ti`t''
			qui capture drop `xb_meif'
			qui predict double `xb_meif'
			
			qui capture drop `eif_tmp' 
			qui generate double `eif_tmp' = 	/// 
				`wt`t''*`depvar' if `touse'
			qui sum `eif_tmp'   if `touse'
			scalar `eif_a' = r(sum)

			qui replace `eif_tmp' = `wtm1`t''*`xb_meif' if `touse'
			qui sum `eif_tmp'  if `touse'
			scalar `eif_c' = r(sum)

			matrix `b'[1,`t'] = (`eif_a'-`eif_c')/(`n')
		}
					// GET EIF quantile estimates here
		if `kq'>0 {
			mata: _poparms_qEIF2("`depvar'", "`cvars'",	///
				"`touse'", 		///
				"`levels'", "`tilist'", "`wlist'",  	///
				"`tau'", "`b'", "", "`trace'", 		///
				"`dhat'")
		}
	}
	else {
				// This loop puts IPW mean estimates in b
		local j = 0
		forvalues t = 1/`kt' {
			local s = `levels'[`t',1]
			qui regress `depvar' [iw=`wt`t''] if `ti`t''
			matrix `b'[1,`++j'] = _b[_cons]
		}
					// Get IPW quantile estimates 
		if `kq'>0 {
			mata: _poparms_qIPW2("`depvar'", "`touse'", 	///
				"`levels'", "`tilist'", "`wlist'", 	///
				"`tau'", "`b'", "", "`trace'")
		}
	}

	if (`ieif') local title2 (efficient influence function)
	else local title2 (inverse probability weighting)

// Now deal with VCE
	if "`vcetype'" == "analytic" {
		tempname V
					// Make Psi_mean variables
		tempvar xbe yam
		qui gen double `yam' = .

		forvalues t=1/`kt' {
			qui replace `yam' = `depvar' - `b'[1, `t'] 
			qui regress `yam' `cvars' if `ti`t''
			capture drop `xbe'
			qui predict double `xbe' if `touse'

			tempvar psim_`t'
			local psimlist `psimlist' `psim_`t''
			qui gen double `psim_`t'' = `wt`t''*`yam' - 	///
				`wtm1`t''*`xbe'
		}

		if `kq'>0 {		
// This section computes psi variables and Gamma matrix when
//	quantiles are estimated

// consolidate psi computations into one loop
			forvalues i=1/`kq' {
				forvalues t=1/`kt' {
					tempvar psiq_`i'_`t'
					qui gen double `psiq_`i'_`t'' = .
					local psilistq `psilistq' `psiq_`i'_`t''
				}
			}

			tempvar ylt xb
			tempname bq
			qui gen double `ylt' = .
			forvalues i = 1/`kq' {
				forvalues t = 1/`kt' {
					local s = `levels'[`t',1]

					local el = (`i'-1)*`kt' + `t'
					local psi_it : word `el' of `psilistq'

					scalar `bq' = `b'[1, `kt' + `el']

					capture drop `xb'
					qui replace `ylt' = 		///
						(`depvar' <= `bq') - `tau`i''
					qui regress `ylt' `cvars' 	///
						if `treatvar'==`s' & `touse'
					qui predict double `xb'
					qui replace `psi_it' = 		///
						`wt`t''*`ylt' -		///
						`xb'*`wtm1`t'' if `touse'
				}
			}

			// Put this mess into a function 
			// now adjust for Gamma

			tempname Gamma dhat 	
			if "`usdensities'" == "" {
				tempvar zb kv tousej tousecv
				tempname bw_cv bw_cv_v bw_pi_v bw_v

				if "`cvband'" != "" {
					matrix `bw_cv_v' = J(1, `kq'*`kt',.)
					matrix colnames `bw_cv_v' = `dnames'
					matrix rownames `bw_cv_v' = "CVbwidths"
				}

				matrix `bw_pi_v' = J(1, `kq'*`kt',.)
				matrix colnames `bw_pi_v' = `dnames'
				matrix rownames `bw_pi_v' = "PIbwidths"

				matrix `bw_v' = J(1, `kq'*`kt',.)
				matrix colnames `bw_v' = `dnames'
				matrix rownames `bw_v' = "Bwidths"

				qui generate double `zb'    = .
				qui generate double `kv'    = .
				qui generate byte `tousej'  = .
				qui generate byte `tousecv' = .
				matrix `dhat' = J(1, `kt' + `kq'*`kt', 1)
				matrix `Gamma' = I(`kt'*(1+`kq'))
				forvalues i = 1/`kq' {
forvalues t = 1/`kt' {
	local pn  = `kt' + (`i'-1)*`kt' + `t'
	local pnb = (`i'-1)*`kt' + `t'
	local qn = `b'[1, `pn']
	local treatval = `levels'[`t',1]

	if "`usbwidths'" == "" {
		qui summarize `depvar' [aw=`wt`t'']	///
			if `treatvar'==`treatval' & `touse' , detail
		local miny = r(min)
		local maxy = r(max)
		local m1   = r(sd)
		local m2   = (r(p75) - r(p25))/1.349
		local m    = min(`m1', `m2')
		local nj   = r(N)
		local bw_pi = 2.3449*`m'/((`nj')^(.2))
		matrix `bw_pi_v'[1,`pnb'] = `bw_pi'
		local bw0 = `bwscale'*`bw_pi'
		if "`cvband'" != "" {
			qui replace `tousej' = 		///
				cond(`treatvar'==`treatval' & `touse' , 1, 0)
			local sL = `qn'-`miny'
			local sH = `maxy' - `qn'
			local cut = min(.5*`s', `sL', `sH')
			qui replace `tousecv' = 	///
			cond((abs(y - `qn') < `cut') & `tousej', 1, 0)  
			mata: _poparms_PPSI_BCVGrid("`depvar'", "`wt`t''", ///
				"`tousej'", "`tousecv'", `bw0',	///
				`cut', `qn', 150, "", "", "`bw_cv'")
			local mh = scalar(`bw_cv')
			matrix `bw_cv_v'[1,`pnb'] = scalar(`bw_cv')
			matrix `bw_v'[1,`pnb']    = scalar(`bw_cv')
		}
		else {
			local mh    = `bw0'
			matrix `bw_v'[1,`pnb']    = `mh'
		}
	}
	else {
		local mh                  = `usbwidths'[1,`pnb']   
		matrix `bw_v'[1,`pnb']    = `usbwidths'[1,`pnb']   
	}

	qui replace `zb' = (((`qn')-`depvar')/`mh')
	qui replace `kv' = cond(abs(`zb')<=1, 	///
		.75*(1-(`zb')^2), 0)
	qui regress `kv' [aw=`wt`t''] 	///
	  if `treatvar'==`treatval' & `touse' 
	local fj = _b[_cons] /(`mh')

	matrix `dhat'[1, `pn'] = `fj'
}
				}
			}
			else {
				matrix `dhat' = J(1, `kt' , 1), `usdensities'
			}

			mata: `dhat' = st_matrix("`dhat'")'
			mata: st_matrix("`Gamma'", diag(1:/`dhat'))


			matrix colnames `dhat' = `dnames'	
			matrix rownames `dhat' = densities

		}

//  Always compute V
		qui matrix accum `V' = `psimlist' `psilistq', noconstant
		local n_tmp = r(N)
		matrix `V' = (1/`n_tmp')*`V'


		if `kq'>0 {
// Only adjust for Gamma when Quantiles are estimated
			tempname V1
			matrix `V1' = `V'

			matrix colnames `V1' = `names'
			matrix rownames `V1' = `names'

			matrix `V' = `Gamma'*`V'*`Gamma'/`n_tmp'

		}
		else {
			matrix `V' = (1/`n_tmp')*`V'
		}

		matrix colnames `V' = `names'
		matrix rownames `V' = `names'


	}
	else if "`vcetype'" == "bootstrap" {
		tempname B bj V 
		local nparms = colsof(`b')
		mata: `B' = J(`reps', `nparms', .)
		local sr = 0
		forvalues s=1/`reps' {
			preserve
			qui keep if `touse'
			qui bsample 
			capture poparms (`treatvar' `gpvars') 	///
				(`depvar'   `cvars'),		///
				quantiles(`quantiles')		///
				vce(none)
			local rc = _rc
			restore 
			if `rc' {
di in red "Bad bootstrap sample: cannot compute poparms estimates"
			}
			else {
				// increment sr but post in s
				//    missing value structure identifies 
				//    bad samples
				local ++sr
				mata: `B'[`s',.] = st_matrix("e(b)")
			}
		}
		mata: st_matrix("`V'", quadvariance(`B'))
	
		local bsreps = `sr'

		matrix colnames `V' = `names'
		matrix rownames `V' = `names'
	}
	else {			// vcetype must be none
	}


	matrix colnames `b' = `names'	

	ereturn post `b' `V', obs(`n') esample(`touse') 	///
		properties(`properties')

	ereturn local k = `k'
	ereturn local quantiles `quantiles'
	ereturn local marginsok default
	ereturn local depvar `depvar'
	ereturn local vcetype `vcetype'

	if "`vcetype'" == "analytic" & `kq'>0 {

		matrix `dhat' = `dhat'[1, `kt'+1 ...]
		ereturn matrix densities = `dhat'

		capture mata: mata drop `dhat'

		// bandwidth only 
		if "`usdensities'" == "" {
			if "`bwidths'" == "" {
				ereturn scalar bwscale = `bwscale'
				ereturn matrix bw_pi     = `bw_pi_v'

				if "`cvband'" != "" {
					ereturn matrix bw_cv     = `bw_cv_v'
				}
				ereturn matrix bw        = `bw_v'
			}
			else {
				ereturn matrix bw        = `bw_v'
			}
		}
		ereturn matrix V1        = `V1'
	}

	if "`vcetype'" == "bootstrap" {
		capture mata: mata drop `B'
		ereturn scalar reps   = `reps'
		ereturn scalar bsreps = `bsreps'
	}

	ereturn matrix levels    = `levels'

	ereturn local predict  "poparms_p"
	ereturn local title2 `title2'
	ereturn local title Treatment Mean and Quantiles Estimation
	ereturn local cmdline `cmdline'
	ereturn local cmd poparms

	Replay, `diopts'
end

program Replay
	syntax, [ * ]

	_get_diopts diopts rest, `options'

	if "`rest'" != "" {
		if `:word count `rest'' > 1 {
			di in red "{p}options {bf:`rest'} are not " ///
			 "allowed{p_end}"
		}
		else  di in red "{p}option {bf:`rest'} is not allowed{p_end}"

		exit 198
	}
	if (e(df_m)==0) _coef_table_header, nomodeltest
	else _coef_table_header

	_coef_table, `diopts'
	if "`e(vcetype)'"=="bootstrap" & e(reps)!=e(bsreps) {
		local bsreps = e(bsreps)
		local reps   = e(reps)
		di "Only `bsreps' of the requested `reps' bootstrap " 	///
			"repetitions could be performed"
	}
end

program ParseEq3, sclass
	cap syntax varlist(numeric fv) 

	local rc = c(rc)
	if `rc' {
		di in red "invalid equation; " 
		cap noi syntax varlist(numeric fv)
		exit `rc'
	}

	gettoken depvar varlist : varlist
	_fv_check_depvar `depvar'

	sreturn local depvar `depvar'
	sreturn local indvars `varlist'
end


program ValidateTreatvar, rclass
	syntax varname(numeric), [ touse(varname numeric) ]

	preserve
	/*  check that the treatment variable is categorical		*/
	tempvar check del
	qui gen int `check' = round(`varlist') if `touse'
	cap assert `check' == `varlist' if `touse'
	if c(rc) {
		di in red "{it:treatvar}, {bf:`varlist'}, must be categorical"
		exit 459
	}
	qui count if `touse'
	local n = r(N)

	sort `check'
	local max = `varlist'[`n']
	local min = `varlist'[1]

	qui gen int `del' = (`check'[_n]-`check'[_n-1]>0) if _n>1 & `touse'
	qui replace `del' = 1 in 1
	qui count if `del' & `touse'
	local kt = r(N)
	if `kt' > 30 {
		di in red "{p}there are `kt' unique values in " ///
		 "{it:treatvar} {bf:`varlist'}; the maximum is 30{p_end}"
		exit 459
	}
	if `kt' < 2 {
		di in red "{p}at least two treatment groups are required{p_end}"
		exit 459
	}
	tempname levels
	mat `levels' = J(`kt',1,.)
	gsort - `del' + `check'

	forvalues i=1/`kt' {
		mat `levels'[`i',1] = `check'[`i']
	}
	return local max = `max'		// not used
	return local kt = `kt'
	return mat levels = `levels'
end

program define PP_vceparse, rclass
	syntax [anything(name=vcetype)] 	///
		[, 				///
		Reps(string) 			///
		BWScale(string) 		///
		CVBand 				///
		Quantiles(numlist)		///
		DENSities(string)		///
		bwidths(string)			///
		]
	
	if "`vcetype'" == "" {
		if "`quantiles'" != "" {
			local vcetype "bootstrap"
			local properties "b V"
		}
		else {
			local vcetype "analytic"
			local properties "b V"
		}
	}
	else {
		PP_getvcetype , `vcetype'
		if "`vcetype'" == "none" {
			local properties "b"
		}
			
		local vcetype `r(vcetype)'
	}
	
	if `"`reps'"' != "" {
		if "`vcetype'" != "bootstrap" {
			di in red "{cmd:reps()} cannot be specified "   ///
				"with vcetype `vcetype'"
			exit 498
		}

		capture confirm integer number `reps'
		if _rc {
			di in red "{cmd:reps() must specify an integer number"
			exit 498
		}

		if `reps' <50 {
			di in red "{cmd:reps() must specify an integer " ///
				"number at least as large as 50"
			exit 498
		}
	}
	else {
		local reps 2000
	}

	if "`vcetype'" == "analytic" {
		if "`bwscale'" != "" & "`bwidths'" != "" {
			di in red "{cmd:bwscale()} and "	///
				"{cmd:bwidths()} cannot both be specified"
			exit 498
		}

		if "`bwidths'" != "" & "`cvband'" != "" {
			di in red  "{cmd:bwidths()} and "	///
				"{cmd:cvband} cannot both be specified"
			exit 498
		}

		if "`bwidths'" != "" & "`densities'" != "" {
			di in red "{cmd:bwidths()} and "	///
				"{cmd:densities()} cannot both be specified"
			exit 498
		}

		if "`bwscale'" != "" & "`cvband'" != "" {
			di in red "{cmd:bwscale()} and "	///
				"{cmd:cvband} cannot both be specified"
			exit 498
		}

		if "`bwscale'" != "" & "`densities'" != "" {
			di in red "{cmd:bwscale()} and "	///
				"{cmd:densities()} cannot both be specified"
			exit 498
		}

		if "`cvband'" != "" & "`densities'" != "" {
			di in red "{cmd:cvband} and "	///
				"{cmd:densities()} cannot both be specified"
			exit 498
		}

		if `"`bwscale'"' != "" {
			capture confirm number `bwscale'
			if _rc {
				di in red "{cmd:bwscale() must specify a number"
				exit 498
			}
	
			if `bwscale' < .1 | `bwscale' > 10 {
				di in red "{cmd:bwscale()} must "	///
					"specify a number between .5 and 2"
				exit 498
			}

			if `bwscale' != 1 & "`cvband'" != "" {
				di in red "{cmd:bwscale()} and "	///
					"{cmd:cvband} cannot both be specified"
				exit 498
			}
		}
		else {
			local bwscale 1
		}

		if `"`densities'"' != "" {
			capture confirm matrix `densities'
			if _rc {
				di in red "{cmd:densities() must "	///
					"specify a matrix"
				exit 498
			}
	
		}

		if `"`bwidths'"' != "" {
			capture confirm matrix `bwidths'
			if _rc {
				di in red "{cmd:bwidths() must "	///
					"specify a matrix"
				exit 498
			}
	
		}
	}
	else {
		if `"`bwscale'"' != "" {
			di in red "{cmd:bwscale()} cannot be specified " ///
				"when vcetype is {cmd:`vcetype'}"
			exit 498
		}

		if `"`cvband'"' != "" {
			di in red "{cmd:cvband} cannot be specified "	///
				"when vcetype is {cmd:`vcetype'}"
			exit 498
		}

		if `"`densities'"' != "" {
			di in red "{cmd:densities()} cannot be "		///
				"specified when vcetype is {cmd:`vcetype'}"
			exit 498
		}

	}

	return local properties `properties'
	return local bwscale `bwscale'
	return local vcetype `vcetype'
	return local reps `reps'
	if "`densities'" != "" {
		return local usdensities usdensities
		return matrix densities = `densities' , copy
	}

	if "`bwidths'" != "" {
		return local usbwidths usbwidths
		return matrix bwidths = `bwidths' , copy
	}

end

program define PP_getvcetype, rclass
	syntax , [ ANalytic BOOTstrap NONE *]

	if "`options'" != "" {
		di in red `"`options' invalid vcetype"'
		exit 498
	}

	local w : word count `analytic' `bootstrap' `none'
	if `w' > 1 {
		di in red "vcetype invalid"
		di in red "Only one of `analytic' `bootstrap' `none' "	///
			"can be specified"
	}
	
	return local vcetype "`analytic'`bootstrap'`none'"
end

