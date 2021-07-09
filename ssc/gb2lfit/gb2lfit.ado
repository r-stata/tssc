*! version 3.0.0 SPJ, October 2007 Add left-truncation option
*! version 2.1.0 Stephen P. Jenkins, 11 April 2007
*!	Revise Gini calc; add GE indices; etc
*! version 2.0.0 Stephen P. Jenkins, 28 May 2006
*! version 1.2.0 Stephen P. Jenkins, April 2004
*! Fit GB2 distribution by ML to unit record data (log parameter metric)


/*------------------------------------------------ playback request */
 
program define gb2lfit, eclass byable(onecall)
	version 8.2
	if replay() {
		if "`e(cmd)'" != "gb2lfit" {
			noi di as error "results for gb2lfit not found"
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
		Avar(varlist numeric) Bvar(varlist numeric) Pvar(varlist numeric) Qvar(varlist numeric) ///
		ABPQ(varlist numeric) CENSvar(varname) From(string) ///
		CDF(namelist max=1) PDF(namelist max=1) POORfrac(real 0) ///
		Robust Cluster(varname) SVY  STats  ///
		Level(integer $S_level) CGINI EPSilon(real 1e-10) EXtras ///
		IGINI NIPS(integer 5000) LEFTtr(varname) ///
		noLOG  * ]

	local title "ML fit of GB2 distribution"

	local inc "`varlist'"
	
	if "`abpq'" ~= "" & (("`avar'"~="")|("`bvar'"~="")|("`pvar'"~="")|("`qvar'"~="")) {
		di as error "Cannot use abpq(.) option in conjunction with avar(.), bvar(.), pvar(.), qvar(.) options"
		exit 198
	}

	if "`abpq'" ~= "" {
		local avar "`abpq'"
		local bvar "`abpq'"
		local pvar "`abpq'"
		local qvar "`abpq'"
	}

	local na : word count `avar'
	local nb : word count `bvar'
	local np : word count `pvar'
	local nq : word count `qvar'

	if ("`avar'"~="")|("`bvar'"~="")|("`pvar'"~="")|("`qvar'"~="") {
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
	markout `touse' `varlist' `avar' `bvar' `pvar' `qvar' `cluster' `censvar' 
	if "`svy'" ~= "" {
		svymarkout `touse'
		svyopts modopts diopts options, `option0'

		eret local diopts "`diopts'"
	}
	mlopts mlopts, `options'


	set more off

quietly {

	count if `inc' < 0 & `touse'
	local ct =  r(N) 
	if `ct' > 0 {
		noi di " "
		noi di as text "Warning: {res:`inc'} has `ct' values < 0;" _c
		noi di as text " not used in calculations"
	  }

	count if `inc' == 0 & `touse'
	local ct =  r(N) 
	if `ct' > 0 {
		noi di " "
		noi di as text "Warning: {res:`inc'} has `ct' values = 0;" _c
		noi di as text " not used in calculations"
	}

	replace `touse' = 0 if `inc' <= 0


        count if `touse' 
        if r(N) == 0 {
		error 2000 
	}

	if "`censvar'" != "" {
		capture quietly assert (`censvar' == 1 | `censvar' == 0) if `touse'
		if _rc != 0 {
			di as error "censvar must be 0/1 variable"
			exit 198
		}
	}

	if "`lefttr'" != "" replace `touse' = 0 if `inc' < `lefttr'
	global S_mlz "`lefttr'"


	if "`from'" != ""  {
		local b0 "`from'"
	}

	global S_mlinc "`inc'"
	global S_mlcens "`censvar'"

	`log' ml model lf gb2lfit_ll (ln_a: `avar') (ln_b: `bvar') (ln_p: `pvar') (ln_q: `qvar') 	///
		`wgt' if `touse' , maximize 						///
		collinear title(`title') `robust' `svy' init(`b0')		 		///
		search(on) `clopt' `level' `mlopts' `stdopts' `modopts'

	eret local cmd "gb2lfit"
	eret local depvar "`inc'"
	if "`censvar'" != "" eret local censvar "`censvar'"
	if "`lefttr'" != "" eret local lefttr "`lefttr'"


	tempname b ba bb bp bq
	mat `b' = e(b)
	mat `ba' = `b'[1,"ln_a:"] 
	mat `bb' = `b'[1,"ln_b:"]
	mat `bp' = `b'[1,"ln_p:"]
	mat `bq' = `b'[1,"ln_q:"]

	eret matrix b_lna = `ba'
	eret matrix b_lnb = `bb'
	eret matrix b_lnp = `bp'
	eret matrix b_lnq = `bq'
	eret scalar length_b_lna = 1 + `na'
	eret scalar length_b_lnb = 1 + `nb'
	eret scalar length_b_lnp = 1 + `np'
	eret scalar length_b_lnq = 1 + `nq'

	if ("`avar'"!="" | "`bvar'"!="" | "`pvar'"!=""  | "`qvar'"!="") {
		eret scalar nocov = 0
	}
	
	if "`avar'"=="" & "`bvar'"=="" & "`pvar'"=="" & "`qvar'"=="" {

		tempname e v		

		mat `e' = e(b)
		local a = exp(`e'[1,1])
		local b = exp(`e'[1,2])
		local p = exp(`e'[1,3])
		local q = exp(`e'[1,4])

		eret scalar ba = `a'
		eret scalar bb = `b'
		eret scalar bp = `p'
		eret scalar bq = `q'

		mat `v' = e(V)
		eret scalar se_a = `a' * sqrt(`v'[1,1])
		eret scalar se_b = `b' * sqrt(`v'[2,2])
		eret scalar se_p = `p' * sqrt(`v'[3,3])
		eret scalar se_q = `q' * sqrt(`v'[4,4])

		eret scalar nocov = 1
		eret local svy "`svy'"
	
			/* Estimated GB2 c.d.f. */

		if "`cdf'" ~= "" {		 	
			qui ge `cdf' = ibeta(`p',`q', (`inc'/`b')^`a'/(1+(`inc'/`b')^`a') ) if `touse'
		 	eret local cdfvar "`cdf'"
		}


			/* Estimated GB2 p.d.f. */
	
		if "`pdf'" ~= "" {
		 	qui ge `pdf' = (`a'*(`inc')^(`a'*`p'-1))*exp(lngamma(`p'+`q')) / (		  ///
	 				 (`b'^(`a'*`p'))*exp(lngamma(`p') + lngamma(`q'))  ///
					  *( (1 +(`inc'/`b')^`a')^(`p'+`q') ) ///
					) if `touse'
			eret local pdfvar "`pdf'"
		}


			/* Fraction with income below given level */
	
		if "`poorfrac'" ~= "" & `poorfrac' > 0 {
			eret scalar poorfrac = ibeta(`p',`q', (`poorfrac'/`b')^`a'/(1+(`poorfrac'/`b')^`a') )
			eret scalar pline = `poorfrac'
		}


			/* selected quantiles predicted from GB2 model */
			/* Lorenz curve ordinates at selected quantiles */

		if "`stats'" ~= "" {
			eret scalar mean = `b'*exp(				///
						lngamma(`p'+1/`a') 		///
						+ lngamma(`q'-1/`a') 		/// 
						- lngamma(`p')			///
						- lngamma(`q') 			///
						) 
			eret scalar mode = cond(`a'*`p'>1,`b'*(((`a'*`p'-1)/(`a'*`q'+1))^(1/`a')),0,.)
			eret scalar var = `b'*`b'*exp(				///
						lngamma(`p'+2/`a') 		///
					   	+ lngamma(`q'-2/`a')		///
					        - lngamma(`p')			///
						- lngamma(`q')			///
						) - (`e(mean)'*`e(mean)')
			eret scalar sd = sqrt(`e(var)')
			eret scalar i2 = .5*`e(var)'/(`e(mean)'*`e(mean)')
			eret scalar gini = .
			// Gini coeff is function of generalized hypergeometric function!!!
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname ib	
				scalar `ib' = invibeta(`p',`q',`x'/100)
				eret scalar p`x' =  `b'* (`ib'/(1-`ib'))^(1/`a') 
				eret scalar Lp`x' = ibeta(`p'+1/`a',`q'-1/`a',(`e(p`x')'/`b')^`a'/(1+(`e(p`x')'/`b')^`a') )
			}
			eret scalar p90p10 = `e(p90)'/`e(p10)'
			eret scalar p75p25 = `e(p75)'/`e(p25)'

		}

			/* Selected GE inequality indices & other stats */
		if "`extras'" != "" {
			nlcom (aXp:    ( exp([ln_a]_cons) * exp([ln_p]_cons)) ) ///
		          (aXq:    ( exp([ln_a]_cons) * exp([ln_q]_cons) ) )	///
			(mean: exp([ln_b]_cons)*exp(				///
			  lngamma( exp([ln_p]_cons)+1/exp([ln_a]_cons))  	///
			+ lngamma( exp([ln_q]_cons)-1/exp([ln_a]_cons))  	///
			- lngamma( exp([ln_p]_cons))  				///
			- lngamma( exp([ln_q]_cons)) 				///
			))							///
			(var: (exp([ln_b]_cons))^2*exp(				///
			  lngamma( exp([ln_p]_cons)+2/exp([ln_a]_cons))  	///
			+ lngamma( exp([ln_q]_cons)-2/exp([ln_a]_cons))  	///
			- lngamma( exp([ln_p]_cons))  				///
			- lngamma( exp([ln_q]_cons)) 				///
			)							///
			- ( exp([ln_b]_cons)*exp(				///
			  lngamma( exp([ln_p]_cons)+1/exp([ln_a]_cons))  	///
			+ lngamma( exp([ln_q]_cons)-1/exp([ln_a]_cons))  	///
			- lngamma( exp([ln_p]_cons))  				///
			- lngamma( exp([ln_q]_cons)) ))^2			///
			)							///
			(sd: sqrt( (exp([ln_b]_cons))^2*exp(			///
			  lngamma( exp([ln_p]_cons)+2/exp([ln_a]_cons))  	///
			+ lngamma( exp([ln_q]_cons)-2/exp([ln_a]_cons))  	///
			- lngamma( exp([ln_p]_cons))  				///
			- lngamma( exp([ln_q]_cons)) 				///
			)							///
			- ( exp([ln_b]_cons)*exp(				///
			  lngamma( exp([ln_p]_cons)+1/exp([ln_a]_cons))  	///
			+ lngamma( exp([ln_q]_cons)-1/exp([ln_a]_cons))  	///
			- lngamma( exp([ln_p]_cons))  				///
			- lngamma( exp([ln_q]_cons)) ))^2 )			///
			)							///
			(GEm1: -.5 + exp( lngamma(exp([ln_p]_cons)-1/exp([ln_a]_cons)) ///
				+ lngamma(exp([ln_q]_cons)+1/exp([ln_a]_cons)) 	///
				+ lngamma(exp([ln_p]_cons)+1/exp([ln_a]_cons))	///
				+ lngamma(exp([ln_q]_cons)-1/exp([ln_a]_cons))	///
				- 2*lngamma(exp([ln_p]_cons))			///
				- 2*lngamma(exp([ln_q]_cons))  - ln(2) ) 	///
			)							///
			(GE0: lngamma( exp([ln_p]_cons)+1/exp([ln_a]_cons))	///
			+ lngamma( exp([ln_q]_cons)-1/exp([ln_a]_cons))  	///
			- lngamma( exp([ln_p]_cons))  				///
			- lngamma( exp([ln_q]_cons)) 				///
			- digamma(exp([ln_p]_cons))/exp([ln_a]_cons)		///
			+ digamma(exp([ln_q]_cons))/exp([ln_a]_cons)		///
			)							///
			(GE1: lngamma( exp([ln_p]_cons))			///
			+ lngamma( exp([ln_q]_cons)) 				///
			- lngamma( exp([ln_p]_cons)+1/exp([ln_a]_cons))		///
			- lngamma( exp([ln_q]_cons)-1/exp([ln_a]_cons))  	///
			+ digamma(exp([ln_p]_cons)+1/exp([ln_a]_cons))/exp([ln_a]_cons)	///
			- digamma(exp([ln_q]_cons)-1/exp([ln_a]_cons))/exp([ln_a]_cons)	///
			)							///
			(GE2: -.5 + exp( lngamma(exp([ln_p]_cons)) + lngamma(exp([ln_q]_cons)) ///
				+ lngamma(exp([ln_p]_cons)+2/exp([ln_a]_cons))	///
				+ lngamma(exp([ln_q]_cons)-2/exp([ln_a]_cons))	///
				- 2*lngamma(exp([ln_p]_cons)+1/exp([ln_a]_cons))	///
				- 2*lngamma(exp([ln_q]_cons)-1/exp([ln_a]_cons))  - ln(2) ) ///
			)

			tempname bGE VGE
			matrix `VGE' = r(V)
			matrix	`bGE' = r(b)				
			ereturn matrix V_GE = `VGE', copy
			ereturn matrix b_GE = `bGE', copy

			ereturn scalar aXp = `bGE'[1,1]
			ereturn scalar aXq = `bGE'[1,2]
			ereturn scalar cmean = `bGE'[1,3]
			ereturn scalar cvar = `bGE'[1,4]
			ereturn scalar csd = `bGE'[1,5]
			ereturn scalar GEm1 = `bGE'[1,6]
			ereturn scalar GE0 = `bGE'[1,7]
			ereturn scalar GE1 = `bGE'[1,8]
			ereturn scalar GE2 = `bGE'[1,9]

			ereturn scalar se_aXp = sqrt(`VGE'[1,1])
			ereturn scalar se_aXq = sqrt(`VGE'[2,2])
			ereturn scalar se_cmean = sqrt(`VGE'[3,3])
			ereturn scalar se_cvar = sqrt(`VGE'[4,4]) 
			ereturn scalar se_csd = sqrt(`VGE'[5,5]) 
			ereturn scalar se_GEm1 = sqrt(`VGE'[6,6])
			ereturn scalar se_GE0 = sqrt(`VGE'[7,7]) 
			ereturn scalar se_GE1 = sqrt(`VGE'[8,8]) 
			ereturn scalar se_GE2 = sqrt(`VGE'[9,9]) 

			// estimated quantiles, top shares, etc.

			* overall 
			quantcalc `a' `b' `p' `q' 
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				eret scalar cp`x' = `p`x'est'
				eret scalar cLp`x' = `Lp`x'est'
			}
			eret scalar cp75p25 = `p75p25est'
			eret scalar cp90p10 = `p90p10est'
			eret scalar cshtop01 = `shtop01est'
			eret scalar cshtop05 = `shtop05est'
			eret scalar cshtop10 = `shtop10est'

			* Recalculations for numerical differentiation

			tempname a1 a2 b1 b2 p1 p2 q1 q2
			scalar `a1' = `a' - `a'/100
			scalar `a2' = `a' + `a'/100
			scalar `b1' = `b' - `b'/100
			scalar `b2' = `b' + `b'/100
			scalar `p1' = `p' - `p'/100
			scalar `p2' = `p' + `p'/100
			scalar `q1' = `q' - `q'/100
			scalar `q2' = `q' + `q'/100

			quantcalc `a1' `b' `p' `q'  
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname cp`x'a1 cLp`x'a1
				scalar `cp`x'a1' = `p`x'est'
				scalar `cLp`x'a1' = `Lp`x'est'
			}
			tempname cp75p25a1 cp90p10a1 cshtop01a1 cshtop05a1 cshtop10a1
			scalar `cp75p25a1' = `p75p25est'
			scalar `cp90p10a1' = `p90p10est'
			scalar `cshtop01a1' = `shtop01est'
			scalar `cshtop05a1' = `shtop05est'
			scalar `cshtop10a1' = `shtop10est'

			quantcalc `a2' `b' `p' `q'  
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname cp`x'a2 cLp`x'a2
				scalar `cp`x'a2' = `p`x'est'
				scalar `cLp`x'a2' = `Lp`x'est'
			}
			tempname cp75p25a2 cp90p10a2 cshtop01a2 cshtop05a2 cshtop10a2
			scalar `cp75p25a2' = `p75p25est'
			scalar `cp90p10a2' = `p90p10est'
			scalar `cshtop01a2' = `shtop01est'
			scalar `cshtop05a2' = `shtop05est'
			scalar `cshtop10a2' = `shtop10est'

				// partial multiplied by parameter since logparameter metric
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname aprimep`x' aprimeLp`x'
				scalar `aprimep`x'' = `a' * (`cp`x'a1' - `cp`x'a2')/(`a'/50)
				scalar `aprimeLp`x'' = `a' * (`cLp`x'a1' - `cLp`x'a2')/(`a'/50)
			}
			tempname aprimep75p25 aprimep90p10 aprimetop01 aprimetop05 aprimetop10 
			scalar `aprimep75p25' = `a' * (`cp75p25a1' - `cp75p25a2')/(`a'/50)
			scalar `aprimep90p10' = `a' * (`cp90p10a1' - `cp90p10a2')/(`a'/50)
			scalar `aprimetop01' = `a' * (`cshtop01a1' - `cshtop01a2')/(`a'/50)
			scalar `aprimetop05' = `a' * (`cshtop05a1' - `cshtop05a2')/(`a'/50)
			scalar `aprimetop10' = `a' * (`cshtop10a1' - `cshtop10a2')/(`a'/50)

			quantcalc `a' `b1' `p' `q'  
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname cp`x'b1 cLp`x'b1
				scalar `cp`x'b1' = `p`x'est'
				scalar `cLp`x'b1' = `Lp`x'est'
			}
			tempname cp75p25b1 cp90p10b1 cshtop01b1 cshtop05b1 cshtop10b1
			scalar `cp75p25b1' = `p75p25est'
			scalar `cp90p10b1' = `p90p10est'
			scalar `cshtop01b1' = `shtop01est'
			scalar `cshtop05b1' = `shtop05est'
			scalar `cshtop10b1' = `shtop10est'

			quantcalc `a' `b2' `p' `q'  
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname cp`x'b2 cLp`x'b2
				scalar `cp`x'b2' = `p`x'est'
				scalar `cLp`x'b2' = `Lp`x'est'
			}
			tempname cp75p25b2 cp90p10b2 cshtop01b2 cshtop05b2 cshtop10b2
			scalar `cp75p25b2' = `p75p25est'
			scalar `cp90p10b2' = `p90p10est'
			scalar `cshtop01b2' = `shtop01est'
			scalar `cshtop05b2' = `shtop05est'
			scalar `cshtop10b2' = `shtop10est'

				// partial multiplied by parameter since logparameter metric
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname bprimep`x' bprimeLp`x'
				scalar `bprimep`x'' = `b' * (`cp`x'b1' - `cp`x'b2')/(`b'/50)
				scalar `bprimeLp`x'' = `b' * (`cLp`x'b1' - `cLp`x'b2')/(`b'/50)
			}
			tempname bprimep75p25 bprimep90p10 bprimetop01 bprimetop05 bprimetop10 
			scalar `bprimep75p25' = `b' * (`cp75p25b1' - `cp75p25b2')/(`b'/50)
			scalar `bprimep90p10' = `b' * (`cp90p10b1' - `cp90p10b2')/(`b'/50)
			scalar `bprimetop01' = `b' * (`cshtop01b1' - `cshtop01b2')/(`b'/50)
			scalar `bprimetop05' = `b' * (`cshtop05b1' - `cshtop05b2')/(`b'/50)
			scalar `bprimetop10' = `b' * (`cshtop10b1' - `cshtop10b2')/(`b'/50)

			quantcalc `a' `b' `p1' `q'  
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname cp`x'p1 cLp`x'p1
				scalar `cp`x'p1' = `p`x'est'
				scalar `cLp`x'p1' = `Lp`x'est'
			}
			tempname cp75p25p1 cp90p10p1 cshtop01p1 cshtop05p1 cshtop10p1
			scalar `cp75p25p1' = `p75p25est'
			scalar `cp90p10p1' = `p90p10est'
			scalar `cshtop01p1' = `shtop01est'
			scalar `cshtop05p1' = `shtop05est'
			scalar `cshtop10p1' = `shtop10est'

			quantcalc `a' `b' `p2' `q'  
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname cp`x'p2 cLp`x'p2
				scalar `cp`x'p2' = `p`x'est'
				scalar `cLp`x'p2' = `Lp`x'est'
			}
			tempname cp75p25p2 cp90p10p2 cshtop01p2 cshtop05p2 cshtop10p2
			scalar `cp75p25p2' = `p75p25est'
			scalar `cp90p10p2' = `p90p10est'
			scalar `cshtop01p2' = `shtop01est'
			scalar `cshtop05p2' = `shtop05est'
			scalar `cshtop10p2' = `shtop10est'

				// partial multiplied by parameter since logparameter metric
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname pprimep`x' pprimeLp`x'
				scalar `pprimep`x'' = `p' * (`cp`x'p1' - `cp`x'p2')/(`p'/50)
				scalar `pprimeLp`x'' = `p' * (`cLp`x'p1' - `cLp`x'p2')/(`p'/50)
			}
			tempname pprimep75p25 pprimep90p10 pprimetop01 pprimetop05 pprimetop10 
			scalar `pprimep75p25' = `p' * (`cp75p25p1' - `cp75p25p2')/(`p'/50)
			scalar `pprimep90p10' = `p' * (`cp90p10p1' - `cp90p10p2')/(`p'/50)
			scalar `pprimetop01' = `p' * (`cshtop01p1' - `cshtop01p2')/(`p'/50)
			scalar `pprimetop05' = `p' * (`cshtop05p1' - `cshtop05p2')/(`p'/50)
			scalar `pprimetop10' = `p' * (`cshtop10p1' - `cshtop10p2')/(`p'/50)

			quantcalc `a' `b' `p' `q1'  
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname cp`x'q1 cLp`x'q1
				scalar `cp`x'q1' = `p`x'est'
				scalar `cLp`x'q1' = `Lp`x'est'
			}
			tempname cp75p25q1 cp90p10q1 cshtop01q1 cshtop05q1 cshtop10q1
			scalar `cp75p25q1' = `p75p25est'
			scalar `cp90p10q1' = `p90p10est'
			scalar `cshtop01q1' = `shtop01est'
			scalar `cshtop05q1' = `shtop05est'
			scalar `cshtop10q1' = `shtop10est'

			quantcalc `a' `b' `p' `q2' 
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname cp`x'q2 cLp`x'q2
				scalar `cp`x'q2' = `p`x'est'
				scalar `cLp`x'q2' = `Lp`x'est'
			}
			tempname cp75p25q2 cp90p10q2 cshtop01q2 cshtop05q2 cshtop10q2
			scalar `cp75p25q2' = `p75p25est'
			scalar `cp90p10q2' = `p90p10est'
			scalar `cshtop01q2' = `shtop01est'
			scalar `cshtop05q2' = `shtop05est'
			scalar `cshtop10q2' = `shtop10est'

				// partial multiplied by parameter since logparameter metric
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				tempname qprimep`x' qprimeLp`x'
				scalar `qprimep`x'' = `q' * (`cp`x'q1' - `cp`x'q2')/(`q'/50)
				scalar `qprimeLp`x'' = `q' * (`cLp`x'q1' - `cLp`x'q2')/(`q'/50)
			}
			tempname qprimep75p25 qprimep90p10 qprimetop01 qprimetop05 qprimetop10 
			scalar `qprimep75p25' = `q' * (`cp75p25q1' - `cp75p25q2')/(`q'/50)
			scalar `qprimep90p10' = `q' * (`cp90p10q1' - `cp90p10q2')/(`q'/50)
			scalar `qprimetop01' = `q' * (`cshtop01q1' - `cshtop01q2')/(`q'/50)
			scalar `qprimetop05' = `q' * (`cshtop05q1' - `cshtop05q2')/(`q'/50)
			scalar `qprimetop10' = `q' * (`cshtop10q1' - `cshtop10q2')/(`q'/50)

			tempname prime V var 
			mat V = e(V)

			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				mat `prime' = [`aprimep`x'', `bprimep`x'', `pprimep`x'', `qprimep`x'']
				mat varg = `prime'*V*`prime''
				eret scalar se_cp`x' = sqrt(varg[1,1])
				mat `prime' = [`aprimeLp`x'', `bprimeLp`x'', `pprimeLp`x'', `qprimeLp`x'']
				mat varg = `prime'*V*`prime''
				eret scalar se_cLp`x' = sqrt(varg[1,1])
			}

			mat `prime' = [`aprimep75p25', `bprimep75p25', `pprimep75p25', `qprimep75p25']
			mat varg = `prime'*V*`prime''
			eret scalar se_cp75p25 = sqrt(varg[1,1])

			mat `prime' = [`aprimep90p10', `bprimep90p10', `pprimep90p10', `qprimep90p10']
			mat varg = `prime'*V*`prime''
			eret scalar se_cp90p10 = sqrt(varg[1,1])

			mat `prime' = [`aprimetop01', `bprimetop01', `pprimetop01', `qprimetop01']
			mat varg = `prime'*V*`prime''
			eret scalar se_cshtop01 = sqrt(varg[1,1])

			mat `prime' = [`aprimetop05', `bprimetop05', `pprimetop05', `qprimetop05']
			mat varg = `prime'*V*`prime''
			eret scalar se_cshtop05 = sqrt(varg[1,1])

			mat `prime' = [`aprimetop10', `bprimetop10', `pprimetop10', `qprimetop10']
			mat varg = `prime'*V*`prime''
			eret scalar se_cshtop10 = sqrt(varg[1,1])

		}


		if "`cgini'" != "" {

			capture assert [ln_a]_cons + [ln_q]_cons > 0
			if _rc != 0 {
				noi di " "
				noi di as error "a*q <= 1. 3F2 function is non-convergent. Gini not calculated."
				local jump 1
			}
		}

		if "`cgini'" != "" & "`jump'" == "" {

			noi di " "
			noi di as txt "Calculating Gini using 3F2 functions - be patient"
			noi di as txt "	Convergence tolerance for 3F2 function = " as res `epsilon'

			// estimated Gini 
			* overall Gini
			ginicalc `a' `b' `p' `q' `epsilon'
			eret scalar cgini = `giniest'
			eret scalar num_iter = `num_iter'

			tempname a1 a2 p1 p2 q1 q2
			tempname cginia1 cginia2 cginip1 cginip2 cginiq1 cginiq2
			tempname aprime pprime qprime

			* Ginis used for numerical differentiation
			scalar `a1' = `a' - `a'/100
			scalar `a2' = `a' + `a'/100
			ginicalc `a1' `b' `p' `q'  `epsilon'
			scalar `cginia1' = `giniest'
			ginicalc `a2' `b' `p' `q'  `epsilon'
			scalar `cginia2' = `giniest'
				// partial multiplied by parameter since logparameter metric
			scalar `aprime' = `a' * (`cginia1' - `cginia2')/(`a'/50)

			scalar `p1' = `p' - `p'/100
			scalar `p2' = `p' + `p'/100
			ginicalc `a' `b' `p1' `q'  `epsilon'
			scalar `cginip1' = `giniest'
			ginicalc `a' `b' `p2' `q'  `epsilon'
			scalar `cginip2' = `giniest'
				// partial multiplied by parameter since logparameter metric
			scalar `pprime' = `p' * (`cginip1' - `cginip2')/(`p'/50)

			scalar `q1' = `q' - `q'/100
			scalar `q2' = `q' + `q'/100
			ginicalc `a' `b' `p' `q1'  `epsilon'
			scalar `cginiq1' = `giniest'
			ginicalc `a' `b' `p' `q2'  `epsilon'
			scalar `cginiq2' = `giniest'
				// partial multiplied by parameter since logparameter metric
			scalar `qprime' = `q' * (`cginiq1' - `cginiq2')/(`q'/50)

			tempname gprime V varg 


			mat `gprime' = [`aprime', 0, `pprime', `qprime']
			mat V = e(V)
			mat varg = `gprime'*V*`gprime''
			eret scalar se_cgini = sqrt(varg[1,1])

		}


		if "`igini'" != "" {


			noi di " "
			noi di as txt "Calculating Gini by numerical integration. # integration points = " as res `nips'


			// estimated Gini 	

			tempvar s
			range `s' 0 1 `nips'
			eret scalar nips = `nips'
			global S_s "`s'"

			* overall Gini
			giniint `a' `b' `p' `q'  `nips'
			eret scalar igini = `intgini'

			tempname a1 a2 p1 p2 q1 q2
			tempname iginia1 iginia2 iginip1 iginip2 iginiq1 iginiq2
			tempname aprime pprime qprime

			* Ginis used for numerical differentiation
			scalar `a1' = `a' - `a'/100
			scalar `a2' = `a' + `a'/100
			giniint `a1' `b' `p' `q' `nips'
			scalar `iginia1' = `intgini'
			giniint `a2' `b' `p' `q' `nips' 
			scalar `iginia2' = `intgini'
				// partial multiplied by parameter since logparameter metric
			scalar `aprime' = `a' * (`iginia1' - `iginia2')/(`a'/50)

			scalar `p1' = `p' - `p'/100
			scalar `p2' = `p' + `p'/100
			giniint `a' `b' `p1' `q'  `nips'
			scalar `iginip1' = `intgini'
			giniint `a' `b' `p2' `q'  `nips'
			scalar `iginip2' = `intgini'
				// partial multiplied by parameter since logparameter metric
			scalar `pprime' = `p' * (`iginip1' - `iginip2')/(`p'/50)

			scalar `q1' = `q' - `q'/100
			scalar `q2' = `q' + `q'/100
			giniint `a' `b' `p' `q1'  `nips'
			scalar `iginiq1' = `intgini'
			giniint `a' `b' `p' `q2'  `nips'
			scalar `iginiq2' = `intgini'
				// partial multiplied by parameter since logparameter metric
			scalar `qprime' = `q' * (`iginiq1' - `iginiq2')/(`q'/50)

			tempname gprime V varg 


			mat `gprime' = [`aprime', 0, `pprime', `qprime']
			mat V = e(V)
			mat varg = `gprime'*V*`gprime''
			eret scalar se_igini = sqrt(varg[1,1])
				
					// get rid of global now
			global S_s   

		}


	} // end block executed if no covariates


} // end -quietly block-


	if "`poorfrac'" ~= "" & `poorfrac' > 0 {
		local pfrac "poorfrac(`poorfrac')"
	}


	Display, `level' `pfrac' `diopts'

end




program define Display

	syntax [,Level(int $S_level) POORfrac(real 0)  *]
	local diopts "`options'"
	if `level' < 10 | `level' > 99 {
		local level = 95
	}

	local plus "plus"
	if "`e(svy)'" ~= ""  {
		local plus ""
	}

	if `e(nocov)' == 0 {
		ml display, level(`level') `diopts' 
	}

	if `e(nocov)' == 1 {
		ml display, level(`level') `diopts' `plus'
		_diparm ln_a, level(`level') exp prob label("Parameters a")
		di in smcl in gr "{hline 13}{c +}{hline 64}"
		_diparm ln_b, level(`level') exp prob label("b")
		di in smcl in gr "{hline 13}{c +}{hline 64}"
		_diparm ln_p, level(`level') exp prob label("p")
		di in smcl in gr "{hline 13}{c +}{hline 64}"
		_diparm ln_q, level(`level') exp prob label("q")
		di in smcl in gr "{hline 13}{c BT}{hline 64}"
	}

	if  (`poorfrac' < 0)  {
		di as error "poorfrac value must be positive"
		exit 
	}

	if `poorfrac' > 0 & (`e(nocov)' == 0) {
		di as error "poorfrac option not available (model was specified with covariates)"
		exit
	}

	if `poorfrac' > 0 & (`e(nocov)' == 1) {
		di " "
		di "Fraction with {res: `e(depvar)'} < `poorfrac' = " as res %9.5f ibeta(`e(bp)',`e(bq)', (`poorfrac'/`e(bb)')^`e(ba)'/(1+(`poorfrac'/`e(bb)')^`e(ba)') )
		di " "
	}


	if "`e(mean)'" != ""  {

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
		di as txt  "90%" _col(6) as res %9.5f `e(p90)' _col(20) %9.5f `e(Lp90)'
*		di as txt  "90%" _col(6) as res %9.5f `e(p90)' _col(20) %9.5f `e(Lp90)' _c
*		di as txt  _col(30) "Gini coeff." _col(42) as res %9.5f `e(gini)'
		di as txt  "95%" _col(6) as res %9.5f `e(p95)' _col(20) %9.5f `e(Lp95)' _c
		di as txt  _col(30) "p90/p10" _col(42) as res %9.5f `e(p90)'/`e(p10)'
		di as txt  "99%" _col(6) as res %9.5f `e(p99)' _col(20) %9.5f `e(Lp99)' _c
		di as txt  _col(30) "p75/p25" _col(42) as res %9.5f `e(p75)'/`e(p25)'
		di as txt "{hline 60}"
	} 

	if "`e(cp10)'" != "" {

		di as text "{hline 9}{c TT}{hline 65}"
		di as text "Statistic"_col(10) as text "{c |}   Estimate " _c
		di as text _col(25)  "Std. Err." _col(39) "z"  _c
		di as text _col(46) "P>|z|"  _col(56) "[`level'% Conf. Interval]"
		di as text "{hline 9}{c +}{hline 65}"

		local stats "aXp aXq cmean cvar csd"
		local stats "`stats' cp1 cp5 cp10 cp20 cp25 cp30 cp40 cp50 cp60 cp70 cp75 cp80 cp90 cp95 cp99"
		local stats "`stats' cLp1 cLp5 cLp10 cLp20 cLp25 cLp30 cLp40 cLp50 cLp60 cLp70 cLp75 cLp80 cLp90 cLp95 cLp99"
		local stats "`stats' cshtop01 cshtop05 cshtop10"
		local stats "`stats' cp75p25 cp90p10 GEm1 GE0 GE1 GE2"
		local sname "a*p a*q mean var sd"
		local sname "`sname' p1 p5 p10 p20 p25 p30 p40 p50 p60 p70 p75 p80 p90 p95 p99"
		local sname "`sname' Lp1 Lp5 Lp10 Lp20 Lp25 Lp30 Lp40 Lp50 Lp60 Lp70 Lp75 Lp80 Lp90 Lp95 Lp99"
		local sname "`sname' shTop01pc shTop05pc shTop10pc p75:p25 p90:p10"
		local sname "`sname' GE(-1) GE(0) GE(1) GE(2)"

		if ("`e(cgini)'" != "") & ("`e(igini)'" == "") {
			local stats "`stats' cgini"
			local sname "`sname' cGini"
		}

		if ("`e(cgini)'" == "") & ("`e(igini)'" != "") {
			local stats "`stats' igini"
			local sname "`sname' iGini"
		}

		if ("`e(cgini)'" != "") & ("`e(igini)'" != "") {
			local stats "`stats' cgini igini"
			local sname "`sname' cGini iGini"
		}

		local i = 1
		foreach j of local stats {
			local n: word `i' of `sname'
			di as txt "`n'"  _col(10) "{c |} " as res %10.6f e(`j') _c
			di as res _col(24) %9.6f e(se_`j')  _col(31)  _c
			di %9.3f as result e(`j')/e(se_`j') _col(40) _c
			di %9.3f as result 2*(1-normal(`e(`j')'/`e(se_`j')')) _c
			di _col(56) %9.6g as result `e(`j')'+invnormal((100-`level')/200)*`e(se_`j')' _c
			di _col(67) %9.6g as result `e(`j')'-invnormal((100-`level')/200)*`e(se_`j')' 
			local i = `i' + 1
		}
		di as text "{hline 9}{c BT}{hline 65}"
	}

	if "`e(cp10)'" == "" & "`e(cgini)'" != "" & "`e(igini)'" == "" {

		di as text "{hline 9}{c TT}{hline 65}"
		di as text "Statistic"_col(10) as text "{c |}   Estimate " _c
		di as text _col(25)  "Std. Err." _col(39) "z"  _c
		di as text _col(46) "P>|z|"  _col(56) "[`level'% Conf. Interval]"
		di as text "{hline 9}{c +}{hline 65}"
		di as text " cGini" _col(10) "{c |} "  as result %10.7f e(cgini) _c
		di as result _col(24) e(se_cgini) _col(31)  _c
		di %9.3f as result e(cgini)/e(se_cgini) _col(40) _c
		di %9.3f as result 2*(1-normal(`e(cgini)'/`e(se_cgini)')) _c
		di _col(56) %9.0g as result e(cgini)+invnormal((100-`level')/200)*e(se_cgini) _c
		di _col(67) %9.0g as result e(cgini)-invnormal((100-`level')/200)*e(se_cgini) 
		di as text "{hline 9}{c BT}{hline 65}"
	}

	if "`e(cp10)'" == "" & "`e(cgini)'" == "" & "`e(igini)'" != "" {

		di as text "{hline 9}{c TT}{hline 65}"
		di as text "Statistic"_col(10) as text "{c |}   Estimate " _c
		di as text _col(25)  "Std. Err." _col(39) "z"  _c
		di as text _col(46) "P>|z|"  _col(56) "[`level'% Conf. Interval]"
		di as text "{hline 9}{c +}{hline 65}"
		di as text " iGini" _col(10) "{c |} "  as result %10.7f e(igini) _c
		di as result _col(24) e(se_igini) _col(31)  _c
		di %9.3f as result e(igini)/e(se_igini) _col(40) _c
		di %9.3f as result 2*(1-normal(`e(igini)'/`e(se_igini)')) _c
		di _col(56) %9.0g as result e(igini)+invnormal((100-`level')/200)*e(se_igini) _c
		di _col(67) %9.0g as result e(igini)-invnormal((100-`level')/200)*e(se_igini) 
		di as text "{hline 9}{c BT}{hline 65}"
	}

	if "`e(cp10)'" == "" & "`e(cgini)'" != "" & "`e(igini)'" != "" {

		di as text "{hline 9}{c TT}{hline 65}"
		di as text "Statistic"_col(10) as text "{c |}   Estimate " _c
		di as text _col(25)  "Std. Err." _col(39) "z"  _c
		di as text _col(46) "P>|z|"  _col(56) "[`level'% Conf. Interval]"
		di as text "{hline 9}{c +}{hline 65}"
		di as text " cGini" _col(10) "{c |} "  as result %10.7f e(cgini) _c
		di as result _col(24) e(se_cgini) _col(31)  _c
		di %9.3f as result e(cgini)/e(se_cgini) _col(40) _c
		di %9.3f as result 2*(1-normal(`e(cgini)'/`e(se_cgini)')) _c
		di _col(56) %9.0g as result e(cgini)+invnormal((100-`level')/200)*e(se_cgini) _c
		di _col(67) %9.0g as result e(cgini)-invnormal((100-`level')/200)*e(se_cgini) 
		di as text " iGini" _col(10) "{c |} "  as result %10.7f e(igini) _c
		di as result _col(24) e(se_igini) _col(31)  _c
		di %9.3f as result e(igini)/e(se_igini) _col(40) _c
		di %9.3f as result 2*(1-normal(`e(igini)'/`e(se_igini)')) _c
		di _col(56) %9.0g as result e(igini)+invnormal((100-`level')/200)*e(se_igini) _c
		di _col(67) %9.0g as result e(igini)-invnormal((100-`level')/200)*e(se_igini) 
		di as text "{hline 9}{c BT}{hline 65}"
	}


end

program define ginicalc

	args ca cb cp cq eps

	// estimated Gini a la McDonald (Econometrica 1984) formula
	//   	= B * [ (1/p)* 3F2A - (1/(p + 1/a))* 3F2B]

	tempname B f3F2A f3F2B sumA sumB sumAlast sumBlast ginicalc

	scalar `B' = exp( lngamma(2*`cq' - (1/`ca')) + lngamma(2*`cp' + (1/`ca'))  ///
			- lngamma(2*`cp' + 2*`cq') + 2*lngamma(`cp' + `cq')	///
			- lngamma(`cp') - lngamma(`cq') 			///
			- lngamma(`cp' + (1/`ca')) - lngamma(`cq' - (1/`ca'))	///
			)

	scalar `sumA' = 0
	scalar `sumB' = 0
	scalar `sumAlast' = .
	scalar `sumBlast' = .

		// 3F2 functions are infinite series; 
		//    calculate to pre-specified # decimal places
	local i = 1
	while ( abs(`sumA' - `sumAlast' ) > `eps' ) | ( abs(`sumB' - `sumBlast' ) > `eps' ) {

		scalar `sumAlast' = `sumA'
		scalar `sumA' = `sumA' + 				///
				exp( lngamma(1 + `i') 			///
				+ lngamma(`cp' + `cq' + `i')  		///
				+ lngamma(2*`cp' + (1/`ca') + `i') 	///
				- lngamma(`cp' + 1 + `i')		///
				- lngamma(2*`cp' + 2*`cq' + `i')	///
				- lnfact(`i')				///
				)
		scalar `sumBlast' = `sumB'
		scalar `sumB' = `sumB' + 				///
				exp( lngamma(1 + `i') 			///
				+ lngamma(`cp' + `cq' + `i')  		///
				+ lngamma(2*`cp' + (1/`ca') + `i') 	///
				- lngamma(`cp' + (1/`ca') + 1 + `i')	///
				- lngamma(2*`cp' + 2*`cq' + `i')	///
				- lnfact(`i')				///
				)

		local i = `i' + 1
	}

	c_local num_iter = `i'

	scalar `f3F2A' = 1 +  exp( lngamma(`cp' + 1) + lngamma(2*`cp' + 2*`cq') ///
				- lngamma(`cp' + `cq') - lngamma(2*`cp' + (1/`ca')) ///
				) * `sumA'

	scalar `f3F2B' = 1 +  exp( lngamma(`cp' + (1/`ca') + 1) + lngamma(2*`cp' + 2*`cq') ///
				- lngamma(`cp' + `cq') - lngamma(2*`cp' + (1/`ca')) ///
				) * `sumB'

	scalar `ginicalc' = `B' * ( `f3F2A'/`cp' - `f3F2B'/(`cp' + (1/`ca')) )

	c_local giniest = `ginicalc'

end


program define quantcalc
	args ca cb cp cq 

	local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
	foreach x of local ptile {
		tempname ib p`x' Lp`x'
		scalar `ib' = invibeta(`cp',`cq',`x'/100)
		scalar `p`x'' =  `cb'* (`ib'/(1-`ib'))^(1/`ca') 
		scalar `Lp`x'' = ibeta(`cp'+1/`ca',`cq'-1/`ca',(`p`x''/`cb')^`ca'/(1+(`p`x''/`cb')^`ca') )
		
		c_local p`x'est = `p`x''
		c_local Lp`x'est = `Lp`x''

	}

	tempname p90p10 p75p25 shtop01 shtop05 shtop10

	scalar `p90p10' = `p90'/`p10'
	scalar `p75p25' = `p75'/`p25'
	scalar `shtop01' = 1 - `Lp99'
	scalar `shtop05' = 1 - `Lp95'
	scalar `shtop10' = 1 - `Lp90'
	c_local p90p10est = `p90p10'
	c_local p75p25est = `p75p25'
	c_local shtop01est = `shtop01'
	c_local shtop05est = `shtop05'
	c_local shtop10est = `shtop10'

end




program define giniint

	args ca cb cp cq cnips

	// estimated Gini using Stata -intreg-  Gini = int(0,1)  { 2*(s-L(s) } ds
	//	Calculate over range of p = F(y), i.e. [0,1]
	// # integration points in interval is set by NIPS options

	tempvar z L y
	ge double `z' =  `cb'* ( invibeta(`cp',`cq',$S_s) / ( 1 - invibeta(`cp',`cq', $S_s) ))^(1/`ca')
	ge double `L' = ibeta(`cp'+1/`ca',`cq'-1/`ca',(`z'/`cb')^`ca'/(1+ (`z'/`cb')^`ca') )
	replace `L' = 0 in 1
	replace `L' = 1 in `cnips'

	ge double `y' = 2*($S_s - `L')
	integ `y' $S_s

	c_local intgini = r(integral)

end


