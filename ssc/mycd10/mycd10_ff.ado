*! version 1.0.1  30aug1999  STB-54: dm76
program define mycd10_ff, rclass
	version 6
	gettoken fn 0 : 0, parse(" ,")
	syntax [, ADO]

	local sep : dirsep
	local ltr = substr(`"`fn'"',1,1)
	if `"`ltr'"' != "" {
		tokenize `"$S_ADO"', parse(" ;")
		while `"`1'"' != "" {
			if `"`1'"' != ";" {
				local realdir : sysdir `"`1'"'
				return local fn `"`realdir'`fn'"'
				capture confirm file `"`return(fn)'"'
				if _rc==0 { 
					di in gr `"`return(fn)'"'
					exit 
				}
				return local fn `"`realdir'`ltr'`sep'`fn'"'
				capture confirm file `"`return(fn)'"'
				if _rc==0 { 
					di in gr `"`return(fn)'"'
					exit
				}
			}
			mac shift
		}
	}
	di in red `"file "`fn'" not found"'
	exit 601
end

