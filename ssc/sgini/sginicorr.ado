*! v1.1.0, 2020-04-21, Philippe Van Kerm, Generalized Gini correlation
* (based on sgini.ado * v2.0.0, 2020-04-21)
* v1.0.0, 2010-03-09, Philippe Van Kerm, Generalized Gini correlation
* (based on sgini.ado * v1.1.0, 2010-02-03)

program define sginicorr , rclass sortpreserve byable(recall) properties(svyb svyj)
  version 8.2
  syntax varlist(min=2 numeric ts) [if] [in]  [fweight aweight pweight] [ , ///
     Parameter(real 2)  Format(passthru) ]

  // --- set sample marker
  marksample touse

  // --- parse options
  if ("`format'"=="") loc format "format(%5.4f)"
  if (`parameter'<=1) {
    di as error "parameter() must be no less than 1" 
    exit 198
  }

  // --- parse weight
  loc w "`weight'`exp'"
  if (inlist("`weight'","","fweight","aweight"))  loc faw "`w'"  
    else loc faw "aweight`exp'"     // where iw, pw and aw treated similarly
  
  // --- estimate correlation matrix
  loc i 0
  foreach var of varlist `varlist' {
    tempname m_`++i'
    qui sgini `varlist' [`w'] if `touse' , sortvar(`var') parameter(`parameter')
    if (`i'==1) {
    	loc N = r(N) 
    	loc sum_w = r(sum_w)
    }	
    mat `m_`i'' = r(coeffs)
    loc rnames "`rnames' :`var'"
  }
  loc nvars = `i'
  tempname m
  mat `m' = `m_1'
  forv i=2/`nvars' {
    mat `m' = `m' \ `m_`i''
  }
  mat `m' = `m' * inv(diag(vecdiag(`m')))
  mat `m' = `m'' 

  // --- Output: 
//  if ("`w'" != "") di as text "(sum of wgt is " %11.0e `sum_w' ")"
//  di as text "(obs = `N')"
  spit_titlecorr "`varlist'" "`parameter'" 
  matrix rowname `m' = `rnames'
  matrix colname `m' = `rnames'
//  di 
  mat list `m' , noblank nohalf noheader nodotz `format'
  di as text _newline "(Note: Gini correlations are asymmetric. In corr(F(X),Y), X is the row variable and Y is the column variable.)"
      
  // --- Return results:
  return scalar N = `N'
  return scalar sum_w = `sum_w'
  return scalar rho = `m'[1,2]
  return matrix Rho = `m'
  return scalar parameter = `parameter'
  return local varlist "`varlist'"
  
  
end  

program define spit_titlecorr
  version 8.2
  args varlist param 
//  di ""
  loc line ""
  if ("`param'"!="2")  {
    loc line "Generalized "
  }
  loc line "`line'Gini correlation matrix (v=`param'):"
  di as text "`line'" 
end  




exit
Philippe Van Kerm
Luxembourg Institute of Socio-Economic Research and University of Luxembourg

