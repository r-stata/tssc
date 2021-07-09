*! overid V2.0.8 18may2016
*! Authors C F Baum, Vince Wiggins, Steve Stillman, Mark Schaffer
* Ref: Davidson and MacKinnon, Estimation and Inference in Econometrics, p.236
*      Wooldridge, Econometric Analysis of Cross-Section and Panel Data, p.123
*      Davidson and MacKinnon, Econometric Theory and Methods, p. 532
* V1.1    C F Baum 9B19
* V1.3:   add handling of weights, guard against use with robust
* V1.35:  correct handling of inst list 
* V1.4.0: adds support for xtivreg, fe
* V1.4.1: standard error msg re xtivreg
* V1.4.2: move to ivreg 5.00.09 for collinear instruments correction 
* V1.4.3: fixed bug with lagged covariates in xtivreg
* V1.4.4: suppress constant in aux reg if no constant in orig eqn, per ivreg2
* V1.5.0: comment xtivreg code, enable use after ivreg2
* V1.6.0: added Sargan2, Basmann, and pseudo-F versions of Sargan and Basmann
* V1.6.1: added GMM-style robust overid statistic including cluster
*         and handling of all weight types (except iweights not allowed with robust)
* V1.6.2: fixed nocons bug
* V1.6.3: removed incorrect robust overid stat and robust/cluster options,
*         including pweights
* V1.6.4: prevent execution if N < # of instruments
* V1.6.5: remove test for 5.00.09 since Stata 9 does not define e(version)
* V1.6.6: added support for ivreg2 fwl option
* V1.6.7: promote to 9.2, add code for reg3
* V2.0.0: added support for ivprobit and ivtobit
* V2.0.1: corrected logic for ivprobit depvar handling
* V2.0.2: deal with collinearities in reg3 exogenous list
* V2.0.3: tweaked support for fwl to allow for partialling-out of just _cons
* V2.0.4: added support for new ivreg2 syntax "partial"
* V2.0.5: correction in overidreg3() for vec() in Stata 10, add support for ts ops in reg3
* V2.0.6: update overidreg3() for Austin Nichols' suggestions, deal with ivtobit depvar bug
* V2.0.7: added ivreg29 as valid estimator
* V2.0.8: added ivregress as valid estimator; note overid breaks if FVs used in varlist

program define overid, rclass
        version 9.2
        syntax [ , chi2 dfr f all depvar(varname) ]

        if "`e(cmd)'" ~= "ivreg" & "`e(cmd)'" ~= "ivreg2" & "`e(cmd)'" ~= "reg3" /*
                */      & "`e(cmd)'" ~= "ivprobit" & "`e(cmd)'" ~= "ivtobit" /*
                */      & "`e(cmd)'" ~= "ivreg3" & "`e(cmd)'" ~= "ivreg29" /* 
				*/      & "`e(cmd)'" ~= "ivregress" {
                di in r "overid not supported for command `e(cmd)'"
                error 301
        }

        if "`e(vcetype)'" == "Robust" {
                di in red "Test not valid with robust covariance matrix: use ivreg2"
                exit 198
        }
        
        if ("`e(cmd)'" == "ivprobit" | "`e(cmd)'" == "ivtobit") & ("`e(method)'"~="twostep") {
                di in red "Test available for `e(cmd)' only with -twostep- method"
                exit 198
        }


* pweight is equivalent to aweight+robust and hence not allowed
        local weight ""
        if "`e(wexp)'" != "" {
                if "`e(wtype)'"=="pweight" {
                di in red "test not valid with pweights"
                exit 198
                }
                else {
                        local weight "[`e(wtype)'`e(wexp)']"
                }
        }

* Default is Sargan and Basmann chi2
        if "`chi2'`dfr'`f'`all'" == "" {
                local chi2 "chi2"
        }
        if "`e(cmd)'" == "ivreg" | "`e(cmd)'" == "ivreg2" | "`e(cmd)'" == "ivreg29" | "`e(cmd)'" == "ivregress" | "`e(cmd)'" == "ivreg3" {
* branch for 2SLS
                tempname res iota Nprec K L inst touse sargan regest rssiv b

* determine whether _cons in original list (includes ,noc hanscons)
                mat `b' = e(b) 
                local x : colnames `b'
                local x : subinstr local x "_cons" "_cons" , word count(local hc)
                if `hc' == 0 {
                        local noc "noc"
                }

* instrument list
                local inst `e(insts)'
                local rssiv = e(rss)
                gen byte `touse' = e(sample)
* L=number of non-collinear regressors
* Count includes constant if it exists
                mat `b'=diag(e(b))
                local L=colsof(`b')-diag0cnt(`b')
* fetch residuals
                qui predict double `res' if `touse', res
        
                if "`e(fwlcons)'"~= "" | (e(partial_ct)>0 & e(partial_ct)<.) {
* Partial-out fwl block
                        preserve
                        tempname partial_resid
                        if e(fwlcons)==0 | e(partialcons)==0 {
                                local partialnocons "nocons"
                        }
* Alway nocons after partialling-out
                        local noc "noc"
                        if "`e(fwl1)'`e(partial1)'" ~= "" {
                                local partial1 `e(fwl1)'`e(partial1)'
                        }
                        else {
                                local partial1 `e(fwl)'`e(partial)'
                        }
                        _estimates hold `regest'
                        foreach var of varlist `inst' `res' {
                                qui regress `var' `partial1' if `touse', `partialnocons'
                                qui predict double `partial_resid' if `touse', resid
                                qui replace `var' = `partial_resid'
                                drop `partial_resid'
                        }
                        mat `b'=diag(e(b))
                        local partial_ct = colsof(`b')-diag0cnt(`b')
                        local L = `L' + `partial_ct'
                        _estimates unhold `regest'
                }
                else {
                        local partial_ct = 0
                }

* Nprec is ob count from mat accum.  Use this rather than e(N) in calculations
* because e(N) is rounded if iweights are used and because summarize
* won't work with iweights.
                qui gen `iota'=1
                qui matrix accum `b' = `iota' `weight' if `touse'
                scalar `Nprec'=`b'[1,1]
        
* Regress IV residuals on instrument list
                capture {
                        _estimates hold `regest'
                        regress `res' `inst' `weight' if `touse', `noc'
                        scalar `sargan' = `Nprec'*(1.0-e(rss)/`rssiv')
* K=number of non-collinear instruments
* Count includes constant if it exists
                        mat `b'=diag(e(b))
                        local K=colsof(`b')-diag0cnt(`b')+`partial_ct'
                        local enn = `e(N)'
                        _estimates unhold `regest'
                }
				if _rc > 0 {
					di as err "overid does not handle factor variables."
					error 198
				}
        
* check that number of observations exceeds number of instruments       
                if `enn' <= `K' {
                        di as err "Error: cannot calculate test when number of instruments"
                        di as err "       equals or exceeds number of observations"
                        error 2001
                }
        
* Calculate degree of overid
                return scalar df = `K'-`L'
                if return(df) == 0 {
                        di in red _n "There are no overidentifying restrictions."
                        exit 
                }
                return scalar dfu=`Nprec'-`K'
                return scalar dfr=`Nprec'-`L'
                return scalar N = e(N)

di in gr _n "Tests of overidentifying restrictions:"

if "`chi2'`all'" != "" {
                return scalar sargan = `sargan'
                return scalar sarganp= chiprob(return(df),return(sargan))
                di in gr _c "Sargan N*R-sq test " /*
                        */ in ye _col(25) %7.3f return(sargan) in gr            /* 
                        */ in gr "  Chi-sq(" %1.0f in ye return(df)    /*
                        */ in gr ")" _col(47) "P-value = " in ye %5.4f return(sarganp)
                di
                }

if "`dfr'`all'" != "" {
                return scalar sargan2 = `sargan'*return(dfr)/`Nprec'
                return scalar sargan2p= chiprob(return(df),return(sargan2))
                di in gr _c "Sargan (N-L)*R-sq test " /*
                        */ in ye _col(25) %7.3f return(sargan2) in gr            /* 
                        */ in gr "  Chi-sq(" %1.0f in ye return(df)    /*
                        */ in gr ")" _col(47) "P-value = " in ye %5.4f return(sargan2p)
                di
                }


if "`chi2'`dfr'`all'" != "" {
                return scalar basmann = /*
                        */ `sargan'*return(dfu)/(`Nprec'-`sargan')
                return scalar basmannp= chiprob(return(df),return(basmann))
                di in gr _c "Basmann test " /*
                        */ in ye _col(25) %7.3f return(basmann) in gr            /* 
                        */ in gr "  Chi-sq(" %1.0f in ye return(df)    /*
                        */ in gr ")" _col(47) "P-value = " in ye %5.4f return(basmannp)
                di
                }

if "`f'`all'" != "" {
                return scalar sarganf = /*
                        */ `sargan'/`Nprec'*return(dfr)/return(df)
                return scalar sarganfp= Ftail(return(df),return(dfr),return(sarganf))
                di in gr _c "Sargan pseudo-F test " /*
                        */ in ye _col(25) %7.3f return(sarganf) in gr            /* 
                        */ in gr "  F(" %1.0f in ye return(df)    /*
                        */ in gr "," %1.0f in ye return(dfr)         /*
                        */ in gr ")" _col(47) "P-value = " in ye %5.4f return(sarganfp)
                di
                return scalar basmannf = /*
                        */ `sargan'*return(dfu)/(`Nprec'-`sargan')/return(df)
                return scalar basmannfp= Ftail(return(df),return(dfu),return(basmannf))
                di in gr _c "Basmann pseudo-F test " /*
                        */ in ye _col(25) %7.3f return(basmannf) in gr            /* 
                        */ in gr "  F(" %1.0f in ye return(df)    /*
                        */ in gr "," %1.0f in ye return(dfu)         /*
                        */ in gr ")" _col(47) "P-value = " in ye %5.4f return(basmannfp)
                di
                }
* end of ivreg / ivreg2 logic
        }
        
        if "`e(cmd)'" == "reg3" {
* reg3 code
                tempname esigma beta eps 
                tempvar iota touse
                mat __sigma = e(Sigma)
                mat `beta' = e(b)
                mat __V = e(V)
                qui g byte `iota' = 1 if e(sample)
                local exog `e(exog)' `iota'
                local depvar `e(depvar)'
                local eqnames `e(eqnames)'
// allow for tsops
                _find_tsops `exog' `depvar'
                if `r(tsops)' {
                        tsunab exog : `exog'
                        tsrevar `exog'
                        local exog `r(varlist)'
                        tsunab depvar : `depvar'
                        tsrevar `depvar'
                        local depvar `r(varlist)'
                }
* construct the 3SLS residuals and vec them
                local neq  `e(k_eq)'    
                local iw 0
                foreach w of local eqnames {
                        local ++iw
                        tempvar eps`iw'
                        qui predict double `eps`iw'', resid equation(`w')
                        local epss "`epss' `eps`iw''"
                }
                local nbeta = colsof(`beta')
                qui g byte `touse' = e(sample)
                mata: overidreg3("`epss'","`exog'",`nbeta',"`touse'")
                local nbeta = `nbeta' - nconstr
                di in gr _n "Number of equations : " `neq'
                di in gr   "Total number of exogenous variables in system : " nexog
                di in gr   "Number of estimated coefficients : " `nbeta'
                if nconstr > 0 {
                        di in gr   "Net of " nconstr " linear constraints / dependencies"
                }
                di in gr   "Hansen-Sargan overidentification statistic : " %9.3f crit
                di in gr   "Under H0, distributed as Chi-sq(" df "), pval = " %6.4f chi2
                return scalar crit = crit
                return scalar df = df
                return scalar p = chi2
                return scalar nexog = nexog
                return scalar nbeta = `nbeta' 
                return scalar nconstr = nconstr
                return scalar neq = `neq'
                return local cmd = "reg3"
* End of reg3 block
        }
        
* Start of ivprobit block       
        if "`e(cmd)'" == "ivprobit" {
                tempname regest b b2 overid overidp df nobs
                tempvar touse
                gen byte `touse'=e(sample)
                mat `b'=e(b)
                local regressors : colnames `b'
                local dirt "_cons"
                local regressors : list regressors - dirt
                local endo "`e(instd)'"
                local insts "`e(insts)'"
                local exexog : list insts - regressors
                local inexog : list regressors - endo
                local inexog : list inexog - exexog
                if "`depvar'"=="" {
                        local depvar : word 1 of `e(depvar)'
                }
                if "`depvar'" =="" {
                        di in red "Error: you must use the depvar() option"
                        exit 198
                }
                local asis "`e(asis)'"
                local wtopt "[`e(wtype)'`e(wexp)']"
                _estimates hold `regest', restore
                ivprobit2 `depvar' `inexog' (`endo' = `exexog') if `touse' `wtopt', twostep `asis'
                mat `b2'=e(b)
                vecsort `b'
                vecsort `b2'
                local cob=colsof(`b')
                forvalues i=1/`cob' {
                        if reldif(`b'[1,`i'],`b2'[1,`i']) > 1e-5 {
di in red "overid error: internal reestimation of eqn differs from original"
                                exit 198
                        }
                }
                scalar `overid'=e(overid)
                scalar `overidp'=e(overidp)
                scalar `df'=e(overiddf)
                scalar `nobs'=e(N)
                _estimates unhold `regest'
                return scalar overid=`overid'
                return scalar overidp=`overidp'
                return scalar df=`df'
                return scalar N=`nobs'
        }
        
* Start of ivtobit block
        if "`e(cmd)'" == "ivtobit" {
                tempname regest b b2 overid overidp df nobs
                tempvar touse
                gen byte `touse'=e(sample)
                mat `b'=e(b)
                local regressors : colnames `b'
                local dirt "_cons"
                local regressors : list regressors - dirt
                local endo "`e(instd)'"
                local insts "`e(insts)'"
                local exexog : list insts - regressors
                local inexog : list regressors - endo
                local inexog : list inexog - exexog
                local depvar "`e(depvar)'"
// cfb fix for extraneous material in depvar
                local depvar : word 1 of `depvar'
                local asis "`e(asis)'"
                if "`e(llopt)'" ~= "" {
                        local llopt "ll(`e(llopt)')"
                }
                if "`e(ulopt)'" ~= "" {
                        local ulopt "ul(`e(ulopt)')"
                }
                local wtopt "[`e(wtype)'`e(wexp)']"
                _estimates hold `regest', restore
                ivtobit2 `depvar' `inexog' (`endo' = `exexog') if `touse' `wtopt', twostep `asis' `llopt' `ulopt' first
                mat `b2'=e(b)
                vecsort `b'
                vecsort `b2'
                local cob=colsof(`b')
                forvalues i=1/`cob' {
                        if reldif(`b'[1,`i'],`b2'[1,`i']) > 1e-5 {
di in red "overid error: internal reestimation of eqn differs from original"
                                exit 198
                        }
                }
                scalar `overid'=e(overid)
                scalar `overidp'=e(overidp)
                scalar `df'=e(overiddf)
                scalar `nobs'=e(N)
                _estimates unhold `regest'
                return scalar overid=`overid'
                return scalar overidp=`overidp'
                return scalar df=`df'
                return scalar N=`nobs'
        }
        if "`e(cmd)'" == "ivprobit" | "`e(cmd)'" == "ivtobit" {
di
di in gr "Test of overidentifying restrictions:"
di in gr _c "Amemiya-Lee-Newey minimum chi-sq statistic" /*
        */ in ye _col(45) %7.3f return(overid) in gr            /* 
        */ in gr "  Chi-sq(" %1.0f in ye return(df)    /*
        */ in gr ")" _col(66) "P-value = " in ye %5.4f return(overidp)
di
        }
* End of ivtobit block

end

program define vecsort          /* Also clears col/row names */
        version 8.2
        args vmat
        tempname hold
        mat `vmat'=`vmat'+J(rowsof(`vmat'),colsof(`vmat'),0)
        local lastcol = colsof(`vmat')
        local i 1
        while `i' < `lastcol' {
                if `vmat'[1,`i'] > `vmat'[1,`i'+1] {
                        scalar `hold' = `vmat'[1,`i']
                        mat `vmat'[1,`i'] = `vmat'[1,`i'+1]
                        mat `vmat'[1,`i'+1] = `hold'
                        local i = 1
                }
                else {
                        local i = `i' + 1
                }
        }
end

// Austin Nichols version of 21may2009, Statalist posting
version 10
mata:
void overidreg3(string scalar epss, ///
                string scalar exog, ///
                real scalar nbeta,  ///
                string scalar touse)
{
epssv = tokens(epss)
vepss = epssv[|1,.|]
evec = vec( st_data(., vepss, touse) )
exogv = tokens(exog)
vexog = exogv[|1,.|]
st_view(wmat,.,vexog,touse)
meat=invsym(quadcross(wmat,wmat))
zz=rank(meat)
sigma = st_matrix("__sigma")
isigma=invsym(sigma)
crit=0
for (i=1; i<=cols(vepss); i++) {
 v1=vepss[i]
 st_view(vv1,.,v1,touse)
 for (j=1; j<=cols(vepss); j++) {
  v2=vepss[j]
  st_view(vv2,.,v2, touse)
  crit=crit+isigma[i,j]*quadcross(vv1,wmat)*meat*quadcross(wmat,vv2)
  }
 }
nconstr = nbeta - rank(st_matrix("__V"))        
df = rows(sigma) * zz - ( nbeta - nconstr)
chi2 = chi2tail(df, crit)
st_numscalar("crit",crit)
st_numscalar("df",df)
st_numscalar("chi2",chi2)
st_numscalar("nexog",zz)
st_numscalar("nconstr",nconstr)
}
end

* ivprobit2
* version 1.1.5  03apr2005
// BPP
* cloned and modified by mes 30oct2005
program define ivprobit2, eclass byable(recall) sortpreserve
        
        // Portions of syntax parsing code are from ivreg.ado
        local n 0

        gettoken lhs 0 : 0, parse(" ,[") match(paren)
        IsStop `lhs'
        if `s(stop)' { 
                error 198 
        }  
        while `s(stop)'==0 {
                if "`paren'"=="(" {
                        local n = `n' + 1
                        if `n'>1 {
                                capture noi error 198
di as error `"syntax is "(all instrumented variables = instrument variables)""'
                                exit 198
                        }
                        gettoken p lhs : lhs, parse(" =")
                        while "`p'"!="=" {
                                if "`p'"=="" {
                                        capture noi error 198
di as error `"syntax is "(all instrumented variables = instrument variables)""'
di as error `"the equal sign "=" is required"'
                                        exit 198
                                }
                                local end`n' `end`n'' `p'
                                gettoken p lhs : lhs, parse(" =")
                        }
                        tsunab end`n' : `end`n''
                        tsunab exog`n' : `lhs'
                }
                else {
                        local exog `exog' `lhs'
                }
                gettoken lhs 0 : 0, parse(" ,[") match(paren)
                IsStop `lhs'
        }
        local 0 `"`lhs' `0'"'

        tsunab exog : `exog'
        tokenize `exog'
        local lhs "`1'"
        local 1 " "
        local exog `*'
        
        // Eliminate vars from `exog1' that are in `exog'
        Subtract inst : "`exog1'" "`exog'"
        
        // `lhs' contains depvar, 
        // `exog' contains RHS exogenous variables, 
        // `end1' contains RHS endogenous variables, and
        // `inst' contains the additional instruments

        local lhsname `lhs'
        local lhsstr : subinstr local lhsname "." "_"
        local exogname `exog'
        local end1name `end1'
        local instname `inst'

        _find_tsops `lhs' `exog' `end1' `inst'
        if `r(tsops)' {
                qui tsset
                tsrevar `lhs'
                local lhs `r(varlist)'
                tsrevar `end1'
                local end1 `r(varlist)'
                tsrevar `exog'
                local exog `r(varlist)'
                tsrevar `inst'
                local inst `r(varlist)'
        }

        // Check for collinearity in RHS variables
        foreach x in end1 exog inst {
                local old`x' ``x''
                qui _rmcoll ``x''
                local `x' "`r(varlist)'"
                local dropped : list old`x' - `x'   // `x' resolves to a local
                foreach y of local dropped {
                        local j : list posof "`y'" in old`x'
                        local y2 : word `j' of ``x'name'
                }
        }

        // Now parse the remaining syntax
        syntax [if] [in] [fw pw iw / ] , [ TWOstep Robust       ///
                CLuster(varname) FIRST noLOg    ///
                ASIS Level(cilevel) FROM(string)                ///
                NRTOLerance(string) * ]

        marksample touse
        markout `touse' `lhs' `exog' `end1' `inst'
        
        local end1_ct : word count `end1'
        local inst_ct : word count `inst'
        local exog_ct : word count `exog'

        local estimator "twostep"

        if "`weight'" != "" { 
                local wgt `"[`weight'=`exp']"' 
        }

        // Model identification checks
        // Step 1 : call -ivreg- and see what's left
        CheckVarsP `lhs' "`exog'" "`end1'" "`inst'" `touse'
        local exog `"`s(exog)'"'
        local inst `"`s(inst)'"'
        // Step 2 : call _binperfect and locate perfect predictors
        // This includes exogenous and endogenous vars and insts.
        // Not if asis specified
        tempname rules
        mat `rules' = J(1,4,0)
        if "`asis'" == "" {
                _binperfect `lhs' `exog' `end1' , touse(`touse')
                mat `rules' = r(rules)
                if !(`rules'[1,1] == 0 & `rules'[1,2] == 0 & ///
                        `rules'[1,3] == 0 & `rules'[1,4] == 0) {
                        noi _binperfout `rules'
                        // Remove dropped vars from varlists
                        local dropped : rownames(`rules')
                        foreach d in `dropped' {
                                local exog : subinstr local exog "`d'" ""
                                local inst : subinstr local inst "`d'" ""
                                local end1 : subinstr ///
                                        local end1 "`d'" "", count(local c)
                                if `c' > 0 {
                                        di as error ///
                                        "may not drop an endogenous variable"
                                        exit 498
                                }
                        }
                        CheckVarsP `lhs' "`exog'" "`end1'" "`inst'" `touse'
                        local exog `"`s(exog)'"'
                        local inst `"`s(inst)'"' 
                }
        }
        qui count if `touse'
        if r(N) == 0 {
                exit 2000
        }
        local exog_ct : word count `exog'
        local end1_ct : word count `end1'
        local inst_ct : word count `inst'

        tempvar xb      // used later by both estimators
        
        if "`estimator'" == "twostep" {
                // First set up D(Pi)
                // The selection matrix is just the identity matrix
                // if we include the exogenous variables after the other insts.
                local totexog_ct = `exog_ct' + `inst_ct'
                tempname DPi  
                mat `DPi' = J(`totexog_ct'+1, `end1_ct'+`exog_ct'+1, 0)
                mat `DPi'[`inst_ct'+1, `end1_ct'+1] = I(`exog_ct'+1)
                // Now do the first-stage regressions, fill in DPi and
                // save fitted values and residuals
                tempname junk
                local fitted ""
                local resids ""
                local qui "qui"
                if "`first'" != "" {
                        local qui ""
                }
                local i = 1
                if `end1_ct' == 1 {
                        `qui' di "First stage regression"
                }
                else {
                        `qui' di "First stage regressions"
                }
                foreach y of local end1 {
                        `qui' regress `y' `inst' `exog' `wgt' if `touse', ///
                                level(`level')
                        mat `junk' = e(b)
                        mat `DPi'[1, `i'] = `junk' '
                        tempvar fitted`i' resids`i'
                        qui predict double `fitted`i'' if `touse', xb
                        qui predict double `resids`i'' if `touse', residuals
                        local fitted "`fitted' `fitted`i''"
                        local resids "`resids' `resids`i''"
                        local i = `i' + 1
                }

                // 2SIV estimates
                // We also use these 2SIV estimates for exog. test
                cap qui probit `lhs' `end1' `exog' `resids' ///
                       `wgt' if `touse'
                tempname beta2s b2s l2s var2s chi2exog chi2exdf
                mat `beta2s' = e(b)
                mat `b2s' = `beta2s'[1, 1..`end1_ct']
                // Do the exog. test while we're at it.
                qui test `resids'
                scalar `chi2exog' = r(chi2)
                scalar `chi2exdf' = r(df)
                
                // Next, estimate the reduced-form alpha
                // alpha does not contain the params on `resids'
                // Also get lambda
                cap qui probit `lhs' `inst' `exog' `resids' `wgt' if `touse'
                tempname b alpha lambda
                mat `b' = e(b)
                mat `alpha' = J(1, `totexog_ct'+1, 0)
                mat `alpha'[1, 1] = `b'[1, 1..`totexog_ct']
                mat `alpha'[1, `totexog_ct'+1] = ///   
                        `b'[1, `totexog_ct'+`end1_ct'+1]
                mat `lambda' = `b'[1, `totexog_ct'+1..`totexog_ct'+`end1_ct']

                // Build up the omega matrix
                tempname omega var
                mat `var' = e(V)
                mat `omega' = J(`totexog_ct'+1, `totexog_ct'+1, 0)
                // First term is J_aa inverse, which is cov matrix
                // from reduced-form probit
                mat `omega'[1, 1] = `var'[1..`totexog_ct', 1..`totexog_ct']
                local j = `totexog_ct'+`end1_ct'+1 
                mat `omega'[`totexog_ct'+1, `totexog_ct'+1] = `var'[`j',`j']
                forvalues i = 1/`totexog_ct' {
                        mat `omega'[`totexog_ct'+1, `i'] = `var'[`j', `i']
                        mat `omega'[`i', `totexog_ct'+1] = `var'[`i', `j']
                }
                tempvar ylb
                qui gen double `ylb' = 0
                local i = 1
                foreach var of varlist `end1' {
                        qui replace `ylb' = `ylb' + ///
                                    `var'*(`lambda'[1,`i'] - `b2s'[1, `i']) ///
                                    if `touse'
                        local i = `i' + 1
                }
                qui regress `ylb' `inst' `exog' `wgt' if `touse'
                tempname V
                mat `V' = e(V)
                mat `omega' = `omega' + `V'
                tempname omegai
                mat `omegai' = inv(`omega')

                // Newey answer
                tempname finalb finalv
                mat `finalv' = inv(`DPi'' * `omegai' * `DPi')
                mat `finalb' = `finalv' * `DPi'' * `omegai' * `alpha''
                mat `finalb' = `finalb''

* added overid code
tempname Aprime A B
mat `Aprime'=(`alpha'-`finalb'*`DPi'')
mat `A'=`Aprime''
mat `B'=`Aprime'*`omegai'*`A'

                // Do this here before we restripe e(b)
                loc names `end1' `exog' _cons
                mat colnames `finalb' = `names'
                mat score double `xb' = `finalb' if e(sample)

                // Fill in orig names for end1, exog and inst - timeseries ops.
                foreach x in end1 exog inst {
                        local new`x' ``x''
                        foreach y of local `x' {
                                local j : list posof "`y'" in old`x'
                                local y2 : word `j' of ``x'name'
                                local new`x' : subinstr local new`x' "`y'" "`y2'"
                        }
                        local `x' `new`x''
                }
                loc names `end1' `exog' _cons
                mat colnames `finalb' = `names'
                mat colnames `finalv' = `names'
                mat rownames `finalv' = `names'
                qui summ `touse' `wgt' , meanonly
                local capn = r(sum)
                eret post `finalb' `finalv', depname(`lhsname') o(`capn') ///
                                        esample(`touse')
* added overid code
tempname overid overidp
scalar `overid'=`B'[1,1]
scalar `overidp'= chiprob(`inst_ct'-`end1_ct',`overid')
eret scalar overid=`overid'
eret scalar overidp=`overidp'
eret scalar overiddf=`inst_ct'-`end1_ct'
        }

end


// Collinearity checker for ivProbit
program define CheckVarsP, sclass

        args lhs exog end1 inst touse

        sret clear
        qui ivreg `lhs' `exog' (`end1' = `inst')
        if ( e(N) == 0 | e(N) >= . ) {
                exit 2000
        }
        local newinst `"`e(insts)'"'
        tempname b
        mat `b' = e(b)
        qui replace `touse' = 0 if !(e(sample))
        local varlist : colnames(`b')
        tokenize `varlist'
        local i : word count `varlist'
        if `"``i''"' != "_cons" {
                di as error "may not drop constant"
                exit 399
        }
        local `i'               //   These two lines essentially
        local varlist `"`*'"'   //   remove _cons from varlist
        // If any of the endogenous variables were dropped, exit
        // with an r(498).
        tokenize `varlist'
        local i = 1
        foreach x of local end1 {
                if `"``i''"' != `"`x'"' {
                        di as error "may not drop an endogenous variable"
                        exit 498
                }
                local i = `i' + 1   
        }
        local exog : subinstr local varlist "`end1'" ""
        tokenize `exog'         // Clean up exog and remove
        local exog `"`*'"'      // extraneous white space
        foreach word of local exog {
                local newinst : subinstr local newinst "`word'" ""
        }
        tokenize `newinst'
        local newinst `"`*'"'
        sret local exog `"`exog'"'
        sret local inst `"`inst'"'
                        
end

* version 1.1.8  14jul2006
// BPP
* cloned and modified by mes 5oct2006

program define ivtobit2, eclass byable(recall) sortpreserve
        version 8.2
        // Portions of syntax parsing code are from ivreg.ado
        local n 0

        gettoken lhs 0 : 0, parse(" ,[") match(paren)
        IsStop `lhs'
        if `s(stop)' { 
                error 198 
        }  
        while `s(stop)'==0 {
                if "`paren'"=="(" {
                        local n = `n' + 1
                        if `n'>1 {
                                capture noi error 198
di as error `"syntax is "(all instrumented variables = instrument variables)""'
                                exit 198
                        }
                        gettoken p lhs : lhs, parse(" =")
                        while "`p'"!="=" {
                                if "`p'"=="" {
                                        capture noi error 198
di as error `"syntax is "(all instrumented variables = instrument variables)""'
di as error `"the equal sign "=" is required"'
                                        exit 198
                                }
                                local end`n' `end`n'' `p'
                                gettoken p lhs : lhs, parse(" =")
                        }
                        tsunab end`n' : `end`n''
                        tsunab exog`n' : `lhs'
                }
                else {
                        local exog `exog' `lhs'
                }
                gettoken lhs 0 : 0, parse(" ,[") match(paren)
                IsStop `lhs'
        }
        local 0 `"`lhs' `0'"'

        tsunab exog : `exog'
        tokenize `exog'
        local lhs "`1'"
        local 1 " "
        local exog `*'

        // Eliminate vars from `exog1' that are in `exog'
        Subtract inst : "`exog1'" "`exog'"
        
        // `lhs' contains depvar, 
        // `exog' contains RHS exogenous variables, 
        // `end1' contains RHS endogenous variables, and
        // `inst' contains the additional instruments

        // Now parse the remaining syntax
        syntax [if] [in] [fw pw iw / ] , [ TWOstep Robust       ///
                CLuster(varname) FIRST noLOg    ///
                LL1 LL2(numlist min=1 max=1) UL1 UL2(numlist min=1 max=1) ///
                Level(cilevel) FROM(string)                     ///
                NRTOLerance(string) * ]
        local mloptions `"`options'"'
        
        if _by() {
                _byoptnotallowed score() `"`score'"'
        }
                                
        marksample touse
        markout `touse' `lhs' `exog' `end1' `inst'

        local estimator "twostep"

        if "`weight'" != "" { 
                local wgt `"[`weight'=`exp']"' 
        }

        // Model identification checks
        CheckVarsT `lhs' "`exog'" "`end1'" "`inst'" `touse' "`wgt'"
        local exog `"`s(exog)'"'
        local inst `"`s(inst)'"'
        qui count if `touse'
        if r(N) == 0 {
                exit 2000
        }
        
        local lhsname `lhs'
        local lhsstr : subinstr local lhsname "." "_"
        local exogname `exog'
        local end1name `end1'
        local instname `inst'

        _find_tsops `lhs' `exog' `end1' `inst'
        if `r(tsops)' {
                qui tsset
                tsrevar `lhs'
                local lhs `r(varlist)'
                tsrevar `end1'
                local end1 `r(varlist)'
                tsrevar `exog'
                local exog `r(varlist)'
                tsrevar `inst'
                local inst `r(varlist)'
        }
        local exog_ct : word count `exog'
        local end1_ct : word count `end1'
        local inst_ct : word count `inst'

        // Now figure out what the ll() and ul() opts are
        qui summ `lhs' if `touse', meanonly
        local ulopt ""
        local llopt ""
        local tobitll = `r(min)' - 1
        local tobitul = `r(max)' + 1
        if "`ll1'" != "" {
                local llopt "ll(`r(min)')"
                local tobitll `r(min)'
        }
        else if "`ll2'" != "" {
                local llopt "ll(`ll2')"
                local tobitll `ll2'
        }
        if "`ul1'" != "" {
                local ulopt "ul(`r(max)')"
                local tobitul `r(max)'
        }
        else if "`ul2'" != "" {  
                local ulopt "ul(`ul2')"
                local tobitul `ul2'
        }
        if `tobitul' <= `tobitll' {
                di as error "no uncensored observations"
                exit 2000
        }
        if "`estimator'" == "twostep" {
                // First set up D(Pi)
                // The selection matrix is just the identity matrix
                // if we include the exogenous variables after the other insts.
                local totexog_ct = `exog_ct' + `inst_ct'
                tempname DPi  
                mat `DPi' = J(`totexog_ct'+1, `end1_ct'+`exog_ct'+1, 0)
                mat `DPi'[`inst_ct'+1, `end1_ct'+1] = I(`exog_ct'+1)
                // Now do the first-stage regressions, fill in DPi and
                // save fitted values and residuals
                tempname junk
                local fitted ""
                local resids ""
                local qui "qui"
                if "`first'" != "" {
                        local qui ""
                }
                local i = 1
                /*
                if `end1_ct' == 1 {
                        `qui' di "First stage regression"
                }
                else {
                        `qui' di "First stage regressions"
                }
                */
                foreach y of local end1 {
                cap     `qui' regress `y' `inst' `exog' `wgt' if `touse', ///
                                level(`level')
                        mat `junk' = e(b)
                        mat `DPi'[1, `i'] = `junk' '
                        tempvar fitted`i' resids`i'
                        qui predict double `fitted`i'' if `touse', xb
                        qui predict double `resids`i'' if `touse', residuals
                        local fitted "`fitted' `fitted`i''"
                        local resids "`resids' `resids`i''"
                        local i = `i' + 1
                }
  
                // 2SIV estimates
                // We also use these 2SIV estimates for exog. test
                cap  qui tobit `lhs' `end1' `exog' `resids' ///
                       `wgt' if `touse', `llopt' `ulopt'
                tempname beta2s b2s l2s var2s chi2exog chi2exdf
                mat `beta2s' = e(b)
                mat `b2s' = `beta2s'[1, 1..`end1_ct']
                // Do the exog. test while we're at it.
                qui test `resids'
                scalar `chi2exog' = r(F)/r(df)
                scalar `chi2exdf' = r(df)
                
                // Next, estimate the reduced-form alpha
                // alpha does not contain the params on `resids'
                // Also get lambda
                cap qui tobit `lhs' `inst' `exog' `resids' ///
                        `wgt' if `touse', `llopt' `ulopt'
                tempname b alpha lambda
                mat `b' = e(b)
                mat `alpha' = J(1, `totexog_ct'+1, 0)
                mat `alpha'[1, 1] = `b'[1, 1..`totexog_ct']
                mat `alpha'[1, `totexog_ct'+1] = ///   
                        `b'[1, `totexog_ct'+`end1_ct'+1]
                mat `lambda' = `b'[1, `totexog_ct'+1..`totexog_ct'+`end1_ct']

                // Build up the omega matrix
                tempname omega var
                mat `var' = e(V)
                mat `omega' = J(`totexog_ct'+1, `totexog_ct'+1, 0)
                // First term is J_aa inverse, which is cov matrix
                // from reduced-form tobit
                mat `omega'[1, 1] = `var'[1..`totexog_ct', 1..`totexog_ct']
                local j = `totexog_ct'+`end1_ct'+1 
                mat `omega'[`totexog_ct'+1, `totexog_ct'+1] = `var'[`j',`j']
                forvalues i = 1/`totexog_ct' {
                        mat `omega'[`totexog_ct'+1, `i'] = `var'[`j', `i']
                        mat `omega'[`i', `totexog_ct'+1] = `var'[`i', `j']
                }
                tempvar ylb
                qui gen double `ylb' = 0
                local i = 1
                foreach var of varlist `end1' {
                        qui replace `ylb' = `ylb' + ///
                                    `var'*(`lambda'[1,`i'] - `b2s'[1, `i']) ///
                                    if `touse'
                        local i = `i' + 1
                }
                qui regress `ylb' `inst' `exog' `wgt' if `touse'
                tempname V
                mat `V' = e(V)
                mat `omega' = `omega' + `V'
                tempname omegai
                mat `omegai' = inv(`omega')
                
                // Newey answer
                tempname finalb finalv
                mat `finalv' = inv(`DPi'' * `omegai' * `DPi')
                mat `finalb' = `finalv' * `DPi'' * `omegai' * `alpha''
                mat `finalb' = `finalb''

* added overid code
* code taken from ivprobit2
tempname Aprime A B
mat `Aprime'=(`alpha'-`finalb'*`DPi'')
mat `A'=`Aprime''
mat `B'=`Aprime'*`omegai'*`A'
                
                // Fill in orig names for end1, exog and inst - timeseries ops.
                foreach x in end1 exog inst {
                        local new`x' ``x''
                        foreach y of local `x' {
                                local j : list posof "`y'" in `x'
                                local y2 : word `j' of ``x'name'
                                local new`x' : subinstr local new`x' "`y'" "`y2'"
                        }
                        local `x' `new`x''
                }
                loc names `end1' `exog' _cons
                mat colnames `finalb' = `names'
                mat colnames `finalv' = `names'
                mat rownames `finalv' = `names'
                qui summ `touse' `wgt' , meanonly
                local capn = r(sum)
                eret post `finalb' `finalv', depname(`lhsname') o(`capn') ///
                        esample(`touse')
* added overid code
tempname overid overidp
scalar `overid'=`B'[1,1]
scalar `overidp'= chiprob(`inst_ct'-`end1_ct',`overid')
eret scalar overid=`overid'
eret scalar overidp=`overidp'
eret scalar overiddf=`inst_ct'-`end1_ct'
                
        }

end

// Collinearity checker for ivTobit
program define CheckVarsT, sclass

        args lhs exog end1 inst touse wgt

        /* backups */
        local end1_o `end1'
        local exog_o `exog'
        local inst_o `inst'
        
        /* Let X = [endog exog] and W = [exog inst].  Then
           X'X and W'W must be of full rank */
        quietly {
                /* X'X */
                _rmcoll `end1' `exog' if `touse' `wgt', `coll'
                local noncol `r(varlist)'
                local end1 : list end1 & noncol
                local exog : list exog & noncol
                /* W'W */
                _rmcoll `exog' `inst' if `touse' `wgt', `coll'
                local noncol `r(varlist)'
                local exog : list exog & noncol
                local inst : list inst & noncol
        }
        local dropped : list end1_o - end1
        if `:word count `dropped'' > 0 {
                di as error "may not drop an endogenous regressor"
                exit 498
        }
        foreach type in exog inst {
                local dropped : list `type'_o - `type'
                foreach x of local dropped {
                        di as text "note: `x' dropped due to collinearity"
                }
        }

        sret local exog `exog'
        sret local inst `inst'
                        
end


// Borrowed from ivreg.ado      
program define IsStop, sclass

        if `"`0'"' == "[" {
                sret local stop 1
                exit
        }
        if `"`0'"' == "," {
                sret local stop 1
                exit
        }
        if `"`0'"' == "if" {
                sret local stop 1
                exit
        }
        if `"`0'"' == "in" {
                sret local stop 1
                exit
        }
        if `"`0'"' == "" {
                sret local stop 1
                exit
        }
        else {
                sret local stop 0
        }

end

// Borrowed from ivreg.ado      
program define Subtract   /* <cleaned> : <full> <dirt> */

        args        cleaned     /*  macro name to hold cleaned list
                */  colon       /*  ":"
                */  full        /*  list to be cleaned
                */  dirt        /*  tokens to be cleaned from full */

        tokenize `dirt'
        local i 1
        while "``i''" != "" {
                local full : subinstr local full "``i''" "", word all
                local i = `i' + 1
        }

        tokenize `full'                 /* cleans up extra spaces */
        c_local `cleaned' `*'

end


// Borrowed from ivreg.ado
program define Disp
        local first ""
        local piece : piece 1 64 of `"`0'"'
        local i 1
        while "`piece'" != "" {
                di as text "`first'`piece'"
                local first "               "
                local i = `i' + 1
                local piece : piece `i' 64 of `"`0'"'
        }
        if `i'==1 { 
                di 
        }

end


exit
