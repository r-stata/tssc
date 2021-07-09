*! 1.0.2 NJC 8 November 1999 
* 1.0.0 NJC 2 March 1999
program def tabhbar
    version 6.0
    syntax varlist(max=2) [if] [in] [fweight] /*
    */ [, Zero FSort RFSort SOrt(str) TItle(str asis) Wide Format(str) /*
    */ rowpc colpc rowpr colpr rowfr colfr * ]

    local nopts = ("`fsort'" != "") + ("`rfsort'" != "" ) + ("`sort'" != "")
    if `nopts' > 1 {
        di in r "sort options may not be combined"
        exit 198
    }

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
        args col
        tempvar row
        gen byte `row' = 1
    }

    marksample touse, strok
    preserve

    contract `row' `col' [`weight' `exp'] if `touse', `zero'

    qui if `nrcopts' {
        tempvar sum
        if "`rowpr'`rowpc'`rowfr'" != "" {
                sort `row'
                by `row' : gen `sum' = sum(_freq)
                if "`rowpr'`rowfr'" != "" {
                        by `row' : replace _freq = _freq / `sum'[_N]
                        if "`format'" == "" { local format "%3.2f" }
                }
                else {
                        by `row' : replace _freq = _freq * 100 / `sum'[_N]
                }
        }
        else {
                sort `col'
                by `col' : gen `sum' = sum(_freq)
                if "`colpr'`colfr'" != "" {
                        by `col' : replace _freq = _freq / `sum'[_N]
                        if "`format'" == "" { local format "%3.2f" }
                }
                else {
                        by `col' : replace _freq = _freq * 100 / `sum'[_N]
                }
        }
        drop `sum' /* can cause problems for reshape */
    }

    if `nvars' == 2 {
        if "`wide'" == "" {
                qui separate _freq, by(`row')
                local freq "`r(varlist)'"
                local nrows : word count `freq'
                local j = 1
                while `j' <= `nrows' {
                        local rowvar : word `j' of `freq'
                        local lab : variable label `rowvar'
                        local lab = substr("`lab'",index("`lab'","==")+2,.)
                        label var `rowvar' "`lab'"
                        local j = `j' + 1
                }
                sort `row' `col'
        }
        else {
                sort `col'
                local vallab : value label `col'
                qui tab `col'
                local ncols = r(r)

                local i = 1
                local j = 1
                while `j' <= `ncols' {
                        local cval`j' = `col'[`i']
                        if "`vallab'" != "" {
                                local cval`j' : label `vallab' `cval`j''
                        }
                        qui count if `col' == `col'[`i']
                        local i = `i' + r(N)
                        local j = `j' + 1
                }

                capture confirm string variable `col'
                if _rc == 0 { local string "string" }

                qui reshape wide _freq, i(`row') j(`col') `string'
                unab freq : _freq*
                local j = 1
                while `j' <= `ncols' {
                        local colvar : word `j' of `freq'
                        label var `colvar' "`cval`j''"
                        local j = `j' + 1
                }
                sort `row'
                local col `row'
        }
    }
    else {
        local freq "_freq"
        _crcslbl _freq `varlist'
        if `"`title'"' == `""' { local title : variable label _freq }
    }

    if `"`title'"' != `""' { local title `"ti(`title')"' } 

    if "`sort'" != "" { local sort "sort(`sort')" }
    else if "`fsort'" != "" & `nvars' == 1 { local sort "sort(_freq)" }
    else if "`rfsort'" != "" & `nvars' == 1 { local sort "sort(-_freq)" }

    if "`format'" != "" { local format "f(`format')" }
    hbar `freq',  `options' l(`col') `sort' `title' `format'
end

