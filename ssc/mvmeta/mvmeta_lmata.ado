/*******************************************************************************************
LIKELIHOOD FOR MVMETA.ADO 
*! version 3.0.1  Ian White  27may2015
version 2.2.1  31may2011
    corrected the constant term in log L and log RL, as suggested by Antonio Gasparrini: affects L/RL (only) in models with missing outcomes and models with covariates
version 1.7.1  3jun2010
    drops any observations with all missing outcomes
*******************************************************************************************/

prog def mvmeta_lmata

// Parse
args todo b lnf
local y      $MVMETA_ymat
local S      $MVMETA_Smat
local X      $MVMETA_Xmat
local p      $MVMETA_p
forvalues j=1/`p' {
    local xvars_`j' ${MVMETA_xvars_`j'}
}
local ynames   $MVMETA_ylist
local bsest    $MVMETA_bsest
local parmtype $MVMETA_parmtype
local xcons    $MVMETA_xcons
local riley  = ("$MVMETA_wscorr"=="riley")
local add2pi = ("$MVMETA_2pi"=="")
local bscovariance $MVMETA_bscovariance
local fixedparms = cond("$MVMETA_quick"=="quick",0,$MVMETA_fixedparms)


// Set up
qui count if $ML_samp
local n = r(N)
local N=_N

tempname BETA Sigma varparms
tempvar mu 

// Form Sigma from parameters b
if `fixedparms'<colsof(`b') {
        mat `varparms' = `b'[., (`fixedparms'+1)..colsof(`b')]
}
mvmeta_bscov_`bscovariance' if $ML_samp, varparms(`varparms') 
mat `Sigma' = r(Sigma)

// Form mu vectors from parameters b
tempname fixedb
if "$MVMETA_quick" == "quick" {
    mvmeta_mufromsigma, sigma(`Sigma')
    mat `fixedb' = e(b)
}
else mat `fixedb' = `b'[1,1..$MVMETA_fixedparms]
if "`parmtype'"=="short" {
    forvalues r=1/`p' {
        qui gen `mu'`r' = `fixedb'[1,`r']
    }
    local k `p'
}
else {
    local k 0
    forvalues i=1/`p' {
        if "`parmtype'"=="common" local k 0
        gen double `mu'`i'=0
        foreach x in `xvars_`i'' `xcons' {
            local ++k
            qui replace `mu'`i' = `mu'`i' + `fixedb'[1,`k'] * `x'
        }
    }
}
forvalues r=1/`p' {
    if "`mulist'"!="" local mulist `"`mulist',"'
    local mulist `"`mulist' "`mu'`r'""'
}

// Call mata to evaluate log-lik
mata: loglik("`y'","`S'","`X'","`Sigma'",(`mulist'),"$ML_samp",`n',`riley',`add2pi')
if "`bsest'"=="ml" scalar `lnf' = r(ll)
if "`bsest'"=="reml" scalar `lnf' = r(rl)

*mat l `Sigma', title(Sigma)
*di "lnf=" `lnf'

*set trace off
end


mata: 
void loglik(string scalar yname, 
            string scalar Sname, 
            string scalar Xname, 
            string scalar Sigmaname, 
            string vector mulist,
            string scalar touse,
            real scalar n,
            real scalar riley,
            real scalar add2pi
)
{
    string matrix X1name
    st_view(data=.,.,(mulist),touse)
    p = cols(data)
    X1name = (Xname+strofreal(1))
    X1 = st_matrix(Xname+strofreal(1))
    q = rows(X1)
    XWXsum=J(q,q,0)
    ll=0
debug=0
if(debug==1) "Debugging loglik() in mvmeta_lmata.ado"
if(debug==1) printf("yname is %s\n", yname)
    for(i=1;i<=n;++i) {
if(debug==1) printf("Loop with i = %6.0f\n",i)
        Sigma = st_matrix(Sigmaname)
if(debug==1) "Sigma"
if(debug==1) Sigma
        y = st_matrix(yname+strofreal(i))
if(debug==1) "y"
if(debug==1) y
        S = st_matrix(Sname+strofreal(i))
if(debug==1) "S"
if(debug==1) S
        X = st_matrix(Xname+strofreal(i))
if(debug==1) "X"
if(debug==1) X
        mu= data[i,]
        dev = y-mu
if(debug==1) "dev"
if(debug==1) dev
if(debug==1) "!colmissing(y)"
if(debug==1) !colmissing(y)

        /* Restrict to submatrices with non-missing values */
        X = select(X,!colmissing(y))
if(debug==1) "X"
if(debug==1) X
        S = select(S,!colmissing(y))
        S = select(S,!colmissing(y)')
if(debug==1) "S"
if(debug==1) S
        Sigma = select(Sigma,!colmissing(y))
        Sigma = select(Sigma,!colmissing(y)')
if(debug==1) "Sigma"
if(debug==1) Sigma
        dev = select(dev,!colmissing(y))
if(debug==1) "dev"
if(debug==1) dev

        V = S+Sigma
        if (riley) {
//            V = sqrt(diag(diagonal(V)))
            V = sqrt( I(cols(V)) :* V)
            V = V*corr(Sigma)*V
// thought this might be more accurate, 13jul2015, but for p53 it just increases #iter to 2026
//            for(r=1;r<=cols(S);r++) { 
//                for(s=1;s<=cols(S);s++) {
//                    V[r,s] = Sigma[r,s] * sqrt( (1+S[r,r]/Sigma[r,r]) * (1+S[s,s]/Sigma[s,s]) )
//                }
//            }
        }
if(debug==1) "V"
if(debug==1) V
        W = cholinv(V)
if(debug==1) "W"
if(debug==1) W
        ll = ll - add2pi*cols(dev)*log(2*pi())/2 + log(det(W))/2 - dev*W*dev'/2
if(debug==1) "ll"
if(debug==1) ll
        XWXsum = XWXsum + X*W*X'
if(rows(XWXsum) != rows(X)) "rows(XWXsum) != rows(X)"
if(debug==1) "XWXsum"
if(debug==1) XWXsum
    }
    rl = ll - log(det(XWXsum))/2 + add2pi*q*log(2*pi())/2
if(debug==1) "rl"
if(debug==1) rl
    st_numscalar("r(ll)",ll)
    st_numscalar("r(rl)",rl)
}
end

