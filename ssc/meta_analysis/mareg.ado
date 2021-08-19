/* Stata Macro -- Written by David B. Wilson 
   Version 2021.05.12
   See help for mareg */

program define mareg
preserve
version 14.0

#delimit ;
syntax varlist(min=2 numeric) [if] [in],
   [var(string)] [se(string)] [w(string)] [model(string)] ;
#delimit cr

marksample touse
markout `touse'
tokenize `varlist' 

tempvar tau2 tau _w _wfixed _v _x _lbl _minw _maxw _mines _maxes _j _k _dfm _dfe _dft
tempvar Y X V
tempvar _intercept W W1 b bfe resid2 qe_f qe_r pqe Wdiag _w
tempvar ywy iwy iwi qt qm pqm pqt I2 Ivector vtypical se_tau2

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
qui g `_wfixed' = `_w'

/* Drop missing values */
if `1'==. | `_w'==. {
   qui drop if `1'==. | `_w'==. | `2'==.
   }

/* Set default model to REML */
local model = strupper("`model'")
if "`model'"!="FE" &  "`model'"!="DL" &  "`model'"!="HE" &  "`model'"!="HS" &  "`model'"!="SJ" &  "`model'"!="SJIT" &  "`model'"!="ML" &  "`model'"!="EB" {
   local model = "REML"
}

/* Determine common tau^2 it not a fixed effect model */
if "`model'" != "FE" {
   _matau2 `1' `_w' `varlist', model("`model'") modtype(reg)
   scalar `tau2' = r(tau2)
   scalar `se_tau2' = r(se_tau2)
      if `tau2' < 0 {
         scalar `tau2' = 0
      }
   qui replace `_w' = 1/(`_v'+`tau2') /* adjust the weight */
   scalar `tau' = sqrt(`tau2')
   } 

/* some values needed for header info */
qui sum `_w'
scalar `_minw' = r(min)
scalar `_maxw' = r(max)
qui sum `1'
scalar `_mines' = r(min)
scalar `_maxes' = r(max)

/* compute regression model */
tempvar se z V invXWX lb ub pz
/* make matrices from data */
mkmat `1', matrix(`Y')
qui g `_intercept' = 1
mkmat `varlist' `_intercept', matrix(`X')
matrix `X' = `X'[1...,2...]
mkmat `_w', matrix(`W')
matrix `Wdiag' = diag(`W')
mkmat `_intercept', matrix(`Ivector') 
/* regression coefficients */
matrix `invXWX' =  syminv(`X'' * `Wdiag' * `X')
matrix `b' = `invXWX' * `X'' * `Wdiag' * `Y'
local ivnames : rownames `b'
local _k = rowsof(`X')
local _p = colsof(`X')
matrix `se' = J(`_p',1,0)
matrix `z' = J(`_p',1,0)
matrix `lb' = J(`_p',1,0)
matrix `ub' = J(`_p',1,0)
matrix `pz' = J(`_p',1,0)
forvalues i = 1/`_p' {
  matrix `se'[`i',1] = sqrt(`invXWX'[`i',`i'])
  matrix `z'[`i',1] = `b'[`i',1]/`se'[`i',1]
  matrix `pz'[`i',1] = (1 - normprob(abs(`z'[`i',1])))*2
  matrix `lb'[`i',1] = `b'[`i',1] - invnormal(.975)*`se'[`i',1]
  matrix `ub'[`i',1] = `b'[`i',1] + invnormal(.975)*`se'[`i',1]
}

/* Q-between/Q-model (based on weights used in model */
matrix `ywy' = `Y'' * `Wdiag' * `Y'
matrix `iwy' = `Ivector'' * `Wdiag' * `Y'
matrix `iwi' = `Ivector'' * `Wdiag' * `Ivector'
matrix `qt' = `ywy' - (`iwy' * `iwy') * syminv(`iwi')
matrix `qe_r' = (`Y'' * `Wdiag' * `Y') - (2 * `b'' * `X'' * `Wdiag' * `Y') + (`b'' * `X'' * `Wdiag' * `X' *  `b')
matrix `qm' = `qt' - `qe_r'
scalar `qm' = `qm'[1,1]
scalar `qt' = `qt'[1,1]
scalar `_dfm' = `_p' - 1
scalar `_dft' = `_k' - 1
scalar `pqm' = chiprob(`_dfm',`qm')
scalar `pqt' = chiprob(`_dft',`qt')


/* Q-within/Q-errors (based on fixed-effect weights */
mkmat `_wfixed', matrix(`W')
matrix `Wdiag' = diag(`W')
matrix `bfe' = syminv(`X'' * `Wdiag' * `X') * `X'' * `Wdiag' * `Y'
matrix `qe_f' = (`Y'' * `Wdiag' * `Y') - (2 * `bfe'' * `X'' * `Wdiag' * `Y') + (`bfe'' * `X'' * `Wdiag' * `X' *  `b')
scalar `qe_f' = `qe_f'[1,1]
scalar `_dfe' = `_k' - `_p'
scalar `pqe' = chiprob(`_dfe',`qe_f')

/* compute I^2 */
if "`model'" == "FE" | "`model'" == "DL" {
  scalar `I2' = ((`qe_f' - `_dfe')/`qe_f') * 100
  }
if "`model'" != "FE" & "`model'" != "DL" {
  matrix `invXWX' =  syminv(`X'' * `Wdiag' * `X')
  matrix `vtypical' = (`_k' - `_p')/trace(`Wdiag' - `Wdiag' * `X' * syminv(`X''*`Wdiag'*`X') * `X'' * `Wdiag')
  scalar `I2' = `tau2'/(`vtypical'[1,1] + `tau2') * 100 
  }
if `I2' < 0 {
  scalar `I2' = 0
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

/* header info */
di " "
di in text _col(1) "No. of obs  =" in result _col(24) %8.0f `_k'   
di in text _col(1) "Minimum effect size =" in result _col(24) %8.4f `_mines'
di in text _col(1) "Maximum effect size =" in result _col(24) %8.4f `_maxes'
di in text _col(1) "Minimum weight =" in result _col(24) %8.4f `_minw'
di in text _col(1) "Maximum weight =" in result _col(24) %8.4f `_maxw'
if "`model'"!="FE" {
    di in text _col(1) "tau^2 =" in result _col(24) %8.4f `tau2'
    di in text _col(1) "se (tau^2) =" in result _col(24) %8.4f `se_tau2'
    di in text _col(1) "tau   =" in result _col(24) %8.4f `tau'
}
di in text _col(1) "I^2 =" in result _col(24) %4.2f `I2' "%"
di " "

/* print regression model */
di in text _col(1) "`model_type'"
di in text _col(1) "----------------+-------------------------------------------------------------"
 di in text _col(1) /*
 */                 "Variable        |            b       se        z      P(z)  [-----95% CI-----]"
 di in text _col(1) "----------------+-------------------------------------------------------------"
 forvalues i = 1/`_p' {
        if `i' < `_p' {
             local thisiv : word `i' of `ivnames'
             }
        if `i' == `_p' {
             local thisiv = "_cons"
             }
        di in text _col(1) "`thisiv'" in text  _col(17) "|" /*
        */     _col(23) %8.5f `b'[`i',1]  /*
        */     _col(32) %8.5f `se'[`i',1]  /*
        */     _col(42) %8.5f `z'[`i',1]  /*
        */     _col(51) %8.5f `pz'[`i',1]  /*
        */     _col(61) %8.5f `lb'[`i',1]  /*
        */     _col(71) %8.5f `ub'[`i',1]  
     }
 di in text _col(1) "----------------+-------------------------------------------------------------"

di "  "
di "Overall Model Statistics"
di in text _col(1) "----------------+------------------------------------"
di in text _col(1) "Source          |          Q          p(Q)         df"
di in text _col(1) "----------------+------------------------------------"
di in text _col(1) "Model"  in text _col(17) "|" /*
      */ in result _col(21) %8.4f `qm'  /*
      */           _col(35) %8.4f `pqm'  /*
      */           _col(46) %8.0f `_dfm'
di in text _col(1) "Error"  in text _col(17) "|" /*
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
if "`model'"!="FE" {
  di in text _col(1) "Q-within based on fixed effect weights"
}
di " "
di  in gr "Version 2021.04.18 of mareg.ado written by David B. Wilson"

restore
end
