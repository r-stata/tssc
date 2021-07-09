* Parametric likelihood definitions for Waiting Time Distribution.
* Henrik Støvring, Dec, 2001
* Henrik Støvring, Feb, 2005
* Henrik Støvring, , 2005

program define wtd_loglik
version 8

args lnf $parms

qui{
  
  tempname p H
  scalar `p' = exp(`logitp')/(1+exp(`logitp'))
  
  if "$hmodel" == "unif" {
    scalar `H' = exp(`logitH')/(1 + exp(`logitH'))
  }
  if "$hmodel" == "exp" {
    scalar `H' = exp(- exp(`lnlambda'))
  }    
  tempname D0 D1
  if index("$cens", "dep") == 1 {
    if "$dmodel" == "unif" {
      scalar `D1' = exp(`logitD1')/(1+exp(`logitD1'))
      scalar `D0' = exp(`logitD0')/(1+exp(`logitD0'))
    }
    if "$dmodel" == "exp" {
      scalar `D1' = exp(- exp(`lnd1'))
      scalar `D0' = exp(- exp(`lnd0'))
    }
  }
  if "$cens" == "indep" {
    if "$dmodel" == "unif" {
      scalar `D1' = exp(`logitD')/(1+exp(`logitD'))
      scalar `D0' = `D1'
    }
    if "$dmodel" == "exp" {
      scalar `D1' = exp(- exp(`lnd'))
      scalar `D0' = `D1'
    }
  }
    
  tempname gargs
  tempvar gcont gtmp unit
  gen double `gcont' = .

  if "`lnsigma'" != "" & "`mu'" != "" {
    local gdens = "frlnorm"
    tempname m ls
    scalar `m' = `mu'
    scalar `ls' = `lnsigma'
    matrix `gargs' = (`m', `ls')
  }
  
  if "`lnalpha'" != "" & "`lnbeta'" != "" {
    local gdens = "frwei"
    tempname lna lnb
    scalar `lna' = `lnalpha'
    scalar `lnb' = `lnbeta'
    matrix `gargs' = (`lna', `lnb')
  }
  
  if "`lnalpha'" == "" & "`lnbeta'" != "" {
    tempname lnb
    local gdens = "exp"
    scalar `lnb' = `lnbeta'
    matrix `gargs' = (`lnb')
  }
  
  if  "$dmodel" ~= "none" {
    if "`gdens'" ~= "exp" {
      imc_tail `gcont' if $ML_y3 >= 3,  fcnname(`gdens') /* 
*/ gparm(`gargs') transf("iexp_xtr") ain(1)
      gen double `gtmp' = .
      imc_int $ML_y2 $ML_y1 `gtmp' if $ML_y3 == 3, fcnname(`gdens') /* 
*/ gparm(`gargs') neval($MCnval)
      replace `gcont' = `gcont' + `gtmp' if $ML_y3 == 3
      
      `gdens' $ML_y1 `gcont' if $ML_y3 <=2, gparm(`gargs')
    }
    else {
      replace `gcont' = exp(- exp(`lnb') * $ML_y2)  if $ML_y3 >= 3
      frexp $ML_y1 `gcont' if $ML_y3 < 3, gparm(`gargs') 
    }
  }
  else {
    if "`gdens'" ~= "exp" {
      imc_tail `gcont' if $ML_y3 >= 3,  fcnname(`gdens') /* 
*/ gparm(`gargs') transf("iexp_xtr") ain(1)
      `gdens' $ML_y1 `gcont' if $ML_y3 <=2, gparm(`gargs')
    }
    else {
      tempvar mly2 
      gen `mly2' = 1 if $ML_y3 >= 3
      iexptl `mly2' `gcont' if $ML_y3 >= 3, gparm(`gargs')
      frexp $ML_y1 `gcont' if $ML_y3 < 3, gparm(`gargs') 
    }
  }
    
  tempvar hcont ddens0 ddens1 hint
  
  /* These may later be extended to allow other functional shapes */
    
    if "$hmodel" == "unif" {
      gen double `hcont' = 1 if $ML_y3 <= 2
      replace `hcont' = (1 - $ML_y2)  if $ML_y3 == 3
    }
  if "$hmodel" == "exp" {
    gen double `hcont' = .
    tempname Hrate
    scalar `Hrate' = exp(`lnlambda')
    cf_exp $ML_y1 `hcont' if $ML_y3 <= 2, beta(`Hrate')
    cs_exp $ML_y2 `hcont' if $ML_y3 == 3, beta(`Hrate')
  }
  
  if "$dmodel" == "unif" {
    forv d = 0/1 {
      gen double `ddens`d'' = 1
    }
  }
  if "$dmodel" == "exp" {
    forv d = 0/1 {
      gen double `ddens`d'' = 1
      tempname Drate`d'
      if index("$cens", "dep") == 1 {
        scalar `Drate`d'' = exp(`lnd`d'')
      }
      else {
        scalar `Drate`d'' = exp(`lnd')
      }
      cf_exp $ML_y2 `ddens`d'' if $ML_y3 == 1 | $ML_y3 == 3, beta(`Drate`d'')
    }
  }
  
  if "$dmodel" ~= "none" {
    tempname p11 p10 p01 p00 phi
    if "`lnphi'" == "" {
      scalar `phi' = 1
      scalar `p11' = (1 - `H') * (1 - `D0')
    }
    else {
      
      scalar `phi' = exp(`lnphi')
      scalar `p11' = (1 - `H') * (1 - `D0') * `phi'
    }	
    
    scalar `p10' = (1 - `H') - `p11'
    scalar `p01' = (1 - `D0') - `p11'
    scalar `p00' = 1 - `p11' - `p01' - `p10'
    
    * Case 1
    replace `lnf' = log(/* 
*/ (`p' * `gcont' * `ddens1' * (1 - `D1')  /*
*/ + (1-`p') * `hcont' * `ddens0' * `p11' ) /*
*/ ) if $ML_y3 == 1
    
    * Case 2	
    replace `lnf' = ln( /* 
*/ (`p' * `gcont' * `D1'   /*
*/ + (1-`p') * `hcont' * `p10') ) /*
*/ if $ML_y3 == 2
    
    * Case 3	
    replace `lnf' = ln( /* 
*/ (`p' * `gcont' * `ddens1' * (1 - `D1')  /*
*/ + (1-`p') * ( `p11' * `hcont' + `p01') * `ddens0' ) ) /*
*/ if $ML_y3 == 3
    
    * Case 4
    replace `lnf' = ln( /* 
*/ (`p' * `gcont' * `D1'   /*
*/ + (1-`p') * `p00')  ) /*
*/ if $ML_y3 == 4
  }
  else {
    replace `lnf' = log(`p' * `gcont' + (1 - `p') * `hcont' * (1 - `H') ) if $ML_y3 <= 2
    replace `lnf' = log(`p' * `gcont' + (1 - `p') * `H') if $ML_y3 >= 3
  }
}

end

