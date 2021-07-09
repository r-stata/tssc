*! NJC 2.0.3 28 July 2004
* NJC 2.0.2 6 May 2004 
* NJC 2.0.1 30 March 2004 
* NJC 2.0.0 20 January 2004 
* NJC 1.5.0 15 December 1998
* NJC 1.4.2  27 October 1996
* Wheeler-Watson-Mardia test: Fisher 1993 pp.122-3
program circwwmardia, sort 
        version 8.0
        syntax varlist(numeric) [if] [in] , BY(varname)

	marksample use, novarlist 

	qui count if `use' 
	if r(N) == 0 error 2000
	
	local which "     Variable "
        di _n as txt "`which'{c |}   Obs"  ///
	    _col(29) "W_r"                 ///
            _col(37) "df"                  ///
	    _col(44) "P-value" 
        di as txt " {hline 13}{c +}{hline 35}"

        qui foreach v of local varlist {
	        tempvar touse 
		gen byte `touse' = `use' 
                markout `touse' `v'
		count if `touse' 
	
                if r(N) > 0 { 
			Wwmardia `v' if `touse', by(`by')  
			local name = abbrev("`v'",12) 
	                local skip = 13 - length("`name'")
        	        noi di _skip(`skip') as txt "`name' {c |}" as res ///
			%6.0f  `r(N)'                              ///
                        %10.2f  `r(WWM)'                           ///
                        %7.0f  `r(df)'                             ///
                        %12.3f `r(PWWM)'
              	} 
		
                drop `touse'
        }
end

program Wwmardia, rclass   	
	version 8.0 
	syntax varname [if] , BY(varname)
        tempvar rank cosrank sinrank cossum sinsum
        tempname WWM pval

        marksample touse
        markout `touse' `by', strok
        qui count if `touse'
	local N = r(N) 
	return scalar N = r(N) 
	if `N' == 0 exit 0 

	qui tab `by' if `touse'
        local df = 2 * r(r) - 2
        if `df' <= 0 {
		return scalar WWM = . 
		return scalar df = `df'
		return scalar PWWM = . 
		exit 0 
	} 	

        qui {
                egen `rank' = rank(`varlist') if `touse'
                gen `cosrank' = cos(2 * _pi * (`rank' / `N'))
                gen `sinrank' = sin(2 * _pi * (`rank' / `N'))
                bysort `touse' `by' : gen `cossum' = sum(`cosrank')
                by `touse' `by': gen `sinsum' = sum(`sinrank')
                by `touse' `by': replace `cossum' = `cossum'^2 / _N
                by `touse' `by': replace `sinsum' = `sinsum'^2 / _N
                by `touse' `by': replace `touse' = 0 if _n != _N
                replace `cossum' = sum(`cossum') if `touse'
                replace `sinsum' = sum(`sinsum') if `touse'
        }

        scalar `WWM' = 2 * (`cossum'[_N] + `sinsum'[_N])
        scalar `pval' = chiprob(`df', `WWM')

        return scalar WWM   = `WWM'
        return scalar df    = `df'
        return scalar PWWM = `pval'
end
