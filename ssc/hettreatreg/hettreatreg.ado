*! version 1.0.0  08nov2019  Tymon Sloczynski

program hettreatreg, eclass
	version 12.1
	syntax varlist(num fv) [if] [in], Outcome(varname) Treatment(varname) [NOIsily vce(str)]
	
	fvrevar `varlist'
	local varlist `r(varlist)'
	
	preserve
	drop `outcome'
	capture summarize `treatment'
	if _rc!=0 {
		display as error "outcome and treatment must not be the same"
		error 498
	}
	
	restore, preserve
	drop `varlist'
	capture summarize `outcome'
	if _rc!=0 {
		display as error "outcome must not appear on the list of control variables"
		error 498
	}
	
	capture summarize `treatment'
	if _rc!=0 {
		display as error "treatment must not appear on the list of control variables"
		error 498
	}
	
	restore
	
	tempvar touse
	tempname b V N r2 ols1
	
	if `"`vce'"'=="" local vce = "ols"
	
	quietly {
		`noisily' regress `outcome' `treatment' `varlist' `if' `in', vce(`vce')
		matrix `b' = e(b)
		matrix `V' = e(V)
		scalar `N' = e(N)
		scalar `r2' = e(r2)
		scalar `ols1' = _b[`treatment']
		generate `touse' = e(sample)
	}
	
	*hettreatreg only allows binary treatments
	capture tabulate `treatment' if `touse'==1
	if _rc!=0 | (_rc==0 & r(r)!=2) {
		display as error "treatment must be binary"
		error 450
	}
	
	*hettreatreg only allows treatments that take on values zero or one
	quietly summarize `treatment' if `touse'==1
	if r(min)!=0 | r(max)!=1 {
		display as error "treatment must only take on values zero or one"
		error 450
	}
	
	tempvar ps ot oc te
	tempname ols2 ate att atu v1 v0 p1 p0 w1 w0 delta
	
	quietly {
		regress `treatment' `varlist' if `touse'==1
		predict double `ps'
		
		regress `outcome' `ps' if `touse'==1 & `treatment'==1
		predict double `ot'
		regress `outcome' `ps' if `touse'==1 & `treatment'==0
		predict double `oc'
		generate double `te' = `ot'-`oc'
		
		summarize `te' if `touse'==1
		scalar `ate' = r(mean)
		summarize `te' if `touse'==1 & `treatment'==1
		scalar `att' = r(mean)
		summarize `te' if `touse'==1 & `treatment'==0
		scalar `atu' = r(mean)
		
		summarize `ps' if `touse'==1 & `treatment'==1
		scalar `v1' = r(Var)*((r(N)-1)/r(N))
		summarize `ps' if `touse'==1 & `treatment'==0
		scalar `v0' = r(Var)*((r(N)-1)/r(N))
		
		summarize `treatment' if `touse'==1
		scalar `p1' = r(mean)
		scalar `p0' = 1-r(mean)
		
		scalar `w1' = (`p0'*`v0')/(`p0'*`v0'+`p1'*`v1')
		scalar `w0' = (`p1'*`v1')/(`p0'*`v0'+`p1'*`v1')
		scalar `delta' = `p1'-`w1'
		
		scalar `ols2' = `w1'*`att'+`w0'*`atu'
	}
	
	display ""
	display as text `""OLS" is the estimated regression coefficient on `treatment'."'
	display ""
	display as text "   OLS  =  " as result %-9.4g `ols1'
	display ""
	display as text "P(d=1)  =  " as result round(`p1',.001)
	display as text "P(d=0)  =  " as result round(`p0',.001)
	display ""
	display as text "    w1  =  " as result round(`w1',.001)
	display as text "    w0  =  " as result round(`w0',.001)
	display as text " delta  =  " as result round(`delta',.001)
	display ""
	display as text "   ATE  =  " as result %-9.4g `ate'
	display as text "   ATT  =  " as result %-9.4g `att'
	display as text "   ATU  =  " as result %-9.4g `atu'
	display ""
	display as text "OLS = w1*ATT + w0*ATU = " as result %-9.4g `ols2'
	
	ereturn post `b' `V', esample(`touse')
	
	ereturn scalar N = `N'
	ereturn scalar r2 = `r2'
	ereturn scalar ols1 = `ols1'
	ereturn scalar ols2 = `ols2'
	ereturn scalar ate = `ate'
	ereturn scalar att = `att'
	ereturn scalar atu = `atu'
	ereturn scalar p1 = `p1'
	ereturn scalar p0 = `p0'
	ereturn scalar w1 = `w1'
	ereturn scalar w0 = `w0'
	ereturn scalar delta = `delta'
	
	ereturn local depvar `"`outcome'"'
	ereturn local cmdline `"hettreatreg `0'"'
	ereturn local cmd "hettreatreg"
end
