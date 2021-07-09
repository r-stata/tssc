*! version 2.0
*! Predict program for the command xtdolshm
*! Diallo Ibrahima Amadou
*! All comments are welcome, 16May2015





capture program drop xtdolshm_p
program xtdolshm_p, eclass sortpreserve
        version 10
	syntax anything(id="newvarname") [if] [in] [, DOLSRes xb ]

	if "`dolsres'" != "" {
		syntax newvarname [if] [in] [, DOLSRes ]
		local lignecom = e(cmdline)
		local nomcom = e(cmd)
		gettoken firstsansv restoptions : lignecom, parse(",")
		local lesvariables: list firstsansv - nomcom
                quietly {
                         tsset
                         local panelvarrs "`r(panelvar)'"
                         local timevarrs  "`r(timevar)'"
                         tempfile maindata sampledata
                         sort `panelvarrs' `timevarrs'
                         save `maindata',replace
                         return clear
                         capture drop _myztouse
                         sampleselectkk `lesvariables' `if' `in', zvarsel(_myztouse)
                         makedolsres `lesvariables'  `if' `in'
                         keep if _myztouse == 1
                         tempname matres
                         matrix define `matres' = r(u1_dols)
                         capture drop _kkandecaba1
                         svmat `typlist' `matres', names(_kkandecaba)
                         gen `typlist' `varlist'  = _kkandecaba1 `if' `in'
                         label variable `varlist' "Dols residuals"
                         capture drop _kkandecaba1
                         capture drop _myztouse
                         sort `panelvarrs' `timevarrs'
                         keep `panelvarrs' `timevarrs' `varlist'
                         save `sampledata',replace
                         capture clear
                         quietly use `maindata', clear
                         merge `panelvarrs' `timevarrs' using `sampledata'
                         drop _merge
                         count if `varlist' >= .
                         local nbmissres = r(N)
                }
                display as text "(`nbmissres' missing values generated)"
                return clear
                exit
	}



	syntax newvarname [if] [in] [, xb ]
	_predict `typlist' `varlist' `if' `in', xb
	label variable `varlist' "Linear prediction from the long-run coefficients"
end





program sampleselectkk, eclass sortpreserve
        syntax varlist(ts) [if] [in], zvarsel(string)
        marksample touse
        tempvar count
        qui {
             tsset
             local ivar "`r(panelvar)'"
             bysort `touse' `ivar': gen long `count' = _N
             sum `count' if `touse', meanonly
             tempvar  mc
             gen `mc' = .
             replace `mc' = 1 if `count' == r(max) & `touse'
             markout `touse' `mc'
             rename `touse' `zvarsel'
        }

end





program makedolsres, eclass sortpreserve
        syntax varlist(ts) [if] [in]
        marksample touse
        qui count if `touse'
        tempvar count
        qui {
             tsset
             local ivar "`r(panelvar)'"
             bysort `touse' `ivar': gen long `count' = _N
             sum `count' if `touse', meanonly
             tempvar  mc
             gen `mc' = .
             replace `mc' = 1 if `count' == r(max) & `touse'
             markout `touse' `mc'
             tokenize `varlist'
             local first `1'
             macro shift
             local rest `*'
             tsset
             local nrlags = e(nlags)
             local nrleads = e(nleads)
             tsset
        }
        mata: _mz_dolsres("`first'", "`rest'", "`r(panelvar)'","`touse'",`nrlags',`nrleads')
end



mata:
void _mz_dolsres(string scalar first, string scalar rest, string scalar panelvar,string scalar touse, real scalar nblags, real scalar nbleads)
{
              real matrix x0, x, y01, x01, info, temp_x1, x1, temp_x1_dols, x1_dols, Dif_x1_cum, dif_x1
              real colvector y0, pvar, y, DOLS_beta, u1_dols, y_dols
              real rowvector s
              string rowvector lvx
              string scalar lvy, lvp
              real scalar N, T, k1, lags, leads


              lvy = tokens(first); lvx = tokens(rest); lvp = tokens(panelvar);
              st_view(y0,., lvy, touse);  st_view(x0,., st_tsrevar(lvx), touse); st_view(pvar,., lvp, touse);
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

              DOLS_beta = invsym(cross(x1_dols, x1_dols))*cross(x1_dols, y_dols)
              u1_dols = y - x1*DOLS_beta[|2\(k1+1)|]
              st_matrix("r(u1_dols)",u1_dols)


}

end





