/* Stata Macro -- Written by David B. Wilson 
   Version 2021.05.05
   See help for masum */

program define masum, rclass
preserve
version 14.0

#delimit ;
syntax varlist(min=1 max=1 numeric) [if] [in],
   [var(string)] [se(string)] [w(string)] [print(string)]
   [model(string)] ;
#delimit cr

marksample touse
markout `touse'
tokenize `varlist'

tempvar _w _mes _k _df _sumw _sem _les _ues _min _max _q _pq _z _pz _I2 _v _neww
tempname model_type _minw _maxw tau2 vtypical _intercept Wdiag W X invXWX se_tau2

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
   qui drop if `1'==. | `_w'==.
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

/* fixed (common) effect model */
/* always compute */
qui sum `1' if `touse' [aw = `_w']
scalar `_mes' = r(mean)
scalar `_k' = r(N)
scalar `_df' = `_k' - 1
scalar `_sumw' = r(sum_w)
scalar `_sem' = sqrt(1/`_sumw')
scalar `_les' = `_mes' -    1.95996*`_sem'
scalar `_ues' = `_mes' +    1.95996*`_sem'
scalar `_min' = r(min)
scalar `_max' = r(max)
scalar `_q' = r(Var)*((`_k'-1)/`_k')*`_sumw'
scalar `_pq' = chiprob(`_df',`_q')
scalar `_z' = `_mes'/`_sem'
scalar `_pz' = (1 - normprob(abs(`_z')))*2

/* determine random effects tau2 */
if "`model'" != "FE" {
   _matau2 `1' `_w' if `touse', model("`model'")
   scalar `tau2' = r(tau2)
   scalar `se_tau2' = r(se_tau2)
      if `tau2' < 0 {
         scalar `tau2' = 0
      }
   }

/* compute I^2 */
if "`model'" == "FE" | "`model'" == "DL" {
  scalar `_I2' = 100 * (`_q' - `_df')/`_q'
  }
if "`model'" != "FE" & "`model'" != "DL" {
  qui gen `_intercept' = 1
  mkmat `_intercept', matrix(`X')
  mkmat `_w', matrix(`W')
  matrix `Wdiag' = diag(`W')
  matrix `invXWX' =  syminv(`X'' * `Wdiag' * `X')
  matrix `vtypical' = (`_k' - 1)/trace(`Wdiag' - `Wdiag' * `X' * `invXWX' * `X'' * `Wdiag')
  scalar `_I2' = `tau2'/(`vtypical'[1,1] + `tau2') * 100 
  }
if `_I2' < 0 {
  scalar `_I2' = 0
}

/* random effects model */
if "`model'"!="FE" {
    qui g `_neww' = 1/(`_v' + `tau2')
    qui sum `1' if `touse' [aw = `_neww']
    scalar `_mes' = r(mean)
    scalar `_sumw' = r(sum_w)
    scalar `_sem' = sqrt(1/`_sumw')
    scalar `_les' = `_mes' -    1.95996*`_sem'
    scalar `_ues' = `_mes' +    1.95996*`_sem'
    scalar `_min' = r(min)
    scalar `_max' = r(max)
    scalar `_z' = `_mes'/`_sem'
    scalar `_pz' = (1 - normprob(abs(`_z')))*2
}

/* determine min and max weights */
if "`model'"=="FE" {
  qui sum `_w'
  scalar `_minw' = r(min)
  scalar `_maxw' = r(max)
  scalar `_sumw' = r(sum)
  }
/* determine min and max weights */
if "`model'"!="FE" {
  qui sum `_neww'
  scalar `_minw' = r(min)
  scalar `_maxw' = r(max)
  scalar `_sumw' = r(sum)
  }

/* transform data if requested via Print statement */
local print = strupper("`print'")
if "`print'"=="EXP" | "`print'"=="IVZR" | "`print'"=="PROP" {
       scalar `_sem' = .
       foreach x in `_mes' `_les' `_ues' `_min' `_max' {
          if "`print'"=="EXP"  {
             scalar `x' = exp(`x')
             }
          if "`print'"=="IVZR" {
             scalar `x' = (exp(2*`x')-1)/(exp(2*`x')+1)
             }
          if "`print'"=="PROP" {
             scalar `x' = (exp(`x')/(exp(`x')+1))
             }
        }
}

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

di " "
di in text _col(1) "No. of obs  =" in result _col(21) %8.0f `_k'   /*
  */ in text _col(53) "Homogeneity Analysis"
di in text _col(1) "Minimum obs =" in result _col(21) %8.3f `_min' /*
  */ in text _col(59) "Q =" in result _col(64) %9.4f `_q'
di in text _col(1) "Maximum obs =" in result _col(21) %8.3f `_max' /*
  */ in text _col(58)"df =" in result _col(62) %11.0f `_df'
di in text _col(1) "Minimum weight =" in result _col(21) %8.4f `_minw' /*
  */ in text _col(59) "p =" in result _col(62) %11.5f `_pq'
di in text _col(1) "Maximum weight =" in result _col(21) %8.4f `_maxw' /*
  */ in text _col(57) "I^2 =" in result _col(67) %4.2f `_I2' "%"
if "`model'"!="FE" {
di in text _col(1) /*
  */ in text _col(55) "tau^2 =" in result _col(58) %11.5f `tau2'
di in text _col(1) /*
  */ in text _col(50) "se (tau^2) =" in result _col(58) %11.5f `se_tau2'
di in text _col(1) /*
  */ in text _col(57) "tau =" in result _col(58) %11.5f sqrt(`tau2')
  }

di in text _col(1) "--------------------------------------------------------------------------"
di in text _col(1) "                |    Mean    -95%CI    +95%CI        se         z        p"
di in text _col(1) "----------------+---------------------------------------------------------"
di in text _col(1) "Model " "`model' " in text _col(17) "|" in result _col(16) %8.4f `_mes'  _col(28) %8.4f `_les' /*
  */  _col(38) %8.4f `_ues'  _col(48) %8.4f `_sem'  _col(58) %8.4f `_z'  _col(69) %6.4f `_pz'
di in text _col(1) "--------------------------------------------------------------------------"
di in text _col(1) "`model_type'"

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

di " "
di  in gr "Version 2021.04.18 of masum written by David B. Wilson"

/* return list */
return scalar I2    = `_I2'
return scalar mean  = `_mes'
return scalar lci   = `_les'
return scalar uci   = `_ues'
return scalar Q     = `_q'
return scalar pQ    = `_pq'
return scalar se    = `_sem'
return scalar z     = `_z'
return scalar pz    = `_pz'
return scalar k     = `_k'
return scalar df     = `_df'
if "`model'"!="FE" {
    return scalar tau2  = `tau2'
    }

restore
end
