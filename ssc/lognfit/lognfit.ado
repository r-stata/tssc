*! version 1.2.2 Stephen P. Jenkins, June 2013 (fix bug in post-estimation Lp`x' calculation)
*! version 1.2.1 Stephen P. Jenkins, March 2007
*! Fit lognormal distribution by ML to unit record data


/*------------------------------------------------ playback request */
 
program define lognfit, eclass byable(onecall)
	version 8.2
	if replay() {
		if "`e(cmd)'" != "lognfit" {
			noi di as error "results for lognfit not found"
			exit 301
		}
		if _by() { 
			error 190 
		} 
		Display `0'
		exit `rc'
	}
	if _by() {
		by `_byvars'`_byrc0': Estimate `0'
	}
	else	Estimate `0'
end

/*------------------------------------------------ estimation */

program define Estimate, eclass byable(recall)

	syntax varlist(max=1) [if] [in] [aw fw pw iw] [,  ///
		Mvar(varlist numeric) Vvar(varlist numeric) MANDV(varlist numeric) ///
		CDF(namelist max=1) PDF(namelist max=1) POORfrac(real 0) ///
		Robust Cluster(varname) SVY STats  From(string)  ///
		Level(integer $S_level)    ///
		noLOG * ]


	local title "ML fit of lognormal distribution"

	local inc "`varlist'"

        if "`mandv'" ~= "" & (("`mvar'"~="")|("`vvar'"~="")) {
                di as error "Cannot use mandv(.) option in conjunction with mvar(.), vvar(.) options"
                exit 198
        }

        if "`mandv'" ~= "" {
                local mvar "`mandv'"
                local vvar "`mandv'"
        }
	
	local nm : word count `mvar'
	local nv : word count `vvar'

	if ("`mvar'"~="")|("`vvar'"~="") {
		if ("`stats'"~= "") {
			noi di as error "stats option not available for model with covariates"
			exit 198
		}	
		if ("`poorfrac'"~="") & `poorfrac' > 0   {
			noi di as error "poorfrac option not available for model with covariates"
			exit 198
		}
		if ("`pdf'"~="") {
			noi di as error "pdf option not available for model with covariates"
			exit 198
		}
		if ("`cdf'"~="") {
			noi di as error "cdf option not available for model with covariates"
			exit 198
		}
	}

	if "`cdf'" ~= "" {
		confirm new variable `cdf' 
	}
	if "`pdf'" ~= "" {
		confirm new variable `pdf' 
	}

	if  (`poorfrac' < 0)  {
		di as error "poorfrac value must be positive"
		exit 198
	}

	local option0 `options'

	local wtype `weight'
	local wtexp `"`exp'"'
	if "`weight'" != "" { 
		local wgt `"[`weight'`exp']"'  
	}

	if "`weight'" == "pweight" & "`svy'" == "" {
		di as error "To use pweights, -svyset- your data, and use -svy- option"
		exit
	}

	if "`weight'" == "pweight" | "`cluster'" != "" {
	        local robust "robust"
	}

	if "`cluster'" ! = "" { 
		local clopt "cluster(`cluster')" 
	}


	if "`level'" != "" {
		local level "level(`level')"
	}
	
        local log = cond("`log'" == "", "noisily", "quietly") 
	
	marksample touse 
	markout `touse' `varlist' `mvar' `vvar' `cluster'
	if "`svy'" ~= "" {
		svymarkout `touse'
		svyopts modopts diopts options, `option0'		
	}
	mlopts mlopts, `options'

	set more off

	quietly {

	  count if `inc' < 0 & `touse'
	  local ct =  r(N) 
	  if `ct' > 0 {
		noi di " "
		noi di as txt "Warning: {res:`inc'} has `ct' values < 0." _c
		noi di as text " Not used in calculations"
		}

	  count if `inc' == 0 & `touse'
	  local ct =  r(N) 
	  if `ct' > 0 {
		noi di " "
		noi di as txt "Warning: {res:`inc'} has `ct' values = 0." _c
		noi di as text " Not used in calculations"
		}

	  replace `touse' = 0 if `inc' <= 0

	}

        qui count if `touse' 
        if r(N) == 0 {
		error 2000 
	}


	if "`from'" != ""  {
		local b0 "`from'"
	}

	global S_mlinc "`inc'"


	`log' ml model lf lognfit_ll (m: `mvar') (v: `vvar')  		///
		`wgt' if `touse' , maximize 				 ///
		collinear title(`title') `robust' `svy'  init(`b0')	 ///
		search(on) `clopt' `level' `mlopts' `stdopts' `modopts'


	eret local cmd "lognfit"
	eret local depvar "`inc'"

	tempname b bm bv
	mat `b' = e(b)
	mat `bm' = `b'[1,"m:"] 
	mat `bv' = `b'[1,"v:"]

	eret matrix b_m = `bm'
	eret matrix b_v = `bv'
	eret scalar length_b_m = 1 + `nm'
	eret scalar length_b_v = 1 + `nv'

	if ("`mvar'"!="" | "`vvar'"!=""  ) {
		eret scalar nocov = 0
	}


	if "`mvar'"=="" & "`vvar'"==""  {

		tempname e		

		mat `e' = e(b)
		local m = `e'[1,1]
		local v = `e'[1,2]

		eret scalar bm = `m'
		eret scalar bv = `v'

		eret scalar nocov = 1
	

			/* Estimated lognormal c.d.f. */

		if "`cdf'" ~= "" {		 	
			qui ge `cdf' = norm( (ln(`inc') - `m')/`v' ) if `touse'
		 	eret local cdfvar "`cdf'"
		}


			/* Estimated lognormal p.d.f. */
	
		if "`pdf'" ~= "" {
		 	qui ge `pdf' = ((`inc'*sqrt(2*_pi)*`v')^(-1)) *  ///
	 				exp( -.5*((`v')^(-2))*(ln(`inc')-`m')^2 )  ///
					if `touse'
			eret local pdfvar "`pdf'"
		}

			/* selected quantiles predicted from lognormal model */
			/* Lorenz curve ordinates at selected quantiles */

		if "`stats'" ~= "" {
			eret scalar mean = exp( `m' + .5*(`v')^2 )
			eret scalar mode = exp( `m' - (`v')^2 )
			local omega = exp(`v'^2)
			eret scalar var = exp(2*`m')*`omega'*(`omega'-1)
			eret scalar sd = sqrt(`e(var)')
			eret scalar i2 = .5*`e(var)'/(`e(mean)'*`e(mean)')
			eret scalar gini = 2*norm(`v'/sqrt(2)) - 1
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {	
				eret scalar p`x' = exp(`m' + `v'*invnorm(`x'/100) )
				eret scalar Lp`x' = norm(  invnorm(`x'/100) - `v'  ) 
			}
		}

			/* Fraction with income below given level */
	
		if "`poorfrac'" ~= "" & `poorfrac' > 0 {
			eret scalar poorfrac = norm( (ln(`poorfrac') - `m')/`v' )	
			eret scalar pline = `poorfrac'
		}
	}

	if "`poorfrac'" ~= "" & `poorfrac' > 0 {
		local pfrac "poorfrac(`poorfrac')"
	}


	Display, `level' `pfrac' `diopts'


end

program define Display
	syntax [,Level(int $S_level) POORfrac(real 0)  *]
	local diopts "`options'"
	ml display, level(`level') `diopts'
	if `level' < 10 | `level' > 99 {
		local level = 95
		}

	if  (`poorfrac' < 0)  {
		di as error "poorfrac value must be positive"
		exit 
	}

	if `poorfrac' > 0 & (`e(nocov)' == 0) {
		di as error "poorfrac option not available (model was specified with covariates)"
		exit
	}

	if `poorfrac' > 0 & (`e(nocov)' == 1)  {
		di " "
		di "Fraction with {res: `e(depvar)'} < `poorfrac' = " as res %9.5f norm( (ln(`poorfrac') - `e(bm)')/`e(bv)' )
		di " "
	}


	if ("`e(mean)'" ~= "")  {

		di as txt "{hline 60}"
		di as txt  _col(6) "Quantiles" _col(22) "Cumulative shares of" 
		di as txt  _col(22) "total `e(depvar)' (Lorenz ordinates)"
		di as txt "{hline 60}"
		di as txt  " 1%" _col(6) as res %9.5f `e(p1)' _col(20) %9.5f `e(Lp1)'
		di as txt  " 5%" _col(6) as res %9.5f `e(p5)' _col(20) %9.5f `e(Lp5)'
		di as txt  "10%" _col(6) as res %9.5f `e(p10)' _col(20) %9.5f `e(Lp10)'
		di as txt  "20%" _col(6) as res %9.5f `e(p20)' _col(20) %9.5f `e(Lp20)'
		di as txt  "25%" _col(6) as res %9.5f `e(p25)' _col(20) %9.5f `e(Lp25)'
		di as txt  "30%" _col(6) as res %9.5f `e(p30)' _col(20) %9.5f `e(Lp30)'
		di as txt  "40%" _col(6) as res %9.5f `e(p40)' _col(20) %9.5f `e(Lp40)' _c
		di as txt  _col(30) "Mode" _col(42) as res %9.5f `e(mode)'
		di as txt  "50%" _col(6) as res %9.5f `e(p50)' _col(20) %9.5f `e(Lp50)' _c
		di as txt  _col(30) "Mean" _col(42) as res %9.5f `e(mean)'
		di as txt  "60%" _col(6) as res %9.5f `e(p60)' _col(20) %9.5f `e(Lp60)' _c
		di as txt  _col(30) "Std. Dev." _col(42) as res %9.5f `e(sd)'
		di as txt  "70%" _col(6) as res %9.5f `e(p70)' _col(20) %9.5f `e(Lp70)'
		di as txt  "75%" _col(6) as res %9.5f `e(p75)' _col(20) %9.5f `e(Lp75)' _c
		di as txt  _col(30) "Variance" _col(42) as res %9.5f `e(var)'
		di as txt  "80%" _col(6) as res %9.5f `e(p80)' _col(20) %9.5f `e(Lp80)' _c
		di as txt  _col(30) "Half CV^2" _col(42) as res %9.5f `e(i2)'
		di as txt  "90%" _col(6) as res %9.5f `e(p90)' _col(20) %9.5f `e(Lp90)' _c
		di as txt  _col(30) "Gini coeff." _col(42) as res %9.5f `e(gini)'
		di as txt  "95%" _col(6) as res %9.5f `e(p95)' _col(20) %9.5f `e(Lp95)' _c
		di as txt  _col(30) "p90/p10" _col(42) as res %9.5f `e(p90)'/`e(p10)'
		di as txt  "99%" _col(6) as res %9.5f `e(p99)' _col(20) %9.5f `e(Lp99)' _c
		di as txt  _col(30) "p75/p25" _col(42) as res %9.5f `e(p75)'/`e(p25)'
		di as txt "{hline 60}"

	} 


end



