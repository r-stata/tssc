***************************************
** Maximo Sangiacomo & Demian Panigo **
** January 2013. Program version 2.3 **
***************************************
program define rollstat
version 10
syntax varlist [if] [in],  Statistic(str) [w(integer 3) FORCE ]

local nstat : word count `statistic'
if `nstat' > 1 {
	disp as err "too many arguments specified in {it:statistic()} option"
	exit 198
}
if ("`statistic'"!="sd"&"`statistic'"!="mean"&"`statistic'"!="sum"&"`statistic'"!="min"&"`statistic'"!="max"&"`statistic'"!="N"&"`statistic'"!="Var") {
	di as err "{it:statname} could be one of the following possibilities:" 
	di "{inp} mean"
	di "{inp} sum"
	di "{inp} sd"
	di "{inp} Var"
	di "{inp} min"
	di "{inp} max"
	di "{inp} N (count of nonmissing observations)"
	exit 198
}
if `w' < 2 {
        di as err "window length must be at least 2"
	exit 198
}
if "`force'"!="" {
	local calcond "> 1"
}
else {
	local calcond "== `w'"
}
quietly {
	tempname Vals 
	marksample touse, nov
	markout `touse' `time'
	if "`r(panelvar)'"==""&"`r(timevar)'"=="" {
		disp in red "No TIME nor PANEL variable defined: Please use {it:{help tsset}} BEFORE rollstat command"
		exit 198
	}
	else if "`r(panelvar)'"!="" & "`r(timevar)'"!="" {
		local id `r(panelvar)'
		local time `r(timevar)'
	        tsreport if `touse', report panel
		if r(N_gaps) {
			di in red "sample may not contain gaps"
			exit 198 
		}
		qui tab `id' if `touse', matrow(`Vals') 
		local nvals = r(r)
		local i = 1
		while `i' <= `nvals' {
		    	local val = `Vals'[`i',1]
		    	local vals "`vals' `val'"
		    	local i = `i' + 1
    		}
		foreach var of varlist `varlist' {
			confirm new variable _`statistic'`w'_`var'
			gen _`statistic'`w'_`var'=.
			tempvar iid_`var'
			gen `iid_`var''=_n
			foreach i of local vals {
				sum `iid_`var'' if `id'==`i' & `touse'
				local n1 = r(N)
				if `n1' == 0 {
					continue
				}
				else {
					local l = 1
					local u = r(max)
					local j = 1
					if `w'>`u' {
						local w2 = `u'
					}
					else {	
						local w2 = `w'
					}
					while `j'<`w2' {
						sum `var' if `id'==`i' in 1/`j'
						local n2 = r(N)	
						if `n2' `calcond' {
							sum `var' if `id'==`i' in 1/`j' 
							replace _`statistic'`w'_`var'=r(`statistic') if `id'==`i' in `j'
						}
						local ++j
					}
					local l2 = `j'
					while `l2'<=`u'  {
						sum `var' if `id'==`i' in `l'/`l2'
						local n3 = r(N)	
						if `n3' `calcond' {
							sum `var' if `id'==`i' in `l'/`l2' 
							replace _`statistic'`w'_`var'=r(`statistic') if `id'==`i' in `l2'
							local l = `l'+1
							local l2= `l2'+1
						}
						else {
							local l = `l'+1
							local l2= `l2'+1
						}
					}
				}
			}
		}
		tsset `id' `time'
	}
	else if "`r(timevar)'"!="" {
		local time `r(timevar)'
		tsreport if `touse', report 
		if r(N_gaps) {
			di in red "sample may not contain gaps"
	                exit 198 
		}
		foreach var of varlist `varlist' {
			confirm new variable _`statistic'`w'_`var'
			gen _`statistic'`w'_`var'=.
			tempvar iid_`var'
			gen `iid_`var'' = _n
			sum `iid_`var'' if `touse'
			local l = 1
			local u = r(max)
			local j = 1
			if `w'>`u' {
				local w2 = `u'
			}
			else {	
				local w2 = `w'
			}
			while `j'<`w2' {
				sum `var' in 1/`j'
				local n2 = r(N)	
				if `n2' `calcond' {
					sum `var' in 1/`j' 
					replace _`statistic'`w'_`var'=r(`statistic') in `j'
				}
				local ++j
			}
			local l2 = `j'
			while `l2'<=`u'  {
				sum `var' in `l'/`l2'
				local n3 = r(N)	
				if `n3' `calcond' {
					sum `var' in `l'/`l2' 
					replace _`statistic'`w'_`var'=r(`statistic') in `l2'
					local l = `l'+1
					local l2= `l2'+1
				}
				else {
					local l = `l'+1
					local l2= `l2'+1
				}
			}
		}
		tsset `time'
	}
}
end
