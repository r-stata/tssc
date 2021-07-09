*! version 1.1.1  29apr2011  Ben Jann
*! version 1.0.1  26sep2008  Ben Jann
*! version 1.0.0  18jan2008  Ben Jann

program rrreg, eclass byable(recall) prop(svyb svyj svyr swml)
    version 9.0
    local caller : di _caller()
    if replay() {
        if `"`e(cmd2)'"'!="rrreg" {
            di as err "last estimates not found"
            exit 301
        }
        version `caller': Display `0'
        exit
    }
    syntax varlist(numeric) [if] [in] [aw fw iw pw] [, ///
        PWarner(str) PYes(str) PNo(str) ///
        Level(passthru) Beta EForm(passthru) noHEader plus DEPname(str) * ]
    if `"`pwarner'"'==""  local pwarner 1
    if `"`pyes'"'=="" local pyes 0
    if `"`pno'"'==""  local pno 0
    
    marksample touse
    capt assert (`pwarner'>=0) & (`pwarner'<=1) & (`pwarner'!=0.5) if `touse'
    if _rc {
        di as err "pwarner() must be in [0,1]; pwarner() must be unequal 0.5"
        exit 198
    }
    capt assert (`pyes'>=0) & (`pno'>=0) & ((`pyes'+`pno')<1) if `touse'
    if _rc {
        di as err "pyes() and pno() must be in [0,1]; pyes()+pno() must be < 1"
        exit 198
    }

    tempvar rrvar
    gettoken depvar indepvars : varlist
    qui gen double `rrvar' = (`depvar'!=0) if `touse'
    ta `rrvar' if `touse', nofreq
    if r(r)<2 {
        di as txt "outcome does not vary; remember:"
        di as txt _col(35) "0 = negative outcome,"
        di as txt _col(9) /*
        */ "all other nonmissing values = positive outcome"
                exit 2000
        }
    if `"`depname'"'=="" local depname `depvar'
    qui replace `rrvar' = (`rrvar' - (1 - `pyes' - `pno')*(1-`pwarner') - `pyes') ///
        / ((2*`pwarner'-1)*(1-`pyes'-`pno')) if `touse'
    qui version `caller': regress `rrvar' `indepvars' if `touse' [`weight'`exp'], depname(`depname') `options'
    eret local title "Randomized response regression"
    eret local cmd2 "rrreg"
    eret local cmdline `"`0'"'
    eret local pyes "`pyes'"
    eret local pno "`pno'"
    eret local pwarner "`pwarner'"
    Display, `level' `beta' `eform' `header' `plus'
end

prog Display
    version 9.0
    local caller : di _caller()
    syntax [, noHEader * ]
    if "`header'"=="" {
        version `caller': _coef_table_header
        di ""
    }
    version `caller': regress, noheader `options'
    di ""
    di as txt `"Pr(non-negated question) = "' as res `"`e(pwarner)'"'
    di as txt `"Pr(surrogate "yes")      = "' as res `"`e(pyes)'"'
    di as txt `"Pr(surrogate "no")       = "' as res `"`e(pno)'"'
end
