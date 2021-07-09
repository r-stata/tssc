
*! Bollen-Stine bootstrap, v.1.4, Stas Kolenikov
program define bollenstine, eclass

 syntax, [Reps(int 200) SAVing(str) notable noheader nolegend ///
   SAFER CONFAOPTions(str) STATistic( str ) *]


 * this is a post-estimation command following cfa1
 if "`e(cmd)'" ~= "cfa1" & "`e(cmd)'" ~= "confa" error 301

 * the low level preserve
 preserve
 tempfile pres
 tempname confares
 est store `confares'
 qui save `pres'

 qui keep if e(sample)
 local T = e(lr_u)

 if "`safer'"!="" {
   local safer cap noi
 }

 if "`saving'" == "" {
    tempfile bsres
    local saving `bsres'
 }

 if "`e(cmd)'" == "cfa1" {

    local varlist = "`e(depvar)'"
    local p : word count `varlist'

    tempname Sigma bb
    mat `Sigma' = e(Model)
    mat `bb' = e(b)

    mata: CONFA_BSrotate("`Sigma'","`varlist'")

     `safer' bootstrap _b (T: T = e(lr_u)) (reject: reject = (e(lr_u) > `T') ) `statistic' , ///
          reps(`reps') saving(`saving') notable noheader nolegend ///
          reject( e(converged) == 0) `options' ///
       : cfa1 `varlist' , from(`bb', skip) `confaoptions'
    * may need some other options, too!
    nobreak if "`safer'"~="" & _rc {
       * for whatever reason, the bootstrap broke down
       qui use `pres' , clear
       qui est restore `confares'
       qui est drop `confares'
       error _rc
    }
    * just to display the results
    * the covariance matrix should have been reposted by the -bootstrap-!

    * we still need to trick Stata back into cfa1!
    ereturn local cmd cfa1

 }

 else if "`e(cmd)'" == "confa" {

     local varlist = "`e(observed)'"
     local p : word count `varlist'

     tempname Sigma bb
     mat `Sigma' = e(Sigma)
     mat `bb' = e(b)

     mata: CONFA_BSrotate("`Sigma'","`varlist'")

     * set up the call
     local k = 1
     while "`e(factor`k')'" ~= "" {
        local call `call' (`e(factor`k')')
        local ++k
     }

     * the first call and resetting the from vector
     cap confa `call' , from(`bb') `confaoptions'
     if _rc {
        di as err "cannot execute confa with rotated data"
        restore
        qui est restore `confares'
        cap est drop `confares'
        exit 309
     }
     mat `bb' = e(b)
     if ~strpos("`confaoptions'", "from")  local from from(`bb')

     * correlated errors?
     * unit variance identification?

      `safer' bootstrap _b (T: T = e(lr_u)) (reject: reject = (e(lr_u) > `T') ) `statistic' , ///
           reps(`reps') saving(`saving') notable noheader nolegend ///
           reject( e(converged) == 0) `options' ///
        : confa `call' , `from' `confaoptions'
     * may need some other options, too!
     nobreak if "`safer'"~="" & _rc {
        * for whatever reason, the bootstrap broke down
        qui use `pres' , clear
        qui est restore `confares'
        cap est drop `confares'
        error _rc
     }
     * the covariance matrix should have been reposted by the -bootstrap-!

     * we still need to trick Stata back into confa!
     ereturn local cmd confa
 }

 else {
     * what on earth was that?
     error 301
 }


 * the bootstrap test on T
 gettoken bsres blah : saving , parse(",")
 * to strip off replace option, if there is any
 qui use `bsres', clear
 sum reject_reject, mean

 local pBS = r(mean)
 local BBS = r(N)

 qui sum T_T, det
 local q05 = r(p5)
 local q95 = r(p95)

 if (e(bs_version) >= 3) {
    tempname ci_no ci_pc ci_bc
    mat `ci_no' = e(ci_normal)
    mat `ci_pc' = e(ci_percentile)
    mat `ci_bc' = e(ci_bc)
 }

 * version control?
 tempname vce
 mat `vce' = e(V)

 mat `vce' = `vce'[1..colsof(`bb'), 1..colsof(`bb')]

 qui use `pres', clear
 qui est restore `confares'
 qui est drop `confares'

 ereturn scalar p_u_BS = `pBS'
 ereturn scalar B_BS = `BBS'
*  ereturn scalar lr_u = `T'
*  ereturn scalar p_u = chi2tail(e(df_u),e(lr_u))

 ereturn scalar T_BS_05 = `q05'
 ereturn scalar T_BS_95 = `q95'
 ereturn local vce BollenStine
 ereturn local vcetype Bollen-Stine

 * version control?
 * col/row names?
 ereturn repost V = `vce'

 if !missing("`ci_no'") {
    ereturn matrix ci_normal = `ci_no'
    ereturn matrix ci_percentile = `ci_pc'
    ereturn matrix ci_bc = `ci_bc'
 }

 `e(cmd)'

end


exit

History:
v.1.1  -- Jan 9, 2007
v.1.2  -- Mar 26, 2008: cfa1 options added; reject() added
v.1.3  -- July 12, 2008: upgraded to confa
v.1.4  -- Nov 17, 2009: use e(ci*) from the bootstrap
      -- ci(bc), ci(percentile) level( passthru from c*fa* )
      