*! extreme 1.2.0 17 May 2017
*! Copyright (C) 2015-17 David Roodman

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.

* Version history at bottom

cap program drop extreme
program extreme, eclass byable(recall) sortpreserve
	version 11.0

	if replay() {
		if "`e(cmd)'" != "extreme" error 301
		if _by() error 190
		Display `0'
		exit 0
	}

	tokenize `"`0'"', parse(", ")

	if inlist(`"`1'"', "gpd", "gev") {
		syntax anything [if] [in] [fw aw iw pw/], [SIGvars(string) XIvars(string) MUvars(string) CONSTraints(string) /// 
			CLuster(varname) Robust vce(string) Level(cilevel) PERiod(string) THRESHold(string) QUIetly small(string) GUMBel init(namelist min=1 max=1) from(namelist min=1 max=1) NOLOg *]

		if `"`period'"' != "" {
			confirm number `period'
			if `period' <= 0 {
				di as err "{cmdab:per:iod()} option must be positive."
				exit 198
			}
		}
		else local period 0

		if "`from'" != "" {
			if "`init'" != "" cmp_error 198 "Cannot specify both {cmd:init()} and {cmd:from()}."
			local init `from'
		}
		_get_eformopts, soptions eformopts(`options')
		local diopts `s(eform)' level(`level')
		_get_mldiopts, `s(options)'
		local diopts `diopts' `s(diopts)'
		mlopts mlopts options, `s(options)'
		local mlopts `mlopts' `nolog'
		_get_gropts, graphopts(`options') gettwoway
		local uniqueopts `s(twowayopts)'
		local mergedopts `s(graphopts)'
		local cmdline extreme `0'

		tokenize `"`anything'"'
		di _n
		

		if `"`1'"'!="gpd" & `"`1'"'!="gev" {
			di as err `"`1' not a valid model. Choose {cmd:gpd} or {cmd:gev}."'
			exit 198
		}
		local GEV = `"`1'"'=="gev"
		if "`muvars'"!="" & !`GEV' {
			di as err "{cmdab:mu:vars()} option valid only for the GEV model."
			exit 198
		}
		if "`gumbel'"!="" {
			constraint free
			local constraints `constraints' `r(free)'
			constraint `r(free)' [xi]_cons
			if "`xivars'"!="" {
				di "{cmdab:xi:vars(}`xivars'{cmd:)} ignored for Gumbel model." _n
				local xivars
			}
		}

		marksample touse
		local _weight `weight'
		local _exp `exp'

		local subcommand `1'
		macro shift
		local 0 `*'
		syntax varlist(numeric fv ts `=cond(`GEV',"","max=1")')
		local depvar_user `varlist'
		fvrevar `varlist' if `touse'
		local depvar_revar `r(varlist)'
		markout `touse' `:word 1 of `r(varlist)''
		local Ndepvar: word count `depvar_revar'
		if `GEV' {
			if `"`threshold'"'!="" {
				di  "{cmdab:thresh:old()} ignored for the GEV model." _n
			}
			local title ML fit of generalized extreme value distribution
			local depvar_thresh `depvar_revar'
		}
		else {
			tempvar depvar_thresh
			qui gen double `depvar_thresh' = . in 1
			local title ML fit of generalized Pareto distribution
		}

		if "`_weight'" != "" {
			cap confirm var `_exp'
			if _rc {
				tempname wvar
				gen double `wvar' `_exp' if `touse'
			}
			else local wvar `_exp'
			local wgt  [`_weight'=`wvar']
			local awgt [aw       =`wvar']
			local wtype `_weight'
			local wexp `"=`_exp'"'
		}

		if `"`small'"' != "" {
			local 0 `small'
			syntax anything, [Reps(integer 50)]
			if !inlist(`"`anything'"', "bs", "cs") {
				di as err "{cmd:small()} option must be {cmd:bs} (bootstrap) or {cmd:cs} (Cox-Snell)."
				exit 198
			}
			local small `anything'
			local smallreps `reps'
			if "`small'"=="bs" di as txt "Bootstrapped bias correction and standard errors based on `reps' replications" _n
				else if "`constraints'" !="" {
					di as err "Cox-Snell correction not available for constrained models. Try {cmd:small(bs)}."
					exit 198
				}
		}

		foreach param in mu sig xi {
			if "`param'"!="mu" | `GEV' {
				local 0 ``param'vars'
				syntax [varlist(numeric default=none fv ts)], [noConstant]
				if "`varlist'"=="" & "`constant'"!="" {
					di as err "No right-side variables for `param'."
					exit 498
				}
				local `param'vars `varlist'
				local `param'nocons `constant'
				markout `touse' `varlist'
			}
		}
		foreach param in mu sig xi {
			if "`param'"!="mu" | `GEV' {
				_rmcoll ``param'vars' if `touse', ``param'nocons' expand
				local `param'vars `r(varlist)'
				local bcolnames `bcolnames' `r(varlist)' `=cond("``param'nocons'"=="", "_cons", "")'
				fvrevar `r(varlist)' if `touse'
				tokenize `r(varlist)'
				forvalues i=1/`:word count `r(varlist)'' {  // stick "o." back on fvrevar'd omitted variables
					local `param'_revar ``param'_revar' `=cond(strpos("`:word `i' of `r(varlist)''", "o."), "o.", "")'``i''  
				}
			}
		}

		local stationary = "`mu_revar'`sig_revar'`xi_revar'"==""
		if !`stationary' & `period' {
			di as txt "({cmdab:per:iod()} ignored for non-stationary models.)" _n
			local period 0
		}

		local 0 `vce'
		syntax [anything(everything)], [*]
		local bootoptions `options'
		local 0, `anything'
		syntax, [bs bootstrap *]
		if "`bs'`bootstrap'" != "" {
			local _vce `options'
			_vce_parse, argoptlist(cluster) pwallowed(cluster) old: `wgt', cluster(`cluster') vce(`_vce')
			local BS bs _b, notable noheader cluster(`r(cluster)') level(`level') `bootoptions':
			local vce
			local level
			if "`small'"=="bs" {
				di as txt "Warning: It may be inefficient to (non-parametrically) bootstrap the standard errors of the bootstrap-based, bias-corrected point estimates."
				di as txt "{cmd:small(bs)} by itself will produce (parametrically) bootstrapped standard errors along with bias-corrected pointed estimates." _n
			}
		}
		else {
			_vce_parse, optlist(robust oim opg) argoptlist(cluster) pwallowed(robust cluster oim opg) old: `wgt', `robust' cluster(`cluster') vce(`vce')
			local vce `r(vceopt)'
			local cluster `r(cluster)'
		}
		markout `touse' `r(cluster)', strok

		if "`small'"=="bs" | `"`BS'"'!="" local seed `c(seed)'
		
		tempname b bsmall V ll zeta
		local Nthresh 1
		if !`GEV' {
			if `"`threshold'"'=="" {
				sum `depvar_revar' if `touse', meanonly
				local _threshold = r(min)
				local threshold = r(min)
				local Nthreshcoefs 1
				di as txt "Taking sample minimum of " as res r(min) as txt " as the threshold." _n
				scalar `zeta' = 1
			}
			else {
				local 0 `threshold'
				syntax anything, [plot(string)]
				local threshcoefs `plot'
				if `"`threshcoefs'"'=="" local threshcoefs lnsig xi
				local Nthreshcoefs: word count `threshcoefs'
				cap confirm numeric variable `anything'
				if _rc {
					parse_numlist, numlist(`"`anything'"') min(1)
					local _threshold `s(numlist)'
					local Nthresh = `: word count `_threshold''
					if `Nthresh'>1 local quietly quietly
				}
				else {
					tempvar _threshold
					gen double `_threshold' = `anything' if `touse'
					local stationary 0
				}
				tempvar touse2
				gen byte `touse2' = `touse' & `depvar_revar' > `:word 1 of `_threshold''
				sum `touse2' if `touse' `awgt', meanonly
				scalar `zeta' = r(mean)
				local touse `touse2'
				if `period'>=1 & `period'*`zeta'<1 {
					di as txt "Warning: Since " `zeta' " of the observations" cond("`wgt'"!=""," (on a weighted basis)","") " are included in the regression, or 1 out of " 1/`zeta' ", "
					di "return levels for return periods at least that long can be estimated. {cmdab:per:iod(`period')} ignored."
					local period 0
				}
			}
			mata _extremeThresh=J(0,1,0); _extremeThreshb=_extremeThreshse=J(0,0`Nthreshcoefs',0)
		}
		else {
			scalar `zeta' = 1
			local _threshold XXX
		}

		if (`GEV' | `Nthresh'==1) & `"`mergedopts'`uniqueopts'"'!="" {
			di as err `"`mergedopts' `uniqueopts' not allowed."'
			exit 198
		}

		preserve
		qui keep if `touse'
		if _N==0 {
			di as err "No observations."
			exit 2000
		}

		mata _extremeDepVar = .; _extremeIsGEV = `GEV'
		if `GEV' mata _extremeDepVar = st_data(., "`depvar_thresh'")
		if `"`init'"'=="" {  // starting values from http://cran.r-project.org/web/packages/ismev/ismev.pdf#page=11
			tempname init sig0
			qui sum `:word 1 of `depvar_revar'' `awgt'
			scalar `sig0' = r(sd) `=cond(`GEV', "*sqrt(6)/_pi", "")' // correct values if xi=0, model stationary, and observed mean, var correct
			if "`sig_revar'"!="" mat `init' =                  J(1,`:word count `sig_revar'', 0)
			if "`signocons'"=="" mat `init' = nullmat(`init'), ln(`sig0')
			if "`xi_revar'" !="" mat `init' =         `init' , J(1,`:word count `xi_revar'', 0)
			if "`xinocons'" =="" mat `init' =         `init' , 0
			if `GEV' mat `init' = `=cond("`mu_revar'"!="", "J(1,`:word count `mu_revar'', 0),", "")' `=cond("`munocons'"=="", "r(mean)-.5772156649*`sig0'", "")' , `init'
		}
		foreach param in sig xi mu {
			if "`param'"!="mu" | `GEV' {
				if "``param'nocons'"!="" local `param'vars ``param'vars', noconstant
			}
			else local muvars
		}
		tempname t
		foreach thresh `=cond(0`Nthresh'>1, "of numlist", "in")' `_threshold' {
			qui if !`GEV' {
				replace `depvar_thresh' = `depvar_revar' - `thresh'
				drop if `depvar_thresh'<=0
				mata _extremeDepVar = st_data(., "`depvar_thresh'")
			}
			
			ml model lf2 extreme_lf2() `=cond(`GEV', "(mu:`mu_revar',`munocons')", "")' (lnsig:`sig_revar',`signocons') (xi:`xi_revar',`xinocons') `wgt', ///
				collinear title(`title') `vce' constraints(`constraints') nopreserve // estimate directly even when boostrapping, in order to rescue e(ll)
			mata moptimize_init_userinfo($ML_M, 3, extreme_est_prep(_extremeDepVar))
			mata moptimize_init_userinfo($ML_M, 2, _extremeDepVar)
			mata moptimize_init_userinfo($ML_M, 1, _extremeIsGEV)

			ml init `init', copy
			`quietly' ml max, `mlopts' noclear level(`level') `=cond(`"`BS'"'=="", "", "nolog")' nooutput search(off)
			scalar `ll' = e(ll)

			if e(converged) {
				if `"`BS'"' == "" {
					if "`small'"!="" extreme_small, xivars(`xivars') small(`small') smallreps(`smallreps')
				}
				else `quietly' `BS' extreme_estimate, init(`init', copy) small(`small') smallreps(`smallreps') xivars(`xivars') depvarname(`depvar_thresh')
			
				if `Nthresh'>1 {
					mat `b' = e(b)
					mat `init' = `b'
					if `period' mat `init' = `init'[1,1..`=colsof(`init')-1']
					mata _extremeThresh = _extremeThresh \ `thresh'
					foreach stat in b se {
						cap mat drop `t'
						foreach coef in `threshcoefs' {
							cap mat `t' = nullmat(`t'), _`stat'[/`coef']
							if _rc mat `t' = nullmat(`t'), .
						}
						mata _extremeThresh`stat' = _extremeThresh`stat' \ st_matrix("`t'")
					}
				}
			}
			ml clear
		}
		ereturn scalar ll = `ll'

		if `Nthresh'>1 {
			ereturn clear
			
			tempvar lo hi threshname
			getmata `threshname' = _extremeThresh, force
			foreach stat in b se {
				local names
				forvalues i=1/`Nthreshcoefs' {
					tempname t
					local names`stat' `names`stat'' `t'
				}
				getmata (`names`stat'') = _extremeThresh`stat', force
			}
			tokenize `threshcoefs'
			label var `threshname' "Threshold"
			qui forvalues i=1/`Nthreshcoefs' {
				local mid: word `i' of `namesb'
				cap drop `lo'
				cap drop `hi'
				gen `lo' = `mid' - invnormal((1+`level'/100)/2) * `: word `i' of `namesse''
				gen `hi' = `mid' + invnormal((1+`level'/100)/2) * `: word `i' of `namesse''
				label var `mid' ``i''
				label var `lo' "Confidence interval minimum"
				label var `hi' "Confidence interval maximum"
				twoway rarea `lo' `hi' `threshname', `mergedopts' || line `mid' `threshname', name(extremeThresh`i', replace) nodraw ///
					`=cond(`i'==`Nthreshcoefs', "xtitle(Threshold)",`"xtitle("") xlabels(none)"')' legend(off) ytitle(`"`:var label `mid''"') `mergedopts' `uniqueopts'
				local threshgraphs `threshgraphs' extremeThresh`i'
			}
			graph combine `threshgraphs', cols(1) name(extremeThresh, replace) xcommon
		}
		else {
			restore
			mat `b' = e(b)
			mat colnames `b' = `bcolnames'
			ereturn repost b = `b', esample(`touse') rename // pass the sample marker across the restore barrier

			ereturn local threshold `threshold'
			ereturn local seed `seed'
			ereturn scalar Nthresh = cond(`GEV', 0, `Nthresh')
			ereturn scalar Ndepvar = `Ndepvar'
			ereturn scalar zeta = `zeta'
			ereturn local depvar `depvar_user'
			ereturn local model `subcommand'
			ereturn local gumbel `gumbel'
			ereturn scalar stationary = `stationary'
			cap local t = [lnsig]_cons
			if !_rc local diparmopts diparm(lnsig, exp label("sig"))
			ereturn local diparmopts `diparmopts'
			if "`small'"=="bs" ereturn local vcetype Bootstrap
			ereturn local muvars `muvars'
			ereturn local sigvars `sigvars'
			ereturn local xivars `xivars'
			ereturn local munocons `munocons'
			ereturn local signocons `signocons'
			ereturn local xinocons `xinocons'
			ereturn local wtype `wtype'
			ereturn local wexp `"`wexp'"'
			ereturn local predict extreme_p
			eret local cmdline `cmdline'
			eret local cmd "extreme"
			Display, `diopts'
		}
		mata mata drop _extremeDepVar _extremeIsGEV
		cap mata mata drop _extremeThresh _extremeThreshb _extremeThreshse 
	}

	else if `"`1'"' == "plot" {
		syntax [anything(everything)] [fw aw iw pw], [mrl *]
		local _mrl `mrl'
		local 0 `anything' [`weight'`exp'], `options'
		syntax [anything] [if] [in] [fw aw iw pw/], [PP QQ DENSity RETurn mrl(string) Level(cilevel) name(string) *]
		parse_profile_opts, `options'
		local retprofile `s(retprofile)'
		local rateprofile `s(rateprofile)'
		local xiprofile `s(xiprofile)'
		_get_kdensopts, `s(options)'
		local kdensopts `s(kdensopts)'
		_get_gropts, graphopts(`s(options)') gettwoway
		local uniqueopts `s(twowayopts)'
		local mergedopts `s(graphopts)'
		if "`name'"=="" local name extreme
		marksample touse

		qui if "`mrl'`_mrl'"!="" {
			tempvar wt x mid lo hi
			tempname results hold

			if "`weight'" != "" {
				cap confirm var `exp'
				if _rc {
					tempname wvar
					gen double `wvar' = `exp' if `touse'
				}
				else local wvar `exp'
				local wtexp [`weight'=`wvar']
			}

			preserve
			keep if `touse'
			if _N==0 {
				di as err "No observations."
				exit 2000
			}

			local 0 `2'
			syntax varlist(ts fv max=1)
			fvrevar `varlist'
			local var `r(varlist)'
			cap _est hold `hold', restore
			mata _extremeResults = J(0, 4, 0)
			if "`mrl'" != "" {
				parse_numlist, numlist("`mrl'") var(`var') min(2)
				foreach min of numlist `s(numlist)' {
					mata _extremeResults = _extremeResults \ `min', extreme_mrl("`var'", "`wvar'", "`weight'", `min', `level')
				}
			}
			else {
				sort `var'
				forvalues i=1/`=_N' {
					local min = `var'[`i']
					mata _extremeResults = _extremeResults \ `min', extreme_mrl("`var'", "`wvar'", "`weight'", `min', `level')
				}
			}
			ereturn clear
			cap _estimates unhold `hold'
			mata _sort(_extremeResults, 1)
			getmata (`x' `mid' `lo' `hi') = _extremeResults, force
			mata mata drop _extremeResults
			label var `x' "`varlist'"
			label var `mid' "Point estimate"
			label var `lo' "Confidence interval minimum"
			label var `hi' "Confidence interval maximum"
			twoway rarea `lo' `hi' `x' `mergedopts' || line `mid' `x', xtitle("Threshold") ytitle("Mean excess") name(`"`name'MRL"', replace) legend(off) `mergedopts' `uniqueopts'
			restore
		}
		else if "`2'"!="," {
			di as err "varlist not allowed"
			exit 101
		}

		if `"`pp'`qq'`return'`density'`xiprofile'`retprofile'`rateprofile'"' == "" exit

		if "`e(cmd)'" != "extreme" error 301
		if e(Nthresh)>1 {
			di as err "Requested plot(s) unavailable after multi-threshold estimation."
			exit 198
		}

		tokenize `"`anything'"'
		macro shift
		local 0, `*'
		if !e(stationary) {
			foreach plottype in density return retprofile rateprofile {
				if "``plottype''"!="" {
					local `plottype'
					di as res "{cmd:`plottype'} plot not available for non-stationary models."
				}
			}
		}
		if "`xiprofile'"!="" & "`e(xivars)'"!="" {
			di as error "{cmdab:xiprof:ile()} plot available only for models that are stationary in xi."
			local xiprofile
		}

		if "`xiprofile'`retprofile'`rateprofile'" != "" & "`e(esttype)'"=="corrected" {
			di as error "{cmd:`plottype'} plot unavailable for estimates with bias correction."
			local xiprofile
			local retprofile
			local rateprofile
		}

		local depvar: word 1 of `e(depvar)'
		
		tempvar wt
		if "`e(wtype)'"!="" {
			qui gen double `wt' `e(wexp)' if `touse'
			local wexp = `wt'
		}

		preserve
		qui keep if e(sample)
		local GEV = e(model)=="gev"
		tempvar muhat
		if `GEV' {
			if "`e(muvars)'"!="" qui predict `muhat', eq("mu")
				else scalar `muhat' = [mu]_cons
		}
		else local muhat (`e(threshold)')

		qui if "`pp'`qq'`return'"!="" {
			tempvar modcdf modquant empcdf empquant
			if e(stationary) qui predict `modcdf' if `touse', cdf
			else {                                                           // transform into Gumbel variate a la Coles eq 6.6
				tempvar lnsighat xihat z
				if "`e(sigvars)'"!="" qui predict `lnsighat', eq("lnsig")
					else scalar `lnsighat' = [lnsig]_cons
				if "`e(xivars)'" !="" qui predict `xihat'   , eq("xi")
					else scalar `xihat'    = [xi]_cons
				qui gen `z' = ln(1+`xihat'/exp(`lnsighat')*(`depvar'-`muhat'))/`xihat'
				qui gen `modcdf' = cond(`GEV', exp(-exp(-`z')), 1-exp(-`z'))
			}
			label var `modcdf' `"Modeled cumulative distribution `=cond(e(stationary),""," (Gumbel scale)")'"'
			sort `modcdf'

			gen `empcdf' = e(sample)
			if "`e(wtype)'"!="" {
				replace `empcdf' = `empcdf' *	`wt'
				recode `empcdf' (. = 0)
			}
			replace `empcdf' = `empcdf' + `empcdf'[_n-1] if _n>1
			replace `empcdf' = `empcdf'*(e(N)/(e(N)+1)/`empcdf'[_N]) if `touse'
			label var `empcdf' "Empirical cumulative distribution"

			if "`pp'"!="" {
				sum `empcdf' if `touse', meanonly
				scatter `modcdf' `empcdf', `mergedopts' || function y=x, range(`r(min)' `r(max)') ytitle(Modeled probability) xtitle(Empirical probability) legend(off) name(`"`name'PP"', replace) `mergedopts' `uniqueopts' || if `touse'
			}

			if "`qq'"!="" {
				if e(stationary) {
					local empquant `depvar'
					qui predict `modquant' if `touse', invccdf(1-`empcdf')
				}
				else {
					gen `modquant' = cond(`GEV', -ln(-ln(`empcdf')), -ln(1-`empcdf')) if e(sample) // Coles section 6.2.3
					local empquant `z'
				}
				label var `empquant' "Empirical quantile"
				label var `modquant' "Modeled quantile"
				sum `empquant' if `touse', meanonly
				scatter `empquant' `modquant', `mergedopts' || function y=x, range(`r(min)' `r(max)') xtitle(Modeled quantile) ytitle(Empirical quantile) legend(off) name(`"`name'QQ"', replace) `mergedopts' `uniqueopts' || if `touse'
				drop `modquant'
			}

			if "`return'"!="" {
				tempvar yp mid lo hi retperiod
				set obs `=_N+1'
				gen `retperiod' = (1/e(zeta))/(1-`empcdf')
				sum `retperiod' if e(sample), meanonly
				replace `empcdf' = 1-1/(2*r(max))/e(zeta) in `=_N'
				replace `touse'=1 in `=_N'
				forvalues i=`=ceil(log10(r(min)))'/`=floor(log10(2*r(max)))' {
					local xlabels `" `xlabels' `=cond(`GEV', -1/log(1-1/10^`i'), e(zeta)*10^`i')' "`=10^`i''" "'
				}
				gen `yp' = cond(`GEV', -1/log(`empcdf'), 1/(1-`empcdf'))
				label var `yp' "Return period"
				predictnl `mid' = `muhat' + exp([lnsig]_cons) * cond(abs([xi]_cons)<1e-10, ln(`yp'), ((`yp')^[xi]_cons-1)/[xi]_cons), ci(`lo' `hi') level(`level') force
 				label var `mid' "Point estimate"
				label var `lo' "Confidence interval minimum"
				label var `hi' "Confidence interval maximum"
				twoway rarea `lo' `hi' `yp', astyle(ci) `mergedopts' || ///
					line `mid' `yp', `mergedopts' || ///
					scatter `depvar' `yp', xscale(log) legend(off) name(`"`name'Return"', replace) ytitle("Return level") xlabel(`xlabels') `mergedopts' `uniqueopts'
				qui drop in `=_N'
			}
		}

		if "`density'"!="" {
			tempvar zero
			gen byte `zero' = 0
			sum `depvar' if e(sample), meanonly
			local x (x - `muhat')/exp([lnsig]_cons)
			local f = cond(abs([xi]_cons)<1e-5, "exp(-`x')", "(1+[xi]_cons*`x')^(-1/[xi]_cons)")
			twoway kdensity `depvar', `kdensopts' `mergedopts' || ///
				function y=1/exp([lnsig]_cons)*(`f')^(1+[xi]_cons) `=cond(`GEV', "* exp(-(`f'))","")', range(`=r(min)' `=r(max)') `mergedopts' ///
				|| scatter `zero' `depvar', ytitle(Density) msize(vsmall) msymbol("d") xtitle("") name(`"`name'Density"', replace) legend(off) `mergedopts'  `uniqueopts' || if `touse'
		}

		foreach param in xi ret rate {
			if "``param'profile'"!="" {
				local paramname = cond("`param'"=="xi", "xi", cond("`param'"=="ret", "Return level", "Return rate"))
				local 0 ``param'profile'
				syntax [anything], `=cond("`param'"=="ret", "PERiod(string)", cond("`param'"=="rate", "RETlevel(string)", ""))'
				if inlist(`"`anything'"', "", ".") local numlist .
					else {
						parse_numlist, numlist("`anything'") min(2)
						local numlist `s(numlist)'
					}
				tempname b Cns hold yp zp t t2 CI plotmat _plotmat profilell
				tempvar x ll depvar
				mat `b' = e(b)
				mat `Cns' = e(`Cns')
				if `Cns'[1,1]==. mat drop `Cns'
				if "`param'" == "xi" {
					local mlcmd ml model lf2 extreme_lf2()
					scalar `zp' = .
				}
				else if "`param'" == "ret" {
					local mlcmd ml model lf1 extreme_return_lf1()
					local period = `period'
					if `GEV' {
						scalar `yp' = -1/ln(1-1/`period')
						mat `b'[1,2] = `b'[1,1]+exp(`b'[1,2])*ln(`yp') // starting value: return level if Gumbel is mu+sig*ln(yp)
					}
					else {
						scalar `yp' = `period'*e(zeta)
						mat `b'[1,1] = exp(`b'[1,1])*ln(`yp')
					}
					scalar `zp' = `muhat' + exp([lnsig]_cons) * cond(abs([xi]_cons)<1e-10, ln(`yp'), ((`yp')^[xi]_cons-1)/[xi]_cons)
				}
				else { // rate profile
					local mlcmd ml model lf1 extreme_rate_lf1()
					local retlevel = `retlevel'
					scalar `yp' = (1 + [xi]_cons * (`retlevel'-`muhat') / exp([lnsig]_cons)) ^ (-1/[xi]_cons)
					if (`GEV') mat `b'[1,2] = 1 - exp(-`yp')
					  else     mat `b'[1,1] = `yp'
				}

				mata _extremeProfileCI = J(0,0,0)
				if `GEV' {
					local mlcmd `mlcmd' (mu:`e(muvars)')
					mata _extremeDepVar = st_data(., st_global("e(depvar)"))
				}
				else {
					gen double `depvar' = `e(depvar)' - `e(threshold)'
					mata _extremeDepVar = st_data(., "`depvar'")
				}
				local mlcmd `mlcmd' (lnsig:`e(sigvars)') /xi  [`e(wtype)'`wexp'], collinear nopreserve constraints(`Cns') nocnsnotes
				_est hold `hold', restore
				`mlcmd'
				ml init `b', copy
				_estimates unhold `hold'
				mata moptimize_init_userinfo($ML_M, 3, extreme_est_prep(_extremeDepVar))
				mata moptimize_init_userinfo($ML_M, 2, _extremeDepVar)
				mata moptimize_init_userinfo($ML_M, 1, `GEV')
				mata _extremeNumlist = strtoreal(tokens(st_local("numlist")))'
				if "`param'"=="xi" {
					mata _extremeProfileLL = extremeProfile($ML_M, `e(k)   ', "`paramname'", _extremeNumlist, 0              , st_numscalar("e(ll)"), `level', _extremeProfileCI)
				}
				else if "`param'"=="ret" {
					mata moptimize_init_userinfo($ML_M, 4, st_numscalar("`yp'"))
					if !`GEV' mata _extremeNumlist = _extremeNumlist :- `e(threshold)'
					mata _extremeProfileLL = extremeProfile($ML_M, `=e(k)-1', "`paramname'", _extremeNumlist, 0`e(threshold)', st_numscalar("e(ll)"), `level', _extremeProfileCI)
				}
				else {
					mata moptimize_init_userinfo($ML_M, 4, `GEV'? `retlevel' : `retlevel'-`=`muhat'')
					mata _extremeProfileLL = extremeProfile($ML_M, `=e(k)-1', "`paramname'", _extremeNumlist, 0              , st_numscalar("e(ll)"), `level', _extremeProfileCI)
				}
				ml clear
				local N = _N

				mata st_matrix("`plotmat'", _extremeProfileLL)
				mata st_matrix("`CI'", _extremeProfileCI)
				scalar `profilell' = e(ll) - invchi2(1,`level'/100)/2
				cap confirm matrix `plotmat'
				if !_rc {
					di
					cap confirm matrix `CI'
					if _rc mat `_plotmat' = `plotmat'
						else mat `_plotmat' = `plotmat' \ ((`CI'[1...,1] \ `CI'[1...,2]), J(2*rowsof(`CI'), 1, `profilell'))
					mat colnames `_plotmat' = `x' `ll'
					qui svmat `_plotmat', names(col)
					qui if !`GEV' & "`param'"=="ret" replace `x' = `x' + `e(threshold)'
					label var `ll' "Profile log likelihood"
					label var `x' "`paramname'"
					if `level' < 100 {
						if        "`param'"=="xi"  local profilemid = [xi]_cons
							else if "`param'"=="ret" local profilemid = `muhat' + exp([lnsig]_cons)*(`yp'^[xi]_cons-1)/[xi]_cons
							else                     local profilemid = `yp'
						local lineopts xline(`profilemid', lpattern(dash)) yline(`=`profilell'')
						cap confirm matrix `CI'
						if _rc {
							di as res "Profile-based `level'% confidence for `:var label `x'' interval appears to extend beyond graphing bounds." 
							di "Could not be constructed. Try widening the bounds."
						}
						else {
							if !`GEV' & "`param'"=="ret" mata st_matrix("`CI'", st_matrix("`CI'") :+ `e(threshold)')
							mat colnames `CI' = ll ul
							di as res "Profile-based `level'% confidence set for " lower("`paramname'") ":" _c
							forvalues r = 1/`=rowsof(`CI')' {
								if `r'>1 di " U" _c
								di  " [" `CI'[`r',1] ", " `CI'[`r',2] "]" _c
								if `CI'[`r',1]<. | `CI'[`r',2]<. local lineopts `lineopts' xline(`=cond(`=`CI'[`r',1]'==.,"","`=`CI'[`r',1]'")' `=cond(`=`CI'[`r',2]'==.,"","`=`CI'[`r',2]'")', lpattern(dash))
							}
							ereturn matrix `param'profileCI = `CI'
							di _n
						}
					}
					format `x' %5.0g
					line `ll' `x', sort(`x') || scatter `ll' `x' if _n>rowsof(`plotmat'), legend(off) mlabel(`x') mlabpos(6) `lineopts' name(`name'`=proper("`param'")'Profile, replace) `mergedopts' `uniqueopts'
					qui keep if _n <= `N'
					ereturn matrix `param'profileplot = `plotmat'
				}
				else di as res "Nothing to plot."

				mata mata drop _extremeDepVar _extremeProfileLL _extremeNumlist _extremeProfileCI
				cap mata mata drop _extremeYp
			}
		}
		restore
	}
	else { // nlcom
/*		macro shift
		if "`e(b_bs)'" == "" nlcom `*'
		else {
			tempname b b_bs hold t
			mat `b_bs' = e(b_bs)
			mat `t' = J(
			_est hold `hold', restore
			for i=1/`=rowsof(`b_bs')' {
				mat `b' = `b_bs'[`i',1...]
				ereturn post `b'
				mat `t' = `*'
			
		}*/
	}
end

// built-in _get_eformopts and _get_diopts don't align with ml display option sets
// This routine extracts all acceptable ml display options
cap program drop _get_mldiopts
program define _get_mldiopts, sclass
	syntax, [NOHeader NOFOOTnote First neq(passthru) SHOWEQns PLus NOCNSReport NOOMITted vsquish NOEMPTYcells BASElevels ALLBASElevels cformat(passthru) pformat(passthru) sformat(passthru) NOLSTRETCH coeflegend *]
	sreturn local diopts `noheader' `nofootnote' `first' `neq' `showeqns' `plus' `nocnsreport' `noomitted' `vsquish' `noemptycells' `baselevels' `allbaselevels' `cformat' `pformat' `sformat' `nolstretch' `coeflegend' `shr'
	sreturn local options `options'
end

cap program drop parse_profile_opts
program define parse_profile_opts, sclass
	syntax, [XIPROFile RETPROFile *]
	local _xiprofile `xiprofile'
	local _retprofile `retprofile'
	local _rateprofile `rateprofile'
	local 0, `options'
	syntax, [XIPROFile(string) RETPROFile(string) RATEPROFile(string)*]
	sreturn local options `options'
	sreturn local xiprofile  = cond(`"`xiprofile'"' =="", cond("`_xiprofile'" =="", "", "."), `"`xiprofile'"' )
	sreturn local retprofile = cond(`"`retprofile'"'=="", cond("`_retprofile'"=="", "", "."), `"`retprofile'"')
	sreturn local rateprofile = cond(`"`rateprofile'"'=="", cond("`_rateprofile'"=="", "", "."), `"`rateprofile'"')
end

cap program drop _get_kdensopts
program define _get_kdensopts, sclass
	syntax, [BWidth(passthru) Kernel(passthru) Range(passthru) n(passthru) area(passthru) HORizontal *]
	sreturn local kdensopts `bwidth' `kernel' `range' `n' `area' `horizontal'
	sreturn local options `options'
end

cap program drop Display
program Display
	version 11.0
	syntax [, Level(int $S_level) *]
	ml display, level(`level') `options' `e(diparmopts)'
end

// parse a numlist. If it has 2 entries, interpret them as bounds with 100 steps between
// if either of the 2 is missing and optional variable name provided, then interpret them as variable's min/max over entire data set
cap program drop parse_numlist
program define parse_numlist, sclass
	version 11.0
	syntax, numlist(string) min(string) [var(string)]
	numlist "`numlist'", min(`min') `=cond(`"`var'"'!="", "missingok", "")'
	if `: word count `r(numlist)''==2 {
		tokenize `r(numlist)'
		if `1'>=. | `2'>=. {
			sum `var', meanonly
			if `1'>=. local 1 = r(min)
			if `2'>=. local 2 = r(max)
		}
		numlist "`1'(`=(`2'-`1'-epsdouble())/100')`2'"
	}
	else numlist "`r(numlist)'", sort
	sreturn local numlist `r(numlist)'
end

* 1.2.0 Fixed failure to incorporate weights in computing zeta. Improved code for determining confidence sets. Added rateprofile plot.
* 1.1.7 Fixed ignoring weights. Fixed bug Cox-Snell correction with weights causing massive overcorrection.
* 1.1.6 Added from() option. Added scores option to predict. Fixed bug 1.1.4 bug in weight handling.
* 1.1.5 Added nolog to -ml- passthrough options
* 1.1.4 Fixed numerous bugs
* 1.1.3 If multiple thresholds requested, no estimation results displayed or left behind
* 1.1.2 Added xcommon to twoway command for plot for multiple thresholds
* 1.1.1 Assured random numbers in extreme_BS() always non-zero
* 1.1.0 Added small(bs). Fixed bugs.
