*! 0.1 HS, Nov 11, 2015
*! 0.2 HS, Mar 16, 2016
*! 0.3 HS, Aug 30, 2016
*! 0.4 HS, Sep 09, 2018
*! 0.5 HS, Dec 02, 2019 - init values
*! 0.6 KBN, Dec 18, 2019 - discrete (default) or continuous time

pr define wtdttt, rclass
version 14.0

syntax varname [if] [in], ///
    start(string) end(string) ///
	DISTtype(string) ///
    [IADPercentile(real 0.8) ///
     LOGITPcovar(varlist fv) ///
     MUcovar(varlist fv) LNSIGMAcovar(varlist fv) ///
     LNALPHAcovar(varlist fv) LNBETAcovar(varlist fv) ///
                         ALLcovar(varlist fv) ///
                         eform(passthru) reverse conttime ///
						 niter(integer 50) ///
                                                       *]
qui {
preserve
tokenize `varlist'
local obstime `1'

tempname resmat covarmat prevpr seprev timeperc setimeperc ///
         logtimeperc beta mu sigma alpha

local fmtperc = strofreal(`iadpercentile' * 100, "%2.0f")

capture {
	* For analysis of discrete data with continuity correction
	if "`conttime'" == "" {
		local tstart = td(`start') - .5
		local tend = td(`end') + .5
	}
	* For analysis of continuous data 
	else {
		local tstart = `start'
		local tend = `end'
	}
}
if _rc == 198 {
	display as error "For discrete prescription data both -start()- and -end()- need to be specified as dates." ///
	_n "For continuous data use the option -conttime- and let -start()- and -end()- be given as numbers instead of dates."
	exit 198
}
local delta = `tend' - `tstart'
if "`reverse'" != "" {
	replace `obstime' = `tend' - `obstime'
}
else {
	replace `obstime' = `obstime' - `tstart'
}  

* Compute init values
local ntot = _N
count if `obstime' > (2/3 * `delta')
local nonprevend = r(N)
local prp = 1 - 3 * `nonprevend' / `ntot'
local lpinit = logit(`prp')

if "`disttype'" == "exp" & strpos("`options'", "init(") == 0 {
	su `obstime' if `obstime' < (.5 * `delta')
	local lnbetainit = log(1 / r(mean))
	
	local initstring = "init(logitp:_cons = `lpinit' lnbeta:_cons = `lnbetainit') search(off)"
}
	
if "`disttype'" == "lnorm" & strpos("`options'", "init(") == 0 {
	tempvar logtime
	gen `logtime' = log(`obstime') if `obstime' < (.5 * `delta')
	su `logtime'
	local muinit = r(mean)
	local lnsinit = log(r(sd))
	
	local initstring = "init(logitp:_cons = `lpinit' mu:_cons = `muinit' lnsigma:_cons = `lnsinit') search(off)"
}

if "`disttype'" == "wei" & strpos("`options'", "init(") == 0 {
	su `obstime' if `obstime' < (.5 * `delta')
	local lnbetainit = log(1 / r(mean))
	
	local initstring = "init(logitp:_cons = `lpinit' lnbeta:_cons = `lnbetainit' lnalpha:_cons = 0) search(off)"
}
	
   
global wtddelta = `delta'

* Exponential FRD
if "`disttype'" == "exp" {
    noi ml model lf mlwtdttt_exp ///
        (logitp: `obstime' = `logitpcovar' `allcovar') ///
        (lnbeta: `lnbetacovar' `allcovar') `if' `in', iterate(`niter') ///
            max `initstring' `options'
    if "`eform'" != "" {
        seteform, kexpo(2)
    }
    noi ml display, `eform'

    if "`nlcomoff'" == "" {
        noi nlcom (prevfrac: invlogit([logitp]_b[_cons])) ///
            (iadperc`fmtperc': - log(1 - `iadpercentile') ///
                    / exp([lnbeta]_b[_cons])) ///
            (logiadperc`fmtperc': log(- log(1 - `iadpercentile')) ///
                       - [lnbeta]_b[_cons])
     }
}

* Log-Normal FRD
if "`disttype'" == "lnorm" {
    noi ml model lf mlwtdttt_lnorm ///
        (logitp: `obstime' = `logitpcovar' `allcovar') ///
        (mu: `mucovar' `allcovar') ///
        (lnsigma: `lnsigmacovar' `allcovar') `if' `in', iterate(`niter') ///
    `options' `initstring' max
    if "`eform'" != "" {
        seteform, kexpo(3)
    }
    noi ml display, `eform'

    if "`nlcomoff'" == "" {
        noi nlcom (prevfrac: invlogit([logitp]_b[_cons])) ///
        (iadperc`fmtperc': exp(invnormal(`iadpercentile') ///
                      * exp([lnsigma]_b[_cons]) + [mu]_b[_cons])) ///
        (logiadperc`fmtperc': invnormal(`iadpercentile') ///
                      * exp([lnsigma]_b[_cons]) + [mu]_b[_cons])
    }
}

* Weibull FRD
if "`disttype'" == "wei" {
    noi ml model lf mlwtdttt_wei ///
        (logitp: `obstime' = `logitpcovar' `allcovar') ///
        (lnbeta: `lnbetacovar' `allcovar') ///
        (lnalpha: `lnalphacovar' `allcovar') `if' `in', iterate(`niter') ///
                max `initstring' `options'
    if "`eform'" != "" {
        seteform, kexpo(3)
    }
    noi ml display, `eform'

    mat `resmat' = e(b)
    mat `covarmat' = e(V)

    if "`nlcomoff'" == "" {
        noi nlcom (prevfrac: invlogit([logitp]_b[_cons])) ///
        (iadperc`fmtperc': ///
                (- log(1 - `iadpercentile'))^(1 / exp([lnalpha]_b[_cons])) ///
                                             / exp([lnbeta]_b[_cons])) ///
        (logiadperc`fmtperc': ///
                log(- log(1 - `iadpercentile')) ///
                    * (1 / exp([lnalpha]_b[_cons])) ///
                    - [lnbeta]_b[_cons])
    }
}
if e(converged) == 0 {
	noi di as txt "Warning: convergence not achieved"
}

mat `resmat' = r(b)
mat `covarmat' = r(V)

scalar `prevpr' = `resmat'[1, 1]
scalar `seprev' = sqrt(`covarmat'[1, 1])

scalar `timeperc' = `resmat'[1, 2]
scalar `setimeperc' = sqrt(`covarmat'[2, 2])
scalar `logtimeperc' = log(`timeperc')
return scalar logtimeperc = `logtimeperc'
return scalar timepercentile = `timeperc'
return scalar setimepercentile = `setimeperc'
return scalar prevprop = `prevpr'
return scalar seprev = `seprev'
return local disttype "`disttype'"
return local reverse "`reverse'"
return scalar delta = `delta'
return scalar start = `tstart'
return scalar end = `tend'

}
end

program seteform, eclass
syntax, kexpo(integer)
ereturn scalar k_eform = `kexpo'
end
