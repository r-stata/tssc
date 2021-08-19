program define mybspline

* x = variate
* degree = degree of polynomial
* knotvector = name of stata rowvector containing internal knot values
* deriv: if this argument contains "deriv" then the code returns derivatives
* of the spline functions
args x degree knotvector stem deriv
tempname ts
tempvar bstem
if "`deriv'"!="" tempvar dstem
*number of internal knots:
local N = colsof(`knotvector')
local n = `degree'

* construct augmented knots
matrix `ts' = J(1,`n'+1,0),`knotvector',J(1,`n'+1,1)
local numterms=`N'+`n'
forvalues i = 0/`numterms' {
	makemybspline `i' `n' `ts' `bstem' `x' `deriv' `dstem'
	if "`deriv'"=="" rename `bstem'`i'`n' `stem'`i'
	else rename `dstem'`i'`n' `stem'`i'
	
}

end

program define makemybspline,rclass
args i jp1 ts bstem x deriv dstem
tempname alpha
if "`deriv'"!="" tempname alphap
* have to remember to up index for ts by one!

if `jp1'==0 {
	gen byte `bstem'`i'`jp1'=(`ts'[1,`i'+1]<=`x' & `x'<`ts'[1,`i'+1+1])
	if "`deriv'"!="" gen byte `dstem'`i'`jp1'=0
}
else {
	local j = `jp1'-1
	local ip1=`i'+1
	makemybspline `i' `j' `ts' `bstem' `x' `deriv' `dstem'
	makemybspline `ip1' `j' `ts' `bstem' `x' `deriv' `dstem'
	makealpha `i' `jp1' `ts' `alpha' `x' `deriv' `alphap'
	makealpha `ip1' `jp1' `ts' `alpha' `x' `deriv' `alphap'
	gen `bstem'`i'`jp1' = `alpha'`i'`jp1'*`bstem'`i'`j'+(1-`alpha'`ip1'`jp1')*`bstem'`ip1'`j'
	if "`deriv'"!="" {
		gen `dstem'`i'`jp1' = `alphap'`i'`jp1'*`bstem'`i'`j'+`alpha'`i'`jp1'*`dstem'`i'`j' ///
					-`alphap'`ip1'`jp1'*`bstem'`ip1'`j'+(1-`alpha'`ip1'`jp1')*`dstem'`ip1'`j'
		drop `alphap'`i'`jp1' `dstem'`i'`j' `alphap'`ip1'`jp1' `dstem'`ip1'`j'
	}
	drop `alpha'`i'`jp1' `bstem'`i'`j' `alpha'`ip1'`jp1' `bstem'`ip1'`j'
}

end

program define makealpha
* remember to up index for ts by one!
args i j ts stem x deriv dstem
if `ts'[1,`i'+`j'+1]==`ts'[1,`i'+1] {
	gen `stem'`i'`j'=0
	if "`deriv'"!="" gen `dstem'`i'`j'=0
}
else {
	gen `stem'`i'`j'=(`x'-`ts'[1,`i'+1])/(`ts'[1,`i'+`j'+1]-`ts'[1,`i'+1])
	if "`deriv'"!="" gen `dstem'`i'`j'=1/(`ts'[1,`i'+`j'+1]-`ts'[1,`i'+1])
}
end
