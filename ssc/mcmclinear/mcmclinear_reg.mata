version 12.0
mata:
mata set matastrict on
mata set matafavor speed

/* version 1.0, 4 jan 2012 */
/* sam schulhofer-wohl, federal reserve bank of minneapolis */

/* gibbs sampling for linear regression */
void mcmclinear_reg(string scalar yy, string scalar xx, 
  real scalar iters, real scalar seed, real scalar d0, 
  real scalar useconstant, string scalar ww, real scalar useweight,
  real scalar weight_is_aweight, real scalar showiter, real scalar usex)
  {

  /* declarations */
  real matrix y, x, w, wsqrt, xPx, xPy, betahat, xPx_ci, myP2x, beta, beta_out, sigma2_out
  real scalar Kx, lx, df, yPy, sigma, invsig2, iter, i, sigma2

  /* set seed */
  rseed(seed)

  /* find data */
  y=st_data(.,yy)
  if(usex) x=st_data(.,xx)
  if(useweight) w=st_data(.,ww)

  /* transform data if we have aweights */
  if(weight_is_aweight & useweight) {
    wsqrt=sqrt(w)
    y=y:*wsqrt
    if(useconstant) {
      if(usex) x=(x,J(rows(x),1,1)):*wsqrt
      else {
        x=wsqrt
        usex=1
        }
      useconstant=0
      }
    else x=x:*wsqrt /* always have either useconstant or usex */
    useweight=0
    }

  /* useful scalars */
  if(usex) Kx=cols(x)
  else Kx=0
  if(useconstant) lx=Kx+1
  else lx=Kx

  /* precalculate matrices used repeatedly */
  if(useweight) {
    if(usex) {
      xPx=quadcross(x,useconstant,w,x,useconstant)
      xPy=quadcross(x,useconstant,w,y,0)
      }
    else {
      xPx=quadsum(w)
      xPy=quadcross(w,y)
      }    
    yPy=quadcross(y,w,y)
    }
  else {
    if(usex) {
      xPx=quadcross(x,useconstant,x,useconstant)
      xPy=quadcross(x,useconstant,y,0)
      }
    else {
      xPx=rows(y)
      xPy=quadsum(y)
      }
    yPy=quadcross(y,y)
    }
  xPx_ci=cholesky(luinv(xPx))
  myP2x=-2*xPy'
  betahat=lusolve(xPx,xPy)
  if(useweight) df=(quadsum(w)+1)/2
  else df=(rows(y)+1)/2

  /* set up initial guess for sigma2 */
  /* changing seed will change this initial guess, so you can get different chains */
  /* this is the only relevant initial guess */
  invsig2=rgamma(1,1,df,2/(yPy+(myP2x+betahat'*xPx)*betahat+d0))
  sigma2=1/invsig2
  sigma=sqrt(sigma2)

  /* matrices to store results */
  beta_out=(betahat'\J(iters,lx,0))
  sigma2_out=(sigma2\J(iters,1,0))

  /* run the gibbs sampler */
  for(iter=1;iter<=iters;iter++) {

    if(showiter) {
      display("iteration "+strofreal(iter))
      displayflush()
      }

    /* 1. draw beta */
    beta=betahat+sigma*xPx_ci*rnormal(lx,1,0,1)
    beta_out[iter+1,.]=beta'

    /* 2. draw sigma2 */
    invsig2=rgamma(1,1,df,2/(yPy+(myP2x+betahat'*xPx)*betahat+d0))
    sigma2=1/invsig2
    sigma=sqrt(sigma2)
    sigma2_out[iter+1,1]=sigma2

    }

  /* return results */
  stata("drop _all")
  st_addobs(iters+1)
  for(i=1;i<=lx;i++) {
    (void) st_addvar("double","beta"+strofreal(i))
    }
  st_store(.,range(1,lx,1)',beta_out)
  (void) st_addvar("double","sigma2")
  st_store(.,lx+1,sigma2_out)

  }

end
