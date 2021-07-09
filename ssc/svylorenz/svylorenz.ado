*! 3.1.0 SPJ September 2015. Fixed bug in SE calculations for Lorenz and shares (thanks to Ben Jann)  
*! 3.0.0 SPJ September 2006.  Added Generalized Lorenz estimation; fixed bug with subpop()
*! version 2.1.0 Stephen P. Jenkins, Nov 2005
*!   Variance estimation for Gini, income shares,
*!   cumulative shares (Lorenz curve ordinates) and generalized Lorenz ordinates

program define svylorenz, eclass sortpreserve

	version 9

if replay() {
		if "`e(cmd)'" != "svylorenz" {
			noi di in red "results for svylorenz not found"
			exit 301
		}
		Display `0'
		exit `rc'
	}
	else	Estimate `0'
end

program define Estimate, eclass 

	set more off

 	syntax varname [if] [in] [, Ngps(int 10) QGP(string) ///
		SUBpop(varname) Level(passthru) ///
		PVar(string) LVar(string) SELVar(string) GLVar(string) SEGLVar(string) ]

	local inc `varlist'

        marksample touse
        markout `touse' `inc' 
	svymarkout `touse'

	qui svyset
	if _rc != 0  {
		di " "
		di as err "data not set up for svy, use" in smcl "{help svyset}"
		exit 119
	}
	tempvar wi
	if "`r(wvar)'" == ""    qui ge `wi' = 1 
	else 	qui ge `wi' =  `r(wvar)' if `touse'


	if (`ngps' <= 0 | `ngps' > 100) {
	  di as error "# quantile groups should be integer in range (0,100]"
	  error 198
	}       

	tempvar last qrel totalj incshj  qtile badinc 

	if "`qgp'" != ""   confirm new variable `qgp' 
	else tempvar qgp

	if "`pvar'" != ""  confirm new variable `pvar' 
	else tempvar pvar

	if "`lvar'" != ""  confirm new variable `lvar' 
	else tempvar lvar

	if "`selvar'" != ""  confirm new variable `selvar' 
	else tempvar selvar

	if "`glvar'" != ""  confirm new variable `glvar' 
	else tempvar glvar

	if "`seglvar'" != "" confirm new variable `seglvar' 
	else tempvar seglvar
	


quietly {

	count if `inc' < 0 & `touse'
	local ct = r(N)
	if `ct' > 0 {
		noi di " "
		noi di as txt "Warning: `inc' has `ct' values < 0." _c
		noi di as txt " Not used in calculations"
	}
	count if `inc' == 0 & `touse'
	local ct = r(N)
	if `ct' > 0 {
		noi di " "
		noi di as txt "Warning: `inc' has `ct' values = 0." _c
		noi di as txt " Used in calculations"
	}

	// comment out next line if want to include 
	// obs with `inc' < 0 in calculations 
	
	replace `touse' = 0 if `inc' < 0

	// stop if no valid obs
        qui count if `touse' 
        if r(N) == 0 error 2000 

	if "`subpop'" != "" {
		local opt ", subpop(`subpop')"
		local andsub "& `subpop'"
	}
	
	svy `opt' : mean `inc' if `touse'
	if "`subpop'" == "" {
		local sumwi = e(N_pop)
	}
	else {
		local sumwi = e(N_subpop)
		local N_sub = e(N_sub)
		local N_subpop = e(N_subpop)
	}
		// pick up all svy summary stuff from the svy mean calculation
	tempname m v
	mat `m' = e(b)
	local meany = `m'[1,1]
	local toty =  `sumwi'*`meany'
	mat `v' = e(V)
	local se_mean = sqrt(`v'[1,1])
	local N_strata = e(N_strata)
	local N_psu = e(N_psu)
	local N = e(N)
	local N_pop = e(N_pop)
	local df_r = e(df_r)

	xtile `qgp' = `inc' [w = `wi'] if `touse' `andsub', nq(`ngps')

	sort `qgp' `touse' `subpop' `inc'


	by `qgp': ge `last' = (_n==_N)   if `touse' `andsub'

	svy `opt' : total `inc' if `touse', over(`qgp')  
	tempname totals
	mat `totals' = e(b)
	ge double `totalj' = .
	forvalues j = 1/`ngps' {
		replace `totalj' = `totals'[1,`j'] if `touse' & `qgp' == `j' `andsub'
	}

	
	sort `qgp' `touse' `subpop' `inc'
	by `qgp': ge `qtile' = `inc' if `last' & `touse' & `qgp' <. `andsub'
	ge double `incshj' = `totalj'/`toty' if `touse' & `last' `andsub'      // for group!
	sort `qgp'


	replace `qtile' = . if `qgp' == `ngps'

	tempname qs shs
	mat `qs' = J(1,`=`ngps'-1',0)
	mat `shs' = J(1,`ngps',0)

	forvalues j = 1/`ngps' {
		sum `incshj' if `touse' & `last' & (`qgp' == `j') `andsub', meanonly
		local sh`j' = r(mean)
		mat `shs'[1,`j'] = r(mean)
		if `j' == 1 {
			local cush`j' = `sh1'
		}
		else {
			local cush`j' = `cush`=`j'-1'' + `sh`j''
		}

		local gl`j' = `meany'*`cush`j''  // generalised Lorenz ordinate

		sum `qtile' if `last' & `touse' & (`qgp' == `j') `andsub', meanonly
		if `j' < `ngps' {
			local q`j' = r(mean)
			mat `qs'[1,`j'] = r(mean)
		}
	}

        gsort -`touse' `inc'

	tempvar B py u 	//  see B formula below
	
	ge double `B' = sum( `inc' * `wi'/`sumwi' ) if `touse' `andsub'
	replace `B' = `meany' - `B' if `touse' 
				*  code to handle ties properly
       	ge double `py' = ( 2*sum(`wi') - `wi'  ) / ( 2 * `sumwi' ) if `touse' `andsub'

	// Gini & 'residual' var of Kovacavic & Binder (JOS 1997, pp. 49-50). 

		// Gini = (1/(sum_wi*meany)) * SUM wi*( 2*Fi - 1 )*yi
		//      = SUM wi*( 2*Fi - 1 )*yi / total_yi   <------- "Glasser" version
		// I use -ineqdeco- (and -inequal7-) version of same formula (see below)

		// Residual = (2/N*meany)*[ A(yi)*yi + B(yi) - (meany/2)*(Gini + 1) ]
		// where A(yi) = F(y) - (Gini+1)/2, and B(yi) = SUM wiyi*I(yi>=y)/sum_wi
		//  I rewrite B(yi) as B(yi) = meany - SUM (wi/sumwi)*yi*I(yi<y):
		//	calculation of B is done above

	tempvar ginivar gu

	// version of formula as in -ineqdec0-, -inequal7-
	ge double `ginivar' = (1/`sumwi') * (2/`meany')*`py' * (`inc' - `meany')   if `touse' `andsub'

	svy `opt' : total `ginivar' if `touse' 
	tempname gest 
	mat `gest' = e(b)
	local gini = `gest'[1,1] 

/*
	// "Glasser version" as in JOS article. (Gives same results)
	tempvar gg
	ge double `gg' =   (2*`py' - 1) * `inc' / (`meany' * `sumwi') if `touse' & `subpop' 
	svy `opt' : total `gg' if `touse'  
	tempname gest2 
	mat `gest2' = e(b)
	local gini2 = `gest2'[1,1]

*/

	ge double `gu' = ( 2/`toty' ) * ( 		///
			`inc' * (`py' - (`gini'+1)/2)  	///
			+ `B' - `meany' * (`gini'+1)/2	///
			 ) if `touse' 
	if "`subpop'" != "" {
		replace `gu' = 0 if `subpop' == 0
	}

	svy `opt' : total `gu' if `touse' 
	tempname gcov
        matrix `gcov' = e(V)
	local se_gini = sqrt( `gcov'[1,1] )


	// 'residual' var of Kovacavic & Binder (JOS 1997, p. 49) for Lorenz ordinates
	// uj = (1/(sumwi*meany)) * 
	//	 [ yi - quantile_p]*I(yi <= quantile_p) + p*quantile_p - yi*L(p) ]

	forvalues j = 1/`=`ngps'-1' {
		tempvar u`j' 
		ge double `u`j'' = (1/`toty') * (                ///
			        ( `inc' - `q`j'' )*( `inc' <= `q`j''  )   ///
				+ ( (`j'/`ngps')*`q`j'' )   		///
				 - ( `inc'*`cush`j'')      		///
				) if `touse' 
		if "`subpop'" != "" {
			replace `u`j'' = 0 if `subpop' == 0
		}
		local us  `us' `u`j''
	}

	tempname cov

	svy `opt' : total `us' if `touse' 
        matrix `cov' = e(V)
	forvalues j = 1/`= `ngps'-1'	{
		local se_cush`j' = sqrt( `cov'[`j',`j'] )
	}

 
	// SEs for quantile group shares from Beach & Kaliski, Applied Stats, 1986, p. 41
	//	-- derived from estimates for Lorenz ordinates (cumulative shares)

	forvalues j = 1/`ngps'	{

		if `j' == 1 {
			local se_sh`j'  = sqrt( `cov'[`j',`j'] )
		}
		if `j' > 1 & `j' < `ngps' {
			local se_sh`j'  = sqrt( `cov'[`j',`j'] ///
				+ `cov'[`=`j'-1',`=`j'-1'] - 2*`cov'[`j',`=`j'-1'] ) 
		}
		if `j' == `ngps' {
			local se_sh`j'  =  sqrt( `cov'[`=`j'-1',`=`j'-1'] )
		}
	}


	// 'residual' var of GL ordinate derived following method for Gini ordinate
	// in Binder & Kovacavic  (Survey Methodology 1995)
	//	v_j = [ yi - quantile_p]*I(yi <= quantile_p) + p*quantile_p - GL(p) ] / total_pop, j < J ; 
	//	v_j = [ yi - (total_y / total_pop)] / total_pop  if j = J

	forvalues j = 1/`=`ngps'' {

		tempvar v`j' 
		if `j' < `ngps' {
			ge double `v`j'' = ( ( `inc' - `q`j'' ) * ( `inc' <= `q`j''  )   ///
					     +  (`j'/`ngps') * `q`j''    		///
				 	     -  `gl`j'' 		     		///
				           ) / `sumwi'  if `touse' 
		}
		if `j' == `ngps' {
			ge double `v`j'' = ( `inc' - ( `toty'/`sumwi' ) ) / `sumwi'  if `touse' 
		}	
		if "`subpop'" != "" {
			replace `v`j'' = 0 if `subpop' == 0
		}
		local vs  `vs' `v`j''
	}

	tempname cov2

	svy `opt' : total `vs' if `touse'
	matrix `cov2' = e(V)

	forvalues j = 1/`= `ngps''	{
		local se_gl`j' = sqrt( `cov2'[`j',`j'] )
	}

       	ereturn local cmd  "svylorenz"
        ereturn local var "`inc'"
	ereturn scalar mean = `meany' 
	ereturn scalar se_mean = `se_mean'
	ereturn scalar total = `toty'
	ereturn scalar N = `N'
	ereturn scalar N_pop = `N_pop'
	ereturn scalar df_r = `df_r'

	ereturn scalar ngps = `ngps'
	ereturn matrix quantiles = `qs'
	ereturn matrix shares = `shs' 

	ereturn matrix V_cush = `cov', copy
	ereturn matrix V_gl = `cov2', copy

	forvalues j = 1/`ngps'	{
		ereturn scalar sh`j' = `sh`j'' 
		ereturn scalar se_sh`j' = `se_sh`j''

		ereturn scalar cush`j' = `cush`j''

		ereturn scalar gl`j' = `gl`j''
		ereturn scalar se_gl`j' = `se_gl`j''

		if `j' < `ngps' {
			ereturn scalar q`j' = `q`j'' 
			ereturn scalar se_cush`j' = `se_cush`j''
		}
	}
	ereturn scalar gini = `gini'
	ereturn scalar se_gini = `se_gini'

	ereturn scalar N_strata = `N_strata'
	ereturn scalar N_psu = `N_psu'
	if "`subpop'" != "" {
		ereturn scalar N_subpop = `N_subpop'
		ereturn scalar N_sub = `N_sub'
	}

	// create variables that might be used for graphs
	ge `pvar' = 0 in 1
	ge `lvar' = 0 in 1
	ge `selvar' = . in 1

	ge `glvar' = 0 in 1
	ge `seglvar' = . in 1

	forval z = 1/`e(ngps)'  {
		replace `pvar' = `z' / `e(ngps)' in `=`z'+1'
		replace `lvar' =  `e(cush`z')' in `=`z'+1'

		replace `glvar' = `e(gl`z')' in `=`z'+1'
		replace `seglvar' = `e(se_gl`z')' in `=`z'+1'

		if `z' < `e(ngps)' {
			replace `selvar' = `e(se_cush`z')' in `=`z'+1'
		}
	}	

} // end quietly block

	Display, `level'



end



program define Display

	syntax [, Level(int $S_level) ]

	di _newline
	di as text "Quantile group shares, cumulative shares (Lorenz ordinates), " 
	di as text "generalized Lorenz ordinates, and Gini"   
	di " "

	di as text "Number of strata = " %10.0f as res `e(N_strata)' _c
	di _col(45) as txt "Number of obs    = " %12.0f as res `e(N)' 
	di as text "Number of PSUs   = " %10.0f as res `e(N_psu)'  _c
	di  _col(45) as txt "Population size  = " %12.2f as res `e(N_pop)'

	if "`e(subpop)'" ~= "" {
		di as text _col(45) "Subpop. no. obs  = " %12.0f as res `e(N_sub)'   
		di as text _col(45) "Subpop. size     = " %12.2f as res `e(N_subpop)'
	}
	di as text _col(45) "Design df        = " %12.0f as res `e(df_r)'
	di " "

	di as text "{hline 9}{c TT}{hline 65}"
	di as text "  Group" _col(10) as text "{c |}"  _col(24)  "Linearized"
	di as text "  share" _col(10) as text "{c |}   Estimate " _c
	di as text _col(25)  "Std. Err." _col(39) "z"  _c
	di as text _col(46) "P>|z|"  _col(56) "[`level'% Conf. Interval]"
	di as text "{hline 9}{c +}{hline 65}"


	forvalues j = 1/`e(ngps)'	{
		di as txt _col(5) `j'  _col(10) "{c |} " as res %10.6f `e(sh`j')' _c
		di as res _col(24) %9.6f `e(se_sh`j')'  _col(31)  _c
		di %9.3f as result e(sh`j')/e(se_sh`j') _col(40) _c
		di %9.3f as result 2*(1-normal(`e(sh`j')'/`e(se_sh`j')')) _c
		di _col(56) %9.6g as result e(sh`j')+invnormal((100-`level')/200)*e(se_sh`j') _c
		di _col(67) %9.6g as result e(sh`j')-invnormal((100-`level')/200)*e(se_sh`j') 
	}
	di as text "{hline 9}{c +}{hline 65}"
	di as text "  Cumul." _col(10) as text "{c |}"  
	di as text "  share" _col(10) as text "{c |}" 

	forvalues j = 1/`e(ngps)'	{

		if `j' < `e(ngps)' {
			di as txt _col(5) `j'  _col(10) "{c |} " as res %10.6f `e(cush`j')' _c
			di as res _col(24) %9.6f `e(se_cush`j')'  _col(31)  _c
			di %9.3f as result e(cush`j')/e(se_cush`j') _col(40) _c
			di %9.3f as result 2*(1-normal(`e(cush`j')'/`e(se_cush`j')')) _c
			di _col(56) %9.6g as result e(cush`j')+invnormal((100-`level')/200)*e(se_cush`j') _c
			di _col(67) %9.6g as result e(cush`j')-invnormal((100-`level')/200)*e(se_cush`j') 
		}
		else {
			di as txt _col(5) `j'  _col(10) "{c |} " as res %10.6f `e(cush`j')' 
		}
	}

di as text "{hline 9}{c +}{hline 65}"
di as text "  Gen." _col(10) as text "{c |}"  
di as text "  Lorenz" _col(10) as text "{c |}" 


forvalues j = 1/`e(ngps)'	{

		di as txt _col(5) `j'  _col(10) "{c |} " as res %10.3f `e(gl`j')' _c
		di as res _col(24) %9.3f `e(se_gl`j')'  _col(31)  _c
		di %9.3f as result e(gl`j')/e(se_gl`j') _col(40) _c
		di %9.3f as result 2*(1-normal(`e(gl`j')'/`e(se_gl`j')')) _c
		di _col(55) %10.3f as result e(gl`j')+invnormal((100-`level')/200)*e(se_gl`j') _c
		di _col(66) %10.3f as result e(gl`j')-invnormal((100-`level')/200)*e(se_gl`j') 
}


	di as text "{hline 9}{c +}{hline 65}"

	di as text "  Gini" _col(10) "{c |} "  as result %10.7f e(gini) _c
	di as result _col(24) e(se_gini) _col(31)  _c
	di %9.3f as result e(gini)/e(se_gini) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(gini)'/`e(se_gini)')) _c
	di _col(56) %9.0g as result e(gini)+invnormal((100-`level')/200)*e(se_gini) _c
	di _col(67) %9.0g as result e(gini)-invnormal((100-`level')/200)*e(se_gini) 

	di as text "{hline 9}{c BT}{hline 65}"


end


