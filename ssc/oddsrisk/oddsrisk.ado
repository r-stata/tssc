*! version 2.0
* Program to calculate Risk Ratio given the logistic Odds Ratio
* Joseph Hilbe 19Dec2007: Amended 30Jan2008 
* Modified from J. Zhang and K Yu, "What's the Relative Risk", JAMA, Vol 280, No 19, pp1690-1691 (1998).
* Appreciation to Kristin MacDonald, Stata Corp, for her advice
* =>  oddsrisk <y (1/0)> <riskvariable (1/0)> <varlist> [fw=countvar]
program define oddsrisk
version 10.0
syntax varlist(min=2) [if] [in] [fweight] 
  marksample touse
  tokenize `varlist'
  local dpvar `1'
  local riskvar `2'

  if "`weight'" != "" {
    local wt [`weight'`exp']
  }
  tempvar incid
  qui {
     sum `dpvar' if `riskvar'==0  & `touse' `wt'
     gen `incid' = _result(3)
     mac shift
     logit `varlist' `wt' if `touse', or
  }
  di
  di in gr "---------------------------------------------------------------------"
  di in gr "Incidence for unexposed risk group =  "  in ye %9.4f `incid'
  di in gr "---------------------------------------------------------------------"
  di in gr _col(1) "Predictor"  _col(14) "Odds Ratio"  _col(27) "Risk Ratio" _col(42) "[95% Conf. Interval]"
  di in gr "---------------------------------------------------------------------"
  tempvar  orse orcil orciu rrcil rrciu
  gen `orse' = 1
  gen `orcil' = 1
  gen `orciu' = 1
  gen `rrcil' = 1
  gen `rrciu' = 1
  while "`1'" !="" {
*    Estimated Risk Ratio     
     local rr = (exp(_b[`1'])/((1-`incid') + (`incid'*exp(_b[`1']))))
    
*    SE of the RR
     qui replace `orse' = exp(_b[`1'])*_se[`1']

*    CE of OR
     qui replace `orcil' = exp(_b[`1']-invnorm(0.975)*_se[`1'])
     qui replace `orciu' = exp(_b[`1']+invnorm(0.975)*_se[`1'])  

*    Conversion of OR CIs to RR CIs
     qui replace `rrcil' = `orcil'/((1-`incid') + (`incid'*`orcil'))
     qui replace `rrciu' = `orciu'/((1-`incid') + (`incid'*`orciu'))

*    Diaplay Results
     noi di in gr _col(1) "`1'" in ye _col(14) %9.4f exp(_b[`1']) in ye _col(27) %9.4f `rr' ///
         in ye _col(40) %9.4f `rrcil'  _col(53) %9.4f `rrciu'
   mac shift
    }
  di in gr "---------------------------------------------------------------------"
end



