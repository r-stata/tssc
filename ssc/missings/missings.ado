*! 1.1.1 NJC 11 May 2017 
* 1.1.0 NJC 26 Apr 2017 
* 1.0.1 NJC 24 Sep 2015
* 1.0.0 NJC 26 Aug 2015
program missings, rclass byable(recall) 
	version 9

	// identify subcommand
	gettoken cmd 0 : 0, parse(" ,") 
	local l = length("`cmd'")

	if `l' == 0 {
		di "{err}subcommand needed; see help on {help missings}"
		exit 198
	}

	// report list table tag dropvars dropobs  
	if substr("report", 1, max(1, `l')) == "`cmd'" {
		local cmd "report"
	}
	else if substr("list", 1, max(1, `l')) == "`cmd'" {
		local cmd "list"
	}
	else if substr("table", 1, max(3, `l')) == "`cmd'" {
		local cmd "table"
	}
	else if "tag" == "`cmd'" {
		* -t- or -ta- would be ambiguous
		if _by() error 190 
	}
	else if "dropvars" == "`cmd'" {
		* destructive subcommand spelled out 
		if _by() error 190 
	}
	else if "dropobs" == "`cmd'" {
		* destructive subcommand spelled out 
		if _by() error 190 
	}
	else {
		di "{err}illegal {cmd}missings {err}subcommand"
		exit 198
	}

	// check rest of syntax
	local common NUMeric STRing SYSmiss noHEADER 

	if "`cmd'" == "report" { 
		syntax [varlist(default=none)] [if] [in] ///
		[ , `common' OBServations MINimum(numlist max=1 >=0) ///
		Percent Format(str) SORT SHOW(numlist int min=1 >0) * ]
		if "`format'" == "" local format %5.2f 
	}
	else if "`cmd'" == "list" { 
		syntax [varlist(default=none)] [if] [in] ///
		[ , `common' MINimum(numlist max=1 >=0)  * ]
	}
	else if "`cmd'" == "table" { 
		syntax [varlist(default=none)] [if] [in] ///
		[ , `common' MINimum(numlist max=1 >=0)  * ]
	}
	else if "`cmd'" == "tag" { 
		syntax [varlist(default=none)] [if] [in], ///
		Generate(str) [`common']  

		capture confirm new variable `generate' 
		if _rc { 
			di as err "generate() must specify new variable" 
			exit _rc 
		}
	}	
	else if "`cmd'" == "dropvars" { 
		syntax [varlist] [, `common'  force ]

		if "`force'" == "" & c(changed) { 
			di as err "force option required with changed dataset"
			exit 4 
		}   
	}
	else if "`cmd'" == "dropobs" { 
		syntax [varlist] [if] [in] [, `common'  force] 

		if "`force'" == "" & c(changed) { 
			di as err "force option required with changed dataset"
			exit 4
		}   
	}

	quietly { 
		if "`varlist'" == "" { 
			local vartext "{txt} all variables"
			unab varlist : _all
			if _by() local varlist : ///
			subinstr local varlist "`_byindex'" "" 
		} 

		if "`numeric'`string'" != "" { 
			if "`numeric'" != "" & "`string'" != "" { 
				* OK 
			} 
			else { 
				if "`numeric'" != "" ds `varlist', has(type numeric) 
				else ds `varlist', has(type string) 
				local varlist `r(varlist)' 
				if "`varlist'" == "" { 
					di as err "no variables specified" 
					exit 100
				} 

				if "`vartext'" != "" { 
					local vartext "{txt}all `numeric'`string' variables" 
				} 
			}
		} 

		if "`vartext'" == "" local vartext "{res} `varlist'"
	}

	// looking at observations with missings is the point! 
	marksample touse, novarlist

	// # of observations used  
	quietly count if `touse' 
	if r(N) == 0 error 2000 
	local N = r(N) 
	return scalar N = r(N)
	
	// nmissing is count of missings on variables specified 
	tempvar nmissing  
 
	quietly { 
		if "`sysmiss'" != "" local system "system " 
		gen `nmissing' = 0 if `touse'  
		label var `nmissing' "# of `system'missing values" 
		local min `minimum' 
		if "`min'" == "" local min = cond("`cmd'" == "table", 0, 1) 

		foreach v of local varlist { 
			capture confirm numeric variable `v' 
			local sys = (_rc == 0) & ("`sysmiss'" != "") 

			if `sys' count if `v' == . & `touse' 
			else count if missing(`v') & `touse' 
	
			if r(N) >= `min' { 
				local misslist `misslist' `v' 
				if r(N) == `N' { 
					local droplist `droplist' `v' 
				} 
				local nmiss `nmiss' `r(N)' 
				if "`percent'" != "" { 
					local pc = 100 * `r(N)'/`N' 
					local pcmiss `pcmiss' `pc' 
				}
			}

			if `sys' replace `nmissing' = `nmissing' + (`v' == .) if `touse' 
			else replace `nmissing' = `nmissing' + missing(`v') if `touse' 
		}
		if "`percent'" != "" & "`observations'" != "" { 
		// pcmissing is percent of missings on variables specified 
			local nvars : word count `varlist' 
			tempvar pcmissing 
			gen `pcmissing' = 100 * `nmissing'/`nvars' if `touse'  
			label var `pcmissing' "% of `system'missing values" 
			format `pcmissing' `format' 
 		} 
	}
	
	if "`header'" == "" { 
		di _n "{p 0 4}{txt}Checking missings in `vartext':{txt}{p_end}"
	}
	else di   

	quietly count if `nmissing' & `touse'
	local NM = r(N)
	di "`NM' " cond(`NM' == 1, "observation", "observations") ///
	" with `system'missing values" 

	if "`cmd'" == "report" {
		if `NM' == 0 exit 0 

		if "`observations'" != "" { 
			char `nmissing'[varname] "# `system'missing" 
			if "`percent'" != "" {  
				char `pcmissing'[varname] "% `system'missing" 
			}
			list `nmissing' `pcmissing' if `nmissing' >= `min', ///
			abbrev(9) subvarname `options' 

			exit 0 
		} 

		local namelen = 0 
		foreach v of local misslist { 
			local namelen = max(`namelen', length("`v'"))  
		}
		local col = `namelen' + 4 
		local nfig = length("`NM'")

		di 
		tokenize "`nmiss'" 

		// set up string matrix in Mata 
		if "`percent'" != "" { 
			mata : mout = J(0, 3, "") 
			local nc = 3
		}
		else {
			mata : mout = J(0, 2, "") 
			local nc = 2 
		}

		local j = 1 
		foreach v of local misslist { 
			local spaces = `nfig' - length("``j''") 
			local spaces : di _dup(`spaces') " " 
			mata : mout = mout \ J(1, `nc', "") 

			if "`percent'" != "" { 
				local pcm : word `j' of `pcmiss' 

				if `pcm' == 100 local pcs = 3
				else if `pcm' >= 10 local pcs = 4 
				else local pcs = 5 
				local pcspaces : di _dup(`pcs') " "
 
				mata : mout[`j', 3] = strofreal(`pcm', "`format'") 
			}  
		
			mata : mout[`j', (1, 2)] = ("`v'", "``j''") 

			local ++j 
		}

		if "`sort'" != "" {
			mata: nmissings = strtoreal(mout[, 2]) 
			mata: mout = mout[order(nmissings, -1),] 

			if ("`show'" != "") { 
				mata: nr = min((rows(mout), `show')) 
				mata: mout = mout[1..nr,] 
			} 				
		}
	
		mata: st_local("nr", strofreal(rows(mout))) 

		forval j = 1/`nc' { 
			mata: st_local("w`j'", strofreal(colmax(strlen(mout[,`j'])))) 
			local w`j' = cond(`j' == 1, 2 + `w`j'', 4 + `w`j'') 
		}
 
		// top of table 
	        tempname mytab 
	        .`mytab' = ._tab.new, col(`nc') lmargin(0)
		if `nc' == 3 .`mytab'.width `w1'  | `w2' `w3' 
		else         .`mytab'.width `w1'  | `w2'      
	        .`mytab'.sep, top
		if `nc' == 3 .`mytab'.titles " " "#"  "%"  
		else         .`mytab'.titles " " "#"       
	        .`mytab'.sep

		// body of table 
		forval i = 1/`nr' {
			forval j = 1/`nc' { 
				mata: st_local("t`j'", mout[`i', `j'])  
			}
			if `nc' == 3 .`mytab'.row  "`t1'" "`t2'" "`t3'"   
			else         .`mytab'.row  "`t1'" "`t2'"          
		} 
	
		// bottom of table 
	        .`mytab'.sep, bottom
		mata mata clear 

		return local varlist "`misslist'" 
	}
	else if "`cmd'" == "list" {
		if `NM' > 0 {
			list `misslist' if `nmissing' >= `min' & `touse', `options'
		}
		return local varlist "`misslist'" 
	}
	else if "`cmd'" == "table" {
		if `NM' > 0 {
			tab `nmissing' if `nmissing' >= `min' & `touse', `options'
		}
		return local varlist "`misslist'" 
	}
	else if "`cmd'" == "tag" { 
		gen double `generate' = `nmissing' if `touse' 
		quietly compress `generate' 
	} 	
	else if "`cmd'" == "dropvars" {
		di
		if "`droplist'" != "" { 
			noisily drop `droplist' 
			di "{p}note: `droplist' dropped{p_end}" 
		}
		else di "note: no variables qualify" 
		return local varlist "`droplist'" 
	}
	else if "`cmd'" == "dropobs" { 
		di 
		local nvars : word count `varlist' 
		quietly count if `nmissing' == `nvars' & `touse' 
		return scalar n_dropped = r(N) 
		
		if r(N) == 0 di "note: no observations qualify" 
		else noisily { 
			drop if `nmissing' == `nvars' & `touse' 
		}
	} 
end


