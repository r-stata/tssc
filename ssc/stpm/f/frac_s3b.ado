*! version 1.0.3 PR 13oct2003.
program define frac_s3b, rclass
* calc derivatives of basis functions for restricted cubic splines.
* Gives orthogonalised basis functions if option q() is specified.
* Based on version 1.0.2 of frac_s3b, and frac_s3d.
version 7
syntax varlist(max=1), K(string) [ BKnots(string) Name(string) Q(string) Second ]
local x `varlist'
if "`bknots'"!="" {
	local bk: word count `bknots'
	if `bk'!=2 {
		di in red "invalid bknots(), must specify 2 boundary knots"
		exit 198
	}
}
if "`name'"!="" {
	if length("`name'")>6 {
		di in red "name() must be at most 6 characters"
		exit 198
	}
}
else local name=substr("`x'",1,6)
local nk: word count `k'
quietly {
/*
	Generate interior knots
*/
	count if `x'!=.
	local nobs=r(N)
	sort `x'
	if "`bknots'"!="" {
		local k0: word 1 of `bknots'
		confirm num `k0'
		local kN: word 2 of `bknots'
		confirm num `kN'
	}
	else {
		local k0=`x'[1] 
		local kN=`x'[`nobs']
	}
/*
	Calc derivative of each basis function
*/
	local names
	local j `nk'
	while `j' > 0 {
		local j1=`j'+1
		local kj: word `j' of `k'
		* lambda notation of Royston & Parmar (2002)
		local lambdaj=(`kN'-`kj')/(`kN'-`k0')
		cap drop `name'`j'
		if "`second'"=="" {	/* first derivative */
			gen double `name'`j'=3*(`x'>`kj')*(`x'-`kj')^2 /*
			 */ -3*`lambdaj'*(`x'>`k0')*(`x'-`k0')^2 /*
			 */ -3*(1-`lambdaj')*(`x'>`kN')*(`x'-`kN')^2
		}
		else {			/* second derivative */
			gen double `name'`j'=6*(`x'>`kj')*(`x'-`kj') /*
			 */ -6*`lambdaj'*(`x'>`k0')*(`x'-`k0') /*
			 */ -6*(1-`lambdaj')*(`x'>`kN')*(`x'-`kN')
			lab var `name'`j' "deriv of basis function for knot `kj'"
		}
		local names `name'`j' `names' 
		local j=`j'-1
	}

	if "`q'"!="" {
/*
	Convert to orthogonalised basis via inverse of Q matrix
	!! second derivs are shifted by a constant cf. correct values - unimportant bug not corrected
*/
		tempname Qinv
		matrix `Qinv'=inv(`q')
		* j indexes knots, basis fns (1, 2, ... );
		* 0 is the linear term lnt - not orthogonalised
		forvalues j=1/`nk' {
			tempvar sum`j'
			local j1=`j'+1				/* j1 indexes cols in the Qinv matrix */
			gen double `sum`j''=`Qinv'[1, `j1']	/* for the linear term in ln(_t) */
			forvalues i=1/`j' {
				local i1=`i'+1			/* i1 indexes rows in the Qinv matrix */
				replace `sum`j''=`sum`j''+`Qinv'[`i1', `j1']*`name'`i'
			}
		}
		forvalues j=1/`nk' {
			replace `name'`j'=`sum`j''
			local kj: word `j' of `k'
			lab var `name'`j' "deriv of orthogonalised basis function for knot `kj'"
		}
	}
}
return local names `names'
end
exit

Example:

. mat Qinv=inv(Q)
. mat list Qinv

Qinv[4,4]
               r0          r1          r2       _cons
   z0   1.1917998   2.5496751  -1.9985308           0
   z1           0   .51212157  -5.6359568           0
   z2           0           0   7.1723579           0
_cons  -8.0805192  -13.158682   8.4948663           1

Note that unused, zero'th orthog basis function r0=1.1917998*z0-8.0805192 where z0=ln(_t)

/*
	First deriv of first and second orthog basis functions
	from derivs of untransformed basis functions
*/
. gen deriv1=2.5496751+I__c1*.51212157
. gen deriv2=-1.9985308+I__c1*(-5.6359568)+I__c2*7.1723579
