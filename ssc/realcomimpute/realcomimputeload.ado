*realcomImputeLoad Jonathan Bartlett jwb133@googlemail.com
*21st September 2011
*bug fixed when number of responses exceeds number of imputations
*18th April 2017 - contact information updated
program define realcomImputeLoad
version 11.1
syntax

preserve

quietly insheet using impvals.txt, clear nonames
local numimputations = v1[3]

*find names of imputed variables
local i = 1
local varname = v1 in 1
local varname1 `varname'
local ok = 1
while `ok'==1 {
	local i = `i' + 1
	capture confirm variable v`i'
	if !_rc {
		local varname = v`i' in 1
		if "`varname'"!="" {
			local varname`i' `varname'
			local ok = 1
		}
		else {
			local ok = 0
		}
	}
	else {
		local ok = 0
	}
}
local numimputedvars = `i'-1

quietly keep in 4
quietly gen id=_n
quietly reshape long v, i(id)

quietly forvalues i=1(1)`numimputations' {
	local filename`i' = v in `i'
}
quietly forvalues i=1(1)`numimputations' {
	insheet using "`filename`i''.", tab clear nonames
	forvalues j=1(1)`numimputedvars' {
		rename v`j' `varname`j''`i'
	}
	save imp`i', replace
}

restore

*now adding imputed data to original data
forvalues i=1(1)`numimputations' {
	quietly merge using imp`i'
	drop _merge
}

*mi set the data
*construct argument to mi import
local miimportarg
forvalues i=1(1)`numimputedvars' {
	local miimportarg `miimportarg' `varname`i''=
	forvalues j=1(1)`numimputations' {
		local miimportarg `miimportarg' `varname`i''`j'
	}
	local miimportarg `miimportarg' 
}

quietly mi import wide, imputed(`miimportarg') clear drop 

di
di as result "`numimputations' multiple imputations successfully loaded"

mi describe

end
