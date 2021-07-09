*! 1.1.8 3 Sep 2008 Austin Nichols
* 1.1.8  3 Sep 2008 add undocumented -noisily- option, switch to cross() for some calcs
* 1.1.7  9 Apr 2008 fix loc ok in check for collinearity
* 1.1.6 30 Mar 2008 fix collinear and level options and check for collinearity
* 1.1.5 28 Mar 2008 add collinear and level options and check for collinearity
* 1.1.4 22 Mar 2008 add from() and use Poisson estimates as init by default
* 1.1.3 21 Mar 2008 add exposure() and offset() options
* 1.1.2 14 Feb 2008 check for overlap in exog and endog
* 1.1.1  5 Jan 2008 switch to d1 using gradient vector
* 1.1.0 12 Dec 2007 add analytic SE, discontinue use of iv_poisson and bootstrap
* 1.0.1 12 Dec 2007 add markout for exog and endog
* 1.0.0 10 Nov 2007 Austin Nichols
prog ivpois, eclass
 version 10
 if replay() {
  syntax [anything] [, EForm(string) Level(real 95) ]
  eret di, eform(`eform') level(`level')
  }
 else {
  syntax [varlist] [if] [in] [, exog(varlist) endog(varlist) Exposure(varname) Offset(varname) from(string) EForm(string) Level(real 95) collinear NOIsily]
  if "`:list exog & endog'"!="" {
   di as err "Variables `:list exog & endog' cannot be both exogenous and endogenous"
   error 198
   }
  if wordcount("`exposure' `offset'")>1 {
   di as err "only one of offset() or exposure() can be specified"
   error 198
   }
  if wordcount("`exposure' `offset'")==0 {
   tempvar offset
   g `offset'=0
   }
  if "`exposure'"!="" {
   tempvar offset
   g `offset'=ln(`exposure')
   }
  marksample touse
  markout `touse' `exog' `endog' `exposure' `offset'
  gettoken lhs varlist:varlist
  loc rhs1: list varlist | endog
  loc insts1: list varlist | exog 
  loc insts1: list insts1 - endog
  loc exexog: list insts1 - varlist
  loc allvars: list rhs1 | exexog
  _rmcoll `allvars' if `touse', `collinear'
  loc ok `r(varlist)'
  loc notok: list allvars - ok
  loc insts1: list insts1 - notok
  loc rhs1: list rhs1 - notok
  loc exexog: list exexog - notok
  if `: word count `exexog''<`: word count `endog'' {
   di as err "equation not identified"
   di as err "you must have at least as many excluded instruments as endog vars"
   error 198
   }
  if "`from'"!="" {
   cap conf mat `from'
   if _rc!=0 & "`from'"!="zero" error 198
   loc k=`:word count `rhs1''+1
   if "`from'"=="zero" {
    tempname from
    mat `from'=J(1,`k',0)
    }
   if (`k'!=colsof(`from')) | (rowsof(`from')!=1) {
    di as err "from() option specified incorrectly"
    di as err "matrix must have 1 row, `k' columns"
    error 198
    }
   forv i=1/`k' {
    if `from'[1,`i']==. {
     di as err "from() option specified incorrectly"
     error 504
     }
    }
   tempname b V
   mat `b'=`from'
   loc names `rhs1' _cons
   mat rownames `b'=y1
   mat colnames `b'=`names'
   mat coleq `b'=`lhs'
   mat `V'=J(`k',`k',.)
   mat rownames `V'=`names'
   mat roweq `V'=`lhs'
   mat colnames `V'=`names'
   mat coleq `V'=`lhs'
  }
  else {
   qui poisson `lhs' `rhs1' if `touse', nolog
   tempname b V
   mat `b'=e(b)
   mat `V'=e(V)
  }
  qui `noisily' di `"mata: i_pois("`lhs'", "`rhs1'", "`insts1'", "`offset'", "`touse'", "`b'", "`V'")"'
  cap `noisily' mata: i_pois("`lhs'", "`rhs1'", "`insts1'", "`offset'", "`touse'", "`b'", "`V'")
  if _rc {
    di as err "Initial values not feasible, starting over with b=0"
    mat `b'=0*`b'
    qui `noisily' mata: i_pois("`lhs'", "`rhs1'", "`insts1'", "`offset'", "`touse'", "`b'", "`V'")
    }
  qui count if `touse'
  loc N = r(N)
  eret post `b' `V', esample(`touse')
  ereturn scalar N = `N'
  ereturn local depvar "`lhs'"
  ereturn local version "1.1.5"
  ereturn local cmd "ivpois"
  ereturn local properties "b V"
  eret di, eform(`eform') level(`level')
 }
end
version 10
mata:
 void iv_pois(todo,b,crit,g,H)
 {
  external y,X,Z,W,offset
  m=((1/rows(Z))*cross(Z,((y:*exp(-X*b'-offset):- 1))))
  crit=cross(m,W)*m
  g=(2/rows(Z))*cross(m,W)*cross(Z,(y :* exp(-X*b'-offset) :* (-X)))
 }
 void i_pois(string scalar depvar, string scalar x, string scalar z, string scalar o, string scalar tousename, string scalar beta, string scalar var)
 {
  external y,X,Z,W,offset
  y = st_data(., tokens(depvar), tousename)
  X1 = st_data(., tokens(x), tousename)
  Z1 = st_data(., tokens(z), tousename)
  offset = st_data(., tokens(o), tousename)
  cons=J(rows(X1),1,1)
  X = X1, cons
  Z = Z1, cons
  W=rows(Z)*cholinv(quadcross(Z,Z))
  init=st_matrix(beta)
  S=optimize_init()
  optimize_init_evaluator(S, &iv_pois())
  optimize_init_which(S,"min")
  optimize_init_evaluatortype(S,"d1")
  optimize_init_params(S,init)
  p = optimize(S)
  D = (1/rows(Z))*cross(Z,(y :* exp(-X*p'-offset) :* (-X)))
  G = cross(D,W)*D
  _invsym(G)
  M = Z :* ((y :* exp(-X*p'-offset) :- 1))
  Sigma = cross(M,M)/(rows(Z))
  Var = cross(D,W)*Sigma*cross(W,D)
  vce = cross(G,Var)*G/(rows(Z))
  st_replacematrix(beta,p)
  st_replacematrix(var,vce)
  }
end
