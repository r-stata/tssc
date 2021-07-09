*! version 1.0  3Nov2014
*! Hai-Anh Hoang Dang - hdang@worldbank.org
*! Minh Cong Nguyen - congminh6@gmail.com/ mnguyen3@worldbank.org
cap program drop povimp
program define povimp, eclass byable(recall) sortpreserve
                 
syntax varlist [if] [in] [aweight fweight],  by(varname numeric) from(numlist max=1) to(numlist max=1) ///
	method(string) pline(varname numeric) ///
	[WTstats(varname numeric) cluster(varname numeric) strata(varname numeric) ///
	decomp(string) rep(numlist max=1) seed(numlist max=1) noCONStant wald]
	
	version 12, missing
	if c(more)=="on" set more off
    local version : di "version " string(_caller()) ", missing:"

	local cmdline: copy local 0
    local nocns "`constant'"
	if "`seed'"=="" local seed 1234567
	preserve
	cap mat drop all
	
	*** area options
	if ("`cluster'"=="") {
		tempvar grv
		qui gen `grv' = 1
		local grvar `grv'
	}
	else {
		if (`:word count `cluster''==1) { // one group variable
			local grvar `cluster'
		}               
		else { // more than one group variable
			tempvar grmv
			qui egen `grmv' = group(`cluster'), label truncate(16)
			local grvar `grmv'
		}
	}
	
	*** Weights
	if ("`weight'"=="") {
		tempvar w
		qui gen `w' = 1
		local wvar "`w'"
	}       
	else {
		local weight "[`weight'`exp']"                          
		local wvar : word 2 of `exp'
	}
	
	*** Indicator weight
	if "`wtstats'"=="" {
		tempvar w
		qui gen `w' = 1
		local wtstats "`w'"
	}
	
	if "`rep'"=="" local rep 50
	
	gettoken lhs varlist: varlist
	local flist `"`varlist' `by' `pline'"'
	local okvarlist `varlist'
	tempvar pr
	qui gen `pr'= `lhs'<= `pline' if `lhs'<. & `by'==`from'
	local poor `pr'
	
	// decomp variable
	tempvar prfr prto
	qui if "`decomp'"~="" {
		if "`decomp'"~="relative" & "`decomp'"~="absolute" {
			noisily dis in red `"In the decomp option, either "relative" or "absolute" is allowed"'
			exit 198 
		}
		qui su `lhs' if `by'==`from'
		local fr = r(N)
		if r(N)==0 | r(mean)==0 {
			noisily dis in red "There is no observation or mean is zero for `by'==`from'"
			exit 198 
		}
		else {
			gen `prfr'= `lhs'<= `pline' if `lhs'<. & `by'==`from'
			qui su `prfr' [aw=`wtstats'] if `by'==`from'
			local povfr = r(mean)
			
			qui su `lhs' if `by'==`to'
			local td = r(N)
			if r(N)==0 | r(mean)==0 {
				noisily dis in red "There is no observation or mean is zero for `by'==`to'"
				exit 198 
			}
			else {
				//Good condition
				gen `prto'= `lhs'<= `pline' if `lhs'<. & `by'==`to'
				qui su `prto' [aw=`wtstats'] if `by'==`to'
				local povto = r(mean)
			}			
		}			
	}
	
	** Save original data
	tempfile dataori datafrm datato
	qui save `dataori', replace
	
	** from data
	use `dataori', clear
	qui keep if `by'==`from'
	qui count
	local fr = r(N)
	if `fr'<=0 {
		dis "Data (`from') has no observation"
		exit 198 
	}
	qui save `datafrm', replace
	
	** to data
	use `dataori', clear
	qui keep if `by'==`to'
	qui count
	local toc = r(N)
	if `toc'<=0 {
		dis "Data (`to') has no observation"
		exit 198 
	}
	qui save `datato', replace
	
	use `dataori', clear 	
	tempvar ut et
	if "`method'"=="empirical" | "`method'"=="normal" {	
		qui xtreg `lhs' `okvarlist' `weight' if `by'==`from', i(`grvar')
	}
	if "`method'"=="probit" {
		qui xtprobit `poor' `okvarlist' `weight' if `by'==`from', i(`grvar')
	}
	if "`method'"=="logit" {
		qui xtlogit `poor' `okvarlist' `weight' if `by'==`from', i(`grvar')
	}
	qui {
		local nfdata= e(N)
		keep if `by'==`to'
		predict double __xb, xb
		keep if __xb<.
		keep `lhs' `okvarlist' __xb `by' `strata' `cluster' `wvar' `pline' `wtstats'
		gen __obid= _n
		qui su __obid
		local nsdata= r(N)
		sort __obid
		compress
		tempfile datatoxb
		save `datatoxb', replace
	}
	cap mat drop all	
		
	// Simulate with empirical distribution of errors
	_dots 0, title(Running with `rep' reps) reps(`rep')
	qui if "`method'"=="empirical" {		
		use `dataori', clear
		qui xtreg `lhs' `okvarlist' `weight' if `by'==`from', i(`grvar')
		scalar r2_m = e(r2_o)
		scalar n_m = r(N)
		predict double __ut if e(sample), u
		predict double __et if e(sample), e
		keep if __ut<.
		keep __ut __et
		compress
		tempfile euh
		save `euh', replace
		local ratio = ceil(`toc'/`fr')
		
		set seed `seed'
		qui forv i=1/`rep' {
			use `euh', clear
			expand `ratio'				
			bsample `nsdata' 
			gen __obid= _n
			sort __obid			
			merge 1:1 __obid using `datatoxb'
			drop _m
			gen double yh= __xb + __ut + __et			
			*USE POVERTY LINE IN 1ST PERIOD
			gen poor1= yh<= `pline' 
			svyset `cluster' [w= `wtstats'], strata(`strata')  
			svy: mean poor1
			mat poor1h= e(b)
			mat poor1h_var= e(V)
			mat all = nullmat(all) \ `i', poor1h[1,1], poor1h_var[1,1]
			noisily _dots `i' 0
		}
		clear
		mat colnames all = rep poor1h poor1h_var
		svmat all, names(col)
		
		qui su poor1h
		local pov_imp = r(mean)*100	
		scalar seexp= r(Var)/r(N) 
		qui su poor1h_var
		local se2 = (r(mean)+ seexp)^0.5*100 
		
		qui if "`decomp'"~="" {
			if "`decomp'"=="relative" {
				gen double p2_p21 = (`povto' - poor1h)/(`povto'-`povfr')
				gen double p21_p1 = (poor1h - `povfr')/(`povto'-`povfr')
			}
			if "`decomp'"=="absolute" {
				gen double p2_p21 = `povto' - poor1h
				gen double p21_p1 = poor1h - `povfr'
			}
			qui su p2_p21
			local p2_p21 = 100*r(mean)
			qui su p21_p1
			local p21_p1 = 100*r(mean)
		}
			
	}
	qui if "`method'"=="normal" {
		use `dataori', clear
		qui xtreg `lhs' `okvarlist' `weight' if `by'==`from', i(`grvar')
		scalar r2_m = e(r2_o)
		scalar n_m = r(N)
		mat b= e(b)
		mat V= J(2,2,.)
		scalar varu= e(sigma_u)^2
		mat V[1,1]= varu
		scalar vare= e(sigma_e)^2
		mat V[2,2]= vare
		mat V[1,2]= 0
		mat V[2,1]= 0
		
		set seed `seed'
		qui forv i= 1/`rep'  {
			clear
			drawnorm __ut __et, n(`nsdata') cov(V) double			
			gen __obid= _n
			sort __obid			
			merge 1:1 __obid using `datatoxb'
			drop _m 			
			gen double yh= __xb + __ut + __et
				
			*USE POVERTY LINE IN 1ST PERIOD
			gen poor1= yh<= `pline' 
			svyset `cluster' [w= `wtstats'], strata(`strata')  
			svy: mean poor1
			mat poor1h= e(b)
			mat poor1h_var= e(V)
			mat all = nullmat(all) \ `i', poor1h[1,1], poor1h_var[1,1]
			noisily _dots `i' 0
		}
				
		clear	
		mat colnames all = rep poor1h poor1h_var
		svmat all, names(col)		
		qui su poor1h
		local pov_imp = r(mean)*100 
		scalar seexp= r(Var)/r(N) 
		qui su poor1h_var
		local se2 = (r(mean)+ seexp)^0.5*100
		
		qui if "`decomp'"~="" {
			if "`decomp'"=="relative" {
				gen double p2_p21 = (`povto' - poor1h)/(`povto'-`povfr')
				gen double p21_p1 = (poor1h - `povfr')/(`povto'-`povfr')
			}
			if "`decomp'"=="absolute" {
				gen double p2_p21 = `povto' - poor1h
				gen double p21_p1 = poor1h - `povfr'
			}
			qui su p2_p21
			local p2_p21 = 100*r(mean)
			qui su p21_p1
			local p21_p1 = 100*r(mean)
		}			
	}
	
	qui if "`method'"=="probit" {
		use `dataori', clear		
		qui xtprobit `poor' `okvarlist' `weight' if `by'==`from', i(`grvar')
		scalar n_m = r(N)
		mat b= e(b)
		mat V= J(1,1,.)
		scalar varu= e(sigma_u)^2
		mat V[1,1]= varu		
		scalar r2_m = .
		set seed `seed'
		qui forv i= 1/`rep'  {
			clear
			drawnorm __ut, n(`nsdata') cov(V) double
			gen __obid= _n
			sort __obid			
			merge 1:1 __obid using `datatoxb'
			drop _m 				
			*USE POVERTY LINE IN 1ST PERIOD
			gen double poor1= normal(__xb + __ut)
			svyset `cluster' [w= `wtstats'], strata(`strata')  
			svy: mean poor1
			mat poor1h= e(b)
			mat poor1h_var= e(V)
			mat all = nullmat(all) \ `i', poor1h[1,1], poor1h_var[1,1]
			noisily _dots `i' 0
		}
		clear
		mat colnames all = rep poor1h poor1h_var
		svmat all, names(col)
		
		qui su poor1h
		local pov_imp = r(mean)*100 
		scalar seexp= r(Var)/r(N) 
		qui su poor1h_var
		local se2 = (r(mean)+ seexp)^0.5*100 
		
		qui if "`decomp'"~="" {
			if "`decomp'"=="relative" {
				gen double p2_p21 = (`povto' - poor1h)/(`povto'-`povfr')
				gen double p21_p1 = (poor1h - `povfr')/(`povto'-`povfr')
			}
			if "`decomp'"=="absolute" {
				gen double p2_p21 = `povto' - poor1h
				gen double p21_p1 = poor1h - `povfr'
			}
			qui su p2_p21
			local p2_p21 = 100*r(mean)
			qui su p21_p1
			local p21_p1 = 100*r(mean)
		}		
	}
	
	qui if "`method'"=="logit" {
		use `dataori', clear		
		qui xtlogit `poor' `okvarlist' `weight' if `by'==`from', i(`grvar')
		scalar n_m = r(N)
		mat b= e(b)
		mat V= J(1,1,.)
		scalar varu= e(sigma_u)^2
		mat V[1,1]= varu
		scalar r2_m = .
		set seed `seed'
		qui forv i= 1/`rep'  {
			clear
			drawnorm __ut, n(`nsdata') cov(V) double			
			gen __obid= _n
			sort __obid			
			merge 1:1 __obid using `datatoxb'
			drop _m 				
			*USE POVERTY LINE IN 1ST PERIOD
			gen double poor1= invlogit(__xb + __ut)
 
			svyset `cluster' [w= `wtstats'], strata(`strata')  
			svy: mean poor1
			mat poor1h= e(b)
			mat poor1h_var= e(V)
			mat all = nullmat(all) \ `i', poor1h[1,1], poor1h_var[1,1]
			noisily _dots `i' 0
		}
		clear
		mat colnames all = rep poor1h poor1h_var
		svmat all, names(col)
		
		qui su poor1h
		local pov_imp = r(mean)*100 
		scalar seexp= r(Var)/r(N) 
		qui su poor1h_var
		local se2 = (r(mean)+ seexp)^0.5*100 
		
		qui if "`decomp'"~="" {
			if "`decomp'"=="relative" {
				gen double p2_p21 = (`povto' - poor1h)/(`povto'-`povfr')
				gen double p21_p1 = (poor1h - `povfr')/(`povto'-`povfr')
			}
			if "`decomp'"=="absolute" {
				gen double p2_p21 = `povto' - poor1h
				gen double p21_p1 = poor1h - `povfr'
			}
			qui su p2_p21
			local p2_p21 = 100*r(mean)
			qui su p21_p1
			local p21_p1 = 100*r(mean)
		}		
	}

	dis _n "Method: `method'"
	dis "Imputed poverty estimate (%) is `: dis %9.2f `pov_imp''"
	dis "Imputed poverty standard error (%) is `: dis %9.2f `=`se2'''"
	if "`decomp'"~="" {
		dis "Decomposition due to changes in the estimated coefficients (`decomp'): `: dis %9.2f `p2_p21''"
		dis "Decomposition due to changes in the x characteristics (`decomp'): `: dis %9.2f `p21_p1''"
	}
	
	// Wald test
	qui if "`wald'"=="wald" {
		use `dataori', clear 	
		tempname dy
		su `by', meanonly
		local ymax = r(max)
		gen `dy' = `by'==`ymax'
		local dylist
		foreach var of local okvarlist {
			tempname dy`var'
			gen `dy`var'' = `var'*`dy'
			local dylist "`dylist' `dy`var''"
		}
		reg `lhs' `okvarlist' `dy' `dylist'
		testparm `dy' `dylist'
		noisily dis "Walt test: F = `: dis %9.2f `r(F)'', and p = `: dis %9.2f `r(p)''"
		local F = r(F) 
		local p = r(p) 
		local df_r = r(df_r)
		local df = r(df)
	}
	ereturn clear
	ereturn local cmdline = "`cmdline'"
	ereturn scalar pov_imp = `pov_imp' 
	ereturn scalar pov_var = `se2'^2
	//ereturn scalar N = n_m 
	ereturn scalar r2 = r2_m 		 
	ereturn scalar N1 = `nfdata'
	ereturn scalar N2 = `nsdata'
	if "`decomp'"~="" {
		ereturn scalar p2_p21 = `p2_p21'
		ereturn scalar p21_p1 = `p21_p1'
	}
	if "`wald'"=="wald" {
		ereturn scalar F = `F'
		ereturn scalar p = `p' 
		ereturn scalar df_r = `df_r'
		ereturn scalar df = `df'
	}
	restore
end
