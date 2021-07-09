*! 1.0.2 MLB 23Jul2007
*! 1.0.1 MLB 15May2007
program define seqlogit_lf
	version 9.2
	/*count number of equations*/
	forvalues i = 1/$S_eqs {
		local xb "`xb' xb`i'"
	}
	args lnf `xb'
		
	/*The numerators*/
	forvalues i = 1/$S_Ntrans {
		local denom`i' "1"
		foreach j of global S_eqstr`i' {
			local denom`i' "`denom`i'' + exp(`xb`j'')"
		}
	}
	/*The likelihood*/	
	forvalues t = 1/$S_Ntrans {
		/*likelihood for the failing transitions*/
		foreach lev of global S_treelevels {
			local ctr`t'choice0 : subinstr global S_tr`t'choice0 " " " | `lev' == ", all
			if (`lev' == `ctr`t'choice0') {
				local ll`lev' "`ll`lev'' + ln(1/(`denom`t''))"
			}
		}
		/*likelihood for the other choises*/
		local end = ${S_Nchoice`t'} -1
		forvalues c = 1/`end' {
			foreach lev of global S_treelevels {
				local ctr`t'choice`c' : subinstr global S_tr`t'choice`c' " " " | `lev' == ", all
				if (`lev' == `ctr`t'choice`c'') {
					local ll`lev' "`ll`lev'' + ln(exp(`xb${S_eqtr`t'c`c'}')/(`denom`t''))"
				}
			}		
		}
	}	
	foreach lev of global S_treelevels {
		gettoken plus ll`lev' : ll`lev', pars("+")
		qui replace `lnf' = `ll`lev'' if $ML_y1==`lev'
	}
end
