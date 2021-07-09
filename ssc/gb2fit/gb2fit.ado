*! version 1.2.2 Stephen P. Jenkins, July 2012
*!   fix typo in post-estimation prediction of variance 
*!      (Thanks to Michal Brzezinski for spotting the typo)
*! version 1.2.1 Stephen P. Jenkins, March 2007
*! Fit GB2 distribution by ML to unit record data


/*------------------------------------------------ playback request */
 
program define gb2fit, eclass byable(onecall)
	version 8.2
	if replay() {
		if "`e(cmd)'" != "gb2fit" {
			noi di as error "results for gb2fit not found"
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
		ABPQ(varlist numeric) CDF(namelist max=1) PDF(namelist max=1) POORfrac(real 0) ///
		Robust Cluster(varname) SVY  STats From(string) ///
		Level(integer $S_level)    ///
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
	markout `touse' `varlist' `avar' `bvar' `pvar' `qvar' `cluster'
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
		noi di as txt "Warning: {res:`inc'} has `ct' values < 0;" _c
		noi di as text " not used in calculations"
		}

	  count if `inc' == 0 & `touse'
	  local ct =  r(N) 
	  if `ct' > 0 {
		noi di " "
		noi di as txt "Warning: {res:`inc'} has `ct' values = 0;" _c
		noi di as text " not used in calculations"
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

	`log' ml model lf gb2fit_ll (a: `avar') (b: `bvar') (p: `pvar') (q: `qvar') 	///
		`wgt' if `touse' , maximize 						///
		collinear title(`title') `robust' `svy' init(`b0') 		///
		search(on) `clopt' `level' `mlopts' `stdopts' `modopts'


	eret local cmd "gb2fit"
	eret local depvar "`inc'"

	tempname b ba bb bp bq
	mat `b' = e(b)
	mat `ba' = `b'[1,"a:"] 
	mat `bb' = `b'[1,"b:"]
	mat `bp' = `b'[1,"p:"]
	mat `bq' = `b'[1,"q:"]

	eret matrix b_a = `ba'
	eret matrix b_b = `bb'
	eret matrix b_p = `bp'
	eret matrix b_q = `bq'
	eret scalar length_b_a = 1 + `na'
	eret scalar length_b_b = 1 + `nb'
	eret scalar length_b_p = 1 + `np'
	eret scalar length_b_q = 1 + `nq'

	if ("`avar'"!="" | "`bvar'"!="" | "`pvar'"!=""  | "`qvar'"!="") {
		eret scalar nocov = 0
	}

	
	if "`avar'"=="" & "`bvar'"=="" & "`pvar'"=="" & "`qvar'"=="" {

		tempname e		

		mat `e' = e(b)
		local a = `e'[1,1]
		local b = `e'[1,2]
		local p = `e'[1,3]
		local q = `e'[1,4]

		eret scalar ba = `a'
		eret scalar bb = `b'
		eret scalar bp = `p'
		eret scalar bq = `q'

		eret scalar nocov = 1
	
			/* Estimated GB2 c.d.f. */

		if "`cdf'" ~= "" {		 	
			qui ge `cdf' = ibeta(`p',`q', (`inc'/`b')^`a'/(1+(`inc'/`b')^`a') ) if `touse'
		 	eret local cdfvar "`cdf'"
		}


			/* Estimated GB2 p.d.f. */
	
		if "`pdf'" ~= "" {
		 	qui ge `pdf' = (`a'*(`inc')^(`a'*`p'-1))*exp(lngamma(`p'+`q')) / (		  ///
	 				 (`b'^(`a'*`p'))*exp(lngamma(`p'))*exp(lngamma(`q'))  ///
					  *( (1 +(`inc'/`b')^`a')^(`p'+`q') ) ///
					) if `touse'
			eret local pdfvar "`pdf'"
		}

			/* selected quantiles predicted from GB2 model */
			/* Lorenz curve ordinates at selected quantiles */

		if "`stats'" ~= "" {
			eret scalar mean = `b'*exp(lngamma(`p'+1/`a'))     	///
				       	   *exp(lngamma(`q'-1/`a')) 		/// 
					   /( exp(lngamma(`p'))*exp(lngamma(`q')) ) 
			eret scalar mode = cond(`a'*`p'>1,`b'*(((`a'*`p'-1)/(`a'*`q'+1))^(1/`a')),0,.)
			eret scalar var = `b'*`b'*exp(lngamma(`p'+2/`a')) 		///
					   *exp(lngamma(`q'-2/`a'))		   	///
					   /( exp(lngamma(`p'))*exp(lngamma(`q')) ) 	///
				 	- (`e(mean)'*`e(mean)')
			eret scalar sd = sqrt(`e(var)')
			eret scalar i2 = .5*`e(var)'/(`e(mean)'*`e(mean)')
			eret scalar gini = .
			// Gini coeff is function of generalized hypergeometric function!!!
			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {	
				local ib = invibeta(`p',`q',`x'/100)
				eret scalar p`x' =  `b'* (`ib'/(1-`ib'))^(1/`a') 
				eret scalar Lp`x' = ibeta(`p'+1/`a',`q'-1/`a',(`e(p`x')'/`b')^`a'/(1+(`e(p`x')'/`b')^`a') )
			}
		}

			/* Fraction with income below given level */
	
		if "`poorfrac'" ~= "" & `poorfrac' > 0 {
			eret scalar poorfrac = ibeta(`p',`q', (`poorfrac'/`b')^`a'/(1+(`poorfrac'/`b')^`a') )
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

	if `poorfrac' > 0 & (`e(nocov)' == 1) {
		di " "
		di "Fraction with {res: `e(depvar)'} < `poorfrac' = " as res %9.5f ibeta(`e(bp)',`e(bq)', (`poorfrac'/`e(bb)')^`e(ba)'/(1+(`poorfrac'/`e(bb)')^`e(ba)') )
		di " "
	}


	if "`e(mean)'" ~= ""  {

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

end



