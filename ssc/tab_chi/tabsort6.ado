program define tabsort6
*! NJC 1.3.1 2 October 2003 
*! NJC 1.3.0 2 April 2002 
* NJC 1.2.0 1 December 1999 
* NJC 1.1.0 27 July 1998
    version 6.0
    syntax varlist(max=2) [if] [in] [fweight aweight iweight] /* 
    */ [ , Missing noRSort noCSort noLAbel Generate(str)      /*
    */ Summarize(str) SOrt(str) REVerse * ]
    tokenize `varlist'

    local so = substr("`sort'",1,1)
    if "`sort'" == "" | "`so'" == "f" | "`so'" == "c" {
        local sort "freq"
        local so "f"
    }

    if "`summarize'" != "" {
        unab summarize: `summarize', max(1)
        if "`sort'" != "freq" {
            if "`so'" == "m" { local sort "mean" }
            else if "`so'" == "s" { local sort "sd" }
            else {
                di in r "sort( ) should be freq, mean or sd"
                exit 198
            }
        }
        local summ "s(`summarize')"
    }
    else {
        if "`so'" != "f" {
            di in r "sort(`sort') not allowed without summarize( )"
            exit 198
        }
    }

    tempvar touse w W stat group1 group2

    mark `touse' `if' `in'
    if "`missing'" == "" { markout `touse' `varlist', strok }
    if "`summarize'" != "" { markout `touse' `summarize' }

    qui {
        if "`exp'" == "" { gen `w' = 1 }
        else { /* do this now, just in case expression depends on _n */
            gen `w' `exp'
            markout `touse' `w'
            local exp "= `w'"
        }
        gen `W' = .
        gen double `stat' = .
    }

    * sort on row stats, or carry row variable as is
    if "`rsort'" == "" { local slist "`1'" }
    else local tlist "`1'"

    * sort on col stats, or carry col variable as is
    if "`csort'" == "" { local slist "`slist' `2'" }
    else local ulist "`2'"

    local nsort : word count `slist'
    local k = 1

    qui while `k' <= `nsort' {
        local var`k' : word `k' of `slist'
        local type : type `var`k''
        local numvar = substr("`type'",1,3) != "str"
        local fmt : format `var`k''
        local vallab : value label `var`k''

        sort `touse' `var`k''
        if "`sort'" == "freq" {
            by `touse' `var`k'' : replace `stat' = sum(`w') if `touse'
            by `touse' `var`k'' : replace `stat' = `stat'[_N]
        }
        else { /* mean or sd */
            by `touse' `var`k'' : replace `W' = sum(`w') / sum(1) /*
             */ if `touse'
            by `touse' `var`k'' : replace `W' = `w' / `W'[_N]
            by `touse' `var`k'' : replace `stat' = /*
             */ sum(`W' * `summarize') / sum(1) if `touse'
            by `touse' `var`k'' : replace `stat' = `stat'[_N]
        }
        if "`sort'" == "sd" {
    		by `touse' `var`k'' : replace `stat' = /*
        	 */ sqrt(sum(`W' * (`summarize' - `stat')^2) / (sum(1) - 1)) if `touse'
    		by `touse' `var`k'' : replace `stat' = `stat'[_N]
        }
        if "`reverse'" == "" { replace `stat' = -`stat' }
        sort `stat' `var`k''
        by `stat' `var`k'' : gen int `group`k'' = _n == 1 if `touse'
        replace `group`k'' = sum(`group`k'')

        local ng = `group`k''[_N]
        local i = 1
        local j = 1

        while `i' <= `ng' {
            local lbl = `var`k''[`j']
            if `numvar' {
                local big = `lbl' >= 1e8 | `lbl' <= -1e7
                local small = `lbl' < 1 & `lbl' > 0
                local small = `small' | (`lbl' > -1 & `lbl' < 0)
                local nonint = `lbl' != int(`lbl')
                if `big' | `small' { local lbl : di %7.0e `lbl' }
                else if `nonint' { local lbl : di `fmt' `lbl' }
                if "`vallab'" != "" { local lbl : label `vallab' `lbl' }
            }
            else { /* see notes at end */
                if "`lbl'" == "" {
                    local len = length(`var`k''[`j'])
                    if `len' == 0 { local lbl "missing" }
                    else local lbl : di "|" _dup(`len') " " "|"
                }
            }
            label define `group`k'' `i' "`lbl'", add
            count if `group`k'' == `i'
            local j = `j' + _result(1)
            local i = `i' + 1
        }

        label val `group`k'' `group`k''
        _crcslbl `group`k'' `var`k''
        local tlist "`tlist' `group`k''"
        local k = `k' + 1
    }

    tabulate `tlist' `ulist' [`weight' `exp'] if `touse', /*
     */ `summ' `label' `options'

    if "`label'" == "nolabel" & "`slist'" != "" {
        local slist = trim("`slist'")
        if `nsort' == 2 { local s "s" }
        di in bl /*
         */ "Note: labels of `slist' are not those of original variable`s'"
    }

    if "`generat'" != "" { qui tab `varlist', gen(`generat') }

    capture label drop `group1'
    capture label drop `group2'
end

/*

    Spaces in string values:

     get lost in copying -- local lbl = `var`k''[`j']
     must put them back again!

    Missing string values:

     label def <lbl> <val> "", add  -- will not work
     label def <lbl> <val> " ", add -- would work, but then missings and
                                       blanks would give the same result


*/

