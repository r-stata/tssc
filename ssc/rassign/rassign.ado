program define rassign, rclass

    version 10.1

    if replay()& "`e(cmd)'"=="rassign" {
        ereturn  display
        exit
    }

    syntax varlist(numeric fv) [if] [in], Group(string)

	tempvar y x w ym xm Ng t w0 gfreq z1 Z Z1 n2 numid2 tvar id
	tempname touse
	
    mark `touse' `if' `in'
    markout `touse' `varlist'

	gen `id'=_n
	
	local y: word 1 of `varlist'
    local x: word 2 of `varlist'
	local w: list varlist -y
	local w: list w -x
	
	qui {
	preserve
	keep if `touse'==1
	sort `group' `id'
	by `group': gen `tvar'=_n  
	by `group': gen `Ng'=_N
	
	drop if `Ng'<3

	qui areg `y' `w' if `touse', absorb(`group')
	predict `ym' if `touse', residuals

	qui areg `x' `w' if `touse', absorb(`group')
	predict `xm' if `touse', residuals

	gen `w0'=1/(`Ng'-1) if `touse'
	gen `z1'=`ym'*(`xm'+`w0'*`ym') if `touse'
	qui sum `z1' if `touse'
	local S=r(sum)
	bysort `group': gen `gfreq' = _N if `touse'
	expand `gfreq' if `touse'

	sort `group' `tvar'

	by `group' `tvar': gen `numid2' = _n if `touse'
	by `group': gen `n2' = `tvar'[`gfreq' * `numid2'] if `touse'
	by `group': gen `Z1' = `z1'[`gfreq' * `numid2'] if `touse'

	gen `Z'=`z1'*`Z1' if `touse'
	qui sum `Z' if `touse'
	local V=r(sum)

	local t=`S'/sqrt(`V')
	local lpvalue=normal(`t')
	local rpvalue=1-normal(`t')
	local tpvalue=2*(1-normal(abs(`t')))
	sum `Ng'
	local Ngmin=r(min)
	local Ngmax=r(max)
	qui levelsof `group'
	local NN=r(r)
	}
	di as txt ""
	di as txt "——————————————————————————————————————————————————————————————————————————————————————————————————"
	di in y "Test for (conditional) random assignment to peer groups (or absence of conditional correlation):"
	di as txt "——————————————————————————————————————————————————————————————————————————————————————————————————"
	di as txt ""
	di "T-statistic: " in y `t' in g "	(reference distribution is standard normal)"
	di as txt ""
	di as txt "P-values left-sided:" %8.4f `lpvalue' "     two-sided:" %8.4f `tpvalue' "     right-sided:" %8.4f `rpvalue'
	di as txt "——————————————————————————————————————————————————————————————————————————————————————————————————"
	di as txt "The null is absence of correlation."
	di ""
	di as text "The grouping variable is `group'. There are " `NN' " groups."
	di as text "The smallest group is of size " `Ngmin' " while the largest is of size " `Ngmax'


	return clear
	
	return scalar minG = `Ngmin'
	return scalar maxG = `Ngmax'
	return scalar Ng = `NN'
	return scalar l_pvalue = `lpvalue'
	return scalar pvalue = `tpvalue'
	return scalar r_pvalue = `rpvalue'
	return scalar t = `t'

	sort `id'
	restore

end

