*! version 1.0.0 DH 29Sep2004.
program define kappaci, rclass
    version 8.0
    syntax varlist(min=2 max=2 numeric) [if] [in] /*
		*/ [, Level(integer $S_level) ]
    tempvar touse
	mark `touse' `if' `in'
	qui count if `touse'
	if r(N) < 1 {
		error 2000
	}
    qui {
        tokenize `varlist'
        tempvar x m w minv msq
        gen `x'=`1' if `touse'
        gen `m'=`1'+`2' if `touse'
        summ `m', detail
        if r(max)<3 {
            di as error "must have at least 3 raters"
            exit 198
        }
        local n=r(N)
        local N=r(sum)
        if r(min)<r(max) {
			local med : di %9.2f r(p50)
			local med `med'
			nois di as text _n "There are between " r(min) " and " /*
				*/ r(max) " (median = `med') raters per subject:"
		}
		else {
			nois di as text _n "There are " r(min) " raters per subject:"
        }
        nois di as text _n "Two-outcomes, multiple raters:"
        * call -kappa- and store returns
        kappa `varlist' if `touse'
		local kappa=r(kappa)
        local z=r(z)
        return add
        * calculate ci for kappa, following Zou & Donner (2004)
        local pval=1-norm(`z')
		summ `x', meanonly
        local pbar=r(sum)/`N'
        local pq=`pbar'*(1-`pbar')
        gen `minv'=1/`m'
        summ `minv', meanonly
        local Sminv=r(sum)
        gen `msq'=`m'^2
        summ `msq', meanonly
        local Smsq=r(sum)
        local A=(1/`pq'-6)*`Sminv'/((`N'-`n')^2) /*
			*/ + (2*`N'+4*`n'-`n'/`pq')*`n'/(`N'*((`N'-`n')^2))
        local B=`Smsq'/((`N'^2)*`pq') /*
            */ - (3*`N'-2*`n')*(`N'-2*`n')*`Smsq'/((`N'^2)*((`N'-`n')^2)) /*
            */ - (2*`N'-`n')/((`N'-`n')^2)
        local C=(4-1/`pq')*(`Smsq'-`N')/(`N'^2)
        local Z=invnorm((100+`level')/200)^2
        local a=`Z'*`C'
        local b=`Z'*(`B'-`C')+1
        local c=`Z'*(`A'-`B')-2*`kappa'
        local d=((`kappa')^2)-`Z'*`A'
        * ci bounds are the first two roots of the cubic ax^3 + bx^2 + cx + d = 0
        solvcui `a' `b' `c' `d'
        local lb=r(x1)
        local ub=r(x2)
	}
    * output results
	di as text _n _col(10) "Kappa" _col(18) "[`level'% Conf. Interval]" _col(46) "Z" _col(52) "Prob>Z"
    di as text _col(9) "{hline 49}"
    di as result _col(8) %7.4f `kappa' _col(20) %7.4f `lb' _col(31) %7.4f `ub' /*
		*/ _col(40) %7.2f `z' _col(51) %7.4f `pval'
    return scalar kappa_ub=`ub'
    return scalar kappa_lb=`lb'
end
