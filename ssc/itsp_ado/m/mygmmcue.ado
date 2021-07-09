*! mygmmcue 1.0.2 MES/CFB 11aug2008
program mygmmcue, eclass
        version 10.1
        syntax varname(ts) [if] [in] [ , endog(varlist ts) ///
                inexog(varlist ts) exexog(varlist ts) robust ]
        local depvar `varlist'

        marksample touse
        markout `touse' `endog' `inexog' `exexog'
        tempname b V omega

        mata: m_mygmmcue("`depvar'", "`endog'", "`inexog'", /// 
                         "`exexog'", "`touse'", "`robust'")

        mat `b' = r(beta)
        mat `V' = r(V)
        mat `omega'=r(omega)
// Prepare row/col names
// Our convention is that regressors are [endog   included exog]
// and instruments are                   [excluded exog  included exog]
        local vnames `endog' `inexog' _cons
        matrix rownames `V' = `vnames'
        matrix colnames `V' = `vnames'
        matrix colnames `b' = `vnames'
        local vnames2 `exexog' `inexog' _cons
        matrix rownames `omega' = `vnames2'
        matrix colnames `omega' = `vnames2'

        local N = r(N)
        ereturn post `b' `V', depname(`depvar') obs(`N') esample(`touse')

        ereturn matrix omega `omega'
        ereturn local depvar = "`depvar'"
        ereturn scalar N = r(N)
        ereturn scalar j = r(j)
        ereturn scalar L = r(L)
        ereturn scalar K = r(K)

        if "`robust'" != "" ereturn local vcetype "Robust"

        display _newline "GMM-CUE estimates" _col(60) "Number of obs = " e(N)
        ereturn display
        display "Sargan-Hansen J statistic: " %7.3f e(j)
        display "Chi-sq(" %3.0f e(L)-e(K) "  )       P-val = " ///  
                %5.4f chiprob(e(L)-e(K), e(j)) _newline

end
