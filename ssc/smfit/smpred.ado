*! version 1.2.0    Stephen P. Jenkins April 2004 
*! predict program to accompany -smfit- for predictions when covariates


program define smpred, eclass
	version 8.2

	if "`e(cmd)'" != "smfit" { 
		di in red  "smfit was not the last estimation command"
		exit 301
	}

	syntax  [if] [in]  [, Aval(string) Bval(string) Qval(string) ///
		  ABQval(string) CDF(namelist max=1) PDF(namelist max=1) ///
		   POORfrac(real 0) ]

        if "`abqval'" ~= "" & (("`aval'"~="")|("`bval'"~="")|("`qval'"~="")) {
                di as error "Cannot use abqval(.) option in conjunction with aval(.), bval(.), qval(.) options"
                exit 198
        }

        if "`abqval'" ~= "" {
                local aval "`abqval'"
                local bval "`abqval'"
                local qval "`abqval'"
        }

	if ("`if'" ~= "" | "`in'" ~= "") & ("`cdf'" == "") & ("`pdf'" == "") {
		di as txt "Warning: if and in have effect only if cdf or pdf options specified"
	}

	if "`cdf'" ~= "" {
		confirm new variable `cdf' 
	}
	if "`pdf'" ~= "" {
		confirm new variable `pdf' 
	}

	if "`poorfrac'" ~= "" {
		capture assert `poorfrac' < 0
		if _rc == 0 {
			di as error "poorfrac value must be positive"
			exit 198
		}
	}

	if `e(nocov)' ~= 1 & ("`aval'" == ""|"`bval'" == ""|"`qval'" == "") {
		di as error "Model used covariates: specify covariate values"
		exit
	}


	if `e(nocov)' == 1 {
		local a = `e(ba)'
		local b = `e(bb)'
		local q = `e(bq)'
	}
	else {

		tempname maval mbval mqval
		mat `maval' = (`aval')
		mat `mbval' = (`bval')
		mat `mqval' = (`qval')

		if colsof(`maval') ~= `e(length_b_a)' {
			di as error "# aval() elements ~= # covariates in a: eqn"
			exit
		}
		if colsof(`mbval') ~= `e(length_b_b)' {
			di as error "# bval() elements ~= # covariates in b: eqn"
			exit
		}
		if colsof(`mqval') ~= `e(length_b_q)' {
			di as error "# qval() elements ~= # covariates in q: eqn"
			exit
		}

		tempname ba bb bq 
		mat `ba' = e(b_a)'
		mat `bb' = e(b_b)'
		mat `bq' = e(b_q)'

		mat `ba' = `maval'*`ba'
		mat `bb' = `mbval'*`bb'
		mat `bq' = `mqval'*`bq'

		local a = `ba'[1,1]
		local b = `bb'[1,1]
		local q = `bq'[1,1]

	}

	eret scalar bba = `a'
	eret scalar bbb = `b'
	eret scalar bbq = `q'


	eret scalar mean = `b'*exp(lngamma(1+1/`a'))     ///
		       	   *exp(lngamma(`q'-1/`a'))/exp(lngamma(`q')) 
	eret scalar mode = cond(`a'>1,`b'*(((`a'-1)/(`a'*`q'+1))^(1/`a')),0,.)
	eret scalar var = `b'*`b'*exp(lngamma(1+2/`a')) ///
			*exp(lngamma(`q'-2/`a'))/exp(lngamma(`q')) ///
		 	- (`e(mean)'*`e(mean)')
	eret scalar sd = sqrt(`e(var)')
	eret scalar i2 = .5*`e(var)'/(`e(mean)'*`e(mean)')
	eret scalar gini = 1-(exp(lngamma(`q'))*exp(lngamma(2*`q'-1/`a'))  ///
	        	    / (exp(lngamma(`q'-1/`a'))*exp(lngamma(2*`q'))))

	local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"

	/* selected quantiles predicted from S-M model */
	/* Lorenz curve ordinates at selected quantiles */

	foreach x of local ptile {	
		eret scalar p`x' = `b' * ( (1-`x'/100)^(-1/`q') - 1 )^(1/`a') 
		eret scalar Lp`x' = ibeta(1+1/`a',`q' -1/`a',1-(1-`x'/100)^(1/`q'))
	}
	di as txt "{hline 60}"
	di as txt _col(6) "Quantiles" _col(22) "Cumulative shares of" 
	di as txt _col(22) "total `e(depvar)' (Lorenz ordinates)"
	di as txt "{hline 60}"
	di as txt " 1%" _col(6) as res %9.5f `e(p1)' _col(20) %9.5f `e(Lp1)'
	di as txt " 5%" _col(6) as res %9.5f `e(p5)' _col(20) %9.5f `e(Lp5)'
	di as txt "10%" _col(6) as res %9.5f `e(p10)' _col(20) %9.5f `e(Lp10)'
	di as txt "20%" _col(6) as res %9.5f `e(p20)' _col(20) %9.5f `e(Lp20)'
	di as txt "25%" _col(6) as res %9.5f `e(p25)' _col(20) %9.5f `e(Lp25)'
	di as txt "30%" _col(6) as res %9.5f `e(p30)' _col(20) %9.5f `e(Lp30)'
	di as txt "40%" _col(6) as res %9.5f `e(p40)' _col(20) %9.5f `e(Lp40)' _c
	di as txt  _col(30) "Mode" _col(42) as res %9.5f `e(mode)'
	di as txt "50%" _col(6) as res %9.5f `e(p50)' _col(20) %9.5f `e(Lp50)' _c
	di as txt _col(30) "Mean" _col(42) as res %9.5f `e(mean)'
	di as txt "60%" _col(6) as res %9.5f `e(p60)' _col(20) %9.5f `e(Lp60)' _c
	di as txt _col(30) "Std. Dev." _col(42) as res %9.5f `e(sd)'
	di as txt "70%" _col(6) as res %9.5f `e(p70)' _col(20) %9.5f `e(Lp70)'
	di as txt "75%" _col(6) as res %9.5f `e(p75)' _col(20) %9.5f `e(Lp75)' _c
	di as txt _col(30) "Variance" _col(42) as res %9.5f `e(var)'
	di as txt "80%" _col(6) as res %9.5f `e(p80)' _col(20) %9.5f `e(Lp80)' _c
	di as txt _col(30) "Half CV^2" _col(42) as res %9.5f `e(i2)'
	di as txt "90%" _col(6) as res %9.5f `e(p90)' _col(20) %9.5f `e(Lp90)' _c
	di as txt _col(30) "Gini coeff." _col(42) as res %9.5f `e(gini)'
	di as txt "95%" _col(6) as res %9.5f `e(p95)' _col(20) %9.5f `e(Lp95)' _c
	di as txt _col(30) "p90/p10" _col(42) as res %9.5f `e(p90)'/`e(p10)'
	di as txt "99%" _col(6) as res %9.5f `e(p99)' _col(20) %9.5f `e(Lp99)' _c
	di as txt _col(30) "p75/p25" _col(42) as res %9.5f `e(p75)'/`e(p25)'
	di as txt "{hline 60}"

	/* Fraction with income below given level */
	if "`poorfrac'" ~= "" & `poorfrac' > 0 {
		eret scalar poorfrac = 1 - ( 1/(1 + (`poorfrac'/`b')^`a')^`q' )	
		eret scalar pline = `poorfrac'
	}
	if "`e(poorfrac)'" ~= ""  {
		di " "
		di "Fraction with `e(depvar)' < `e(pline)' = " as res %9.5f e(poorfrac)
		di " "
	}


	marksample touse 
	markout `touse' 


		/* Estimated S-M c.d.f. */
	if "`cdf'" ~= "" {
	 	qui ge `cdf' = 1 - ( 1/(1 + (`e(depvar)'/`b')^`a')^`q' ) if `touse'
	 	eret local cdfvar "`cdf'"
	}


		/* Estimated S-M p.d.f. */
	if "`pdf'" ~= "" {
	 	qui ge `pdf' = (`a'*`q'/`b')*  ///
			 ((1 + (`e(depvar)'/`b')^`a')^-(`q'+1))  ///
			 * ((`e(depvar)'/`b')^(`a'-1)) if `touse'
	 	eret local pdfvar "`pdf'"
	}



end

