*! version 0.1 HS, Feb 20, 2004
*! version 0.2 HS, Jun 15, 2006
/* wtdpred

Computes predicted density for waiting time distribution.

As default the latest estimated wtdml-model is used, i.e. when no
options are given.

If, however, just one option is given, they must all be set. If you
supply options manually, be aware that the program does little with
respect to checking consistency of the supplied options - use at your
own risk!

*/
  
program define wtdpred
version 8.2
syntax varlist(min = 2 max = 2) [if] [in] [, prevd(string) hdens(string) ddens(string) cens(string) coefvek(string) tailar(real 0)]

tokenize `varlist'
local time `1'
local pred `2'

tempvar tmptime tmppred stdtime hinc S0mort S1mort
tempfile orgdat
tempname pval D1 D0 H phi p10 p11 curar gparm

/* If there are no options, we use last estimated wtdml model */
if "`options'" == "" {
  foreach parm in prevd hdens ddens cens {
    local `parm' = e(`parm')
  }
  local tailar = e(tailar)
  tempname coefvek
  matrix `coefvek' = e(b)
}

marksample touse, novar
qui {
  gen double `stdtime' = `time' if `touse'
  scalar `pval' = exp(`coefvek'[1, 1]) / (1 + exp(`coefvek'[1, 1]))
  
  tempvar gpred
  gen `gpred' = .
  
  if "`prevd'" == "exp" {
    local coeflg = colsof(`coefvek')
    scalar `gparm' = exp(`coefvek'[1, `coeflg'])
    replace `gpred' = `gparm' * exp( - (`gparm' * `stdtime'))
  }
  
  if "`prevd'" == "wei" {
    local coeflg = colsof(`coefvek')
    local coeflg1 = `coeflg' - 1
    matrix `gparm' = `coefvek'[1, `coeflg1'..`coeflg']
    frwei `stdtime' `gpred', gparm("`gparm'")
  }
  if "`prevd'" == "lnorm" {
    local coeflg = colsof(`coefvek')
    local coeflg1 = `coeflg' - 1
    matrix `gparm' = `coefvek'[1, `coeflg1'..`coeflg']
    frlnorm `stdtime' `gpred', gparm("`gparm'")
  }

  if "`hdens'" == "unif" {
    scalar `H' = exp(`coefvek'[1, 2]) / (1 + exp(`coefvek'[1, 2]))
    gen `hinc' = 1
  }
  if "`hdens'" == "exp" {
    scalar `H' = exp(- exp(`coefvek'[1, 2]))
    gen `hinc' = .
    tempname Hrate
    scalar `Hrate' = exp(`coefvek'[1, 2])
    cf_exp `stdtime' `hinc', beta(`Hrate')
  }

  if "`cens'" == "none" {
    replace `pred' = (`pval' * `gpred' + (1 - `pval') * (1 - `H') * `hinc') /*
*/ / (`pval' * (1 - `tailar') + (1 - `pval') * (1 - `H'))
  }

  if index("`cens'", "dep") ~= 0 {
    if "`ddens'" == "" {
      di in r "ddens must be specified when cens() is set to `cens'" 
      exit
    }
    
    sa `orgdat'

    if "`prevd'" == "exp" {
      drop _all
      set obs 1000
      gen double `tmptime' = (_n - .5) / _N
      gen double `tmppred' = .
      replace `tmppred' = `gparm' * exp( - (`gparm' * `tmptime'))
    }
    
    if "`prevd'" == "wei" {
      drop _all
      set obs 1000
      gen double `tmptime' = (_n - .5) / _N
      gen double `tmppred' = .
      frwei `tmptime' `tmppred', gparm("`gparm'")
    }
    
    if "`prevd'" == "lnorm" {
      drop _all
      set obs 1000
      gen double `tmptime' = (_n - .5) / _N
      gen double `tmppred' = .
      frlnorm `tmptime' `tmppred', gparm("`gparm'")
    }
    
    
    if "`cens'" == "depphi" {
      local philoc = colnumb(`coefvek', "lnphi:_cons")
      if `philoc' == . {
        di in r "Required parameter -lnphi- is not supplied"
        exit
      }
      else {
        scalar `phi' = exp(`coefvek'[1, `philoc'])
      }
    }
    else {
      local philoc = colnumb(`coefvek', "lnphi:_cons")
      if `philoc' ~= . {
        di in r "The supplied coefficent vector contains a lnphi parameter"
        di in r "but you did not use option -cens(depphi)-"
        exit
      }  
      scalar `phi' = 1
    }
    
    if "`hdens'" == "unif" {
      gen `hinc' = 1
    }
    if "`hdens'" == "exp" {
      gen `hinc' = .
      cf_exp `tmptime' `hinc', beta(`Hrate')
    }
    
    if "`ddens'" == "unif" {
      if index("`cens'", "dep") == 1 {
        scalar `D1' = exp(`coefvek'[1, 3]) / (1 + exp(`coefvek'[1, 3]))
        scalar `D0' = exp(`coefvek'[1, 4]) / (1 + exp(`coefvek'[1, 4]))
      }
      if index("`cens'", "indep") == 1 {
        scalar `D1' = exp(`coefvek'[1, 3]) / (1 + exp(`coefvek'[1, 3]))
        scalar `D0' = `D1'
      }
      gen `S1mort' = 1 - `tmptime'
      gen `S0mort' = 1 - `tmptime'
    }
    if "$hmodel" == "exp" {
      if index("`cens'", "dep") == 1 {
        scalar `D1' = exp(- exp(`coefvek'[1, 3]))
        scalar `D0' = exp(- exp(`coefvek'[1, 4]))
      }
      if index("`cens'", "indep") == 1 {
        scalar `D1' = exp(- exp(`coefvek'[1, 3]))
        scalar `D0' = `D1'
      }
      gen `S1mort' = .
      gen `S0mort' = .
      
      forv d = 0/1 {
        tempname Drate`d'
        scalar `Drate`d'' = - log(`D`d'')
        cs_exp `tmptime' `S`d'mort', beta(`Drate`d'')
      }
    }
    scalar `p11' = (1 - `H') * (1 - `D0') * `phi'
    scalar `p10' = (1 - `H') - `p11'
    
    replace `tmppred' = `pval' * `tmppred' * (`D1' + /*
*/ (1 - `D1') * `S1mort') + /*
*/ (1 - `pval') * `hinc' * (`p10' + `p11' * `S0mort')
    
    su `tmppred', mean
    scalar `curar' = r(mean)
    scalar curar = `curar'

    use `orgdat', clear
    if "`ddens'" == "unif" { 
      gen `S1mort' = 1 - `stdtime'
      gen `S0mort' = 1 - `stdtime'
    }
    if "`ddens'" == "exp" {
      gen `S1mort' = .
      gen `S0mort' = .
      forv d = 0/1 {
        cs_exp `stdtime' `S`d'mort', beta(`Drate`d'')
      }
    }

    replace `pred' = `pval' * `gpred' * (`D1' + /*
*/ (1 - `D1') * `S1mort') + /*
*/ (1 - `pval') * `hinc' * (`p10' + `p11' * `S0mort')
    
    replace `pred' = `pred' / `curar' 
  }
}

end



