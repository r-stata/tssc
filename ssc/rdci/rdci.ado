*! rdci.ado Version 1.0 JRC 2007-03-06
program define rdci, byable(recall)
    version 9.2
    syntax varlist(min=2 max=2) [if] [in] [fweight] [, Level(real `c(level)') Zsot Cc noBRUTEforce TOLerance(real 1e-6) ///
      LTOLerance(real 0) Verbose INITial(numlist ascending min=1 max=2)]

    tokenize `varlist'
    marksample touse
    if ("`weight'" == "fweight") local weight [fweight `exp']

    summarize `1' if `2' == 0 & `touse' & `1' == 0 `weight', meanonly
    local noncases0 = r(N)
    summarize `1' if `2' == 0 & `touse' & `1' != 0 & !missing(`1') `weight', meanonly
    local cases0 = r(N)
    summarize `1' if `2' != 0 & !missing(`2') & `touse' & `1' == 0 `weight', meanonly
    local noncases1 = r(N)
    summarize `1' if `2' != 0 & !missing(`2') & `touse' & `1' != 0 & !missing(`1') `weight', meanonly
    local cases1 = r(N)

    if ("`level'" != "`c(level)'") local level level(`level')
    else local level
    if (`tolerance' != 1.000e-06) local tolerance  tolerance(`tolerance')
    else local tolerance
    if (`ltolerance' != 0) local ltolerance ltolerance(`ltolerance')
    else local ltolerance
    if ("`initial'" != "") local initial initial(`initial')
    else local initial
    rdcii `cases1' `cases0' `noncases1' `noncases0', `level' `zsot' `cc' `bruteforce' ///
      `tolerance' `ltolerance' `verbose' `initial'
end
