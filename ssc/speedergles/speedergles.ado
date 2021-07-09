*! version 1.0  02apr2015

*-------------------------------------------------------------------------------
*            
*  Recommended citation (APA Style, 6th ed.): 
*  Roﬂmann, J. (2015): SPEEDERGLES: Stata module for the computation 
*  of the GLES response speed index (Version: 1.0) [Computer Software]. 
*  Chestnut Hill, MA: Boston College.
*
*-------------------------------------------------------------------------------

program speedergles
version 12.1
syntax varlist(numeric) [if] [in], DURation(varname) INDEXname(string) FLAGname(string) [MISSing(numlist miss)] [QUIetly]

*--- Check input ---*

*--- Sample to use ---*
	marksample touse, novarlist

*--- Compute speeder index for item or page level response times ---*
	tempvar tempvar values nopages speedindex error tempdur durvalue
	quietly gen `tempvar'=0 if `touse'
	quietly gen `nopages'=0 if `touse'
	quietly gen `values'=0 if `touse'
	quietly gen `speedindex'=0 if `touse'
	quietly gen `tempdur'=0 if `touse'
	quietly gen `error'=0 if `touse'
	foreach var of varlist `varlist' {	
		quietly replace `tempvar'=`var' if `touse'
		if "`missing'"!="" {
			foreach num of numlist `missing' {
				quietly replace `tempvar'=. if `tempvar'==`num'
				}
			}
		quietly sum `tempvar' if `tempvar'!=. & `touse', d
		quietly replace `values'=`tempvar'/r(p50) if `tempvar'<r(p50) & `tempvar'!=. & `touse'
		quietly replace `values'=1+(1-r(p50)/`tempvar') if `tempvar'>=r(p50) & `tempvar'!=. & `touse'
		quietly replace `values'=. if `tempvar'==.  & `touse'
		quietly replace `nopages'=`nopages'+1 if `tempvar'!=. & `touse'
		if "`quietly'"=="" {
			sum `values'
			}
		quietly sum `values'
		quietly replace `error'=1 if (r(min)<0 | r(max)>2) & r(max)!=.
		quietly replace `speedindex'=`speedindex'+`values' if `values'!=. & `touse'
		}
	quietly replace `speedindex'=`speedindex'/`nopages' if `speedindex'!=. & `nopages'!=. & `touse'
	quietly sum `speedindex'
	quietly replace `error'=1 if (r(min)<0 | r(max)>2) & r(max)!=.

*--- Compute speeder index for overall interview duration ---*
	quietly replace `tempdur'=`duration' if `touse'
	if "`missing'"!="" {
		foreach num of numlist `missing' {
			quietly replace `tempdur'=. if `tempdur'==`num'
			}
		}
	quietly sum `tempdur' if `touse', d
	quietly gen `durvalue'=`tempdur'/r(p50) if `tempdur'<r(p50) & `touse'
	quietly replace `durvalue'=1+(1-r(p50)/`tempdur') if `tempdur'>=r(p50) & `tempdur'!=. & `touse'
	quietly replace `durvalue'=`speedindex' if `tempdur'==. & `touse'
	quietly sum `durvalue'
	quietly replace `error'=1 if (r(min)<0 | r(max)>2) & r(max)!=.
	
*--- Compute the GLES speeder index ---*
	quietly gen `indexname' = (`speedindex'+`durvalue')/2 if `touse'
	lab var `indexname' "Zeitunterschreiter-Index"
	quietly sum `indexname'
	quietly replace `error'=1 if r(min)<0 | r(max)>2
	quietly replace `error'=1 if r(mean)<.95 | r(mean)>1.05
	
*--- Generate flag variable ---*
	quietly gen `flagname'=0 if `touse'
	quietly sum `indexname' if `touse', d
	quietly replace `flagname'=1 if `indexname'<=r(p10) & `touse'
	quietly replace `flagname'=. if `indexname'==. & `touse'
	lab var `flagname' "Zeitunterschreiter (10% der Befragten mit den niedrigsten Indexwerten)"
	lab def `flagname' 0 "kein Zeitunterschreiter" 1 "Zeitunterschreiter", replace
	lab val `flagname' `flagname'

*--- Option: QUIetly 
if "`quietly'"=="" {
	quietly sum `error'
		if r(min)==1 {
			dis as error "An error occured. Please check input and results."
		}
		sum `nopages' `speedindex' `indexname' `flagname' 
	}
	else {
	quietly sum `error'
		if r(min)==1 {
			dis as error "An error occured. Please check input and results."
		}
		sum `indexname' `flagname'
	}
	
end
exit
