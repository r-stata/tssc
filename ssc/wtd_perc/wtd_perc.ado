*! 0.1 HS, Nov 11, 2015
*! 0.2 HS, Mar 16, 2016

pr define wtd_perc, rclass
version 14.0

syntax varname [if] [in], ///
    DISTtype(string) IADPercentile(real) [start(string) end(string) ///
        PREVFormat(string) PERCFormat(string) delta(real 1)]
qui {
tokenize `varlist'
local obstime `1'

tempname resmat covarmat prevpr selogitprev timeperc beta mu sigma alpha

if ("`start'" != "" & "`end'" == "") | ("`start'" == "" & "`end'" != "") {
    di in red "If you specify -start()- or -end() you must specify both"
    error 119
}
if ("`start'" != "" & "`end'" != "") {
    local delta = (td(`end') - td(`start')) + 1
    if "`reverse'" != "" {
        replace `obstime' = td(`end') + .5 - `obstime'
    }
    else {
        replace `obstime' = `obstime' - (d(`start') - .5)
    }
    local tstart = td(`start') - .5
    local tend = td(`end') + .5
}
else {
    local tstart = 0
    local tend = `delta'
    if "`reverse'" != "" {
        replace `obstime' = `tend' - `obstime'
    }
}    
global wtddelta = `delta'

    
* Exponential FRD
if "`disttype'" == "exp" {
    noi ml model lf mlwtd_exp ///
        (logitp: `obstime' = ) (lnbeta: ) `if' `in', ///
            max
    noi ml display

    mat `resmat' = e(b)
    mat `covarmat' = e(V)

    scalar `prevpr' = invlogit(`resmat'[1, 1])
    scalar `selogitprev' = sqrt(`covarmat'[1, 1])

    scalar `beta' = exp(`resmat'[1, 2])
    scalar `timeperc' = - log(1- `iadpercentile') / `beta'
}

* Log-Normal FRD
if "`disttype'" == "lnorm" {
    noi ml model lf mlwtd_lnorm ///
        (logitp: `obstime' = ) (mu: ) (lnsigma: ) `if' `in', ///
                max
    noi ml display

    mat `resmat' = e(b)
    mat `covarmat' = e(V)

    scalar `prevpr' = invlogit(`resmat'[1, 1])
    scalar `selogitprev' = sqrt(`covarmat'[1, 1])

    scalar `beta' = exp(`resmat'[1, 2])
    scalar `mu' = `resmat'[1, 2]
    scalar `sigma' = exp(`resmat'[1, 3])
    scalar `timeperc' = ///
        exp(invnormal(`iadpercentile') * `sigma' + `mu')
}

* Weibull FRD
if "`disttype'" == "wei" {
    noi ml model lf mlwtd_wei ///
        (logitp: `obstime' = ) (lnbeta: ) (lnalpha: ) `if' `in', ///
                max
    noi ml display

    mat `resmat' = e(b)
    mat `covarmat' = e(V)

    scalar `prevpr' = invlogit(`resmat'[1, 1])
    scalar `selogitprev' = sqrt(`covarmat'[1, 1])

    scalar `beta' = exp(`resmat'[1, 2])
    scalar `alpha' = exp(`resmat'[1, 3])
    scalar `timeperc' = ///
        (- log(1 - `iadpercentile'))^(1 / `alpha') / `beta'
}

* Display and return results
tempname lclpr uclpr
scalar `lclpr' = invlogit(logit(`prevpr') - invnorm(.975) * `selogitprev')
scalar `uclpr' = invlogit(logit(`prevpr') + invnorm(.975) * `selogitprev')

if "`prevformat'" == "" {
    local prevformat = "%4.3f"
}

if "`percformat'" == "" {
    local percformat = "%4.3f"
}

noi di _n _n "Proportion of prevalent users (with 95% CI): "
noi di _col(20) `prevformat' `prevpr' " (" `prevformat' `lclpr' ///
    "; " `prevformat' `uclpr' ")"

noi di _n %2.0f `iadpercentile' * 100 ///
    "th percentile of Inter-arrival distribution: "
noi di _col(20) `percformat' `timeperc'

return scalar logtimeperc = log(`timeperc')
return scalar timepercentile = `timeperc'
return scalar prevprop = `prevpr'
return scalar selogitprev = `selogitprev'
}
end
