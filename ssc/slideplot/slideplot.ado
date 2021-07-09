program slideplot, sortpreserve 
*! NJC 1.0.0 30 April 2003 
	version 8 
	
	// bar or hbar 
	gettoken plottype 0 : 0 
	local plotlist "bar hbar" 
	if !`: list plottype in plotlist' { 
		di ///
		"{p}{txt}syntax is {inp:slideplot} {it:plottype varlist} " /// 
		"... e.g. {inp: slideplot hbar answer} ...{p_end}" 
		exit 198 
	}

	syntax varlist [if] [in] [fweight aweight/] , ///
	POSitive(str asis) NEGative(str asis) [ by(varlist max=2) PERCent * ]

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
		tempvar total diff tag 
		
		// one variable: count distinct values 
		if `nvars' == 1 { 
			gen `total' = 1       
			if `isnum' { 
				foreach v of numlist `positive' {
					tempvar p 
					gen `p' = `varlist' == `v' 
					local ps "`ps' `p'" 
					local l : label (`varlist') `v' 
					local plabs `"`plabs' `"`l'"'"' 
				}
				local positive `"`plabs'"' 
				foreach v of numlist `negative' { 
					tempvar n 
					gen `n' = -1 * (`varlist' == `v')
					local ns "`ns' `n'" 
					local l : label (`varlist') `v' 
					local nlabs `"`nlabs' `"`l'"'"' 
				} 
				local negative `"`nlabs'"' 
			} 

			else { 
				foreach v of local positive {
					tempvar p 
					gen `p' = `varlist' == "`v'" 
					local ps "`ps' `p'" 
				} 
				foreach v of local negative {
					tempvar n 
					gen `n' = -1 * (`varlist' == "`v'") 
					local ns "`ns' `n'" 
				} 
			} 
		}
		
		// two or more variables: sum values 
		else {
			generate `total' = 0 
			foreach v of local varlist { 
				replace `total' = `total' + `v' 
			} 	
			foreach v of local positive { 
				tempvar p
				gen `p' = `v' 
				local ps "`ps' `p'" 
				local l : variable label `v' 
				if `"`l'"' == "" local l "`v'" 
				local plabs `"`plabs' `"`l'"'"' 
			} 
			local positive `"`plabs'"' 
			foreach v of local negative { 
				tempvar n 
				gen `n' = -`v' 
				local ns "`ns' `n'"                 
				local l : variable label `v' 
				if `"`l'"' == "" local l "`v'" 
				local nlabs `"`nlabs' `"`l'"'"' 
			} 
			local negative `"`nlabs'"' 
		} 	
	
		// apply weights and get sums (using any -by()-) 
		if "`exp'" == "" local exp 1 
		sort `touse' `by'
		by `touse' `by': replace `total' = sum(`exp' * `total')
		foreach v of varlist `ps' `ns' { 
			by `touse' `by': replace `v' = sum(`exp' * `v')
			if "`percent'" != "" replace `v' = 100 * `v' / `total' 
		} 	

		// we only look at the last of each group 
		by `touse' `by': gen byte `tag' = _n == _N & `touse'
	}

	// prepare graph
	if "`by'" != "" { 
		foreach v of varlist `by' { 
			local overs "`overs'over(`v') " 
		}
	}	

	local nn : word count `ns' 
	local nv : word count `ns' `ps'  
	
	// graph will stack out from first-named; so reverse this 
	local j = 1
	forval i = `nn'(-1)1 { 
		local NS `"`NS' `:word `i' of `ns''"'
		local labels ///
		`"`labels' label(`j++' `"`: word `i' of `negative''"')"' 
	}	
	
	foreach g of local positive { 
		local labels `"`labels' label(`j++' `"`g'"')"' 
	} 
	
	if "`percent'" != "" local ytitle "ytitle(percent)" 
	
	numlist "`nn'/1 `=`nn' + 1'/`nv'" 
	local order "order(`r(numlist)')" 

	graph `plottype' (asis) `NS' `ps' if `tag', ///
	stack `overs' legend(`labels' `order') `ytitle' `options' 	
end 
		
