
*! aggreg 1.0.0  CFBaum 11aug2008
program aggreg, rclass
	version 10.1
	syntax varlist(max=1 numeric) [if] [in], per(integer) [func(string)]
	marksample touse
	quietly count if `touse'
	if `r(N)' == 0 {
	        error 2000
	}
* validate per versus selected sample
	if `per' <= 0 | `per' >= `r(N)' {
		display as error "per must be > 0 and < N of observations."
		error 198
	}
	if mod(`r(N)',`per' != 0) {
		display as error "N of observations must be a multiple of per."
		error 198
	}
* validate func option; default is average (code A)
    local ops A S F L
    local opnames average sum first last
    if "`func'" == "" {
    	local op "A"
    }
    else {
    	local nop : list posof "`func'" in opnames
    	if !`nop' {
    		display as err "Error: func must be chosen from `opnames'"
    		error 198
    	}
    	local op : word `nop' of `ops'
    }
* validate the new varname
	local newvar = "`varlist'`op'`per'"
     quietly generate `newvar' = .
* pass the varname and newvarname to Mata
	mata: aggreg("`varlist'", "`newvar'",  `per', "`op'", "`touse'")
	end
