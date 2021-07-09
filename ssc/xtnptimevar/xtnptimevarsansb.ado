*! xtnptimevarsansb version 1.0.0
*! The evaluator for the command xtnptimevar without bootstrapping
*! Ibrahima Amadou Diallo
*! All comments are welcome, 14Mar2014




capture program drop xtnptimevarsansb
program xtnptimevarsansb, eclass sortpreserve
        version 12.0
        syntax varlist(ts) [if] [in] , STUB(string) [ bwidth(real 999.999) forcereg alle noGRAPHS SAVing(string asis) title(string)  ]
        marksample touse
        quietly count if `touse'
        if r(N) == 0 {
                      di as err "No observations."
                      exit 2000
        }
        tempvar count
        quietly tsset
        local panelvar = r(panelvar)
        local timevar  = r(timevar)
        if "`forcereg'" == "" {
                               quietly _xtstrbal `panelvar' `timevar' `touse'
                               if r(strbal) == "no" {
                                                     di as error "The xtnptimevar command requires strongly balanced data"
                                                     di as error "Or use the forcereg option"
                                                     exit 498
                               }
        }
        else {
             quietly {
                      tsset
                      local ivar "`r(panelvar)'"
                      bysort `touse' `ivar': gen long `count' = _N
                      sum `count' if `touse', meanonly
                      tempvar  mc
                      gen `mc' = .
                      replace `mc' = 1 if `count' == r(max) & `touse'
                      markout `touse' `mc'
             }
        }
        gettoken first rest : varlist
        quietly tsset
        _rmcoll `rest' if `touse'
        local rest `r(varlist)'
        quietly tsset
        local pvarvh "`r(panelvar)'"
        local timevarrma  = r(timevar)
        return clear
        if `bwidth' == 999.999 {
                                mata: _mz_bdwidthm("`rest'", "`pvarvh'", "`touse'")
                                local hh = r(rvh)
        }
        else {
              local hh "`bwidth'"
        }
        quietly tsset
        local ivarpp "`r(panelvar)'"
        display
        display _dup(78) "="
        display "Performing Non-Parametric Panel Data Estimations."
        display "This may take some time, please wait."
        display _dup(78) "="
        display
        ereturn clear
        if "`alle'" == "" {
                           mata: _mz_lldve("`rest'", "`first'", `hh', "`ivarpp'", "`touse'")
        }
        else {
              mata: _mz_lle("`rest'", "`first'", `hh', "`ivarpp'", "`touse'")
        }
        tempname matcoefs nnsc ttsc hhsc kksc nnttsc
        tempvar Ti
        matrix define `matcoefs' = e(M_Ebetastart)
        local touse = e(touse)
        scalar `nnsc'   = e(N)
        scalar `ttsc'   = e(T)
        scalar `hhsc'   = e(h)
        scalar `kksc'   = e(k)
        scalar `nnttsc' = e(NT)
        local yyvr "`e(depvar)'"
        local ivarvr "`e(ivar)'"
        quietly {
                 sort `ivarvr'
                 preserve
                 keep if `touse'
                 by `ivarvr': gen long `Ti' = _N if _n==_N
                 summarize `Ti'
                 restore
        }
        local g_min `r(min)'
        local g_avg `r(mean)'
        local g_max `r(max)'
        ereturn clear
        capture drop `stub'_*
        svmat double `matcoefs', names(`stub'_)
        local nbcoefs = colsof(`matcoefs')
        quietly tsset
        forvalues i = 1(1)`nbcoefs' {
                                     label var `stub'_`i' "Coefficient-Vector `i', original"
        }
        quietly {
                 tsset
                 local labtimevrma: var l `timevarrma'
                 gen `stub'_tvarrma1 = `timevarrma'  if `touse'
                 levelsof `stub'_tvarrma1 if `touse', local(yearlevrma)
                 gen `stub'_tvprime = .
                 local i = 1
                 foreach l of local yearlevrma {
                                                replace `stub'_tvprime = `l' if _n == `i'
                                                local i = `i' + 1
                 }
                 label var `stub'_tvprime "`labtimevrma'"
        }
        if "`graphs'" == "" {
                             quietly {
                                      if `"`saving'"' == "" {
                                                             if "`title'" == "" {
                                                                                 local titlep "Graph of Coefficient-Vector"
                                                             }
                                                             else {
                                                                   local titlep  "`title'"
                                                             }
                                                             forvalues i = 1(1)`nbcoefs' {
                                                                                          local titleps "title("`titlep' `i'")" 
                                                                                          twoway line `stub'_`i' `stub'_tvprime, name(`stub'_`i'_graph, replace) `titleps' sort
                                                             }
                                      }
                                      else {
                                            cd `saving'
                                            if "`title'" == "" {
                                                                local titlep "Graph of Coefficient-Vector"
                                            }
                                            else {
                                                  local titlep  "`title'"
                                            }
                                            forvalues i = 1(1)`nbcoefs' {
                                                                         local titleps "title("`titlep' `i'")"
                                                                         twoway line `stub'_`i' `stub'_tvprime, name(`stub'_`i'_graph, replace) `titleps' sort
                                                                         graph save `stub'_`i'_graphsv, replace
                                            }
                                      }
                             }
        }
        capture drop `stub'_tvarrma1
        ereturn post , esample(`touse')
        ereturn local depvar "`yyvr'"
        ereturn local ivar "`ivarvr'"
        ereturn scalar N       = `nnsc'
        ereturn scalar T       = `ttsc'
        ereturn scalar bwidth  = `hhsc'
        ereturn scalar k       = `kksc'
        ereturn scalar NT      = `nnttsc'
        ereturn scalar g_avg   = `g_avg'
        ereturn scalar g_min   = `g_min'
        ereturn scalar g_max   = `g_max'
        forvalues i = 1(1)`nbcoefs' {
                                     ereturn local seq_`stub'_b_`i' "`stub'_`i'"
        }
        ereturn local seq_`stub'_efftv "`stub'_tvprime"

end

  


mata:



void _mz_bdwidthm(string scalar rest, string scalar panelvar, string scalar touse)
{
              real matrix x0, pvx, info, HHDM
              real colvector pvar, HHV, xvar
              real rowvector s
              real scalar NN, TT, qp, qq, hs, sigm, bdwidval
              string rowvector lvx
              string scalar lvp

              lvx = tokens(rest); lvp = tokens(panelvar);
              st_view(x0,., st_tsrevar(lvx), touse); st_view(pvar,., lvp, touse);
              pvx = (pvar, x0)
              info = panelsetup(pvx, 1, 2, 0); s = panelstats(info);
              NN = s[1]; TT = s[4]; qp = cols(x0); qq = qp;
              HHV = J(qp, 1, missingof(x0))
              for (i=1; i<=qp; i++) {
                                     xvar = x0[.,i]
                                     sigm = sqrt(variance(xvar))
                                     hs = 100.0^(1/(4+qq))*(exp(0.755*qq)/(2+qq))^(1/(4+qq))*sigm*(NN*TT)^(-1/(4+qq))
                                     HHV[i] = hs
              }
              HHDM = diag(HHV)
              bdwidval = det(HHDM)
              st_numscalar("r(rvh)", bdwidval)
}



void _mz_lldve(string scalar rest, string scalar first, real scalar hh, string scalar ivarpp, string scalar touse)
{
              real matrix x0, pyx, info, yxm, ovyx, TX, TD , Est, D, K, W, Wstar, Ebetastar, Ebetastart
              real colvector y0, pvar, TY, S, TS, Sth
              real rowvector s
              real scalar NN, NT, TT, k1, i, M, d, T, h, k
              string rowvector lvx
              string scalar lvy, lvp

              lvx = tokens(rest); lvy = tokens(first);  lvp = tokens(ivarpp);
              st_view(x0,., st_tsrevar(lvx), touse); st_view(y0,., lvy, touse); st_view(pvar,., lvp, touse);
              pyx = (pvar,y0,x0)
              info = panelsetup(pyx, 1, 2, 0); s = panelstats(info);
              NN = s[1]; NT = s[2] ; TT = s[4];
              yxm = pyx[.,(2..cols(pyx))]
              k1 = cols(yxm)
              ovyx = J(NT,k1, missingof(yxm))
              for (i=1; i<=NN; i++) {
                                     ovyx[|(i-1)*TT+1,1\i*TT,.|] = panelsubmatrix(yxm, i, info)
              }
              TX = ovyx[., (2..cols(ovyx))]
              TY = ovyx[., 1]
              M = NT; d = cols(TX); N = NN; T = TT; h = hh;
              S = range(1/T, 1, 1/T)
              TS = J(N, 1, S)
              TD = ((-J(N-1,1,1),I(N-1))')#(J(T,1,1)) 
              Est = J(d+1,T, missingof(ovyx))
              for (k=1; k<=T; k++) {
                                    Sth = (TS - J(M, 1, S[k]))/h
                                    D   = (J(M,1,1), TX, Sth, J(1,d,Sth):*TX)
                                    K   = 0.75*diag( (J(M,1,1)-Sth:^2):*(abs(Sth):<=1) )
                                    W   = I(M) - TD*pinv( TD'*K*TD )*TD'*K
                                    Wstar=W'*K*W
                                    Est[.,k] = ( I(d+1), J(d+1,d+1,0) )* pinv( D'*Wstar*D ) *D'*Wstar*TY
              }
              Ebetastar = Est
              Ebetastart = Ebetastar'
              st_matrix("e(M_Ebetastart)", Ebetastart)
              st_global("e(touse)", touse)
              st_numscalar("e(N)", N)
              st_numscalar("e(T)", T)
              st_numscalar("e(h)", h)
              st_numscalar("e(k)", d)
              st_numscalar("e(NT)", M)
              st_global("e(depvar)", lvy)
              st_global("e(ivar)", lvp)
}




void _mz_lle(string scalar rest, string scalar first, real scalar hh, string scalar ivarpp, string scalar touse)
{
              real matrix x0, pyx, info, yxm, ovyx, TX, Est, D, K, Ebetastar, Ebetastart
              real colvector y0, pvar, TY, S, TS, Sth
              real rowvector s
              real scalar NN, NT, TT, k1, i, M, d, T, h, k
              string rowvector lvx
              string scalar lvy, lvp

              lvx = tokens(rest); lvy = tokens(first);  lvp = tokens(ivarpp);
              st_view(x0,., st_tsrevar(lvx), touse); st_view(y0,., lvy, touse); st_view(pvar,., lvp, touse);
              pyx = (pvar,y0,x0)
              info = panelsetup(pyx, 1, 2, 0); s = panelstats(info);
              NN = s[1]; NT = s[2] ; TT = s[4];
              yxm = pyx[.,(2..cols(pyx))]
              k1 = cols(yxm)
              ovyx = J(NT,k1, missingof(yxm))
              for (i=1; i<=NN; i++) {
                                     ovyx[|(i-1)*TT+1,1\i*TT,.|] = panelsubmatrix(yxm, i, info)
              }
              TX = ovyx[., (2..cols(ovyx))]
              TY = ovyx[., 1]
              M = NT; d = cols(TX); N = NN; T = TT; h = hh;
              S = range(1/T, 1, 1/T)
              TS = J(N, 1, S)
              Est = J(d+1,T, missingof(ovyx))
              for (k=1; k<=T; k++) {
                                    Sth = (TS - J(M, 1, S[k]))/h
                                    D   = (J(M,1,1), TX, Sth, J(1,d,Sth):*TX)
                                    K   = 0.75*diag( (J(M,1,1)-Sth:^2):*(abs(Sth):<=1) )
                                    Est[.,k] = ( I(d+1), J(d+1,d+1,0) )* pinv( D'*K*D ) *D'*K*TY
              }
              Ebetastar = Est
              Ebetastart = Ebetastar'
              st_matrix("e(M_Ebetastart)", Ebetastart)
              st_global("e(touse)", touse)
              st_numscalar("e(N)", N)
              st_numscalar("e(T)", T)
              st_numscalar("e(h)", h)
              st_numscalar("e(k)", d)
              st_numscalar("e(NT)", M)
              st_global("e(depvar)", lvy)
              st_global("e(ivar)", lvp)
}



end



