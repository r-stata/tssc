*! version 1.0.6  20may2008  Ben Jann
program define fairlie, rclass
    version 9.2
    capt syntax [, Level(passthru) noLEgend ]
    if _rc==0 {
        Display `0'
        exit
    }
    syntax anything(id="varlist") [if] [in] [fw pw iw], by(varname) [ ///
        Reps(int 100) REFerence(str) Pooled Pooled2(varlist) ro ///
        probit Level(passthru) noDots noEst SAVEest(name) noLEgend * ]

//=> preprocess some options
    if `reps' < 1 {
        di as err "reps() must be a positive integer"
        exit 198
    }
    if `"`pooled2'"'!="" local pooled pooled
    if `"`reference'"'!="" {
        if "`pooled'"!="" {
            di as err "pooled() and reference() not both allowed"
            exit 198
        }
        if `"`reference'"'!="0" & `"`reference'"'!="1" {
            di as err "reference() must be 0 or 1"
            exit 198
        }
    }
    if `"`pooled'"'=="" & `"`reference'"'=="" local reference 0
    if "`probit'"!="" local cmd probit
    else local cmd logit
    if "`est'"!="" local qui quietly

//=> parse groups of variables: vgrp1, vgrp2, ...
    gettoken depvar rest: anything
    local i 0
    local space
    while (1) {
        if `"`rest'"'=="" continue, break
        gettoken group rest : rest, match(paren)
        if `"`paren'"'=="" {
            unab group: `group'
            foreach var of local group {
                local vgrp`++i' `var'
                local idepvars `idepvars' `var'
                local vgrpnms `vgrpnms' `var'
            }
        }
        else {
            if index(`"`group'"',":") {
                gettoken gname vars : group, parse(":")
                gettoken colon vars : vars, parse(":")
                local gname = trim(`"`gname'"')
                unab vars: `vars'
            }
            else {
                gettoken gname : group
                unab vars: `group'
            }
            local vgrp`++i' `vars'
            local idepvars `idepvars' `vars'
            local vgrpnms `vgrpnms' `gname'
            local vgrplegend `"`vgrplegend'`space'"`gname': `vars'""'
            local space " "
        }
    }
    local nvgrps `i'
    if `"`idepvars'"'=="" {
        di as err "too few variables specified"
        exit 198
    }


//=> mark samples
    marksample touse, novarlist
    markout `touse' `depvar' `pooled2' `idepvars'
*   if "`pooled'"!="" & `"`pooled2'"'=="" markout `touse' `by'
    capt assert `by'==0|`by'==1 if `touse' & `by'<.
    if _rc {
        di as err "groupvar must be 0/1"
        exit 198
    }
    tempvar touse0 touse1
    qui gen `touse0' = `touse' & `by'==0
    qui gen `touse1' = `touse' & `by'==1

//=> overall statistics
    if "`weight'"=="pweight" {
        local suweight "aweight"
    }
    else {
        local suweight "`weight'"
    }
    tempname depvar01 p0 p1 d
    qui gen byte `depvar01' = `depvar'!=0 if `touse'
    su `depvar01' [`suweight'`exp'] if `touse0', meanonly
    local p0 = r(mean)
    local N0 = r(N)
    su `depvar01' [`suweight'`exp'] if `touse1', meanonly
    local p1 = r(mean)
    local N1 = r(N)
    local d = `p0' - `p1'

//=> estimate model
    if "`pooled'"!="" {
        `qui' `cmd' `depvar' `pooled2' `idepvars' if `touse' [`weight'`exp'], `level' `options'
        qui replace `touse' = 0 if `touse0'==0 & `touse1'==0 & e(sample)==0
    }
    else {
        `qui' `cmd' `depvar' `idepvars' if `touse`reference'' [`weight'`exp'], `level' `options'
        qui replace `touse' = 0 if `touse0'==0 & `touse1'==0
    }
    tempname _b _V
    mat `_b' = e(b)
    mat `_V' = e(V)
    if `"`saveest'"'!="" {
        est sto `saveest'
        di as txt "(model estimation results stored as {stata estimates replay `saveest':`saveest'})"
    }
    qui count if `touse'
    local N = r(N)

//=> decomposition
    tempname b V
    local dp = c(dp)
    set dp period
    mata: fairlie() // returns local N_match and matrices `b' and `V'
    set dp `dp'
    mat coln `b' = `vgrpnms'
    mat coln `V' = `vgrpnms'
    mat `V' = diag(`V')

//=> post results
    PostResults `b' `V', by(`by') depvar(`depvar') esample(`touse') obs(`N') ///
        n0(`N0') n1(`N1') p0(`p0') p1(`p1') d(`d') e(`e') ///
        nmatch(`N_match') reps(`reps') cmd(`cmd') ///
        b0(`_b') v0(`_V') wtype(`e(wtype)') wexp(`e(wexp)') ///
        reference(`reference') `pooled' legend(`vgrplegend') `ro'

//=> display
    Display, `level' `legend'
end

prog def PostResults, eclass
    syntax anything, by(str) depvar(str) esample(str) obs(str) n0(str) n1(str) ///
        p0(str) p1(str) d(str) e(str) ///
        nmatch(str) reps(str) cmd(str) b0(str) v0(str) ///
        [ wtype(str) wexp(str) reference(str) pooled legend(str asis) ro ]
    eret post `anything', depname(`depvar') esample(`esample') obs(`obs')
    eret scalar N       = `obs'
    eret scalar N_0     = `n0'
    eret scalar N_1     = `n1'
    eret scalar N_match = `nmatch'
    eret scalar reps    = `reps'
    eret scalar pr_0    = `p0'
    eret scalar pr_1    = `p1'
    eret scalar diff    = `d'
    eret scalar expl    = `e'
    eret local ro       "`ro'"
    eret local legend   `"`legend'"'
    eret local reference "`reference'"
    if `"`reference'"'=="" {
        eret local reference "`pooled'"
    }
    eret local wexp     "`wexp'"
    eret local wtype    "`wtype'"
    eret local _cmd     "`cmd'"
    eret local by       "`by'"
    eret local depvar   "`depvar'"
    eret local cmd      "fairlie"
    eret mat _b = `b0'
    eret mat _V = `v0'
end

prog def Display
    syntax, [ Level(passthru) noLEgend ]

    _coef_table_header, title(Non-linear decomposition by {res}`e(by)'{txt} (G))
    if `"`e(prefix)'"'=="" {
        local col 51
        local space ""
        local fmt "%10.0g"
    }
    else {
        local col 49
        local space "   "
        local fmt "%9.0g"
    }
    di as txt _col(`col') "N of obs G=0    `space'= " as res `fmt' e(N_0)
    di as txt _col(`col') "N of obs G=0    `space'= " as res `fmt' e(N_1)
    di as txt _col(`col') "Pr(Y!=0|G=0)    `space'= " as res `fmt' e(pr_0)
    di as txt _col(`col') "Pr(Y!=0|G=1)    `space'= " as res `fmt' e(pr_1)
    di as txt _col(`col') "Difference      `space'= " as res `fmt' e(diff)
    di as txt _col(`col') "Total explained `space'= " as res `fmt' e(expl)
    ereturn display, `level'
    if "`legend'"=="" {
        Display_legend
    }
end

prog Display_legend
    if `"`e(legend)'"'=="" exit
    foreach line in `e(legend)' {
        local i 0
        local piece: piece `++i' 78 of `"`line'"'
        di as txt `"`piece'"'
        while (1) {
            local piece: piece `++i' 76 of `"`line'"'
            if `"`piece'"'=="" continue, break
            di as txt `"  `piece'"'
        }
    }
end


version 9.2
mata:
void fairlie()
{
    dot = st_local("dots")==""
    ro  = st_local("ro")!=""
    st_global("r(cmd)",st_local("cmd"))
    if (st_local("probit")=="") {
        F = &fairlie_logistic()
        f = &fairlie_logisticden()
    }
    else{
        F = &fairlie_normal()
        f = &fairlie_normalden()
    }

//get data
    vars    = tokens(st_local("idepvars"))
    nvars   = length(vars)
    vindex  = 1..nvars
    st_view(X0=., ., vars, st_local("touse0"))
    st_view(X1=., ., vars, st_local("touse1"))

//weights
    wgt = (st_local("weight")!="")
    if (wgt) {
        st_view(w0=., ., substr(st_local("exp"),3,.), st_local("touse0"))
        st_view(w1=., ., substr(st_local("exp"),3,.), st_local("touse1"))
    }
    else {
        w0 = 1
        w1 = 1
    }

//set up coefficients vector and variance matrix (b, bV)
    eb = st_matrix("e(b)")
    ebnames =  st_matrixcolstripe("e(b)")[.,2]
    eV = st_matrix("e(V)")
    _cons = (fairlie_posof("_cons",ebnames)!=0)
    b = J(nvars+_cons,1,0)
    bV = J(nvars+_cons,cols(eV),0)
    for (i=1; i<=nvars; i++) {
        tpos = fairlie_posof(vars[i],ebnames)
        if (tpos) {
            b[i] = eb[tpos]
            bV[i,.] = eV[tpos,.]
        }
    }
    tpos = fairlie_posof("_cons",ebnames)
    if (tpos) {
        b[rows(b)] = eb[tpos]
        bV[rows(bV),.] = eV[tpos,.]
    }
    eV = bV
    bV = J(rows(bV),rows(bV),0)
    for (i=1; i<=nvars; i++) {
        tpos = fairlie_posof(vars[i],ebnames)
        if (tpos) bV[.,i] = eV[.,tpos]
    }
    tpos = fairlie_posof("_cons",ebnames)
    if (tpos) bV[.,cols(bV)] = eV[.,tpos]

//compute total contribution and determine order
    if (_cons) {
        Fxlb = (*F)((X0,J(rows(X0),1,1))*b)
        Fxrb = (*F)((X1,J(rows(X1),1,1))*b)
    }
    else {
        Fxlb = (*F)(X0*b)
        Fxrb = (*F)(X1*b)
    }
    p0 = order(Fxlb,1)
    p1 = order(Fxrb,1)
    e  = mean(Fxlb,w0) - mean(Fxrb,w1) //e = colsum(Fxlb)/rows(X0) - colsum(Fxrb)/rows(X1)
    st_local("e",strofreal(e,"%18.0g"))

//set up variable groups (g records the end position of each vargroup)
    k = strtoreal(st_local("nvgrps"))
    g = J(1,k,0)
    i = 1
    g[1] = length(tokens(st_local("vgrp"+strofreal(i))))
    for (i=2;i<=k;i++) {
        g[i] = g[i-1] + length(tokens(st_local("vgrp"+strofreal(i))))
    }

//set number of cases and prepare results vectors
    if (wgt)    n = trunc((rows(X0) + rows(X1))/2)
    else        n = min((rows(X0),rows(X1)))
    c = J(1,k,0)
    v = J(1,k,0)

//loop over reps
    reps = strtoreal(st_local("reps"))
    if (dot) {
        printf("{txt}\nDecomposition replications ({res}%g{txt})\n", reps)
        display("{txt}{hline 4}{c +}{hline 3} 1 " +
            "{hline 3}{c +}{hline 3} 2 " + "{hline 3}{c +}{hline 3} 3 " +
            "{hline 3}{c +}{hline 3} 4 " + "{hline 3}{c +}{hline 3} 5 ")
    }
    for (i=1;i<=reps;i++) {
//sample data
        if (wgt) {
            s0 = &p0[fairlie_upswr(n, w0[p0])]
            s1 = &p1[fairlie_upswr(n, w1[p1])]
        }
        else {
            if (n<rows(X0)) s0 = &p0[sort(unorder(rows(p0))[|1 \ n|],1)]
            else            s0 = &p0
            if (n<rows(X1)) s1 = &p1[sort(unorder(rows(p1))[|1 \ n|],1)]
            else            s1 = &p1
        }
//prepare randomization of variable order
        if (ro) kord = unorder(k)
        vselect = J(1,nvars,0)
//compute scores
        for (j=1;j<=k;j++) {
            if (ro) jj = kord[j]
            else jj = j
            if (j==1) {
                xl = X0[*s0,.]
                if (_cons) xl = xl, J(rows(xl),1,1)
                Fxlb = (*F)(xl*b)
                fxlb = (*f)(xl*b)
            }
            else {
                swap(xl, xr)
                swap(Fxlb, Fxrb)
                swap(fxlb, fxrb)
            }
            if (j==k) {
                xr = X1[*s1,.]
            }
            else {
                jjrange = (jj==1 ? 1 : g[jj-1]+1)..g[jj]
                vselect[jjrange] = J(1,length(jjrange),1)
                vindex1 = select(vindex, vselect)
                vindex0 = select(vindex, vselect:==0)
                xr = X1[*s1,vindex1], X0[*s0,vindex0]
                if (ro) xr = xr[.,invorder((vindex1,vindex0))]
            }
            if (_cons) xr = xr, J(n,1,1)
            Fxrb = (*F)(xr*b)
            fxrb = (*f)(xr*b)
            c[jj] = c[jj] + (mean(Fxlb - Fxrb) - c[jj])/i  // mean-update formula
            dx = mean(fxlb:*xl - fxrb:*xr)
            v[jj] = v[jj] + (dx*bV*dx' - v[jj])/i  // mean-update formula
        }
        if (dot) {
            printf(".")
            if (mod(i,50)==0) printf(" %5.0f\n",i)
            displayflush()
        }
    }
    if (dot & mod(i-1,50)) display("")
//return results
    st_local("N_match",strofreal(n))
    st_matrix(st_local("b"),c)
    st_matrix(st_local("V"),v)
}

// unequal probability sampling, with replacement
real colvector fairlie_upswr(real scalar n, real colvector w)
{
        real colvector ub, res, u
        real scalar i, j

        // check args
        if (rows(w)<1) _error(3498, "no cases")

        // no sampling
        if (rows(w)==1) return(J(n,1,1))

        // draw sample
        ub = fairlie_runsum(w)
        ub = ub/ub[rows(ub)]
        u = sort(uniform(n,1),1)
        j=1
        res = J(n,1,0)
        for (i=1;i<=n;i++) {
                while (u[i]>ub[j]) j++
                res[i] = j
        }
        return(res)
}
real colvector fairlie_runsum(real colvector X)
{
    real colvector Y
    real scalar i
    Y = X
    for (i=2; i<=rows(Y); i++) Y[i,] = Y[i-1,] + Y[i,]
    return(Y)
}


real scalar fairlie_posof(transmorphic scalar s, transmorphic vector A)
{
    real scalar i

    for (i=1; i<=length(A); i++) {
        if (A[i]==s) return(i)
    }
    return(0)
}


real matrix fairlie_logistic(real matrix Z) return(1:/(1:+exp(-1*Z)))
real matrix fairlie_logisticden(real matrix Z) return(exp(Z):/(1:+exp(Z)):^2)

real matrix fairlie_normal(real matrix Z) return(normal(Z))
real matrix fairlie_normalden(real matrix Z) return(normalden(Z))

end
