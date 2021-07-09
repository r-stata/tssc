*! 1.0.0 NJC 25 October 2017 
program niceloglabels 
	version 11 
	capture { 
                /// fudge() undocumented 
		syntax varname(numeric) [if] [in] ///
		, Local(str) Style(str) [ Powers Fudge(real 1)] 

		marksample touse 
		count if `touse' 	
		if r(N) == 0 exit 2000 
	} 
	if _rc { 
		// syntax #1 #2 , Local(str) Style(str) [ Powers Fudge(real 1) ] 
		if _N < 2 { 
			preserve 
			quietly set obs 2 
		}

		gettoken first 0 : 0, parse(" ") 
		gettoken second 0 : 0, parse(" ,") 
		syntax , Local(str) Style(str) [ Powers Fudge(real 1) ] 
		
		tempvar varlist touse 
		gen `varlist' = cond(_n == 1, `first', `second') 
		gen byte `touse' = _n <= 2 
	}	

	local style = trim(subinstr("`style'", " ", "", .)) 
	if !inlist("`style'", "1", "13", "15", "125", "147", "2") { 
		di as err "invalid style: choices are 1 13 15 125 147 2" 
		exit 498 
	} 
	
	tempname dmin dmax 
	su `varlist' if `touse', meanonly 
	scalar `dmin' = r(min) 
	scalar `dmax' = r(max) 

	if `dmin' == 0 { 
		di as err "zero values present" 
		exit 498 
	}
	else if `dmin' < 0 { 
		di as err "negative values present" 
		exit 498 
	} 
	else if (`dmax' - `dmin') == 0 { 
		di as err "minimum and maximum equal?" 
		exit 498 
	} 
	
	tempvar logx 
	quietly {
		if "`style'" == "2" {
			gen double `logx' = log10(`varlist')/log10(2) if `touse'
		}
		else gen double `logx' = log10(`varlist') if `touse' 
	}

	su `logx', meanonly 
	// default is to bump (minimum, maximum) (down, up) by 1%
	// otherwise we can be trapped by precision problems, 
	// e.g. floor(log10(1000)) is returned as 2 not 3 
	local lmin = ceil(r(min) * (100 - `fudge')/100) 
	local lmax = floor(r(max) * (100 + `fudge')/100) 

	local p = "`powers'" != "" 

	if "`style'" == "2" { 
		forval n = `lmin'/`lmax' { 
			local this = 2^`n' 
			if `p' local this `" `this' "2{sup:`n'}" "'  
			local all `all' `this' 
		} 

	}
	else if "`style'" == "1" { 
		forval n = `lmin'/`lmax' { 
			local this = 10^`n' 
			if `p' local this `" `this' "10{sup:`n'}" "'  
			local all `all' `this' 
		} 
	}
	else if inlist("`style'", "13", "15") { 
		local s = substr("`style'", -1, 1) 

		local nm1 = `lmin' - 1 
		if `dmin' <= `s' * 10^`nm1' & `dmax' >= `s' * 10^`nm1' { 
			local this = `s' * 10^`nm1' 
			if `p' local this `" `this' "`s'x10{sup:`nm1'}" "' 
			local all `this' 
		} 

		forval n = `lmin'/`lmax' { 
			local this = 10^`n' 
			if `p' local this `" `this' "10{sup:`n'}" "' 
	
			if `dmax' >= `s' * 10^`n' { 		 
				local that = `s' * 10^`n' 
				if `p' local that `" `that' "`s'x10{sup:`n'}" "' 
			} 
			else local that 
	 
			local all `all' `this' `that' 
		} 
	} 
	else if "`style'" == "125" { 
		local nm1 = `lmin' - 1 
		if `dmin' <= 2 * 10^`nm1' & `dmax' >= 2 * 10^`nm1' { 
			local this = 2 * 10^`nm1' 
			if `p' local this `" `this' "2x10{sup:`nm1'}" "' 
			local all `this' 
		}

		if `dmin' <= 5 * 10^`nm1' & `dmax' >= 5 * 10^`nm1' { 
			local this = 5 * 10^`nm1' 
			if `p' local this `" `this' "5x10{sup:`nm1'}" "' 
			local all `all' `this' 
		} 

		forval n = `lmin'/`lmax' { 
			local this = 10^`n' 
			if `p' local this `" `this' "10{sup:`n'}" "' 

			if `dmax' >= 2 * 10^`n' { 
				local that = 2 * 10^`n' 
				if `p' local that `" `that' "2x10{sup:`n'}" "' 
			}
			else local that 

 			if `dmax' >= 5 * 10^`n' { 
				local tother = 5 * 10^`n' 
				if `p' local tother `" `tother' "5x10{sup:`n'}" "' 			
			}
			else local tother 
			 
			local all `all' `this' `that' `tother'
		}
	} 
	else if "`style'" == "147" { 
		local nm1 = `lmin' - 1 
		if `dmin' <= 4 * 10^`nm1' & `dmax' >= 4 * 10^`nm1' { 
			local this = 4 * 10^`nm1' 
			if `p' local this `" `this' "4x10{sup:`nm1'}" "' 
			local all `this' 
		}

		if `dmin' <= 7 * 10^`nm1' & `dmax' >= 7 * 10^`nm1'  { 
			local this = 7 * 10^`nm1' 
			if `p' local this `" `this' "7x10{sup:`nm1'}" "' 
			local all `all' `this' 
		} 

		forval n = `lmin'/`lmax' { 
			local this = 10^`n' 
			if `p' local this `" `this' "10{sup:`n'}" "' 

			if `dmax' >= 4 * 10^`n' { 
				local that = 4 * 10^`n' 
				if `p' local that `" `that' "4x10{sup:`n'}" "' 
			}
			else local that 

 			if `dmax' >= 7 * 10^`n' { 
				local tother = 7 * 10^`n' 
				if `p' local tother `" `tother' "7x10{sup:`n'}" "' 
			}
			else local tother 
		 
			local all `all' `this' `that' `tother'
		}
	} 

	di `"`all'"'  
	c_local `local' `"`all'"'  
end 
		
