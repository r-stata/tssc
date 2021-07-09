*! NJC 2.0.0 31 March 2004
* 1.2.0 1 August 2001 
* 1.1.0 3 October 1996
program circvm, sort 
        version 8.0
        syntax varlist(numeric) [if] [in] [ , BY(varname) ] 

	tokenize `varlist'
	local nvars : word count `varlist'
	
        if `nvars' > 1 & "`by'" != "" {
                di as err "too many variables specified"
                exit 103
        }

	marksample use, novarlist 

	qui count if `use' 
	if r(N) == 0 error 2000

	if "`by'" != "" local which "        Group " 
	else local which "     Variable "
	// cond() strips leading spaces
	
	di _n as txt "`which'{c |}   Obs"  ///
	    _col(26) "Mean"                ///
            _col(32) "Strength"            ///
	    _col(45) "Kappa" 

	di as txt " {hline 13}{c +}{hline 34}"

        tempvar touse group

        qui foreach v of local varlist {
                mark `touse' `if' `in'
                markout `touse' `v'

                bysort `touse' `by' : gen `group' = _n == 1 if `touse'
                replace `group' = sum(`group')
                local max = `group'[_N]
		
                forval j = 1/`max' { 
                        Vonmises `v' if `group' == `j'
                        if "`by'" != "" {
                                local name = `by'[_N]
                                local bylab : value label `by'
                                if "`bylab'" != "" {
                                        local name : label `bylab' `name'
                                }
                        }
                        else local name "`v'"
                        if length("`name'") > 12 {
				if "`by'" == "" { 
					local name = abbrev("`name'",12) 
				} 	
                                else local name = substr("`name'",1,12) + "+"
                        }
                        local skip = 13 - length("`name'")
 
                        noi di _skip(`skip') as txt "`name' {c |}" as res ///
			%6.0f  `r(N)'                                     /// 
                        %8.1f  `r(vecmean)'                               /// 
			%10.3f `r(vecstr)'                                /// 
                        %10.3f `r(kappa)' 
                }

                drop `touse' `group'
        }
end

* fit von Mises to circular data
program Vonmises, rclass      
	version 8.0
	syntax varname(numeric) [if] [in] 
	marksample touse
	tempvar xsum ysum
	tempname vecmean S C r kappa kappabc

	sort `touse' 
	qui count if `touse'
	local N = r(N)
	return scalar N = `N' 
	
        local first = _N - `N' + 1 
	qui gen double `xsum' = sum(sin((`varlist'*_pi)/180)) in `first'/l 
	qui gen double `ysum' = sum(cos((`varlist' * _pi)/180)) in `first'/l
	scalar `S' = `xsum'[_N] 
	scalar `C' = `ysum'[_N] 
    	scalar `vecmean' = atan(`xsum'[_N]/`ysum'[_N]) * (180/_pi)
	
	// Stata atan routine takes a single argument
	// and gives the wrong answer in three out of four quadrants 
	if `C' < 0 scalar `vecmean' = `vecmean' + 180
	else if `S' < 0 & `C' > 0 scalar `vecmean' = `vecmean' + 360
	else if `S' == 0 & `C' == 0 scalar `vecmean' = . 
		
	return scalar vecmean = `vecmean'
    
	scalar `r' = sqrt((`S')^2 + (`C')^2) / `N' 
	return scalar vecstr = `r'

	if `r' < 0.53 scalar `kappa' = 2 * `r' + `r'^3 + 5 * `r'^5 / 6
	else if `r' < 0.85 scalar `kappa' = -0.4 + 1.39 * `r' + 0.43 / (1 - `r')
	else if `r' >= 0.85 scalar `kappa' = 1 / (`r'^3 - 4 * `r'^2 + 3 * `r')
    	return scalar kappa = `kappa'
    
	if `N' <= 15 {
        	if `kappa' < 2 {
			scalar `kappabc' = max(0, `kappa' - 2 / (`N' * `kappa')) 
		}
		else scalar `kappabc' = `kappa' * ((`N' - 1)^3) / (`N'^3 + `N')
        	return scalar kappabc = `kappabc'
	}
end

