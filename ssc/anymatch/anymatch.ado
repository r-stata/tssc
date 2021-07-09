*! anymatch 1.0.0 13Sep2009 roywada@hotmail.com
*! distance matching based on any metric

prog define anymatch, sortpreserve

version 8.0

syntax [varlist(default=none)], id(string) [METric(string) dist(string) NEARest(string) SUFfix(string) /*
	*/ MAXimum(numlist max=1 >=0) MINimum(numlist max=1) count COUNT1(string) PREfix(string) NOIsily /*
	*/ DONor(string) RECipient(string)]

qui {

if "`noisily'"=="noisily" {
	local noi noi
}
if "`dist'"=="" {
	local dist "dist"
}
if "`suffix'"=="" {
	local _near ""
}
if "`prefix'"=="" {
	local pre "_"
}
if "`maximum'"=="" {
	local maximum .
}
if "`minimum'"=="" {
	local minimum -1
}
if `maximum'<`minimum' {
	noi di in red `"invalid range: {opt maximum( )} needs to be greaer than or equal to {opt minimum( )}"'
	exit 198
}
if "`count'"=="" & "`count1'"=="" {
	local nocount nocount
}
if "`count'"~="" & "`count1'"=="" {
	local count1 "count"
}

* check id
tempvar test group
egen `group'=group(`id')
local wcount: word count `group'
forval num=1/`wcount' {
	local this : word `num' of `id'
	cap replace `group'=. if `this'==""
}
bys `group': gen `test'=_N if `group'~=.
sum `test', meanonly
if `r(max)'>1 {
	noi di in red `"observations not uniquely identified by "`id'""'
	exit 198
}
local N=_N
count if `id'~=.
if `r(N)'~=`N' {
	noi di in red `"`id' is missing for some observations"'
	exit 198
}

*** how many neighbors to search for
if "`nearest'"=="" {
	local nearest 5
}
else if "`nearest'"=="." {
	sum `group', meanonly
	local nearest `r(max)'
}

* donor & recipient
tempvar don rec
gen `don'=1
gen `rec'=1
if "`donor'"~="" {
	replace `don'=. if `donor'~=1
}
if "`recipient'"~="" {
	replace `rec'=. if `recipient'~=1
}

sort `don', stable
replace `don'=_n if `don'==1
sum `don', mean
if r(N)==0 {
	noi di in red "at least one `donor' needs to be 1"
	exit 198
}
local donN=r(N)
local donMin=r(min)
local donMax=r(max)

sum `rec', mean
if r(N)==0 {
	noi di in red  "at least one `recipient' needs to be 1"
	exit 198
}

* does it sideways by creating variables
foreach var in `id' {
	forval num=1/`nearest' {
		gen `pre'`var'`_near'`num'=`var'
		cap replace `pre'`var'`_near'`num'=""
		cap replace `pre'`var'`_near'`num'=.
		label var `pre'`var'`_near'`num' "nearest `var' `num'"
	}
}
foreach var in `dist' {
	forval num=1/`nearest' {
		gen `pre'`var'`_near'`num'=.
		label var `pre'`var'`_near'`num' "nearest `var' `num'"
	}
}
foreach var in `group' {
	forval num=1/`nearest' {
		gen `var'`_near'`num'=`var'
		cap replace `var'`_near'`num'=""
		cap replace `var'`_near'`num'=.
		label var `var'`_near'`num' "nearest `var' `num'"
	}
}
foreach var in `varlist' {
	forval num=1/`nearest' {
		gen `pre'`var'`_near'`num'=`var'
		cap replace `pre'`var'`_near'`num'=""
		cap replace `pre'`var'`_near'`num'=.
		label var `pre'`var'`_near'`num' "nearest `var' `num'"
	}
}

/*
*** flip if one group is larger than the other
sum `group', meanonly
local N=_N
if r(max)<`N'/2 {

*/

* place holders
foreach var in `group' `id' `varlist' `metric' {
	tempvar `var'New
	gen ``var'New'=`var'
}
foreach var in `dist' {
	tempvar `var'New
	gen double ``dist'New'=.
}
tempvar reject
gen `reject'=0
local N=_N


*tempvar loncut latcut

* cycle `don'
forval candidate=1/`nearest' {
	noi `di'
	noi di ""
	noi di in white "nearest `candidate'/`nearest'" _c
	`noi' di " from `donMax' potential donors :" _c
	
	local di di
	
	*** grid search
	*if "`grid'"~="" {
	*	noi di in red "grid search"
	*	local gridN 10
	*	egen `loncut'=cut(`lon') if `rec'~=., group(`gridN')
	*	egen `latcut'=cut(`lat') if `rec'~=., group(`gridN')	
	*}
	
	forval place=`donMin'/`donMax' {
		* comarison values
		foreach var in `group' `id' `varlist' `metric' {
			replace ``var'New'=`var'[`place']
		}
		
		if "`noi'"~="" {
			`noi' di in yel " `place'" _c
		}
		
		foreach var in `metric' {
			replace ``dist'New'= abs(`metric'-``metric'New')
			
			replace ``dist'New'=. if ``dist'New'>`maximum' | ``dist'New'<`minimum'
		}
		
		replace `reject'=0
		if `candidate'~=1 {
			forval num=2/`candidate' {
				replace `reject'=1 if `group'`_near'`=`num'-1'==``group'New' & `rec'==1
			}
		}
		
		foreach var in `group' {
			* take the value if conditions are met (exclude the same place)
			replace `var'`_near'`candidate'=``var'New' if (``dist'New'<`pre'`dist'`_near'`candidate') & `group'~=``group'New' & `reject'==0 & `rec'==1
		}
		set trace off
		foreach var in `id' `varlist' {
			* take the value if conditions are met (exclude the same place)
			replace `pre'`var'`_near'`candidate'=``var'New' if (``dist'New'<`pre'`dist'`_near'`candidate') & `group'~=``group'New' & `reject'==0 & `rec'==1
		}
		
		* do this last:
		foreach var in `dist' {
			* take the value if conditions are met (exclude the same place)
			replace `pre'`dist'`_near'`candidate'=``dist'New' if (``dist'New'<`pre'`dist'`_near'`candidate') & `group'~=``group'New' & `reject'==0 & `rec'==1
		}
	}
	
	local max_candidate `=`candidate'-1'
	
	* break the loop if no neighbor found
	sum `group'`_near'`candidate', meanonly
	if `r(N)'==0 {
		noi di in white " - does not exist, the maximum number of neighbor is `=`candidate'-1'"
		local max_candidate `=`candidate'-1'
		foreach var in `id' `varlist' `dist' {
			drop `pre'`var'`_near'`candidate'-`pre'`var'`_near'`nearest'
		}
		continue, break
	}
}

if "`count1'"~="" & "`nocount'"~="nocount" {
	cap egen long `pre'`count1'=rownonmiss(`pre'`id'`_near'1-`pre'`id'`_near'`max_candidate')
	if _rc~=0 | `max_candidate'==0 {
		gen long `pre'`count1'=0
	}
	label var `pre'`count1' "the number of neighbors meeting the condition"
}

*/



di
} /* qui */

end
exit



donate except one's self

