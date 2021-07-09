program tabsort, byable(recall) sortpreserve 
*! NJC 1.4.0 30 Sept 2003
*! NJC 1.3.0 2 April 2002 
* NJC 1.2.0 1 December 1999 
* NJC 1.1.0 27 July 1998
    version 8.0
    syntax varlist(max=2) [if] [in] [fweight aweight iweight] ///
    [ , Missing noRSort noCSort noLAbel Generate(str)      /// 
    Summarize(varname) SOrt(str) REVerse * ]
    tokenize `varlist'

    local so = substr("`sort'",1,1)
    if "`sort'" == "" | "`so'" == "f" | "`so'" == "c" {
        local sort "freq"
        local so "f"
    }

    if "`summarize'" != "" {
        if "`sort'" != "freq" {
            if "`so'" == "m" local sort "mean" 
            else if "`so'" == "s" local sort "sd" 
            else {
                di as err "sort() should be freq, mean or sd"
                exit 198
            }
        }
        local summ "s(`summarize')"
    }
    else {
        if "`so'" != "f" {
            di as err "sort(`sort') not allowed without summarize()"
            exit 198
        }
    }

    tempvar w W stat group1 group2

    marksample touse, novarlist
    if "`missing'" == "" markout `touse' `varlist', strok
    if "`summarize'" != "" markout `touse' `summarize' 

    qui {
        if "`exp'" == "" gen `w' = 1 
        else { /* do this now, just in case expression depends on _n */
            gen `w' `exp'
            markout `touse' `w'
            local exp "= `w'"
        }
        gen `W' = .
        gen double `stat' = .
    }

    // sort on row stats, or carry row variable as is
    if "`rsort'" == "" local slist "`1'" 
    else local tlist "`1'"

    // sort on col stats, or carry col variable as is
    if "`csort'" == "" local slist "`slist' `2'" 
    else local ulist "`2'"

    local nsort : word count `slist'

    qui forval k = 1/`nsort' {
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
            by `touse' `var`k'' : replace `W' = sum(`w') / sum(1) if `touse'
            by `touse' `var`k'' : replace `W' = `w' / `W'[_N]
            by `touse' `var`k'' : replace `stat' = ///
                sum(`W' * `summarize') / sum(1) if `touse'
            by `touse' `var`k'' : replace `stat' = `stat'[_N]
        }
        if "`sort'" == "sd" {
    		by `touse' `var`k'' : replace `stat' = /// 
       	    sqrt(sum(`W' * (`summarize' - `stat')^2) / (sum(1) - 1)) if `touse' 
    		by `touse' `var`k'' : replace `stat' = `stat'[_N]
        }
        if "`reverse'" == "" replace `stat' = -`stat' 
        bysort `stat' `var`k'' : gen int `group`k'' = _n == 1 if `touse'
        replace `group`k'' = sum(`group`k'')

        local ng = `group`k''[_N]
        local j = 1

        forval i = 1/`ng' {
            local lbl = `var`k''[`j']
            if `numvar' {
                local big = `lbl' >= 1e8 | `lbl' <= -1e7
                local small = `lbl' < 1 & `lbl' > 0
                local small = `small' | (`lbl' > -1 & `lbl' < 0)
                local nonint = `lbl' != int(`lbl')
                if `big' | `small' local lbl : di %7.0e `lbl' 
                else if `nonint' local lbl : di `fmt' `lbl' 
                if "`vallab'" != "" local lbl : label `vallab' `lbl' 
            }
            else { /* see notes at end */
                if "`lbl'" == "" {
                    local len = length(`var`k''[`j'])
                    if `len' == 0 local lbl "missing" 
                    else local lbl : di "|" _dup(`len') " " "|"
                }
            }
            label define `group`k'' `i' "`lbl'", add
            count if `group`k'' == `i'
            local j = `j' + r(N)
        }

        label val `group`k'' `group`k''
        _crcslbl `group`k'' `var`k''
        local tlist "`tlist' `group`k''"
    }

    tabulate `tlist' `ulist' [`weight' `exp'] if `touse', ///
        `summ' `label' `options'

    if "`label'" == "nolabel" & "`slist'" != "" {
        local slist = trim("`slist'")
        if `nsort' == 2 local s "s" 
        di as txt ///
        "Note: labels of `slist' are not those of original variable`s'"
    }

    if "`generate'" != "" qui tab `varlist', gen(`generate') 

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

