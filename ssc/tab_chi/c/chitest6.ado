*! renamed NJC 9 July 2003 
*! 1.5.0 NJC 15 July 2000 
* 1.4.4 NJC 26 January 1999
* 1.4.3  2 Sept 1997
* 1.4.2  13 August 1997
* 1.4.2, 1.4.3 indicate keyboard entry (undocumented option)
* 1.4.1  30 April 1997     save emean in S_7
* 1.4.0  20 December 1996
program def chitest6, rclass 
    version 6.0
    syntax varlist(min=1 max=2) [if] [in] [, nfit(int 0) kb count ] 
    tokenize `varlist'
    local nvars : word count `varlist'

    tempvar obs exp lrchi2
    marksample touse, strok 

    qui if "`count'" != "" { 
    	if `nvars' == 2 { 
		di in r "count option not valid with two variables: " _c 
		di in r "use -tabulate-?" 
		exit 198 
	} 
    	sort `touse' `varlist' 
	by `touse' `varlist' : gen `obs' = _N * (_n == 1) * `touse' 
	replace `touse' = 0 if `obs' == 0 
    } 	
    else qui gen `obs' = `1' 
    
    * degrees of freedom (subtract `nfit')
    qui count if `touse'
    local df = r(N) - 1 - `nfit'
    if `df' < 1 {
        di in r "too few categories"
        exit 149
    }

    qui {

        su `obs' if `touse', meanonly
        local omean = r(mean)
        local osum = r(sum)
        local omin = r(min)

        * check observed frequencies
        if `omin' < 0 {
            di in r "observed frequencies must be zero or positive"
            exit 499
        }
        capture assert `obs' == int(`obs') if `touse'
        if _rc == 9 {
            di in r "observed frequencies must be integers"
            exit 499
        }

        if `nvars' == 2 { gen `exp' = `2' } 
	else gen `exp' = `omean'  

        su `exp' if `touse', meanonly
        local emean = r(mean)
        local esum =  r(sum)
        local emin =  r(min)

        * check expected frequencies
        if `emin' <= 0 {
            di in r "expected frequencies must be positive"
            exit 411
        }

        * got to here => we're in business

        preserve
        keep if `touse'
        keep `obs' `exp'
        tempname chi2 p chi2_lr p_lr
        gen observed = `obs'
        gen expected = `exp'

        * count cells with < 5 & < 1
        local lowexp = `emin' < 5
        count if exp >= 1 & exp < 5
        local lt5 = r(N)
        count if exp < 1
        local lt1 = r(N)

    }

    * print header
    di _n in g "Chi-square test:"
    di in g "    observed frequencies from " _c
    if "`kb'" == "kb" { di in g "keyboard" }
    else  di in g "`1'"
    if `nvars' == 2 {
        di in g "    expected frequencies from " _c
        if "`kb'" == "kb" { di in g "keyboard" }
        else di in g "`2'"
    }
    else di in g "    expected frequencies equal"

    * warn if totals differ by more than 0.01
    if `nvars' == 2 & abs(`osum'-`esum') > 0.01 {
        di _n in r "Warning: totals of `1' and `2' differ"
        di in r _col(15) "total"
        di in r "`1'" _col(12) %8.0g `osum'
        di in r "`2'" _col(12) %8.0g `esum'
    }

    * macros for output if `emin' >= 5
    local outlist "obs exp classic Pearson"
    local nspaces = 35

    * prepare notes and change macros for output if `emin' < 5
    if `lowexp' {
        qui {
            gen str2 notes = "  "
            replace notes = " *" if exp < 5
            replace notes = "**" if exp < 1
            format notes %6s
            local outlist "obs exp notes classic Pearson"
            local nspaces = 43
       }
    }

    * chi-square calculations
    qui {
        gen classic  = obs - exp
        gen Pearson = (obs - exp) / sqrt(exp)
        format exp classic Pearson %10.3f
        gen Pearson2 = Pearson^2
        su Pearson2, meanonly
        local k  = r(N)
        scalar `chi2' = r(sum)
        scalar `p' = chiprob(`df', `chi2')
        gen `lrchi2' = obs * log(obs / exp)
        su `lrchi2', meanonly
        scalar `chi2_lr' = 2 * r(sum)
        scalar `p_lr' = chiprob(`df', `chi2_lr')
    }

    * output results
    di _n in g "         Pearson chi2(" in y "`df'"  /*
    */ in g ") = " in y %8.4f `chi2' in g "   Pr = "   /*
    */ in y %6.3f `p'
    di in g "likelihood-ratio chi2(" in y "`df'"     /*
    */ in g ") = " in y %8.4f `chi2_lr' in g "   Pr = "   /*
    */ in y %6.3f `p_lr'
    di _n _dup(`nspaces') " " in g  "residuals" _c
    l `outlist'

    * explain notes if necessary
    if `lt5' | `lt1' { di }
    if `lt5' { di in y " *" in g " 1 <= expected < 5" }
    if `lt1' { di in y "**" in g " 0 <  expected < 1" }

    return local emean `emean'
    return local p_lr = `p_lr'
    return local chi2_lr = `chi2_lr'
    return local p = `p'
    return local chi2 = `chi2'
    return local df `df'
    return local k `k'

end
