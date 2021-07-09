*! v1.1.0, 2017-07-24, PVK -- SPJ, Decomposition of Change in Generalized Gini
* allow pw and iw ;  svyb and svyj properties to allow svy bootstrap/jackknife ; update sgini (speedup from inequaly) 
* v1.0.2, 2009-02-20, PVK -- SPJ, Decomposition of Change in Generalized Gini
* fix display col width
* v1.0.1, 2009-02-19, PVK -- SPJ, Decomposition of Change in Generalized Gini
* label changes 
* v1.0.0, 2009-02-13, PVK -- SPJ, Decomposition of Change in Generalized Gini
* v0.0.2, 2008-06-24, Philippe Van Kerm, Decomposition of Change in Generalized Gini

pr def dsginideco , rclass sortpreserve byable(recall)  properties(svyb svyj)

  version 8.2
  syntax varlist(min=2 max=2 ts numeric) [if] [in]  [fweight aweight iweight pweight] [ , ///
     Parameters(numlist >0) Format(string) PERcentage PERCFormat(string) Welfare Kakwani ]

  // --- parse options
  if (("`format'"=="") & ("`welfare'"=="")) loc format "%5.3f"
  if (("`format'"=="") & ("`welfare'"!="")) loc format "%5.2f"
  if (("`percentage'"!="") & ("`percformat'"=="")) loc percformat "%4.1f"
  if ("`parameters'"=="") loc parameters "2"
   loc firstparam : word 1 of `parameters'
   loc parameters : list sort parameters
   loc parameters : list uniq parameters
   loc np : word count `parameters'  

  // --- set sample marker
  marksample touse
  
  // --- parse weight
  loc w "`weight'`exp'"
  if (inlist("`weight'","","fweight","aweight"))  loc faw "`w'"  
    else loc faw "aweight`exp'"     // where iw, pw and aw treated similarly
 
  // --- display title
  di
  if ("`welfare'"=="") di as text "Decomposition of change in S-Gini coefficient of inequality"
  else                 di as text "Decomposition of change in S-Gini coefficient of social welfare"
  
  // --- estimate components
  tempvar dinc inc0 inc1 p0 p1 
  tokenize `varlist' 
  loc var0 "`1'"
  loc var1 "`2'"
  qui gen double `inc0' = `var0' if `touse'
  qui gen double `inc1' = `var1' if `touse'
  qui gen double `dinc' = `inc1' - `inc0'  if `touse'
  
  qui su  `inc0' [`faw'] if `touse' , meanonly
  loc mn0 = r(mean)
  local N = r(N)
  local sum_w = r(sum_w)
  qui su  `inc1' [`faw'] if `touse' , meanonly
  loc mn1 = r(mean)
  qui su  `dinc' [`faw'] if `touse' , meanonly
  loc mnd = r(mean)
  loc pi = (`mn1'-`mn0')/`mn0'
  loc  j 0
  foreach v of numlist `parameters' {
    loc ++j
    if (`v'==`firstparam') loc firstj = `j'
    cap confirm variable `p0' 
    if (_rc==0) {
      _sgini `inc1' [`faw'] if `touse', pvar(`p1') param(`v')  `welfare'
      local G1_`j' = r(coeff)
      _sgini `inc0' [`faw'] if `touse', pvar(`p0') param(`v')  `welfare'
      local G0_`j' = r(coeff)
    }
    else {
      _sgini `inc1' [`faw'] if `touse', gen(`p1') param(`v')  `welfare'
      local G1_`j' = r(coeff)
      _sgini `inc0' [`faw'] if `touse', gen(`p0') param(`v')  `welfare'
      local G0_`j' = r(coeff)
    }  
    if ("`kakwani'"!="") {
      _sgini `dinc' [`faw'] if `touse', pvar(`p0') param(`v') `welfare'
      local Cdinc_`j' = r(coeff)
    }  
    _sgini `inc1' [`faw'] if `touse', pvar(`p0') param(`v') `welfare'
    local C1_`j' = r(coeff)
    
    local dG_`j' = `G1_`j'' - `G0_`j''
    local P_`j' = `G0_`j'' - `C1_`j''    
    local R_`j' = `G1_`j'' - `C1_`j''    
    if ("`kakwani'"!="") local K_`j' = sign(`pi')*(`G0_`j'' - `Cdinc_`j'')
    if ("`welfare'"!="") {
      local P_`j' = - `P_`j'' 
      local R_`j' = - `R_`j''
    }
    if ("`percentage'"!="") {
      local rdG_`j' =  100 * (`dG_`j'' / `G0_`j'')
      local rP_`j' = 100 * (`P_`j'' / `G0_`j'')    
      local rR_`j' = 100 * ( `R_`j'' / `G0_`j'')    
      if ("`kakwani'"!="")  local rK_`j' = 100 * ( `K_`j'' / `G0_`j'')    
    }
  }      

  // --- Output: Table 1 
  display
  di as text "Average growth rate = " as res `format' `pi'
  spit_tabheader "`parameters'" 
  loc np : word count `parameters'  
  * Initial Gini
  display as text %15s "Initial S-Gini" " {c |}" _c
  forv j=1/`np' {
    display as result %9s `"`:display `format' `G0_`j'' '"' _c
  }
  display 
  * Final Gini
  display as text %15s "Final S-Gini" " {c |}" _c
  forv j=1/`np' {
    display as result %9s `"`:display `format' `G1_`j'' '"' _c
  }
  display 
  * Change
  display as text %15s "Change" " {c |}" _c
  forv j=1/`np' {
    display as result %9s `"`:display `format' `dG_`j'' '"' _c
  }
  display 
  * Reranking
  display as text %15s "R-component" " {c |}" _c
  forv j=1/`np' {
    display as result %9s `"`:display `format' `R_`j'' '"' _c
  }
  display 
  * Progressivity
  display as text %15s "P-component" " {c |}" _c
  forv j=1/`np' {
    display as result %9s `"`:display `format' `P_`j'' '"' _c
  }
  display 
  if ("`kakwani'"!="") {
    * Kakwani
    display as text %15s "K-index" " {c |}" _c
    forv j=1/`np' {
      display as result %9s `"`:display `format' `K_`j'' '"' _c
    }
    display 
  }  
  spit_tabfooter "`parameters'" 

  if ("`percentage'"!="") {
    display
    display "Change, P- and R-components as percentage of initial S-Gini:"
    spit_tabheader "`parameters'" 
    display as text %15s "Change" " {c |}" _c
    forv j=1/`np' {
      display as result %9s `"`:display `percformat' `rdG_`j'' '"' _c
    }
    display 
    display as text %15s "R-component" " {c |}" _c
    forv j=1/`np' {
      display as result %9s `"`:display `percformat' `rR_`j'' '"' _c
    }
    display 
    display as text %15s "P-component" " {c |}" _c
    forv j=1/`np' {
      display as result %9s `"`:display `percformat' `rP_`j'' '"' _c
    }
    display 
    if ("`kakwani'"!="") {
      display as text %15s "K-index" " {c |}" _c
      forv j=1/`np' {
       display as result %9s `"`:display `percformat' `rK_`j'' '"' _c
      }
      display 
    }  
  spit_tabfooter "`parameters'" 
 
  }  
  
  
  // ---  Return results
  * macros 
  return local var0 "`var0'"  
  return local var1 "`var1'"  
  return local paramlist "`parameters'"
  * scalars with values for 1st parameter in supplied list
  return scalar N = `N'
  return scalar sum_w = `sum_w'
  return scalar pi = `pi'
  return scalar sgini0 = `G0_`firstj''
  return scalar sgini1 = `G1_`firstj''
  return scalar dsgini = `dG_`firstj''
  return scalar P = `P_`firstj''
  return scalar R = `R_`firstj''
  if ("`kakwani'"!="") return scalar K = `K_`firstj''
  if ("`percentage'"!="") {
    return scalar reldsgini = `rdG_`firstj''
    return scalar relP = `rP_`firstj''
    return scalar relR = `rR_`firstj''
    if ("`kakwani'"!="") return scalar relK = `rK_`firstj''
  }  
  * vectors with parameters
  loc colnames ""
  tempname params
  mat def `params' = J(1,`np',.)
  forv j=1/`np' {
    loc colnames "`colnames' param`j'"
    matrix `params'[1,`j'] = `: word `j' of `parameters''
  }
  matrix rowname `params' = parameter
  matrix colname `params' = `colnames'
  return matrix parameters  = `params'
 
  * matrix all coeffs
  tempname coeffs
  if ("`kakwani'"!="") mat def `coeffs' = J(6,`np',.)
  else                 mat def `coeffs' = J(5,`np',.)  
  loc colnames ""
  forv j=1/`np' {
    loc colnames   "`colnames' param`j'"
    matrix `coeffs'[1,`j'] = `G0_`j''
    matrix `coeffs'[2,`j'] = `G1_`j''
    matrix `coeffs'[3,`j'] = `dG_`j''
    matrix `coeffs'[4,`j'] = `R_`j''
    matrix `coeffs'[5,`j'] = `P_`j''
    if ("`kakwani'"!="") matrix `coeffs'[6,`j'] = `K_`j''
  }
  if ("`kakwani'"!="") matrix rowname `coeffs' = sgini0 sgini1 dgini R P K
  else                 matrix rowname `coeffs' = sgini0 sgini1 dgini R P 
  matrix colname `coeffs' = `colnames'
  return matrix coeffs  = `coeffs'
  
  if ("`percentage'"!="") {  
    tempname relcoeffs
    if ("`kakwani'"!="") mat def `relcoeffs' = J(4,`np',.)
    else                 mat def `relcoeffs' = J(3,`np',.)  
    loc colnames ""
    forv j=1/`np' {
      loc colnames   "`colnames' param`j'"
      matrix `relcoeffs'[1,`j'] = `rdG_`j''
      matrix `relcoeffs'[2,`j'] = `rR_`j''
      matrix `relcoeffs'[3,`j'] = `rP_`j''
      if ("`kakwani'"!="") matrix `relcoeffs'[4,`j'] = `rK_`j''
    }
    if ("`kakwani'"!="") matrix rowname `relcoeffs' = dgini R P K
    else                 matrix rowname `relcoeffs' = dgini R P 
    matrix colname `relcoeffs' = `colnames'
    return matrix relcoeffs  = `relcoeffs'
  }  
  
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
  display as text "{hline 16}{c TT}{hline `length'}"
  display as text %15s "Parameter:" " {c |}" `headlist' 
  display as text "{hline 16}{c +}{hline `length'}"  
end  

program define spit_tabfooter 
  version 8.2
  args param
  display as text "{hline 16}{c BT}{hline `=9*`: word count `param'''}"  
end  



program define _sgini , rclass 
  * redone 2017-07-24: much faster 	
  * v3.1.0, 2008-04-23 (based on v3.0.0,  2007-11-19)
  * -generate()- and -pvar()- options added. Receives/generates fractional rank variable  -- only needed for speed
  version 8.2
  syntax varname [if] [in]  [fweight aweight] [ , Param(real 2.0) Sortvar(varname) PVar(varname) ABSolute Welfare Generate(name)]
  loc w "`weight'`exp'"
  gettoken eq wexp : exp , parse(=)
  if "`wexp'"=="" loc wexp "1"
  marksample touse
  markout `touse' `sortvar'  `pvar'
  if ("`sortvar'"!="") & ("`pvar'"!="") {
    di as error "Options sorvar() and pvar() are mutually exclusive"
    exit 198
  }
  if ("`sortvar'"=="") & ("`pvar'"=="") {
    loc sortvar "`varlist'"
  }
  tempvar p padj sumw sumwp
  tempname X mu
  quietly {
    if ("`pvar'"=="") {
	
      /* Old: slower
	  // 0. get raw cumulative rank
      cumul `sortvar' [`w'] if `touse' , gen(`p') 
      // 1. use 'adjusted ranks' padj[i] = sum(w[1]::w[i]) - w[i]/2 
      // to ensure that expected adjusted rank = 0.5
      // see Lerman & Yitzhaki (J of Econometrics, 1989); Chokitapanich & Griffiths (RIW, 2001)
      sort `p'
      gen double `padj' = max(0,`p'[_n-1]) + ( ( `p'-max(0,`p'[_n-1]) )/2 )  if `touse'
      // 2. take average padj within all tied values of sortvar (relevant for concentration indices only)
      gen double `sumw' = .
      gen double `sumwp' = .
      bys `sortvar' `touse' : replace `sumw' = sum(`wexp') if `touse'
      bys `sortvar' `touse' : replace `sumwp' = sum(`wexp'*`padj') if `touse'
      bys `sortvar' `touse' : replace `padj' = `sumwp'[_N]/`sumw'[_N] if `touse'
	  */
	  /* Faster version:  */
      tempvar wvar svar cusum
	  qui gen double `wvar' = `wexp'  if `touse'  // it needs a variable
      qui gen double `svar' = `varlist' if `touse'  // to deal with ts operators not allowed by cumul
	  sort `touse' `svar' `wvar'
	  gen double `cusum' = sum(`wvar'*`touse') if `touse' 
	  loc N = `cusum'[_N]
	  // all obs with same income receive same rank
	  by `touse' `svar' : gen double `padj' = 0.5 * (`cusum'[_N] + `cusum'[1] - `wvar'[1])/`N'  if `touse'
    }
    else {
      gen double `padj' = `pvar' if `touse' 
	}  
    gen double `p' = .   
    
    if ("`generate'"!="") {
      gen double `generate' = `padj' if `touse'
    }  
    // 3. use covariance formula to estimate index
    replace `p' = (1-`padj')^(`param'-1) if `touse'
    mat accum `X' = `varlist' `p' [`w'] if `touse' , dev noc means(`mu')
    loc mu_minus_ede = -`param' * (`X'[2,1]/(r(N))) 
    if ("`absolute'"!="") return scalar coeff = `mu_minus_ede'   
    if ("`welfare'"!="") return scalar coeff =  `mu'[1,1] - `mu_minus_ede'  
    if (("`absolute'"!="") + ("`welfare'"!="") == 0) return scalar coeff = `mu_minus_ede' / `mu'[1,1]  
    return scalar N = r(N)
  }
end











exit
Philippe Van Kerm
CEPS/INSTEAD, Luxembourg  
        
