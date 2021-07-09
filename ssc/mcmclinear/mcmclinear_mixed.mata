version 12.0
mata:
mata set matastrict on
mata set matafavor speed

/* version 1.0, 5 jan 2012 */
/* sam schulhofer-wohl, federal reserve bank of minneapolis */

/* gibbs sampling for linear mixed model */
void mcmclinear_mixed(string scalar yy, string scalar xx, string scalar zz,
  string scalar gg, real scalar iters, real scalar seed, real scalar d0, string scalar ddelta0,
  real scalar useconstant_fe, real scalar useconstant_re,
  string scalar ww_fe, real scalar useweight_fe,
  real scalar feweight_is_aweight, 
  real scalar showiter, real scalar N_g, string scalar sigrownames, string scalar sigcolnames,
  real scalar usex, real scalar usez)
  {

  /* declarations */
  real matrix y, x, z, g, w_fe, wsqrt_fe, beta, beta_out, sigma2_out, Sigma_out, theta_g_out, ginfo, 
    xPx_g, zPz_g, xPy_g, xPz_g, zPxy_g, zPy_g, zPx_g, m2yPx_g, m2yPz_g, xP2z_g,
    work_x, work_y, work_z, work_w, invsigma2_zPz_g, invsigma2_zPxy_g, theta_g, Sigma, work, D, Dy, E, Sigmainv, delta0
  real scalar Kx, lx, df, sigma2, invsig2, iter, i, gi, Kz, lz, chi_sig2eps_start, chi_sig2eps, usecfetemp, usecretemp

  /* set seed */
  rseed(seed)

  /* find data */
  y=st_data(.,yy)
  if(usex) x=st_data(.,xx)
  if(usez) z=st_data(.,zz)
  g=st_data(.,gg)
  if(useweight_fe) w_fe=st_data(.,ww_fe)
  delta0=st_matrix(ddelta0)

  /* set up panel identifiers */
  ginfo=panelsetup(g,1)

  /* transform data if we have aweights */
  if(feweight_is_aweight & useweight_fe) {
    wsqrt_fe=sqrt(w_fe)
    y=y:*wsqrt_fe
    if(useconstant_fe) {
      if(usex) x=(x,J(rows(x),1,1)):*wsqrt_fe
      else {
        x=wsqrt_fe
        usex=1
        }
      useconstant_fe=0
      }
    else x=x:*wsqrt_fe   /* always have either useconstant_fe or usex */
    useweight_fe=0
    }

  /* useful scalars */
  if(usex) Kx=cols(x)
  else Kx=0
  if(useconstant_fe) lx=Kx+1
  else lx=Kx
  if(usez) Kz=cols(z)
  else Kz=0
  if(useconstant_re) lz=Kz+1
  else lz=Kz

  /* precalculate matrices used repeatedly */
  xPx_g=J(lx,lx*N_g,.)
  zPz_g=J(lz,lz*N_g,.)
  xPy_g=J(lx,N_g,.)
  xPz_g=J(lx,lz*N_g,.)
  zPy_g=J(lz,N_g,.)
  zPx_g=J(lz,lx*N_g,.)
  zPxy_g=J(lz,(lx+1)*N_g,.)
  m2yPx_g=J(N_g,lx,.)
  m2yPz_g=J(N_g,lz,.)
  xP2z_g=J(lx,N_g*lz,.)
  if(usex) usecfetemp=useconstant_fe
  else usecfetemp=0
  if(usez) usecretemp=useconstant_re
  else usecretemp=0
  for(gi=1;gi<=N_g;gi++) {
    work_y=y[|ginfo[gi,1],1\ginfo[gi,2],1|]
    if(usex) work_x=x[|ginfo[gi,1],1\ginfo[gi,2],.|]
    else work_x=J(rows(work_y),1,1)
    if(usez) work_z=z[|ginfo[gi,1],1\ginfo[gi,2],.|]
    else work_z=J(rows(work_y),1,1)
    if(useweight_fe) {
      work_w=w_fe[|ginfo[gi,1],1\ginfo[gi,2],1|]
      xPx_g[|1,(gi-1)*lx+1\.,gi*lx|]=quadcross(work_x, usecfetemp,work_w,work_x, usecfetemp)
      xPy_g[.,gi]=quadcross(work_x, usecfetemp,work_w,work_y,0)
      xPz_g[|1,(gi-1)*lz+1\.,gi*lz|]=quadcross(work_x, usecfetemp,work_w,work_z, usecretemp)
      zPy_g[.,gi]=quadcross(work_z, usecretemp,work_w,work_y,0)
      zPz_g[|1,(gi-1)*lz+1\.,gi*lz|]=quadcross(work_z, usecretemp,work_w,work_z, usecretemp)
      }
    else {
      xPx_g[|1,(gi-1)*lx+1\.,gi*lx|]=quadcross(work_x, usecfetemp,work_x, usecfetemp)
      xPy_g[.,gi]=quadcross(work_x, usecfetemp,work_y,0)
      xPz_g[|1,(gi-1)*lz+1\.,gi*lz|]=quadcross(work_x, usecfetemp,work_z, usecretemp)
      zPy_g[.,gi]=quadcross(work_z, usecretemp,work_y,0)
      zPz_g[|1,(gi-1)*lz+1\.,gi*lz|]=quadcross(work_z, usecretemp,work_z, usecretemp)
      }
    zPx_g[|1,(gi-1)*lx+1\.,gi*lx|]=xPz_g[|1,(gi-1)*lz+1\.,gi*lz|]'
    zPxy_g[|1,(gi-1)*(lx+1)+1\.,gi*(lx+1)|]=(zPx_g[|1,(gi-1)*lx+1\.,gi*lx|],zPy_g[.,gi])
    }
  m2yPx_g=-2:*xPy_g'
  m2yPz_g=-2:*zPy_g'
  xP2z_g=2:*xPz_g
  if(useweight_fe) chi_sig2eps_start=d0+quadcross(y,w_fe,y)
  else chi_sig2eps_start=d0+quadcross(y,y)
  if(useweight_fe) df=(quadsum(w_fe)+1)/2
  else df=(rows(y)+1)/2

  /* set up initial guesses for sigma2 and Sigma */
  /* strategy here is to guess beta and theta_g by running regressions, then draw random estimates of sigma2 and Sigma based on the guesses for beta and theta_g */
  /* the guesses for sigma2 and Sigma are all that matter for initializing the chain; thus, different seeds give you different chains */
  if(useweight_fe) {
    if(usex) beta=cholsolve(quadcross(x,useconstant_fe,w_fe,x,useconstant_fe),quadcross(x,useconstant_fe,w_fe,y,0))
    else beta=mean(y,w_fe)
    }
  else {
    if(usex) beta=cholsolve(quadcross(x,useconstant_fe,x,useconstant_fe),quadcross(x,useconstant_fe,y,0))
    else beta=mean(y)
    }
  theta_g=J(lz,N_g,0)
  for(gi=1;gi<=N_g;gi++) {
    E=cholinv(delta0)+(1/d0):*zPz_g[|1,(gi-1)*lz+1\.,gi*lz|]
    theta_g[.,gi]=cholsolve(E,(1/d0):*(zPxy_g[.,gi*(lx+1)]-zPxy_g[|1,(gi-1)*(lx+1)+1\.,gi*(lx+1)-1|]*beta))+cholesky(cholinv(E))*rnormal(lz,1,0,1)      
    }
  work=(cholesky(luinv(delta0+quadcross(theta_g',theta_g')))*rnormal(lz,1+N_g,0,1))'
  Sigmainv=quadcross(work,work)
  Sigma=luinv(Sigmainv)
  chi_sig2eps=chi_sig2eps_start
  work=J(1,lx,0)
  for(gi=1;gi<=N_g;gi++) {
    work=work+m2yPx_g[gi,.]+beta'*xPx_g[|1,(gi-1)*lx+1\.,gi*lx|]
    chi_sig2eps=chi_sig2eps+(m2yPz_g[gi,.]+beta'*xP2z_g[|1,(gi-1)*lz+1\.,gi*lz|]+theta_g[.,gi]'*zPz_g[|1,(gi-1)*lz+1\.,gi*lz|])*theta_g[.,gi]
    }
  invsig2=rgamma(1,1,df,2/(chi_sig2eps+work*beta))
  sigma2=1/invsig2

  /* matrices to store results */
  beta_out=(beta'\J(iters,lx,0))
  theta_g_out=(vec(theta_g)'\J(iters,lz*N_g,0))
  sigma2_out=(sigma2\J(iters,1,0))
  Sigma_out=(vech(Sigma)'\J(iters,lz*(lz+1)/2,0))

  /* run the gibbs sampler */
  for(iter=1;iter<=iters;iter++) {

    if(showiter) {
      display("iteration "+strofreal(iter))
      displayflush()
      }

    /* 1. matrices used repeatedly */
    invsigma2_zPz_g=invsig2:*zPz_g
    invsigma2_zPxy_g=invsig2:*zPxy_g

    /* 2. draw beta */
    D=J(lx,lx,0)
    Dy=J(lx,1,0)
    for(gi=1;gi<=N_g;gi++) {
      work=xPz_g[|1,(gi-1)*lz+1\.,gi*lz|]*cholsolve(Sigmainv+invsigma2_zPz_g[|1,(gi-1)*lz+1\.,gi*lz|],invsigma2_zPxy_g[|1,(gi-1)*(lx+1)+1\.,gi*(lx+1)|])
      D=D+xPx_g[|1,(gi-1)*lx+1\.,gi*lx|]-work[|1,1\.,lx|]
      Dy=Dy+xPy_g[.,gi]-work[.,lx+1]
      }
    beta=cholsolve(D,Dy)+cholesky(cholinv(D))*rnormal(lx,1,0,sqrt(sigma2))
    beta_out[iter+1,.]=beta'

    /* 3. draw theta_g */
    for(gi=1;gi<=N_g;gi++) {
      E=Sigmainv+invsigma2_zPz_g[|1,(gi-1)*lz+1\.,gi*lz|]
      theta_g[.,gi]=cholsolve(E,invsigma2_zPxy_g[.,gi*(lx+1)]-invsigma2_zPxy_g[|1,(gi-1)*(lx+1)+1\.,gi*(lx+1)-1|]*beta)+cholesky(cholinv(E))*rnormal(lz,1,0,1)      
      } 
    theta_g_out[iter+1,.]=vec(theta_g)' 

    /* 4. draw Sigma */
    work=(cholesky(luinv(delta0+quadcross(theta_g',theta_g')))*rnormal(lz,1+N_g,0,1))'
    Sigmainv=quadcross(work,work)
    Sigma=luinv(Sigmainv) 
    Sigma_out[iter+1,.]=vech(Sigma)'

    /* 5. draw sigma2 */
    chi_sig2eps=chi_sig2eps_start
    work=J(1,lx,0)
    for(gi=1;gi<=N_g;gi++) {
      work=work+m2yPx_g[gi,.]+beta'*xPx_g[|1,(gi-1)*lx+1\.,gi*lx|]
      chi_sig2eps=chi_sig2eps+(m2yPz_g[gi,.]+beta'*xP2z_g[|1,(gi-1)*lz+1\.,gi*lz|]+theta_g[.,gi]'*zPz_g[|1,(gi-1)*lz+1\.,gi*lz|])*theta_g[.,gi]
      }
    invsig2=rgamma(1,1,df,2/(chi_sig2eps+work*beta))
    sigma2=1/invsig2
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
  for(i=1;i<=lz*N_g;i++) {
    (void) st_addvar("double","theta"+strofreal(i))
    }
  st_store(.,range(lx+2,lx+1+lz*N_g,1)',theta_g_out)
  for(i=1;i<=cols(Sigma_out);i++) {
    (void) st_addvar("double","Sigma"+strofreal(i))
    }
  st_store(.,range(lx+1+lz*N_g+1,lx+1+lz*N_g+cols(Sigma_out),1)',Sigma_out)

  st_matrix(sigrownames,vech(range(1,lz,1)#J(1,lz,1)))
  st_matrix(sigcolnames,vech(J(lz,1,1)#(range(1,lz,1)')))

  }

end
