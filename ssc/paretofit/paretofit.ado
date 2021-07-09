*! paretofit.ado, 1.1.0, Stephen P. Jenkins, 2015-10-15
*! paretofit.ado, 1.0.0, Stephen P. Jenkins & Philippe Van Kerm, 2007-04-06

*----------------------------------------------------------------------
*                                       Revision history :
* 1.1.0: added more output from stats option; fixed bug in variance calculation
*----------------------------------------------------------------------
*----------------------------------------------------------------------
*                                       Description :
*
* Fit Pareto distribution by ML to unit record data.
* Code largely borrowed from -smfit- (for fitting Singh-Maddala distributions).
* See similar commands -dagumfit-, -gb2fit-, -lognfit-.  
*
*----------------------------------------------------------------------


/*------------------------------------------------ playback request */
 
program define paretofit, eclass byable(onecall) properties(ml_score svyr)
	version 9.2
	if replay() {
		if "`e(cmd)'" != "paretofit" {
			noi di as error "results for {cmd:paretofit} not found"
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
	else {
		Estimate `0'
	}
end

/*------------------------------------------------ estimation */

program define Estimate, eclass byable(recall) sortpreserve

	syntax varlist(max=1) [if] [in] [aw fw pw iw] [,  ///
		Avar(varlist numeric) ///
		X0(string) ME(string) ///
		CDF(namelist max=1) PDF(namelist max=1) ///
		POORfrac(real 0) STats ///
		Robust Cluster(varname) From(real 0)  ///
		Level(cilevel)    ///
		noLOG * ]

	local title "ML fit of Pareto distribution"

	local inc "`varlist'"

	local na : word count `avar'

	if ("`avar'"~="") {
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

	if (`from'<0) {
		di as error "from() starting value must be positive" 
		exit 198
	}
	
	local option0 `options'

	local wtype `weight'
	local wtexp `"`exp'"'
	if "`weight'" != "" { 
		local wgt `"[`weight'`exp']"'  
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
	markout `touse' `varlist' `avar' 
	markout `touse' `cluster' , strok
	mlopts mlopts, `options'

	if ! `:length local x0'  {
		qui su `inc' if `touse', meanonly
		loc x0 = r(min)
	}
	
	if  (`x0' < 0)  {
		di as error "x0 must be positive"
		exit 198
	}
	if  (`poorfrac' != 0) & (`poorfrac' < `x0')  {
		di as error "poorfrac value must be higher than x0 (here `x0')"
		exit 198
	}

	if ! `:length local me'  {
		loc t = `x0'
	}
	else local t = `me'
	if  `t' < `x0'   {
		di as error "ME threshold cannot be less than x0 (here `x0')"
		exit 198
	}

	
	qui replace `touse' = 0 if `inc' < `x0'

	qui count if `touse' 
	if (r(N) == 0) 	error 2000 
	else			loc nobs = r(N)

	if (`from' == 0) 	local init ""
	else 				local init "init(`from' , copy)"
	
		
	global S_mlinc "`inc'"
	global S_x0 "`x0'"

	`log' ml model lf paretofit_ll (a: `avar')  	///
		`wgt' if `touse' , maximize					///
		collinear title(`title') `robust' 	///
		search(on) `clopt' `level' `mlopts' `stdopts' `modopts' `init'

	eret local cmd "paretofit"
	eret local depvar "`inc'"
	eret scalar x0 = `x0'
	eret scalar t = `t'

	if ("`avar'"!="") 	eret scalar nocov = 0
	else {
		tempname e
		mat `e' = e(b)
		local a = `e'[1,1]
		eret scalar ba = `a'
		eret scalar nocov = 1
		
		/* Estimated Pareto c.d.f. */
		if "`cdf'" ~= "" {
			qui ge `cdf' = 1 - (`inc'/`x0')^(-`a') if `touse'
		 	eret local cdfvar "`cdf'"
		}
		/* Estimated Pareto p.d.f. */
		if "`pdf'" ~= "" {
		 	qui ge `pdf' = `a' * (`inc')^(-(`a'+1)) * (`x0')^(`a') if `touse'
			eret local pdfvar "`pdf'"
		}
		/* Summary statistics and Lorenz ordinates */
		if "`stats'" ~= "" {
			eret scalar mode = `x0'
			
			quietly nlcom 	(alpha: (_b[a:_cons]) ) 			///
			(beta: ( _b[a:_cons]/(_b[a:_cons] - 1) ) ) 			///
			(gini: ( 1/ (2*_b[a:_cons] - 1 ) )  )				///
			(mld: ( log(_b[a:_cons]/(_b[a:_cons] - 1)) - (1/_b[a:_cons])  ) )	///
			(theil: (  (1/(_b[a:_cons] - 1)) - log(_b[a:_cons]/(_b[a:_cons] - 1)) ) ) ///
			(mean:  ( `x0'*_b[a:_cons]/(_b[a:_cons] - 1)  ) )			///
			(me: ( `t'/(_b[a:_cons] - 1)  ) ), noheader  	
			
			tempname b V
			mat `b' = r(b)
			mat `V' = r(V)	
			ereturn scalar alpha = `b'[1,1]
			ereturn scalar se_alpha = sqrt( `V'[1,1] )
			ereturn scalar beta = `b'[1,2]
			ereturn scalar se_beta = sqrt( `V'[2,2] )
			ereturn scalar gini = `b'[1,3]
			ereturn scalar se_gini = sqrt( `V'[3,3] )
			ereturn scalar ge0 = `b'[1,4]
			ereturn scalar se_ge0 = sqrt( `V'[4,4] )
			ereturn scalar ge1 = `b'[1,5]
			ereturn scalar se_ge1 = sqrt( `V'[5,5] )
			ereturn scalar mean = `b'[1,6]
			ereturn scalar se_mean = sqrt( `V'[6,6] )
			ereturn scalar me = `b'[1,7]
			ereturn scalar se_me = sqrt( `V'[7,7] )
				// SPJ changed `a' >=2 to `a' > 2 (see K & K)
			if (`a' > 2) {

				quietly nlcom 	(ge2: ( 1/ ( 2*_b[a:_cons]*(_b[a:_cons]-2) )) ) 	 ///
				 (var: ( (`x0'^2)*_b[a:_cons]/( (_b[a:_cons]-2)*(_b[a:_cons]-1)^2) )  )   ///
				 (sd: (  sqrt((`x0'^2)*_b[a:_cons]/( (_b[a:_cons]-2)*(_b[a:_cons]-1)^2) )) ) , noheader

				tempname c W
				mat `c' = r(b)
				mat `W' = r(V)	
				ereturn scalar ge2 = `c'[1,1]
				ereturn scalar se_ge2 = sqrt( `V'[1,1] )
				ereturn scalar var = `c'[1,2]
				ereturn scalar se_var = sqrt( `V'[2,2] )
				ereturn scalar sd = `c'[1,3]
				ereturn scalar se_sd = sqrt( `V'[3,3] )
			}

			local ptile "1 5 10 20 25 30 40 50 60 70 75 80 90 95 99"
			foreach x of local ptile {
				eret scalar p`x' = `x0'*(1-`x'/100)^(-(1/`a'))
				eret scalar Lp`x' = 1 - (1-`x'/100)^(1 - (1/`a'))
			}
		}
		/* Fraction with income below given level */
		if ("`poorfrac'" ~= "" & `poorfrac' > 0) {
			eret scalar poorfrac = 1 - ( `x0' / `poorfrac' )^`a'
			eret scalar pline = `poorfrac'
			local pfrac "poorfrac(`poorfrac')"
		}
	}

	Display, `level' `pfrac' 

end

program define Display
	syntax [,Level(cilevel) POORfrac(real 0) *]
	local diopts "`options'"
	ml display, level(`level') `diopts'
	if `level' < 10 | `level' > 99 {
		local level = 95
	}

	if 	"`e(mean)'" ~= ""  {
		local sname "alpha beta mean me gini ge0 ge1"
		local i = 1
		foreach j of local sname {
				local n: word `i' of `sname'
				di as txt "   `n'"  _col(14) "{c |} " as res %10.6f e(`j') _c
				di as res _col(28) %9.6f e(se_`j')  _col(34)  _c
				di %9.3f as result e(`j')/e(se_`j') _col(44) _c
				di %9.3f as result 2*(1-normal(`e(`j')'/`e(se_`j')')) _c
				di _col(58) %9.6g as result `e(`j')'+invnormal((100-`level')/200)*`e(se_`j')' _c
				di _col(70) %9.6g as result `e(`j')'-invnormal((100-`level')/200)*`e(se_`j')' 
				local i = `i' + 1
		}
			if `e(alpha)' > 2 {
				local vname = "ge2 var sd" 
				local k = 1
				foreach m of local vname {
					local n: word `k' of `vname'
					di as txt "   `n'"  _col(14) "{c |} " as res %10.6f e(`m') _c
					di as res _col(28) %9.6f e(se_`m')  _col(34)  _c
					di %9.3f as result e(`m')/e(se_`m') _col(44) _c
					di %9.3f as result 2*(1-normal(`e(`m')'/`e(se_`m')')) _c
					di _col(58) %9.6g as result `e(`m')'+invnormal((100-`level')/200)*`e(se_`m')' _c
					di _col(70) %9.6g as result `e(`m')'-invnormal((100-`level')/200)*`e(se_`m')' 
					local k = `k' + 1
			}
		
		}
				
		di as text "{hline 13}{c BT}{hline 65}"
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
		di "Fraction with {res: `e(depvar)'} < `poorfrac' = " as res %9.5g 1 - ( `e(x0)' / `poorfrac' )^`e(ba)'   
		di " "
	}

	if "`e(mean)'" ~= ""  {
		di as txt "{hline 60}"
		di as txt  _col(6) "Quantiles" _col(22) "Cumulative shares of" 
		di as txt  _col(22) "total `e(depvar)' (Lorenz ordinates)"
		di as txt "{hline 60}"
		di as txt  " 1%" _col(6) as res %9.5g `e(p1)' _col(20) %9.5g `e(Lp1)'
		di as txt  " 5%" _col(6) as res %9.5g `e(p5)' _col(20) %9.5g `e(Lp5)'
		di as txt  "10%" _col(6) as res %9.5g `e(p10)' _col(20) %9.5g `e(Lp10)'
		di as txt  "20%" _col(6) as res %9.5g `e(p20)' _col(20) %9.5g `e(Lp20)'
		di as txt  "25%" _col(6) as res %9.5g `e(p25)' _col(20) %9.5g `e(Lp25)'
		di as txt  "30%" _col(6) as res %9.5g `e(p30)' _col(20) %9.5g `e(Lp30)'
		di as txt  "40%" _col(6) as res %9.5g `e(p40)' _col(20) %9.5g `e(Lp40)' _c
		di as txt  _col(30) "Mode" _col(42) as res %9.5g `e(mode)'
		di as txt  "50%" _col(6) as res %9.5g `e(p50)' _col(20) %9.5g `e(Lp50)' _c
		di as txt  _col(30) "Mean" _col(42) as res %9.5g `e(mean)'
		di as txt  "60%" _col(6) as res %9.5g `e(p60)' _col(20) %9.5g `e(Lp60)' _c
		di as txt  _col(30) "Std. Dev." _col(42) as res %9.5g `e(sd)'
		di as txt  "70%" _col(6) as res %9.5g `e(p70)' _col(20) %9.5g `e(Lp70)'
		di as txt  "75%" _col(6) as res %9.5g `e(p75)' _col(20) %9.5g `e(Lp75)' _c
		di as txt  _col(30) "Variance" _col(42) as res %9.5g `e(var)'
		di as txt  "80%" _col(6) as res %9.5g `e(p80)' _col(20) %9.5g `e(Lp80)' _c
		di as txt  _col(30) "Half CV^2" _col(42) as res %9.5g `e(i2)'
		di as txt  "90%" _col(6) as res %9.5g `e(p90)' _col(20) %9.5g `e(Lp90)' _c
		di as txt  _col(30) "Gini coeff." _col(42) as res %9.5g `e(gini)'
		di as txt  "95%" _col(6) as res %9.5g `e(p95)' _col(20) %9.5g `e(Lp95)' _c
		di as txt  _col(30) "p90/p10" _col(42) as res %9.5g `e(p90)'/`e(p10)'
		di as txt  "99%" _col(6) as res %9.5g `e(p99)' _col(20) %9.5g `e(Lp99)' _c
		di as txt  _col(30) "p75/p25" _col(42) as res %9.5g `e(p75)'/`e(p25)'
		di as txt "{hline 60}"

		
	} 


end



exit

