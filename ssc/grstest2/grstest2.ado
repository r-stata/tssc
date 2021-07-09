
capture program drop grstest2
program define grstest2, rclass 
	version 12
	syntax varlist [if] , flist(string) [alphas nqui]
	local a: word count `varlist'
	local b: word count `flist'
	local c = "`varlist'"
	local d = "`flist'"
	
	local i=1
	foreach var of varlist `c' {
		if ("`nqui'"!="") {
			reg `var' `flist'
		}
		qui reg `var' `flist'
		qui predict Res`var', res
		qui predict ER`i'
		qui replace ER`i'=ER`i'-_b[_cons]
		qui sum ER`i'
		local ERM`i'=r(mean)
		drop ER`i'
		
		matrix R2`i'=0
		matrix R2`i'[1,1]=e(r2_a) 
		matrix A`i'=0
		matrix A`i'[1,1]=_b[_cons]
		matrix SE`i'=0
		matrix SE`i'[1,1]=_se[_cons]
		qui sum `var'
		local mean`i'=r(mean)
		local ++i
	}
	
	

	qui mat accum RR  =  Res*, dev noconstant
	mat S =RR/(e(N)-1)
	drop Res*
	mat drop RR
	
	matrix A=A1
	matrix R2=R21
	matrix SE=SE1
	local i=2
	while `i'<=`a' {
		matrix A=A\A`i'
		matrix R2=R2\R2`i'
		matrix SE=SE\SE`i'
		local ++i
	}
	
	
	
	local i=1
	foreach var of varlist `d' {
		qui sum `var'
		matrix M`i'=0
		matrix M`i'[1,1]=r(mean)
		local ++i
	}
	matrix M=M1
	local i=2
	if (`b'>1) {
		while `i'<=`b' {
			matrix M=M\M`i'
			local ++i
		}
	}
		
	local sum = 0
	local sum1 = 0
	local sum2 = 0
	local sum3 = 0
	forvalues i = 1/ `a' {
		local sum = `sum' + A[`i',1]
		local sum1 = `sum1' + R2[`i',1]
		local sum2 = `sum2' + SE[`i',1]
		local sum3 = `sum3' + abs(A[`i',1])
	}
	
	local meanalpha = `sum' / `a'	
	local meanadjR2 = `sum1' / `a'
	local meanSE = `sum2' / `a'
	local meanabsalpha = `sum3' / `a'
	
	matrix R = (0,0,0,0,0,0,0) \ (0,0,0,0,0,0,0)
	matrix rownames R = "J0" "J1" 
	matrix colnames R = "Mean alpha" "Test statistic" "P-value" "Mean adj R2" "Mean SE" "Mean abs alpha" "SR"
	matrix R[1,1] = `meanalpha'
	matrix R[2,1] = `meanalpha'
	matrix R[1,4] = `meanadjR2'
	matrix R[2,4] = `meanadjR2'
	matrix R[1,5] = `meanSE'
	matrix R[2,5] = `meanSE'
	matrix R[1,6] = `meanabsalpha'
	matrix R[2,6] = `meanabsalpha'
	
	qui correlate `d', covariance 
	matrix F=r(C)

	*--- Wald test (J0) ----*
	matrix T=(1+ M' * invsym(F) * M)
	matrix H=1/T[1,1]
	matrix R[1,2] =  e(N)* H * A' * invsym(S) * A 
	matrix R[1,3] = 1- chi2(`a',R[1,2])
		
	*--- F-test (J1) ----*
	matrix R[2,2] =  ((e(N)-`a'-`b')/`a')*H * A' * invsym(S) * A
	matrix R[2,3] = 1- F(`a',e(N)-`a'-`b',R[2,2])
	mat Y=0
	matrix Y[1,1] = ((A' * invsym(S)* A))
	mat R[2,7]=sqrt(Y[1,1])
		
	matrix list R
	
	if ("`alphas'"!="") {
		matrix list A
	}
end
