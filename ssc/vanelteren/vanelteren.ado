*! vanelteren.ado  Version 1.0  2004-05-09  JRC
program define vanelteren, byable(recall) sortpreserve rclass
    version 8.2
    syntax varlist(min=1 max=1 numeric) [if] [in], BY(varname) STrata(varname)
    tempfile tmpfile
    tempvar tmp tmp1
    tempname StrataLabels
    marksample touse
*    In the next version, generate tempvar for string dependent variable
    capture confirm numeric variable `by'
    if _rc {
        display as error "by-variable must be numeric."
        exit
    }
    quietly tabulate `by' if `touse'
    if r(r) > 2 {
        display as error "No more than two levels of by-variable allowed."
        exit
    }
    capture confirm string variable `strata'
    if !_rc {
        encode `strata' if `touse', generate(`tmp') label(`StrataLabels')
        quietly save `tmpfile'
        uselabel `StrataLabels', clear
        quietly count
        local number_of_blocks = r(N)
        forvalues i = 1/`number_of_blocks' {
            local stratum`i' = substr(label[`i'], 1, 12)
        }
        use `tmpfile', clear
        erase `tmpfile'
        summarize `tmp' if `touse', meanonly
        assert `number_of_blocks' == r(max)
        local N = r(N)
        label drop `StrataLabels'
    }
    else {
        sort `touse' `strata'
        by `touse' `strata':  generate long `tmp' = _n == 1
        quietly replace `tmp' = `tmp' * `touse'
        quietly replace `tmp' = sum(`tmp')
        summarize `tmp' if `touse', meanonly
        local number_of_blocks = r(max)
        local N = r(N)
        quietly save `tmpfile'
        local checkvalabels: value label `strata'
        capture assert "`checkvalabels'" == ""
        if _rc {
            decode `strata', generate(`tmp1')
            contract `tmp1' `tmp' if `touse'
            sort `tmp'
            forvalues i = 1/`number_of_blocks' {
                local stratum`i' = substr(`tmp1'[`i'], 1, 12)
            }
        }
        else {
            contract `strata' `tmp' if `touse'
            sort `tmp'
            forvalues i = 1/`number_of_blocks' {
                local stratum`i' = substr(string(`strata'[`i']), 1, 12)
            }
        }
        macro drop checkvalabels
        use `tmpfile', clear
        erase `tmpfile'
    }
    local sum_of_weightedranksum = 0
    local sum_of_expected_weightedranksum = 0
    local sum_of_weightedranksum_variance = 0
    display
    display as text "Generalized Wilcoxon-Mann-Whitney Ranksum Test (van Elteren's Test)"
    display
    display
    display as text "                                               Variance of"
    display as text "                       Weighted    Expected     Weighted"
    display as text "   Stratum   |   n   | Ranksum   | Ranksum  |   Ranksum"
    display as text "-------------+-------+-----------+----------+-------------"
*                             1         2         3         4         5         6
*                    123456789012345678901234567890123456789012345678901234567890
    forvalues block = 1/`number_of_blocks' {
        quietly ranksum `varlist' if `tmp' == `block' & `touse' == 1, by(`by')
        local Ni = r(N_1) + r(N_2)
        local Wr = r(sum_obs) / (`Ni' + 1)
        local EH = r(N_1) / 2
        local VarH = r(Var_a) / (`Ni' + 1 )^2
        display as result _col(1) %12s "`stratum`block''" ///
                as text _col(14) "|" as result _col(15) %5.0fc `Ni' ///
                as text _col(22) "|" as result _col(26) %5.2fc `Wr' ///
                as text _col(34) "|" as result _col(37) %5.1fc `EH' ///
                as text _col(45) "|" as result _col(50) %5.3fc `VarH'
        local sum_of_weightedranksum = `sum_of_weightedranksum' + `Wr'
        local sum_of_expected_weightedranksum = `sum_of_expected_weightedranksum' + `EH'
        local sum_of_weightedranksum_variance = `sum_of_weightedranksum_variance' + `VarH'
    }
    drop `tmp'
    display as text "-------------+-------+-----------+----------+-------------"
    display as text "    Sums     |" _continue
    display as result _col(15) %5.0fc `N' _continue
    display as text _col(22) "|" as result _col(26) %5.2fc `sum_of_weightedranksum' _continue
    display as text _col(34) "|" as result _col(37) %5.1fc `sum_of_expected_weightedranksum' _continue
    display as text _col(45) "|" as result _col(50) %5.3fc `sum_of_weightedranksum_variance'
    display
    return scalar z = (`sum_of_weightedranksum' - `sum_of_expected_weightedranksum') ///
     / sqrt(`sum_of_weightedranksum_variance')
    return scalar p = 2 - 2 * norm( abs( return(z) ) )
    display as text "Asymptotic test statistic"
    display as text "z = " as result %7.4g return(z)
    display as text "Prob(Z > |z|) = " as result %6.4g return(p)
end

