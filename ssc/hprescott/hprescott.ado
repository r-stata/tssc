*! hprescott 1.0.7 CFBaum  01aug2006
*  from hprescott(8).ado 1.0.4  18jun2006
* 1.0.0: from http://ideas.repec.org/c/dge/qmrbcd/3.html
* 1.0.1: corrections to match FORTRAN output
* 1.0.2: add stub option for multiple variables
* 1.0.3: make byable(recall), new variable generation for subgroups
* 1.0.4: return smoothed variables as well as filtered variables
* 1.0.5: hprescott Mata version
* 1.0.6: corr for tsrevar
* 1.0.7: smooth should accept reals

program hprescott, rclass byable(recall,noheader)
	version 9.2
	
syntax varlist(ts) [if] [in], STUB(string) [Smooth(real 0)] 
 
    marksample touse
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
		gen double `stub'_`v'_sm_`suf' = .
		local varlist3 "`varlist3' `stub'_`v'_`suf'"
		local varlist4 "`varlist4' `stub'_`v'_sm_`suf'"
	}
* create temp vars for any ts operators in the varlist
* pass the resulting varlist1 to Mata fn
	tsrevar `varlist'
	local varlist1 `r(varlist)'
	
* determine default smooth value from data frequency, if reported
	qui tsset
	local tu `r(unit1)'
	if `smooth' <= 0 {
* Quarterly
		if "`tu'" == "q" {
			local smooth 1600
		}
* Annual
		else if "`tu'" == "y" {
			local smooth 6.25
		}
* Monthly
		else if "`tu'" == "m" {
			local smooth 129600
		}
* Other frequency or undefined
		else {
			local smooth 1600
			di _n "Warning: default smooth = 1600 used" _n
		}
	}

	mata: hprescott("`varlist1'","`varlist3'","`varlist4'","`touse'",`smooth')

    return local rawvars "`varlist'"
	return local filtvars "`varlist3'"
	return local trendvars "`varlist4'"
	return local smooth "`smooth'"	
	end
	
mata:
// from Pawel Kowal's HP function for MATLAB
void hprescott(string scalar vname, ///
               string scalar vname3, ///
               string scalar vname4, ///
               string scalar touse, 
               real scalar smooth)
{

	real scalar i, T, lambda
	real matrix X, I, LT, Q, SIGMA_R, SIGMA_Q, g, A, b, Y, Z
	string rowvector vars, vars3, vars4
	string scalar v, v3, v4
		
// access the Stata variables in varlist, varlist3, varlist4, honoring touse
	vars = tokens(vname)
	v = vars[|1,.|]
	st_view(X,.,v,touse)
	vars3 = tokens(vname3)
	v3 = vars3[|1,.|]
// Y contains cyclical components to be extracted from X (residuals from smoothing)
	st_view(Y,.,v3,touse)
	vars4 = tokens(vname4)
	v4 = vars4[|1,.|]
// Z contains the smoothed series 
	st_view(Z,.,v4,touse)
	T = rows(X)
	I = I(T)
	LT = J(T,T,0)
	for (i=2; i<=T; i++){
		LT[i,i-1] = 1.0
	}
	LT = (I - LT)*(I - LT)
	Q = (LT[(3::T),.])'
	SIGMA_R = Q' * Q
	SIGMA_T = I(T-2)
	lambda = smooth
	g = Q' * X
	A = (SIGMA_T + lambda * SIGMA_R)
	b = cholsolve( A, g )
	Y[.,.] = lambda * Q * b	
	Z[.,.] = X - Y

}
end
