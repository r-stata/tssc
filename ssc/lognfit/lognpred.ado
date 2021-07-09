*! version 1.2.1    Stephen P. Jenkins 1 June 2013 (fix bug in calculation of L(x))
*! version 1.2.0    Stephen P. Jenkins April 2004 
*! predict program to accompany -lognfit- for predictions when covariates


program define lognpred, eclass
	version 8.2

	if "`e(cmd)'" != "lognfit" { 
		di in red  "lognfit was not the last estimation command"
		exit 301
	}

	syntax [if] [in] [, Mval(string) Vval(string) ///
		  MANDVval(string) CDF(namelist max=1) PDF(namelist max=1) ///
		   POORfrac(real 0) ]

        if "`mandvval'" ~= "" & (("`mval'"~="")|("`vval'"~="")) {
                di as error "Cannot use mandvval(.) option in conjunction with mval(.), vval(.) options"
                exit 198
        }

        if "`mandvval'" ~= "" {
                local mval "`mandvval'"
                local vval "`mandvval'"
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
			exit
		}
	}

	if `e(nocov)' ~= 1 & ("`mval'" == ""|"`vval'" == "") {
		di as error "Model used covariates: specify covariate values"
		exit
	}


	if `e(nocov)' == 1 {
		local m = `e(bm)'
		local v = `e(bv)'
	}
	else {
		tempname mmval mvval 
		mat `mmval' = (`mval')
		mat `mvval' = (`vval')

		if colsof(`mmval') ~= `e(length_b_m)' {
			di as error "# mval() elements ~= # covariates in m: eqn"
			exit
		}
		if colsof(`mvval') ~= `e(length_b_v)' {
			di as error "# vval() elements ~= # covariates in v: eqn"
			exit
		}

		tempname bm bv 

		mat `bm' = e(b_m)'
		mat `bv' = e(b_v)'

		mat `bm' = `mmval'*`bm'
		mat `bv' = `mvval'*`bv'

		local m = `bm'[1,1]
		local v = `bv'[1,1]

	}

	eret scalar bbm = `m'
	eret scalar bbv = `v'

	eret scalar mean = exp( `m' + .5*(`v')^2 )
	eret scalar mode = exp( `m' - (`v')^2 )
	local omega = exp(`v'^2)
	eret scalar var = exp(2*`m')*`omega'*(`omega'-1)
	eret scalar sd = sqrt(`e(var)')
	eret scalar i2 = .5*`e(var)'/(`e(mean)'*`e(mean)')
	eret scalar gini = 2*norm(`v'/sqrt(2)) - 1


	local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"

	/* selected quantiles predicted from lognormal model */
	/* Lorenz curve ordinates at selected quantiles */

	foreach x of local ptile {	
		eret scalar p`x' = exp(`m' + `v'*invnorm(`x'/100) )
		eret scalar Lp`x' = norm(  invnorm(`x'/100) - `v'  ) 
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
		eret scalar poorfrac = norm( (ln(`poorfrac') - `m')/`v' )	
		eret scalar pline = `poorfrac'
	}

	if "`e(poorfrac)'" ~= ""  {
		di " "
		di "Fraction with `e(depvar)' < `e(pline)' = " as res %9.5f e(poorfrac)
		di " "
	}

	marksample touse 
	markout `touse' 

		/* Estimated lognormal c.d.f. */

	if "`cdf'" ~= "" {		 	
		qui ge `cdf' = norm( (ln(`e(depvar)') - `m')/`v' ) if `touse'
	 	eret local cdfvar "`cdf'"
	}


		/* Estimated lognormal p.d.f. */

	if "`pdf'" ~= "" {
	 	qui ge `pdf' = ((`e(depvar)'*sqrt(2*_pi)*`v')^(-1)) *  ///
 				exp(-.5*((`v')^(-2))*((ln(`e(depvar)')-`m')^2)  ///
				if `touse'
		eret local pdfvar "`pdf'"
	}


end

