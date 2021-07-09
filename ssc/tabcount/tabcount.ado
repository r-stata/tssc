*! NJC 2.0.2 17 Sept 2004 	
* NJC 2.0.1 7 Sept 2004 	
* NJC 2.0.0 20 June 2003 	
program tabcount, byable(recall) 
	syntax varlist(max=7) [if] [in] [fweight iweight/] ,     /// 
	[ v(str asis) v1(str asis) v2(str asis) v3(str asis)     ///
	  v4(str asis) v5(str asis) v6(str asis) v7(str asis)    ///
          c(str asis) c1(str asis) c2(str asis) c3(str asis)     ///
	  c4(str asis) c5(str asis) c6(str asis) c7(str asis)    ///
	  MATrix(str) replace zero MISSing freq(str) * ]   

	quietly {
		tokenize `varlist' 
		local nvars : word count `varlist'

		if `nvars' > 2 & "`matrix'" != "" { 
			di as err "matrix() not allowed with `nvars' variables"
			exit 198 
		} 	

		if _by() & "`matrix'" != "" { 
			di as err "matrix() may not be combined with by:"
			exit 198 
		}	
		
		if _by() & "`replace'" != "" { 
			di as err "replace may not be combined with by:"
			exit 198 
		}	
	
		if "`missing'" != "" local novarlist "novarlist"
		marksample touse, strok `novarlist'  
		count if `touse' 
		if r(N) == 0 error 2000 

		// v() is a synonym for v1() with one variable 
		if `nvars' == 1 & `"`v1'"' == "" { 
			local v1 `"`v'"'
		} 	
		
		forval i = 1/`nvars' { 
			if `"`v`i''"' != "" local vlist "`vlist'`i' "  
		} 
		
		// c() is a synonym for c1() with one variable 
		if `nvars' == 1 & `"`c1'"' == "" { 
			local c1 `"`c'"'
		} 	
		
		forval i = 1/`nvars' { 
			if `"`c`i''"' != "" local clist "`clist'`i' "  
		} 

		local inter : list vlist & clist 
		if "`inter'" != "" { 
			di as err "cannot specify both v?() and c?()" 
			exit 198 
		}

		local union : list vlist | clist 
		local union : list sort union 
		local nopts : list sizeof union 

		if `nopts' != `nvars' { 
			if `nvars' > 1 local s "s" 
			di as err "must specify `nvars' v?() or c?() option`s'"
			exit 198 
		} 
			
		local nc = 1 
		foreach i of local vlist { 
			capture numlist "`v`i''", miss
			if _rc == 0 local v`i' "`r(numlist)'" 
			local nc = `nc' * `: word count `v`i''' 
		} 

		foreach i of local clist { 
			local nc = `nc' * `: word count `c`i''' 
		} 
		
		if `nc' > _N { 
			preserve 
			set obs `nc'
		} 
		else if "`replace'" != "" { 
			preserve
		} 	
		
		tempvar toshow wt 
		gen long `toshow' = .
		label var `toshow' "Freq."

		local j = 1 
		local cond "`touse'" 
		foreach i of local union { 
			tempvar V`i' 
			
			if `"`v`i''"' != "" { 
				Repeat1 `V`i'', values(`v`i'') block(`j')
				local vallbl : value label ``i'' 
				if "`vallbl'" != "" label val `V`i'' `vallbl' 
				local cond "`cond' & ``i'' == `V`i''[@]" 
			} 	
			else {
				tempvar C`i'  
				Repeat2 `V`i'' `C`i'', cond(`c`i'') block(`j') 
				local cond "`cond' & ``i'' `V`i''" 
				local Clist "`Clist' `V`i''" 
				local V`i' "`C`i''" 
			}	
			
			local Union "`Union' `V`i''" 
			_crcslbl `V`i'' ``i'' 
			local j = `j' * `r(nvals)' 
		} 

		if "`exp'" == "" local exp 1 
		gen `wt' = `exp' 
		
		forval i = 1/`nc' { 
			local COND : subinstr local cond "[@]" "[`i']", all  
			
			foreach C of local Clist {
				local COND : ///
				subinstr local COND "`C'" `"`= `C'[`i']'"' 
			}
		
			su `wt' if `COND', meanonly 
			replace `toshow' = r(sum) in `i' 
		} 
		
		if "`zero'" == "" replace `toshow' = . if `toshow' == 0 
	}	

	tokenize `Union' 
	local vars "`1' `2' `3'"
	if `nvars' >= 4 local byvars "by(`4' `5' `6' `7')"

	tabdisp `vars' in 1/`nc' , c(`toshow') `byvars' `options'

	quietly { 
		if "`matrix'`replace'" != "" { 
			replace `toshow' = 0 if missing(`toshow') 
		} 
		
		if "`matrix'" != "" { 
			Tomatrix `1' `2' `toshow' in 1/`nc', ///
			matrix(`matrix') `missing' 
		} 	
		
		if "`replace'" != "" { 
			if "`freq'" == "" { 
				capture confirm new variable _freq
				if _rc == 0 local freq "_freq"
				else {
					di as err "_freq already defined: " ///
			"use freq() option to specify frequency variable"
					exit 110
				}
			}
			else confirm new variable `freq'
		
			local i = 1 
			foreach v of local varlist { 
				drop `v' 
				rename ``i++'' `v' 
			}	
			rename `toshow' `freq' 
			keep in 1/`nc' 
			keep `varlist' `freq'
			compress 
			restore, not 
		} 	
	}	
end 
	 
program Repeat1, rclass 
* NJC 1.0.0 12 June 2003 
	version 8 
	syntax newvarlist(max=1), Values(str asis) [ Block(int 1) ]

	qui { 
		tempvar obs which 
		gen long `obs' = _n  
	
		capture numlist "`values'", miss 
		local isstr = _rc  
		if `isstr' { 
			gen `varlist' = "" 
			local nvals : word count `values' 
			tokenize `"`values'"' 
		} 
		else { 
			gen double `varlist' = .
			local nvals : word count `r(numlist)' 
			tokenize "`r(numlist)'" 
		} 
		
		gen long `which' = 1 + int(mod((`obs' - 1) / `block', `nvals'))

		if `isstr' { 
			forval i = 1 / `nvals' { 
				replace `varlist' = "``i''" if `which' == `i'  
			}
		}	
		else { 	
			forval i = 1 / `nvals' { 
				replace `varlist' = ``i'' if `which' == `i' 
			} 	
		}
	}	
	return local nvals = `nvals' 
end

program Repeat2, rclass 
* NJC 1.0.0 12 June 2003 
	version 8 
	syntax newvarlist(max=2), Cond(str asis) [ Block(int 1) ]

	qui { 
		tokenize `varlist' 
		args newvar which 
		gen `newvar' = ""
		local nvals : word count `cond' 
		gen long `which' = 1 + int(mod((_n - 1) / `block', `nvals'))
		
		tokenize `"`cond'"' 
		local oper "> < ! ~" 
		
		forval i = 1 / `nvals' {
			label def `which' `i' "``i''", modify 
			capture confirm number ``i'' 
			if _rc == 0 { 
				local `i' "== ``i''"
				replace `newvar' = "``i''" if `which' == `i'  
			}
			else { 
				local char = substr(trim(`"``i''"'),1,1) 
				if `: list char in oper' { 
					replace `newvar' = `"``i''"' if `which' == `i'
				}	
				else replace `newvar' = ///
				`" == `"``i''"'"' if `which' == `i' 
			}	
		}
		label val `which' `which'   
	}	
	return local nvals = `nvals' 
end

program Tomatrix, sort  
	syntax varlist(min=1 max=3) [if] [in] , Matrix(str) [ missing ] 
	
	marksample touse, novarlist
	qui count if `touse' 
	if r(N) == 0 error 2000 
	local N = r(N) 

	tokenize `varlist' 
	local nvars : word count `varlist' 

	if `nvars' == 3 { 
		args row col val 
		qui levels `row' if `touse', local(lr) `missing' 
		local nr : word count `lr' 
		qui levels `col' if `touse', local(lc) `missing' 
		local nc : word count `lc'
		
		if `N' != (`nr' * `nc') { 
			di as err "`nr' X `nc' matrix expected; `N' values"
			exit 498 
		}
	} 
	else if `nvars' == 2 { 
		args row val 
		qui levels `row' if `touse', local(lr) `missing' 
		local nr : word count `lr'
		local nc = 1 
		if `N' != (`nr' * `nc') { 
			di as err "`nr' X `nc' matrix expected; `N' values"
			exit 498 
		}
	
	} 
	else if `nvars' == 1 { 
		local nr = `N' 
		local nc = 1 
	} 

	matrix `matrix' = J(`nr',`nc',0) 

	tempvar obs 
	sort `touse' `row' `col' `_sortindex' 
	qui gen long `obs' = _n if `touse'
	su `obs', meanonly 
	local k = `r(min)' 
	forval i = 1/`nr' { 
		forval j = 1/`nc' { 
			matrix `matrix'[`i',`j'] = `val'[`k++'] 
		}
	} 

	if `nvars' >= 2 { 
		capture matrix rownames `matrix' = `lr' 
		if _rc { 
			numlist "1/`nr'" 
			matrix rownames `matrix' = `r(numlist)'
		} 	
	}
	if `nvars' == 3 { 
		capture matrix colnames `matrix' = `lc'
		if _rc { 
			numlist "1/`nc'" 
			matrix colnames `matrix' = `r(numlist)'
		} 
	}	
end 
	
