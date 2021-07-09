* renamed 7 March 2003 
*! 1.0.1 NJC 10 Sept 2002 
*! 1.0.0 NJC 16 July 2002 
program define levels7, sortpreserve rclass 
        version 7.0
        syntax varname [if] [in] [, Separate(str) MISSing Local(str) ]
	
        if "`separate'" == "" { 
		local sep " " 
	} 
	else local sep "`separate'" 

	if "`missing'" != "" { local novarlist "novarlist" } 
        marksample touse, strok `novarlist' 
	capture confirm numeric variable `varlist'
	local isnum = _rc != 7 
	
        if `isnum' { /* numeric variable */
		capture assert `varlist' == int(`varlist') if `touse' 
		if _rc { 
			di as err "`varlist' contains non-integer values" 
			exit 459
			/* NOT REACHED */ 
		} 
		
                tempname Vals
                qui tab `varlist' if `touse', matrow(`Vals')
                local nvals = r(r)

                forval i = 1 / `nvals' {
                        local val = `Vals'[`i',1]
			if `i' < `nvals' { local vals "`vals'`val'`sep'" }
			else local vals "`vals'`val'" 
                }
		
		if "`missing'" != "" { 
			qui count if missing(`varlist') & `touse' 
			if `r(N)' > 0 { 
				local vals "`vals'`sep'." 
			} 	
		} 	
        }
	else { /* string variable */
                tempvar select counter
                bysort  `touse' `varlist' : /*
                 */ gen byte `select' = (_n == 1) * `touse'
                generate `counter' = sum(`select') * (`select' == 1) 
                sort `counter'
		qui count if `counter' == 0 
                local j = 1 + r(N)
		local nvals = _N 
		forval i = `j' / `nvals' { 
			local val = `varlist'[`i']
                        if `i' < `nvals' { 
				local vals `"`vals'`"`val'"'`sep'"' 
			}
			else local vals `"`vals'`"`val'"'"' 
                }
        }

        di as txt `"`vals'"' 
	return local levels `"`vals'"' 
	if "`local'" != "" { 
		c_local `local' `"`vals'"' 
	} 	
end
