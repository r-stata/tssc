*! Friday, April 11, 2008 at 15:36 by raa (ralfaro@bcentral.cl)
program define mira, eclass
    version 8
    syntax [anything] using/ [, M(integer 5) VAR(string)]
    tempname b V betas vars aux se df

    local more = c(more)
    set more off
    if `m'<2 {
        di as err "Multiple Imputation requires at least 2 datasets"
        exit    
    }

    qui {
        preserve
        gettoken todo : anything, match(parns)

        if "`var'"=="" {
            use `using'1, clear
        }
        else {
            use `using', clear
            keep if `var'==1
        }
        `todo'
        local depvar=e(depvar)
        local r2a =e(r2)
        if `r2a'>0 {
            local r2g =log(`r2a')
        }
        else {
            local r2g = -21
        }

        mat `b'=e(b)
        mat `se'=`b'
        mat `df'=`b'
        mat `V'=e(V)    
        local k=colsof(`b')
        mat `betas'=`b'
        mat `aux'=J(1,`k',0)
        forvalues j=1(1)`k' {
            mat `aux'[1,`j']=`V'[`j',`j']
        }
        mat `vars'=`aux'        

        forvalues i=2(1)`m' {
            if "`var'"=="" {
                use `using'`i', clear
            }
            else {
                use `using', clear
                keep if `var'==`i'
            }

            `todo'
            mat `b'=e(b)
            mat `V'=e(V)    
            local r2a =e(r2)+`r2a'
            if `r2a'>0 {
                local r2g = `r2g' + log(`r2a')
            }
            else {
                local r2g = `r2g' - 21
            }


            mat `betas'=`betas' \ `b'
            forvalues j=1(1)`k' {
                mat `aux'[1,`j']=`V'[`j',`j']
            }
            mat `vars'=`vars' \ `aux'       
        }
    
        drop _all
        local names: colnames `betas'
        tokenize `names'
        svmat double `vars', name(vars)
        svmat double `betas', name(bcoef)
        local ar2a = `r2a'/`m'
        local ar2g = exp(`r2g'/`m')
        local nobs = e(N)
    }


    di _n in gr "Multiple Imputation Estimates using " /*
        */ in ye "`e(cmd)'" in gr " command"
    di " "
    di in gr `"Sample min period ="' in ye %8.0f e(T_l) /*
        */ in gr _col(52) `"Number of obs     ="' in ye %8.0f `nobs'
    di in gr `"       max period ="' in ye %8.0f e(T_u) /*
        */ in gr _col(52) `"Number of groups  ="' in ye %8.0f e(N_g)
    di in gr `"Simple Average R2 ="' in ye %8.4f `ar2a' /*
        */ in gr _col(52) `"Geome. Average R2 ="' in ye %8.4f `ar2g'
    di " "

    di in text "{hline 13}{c TT}{hline 64}"
    di in text abbrev("`depvar'",12) _col(13) " {c |}      Coef.   Std. Err."  /*
        */ "      t    P>|t|       Df"
    di in text "{hline 13}{c +}{hline 64}"

    mat `V'=diag(`b')
        forvalues i=1(1)`k'{
            qui sum bcoef`i'
            local aux1=r(mean)              /* q-value coeff*/
            local aux2=r(sd)^2              /* b-value */
            qui sum vars`i'
            local aux3=r(mean)              /* u-value */
            local aux4=sqrt(`aux3'+(1+1/`m')*`aux2')    /* variance */
            local aux5=`aux1'/`aux4'
            local aux6=(`m'-1)*(1+`m'*`aux3'/((1+`m')*`aux2'))^2 /* df */
            local aux6=round(`aux6')
            local aux7=tprob(`aux6',`aux5')                 /* t */
            di as text %12s abbrev("``i''",12) " {c |}  " /*
                */ as result %9.0g `aux1' "  " /*
                */ %9.0g `aux4' "   " %6.0g `aux5' /*
                */ "   " %4.3f `aux7' "    " %4.0f `aux6'
            mat `b'[1,`i']=`aux1'
            mat `se'[1,`i']=`aux4'
            mat `df'[1,`i']=`aux6'
            mat `V'[`i',`i']=`aux4'^2
        }   

    drop _all
    discard
    restore
    di in text "{hline 13}{c BT}{hline 64}" 
    eret post `b' `V'
    eret mat se = `se'
    eret mat df =`df'
    eret sca N = `nobs'
    eret sca r2a = `ar2a'
    eret sca r2g = `ar2g'
    set more `more'
end
