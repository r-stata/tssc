*! version 1.0.5 PR/GA 18feb2005.
program define frac_spl, rclass	/* generate spline basis functions */
version 6
gettoken v 0 : 0, parse(" ,")
unab v : `v', max(1)
local done 0
gettoken nxt : 0, parse(" ,")
while ("`nxt'" != "" & "`nxt'" != ",") & !`done' {
	cap confirm number `nxt'
	if !_rc {
		local knots "`knots' `nxt'"
		gettoken nxt 0 : 0, parse(" ,")
		gettoken nxt   : 0, parse(" ,")
	}
	else 	local done 1
}
if "`knots'"=="" {
	local options "DF(int 0) UNIQUE"
}
syntax [if] [in] [, `options' all Orthog Q(string) Name(string) Basis(string) /*
 */ DEGree(int 3) BKnots(string) ]
if "`bknots'"!="" {
	local bk: word count `bknots'
	if `bk'!=2 {
		di in red "invalid bknots(), must specify 2 boundary knots"
		exit 198
	}
}
if "`basis'"!="" {
	local name `basis'
}
if "`name'"!="" {
	if length("`name'")>6 {
		di in red "name() must be at most 6 characters"
		exit 198
	}
}
else local name=substr("`v'",1,6)
if `degree'>3 | `degree'<0 | `degree'==2 {
	di in red "degree must be either 0, 1, or 3."
	exit 198
}
if `degree'==0 {
	local lt "<" /* allows knots at min for deg 0 */
}
else local lt "<="
* All is same as in fracgen, to generate basis functions for all obs but knots in generatation sample
if "`all'" == "" { 
	local all `"`if' `in'"'
}
else	local all
marksample touse
markout `touse' `v'
tempvar x
quietly {
	gen double `x' = `v' `all'
	gsort -`touse' `x'
	if "`unique'"!="" {
		tempvar xold
		gen double `xold'=`x'
		bysort `x': replace `x'=. if _n!=1
		sort `x'
		count if `touse' & !missing(`x')
		local nobs=r(N)
	}
	else {
		count if `touse'
		local nobs=r(N)
	}
/*
	Generate interior knots
*/
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
	local klast `kN'
	if "`knots'"=="" {
		if `df'==0 { local nk = (`degree'==0)+int((`nobs')^.25) }
		else local nk=`df'-(`degree'!=0)
		if `nk'!=1 { local s s }
		noi di in blue "[`nk' knot`s' to be used]"
		local j `nk' 
		while `j' > 0 {
			local k`j'=`x'[int((`j'*`nobs'/(`nk'+1))+.5)]
			if `k`j''==`klast'|`k`j''`lt'`k0' {
				noisily di in bl "[knot at `k`j'' ignored]"
				local i `j'
				while `i'<`nk' {
					local i2=`i'+1
					local k`i' `k`i2''
					local i=`i'+1
				}
				local nk=`nk'-1
			}
			else {
				local knots "`k`j'' `knots'"
				local klast `k`j''
			}
			local j = `j' -1
		}
		if "`unique'"!="" { replace `x'=`xold' }
	}
	else {
		tokenize `knots'
		local nk 0
		while "`1'"!="" {
			if `1'`lt'`k0' | `1'>=`kN' {
				noi di in bl "[knot at `1' ignored]"
			}
			else {
				local nk = `nk' + 1
				local k`nk' `1' 
			}
			mac shift
		}
		if `nk'!=1 { local s s }
		noi di in blue "[`nk' knot`s' to be used]"
	}
/*
	Create basis variables
*/
	local j `nk'
	while `j' > 0 {
		local vn `name'
		if `j'<10 { local vn "`vn'_" }
		cap drop `vn'`j'
		if "`orthog'"=="" {
			local n `vn'`j'
		}
		else {
			tempvar cov`j'
			local n `cov`j''
		}
		if `degree'==0 {
			* care needed for missing x
			gen byte `n'=(`x'>`k`j'') if !missing(`x')
			frac_mdp 3 `k`j''
			local low: word 1 of `r(mdp)'
			lab var `n' "`v'>`low'"
		}
		else if `degree'==1 {
			* is correct for missing x
			gen double `n'=(`x'>`k`j'')*(`x'-`k`j'')
		}
		else if `degree'==3 {
			* now using lambda notation of Royston & Parmar (2001)
			local lambdaj=(`kN'-`k`j'')/(`kN'-`k0')
			gen double `n'=(`x'>`k`j'')*(`x'-`k`j'')^3 /*
			 */ -`lambdaj'*(`x'>`k0')*(`x'-`k0')^3 /*
			 */ -(1-`lambdaj')*(`x'>`kN')*(`x'-`kN')^3
		}
		local covars "`n' `covars'"
		local j = `j' -1
	}
	if "`orthog'"=="" & `degree'!= 0 {
		if "`v'"!="`name'" {
			cap gen double `name'_0=`x'
			if _rc {
				drop `name'_0
				gen double `name'_0=`x'
			}
			local covars "`name'_0 `covars'"
		}
		else {
			local covars "`name' `covars'"
		}
	}
	else if "`orthog'"!="" {
		local nk1=`nk'+(`degree'!=0)
		local vn `name'
		if `nk1'<10 { local vn "`vn'_" }	
		if `degree'!=0 { 
			cap drop `vn'`nk1'
			local xvar `x'
		}
/*
	If the matrix Q is fed in thru q() option, we use its inverse to 
	compute the transformed (orthogonalised) basis functions.
	Otherwise, compute them from scratch using orthog.ado.
*/
		tempname Q
		if "`q'"!="" {
/*
	Convert to orthogonalised basis fns via inverse of Q matrix
*/
			tempname Qinv
			matrix `Q'=`q'
			matrix `Qinv'=inv(`Q')
			* j indexes knots, basis fns (1, 2, ... );
			* 0 is the linear term lnt - not orthogonalised
			local nk2=`nk1'+1
			forvalues j=1/`nk' {
				local j1=`j'+1				/* j1 indexes cols in the Qinv matrix */
				/* constant + term in ln(_t) */
				gen double `vn'`j1'=`Qinv'[`nk2', `j1']+`Qinv'[1, `j1']*`xvar'
				forvalues i=1/`j' {
					local n: word `i' of `covars'	/* covars don't include ln(_t) */
					local i1=`i'+1			/* i1 indexes rows in the Qinv matrix */
					replace `vn'`j1'=`vn'`j1'+`Qinv'[`i1', `j1']*`n'
				}
			}
		}
		else {
			orthog `xvar' `covars', gen(`vn'*) matrix(`Q')
			drop `vn'1	/* discard first orthog var, using original x */
		}
		if "`v'"!="`name'" {
			cap gen double `name'_0=`x'
			if _rc {
				drop `name'_0
				gen double `name'_0=`x'
			}
			local covars "`name'_0"
		}
		else {
			local covars "`v'"
		}
		forvalues j=2/`nk1' {
			local jm=`j'-1
			local vnew `vn'`jm'
			local vold `vn'`j'
			rename `vold' `vnew'
			local covars "`covars' `vnew'"
			lab var `vnew' "orthogonalized basis `jm'"
			cap drop `cov`jm''
/*
	label basis vectors with chars corresponding to knot positions
*/
			if `jm'>1 {
				cap char `vnew'[fp] `k`jm''
			}
			else cap char `name'[fp] "linear"	/* !! this may be incorrect */
		}
	}
}
global S_1 `covars'
global S_2 `nk'
global S_3 `knots'
return local names `covars'
return scalar nk=`nk'
return local knots `knots'
return local bknots `k0' `kN'
if "`orthog'"!="" {
	return matrix Q `Q'
}
end

program define frac_mdp, rclass
	* 1=decimal places, rest=numbers sep by spaces
	* Output in `r(mdp)'.
	args dp
	mac shift
	while "`1'"!="" {
		cap confirm num `1'
		if _rc { local ddp `ddp' `1' }
		else {
			if int(2*`1')==(2*`1') { 
				local ddp `ddp' `1' 	/* respect .5 */
			} 
			else {
				frac_ddp `1' `dp'
				local ddp `ddp' `r(ddp)'
			}
		}
		mac shift
	}
	return local mdp `ddp'
end

*! version 1.0.1 PR 25Feb1999.
program define frac_ddp, rclass
	version 6
	* 1=input number, 2=decimal places required.
	* Output in (string) r(ddp).
	* `1' and `2' allowed to be scalars.
	local n=`1'
	local dp=int(`2')
	if `dp'<0 | `dp'>20 {
		ret local ddp `n'
		exit
	}
	local z=int(abs(`n')*(10^`dp')+.5)
	if `z'>1e15 { /* can't cope with number this large --
			E notation messes it up */
		ret local ddp `n'
		exit
	}
	local lz=length("`z'")
	if `lz'<`dp' {
		local z=substr("00000000000000000000",1,`dp'-`lz')+"`z'"
	}
	if `dp'>0 { 
		local f=length("`z'")-`dp'
		ret local ddp=substr("`z'",1,`f')+"."+substr("`z'",`f'+1,`dp')
					/* add leading zero */
		if abs(`n')<1 { ret local ddp 0`return(ddp)' }	
	}
	else 	ret local ddp `z'
	if `n'<0 { ret local ddp -`return(ddp)' }

	* failsafe check
	cap confirm num `return(ddp)'
	if _rc { ret local ddp `n' }

end
