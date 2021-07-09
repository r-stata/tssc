*! version 1.0.6  27aug2008  Ben Jann
*! 25oct2006: renamed from -jmp2- to -jmpierce2-

program define jmpierce2, rclass sortpreserve

    version 8.2
    syntax anything(name=estimates id="estimates") [ , ///
     Reference(str) ///
     Benchmark(str) ///
     Detail Detail2(passthru) ///
     PARametric ///
     RESiduals(namelist max=2) ///
     RANKs(namelist max=2) ///
     noNotes ///
     noPRESERVE ]
    if `"`detail2'"'!="" local detail detail
    foreach temp in residuals ranks {
        if "``temp''"!="" & "`parametric'"!="" {
            di as err "`temp'() not allowed if parametric is specified"
            exit 198
        }
    }

//prepare new variables
    foreach name in residuals ranks {
        if "``name''"!="" {
            if `: list sizeof `name''==1 {
                local `name'=substr("``name''",1,30)
                local `name'1 "``name''1"
                local `name'2 "``name''2"
            }
            else {
                local `name'1: word 1 of ``name''
                local `name'2: word 2 of ``name''
            }
            confirm new variable ``name'1'
            confirm new variable ``name'2'
        }
    }

//expand estimates names
    est_expand `"`estimates'"'
    local estimates "`r(names)'"
    local estimates: list uniq estimates
    if `:word count `estimates''<4 {
        di as err "too few estimates specified"
        exit 198
    }
    local est11: word 1 of `estimates'
    local est21: word 2 of `estimates'
    local est12: word 3 of `estimates'
    local est22: word 4 of `estimates'

//determine benchmark estimates
    if `"`benchmark'"'=="1" {
        local bm 1
    }
    else if `"`benchmark'"'=="2" {
        local bm 2
    }
    else if `"`benchmark'"'!="" {
        est_expand `"`benchmark'"'
        local benchmark "`r(names)'"
        local benchmark: list uniq benchmark
        if `:word count `benchmark''<2 {
            di as err "too few benchmark estimates specified"
            exit 198
        }
        local 1bm: word 1 of `benchmark'
        local 2bm: word 2 of `benchmark'
        if "`est11'"=="`1bm'" & "`est21'"=="`2bm'" local bm 1
        else if "`est12'"=="`1bm'" & "`est22'"=="`2bm'" local bm 2
        else {
            local bm bm
            local est1bm `1bm'
            local est2bm `2bm'
        }
        local 1bm
        local 2bm
    }

//determine reference estimates
    if `"`reference'"'=="1" | `"`reference'"'=="" {
        local ref 1
    }
    else if `"`reference'"'=="2" {
        local ref 2
    }
    else if `"`reference'"'!="" {
        est_expand `"`reference'"'
        local reference "`r(names)'"
        local refbm: word 3 of `reference'
        forv t=1/2 {
            local ref`t': word `t' of `reference'
        }
        local reference "`ref1' `ref2'"
        local reference: list uniq reference
        if `:word count `reference'' < 2 {
            di as err "too few reference estimates specified"
            exit 198
        }
        if ("`bm'"=="bm" & "`refbm'"=="") {
            di as err "too few reference estimates specified"
            exit 198
        }
        if "`est11'"=="`ref1'" & "`est12'"=="`ref2'"  ///
         & ( "`bm'"!="bm" | "`est1bm'"=="`refbm'" ) local ref 1
        else if "`est21'"=="`ref1'" & "`est22'"=="`ref2'"  ///
         & ( "`bm'"!="bm" | "`est2bm'"=="`refbm'" ) local ref 2
        else {
            local ref ref
            local estref1 `ref1'
            local estref2 `ref2'
            if "`bm'"=="bm" local estrefbm `refbm'
        }
        local ref1
        local ref2
        local refbm
    }

//get coefficients etc. from estimates
    nobreak {
        tempname hcurrent
        _est hold `hcurrent', restore nullok estsystem
        foreach gt in 11 21 12 22 1bm 2bm ref1 ref2 refbm {
            if "`est`gt''"=="" continue
            if "`est`gt''"=="." _est unhold `hcurrent'
            else qui estimates restore `est`gt''
            tempvar s`gt'
            qui gen byte `s`gt'' = e(sample)
            local depv`gt': word 1 of `e(depvar)'
            local N`gt' `e(N)'
            local wgt`gt' `e(wtype)'
            local wgt`gt': subinstr local wgt`gt' "pw" "aw"
            local wgt`gt' "`wgt`gt''`e(wexp)'"
            tempname B`gt' rmse`gt'
            mat `B`gt'' = e(b)
            sca `rmse`gt'' = e(rmse)
            if "`est`gt''"=="." _est hold `hcurrent', restore nullok estsystem
        }
        _est unhold `hcurrent'
    }

//markout unused obs
    tempname touse
    local temp "`s11' + `s21' + `s12' + `s22'"
    if "`bm'"=="bm" local temp "`temp' + `s1bm' + `s2bm'"
    qui gen `touse' = (`temp')>0 & (`temp')<.

//optional, but computation faster on most data with it (specify
// the -nopreserve- option to skip this)
    if "`residuals'"=="" & "`ranks'"=="" & "`preserve'"=="" {
        preserve
        local preserved preserved
        qui keep if `touse'
    }

//compute residuals
    local i 0
    foreach t in 1 2 bm {
        if "`t'"=="bm" & "`bm'"!="bm" continue
        local gt1: word `++i' of 11 12 1bm
        local gt2: word `i' of 21 22 2bm
        capt assert !(`s`gt1''==1&`s`gt2''==1)
        if _rc {
            di as err "group samples must not overlap"
            exit 499
        }
        if "`wgt`gt1''"!="`wgt`gt2''" {
            di as err "group models weighted differentially"
            exit 198
        }
        tempvar r`t' rr`t'
        if "`ref'`t'"=="`gt1'" {
            matrix score `r`t'' = `B`gt1'' if (`s`gt1''==1|`s`gt2''==1) & `touse', eq(#1)
            qui replace `r`t'' = `depv`gt1'' - `r`t'' if `r`t''<. & `touse'
            if "`parmetric'"=="" qui gen `rr`t'' = `r`t'' if (`s`gt1''==1) & `touse'
        }
        else if "`ref'`t'"=="`gt2'" {
            matrix score `r`t'' = `B`gt2'' if (`s`gt1''==1|`s`gt2''==1) & `touse', eq(#1)
            qui replace `r`t'' = `depv`gt2'' - `r`t'' if `r`t''<. & `touse'
            if "`parmetric'"=="" qui gen `rr`t'' = `r`t'' if (`s`gt2''==1) & `touse'
        }
        else {
            if "`parmetric'"=="" {
                matrix score `rr`t'' = `B`gt1'' if (`s`gt1''==1) & `touse', eq(#1)
                qui replace `rr`t'' = `depv`gt1'' - `rr`t'' if `rr`t''<. & `touse'
                matrix score `r`t'' = `B`gt2'' if (`s`gt2''==1) & `touse', eq(#1)
                qui replace `rr`t'' = `depv`gt2'' - `r`t'' if `r`t''<. & `touse'
                drop `r`t''
            }
            matrix score `r`t'' = `Bref`t'' if (`s`gt1''==1|`s`gt2''==1) & `touse', eq(#1)
            qui replace `r`t'' = `depvref`t'' - `r`t'' if `r`t''<. & `touse'
        }
        capt assert `r`t''<. if (`s`gt1''==1|`s`gt2''==1) & `touse'
        if _rc {
            di as err "something's wrong: sample has missing values"
            exit 499
        }
    }

//prepare coefficients vectors: first eqation only, transpose,
//drop constant, harmonize varlist
    PrepareCoefs `B`ref'1' `B`ref'2' `B`ref'`bm''

//compute vectors of mean differences
    forv t=1/2 {
        local gt1: word `t' of 11 12
        local gt2: word `t' of 21 22
        tempname dX`t'
        Meandev "`vars'" `dX`t'' `s`gt1'' "`wgt`gt1''" `s`gt2'' "`wgt`gt2''" `touse'
    }

//percentile ranks and hypothetical residuals
    if "`parametric'"=="" {
        nobreak {
            local i 0
            forv t=1/2 {
                tempvar rank`t'
                relrank `r`t'' [`wgt1`t''] if `touse', ref(`rr`t'' if `touse') g(`rank`t'')
            }
            forv t=1/2 {
                tempvar rhyp`t'
                    if "`est`ref'`t''"=="`est`ref'`bm''" {
                    qui gen `rhyp`t'' = `r`t'' if `touse'
                    continue
                }
                local temp = cond("`bm'"!="","`bm'","`=3-`t''")
                invcdf `rank`t'' [`wgt`ref'`temp''] if `touse', ref(`rr`temp'' if `touse') g(`rhyp`t'')
            }
        }
    }

//compute means of residuals and depvar
    forv t=1/2 {
        forv g=1/2 {
            foreach var in y r rhyp {
                if "`var'"=="rhyp" & "`parametric'"!="" continue
                if "`var'"=="y" local vvar `depv`g'`t''
                else local vvar ``var'`t''
                tempname `var'`g'`t'
                sum `vvar' [`wgt`g'`t''] if `s`g'`t''==1 & `touse', meanonly
                sca ``var'`g'`t'' = r(mean)
            }
        }
    }

//parametric computation of means of hypothetical residuals
    if "`parametric'"!="" {
        forv t=1/2 {
            local temp = cond("`bm'"!="","`bm'","`=3-`t''")
            tempname rmse1 rmse2
            if "`ref'"=="ref" {
                sca `rmse1' = sqrt( (`rmse1`t''^2*`N1`t'' + `rmse2`t''^2*`N2`t'' ) ///
                                     /(`N1`t''+`N2`t'') )
                sca `rmse2' = sqrt( (`rmse1`temp''^2*`N1`temp'' + `rmse2`temp''^2*`N2`temp'' ) ///
                                     /(`N1`temp''+`N2`temp'') )
            }
            else {
                sca `rmse1' = `rmse`ref'`t''
                sca `rmse2' = `rmse`ref'`temp''
            }
            forv g=1/2 {
                tempname rhyp`g'`t'
                sca `rhyp`g'`t'' = `r`g'`t'' / `rmse1' * `rmse2'
            }
        }
    }

//decomposition of differentials
    local B1 `B`ref'1'
    local B2 `B`ref'2'
    tempname D
    forv t=1/2 {
        mat `D' = nullmat(`D') \ (`y1`t''-`y2`t'') , (`dX`t''*`B`t'') , (`r1`t'' - `r2`t'')
    }
    mat rown `D' = s1 s2
    mat coln `D' = D E U

//decomposition of change in differentials
    tempname DD
    mat `DD' = (`y12'-`y22') - (`y11'-`y21')
    mat `DD' = `DD', `dX2' * `B2' - `dX1' * `B1'
    mat `DD' = `DD', (`r12' - `r22') - (`r11' - `r21')
    mat rown `DD' = Total
    mat coln `DD' = D E U

//decomposition of change in predicted gap
    tempname E
    forv t=1/2 {
        if "`bm'"!="" local B`t'r `B`ref'`bm''
        else local B`t'r `B`ref'`t''
    }
    mat `E' = `dX2' * `B2' - `dX1' * `B1'
    mat `E' = `E', (`dX2'-`dX1') * `B1r'
    mat `E' = `E', `dX2' * (`B2'-`B2r') + `dX1' * (`B2r'-`B1')
    mat `E' = `E', (`dX2'-`dX1') * (`B2r'-`B1r')
    mat rown `E' = Total
    mat coln `E' = E Q P QP

//decomposition of change in predicted gap: contribution
//of individual variables/groups of variables
    if "`detail'"!="" {
        tempname Ev
        mat `Ev' = diag(`B2') * `dX2'' - diag(`B1') * `dX1''
        mat `Ev' = `Ev', diag(`B1r') * (`dX2'-`dX1')'
        mat `Ev' = `Ev', diag(`B2'-`B2r') * `dX2'' + diag(`B2r'-`B1') * `dX1''
        mat `Ev' = `Ev', diag(`B2r'-`B1r') * (`dX2'-`dX1')'
        mat rown `Ev' = `vars'
        CollapseMat `Ev' , `detail2'
        mat coln `Ev' = E Q P QP
    }

//decomposition of residual gap
    tempname U
    forv t=1/2 {
        if "`bm'"!="" {
            local r1`t'r `rhyp1`t''
            local r2`t'r `rhyp2`t''
        }
        else {
            local r1`t'r `r1`t''
            local r2`t'r `r2`t''
        }
    }
    mat `U' = (`r12' - `r22') - (`r11' - `r21')
    mat `U' = `U', (`rhyp12' - `rhyp22') - (`r11r' - `r21r')
    mat `U' = `U', (`r12' - `r22') - (`r12r' - `r22r')  ///
                      + (`rhyp11' - `rhyp21') - (`r11' - `r21')
    mat `U' = `U', (`r12r' - `r22r') - (`rhyp12' - `rhyp22') ///
                      - (`rhyp11' - `rhyp21') + (`r11r' - `r21r')
    mat rown `U' = Total
    mat coln `U' = U Q P QP

//display results
    di _n as txt "Decomposition of individual differentials:"
    di as txt "{hline 13}{c TT}{hline 33}
    di as txt _col(14) "{c |}  " %9s "raw dif-" "  " %9s "quantity" "  " %9s "residual"
    di as txt _col(14) "{c |}  " %9s "ferential" "  " %9s "effect" "  " %9s "gap"
    di as txt "{hline 13}{c +}{hline 33}
    forv t=1/2 {
        di as txt %12s abbrev("Sample `t'",12) " {c |}  " as res %9.0g `D'[`t',1] ///
         "  " %9.0g `D'[`t',2] "  " %9.0g `D'[`t',3]
    }
    di as txt "{hline 13}{c BT}{hline 33}

    di _n as txt "Difference in (components of) differentials:"
    di as txt "{hline 13}{c TT}{hline 33}
    di as txt _col(14) "{c |}  " %9s "D" "  " %9s "E" "  " %9s "U"
    di as txt "{hline 13}{c +}{hline 33}
    di as txt %12s "Total" " {c |}  " as res %9.0g `DD'[1,1] ///
     "  " %9.0g `DD'[1,2] "  " %9.0g `DD'[1,3]
    di as txt "{hline 13}{c BT}{hline 33}

    if "`bm'"=="" local line 44
    else local line 33
    di _n as txt "Decomposition of difference in predicted gap:"
    di as txt "{hline 13}{c TT}{hline `line'}
    di as txt _col(14) "{c |}  " %9s "E" "  " %9s "Q" ///
     "  " %9s "P" _c
    if "`bm'"=="" di "  " %9s "QP"
    else di
    di as txt "{hline 13}{c +}{hline `line'}
    di as txt %12s "Total" " {c |}  " as res %9.0g `E'[1,1] ///
     "  " %9.0g `E'[1,2] "  " %9.0g `E'[1,3] _c
    if "`bm'"=="" di "  " %9.0g `E'[1,4]
    else di
    if "`detail'"!="" {
        di as txt "{hline 13}{c +}{hline `line'}
        local r 0
        foreach var of local vars {
            local ++r
            di as txt %12s abbrev("`var'",12) " {c |}  " as res ///
             %9.0g `Ev'[`r',1] "  " %9.0g `Ev'[`r',2] "  " %9.0g `Ev'[`r',3] _c
            if "`bm'"=="" di "  " %9.0g `Ev'[`r',4]
            else di
        }
    }
    di as txt "{hline 13}{c BT}{hline `line'}

    di _n as txt "Decomposition of diffence in residual gap:"
    di as txt "{hline 13}{c TT}{hline `line'}
    di as txt _col(14) "{c |}  " %9s "U" "  " %9s "Q" "  " %9s "P" _c
    if "`bm'"=="" di "  " %9s "QP"
    else di
    di as txt "{hline 13}{c +}{hline `line'}
    di as txt %12s "Total" " {c |}  " as res %9.0g `U'[1,1] ///
     "  " %9.0g `U'[1,2] "  " %9.0g `U'[1,3] _c
    if "`bm'"=="" di "  " %9.0g `U'[1,4]
    else di
    di as txt "{hline 13}{c BT}{hline `line'}

    if "`notes'"=="" {
        di _n as txt "D  = difference in differential
        di as txt "E  = difference in predicted gap"
        di as txt "U  = difference in residual gap"
        di as txt "Q  = quantity effect"
        di as txt "P  = price effect"
        if "`bm'"=="" di as txt "QP = interaction Q x P"
    }

//returns
    if "`bm'"=="bm" ret mat b3 = `B`ref'bm'
    forv t=2(-1)1 {
        ret mat dX`t' = `dX`t''
        ret mat b`t' = `B`t''
    }
    ret mat U = `U'
    if "`detail'"!="" {
        mat `E' = `Ev' \ `E'
    }
    ret mat E = `E'
    ret mat DD = `DD'
    ret mat D = `D'
    if "`parametric'"=="" {
        if "`residuals'"!="" {
            forv t=1/2 {
                rename `rhyp`t'' `residuals`t''
                lab var `residuals`t'' "Hypothetical residuals for sample `t'"
            }
        }
        if "`ranks'"!="" {
            forv t=1/2 {
                rename `rank`t'' `ranks`t''
                lab var `ranks`t'' "Percentile rank in reference residual distribution for sample `t'"
            }
        }
    }
end

program define PrepareCoefs
    local 0: list uniq 0
    foreach B of local 0 {
        local eq: coleq `B'
        local eq: word 1 of `eq'
        mat `B' = `B'[1,"`eq':"]
        local vars "`vars'`: colnames `B'' "
    }
    local vars: list uniq vars
    local cons _cons
    local vars: list vars - cons
    tempname temp
    foreach B of local 0 {
        mat rename `B' `temp'
        foreach var of local vars {
            local c = colnumb(`temp',"`var'")
            if `c'<. mat `B' = nullmat(`B') \ `temp'[1,`c']
            else mat `B' = nullmat(`B') \ 0
        }
        mat rown `B' = `vars'
        mat drop `temp'
    }
    c_local vars `vars'
end

program define Meandev, rclass
    args varlist matrix s1 w1 s2 w2 touse
    tempname temp1 temp2
    qui mat accum `temp1' = `varlist' [`w1'] if `s1' & `touse', nocons means(`matrix')
    local nobs `r(N)'
    if substr("`w1'",1,2)=="fw" sum `touse' [`w1'] if `s1', mean
    else qui count if `s1' & `touse'
    if `nobs'!=`r(N)' {
        di as err "something's wrong: sample has missing values"
        exit 499
    }
    qui mat accum `temp1' = `varlist' [`w2'] if `s2' & `touse', nocons means(`temp2')
    local nobs `r(N)'
    if substr("`w2'",1,2)=="fw" sum `touse' [`w2'] if `s2', mean
    else qui count if `s2' & `touse'
    if `nobs'!=`r(N)' {
        di as err "something's wrong: sample has missing values"
        exit 499
    }
    mat `matrix' = `matrix' - `temp2'
    mat rown `matrix' = r1
end

program define CollapseMat
    syntax name [ , Detail2(str) ]
    if "`detail2'"=="" exit
    tempname temp1 temp2
    local vars: rownames `namelist'
    local ncol = colsof(`namelist')
    mat rename `namelist' `temp1'
    tokenize "`detail2'", parse(",")
    while "`1'"!="" {
        gettoken gname 1: 1, parse("=")
        mat `temp2' = J(1,`ncol',0)
        gettoken trash 1: 1, parse("=")
        unab 1: `1'
        local 1: list vars & 1
        local vars: list vars - 1
        if "`1'"!="" {
            foreach var of local 1 {
                mat `temp2' = `temp2' + `temp1'[rownumb(`temp1',"`var'"),1...]
            }
            mat rown `temp2' = `gname'
            mat `namelist' = nullmat(`namelist') \ `temp2'
            mat drop `temp2'
        }
        mac shift
        mac shift
    }
    foreach var of local vars {
        mat `namelist' = nullmat(`namelist') \ `temp1'[rownumb(`temp1',"`var'"),1...]
    }
    mat drop `temp1'
    c_local vars: rownames `namelist'
end

* version 1.0.2, Ben Jann, 13jun2005
program define invcdf, byable(onecall) sort
    version 8.2
    syntax varname(numeric) [if] [in] [fw aw] , Reference(str) Generate(name) [ cdf(varname) ]
    tempvar touse             //changed
    mark `touse' `if' `in'    //changed
    markout `touse' `varlist' //changed
    confirm new var `generate'
    capt assert inrange(`varlist',0,1) if `touse'
    if _rc {
        di as error "`varlist' not in [0,1]"
        exit 459
    }
    gettoken refvar refif: reference
    if _by() local by "by `_byvars':"
    if "`cdf'"=="" {
        tempvar cdf
        `by' cumul `refvar' `refif' [`weight'`exp'] , generate(`cdf') equal
    }
    else {
        capt assert inrange(`cdf',0,1) | ( `cdf'>=. & `refvar'>=. ) `refif'
        if _rc {
            di as error "`cdf' not in [0,1] or is incomplete"
            exit 459
        }
    }
    quietly {
        nobreak {
            tempvar id x u
            gen `: type `refvar'' `generate' = `refvar' `refif'
            expand 2 if `generate'<. & `touse'
            sort `_sortindex'
            by `_sortindex': gen byte `id' = _n
            replace `touse' = 0 if `id'==2
            replace `generate' = . if `touse'
            gen `: type `refvar'' `u' = `refvar' if `generate'<.
            gen `: type `varlist'' `x' = 1 - `varlist' if `touse'
            replace `x' = 1 - `cdf' if `generate'<. & !`touse'
            replace `generate' = -`generate' if `generate'<.
            sort `_byvars' `x' `id' `generate'
            `by' replace `u' = `u'[_n-1] if `touse'
            replace `x' = 1 - `x'
            replace `generate' = -`generate' if `generate'<.
            sort `_byvars' `x' `touse' `generate'
            `by' replace `generate' = `generate'[_n-1] if `x'==`x'[_n-1] & `touse'
            `by' replace `generate' = cond( `generate'>=. , `u' , ///
                 cond( `u'>=. , `generate', (`generate'+`u')/2 ) ) if `touse'
            replace `generate' = . if !`touse'
            drop if `id'==2
        }
    }
end

* version 1.0.3, Ben Jann, 26jan2005
program define relrank, byable(onecall) sort
    version 8.2
    syntax varname(numeric) [if] [in] [fw aw] , Reference(str) Generate(name) [ cdf(varname) ]
    tempvar touse             //changed
    mark `touse' `if' `in'    //changed
    markout `touse' `varlist' //changed
    confirm new var `generate'
    gettoken refvar refif: reference
    if _by() local by "by `_byvars':"
    if "`cdf'"=="" {
        `by' cumul `refvar' `refif' [`weight'`exp'] , generate(`generate') equal
    }
    else {
        capt assert inrange(`cdf',0,1) | ( `cdf'>=. & `refvar'>=. ) `refif'
        if _rc {
            di as error "`cdf' not in [0,1] or has missing values"
            exit 459
        }
        qui gen `: type `cdf'' `generate' = `cdf' `refif'
        qui replace `generate' = . if `refvar'>=.
    }
    quietly {
        nobreak {
            expand 2 if `generate'<. & `touse'
            tempvar id x
            sort `_sortindex'
            by `_sortindex': gen byte `id' = _n
            replace `touse' = 0 if `id'==2
            replace `generate' = . if `touse'
            gen `: type `varlist'' `x' = `varlist' if `touse'
            replace `x' = `refvar' if `generate'<. & !`touse'
            sort `_byvars' `x' `touse'
            `by' replace `generate' = 0 if _n==1 & `touse'
            `by' replace `generate' = `generate'[_n-1] if _n>1 & `touse'
            replace `generate' = . if !`touse'
            drop if `id'==2
        }
    }
end
