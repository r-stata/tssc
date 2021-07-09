* ! version 0.0.2 2011-02-28 jx
*   add different in marginal effects in the output

// Bootstrap low level utility to compute marginal effects and compare differences in binary regression models

// TO DO: not in planning at this point

capture program drop _grmargb
program define _grmargb, rclass
    version 8.0
    tempname post_name lastest
    tempfile    original post_file
    tempname b xnoc xvec xb sxb prob marg pdf lastest tobase
    tempname    dpdx    /// marginal effects of the orignal run
                dpdx1   /// marginal effects of dif
                dpdx2   /// marginal effects of sav    
                dfdl grad margvar margse dmarg dmargvar marglo marghi dmarglo dmarghi z I // xj addition
    tempname    totobs tdf t z zpr zdc
    tempname    m_obs m_avg m_std m_normup m_normlo m_pctup m_pctlo m_bcup m_bclo m_cimat
    tempname    mdif_obsmat mdif_obs mdif_avg mdif_std mdif_normup mdif_normlo mdif_pctup mdif_pctlo mdif_bcup mdif_bclo mdif_cimat
    tempvar     touse
    
    
//  DECODE SYNTAX

    syntax [if] [in] [, x(passthru) rest(passthru) choices(varlist)     ///
                    Reps(int 1000)  SIze(int -9) dots match         ///
                    ITERate(passthru) level(integer $S_level)       ///
                    all Save Diff]
    
//  MODELS APPLIED
    
        if "`e(cmd)'"=="logistic" | ///
           "`e(cmd)'"=="logit"    | ///
           "`e(cmd)'"=="probit"    | ///
           "`e(cmd)'"=="cloglog"    {
            local io = "typical binary"
        }
        
   
        if "`io'"=="" {
            di in r "this grcompare command does not work for the last type of model estimated."
            exit
    }   
    
    
    // get z score 
    loc lvlprb = `level'/100
    sca `z' = -invnorm((1-`lvlprb')/2)
    // noisily di in y `z' "+" `level'
    
    // estimation info
    mat `b'     = e(b)
    loc cmd     = "`e(cmd)'"
    loc depvar  = "`e(depvar)'"
    // di in y "`depvar'"
    loc names : colnames `b'
    loc wtype "`e(wtype)'" // weight type
    loc wexp "`e(wexp)'" // weight expression
    loc tmpnms : subinstr loc names `"_cons"' `"dog"', all count(local count)
    loc isnocon = 1 - `count'
    // if the first argument in cond holds, returns nocon, otherwise empty
    loc nocon = cond("`isnocon'"=="1", "nocon", "") 

    // di "`isnocon'"
    
    *di in y "`rest'"
    
    // get base values
    _pebase `if' `in' , `x' `rest' `choices' `all'
    loc nrhs    =   `r(nrhs)'
    loc rhsnms  =   "`r(rhsnms)'"
    mat `xnoc'  =   r(pebase)
    mat `tobase'=   r(pebase)
    // mat PE_in   =    `xnoc'  // NEED IT?
    loc nvar: word count `rhsnms'
    
    // get values and number of categories of the dependent variables
    _pecats
    loc numcats = `r(numcats)'
    loc catvals "`r(catvals)'"
    
    // _pepred, `level' // `maxcnt' NEED IT?
    *di in y "`rhsnms'"
    *di in y "`nrhs'"
    *mat list `xnoc'
    // compile string for mfx at from base value vector and the list of independent variables
    forval i = 1/`nrhs' {
        loc var`i': word `i' of `rhsnms'
        loc num`i' = `xnoc'[1, `i']
        loc mfxstr`i' "`var`i''=`num`i'', "
        loc mfxstr "`mfxstr'`mfxstr`i'' "
    }
    
    // creat marker of the original sample
    mark `touse' if e(sample)
    if "`size'"=="-9" | "`size'"=="" { // -9 is default for size
        local size = e(N)
    }
    if "`size'"!="" & `size'>e(N) {
        di as error ///
            "Error: resample size is larger than the number of observations"
        exit
    }
    
    // grab info from the original sample
    local nobs = e(N) // observations in original estimation sample
    
    // create list of variables and expressions used by post commands
    // number of marginal effects should be equal to number of right-hand side vars
    forval i = 1/`nrhs' {
        tempname  m`i'
        loc post_var "`post_var'`m`i'' "
        loc post_exp "`post_exp'(`m`i'') "
        if "`diff'"!="" {
            tempname m`i'dif
            loc post_var "`post_var'`m`i'dif' "
            loc post_exp "`post_exp'(`m`i'dif') "
        }
    
    }

    if "`match'"!="" {
        preserve // #1
        quietly keep if `touse'
        quietly save `original'
        restore // #1
    }
    
  
    // store the observed estimates
    mfx `if' `in', predict(p) at(`mfxstr')
    *mfx, predict(p) at(hisei=70)
    mat `marg' = e(Xmfx_dydx)
    *di in y "`mfxstr'"
    *mat list `marg'
    
    
    // start of bootstrap
    // hold non-bootstrap estimation results; restore later
    _estimates hold `lastest', restore

    loc dots = cond("`dots'"=="", "*", "noisily")
    
    postfile `post_name' `post_var' using `post_file'
    
    
// SIMULATION
    //  get the random sample
    quietly {
    
        // number of replication missed due to non-convergence or other reasons
        loc nmissed = 0
        
        // start of replications
        forval i = 1/`reps' {
            `dots' dodot `reps' `i'
            preserve // #2 preserve
                        // resample if match option specified
                        if "`match'"!="" {
                            tempname samppct catsize
                            scalar `samppct' = `size' / `nobs'
            
                            forval j = 1/`numcats' {
                                tempfile cat`j'file
                                use `original', clear
                                loc cur_val: word `j' of `catvals'
                                loc depval`j' "`cur_depval'"
                                keep if `depvar'==`cur_val'
                                count
                                scalar `catsize' = `samppct'*r(N)
                                local resamp = round(`catsize',1)
                                if `catsize'==0 {
                                    local resamp = 1
                                }
                                bsample `resamp'
                                save `cat`j'file'
                            }
            
                            * stack data from all categories
                            use `cat1file', clear
                            forval i = 2/`numcats' {
                                append using `cat`j'file'
                            }
                        } // matched
            
                        // resample if match option not specified
                        else {
            
                            keep if `touse'
                            bsample `size'
            
                            * check if boot sample has all outcome categories
                            _pecats `depvar'
                            loc catschk = r(numcats)
                            * if category missed, count it, and take another sample
                            if `catschk' != `numcats' {
                                loc ++nmissed // count missed replication
                                loc errlog "`errlog'`i', "
                                restore
                                continue
                            }
                        } // no matched
            
            // estimate model with mfx
            capture { // trap errors in estimation

              `cmd' `depvar' `rhsnms' ///
                  if `touse' [`wtype'`wexp'], `iterate' `nocon'

               mfx, predict(p) at(`mfxstr')

            } // capture

            // if error in estimation, count it as missed
            if _rc!=0 {
                loc ++nmissed
                loc errlog "`errlog'`i', "
                restore
                continue
            }

            // get marginal effects for this run
            mat `dpdx1' = e(Xmfx_dydx)      
    
    
    //  discrete changes
    
           if "`diff'"!="" {

                capture {
                    mfx `if' `in', predict(p) at($margx)
                    mat `dpdx2' = e(Xmfx_dydx)
                    mat `dmarg' = `dpdx1' -`dpdx2'

                } // end of capture

                if _rc !=0 { // if error in estimation
                    local ++nmissed // count missed replication
                    local errlog "`errlog'`i', "
                    restore
                    continue
                }


            } // end of diff loop
    
    
    //  post results
    
            // move marginal effects from matrices to scalars for posting
            forval k = 1/`nrhs' {
                scalar `m`k'' = `dpdx1'[1, `k']
                if "`diff'"!="" {
                    scalar `m`k'dif' = `dmarg'[1, `k']
                }
            }
            post `post_name' `post_exp'

            restore // #2   
    
        } // end of replication loop        
        postclose `post_name' // close postfile
        
    //  construct ci for prediction from mfx
    
        preserve // #3

        use `post_file', clear
        qui count
        sca `totobs'    = r(N)
        // noisily di in y "this is totobs " `totobs' 
        sca `tdf'       = `totobs' -1
        sca `t'         = invttail(`tdf',((1-(`level')/100)/2))

        // loop through each statistics
        forval i = 1/`nrhs' {

            sum `m`i'', d
            sca `m_obs' = `marg'[1, `i']
            sca `m_avg' = r(mean)
            sca `m_std' = r(sd)

            // bias correction method
            qui count if `m`i''<=`m_obs'
            * zpr will be missing if r(N)=0
            sca `zpr' = invnorm(r(N)/`totobs')
            
            // noisily di in y r(n)
            // noisily di in y `totobs'
            
            // noisily di in y invnorm(r(N)/`totobs')
            // noisily di in y "`zpr'"

            // use t for normal
            sca `m_normup' = `m_obs' + `t'*`m_std'
            sca `m_normlo' = `m_obs' - `t'*`m_std'

            // percentile method
            qui _pctile `m`i'', nq(1000)
            loc upperpctile = 500 - 5*-`level'
            loc lowerpctile = 1000 - `upperpctile'
            sca `m_pctup' = r(r`upperpctile')
            sca `m_pctlo' = r(r`lowerpctile')

            // percentile for the bias-correction.
            loc upnum = round((norm(2*`zpr' + `z')) * 1000, 1)
            loc lonum = round((norm(2*`zpr' - `z')) * 1000, 1)
            if `zpr'==. { // if missing, upper & lower limits are missing
                sca `m_bcup' = .
                sca `m_bclo' = .
            }
            else {
                sca `m_bcup' = r(r`upnum')
                sca `m_bclo' = r(r`lonum')
            }

            // stack results from 3 methods
            mat `m_cimat' = nullmat(`m_cimat') \ ///
                `m_pctlo', `m_pctup', ///
                `m_normlo', `m_normup', ///
                `m_bclo', `m_bcup'
    
    //  construct ci for differences
    
            if "`diff'"!="" {
    
                    sum `m`i'dif', d
                    mat `mdif_obsmat'   = `marg' - MargSave
                    *noi mat list `marg'
                    *noi mat list MargSave
                    sca `mdif_obs' = `mdif_obsmat'[1, `i']
                    sca `mdif_avg' = r(mean)
                    sca `mdif_std' = r(sd)
    
                    // bias corrected method
                    qui count if `m`i'dif'<=`mdif_obs'
                    sca `zdc' = invnorm(r(N)/`totobs')
                    loc upnum = round((norm(2*`zdc' + `z'))*1000, 1)
                    loc lonum = round((norm(2*`zdc' - `z'))*1000, 1)
    
                    // use t for normal
                    scalar `mdif_normup' = `mdif_obs' + `t'*`mdif_std'
                    scalar `mdif_normlo' = `mdif_obs' - `t'*`mdif_std'
    
                    // percentile method
                    _pctile `m`i'dif', nq(1000)
                    sca `mdif_pctup' = r(r`upperpctile')
                    sca `mdif_pctlo' = r(r`lowerpctile')
    
                    // percentile for bias corrected
                    if `zdc'==. {
                        sca `mdif_bcup' = .
                        sca `mdif_bclo' = .
                    }
                    else {
                        sca `mdif_bcup' = r(r`upnum')
                        sca `mdif_bclo' = r(r`lonum')
                    }
    
                    // stack results from 3 methods
                    mat `mdif_cimat' = nullmat(`mdif_cimat') \ ///
                        `mdif_pctlo', `mdif_pctup', ///
                        `mdif_normlo', `mdif_normup', ///
                        `mdif_bclo', `mdif_bcup'

            }

        } // end of each statistic
        
        // restore data from original estimation
        restore // #3   
    } // end of quietly




//  add ci's to global for save and diff

    // save x() rest() all setup to be used for margdiff, dif
    if "`save'"!="" {
        global margx "`mfxstr'"
        mat MargSave =  `marg' // mfxdpdx saved
        mat _GRSavebase = `tobase'
    }
    
    mat colnames    `m_cimat' = pctlo pctup nrmlo nrmup bclo bcup
    mat rownames    `m_cimat' = `rhsnms'
    mat list `m_cimat', noheader
    ret mat marg    `marg'
    ret mat margci  `m_cimat'
    
    
    // estimates unhold
    _estimates unhold `lastest'
    
    if "`diff'"!="" {
        mat colnames `mdif_cimat' = pctlo pctup nrmlo nrmup bclo bcup
        mat rownames `mdif_cimat' = `rhsnms'
        mat list `mdif_cimat', noheader
        mat list `mdif_obsmat', noheader
        ret mat dmarg `mdif_obsmat'
        ret mat dmargci `mdif_cimat'
    
    }
    
    
// adding base values    
    if "`base'"!="nobase" {

        mat rownames `tobase' = "x="
        if "`diff'"=="" {
            mat _GRtemp = `tobase'
            _peabbv _GRtemp
            mat list _GRtemp, noheader
        }   
        else {
            local tmp1: colnames `tobase'
            local tmp2: colnames _GRSavebase
            
            if "`tmp1'"=="`tmp2'" {
                mat _GRtemp = (`tobase' \ _GRSavebase \ (`tobase' - _GRSavebase))
                mat rownames _GRtemp = "Current=" "Saved=" "Diff="
                _peabbv _GRtemp 
                mat list _GRtemp, noheader
            }
            else {
                mat rownames `tobase' = "Current="
                mat rownames _GRSavebase =  "  Saved="
                mat _GRtemp = `tobase'
                _peabbv _GRtemp
                mat list _GRtemp, noheader
                mat _GRtemp = _GRSavebase
                _peabbv _GRtemp
                mat list _GRtemp, noheader
            }
        }    
    }    
    
    
    
end // end of grmargb.ado


// produce dots
capture program drop dodot
program define dodot
    version 8
    tempname s
    args N n
    local dot "."
    * don't bother with %'s if few than 20 reps
    if `N'>19 {
        scalar `s' = `N'/10
        forvalues c = 0/10 {
            local c`c' = floor(`c'*`s')
            if `n'==`c`c'' {
                local pct = `c'*10
                di in g `pct' "%" _c
                local dot ""
                * new line when iterations are done
                if `pct'==100 {
                    di
                }
            }
        } //forvalues
    } // if > 19
    di in g as txt "`dot'" _c
end



    
    
    
    

