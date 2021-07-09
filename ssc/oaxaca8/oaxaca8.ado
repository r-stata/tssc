*!version 2.15  Ben Jann  22apr2008

program define oaxaca8, rclass sortpreserve
    version 8.2
    syntax namelist(name=elist id="estimates list" min=2 max=2) [,  ///
     Weight(str) ///
     Pooled /// discontinued option
     Reference(namelist) referencenames(str) ///
     Adjust(passthru) ///
     Detail Detail2(passthru) ///
     FIXed FIXed2(string) ///
     noSE ///
     eform ///
     Level(passthru) ///
     TF ///
     noPRed /// has no effect (discontiued option)
     asis ///
     ESave ]
    if "`pooled'"!="" {
        di as err "option pooled not supported anymore, use weight(omega)"
        exit 198
    }
    local se = "`se'"==""
    if `"`detail2'"'!="" local detail detail
    if `"`weight'"'=="" & `"`reference'"'=="" local tf tf
    local reference: list uniq reference

//parse weight()
    local omegao 0
    foreach w of local weight {
        if substr("omega",1,length("`w'"))=="`w'" {
            local omegao 1
            local w omega
        }
        else {
            capt confirm num `w'
            if _rc {
                di as err "`w' not allowed in weight()"
                exit 198
            }
        }
        local weight2 "`weight2' `w'"
    }
    local weight: list uniq weight2

//parse fixed()
    if `"`fixed2'"'!="" {
        local fixed
        capt unab temp: `fixed2'
        if _rc==0 {
            local fixed2 "`temp'"
        }
    }

//referencenames
    local i 0
    foreach ref of local reference {
        local refname: word `++i' of `referencenames'
        if `"`refname'"'=="" {
            local referencenames `"`referencenames' `ref'"'
        }
    }

//get estimates
//- preserve last estimates
    nobreak {
        tempname hcurrent
        _est hold `hcurrent', restore nullok estsystem
//- restore group estimates, calculate means
        tempname esample
        qui gen byte `esample' = 0
        local g 0
            foreach est in `elist' `reference' {
            local ++g
            qui estimates restore `est'
//- get coeffs, varnames and variances (first equation only)
            tempname B`g'
            mat `B`g'' = e(b)'
            local firsteq: roweq(`B`g'')
            local firsteq: word 1 of `firsteq'
            mat `B`g'' = `B`g''["`firsteq':",1]
            mat roweq `B`g'' = _
            if `se' {
                tempname VB`g'
                mat `VB`g'' = e(V)
                mat `VB`g'' = `VB`g''["`firsteq':","`firsteq':"]
                mat coleq `VB`g'' = _
                mat roweq `VB`g'' = _
            }
            local depvar`g': word 1 of `e(depvar)'
//- get means of vars and covariance matrix of means of vars
            if `g'<3 {
                local N`g' = e(N)
                capt assert `esample'==0 if e(sample)
                if _rc {
                    di as error "warning: overlapping samples"
                }
                qui replace `esample' = 1 if e(sample)
                tempname X`g' VX`g'
                if `omegao' tempname XX`g'
                GetMeans `se' "`fixed'" "`fixed2'" `B`g'' `X`g'' `VX`g'' `XX`g''
                if !`se' {
                    mat drop `VX1' `VX2'
                    local VX1
                    local VX2
                }
            }
            else {
                local Bp "`Bp'`B`g'' "
                local VBp "`VBp'`VB`g'' "
            }
            if `g'==2 {
                local g = `g' + `:word count `weight''
            }
        }
    }

//harmonize matrices
    HarmonizeMatrices `B1' "`VB1'" `X1' "`VX1'" `B2' "`VB2'" `X2' "`VX2'" ///
     "`Bp'" "`VBp'" "`XX1'" "`XX2'", `adjust'

//Mean predictions and mean difference
    tempname pred1 pred2 diff
    matrix `pred1' = `X1'' * `B1'
    matrix `pred2' = `X2'' * `B2'
    if `se' {
        tempname Vpred1 Vpred2 Vdiff
        matrix `Vpred1' = `X1''*`VB1'*`X1' + `B1''*`VX1'*`B1' + trace(`VB1'*`VX1')
        matrix `Vpred2' = `X2''*`VB2'*`X2' + `B2''*`VX2'*`B2' + trace(`VB2'*`VX2')
        matrix `Vdiff' = `Vpred1' + `Vpred2'
    }
    if "`asis'"=="" & `pred1'[1,1] < `pred2'[1,1] {
        local 1 2
        local 2 1
    }
    else {
        local 1 1
        local 2 2
    }
    matrix `diff' = `pred`1'' - `pred`2''

//prepare tempnames and matrices for decomposition
    tempname D
    if `se' tempname VD
    local i 2
    tempname W
    local Bp
    local VBp
    foreach w in `weight' {
        local ++i
        if "`w'"=="omega" {
            mat `W' = inv( `XX`1'' + `XX`2'' ) * `XX`1''
        }
        else mat `W' = I(`p')*`w'
        tempname B`i' X`i'
        mat `B`i'' = `W'*`B`1'' + (I(`p')-`W')*`B`2''
        mat `X`i'' = (I(`p')-`W')'*`X`1'' + `W''*`X`2''
        local Bp "`Bp'`B`i'' "
        local Xp "`Xp'`X`i'' "
        if `se' {
            tempname VB`i' VX`i'
            mat `VB`i'' = `W'*`VB`1''*`W'' + (I(`p')-`W')*`VB`2''*(I(`p')-`W')'
            mat `VX`i'' = (I(`p')-`W')'*`VX`1''*(I(`p')-`W') + `W''*`VX`2''*`W'
            local VBp "`VBp'`VB`i'' "
            local VXp "`VXp'`VX`i'' "
        }
    }
    foreach w of local reference {
        local ++i
        mat `W' = diag(`B`i''-`B`2'') * inv(diag(`B`1''-`B`2''))
        tempname X`i'
        mat `X`i'' = (I(`p')-`W')'*`X`1'' + `W''*`X`2''
        local Bp "`Bp'`B`i'' "
        local Xp "`Xp'`X`i'' "
        if `se' {
            tempname VX`i'
            mat `VX`i'' = J(`p',`p',.) //(no standard errors for U in this case)
            //mat `VX`i'' = (I(`p')-`W')'*`VX`1''*(I(`p')-`W') + `W''*`VX`2''*`W'
            local VBp "`VBp'`VB`i'' "
            local VXp "`VXp'`VX`i'' "
        }
    }
    foreach M in `Bp' `Xp' `VBp' `VXp' {
        mat rown `M' = `vars'
    }
    foreach M in `VBp' `VXp' {
        mat coln `M' = `vars'
    }

//aggregate decomposition
    Decompose "`tf'" `B`1'' "`VB`1''" `X`1'' "`VX`1''" `B`2'' "`VB`2''" `X`2'' "`VX`2''" ///
     "`Bp'" "`VBp'" "`Xp'" "`VXp'" `D' "`VD'"

//detailed decomposition
    if "`detail'"!="" {
        GroupWise "`tf'" `B`1'' "`VB`1''" `X`1'' "`VX`1''" `B`2'' "`VB`2''" `X`2'' "`VX`2''" ///
         "`Bp'" "`VBp'" "`Xp'" "`VXp'" `D' "`VD'" , ///
         vars(`vars') `detail2'
    }
    else local vars

//row- and colnames for D and VD
    if "`tf'"!="" local coln three-fold:endowments ///
     three-fold:coefficients three-fold:interaction
    else local coln
    if `omegao' local weight: subinstr local weight "omega" "W=omega"
    local i 0
    foreach B in `Bp' {
        local ++i
        local w: word `i' of `weight' `referencenames'
        capt confirm number `w'
        if _rc==0 {
        local w: di %9.0g `w'
        local w: list retok w
        local w: subinstr local w "." ",", all
        local w W=`w'
        }
        local QU "`QU'`w':explained `w':unexplained "
    }
    local coln `coln' `QU'
    mat rown `D' = Total `vars'
    mat coln `D' = `coln'
    if `se' {
        mat rown `VD' = Total `vars'
        mat coln `VD' = `coln'
    }

//display
    if "`asis'"=="" {
         di as txt "(high estimates: " as res "`:word `1' of `elist''" ///
            as txt "; low estimates: " as res "`:word `2' of `elist''" as txt ")"
    }
//total difference
    di
    di as txt _col(50) "Mean prediction 1 = " as res %9.0g `pred`1''[1,1]
    di as txt _col(50) "Mean prediction 2 = " as res %9.0g `pred`2''[1,1]
    tempname B V
    mat `B' = `diff'
    if `se' mat `V' = `Vdiff'
    else mat `V' = 0
    mat coln `B' = "difference"
    mat coln `V' = "difference"
    mat rown `V' = "difference"
    Display `B' `V', `eform' `level'
//decomposition results
    capt mat `B' = `D'
    capt confirm matrix `B'
    if !_rc {
        di _n as txt "Linear decomposition" _c
        if colsof(`D')>3 di "s"
        else di
        if "`detail'"=="" {
            if `se' {
                capt mat `V' = `VD'
                mat `V' = diag(`V')
            }
            else mat `V' = diag(`B')*0
            Display `B' `V', `eform' `level' dep(`:rown `B'')
        }
        else {
            local coleq: coleq `B'
            local coleq: list uniq coleq
            tempname m
            foreach eq of local coleq {
                capt mat drop `B'
                capt mat drop `V'
                mat `m' = `D'[1...,"`eq':"]
                local coln: coln `m'
                foreach col of local coln {
                    mat `m' = `D'[1...,"`eq':`col'"]'
                    if inlist("`col'","endowments","interaction","explained") & `_cons' {
                        mat `m' = `m'[1,1..colsof(`m')-1]
                    }
                    mat `m' = `m'[1...,2...], `m'[1...,1]
                    mat coleq `m' = `col'
                    mat `B' = nullmat(`B'), `m'
                    if `se' {
                        mat `m' = `VD'[1...,"`eq':`col'"]'
                        if inlist("`col'","endowments","interaction","explained") & `_cons' {
                            mat `m' = `m'[1,1..colsof(`m')-1]
                        }
                        mat `m' = `m'[1...,2...], `m'[1...,1]
                        mat coleq `m' = `col'
                        mat `V' = nullmat(`V'), `m'
                    }
                }
                if "`eform'"!="" {
                    local names: coln `B'
                    local names: subinstr local names "_cons" "_const", all
                    mat coln `B' = `names'
                }
                if `se' {
                    if "`eform'"!="" mat coln `V' = `names'
                    mat `V' = diag(`V')
                }
                else mat `V' = diag(`B')*0
                Display `B' `V', `eform' `level' dep(`eq')
            }
        }
    }

//reorder results
    if "`detail'"!="" {
        if `se' {
            mat `VD' = `VD'[2...,1...] \ `VD'[1,1...]
        }
        mat `D' = `D'[2...,1...] \ `D'[1,1...]
    }

//e-returns
    if "`esave'"!="" {
        nobreak {
            _estimates unhold `hcurrent', not
            PostInE `N1' `N2' `esample' `pred`1'' `pred`2'' `diff' ///
             "`Vpred`1''" "`Vpred`2''" "`Vdiff'" `D' "`VD'" `_cons'
        }
    }

//r-returns
    if `se' {
        return mat VX2 `VX`2''
        return mat VX1 `VX`1''
        return mat VB2 `VB`2''
        return mat VB1 `VB`1''
        return mat V `VD'
        return scalar se_diff  = sqrt(`Vdiff'[1,1])
        return scalar se_pred2 = sqrt(`Vpred`2''[1,1])
        return scalar se_pred1 = sqrt(`Vpred`1''[1,1])
    }
    mat `X`2'' = `X`2'''
    return mat X2 `X`2''
    mat `X`1'' = `X`1'''
    return mat X1 `X`1''
    mat `B`2'' = `B`2'''
    return mat B2 `B`2''
    mat `B`1'' = `B`1'''
    return mat B1 `B`1''
    return mat D `D'
    return scalar diff     = `diff'[1,1]
    return scalar pred2    = `pred`2''[1,1]
    return scalar pred1    = `pred`1''[1,1]

end


prog def GetMeans
    args se fix fixvars B X VX XX

//determine relevant sample
    local select "`: word 1 of `e(depvar)''<."
    if "`e(cmd)'"=="heckman" | "`e(cmd)'"=="heckprob" {
        if "`:word 2 of `e(depvar)''"!="" {
            local select "`select' & `:word 2 of `e(depvar)''!=0"
        }
    }
    if "`e(subpop)'"!="" local select "`select' & `e(subpop)'"

//get varnames
    local vars: rownames `B'
    local vars: subinstr local vars "_cons" "", count(local _cons)

//if -pooled-: compute X'X
    if "`XX'"!="" {
        qui mat accum `XX' = `vars' [`e(wtype)'`e(wexp)'] if e(sample) & `select'
    }

//compute means and crossproduct of deviations
    qui mat accum `VX' = `vars' [`e(wtype)'`e(wexp)'] if e(sample) & `select', dev means(`X') nocons
    mat `X' = `X''
    if `_cons' {
        mat `X' = `X' \ 1
        mat rown `X' = `vars' _cons
    }

//if fixed regressors or no SE's requested: set VX to zero
    if "`fix'"!="" | !`se' {
        mat `VX' = `VX' * 0
    }

//else: determine (co)variances of regressors means
    else {
//standard formula
        mat `VX' = `VX' / (r(N)-1) / r(N)
//robust method
        qui svyset
        local svyset = substr(`"`r(settings)'"',1,7)!=", clear"
        if `svyset' | ///
         ( "`e(vcetype)'"=="Robust" & ///
         ( inlist("`e(wtype)'","pweight","iweight") | "`e(clustvar)'"!="" ) ) {
            if !`svyset' qui svyset [`e(wtype)'`e(wexp)'], psu(`e(clustvar)')
            di as txt "(note: using svymean to compute vce of means of regressors)"
            qui svymean `vars' if e(sample), subpop(if `select')
            mat `VX' = e(V)
            if !`svyset' qui svyset, clear(all)
        }
//set variances of fixed regressors to 0
        if "`fixvars'"!="" {
            forv i=1/`=rowsof(`VX')' {
                foreach var in `:list fixvars & vars' {
                    mat `VX'[`i',colnumb(`VX',"`var'")] = 0
                    mat `VX'[rownumb(`VX',"`var'"),`i'] = 0
                }
            }
        }
    }

//add constant to VX
    if `_cons' {
        mat `VX' = `VX' , J(rowsof(`VX'),1,0)
        mat `VX' = `VX' \ J(1,colsof(`VX'),0)
        mat rown `VX' = `vars' _cons
        mat coln `VX' = `vars' _cons
    }
end


program define HarmonizeMatrices
    syntax anything [, adjust(string) ]
    args B1 VB1 X1 VX1 B2 VB2 X2 VX2 Bp VBp XX1 XX2

//determine varlist
    local vars: rownames `B1'
    local vars "`vars' `:rownames `B2''"
    local vars: list uniq vars
    local _cons: list posof "_cons" in vars
    if `_cons' {
        local vars: subinstr local vars "_cons" "", word
        local vars `"`vars' _cons"'
        local vars: list retok vars
    }
    if `"`adjust'"'!="" {
        capt unab temp: `adjust'
        if _rc==0 local adjust "`temp'"
        local vars: list vars - adjust
    }
    local p: word count `vars'  //????

//reorder matrices
    tempname m
    foreach M in `B1' `X1' `B2' `X2' `Bp' ///
     `VB1' `VX1' `VB2' `VX2' `VBp' `XX1' `XX2' {
        foreach var of local vars {
            local num = rownumb(`M',"`var'")
            if `num'<. mat `m' = nullmat(`m') \ `M'[`num',1...]
            else mat `m' = nullmat(`m') \ J(1,colsof(`M'),0)
        }
        mat colnames `m' = `: colnames `M'' // just to be sure
        mat `M' = `m'
        mat drop `m'
    }
    foreach M in `VB1' `VX1' `VB2' `VX2' `VBp' `XX1' `XX2' {
        foreach var of local vars {
            local num = colnumb(`M',"`var'")
            if `num'<. mat `m' = nullmat(`m') , `M'[1...,`num']
            else mat `m' = nullmat(`m') , J(rowsof(`M'),1,0)
        }
        mat `M' = `m'
        mat drop `m'
    }

//set row and column names
    foreach M in `B1' `X1' `B2' `X2' `Bp' {
        mat rown `M' = `vars'
    }
    foreach M in `VB1' `VX1' `VB2' `VX2' `VBp' `XX1' `XX2' {
        mat rown `M' = `vars'
        mat coln `M' = `vars'
    }
    c_local vars `vars'
    c_local p `p'
    c_local _cons `_cons'
end


program Decompose
    args tf B1 VB1 X1 VX1 B2 VB2 X2 VX2 Bp VBp Xp VXp D VD

//three-fold decomposition into E, C, and CE
    if "`tf'"!="" {
        mat `D' = (`X1'-`X2')' * `B2' , `X2'' * (`B1'-`B2') , ///
                  (`X1'-`X2')' * (`B1'-`B2')
//variances of three-fold decomposition
        if "`VD'"!="" {
            mat `VD' = ///
              (`X1'-`X2')' * `VB2' * (`X1'-`X2') + `B2'' * (`VX1'+`VX2') * `B2' ///
                + trace( (`VX1'+`VX2') * `VB2' ) , ///
              `X2'' * (`VB1'+`VB2') * `X2' + (`B1'-`B2')' * `VX2' * (`B1'-`B2') ///
                + trace( `VX2' * (`VB1'+`VB2') ) , ///
              (`X1'-`X2')' * (`VB1'+`VB2') * (`X1'-`X2') ///
                + (`B1'-`B2')' * (`VX1'+`VX2') * (`B1'-`B2') ///
                + trace( (`VX1'+`VX2') * (`VB1'+`VB2') )
        }
    }

//decomposition into Q and U
    local i 0
    foreach B of local Bp {
        local ++i
        local X: word `i' of `Xp'
        mat `D' = nullmat(`D') , (`X1'-`X2')' * `B' , `X'' * (`B1'-`B2')
        if "`VD'"!="" {
            local VB: word `i' of `VBp'
            local VX: word `i' of `VXp'
            mat `VD' = nullmat(`VD') , ///
             (`X1'-`X2')' * `VB' * (`X1'-`X2')   ///
               + `B'' * (`VX1'+`VX2') * `B'      ///
               + trace( (`VX1'+`VX2') * `VB' ) , ///
             `X'' * (`VB1'+`VB2') * `X' ///
               + (`B1'-`B2')' * `VX' * (`B1'-`B2') ///
               + trace( `VX' * (`VB1'+`VB2') )
            if `VD'[1,colsof(`VD')]>=. mat `VD'[1,colsof(`VD')] = 0
        }
    }
end


program define GroupWise
    syntax anything(name=0), vars(str) [ detail2(str) ]
    args tf B1 VB1 X1 VX1 B2 VB2 X2 VX2 Bp VBp Xp VXp D VD

//determine groups
    local rest `vars'
    if `"`detail2'"'!="" {
        tokenize `"`detail2'"', parse(",")
        while `"`1'"'!="" {
            gettoken gname 1: 1, parse("=")
            local gname: list retok gname
            local tgnames `"`tgnames'`"`gname'"' "'
            gettoken trash 1: 1, parse("=")
            if `:list posof "_cons" in 1' {
                local cons _cons
                local 1: list 1 - cons
            }
            else local cons
            capt unab trash: `1'
            if _rc local 1: list 1 | cons
            else local 1: list trash | cons
            local 1: list vars & 1
            if !`:list 1 in rest' {
                di as error "groups in detail() must be mutually exclusive"
                exit 198
            }
            local rest: list rest - 1
            local tgvars `"`tgvars'"`1'" "'
            mac shift
            mac shift
        }
    }

//insert remaining variables
    local var: word 1 of `vars'
    while "`var'"!="" {
        if `:list var in rest' {
            local gnames `"`gnames'`var' "'
            local gvars `"`gvars'`var' "'
            local vars: list vars - var
        }
        else {
            local i 0
            foreach gvar of local tgvars {
                local ++i
                if `:list var in gvar' {
                    local gname: word `i' of `tgnames'
                    local gnames `"`gnames'"`gname'" "'
                    local gvars `"`gvars'"`gvar'" "'
                    local vars: list vars - gvar
                    local tgnames: list tgnames - gname
                    local gvar `""`gvar'""'
                    local tgvars: list tgvars - gvar
                    continue, break
                }
            }
        }
        local var: word 1 of `vars'
    }

//prepare tempnames
    tempname tD
    if "`VD'"!="" tempname tVD
    foreach M in B1 VB1 X1 VX1 B2 VB2 X2 VX2 {
        if "``M''"!="" tempname t`M'
    }
    local i 3
    foreach j in `Bp' {
        local ++i
        foreach M in B X {
            tempname t`M'`i'
            local t`M'p "`t`M'p'`t`M'`i'' "
            if "`VD'"!="" {
                tempname tV`M'`i'
                local tV`M'p "`tV`M'p'`tV`M'`i'' "
            }
        }
    }
    tempname m

//groupwise decomposition
    local k 0
    foreach vars of local gvars {
        local gname: word `++k' of `gnames'
        local j 0
//select rows
        foreach M in `B1' `VB1' `X1' `VX1' `B2' `VB2' `X2' `VX2' `Bp' `VBp' `Xp' `VXp' {
            local tM: word `++j' of `tB1' `tVB1' `tX1' `tVX1' `tB2' `tVB2' `tX2' `tVX2' ///
             `tBp' `tVBp' `tXp' `tVXp'
            local i 0
            foreach var of local vars {
                local ++i
                mat `tM' = nullmat(`tM') \ `M'[rownumb(`M',"`var'"),1...]
            }
        }
//select columns
        local j 0
        foreach M in `VB1' `VX1' `VB2' `VX2' `VBp' `VXp' {
            local tM: word `++j' of `tVB1' `tVX1' `tVB2' `tVX2' `tVBp' `tVXp'
            mat ren `tM' `m'
            local i 0
            foreach var of local vars {
                local ++i
                mat `tM' = nullmat(`tM') , `m'[1...,colnumb(`m',"`var'")]
            }
            mat drop `m'
        }
//decompose
        Decompose "`tf'" `tB1' "`tVB1'" `tX1' "`tVX1'" `tB2' "`tVB2'" `tX2' "`tVX2'" ///
         "`tBp'" "`tVBp'" "`tXp'" "`tVXp'" `tD' "`tVD'"
        mat `D' = `D' \ `tD'
        mat drop `tD'
        if "`VD'"!="" {
            mat `VD' = `VD' \ `tVD'
            mat drop `tVD'
        }
//cleanup
        foreach M in `tB1' `tVB1' `tX1' `tVX1' `tB2' `tVB2' `tX2' `tVX2' ///
         `tBp' `tVBp' `tXp' `tVXp' {
            mat drop `M'
        }
    }

//return groups
    c_local p: word count `gnames'
    c_local vars `"`gnames'"'
end


prog def Display, eclass
    syntax anything [, eform Level(passthru) dep(str) ]
    eret post `anything', depn(`dep')
    eret local cmd oaxaca8
    if "`eform'"!="" local eform "eform(exp(b))"
    ereturn display, `eform' `level'
end


prog def PostInE, eclass
    args N1 N2 esample pred1 pred2 diff Vpred1 Vpred2 Vdiff D VD _cons
    local type: coleq `D'
    local comp: colnames `D'
    local c = colsof(`D')
    local r = rowsof(`D')
    tempname b
    if "`VD'"!="" tempname V
    forv j=1/`c' {
        mat `b' = nullmat(`b'), `D'[1...,`j']'
        if "`VD'"!="" mat `V' = nullmat(`V'), `VD'[1...,`j']'
        gettoken ty type: type
        gettoken co comp: comp
        if `r'==1 {
            local names `"`names'`ty':`co' "'
        }
        else {
            if inlist("`co'","endowments","interaction","explained") & `_cons' {
                mat `b' = `b'[1,1..colsof(`b')-2], `b'[1,colsof(`b')..colsof(`b')]
                if "`VD'"!="" mat `V' = `V'[1,1..colsof(`V')-2], `V'[1,colsof(`V')..colsof(`V')]
                local rr = `r'-1
            }
            else local rr `r'
            forv i=1/`rr' {
                local names `"`names'`co'(`ty'): "'
            }
        }
    }
    if `r'>1 {
        local names: subinstr local names "(three-fold)" "", all
        local names: subinstr local names "unexplained" "U", all
        local names: subinstr local names "explained" "E", all
    }
    mat coln `b' = `names'
    if "`VD'"!="" {
        mat coln `V' = `names'
        mat `V' = diag(`V')
    }
    else if c(stata_version)<9 {
        tempname V
        mat `V' = diag(`b'*0)
    }
    eret post `b' `V', esample(`esample')
    eret local cmd oaxaca8
    eret scalar N        = `N1'+`N2'
    eret scalar N1       = `N1'
    eret scalar N2       = `N2'
    eret scalar pred1    = `pred1'[1,1]
    eret scalar pred2    = `pred2'[1,1]
    eret scalar diff     = `diff'[1,1]
    if "`VD'"!="" {
        eret scalar se_pred1 = sqrt(`Vpred1'[1,1])
        eret scalar se_pred2 = sqrt(`Vpred2'[1,1])
        eret scalar se_diff  = sqrt(`Vdiff'[1,1])
    }

end
