capture program drop itercenter
program define itercenter

*** This program is used to "demean" the data, respect to all variables provided in the `Varlist' 
*** One can choose tolerance levels, and define the max number of iterations.
*** One can choose to keep the mean of variables intact. Original variable is replaced by the transformed data
*** it has been tested to run under stata 12 or greater.

syntax varlist [if] [in] [aw fw iw] , fe(varlist min=1) [tolerance(str)] [maxiter(integer 10000)] [mean] [replace xfe(str)]
marksample touse2
foreach i in `fe' {
qui replace `touse2'=0 if `i'==.
}

if "`replace'"=="" & "`xfe'"=="" {
dis in r "Option -replace- or -xfe()- required"
exit 198
}
if "`replace'"!="" & "`xfe'"!="" {
dis in r "Only one option, -replace- or -xfe()-, allowed"
exit 198
}
if "`replace'"!="" {
local varlist2 `varlist'
}

if "`xfe'"!="" {
	foreach i in `varlist' {
	qui:clonevar `xfe'_`i'=`i'
    local varlist2 `varlist2' `xfe'_`i'
	}
}

recast double `varlist2'

local cntr=`maxiter'
if "`mean'"!="" {
   foreach v in `varlist2' {
     qui:sum `v' [`weight'`exp'] if `touse2'
	 local `v'_mean=r(mean)
   }
}
if "`tolerance'"==""   local tolerance=epsfloat() 
	
	foreach i of local fe {
		qui: replace `touse2'=0 if `i'==.
	}
	foreach i in `varlist2' {
		local a0_`i'=0
		local a1_`i'=10
	}
	local flag=1
	
	while `flag'==1 & `cntr'>0 {
	    di "." _cont
		local cntr=`cntr'-1
		local flag=0
		local var2 
		foreach i in `varlist2' {
		*** the second condition is to reduce unnecessary iterations for cases of X variables colinear to the fixed effects. the detection of collinearity is indirect. 
		** the collinear variables are excluded from the final regression.
			if 10*abs(`a0_`i''-`a1_`i'')>=`tolerance' & (`a1_`i'')^2>epsfloat() {
				 local flag=1
				 local var2 `var2' `i'
				 local a0_`i'=`a1_`i''
				 qui: sum `i' [`weight'`exp'] if `touse2'
				 local a1_`i'=(r(sd))
			 }
		}
    foreach h of local fe {
			sort `h'
		    foreach ix of local var2 {
			  qui: by `h':center `ix' [`weight'`exp'] if `touse2', inplace double
		   }
	    }
	}

if "`mean'"=="mean" & `maxiter'>0 {
   foreach v in `varlist2' {
   qui: replace `v'=`v'+``v'_mean' if `touse2'
   }
}
   foreach v in `varlist2' {
		label var `v' "Demeaned `v'"
	}

end

