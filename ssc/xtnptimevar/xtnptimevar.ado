*! xtnptimevar version 1.0.0
*! Performs non-parametric time-varying coefficient panel data regressions
*! Ibrahima Amadou Diallo
*! All comments are welcome, 14Mar2014




capture program drop xtnptimevar
program xtnptimevar, eclass sortpreserve
        version 12.0
        syntax varlist(ts) [if] [in] , STUB(passthru) [ bwidth(passthru) forcereg alle noGRAPHS SAVing(string asis) title(string) bootstrap bootoptions(string asis) matsize(passthru) ]
        if "`bootstrap'" == "" {
                                local saving "saving(`saving')"
                                local title "title(`title')"
                                xtnptimevarsansb `varlist' `if' `in', `stub' `bwidth' `forcereg' `alle' `graphs' `saving' `title'
                                ereturn local cmd "xtnptimevar"
                                ereturn local  cmdline "xtnptimevar `0'"
        }
        else {
              if `"`saving'"' == "" {
                                     di as error "You must specify the file path where to save the bootstrap results"
                                     exit 498
              }
              quietly cd `saving'
              xtnptimevaravecb `varlist' `if' `in', `stub' `bwidth' `forcereg' `alle' `matsize'
              tempname nnscbot ttscbot hhscbot kkscbot nnttscbot
              scalar `nnscbot'   = e(N)
              scalar `ttscbot'   = e(T)
              scalar `hhscbot'   = e(bwidth)
              scalar `kkscbot'   = e(k)
              scalar `nnttscbot' = e(NT)
              local yyvrbot "`e(depvar)'"
              local ivarvrbot "`e(ivar)'"
              local g_minbot "`e(g_min)'"
              local g_avgbot "`e(g_avg)'"
              local g_maxbot "`e(g_max)'"
              local nombrecobot "`e(nombreco)'"
              local stbprime "`e(stubloc)'"
              tempvar tousebot
              quietly gen `tousebot' = e(sample)
              quietly {
                       tsset
                       local panelvarbot = r(panelvar)
                       local timevarbot  = r(timevar)
                       sort `panelvarbot' `timevarbot'
                       tsset `panelvarbot' `timevarbot'
                       tempvar newid
                       generate `newid' = `panelvarbot'
                       tsset `newid' `timevarbot'
                       save `stbprime'_origds.dta, replace
              }
              ereturn clear
              forvalues i = 1(1)`nombrecobot' {
                                               quietly use `stbprime'_origds.dta, clear
                                               display
                                               display _dup(78) "="
                                               display "Performing Non-Parametric Panel Data Estimations."
                                               display "Bootstrapping Coefficient-Vector:" _skip(5) `i'
                                               display "This may take some time, please wait."
                                               display _dup(78) "="
                                               display
                                               bootstrap _b, `bootoptions' cluster(`panelvarbot') idcluster(`newid') saving(`stbprime'_bootds.dta, double replace): xtnptimevaravecb ///
                                               `varlist' `if' `in', `stub' `bwidth' `forcereg' `alle' `matsize' pvk(`i') checkb
                                               quietly {
                                                        tempname vecbbot sesbot citbot
                                                        matrix define `vecbbot' = (e(b))'
                                                        matrix define `sesbot'  = (e(se))'
                                                        matrix define `citbot'  = (e(ci_normal))'
                                                        svmat double `vecbbot', names(`stbprime'_b)
                                                        svmat double `sesbot', names(`stbprime'_se)
                                                        svmat double `citbot', names(`stbprime'_ci)
                                                        gen double `stbprime'_b_`i' = .
                                                        gen double `stbprime'_se_`i' = .
                                                        gen double `stbprime'_cill_`i' = .
                                                        gen double `stbprime'_ciul_`i' = .
                                                        replace `stbprime'_b_`i' = `stbprime'_b1
                                                        replace `stbprime'_se_`i' = `stbprime'_se1
                                                        replace `stbprime'_cill_`i' = `stbprime'_ci1
                                                        replace `stbprime'_ciul_`i' = `stbprime'_ci2
                                                        matrix drop `vecbbot' `sesbot' `citbot'
                                                        keep `panelvarbot' `timevarbot' `stbprime'_b_`i' `stbprime'_se_`i'  `stbprime'_cill_`i' `stbprime'_ciul_`i'
                                                        sort `panelvarbot' `timevarbot'
                                                        tsset `panelvarbot' `timevarbot'
                                                        save `stbprime'_bootds.dta, replace
                                                        use `stbprime'_origds.dta, clear
                                                        merge 1:1 `panelvarbot' `timevarbot' using `stbprime'_bootds.dta
                                                        drop _merge
                                                        sort `panelvarbot' `timevarbot'
                                                        save `stbprime'_origds.dta, replace
                                               }
              }
              quietly {
                       sort `panelvarbot' `timevarbot'
                       tsset `panelvarbot' `timevarbot'
              }
              local clustvarbot "`e(clustvar)'"
              local seedbot "`e(seed)'"
              local clusterbot "`e(cluster)'"
              local vcetypebot "`e(vcetype)'"
              ereturn clear
              forvalues i = 1(1)`nombrecobot' {
                                               label var `stbprime'_b_`i'    "Coefficient-Vector `i', observed"
                                               label var `stbprime'_se_`i'   "Std. Err. `i', bootstrapped"
                                               label var `stbprime'_cill_`i' "Lower bound confid. inter. `i', NB"
                                               label var `stbprime'_ciul_`i' "Upper bound confid. inter. `i', NB"
              }
              quietly {
                       tsset
                       local labtimevrma: var l `timevarbot'
                       gen `stbprime'_tvarrma1 = `timevarbot'  if `tousebot'
                       levelsof `stbprime'_tvarrma1 if `tousebot', local(yearlevrma)
                       gen `stbprime'_tvprime = .
                       local i = 1
                       foreach l of local yearlevrma {
                                                      replace `stbprime'_tvprime = `l' if _n == `i'
                                                      local i = `i' + 1
                       }
                       label var `stbprime'_tvprime "`labtimevrma'"
              }
              if "`graphs'" == "" {
                                   quietly {
                                            if "`title'" == "" {
                                                                local titlep "Graph of Coefficient-Vector"
                                            }
                                            else {
                                                  local titlep  "`title'"
                                            }
                                            forvalues i = 1(1)`nombrecobot' {
                                                                             local titleps "title("`titlep' `i'")"
                                                                             twoway (rarea  `stbprime'_cill_`i' `stbprime'_ciul_`i' `stbprime'_tvprime, sort color(gs14)) ///
                                                                             (line  `stbprime'_b_`i' `stbprime'_tvprime, sort), name(`stbprime'_`i'_graph, replace) `titleps' legend(cols(1))
                                                                             graph save `stbprime'_`i'_graphsv, replace
                                            }
                                   }
              }
              capture drop `stbprime'_tvarrma1
              quietly {
                       sort `panelvarbot' `timevarbot'
                       tsset `panelvarbot' `timevarbot'
                       save `stbprime'_origds.dta, replace
              }
              ereturn post , esample(`tousebot')
              ereturn local depvar "`yyvrbot'"
              ereturn local ivar "`ivarvrbot'"
              ereturn local nombreco "`nombrecobot'"
              ereturn local stubloc  "`stbprime'" 
              ereturn local clustvar "`clustvarbot'"
              ereturn local seed "`seedbot'"
              ereturn local cluster "`clusterbot'"
              ereturn local vcetype "`vcetypebot'"
              ereturn scalar N       = `nnscbot'
              ereturn scalar T       = `ttscbot'
              ereturn scalar bwidth  = `hhscbot'
              ereturn scalar k       = `kkscbot'
              ereturn scalar NT      = `nnttscbot'
              ereturn scalar g_avg   = `g_avgbot'
              ereturn scalar g_min   = `g_minbot'
              ereturn scalar g_max   = `g_maxbot'
              forvalues i = 1(1)`nombrecobot' {
                                               ereturn local seq_`stbprime'_b_`i'    "`stbprime'_b_`i'"
                                               ereturn local seq_`stbprime'_se_`i'   "`stbprime'_se_`i'"
                                               ereturn local seq_`stbprime'_cill_`i' "`stbprime'_cill_`i'"
                                               ereturn local seq_`stbprime'_ciul_`i' "`stbprime'_ciul_`i'"
              }
              ereturn local seq_`stbprime'_efftv "`stbprime'_tvprime"
              erase `stbprime'_bootds.dta
              ereturn local cmd "xtnptimevar"
              ereturn local  cmdline "xtnptimevar `0'"
        }


end





