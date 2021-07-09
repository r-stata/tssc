*! version 1.2.1 PR 01feb2008
program define fracdydx, rclass
	version 8
	local fp `e(fp_cmd2)'
	syntax [varlist(default=none max=1)] [ , Gen(str) GENSe(string) Powers(string) Coeffs(string) Deriv(int 1) ]
	if `deriv'<1 {
		di in red "invalid `deriv'"
		exit 198
	}
	tempvar x
	if "`fp'"=="fracpoly" {
		if "`e(fp_xpx)'"!="" {
			di in red "exponential transformation not supported"
			exit 198
		}
		if "`powers'`coeffs'"=="" {
			if "`varlist'"!="" {
				qui gen double `x'=`varlist' if e(sample)
			}
/*
			else qui gen double `x'=(`e(fp_x1)'+ /*
			 */ e(fp_shft))/e(fp_sfac) if e(sample)
*/
			else qui gen double `x'=(`e(fp_x1)'+e(fp_shft))/e(fp_sfac)
		}
		else local fp
	}
/*
	Store powers in macros and coefficients in locals
*/
	if "`fp'"!="fracpoly" {
		if "`varlist'"=="" {
			di in red "varname required"
			exit 198
		}
		if "`powers'"=="" {
			di in red "powers() required"
			exit 198
		}
		if "`coeffs'"=="" {
			di in red "coeffs() required"
			exit 198
		}
		cap local np=colsof(`powers')
		local rc=_rc
		if `rc' {
			// Treat as a numlist
			cap numlist "`powers'"
			if _rc {
				noi di as err `"invalid powers(`powers')"'
				exit 198
			}
			local powers `r(numlist)'
			local np: word count `powers'
		}
		forvalues i=1/`np' {
			if `rc' {
				local p`i': word `i' of `powers'
			}
			else local p`i'=`powers'[1,`i']
		}
		cap local r=colsof(`coeffs')
		local rc=_rc
		if `rc' {
			local r: word count `coeffs'
		}
		if `r'!=`np' {
			di in red "numbers of powers and coefficients differ"
			exit 198
		}
		forvalues i=1/`np' {
			if `rc' {
				local b`i': word `i' of `coeffs'
			}
			else local b`i'=`coeffs'[1,`i'] 
		}
		qui gen double `x'=`varlist'
	}
	else {
		local pwrs `e(fp_k1)'
		local np: word count `pwrs'
		forvalues i=1/`np' {
			local p`i': word `i' of `pwrs'
			local X`i': word `i' of `e(fp_xp)'
			local b`i'=_b[`X`i'']
		}
	}
	tempname small
	scalar `small'=1e-6
/*
	Compute powers and coefficients for (successive) derivative(s)
*/
	local m `np'
	local np0 `np'
	forvalues d=1/`deriv' {
		local i=`np'+1
		local p`i' .
		local c0 0
		local j1 0
		local j 1
		local pi .
		while `j'<=`np' {
			local pj `p`j''
			local jplus1=`j'+1
			local isrepeat=(abs(`p`jplus1''-`pj')<`small')	/* next power is repeated power */
			local islog=(abs(`pj')<`small')			/* this power is log */
			if abs(`pj'-`pi')>`small' {			/* pj is new power (not a repeated power) */
				local j0 `j'
			}
			if `islog' {
				local k=`j'-`j0'+1			/* deals with repeated powers of 0 */
			}
			else local k `pj'				/* power term */
			local c=`k'*`b`j''
			if `isrepeat' & !`islog' {			/* repeated power not of 0 */
				local c=`c'+(`j'-`j0'+1)*`b`jplus1''
			}
			if abs(`pj'-1)>`small'{
				local jj1=`j'-`j1'
				local c`jj1' `c'
				local p`jj1'=`pj'-1
			}
			else {
				if `j'==`j0' {
					local c0 `c'
					local m=`m'-1
					local j1 1
				}
				else {
					local jm1=`j'-1
					local c`jm1' `c'
					local p`jm1' 0
				}
			}
			local pi `pj'
			local j `jplus1'
		}
		forvalues j=1/`m' {
			local b`j' `c`j''
		}
		local np `m'
	}
/*
	Calc derivative
*/
	quietly {
		if "`gen'"!="" {
			tempvar new
			qui gen double `new'=`c0' if `x'!=.
		}
		tempname s4
		if `np'>0 {
/*
	Generate fractional powers.
*/
			tempvar lnx
			gen double `lnx'=log(`x')
			matrix `s4'=J(1,`np',0)
			local s2 `p1'
			local plast 0
			local hlast 1
			forvalues i=1/`np' {
				tempvar h`i'
				local pi `p`i''
				if abs(`pi'-`plast')>`small' {
					if abs(`pi')<`small' {
						gen double `h`i''=`lnx'
					}
					else if abs(`pi'-1)<`small' {
						gen double `h`i''=`x'
					}
					else gen double `h`i''= cond(`x'==0,0,`x'^`pi')
				}
				else {
					gen double `h`i''=`lnx'*`hlast'
				}
				local hlast `h`i''
				local plast `pi'
				if "`gen'"!="" {
					replace `new'=`new'+`c`i''*`h`i''
				}
				matrix `s4'[1,`i']=`c`i''
				if `i'>1 {
					local s2 `s2' `pi'
				}
			}
		}
	}
	if `np'<`np0' {
		local s2 `s2' .
	}
	if "`gen'"!="" {
		if "`varlist'"=="" {
			qui replace `new'=`new'/(e(fp_sfac)^`deriv')
		}
		cap drop `gen'
		rename `new' `gen'
		lab var `gen' "Derivative `deriv'"
	}

	if "`gense'"!="" & "`varlist'"=="" {
		// Calc SE of derivative
		tempname B VCE tmp
		local sfac = e(fp_sfac)
		matrix `B' = e(b)
		matrix `B' = `B'[1, "`X1'".."`X`np''"]	// submatrix for X's only
		matrix `VCE' = e(V)
		matrix `VCE' = `VCE'["`X1'".."`X`np''", "`X1'".."`X`np''"]	// submatrix for X's only
		// Replace x's temporarily with termise derivatives
		forvalues j=1/`np' {
			tempvar temp`j'
			rename `X`j'' `temp`j''
			qui gen double `X`j'' = `c`j''*`h`j''/_b[`X`j'']	// gives termwise derivative
		}
		_estimate hold `tmp'
		ereturn post `B' `VCE'
		cap drop `gense'
		_predict `gense' if !missing(`x'), stdp
		replace `gense' = `gense'/(`sfac'^`deriv')
		lab var `gense' "SE(derivative `deriv')"
		_estimate unhold `tmp'
		forvalues j=1/`np' {
			drop `X`j''
			rename `temp`j'' `X`j''
		}
	}
	return local powers `s2'
	return matrix coeffs `s4'
end
