prog iv_poisson, eclass
 version 10
 if replay() eret di
 else {
  syntax [varlist] [if] [in] [, exog(varlist) endog(varlist) b(str)]
  marksample touse
  gettoken lhs varlist:varlist
  loc rhs1: list varlist | endog
  loc insts1: list varlist | exog 
  loc insts1: list insts1 - endog
  loc exexog: list insts1 - varlist
  if `: word count `exexog''<  `: word count `endog'' error 198
  qui poisson `lhs' `rhs1' if `touse', nolog
  tempname b
  mat `b'=e(b)
  qui mata: i_pois("`lhs'", "`rhs1'", "`insts1'", "`touse'", "`b'")
  eret post `b', esample(`touse')
  ereturn scalar N = `=r(N)'
  ereturn local depvar "`lhs'"
  ereturn local cmd "ivpois"
  ereturn local version "`version'"
  eret di
 }
end


version 10
mata:
 void iv_pois(todo,b,crit,g,H)
 {
  external y,X,Z,W
  m=((1/rows(Z)):*Z'((y:*exp(-X*b') :- 1)))'
  crit=(m*W*m')
  }
 void i_pois(string scalar depvar, string scalar x, string scalar z, string scalar tousename, string scalar beta)
 {
  external y,X,Z,W
  y = st_data(., tokens(depvar), tousename)
  X1 = st_data(., tokens(x), tousename)
  Z1 = st_data(., tokens(z), tousename)
  cons=J(rows(X1),1,1)
  X = X1, cons
  Z = Z1, cons
  W=rows(Z)*cholinv(Z'Z)
  init=J(1,cols(X),0)
  b=init
  S=optimize_init()
  optimize_init_evaluator(S, &iv_pois())
  optimize_init_which(S,"min")
  optimize_init_evaluatortype(S,"d0")
  optimize_init_params(S,init)
  p=optimize(S)
  /* p */
  st_replacematrix(beta,p)
  }
end

