*! xtdolshm version 2.0
*! Performs panel data cointegration regression
*! Diallo Ibrahima Amadou
*! All comments are welcome, 16May2015






/* MAIN PROGRAM */

capture program drop xtdolshm
program xtdolshm, eclass byable(recall) sortpreserve
            version 10
            local options "Level(cilevel)"
            if replay() {
                         if "`e(cmd)'" != "xtdolshm" {
                                                      error 301
                         }
                         syntax [, `options']
            }
            else {
                  syntax varlist(ts) [if] [in] [, NLAgs(integer 2) NLEads(integer 1) `options' ]
                  marksample touse
                  qui count if `touse'
                  if r(N) == 0 {
                                di as err "No observations."
                                exit 2000
                  }
                  tempvar count
                  qui {
                       tsset
                       local ivar "`r(panelvar)'"
                       if "`ivar'" == "" {
                                          di as err "You must tsset the data: specify the panel and time variables."
                                          exit 459
                       }
                       bysort `touse' `ivar': gen long `count' = _N
                       sum `count' if `touse', meanonly
                       tempvar  mc
                       gen `mc' = .
                       replace `mc' = 1 if `count' == r(max) & `touse'
                       markout `touse' `mc'
                  }
                  gettoken first rest : varlist
                  qui tsset
                  _rmcoll `rest' if `touse'
                  local rest `r(varlist)'
                  qui tsset
                  local nrlags "`nlags'"
                  local nrleads "`nleads'"
                  ereturn clear
                  mata: _mz_dolsrd("`first'", "`rest'", "`r(panelvar)'","`touse'",`nrlags',`nrleads')
            }
            local sch = cond(!replay() , 0, 1)
            display
            DisplayDOLS, level(`level') sch(`sch')
            ereturn local cmdline "xtdolshm `0'"
end






/* DISPLAYS THE RESULTS */

program define DisplayDOLS, eclass sortpreserve
        syntax [, Level(cilevel) SCHwitch(integer 0) ]

        tempname bhat vce nng rr2 rr2a nlag nlead W  pvW omega12
        tempvar Ti touse

        local le "`level'"
        if `schwitch' == 1 {
                            matrix define `bhat' = e(b)
                            matrix define `vce' = e(V)
                            gen `touse' = e(sample)
        }
        else {
              matrix define `bhat' = e(bb)
              matrix define `vce' = e(VV)
              local touse = e(touse)
        }
        local nn = e(N)
        scalar `nng' = e(N_g)
        scalar `rr2' = e(r2)
        scalar `rr2a' = e(r2_a)
        local yy "`e(depvar)'"
        local ivar "`e(ivar)'"
        local k1 = e(k1)
        local T = e(T)
        scalar `nlag' =  e(nlags)
        scalar `nlead' = e(nleads)
        scalar `W' = e(chi2)
        scalar `pvW' = e(chi2_p)
        matrix define `omega12' = e(omega_1_2)
        ereturn clear
        sort `ivar'
        qui {
             preserve
             keep if `touse'
             by `ivar': gen long `Ti' = _N if _n ==_N
             summ `Ti'
             restore
        }
        local g_min "`r(min)'"
        local g_avg "`r(mean)'"
        local g_max "`r(max)'"
        ereturn clear
        ereturn post `bhat' `vce', esample(`touse')
        di _n in gr "DOLS Hom. Panel data Coint. Estimation results"                   _col(49) in gr "Number of obs" _col(68) "=" _col(70) in ye %9.0f `nn'
        di in gr "Group variable: " in ye abbrev("`ivar'",12)                         in gr _col(49) "Number of groups" _col(68) "=" _col(70) in ye %9.0g `nng'
        di in gr "Wald chi2(" as res `k1' as txt ")" _col(15) "= " as res %9.2f `W'   in gr _col(49) "Obs per group: min = " _col(70) in ye %9.0g `g_min'
        di in gr "Prob > chi2" _col(15) "=" as res %10.3f `pvW'                       in gr _col(49) "               avg = " _col(70) in ye %9.0g `g_avg'
        di in gr _col(49) "               max = " _col(70) in ye %9.0g `g_max'
        di in gr _col(49) "R-squared          =    " in ye %6.4f `rr2'
        di in gr _col(49) "Adj R-squared      =   " in ye %6.4f `rr2a'
        ereturn display, level(`le')
        ereturn matrix omega_1_2 `omega12'
        ereturn local depvar "`yy'"
        ereturn local ivar "`ivar'"
        ereturn scalar N = `nn'
        ereturn scalar k1 = `k1'
        ereturn scalar T = `T'
        ereturn scalar N_g = `nng'
        ereturn scalar r2 = `rr2'
        ereturn scalar r2_a = `rr2a'
        ereturn scalar g_avg = `g_avg'
        ereturn scalar g_min = `g_min'
        ereturn scalar g_max = `g_max'
        ereturn scalar nlags =  `nlag'
        ereturn scalar nleads = `nlead'
        ereturn scalar chi2 = `W'
        ereturn scalar chi2_p = `pvW'
        ereturn local predict xtdolshm_p
        ereturn local cmd "xtdolshm"
end






/*************************** PERFORMS THE DOLS ESTIMATIONS *****************************/
// This program is a MATA adaptation of the GAUSS original program of
// Chiang, M-H. and C. Kao(2002) " Nonstationary Panel Time Series Using NPT 1.3 -
// A User Guide," Center for Policy Research, Syracuse University.
// To keep the presentation simple and comparable to the original program, the notations
// are left as in the original program, which is downloadable at:
// http://faculty.maxwell.syr.edu/cdkao/working/npt.html
/***************************************************************************************/

mata:

void _mz_dolsrd(string scalar first, string scalar rest, string scalar panelvar,string scalar touse, real scalar nblags, real scalar nbleads)
{
              real matrix x0, x, y01, x01, info, temp_x1, x1, dif_x1, Dif_x1_cum, temp_x1_dols, x1_dols, temp_dif_x1, vb1, es1, ts1, /*
                      */ temp_D_resi_1, Dif_resi_1, /*
                      */ uk, ke, ini1, temp_sigma, ini2, amat_1, sigma_1, lr_var_1, epsilon_1, delta_1, /*
                      */ del_eps_1, DOLS_cov, R, r, num, tse, omega1_2, DOLS_cov_bon
              real colvector y0, pvar, y, b1, u1, tb1, DOLS_beta, u1_dols, y_dols
              real rowvector s, del_mu_eps_1, mu_eps_1
              string rowvector lvx
              string scalar lvy, lvp
              real scalar N, T, k1, lags, leads, Rsquare_1, Adjust_Rsquare_1, tss1, ess1, mu_1, mu_dot_eps_1, panel_kernel_lag_hom, /*
                         */  dof, ntot, W, pvW, scal1, DOLS_t_calc
              string matrix sg1



              lvy = tokens(first); lvx = tokens(rest); lvp = tokens(panelvar);
              st_view(y0,., lvy, touse);  st_view(x0,., st_tsrevar(lvx), touse); st_view(pvar,., lvp, touse)
              y01 = (pvar,y0); x01 = (pvar,x0)
              info = panelsetup(y01, 1, 2, 0); s = panelstats(info)
              N = s[1]; T = s[4]; k1 = cols(x0)
              y = mz_panrowshape(y01, 1, "KC", 1)
              x = mz_panrowshape(x01, 1, "KC", 1)
              lags  = nblags
              leads = nbleads
              y_dols = vec(mz_trimrows(y,(lags + 1),leads))
              y = y - mz_reshape(mean(y), T, N); y = vec(y)
              temp_x1 = J((T*N),1, missingof(x))
              for (i=1; i<=k1; i++) {
                                     temp_x1 = (temp_x1,vec(x[|1,(1+(i-1)*N)\.,(i*N)|]- mz_reshape(mean(x[|1,(1+(i-1)*N)\.,(i*N)|]),T,N)))
              }
              x1 = temp_x1[.,(2.. cols(temp_x1))]


              Dif_x1_cum = J((N*(T-1-(leads+lags))),1,missingof(x))
              dif_x1 = x[(2::rows(x)),.] - mz_trimrows(mz_decalen(x,1),1,0)
              for (i=0; i<=(leads+lags); i++) {
                                               if (i != lags) {
                                                               for (j=1; j<=k1; j++) {
                                                                                      Dif_x1_cum = (Dif_x1_cum,vec(mz_trimrows(dif_x1[|1,(1+(j-1)*N)\.,(j*N)|],i,(leads + lags - i))))
                                                               }
                                               }
              }
              temp_x1_dols = J((N*(T-1-(leads+lags))),1,missingof(x))
              for (j=1; j<=k1; j++) {
                                     temp_x1_dols = (temp_x1_dols,vec(mz_trimrows(x[|1,(1+(j-1)*N)\.,(j*N)|],(lags+1),leads)))
              }
              x1_dols = (vec(J((T-(leads+lags+1)),N,1)),temp_x1_dols[.,(2.. cols(temp_x1_dols))],Dif_x1_cum[.,(2.. cols(Dif_x1_cum))])

              temp_dif_x1 = J((N*(T-1)),1,missingof(x))
              for (i=1; i<=k1; i++) {
                                     temp_dif_x1 = (temp_dif_x1,vec(dif_x1[|1,(1+(i-1)*N)\.,(i*N)|]))
              }
              dif_x1 = temp_dif_x1[.,(2.. cols(temp_dif_x1))]
              b1 = invsym(cross(x1, x1))*cross(x1, y)
              u1 = y - x1*b1
              vb1 = invsym(cross(x1, x1))*(cross(u1,u1)/(N*T-k1))
              tb1 = b1:/diagonal(sqrt(vb1))
              es1 = mz_reshape(u1,N,T)'; ess1 = colsum((T-1)*(mz_stdc(es1):*mz_stdc(es1)))'
              ts1 = mz_reshape(y,N,T)';  tss1 = colsum((T-1)*(mz_stdc(ts1):*mz_stdc(ts1)))'
              Rsquare_1 = 1-ess1/tss1
              Adjust_Rsquare_1 = 1-((cross(u1,u1)/(N*T-k1))/(tss1/(N*T)))
              temp_D_resi_1 = mz_reshape(u1,N,T)
              Dif_resi_1 = temp_D_resi_1[.,(2.. T)]'
              ini1 = ini2 = amat_1 = sigma_1 = lr_var_1 /*
              */ = J((cols(dif_x1) + 1),(cols(dif_x1) + 1),0)
              panel_kernel_lag_hom = 5

              for (i=1; i<=N; i++) {
                                    uk = (Dif_resi_1[.,i],dif_x1[|(1+(i-1)*(T-1)),1\(i*(T-1)),.|])
                                    ke = mz_fejer(uk, panel_kernel_lag_hom)
                                    ini1 = ini1 + ke
                                    temp_sigma = cross(uk,uk)/rows(uk)
                                    ini2 = ini2 + temp_sigma
              }

              amat_1 = ini1/N
              sigma_1 = ini2/N
              lr_var_1 = sigma_1 + amat_1 + amat_1'
              epsilon_1 = lr_var_1[(2::rows(lr_var_1)),(2.. cols(lr_var_1))]
              delta_1 = sigma_1 + amat_1
              del_mu_eps_1 = delta_1[1,(2.. cols(delta_1))]
              del_eps_1 = delta_1[(2::rows(delta_1)),(2.. cols(delta_1))]
              mu_1 = lr_var_1[1,1]
              mu_eps_1 = lr_var_1[1,(2.. cols(lr_var_1))]
              mu_dot_eps_1 = mu_1 - mu_eps_1*qrinv(epsilon_1)*mu_eps_1'
              DOLS_beta = invsym(cross(x1_dols, x1_dols))*cross(x1_dols, y_dols)
              DOLS_cov = 6*qrinv(epsilon_1)*mu_dot_eps_1
              DOLS_cov_bon = DOLS_cov/((sqrt(N)*(T - (leads + lags + 1)))^2)
              u1 = y_dols - x1_dols*DOLS_beta
              u1_dols = y - x1*DOLS_beta[|2\(k1+1)|]
              es1 = mz_reshape((x1_dols*DOLS_beta),N,(T-(leads + lags + 1)))'
              ess1 = colsum((T - (leads + lags + 2))*(mz_stdc(es1) :* mz_stdc(es1)))'
              ts1 = mz_reshape(y_dols,N,(T - (leads + lags + 1)))'
              tss1 = colsum((T - (leads + lags + 2))*(mz_stdc(ts1) :* mz_stdc(ts1)))'
              Rsquare_1 = ess1/tss1
              Adjust_Rsquare_1 = 1 - /*
                   */ ((cross(u1,u1)/(N*(T - (leads + lags + 1)) - N - k1 - (lags + leads )*k1))/ /*
                   */ (tss1/(N*(T - (leads + lags + 1)) - N)))
              omega1_2 = mu_dot_eps_1
              ntot = N*(T-(leads + lags + 1))
              DOLS_betaf = DOLS_beta[|2\(k1+1)|]'
              R = I(k1)
              r = J(k1,1,0)
              W = (1/6)*N*((T - (leads + lags + 1))^2)*((R*DOLS_betaf'-r)')*qrinv(R*qrinv(epsilon_1)*mu_dot_eps_1*R')*(R*DOLS_betaf'-r)
              pvW = chi2tail(k1, W)
              st_matrix("e(bb)", DOLS_betaf)
              st_matrix("e(VV)", DOLS_cov_bon)
              st_matrix("e(omega_1_2)",omega1_2)
              st_global("e(touse)", touse)
              sg1 = ("")
              sg2 = (mz_reshape(sg1,k1,1), lvx')
              st_matrixcolstripe("e(bb)", sg2)
              st_matrixcolstripe("e(VV)", sg2)
              st_matrixrowstripe("e(VV)", sg2)
              st_numscalar("e(N)", ntot)
              st_numscalar("e(N_g)", N)
              st_numscalar("e(r2)", Rsquare_1)
              st_numscalar("e(r2_a)", Adjust_Rsquare_1)
              st_global("e(depvar)", lvy)
              st_global("e(ivar)", lvp)
              st_numscalar("e(T)", T)
              st_numscalar("e(k1)", k1)
              st_numscalar("e(nlags)", lags)
              st_numscalar("e(nleads)", leads)
              st_numscalar("e(chi2)", W)
              st_numscalar("e(chi2_p)", pvW)
}


real matrix mz_fejer(real matrix x, real scalar k)
{
     real matrix t1, t2, a
     real scalar i, m, f
     a = J(cols(x),cols(x),0)
     for(i=1; i<=k; i++) {
                          f = i/(k+1)
                          m = 1 - f
                          t1 = mz_trimrows(x,i,0)
                          t2 = mz_trimrows(mz_decalen(x,i),i,0)
                          a = a + m*cross(t1,t2)
     }
     return(a/rows(x))
}



end




