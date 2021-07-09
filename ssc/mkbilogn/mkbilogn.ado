*! mkbilogn.ado version 1.1.1 spj revised 27 Jan 98
*! Syntax: mkbilogn var1 var2, r(#) m1(#) s1(#) m2(#) s2(#)
*!			 [defaults #=0.5,0,1,0,1; respectively]

prog def mkbilogn
	version 5.0
	local varlist "req new min(2) max(2)"
	local options "Rho(real 0.5) m1(real 0) m2(real 0) s1(real 1) s2(real 1)"
	parse "`*'"
	if `rho' < -1 | `rho' >= 1 {
		di in red "Need rho s.t. -1 <= rho < 1"
		exit 198    /* need rho ~= 1 or Cholesky fails */ 
	}
	if `s1' <=0 | `s2' <= 0 {
		di in red "Std. dev. must be positive"
		exit 198
	}
	parse "`varlist'", parse(" ")

	di "Creating 2 r.v.s X1 X2  s.t. x1=log(X1), x2=log(X2) are bivariate" 
	di " Normal with mean(x1) = `m1' ; mean(x2) = `m2' ; s.d.(x1) = `s1' ;"
	di " s.d.(x2) = `s2' ; corr(x1,x2) = `rho' "

	/* Method of creation based on Stata FAQ at
	 	http://www.stata.com/support/faqs/stat/mvnorm.html */

	tempname a1 a2 A P var1 var2 c1 c2 lnc1 lnc2

	matrix `P' = (1,`rho'\ `rho',1)
	matrix `A' = cholesky(`P')
	matrix colnames `A' = `lnc1' `lnc2'

	quietly {

	ge `c1' = exp(invnorm(uniform()))
	ge `c2' = exp(invnorm(uniform()))

	ge `lnc1' = ln(`c1')
	ge `lnc2' = ln(`c2')

	matrix `a1' = `A'[1,.]
	matrix score `var1' = `a1'
	matrix `a2' = `A'[2,.]
	matrix score `var2' = `a2'

	replace  `1' = exp(`s1'*`var1' + `m1')
	replace  `2' = exp(`s2'*`var2' + `m2')

	}
end

/*

Note:

mean,variances,corr refer to mean,variances,corr
of the log of the vbles.

Mean of lognormal distribution: exp[mu + (sig_sq/2)]
Variance of lognormal distribution:
	[exp(2*mu)]*[exp(2*sig_sq) - exp(sig_sq)]

*/
