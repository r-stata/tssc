*! 1.3.0 NJC 15 July 2000 
* 1.2.4 NJC 18 April 2000 
* 18 April 2000: fix to Pairwise 
* 1.2.3 NJC 21 March 1999
* 1.2.2 NJC 25 January 1999
* 1.2.1 13 January 1998
program define tabchi
        version 6.0
        syntax varlist(max=2) [if] [in] [fweight] /*  
        */ [ , Raw Pearson Adjust Cont noO noE * ] 
        tokenize `varlist'
	args row col 

        quietly {
                preserve
                tempvar obs colsum rowsum fit rawres Pearson adj contr

                if "`exp'" == "" { local exp "= 1" }
                gen `obs' `exp'
                capture assert `obs' == int(`obs') `if' `in'
                if _rc == 9 {
                        di in r "observed frequencies must be integers"
                        exit 499
                }

                marksample touse, strok
                keep if `touse'

                sort `row' `col'
                by `row' `col': replace `obs' = sum(`obs')
                by `row' `col': replace `obs' = `obs'[_N]
                by `row' `col': keep if _n == _N

                * before 1.5.0 used WWG Pairwise
                * Pairwise `row' `col'
		fillin `row' `col' 
	
                replace `obs' = 0 if `obs' == .
                sort `col'
                by `col': gen double `colsum' = sum(`obs')
                by `col': replace `colsum' = `colsum'[_N]
                sort `row'
                by `row': gen double `rowsum' = sum(`obs')
                by `row': replace `rowsum' = `rowsum'[_N]
                su `obs', meanonly
                local tabsum = r(sum) 

                gen double `fit' = (`rowsum' * `colsum') / `tabsum'
                count if `fit' < 5
                local lt5 = r(N)
                count if `fit' < 1
                local lt1 = r(N)
                gen double `rawres' = `obs' - `fit'
                gen double `Pearson' = (`obs' - `fit') / sqrt(`fit')
                gen double `contr' = (`obs' - `fit')^2 / (`fit')
                gen double `adj' = `Pearson' / sqrt((1 - `rowsum' / `tabsum') /*
                */ * (1 - `colsum'/`tabsum'))
                noi di
                noi if "`o'" != "noo" {
                        di in g _dup(10) " " "observed frequency"
                }
                noi if "`e'" != "noe" {
                        di in g _dup(10) " " "expected frequency"
                }
                noi if "`raw'" == "raw" {
                        di in g _dup(10) " " "raw residual"
                        local res "`rawres'"
                }
                noi if "`pearson'" == "pearson" {
                        di in g _dup(10) " " "Pearson residual"
                        local res "`res' `Pearson'"
                }
                noi if "`cont'" == "cont" {
                        di in g _dup(10) " " "contribution to chi-square"
                        local res "`res' `contr'"
                }
                noi if "`adjust'" == "adjust" {
                        di in g _dup(10) " " "adjusted residual"
                        local res "`res' `adj'"
                }
                format `rawres' `fit' `Pearson' `adj' `contr' %9.3f
                if "`o'" != "noo" { local show "`obs'" }
                if "`e'" != "noe" { local show "`show' `fit'" }

                noisily {
                        if "`show'`res'" != "" {
                                tabdisp `row' `col', c(`show' `res') `options'
                        }
			local s = cond(`lt5' > 1, "s", "") 
                        if `lt5' >= 1 {
                                di _n in g /*
                                 */ "`lt5' cell`s' with expected frequency < 5"
                        }
                        local s = cond(`lt1' > 1, "s", "") 
			if `lt1' >= 1 {
                                di in g /*
                                 */ "`lt1' cell`s' with expected frequency < 1"
                        }
                }

                tabulate `row' `col' [fw=`obs'], chi2 lrchi2
                local df = (r(r) - 1) * (r(c) - 1)
                noi di _n in g _dup(10) " " "Pearson chi2(" in y "`df'" /*
                 */ in g ") = " in y %8.4f r(chi2) in g "   Pr = "   /*
                 */ in y %5.3f r(p)
                noi di in g " likelihood-ratio chi2(" in y "`df'"       /*
                 */ in g ") = " in y %8.4f r(chi2_lr) in g "   Pr = "   /*
                 */ in y %5.3f r(p_lr)
        }
end

* 1.0.2 NJC 15 July 2000 
* 1.0.1 NJC 18 April 2000 
* version 1.0.0  WWG 31 jan 1997
program define Pairwise /* varname1 varname2 [if] [in] */
        version 6.0
        syntax varlist(min=2 max=2) [if] [in] 
        tokenize `varlist'
	args row col 
	
        tempfile one

        quietly {
                count `if' `in'
                if _N==0 {
                        exit
                }
                if "`if'"!="" | "`in'"!="" {
                        local keep "keep `if' `in'"
                }
                preserve
                `keep'
                keep `row'
                sort `row'
                by `row': keep if _n==1
                save `"`one'"' 

                restore, preserve
                `keep'
                keep `col'
                sort `col'
                by `col': keep if _n==1

                cross using `"`one'"' 
                sort `row' `col'
                save `"`one'"', replace

                restore, preserve
                sort `row' `col'
                merge `row' `col' using `"`one'"' 
                drop _merge
        }
        restore, not
end
