*! version 1.7.4 12Feb2019
/*
History
PL 12mar2019: meansurv with no timevar opton and td effects.
PL 18jul2018: fixed bug with rcsbaseoff and meansurv
PL 16jun2018: allow at(x1=x2) for example
PL 10oct2017: Fix for using option for lifelost
PL 04oct2017: Previous fix broke use of if statement
PL 17sep2017: Fixed so meansurv now works with Stata version < 15 again.
PL 10sep2017: added meanhazard option
PL 11aug2017: corrected bugs in stpm2_centpred (did nt work with df(1) or with no covariates)
PL 24may2017: fixed bug when standardising with cure models
PL 05mar2017: tidied lifelost code
PR 14jul2016: Fixed bug in rmst with tmin>0. Disallowed rsdst with tmin>0 (calc of rsdst not worked out).
PL 20jun2016: Update centile option - now calls stpm2_centpred and used Brents algorithm.
PR 21dec2015: Fixed bug in tmax() option, also deleted an erroneous blank line.
PR 09OCT2015: option rmst, meansurv recoded to allow tmax() to contain a numlist.
PR 02SEP2015: Corrected bug in rmst option - could fail if tmax() not specified.
PL 08APR2015: Fixed covpat as use of expr_query not compatible with Stata 12
PR 12NOV2014: Corrected minor bug with rmst option
PR 30JUL2014: Allowed meansurv option with rmst for covariate-adjusted RMST calc with meansurv.
PL 29JUL2014: fixed bug in meansurv option that did not allow the use of factor variables
PL 03JAN2014: Added meansurvwt() option to allow external standardization when using meansurv.
PL 09DEC2013: Added if2() option to increase possibilities when using predictnl
PL 21NOV2013: fixed another bug when using factor variables with interactions.
PL 28AUG2013: fixed bug when using hrnum etc with factor variables with continuous interactions.
PL 20JAN2013: added predictions for loss in expectation of life for relative survival models.
PL 20JAN2013: added predictions for log link.
PL 19JUN2012: fixed bug with centile option when df() and dftvc() had different values.
PL 12Feb2012: added failure option (1-S(t)).
PR 09sep2011: rmst now works with factor variables.
PL 08sep2011: fixed bug in centiles for uncured in cure models / PR rmst update
PL 15aug2011: if timevar variable = 0 then survival is predicted to be 1 rather than missing.
PR 26may2011: undocumented option nliter() to set option iterate() in predictnl for rmst.
		If not set, predictnl's default iterate(100) is used. For simulations, it may
		be good to take nliter(0) or nliter(some small integer) to avoid long run times.
PR 09apr2011: hidden option power() of _rmst subroutine not implemented as option for predict
PR 25feb2011: add rmst and abc options for mean survival time and area between curves
PR 25feb2011: add stdp option to various predict options
PL 29NOV2010: fixed bug when using meansurv option with a null model.
PL 07Nov2010: corrected bug that caused error if tempory folder had spaces.
PL 01Nov2010: introduced factor variables.
PL 02sep2010: added Therese Anderssons additions for prediction after fitting a cure model
PL 15mar2010: added reverse option to spline generation
PL 01feb2010: change to Stata 11.
PL 12nov2009: added tvc option
PL 21sep2009: ensure predictions work with new rcsbaselineoff option in stpm2.
PL 08Sep2009: modification of msurvpop to work in Stata 11.
PL 12Mar2009: changed to using Newton-Raphson method for estimating centiles.
PL 11Mar2009: fixed problem with strings>244 characters for long varlists.
PL 11dec2008: changed to using rcsgen for spline functions.
PL 20aug2008: Added hdiff1 and hdiff2 options for difference in survival curves.
PL 20aug2008: Added hdiff1 and hdiff2 options for difference in survival curves.
PL 09aug2008: Fixed bug for some predictions involving time-dependent effects.
*/	

program stpm2_pred, sortpreserve
	version 11.1
	syntax newvarname [if] [in], [Survival Hazard XB XBNOBaseline DXB DZDY HRNumerator(string) HRDenominator(string) MEANSurv ///
									CENtile(string) CUMHazard CUMOdds NORmal MARTingale DEViance DENSity AT(string) ATVAR(string) ///
									ZEROs FAILure ///
									noOFFset SDIFF1(string) SDIFF2(string) HDIFF1(string) HDIFF2(string) tvc(varname) ///
									CI LEVel(real `c(level)') TIMEvar(varname) STDP PER(real 1)  ///
									CENTOL(real 0.0001) Cure UNCured STARTUNC(real -1) ///
									RMst RSDst TMAx(string) TMIn(string) n(int 1000) POWer(real 1) ABc hr0(string) first(int 1) ///
									NLiter(string) CENTITER(int 100) ///
									MERGEBY(string) DIAGAge(name) DIAGYear(name) BY(string) MAXYear(int 2050) ///
									ATTAge(name) ATTYear(name) ID(name) MAXAge(int 99) NOBS(int 100) MAXT(real 10) ///
									SURVProb(name) LIFelost OBSSurv GRpd STub(string) EXPSurv(name) ///
									NODEs(int 50) TINF(int 50) TCOND(int 0) ///
									IF2(string) noCOLLAPSEMEANSURV  *]									

	local newvarname `varlist'
	
	if "`if'" != "" & "`if2'" != "" {
		di in green "WARNING: if statement has been replaced by expression in if2() option"
	}	
	if "`if2'" != "" { 
		local if `if2'
	}
	marksample touse, novarlist
	
	local 0 `", `options'"'
	syntax [,MEANSURVWT(passthru) MEANHAZard MEANFT USIng(string)]

	qui count if `touse'
	if r(N)==0 {
		error 2000          /* no observations */
	}
	
/* Check Options */
/* First check rmst options */
	if "`tmax'" != "" {
		if "`rmst'`rsdst'`abc'" == "" {
			display as error "tmax() valid only with rmst, rsdst or abc"
			exit 198
		}
	  if "`rsdst'" != "" local rmst rmst
	}
	else local tmax .
	// ! PR: allow meansurv with rmst to permit rmst adjusted for covariates
	if "`meansurv'"!="" & "`rmst'"!="" {
		local meansurvrmst meansurv
		local meansurv
	}
	// ! end PR insert

	if "`tmin'" != "" {
		if "`rmst'`rsdst'`abc'" == "" {
			display as error "tmin() valid only with rmst, rsdst or abc"
			exit 198
		}
		confirm number `tmin'
		if `tmin' < 0 {
			display as error "tmin() may not be negative"
			exit 198
		}
		if `tmin' > 0 & "`rsdst'" != "" {
			display as error "rsdst not supported for tmin() > 0"
			exit 198
		}	
	}
	else local tmin 0
	if "`hr0'" != "" {
		if "`rmst'`abc'" == "" {
			display as error "hr0() valid only with rmst or abc"
			exit 198
		}
		cap confirm var `hr0'
		if c(rc) {
			cap confirm number `hr0'
			if c(rc) {
				display as error "hr0() must be a numeric constant or variable"
				exit 198
			}
			if `hr0' <= 0 {
				display as error "hr0() must exceed 0"
				exit 198
			}
		}
	}
	
	if "`hrdenominator'" != "" & "`hrnumerator'" == "" {
		display as error "You must specifiy the hrnumerator option if you specifiy the hrdenominator option"
		exit 198
	}

	if "`sdiff2'" != "" & "`sdiff1'" == "" {
		display as error "You must specifiy the sdiff1 option if you specifiy the sdiff2 option"
		exit 198
	}

	if "`hdiff2'" != "" & "`hdiff1'" == "" {
		display as error "You must specifiy the hdiff1 option if you specifiy the hdiff2 option"
		exit 198
	}
	
	local hratiotmp = substr("`hrnumerator'",1,1)
	local sdifftmp = substr("`sdiff1'",1,1)
	local hdifftmp = substr("`hdiff1'",1,1)
	if wordcount(`"`survival' `hazard' `failure' `meansurv' `meanhazard' `meanft' `hratiotmp' `sdifftmp' `hdifftmp' `centile' `xb' `xbnobaseline' `dxb' `dzdy' `martingale' `deviance' `cumhazard' `cumodds' `normal' `density' `tvc' `cure' `rmst'  `obssurv' `lifelost'"') > 1 {
		display as error "You have specified more than one option for predict"
		exit 198
	}
	if wordcount(`"`survival' `hazard' `failure' `meansurv' `meanhazard' `meanft' `hrnumerator' `sdiff1'  `hdifftmp' `centile' `xb' `xbnobaseline' `dxb' `dzdy' `martingale' `deviance' `cumhazard' `cumodds' `normal' `density' `tvc' `cure' `rmst' `abc'  `obssurv' `lifelost'"') == 0 {
		display as error "You must specify one of the predict options"
		exit 198
	}
	
	if `per' != 1 & "`hazard'" == "" & "`hdiff1'" == "" & "`meanhazard'" == ""{
		display as error "You can only use the per() option in combination with the hazard, hdiff1()/hdiff2() or meanhazard options."
		exit 198		
	}

	if "`stdp'" != "" & "`ci'" != "" {
		display as error "You can not specify both the ci and stdp options."
		exit 19
	}
	
	if "`stdp'" != "" & ///
		wordcount(`"`xb' `dxb' `xbnobaseline' `rmst' `abc' `hrnumerator' `hdiff1' `sdiff1'"') == 0 {
		display as error "The stdp option cannot be used with this predict option."
		exit 198
	}

	if "`ci'" != "" & ///
		wordcount(`"`survival' `hazard' `failure' `hrnumerator' `sdiff1' `hdiff1' `centile' `xb' `dxb' `xbnobaseline' `tvc' `meansurv' `meanhazard' `cure' `rmst' `abc'  `obssurv' `lifelost'"') == 0 {
		display as error "The ci option can not be used with this predict option."
		exit 198
	}
	
	if "`zeros'" != "" & ("`meansurv'" != "" | "`meanhazard'" != "" | "`meanft'" != "") {
		display as error "You can not specify the zero option with the `meansurv'`meanhazard'`meanft' option."
		exit 198
	}

	if "`zeros'" != "" & "`tvc'" != "" {
		display as error "You can not specify the zero option with the tvc option."
		exit 198
	}

	if "`zeros'" != "" & ("`hrnumerator'" != "" | "`hdiff1'" != "" | "`sdiff1'" != "") {
		display as error "You can not specify the zero option with the hrnumerator, hdiff or sdiff options."
		exit 198
	}

	if "`zeros'" != "" & ("`obssurv'" != "" | "`lifelost'" != "") {
		display as error "You can not specify the zero option with the obssurv or lifelost options."
		exit 198
	}
	
	if ("`at'" != "" | "`atvar'" != "") & "`hrnumerator'" != "" {
		display as error "You can not use the at() or atvar() options with the hrnumerator option"
		exit 198
	}

	if ("`at'" != "" | "`atvar'" != "") & "`sdiff1'" != "" {
		display as error "You can not use the at() option with the sdiff1 and sdiff2 options"
		exit 198
	}
	
	if ("`at'" != "" | "`atvar'" != "") & "`hdiff1'" != "" {
		display as error "You can not use the at() option with the hdiff1 and hdiff2 options"
		exit 198
	}

	if "`at'" != "" & ("`obssurv'" != "" | "`lifelost'" != "") {
		display as error "You can not specify the at option with the obssurv or lifelost options."
		exit 198
	}
	
	if "`timevar'" != "" & ("`obssurv'" != "" | "`lifelost'" != "") {
		display as error "You can not specify the timevar option with the obssurv or lifelost options."
		exit 198
	}
	if ("`uncured'" != "" | "`cure'" != "") &  "`e(cure)'" == "" {
		display as error "You can only use the cure and uncured options after fitting a cure model"
		exit 198
	}
	
	if "`uncured'" != "" & "`survival'" == "" & "`hazard'" == "" & "`centile'" == "" & "`meansurv'" == "" {
		display as error "You must specify the survival, hazard or centile option if you specify uncured"
		exit 198
	}


	if ("`meansurv'" == "" & "`meanhazard'" == "" & "`meanft'" == "") & "`meansurvwt'" != "" {
		display as error "You must specify the meansurv() option when using meansurvwt()."
		exit 198
	}
/* call Stmeancurve if meansurv option specified */
	if "`meansurv'" != "" | "`meanhazard'" !="" | "`meanft'" != "" {
		Stmeancurve `newvarname' if `touse', timevar(`timevar') at(`at') atvar(`atvar') `collapsemeansurv' `meansurvwt' `meanhazard' `meanft' `ci' `offset' `uncured' level(`level') per(`per')
		exit
	}

/* options for obssurv and lifelost */
	if "`obssurv'" != "" | "`lifelost'" != "" {
		if "`diagage'" == "" {
			local diagage agediag
		}
		capture confirm variable `diagage'
		if _rc>0 {
			display as error "Age at diagnosis variable, `diagage', does not exist. Specify using the diagage() option."
			exit 198
		}
		if "`diagyear'" == "" {
			local diagyear yeardiag
		}
		capture confirm variable `diagyear'
		if _rc>0 {
			display as error "Year at diagnosis variable, `diagyear', does not exist. Specify using the diagyear() option."
			exit 198
		}
		if "`mergeby'" == "" {
			display "You need to specify the mergeby() when using the lifelost/obssurv options to merge in the population mortality file."
			exit 198
		}
		if "`using'" == "" {
			display "You need to specify the using() option to give the population mortality filename."
			exit 198
		}
		capture qui desc using `"`using'"', varlist
		local using_varlist `r(varlist)'
		if _rc == 601 {
			display "File specified in using() option does not exist."
			exit 198
		}
		foreach mvar in `mergeby' {
			if `"`: list posof `"`mvar'"' in using_varlist'"' == "0" { 
				display as error "Variable `mvar' specified in mergeby() option does not exist in using dataset."
				exit 198
			}
		}
		capture confirm variable _merge
		if _rc==0 {
			display as error "Variable _merge exists and needs to be dropped to use the lifelost/obssurv options."
			exit 198			
		}
		if "`attage'" == "" {
			local attage _age
		}
		novarabbrev capture confirm variable `attage'
		if _rc == 0 {
			display as error "Attained age variable `attage' already exists in dataset. Delete or rename. See the attage() option."
			exit 198
		}
		if "`attyear'" == "" {
			local attyear _year
		}		
		novarabbrev capture confirm variable `attyear'
		if _rc == 0 {
			display as error "Attained year variable `attyear' already exists in dataset. Delete or rename. See the attyear() option."
			exit 198
		}
	} 

/* call Stobssurv if obssurv option specified */
	if "`obssurv'" != "" {
		Stobssurv `newvarname' if `touse', timevar(`timevar') `offset' mergeby(`mergeby') diagage(`diagage') diagyear(`diagyear') ///
						by(`by') attage(`attage') attyear(`attyear') id(`id') maxage(`maxage') maxyear(`maxyear') `ci' level(`level') ///
						survprob(`survprob') using(`"`using'"') `grpd' nobs(`nobs') maxt(`maxt') expsurv(`expsurv')
		exit
	}

/* call Stlifelost if lifelost option specified */
	if "`lifelost'" != "" {
		Stlifelost `newvarname' if `touse', `offset' mergeby(`mergeby') diagage(`diagage') diagyear(`diagyear') ///
						by(`by') attage(`attage') attyear(`attyear') maxage(`maxage') maxyear(`maxyear') `ci' level(`level') ///
						survprob(`survprob') using(`"`using'"') `grpd' stub(`stub') tinf(`tinf') nodes(`nodes') tcond(`tcond')
		exit
	}
	
/* call _rmst (formerly stpm2_mttf) for SE and CI if rmst option specified */
/* call _rmst (formerly stpm2_mttf) for SE and CI if rmst option specified */
	if ("`rmst'" != "") & ("`meansurvrmst'" != "") {
		// rmst meansurv allows >1 values of tmax
		// !! ?? add numlist parse of tmax() - done anyway by _rmst_meansurv
		if "`at'" != "" local At at(`at')
		cap confirm var `newvarname'
		if c(rc) != 0 {
			 _rmst_meansurv if `touse', tmin(`tmin') tmax(`tmax') generate(`newvarname') ///
			 `At' `zeros' n(`n') `rsdst'
			 if "`ci'`stdp'" == "" {
				exit
			}
		}
		cap drop `newvarname'
		if "`ci'" != "" {
			local predictnl_opts , ci(`newvarname'_lci `newvarname'_uci)
		}
		else if "`stdp'" != "" {
			local predictnl_opts , se(`newvarname'_se)
		}
		if "`nliter'"!="" local nli iterate(`nliter')
		else local nli

		qui predictnl `newvarname' = predict(rmst tmin(`tmin') tmax(`tmax') ///
		 `At' `zeros' n(`n') `rsdst' meansurv) `nli' if `touse' ///
		 `predictnl_opts' /* force */
		exit
	}
	if "`rmst'" != "" {
		if !missing(`tmax') {
			confirm number `tmax'
			if `tmax' <= 0 {
				display as error "tmax() must be positive"
				exit 198
			}
		}
		// else local tmax
		if "`at'" != "" local At at(`at')
		if ("`meansurvrmst'" != "") local meansurv meansurv
		cap confirm var `newvarname'
		if c(rc) != 0 {
			 _rmst if `touse', tmin(`tmin') tmax(`tmax') generate(`newvarname') ///
			 `At' `zeros' n(`n') power(`power') `rsdst' `meansurv'			
			 if "`ci'`stdp'" == "" {
				exit
			}
		}
		cap drop `newvarname'
		if "`ci'" != "" {
			local predictnl_opts , ci(`newvarname'_lci `newvarname'_uci)
		}
		else if "`stdp'" != "" {
			local predictnl_opts , se(`newvarname'_se)
		}
		if "`nliter'"!="" local nli iterate(`nliter')
		else local nli

		if !missing(`tmax') local Tmax tmax(`tmax')
		qui predictnl `newvarname' = predict(rmst tmin(`tmin') `Tmax' ///
		 `At' `zeros' n(`n') power(`power') `rsdst' `meansurv') `nli' if `touse' ///
		 `predictnl_opts' force
		exit
	}
	if "`abc'" != "" {
		// if "`at'" != "" local At at(`at')
		if "`hrdenominator'" != "" local hrd hrdenominator(`hrdenominator')
		if `first' local wt wt
		else local wt
		if "`tmin'" != "" local tmin tmin(`tmin')
		if "`hr0'" != "" local hr0 hr0(`hr0')

		cap confirm var `newvarname', exact
		if c(rc) != 0 { // `newvarname' does not exist
			qui _abc `newvarname' if `touse', `hr0' hrnumerator(`hrnumerator') `hrd' ///
			 tmax(`tmax') `tmin' `At' `zeros' n(`n') `wt'
			cap drop _weight
			if "`ci'`stdp'" == "" {
				*cap erase _predict_weights.dta
				exit
			}
		}
		cap drop `newvarname'
		if "`ci'" != "" {
			local predictnl_opts ci(`newvarname'_lci `newvarname'_uci)
		}
		else if "`stdp'" != "" {
			local predictnl_opts se(`newvarname'_se)
		}
		cap predictnl double `newvarname' = predict(abc `hr0' hrnumerator(`hrnumerator') `hrd' ///
		 tmax(`tmax') `tmin' `At' `zeros' n(`n') first(0)) if `touse', `predictnl_opts' level(`level')
		local rc = c(rc)
		// Tidy up weight variable and temporary file created by _abc
		cap drop _weight
		cap erase _predict_weights.dta
		if `rc' {
			noi di as err "could not estimate SE or CI - predictnl failed to converge"
			exit 498
		}
		else exit
	}
	
/* calculate midt for centile option */
	summ _t, meanonly
	local midt = (r(max) - r(min))/2
	
/* calculate startt for centile option if uncured option is specified*/
	/*
	if `startunc' == -1 {
		summ _t, meanonly
	 	local startt = (r(max) - r(min))/8
	}
	else {
		local startt = `startunc'
	}
	*/
/* store time-dependent covariates and main varlist */
	local etvc `e(tvc)'
	local main_varlist `e(varlist)'
		
/* dydx option of old version of stpm */
	if "`dzdy'" != "" {
		local dxb dxb
	}
/* generate ocons for use when orthogonalising splines */
	tempvar ocons
	gen `ocons' = 1
	
/* Use _t if option timevar not specified */
	tempvar t lnt 
	if "`timevar'" == "" {
		qui gen double `t' = _t if `touse'
		qui gen double `lnt' = ln(_t) if `touse'
	}
	else {
		qui gen double `t' = `timevar' if `touse'
		qui gen double `lnt' = ln(`timevar') if `touse'
	}
	
/* Check to see if nonconstant option used */
	if "`e(noconstant)'" == "" {
		tempvar cons
		qui gen `cons' = 1 if `touse'
	}	

/* Preserve data for out of sample prediction  */	
	tempfile newvars 
	preserve

/* Calculate new spline terms if timevar option specified */
	if "`timevar'" != "" & "`e(rcsbaseoff)'" == "" {
		capture drop _rcs* _d_rcs*
		if "`e(orthog)'" != "" {
			tempname rmatrix
			matrix `rmatrix' = e(R_bh)
			local rmatrixopt rmatrix(`rmatrix')
		}
		qui rcsgen `lnt' if `touse', knots(`e(ln_bhknots)') gen(_rcs) dgen(_d_rcs) `e(reverse)' `rmatrixopt' `e(nosecondder)' `e(nofirstder)'
	}
	
/* calculate new spline terms if timevar option or hrnumerator option is specified */

	if "`timevar'" != "" | "`hrnumerator'" != "" | "`sdiff1'" != "" | "`hdiff1'" != "" {
		foreach tvcvar in `e(tvc)' {
			if (("`hrnumerator'" != "" | "`sdiff1'" != "" | "`hdiff1'" != "") & "`timevar'" == "") | "`e(rcsbaseoff)'" != "" {
				capture drop _rcs_`tvcvar'* _d_rcs_`tvcvar'*
			}
			if "`e(orthog)'" != "" {
				tempname rmatrix_`tvcvar'
				matrix `rmatrix_`tvcvar'' = e(R_`tvcvar')
				local rmatrixopt rmatrix(`rmatrix_`tvcvar'')
			}
			qui rcsgen `lnt' if `touse',  gen(_rcs_`tvcvar') knots(`e(ln_tvcknots_`tvcvar')') dgen(_d_rcs_`tvcvar') `e(reverse)' `rmatrixopt' `e(nosecondder)' `e(nofirstder)'
			if "`hrnumerator'" == "" & "`sdiff1'"  == "" & "`hdiff1'" == "" {
				forvalues i = 1/`e(df_`tvcvar')'{
					qui replace _rcs_`tvcvar'`i' = _rcs_`tvcvar'`i'*`tvcvar' if `touse'
					qui replace _d_rcs_`tvcvar'`i' = _d_rcs_`tvcvar'`i'*`tvcvar' if `touse'
				}
			}

		}
	}	
	
/* zeros */
	if "`zeros'" != "" {
		local tmptvc `e(tvc)'
		foreach var in `e(varlist)' {
			_ms_parse_parts `var'
			if `"`: list posof `"`r(name)'"' in at'"' == "0" { 
				qui replace `r(name)' = 0 if `touse'
				if `"`: list posof `"`r(name)'"' in tmptvc'"' != "0" { 
				forvalues i = 1/`e(df_`r(name)')' {
						qui replace _rcs_`r(name)'`i' = 0 if `touse'
						qui replace _d_rcs_`r(name)'`i' = 0 if `touse'
					}
				}
			}
		}
	}

/* Out of sample predictions using at() */
	if "`at'" != "" {
		tokenize `at'
		while "`1'"!="" {
			if "`1'" == "." continue, break
			fvunab tmpfv: `1'
			local 1 `tmpfv'
			_ms_parse_parts `1'
			if "`r(type)'"!="variable" {
				display as error "level indicators of factor" /*
								*/ " variables may not be individually set" /*
								*/ " with the at() option; set one value" /*
								*/ " for the entire factor variable"
				exit 198
			}
			cap confirm var `1'
			if _rc {
				di "`1' is not in the data set"
			}
			if "`2'" != "=" {
				if _rc {
					cap confirm num `2'
					if _rc {
						di as err "invalid at(... `1' `2' ...)"
						exit 198
					}
				}
				qui replace `1' = `2' if `touse'
				local shift 2
			}
			else {
				cap confirm var `3'
				if _rc {
					di as err "`var' is not in the data set"
					exit 198
				}
				qui replace `1' = `3' if `touse'
				local shift 3
			}
			if `"`: list posof `"`1'"' in etvc'"' != "0" {
				local tvcvar `1'
				if "`e(orthog)'" != "" {
					tempname rmatrix_`tvcvar'
					matrix `rmatrix_`tvcvar'' = e(R_`tvcvar')
					local rmatrixopt rmatrix(`rmatrix_`tvcvar'')
				}
				capture drop _rcs_`tvcvar'* _d_rcs_`tvcvar'*
				qui rcsgen `lnt' if `touse', knots(`e(ln_tvcknots_`tvcvar')') gen(_rcs_`tvcvar') dgen(_d_rcs_`tvcvar') `e(reverse)' `rmatrixopt' `e(nosecondder)' `e(nofirstder)'
				forvalues i = 1/`e(df_`tvcvar')'{
					qui replace _rcs_`tvcvar'`i' = _rcs_`tvcvar'`i'*`tvcvar' if `touse'
					qui replace _d_rcs_`tvcvar'`i' = _d_rcs_`tvcvar'`i'*`tvcvar' if `touse'
				}
			}
			mac shift `shift'
		}
	}

/* Add offset term if exists unless no offset option is specified */
	if "`e(offset1)'" !=  "" & /* !! PR */ "`offset'" != "nooffset" {
		local addoff "+ `e(offset1)'" 
	}

/* check ci and stdp options */
	if "`ci'" != "" & "`stdp'" != "" {
		display as error "Only one of the ci and se options can be specified"
		exit 198
	}
	
/* Deviance and Martingale Residuals */
	if "`deviance'" != "" | "`martingale'" != "" {
		tempvar cH res
		qui predict `cH' if `touse', cumhazard timevar(`t')  `offset'
		gen double `res' = _d - `cH' if `touse'
		if "`deviance'" != "" {
			gen double `newvarname' = sign(`res')*sqrt( -2*(`res' + _d*(ln(_d -`res')))) if `touse'
        }
        else rename `res' `newvarname'
	}
	
/* Failure (1-S(t)) */
	else if "`failure'" != "" {
		qui predict `newvarname' if `touse', s timevar(`t')  `offset' ci
		qui replace `newvarname' = 1 - `newvarname' if `touse'
		tempvar tmpSt
		qui gen double `tmpSt' = 1 - `newvarname'_uci if `touse'
		qui replace `newvarname'_uci = 1 - `newvarname'_lci if `touse'
		qui replace `newvarname'_lci = `tmpSt' if `touse'
	}

/* Cumulative Hazard */
	else if "`cumhazard'" != "" {
		tempvar S
		predict `S' if `touse', s timevar(`t')  `offset'
		gen double `newvarname' = -ln(`S') if `touse'
	}

/* Cumulative Odds */
	else if "`cumodds'" != "" {
		tempvar S
		predict `S' if `touse', s timevar(`t') /* !! pr */ `offset'
		gen double `newvarname' = (1 -`S')/`S' if `touse'
	}
	
/* Standard Normal Deviate */
	else if "`normal'" != "" {
		tempvar S
		predict `S' if `touse', s timevar(`t') /* !! pr */ `offset'
		gen double `newvarname' = -invnormal(`S') if `touse'
	}
	
/* density */
	else if "`density'" != "" {
		tempvar S h
		predict  `S' if `touse', s timevar(`t') /* !! pr */ `offset'
		predict  `h' if `touse', h timevar(`t') /* !! pr */ `offset'
		gen double `newvarname' = `S'*`h' if `touse'
	}	
	
/* linear predictor */	
	else if "`xb'" != "" {
		if "`ci'" != "" {
			local prednlopt ci(`newvarname'_lci `newvarname'_uci)
		}
		else if "`stdp'" != "" {
			local prednlopt se(`newvarname'_se)
		}
		qui predictnl double `newvarname' = xb(xb) `addoff' if `touse', `prednlopt' level(`level')
	}
			
/* derivative of linear predictor */	
	else if "`dxb'" != "" {
		if "`ci'" != "" {
			local prednlopt ci(`newvarname'_lci `newvarname'_uci)
		}
		else if "`stdp'" != "" {
			local prednlopt se(`newvarname'_se)
		}
		qui predictnl double `newvarname' = xb(dxb) if `touse', `prednlopt' level(`level')
	}
	
/* linear predictor exluding spline terms */
	else if "`xbnobaseline'" != "" {
		if "`ci'" != "" {
			local prednlopt ci(`newvarname'_lci `newvarname'_uci)
		}
		else if "`stdp'" != "" {
			local prednlopt se(`newvarname'_se)
		}
/* commented out for now - ignores the constant (gamma_0) - may be needed later
		if "`e(noconstant)'" == "" {	
			local xbnobhpred [xb][_cons]
		}	
*/
		foreach var in `e(varlist)' {
			if "`xbnobhpred'" == "" {
				local xbnobhpred [xb][`var']*`var'
			}
			else {
				local xbnobhpred `xbnobhpred' + [xb][`var']*`var'
			}
			if `"`: list posof `"`var'"' in etvc'"' != "0" {
				forvalues i = 1/`e(df_`var')' {
					local xbnobhpred `xbnobhpred' + [xb][_rcs_`var'`i']*_rcs_`var'`i'
				}
			}
		}
*		if "`e(noconstant)'" != "" {	
*			local xbnobhpred = subinstr("`xbnobhpred'","+","",1) 
*		}
		predictnl double `newvarname' = `xbnobhpred' if `touse', `prednlopt' level(`level')
	}
	
/* tvc option */
	else if "`tvc'" != "" {
		if "`ci'" != "" {
			local prednlopt ci(`newvarname'_lci `newvarname'_uci)
		}
		else if "`stdp'" != "" {
			local prednlopt se(`newvarname'_se)
		}
		local tvcpred [xb][`tvc']*`tvc'
		if `"`: list posof `"`tvc'"' in etvc'"' != "0" {
			forvalues i = 1/`e(df_`tvc')' {
				local tvcpred `tvcpred' + [xb][_rcs_`tvc'`i']*_rcs_`tvc'`i'
			}
		}
		predictnl double `newvarname' = (`tvcpred') if `touse', `prednlopt' level(`level')
	}
		
/* Survival Function */
	else if "`survival'" != "" & "`uncured'" == "" {
		tempvar sxb 
		if "`ci'" != "" {
			tempvar sxb_lci sxb_uci
			local prednlopt ci(`sxb_lci' `sxb_uci')
		}
		if "`e(scale)'" != "theta" {
			qui predictnl double `sxb' = xb(xb) `addoff' if `touse', `prednlopt' level(`level') 
		}
/* predict on ln(-ln S(t)) scale for theta */
		else if "`e(scale)'" == "theta" {
			qui predictnl double `sxb' = ln(ln(exp(xb(ln_theta))*exp(xb(xb)`addoff')+1)/exp(xb(ln_theta))) if `touse', `prednlopt'  level(`level') 		
		}
/* Transform back to survival scale */
		if "`e(scale)'" == "hazard" {
			qui gen double `newvarname' = exp(-exp(`sxb')) if `touse'
			if "`ci'" != "" {
				qui gen `newvarname'_lci = exp(-exp(`sxb_uci'))  if `touse'
				qui gen `newvarname'_uci =  exp(-exp(`sxb_lci')) if `touse'
			}
		}
		else if "`e(scale)'" == "odds" {
			qui gen double `newvarname' = (1 +exp(`sxb'))^(-1) if `touse'
			if "`ci'" != "" {
				qui gen `newvarname'_lci = (1 +exp(`sxb_uci'))^(-1) if `touse'
				qui gen `newvarname'_uci = (1 +exp(`sxb_lci'))^(-1) if `touse'
			}
		}
		else if "`e(scale)'" == "normal" {
			qui gen double `newvarname' = normal(-`sxb') if `touse'
			if "`ci'" != "" {
				qui gen `newvarname'_lci = normal(-`sxb_uci') if `touse'
				qui gen `newvarname'_uci = normal(-`sxb_lci') if `touse' 
			}
		}		
		else if "`e(scale)'" == "log" {
			qui gen double `newvarname' = 1 - exp(`sxb') if `touse'
				if "`ci'" != "" {
				qui gen `newvarname'_lci = 1 - exp(`sxb_uci') if `touse'
				qui gen `newvarname'_uci = 1 - exp(`sxb_lci') if `touse' 
			}
		}		
		else if "`e(scale)'" == "theta" {
			qui gen double `newvarname' = exp(-exp(`sxb')) if `touse'
			if "`ci'" != "" {
				qui gen `newvarname'_lci = exp(-exp(`sxb_lci')) if `touse'
				qui gen `newvarname'_uci = exp(-exp(`sxb_uci')) if `touse' 
			}
		}
	
		qui replace `newvarname' = 1 if `t' == 0 & `touse'
		if "`ci'" != "" {
			qui replace `newvarname'_lci = 1 if `t' == 0 & `touse'
			qui replace `newvarname'_uci = 1 if `t' == 0 & `touse'
		}
	}

/* Hazard Function */
	else if "`hazard'" != "" & "`uncured'" == "" {
		tempvar lnh 
		if "`ci'" != "" {
			tempvar lnh_lci lnh_uci
			local prednlopt ci(`lnh_lci' `lnh_uci')
		}
		if "`e(scale)'" == "hazard" {
			qui predictnl double `lnh' = -ln(`t') + ln(xb(dxb)) + xb(xb) `addoff'  if `touse', `prednlopt' level(`level') 
		}
		if "`e(scale)'" == "odds" {
			qui predictnl double `lnh' = -ln(`t') + ln(xb(dxb)) + (xb(xb)`addoff')  -ln(1+exp(xb(xb)`addoff'))   if `touse', `prednlopt' level(`level') 
		}		
		if "`e(scale)'" == "normal" {
			qui predictnl double `lnh' = -ln(`t') + ln(xb(dxb)) + ln(normalden(xb(xb)`addoff')) - ln(normal(-(xb(xb)`addoff')))   if `touse', `prednlopt' level(`level') 
		}		
		if "`e(scale)'" == "log" {
			qui predictnl double `lnh' = -ln(`t') + ln(xb(dxb)) + xb(xb) -ln(1-exp(xb(xb))) `addoff'  if `touse', `prednlopt' level(`level') 
		}
		if "`e(scale)'" == "theta" {
			qui predictnl double `lnh' = -ln(`t') + ln(xb(dxb)) + xb(`xb') - ln(exp(xb(ln_theta))*exp(xb(xb)`addoff') + 1)  if `touse', `prednlopt' level(`level') 
		}		

/* Transform back to hazard scale */
		qui gen double `newvarname' = exp(`lnh')*`per' if `touse'
		if "`ci'" != "" {
			qui gen `newvarname'_lci = exp(`lnh_lci')*`per'  if `touse'
			qui gen `newvarname'_uci =  exp(`lnh_uci')*`per' if `touse'
		}
	}
	
/* Predict Hazard Ratio */
	else if "`hrnumerator'" != "" {
		tempvar lhr
		if `"`ci'"' != "" {
			tempvar lhr_lci lhr_uci
			local predictnl_opts ci(`lhr_lci' `lhr_uci')
		}
		else if "`stdp'" != "" {
			tempvar lhr_se
			local predictnl_opts se(`lhr_se')
		}		
		
		forvalues i=1/`e(dfbase)' {
			local dxb1 `dxb1' [xb][_rcs`i']*_d_rcs`i' 
			local dxb0 `dxb0' [xb][_rcs`i']*_d_rcs`i'
			local xb1_plus `xb1_plus' [xb][_rcs`i']*_rcs`i'
			local xb0_plus `xb0_plus' [xb][_rcs`i']*_rcs`i'
			if `i' != `e(dfbase)' {
				local dxb0 `dxb0' + 
				local dxb1 `dxb1' + 
				local xb1_plus `xb1_plus' +
				local xb0_plus `xb0_plus' +
			}
		}
		
/* use Parse_list to select appropriate values of factor variables */

		Parse_list, listname(hrnumerator) parselist(`hrnumerator')
		tokenize `r(retlist)'
		
		while "`1'"!="" {
			cap confirm var `2'
			if _rc {
				if "`2'" == "." {
					local 2 `1'
				}
				else {
					cap confirm num `2'
					/*
					if _rc {
						di as err "invalid hrnumerator(... `1' `2' ...)"
						exit 198
					}
					*/
					}
			}
			
			if "`xb10'" != "" & "`2'" != "0" & `: list posof `"`1'"' in main_varlist' != 0{
				local xb10 `xb10' +
			}
			if "`xb1_plus'" != "" & "`2'" != "0" &  `: list posof `"`1'"' in main_varlist' != 0{
				local xb1_plus `xb1_plus' +
			}

			if "`2'" != "0" & `: list posof `"`1'"' in main_varlist' != 0 {
				local xb10 `xb10' [xb][`1']*`2' 
				local xb1_plus `xb1_plus' [xb][`1']*`2' 
			}

			if `"`: list posof `"`1'"' in etvc'"' != "0" & "`2'" != "0" {
				if "`e(rcsbaseoff)'" == ""  | (`: list posof `"`1'"' in etvc'>1) {
					local dxb1 `dxb1' +
				}
				local xb10 `xb10' +
				local xb1_plus `xb1_plus' +

				forvalues i=1/`e(df_`1')' {
					local dxb1 `dxb1' [xb][_rcs_`1'`i']*_d_rcs_`1'`i'*`2' 
					local xb10 `xb10' [xb][_rcs_`1'`i']*_rcs_`1'`i'*`2'  
					local xb1_plus `xb1_plus' [xb][_rcs_`1'`i']*_rcs_`1'`i'*`2'  
					if `i' != `e(df_`1')' {
						local dxb1 `dxb1' +
						local xb10 `xb10' +
						local xb1_plus `xb1_plus' +
					}
				}
			}
			mac shift 2
		}			
			
		if "`hrdenominator'" != "" {
/* use Parse_list to select appropriate values of factor variables */
			Parse_list, listname(hrdenominator) parselist(`hrdenominator')
			tokenize `r(retlist)'
			while "`1'"!="" {
				cap confirm var `2'
				if _rc {
					if "`2'" == "." {
						local 2 `1'
					}
					else {
					/*
						cap confirm num `2'
						if _rc {
							di as err "invalid hrdenominator(... `1' `2' ...)"
							exit 198
						}
					*/
					}
				}
				if "`2'" != "0" & `: list posof `"`1'"' in main_varlist' != 0 {
					local xb10 `xb10' - [xb][`1']*`2'
					if "`e(rcsbaseoff)'" == "" & `: list posof `"`1'"' in main_varlist' != 0 {
						local xb0_plus `xb0_plus' + [xb][`1']*`2' 
					}
					else if `: list posof `"`1'"' in main_varlist' != 0 {
						local xb0_plus `xb0_plus' [xb][`1']*`2' 
					}
				}
				if `"`: list posof `"`1'"' in etvc'"' != "0" & "`2'" != "0" {
					if "`e(rcsbaseoff)'" == "" | (`: list posof `"`1'"' in etvc'>1) {
						local dxb0 `dxb0' +
					}
					local xb0_plus `xb0_plus' + 
					local xb10 `xb10' - 
					forvalues i=1/`e(df_`1')' {
						local dxb0 `dxb0' [xb][_rcs_`1'`i']*_d_rcs_`1'`i'*`2'
						local xb10 `xb10' [xb][_rcs_`1'`i']*_rcs_`1'`i'*`2'
						local xb0_plus `xb0_plus' [xb][_rcs_`1'`i']*_rcs_`1'`i'*`2'
						if `i' != `e(df_`1')' {
							local dxb0 `dxb0' +
							local xb10 `xb10' -
							local xb0_plus `xb0_plus' +
						}
					}
				}
				mac shift 2
			}
		}
		if "`e(noconstant)'" == "" {
			local xb0_plus `xb0_plus' + [xb][_cons]
			local xb1_plus `xb1_plus' + [xb][_cons]
		}

		if "`e(scale)'" =="hazard" {
			qui predictnl double `lhr' = ln(`dxb1') - ln(`dxb0') + `xb10' if `touse', `predictnl_opts' level(`level')
		}
		else if "`e(scale)'" =="odds" {
			qui predictnl double `lhr' =  	ln(`dxb1') - ln(`dxb0') + `xb10' - ///
											ln(1+exp(`xb1_plus')) + ln(1+exp(`xb0_plus')) ///
											if `touse', `predictnl_opts' level(`level')
		}
		else if "`e(scale)'" =="normal" {
			qui predictnl double `lhr' =  	ln(`dxb1') - ln(`dxb0') + ///
											ln(normalden(`xb1_plus')) - ln(normalden(`xb0_plus')) - ///
											ln(normal(-(`xb1_plus'))) + ln(normal(-(`xb0_plus'))) ///
											if `touse', `predictnl_opts' level(`level')
		}
		if "`e(scale)'" == "log" {
			qui predictnl double `lhr' = ln(`dxb1') - ln(`dxb0') + `xb10' /// 
										-ln(1-exp(`xb1_plus')) + ln(1-exp(`xb0_plus')) ///
										if `touse', `predictnl_opts' level(`level')
		}		
		else if "`e(scale)'" =="theta" {
			qui predictnl double `lhr' =  	ln(`dxb1') - ln(`dxb0') + `xb10' ///
											-ln(exp(xb(ln_theta))*exp(`xb1_plus') + 1) + ln(exp(xb(ln_theta))*exp(`xb0_plus') + 1) ///
											if `touse', `predictnl_opts' level(`level')
		}
		qui gen double `newvarname' = exp(`lhr') if `touse'
		if `"`ci'"' != "" {
			qui gen double `newvarname'_lci=exp(`lhr_lci')  if `touse'
			qui gen double `newvarname'_uci=exp(`lhr_uci')  if `touse'
		}
		else if "`stdp'" != "" {
			qui gen double `newvarname'_se = `lhr_se' * `newvarname'
		}
	}


/* Predict Difference in Hazard Functions */
	else if "`hdiff1'" != "" {
		if `"`ci'"' != "" {
			local predictnl_opts "ci(`newvarname'_lci `newvarname'_uci)"
		}
		else if "`stdp'" != "" {
			local predictnl_opts se(`newvarname'_se)
		}
		
		forvalues i=1/`e(dfbase)' {
			local dxb1 `dxb1' [xb][_rcs`i']*_d_rcs`i' 
			local dxb0 `dxb0' [xb][_rcs`i']*_d_rcs`i'
			local xb1_plus `xb1_plus' [xb][_rcs`i']*_rcs`i'
			local xb0_plus `xb0_plus' [xb][_rcs`i']*_rcs`i'
			if `i' != `e(dfbase)' {
				local dxb0 `dxb0' + 
				local dxb1 `dxb1' + 
				local xb1_plus `xb1_plus' +
				local xb0_plus `xb0_plus' +
			}
		}
/* use Parse_list to select appropriate values of factor variables */
		Parse_list, listname(hdiff1) parselist(`hdiff1')
		tokenize `r(retlist)'
		while "`1'"!="" {
			cap confirm var `2'
			if _rc {
				if "`2'" == "." {
					local 2 `1'
				}
				else {
					/*
					cap confirm num `2'
					if _rc {
						di as err "invalid hdiff1(... `1' `2' ...)"
						exit 198
					}
					*/
				}
			}
			if "`xb1_plus'" != "" & "`2'" != "0" & `: list posof `"`1'"' in main_varlist' != 0 {
				local xb1_plus `xb1_plus' +
			}
			if "`2'" != "0" & `: list posof `"`1'"' in main_varlist'!=0 {
				local xb1_plus `xb1_plus' [xb][`1']*`2' 
			}
			if `"`: list posof `"`1'"' in etvc'"' != "0" & "`2'" != "0" {
				if "`e(rcsbaseoff)'"  == "" {
					local dxb1 `dxb1' +
				}
				local xb1_plus `xb1_plus' +
				local xb10 `xb10' +

				forvalues i=1/`e(df_`1')' {
					local dxb1 `dxb1' [xb][_rcs_`1'`i']*_d_rcs_`1'`i'*`2' 
					local xb1_plus `xb1_plus' [xb][_rcs_`1'`i']*_rcs_`1'`i'*`2'  
					if `i' != `e(df_`1')' {
						local dxb1 `dxb1' +
						local xb1_plus `xb1_plus' +
					}
				}
			}
			mac shift 2
		}			
		if "`hdiff2'" != "" {
/* use Parse_list to select appropriate values of factor variables */
		Parse_list, listname(hdiff2) parselist(`hdiff2')
		tokenize `r(retlist)'
			while "`1'"!="" {
				cap confirm var `2'
				if _rc {
					if "`2'" == "." {
						local 2 `1'
					}
					else {
						/*
						cap confirm num `2'
						if _rc {
							di as err "invalid hdiff2(... `1' `2' ...)"
							exit 198
						}
						*/
					}
				}
				if "`2'" != "0" {
					if "`e(rcsbaseoff)'" == "" & `: list posof `"`1'"' in main_varlist' != 0 {
						local xb0_plus `xb0_plus' + [xb][`1']*`2' 
					}
					else if `: list posof `"`1'"' in main_varlist' != 0 {
						local xb0_plus `xb0_plus' [xb][`1']*`2' 
					}
				}
				if `"`: list posof `"`1'"' in etvc'"' != "0" & "`2'" != "0" {
					if "`e(rcsbaseoff)'" == "" {
						local dxb0 `dxb0' +
					}
					local xb0_plus `xb0_plus' + 
					forvalues i=1/`e(df_`1')' {
						local dxb0 `dxb0' [xb][_rcs_`1'`i']*_d_rcs_`1'`i'*`2'
						local xb0_plus `xb0_plus' [xb][_rcs_`1'`i']*_rcs_`1'`i'*`2'
						if `i' != `e(df_`1')' {
							local dxb0 `dxb0' +
							local xb0_plus `xb0_plus' +
						}
					}
				}
				mac shift 2
			}
		}
		if "`e(noconstant)'" == "" {
			local xb0_plus `xb0_plus' + [xb][_cons]
			local xb1_plus `xb1_plus' + [xb][_cons]
		}
		if "`e(scale)'" =="hazard" {
			qui predictnl double `newvarname' = (1/`t' * (`dxb1')*exp(`xb1_plus') - 1/`t' * (`dxb0')*exp(`xb0_plus'))*`per' ///
												if `touse', `predictnl_opts' level(`level')
		}
		else if "`e(scale)'" =="odds" {
			qui predictnl double `newvarname' =  (1/`t' *(`dxb1')*exp(`xb1_plus')/((1 + exp(`xb1_plus'))) - ///
												1/`t' *(`dxb0')*exp(`xb0_plus')/((1 + exp(`xb0_plus'))))*`per' ///
												if `touse', `predictnl_opts' level(`level')
		}
		else if "`e(scale)'" =="normal" {
				qui predictnl double `newvarname' = (1/`t' *(`dxb1')*normalden(`xb1_plus')/normal(-(`xb1_plus')) - /// 
													1/`t' *(`dxb0')*normalden(`xb0_plus')/normal(-(`xb0_plus')))*`per' ///
													if `touse', `predictnl_opts' level(`level')
		}
		if "`e(scale)'" =="log" {
			qui predictnl double `newvarname' = (1/`t' * (`dxb1')*exp(`xb1_plus')/(1-exp(`xb1_plus')) - ///
												1/`t' * (`dxb0')*exp(`xb0_plus')/(1-exp(`xb0_plus')))*`per' ///
												if `touse', `predictnl_opts' level(`level')
		}
		else if "`e(scale)'" =="theta" {
			qui predictnl double `newvarname' = (1/`t' *((`dxb1')*exp(`xb1_plus'))/((exp([ln_theta][_cons])*exp(`xb1_plus') + 1)) - ///
												1/`t' *((`dxb0')*exp(`xb0_plus'))/((exp([ln_theta][_cons])*exp(`xb0_plus') + 1)))*`per' ///
												if `touse', `predictnl_opts' level(`level')
		}
	}

/* Predict Difference in Survival Curves */
	else if "`sdiff1'" != "" {
		if `"`ci'"' != "" {
			local predictnl_opts "ci(`newvarname'_lci `newvarname'_uci)"
		}
		else if "`stdp'" != "" {
			local predictnl_opts se(`newvarname'_se)
		}

		forvalues i=1/`e(dfbase)' {
			local xb1_plus `xb1_plus' [xb][_rcs`i']*_rcs`i'
			local xb0_plus `xb0_plus' [xb][_rcs`i']*_rcs`i'
			if `i' != `e(dfbase)' {
				local xb1_plus `xb1_plus' +
				local xb0_plus `xb0_plus' +
			}
		}

/* use Parse_list to select appropriate values of factor variables */
		Parse_list, listname(sdiff1) parselist(`sdiff1')
		tokenize `r(retlist)'
		while "`1'"!="" {
			cap confirm var `2'
			if _rc {
				if "`2'" == "." {
					local 2 `1'
				}
				else {
				/*
					cap confirm num `2'
					if _rc {
						di as err "invalid sdiff1(... `1' `2' ...)"
						exit 198
					}
				*/
				}
			}
			if "`xb1_plus'" != "" & "`2'" != "0" & `: list posof `"`1'"' in main_varlist' != 0 {
				local xb1_plus `xb1_plus' +
			}
			if "`2'" != "0" & `: list posof `"`1'"' in main_varlist' != 0 {
				local xb1_plus `xb1_plus' [xb][`1']*`2' 
			}
			if `"`: list posof `"`1'"' in etvc'"' != "0" & "`2'" != "0" {
				local xb1_plus `xb1_plus' +

				forvalues i=1/`e(df_`1')' {
					local xb1_plus `xb1_plus' [xb][_rcs_`1'`i']*_rcs_`1'`i'*`2'  
					if `i' != `e(df_`1')' {
						local xb1_plus `xb1_plus' +
					}
				}
			}
			mac shift 2
		}			

		if "`sdiff2'" != "" {
/* use Parse_list to select appropriate values of factor variables */
		Parse_list, listname(sdiff2) parselist(`sdiff2')
		tokenize `r(retlist)'
			while "`1'"!="" {
				cap confirm var `2'
				if _rc {
					if "`2'" == "." {
						local 2 `1'
					}
					else {
					/*
						cap confirm num `2'
						if _rc {
							di as err "invalid sdiff2(... `1' `2' ...)"
							exit 198
						}
					*/
					}
				}
				if "`2'" != "0" & `: list posof `"`1'"' in main_varlist' != 0 {
					local xb0_plus `xb0_plus' + [xb][`1']*`2' 
				}
				if `"`: list posof `"`1'"' in etvc'"' != "0" & "`2'" != "0" {
					local xb0_plus `xb0_plus' + 
					forvalues i=1/`e(df_`1')' {
						local xb0_plus `xb0_plus' [xb][_rcs_`1'`i']*_rcs_`1'`i'*`2'
						if `i' != `e(df_`1')' {
							local xb0_plus `xb0_plus' +
						}
					}
				}
				mac shift 2
			}
		}
		if "`e(noconstant)'" == "" {
			local xb0_plus `xb0_plus' + [xb][_cons]
			local xb1_plus `xb1_plus' + [xb][_cons]
		}

		if "`e(scale)'" =="hazard" {
			qui predictnl double `newvarname' = exp(-exp(`xb1_plus')) - exp(-exp(`xb0_plus')) if `touse', `predictnl_opts' level(`level')
		}
		else if "`e(scale)'" =="odds" {
			qui predictnl double `newvarname' =  	1/(exp(`xb1_plus')+1) - 1/(exp(`xb0_plus')+1) if `touse', `predictnl_opts' level(`level')
		}
		else if "`e(scale)'" =="normal" {
			qui predictnl double `newvarname' =  	normal(-(`xb1_plus')) - normal(-(`xb0_plus')) if `touse', `predictnl_opts' level(`level')
		}
		else if "`e(scale)'" == "log" {
			qui predictnl double `newvarname' =  	(1 - exp(`xb1_plus')) - (1-exp(`xb0_plus')) if `touse', `predictnl_opts' level(`level')
		}		
		else if "`e(scale)'" =="theta" {
			qui predictnl double `newvarname' =  	(exp([ln_theta][_cons])*exp(`xb1_plus') + 1)^(-1/exp([ln_theta][_cons])) ///
											-(exp([ln_theta][_cons])*exp(`xb0_plus') + 1)^(-1/exp([ln_theta][_cons])) ///
											if `touse', `predictnl_opts' level(`level')
		}
	}

/* estimate cure, survival of uncured or hazard of uncured */
	else if "`cure'" != "" | "`uncured'" != "" {
		local xblist [xb][_cons]
		local rcslist
		local drcslist
		tempvar temp
		if "`ci'" != "" {
			local prednlopt ci(`temp'_lci `temp'_uci)
		}
		foreach var in `e(varlist)' {
			local xblist `xblist' + [xb][`var']*`var'
		}
		
		if "`cure'" != "" {		/*if cure is specified this is what we want to estimate*/
			qui predictnl double `temp' = `xblist' if `touse', `prednlopt' level(`level')
			qui gen double `newvarname' = exp(-exp(`temp'))	if `touse'	/*we model on log(-log) scale*/
			if "`ci'" != "" {		
				qui gen double `newvarname'_lci = exp(-exp(`temp'_uci))	if `touse'
				qui gen double `newvarname'_uci = exp(-exp(`temp'_lci)) if `touse'
			}
		}
		
		else {		/*continue, estimate survival or hazard of uncured or Predicted survival time among uncured for a given centile*/
			forvalues i = 1/`e(dfbase)' {	
				if "`rcslist'" == "" local rcslist [xb][_rcs`i']*_rcs`i'			/*create a list of the sum of all spline variables*/
				else local rcslist `rcslist' + [xb][_rcs`i']*_rcs`i'
			}
			foreach var in `e(tvc)' {
				forvalues i = 1/`e(df_`var')' {
					local rcslist `rcslist' + [xb][_rcs_`var'`i']*_rcs_`var'`i'
				}
			}
			forvalues i = 1/`e(dfbase)' {
				if "`drcslist'" == "" local drcslist [xb][_rcs`i']*_d_rcs`i'		/*need derivatives of rcslist to calculate hazard and for centile*/
				else local drcslist `drcslist' + [xb][_rcs`i']*_d_rcs`i'
			}
			foreach var in `e(tvc)' {
				forvalues i = 1/`e(df_`var')' {
						local drcslist `drcslist' + [xb][_rcs_`var'`i']*_d_rcs_`var'`i'
				}
			}		
			local pi exp(-exp(`xblist')) 		/*we need cure for estimation of survival and hazard*/
			local exprcs exp(`rcslist') 		/*we need exp of the sum of all spline variables for estimation of survival and hazard*/
	/*predicted survival of uncured*/		
			if "`survival'" != "" & "`uncured'" != "" {			
				tokenize `e(boundary_knots)'
				local lastknot = `2' 
				qui predictnl double `temp' = ln(-(ln(`pi'^(`exprcs') - `pi') - ln(1 - `pi'))) if `touse', `prednlopt' level(`level')
				qui gen double `newvarname' = exp(-exp(`temp')) if `touse'
				qui replace `newvarname' = 0 if `newvarname' == . & `t'>=`lastknot' & `touse'
				if "`ci'" != "" {
					qui gen double `newvarname'_lci = exp(-exp(`temp'_uci)) if `touse'
					qui gen double `newvarname'_uci = exp(-exp(`temp'_lci)) if `touse'
				}
			}
	/*predicted hazard of uncured*/		
			else if "`hazard'" != "" & "`uncured'" != "" {	  
				qui predictnl double `temp' = ln(-ln(`pi')*((`drcslist')/`t')*`exprcs'*`pi'^(`exprcs'))- ln(`pi'^(`exprcs') - `pi')  if `touse', `prednlopt' level(`level') 
				qui gen double `newvarname' = exp(`temp') if `touse'
				if "`ci'" != "" {
					qui gen double `newvarname'_lci = exp(`temp'_lci) if `touse'
					qui gen double `newvarname'_uci = exp(`temp'_uci) if `touse'
				}
			}
	/* Predicted survival time among uncured for a given centile */
			else if "`centile'" != "" & "`uncured'" != ""{
				tempvar centilevar	
				gen `centilevar' = 1 - `centile'/100 if `touse'	
				stpm2_centpred `newvarname' if `touse', centile(`centilevar') centol(`centol') offset(`offset') `uncured' `ci' level(`level')
			}		
		}		
	}
	
	
/* Predicted survival time for a given centile */
/* Updated to useing Brents root finder (version 1.6.4) */
/* calls stpm2_centpred : a separate ado file */
	else if "`centile'" != "" & "`uncured'" == "" {
		tempvar centilevar 
		gen `centilevar' = 1 - `centile'/100 if `touse'
		stpm2_centpred `newvarname' if `touse', centile(`centilevar') centol(`centol') offset(`offset') `ci' level(`level')
	}

	
/* restore original data and merge in new variables */
	local keep `newvarname'
	if "`ci'" != "" { 
		local keep `keep' `newvarname'_lci `newvarname'_uci
	}
	else if "`stdp'" != "" {
		local keep `keep' `newvarname'_se 
	}
	keep `keep'
	qui save `"`newvars'"'
	restore
	merge 1:1 _n using `"`newvars'"', nogenerate noreport
end


/* meansurv added to stpm2_pred as sub program */
* 10March2009 - added averages for models on odds, probit or theta scales.

program Stmeancurve, sortpreserve 
	version 10.0
	syntax newvarname [if] [in],[TIMEvar(varname) AT(string) ATVAR(string) noCOLLAPSEMEANSURV ///
		meansurvwt(varname) ci noOFFSET UNCURED MEANHAZard MEANFT LEVEL(real `c(level)') per(integer 1)] 
	marksample touse, novarlist
	local newvarname `varlist'

	tempvar t lnt touse_time
	preserve

	if "`meanhazard'" == "" & "`meanft'" == "" local meansurv meansurv
	
	
	// use timevar option or _t 
	// do not use if
	if "`timevar'" == "" {
		qui gen `t' = _t 
		qui gen double `lnt' = ln(_t) 
	}
	else {
		qui gen double `t' = `timevar' 
		qui gen double `lnt' = ln(`timevar') 
	}

	/* index which time units are selected */
	gen `touse_time' = `t' != . 
	if "`meanhazard'" != "" | "`meanft'" != "" {
		qui replace `touse_time' = 0 if `t' == 0
	}
	
	/* generate ocons for use when orthogonalising splines */
	tempvar ocons
	gen `ocons' = 1

	/* Calculate new spline terms */

	if "`e(rcsbaseoff)'" == "" {
		capture drop _rcs* _d_rcs*
		if "`e(orthog)'" != "" {
			tempname rmatrix
			matrix `rmatrix' = e(R_bh)
			local rmatrixopt rmatrix(`rmatrix')
		}
		else local rmatrixopt ""
		qui rcsgen `lnt' if `touse_time', knots(`e(ln_bhknots)') gen(_rcs) dgen(_d_rcs) `e(reverse)' `rmatrixopt' `e(nosecondder)' `e(nofirstder)'
	}
	if "`e(tvc)'" != ""  capture drop _rcs_* _d_rcs_*
	foreach tvcvar in `e(tvc)' {
		if "`e(orthog)'" != "" {
			tempname rmatrix_`tvcvar'
			matrix `rmatrix_`tvcvar'' = e(R_`tvcvar')
			local rmatrixopt rmatrix(`rmatrix_`tvcvar'')
		}
		else local rmatrixopt ""
		qui rcsgen `lnt' if `touse_time',  gen(_rcs_`tvcvar') knots(`e(ln_tvcknots_`tvcvar')') dgen(_d_rcs_`tvcvar') `e(reverse)' `rmatrixopt' `e(nosecondder)' `e(nofirstder)'
	}

	/* Out of sample predictions using at() */
	if "`at'" != "" {
		tokenize `at'
		while "`1'"!="" {
			if "`1'" == "." continue, break
				unab 1: `1'
			cap confirm var `1'
			if _rc {
				di "`1' is not in the data set"
			}
			if "`2'" != "=" {
				if _rc {
					cap confirm num `2'
					if _rc {
						di as err "invalid at(... `1' `2' ...)"
						exit 198
					}
				}
				qui replace `1' = `2' if `touse'
				local shift 2
			}
			else {
				cap confirm var `3'
				if _rc {
					di as err "`var' is not in the data set"
					exit 198
				}
				qui replace `1' = `3' if `touse'
				local shift 3
			}
			mac shift `shift'
		}
	}
	
	
			
	

	if "`atvar'" != "" {
		// strip spaces before and after equals sign
		local stillspaces 1
		while `stillspaces' !=0 {
			local newatvar: subinstr local atvar " =" "=", all 	
			local newatvar: subinstr local newatvar "= " "=", all
			if "`newatvar'" == "`atvar'" {
				local stillspaces 0
			}
			else {
				local atvar `newatvar'
			}
		}
		tokenize `atvar'
		while "`1'" != "" {
			capture replace `1' if `touse'
			if _rc>0 {
				di "Error in atvar() option ... `atvar'"
				exit 198
			}
			mac shift 2
		}
	}
	
	
	foreach tvcvar in `e(tvc)' {
		local rcstvclist `rcstvclist' `e(rcsterms_`tvcvar')'
		local drcstvclist `drcstvclist' `e(drcsterms_`tvcvar')'
	}

	if "`e(scale)'" == "theta" 	local theta = exp([ln_theta][_cons])
	
	qui count if `touse_time'
	local Nt `r(N)'
	local touse_msurvpop `touse'
	if "`collapsemeansurv'" == "" {
		tempvar duppattern dupfirst dupsum tmpid newtouse
		gen `tmpid' = _n
		covpat `e(varlist)' `e(tvc)' if `touse', gen(`duppattern')
		quietly bysort `duppattern' : gen `dupfirst' = _n == 1 if !missing(`duppattern') 
		quietly bysort `duppattern' : gen `dupsum' = _N  if !missing(`duppattern') 
		quietly gen `newtouse' = (`dupfirst' == 1)
		local touse_msurvpop `newtouse'
		if "`meansurvwt'" != "" {
			tempvar ismiss
			capture bysort `duppattern' (`meansurvwt'): assert `meansurvwt'[1] == `meansurvwt'[_N]
			if _rc>0 { 
			 di as error "meansurvwt not constant within unique combinations of covariates"
			 di as error "check correct or use nocollapsemeansurv option."
			}
		}
		sort `tmpid'
	}
	tempname tmpb tmpV
	matrix `tmpb' = e(b)
	matrix `tmpV' = e(V)
	_ms_findomitted `tmpb' `tmpV'

	mata: msurvpop() 
/* restore original data and merge in new variables */
	qui replace `newvarname' = 1 if `t' == 0 & `touse_time'
	local keep `newvarname'
	if "`ci'" != "" { 
		if "`meanhazard'" == "" {
			qui replace `newvarname'_lci = 1 if `t' == 0 & `touse_time'
			qui replace `newvarname'_uci = 1 if `t' == 0 & `touse_time'		
			qui replace `newvarname'_lci = 0 if `newvarname'_lci <0 & `touse_time'
			qui replace `newvarname'_uci = 1 if `newvarname'_uci > 1 & `touse_time'
		}
		local keep `keep' `newvarname'_lci `newvarname'_uci
	}
	else if "`stdp'" != "" {
		local keep `keep' `newvarname'_se 
	}
	keep `keep'
	tempfile newvars
	qui save `"`newvars'"'
	restore
	merge 1:1 _n using `"`newvars'"', nogenerate noreport
end

/* 
program Parse_list converts the options give in hrnum, hrdenom, hdiff1, hdiff2, sdiff1 and sdiff2 
to factor notation
_varlist contains the variables listed in the predict option
*/
program define Parse_list, rclass
	syntax, listname(string) parselist(string)
	tokenize `parselist'
	local etvc `e(tvc)'
	local main_varlist `e(varlist)'	
	while "`1'"!="" {
		fvunab tmpfv: `1'
		local 1 `tmpfv'
		_ms_parse_parts `1'
		if "`r(type)'"!="variable" {
			display as error "level indicators of factor" /*
							*/ " variables may not be individually set" /*
							*/ " with the `listname'() option; set one value" /*
							*/ " for the entire factor variable"
			exit 198
		}
		cap confirm var `2'
		if _rc {
			cap confirm num `2'
			if _rc {
				if "`2'" != "." {
					di as err "invalid `listname'(... `1' `2' ...)"
					exit 198
				}
			}
		}

		local _varlist `_varlist' `1'
		local `1'_value `2'
		mac shift 2
	}
	_ms_extract_varlist `e(varlist)', noomitted
	local varlist_omitted `r(varlist)' 

/* check if any tvc variables  not in varlist_omitted */
	local tvconly
	foreach tvcvar in `e(tvc)' {
		mata: st_local("addtvconly",strofreal(subinword(st_local("varlist_omitted"),st_local("tvcvar"),"")==st_local("varlist_omitted")))
		if `addtvconly' {
			local tvconly `tvconly' `tvcvar'
		}
	}

/* loop over all variables in model	*/
	foreach var in `varlist_omitted' `tvconly' {
		_ms_parse_parts `var'
		local vartype `r(type)'
		local intmult
		foreach parse_var in `_varlist' {
			/* check parse_var in model */
			/*
			_ms_extract_varlist  `parse_var'
			if "`r(varlist)'" == "" {
				display as error "`parse_var' is not included in the model"
				exit 198
			}
			*/
			
			
			* NOW SEE IF MODEL VARIABLE IS LISTED IN PARSE_VAR
			_ms_parse_parts `var'
			local invar 0
			if "`r(k_names)'" == "" {
				if "`r(name)'" == "`parse_var'" {
					local invar 1
				}
			}
			else {
				forvalues i = 1/`r(k_names)' {
					if "`r(name`i')'" == "`parse_var'" {
						local invar 1
					}
				}
			}
			if `invar' {
				if "`vartype'" == "variable" {
					local retlist `retlist' `var' ``parse_var'_value'
				}
				else if "`vartype'" == "factor" {
					if `r(level)' == ``parse_var'_value' {
						local retlist `retlist' `var' 1
					}
					else {
						_ms_extract_varlist ``parse_var'_value'.`parse_var'
					}
				}
				else if "`vartype'" == "interaction" {
					if strpos("`var'","`parse_var'") >0 {
							_ms_parse_parts `var'
							forvalues i = 1/`r(k_names)' {
								if "`r(name`i')'" == "`parse_var'" {
									if "`r(op`i')'" == "``parse_var'_value'" {
										local intmult `intmult'*1
									}
									else if "`r(op`i')'" == "c" {
										local intmult `intmult'*`parse_var'
									}
									else {
										local intmult `intmult'*0
									}
								}
							}
					}
					else {
						local intmult `intmult'*0
					}
				}

				else if "`vartype'" == "product" {
						display "products not currently available"
				}
			}
		}
		
		if "`vartype'" == "interaction" { // & `invar' {
			local intmult: subinstr local intmult "*" ""
			if `intmult' != 0 {
				local retlist `retlist' `var' `intmult'
			}
		}
		return local retlist `retlist'
	}
end

program define _rmst, sortpreserve
/*
	Mean or restricted mean or restriced SD of time to failure for an stpm2 model,
	based on covariate patterns or an `at()' specification.

*/

version 11.1
syntax [if] [in], [ at(string) GENerate(string) N(int 1001) ///
		POWer(real 1) RSDst TMAx(real 0) TMIn(real 0) ZEROs ]
local cmdline `e(cmdline)'
if (`tmin' < 0) local tmin 0
if (`tmax' <= 0) local tmax .
local survival survival

// Use original variable names saved by stpm2
local varlist `e(varnames)'

quietly {
	marksample touse
	replace `touse' = 0 if _st == 0
	tempvar t s
	if missing(`tmax') {
		noi di as txt "[tmax() not specified, estimating unrestricted mean survival time]"
		// Find t corresponding to 99.999999 centile for range of t
		local cmax 99.999999
		predict `t', centile(`cmax')
		sum `t', meanonly
		local tmax = r(max)
		drop `t'
	}
	local n_orig = _N
	if `n' > `n_orig' {
		tempvar mark_orig
		gen byte `mark_orig' = 1
	}
	range `t' `tmin' `tmax' `n'
	tempvar integral
	/* `power' option is undocumented and not implemented for rsdst */
	if `power' != 1 {
		tempvar lnt
		gen `lnt' = cond(`power' == 0, ln(`t') - ln(`tmax'),  ///
		 (`t'^`power' - 1) / `power' - (`tmax'^`power' - 1) / `power')
	}
	gen `integral' = .
	
/* identify covariate patterns and compute mean survival for them */
	if "`zeros'" == "" {
		if "`at'" != "" {
			// Identify covariates `s(omitted)' in `varlist' but not in `at'.
			CheckAt "`at'" "`varlist'"
			local covpatvarlist `s(omitted)'
		}
		else local covpatvarlist `varlist'
	}
	if "`covpatvarlist'" != "" {
		tempvar covpat
		covpat `covpatvarlist' if `touse', generate(`covpat')
		sum `covpat', meanonly
		local ncovpat = r(max)
		noi di as txt _n "Processing " as res `ncovpat' as txt " covariate patterns ..."
	}

	else {
		local ncovpat 1
		local covpat 1
	}

	forvalues i = 1 / `ncovpat' {

		local At
		tokenize `covpatvarlist'
		while "`1'" != "" {
			sum `1' if (`covpat' == `i') & (`touse' == 1), meanonly
			local mm = r(mean)
			local At `At' `1' `mm'
			mac shift
		}


*noi di in red `"predict double `s' if `touse', timevar(`t') at(`At' `at') `survival' `meansurv' `zeros'"'
		predict double `s' /*if `touse'*/, timevar(`t') at(`At' `at') `survival' `zeros'
		replace `s' = 1 if `t'==0

		if `power' != 1 {
			// work with f(t) - f(tmax), so that on power-transformed scale, tmax (effective) = 0.
			replace `s' = 1 - `s' // distribution function
			integ `s' `lnt' if !missing(`lnt')
			replace `integral' = cond(`power' == 0, ln(`tmax'), (`tmax'^`power'-1)/`power') - r(integral) if `covpat' == `i'
		}
		else {
// !! PR bug fix 14jul2016: get correct integrated survival between tmin > 0 and tmax = t*
			if `tmin' > 0 {
				// direct integration of survival function
				integ `s' `t'
				local ex = r(integral)
			}
			else { // via integration of distribution function, F(t) = 1-S(t)
				replace `s' = cond(`t' == 0, 0, 1 - `s')
				integ `s' `t'

				local ex = `tmax' - r(integral)
			}
			if "`rsdst'" != "" { // supported only if tmin = 0
				replace `s' = `s' * `t'
				integ `s' `t'
				local ex2 = `tmax'^2 - 2 * r(integral)
				replace `integral' = sqrt(`ex2' - `ex'^2) if `covpat' == `i'
			}
			else replace `integral' = `ex' if `covpat' == `i'
		}		
		drop `s'
		if mod(`i', 10) == 0 noi di as txt `i', _cont
	}

	if !missing("`generate'") {
		cap confirm var `generate', exact
		if (c(rc) == 0) replace `generate' = `integral'
		else rename `integral' `generate'
/*
		local txt = cond("`rsdst'" != "", "SD", "mean")
		if (missing("`cmax'")) lab var `generate' "restricted `txt' at time `tmax'"
		else lab var `generate' "`txt' time"
*/
	}

	if `n' > `n_orig' {
		drop if missing(`mark_orig')
		drop `mark_orig'
	}
}
end

* version 1.1 PCL 28JUL2014 (now allows for factor variables)
* Based on PR 9-Jan-94. Based on covariate-pattern counter in lpredict.ado.
program define covpat, sortpreserve
	version 11
	syntax [varlist(default=none fv)] [if] [in], Generate(string)
	confirm new var `generate'
	tempvar keep

	fvexpand `varlist'
	local expvarlist `r(varlist)'

// The following is changes as expr_query did not work in Stata 12.	
/* 
	local expvars: subinstr local expvarlist " " "+", all
	expr_query `expvars'
	local uniquevars `r(varnames)'
*/
	local uniquevars
	foreach var in `expvarlist' {
		_ms_parse_parts `var'
		if "`r(k_names)'" == "" {
			local uniquevars `uniquevars' `r(name)'
		}
		else {	
			forvalues i = 1/`r(k_names)' {
				local uniquevars `uniquevars' `r(name`i')'
			}
		}
	}
	local uniquevars: list uniq uniquevars
	quietly {
		marksample keep
		sort `keep' `uniquevars'
		gen long `generate' = .
		by `keep' `uniquevars': replace `generate'=cond(_n==1 & `keep',1,.)
		replace `generate' = sum(`generate')
		replace `generate'=. if `generate'==0
	}
end


program define _rmst_meansurv, sortpreserve
version 11.1
/*
	Mean or restricted mean or restriced SD of time to failure for an stpm2 model,
	based on covariate patterns or an `at()' specification.
	Assumes stpm2 model has been fitted.
*/
syntax [if] [in], [ at(string) GENerate(string) N(int 1001) meansurv ///
 POWer(real 1) RSDst TMIn(real 0) TMAx(numlist >0 ascending) ZEROs ]

local cmdline `e(cmdline)'
local tmin 0

local ntstar : word count `tmax'
local tbig : word `ntstar' of `tmax'

// Use original variable names saved by stpm2
local varlist `e(varnames)'

quietly {
	marksample touse
	replace `touse' = 0 if _st == 0
	tempvar t s integral
	local n_orig = _N
	local n_plus = `n' + `ntstar' - 1
	if `n_plus' > `n_orig' {
		tempvar mark_orig
		gen byte `mark_orig' = 1
		set obs `n_plus'
	}
	range `t' `tmin' `tbig' `n'
	if `ntstar' > 1 {
	// Augment t with tstar values excluding highest
		local n1 = `n' + 1
		local ntstar1 = `ntstar' - 1
		tokenize `tmax'
		forvalues j = 1/`ntstar1' {
			replace `t' = ``j'' in `n1'
			local ++n1
		}
	}
	gen `integral' = .
	
/* identify covariate patterns and compute mean survival for them */
	if "`zeros'" == "" {
		if "`at'" != "" {
			// Identify covariates `s(omitted)' in `varlist' but not in `at'.
			CheckAt "`at'" "`varlist'"
			local covpatvarlist `s(omitted)'
		}
		else local covpatvarlist `varlist'
	}
	predict double `s', timevar(`t') at(`At' `at') meansurv `zeros'
	replace `s' = cond(`t' == 0, 0, 1 - `s')
	// eval integral on each (0,tstar] interval
	tokenize `tmax'
	forvalues j = 1/`ntstar' {
		local ts ``j''
		integ `s' `t' if `t'<=(`ts' * 1.000001)
		local ex = `ts' - r(integral)
		if "`rsdst'" != "" {
			replace `s' = `s' * `t'
			integ `s' `t' if `t'<=`ts'
			local ex2 = `ts'^2 - 2 * r(integral)
			replace `integral' = sqrt(`ex2' - `ex'^2) in `j'
		}
		else replace `integral' = `ex' in `j'
	}
	drop `s'

	if !missing("`generate'") {
		cap confirm var `generate', exact
		if (c(rc) == 0) replace `generate' = `integral'
		else rename `integral' `generate'
	}
	if `n_plus' > `n_orig' {
		drop if missing(`mark_orig')
		drop `mark_orig'
	}
*stop
}
end
program define CheckAt, sclass
version 11
/*
	Checks whether the `at' list specifies all variables in varlist.
	If not, provides in s(omitted) a list of omitted variables
*/
args at varlist
sret clear
local omitted `varlist'
tokenize `at'
while "`1'"!="" {
	fvunab v: `1'
	local 1 `v'
	_ms_parse_parts `1'
	if "`r(type)'"!="variable" {
		display as error "level indicators of factor" /*
						*/ " variables may not be individually set" /*
						*/ " with the at() option; set one value" /*
						*/ " for the entire factor variable"
		exit 198
	}
	cap confirm var `2'
	if _rc {
		cap confirm num `2'
		if _rc {
			di as err "invalid at(... `1' `2' ...)"
			exit 198
		}
	}
	ChkIn `1' "`varlist'"
	local omitted : list omitted - 1
	macro shift 2
}
sreturn local omitted `omitted'
end


program define ChkIn, sclass
version 9.2
* Returns s(k) = index # of target variable v in varlist, or 0 if not found.
args v varlist
sret clear
local k: list posof "`v'" in varlist
sret local k `k'
if `s(k)' == 0 {
   	di as err "`v' is not a valid covariate"
   	exit 198
}
end


// mata program to obtain mean survival 
mata:
void msurvpop() 
{
// Transfer data from Stata 
	newvar = st_local("newvarname")
	touse = st_local("touse_msurvpop")
	touse_time = st_local("touse_time")
	tvcrcslist = st_local("rcstvclist")
	Nt = strtoreal(st_local("Nt"))
	hascons = st_global("e(noconstant)") == ""	
	uncured = st_local("uncured") != ""
	meansurv_opt = st_local("meansurv") != ""
	meanhazard_opt = st_local("meanhazard") != ""
	per = strtoreal(st_local("per"))
	meanft_opt = st_local("meanft") != ""
	t = st_data( ., st_local("t"), touse_time)
	if (st_global("e(rcsbaseoff)") == "") {
		rcsbase = st_data( ., tokens(st_global("e(rcsterms_base)")), touse_time)
		if(meanhazard_opt | meanft_opt) drcsbase = st_data( ., tokens(st_global("e(drcsterms_base)")), touse_time)
	}
	else rcsbase = J(Nt,0,0)

	if (tvcrcslist != "") {
		rcstvc = st_data( ., tokens(tvcrcslist), touse_time)
		drcstvc = st_data( ., tokens(st_local("drcstvclist")), touse_time)
	}
	else rcstvc = I(0)
	
	if (st_global("e(varlist)") != "") {
		x = st_data(.,tokens(st_global("e(varlist)")),touse)
	}
	else x = J(1,0,.)

	if (st_global("e(tvc)") != "") {
		xtvc = st_data(.,tokens(st_global("e(tvc)")),touse)
	}
	else xtvc = J(1,0,.)
	
	tvcvar = tokens(st_global("e(tvc)"))
	ntvc = cols(tvcvar)
	Nvarlist = cols(tokens(st_global("e(varlist)")))

	// Beta matrix 
	tmpb = st_local("tmpb")
	beta = st_matrix(tmpb)'[1..cols(rcsbase)+cols(rcstvc) + Nvarlist + hascons,1]
	betarcs = beta[(Nvarlist+1)..(Nvarlist + cols(rcsbase)+cols(rcstvc)),1]
	scale = st_global("e(scale)")
	if (scale == "theta") theta = strtoreal(st_local("theta"))

//	check whether to include offset 
	offset_name = st_global("e(offset1)")
	if (offset_name != "" & st_local("offset") != "nooffset") offset = st_data(.,offset_name,touse)
	else offset = 0

	startstop = J(ntvc,2,.)
	tvcpos = J(ntvc,1,.)
	tmpstart = 1
// Loop over number of time observations 
	for (i=1;i<=ntvc;i++){
		startstop[i,1] = tmpstart
		tmpntvc = cols(tokens(st_global("e(rcsterms_"+tvcvar[1,i]+")")))
		startstop[i,2] = tmpstart + tmpntvc - 1
		tmpstart = startstop[i,2] + 1
	}
	if(st_local("collapsemeansurv")!="") {
		Nx = rows(x)
		Nobs = Nx
		covfreq = J(Nx,1,1)
	}
	else {
		covfreq = st_data(.,tokens(st_local("dupsum")),touse)
		Nx = rows(covfreq)
		Nobs = sum(covfreq)
	}
	if(st_local("meansurvwt") == "") {
		wt = J(Nx,1,1)
	}
	else {
		wt = st_data(.,st_local("meansurvwt"),touse)
	}
// Loop over all selected observations 
	meansurv = J(Nt,1,0)
	if(meanhazard_opt | meanft_opt) meanft = J(Nt,1,0)
	if (hascons) addcons = J(Nt,1,1)
	else addcons = J(Nt,0,0)
	
	if(uncured) {
		pi_cure = exp(-exp((x[,])*(beta[1..Nvarlist]) :+ hascons :* beta[rows(beta)]))
		start_exprcs = Nvarlist :+ 1
		stop_exprcs = rows(beta) :- 1
		if(!hascons) stop_exprcs = stop_exprcs :+ 1
	}
	for (i=1;i<=Nx;i++) {
		tmprcs = J(Nt,0,.)
		tmpdrcs = J(Nt,0,.)
		for (j=1;j<=ntvc;j++) {
			tmprcs = tmprcs, rcstvc[,startstop[j,1]..startstop[j,2]]:*xtvc[i,j]
			tmpdrcs = tmpdrcs, drcstvc[,startstop[j,1]..startstop[j,2]]:*xtvc[i,j]
		}
		if(!uncured) {
			if (scale == "hazard")	{
				meansurv = meansurv :+ wt[i,]:*covfreq[i,]:*exp(-exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*beta :+ offset)):/Nobs
				if(meanhazard_opt | meanft_opt) {
					meanft = meanft + wt[i,]:*covfreq[i,]:*1:/t :*((drcsbase,tmpdrcs)*betarcs):*exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*beta - exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*beta :+ offset)):/Nobs
				}
			}
			else if (scale == "odds")	meansurv = meansurv :+ wt[i,]:*covfreq[i,]:*((1 :+ exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*beta :+ offset)):^(-1)):/Nobs
			else if (scale == "normal")	meansurv = meansurv :+ wt[i,]:*covfreq[i,]:* normal(-(J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*beta :+ offset):/Nobs
			else if (scale == "theta")	meansurv = meansurv :+ wt[i,]:*covfreq[i,]:* ((theta:*exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*beta :+ offset) :+ 1):^(-1/theta)):/Nobs
		}			
		else if(uncured) {
			exprcs = exp((rcsbase,tmprcs) * beta[start_exprcs..stop_exprcs] :+ offset)
			meansurv = meansurv :+ wt[i,]:*covfreq[i,]:* ((pi_cure[i]:^(exprcs) :- pi_cure[i]):/(1 :- pi_cure[i])):/Nobs
		}

	}
	(void) st_addvar("double",newvar)
	if(meansurv_opt) st_store(., newvar, touse_time, meansurv)
	else if(meanhazard_opt) {
		meanhaz_result =  meanft:/meansurv
		st_store(., newvar, touse_time, per:*meanhaz_result)
	}
	else if(meanft_opt) st_store(., newvar, touse_time, meanft)
// Calculate CI using delta method	
	if(st_local("ci") != "") {
		Nparams = rows(beta)
		stata("_ms_omit_info " + tmpb)
		omitvars = st_matrix("r(omit)")[,1..Nparams]
		V = st_matrix("e(V)")[1..Nparams,1..Nparams]
		G = J(Nt,0,.)
		for(k=1;k<=Nparams;k++) {
			if(omitvars[k]==1) {
				G = (G,J(Nt,1,1))
				continue		
			}
			h = sqrt(epsilon(1))*beta[k]
			newbeta1 = beta
			newbeta1[k] = beta[k] + h/2 
			newbeta1rcs = newbeta1[(Nvarlist+1)..(Nvarlist + cols(rcsbase)+cols(rcstvc)),1]
			newbeta2 = beta
			newbeta2[k] = beta[k] - h/2 
			newbeta2rcs = newbeta2[(Nvarlist+1)..(Nvarlist + cols(rcsbase)+cols(rcstvc)),1]
			f1 = J(Nt,1,0)
			f2 = J(Nt,1,0)
			
			
			if(uncured) {
				pi_cure1 = exp(-exp((x[,])*(newbeta1[1..Nvarlist]) :+ hascons :* newbeta1[rows(beta)]))
				pi_cure2 = exp(-exp((x[,])*(newbeta2[1..Nvarlist]) :+ hascons :* newbeta2[rows(beta)]))
			}
			if(meanhazard_opt) {
				f1b = J(Nt,1,0)
				f2b = J(Nt,1,0)
			}
			// loop over unique x's 
			for (i=1;i<=Nx;i++) {
				tmprcs = J(Nt,0,.)
				tmpdrcs = J(Nt,0,.)
				for (j=1;j<=ntvc;j++) {
					tmprcs = tmprcs, rcstvc[,startstop[j,1]..startstop[j,2]]:*xtvc[i,j]
					tmpdrcs = tmpdrcs, drcstvc[,startstop[j,1]..startstop[j,2]]:*xtvc[i,j]
				}
				if(!uncured) {
					if (scale == "hazard")	{
						f1 = f1 :+ wt[i,]:*covfreq[i,]:*exp(-exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta1 :+ offset)):/Nobs
						f2 = f2 :+ wt[i,]:*covfreq[i,]:*exp(-exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta2 :+ offset)):/Nobs
					}
					else if(scale == "odds") {
						f1 = f1 :+ wt[i,]:*covfreq[i,]:*((1 :+ exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta1 :+ offset)):^(-1)):/Nobs				
						f2 = f2 :+ wt[i,]:*covfreq[i,]:*((1 :+ exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta2 :+ offset)):^(-1)):/Nobs				
					}
					else if(scale == "normal") {
						f1 = f1 :+ wt[i,]:*covfreq[i,]:* normal(-(J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta1 :+ offset):/Nobs				
						f2 = f2 :+ wt[i,]:*covfreq[i,]:* normal(-(J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta2 :+ offset):/Nobs				
					}
					else if(scale == "theta") {
						f1 = f1 :+ wt[i,]:*covfreq[i,]:* ((theta:*exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta1 :+ offset) :+ 1):^(-1/theta)):/Nobs				
						f2 = f2 :+ wt[i,]:*covfreq[i,]:* ((theta:*exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta2 :+ offset) :+ 1):^(-1/theta)):/Nobs				
					}
				}
				else if(uncured) {
					exprcs1 = exp((rcsbase,tmprcs) * newbeta1[start_exprcs..stop_exprcs] :+ offset)
					exprcs2 = exp((rcsbase,tmprcs) * newbeta2[start_exprcs..stop_exprcs] :+ offset)
					f1 = f1 :+ wt[i,]:*covfreq[i,]:*((pi_cure1[i]:^(exprcs1) :- pi_cure1[i]):/(1 :- pi_cure1[i])):/Nobs
					f2 = f2 :+ wt[i,]:*covfreq[i,]:*((pi_cure2[i]:^(exprcs2) :- pi_cure2[i]):/(1 :- pi_cure2[i])):/Nobs
					}
				if(meanhazard_opt) {
					if (scale == "hazard")	{
						f1b = f1b :+ wt[i,]:*covfreq[i,]:*1:/t :*((drcsbase,tmpdrcs)*newbeta1rcs):*exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta1 - exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta1 :+ offset)):/Nobs
						f2b = f2b :+ wt[i,]:*covfreq[i,]:*1:/t :*((drcsbase,tmpdrcs)*newbeta2rcs):*exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta2 - exp((J(Nt,1,x[i,]),rcsbase, tmprcs,addcons)*newbeta2 :+ offset)):/Nobs
					}
				}
				
			}
			if(meansurv_opt) G = (G,(log(f1) :- log(f2)):/h)	
			else if(meanhazard_opt)G = (G,(log(f1b:/f1) :- log(f2b:/f2)):/h)	
		}
		//se = sqrt(diagonal(G*V*G')) 
		se = sqrt(rowsum((G*V):*G)) // This is quicker
// calculate confidence interval
		level = strtoreal(st_local("level"))
		z =  abs(invnormal((1-(level/100))/2))
		(void) st_addvar("double",newvar+"_lci")	
		(void) st_addvar("double",newvar+"_uci")
		if(meansurv_opt) {
			st_store(., newvar+"_lci", touse_time, exp(log(meansurv) - z*se))
			st_store(., newvar+"_uci", touse_time, exp(log(meansurv) + z*se))
		}
		else if(meanhazard_opt){
			per
			st_store(., newvar+"_lci", touse_time, exp(log(meanhaz_result) - z*se):*per)
			st_store(., newvar+"_uci", touse_time, exp(log(meanhaz_result) + z*se):*per)
		}	}
}	
end

****************************************************
* Predict observed survival (relative survival times expected survival) from a relative survival model
* Added by Therese Andersson
***************************

program Stobssurv, sortpreserve
	version 11.1
	syntax newvarname [if] [in],[TIMEvar(varname) noOFFSET MERGEBY(string) DIAGAge(name) DIAGYear(name) BY(string) GRpd ATTAge(name) ///
								ATTyear(name) ID(name) MAXAge(int 99) MAXYear(int 2050) Nobs(int 100) CI LEVel(real `c(level)') MAXT(real 10) survprob(name) USIng(string) EXPSURV(string)] 

	marksample touse, novarlist
	local newvarname `varlist'

	if "`e(scale)'" != "hazard" | "`e(bhazard)'" == ""{
		display as error "You can only use the obssurv option after fitting a relative survival model with the scale(hazard) option"
		exit 198
	}
	
	if "`grpd'"=="" & "`by'" != "" {
		display as error "You can not specify the by option without the grpd option"
		exit 198
	}
	
	*Set all variable names needed for strs, if they have not been specified in options
	**********************	

	local atstep = `maxt'/`nobs'
	
	
	if "`id'" == "" {
		local id id
	}

	
	if "`survprob'" == "" {
		local survprob prob
	}
	
	if "`by'" != "" {
		local byexp by(`by')
	}
	
	* Now preserve the data and recalculate the splines if timevar option is used
	***************************
	
	preserve
	tempvar t lnt
	/* use timevar option or _t */
	if "`timevar'" == "" {
		qui gen `t' = _t if `touse'
		qui gen double `lnt' = ln(_t) if `touse'
	}
	else {
		qui gen double `t' = `timevar'  if `touse'
		qui gen double `lnt' = ln(`timevar') if `touse'
	}

	
	/* Calculate new spline terms if timevar option is specified */
	if "`timevar'" != "" & "`e(rcsbaseoff)'" == "" {
		drop _rcs* _d_rcs*
		if "`e(orthog)'" != "" {
			tempname rmatrix
			matrix `rmatrix' = e(R_bh)
			local rmatrixopt rmatrix(`rmatrix')
		}
		qui rcsgen `lnt' if `touse', knots(`e(ln_bhknots)') gen(_rcs) dgen(_d_rcs) `e(reverse)' `rmatrixopt' `e(nosecondder)' `e(nofirstder)'
	}
	
	/* calculate new spline terms if timevar option is specified */
	if "`timevar'" != "" {
		foreach tvcvar in `e(tvc)' {     
			capture drop _rcs_`tvcvar'* _d_rcs_`tvcvar'*
			if "`e(orthog)'" != "" {
				tempname rmatrix_`tvcvar'
				matrix `rmatrix_`tvcvar'' = e(R_`tvcvar')
				local rmatrixopt rmatrix(`rmatrix_`tvcvar'')
			}
			qui rcsgen `lnt' if `touse',  gen(_rcs_`tvcvar') knots(`e(ln_tvcknots_`tvcvar')') dgen(_d_rcs_`tvcvar') `e(reverse)'  `rmatrixopt' `e(nosecondder)' `e(nofirstder)'
			forvalues i = 1/`e(df_`tvcvar')'{
				qui replace _rcs_`tvcvar'`i' = _rcs_`tvcvar'`i'*`tvcvar' if `touse'
				qui replace _d_rcs_`tvcvar'`i' = _d_rcs_`tvcvar'`i'*`tvcvar' if `touse'
			}
		}
	}
		
	* We need the predictions xb(xb), to get the relative survival
	***************************

	tempvar sxb 
	if "`ci'" != "" {
		tempvar sxb_uci sxb_lci
		local prednlopt ci(`sxb_lci' `sxb_uci')
	}
	
	qui predictnl double `sxb' = xb(xb)`addoff' if `touse', `prednlopt' level(`level')
	
	* Calculate the expected survival using strs
	**************************************************
	
	tempfile grpdat inddat
	tempvar St_star tempfail temptime
	
	gen `tempfail'=0
	gen `temptime'=`maxt'
	
	qui stset `temptime', failure(`tempfail'=1) id(`id')
	qui strs using 	"`using'" if `touse', br(0(`atstep')`maxt') mergeby(`mergeby') diagage(`diagage') diagyear(`diagyear') ///
					 savgroup(`grpdat', replace) savind(`inddat', replace) attage(`attage') attyear(`attyear') maxage(`maxage') ///
					 notables survprob(`survprob') `byexp' ederer1

	qui stset `t', failure(`tempfail'=1) id(`id')

	if "`grpd'" != "" {
		if "`by'" != "" {
			joinby `by' using `grpdat', nolabel unmatched(both)
			assert _merge==3 if `touse'
			assert _merge==3 | _merge==1
			drop _merge
		}
		else {
			cross using `grpdat'
		}	
		sort `id' end
		gen `St_star'=cp_e1 if `touse'
	}
	
	if "`grpd'" == "" {
		qui merge 1:m `id' using `inddat', keepusing(p_star end) assert(match master)
		drop _merge
	
		sort `id' end
		by `id': gen double `St_star' = exp(sum(ln(p_star))) if `touse'
	}	

	qui replace _t = float(_t) if float(_t)==`maxt'

	qui keep if end>=_t
	qui by `id': keep if _n==1

	* Use expected and relative survival to obtain observed survival
	*****************************
	
	qui gen double `newvarname' = exp(-exp(`sxb'))*`St_star' if `touse'
	if "`ci'" != "" {
		qui gen `newvarname'_lci = exp(-exp(`sxb_uci'))*`St_star'  if `touse'
		qui gen `newvarname'_uci =  exp(-exp(`sxb_lci'))*`St_star' if `touse'
	}
	
	* restore original data and merge in new variables 
	*******************************
    
	local keep `id' `newvarname'
	if "`ci'" != "" { 
		local keep `keep' `newvarname'_lci `newvarname'_uci
	}
	if "`expsurv'" != "" {
		gen `expsurv'= `St_star'
		local keep `keep' `expsurv' 		
	}
	keep `keep'
	tempfile newvars
	qui save `newvars'
	restore
	merge 1:1 `id' using `newvars', nogenerate noreport
end

***********************************************************************************************
* Program for calculating loss in expectation of life, ADDED Feb 2012 by Therese Andersson
* Nov 2012, changed the way the numerical integration is done, to speed up calculation
***********************************************************************************************
program Stlifelost, sortpreserve 
	version 11.1
	syntax newvarname [if] [in],[ noOFFSET MERGEBY(string) DIAGAge(name) DIAGYear(name) MAXAge(int 99) ATTAge(name) ATTyear(name) survprob(name) USIng(string) ///
								BY(string) MAXYear(int 2050) Nodes(int 50) Tinf(int 50) Tcond(int 0) GRpd Stub(string) CI LEVel(real `c(level)') ]

	marksample touse, novarlist
	local newvarname `varlist'
	
	/*variables names for mean observed and mean expected survival, if stub option used*/
	local meanexp `stub'exp
	local meanobs `stub'obs

	* CHECKS
	**********	

	if "`e(scale)'" != "hazard" | "`e(bhazard)'" == ""{
		display as error "You can only use the lifelost option after fitting a relative survival model with the scale(hazard) option"
		exit 198
	}
	
	if "`grpd'"=="" & "`by'" != "" {
		display as error "You can not specify the by option without the grpd option"
		exit 198
	}
	
	if `nodes' < 0 {
        display as err "You need non-negative number of nodes"
		exit 198
	}
	
	if `tcond' < 0 {
        display as err "Tcond must be non-negative"
		exit 198
	}
	
	if `tinf' < 0 {
        display as err "Tinf must be non-negative"
		exit 198
	}
		
	*Set all variable names needed for merging on p_star, if they have not been specified in options
	**********************	
	
	
	if "`survprob'" == "" {
		local survprob prob
	}
	
	********************************************************************
	* Now preserve the data and loop over each year until tinf         *
	* and merge on interval specific expected survival at every year   *
	* calculate cumulative expected survival at each year              *
	********************************************************************

	preserve
	tempvar obsn 
	qui gen `obsn' = _n
	tempvar S_star_`tcond'

	qui gen `S_star_`tcond''=1 if `touse'
	local b=`tcond'+1
	forvalues i=`b'/`tinf' {		
		tempvar S_star_`i' `attage' `attyear'
		local j=`i'-1
	
		qui gen `attage'=floor(min(`diagage'+ `j',`maxage'))  if `touse'
		qui gen `attyear'=floor(min(`diagyear' + `j', `maxyear')) if `touse' 
		sort `mergeby'

		qui merge m:1 `mergeby' using `"`using'"', nolabel keepusing(`survprob') ///
				keep(1 3) noreport sorted
		capture assert _merge==3 if `touse'

		if _rc>0 {
			display as error "Records fail to match with the population file (`using'.dta)."


			exit 459
		}
		*qui gen `p_star_`i''=`survprob' if `touse'
		qui gen `S_star_`i''=`S_star_`j''*`survprob' if `touse'
		drop `attage' `attyear' `survprob' _merge			

	}
	
	/*if using grouped expected survival, calculate mean according to Ederer1*/
	if "`grpd'" != "" {
		if "`by'"!= "" {
			forvalues i=`b'/`tinf' {
				tempvar S_star_`i'_grp
				qui bysort `by': egen `S_star_`i'_grp' =mean(`S_star_`i'')
				qui replace `S_star_`i''= `S_star_`i'_grp' if `touse'
				qui drop `S_star_`i'_grp'
			}
		}
		else {
			forvalues i=`b'/`tinf' {
				tempvar S_star_`i'_grp
				qui egen `S_star_`i'_grp'=mean(`S_star_`i'')
				qui replace `S_star_`i''= `S_star_`i'_grp' if `touse'
				qui drop `S_star_`i'_grp'
			}
		}
	}
	
	******************************************************************
	* Find the nodes and the weights for the numerical integration   *
	* using the guassquad command and then calculate the time points *
	******************************************************************
	
	tempname weightsmat nodesmat
	mata gq("`weightsmat'","`nodesmat'")

	forvalues i=1/`nodes' {			// loop over all nodes to create the time points
		local t`i'= (`tinf'-`tcond')*0.5*el(`nodesmat',`i',1)+(`tinf'+`tcond')*0.5
		tempvar tvar`i'
		qui gen `tvar`i''=`t`i'' if `touse'
	}

	****************************************************************************
	* Calculate cumulative expected survival at every time point of interest,  *
	* and multiply with the weights, and do the integration (summation)        *
	****************************************************************************

	forvalues i=1/`nodes' {
		tempvar S`i' S_W_`i'
		local floort=floor(`t`i'')
		local ceilt=ceil(`t`i'')
		local dist=`t`i''-`floort'
		qui gen `S`i''=`S_star_`floort''-(`S_star_`floort''-`S_star_`ceilt'')*`dist' if `touse'
		qui gen `S_W_`i''= `S`i''*el(`weightsmat',`i',1) if `touse'
	}
	
	/*Sum up to get the mean expected survival*/
	local SW_list `S_W_1'
	forvalues i=2/`nodes' {
		local SW_list `SW_list' `S_W_`i''
	}
	
	qui egen `meanexp' = rowtotal(`SW_list') if `touse'
	qui replace `meanexp' = `meanexp'*(`tinf'-`tcond')*0.5 if `touse'

	******************************************************************************************
	* Loop over each time point and save R(t)S*(t) (the integrand) for each time point       *
	* estimate the mean observed survival and CI, then calculate loss in expectation of life *
	******************************************************************************************
	
	local predictstat (predict(survival timevar(`tvar1'))*`S_W_1')
	forvalues i=2/`nodes' {
		local predictstat `predictstat' + (predict(survival timevar(`tvar`i''))*`S_W_`i'')
	}	
	
	tempvar sxb 
	if "`ci'" != "" {
		local prednlopt ci(`meanobs'_lci `meanobs'_uci)
		local levelci level(`level')
	}

	if `tcond'==0 {
				qui predictnl double `meanobs' = 0.5*`tinf'*(`predictstat') if `touse',  `prednlopt' `levelci'
	}

	else {
		display as text "Estimating conditional loss in expectation of life"
		tempvar t_cond
		qui gen `t_cond'=`tcond'
		qui predictnl double `meanobs' = 0.5*(`tinf'-`tcond')*(`predictstat')/(predict(survival timevar(`t_cond'))) if `touse',  `prednlopt' `levelci'
	}

	qui gen `newvarname' = `meanexp'-`meanobs' if `touse'
	
	if "`ci'" != "" {
		gen `newvarname'_lci= `meanexp'-`meanobs'_uci if `touse'
		gen `newvarname'_uci= `meanexp'-`meanobs'_lci if `touse'

	}	
		
	* Restore original data and merge in new variables 
	************************************************************
	
//	local keep `newvarname'
	local keep `id' `newvarname'
	
	if "`ci'" != "" {
		local keep `keep' `newvarname'_lci `newvarname'_uci
    }
	
	if "`stub'" != "" {
		local keep `keep' `meanexp' `meanobs' 
		if "`ci'" != "" {
			local keep `keep' `meanobs'_lci `meanobs'_uci
		}
	}
	sort `obsn'
	keep `keep'
	tempfile newvars
	qui save `"`newvars'"'
	restore
	merge 1:1 _n using `"`newvars'"', nogenerate noreport 
end

mata:
	void gq(string scalar weightsname, string scalar nodesname)
{
	n =  strtoreal(st_local("nodes"))
	i = range(1,n,1)'
	i1 = range(1,n-1,1)'
	muzero = 2
	a = J(1,n,0)
	b = i1:/sqrt(4 :* i1:^2 :- 1)	
	A= diag(a)
	for(j=1;j<=n-1;j++){
		A[j,j+1] = b[j]
		A[j+1,j] = b[j]
	}	
	symeigensystem(A,vec,nodes)
	weights = (vec[1,]:^2:*muzero)'
	weights = weights[order(nodes',1)]
	nodes = nodes'[order(nodes',1)']
	st_matrix(weightsname,weights)
	st_matrix(nodesname,nodes)
}
end

