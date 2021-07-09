*! renamed 12 February 2004 
*! 1.0.1 NJC 26 February 1999
program def tabplot6
    version 6.0
    #delimit ;
    syntax varlist(max=2) [if] [in] [fweight]
    [, Zero Width(real 0.5) rowpc colpc rowpr colpr rowfr colfr
    yasis xasis  L2title(str) T1title(str) YReverse XReverse
    YLAbel(numlist) XLAbel(numlist) Barfrac(real 0.8) * ] ;
    #delimit cr
    * barfrac( ) undocumented: handle is there if user needs it

    local rcopts = trim("`rowpc' `rowpr' `colpc' `colpr' `rowfr' `colfr'")
    local nrcopts : word count `rcopts'
    if `nrcopts' > 1 {
        di in r "`rcopts' options may not be combined"
        exit 198
    }

    tokenize `varlist'
    local nvars : word count `varlist'
    if `nvars' == 2 { args row col }
    else {
        tempvar row
        gen byte `row' = 1 /* any constant would do */
        args col
    }

    tempvar id sum
    marksample touse, strok

    preserve
    contract `row' `col' [`weight' `exp'] if `touse', `zero'

    qui if `nrcopts' {
         if "`rowpr'`rowpc'`rowfr'" != "" {
                sort `row'
                by `row' : gen `sum' = sum(_freq)
                if "`rowpr'`rowfr'" != "" {
                        by `row' : replace _freq = _freq / `sum'[_N]
                        if "`rowpr'" != "" { local kind "proportion" }
                        else local kind "fraction"
                }
                else {
                        by `row' : replace _freq = _freq * 100 / `sum'[_N]
                        local kind "percent"
                }
        }
        else {
                sort `col'
                by `col' : gen `sum' = sum(_freq)
                if "`colpr'`colfr'" != "" {
                        by `col' : replace _freq = _freq / `sum'[_N]
                        if "`colpr'" != "" { local kind "proportion" }
                        else local kind "fraction"
                }
                else {
                        by `col' : replace _freq = _freq * 100 / `sum'[_N]
                        local kind "percent"
                }
        }
    }
    else local kind "frequency"

    su _freq, meanonly
    local fmax = r(max)

    if "`t1title'" == "" & `nvars' == 2 {
        if "`kind'" == "percent" {
                local t1title : di "maximum `kind' " %2.1f `fmax'
        }
        else if "`kind'" == "proportion" | "`kind'" == "fraction" {
                local t1title : di "maximum `kind' " %4.3f `fmax'
        }
        else local t1title : di "maximum `kind' " `fmax'
    }

    qui {
        if `nvars' == 2 {
                if "`yasis'" == "" {
                        tempvar y
                        * map to integers 1 ... and carry labels
                        egen `y' = lgroup(`row')
                        su `y', meanonly
                        if r(max) < 26 { local ylabel "1/`r(max)'" }
                }
                else local y "`row'"
        }
        else {
                local y "_freq"
                label var _freq "`kind'"
        }

        if "`xasis'" == "" {
                tempvar x
                * map to integers 1 ... and carry labels
                egen `x' = lgroup(`col')
                su `x', meanonly
                if r(max) < 26 { local xlabel "1/`r(max)'" }
        }
        else local x "`col'"

        expand 6

        if "`xreverse'" == "" { gsort - `x' `y' }
        else sort `x' `y'

        gen byte `id' = mod(_n,6)

        if `nvars' == 2 {
                if "`yreverse'" == "" {
                        replace `y' = /*
            */ `y' + `barfrac' * _freq / `fmax' if `id' == 2 | `id' == 3
                }
                else {
                        replace `y' = /*
            */ `y' - `barfrac' * _freq / `fmax' if `id' == 2 | `id' == 3
                }
        }
        else replace `y' = 0 if `id' == 2 | `id' == 3

        if "`xreverse'" == "" {
                replace `x' = /*
            */ `x' - 0.5 * `width' if `id' == 1 | `id' == 2 | `id' == 5
                replace `x' = /*
            */ `x' + 0.5 * `width' if `id' == 3 | `id' == 4 | `id' == 0
        }
        else {
                replace `x' = /*
            */ `x' + 0.5 * `width' if `id' == 1 | `id' == 2 | `id' == 5
                replace `x' = /*
            */ `x' - 0.5 * `width' if `id' == 3 | `id' == 4 | `id' == 0
        }

        if "`l2title'" == "" { local l2title : variable label `y' }
        if "`l2title'" == "" { local l2title "`y'" }
        if "`xlabel'" == "" { local xlabel "xla" }
        else local xlabel "xla(`xlabel')"
        if "`ylabel'" == "" { local ylabel "yla" }
        else local ylabel "yla(`ylabel')"
    }

    gra `y' `x', c(L) sy(i) `xlabel' `ylabel' l2("`l2title'") /*
     */ t1("`t1title'") `options' `yreverse' `xreverse'
 end
