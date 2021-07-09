*! NJC 2.0.1 30 March 2004 
* NJC 2.0.0 22 January 2004 
* NJC 1.1.0 15 December 1998
* NJC 1.0.3  27 October 1996
* Two-sample tests for circular data
program circtwosample 
        syntax varlist(numeric) [if] [in] , BY(varname)
	
        marksample use, novarlist 
	markout `use' `by', strok 
	qui count if `use' 
	if r(N) == 0 error 2000

	qui tab `by' if `use'
        if r(r) != 2 {
                di as err "`by' takes on " r(r) " values, not 2"
                exit 450
        }
	
        di _n as txt ///
        "{space 32}Watson    {hline 7} Kuiper {hline 7}"  _n  ///
	"              {c |}   n_1   n_2   U-square        V       k       k*"
        di as txt " {hline 13}{c +}{hline 49}"

        tempvar touse 
	
        qui foreach v of local varlist {
                gen byte `touse' = `use' 
                markout `touse' `v'

                Twosample `v' if `touse', by(`by') 
		
                local name "`v'"
                if length("`name'") > 12 local name = abbrev("`name'",12) 
		local skip = 13 - length("`name'")
		
                noi di _skip(`skip') as txt "`name' {c |}" as res ///
		%6.0f  `r(n1)'                                    /// 
		%6.0f  `r(n2)'                                    /// 
                %11.3f `r(Usquare)'                               /// 
                %9.3f  `r(V)'                                     ///
		%8.3g  `r(k)'                                     ///
		%9.3f  `r(kstar)' 
                
                drop `touse' 
        }
end

program Twosample, rclass sort 
	version 8.0
	syntax varname(numeric) [if] [in] , by(varname) 
	marksample touse

        tempvar cdf1 cdf2 diff diffsq

        qui {
                sort `touse' `by'
		count if `touse'
                local first = _N - r(N) + 1
                count if `touse' & `by' == `by'[`first']
		local by1 = `by'[`first'] 
		local n1 = r(N) 
                count if `touse' & `by' == `by'[_N]
		local by2 = `by'[_N] 
		local n2 = r(N) 
			
                sort `touse' `varlist' `by'
                gen `cdf1' = sum(`by' == `by1') if `touse'
                gen `cdf2' = sum(`by' == `by2') if `touse'
                // adjustment for ties
                by `touse' `varlist' : replace `cdf1' = `cdf1'[_N]
                by `touse' `varlist' : replace `cdf2' = `cdf2'[_N]
                gen `diff' = `cdf1' / `n1' - `cdf2' / `n2'
                gen `diffsq' = `diff'^2

                su `diff', meanonly
                local diffsum = r(sum)
                local V = r(max) - r(min)
                local k = `n1' * `n2' * `V'
                local nmin = min(`n1',`n2')
                local nmax = max(`n1',`n2')
                local nall = `n1' + `n2'
                local kstar = /// 
		`k' * (1 + 0.155 / sqrt(`nmin') + 0.24 / `nmin') ///
                / sqrt(`nmin' * `nmax' * `nall')
		
                su `diffsq', meanonly
                local WU2 = ///
		(`n1' * `n2' / (`nall'^2)) * (r(sum) - ((`diffsum')^2 / `nall'))
        }

        return scalar n1      = `n1'
        return scalar n2      = `n2'
        return scalar Usquare = `WU2'
        return scalar V       = `V'
        return scalar k       = `k'
        return scalar kstar   = `kstar'
end
