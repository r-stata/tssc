*! 1.0.0 NJC 21 January 2003 
program def mypkg 
	version 7 
	syntax [anything] [, ALL * ] 
	preserve 
	qui { 
		local source : sysdir STBPLUS 
		local sep : dirsep 
		infix str pkg 1-80 using "`source'`dirsep'stata.trk", clear  
		keep if substr(pkg,1,1) == "D" /* 
		*/ | substr(pkg,1,1) == "N"    
		gen str1 which = substr(pkg,1,1) 
		replace pkg = trim(substr(pkg,3,.)) 
		gen int npkg = 1 + int((_n - 1) / 2)
		reshape wide pkg, i(npkg) j(which) string 
		sort pkgN npkg 
		if "`all'" == "" { 
			by pkgN : keep if _n == _N 
		} 	
		replace pkgN = subinstr(pkgN,".pkg","",.)
		gen str1 number = "" 
		replace number = "[" + string(npkg) + "]"
		compress
		rename pkgN package 
		rename pkgD date
	} 

	local 0 `anything' 
	if "`0'" == "" { 
		list number package date, noobs `options' 
	} 
	else if index("`0'","*") | index("`0'","?") { 
		foreach p of local 0 { 
			list number package date if match(package,"`p'"), /* 
			*/ noobs `options'  
		}
	} 	
	else { 	
		foreach p of local 0 { 
			qui count if package == "`p'" 
			if r(N) { 
				qui Levels npkg if package == "`p'", /* 
				*/ local(levels) 
				foreach l of local levels { 
					ado desc [`l'] 
				} 
			} 	
			else di _n "{txt}package {inp}{bf:`p'} {txt}not found"
		} 
	} 	
end 

/* N.B. the U record is not necessarily what is used by -ado- !!! */ 

*! 1.0.1 NJC 10 Sept 2002 
*! 1.0.0 NJC 16 July 2002 
program define Levels, sortpreserve rclass 
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


