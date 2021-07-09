/******************************************************************************
*! version 3.0.2  Ian White  9jun2015
    handles failure by returning missing matrix
version 3.0.1  Ian White  27may2015
version 2.3.4  Ian White       30mar2015
    deleted unused prog mmnew4
version 2.3.3  Ian White       15nov2011
Unstructured between-studies variance Sigma
******************************************************************************/

program define mvmeta_bscov_unstructured, rclass

syntax [if] [in], [cholnames                        ///
    setup start(string)                 /// Set up
    mm1 mm2 notrunc                      /// Method of moments
    varparms(string)                    /// Within -ml-
    postfit                             /// After -ml-
    debug mmfix   ]
if "`debug'"=="debug" di as input "mvmeta_bscov_unstructured `0'"
local p $MVMETA_p
marksample touse
tempname chol Sigma binit init

if "`cholnames'"=="cholnames" {
    forvalues r=1/`p' {
        local y`r' = word("$MVMETA_ylist",`r')
    }
}

if "`setup'"!="" {
    di as text "Note: variance-covariance matrix is " as result "unstructured"
    // Set Sigma to starting value
    if "`start'"=="" mat `Sigma' = I(`p')
    else {
        cap mat `Sigma' = `start'
        if _rc {
            di as error `"mvmeta_bscov_unstructured: start() must be a `p'x`p' matrix"'
            exit 498
        }
        if rowsof(`Sigma')!=`p' | colsof(`Sigma')!=`p' {
            di as error `"mvmeta_bscov_unstructured: start() must be a `p'x`p' matrix"'
            exit 498
        }
        if trace(`Sigma')==0 {
            di as error `"mvmeta_bscov_unstructured: start() has trace zero: changed to I(`p')"'
            mat `Sigma' = I(`p')
        }
    }
    mvmeta_mufromsigma, sigma(`Sigma')
    mat `binit' = e(b)
    cholesky2 `Sigma' `chol' 
    * add chol into inits
    mat `init'=`binit'
    forvalues r=1/`p' {
         mat `init' = `init', `chol'[`r',1..`r']
    }
    return local nvarparms = `p'*(`p'+1)/2
    return matrix binit=`binit'
    return matrix init=`init'
    // SET UP EQUATIONS
    forvalues r=1/`p' {
        forvalues s=1/`r' {
            local eq = cond("`cholnames'"=="cholnames", "c_`y`s''_`y`r''", "chol`s'`r'")
            local eqlist2 `eqlist2' (`eq':)
        }
    }
    return local eqlist `eqlist2'
}

if "`varparms'" != "" {
    mat `chol' = J(`p',`p',0)
    local k 0
    forvalues r=1/`p' {
       forvalues s=1/`r' {
          local ++k
          matrix `chol'[`r',`s'] = `varparms'[1,`k']
       }
    }
    matrix `Sigma'=`chol'*`chol''
}

if "`postfit'" != "" {
    mat `chol'=J(`p',`p',0)
    forvalues r=1/`p' {
        forvalues s=1/`r' {
            local eq = cond("`cholnames'"=="cholnames", "c_`y`s''_`y`r''", "chol`s'`r'")
            matrix `chol'[`r',`s'] = [`eq']_b[_cons]
        }
    }
    matrix `Sigma'=`chol'*`chol''
    mat rownames `Sigma' = $MVMETA_ylist
    mat colnames `Sigma' = $MVMETA_ylist
    // SET UP NLCOM EXPRESSIONS
    // Note problem: If an element is too close to 0, nlcom fails with message "Maximum number of iterations exceeded". My first fix was to ignore elements smaller than 1E-8, but now I just ignore elements that make nlcom fail.
    forvalues r=1/`p' {
        forvalues s=1/`r' {
            forvalue t=1/`s' {
                local plus = cond("`nlcom`s'`r''"=="","","+")
                local nlcom`s'`r' `nlcom`s'`r'' `plus' [chol`t'`r']_b[_cons]*[chol`t'`s']_b[_cons]
            }
            return local Sigma`s'`r' `nlcom`s'`r''
        }
    }
}

// METHOD OF MOMENTS
if ("`mm1'"=="mm1") | ("`mm2'"=="mm2") {    
    tempname Q Qa Qb 
    * READ GLOBAL MACROS
    local ylist $MVMETA_ylist
    local xcons $MVMETA_xcons
    forvalues r = 1/`p' {
        local var`r' ${MVMETA_yvar_`r'}
        local xvars_`r' ${MVMETA_xvars_`r'} 
        forvalues s = `r'/`p' {
            local cov`r'`s' ${MVMETA_Svar_`r'_`s'}
        }
    }
    if "`mm1'"=="mm1" {    // ORIGINAL METHOD OF MOMENTS
        * NB this code uses the original variables, not the matrices: it is sensitive to missingness
        tempname Mu varMu pred xi AX AY A P psisqrt WX WY VX VY ael bel 
        tempvar ok w wsqrt term mmcorr
        foreach name in `Q' `Qa' `Qb' `Sigma' { 
            matrix `name' = J(`p',`p',.)
            matrix rownames `name' = `ylist'
            matrix colnames `name' = `ylist'
        }
        forvalues r = 1/`p' {
            forvalues s = `r'/`p' {
                qui gen `ok' = !missing(`var`r'') & !missing(`var`s'') if `touse'
                qui count if `ok' & `touse'
                local n_ok = r(N)
                qui gen `w'=1/sqrt(`cov`r'`r''*`cov`s'`s'') if `ok' & `touse'
                qui replace `w'=0 if !`ok' & `touse'
                * FIT MODEL TO APPROPRIATE OBSERVATIONS & GET FITTED VALUES 
                cap drop `pred'*
                cap reg `var`r'' `xvars_`r'' [aw=`w'] if `touse', `constant'
                cap predict double `pred'`r' if `touse'
                if `s'>`r' {
                    cap reg `var`s'' `xvars_`s'' [aw=`w'] if `touse', `constant'
                    cap predict double `pred'`s' if `touse'
                }
                * Q MATRIX
                cap gen `term'=`w'*(`var`r''-`pred'`r')*(`var`s''-`pred'`s') if `ok' & `touse'
                if !_rc {
                    summ `term' if `touse', meanonly
                    matrix `Q'[`r',`s'] = r(sum)
                    * EXPECTATION OF Q MATRIX
                    mkmat `xvars_`r'' `xcons' if `ok' & `touse', matrix(`WX')
                    mkmat `xvars_`s'' `xcons' if `ok' & `touse', matrix(`WY')
                    qui gen double `wsqrt' = sqrt(`w') if `ok' & `touse'
                    mkmat `wsqrt' if `ok' & `touse', matrix(`psisqrt')
                    mat `psisqrt' = diag(`psisqrt')
                    qui gen double `mmcorr' = `cov`r'`s''/sqrt(`cov`r'`r''*`cov`s'`s'') if `ok' & `touse'
                    mkmat `mmcorr' if `ok' & `touse', matrix(`P')
                    matrix `P' = diag(`P')
                    mat `VX' = `psisqrt' * `WX'
                    mat `VY' = `psisqrt' * `WY'
                    mat `AX' = I(`n_ok') - `VX'*syminv(`VX''*`VX')*`VX''
                    mat `AY' = I(`n_ok') - `VY'*syminv(`VY''*`VY')*`VY''
                    mat `A' = `AX''*`AY'
                    mat `ael' = trace(`A'*`P')
                    mat `bel' = trace(`A'*`psisqrt'*`psisqrt')
                    matrix `Qa'[`r',`s'] = `ael'[1,1]
                    matrix `Qb'[`r',`s'] = `bel'[1,1]
                    * SOLVE FOR SIGMA
                    matrix `Sigma'[`r',`s'] = (`Q'[`r',`s']-`Qa'[`r',`s']) / `Qb'[`r',`s']
                    foreach name in `Q' `Qa' `Qb' `Sigma' { 
                        matrix `name'[`s',`r'] = `name'[`r',`s']
                    }
                    drop `term' `wsqrt' `mmcorr'
                }
                if `Sigma'[`r',`s'] == . {
                    if `s'>`r' & "`mmfix'"=="mmfix" {
                        di as error "Method of moments warning: Sigma[`r',`s'] could not be computed and is being set to 0"
                        matrix `Sigma'[`r',`s'] = 0
                        matrix `Sigma'[`s',`r'] = 0
                    }
                    else {
*                        di as error "Method of moments error: Sigma[`r',`s'] could not be computed"
*                        di as error "    (consider mmfix option)."
                    }
                }
                drop `ok' `w'
            }
        }
        if "`debug'"=="debug" {
            foreach matrix in Q Qa Qb {
                mat list ``matrix'', title(Method of moments: `matrix' matrix)
            }
            mat list `Sigma', title(Method of moments: untruncated estimate of Sigma) 
        }
    }
    else if "`mm2'"=="mm2" {
        mata: mmnew5("$MVMETA_ymat","$MVMETA_Smat","$MVMETA_Xmat", ///
                "`Sigma'","`Q'","`Qa'","`Qb'","`debug'")
        foreach name in `Q' `Sigma' { 
            matrix rownames `name' = `ylist'
            matrix colnames `name' = `ylist'
        }
    }
    * at this point we have `Sigma' as the MM estimate

    * TRUNCATION
    if matmissing(`Sigma') {
        if "`debug'"=="debug" di as error "Warning: Sigma could not be computed by method of moments"
        mat `Sigma' = J(`p',`p',.)+`Sigma' // this syntax keeps row/colnames
        local negevals .
    }
    else { // count negative evals, and optionally set to 0 
        local negevals 0
        tempname evecs evals
        mat symeigen `evecs' `evals' = `Sigma'
        forvalues r=1/`p' {
            if `evals'[1,`r']<0 {
                mat `evals'[1,`r']=0
                local ++negevals
            }
        }
        if "`trunc'"!="notrunc" mat `Sigma' = `evecs'*diag(`evals')*`evecs''
    }
    
    * TIDY UP AND RETURN
    mat colnames `Sigma'=`ylist'
    if "`debug'"=="debug" mat list `Sigma', title(Method of moments: possibly truncated estimate of Sigma) 
    return scalar negevals = `negevals'
    return matrix Q = `Q'
    return matrix Qa = `Qa'
    return matrix Qb = `Qb'
}

// COMMON ENDING FOR ALL OPTIONS
*mat rownames `Sigma' = $MVMETA_ylist
return matrix Sigma = `Sigma'
return scalar nparms_aux = `p'*(`p'+1)/2
return scalar neqs_aux = `p'*(`p'+1)/2
end

*============================= CHOLESKY2 PROGRAM ===============================

program cholesky2
* produce an approximate cholesky decomposition, even if matrix is not positive definite
args M C
cap matrix `C' = cholesky(`M')
if _rc {
    local eps = trace(`M')/1000
    if `eps'<=0 {
        di as error "cholesky2: matrix `M' has non-positive trace"
        matrix list `M'
        exit 498
    }
    local p = rowsof(`M')
    cap matrix `C' = cholesky(`M'+`eps'*I(`p'))
    if _rc {
        di as error "cholesky2: can't decompose matrix `M'"
        matrix list `M'
        exit 498
    }
}
end

*============================= END OF CHOLESKY2 PROGRAM ===============================

*=================== NEW MM PROGRAM - META-REGRESSION VERSION ================

mata:
void mmnew5(string scalar yname, 
            string scalar Sname, 
            string scalar Xname, 
            string scalar Sigmaname,
            string scalar Qname,
            string scalar vecbtrBname,
            string scalar BcrossAtermname,
            | string scalar debug)
{ // Notation as in Dan's article
    if(debug=="debug") "mmnew5: Starting loop 0: find p and n"
    for(i=1;1;++i) {
        y = st_matrix(yname+strofreal(i))'
        if(i==1) p=rows(y)
        if(!rows(y)) break
    }
    n=i-1
    
    if(debug=="debug") "mmnew5: Starting loop 1: set up data"
    yy = J(n,1,NULL)
    SS = J(n,1,NULL)
    WW = J(n,1,NULL)
    RR = J(n,1,NULL)
    XX = J(n,1,NULL)
    for(i=1;i<=n;++i) {
        y = st_matrix(yname+strofreal(i))'
        r = !colmissing(y')
        S = st_matrix(Sname+strofreal(i))
        S = editmissing(S,0)
        X = st_matrix(Xname+strofreal(i))
        if(i==1) p=rows(y)
        if(i==1) qplus=rows(X)
        small = select(I(p),r')
        Ssmall = small*S*small'
        Wsmall = cholinv(Ssmall)
        yy[i] = &(editmissing(y,0))
        RR[i] = &(diag(r))
        SS[i] = &(small'*Ssmall*small)
        WW[i] = &(small'*Wsmall*small)
        XX[i] = &(X')  // NB &(X) makes all XX's point to same (last) X
    }
    
    if(debug=="debug") "mmnew5: Starting loop 2: regress y on x"
    XWXsum = J(qplus,qplus,0)
    XWysum = J(qplus,1,0)
    for(i=1;i<=n;++i) {
        y = *(yy[i])
        W = *(WW[i])
        X = *(XX[i])
        XWXsum = XWXsum + X'*W*X
        XWysum = XWysum + X'*W*y
    }
    beta = cholinv(XWXsum)*XWysum
    if(debug=="debug") "mmnew5: beta"
    if(debug=="debug") beta
    
    Wsuminv = cholinv(Wsum)
    ybar = Wsuminv*Wysum
    Q = J(p,p,0)
    A = J(p,p,0)
    Bvec = J(p^2,p^2,0)
    
    if(debug=="debug") "mmnew5: Starting loop 3: to find Q and hence Sigma"
    for(i=1;i<=n;++i) {
        y = *(yy[i])
        W = *(WW[i])
        X = *(XX[i])
        R = *(RR[i])
        yhat = X*beta
        Q = Q + W*(y-yhat)*(y-yhat)'*R
        if(i==1) bigX=X
        else bigX=(bigX \ X)
        if(i==1) bigW=W
        else bigW=blockdiag(bigW, W)
        if(i==1) bigR=R
        else bigR=blockdiag(bigR, R)
    }
    if(debug=="debug") "mmnew5: Q"
    if(debug=="debug") Q
    if(debug=="debug") "mmnew5: bigW"
    if(debug=="debug") bigW
    if(debug=="debug") "mmnew5: bigX"
    if(debug=="debug") bigX

    bigH = bigX*cholinv(bigX'*bigW*bigX)*bigX'*bigW
    if(debug=="debug") "mmnew5: bigH"
    if(debug=="debug") bigH

    bigA = (I(n*p) - bigH)' * bigW
    if(debug=="debug") "mmnew5: bigA"
    if(debug=="debug") bigA

    bigB = (I(n*p) - bigH)' * bigR
    if(debug=="debug") "mmnew5: bigB"
    if(debug=="debug") bigB

    btrB = J(p,p,0)
    BcrossAterm = J(p^2,p^2,0)
    for(i=1;i<=n;i++) {
        iu=i*p
        il=(i-1)*p+1
        btrB = btrB + bigB[|il, il \ iu, iu|]
        for(j=1;j<=n;j++) {
            ju=j*p
            jl=(j-1)*p+1
            Aij = bigA[|il, jl \ iu, ju|]
            Bji = bigB[|jl, il \ ju, iu|]     
            BcrossAterm = BcrossAterm + Bji' # Aij 
        }
    }
    if(debug=="debug") "mmnew5: btrB"
    if(debug=="debug") btrB
    if(debug=="debug") "mmnew5: BcrossAterm"
    if(debug=="debug") BcrossAterm
    
    vecSigma = luinv(BcrossAterm) * vec(Q-btrB)
    SigmaL=rowshape(vecSigma,p)
    SigmaR = SigmaL'
    Sigma=(SigmaL+SigmaR)/2
    if(debug=="debug") "mmnew5: Sigma"
    if(debug=="debug") Sigma
    
    /* Return results */
    st_matrix(Sigmaname,Sigma)
    st_matrix(Qname,Q)
    st_matrix(vecbtrBname,vec(btrB))
    st_matrix(BcrossAtermname,BcrossAterm)

}
end

*========================== END OF NEW MM PROGRAM ============================
