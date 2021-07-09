*! v2.0.0, 2020-04-21, Philippe Van Kerm, Generalized Gini/concentration coefficients
*   implementation of alternative calculation of ranks -- speeding up calculations
*   implementation of genfracrankvar() (was not previously activated)   
* v1.1.5, 2014-04-29, Philippe Van Kerm, Generalized Gini/concentration coefficients
*   minor bug fix (r(coeffs) size without source)
* v1.1.4, 2011-05-10, Philippe Van Kerm, Generalized Gini/concentration coefficients
*   modify r(coeff) in the -sourcedeocmposition-
*   edit out put column label
*   add return matrices with contribution and relative contributions
* v1.1.3, 2010-05-20, Philippe Van Kerm, Generalized Gini/concentration coefficients
*   add option welfare (synonymous to aggregate -- for backward compatibility)
* v1.1.2, 2010-03-12, Philippe Van Kerm, Generalized Gini/concentration coefficients
*   add saved results for total Gini when using the sourcedecomp option
* v1.1.1, 2010-03-09, Philippe Van Kerm, Generalized Gini/concentration coefficients
*   Change default format
* v1.1.0, 2010-02-05, Philippe Van Kerm, Generalized Gini/concentration coefficients
*   Add -fracrankvar- option and allow time-series operators in -varlist- or -sortvar-
*   computations for -sourcedecomposition- speed up considerably with use of -genp()-/-pvar()-
* v1.0.2, 2009-09-29, Philippe Van Kerm, Generalized Gini/concentration coefficients
* v1.0.1, 2009-09-11, Philippe Van Kerm, Generalized Gini/concentration coefficients
* v1.0.0, 2007-11-19, Philippe Van Kerm, Generalized Gini/concentration coefficients
* syntax varlist [if] [in] [fweight aweight] [ , Param(real 2.0) Sortvar(varname) SOURCEdecomposition ]
* (this version is based on _sgini.ado * v2.3.0, 2007-02-07)

program define sgini , rclass sortpreserve byable(recall) properties(svyb svyj)
  version 8.2
  syntax varlist(numeric ts) [if] [in]  [fweight aweight pweight] [ , ///
     Parameters(numlist sort >0) Sortvar(varname ts) SOURCEdecomposition Format(string) ///
     ABSolute AGgregate WELfare ///
     FRACrankvar(varname) ]

  // --- set sample marker
  marksample touse
  markout `touse' `sortvar' 

  // --- parse options
  if ("`format'"=="") loc format "%5.4f"
  if ("`parameters'"=="") loc parameters "2"
  if ("`welfare'"!="") loc aggregate "aggregate"  // Welfare and aggregate are synonymous options
  loc np : word count `parameters'  
  if (("`absolute'"!="") + ("`aggregate'"!="") == 2) {
    di as error "absolute and aggregate/welfare options are mutually exclusive" 
    exit 198
  }
  if (("`absolute'"!="") + ("`aggregate'"!="") != 0) & ("`sourcedecomposition'"!="") {
    di as error "Options absolute and aggregate/welfare are incompatible with option sourcedecomposition" 
    exit 198
  }
  if (("`sortvar'"!="") + ("`fracrankvar'"!="") == 2) {
  	di as error "sortvar() and fracrankvar() are mutually exclusive ways to specify ordering variable"
    exit 198
  }
  
  if ("`fracrankvar'"!="") {
  	loc sortvar "`fracrankvar'"
    loc sginiopt "pvar(`fracrankvar')"
  }
  else {
    loc sginiopt "sortvar(`sortvar')"  // sortvar() can be empty (default)
  }
    
  // --- parse weight
  loc w "`weight'`exp'"
  if (inlist("`weight'","","fweight","aweight"))  loc faw "`w'"  
    else loc faw "aweight`exp'"     // where iw, pw and aw treated similarly
  
  // --- display title
  spit_title "`varlist'" "`parameters'" "`sortvar'"

  // --- estimate indices 
  tempvar tmpfracvar
  loc i 0
  foreach var of varlist `varlist' {
    loc ++i
    local var_`i' "`var'"
    qui count if `var' < 0 & `touse'
      if (r(N)>0) {
        di as text "Note: " as res "`var'" as text " has " as res  r(N) _c
        di as text " negative observations (used in calculations)."
      }
    qui su  `var' [`faw'] if `touse' , meanonly
    loc mn_`i' = r(mean)
    local N_`i' = r(N)    
    local sum_w_`i' = r(sum_w)
    loc  j 0
    foreach v of numlist `parameters' {
      loc ++j
      if (`j'==1) _sgini `var' [`faw'] if `touse' , `sginiopt' param(`v') `absolute' `aggregate' genp(`tmpfracvar', replace)
	  else    	  _sgini `var' [`faw'] if `touse' ,            param(`v') `absolute' `aggregate' pvar(`tmpfracvar')
      local coeff`j'_`i' = r(coeff)
    }
  }
  loc nvars = `i'

  // --- estimate decomposition if total
  if ("`sourcedecomposition'"!="") {
    tempvar totvar
    if (`nvars'==1) {
      di as text "Note: varlist contains only one variable -- option sourcedecomposition discarded."
      loc sourcedecomposition ""
    }
    else {        
      qui gen double `totvar' = 0  
      foreach var of varlist `varlist' {
        qui replace `totvar' = `totvar' + `var' if `touse' 
      }
      qui count if `totvar' < 0 & `touse'
      local neg_tot = r(N)
      qui su  `totvar' [`faw'] if `touse' , meanonly
      loc mn_tot = r(mean)
      loc N_tot = r(N)
      loc  j 0
      tempvar ranktot
      foreach v of numlist `parameters' {
        loc ++j
        if (`j'==1) _sgini `totvar' [`faw'] if `touse' , `sginiopt' param(`v') `absolute' `aggregate' genp(`ranktot' , replace)
        else  		_sgini `totvar' [`faw'] if `touse' ,            param(`v') `absolute' `aggregate' pvar(`ranktot')
		local coeff`j'_tot = r(coeff)
      }

      forvalues i=1/`nvars' {
        local share_`i'   =  (`mn_`i''/`mn_tot')
        loc  j 0
        foreach v of numlist `parameters' {
          loc ++j
          if ("`sortvar'"=="") {
            _sgini `var_`i'' [`faw'] if `touse' , pvar(`ranktot') param(`v') `absolute' `aggregate' 
            local conctot`j'_`i' = r(coeff)
		  }
          else {
            local conctot`j'_`i'  =  `coeff`j'_`i''
          }  
          local contrib`j'_`i' =  (`share_`i'') * `conctot`j'_`i''
          local scontrib`j'_`i' =  (`contrib`j'_`i'')/(`coeff`j'_tot')
          local correl`j'_`i' = (`conctot`j'_`i'')/(`coeff`j'_`i'')
          *local elast`j'_`i' = `contrib`j'_`i'' - (`share_`i'')*`coeff`j'_tot'  
          local elast`j'_`i' = `scontrib`j'_`i'' - `share_`i''
        }
      }    
    }  
  }
  // --- Output: Table 1 
  spit_tabheader "`parameters'" 
  forval i=1/`nvars' {
    display as text %12s abbrev("`var_`i''",12) " {c |}" _c
    forv j=1/`np' {
      display as result %9s `"`:display `format' `coeff`j'_`i'' '"' _c
    }
    display 
  }
  spit_tabfooter "`parameters'" 
  
  // --- Output: Table 2
  if ("`sourcedecomposition'"!="") {
    display
    di as text "Decomposition by source:" 
    di as text "  TOTAL = " _c
    loc sep ""  
    foreach v of varlist `varlist' {
      di as text "`sep' " as result "`v'" _c
      loc sep " + "  
    }
    display
    display
    
    loc  j 0
    foreach v of numlist `parameters' {
      loc ++j
      display
      display as text "Parameter: v=`v'"
      display as text "{hline 13}{c TT}{hline `=7*9 + 3'}"
      display as text %12s "        " " {c |}" %9s  "Share" %9s  "Coeff." %9s  "Corr." %9s  "Conc."  %9s  "Contri." %10s  "%Contri." %11s  "Elasticity" 
      display as text %12s "Variable" " {c |}" %9s  "s"     %9s  "g"      %9s  "r"     %9s  "c=g*r"  %9s  "s*g*r"    %10s  "s*g*r/G" %11s  "s*g*r/G-s" 
      display as text "{hline 13}{c +}{hline `=7*9 + 3'}"  
      forval i=1/`nvars' {
        display as text %12s abbrev("`var_`i''",12) " {c |}" _c
        display as result %9s `"`:display `format' `share_`i'' '"' _c
        display as result %9s `"`:display `format' `coeff`j'_`i'' '"' _c
        display as result %9s `"`:display `format' `correl`j'_`i'' '"' _c
        display as result %9s `"`:display `format' `conctot`j'_`i'' '"' _c
        display as result %9s `"`:display `format' `contrib`j'_`i'' '"' _c
        display as result %9s `"`:display `format' `scontrib`j'_`i'' '"' _c
        display as result %10s `"`:display `format' `elast`j'_`i'' '"' 
      }
      display as text "{hline 13}{c +}{hline `=7*9 + 3'}"  
      display as text %12s "TOTAL" " {c |}"   _c
      display as result %9s `"`:display `format' 1 '"' _c
      display as result %9s `"`:display `format' `coeff`j'_tot' '"' _c
      display as result %9s `"`:display `format' 1 '"' _c
      display as result %9s `"`:display `format' `coeff`j'_tot' '"' _c
      display as result %9s `"`:display `format' `coeff`j'_tot' '"' _c
      display as result %9s `"`:display `format' 1 '"' _c
      display as result %10s `"`:display `format' 0 '"' 
      display as text "{hline 13}{c BT}{hline `=7*9 + 3'}"  
    }
    
  }  
  
  // ---  Return results
  if ("`coeff1_tot'"!="") loc retcoeff = `coeff1_tot' // just a convenience output with one var - one param
  else                    loc retcoeff = `coeff1_1' // just a convenience output with one var - one param
  return scalar coeff = `retcoeff' 
  
  tempname params
  loc colnames ""
  mat def `params' = J(1,`np',.)
  forv j=1/`np' {
    loc colnames "`colnames' param`j'"
    matrix `params'[1,`j'] = `: word `j' of `parameters''
  }
  matrix rowname `params' = parameter
  matrix colname `params' = `colnames'
  return matrix parameters  = `params'

  return local varlist "`varlist'"  
  return local paramlist "`parameters'"
  if ("`sortvar'"!="") return local sortvar "`sortvar'"

  loc k 0
  tempname coeffs
  if ("`sourcedecomposition'"!="") {
    mat def `coeffs' = J(1,`=`np'*(`nvars'+1)',.)
  }
  else {
    mat def `coeffs' = J(1,`=`np'*(`nvars')',.)
  }   
  
  loc colnames ""
  forv j=1/`np' {
    forval i=1/`nvars' {
      loc ++k
      loc colnames "`colnames'  `var_`i''"
      loc coleqs   "`coleqs' param`j'"
      matrix `coeffs'[1,`k'] = `coeff`j'_`i''
    }
    if ("`sourcedecomposition'"!="") {
      loc ++k
      loc colnames "`colnames'  _factotal"  //_factotal refers to sum of factors (need a strange name to avoid conflicts) 
      loc coleqs   "`coleqs' param`j'"
      matrix `coeffs'[1,`k'] = `coeff`j'_tot'
    }
  }
  matrix rowname `coeffs' = Coeff
  matrix colname `coeffs' = `colnames'
  matrix coleq   `coeffs' = `coleqs'
  return matrix coeffs  = `coeffs'

  if ("`sourcedecomposition'"!="") {
    loc k 0
    tempname s r c elasticity contrib relcontrib
    mat def `s' = J(1,`=`nvars'',.)
    mat def `r' = J(1,`=`np'*`nvars'',.)
    mat def `c' = J(1,`=`np'*`nvars'',.)
    mat def `contrib' = J(1,`=`np'*`nvars'',.)
    mat def `relcontrib' = J(1,`=`np'*`nvars'',.)
    mat def `elasticity' = J(1,`=`np'*`nvars'',.)
    loc colnames ""
    loc colnamess ""
    loc coleqs ""
    forval i=1/`nvars' {
      loc colnamess "`colnamess'  `var_`i''"
      matrix `s'[1,`i'] = `share_`i''
    }
    forv j=1/`np' {
      forval i=1/`nvars' {
        loc ++k
        loc colnames "`colnames'  `var_`i''"
        loc coleqs   "`coleqs' param`j'"
        matrix `r'[1,`k'] = `correl`j'_`i''
        matrix `c'[1,`k'] = `conctot`j'_`i''
        matrix `contrib'[1,`k'] = `contrib`j'_`i''
        matrix `relcontrib'[1,`k'] = `scontrib`j'_`i''
        matrix `elasticity'[1,`k'] = `elast`j'_`i''
      }
    }
    matrix rowname `r' = Coeff
    matrix colname `r' = `colnames'
    matrix coleq   `r' = `coleqs'
    return matrix r  = `r'
    matrix rowname `c' = Coeff
    matrix colname `c' = `colnames'
    matrix coleq   `c' = `coleqs'
    return matrix c  = `c'
    matrix rowname `contrib' = Coeff
    matrix colname `contrib' = `colnames'
    matrix coleq   `contrib' = `coleqs'
    return matrix contrib  = `contrib'
    matrix rowname `relcontrib' = Coeff
    matrix colname `relcontrib' = `colnames'
    matrix coleq   `relcontrib' = `coleqs'
    return matrix relcontrib  = `relcontrib'
    matrix rowname `elasticity' = Coeff
    matrix colname `elasticity' = `colnames'
    matrix coleq   `elasticity' = `coleqs'
    return matrix elasticity  = `elasticity'
    matrix rowname `s' = Coeff
    matrix colname `s' = `colnamess'
    return matrix s  = `s'
  }    
  return scalar N = `N_1'
  return scalar sum_w = `sum_w_1'
  
    
end  

program define spit_title 
  version 8.2
  args varlist param sortvar
  di ""
  loc line ""
  if ("`param'"!="2")  {
  loc line "Generalized "
  }
  if ("`sortvar'"=="") {
    loc line "`line'Gini" 
  }
  else {
    loc line "`line'Concentration"
    loc tail `"as text " against " as result "`sortvar'""' 
  }
  loc line "`line' coefficient for"
  di as text "`line'" _c
  loc sep ""
  foreach v of varlist `varlist' {
    di as text "`sep' " as result "`v'" _c
    loc sep ","  
  }  
  di `tail'
  di 
end  

program define spit_tabheader 
  version 8.2
  args param
  loc length
  loc headlist ""
  loc length 0
  foreach v of numlist `param' {
    loc headlist `"`headlist' %9s "v=`=round(`v',10e-5)'""'  
    loc length = `length' + 9 
  }
  display as text "{hline 13}{c TT}{hline `length'}"
  display as text %12s "Variable" " {c |}" `headlist' 
  display as text "{hline 13}{c +}{hline `length'}"  
end  

program define spit_tabfooter 
  version 8.2
  args param
  display as text "{hline 13}{c BT}{hline `=9*`: word count `param'''}"  
end  


program define _sgini , rclass sortpreserve
  * v4.0.0, 2020-04-21 : faster calculation of ranks, add -replace- suboption to -genp-
  * v3.2.0, 2010-02-05 : add -genp- option for saving fractional rank , allow ts operators
  * v3.1.0, 2009-09-14 : normalize aw
  * v3.0.0, 2007-11-19 (based on v2.3.0, 2007-02-07)
  * -pvar()- option added. Receives rank variable directly -- only needed for speed gain in -sgini- (but not used currently).
  version 8.2
  syntax varname(ts) [if] [in]  [fweight aweight] [ , Param(real 2.0) Sortvar(varname ts) PVAR(varname) ABSolute AGgregate GENP(string)]
  marksample touse
  markout `touse' `sortvar'  `pvar'
  if ("`sortvar'"!="") & ("`pvar'"!="") {
    di as error "Options sortvar() and pvar() are mutually exclusive"
    exit 198
  }  
  if ("`sortvar'"=="") & ("`pvar'"=="") {
    loc sortvar "`varlist'"
  }
  
  _parse_genp `genp' 
  loc w "`weight'`exp'"
  gettoken eq wexp : exp , parse(=)
  if ("`wexp'"=="") loc wexp 1

  // normalize weights to 1 to avoid huge cumulations
  if ("`weight'"!="") {
    tempvar ww
    qui gen double `ww' = `wexp' if `touse'
    qui su `ww'  if `touse' , meanonly 
    qui replace `ww' = `ww'/r(mean)
    loc wexp `ww'
  }
  
  tempvar yvar svar wvar cusum padj 
  qui gen double `yvar' = `varlist'  // needed to handle ts opertors²
  quietly {
    if ("`pvar'"=="") {
	  qui gen double `wvar' = `wexp'  if `touse'  // it needs a variable
      gen double `svar' = `sortvar' if `touse'  
	  sort `touse' `svar' `wvar'
	  gen double `cusum' = sum(`wvar'*`touse') if `touse' 
	  loc N = `cusum'[_N]
      // NB: 1. use 'adjusted ranks' padj[i] = sum(w[1]::w[i]) - w[i]/2 
      // to ensure that expected adjusted rank = 0.5
      // see Lerman & Yitzhaki (J of Econometrics, 1989); Chokitapanich & Griffiths (RIW, 2001)
	  // 2. all obs with same income receive same rank
	  by `touse' `svar' : gen double `padj' = 0.5 * (`cusum'[_N] + `cusum'[1] - `wvar'[1])/`N'  if `touse'
    }
    else {
      gen double `padj' = `pvar' 
    } 
    if ("`genp'"!="") gen double `genp' = `padj'
	
    // 3. use covariance formula to estimate index
    tempvar p 
    tempname X m
    gen double `p' = (1-`padj')^(`param'-1) if `touse'
    mat accum `X' = `yvar' `p' [`w'] if `touse' , dev noc means(`m')
    loc mu_ede = -`param' * (`X'[2,1]/(r(N))) 
    if ("`absolute'"!="") return scalar coeff = `mu_ede'   
    if ("`aggregate'"!="") return scalar coeff =  `m'[1,1] - `mu_ede'  
    if (("`absolute'"!="") + ("`aggregate'"!="") == 0) return scalar coeff = `mu_ede' / `m'[1,1]  
    return scalar N = r(N)
  }
end

pr def _parse_genp 
  syntax [name(name=genp)] [,replace]
  if ("`genp'"!="") {
	cap confirm new var `genp' 
    if (_rc>0) {
		if ("`replace'"=="") {
			di as error "variable `genp' already exists"
			exit 198
		}
		else {
			drop `genp'
		}		
    }
	c_local genp `genp'
  }
end

exit
Philippe Van Kerm
Luxembourg Institute of Socio-Economic Research and University of Luxembourg

