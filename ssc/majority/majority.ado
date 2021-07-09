program majority, sortpreserve 
*! NJC 1.0.0 30 April 2003 
	version 8 
	
	syntax varlist [if] [in] [fweight aweight/] , ///
	POSitive(str asis) NEGative(str asis) /// 
	[ by(varlist) format(str) PERCent Generate(str) * ]

	// start error checks 

	marksample touse, strok  
	qui count if `touse' 
	if r(N) == 0 error 2000 
	
	local nvars : word count `varlist'  
	// arguments should be either a numeric varlist 
	if `nvars' > 1 { 
		confirm numeric var `varlist' 
	}
	// or a numlist or a list of string values 
	else { 
		capture numlist "`positive' `negative'"
		if _rc == 0 { 
			local isnum 1
			numlist "`positive'" 
			local positive "`r(numlist)'"
			numlist "`negative'" 
			local negative "`r(numlist)'"
		}
		else local isnum 0 
	}	
	/// and should not overlap 
	local both : list positive & negative 
	if `: word count `both'' { 
		di as err `"`both' both positive and negative"' 
		exit 498 
	} 	

	quietly { 
		tempvar Pos Neg total maj tag 

		// get positive, negative and total 
		gen `Pos' = 0 
		gen `Neg' = 0

		if `nvars' == 1 { 
			gen `total' = 1       
			if `isnum' { 
				foreach v of numlist `positive' { 
					replace `Pos' = 1 if `varlist' == `v' 
				}
				foreach v of numlist `negative' { 
					replace `Neg' = 1 if `varlist' == `v' 
				} 
			} 
			else { 
				foreach v of local positive { 
					replace `Pos' = 1 if `varlist' == "`v'" 
				} 
				foreach v of local negative { 
					replace `Neg' = 1 if `varlist' == "`v'" 
				} 
			} 
		} 
		else {
			generate `total' = 0 
			foreach v of local varlist { 
				replace `total' = `total' + `v' 
			} 	
			foreach v of local positive { 
				replace `Pos' = `Pos' + `v' 
			} 
			foreach v of local negative { 
				replace `Neg' = `Neg' + `v' 
			} 
		} 	
		
		// apply weights and get sums (using any -by()-) 
		if "`exp'" == "" local exp 1 
		bysort `touse' `by': replace `Pos' = sum(`exp' * `Pos') 
		bysort `touse' `by': replace `Pos' = `Pos'[_N] 
		by `touse' `by': replace `Neg' = sum(`exp' * `Neg')
		by `touse' `by': replace `Neg' = `Neg'[_N] 
		gen `maj' = `Pos' - `Neg'
		by `touse' `by': replace `total' = sum(`exp' * `total')   
		by `touse' `by': replace `total' = `total'[_N] 
		
		char `total'[varname] "total" 	
		char `Pos'[varname] "positive" 	
		char `Neg'[varname] "negative" 	
		char `maj'[varname] "majority" 

		by `touse' `by': gen byte `tag' = _n == _N & `touse'

		if "`percent'" != "" { 
			replace `Pos' = 100 * `Pos' / `total' 
			replace `Neg' = 100 * `Neg' / `total' 
			replace `maj' = 100 * `maj' / `total' 
		}
		
		if "`format'" == "" { 
			local format = cond("`percent'" == "", "%8.0g", "%3.2f")
		} 	
		format `format' `Pos' `Neg' `maj' 
	} 	

	list `by' `total' `Pos' `Neg' `maj' if `tag', ///
		subvarname noobs `options' 	

	qui if "`generate'" != "" { 
		tokenize `generate'
		if "`4'" != "" { 
			di "{err} too many variables to {inp}generate()"
			exit 198 
		} 
		confirm new var `generate' 
		gen `1' = `maj' if `touse' 
		if "`2'" != "" gen `2' = `Pos' if `touse' 
		if "`3'" != "" gen `3' = `Neg' if `touse' 
	}	
end 
		
