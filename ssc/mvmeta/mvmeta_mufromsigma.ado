/*******************************************************************************************
MUFROMSIGMA PROGRAM - called by mvmeta.ado, mvmeta_lmata.ado and mvmeta_bscov_*.ado
*! version 3.1.3  Ian White  21jul2015
    also outputs error observation number as $MVMETA_obserror
version 3.1.2  Ian White  16jul2015
    incorporate id
    stops with error in non-pos-def S+Sigma is found
version 3.0.4  Ian White  15jun2015
    correct the calculation with wscorr(riley)
version 3.0.1  Ian White  27may2015
14may2015 - corrected bug in ll & rl constants - they now agree with those produced by mvmeta_lmata
version 2.0.4  Ian White  1feb2011 - corrects bug in eqnames; gives useful error message with unidentified model
version 2.0.5  Ian White  26feb2011 - names mu and varmu in same way as (RE)ML
      & optionally returns Qscalar
*******************************************************************************************/

program mvmeta_mufromsigma
syntax, sigma(string) [yhat(string) makeq debug] // yhat() is unused?
local debug = 0
*local debug = !mi("`debug'")
tempname mu varmu XWXsum sigmamat
local add2pi = ("$MVMETA_2pi"=="")
local makeq = ("`makeq'"=="makeq")
local riley  = ("$MVMETA_wscorr"=="riley")
if `debug' di as input "mvmeta_mufromsigma `0'"

* create string id variable
tempvar idstring
if mi("$MVMETA_id") {
    gen `idstring' = strofreal(_n)
    label var `idstring' "observation"
}
else {
    cap confirm string variable $MVMETA_id
    if !_rc { // id is string
        gen `idstring' = $MVMETA_id
    }
    else { // id is numeric: is it labelled?
        confirm numeric variable $MVMETA_id
        if mi("`:value label $MVMETA_id'") gen `idstring' = strofreal($MVMETA_id)
        else decode $MVMETA_id, gen(`idstring')
    }
    label var `idstring' "$MVMETA_id ="
}

mat `sigmamat' = `sigma'
mata: mufromsigma("`sigmamat'", "`mu'", "`varmu'", "`XWXsum'", `add2pi', `makeq', `riley', `debug', "`idstring'")
if matmissing(`XWXsum') {
    di as error "mvmeta_mufromsigma: XWXsum has missing values"
    exit 499
}
if matmissing(`varmu') {
    di as error "mvmeta_mufromsigma: sum of XWX could not be inverted - is the model identified?"
    exit 499
}
if "$MVMETA_xcons" != "" local xcons _cons

// Apply suitable row and column names
if "$MVMETA_parmtype"=="common" {
    local eqs $MVMETA_yvar_1 
    local names ${MVMETA_xvars_1} `xcons' 
}
else if "$MVMETA_parmtype"=="long" {
    forvalues r=1/$MVMETA_p {
        local eqname : word `r' of $MVMETA_ylist 
        foreach xvar in ${MVMETA_xvars_`r'} `xcons' { 
            local eqs `eqs' `eqname'
            local names `names' `xvar'
        }
    }
}
else if "$MVMETA_parmtype"=="short" {
    local eqs "Overall"
    local names $MVMETA_ylist
}
mat coleq `mu' = `eqs'
mat coleq `varmu' = `eqs'
mat roweq `varmu' = `eqs'
mat colnames `mu' = `names'
mat colnames `varmu' = `names'
mat rownames `varmu' = `names'

tempvar touse
gen `touse' = $MVMETA_touse
if `debug' {
    di "mvmeta_mufromsigma: debug is switched on"
    mat l `sigmamat', title(mvmeta_mufromsigma: sigma)
    mat l `mu', title(mvmeta_mufromsigma: mu)
    mat l `varmu', title(mvmeta_mufromsigma: varmu)
}
ereturn post `mu' `varmu', obs($MVMETA_n) esample(`touse')
end

mata:
void mufromsigma(string scalar Sigmaname,  // existing matrix name
                 string scalar muname,     // new matrix name
                 string scalar varmuname,  // new matrix name            
                 string scalar XWXsumname, // new matrix name             
                 real scalar add2pi,       // 0/1
                 real scalar makeQ,        // 0/1
                 real scalar riley,        // 0/1
                 real scalar debug,        // 0/1
                 string scalar idvar)
{
if(debug==1) "Debugging mvmeta_mufromsigma"
    Sig = st_matrix(Sigmaname)
    n = strtoreal(st_global("MVMETA_n"))
    p = rows(Sig)
    idname = st_varlabel(idvar)

    touse = st_data(.,st_global("MVMETA_touse"))
    idlist = st_sdata(.,idvar)
    obslist = (1..rows(idlist))' // new 21jul2015
    idlist = select(idlist,touse)
    obslist = select(obslist,touse) // new 21jul2015

    for(i=1;i<=n;++i) {
        identifier =  idname + " " + idlist[i,1]
        y = st_matrix(st_global("MVMETA_ymat")+strofreal(i))
if(debug==1) identifier
if(debug==1) "y"
if(debug==1) y
        S = st_matrix(st_global("MVMETA_Smat")+strofreal(i))
if(debug==1) "S"
if(debug==1) S
        X = st_matrix(st_global("MVMETA_Xmat")+strofreal(i))
if(debug==1) "X"
if(debug==1) X
        /* Restrict to submatrices with non-missing values */
        keep = !colmissing(y)
        S = select(S,keep)
        S = select(S,keep')
        Sigma = select(Sig,keep)
        Sigma = select(Sigma,keep')
        X = select(X,keep)
        y = select(y,keep)
        V = S+Sigma
        if (riley) {
if(debug==1) "V before Riley-ising"
if(debug==1) V
            V = sqrt(diag(diagonal(V)))
            V = V*corr(Sigma)*V
if(debug==1) "V after Riley-ising"
if(debug==1) V
        }
        W = cholinv(V)
if(debug==1) "W"
if(debug==1) W
        if (missing(W)>0) {
            errprintf("mvmeta_mufromsigma: error in S+Sigma at "+identifier+":\n")
            displayas("text")
            printf("Matrix S:\n")
            S
            printf("Matrix Sigma:\n")
            Sigma
            errprintf("S+Sigma is not positive definite\n")
            st_global("MVMETA_obserror",strofreal(obslist[i,1])) // new 21jul2015
            exit(506) // New 17jul2015
        }
        if (i==1) {
            yWXsum = y*W*X'
            XWXsum = X*W*X'
        } 
        else {
            yWXsum = yWXsum + y*W*X'
            XWXsum = XWXsum + X*W*X'
        }
    }
    varmu = cholinv(XWXsum)
if(debug==1) "varmu"
if(debug==1) varmu
    if (missing(varmu)>0) {
        errprintf("mvmeta_mufromsigma: in Mata, XWXsum (below) could not be inverted\n")
        XWXsum 
        exit(error(459)) // New 17jul2015
    }
    mu = yWXsum*varmu
if(debug==1) "mu"
if(debug==1) mu
    if (makeQ == 1) { /* compute Qscalar */
        real matrix Qscalar
        Qscalar = (0)
        sum_p = 0
        for(i=1;i<=n;++i) {
            y = st_matrix(st_global("MVMETA_ymat")+strofreal(i))
            S = st_matrix(st_global("MVMETA_Smat")+strofreal(i))
            X = st_matrix(st_global("MVMETA_Xmat")+strofreal(i))
            yhat = mu * X
            keep = !colmissing(y)
            S = select(S,keep)
            S = select(S,keep')
            yhat = select(yhat,keep)
            y = select(y,keep)
            Qscalar = Qscalar + (y-yhat)*cholinv(S)*(y-yhat)'
            sum_p = sum_p + cols(y)
        }
        st_numscalar("r(Qscalar)",Qscalar)
        st_numscalar("r(sum_p)",sum_p)
    }
    st_matrix(muname,mu)
    st_matrix(varmuname,varmu)
    st_matrix(XWXsumname,XWXsum)

    /* extra to return (restricted) loglik */
    ll=0
    for(i=1;i<=n;++i) {
        y = st_matrix(st_global("MVMETA_ymat")+strofreal(i))
        S = st_matrix(st_global("MVMETA_Smat")+strofreal(i))
        X = st_matrix(st_global("MVMETA_Xmat")+strofreal(i))
        keep = !colmissing(y)
        S = select(S,keep)
        S = select(S,keep')
        Sigma = select(Sig,keep)
        Sigma = select(Sigma,keep')
        X = select(X,keep)
        y = select(y,keep)
        V = S+Sigma
        if (riley) {
//            V = sqrt(diag(diagonal(V)))
            V = sqrt( I(cols(V)) :* V)
            V = V*corr(Sigma)*V
//            for(r=1;r<=cols(S);r++) {
//                for(s=1;s<=cols(S);s++) {
//                    V[r,s] = Sigma[r,s] * sqrt( (1+S[r,r]/Sigma[r,r]) * (1+S[s,s]/Sigma[s,s]) )
//                }
//            }
        }
        W = cholinv(V)
        dev = y-mu*X
        ll = ll - add2pi*cols(y)*log(2*pi())/2 + log(det(W))/2 - dev*W*dev'/2
        // 14may2015: cols(y) (i.e. p_i) replaces p 
    }
    rl = ll - log(det(XWXsum))/2 + add2pi*cols(mu)*log(2*pi())/2
        // 14may2015: cols(mu) (i.e. q_+) replaces p
if(debug==1) "rl"
if(debug==1) rl
    st_numscalar("r(ll)",ll)
    st_numscalar("r(rl)",rl)
    
}
end

*========================== END OF MUFROMSIGMA PROGRAM ============================

