*! version 1.2.0    Stephen P. Jenkins April 2004
*! predict program to accompany -dagumfit- for predictions when covariates


program define dagumpred, eclass
	version 8.2

	if "`e(cmd)'" != "dagumfit" { 
		di in red  "dagumfit was not the last estimation command"
		exit 301
	}

	syntax [if] [in] [, Aval(string) Bval(string) Pval(string) ///
		  ABPval(string) CDF(namelist max=1) PDF(namelist max=1) ///
		   POORfrac(real 0) ]

        if "`abpval'" ~= "" & (("`aval'"~="")|("`bval'"~="")|("`pval'"~="")) {
                di as error "Cannot use abpqval(.) option in conjunction with aval(.), bval(.), pval(.) options"
                exit 198
        }

        if "`abpval'" ~= "" {
                local aval "`abpval'"
                local bval "`abpval'"
                local pval "`abpval'"
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
		if _rc ==0 {
			di as error "poorfrac value must be positive"
			exit 198
		}
	}

	if `e(nocov)' ~= 1 & ("`aval'" == ""|"`bval'" == ""|"`pval'" == "") {
		di as error "Model used covariates: specify covariate values"
		exit
	}

	if `e(nocov)' == 1 {
		local a = `e(ba)'
		local b = `e(bb)'
		local p = `e(bp)'
	}
	else {

		tempname maval mbval mpval
		mat `maval' = (`aval')
		mat `mbval' = (`bval')
		mat `mpval' = (`pval')

		if colsof(`maval') ~= `e(length_b_a)' {
			di as error "# aval() elements ~= # covariates in a: eqn"
			exit
		}
		if colsof(`mbval') ~= `e(length_b_b)' {
			di as error "# bval() elements ~= # covariates in b: eqn"
			exit
		}
		if colsof(`mpval') ~= `e(length_b_p)' {
			di as error "# pval() elements ~= # covariates in p: eqn"
			exit
		}

		tempname ba bb bp

		mat `ba' = e(b_a)'
		mat `bb' = e(b_b)'
		mat `bp' = e(b_p)'

		mat `ba' = `maval'*`ba'
		mat `bb' = `mbval'*`bb'
		mat `bp' = `mpval'*`bp'

		local a = `ba'[1,1]
		local b = `bb'[1,1]
		local p = `bp'[1,1]
	}

	eret scalar bba = `a'
	eret scalar bbb = `b'
	eret scalar bbp = `p'

	eret scalar mean = `p'*`b'*exp(lngamma(1-1/`a'))     ///
	      	*exp(lngamma(`p'+1/`a'))/exp(lngamma(`p'+1)) 
	eret scalar mode = cond(`a'*`p'>1,`b'*(((`a'*`p'-1)/(`a'+1))^(1/`a')),0,.)
	eret scalar var = `p'*`b'*`b'*exp(lngamma(1-2/`a')) ///
   		*exp(lngamma(`p'+2/`a'))/exp(lngamma(`p'+1)) ///
	 	- (`e(mean)'*`e(mean)')
	eret scalar sd = sqrt(`e(var)')
	eret scalar i2 = .5*`e(var)'/(`e(mean)'*`e(mean)')
	eret scalar gini = -1 + (exp(lngamma(`p'))*exp(lngamma(2*`p'+1/`a'))  ///
 	  	 / (exp(lngamma(`p'+1/`a'))*exp(lngamma(2*`p'))))


	/* selected quantiles predicted from Dagum model */
	/* Lorenz curve ordinates at selected quantiles */
			
	local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
	foreach x of local ptile {	
		eret scalar p`x' = `b' * ( (`x'/100)^(-1/`p') - 1 )^(-1/`a') 
		eret scalar Lp`x' = ibeta(`p'+1/`a',1- 1/`a',(`x'/100)^(1/`p'))
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
		eret scalar poorfrac = (1 + (`b'/`poorfrac')^`a')^(-`p')	
		eret scalar pline = `poorfrac'
	}
	if "`e(poorfrac)'" ~= ""  {
		di " "
		di "Fraction with `e(depvar)' < `e(pline)' = " as res %9.5f e(poorfrac)
		di " "
	}

	marksample touse 
	markout `touse' 

		/* Estimated Dagum c.d.f. */

	if "`cdf'" ~= "" {
	 	qui ge `cdf' = (1 + (`b'/`e(depvar)')^`a')^(-`p')  if `touse'
	 	eret local cdfvar "`cdf'"
	}


		/* Estimated Dagum p.d.f. */

	if "`pdf'" ~= "" {
	 	qui ge `pdf' = (`a'*`p'*(`b')^`a')* `e(depvar)'^-(`a'+1)  ///
			 * ( (1 + (`b'/`e(depvar)')^`a')^-(`p'+1) ) ///
			 if `touse'
	 	eret local pdfvar "`pdf'"
	}

end

