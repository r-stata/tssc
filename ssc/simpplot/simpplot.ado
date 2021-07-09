*! version 1.5.3 01Jul2013 MLB
*  version 1.5.2 02Apr2013 MLB
*  version 1.5.1 28Mar2013 MLB
*  version 1.5.0 22Mar2013 MLB
*  version 1.2.2 08Aug2012 MLB
*  version 1.2.1 28Jun2012 MLB
*  version 1.2.0 20Jun2012 MLB
*  version 1.1.0 19Jun2012 MLB
*  version 1.0.0 18Jun2012 MLB
program define simpplot, sortpreserve
	version 10.1
	syntax varlist [if] [in], *
	
	// count number of variables
	local k_var : word count `varlist'	
	forvalues i = 1/`k_var' {
		local mainopts "`mainopts' main`i'opt(string)"
	}
	
	syntax varlist [if] [in],                       ///
           [                                        ///
		   Level(cilevel)                           ///
		   ra(string asis)                          ///
		   ref0(string asis)                        ///
		   `mainopts'                               ///
		   overall                                  ///
		   reps(numlist integer min=1 max=1 >0)     ///
		   noresid                                  ///
		   noDEViation                              /// 
		   by(string asis)                          ///
		   GENerate(namelist)                       ///
		   addplot(string)                          ///
		   *                                        ///
		   ]
	
	// parse sample
	marksample touse
	tempvar outrange
	qui gen byte `outrange' = 0
	foreach var of local varlist {
		qui replace `outrange' = ( `var' < 0 | `var' > 1 ) & `touse'
	}
	qui count if `outrange'
	if r(N) > 0 {
		di as txt "`r(N)' observations on `varlist' contain values less than 0 or more than 1"
		di as txt "these will be ignored"
		qui replace `touse' = 0 if `outrange'
	}
	qui count if `touse'
	if r(N) == 0 {
		error 2000
	}
	if `"`by'"' == "" {
		local n = r(N)
	}
	
	// parse options for the overall region of accpetance
	if "`overall'" != "" & `"`ra'"' == "off"  {
		di as err "the overall option cannot be specified when the ra() option is set to off"
		exit 198
	}
	if "`reps'" != "" & "`overall'" == "" {
		di as err "the overall option needs to be specified when specifying the reps() option"
		exit 198
	}
	
	// parse by() option
	if `"`by'"' != "" {
		gettoken byvars: by, parse(",")
		confirm variable `byvars'
	}
	
	// check -generate()- option
	if "`generate'" != "" {
		local k_gen : word count `generate'
		if ( `k_gen' <  `k_var'         ) | ///
		   ( `k_gen' == `= `k_var' + 1' ) | ///
		   ( `k_gen' == `= `k_var' + 2' ) | ///
		   ( `k_gen' >  `= `k_var' + 3' ){
			di as err "only `k_var' or `= `k_var' + 3' new variable names can be specified in the generate() option"
			exit 198
		}
		
		confirm new variable `generate'
		if `"`ra'"' != "" & `k_gen' == `= `k_var' + 2' {
			di as error "only `k_var' newvar can be specified in the generate() option"
			di as error "when the nora option has been specified"
			exit 198
		}
	}
	
	// noresid option changed to nodeviation
	if "`resid'" != "" {
		local deviation "nodeviation"
	}
	
	// compute coverage (= CDF) for each variable
	local i = 1
	foreach var of local varlist {
		if `"`by'"' != "" {
			local byby "bys `byvars' (`var') : "
		}
		else {
			sort `var'
		}
		tempvar cumul`i' deviation`i'
		quietly {
			`byby' gen `cumul`i'' = sum(`touse')
			`byby' replace `cumul`i'' = `cumul`i''/`cumul`i''[_N]
			`byby' replace `cumul`i'' = . if !`touse'

		}
		local maingr `maingr' || scatter `deviation`i'' `var' , mstyle(p`i') `main`i'opt'
		local i = `i' + 1
	}
	
	// compute region of acceptance
	if `"`ra'"' != "off" {
		tempvar lb ub nom count
		if `"`by'"' == "" {
			local N = min(_N, 300)
		}
		else {
			tempvar Nby
			by `byvars' : gen `Nby' = _N          // number of rows
			sum `Nby', meanonly
			local N = min(r(min), 300)
			qui {
				bys `touse' `byvars' : replace `Nby' = _N if `touse'   // number of valid rows
			}
			sum `Nby' if `touse', meanonly
			local n = r(min)
			if r(min) != r(max) {
				di as txt ///
"{p}the number of (valid) simulations is not the same in each by-group; the minimum " as result r(min) as txt " was used to compute the region of acceptance{p_end}"
			}
			qui drop `Nby'
		}
		quietly {
			`byby' gen `nom' = .001 + (_n - 1)/(`N' - 1) * (.999 - .001) if _n <= `N'
		}
		if "`overall'" == "" {           // point-wise region of acceptance
			qui gen `count' = `nom'*`n'
			qui gen `lb' = invbinomial(`n', `count',`= ( 100 - `level') / 200')
			qui gen `ub' = invbinomialtail(`n', `count',`= ( 100 - `level' ) / 200')
			qui drop `count'
		}
		else {                           // overall region of acceptance
			if "`reps'" == "" local reps = 1000
			tempname bounds
			mata: simpplot_sim(`reps', `N', `n', `level', "`bounds'")
			if `"`by'"' != "" {
				local byby "bys `byvars' (`nom') : "
			}
			quietly {
				`byby' gen `lb' = `bounds'[_n,1]
				`byby' gen `ub' = `bounds'[_n,2]
			}
			if (`orate' * 100) > (100 - `level') {
				di as txt ///
"{p}not enough replications to compute overall bounds; the returned bounds have an approximate overall error rate of" as result %6.3f `orate' "{p_end}" 
			}
		}
		
		if "`deviation'" == "" {
			qui replace `lb' = `lb' - `nom'
			qui replace `ub' = `ub' - `nom'
		}
		if `"`ra'"' == "" {
			local ragr `"rarea `lb' `ub' `nom', astyle(ci)"' 
		}
		else {
			local ragr `"rarea `lb' `ub' `nom', `ra'"' 
		}
		local note `"note("with `level'% `= cond("`overall'" == "", "point-wise", "overall")' Monte Carlo region of acceptance")"'
		if `"`by'"' != "" {
			gettoken byvars byopts : by, parse(",")
			gettoken comma byopts : byopts, parse(",")
			local by by(`byvars', `note' `byopts')
			local note ""
		}
	}
	else {
		local by by(`by')
	}
	
	// compute deviations when desired and choose appropriate y-title
	if "`deviation'" == "" { 
		forvalues i = 1/`k_var' {
			qui gen `deviation`i'' =  `cumul`i'' - `: word `i' of `varlist''
		}
		local ytitle "ytitle(deviations)"
	}
	else {
		forvalues i = 1/`k_var' {
			qui gen `deviation`i'' = `cumul`i''
		}
		local ytitle "ytitle(covarage)"
	}
	
	// add variable labels to the variables that are to be plotted
	// these will show up in legend
	local i = 1
	foreach var of local varlist {
		local lab : variable label `var'
		if `"`lab'"' == "" {
			local lab "`var'"
		} 
		label var `deviation`i'' `"`lab'"'
		local i = `i' + 1
	}
	
	// create the legend
	if `k_var' > 1 {
		if `"`ra'"' != "off" {
			forvalues i = 1/`k_var' {
				local varl "`varl' `=`i'+1'"
			}
			local leg `"legend(order( `varl' ) cols(1) pos(4)) "' 
		}
		else {
			numlist "1/`k_var'"
			local varl "`r(numlist)'"
			local leg `"legend(order( `varl' ) cols(1) pos(4)) "' 
		}
	}
	else {
		local leg "legend(off)"
	}
	
	// add a reference line
	if `"`ref0'"' != "off" {
		if "`deviation'" == "" {
			local refgr `"|| pci 0 0 0 1, lstyle(yxline) `ref0' yline(0, `ref0')"'
		}
		else {
			local refgr `"|| pci 0 0 1 1, lstyle(yxline) `ref0' "'
		}
	}
	
	// create the graph
	twoway `ragr'                                    ///
	       `maingr'                                  ///
		   xtitle("nominal significance")            ///
		   `ytitle'                                  ///
		   `leg'                                     ///
		   `note'                                    ///
		   `by'                                      /// 
		   `options'                                 ///
		   `refgr' || `addplot'
	
	// leave behind variables when desired
	if "`generate'" != "" {
		tokenize `generate'
		forvalues i = 1/`k_var' {
			gen ``i'' = `deviation`i''
			if `"`ra'"' != "off" {
				label var ``i'' "deviations for `: word `i' of `varlist''"
			}
			else {
				label var ``i'' "coverage for `: word `i' of `varlist''"
			}
		}
		if `k_gen' > `k_var' {
			gen ``=`k_var'+1'' = `nom'
			lab var ``=`k_var'+1'' "x-axis for MC RA"
			gen ``=`k_var'+2'' = `lb'
			lab var ``=`k_var'+2'' `"lower bound of `level'% `= cond("`overall'" == "", "point-wise", "overall")' MC RA"'
			gen ``=`k_var'+3'' = `ub'
			lab var ``=`k_var'+3'' `"upper bound of `level'% `= cond("`overall'" == "", "point-wise", "overall")' MC RA"'
		}
	}

end

mata
real colvector simpplot_putongrid(real colvector u, real colvector grid, real scalar n_obs, real scalar n_grid) {
	real colvector res
	real scalar i, j, c
	res = J(n_grid,1,.)
	u = sort(u,1)
	c = 1
	for (j=1; j <= n_grid; j++) {
		for (i=max((c,1)); i<=n_obs ; i++) {
			if ( u[i,1] > grid[j,1] ) break
		}
		c = i - 1
		res[j,1] = c / n_obs
	}
	return(res)
}

void simpplot_sim(
    real scalar reps, 
	real scalar n_grid, 
	real scalar n_obs, 
	real scalar level,
    string scalar matname)
{
	real scalar i, j, orate, L, U, lr, l1, l2, u1, u2
	real rowvector colminrank, colmaxrank
	real colvector x
	real matrix compare, grid, rank, envelope
	
	compare = J(n_grid, reps,.)
	grid = .001 :+ (0..(n_grid-1))' / (n_grid - 1) * (.999 - .001)
	
	for (i=1; i<=reps ; i++) {
		compare[.,i] = simpplot_putongrid( runiform(n_obs,1), grid, n_obs, n_grid )
	}
	
	L = reps * (100 - level)/200
	U = reps * (100 + level)/200

	rank = J(n_grid,reps,.)
	for (j = 1; j <= n_grid; j++) {
		rank[j,.] = invorder(order(compare[j,.]', 1))'
	}
	colminrank = colmin(rank)
	colmaxrank = colmax(rank)
	for (lr = ceil(L); lr >= 1 ; lr--) {
		orate = sum((colminrank:<= lr) :| (colmaxrank:>=(reps - lr))) / ( reps - 1 )
		if ( (orate*100) < (100-level)) break
	}
	L = lr 
	U = reps- lr
	st_local("orate", strofreal(orate))

	l1 = ceil(L)
	l2 = l1 + (L == l1) 
	if (l1 == 0) l1 = 1 

	u1 = ceil(U)
	u2 = u1 + (U == u1)
	if (u2 == reps + 1) u2 = reps

	envelope = J(n_grid, 2, .)
	for (i = 1; i <= n_grid; i++) {
		   x = sort(compare[i,]', 1)
		   envelope[i,] = ((x[l1] + x[l2])/2, (x[u1] + x[u2])/2)
	}

	st_matrix(matname, envelope)
}
end
