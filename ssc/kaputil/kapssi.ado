*! version 1.0.0 DH 29Sep2004.
program define kapssi, rclass
    version 8.0
	syntax anything(name=k id="kappa") , P1(real) /*
		*/ [ p2(real -1) m(integer 2) Se(real -1) Diff(real -1) /*
		*/ Level(real $S_level) n(integer -1) round ]
    confirm number `k'
    if `k'<0 | `k'>1 {
        disp as error "kappa must be between 0 and 1"
        exit 198
    }
    confirm number `p1'
    if `p1'<=0 | `p1'>=1 {
        disp as error "p1 must be between 0 and 1"
        exit 198
    }
    if `m'<2 {
        disp as error "m must be at least 2"
        exit 198
    }
    local nopts=(`se'==-1)+(`diff'==-1)+(`n'==-1)
    if `nopts'==3 {
        disp as error "one of se, diff and n must be specified"
        exit 198
    }
    if `nopts'<2 {
        disp as error "only one of se, diff and n may be specified"
        exit 198
    }
    if "`round'"=="" {
        local round "ceil"
    }
    if `m'==2 { // two raters
        if `p2'==-1 {
            local p2 `p1'
        }
        if `p2'<=0 | `p2'>=1 {
            disp as error "p2 must be between 0 and 1"
            exit 198
        }
        if `n'==-1 { // calculate sample size
            if `se'==-1 {
                if `diff'<=0 {
                    disp as error "diff must be greater than 0"
                    exit 198
                }
                if `level'<10 | `level'>99 {
                    disp as error "level must be between 10 and 99"
                    exit 198
                }
                local se=`diff'/invnorm((100+`level')/200)
            }
            if `se'<=0 {
                disp as error "se must be greater than 0"
                exit 198
            }
            local n=`round'((1-`k')*(4*`p1'*`p2'*(1-`p1')*(1-`p2')*(1+`k')+(1-2*`p1')*(1-2*`p2')*(`p1'*(1-`p2')+`p2'*(1-`p1'))*`k'*(2-`k'))/((`se'*(`p1'*(1-`p2')+`p2'*(1-`p1')))^2))
            disp as text _n "Estimated sample size for kappa to achieve given standard error"
            disp as text _n "Assumptions:" _n(2) /*
                */ _col(10) "kappa = " as result %8.4f `k' _n /*
                */ as text _col(14) "m = " as result %8.0f `m' as text " (number of raters)" _n /*
                */ _col(13) "p1 = " as result %8.4f `p1' as text " (rater 1 proportion of positive ratings)" _n /*
                */ _col(13) "p2 = " as result %8.4f `p2' as text " (rater 2 proportion of positive ratings)"
            if `diff'!=-1 {
                disp as text _col(11) "diff = " as result %8.4f `diff' /*
					*/ as text " (half width of confidence interval)" _n /*
                    */ _col(10) "alpha = " as result %8.4f (100-`level')/100
            }
            disp as text _col(13) "se = " as result %8.4f `se'
            disp as text _n "Estimated required sample size:" _n(2) /*
                */ _col(14) "n = " as result %8.0f `n'
        }
        else { // calculate standard error
            if `n'<=0 {
                disp as error "n must be greater than 0"
                exit 198
            }
            local se=sqrt((1-`k')*(4*`p1'*`p2'*(1-`p1')*(1-`p2')*(1+`k')+(1-2*`p1')*(1-2*`p2')*(`p1'*(1-`p2')+`p2'*(1-`p1'))*`k'*(2-`k')))/(`n'*(`p1'*(1-`p2')+`p2'*(1-`p1')))
            disp _n as text "Estimated standard error for kappa from given sample size"
            disp _n as text "Assumptions:" _n(2) /*
                */ _col(10) "kappa = " as result %8.4f `k' _n /*
                */ as text _col(14) "m = " as result %8.0f `m' as text " (number of raters)" _n /*
                */ _col(13) "p1 = " as result %8.4f `p1' as text " (rater 1 proportion of positive ratings)" _n /*
                */ _col(13) "p2 = " as result %8.4f `p2' as text " (rater 2 proportion of positive ratings)" _n /*
                */ _col(14) "n = " as result %8.0f `n'
            disp as text _n "Estimated standard error:" _n(2) /*
                */ _col(13) "se = " as result %8.4f `se'
        }
    }
    else { // more than 2 raters
        if `p2'!=-1 {
            disp as error "p2 may not be specified for more than 2 raters"
            exit 198
        }
        local p `p1'
        if `n'==-1 { // calculate sample size
            if `se'==-1 {
                if `diff'<=0 {
                    disp as error "diff must be greater than 0"
                    exit 198
                }
                if `level'<10 | `level'>99 {
                    disp as error "level must be between 10 and 99"
                    exit 198
                }
                local se=`diff'/invnorm((100+`level')/200)
            }
            if `se'<=0 {
                disp as error "se must be greater than 0"
                exit 198
            }
            local n=`round'((1-`k')*(2/(`m'*(`m'-1))-(3-1/(`p'*(1-`p')))*`k'+(`m'-1)*(4-1/(`p'*(1-`p')))*(`k'^2)/`m')/(`se'^2))
            disp as text _n "Estimated sample size for kappa to achieve given standard error"
            disp as text _n "Assumptions:" _n(2) /*
                */ _col(10) "kappa = " as result %8.4f `k' _n /*
                */ as text _col(14) "m = " as result %8.0f `m' as text " (number of raters)" _n /*
                */ _col(14) "p = " as result %8.4f `p' as text " (overall proportion of positive ratings)"
            if `diff'!=-1 {
                disp as text _col(11) "diff = " as result %8.4f `diff' /*
					*/ as text " (half width of confidence interval)" _n /*
                    */ _col(10) "alpha = " as result %8.4f (100-`level')/100
            }
            disp as text _col(13) "se = " as result %8.4f `se'
            disp as text _n "Estimated required sample size:" _n(2) /*
                */ _col(14) "n = " as result %8.0f `n'
        }
        else { // calculate standard error
            if `n'<=0 {
                disp as error "n must be greater than 0"
                exit 198
            }
            local se=sqrt((1-`k')*(2/(`m'*(`m'-1))-(3-1/(`p'*(1-`p')))*`k'+(`m'-1)*(4-1/(`p'*(1-`p')))*(`k'^2)/`m')/`n')
            disp _n as text "Estimated standard error for kappa from given sample size"
            disp _n as text "Assumptions:" _n(2) /*
                */ _col(10) "kappa = " as result %8.4f `k' _n /*
                */ as text _col(14) "m = " as result %8.0f `m' as text " (number of raters)" _n /*
                */ _col(14) "p = " as result %8.4f `p' as text " (overall proportion of positive ratings)" _n /*
                */ _col(14) "n = " as result %8.0f `n'
            disp as text _n "Estimated standard error:" _n(2) /*
                */ _col(13) "se = " as result %8.4f `se'
        }
    }
    return scalar se=`se'
    return scalar N=`n'
end
