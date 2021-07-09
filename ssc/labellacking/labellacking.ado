*! 1.3.0 NJC and RP 23 June 2013
* 1.2.0 NJC 22 June 2013
* 1.0.0 NJC 21 June 2013 
program labellacking
version 8.2
syntax [varlist] [if] [in] [, All Reportnovaluelabels MISSing]
 
quietly {
	ds `varlist', has(type numeric)
	local varlist `r(varlist)'
	if "`varlist'" == "" error 102 
	
	marksample touse, novarlist
	count if `touse'
	if r(N) == 0 error 2000
}
 
local length = 1
local I = 0 
tempvar vuse 
gen byte `vuse' = 0 
 
quietly foreach v of local varlist {
	if "`: value label `v''" == "" {
		if "`reportnovaluelabels'" != "" {
			local ++I 
			local length = max(`length', length("`v'")) 
			local name`I' "`v'"
			local text`I' "(no value label)"
		}
	}
	else {
		tempvar work
		replace `vuse' = `touse' & (`v' != .) & (`v' == int(`v')) 
		decode `v' if `vuse', gen(`work') maxlength(1) 
		levelsof `v' if `vuse' & missing(`work'), local(levels) `missing' 
		if "`levels'" == "" { 
			if "`all'" != "" { 
				local ++I 
				local length = max(`length', length("`v'")) 
				local name`I' "`v'"
				local text`I' "(none)"
			} 
		} 	
		else {
			local ++I  
			local length = max(`length', length("`v'")) 
			local name`I' "`v'"
			local text`I' "`levels'"
		} 
		drop `work'
	}
}

if `I' di 
local col = `length' + 4 
forval i = 1/`I' {
	di "`name`i''{col `col'}`text`i''" 
}
 
end
 

