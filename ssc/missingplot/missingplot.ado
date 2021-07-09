*! 1.0.0 NJC 2 November 2012
program missingplot
	version 8.2
	syntax [varlist] [if] [in] [ , all labels VARiablenames * ]
 
	quietly {
		marksample touse, novarlist
		count if `touse'
		if r(N) == 0 error 2000
 
		local y = 0
		tempvar obsno
		gen long `obsno' = _n if `touse'
		label variable `obsno' "observations"
		local toomany = 0
 
		foreach v of local varlist {
			local include = 1
			if "`all'" == "" {
				count if `touse' & missing(`v')
				if r(N) == 0 local include = 0
			}

			if `include' {
				local ++y

				if `y' > 20 {
					local toomany = 1
					continue, break
				}
 
				tempvar ynew
				gen `ynew' = `y' if missing(`v')
 
				if "`variablenames'" != "" {
					local which "`v'"
				}
				else {
					local which : var label `v'
					if `"`which'"' == "" local which "`v'"
				}

				local call `call' `y' `"`which'"'
				local Y `Y' `ynew'
			}
		}
	}

	if "`Y'" == "" {
		di as txt "(no missing values)"
		exit 0
	}

	if `toomany' {
		di as txt "note: only first 20 variables plotted"
	}

	local stretch "ysc(r(0.5 `=`y'+0.5'))" 

	if "`labels'" != "" { 
		local arg : di _dup(`y') "`obsno' " 
		local labels "mla(`arg') mlabpos(12 ..) mlabcolor(gs3 ..)"
	}

	scatter `Y' `obsno' if `touse', ///
	`labels' /// 
	yla(`call', ang(h) grid noticks) `stretch' ytitle("") ///
	legend(off) mcolor(blue ..) ms(dh ..) `options'
end

