*! NJC 1.0.0 5 March 2004 
program ppplot, sort 
	version 8.0

	gettoken plottype 0 : 0 
	local plotlist "area bar connected dot dropline line scatter spike" 
	if !`: list plottype in plotlist' { 
		di ///
		"{p}{txt}syntax is {inp:ppplot} {it:plottype} ... " /// 
		"... e.g. {inp: ppplot connected} ...{p_end}" 
		exit 198 
	}

	capture syntax varname [if] [in] [fweight aweight/], BY(varname)  ///
	[ MISSing REFerence(str asis) PLOT(str asis) * ]

	if _rc { 
		syntax varlist(min=2 numeric) [if] [in] [fweight aweight/] ///
		[, PLOT(str asis) BY(varname) * ] 
		
		if "`by'" != "" { 
			di as err "by() not supported with two or more variables"
			exit 198 
		}
	}	
	
	marksample touse

	if "`exp'" == "" local exp "1" 
	else {
		capture assert `exp' >= 0 if `touse'
		if _rc {
			di as err "weight assumes negative values"
			exit 402
	        }    
	}

	qui { 
		if "`by'" != "" {
			if "`missing'" == "" markout `touse' `by', strok 
			tempname stub 
			separate `varlist', by(`by') gen(`stub') `missing' short
			local vlist "`r(varlist)'"
			local ref `"`reference'"' 
			if `"`ref'"' != "" { 
				foreach v of local vlist {  
					count if `by' == `ref' & `v' == `varlist' 
					if `r(N)' { 
						local x "`v'" 
						continue, break 
					} 	
				} 
				local vlist : subinstr local vlist "`x'" "" 
				local vlist "`vlist' `x'" 
			}	
		
			sort `touse' `varlist' 
		
			foreach v of local vlist {
				local label : variable label `v' 
				local where = index(`"`label'"', "==") + 3
				local label = substr(`"`label'"', `where', .) 
				label var `v' `"`label'"' 
				format `v' %2.1g 
				by `touse' : replace `v' = sum(`exp' * (`v' < .)) 
				by `touse' `varlist' : replace `v' = `v'[_N] 
				by `touse' : replace `v' = `v' / `v'[_N]
				replace `v' = . if !`touse' 
			}   

			noi twoway `plottype' `vlist', ///
				yla(, ang(h)) xla(0(0.2)1) `options' ///
			|| `plot' 
			// blank 
			
			exit 0 
		}
		else { 
			preserve 
			tempvar data wt 

			tokenize `varlist' 
			local nvars : word count `varlist' 
			forval i = 1/`nvars' { 
				local label`i' : variable label ``i'' 
				if `"`label`i''"' == "" local label`i' "``i''" 
			}	

			gen `wt' = `exp' 

			foreach v of local varlist { 
				local tostack "`tostack' `v' `wt'" 
			} 	
			
			stack `tostack' if `touse', into(`data' `wt') clear 
			separate `data', by(_stack) 
			local vlist "`r(varlist)'" 
			sort `data' 
		
			local i = 1 
			foreach v of local vlist { 
				label var `v' `"`label`i''"' 
				format `v' %2.1g 
				replace `v' = sum(`wt' * (`v' < .)) 
				by `data' : replace `v' = `v'[_N] 
				replace `v' = `v' / `v'[_N]
				local ++i 
			}   

			noi twoway `plottype' `vlist', /// 
				yla(, ang(h)) xla(0(0.2)1) `options' ///
			|| `plot' 
			// blank 
		}
	}		
end
