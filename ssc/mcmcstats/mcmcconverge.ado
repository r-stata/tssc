program mcmcconverge

  version 12.1

  *Gelman-Carlin-Stern-Rubin convergence statistics for mcmc chains
  * varlist: variables to analyze
  * iter: variable identifying iterations of the sampler
  * chain: variable identifying separate chains

  syntax varlist [if] [in], iter(varname) chain(varname) saving(string asis) [replace]

  marksample touse

  preserve

  qui keep `iter' `chain' `varlist' `touse'
  qui keep if `touse'
  
  *check that we still have data
  capture assert _N>0
  if _rc!=0 {
    display("failed: no data satisfy the specifications.")
    exit
    }

  *check that each chain has the same number of obs
  qui xtset `chain' `iter'
  capture assert "`r(balanced)'"!="unbalanced"
  if _rc!=0 {
    display("failed: chains have different numbers of observations.")
    exit
    } 

  *proceed

  qui levelsof `chain', local(usechains)
  local nc : word count `usechains'
  local niters=_N/`nc'
  unab vars : `varlist'
  local nv : word count `vars'

  *means and variances within chains
  mata: mvfun("`vars'","`chain'")
  qui gen double varplus=(B+(`niters'-1)*W)/`niters'
  qui gen double Rhat=sqrt(varplus/W)
  qui gen double neff=`niters'*`nc'*varplus/B
  qui gen double neffmin=min(neff,`niters'*`nc')

  capture lab drop _all
  forvalues i=1/`nv' {
    local v : word `i' of `vars'
    lab def variable `i' "`v'", add
    }
  lab values variable variable
  lab var B "between-sequence variance"
  lab var W "within-sequence variance"
  lab var varplus "marginal posterior variance"
  lab var Rhat "potential scale reduction from further simulations"
  lab var neff "effective number of independent draws"
  lab var neffmin "min(neff,actual number of draws)"

  qui compress
  qui save `saving', `replace'

end



version 12.1
mata:

mata set matastrict on
mata set matafavor speed

void mvfun(string scalar vars, string scalar chain)
  {
  real matrix cvec, cinfo, x, res_m, res_v, work, B
  real scalar c, nc, nx, i
  cvec=st_data(.,chain)
  cinfo=panelsetup(cvec,1)
  nc=rows(cinfo)
  x=st_data(.,vars)
  nx=cols(x)
  res_m=J(nc,nx,0)
  res_v=J(nc,nx,0)
  for(c=1;c<=nc;c++) {
    work=panelsubmatrix(x,c,cinfo)
    res_m[c,.]=mean(work)
    for(i=1;i<=nx;i++) {
      res_v[c,i]=variance(work[.,i])
      }
    }
  stata("qui drop _all")
  st_addobs(nx)
  (void) st_addvar("long","variable")
  st_store(.,1,range(1,nx,1))
  (void) st_addvar("double","B")
  B=J(nx,1,.)
  for(i=1;i<=nx;i++) {
    B[i,1]=variance(res_m[.,i])
    }
  st_store(.,2,B*rows(work))
  (void) st_addvar("double","W")
  st_store(.,3,mean(res_v)')
  }

end
