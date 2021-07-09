*! hprescott8 1.0.4 CFBaum  18jun2006
* 1.0.0: from http://ideas.repec.org/c/dge/qmrbcd/3.html
* 1.0.1: corrections to match FORTRAN output
* 1.0.2: add stub option for multiple variables
* 1.0.3: make byable(recall), new variable generation for subgroups
* 1.0.4: return trend variables as well as filtered variables

program hprescott8, rclass byable(recall,noheader)
	version 8.2
	
syntax varlist(ts) [if] [in], STUB(string) [Smooth(integer 1600)] 
 
    marksample touse
//    _ts timevar panelvar `if' `in', sort onepanel
	_ts timevar panelvar if `touse', sort onepanel
    markout `touse' `timevar'
    tsreport if `touse', report
    if r(N_gaps) {
        di as err "sample may not contain gaps"
        exit 198 
    }
    qui count if `touse'
        if r(N) == 0 error 2000
* validate each new varname defined by stub()
	local kk: word count `varlist'
	local varlist2: subinstr local varlist "." "_", all	
	local suf = _byindex()
	qui forval i = 1/`kk' {
		local v: word `i' of `varlist2'
		confirm new var `stub'_`v'_`suf'
		confirm new var `stub'_`v'_t_`suf'
		gen double `stub'_`v'_`suf' = .
		gen double `stub'_`v'_t_`suf' = .
		local varlist3 "`varlist3' `stub'_`v'_`suf'"
		local varlist4 "`varlist4' `stub'_`v'_t_`suf'"
	}

	local nv 0
	foreach v of varlist `varlist' {
	tempvar rawvar
	qui gen `rawvar' = `v' if `touse'	
	local v11 = 1.0
	local v22 = 1.0
	local v12 = 0.0
	tempvar v1 v2 v3 t d enn
	forv i=1/3 {
		qui gen `v`i'' = .
		}
	qui gen `d' = .
	qui gen `t' = .
* do i = 3,n
	qui gen `enn' = _n if `touse'
	su `enn', meanonly
	local obs1 = r(min)
	local obs2 = r(min)+1
	local obs3 = r(min)+2
	local obsn = r(max) 
	local obsn1 = r(max)-1
	local obsn2 = r(max)-2

	forv i=`obs3'/`obsn' {
		local x = `v11'
		local z = `v12'
		local v11 = 1/`smooth' + 4.0*(`x'-`z') + `v22'
		local v12 = 2*`x' -`z'
		local v22 = `x'
		local det = `v11'*`v22' - `v12'*`v12'
		qui {
			replace `v1' = `v22'/`det' in `i'
			replace `v3' = `v11'/`det' in `i'
			replace `v2' = -`v12'/`det'  in `i'
		}
		local x = `v11'+1
		local z = `v11'
		local v11 = `v11' - `v11'*`v11'/`x'
		local v22 = `v22' - `v12'*`v12'/`x'
		local v12 = `v12' - `z'*`v12'/`x'
	}

* forward pass
	local m1 = `rawvar'[`obs2']
	local m2 = `rawvar'[`obs1']
* do i = 3,n
	forv i = `obs3'/`obsn' {
		local x = `m1'
		local m1 = 2.0*`m1'-`m2'
		local m2 = `x'
		qui { 
			local i1 = `i'-1
			replace `t' = `v1'[`i']*`m1' + `v2'[`i']*`m2' in `i1'
			replace `d' = `v2'[`i']*`m1' + `v3'[`i']*`m2' in `i1'
		}
		local det = `v1'[`i']*`v3'[`i'] - `v2'[`i']^2
		local v11 = `v3'[`i']/`det'
		local v12 = -`v2'[`i']/`det'
		local z = (`rawvar'[`i']-`m1')/(`v11'+1)
		local m1 = `m1' + `v11'*`z'
		local m2 = `m2' + `v12'*`z'
	}
	qui replace `t' = `m1' in `obsn'
	qui replace `t' = `m2' in `obsn1'
* not in orig code, but needed to match it
	qui replace `t' = 0 in `obs1'
* backward pass
	local m1 = `rawvar'[`obsn1']
	local m2 = `rawvar'[`obsn']
* do 15 i = n-2,1,-1
	forv i=`obsn2'(-1)`obs1' {
		local i1 = `i'+1
		local ib = `obsn'-`i'+`obs1'
		local x = `m1'
		local m1 = 2*`m1' - `m2'
		local m2 = `x'
		if (`i' > `obs2') {
			local e1 = `v3'[`ib']*`m2' + `v2'[`ib']*`m1' + `t'[`i']
			local e2 = `v2'[`ib']*`m2' + `v1'[`ib']*`m1' + `d'[`i']

			local b11 = `v3'[`ib'] + `v1'[`i1']
			local b12 = `v2'[`ib'] + `v2'[`i1']
			local b22 = `v1'[`ib'] + `v3'[`i1']
			local det = `b11'*`b22' - `b12'*`b12'
			local tee = (-1*`b12'*`e1' + `b11'*`e2')/`det'
			qui replace `t' = (-1*`b12'*`e1' + `b11'*`e2')/`det' in `i'
			}
* end of combining
		local det = `v1'[`ib']*`v3'[`ib'] - `v2'[`ib']*`v2'[`ib']
		local v11 = `v3'[`ib']/`det'
		local v12 = -1*`v2'[`ib']/`det'
		local z = (`rawvar'[`i']-`m1')/(`v11'+1)
		local m1 = `m1' + `v11'*`z'
		local m2 = `m2' + `v12'*`z'
	}

	qui {
		replace `t' = `m1' in `obs1'
		local obs11= `obs1'+1
		replace `t' = `m2' in `obs11'
		replace `d' = `rawvar' - `t' in `obs1'/`obsn'
	}

*	qui gen double `filt' = `d' if `touse'
	local ++nv
	local vn : word `nv' of `varlist3'
	qui replace `vn' = `d' if `touse'
	local vnt : word `nv' of `varlist4'
	qui replace `vnt' = `t' if `touse'
	}
*	return local depvar "`varlist'"
	return local filtvars "`varlist3'"
	return local trendvars "`varlist4'"
	return local obs1 "`obs1'"
	return local obsn "`obsn'"
	return local smooth "`smooth'"
	end
	
