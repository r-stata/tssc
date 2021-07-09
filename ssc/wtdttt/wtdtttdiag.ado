*! 0.1 HS, Sep 7, 2016
*! 0.2 KBN, Jan 9, 2019


pr define wtdtttdiag
version 14.0

syntax varname [if] [in], ///
        [nbins(integer 0) ytitle(passthru) ///
         legend(passthru) nq(integer 300) ///
	 lpattern(passthru) fcolor(passthru) ///
	 replace *]
qui{
tempname coefs tstart tend delta converged
matrix `coefs' = e(b)
local disttype = r(disttype)
scalar `delta' = r(delta)
local reverse = r(reverse)
scalar `converged' = e(converged)

if r(start) != . & r(end) != . {
	scalar `tstart' = r(start)
	scalar `tend' = r(end)
}
else {
	scalar `tstart' = r(samplestart)
	scalar `tend' = r(sampleend)
}

preserve
tokenize `varlist'
local obstime `1'

if "`reverse'" == "" {
    replace `obstime' = `obstime' - `tstart'
}

if "`reverse'" == "reverse" {
    replace `obstime' = `tend' - `obstime'
}

local xtitletxt : var label `obstime'
local xformat : format `obstime'

if "`if'" != "" | "`in'" != "" {
    keep `if' `in'
}

count
local nobs = r(N)
if `nbins' == 0 {
    local nbins = int(min(sqrt(`nobs'), 10*log(`nobs')/log(10)))
}

local interwidth = `delta' / `nbins'

tempvar lowcutlev obsdens tfit fitdens
gen `lowcutlev' = int(`obstime' / `interwidth') * `interwidth'

collapse (count) `obstime', by(`lowcutlev')

gen `obsdens' = `obstime' / `nobs' / `interwidth'
* / `delta' * `interwidth'
la var `obsdens' "Observed"
count
local np1 = r(N)
local np1 = `np1' + 1
set obs `np1'
if "`reverse'" == "reverse" {
    replace `lowcutlev' = `delta' if missing(`lowcutlev')
}
else {
    replace `lowcutlev' = `tstart' + `delta' if missing(`lowcutlev')
}
format `lowcutlev' `xformat'
sort `lowcutlev'

local np200 = max(`np1', `nq')
set obs `np200'
gen `tfit' = (_n - 1) / (_N - 1) * `delta'
format `tfit' `xformat'

if "`disttype'" == "exp" {
    gen `fitdens' = (invlogit(`coefs'[1, 1]) ///
                     * exp(- `tfit' * exp(`coefs'[1, 2])) ///
                           * exp(`coefs'[1, 2]) ///
                     + invlogit(- `coefs'[1, 1]) / `delta')
}
if "`disttype'" == "lnorm" {
    gen `fitdens' = (invlogit(`coefs'[1, 1]) ///
                     * normal(- (log(`tfit') - `coefs'[1, 2]) ///
                              / exp(`coefs'[1, 3])) ///
                     / exp(`coefs'[1, 2] + exp(2 * `coefs'[1, 3]) / 2) ///
                     + invlogit(- `coefs'[1, 1]) / `delta')
    replace `fitdens' = invlogit(`coefs'[1, 1]) ///
                                 / exp(`coefs'[1, 2] + exp(2 * `coefs'[1, 3]) / 2) ///
                     + invlogit(- `coefs'[1, 1]) / `delta' if `tfit' == 0
}
if "`disttype'" == "wei" {
    gen `fitdens' = (invlogit(`coefs'[1, 1]) ///
                     * exp(- ((`tfit' * exp(`coefs'[1, 2]))^exp(`coefs'[1, 3])) ///
                           -lngamma(1 + 1/exp(`coefs'[1, 3])))* exp(`coefs'[1, 2]) ///
                     + invlogit(- `coefs'[1, 1]) / `delta')
}

la var `fitdens' "Fitted density"
if "`ytitle'" == "" {
    local ytitle = "ytitle(Density)"
}

if "`reverse'" == "reverse" {
    replace `lowcutlev' = `tend' - `lowcutlev'
    replace `tfit' = `tend' - `tfit'
}
else {
    replace `tfit' = `tstart' + `tfit'
}

if `converged' == 1 {
	twoway (bar `obsdens' `lowcutlev', bartype(spanning) ///
		   bstyle(histogram) `fcolor') ///
		   (line `fitdens' `tfit', `lpattern'), ///
		   `ytitle' `legend' `options' xtitle(`xtitletxt')
}
else {
	twoway (bar `obsdens' `lowcutlev', bartype(spanning) ///
		   bstyle(histogram) `fcolor'), ///
		   `ytitle' `legend' `options' xtitle(`xtitletxt')
}


if "`replace'" != "" {
    tempfile diagdat
    gen obstime = `lowcutlev'
    la var obstime "Observed time variable (lower limit of bins)"
    rename `obsdens' obsdens
    la var obsdens "Observed density (bin height)"
    gen fitdens = `fitdens'
    la var fitdens "Fitted density"
    gen fittime = `tfit'
    la var fittime "Time variable for fitted density"
    keep obstime obsdens fittime fitdens
    order obstime obsdens fittime fitdens

    sa `diagdat'
    restore
    use `diagdat', clear
}
else {
    restore
}

}
end
