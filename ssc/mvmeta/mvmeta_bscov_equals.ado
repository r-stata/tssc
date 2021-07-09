/******************************************************************************
*! version 3.0.1  Ian White  27may2015
Sigma = known Sigma0
No unknown parameter
******************************************************************************/

prog def mvmeta_bscov_equals, rclass

syntax [if] [in], [log                        ///
    setup start(string) mmSigma(string) /// Set up
    mm1 mm2 notrunc                          /// Method of moments
    varparms(string)                    /// Within -ml-
    postfit                             /// After -ml-
    ]
local p $MVMETA_p
marksample touse
tempname startchol Sigma binit vinit init
matrix `Sigma' = $MVMETA_sigma0
mat rownames `Sigma' = $MVMETA_ynames
mat colnames `Sigma' = $MVMETA_ynames

if "`setup'"!="" {
    di as text "Note: variance-covariance matrix is " as result "equal to $MVMETA_sigma0exp"
    // STARTING VALUES
    mvmeta_mufromsigma, sigma(`Sigma')
    mat `binit' = e(b)
    mat `init' = (`binit')
    return local nvarparms = 0
    return matrix binit=`binit'
    return matrix init=`init'
    // SET UP EQUATIONS
    return local eqlist 
}

if "`varparms'" != "" {
}

if "`postfit'" != "" {
    // SET UP VARIANCE EXPRESSIONS
    forvalues r=1/`p' {
        forvalues s=1/`r' {
            local this = `Sigma'[`s',`r']
            return local Sigma`s'`r' `this'
        }
    }
}

if !mi("`mm1'`mm2'") {    // METHOD OF MOMENTS - NOTHING TO DO
    return scalar truncated = 0
}

return matrix Sigma = `Sigma'
return scalar nparms_aux = 0
return scalar neqs_aux = 0
end

