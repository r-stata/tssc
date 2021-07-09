*! Attaullah Shah, attaullah.shah@imsciences.edu.pk
*! Version 1.0, 30September2017
cap prog drop asgen
prog asgen, sortpreserve byable(onecall)
	version 11
	syntax namelist =/ exp [if] [in], [Weights(varname) by(varlist)]

	marksample touse, nov
	preserve
	cap confirm variable `exp'
	if _rc {
		tempvar EXP
		qui gen `EXP'= `exp' if `touse'
	}
	else local EXP "`exp'"
		if "`_byvars'"!="" {
			local by "`_byvars'"
		}
		if "`by'"=="" {
			tempvar by
			qui gen `by' = 1
		}
	mata: asgenhk("`by'")
	if "`weights'"!=""{	
		mata: wmean("`namelist'", "`EXP'", "__GByVars", "`weights'", "`touse'") 
	}
	else {
		mata: smean("`namelist'", "`EXP'", "__GByVars", "`touse'") 
	}
	restore, not
end

