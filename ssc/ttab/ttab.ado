!* version 0.1 Apr 2013 Federico Belotti
!* version 0.2 Jul 2013 Federico Belotti over() and over2() added
!* Makes mean comparison for a lot of variables between two groups with formatted table output
!* and eventually exports tables in a bunch of different format including tex

program define ttab, eclass 
    syntax varlist(min=1) [if] [in], by(varlist) [ tshow over(varname) over2(varname) TOFILE(string) ttest(string) ///
                  estout(string asis) BYVARSLABels(string asis) TItle(string asis) ]
version 10
capt findfile estout.ado
if _rc {
    di as error "-estout- is required; type {stata ssc install estout}"
    error 499
}
			
	if "`tofile'"!="" {
		gettoken fp sp: tofile, parse(",")
		local fp = trim("`fp'") 
		local using "using `"`fp'"'"
		local _replace = subinstr("`sp'",",","",.)
		if "`estout'"!="" local estout "`estout' `_replace'" 
	}
	

    // count the number of ovars
    local novars : word count `varlist'	
	
	// count the number of byvars
    local nbyvars : word count `by'	
	local nbyrows = `nbyvars'*3
	
	if "`over'"!="" {
	    qui levelsof `over', l(lev_over1) clean
		local nlev_over1: word count `lev_over1'
		cap confirm numeric var `over'
		if _rc==0 local tover1 "num"
		else local tover1 "str"
	}
	else local nlev_over1 1
	if "`over2'"!="" {
		qui levelsof `over2', l(lev_over2) clean
		local nlev_over2: word count `lev_over2'
		cap confirm numeric var `over2'
		if _rc==0 local tover2 "num"
		else local tover2 "str"
	}
	else local nlev_over2 1
	
	tokenize `"`title'"'
	forvalues i=1/`novars' {
		local _ti`i' `"``i''"'
	}	
	if `"`byvarslabels'"' != "" tokenize `"`byvarslabels'"'
	tempname _ttest

*set trace on
local ov 1	
foreach o of local varlist {
	qui {
	local __2display
	forvalues ov1=1/`nlev_over1' {
		forvalues ov2=1/`nlev_over2' {
			
			// take care of possible missing values
		    marksample touse
		    markout `touse' `by', strok
		    qui count if `touse'
		    if r(N) == 0 error 2000

			local i 1
			local j 2
			local k 3
			local v 1
			local roweqs ""
			local rownames ""
	
			mat `_ttest' = J(`nbyrows',3,.)
	
			foreach var of local by {
				
				if "`over'"!="" {
					if "`tover1'"=="str" local if_ov1 `"& `over'=="`: word `ov1' of `lev_over1''""'
					else local if_ov1 `"& `over'==`: word `ov1' of `lev_over1''"'
				}
				if "`over2'"!="" {
					if "`tover2'"=="str" local if_ov2 `"& `over2'=="`: word `ov2' of `lev_over2''""'
					else local if_ov2 `"& `over2'==`: word `ov2' of `lev_over2''"'
				}
				tempname e`ov'`ov1'`ov2'
				
 				qui ttest `o' if `touse' `if_ov1' `if_ov2', by(`var') `ttest'
				if `i'==1 local N = r(N_1)+r(N_2)
				
				mat `_ttest'[`i',1] = r(mu_1)
				mat `_ttest'[`j',1] = r(mu_2)
				if "`tshow'"=="" mat `_ttest'[`k',1] = (r(mu_1)-r(mu_2))
				else mat `_ttest'[`k',1] = r(t)
				
				mat `_ttest'[`i',2] = r(sd_1)/sqrt(r(N_1))
				mat `_ttest'[`j',2] = r(sd_2)/sqrt(r(N_2))
				if "`tshow'"=="" mat `_ttest'[`k',2] = r(se)
				else mat `_ttest'[`k',2] = r(p)
				
				mat `_ttest'[`i',3] = r(N_1)
				mat `_ttest'[`j',3] = r(N_2)
				mat `_ttest'[`k',3] = r(p)
				
				local i = `i'+3
				local j = `j'+3
				local k = `k'+3 
    		
				if `"`byvarslabels'"' != "" local eqnames `""``v''" "``v''" "T-test""'
				else local eqnames `""`var'" "`var'" "T-test""'
				local roweqs `"`roweqs' `eqnames'"'
				
				levelsof `var', l(varlevels)
				local bothvarlevs
				foreach lev of local varlevels {
					local varlev`lev' "`"`lev'"'"
					local bothvarlevs `"`bothvarlevs' `varlev`lev''"'
				}
				
				local valuelabels
				local valuelabeln: value label `var'
				if "`valuelabeln'" != "" {
					foreach lev of local varlevels {
						local varvaluelabel`lev': label `valuelabeln' `lev' 10, strict
						local valuelabels "`valuelabels' `"`varvaluelabel`lev''"'"
					}
				} 
				if "`valuelabels'" != "" local bothvarlevs "`valuelabels'"
				
				if "`tshow'"=="" local rownames `"`rownames' `bothvarlevs' "Difference""'
				else local rownames `"`rownames' `bothvarlevs' "statistic""'
				
				local v = `v'+1
			
			}
	
			mat roweq `_ttest' = `roweqs'
			mat rownames `_ttest' = `rownames'
			
			*noi mat li `_ttest'
			tempname est se 
			mat `est' = `_ttest'[1...,1]'
			mat `se' = `_ttest'[1...,2]'
			eret post `est', obs(`N') e(`touse')
			eret mat se = `se'
			eret local cmd "ttab"
			
			est sto `e`ov'`ov1'`ov2''
			local __2display "`__2display' `e`ov'`ov1'`ov2''"
			
		} /* Close ov2 */
		
	} /* Close ov1 */
			
	} /* Close quietly */
		
	di ""
	di in yel "`_ti`ov''"
	estout `__2display' `using', `estout'
	local ov = `ov'+1
	
} /* Close o */
	
eret clear

end




