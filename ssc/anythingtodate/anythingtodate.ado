program define anythingtodate

*! Version: 1.0.0
*! Author:  Nobuaki Michihata
*! e-mail:  gha10771+stata@gmail.com
*! Date:    December 25, 2019

version 11.0
syntax varlist [, Keepvarlists Format(string asis) Reference(integer 19000000) ]
tokenize "`0'",parse(" ,")

if "`format'" =="" {
local format = "%tdCCYYNNDD"
}

qui ds `varlist', not(format `format')
local vl="`r(varlist)'"

if "`vl'" !="" {
	di "[numeric]"
	ds `vl', has(type numeric)

	foreach i in `r(varlist)' {
		tempvar tempmax
		qui egen `tempmax'=max(`i')
		if `tempmax' > `reference' {
			tempvar temp1
			qui gen `temp1'=date(string(`i',"%8.0f"),"YMD")
			qui if "`keepvarlists'" != "" {
				local newvarname = ustrregexra(abbrev("`i'_original",32),"~","_")
				capture des `newvarname'
				if _rc == 0 {
				        local j=1
					while _rc == 0 {
					      local j=`j'+1
					      capture des `newvarname'`j'
					}
			        local newvarname = "`newvarname'" + "`j'"
				}
				qui capture drop `newvarname'
				qui clonevar `newvarname' = `i'
			}				
			qui drop `i'
			rename  `temp1' `i'
		}
		format `i' `format'
	}
}

if "`vl'" !="" {
	di "[string]"
	ds `vl', has(type string)

	foreach i in `r(varlist)' {
		tempvar temp2
		qui gen `temp2'=  date(`i',"YMD")
		qui if "`keepvarlists'" != "" {
			local newvarname = ustrregexra(abbrev("`i'_original",32),"~","_")
			capture des `newvarname'
			if _rc == 0 {
				local j=1
				while _rc == 0 {
					local j=`j'+1
					capture des `newvarname'`j'
				}
			local newvarname = "`newvarname'" + "`j'"
			}
			qui capture drop `newvarname'
			qui clonevar `newvarname' = `i'
		}			

qui drop `i'
		qui rename `temp2' `i'
		format `i' `format'
	}
}
end