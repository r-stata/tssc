program define hangr_ci, sclass
	syntax, dist(string)     ///
	        level(integer)   ///
			nbins(integer)   ///
			h(varname)       ///
			w(real)          ///
			nobs(integer)    ///
			lb(string)       ///
			ub(string)       ///
			[                ///
			min(numlist)     /// 
			max(numlist)     ///
			spike            ///
			bar              ///
			suspended        ///
			xsusp(string)    ///
			x(varname)       ///
			x2(varname)      ///
			theor(varname)   ///
			newobs(varname)  ///
			ciopt(string)    ///
			inflate(numlist) ///
			]
	
	tokenize `inflate'
	if "`min'" != "" & "`1'" != "" {
		local min = cond(`1'-.5*`w' < `min', `1' - .5*`w', `min')
	}
	if "`max'" != "" & "`2'" != "" {
		local max = cond(`2' + .5*`w' > `max', `2' + .5*`w', `max')
	}
	
	tempvar count
	if `level' < 10 | `level' > 99 local level = 95
	local bonf = `level'/(100*`nbins')
	local B = invchi2tail(1,`bonf')
	qui gen `count' = `h'*`w'*`nobs'
	qui gen `lb' = (`B' + 2*`count' - ///
	           sqrt(`B'*(`B' + 4*`count'*(`nobs'-`count')/`nobs'))) / ///
	           (2*(`nobs' + `B'))
	qui gen `ub' = (`B' + 2*`count' + ///
		   sqrt(`B'*(`B' + 4*`count'*(`nobs'-`count')/`nobs'))) / ///
	           (2*(`nobs' + `B'))
	if "`suspended'" != "" {
		tempvar cioffset 
		qui gen `cioffset' = (sqrt(`ub'*`nobs') - sqrt(`lb'*`nobs'))/2
		qui replace `lb' = - `cioffset' /*+ cond(-`cioffset' < -`theor', `cioffset' - `theor', 0)*/
		qui replace `ub' = `cioffset'   /*+ cond(-`cioffset' < -`theor', `cioffset' - `theor', 0)*/
		if "`dist'" != "theoretical" {
			qui gen `xsusp' = `x'
			if _N < `nbins' + 2 {
				qui set obs `=`nbins'+2'
				qui replace `newobs' = 1 if `newobs' == .
			}
			sum `xsusp' , meanonly
			qui replace `xsusp' = r(min)-.5*`w' in `=`r(N)'+1'
			qui replace `xsusp' = r(max)+.5*`w' in `=`r(N)'+2'
			sort `xsusp'
			qui replace `lb' = `lb'[2] in 1
			qui replace `lb' = `lb'[`=`r(N)'+1'] in `=`r(N)'+2'
			qui replace `ub' = `ub'[2] in 1
			qui replace `ub' = `ub'[`=`r(n)'+1'] in `=`r(N)'+2'
		}
		else{
			qui gen `xsusp' = `x'
			qui replace `xsusp' = `xsusp'[1] in 2
			qui replace `xsusp' = `x2' in 1
			qui replace `xsusp' = `x2' in `=`nbins'+2'
			qui replace `lb' = `lb'[1] in 2
			qui replace `ub' = `ub'[1] in 2
			qui replace `lb' = `lb'[`=`nbins'+1'] in `=`nbins'+2'
			qui replace `ub' = `ub'[`=`nbins'+1'] in `=`nbins'+2'
		}
	}
	else {
		qui replace `lb' = `theor' - sqrt(`lb'*`nobs') 
		qui replace `ub' = `theor' - sqrt(`ub'*`nobs')
	}
	if "`spike'" != ""  & "`suspended'" == "" {
		local cibarw = .5*`w'
		sreturn local cispike "rbar `lb' `ub' `x', astyle(ci) barw(`cibarw') `ciopt'"
	}
	if "`bar'" != "" & "`suspended'" == "" {
		sreturn local cibar "rcap `lb' `ub' `x', `ciopt'"
	}	
	if "`suspended'" != "" {
		sreturn local ciarea "rarea `lb' `ub' `xsusp', astyle(ci) `ciopt'  || pci 0 `min' 0 `max', lstyle(yxline)"
	}
end
