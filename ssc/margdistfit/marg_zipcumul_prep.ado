*! version 1.3.0 14May2012 MLB
program define marg_zipcumul_prep, rclass 
	version 10.1
	
	syntax [if] ,   ///
	[               ///
	simvars(string) ///
	pi(string)      ///
	simopts(string) ///
	noPArsamp       ///
	]               ///
	ptheor(string)  ///
	ytheor(string)  ///
	pobs(varname)   ///
	sims(integer)   ///
	n(integer)      ///
	y(varname)      ///
	e(real)
	
	marksample touse 
	
	tempvar lambda pr first fw
	qui predict double `lambda' if `touse', xb eq(#1)
	qui replace `lambda' = exp(`lambda')
	qui predict `pr', pr
	qui gen `ptheor' = .

	sum `y' if `touse', meanonly
	local min = r(min)
	local max = r(max)
		
	if "`parsamp'" == "" {
		tempname bname vname orig
		matrix `bname' = e(b)
		matrix `vname' = e(V)
		est store `orig'
		
		tempvar lambda2 pr2
		qui gen `lambda2' = .
		qui gen `pr2' = .
		
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			local pvar : word `i' of `pi'
			drop `lambda2' `pr2'
			marg_parsamp, bname(`bname') v(`vname')
			qui predict double `lambda2' if `touse', xb eq(#1)
			qui replace `lambda2' = exp(`lambda2')
			qui predict double `pr2', pr
			qui gen `nvar' = cond(runiform()< `pr2', 0, rpoisson(`lambda2')) if `touse'
			
			sum `nvar' , meanonly
			local min = min(`min', `r(min)')
			local max = max(`max', `r(max)')
			sort `nvar'
			qui gen `pvar' = sum(`touse')
			qui replace `pvar' = cond(`touse',`pvar'/(`pvar'[_N]+1),.)
			quietly {
				by `nvar' : replace `pvar' = `pvar'[_N]
			}
			local gr "`gr' || scatter `pvar' `nvar', msymbol(oh) color(gs10) sort `simopts'"
		}
		qui est restore `orig'
	}
	else {
		forvalues i = 1/`sims' {
			local nvar : word `i' of `simvars'
			local pvar : word `i' of `pi'
			qui gen `nvar' = cond(runiform()< `pr', 0, rpoisson(`lambda')) if `touse'
			sum `nvar' , meanonly
			local min = min(`min', `r(min)')
			local max = max(`max', `r(max)')
			sort `nvar'
			qui gen `pvar' = sum(`touse')
			qui replace `pvar' = cond(`touse',`pvar'/(`pvar'[_N]+1),.)
			quietly {
				by `nvar': replace `pvar' = `pvar'[_N]
			}
			local gr "`gr' || scatter `pvar' `nvar', msymbol(oh) color(gs10) sort `simopts'"
		}
	}
	
	sort `lambda' `pr'
	by `lambda' `pr' : gen byte `first' = cond(`touse', _n == 1, 0)
	qui by `lambda' `pr' : gen float `fw' = _N if `touse'

	if _N < ( `max' + 1 ) {
		local n_old = _N
		qui set obs `= r(N) + 1 '
	}
	qui gen `ytheor' = _n - 1 if _n <= ( `max' + 1 )
	
	tempvar touse2
	gen byte `touse2' = !missing(`ytheor')
	mata marg_zippp("`ytheor'", "`ptheor'", "`lambda'", "`pr'", "`first'", "`fw'", "`touse2'")
	return local gr `"`gr'"'
end
