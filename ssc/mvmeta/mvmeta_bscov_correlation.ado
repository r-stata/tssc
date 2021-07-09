/******************************************************************************
*! version 3.0.1  Ian White  27may2015
Sigma = s' * sigma0 * s
Given correlation matrix sigma0, unknown vector of SDs s
IRW, 5may2011
******************************************************************************/

prog def mvmeta_bscov_correlation, rclass

syntax [if] [in], [log                        ///
    setup start(string) mmSigma(string) /// Set up
    mm1 mm2 notrunc                          /// Method of moments
    varparms(string)                    /// Within -ml-
    postfit                             /// After -ml-
    ]
local p $MVMETA_p
marksample touse
tempname startchol Sigma binit vinit init

// GENERAL CODE
if "$MVMETA_taulog"=="taulog" {
    // Estimate tau on log scale
    local exp exp
    local tauname logtau
}
else {
    // Estimate tau on untransformed scale, but ignore negative sign
    local exp abs
    local tauname tau
}
forvalues r=1/`p' {
    local yname`r' = word("$MVMETA_ylist",`r')
}

// IF RUN AT SET-UP STAGE
if "`setup'"!="" {
    di as text "Note: variance-covariance matrix is " as result "correlation equal to $MVMETA_sigma0exp"
    tempname junk
    cap mat `junk' = $MVMETA_sigma0 + I(`p')
    if _rc {
        di as error "mvmeta_bscov_correlation: matrix must be `p'x`p'"
        exit 498
    }
    // STARTING VALUES
    tempname startmat
    if "`start'"!="" {
        cap matrix `startmat' = `start'
        if !_rc cap assert rowsof(`startmat')==1
        if !_rc cap assert colsof(`startmat')==`p'
        if _rc {
            di as error "Error in start(`start'): need 1 x `p' matrix"
            exit 499
        }
    }
    else mat `startmat' = J(1,`p',1)
    forvalues r=1/`p' {
        mat `startmat'[1,`r'] = `exp'(`startmat'[1,`r'])
        local eqlist `eqlist' (`tauname'_`yname`r'':)
        local colnames `colnames' "`tauname'_`yname`r''"
    }
    mat `Sigma' = diag(`startmat') * ($MVMETA_sigma0) * diag(`startmat')
    mvmeta_mufromsigma, sigma(`Sigma')
    mat `binit' = e(b)
    mat `vinit' = (`startmat')
    mat colnames `vinit' = `colnames'
    mat `init' = (`binit', `vinit')
    return local nvarparms = `p'
    return matrix binit=`binit'
    return matrix init=`init'
    // SET UP EQUATIONS
    return local eqlist `eqlist'
}

// Compute Sigma from row vector of variance parameters - used by mvmeta_lmata.ado
if "`varparms'" != "" {
    forvalues r=1/`p' {
        mat `varparms'[1,`r'] = `exp'(`varparms'[1,`r'])
    }
    matrix `Sigma' = diag(`varparms') * ($MVMETA_sigma0) * diag(`varparms')
}

if "`postfit'" != "" {
    tempname parmvec
    mat `parmvec' = J(1,`p',.)
    forvalues r=1/`p' {
        mat `parmvec'[1,`r'] = `exp'([`tauname'_`yname`r'']_b[_cons])
    }
    matrix `Sigma' = diag(`parmvec') * ($MVMETA_sigma0) * diag(`parmvec')
    mat rownames `Sigma' = $MVMETA_ylist
    mat colnames `Sigma' = $MVMETA_ylist
    // SET UP VARIANCE EXPRESSIONS
    tempname sigma0
    mat `sigma0' = $MVMETA_sigma0
    forvalues r=1/`p' {
        forvalues s=1/`r' {
            local this = `sigma0'[`s',`r']
            if `s'==`r' return local Sigma`s'`r' `this'*(`exp'([`tauname'_`yname`r'']_b[_cons]))^2
            else return local Sigma`s'`r' `this'*`exp'([`tauname'_`yname`r'']_b[_cons])*`exp'([`tauname'_`yname`s'']_b[_cons])
        }
    }
}

if !mi("`mm1'`mm2'") {    // METHOD OF MOMENTS
    di as error "Sorry, method of moments is not yet implemented for covariance(proportional)
    exit 498
    return scalar truncated = `truncated'
    return matrix Q = `Q'
    return matrix Qa = `Qa'
    return matrix Qb = `Qb'
}

return matrix Sigma = `Sigma'
return scalar nparms_aux = `p'
return scalar neqs_aux = `p'
end

