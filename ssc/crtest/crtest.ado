*! version 1.2 (25 November 2003)		Joao Pedro Wagner de Azevedo
* version 1.1  (19 November 2003)
* version 1.0 (15 July 2003)
* NJC hacks 15 July 2003
* version 0.7 6/6/03 		

program define crtest, rclass

	version 7.0
	tempvar sample tmp new 
	tempname b valnum rcount nxtrow coef output C testn 
		
	*-> confirm mlogit

	if "`e(cmd)'" != "mlogit" {
		di _n in y "crtest" in r " only works after " in y "mlogit"
		exit 498 
	}
	
	*-> get dependent variable from last mlogit

		local depvar = e(depvar)

	*-> get regressors from last mlogit

		matrix `coef' = e(b)
		local cols = colsof(`coef')
		local regs = `cols' / (e(k_cat) - 1)
		matrix `b' = `coef'[1, 1..`regs']
		local rhs : colnames(`b')
		local rhs : subinstr local rhs "_cons" ""
	
	*-> get outcome labels from last mlogit 
	* This section uses the Stata ado file _pecats from J. Scott Long and 
	* Jeremy Freese
	
		_pecats
		local catnms8 "`r(catnms8)'"
				
	*-> get other variables from last mlogit
	
		local ll = e(ll)
		local numcasts = e(k_cat)
		local df = e(df_m) / (e(k_cat) - 1) 

	
	*-> get weight info from last mlogit
	
		if "`e(wtype)'" != "" {
			local wtis "[`e(wtype)'`e(wexp)']"
			local wexp2 "`e(wexp)'"
		}

	*-> check that estimation sample matches n from regression
	
		quietly { 
			generate `sample' = e(sample)
			
			if "`e(wtype)'" == "" | "`e(wtype)'" == "aweight" /* 
				*/ | "`e(wtype)'" == "pweight" {
				count if `sample'
				scalar `testn' = r(N)
			}
			else if "`e(wtype)'" == "fweight" | /* 
				*/ "`e(wtype)'" == "iweight" {
				local wtexp = substr("`e(wexp)'", 3, .)
				gen `tmp' = (`wtexp') * `sample'
				su `tmp', meanonly
				scalar `testn' = round(r(sum),1)
			}
		}	
			
		if e(N) ~= `testn' {
			di  _n in r "data has been altered since " /*
			*/ in y "mlogit" in r " was estimated"
			exit 459 
		}

	*-> check number of categories
	
	if e(k_cat) == 2 {
		di _n in r "Cramer-Ridder test requires at least 3 dependent categories"
		exit 148 
	}

	*-> output column names
	
	mat `output' = (1, 1, 1, 1) 
	mat colnames `output' = "ln L" "ln Lr" LR "P>chi2"

	*-> reference for test
	
	qui tabulate `depvar' if `sample', matrow(`valnum') matcell(`rcount')

	*-> get the highest scalar of the valnum matrix

	local nrows = rowsof(`valnum')
	
	* grab values 
	local c = `valnum'[1,1] 
	forval i = 2 / `nrows' {
		local c = max(`c', `valnum'[`i',1]) 
	}
               
	*->    cycle through all pairs of outcomes with mlogit without weights
	
if "`e(wtype)'" == "" {
	
	gen `new' = 0 
	
	quietly forval count1 = 1 / `numcasts' {
		tempname ccount1
		local c2 = `count1' + 1
			
		forval count2 = `c2' / `numcasts'  {
			tempname ccount2 adj_`count1'_`count2' 
			tempname LR_`count1'_`count2' 
			
			replace `new' = `depvar'
			replace `new' = `c' + 1 if /*
				*/ `depvar'   == `valnum'[`count1', 1] /*
				*/ | `depvar' == `valnum'[`count2', 1]
			mlogit `new' `rhs' if `sample' 
			local llp = e(ll)
			scalar `ccount1' = `rcount'[`count1', 1]
			scalar `ccount2' = `rcount'[`count2', 1]
			scalar `adj_`count1'_`count2'' = /* 
        */ `ccount1' * ln(`ccount1') + `ccount2' * ln(`ccount2') /*
	*/ -(`ccount1' + `ccount2') * ln(`ccount1'+ `ccount2')
			local llr = `llp' + `adj_`count1'_`count2'' 
			scalar `LR_`count1'_`count2'' =  2 * (`ll' - `llr')
			local chi2 = `LR_`count1'_`count2''
			local pval = chi2tail(`df', `LR_`count1'_`count2'')
			local s1`count1'_`count2' : word `count1' of `catnms8'
                	local s2`count1'_`count2' : word `count2' of `catnms8'
			mat `nxtrow'  = (`ll', `llr', `chi2', `pval')
			mat roweq `nxtrow' = "`s1`count1'_`count2''"
			mat rownames `nxtrow' = "`s2`count1'_`count2''"
			mat `output' = `output' \ `nxtrow' 
		}
	}
	*-> print output 

	di _n in g "**** Cramer-Ridder test for combining outcome categories"
	di _n in g /*
	*/ "Ho: Candidates for pooling have the same regressor coefficients "
	di in g "    apart from the intercept"

	matrix `C' = `output'[2..rowsof(`output'),1..4]
	matrix list `C', format(%9.3f) noheader 
	di _n in g /*
	*/ "degrees of freedom for chi-square distribution:  " in w `df'
}



	*->    cycle through all pairs of outcomes with mlogit with weights

if "`e(wtype)'" != "" {
	
	quietly mat colnames `output' = "ln pseudo-L" "ln Lr" LR "P>chi2"
	
	gen `new' = 0 
	
	if _caller() < 8 {
	
	quietly forval count1 = 1 / `numcasts' {
		tempname ccount1
		local c2 = `count1' + 1
		forval count2 = `c2' / `numcasts'  {
			tempname ccount2 adj_`count1'_`count2' 
			tempname LR_`count1'_`count2' 
			replace `new' = `depvar'
			replace `new' = `c' + 1 if /*
				*/ `depvar'   == `valnum'[`count1', 1] /*
				*/ | `depvar' == `valnum'[`count2', 1]
			mlogit `new' `rhs' `wtis' if `sample' 			
			local llp = e(ll)
			svyprop `depvar' if `depvar'==`count1' [pweight=`wexp2']  
			scalar `ccount1' =r(N_pop)
			svyprop `depvar' if `depvar'==`count2' [pweight=`wexp2'] 
			scalar `ccount2' =r(N_pop)
			scalar `adj_`count1'_`count2'' = /* 
        */ `ccount1' * ln(`ccount1') + `ccount2' * ln(`ccount2') /*
	*/ -(`ccount1' + `ccount2') * ln(`ccount1'+ `ccount2')
			local llr = `llp' + `adj_`count1'_`count2'' 
			scalar `LR_`count1'_`count2'' =  2 * (`ll' - `llr')
			local chi2 = `LR_`count1'_`count2''
			local pval = chi2tail(`df', `LR_`count1'_`count2'')
			local s1`count1'_`count2' : word `count1' of `catnms8'
                	local s2`count1'_`count2' : word `count2' of `catnms8'
			mat `nxtrow'  = (`ll', `llr', `chi2', `pval')
			mat roweq `nxtrow' = "`s1`count1'_`count2''"
			mat rownames `nxtrow' = "`s2`count1'_`count2''"
			mat `output' = `output' \ `nxtrow' 
			}
		}
	}

quietly else {
  	
  	version 8
  	svyset `wtis'
		
		forval count1 = 1 / `numcasts' {
			tempname ccount1
			local c2 = `count1' + 1
			forval count2 = `c2' / `numcasts'  {
				tempname ccount2 adj_`count1'_`count2' 
				tempname LR_`count1'_`count2' 
				replace `new' = `depvar'
				replace `new' = `c' + 1 if /*
					*/ `depvar'   == `valnum'[`count1', 1] /*
					*/ | `depvar' == `valnum'[`count2', 1]
				mlogit `new' `rhs' `wtis' if `sample' 			
				local llp = e(ll)
				svyprop `depvar' if `depvar'==`count1' 
				scalar `ccount1' =r(N_pop)
				svyprop `depvar' if `depvar'==`count2'  
				scalar `ccount2' =r(N_pop)
				scalar `adj_`count1'_`count2'' = /* 
	        */ `ccount1' * ln(`ccount1') + `ccount2' * ln(`ccount2') /*
		*/ -(`ccount1' + `ccount2') * ln(`ccount1'+ `ccount2')
				local llr = `llp' + `adj_`count1'_`count2'' 
				scalar `LR_`count1'_`count2'' =  2 * (`ll' - `llr')
				local chi2 = `LR_`count1'_`count2''
				local pval = chi2tail(`df', `LR_`count1'_`count2'')
				local s1`count1'_`count2' : word `count1' of `catnms8'
	                	local s2`count1'_`count2' : word `count2' of `catnms8'
				mat `nxtrow'  = (`ll', `llr', `chi2', `pval')
				mat roweq `nxtrow' = "`s1`count1'_`count2''"
				mat rownames `nxtrow' = "`s2`count1'_`count2''"
				mat `output' = `output' \ `nxtrow' 
			}
		}
	}
	
	

	*-> print output 
	
        di _n in g "**** Cramer-Ridder test for combining outcome categories"
        di _n in g /*
        */ "Ho: Candidates for pooling have the same regressor coefficients "
        di in g "    apart from the intercept"
	
	matrix `C' = `output'[2..rowsof(`output'),1..4]
	matrix list `C', format(%9.3f) noheader 
	di _n in g /*
	*/ "degrees of freedom for chi-square distribution:  " in w `df'
	di _n in y "crtest uses the " in r e(crittype) in y " for estimations with pweight"
	
}




end

