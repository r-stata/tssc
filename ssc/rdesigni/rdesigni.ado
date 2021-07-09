*! version 2.1.0 14apr2019 daniel klein
program rdesigni // , rclass
    version 11.2
    
    if (replay()) {
        rdesigni_display `0'
        exit 0
    }
    
    syntax anything(id = "numlist")        ///
    [ ,                                    ///
        Alpha(numlist >0 <1)               ///
        DF(numlist integer >0 missingokay) ///
        Reps(integer 10000)                ///
        PARallel                           ///
        FORMAT(passthru)                   /// not documented
        SEED(string asis)                  /// not documented
    ]
    
    if ((`reps') & (`reps' < 2)) {
        display as err "reps() invalid -- " _continue
        error 125
    }
    
    rdesigni_check_format , `format'
    
    gettoken d  anything : anything , match(discard) quotes
    gettoken se anything : anything , match(discard) quotes
    if mi(`"`se'"') confirm number
    if (`"`anything'"' != "") {
        gettoken bad : anything
        display as err `"'`bad'' found where nothing expected"'
        exit 198
    }
    local 0 , d(`"`d'"')
    capture syntax , D(numlist)
    if (_rc) {
        display as err "{it}D{sf} invalid -- " _continue
        error _rc
    }
    local 0 , se(`"`se'"')
    capture syntax , SE(numlist >0)
    if (_rc) {
        display as err "{it}se{sf} invalid -- " _continue
        error _rc
    }
    
    if (`"`seed'"' != "") {
        if (`reps') version `= _caller()' : set seed `seed'
        else display as txt "note: option seed() ignored"
    }
    local seed `c(seed)'
    
    if mi("`alpha'") local alpha = 1-c(level)/100
    if mi("`df'")    local df .
    
    mata : rdesigni_ado()
    
    if c(noisily) rdesigni_display , format(`format')
end

program rdesigni_display
    if (`"`r(cmd)'"' != "rdesigni") error 301
    
    syntax [ , FORMAT(passthru) ]
    
    rdesigni_check_format , `format' fmtw
    local fmtw = fmtwidth("`format'")
    
    tempname table
    mata : rdesigni_make_table("`table'")
    local rows = rowsof(`table')
    local cols = colsof(`table')
    if (`cols' == 6) local ctit "alpha se D power error error"
    else          local ctit "alpha df se D power error error"
    
    local c1 = 6
    local c2 = 20
    local c3 = (31 + (`cols' == 6))
    local c4 = (43 - 4*(`cols' == 6))
    local c5 = 50
    local c6 = 61
    local c7 = 72
    
    local ts = (60 - 11*(`cols' == 6))
    local tm = (`ts' + 11)
    local ll = (78 - 11*(`cols' == 6))
    
    display as txt _n "Design analysis" _continue
    display as txt _col(`= `ts' - 6') "Replications =" _continue
    display as res _col(`= `tm' - 4') %9.0fc r(reps)
    if (!r(reps)) display as txt _col(`= `ts' -6') "(closed-form expression)"
    
    display as txt "{hline `ll'}"
    display as txt _col(`ts') "Type S" _continue
    display as txt _col(`tm') "Type M"
    forvalues c = 1/`cols' {
        local ct : word `c' of `ctit'
        display as txt _col(`c`c'') "`ct'" _continue
    }
    display
    display as txt "{hline `ll'}"
    
    forvalues r = 1/`rows' {
        forvalues c = 1/`cols' {
            local col = ((2+(`c'-1)*11) + (9 - `fmtw'))
            display `format' as res _col(`col') `table'[`r', `c'] _continue
        }
        display
    }
    
    display as txt "{hline `ll'}"
end

program rdesigni_check_format
    syntax [ , FORMAT(string asis) FMTW ]
    if mi("`format'") local format %9.0g
    else {
        capture noisily confirm numeric format `format'
        if (_rc) exit 198
    }
    if ("`fmtw'" == "fmtw") {
        local fmtw = fmtwidth("`format'")
        if (`fmtw' > 9) {
            display as txt "note: invalid format(); using default"
            local format %9.0g
            local fmtw    9
        }
        c_local fmtw : copy local fmtw
    }
    c_local format : copy local format
end

version 11.2

local RC real colvector
local RS real scalar
local RM real matrix

local rdesigni struct struct_rdesigni__ scalar

mata :

mata set matastrict on

struct struct_rdesigni__
{
    // input
    `RC' d
    `RC' se
    `RC' alpha
    `RC' df
    `RS' reps
    `RS' parallel
    
    // derived
    `RC' abs_d
    `RS' rows_d
    `RS' rows_se
    `RS' rows_alpha
    `RS' rows_df
    `RS' nrows
    
    // results
    `RC' zstat
    `RC' zcrit
    `RC' pr_lo
    `RC' pr_hi
    `RC' power
    `RC' typeS
    `RC' typeM
}

void rdesigni_ado()
{
    `rdesigni' r
    rdesigni_get_problem(r)
    if (r.parallel) rdesigni_parallel(r)
    else            rdesigni_crossall(r)
    rdesigni_get_results(r)
    rdesigni_set_results(r)
}

void rdesigni_get_problem(`rdesigni' r)
{
    r.d          = strtoreal(tokens(st_local("d")))'
    r.se         = strtoreal(tokens(st_local("se")))'
    r.alpha      = strtoreal(tokens(st_local("alpha")))'
    r.df         = strtoreal(tokens(st_local("df")))'
    r.reps       = strtoreal(st_local("reps"))
    r.parallel   = (st_local("parallel")=="parallel")
    r.rows_d     = rows(r.d)
    r.rows_se    = rows(r.se)
    r.rows_alpha = rows(r.alpha)
    r.rows_df    = rows(r.df)
}
void rdesigni_parallel(`rdesigni' r)
{
    `RS' add
    r.nrows = max((r.rows_d, r.rows_se, r.rows_alpha, r.rows_df))
    if ((add=r.nrows-r.rows_d)>0)  
        r.d = (r.d\ J(add, 1, r.d[r.rows_d]))
    if ((add=r.nrows-r.rows_se)>0) 
        r.se = (r.se\ J(add, 1, r.se[r.rows_se]))
    if ((add=r.nrows-r.rows_alpha)>0) 
        r.alpha = (r.alpha\ J(add, 1, r.alpha[r.rows_alpha]))
    if ((add=r.nrows-r.rows_df)>0) 
        r.df = (r.df\ J(add, 1, r.df[r.rows_df]))
}

void rdesigni_crossall(`rdesigni' r)
{
    r.nrows = (r.rows_alpha*r.rows_df*r.rows_se*r.rows_d)
    r.alpha = colshape(J(1, r.nrows/r.rows_alpha, r.alpha), 1)
    r.df    = J(r.rows_alpha, 1, colshape(J(1, r.rows_se*r.rows_d, r.df), 1))
    r.se    = J(r.rows_alpha*r.rows_df, 1, colshape(J(1, r.rows_d, r.se), 1))
    r.d     = J(r.nrows/r.rows_d, 1, r.d)
} 

void rdesigni_get_results(`rdesigni' r)
{
    r.abs_d = abs(r.d)
    r.zstat = r.abs_d:/r.se
    r.zcrit = invcdf_(r.alpha/2, r.df)
    r.pr_lo = 1:-cdf_(-r.zcrit:-r.zstat, r.df)
    r.pr_hi = cdf_(r.zcrit:-r.zstat, r.df)
    r.power = (r.pr_hi:+r.pr_lo)
    r.typeS = r.pr_lo:/r.power
    r.typeM = r.reps ? rdesigni_typeM_sim(r) : rdesigni_typeM_cfe(r)
}

`RC' rdesigni_typeM_sim(`rdesigni' r)
{
    `RM' drep, s
    `RS' i
    drep = J(r.nrows, r.reps, .)
    for (i=1; i<=r.nrows; ++i) drep[i,] = rdraw_(r.reps, r.df[i])
    s = abs((drep=r.abs_d:+r.se:*drep)):>(r.se:*r.zcrit)
    return( ((quadrowsum(abs(drep:*s)):/rowsum(s)):/r.abs_d) )
}

`RC' rdesigni_typeM_cfe(`rdesigni' r)
{
    `RC' pdf, cdf1, cdf2
    pdf  = pdf_(r.zstat:+r.zcrit, r.df):+pdf_(r.zstat:-r.zcrit, r.df)
    cdf1 = 1:-cdf_(r.zstat:+r.zcrit, r.df)
    cdf2 = 1:-cdf_(r.zstat:-r.zcrit, r.df)
    return( (pdf:+r.zstat:*(cdf1:+cdf2:-1)):/(r.zstat:*(1:-cdf1:+cdf2)) )
}

`RC' invcdf_(`RC' p, `RC' df)
{
    `RC' z, idx, inf
    idx=(1::rows(z=J(rows(inf=rowmissing(df)), 1, .)))
    if (any(inf))  z[select(idx, inf)]  = select(invnormal(1:-p), inf)
    if (!all(inf)) z[select(idx, !inf)] = select(invttail(df, p), !inf)
    return(z)
}

`RC' cdf_(`RC' z, `RC' df)
{
    `RC' p, idx, inf
    idx=(1::rows(p=J(rows(inf=rowmissing(df)), 1, .)))
    if (any(inf))  p[select(idx, inf)]  = select(1:-normal(z), inf)
    if (!all(inf)) p[select(idx, !inf)] = select(ttail(df, z), !inf)
    return(p)
}

`RC' pdf_(`RC' z, `RC' df)
{
    `RC' pdf, idx, inf
    idx=(1::rows(pdf=J(rows(inf=rowmissing(df)), 1, .)))
    if (any(inf))  pdf[select(idx, inf)]  = select(normalden(z), inf)
    if (!all(inf)) pdf[select(idx, !inf)] = select(tden(df, z), !inf)
    return(pdf)
}

`RM' rdraw_(`RS' reps, `RS' df)
{
    return( missing(df) ? rnormal(1, reps, 0, 1) : rt(1, reps, df) )
}

void rdesigni_set_results(`rdesigni' r)
{
    st_rclear()
    st_numscalar("r(reps)",  r.reps)
    st_numscalar("r(alpha)", r.alpha[r.nrows])
    st_numscalar("r(df)",    r.df[r.nrows])
    st_numscalar("r(se)",    r.se[r.nrows])
    st_numscalar("r(D)",     r.d[r.nrows])
    st_numscalar("r(crit)",  r.zcrit[r.nrows])
    st_numscalar("r(pr_0)",  r.pr_lo[r.nrows])
    st_numscalar("r(pr_1)",  r.pr_hi[r.nrows])
    st_numscalar("r(power)", r.power[r.nrows])
    st_numscalar("r(typeS)", r.typeS[r.nrows])
    st_numscalar("r(typeM)", r.typeM[r.nrows])
    if (r.reps) ///
    st_global("r(seed)", st_local("seed"))
    st_global("r(cmd)", "rdesigni")
    st_matrix("r(table)", 
        (r.alpha, r.df, r.se, r.d, r.zcrit, r.power, r.typeS, r.typeM))
    st_matrixcolstripe("r(table)", (J(8, 1, ""), 
        ("alpha", "df", "se", "D", "crit", "power", "typeS", "typeM")'))
}

void rdesigni_make_table(string scalar tname)
{
    `RM' rtable
    rtable = st_matrix("r(table)")[, (1..4, 6..8)]
    if (colmissing(rtable[, 2]) == rows(rtable)) 
        rtable = rtable[, (1, 3..(cols(rtable)))]
    st_matrix(tname, rtable)
}

end
exit

/* ---------------------------------------
2.1.0 14apr2019 bug fix: incorrect results for d<0
                additional r() results
                implement closed-form expression for type M error
                new option seed(); not documented
                minor changes in output table
                rewrite most of the Mata code
2.0.0 02nov2017 new name rdesigni
                option alpha() replaces level()
                option reps() replaces nsims()
                new option parallel
                new option format(); not documented
                new returned results
                most arguments may be # or (numlist)
                new output
                may replay results
1.0.0 25oct2017 sent to Statalist as retrodesigni
