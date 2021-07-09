/******************************************************************************
*! version 3.0.1  Ian White  27may2015
26mar2015
	better error message for mm2
Sigma = tau^2 * Sigma0
Given matrix Sigma0, unknown parameter tau
******************************************************************************/

program define mvmeta_bscov_proportional, rclass

syntax [if] [in], [log  ///
    setup start(string) ///
    mm1 mm2 notrunc      /// Method of moments
    varparms(string)    /// Within -ml-
    postfit             /// After -ml-
    ]
local p $MVMETA_p
marksample touse
tempname startchol Sigma binit vinit init

if "$MVMETA_taulog"=="taulog" {
    // Estimate tau on log scale
    local exp exp
    local tauname logtau
}
else local tauname tau

if "`setup'"!="" {
    di as text "Note: variance-covariance matrix is " as result "proportional to $MVMETA_sigma0exp"
    tempname junk
    cap mat `junk' = $MVMETA_sigma0 + I(`p')
    if _rc {
        di as error "mvmeta_bscov_proportional: matrix must be `p'x`p'"
        exit 498
    }
    // STARTING VALUES
    if "`start'"!="" {
        cap confirm number `start'
        if _rc {
            di as error "Error in start(`start'): need start(#)"
            exit 499
        }
    }
    else local start 1
    mat `Sigma' = `exp'(`start')^2 * ($MVMETA_sigma0)
    cap mvmeta_mufromsigma, sigma(`Sigma')
    if _rc {
        di as error "mvmeta_bscov_proportional: mvmeta_mufrom sigma failed"
        mat l `Sigma', title(Sigma used)
        exit _rc
    }
    mat `binit' = e(b)
    mat `vinit' = (`start')
    mat colnames `vinit' = "`tauname'"
    mat `init' = (`binit', `vinit')
    return local nvarparms = 1
    return matrix binit=`binit'
    return matrix init=`init'
    // SET UP EQUATIONS
    return local eqlist (`tauname':)
}

if "`varparms'" != "" {
    matrix `Sigma' = (`exp'(`varparms'[1,1])^2) * ($MVMETA_sigma0)
}

if "`postfit'" != "" {
    matrix `Sigma' = (`exp'([`tauname']_b[_cons])^2) * ($MVMETA_sigma0)
    mat rownames `Sigma' = $MVMETA_ylist
    mat colnames `Sigma' = $MVMETA_ylist
    // SET UP VARIANCE EXPRESSIONS
    tempname sigma0
    mat `sigma0' = $MVMETA_sigma0
    forvalues r=1/`p' {
        forvalues s=1/`r' {
            local this = `sigma0'[`s',`r']
            return local Sigma`s'`r' `this'*`exp'([`tauname']_b[_cons])^2
        }
    }
}

if !mi("`mm1'`mm2'") {    // METHOD OF MOMENTS
    di as error "Sorry, method of moments is not yet implemented for bscov(proportional)"
    exit 498
    * but here goes, up to missingness:
    local i 0
    mat sumSinv = J(`p',`p',0)
    mat P = $MVMETA_sigma0
    while 1 {
        local ++i
        cap confirm matrix ${MVMETA_ymat}`i'
        if _rc==111 continue, break
        else if _rc di as error "Error in confirm"
        mat y = ${MVMETA_ymat}`i'
        mat S = ${MVMETA_Smat}`i'
        mat X = ${MVMETA_Xmat}`i'
        mat Sinv = syminv(S)
        mat sumSinv = sumSinv + Sinv
        mat sumXSinvX = sumXSinvX + X'*Sinv*X
        mat sumXSinvPSinvX = sumXSinvPSinvX + X'*Sinv*P*Sinv*X
    }        
    mat dir
    exit 99
}

return matrix Sigma = `Sigma'
return scalar nparms_aux = 1
return scalar neqs_aux = 1
end

