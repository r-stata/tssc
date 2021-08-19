/* Stata Macro -- Written by David B. Wilson 
   Version 2021.05.05
   See help for maanova */

program define maanova
preserve
version 14.0

#delimit ;
syntax varlist(min=2 max=2 numeric) [if] [in],
   [var(string)] [se(string)] [w(string)] [print(string)]
   [model(string)] [tau_unique(string)];
#delimit cr

marksample touse
markout `touse'
tokenize `varlist' 

tempvar tau2 tau _w _v _x _lbl _minw _maxw _mines _maxes _j _k _dfb _dfe _dft
tempvar Y X
tempvar _intercept W W1 b resid2 qe_f qe_r pqe Wdiag _wfixed
tempvar ywy iwy iwi qt qb pqb pqt I2 _t2 vtypical se_tau2 _set2

/* apply "if" statement */
qui keep if `touse'==1

/* Errors */
if "`var'"=="" &  "`se'"=="" &  "`w'"=="" {
  di in error "Specify variance [var(varname)], standard error [se(varname)], "
  di in error "or inverse variance weight [w(varname)]."
  exit
}

if ("`var'"!="" &  "`se'"!="") |   ("`var'"!="" &  "`w'"!="") |   ("`se'"!="" &  "`w'"!="") {
  di in error "Only specify one of the following:"
  di in error "variance [var(varname)], standard error [se(varname)], "
  di in error "or inverse variance weight [w(varname)]."
  exit
}

if "`var'"!="" {
       qui g `_w' = 1/`var'
       qui g `_v' = `var'
   }
if  "`se'"!="" {
       qui g `_w' = 1/`se'^2
       qui g `_v' = `se'^2
   }
if "`w'"!="" {
       qui g `_w' = `w'
       qui g `_v' = 1/`w'
   }

/* Drop missing values */
if `1'==. | `_w'==. {
   qui drop if `1'==. | `_w'==. | `2'==.
   }

/* Set default model to REML */
local model = strupper("`model'")
if "`model'"!="FE" &  "`model'"!="DL" &  "`model'"!="HE" &  "`model'"!="HS" &  "`model'"!="SJ" &  "`model'"!="SJIT" &  "`model'"!="ML" &  "`model'"!="EB" {
   local model = "REML"
}

/* Set model to FE if only 1 effect size */
if _N == 1 {
  local model = "FE"
}

/* Dummy code independent variable */
qui tab `2' `if' `in', gen(`_x')
scalar `_j' = r(r)
local j = r(r)
scalar `_k' = r(N)
scalar `_dfe' = `_k' - `_j'
scalar `_dfb' = `_j' - 1
scalar `_dft' = `_k' - 1

/* Determine common tau^2 if not a fixed effect model */
local tau_unique = strupper("`tau_unique'")
if "`model'" != "FE" & "`tau_unique'"!="YES" {
   _matau2 `1' `_w' `2', model("`model'") modtype(aov)
   scalar `tau2' = r(tau2)
   scalar `se_tau2' = r(se_tau2)
   qui replace `_w' = 1/(`_v'+`tau2') /* adjust the weight */
   scalar `tau' = sqrt(`tau2')
   } 

/* Determine sub-group tau^2 */
if "`model'"!="FE" & "`tau_unique'"=="YES" {
  forvalues i = 1/`j' {
      qui sum `_x'`i'
      local _n = int(r(mean)*r(N))
      if `_n'>1 {
      _matau2 `1' `_w' if `_x'`i' == 1, model("`model'")
       scalar `_t2'`i' = r(tau2)
       scalar `_set2'`i' = r(se_tau2)
          if `_t2'`i' < 0 {
             scalar `_t2'`i' = 0
          }
       qui replace `_w' = 1/(`_v'+`_t2'`i') if `_x'`i' == 1
       }
      if `_n'==1 {
       scalar `_t2'`i' = .
       }
}
}

/* some values needed for header info */
qui sum `_w'
scalar `_minw' = r(min)
scalar `_maxw' = r(max)
qui sum `1'
scalar `_mines' = r(min)
scalar `_maxes' = r(max)

/* Analog-to-the-ANOVA results */
mkmat `1', matrix(`Y')
mkmat `_x'*, matrix(`X')
qui g `_intercept' = 1
mkmat `_intercept', matrix(`W1') 

/* Q-between/Q-model (based on weights used in model */
mkmat `_w', matrix(`W')
matrix `Wdiag' = diag(`W')
matrix `ywy' = `Y'' * `Wdiag' * `Y'
matrix `iwy' = `W1'' * `Wdiag' * `Y'
matrix `iwi' = `W1'' * `Wdiag' * `W1'
matrix `qt' = `ywy' - (`iwy' * `iwy') * syminv(`iwi')
matrix `b' = syminv(`X'' * `Wdiag' * `X') * `X'' * `Wdiag' * `Y'
matrix `qe_r' = (`Y'' * `Wdiag' * `Y') - (2 * `b'' * `X'' * `Wdiag' * `Y') + (`b'' * `X'' * `Wdiag' * `X' *  `b')
matrix `qb' = `qt' - `qe_r'
scalar `qb' = `qb'[1,1]
scalar `qt' = `qt'[1,1]
scalar `pqb' = chiprob(`_dfb',`qb')
scalar `pqt' = chiprob(`_dft',`qt')

/* Q-within/Q-errors (based on fixed-effect weights */
qui g `_wfixed' = 1/`_v'
mkmat `_wfixed', matrix(`W')
matrix `Wdiag' = diag(`W')
matrix `b' = syminv(`X'' * `Wdiag' * `X') * `X'' * `Wdiag' * `Y'
matrix `qe_f' = (`Y'' * `Wdiag' * `Y') - (2 * `b'' * `X'' * `Wdiag' * `Y') + (`b'' * `X'' * `Wdiag' * `X' *  `b')
scalar `qe_f' = `qe_f'[1,1]
scalar `pqe' = chiprob(`_dfe',`qe_f')

/* compute I^2 */
if ("`model'" == "FE" | "`model'" == "DL") &  "`tau_unique'"!="YES" {
  scalar `I2' = ((`qe_f' - `_dfe')/`qe_f') * 100
  }
if "`model'" != "FE" & "`model'" != "DL" & "`tau_unique'"!="YES" {
  matrix `vtypical' = (`_k' - `_j')/trace(`Wdiag' - `Wdiag' * `X' * syminv(`X''*`Wdiag'*`X') * `X'' * `Wdiag')
  scalar `I2' = `tau2'/(`vtypical'[1,1] + `tau2') * 100 
  }
if "`tau_unique'"!="YES" {
if `I2' < 0 {
  scalar `I2' = 0
}
}


/* some labels */
if "`model'"=="FE" {
    local model_type = "Fixed (Common) Effect model"
    }
if "`model'"=="DL" {
    local model_type = "Random effects: Dersimonian-Laird"
    }
if "`model'"=="HS" {
    local model_type = "Random effects: Hunter-Schmidt"
    }
if "`model'"=="HE" {
    local model_type = "Random effects: Hedges"
    }
if "`model'"=="SJ" {
    local model_type = "Random effects: Sikik-Jonkman non-iterative"
    }
if "`model'"=="SJIT" {
    local model_type = "Random effects: Sikik-Jonkman iterative"
    }
if "`model'"=="ML" {
    local model_type = "Random effects: iterative full-information maximum likelihood"
    }
if "`model'"=="REML" {
    local model_type = "Random effects: iterative restricted maximum likelihood (default)"
    }
if "`model'"=="EB" {
    local model_type = "Random effects: iterative empirical bayes"
    }

/* total row of results */
qui masum `1' `if' `in', w(`_w') model(FE) /* use weights computed above base on tau^2 */

/* header info */
di " "
di in text _col(1) "No. of obs  =" in result _col(24) %8.0f r(k)   
di in text _col(1) "Minimum effect size =" in result _col(24) %8.4f `_mines'
di in text _col(1) "Maximum effect size =" in result _col(24) %8.4f `_maxes'
di in text _col(1) "Minimum weight =" in result _col(24) %8.4f `_minw'
di in text _col(1) "Maximum weight =" in result _col(24) %8.4f `_maxw'
if "`model'"!="FE" & ("`tau_unique'"!="yes" & "`tau_unique'"!="YES") {
    di in text _col(1) "Common tau^2 =" in result _col(24) %8.4f `tau2'
    di in text _col(1) "SE tau^2 =" in result _col(24) %8.4f `se_tau2'
    di in text _col(1) "Common tau   =" in result _col(24) %8.4f `tau'
    di in text _col(1) "I^2 =" in result _col(24) %4.2f `I2' "%"
}
di " "
di in text _col(1) "----------------+-------------------------------------------------------------"
di in text _col(1) " Cateogry       |      Mean    -95%CI    +95%CI      se       z       p      k"
di in text _col(1) "----------------+-------------------------------------------------------------"
/* overall results */
di in text _col(1) "Total" in text _col(17) "|" /*
      */ in result _col(20) %8.4f r(mean)  /*
      */           _col(30) %8.4f r(lci)  /*
      */           _col(40) %8.4f r(uci) /*
      */           _col(47) %8.4f r(se) /*
      */           _col(54) %8.4f r(z) /*
      */           _col(66) %6.4f r(pz) /*
      */           _col(75)  %4.0f r(k)
di in text _col(1) "----------------+-------------------------------------------------------------"
/* subgroup results */
foreach v of varlist `_x'* {
   qui masum `1' if `v'==1, w(`_w') model(FE) print("`print'")
   local label : var label `v'
   scalar `_lbl' = strlen("`2'")
   local label = substr(`"`label'"', `_lbl'+3, 16)
   di in text _col(1) `"`label'"' in text _col(17) "|" /*
      */ in result _col(20) %8.4f r(mean)  /*
      */           _col(30) %8.4f r(lci)  /*
      */           _col(40) %8.4f r(uci) /*
      */           _col(47) %8.4f r(se) /*
      */           _col(54) %8.4f r(z) /*
      */           _col(66) %6.4f r(pz) /*
      */           _col(75)  %4.0f r(k)
  }
di in text _col(1) "----------------+--------------------------------------------------------------"
if "`print'"=="EXP" {
   di in text _col(1) /*
   */ "Results are the exponent of computed values (i.e., results are odds-ratios)"
}
if "`print'"=="IVZR" {
   di in text _col(1) /*
   */ "Results are inverse Fisher Zr transformed (i.e., results are correlations)"
}
if "`print'"=="PROP" {
   di in text _col(1) /*
   */ "Results are inverse logits (i.e., results are proportions)"
}


if "`tau_unique'"!="YES" {
di "  "
di in text _col(1) "----------------+-------------------------------"
di in text _col(1) " Cateogry       |  Q-within  p(Q-within)      df"
di in text _col(1) "----------------+-------------------------------"
foreach v of varlist `_x'* {
   qui masum `1' if `v'==1, var(`_v') model(FE) /* use FE weights */
   local label : var label `v'
   scalar `_lbl' = strlen("`2'")
   local label = substr(`"`label'"', `_lbl'+3, 16)
   di in text _col(1) `"`label'"' in text _col(17) "|" /*
      */ in result _col(20) %8.4f r(Q)  /*
      */           _col(33) %8.4f r(pQ)  /*
      */           _col(40) %8.0f r(k)-1
  }
di in text _col(1) "----------------+-------------------------------"
}

if "`tau_unique'"=="YES" {
di "  "
di in text _col(1) "----------------+--------------------------------------------------------------"
di in text _col(1) " Cateogry       |  Q-within  p(Q-within)      df      tau2      tau    se(tau2)"
di in text _col(1) "----------------+--------------------------------------------------------------"
local i = 0
foreach v of varlist `_x'* {
   local i = `i' + 1
   qui masum `1' if `v'==1, var(`_v') model(FE) /* use FE weights */
   local label : var label `v'
   scalar `_lbl' = strlen("`2'")
   local label = substr(`"`label'"', `_lbl'+3, 16)
   di in text _col(1) `"`label'"' in text _col(17) "|" /*
      */ in result _col(20) %8.4f r(Q)  /*
      */           _col(33) %8.4f r(pQ)  /*
      */           _col(40) %8.0f r(k)-1  /*
      */           _col(51) %8.5f `_t2'`i' /*
      */           _col(60) %8.5f sqrt(`_t2'`i') /*
      */           _col(72) %8.5f `_set2'`i'
  }
di in text _col(1) "----------------+--------------------------------------------------------------"
}
if "`model'"!="FE" {
  di in text _col(1) "Q-within based on fixed effect weights"
}

di " "
di "Analog-to-the-ANOVA Table"
di in text _col(1) "----------------+------------------------------------"
di in text _col(1) "Source          |          Q          p(Q)         df"
di in text _col(1) "----------------+------------------------------------"
di in text _col(1) "Between (Model)"  in text _col(17) "|" /*
      */ in result _col(21) %8.4f `qb'  /*
      */           _col(35) %8.4f `pqb'  /*
      */           _col(46) %8.0f `_dfb'
di in text _col(1) "Within (Error)"  in text _col(17) "|" /*
      */ in result _col(21) %8.4f `qe_f'  /*
      */           _col(35) %8.4f `pqe'  /*
      */           _col(46) %8.0f `_dfe'       
di in text _col(1) "----------------+------------------------------------"
if "`model'"=="FE" {
di in text _col(1) "Total"  in text _col(17) "|" /*
      */ in result _col(21) %8.4f `qt'  /*
      */           _col(35) %8.4f `pqt'  /*
      */           _col(46) %8.0f `_dft'
di in text _col(1) "----------------+------------------------------------"      
} 
di in text _col(1) "`model_type'"
if "`model'"!="FE" {
  di in text _col(1) "Q-within based on fixed effect weights"
}
di " "
di  in gr "Version 2021.04.18 of maanova.ado written by David B. Wilson"


restore
end
