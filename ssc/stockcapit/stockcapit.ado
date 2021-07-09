*! stockcapit version 1.0.2
*! Computes Physical Capital Stock
*! Diallo Ibrahima Amadou
*! All comments are welcome, 2011


capture program drop stockcapit
program stockcapit, rclass sortpreserve
        version 10
        syntax varlist(min=2 max=2) [if] [in] , CAPITal(string) [DELTA(real 0.05)]
        qui tsset
        local panelvar "`r(panelvar)'"
        local timevar  "`r(timevar)'"
        tempfile maindata sampledata
        if "`panelvar'" == ""   {
                                 sort `timevar'
                                 qui save `maindata',replace
        }
        else {
              sort `panelvar' `timevar'
              qui save `maindata',replace
        }
        marksample touse
        qui count if `touse'
        if r(N) == 0 {
                      di as err "No observations."
                      exit 2000
        }
        foreach x of varlist `varlist' {
                                        qui replace `touse' = 0 if `x' >= .
        }
        qui keep if `touse'
        gettoken inv gdp : varlist
        tempvar kap invmeam croisimeam indic lengthp maxrunp select decision verif valgdpinit valgdpfinal meanvalgdpinit meanvalgdpfinal
        confirm new var `capital'
        qui capture drop  _spell _seq _end
        if "`panelvar'" == ""   {
                                 quietly {
                                          tsset
                                          tsspell, f(L.`timevar' == .)
                                          bysort  _spell: egen `lengthp' = max(_seq)
                                          egen `maxrunp' = max(_seq)
                                          gen `select' = cond(`maxrunp' == `lengthp',1,0)
                                          gen `decision' = 0
                                          replace `decision' = sum(`select') if `select' == 1
                                          egen `verif' = max(`decision')
                                          replace  `decision' = 0 if  `verif'< 5
                                          sort `timevar'
                                          tsset
                                          gen double `valgdpinit'  = `gdp' if `decision' == 1 & `touse'
                                          gen double `valgdpfinal' = `gdp' if `decision' == 5 & `touse'
                                          egen double `meanvalgdpinit' = mean(`valgdpinit') if `touse'
                                          egen double `meanvalgdpfinal' = mean(`valgdpfinal') if `touse'
                                          gen double `croisimeam'     = ((`meanvalgdpfinal'/`meanvalgdpinit')^(1/5)) - 1 if `decision' >= 1 & `decision' <= 5 &  `touse'
                                          egen double `invmeam'    = mean(`inv') if `decision' >= 1 & `decision' <= 5 &  `touse'
                                          gen double `kap'         = .
                                          replace    `kap'         = `invmeam'/(`croisimeam' + `delta') if `decision' == 1 & `touse'
                                          replace    `kap'         = L.`kap' + L.`inv' - `delta'*(L.`kap') if `decision' > 1 & `touse'
                                          rename `kap' `capital'
                                 }
        }
        else {
              quietly {
                       tsset
                       tsspell, f(L.`timevar' == .)
                       bysort `panelvar' _spell: egen `lengthp' = max(_seq)
                       bysort `panelvar': egen `maxrunp' = max(_seq)
                       gen `select' = cond(`maxrunp' == `lengthp',1,0)
                       bysort `panelvar': gen `decision' = 0
                       bysort `panelvar': replace `decision' = sum(`select') if `select' == 1
                       bysort `panelvar': egen `verif' = max(`decision')
                       bysort `panelvar': replace  `decision' = 0 if  `verif'< 5
                       sort `panelvar' `timevar'
                       tsset
                       by `panelvar' : gen double `valgdpinit'  = `gdp' if `decision' == 1 & `touse'
                       by `panelvar' : gen double `valgdpfinal' = `gdp' if `decision' == 5 & `touse'
                       by `panelvar' : egen double `meanvalgdpinit' = mean(`valgdpinit') if `touse'
                       by `panelvar' : egen double `meanvalgdpfinal' = mean(`valgdpfinal') if `touse'
                       by `panelvar' : gen `indic'              = 0
                       by `panelvar' : replace `indic'          = 1  if  `decision' >= 1 & `decision' <= 5 & `touse'
                       by `panelvar' : gen double `croisimeam'     = ((`meanvalgdpfinal'/`meanvalgdpinit')^(1/5)) - 1  if `indic' == 1
                       by `panelvar' : egen double `invmeam'    = mean(`inv')    if `indic' == 1
                       by `panelvar' : gen double `kap'         = .
                       by `panelvar' : replace    `kap'         = `invmeam'/(`croisimeam' + `delta') if `decision' == 1 & `touse'
                       by `panelvar' : replace    `kap'         = L.`kap' + L.`inv' - `delta'*(L.`kap') if `decision' > 1 & `touse'
                       rename `kap' `capital'
              }
        }
        qui drop  _spell _seq _end
        qui capture drop if `capital' < 0
        if "`panelvar'" == ""   {
                                 sort `timevar'
                                 qui keep `timevar' `capital'
                                 qui save `sampledata',replace
                                 capture clear
                                 qui use `maindata', clear
                                 merge `timevar' using `sampledata'
                                 qui drop _merge
        }
        else {
              sort `panelvar' `timevar'
              qui keep `panelvar' `timevar' `capital'
              qui save `sampledata',replace
              capture clear
              qui use `maindata', clear
              merge `panelvar' `timevar' using `sampledata'
              qui drop _merge
        }
        label var `capital' "Calculated Physical Capital Stock"
        return local capital "`capital'"
end
