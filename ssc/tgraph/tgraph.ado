*! version 2.0.0 PR 07Oct2000.
program define tgraph
version 6
syntax varlist(min=1) [if] [in] [aw fw pw iw], /*
 */ [ XTrans(string) YTrans(string) XLAbel(numlist) YLAbel(numlist) * ]
if "`xtrans'"=="" & "`ytrans'"=="" {
	di in red "at least one of xtrans() or ytrans() required"
	exit 198
}
if "`xtrans'"!="" & "`xlabel'"=="" {
	di in red "xlabel required with xtrans"
	exit 198
}
if "`ytrans'"!="" & "`ylabel'"=="" {
	di in red "ylabel required with ytrans"
	exit 198
}
if "`weight'"!="" { local wgt "[`weight'`exp']" }

* Determine min and max of the yvars
local nvar: word count `varlist'
local min .
local max .
tokenize `varlist'
local i 1
while `i'<`nvar' {
	if "`ytrans'"!="" {
		local oldy`i' `1'
		tempvar y`i'
		qui sum `1' `if' `in'
		if r(N)==0 {
			noi di in red "no observations"
			exit 2000
		}
		if `min'==. 	{ local min=r(min) }
		else		  local min=min(`min',r(min))
		if `max'==. 	{ local max=r(max) }
		else		  local max=max(`max',r(max))
		local yvars "`yvars' `y`i''"
	}
	else {
		local yvars "`yvars' `1'"
	}
	local i=`i'+1
	mac shift
}
local xvar `*'

* Transform yvars
qui if "`ytrans'"!="" {
	tempname tmpylab
	local i 1
	while `i'<`nvar' {
		axiscale `y`i''=`oldy`i'' `if' `in', min(`min') max(`max') /*
		 */ label(`ylabel') function(`ytrans') valuelab(`tmpylab')
		local i=`i'+1
	}
	local ylabel `s(varlab)'
}

* Transform xvar
qui if "`xtrans'"!="" {
	tempname tmpxlab
	tempvar x
	axiscale `x'=`xvar' `if' `in', /*
	 */ label(`xlabel') function(`xtrans') valuelab(`tmpxlab')
	local xlabel `s(varlab)'
}
else {
	local x `xvar'
}
if "`xlabel'"!="" { local xl "xlabel(`xlabel')" }
if "`ylabel'"!="" { local yl "ylabel(`ylabel')" }
graph `yvars' `x' `if' `in' `wgt', `xl' `yl' `options'
end

*! version 2.0.0 PR 07Oct2000.
program define axiscale, sclass
version 6
syntax newvarname =/exp [if] [in], Function(string) Labels(numlist) /*
 */ [ MIN(string) MAX(string) Valuelab(string) ]
tempvar x labs newlabs new
if "`min'"!="" { conf num `min' }
else local min .
if "`max'"!="" { conf num `max' }
else local max .
if "`valuela'"=="" { local valuela _LAB }

* Find min and max of oldvar
quietly {
	gen `x'=`exp' `if' `in'
	sum `x'
/*
	Fuzzy compare for `min'>actual minimum of `x'
	or `max'<actual maximum of `x'.
*/
	tempname delta
	scalar `delta'=1e-7
	if `min'==. {
		local min=r(min)
	}
	else if `min'>r(min) & reldif(`min',r(min))>`delta' {
		noi di in red "invalid min(), `min' > min(`exp')"
		exit 198
	}
	if `max'==. {
		local max=r(max)
	}
	else if `max'<r(max) & reldif(`max',r(max))>`delta' {
		noi di in red "invalid max(), `max' < max(`exp')"
		exit 198
	}

* Convert labels to a var, including min and max
	gen `labs'=.
	tokenize `labels' `min' `max'
	local nlab 0
	while "`1'"!="" {
		local nlab=`nlab'+1
		local lab`nlab' `1'	/* store label as string */
		replace `labs'=`1' in `nlab'
		mac shift
	}

* Update min and max for consistency with labels
	sum `labs'
	if `min'>r(min) & reldif(`min',r(min))>`delta' {
		local nlab1=`nlab'-1
		local min=r(min)
		replace `labs'=`min' in `nlab1'
	}
	if `max'<r(max) & reldif(`max',r(max))>`delta' {
		local max=r(max)
		replace `labs'=`max' in `nlab'
	}

* Transform labels
	parse "`functio'", parse("@")
	local f
	while "`1'"!="" {
		if "`1'"=="@" { local 1 `labs' }
		local f "`f'`1'"
		mac shift
	}
	cap replace `labs'=`f'
	local rc=_rc
	if `rc' { noisily error `rc' }
	local tmin=`labs'[`nlab'-1]
	local tmax=`labs'[`nlab']
	if `tmin'==. {
		noi di in red "a low value of `exp'could not be transformed"
		exit 198
	}
	if `tmax'==. {
		noi di in red "a high value of `exp'could not be transformed"
		exit 198
	}
	if `tmin'>`tmax' & reldif(`tmin',`tmax')>`delta' {
		local temp `tmin'
		local tmin `tmax'
		local tmax `temp'
	}
	
* Transform oldvar

	parse "`functio'", parse("@")
	local f
	while "`1'"!="" {
		if "`1'"=="@" { local 1 `x' }
		local f "`f'`1'"
		mac shift
	}
	cap replace `x'=`f'
	local rc=_rc
	if `rc' { noisily error `rc' }

* Transform transformed oldvar to integer scale

	gen int `new'=.
	rescale `new' `x' `tmin' `tmax'	/* tmin->0, tmax->1000 */

* Do same to labels

	gen int `newlabs'=.
	rescale `newlabs' `labs' `tmin' `tmax'

* Convert newlabs to string

	local xxl	/* string of new labels */
	cap lab drop `valuela'
	local i 0
	while `i'<`nlab'-2 {
		local i=`i'+1
		local xx=`newlabs'[`i']
		if `xx'!=. {
			if "`xxl'"=="" { local xxl `xx' }
			else local xxl "`xxl',`xx'"
			lab def `valuela' `xx' "`lab`i''",add
		}
	}
	rename `new' `varlist'
	lab values `varlist' `valuela'
	lab var `varlist' "`exp', transformed scale"
}
describe `varlist'
sreturn local varlab `xxl'
end

program define rescale /* newintvar oldtsfvar tsfmin tsfmax */
replace `1'=int(10000*(`2'-`3')/(`4'-`3')+.5)
end
