*! fwer1stage v0.02
cap program drop fwer1stage
cap mata: mata drop mvnpb()

program def fwer1stage, rclass
version 10

/*
	Calculate FWER for multi-arm 1-stage trials algebraically
	
	v0.02 - can specify 1 alpha for each arm or a common alpha
*/

syntax, arms(int) alpha(string) aratio(real)

local K = `arms'-1		// # E arms
local A = `aratio'

local nopts: word count `alpha'
if `nopts'!=1 & `nopts'!=`K' {
	di as err "1 or `K' options should be specified for alpha"
	exit 198
}	


forvalues k = 1/`K' {
	if `nopts'==1 local z`k' = invnormal(1-`alpha')
	else {
		local a`k': word `k' of `alpha'
		local z`k' = invnormal(1-`a`k'')
	}
}

	
// Correlation matrix
local r = `A'/(`A'+1)

tempname R
matrix def `R' = I(`K')
forvalues k = 1/`K' {
	forvalues l = 1/`K' {
		if `k'!=`l' matrix def `R'[`k',`l'] = `r'
		else matrix def `R'[`k',`l'] = 1
	}
}


// Vector of z values
local z1ma `z1'
forvalues k = 2/`K' {
	local z1ma `z1ma', `z`k''
}

tempname Z
matrix `Z' = (`z1ma')

local rep = 5000
mata: mvnpb("`Z'", "`R'", `rep')
local fwer = 1-r(p)
return scalar fwer = `fwer'

di as text "FWER = " as res %5.4f `fwer'

end

mata:
mata clear
void mvnpb(string scalar xx, string scalar vv, real scalar reps)
{
/*
	Assumes Hammersley sequences are to be generated, without antithetics.
*/
	real vector opt
	x = st_matrix(xx)	// row or col vector of args at which probability is required
	V = st_matrix(vv)	// variance-covariance matrix
	opt = (2, reps, 1, 0)	// 2 for Hammersley
	p = ghk( x, V, opt, rank=.)
	st_numscalar("r(p)", p)
}
end
