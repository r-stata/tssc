*! NJC 1.0.1 31 March 2004 
* NJC 1.0.0 20 January 2004 
program circmedian 
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

        di _n as txt "`which'{c |}   Obs"  _col(24) "Median" ///
        _col(32) "Mean deviation" 
        di as txt " {hline 13}{c +}{hline 30}"

        tempvar touse group

        qui foreach v of local varlist {
                mark `touse' `if' `in'
                markout `touse' `v'

                bysort `touse' `by' : gen `group' = _n == 1 if `touse'
                replace `group' = sum(`group')
                local max = `group'[_N]
		
                forval j = 1/`max' { 
                        Med `v' if `group' == `j'
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
                        %8.1f  `r(median)'                                /// 
                        %16.1f `r(meandev)' 
                }

                drop `touse' `group'
        }
end

* median and mean deviation for circular data
program Med, rclass     
	version 8.0
	syntax varname(numeric) [if] [in] 
	marksample touse
	tempvar tag diff dev

	count if `touse' 
	return scalar N = r(N) 

	gen `diff' = .
	gen `dev' = .

	bysort `touse' `varlist' : gen byte `tag' = _n == 1 & `touse'
        sort `tag' `varlist'
	count if `tag'

	local i1 = _N - r(N) + 1 
	forval i = `i1'/`=_N' {  
		local thisval = `varlist'[`i']
		replace `diff' = abs(`varlist' - `thisval') if `touse'
		replace `diff' = min(`diff', 360 - `diff')
		su `diff', meanonly
		replace `dev' = - r(mean) in `i'
	}

	sort `tag' `dev'
	circsu `varlist' if `dev' == `dev'[_N]
	return scalar median `r(vecmean)' 
	local meandev = -`dev'[_N]
	return scalar meandev `meandev'
end
