*! version 0.1, HS, Feb 28, 2005

/* wtdml

  Maximizes parametric likelihood

Reparametrized to directly use log(rate) for parameters with
exponential densities.

cens: depphi dep indep none

*/

program define wtdml, eclass
version 8.2
if replay() {
  wtd_is
  if `"`0'"' == "" { 
    wtd_mldi
    exit
  }
}

syntax [, prevd(string) ddens(string) hdens(string) /* 
	*/ cens(string) nval(integer 10) initmat(string) /*
        */ level(passthru) Norobust robust *]

qui {
  preserve
  
  wtd_is
  
  /* Step 1. Create uniform variables for MC integration */
    if `nval' < 1 {
      di in red "You must specify integer nval > 0"
      exit
    }
  
  /* Step 1b. Create dataset for (delta; infty)
Done here since it is not possible to use temporary
dataset otherwise	*/
  
  tempfile utaifl
  global utaidat = "`utaifl'"
  save `utaifl'
  
  if "`prevd'" ~= "exp" {
    MCdata if _ot >= 3, nval(`nval') taildat(`utaifl')
  }
  
  /* Step 2. Set model parameters */
    
    
    global parms = "logitp"
  
  if "`cens'" == "" {
    global cens = "none"
  }
  else {
    global cens = "`cens'"
  }
  
  if "`hdens'" == "" {
    local hdens = "exp"
  }
  global hmodel = "`hdens'"
  
  if "$cens" ~= "none" {
    if "`ddens'" == "" {
      local ddens = "exp"
    }
    global dmodel = "`ddens'"
    }
  else {
    global dmodel = "none"
  }
  
  if index("$cens", "dep") == 1 {
    if "$hmodel" ~= "$dmodel" {
      di in red "hdens and ddens are not allowed to differ in current version"
      error ???
    }
    
    if "$hmodel" == "exp" & "$dmodel" == "exp" {
      global parms = "$parms lnlambda lnd1 lnd0"
      local mlparm = "(lnlambda: ) (lnd1:)  (lnd0: )"
    }
    
    if "$hmodel" == "unif" & "$dmodel" == "unif" {
      global parms = "$parms logitH logitD1 logitD0"
      local mlparm = "(logitH: ) (logitD1: ) (logitD0: )"
    }
  }
  
  if "$cens" == "depphi" {
    local phiparm = "phi"
    local lnphi = 0
    global parms = "$parms lnphi"
    local mlparm = "`mlparm' (lnphi: )"
  }
  
  if index("$cens", "indep") == 1 {
    if "$hmodel" == "exp" & "$dmodel" == "exp" {
      global parms = "$parms lnlambda lnd"
        local mlparm = "(lnlambda: ) (lnd: )"
      }
    
    if "$hmodel" == "unif" & "$dmodel" == "unif" {
      global parms = "$parms logitH logitD"
      local mlparm = "(logitH: ) (logitD: )"
    }
  }
  
  if "$cens" == "none" {
    if "$hmodel" == "exp" {
      global parms = "$parms lnlambda"
      local mlparm = "(lnlambda: )"
    }
    
    if "$hmodel" == "unif" {
      global parms = "$parms logitH"
      local mlparm = "(logitH: )"
    }
  }
  
  
  if "`prevd'" == "" | index(lower("`prevd'"), "exp") == 1 {
    global gmodel = "exp"
    local gmodel = "exp"
    local gparm = "lnbeta"
  }
  
  if index(lower("`prevd'"), "wei") == 1 {
    global gmodel = "wei"
    local gmodel = "wei"
    local gparm = "lnalpha lnbeta"
  }
  
  if index(lower("`prevd'"), "lnorm") == 1 {
      global gmodel = "lnorm"
      local gmodel = "lnorm"
      local gparm = "mu lnsigma"
    }
  
  local ngparm : word count `gparm'
  forval i = 1/`ngparm' {
    local wi : word `i' of `gparm'
    local mlgparm = "`mlgparm' (`wi': ) "
    global parms = "$parms `wi'"
    local mlparm = "`mlparm' (`wi': ) "
  }
  if "`norobust'" == "" {
    local robust : char _dta[wtd_rob]
    
    local cluster : char _dta[wtd_clus]
    if "`cluster'" ~= "" {
      local cluststat = "cl(_clid)"
    }
  }
  
  /* Step 3. Find starting values: Estimate cond'l on T < delta
and get "naive" censoring estimates (if needed) */
  
  if "`initmat'" == "" {
    tempname evcnt nobs pdeath p H D1 D0 D
    tab _ot [fw = _nev], matcell(`evcnt')
    scalar `nobs' = r(N)
    
    ml model lf mlwtd_`gmodel' (logitp: _t =) `mlgparm' /*
*/ [fweight = _nev] if _ot <= 2, max iter(10)
    
    tempname gmatinit pi
    matrix `gmatinit' = get(_b)
    scalar `pi' = exp(el(`gmatinit', 1, 1)) / (1 + exp(el(`gmatinit', 1, 1)))
    scalar `p' = `pi' * (el(`evcnt', 1, 1) + el(`evcnt', 2, 1)) / `nobs'
    
    if index("$cens", "dep") == 1 {
      scalar `D1' = 1 - el(`evcnt', 1, 1) / (el(`evcnt', 1, 1) + `pi' * el(`evcnt', 2, 1))
      scalar `D0' = 1 - el(`evcnt', 3, 1) / ((1 - `pi') * el(`evcnt', 2, 1) + el(`evcnt', 3, 1) + el(`evcnt', 4, 1))
      scalar `H' =el(`evcnt', 4, 1) / (`nobs' * (1 - `p')) / `D0'
    }
    if index("$cens", "indep") == 1 {
      scalar `D'  = 1 - (el(`evcnt', 1, 1) + el(`evcnt', 3, 1)) / `nobs'
      scalar `H' = el(`evcnt', 4, 1) / (`nobs' * (1 - `p')) / `D'
    }
    if "$cens" == "none" {
      scalar `H' = 1 - (el(`evcnt', 1, 1) + el(`evcnt', 2, 1) - `p' * `nobs') / (`nobs' * (1 - `p'))
    }
    
    tempname initmat 
    
    local logitp = log(`p'/ ( 1 - `p'))

    if "$hmodel" == "unif"{
      local logitH = log(`H' / ( 1 - `H'))
      if  "$dmodel" == "unif" {
        if index("$cens", "dep") == 1 {
          local logitD1 = log(`D1' / ( 1 - `D1'))
          local logitD0 = log(`D0' / ( 1 -`D0'))
        }
        if  index("$cens", "indep") == 1 {
          local logitD = log(`D' / ( 1 - `D'))
        }
      }
      matrix input `initmat' = (`logitp' `logitH' `logitD1' `logitD0' `logitD' `lnphi')
    }
    
    if "$hmodel" == "exp" {
      local lnlambda = log(- log(`H'))
      
      if "$dmodel" == "exp" {
        if index("$cens", "dep") == 1 {
          local lnd1 = log(- log(`D1'))
          local lnd0 = log(- log(`D0'))
        }
        if index("$cens", "indep") == 1 {
          local lnd = log(- log(`D'))
        }
      }
      matrix input `initmat' = (`logitp' `lnlambda' `lnd1' `lnd0' `lnd' `lnphi')
    }
    
    matrix `initmat' = `initmat' , `gmatinit'[1,2...]
  }

  
}

/* Step 4. Define and maximize likelihood */ 
  
  ml model lf wtd_loglik (logitp: _t _z _ot = ) `mlparm' [fw = _nev], ///
  max iter(20) search(off) init(`initmat', copy) ///
  `robust' `cluststat' `options'

wtd_mldi, `level' 

ereturn scalar tailar = r(tailar)
ereturn local prevd $gmodel
ereturn local hdens $hmodel
ereturn local ddens $dmodel
ereturn local cens $cens
end

program define MCdata
version 8.0

syntax if, nval(integer) taildat(string)

qui {
  /* Step 1. Create variables for (z; delta] */
  
  local u = "_unifv"
  for new `u'1-`u'`nval': gen double X = uniform() `if'
  global MCnval = `nval'
  
  /* Step 2. Create dataset for (delta; infty) */
    
  su _ot [fw = _nev], meanonly
  local sqnobs = int(sqrt(r(N)))
  
  tempfile orgdat
  save `orgdat'

  use `taildat'
  drop _all
  tempvar `u'
  set obs `sqnobs'
  
  gen double `u' = uniform()
  
  save `taildat', replace
  use `orgdat'
}

end

program define wtd_mldi, rclass
version 8.2
syntax [, level(passthru)]

tempname normfrac orgprlgt 

local start : char _dta[wtd_start]
local end : char _dta[wtd_end]
local scale : char _dta[wtd_scale]
scalar `orgprlgt' = (d(`end') - d(`start')) / `scale'

/* Setting up diparm statements */

if "$hmodel" == "exp" | "$dmodel" == "exp" {
  local dipf = "f(exp(@)/`orgprlgt') d(exp(@)/`orgprlgt')"
}
if "$hmodel" == "unif" | "$dmodel" == "unif" {
  local dipfa = "f(exp(-@)/(1+exp(-@))/`orgprlgt')"
  local dipfb = "d((exp(-@)/(1+exp(-@))-(exp(-@)/(1+exp(-@)))^2)/`orgprlgt')"
}

if "$hmodel" == "exp" {
  local diph = "diparm(lnlambda, `dipf' lab(lambda))"
}
if "$hmodel" == "unif" {
  local dipha = "diparm(logitH, `dipfa'"
  local diphb = "`dipfb' lab(lambda))"
}
if "$dmodel" == "exp" {
  if index("$cens", "dep") == 1 {
    local dipd1 = "diparm(lnd1, `dipf' lab(d1))"
    local dipd0 = "diparm(lnd0, `dipf' lab(d0))"
  }
  if "$cens" == "indep" {
    local dipd = "diparm(lnd, `dipf' lab(d))"
  }
}
if "$dmodel" == "unif" {
  if index("$cens", "dep") == 1 {
    local dipd1a = "diparm(logitD1, `dipfa'"
    local dipd1b = "`dipfb' lab(d1))"
    local dipd0a = "diparm(logitD0, `dipfa'"
    local dipd0b = "`dipfb' lab(d0))"
  }
  if "$cens" == "indep" {
    local dipda = "diparm(logitD, `dipfa'"
    local dipdb = "`dipfb' lab(d))"
  }
}
if "$cens" == "depphi" {
  local dipphi = "diparm(lnphi, exp lab(phi))"
}

if "$gmodel" == "exp" {
  local dipg = "diparm(lnbeta, exp lab(beta))"
}
if "$gmodel" == "wei" {
  local dipga = "diparm(lnalpha, exp lab(alpha))"
  local dipgb = "diparm(lnbeta, f(exp(@)/`orgprlgt') d(exp(@)/`orgprlgt') lab(beta))"
}
if "$gmodel" == "lnorm" {
  local dipg = "diparm(mu, lab(mu)) diparm(lnsigma, exp lab(sigma))"
}

/* ml display */
ml display, diparm(logitp, invlogit lab(p)) /*
*/ `diph' `dipha' `diphb' `dipd1' `dipd1a' `dipd1b' /*
*/ `dipd0' `dipd0a' `dipd0b' `dipd' `dipda' `dipdb' /*
*/ `dipphi' `dipg' `dipga' `dipgb' `level'

/* Displaying estimated tail area of g: P(T > 1 | X = 1) */

local tailar = e(tailar)
if `tailar' == . {
  qui {
    tempname parms
    matrix `parms' = e(b)
    
    if "$gmodel" == "exp" {
      tempname beta
      scalar `beta' = exp(el(`parms', 1, colsof(`parms')))
      local tailar = exp(- `beta')
      return scalar tailar = `tailar'
    }
    else {
      local gdens = "fr$gmodel"
      local nparm1 = colsof(`parms') - 1
      tempname gargs
      mat `gargs' = `parms'[1, `nparm1'...]
      tempvar tailar
      qui gen double `tailar' = .
      imc_tail `tailar', fcnname(`gdens') gparm(`gargs') transf("iexp_xtr") ain(1)
      su `tailar', meanonly
      return scalar tailar = r(mean)
    }
    
  }
}
di _n "Tail area is: " in ye `tailar'
  
end

