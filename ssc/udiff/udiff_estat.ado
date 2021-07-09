*! version 1.0.1  03apr2020  Ben Jann & Simon Seiler

program udiff_estat, rclass
    version 11
    if replay() {
        Display `0'
        exit
    }
    if "`e(cmd)'" != "udiff" {
        error 301
    }
    gettoken cmd rest : 0, parse(", ")
    local l = length(`"`cmd'"')
    if `"`cmd'"'==substr("rescale",1,max(3,`l')) {
        Rescale `rest'
    }
    else if `"`cmd'"'==substr("lambda",1,max(3,`l')) {
        Lambda `rest'
    }
    else if `"`cmd'"'==substr("kappa",1,max(3,`l')) {
        Kappa `rest'
    }
    else {
        estat_default `0'
    }
    return add
end

program Display
    if "`e(cmd)'" != "udiff_estat" {
        error 301
    }
    syntax [, COMPact noPValues noCI * ]
    if "`pvalues'"!="" {
        di as err "option {bf:nopvalues} not allowed"
        exit 198
    }
    Display_header
    if `"`e(subcmd)'"'=="lambda" & "`compact'"!="" {
        matlist e(lambda), nohalf border(rows)
        exit
    }
    di ""
    if c(stata_version)>=12 {
        if c(stata_version)>=14 {
            if "`ci'"=="" local nopvalue nopvalue
            eret di, `ci' `nopvalue' `options'
        }
        else if c(stata_version)>=13 {
            quietly update
            if r(inst_ado)>=d(26jun2014) {
                if "`ci'"=="" local nopvalue nopvalue
                eret di, `ci' `nopvalue' `options'
            }
            else {
                if "`ci'"=="" local nopvalue cionly
                _coef_table, `ci' `nopvalue' `options'
            }
        }
        else {
            if "`ci'"=="" local nopvalue cionly
            _coef_table, `ci' `nopvalue' `options'
        }
    }
    else {
        eret di, `ci' `options'
    }
end

program Display_header, eclass
    if c(stata_version)>=12 {
        nobreak {
            local cmd `"`e(cmd)'"'
            eret local cmd "total" // mimick header of -total-
            capture noisily break {
                _coef_table_header
            }
            eret local cmd `"`cmd'"'
            if _rc exit _rc
        }
    }
    else _coef_table_header
end

program Post_and_display, eclass
    args subcmd k b V mat post options title
    local N = e(N)
    local vce `"`e(vce)'"'
    local vcetype `"`e(vcetype)'"'
    if `"`e(clustvar)'"'!="" {
        local clustvar `"`e(clustvar)'"'
        local N_clust = e(N_clust)
    }
    tempname ecurrent
    _estimates hold `ecurrent', restore
    eret post `b' `V', obs(`N')
    if "`subcmd'"=="lambda" {
        eret matrix lambda = `mat'
    }
    eret local title `"`title'"'
    eret local cmd "udiff_estat"
    eret local subcmd "`subcmd'"
    eret local vce `"`vce'"'
    eret local vcetype `"`vcetype'"'
    eret local estat_cmd "udiff_estat"
    eret scalar k_eq = `k'
    eret scalar k_eform = `k'
    if `"`clustvar'"'!="" {
        eret local clustvar `"`clustvar'"'
        eret scalar N_clust = `N_clust'
    }
    Display, `options'
    if "`post'"!="" {
        _estimates unhold `ecurrent', not
    }
    else {
        rReturn
    }
end

program rReturn, rclass
    return add
    local N = e(N)
    tempname b V
    matrix `b' = e(b)
    matrix `V' = e(V)
    return scalar N = `N'
    return matrix b = `b'
    return matrix V = `V'
    if `"`e(subcmd)'"'=="lambda" {
        tempname lambda
        matrix `lambda' = e(lambda)
        return matrix lambda = `lambda'
    }
end

program Confirm_fv
    args b
    forv j = 1/`=colsof(`b')' {
        _ms_element_info, element(`j') matrix(`b')
        if `"`r(type)'"'!="factor" {
            c_local isfv 0
            exit
        }
    }
    c_local isfv 1
end

program Rescale
    if `"`e(cfonly)'"'!="" {
        di as err "{bf:estat rescale} not allowed after a constant-fluidity model"
        exit 499
    }
    syntax [anything(name=terms)] [, post * ]
    _get_diopts options, `options'
    local nunidiff = e(k_unidiff)   // number of unidiff terms in model
    if `"`terms'"'!="" {
        numlist `"`terms'"', integer range(>=1)
        local terms  "`r(numlist)'"  // unidiff terms to be transformed
        local terms: list uniq terms // remove doubles
        local terms0 "`terms'"
    }
    local COEFS     // list of names of coefficients to be transformed
    local J0        // start indices of unidiff terms to be transformed
    local J1        // end indices of unidiff terms to be transformed
    local j1 = 0    // counter for start index
    local nu = 0    // number of unidiff terms to be transformed
    local K  = 0    // total number of coefficients to be transformed
    local errmsg "unidiff term \`i' not feasible for transformation"
    tempname b V
    forv i = 1/`nunidiff' {
        if `nunidiff'==1 {
            local layervars `"`e(layervars)'"'
            local Phi Phi
        }
        else {
            local layervars `"`e(layervars`i')'"'
            local Phi Phi`i'
        }
        mat `b' = e(b)
        mat `b' = `b'[1,"`Phi':"]
        local k = colsof(`b')
        local j0 = `j1' + 1
        local j1 = `j0' + `k' - 1
        if `"`terms'"'!="" { // check whether current term is in requested list
            local userterm: list i in terms
            if `userterm'==0 continue
            local terms0: list terms0 - i   // update remaining list
        }
        else local userterm 0
        if `: list sizeof layervars'>1 { // multiple layer variables
            local isfv 0
        }
        else {
            Confirm_fv `b' // returns local isfv
        }
        if `isfv'==0 {
            if `userterm' {
                di as err `"`errmsg'"'
                error 499
            }
            di as txt `"(`errmsg')"'
            continue
        }
        local coefs: colfullnames `b'
        local COEFS `COEFS' `coefs'
        local J0 `J0' `j0'
        local J1 `J1' `j1'
        local K = `K' + `k'
        local ++nu
    }
    foreach i of local terms0 {
        di as err "unidiff term `i' not found in model"
        exit 499
    }
    if `K'==0 { // model contains no feasible unidiff term
        di as err "no feasible unidiff terms found in model"
        exit 499
    }
    local COEFS: subinstr local COEFS "b." ".", all
    mata: estat_rescale()
    mat coln `b' = `COEFS'
    mat coln `V' = `COEFS'
    mat rown `V' = `COEFS'
    Post_and_display rescale `nu' `b' `V' "" "`post'" `"`options'"' ///
        "Normalized unidiff parameters"
end

program Lambda
    if `"`e(cfonly)'"'!="" {
        di as err "{bf:estat lambda} not allowed after a constant-fluidity model"
        exit 499
    }
    syntax [anything(name=term)] [, post COMPact STDize eform * ]
    _get_diopts options, `options'
    if "`eform'"!="" local eform eform(exp(b))
    local options `compact' `eform' `options'
    local eform = (`"`eform'"'!="")
    if `"`term'"'=="" local term 1
    local nunidiff = e(k_unidiff)
    else {
        numlist `"`term'"', integer range(>=1) max(1)
        local term "`r(numlist)'"
        if `term'>`nunidiff' {
            di as err "unidiff term `term' not found in model"
        exit 499
        }
    }
    if `nunidiff'==1 {
        local layervar `"`e(layervars)'"'
        local Phi Phi
        local Psi Psi
    }
    else {
        local layervar `"`e(layervars`i')'"'
        local Phi Phi`term'
        local Psi Psi`term'
    }
    if `:list sizeof layervar'>1 {
        di as err "{bf:estat lambda} not allowed with multiple layer variables"
        exit 499
    }
    // layer variables info
    tempname b V
    mat `b' = e(b)
    local k0 = colnumb(`b',"`Phi':")
    mat `b' = `b'[1,"`Phi':"]
    Confirm_fv `b' // returns local isfv
    if  `isfv'==0 {
        di as err "{bf:estat lambda} only allowed if {it:layervar} is a factor variable"
        exit 499
    }
    local K = colsof(`b')   // number layer levels
    local layer: coln `b'
    local layer: subinstr local layer "b." ".", all
    // outcome info
    local depvar `"`e(depvar)'"'
    local ibase = e(ibaseout)
    local out `"`e(out)'"'
    local C = e(k_out)
    // xvar info
    forv i=1/`C' { // get first outcome that is not base
        if `i'==`ibase' continue
        local first: word `i' of `out'
        continue, break
    }
    mat `b' = e(b)
    local i0 = colnumb(`b',"`Psi'_`first':")
    mat `b' = `b'[1,"`Psi'_`first':"]
    Confirm_fv `b' // returns local isfv
    if  `isfv'==0 {
        di as err "{bf:estat lambda} only allowed if {it:xvar} is a factor variable"
        exit 499
    }
    local R = colsof(`b')   // number xvar levels
    local coefs: coln `b'
    local coefs: subinstr local coefs "b." ".", all
    // compute lambda
    mata: estat_lambda("`stdize'"!="")
    // compile overview matrix
    tempname lambda
    mat `lambda' = J(`K'*`R',`C',.)
    local r 0
    local k 0
    foreach l of local layer {
        local ++k
        local j 0
        foreach o of local out {
            local ++j
            local i = (`k'-1) * `R'
            foreach coef of local coefs {
                local ++i
                local ++r
                if `eform' {
                    mat `lambda'[`i', `j'] = exp(`b'[1,`r'])
                }
                else {
                    mat `lambda'[`i', `j'] = `b'[1,`r']
                }
            }
        }
    }
    local COEFS
    foreach o of local out {
        local COEFS `COEFS' `o'.`depvar'
    }
    mat coln `lambda' = `COEFS'
    local COEFS
    foreach l of local layer {
        foreach coef of local coefs {
            local COEFS `COEFS' `l':`coef'
        }
    }
    mat rown `lambda' = `COEFS'
    // coefficient names for b and V
    local COEFS
    foreach l of local layer {
        foreach o of local out {
            foreach coef of local coefs {
                local COEFS `COEFS' `o'.`depvar'@`l':`coef'
            }
        }
    }
    mat coln `b' = `COEFS'
    mat coln `V' = `COEFS'
    mat rown `V' = `COEFS'
    // return results
    if "`stdize'"!="" local title "Std. lambda coefficients"
    else local title "Lambda coefficients"
    if `nunidiff'>1 {
        local title "`title' (`Phi')"
    }
    Post_and_display lambda `=`C'*`K'' `b' `V' `lambda' "`post'" ///
        `"`options'"' "`title'"
end

program Kappa
    if `"`e(cfonly)'"'!="" {
        di as err "{bf:estat kappa} not allowed after a constant-fluidity model"
        exit 499
    }
    syntax [anything(name=term)] [, post * ]
    _get_diopts options, `options'
    if `"`term'"'=="" local term 1
    local nunidiff = e(k_unidiff)
    else {
        numlist `"`term'"', integer range(>=1) max(1)
        local term "`r(numlist)'"
        if `term'>`nunidiff' {
            di as err "unidiff term `term' not found in model"
        exit 499
        }
    }
    if `nunidiff'==1 local Phi Phi
    else             local Phi Phi`term'
    // compute kappa
    quietly Lambda `term', stdize
    tempname lambda
    mat `lambda' = r(lambda)
    local C = colsof(`lambda')
    local coefs: roweq `lambda'
    local coefs: list uniq coefs
    local K: list sizeof coefs
    local R = rowsof(`lambda') / `K'
    tempname b V
    mata: estat_kappa()
    mat coln `b' = `coefs'
    mat coln `V' = `coefs'
    mat rown `V' = `coefs'
    // return results
    local title "Kappa indices"
    if `nunidiff'>1 {
        local title "`title' (for `Phi')"
    }
    Post_and_display kappa 1 `b' `V' "" "`post'" `"`options'"' "`title'"
end

version 11
mata:
mata set matastrict on

void estat_rescale()
{
    real scalar    c, j, j0, j1, i0, i1, K, S
    real colvector e, e2, b, p
    real matrix    G, J
    
    K = strtoreal(st_local("K"))
    J = strtoreal(tokens(st_local("J0"))) \ strtoreal(tokens(st_local("J1")))
    b = p = J(1,K,.); G = J(K,K,0)
    i1 = 0
    c = cols(J)
    for (j=1;j<=c;j++) {
        j0 = J[1,j]; j1 = J[2,j]
        e  = exp(st_matrix("e(b)")[|j0 \ j1|])'
        e2 = e:^2
        S  = sum(e2)
        i0 = i1 + 1
        i1 = i0 + (j1-j0)
        b[|i0 \ i1|]       = e' / sqrt(S)
        G[|i0,i0 \ i1,i1|] = (diag(e * S) - e * e2') * S^(-3/2)
        p[|i0 \ i1|]       = (j0..j1)
    }
    st_matrix(st_local("b"), b)
    st_matrix(st_local("V"), makesymmetric(G * st_matrix("e(V)")[p,p] * G'))
}

void estat_lambda(real scalar std)
{
    real scalar    i0, R, j, C, k, k0, K, base, r, r0, a, b, a0, b0
    real rowvector phi, psi, lambda, rr, cc
    real matrix    G, L, RC
    
    C = strtoreal(st_local("C"))        // outcome levels
    R = strtoreal(st_local("R"))        // xvar levels
    K = strtoreal(st_local("K"))        // layer levels
    base = strtoreal(st_local("ibase")) // index of outcome base level

    k0 = strtoreal(st_local("k0"))
    phi = exp(st_matrix("e(b)")[|k0 \ k0-1+K|])      // unidiff parameters
    i0 = strtoreal(st_local("i0"))
    psi = st_matrix("e(b)")[|i0 \ i0-1+R*(C-1)|]     // psi coefficients
    r0 = K + R * (C - 1)    // number of input coefficients
    r  = R * C * K          // number of output coefficients
    lambda = J(1, r, 0)
    G  = J(r, r0, 0)
    b = 0
    for (k=1;k<=K;k++) {
        b0 = 0
        for (j=1;j<=C;j++) {
            a = b + 1
            b = b + R
            if (j==base) {
                continue
            }
            a0 = b0 + 1
            b0 = b0 + R
            lambda[|a \ b|] = psi[|a0 \ b0|] * phi[k]
            if (!std) {
                G[|a,k \ b,k|] = lambda[|a \ b|]'
                G[|a,K+a0 \ b,K+b0|] = diag(J(R,1,phi[k]))
            }
        }
    }
    if (std) {
        b = 0
        rr = mod((0..R*C-1), R) :+ 1    // row indicator
        cc = ceil((1..R*C) / R)         // column indicator
        RC = cc[|1 \ R*(C-1)|]
        RC = (cc' :== J(R*C, 1, RC + (RC:>=base)))   // shift base
        RC = 1 :+ (rr':==J(R*C, 1, rr[|1 \ R*(C-1)|])) * R :* (RC * C :- 1) ///
               :- RC * C // (1 + [R*C] - [R] - [C])
        for (k=1;k<=K;k++) {
            a = b + 1
            b = b + R * C
            L = rowshape(lambda[|a \ b|], C)'
            lambda[|a \ b|] = lambda[|a \ b|] ///
                - colsum(L)[cc]/R - rowsum(L)[rr]'/C :+ sum(L)/(R*C)
            G[|a,k \ b,k|]   = lambda[|a \ b|]'
            G[|a,K+1 \ b,.|] = J(R*C, R*(C-1), phi[k] / (R*C)) :* RC
        }
    }
    st_matrix(st_local("b"), lambda)
    rr = (k0..k0-1+K, i0..i0-1+R*(C-1))
    st_matrix(st_local("V"), makesymmetric(G * st_matrix("e(V)")[rr,rr] * G'))
}

void estat_kappa()
{
    real scalar     R, C, K, k, a, b
    real rowvector  lambda, kappa
    real matrix     G
    
    R = strtoreal(st_local("R"))        // xvar levels
    C = strtoreal(st_local("C"))        // outcome levels
    K = strtoreal(st_local("K"))        // layer levels

    lambda = st_matrix("r(b)")
    kappa = J(1, K, .)
    G = J(K, R*C*K, 0)
    b = 0
    for (k=1; k<=K; k++) {
        a = b + 1
        b = b + R*C
        kappa[k] = sqrt(sum(lambda[|a \ b|]:^2) / (R*C))
        G[|k,a \ k,b|] = lambda[|a \ b|] / (R*C*kappa[k]) 
    }
    st_matrix(st_local("b"), kappa)
    st_matrix(st_local("V"), makesymmetric(G * st_matrix("r(V)") * G'))
}

end
