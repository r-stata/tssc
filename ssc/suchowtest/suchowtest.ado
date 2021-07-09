*! suchowtest version 1.0.1
*! Performs successive Chow tests 
*! Diallo Ibrahima Amadou
*! All comments are welcome, 10Jan2014



capture program drop suchowtest
program suchowtest, rclass sortpreserve
            version 12.0
            qui capture tsset
            syntax varlist(fv ts) [if] [in] [aw fw iw pw] , thresv(varname numeric fv ts) STUB(string) [ fpctile(real 10) lpctile(real 90)  step(integer 1) sig(real 0.10) noGRAPHS SAVing(string asis) *]
            marksample touse
            markout `touse' `thresv'
            gettoken lhs rhs : varlist
	    _fv_check_depvar `lhs'
            quietly {
                     capture tsset
                     local timevariable  "`r(timevar)'"
                     local panelvariable "`r(panelvar)'"
                     if "`weight'" != "" {
                                          local wgt "[`weight'`exp']"
                     }
                     tempvar sortthresv thresvalter
                     gen double `thresvalter' = `thresv' if `touse'
                     sort `thresvalter'
                     gen `sortthresv' = _n if `touse'
                     tsset `sortthresv'
                     regress `lhs' `rhs' `wgt'  if `touse', `options'
	             tempname rsstot ntot
	             scalar `rsstot' = e(rss)
                     scalar `ntot' = e(N)
                     tempvar departtot fintot departtotrd fintotrd
                     egen `departtot' = pctile(`sortthresv') if `touse', p(`fpctile')
                     egen `fintot'    = pctile(`sortthresv') if `touse', p(`lpctile')
                     gen `departtotrd' = int(`departtot') if `touse'
                     gen `fintotrd'    = int(`fintot')    if `touse'
                     local i = `departtotrd'
                     tempname rss1 rss2 chowstat bcoef knum n1 n2 qlstat chowstatpvalue maxql maxthresv maxpvchow maxchowfisher
                     tempvar itervar qlstatvar0 qlstatvar chowstatpvaluevar chowsigvar chowfishervar
                     gen double  `itervar'     = . if `touse'
                     gen double  `qlstatvar'   = . if `touse'
                     gen double  `qlstatvar0'  = . if `touse'
                     gen double  `chowstatpvaluevar' = . if `touse'
                     gen double  `chowfishervar' = . if `touse'
                     gen double  `chowsigvar' = 0 if `touse'
                     while `i' <= `fintotrd' {
                                              tsset
                                              regress `lhs' `rhs' `wgt'  if `touse' & `sortthresv' <= `i', `options'
                                              scalar `rss1' = e(rss)
                                              scalar `n1' = e(N)
                                              regress `lhs' `rhs' `wgt'  if `touse' & `sortthresv' > `i', `options'
                                              scalar `rss2' = e(rss)
                                              scalar `n2' = e(N)
                                              matrix define `bcoef' = e(b)
                                              scalar `knum' = colsof(`bcoef')
                                              scalar `chowstat' = ((`rsstot' - (`rss1' + `rss2')) / (`rss1' + `rss2')) * ((`ntot' - 2*`knum') / `knum')
                                              scalar `chowstatpvalue' = F(`knum',`ntot' - 2*`knum',`chowstat')
                                              scalar `qlstat' = -`n1'*ln(`rss1')-`n2'*ln(`rss2')
                                              replace `chowfishervar' =  `chowstat' if `touse' & _n== `i'
                                              replace `itervar' = `i' if `touse' & _n== `i'
                                              replace `qlstatvar0' = `qlstat' if `touse' & _n== `i'
                                              replace `chowstatpvaluevar' =  `chowstatpvalue' if `touse' & _n== `i'
                                              local i = `i' + `step'
                     }
                     replace `chowsigvar' = 1 if `chowstatpvaluevar' < `sig' & `touse'
                     replace `qlstatvar' = `qlstatvar0' if `chowsigvar' == 1  & `touse'
                     tempvar maxivarverif
                     gen double `maxivarverif' = .  if `touse'
                     gsort -`qlstatvar'
                     scalar `maxql'     = `qlstatvar'[1]
                     replace `maxivarverif' = `itervar'[1] if `maxql' < . & `touse'
                     sum `maxivarverif' if `touse'
                     local maxivar   = r(mean)
                     local maxqlloc = `maxivar'
            }
            if "`maxqlloc'" == "." {
                                    di in red "There is no break point at this significance level."
                                    di in red "Please increase the significance level with the option sig()"
                                    di in red "to augment the chance of obtaining a break point."
            }
            else {
                  quietly {
                           gsort -`qlstatvar'
                           scalar `maxthresv' = `thresvalter'[1]
                           scalar `maxpvchow' = `chowstatpvaluevar'[1]
                           scalar `maxchowfisher' = `chowfishervar'[1]
                           capture drop `stub'_qlstatvar `stub'_itervar `stub'_chowstatpvalue  `stub'_chowfisher
                           confirm new var `stub'_qlstatvar
                           confirm new var `stub'_itervar
                           confirm new var `stub'_chowstatpvalue
                           confirm new var `stub'_chowfisher
                           rename `qlstatvar' `stub'_qlstatvar
                           rename `itervar'  `stub'_itervar
                           rename `chowstatpvaluevar' `stub'_chowstatpvalue
                           rename `chowfishervar' `stub'_chowfisher
                           label var `stub'_qlstatvar "QL Statistic"
                           label var `stub'_itervar   "Break Point Parameter"
                           label var `stub'_chowstatpvalue "P-Values of the Chow Test"
                           label var `stub'_chowfisher "Chow F-Statistic"
                           return scalar qlstat = `maxql'
                           return scalar maxobsvalue = `maxivar'
                           return scalar maxbreakpt = `maxthresv'
                           return scalar maxpvchowtest = `maxpvchow'
                           return scalar maxchowfh = `maxchowfisher'
                           return local  qlvariable "`stub'_qlstatvar"
                           return local  breakptpar "`stub'_itervar"
                           return local  chowstatpv "`stub'_chowstatpvalue"
                           return local  chowfh "`stub'_chowfisher"
                  }
                  quietly tsset
                  display
                  display _dup(78) "="
                  display "Break Point" _col(22) "= " %9.0g `maxivar' _col(54) "Max. QL Stat. = " %9.0g `maxql'
                  display
                  display "Chow Test F(" `knum' " , " `ntot' - 2*`knum' ")  = " %9.0g `maxchowfisher'  _col(54) "P-Value > F   = "  %9.0g `maxpvchow'
                  display
                  display "Value of" _skip(1) abbrev(`"`thresv'"',8) _col(22) "= " %9.0g `maxthresv'
                  display _dup(78) "="
                  display
                  display _dup(78) "="
                  display "Regression For The Values of" _skip(1) abbrev(`"`thresv'"',8) _skip(1) "Below the Break Point Number " `maxivar'
                  display _dup(78) "="
                  display
                  regress `lhs' `rhs' `wgt' if `touse' & `sortthresv' <= `maxivar', `options'
                  display
                  display _dup(78) "="
                  display "Regression For The Values of" _skip(1) abbrev(`"`thresv'"',8) _skip(1) "Above the Break Point Number " `maxivar'
                  display _dup(78) "="
                  display
                  regress `lhs' `rhs' `wgt' if `touse' & `sortthresv' > `maxivar', `options'
                  if "`graphs'" == "" {
                                      quietly {
                                               if `"`saving'"' == "" {
                                                                      twoway line `stub'_qlstatvar `stub'_itervar if `touse' , title("QL STATISTIC") xtitle("Break Point Parameter") sort xline(`maxqlloc', lcolor(green)) name(`stub'_qlstatgrp, replace)
                                                                      twoway line `stub'_chowstatpvalue `stub'_itervar if `touse', title("P-VALUES OF THE CHOW TEST") xtitle("Break Point Parameter") sort  yline(`sig', lcolor(green)) name(`stub'_chowstatgrp, replace)
                                                                      twoway (line `stub'_chowstatpvalue `stub'_itervar if `touse', sort yline(`sig', lcolor(green))) (line `stub'_qlstatvar `stub'_itervar, yaxis(2) ///
                                                                      sort xline(`maxqlloc', lcolor(green))), title("PV. CHOW TEST AND QL STAT.") xtitle("Break Point Parameter") name(`stub'_chowstatandqlstatgrp, replace)
                                               }
                                               else {
                                                     cd `saving'
                                                     twoway line `stub'_qlstatvar `stub'_itervar if `touse' , title("QL STATISTIC") xtitle("Break Point Parameter") sort xline(`maxqlloc', lcolor(green)) name(`stub'_qlstatgrp, replace)
                                                     graph save `stub'_qlstatgrp.gph, replace
                                                     twoway line `stub'_chowstatpvalue `stub'_itervar if `touse', title("P-VALUES OF THE CHOW TEST") xtitle("Break Point Parameter") sort  yline(`sig', lcolor(green)) name(`stub'_chowstatgrp, replace)
                                                     graph save `stub'_chowstatgrp.gph, replace
                                                     twoway (line `stub'_chowstatpvalue `stub'_itervar if `touse', sort yline(`sig', lcolor(green))) (line `stub'_qlstatvar `stub'_itervar, yaxis(2) ///
                                                     sort xline(`maxqlloc', lcolor(green))), title("PV. CHOW TEST AND QL STAT.") xtitle("Break Point Parameter") name(`stub'_chowstatandqlstatgrp, replace)
                                                     graph save `stub'_chowstatandqlstatgrp.gph, replace
                                               }
                                      }
                  }
            }
            quietly {
                     if "`timevariable'" != ""   {
                                                  if "`panelvariable'" != "" {
                                                                              tsset `panelvariable' `timevariable'
                                                  }
                                                  else {
                                                        tsset `timevariable'
                                                  }
                     }
                     else {
                           tsset, clear
                     }
            }
end
