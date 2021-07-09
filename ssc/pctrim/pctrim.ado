*! pctrim version 1.0 2013-10-09 
*! author: Michael Barker mdb96@georgetown.edu

/*******************************************************************************

Mark or replace outliers based on percentiles bounds of each variable.

*******************************************************************************/

version 10

program define pctrim 
    syntax varlist [if] [in] , [by(varlist numeric) MARK(name) Percentiles(numlist min=2 max=2 >=0) RECode(name) GENerate(name) REPLACE COPYrest MISSok]

    marksample touse, novarlist
	if "`missok'"=="" markout `touse' `varlist'
	if "`by'"!="" markout `touse' `by'

	* Check that one of the output options is selected. 
	if ("`mark'"=="" & "`recode'"=="") {
		display as error "mark and/or recode options must be specified."
		error 198
	}

	* Check mark option
	if "`mark'" != "" confirm new variable `mark' 

	* Check recode, gen, replace options
	if "`recode'"!="" {
		if !inlist("`recode'", "miss", "median", "mean", "bound") {
			display as error "Invalid recode option"
			error 198
		}
		if ("`generate'"=="" & "`replace'"=="") | ("`generate'"!="" & "`replace'"!="") {
			display as error "Must specify either generate or replace with recode."
			error 198
		}
		if ("`generate'" != "") {
			* verify new varlist
			local newvarlist : subinstr local varlist " " " `generate'" , all
			local newvarlist "`generate'`newvarlist'"
			confirm new variable `generate' 
			display "Original Varlist |`varlist'|"
			display "New Varlist |`newvarlist'|"

		}
	}

	if "`recode'"=="" & ("`generate'"!="" | "`replace'"!="") {
		display as error "Generate and replace can only be used with recode option."
		error 198
	}

	if "`copyrest'"=="copyrest" & ("`recode'"=="" | "`generate'"=="") {
		display as error "Copyrest can only be used with recode and generate options"
		error 198
	}

	* check sufficient sample size
	_nobs `touse' , min(1)

	* check sufficient sample size for each "by" group
    if `"`by'"' != "" {
		tempvar bygroup
        * Create by: groups
        egen `bygroup' = group(`by') 
        quietly: levelsof `bygroup' if `touse' , local(bylist)
    } 
    * No "by" option
    else {
        local bygroup 1
        local bylist  1
    }
	foreach group of local bylist {
		_nobs `touse' if `bygroup'==`group' , min(1)
		if "`missok'"!="" {
			foreach var of local varlist {
				quietly: count if `touse' & `bygroup'==`group' & `var'!=. 
				if (r(N)==0) {
					display as error "`var' has no non-missing observations (in some by-group)"
					error 2000
				} /* end if */
			} /* end foreach var */
		} /* end if */
	} /* end foreach group */
	
    * Fill in default trim percentiles 
    if ("`percentiles'"=="") { 
        local low  "1" 
        local high "99"
    }
    else {
        tokenize "`percentiles'"
        local low  "`1'"
        local high "`2'"
    } 

quietly { 

	* Temporary variables  
    tempvar isoutlier 
	tempname rval lowval highval

    * Initialize tempvar to mark outliers 
    gen byte `isoutlier'=0 if `touse'

	* Initialize in-sample tempvars to recode
	local recodevarlist 
	foreach var of local varlist {
		tempvar recodevar
		gen `recodevar' = `var' if `touse'
		local recodevarlist `recodevarlist' `recodevar'
	}

	foreach var of local recodevarlist {
    	foreach group of local bylist {
            * Get high and low cut-off values
            if (`low'>0) {
                _pctile `var' if `touse' & `bygroup'==`group' , p(`low')
                scalar `lowval' = r(r1)
            }
            if (`high'<100) {
                _pctile `var' if `touse' & `bygroup'==`group' , p(`high')
                scalar `highval' = r(r1)
            }

            * Get recode values
            if      "`recode'" == "miss"    scalar `rval' = . 

            else if "`recode'" == "median" { 
                _pctile `var' if `touse' & `bygroup'==`group' , p(50)
                scalar `rval' = r(r1)
            }
            else if "`recode'" == "mean" { 
                sum `var' if `touse' & `bygroup'==`group' , meanonly
                scalar `rval' = r(mean)
            }
            
            * Mark and recode lower bound
            if (`low'>0) {
                replace `isoutlier'=1 if `var'<`lowval' & `touse' & `bygroup'==`group' & !missing(`var')
                if "`recode'" != "" {
                    if "`recode'" == "bound" scalar `rval' = `lowval' 

                    replace `var' = `rval' if `var'<`lowval' & `touse' & `bygroup'==`group' & !missing(`var')
                }
            }
 
            * Mark and recode upper bound
            if (`high'<100) {
                replace `isoutlier'=1 if `var'>`highval' & `touse' & `bygroup'==`group' & !missing(`var')
                if "`recode'" != "" {
                    if "`recode'" == "bound" scalar `rval' = `highval' 

                    replace `var' = `rval' if `var'>`highval' & `touse' & `bygroup'==`group' & !missing(`var')
                }
            }

    	} /* end by group loop */
	} /* end varlist loop */
   
    if "`mark'"!="" gen `mark'=`isoutlier' if `touse'
	
	if "`recode'" != "" {
		if "`replace'" != "" {
			foreach var of local varlist {
				gettoken recodevar recodevarlist : recodevarlist
				replace `var' = `recodevar' if `touse'
			}
		} /* end if */
		else if "`generate'" != "" {
			foreach newvar of local newvarlist {
				gettoken var varlist : varlist
				gettoken recodevar recodevarlist : recodevarlist
				gen `newvar' = `recodevar'  
				if "`copyrest'"=="copyrest" {
					replace `newvar' = `var' if `touse'==0
				}
			}
		} /* end else if */
	} /* end if recode */
 
    sum `isoutlier' if `touse'
 } /* end quietly */
    display _n as text "Note: " r(sum) " observations, or " %3.1f = r(mean)*100 "% of evaluation sample are outliers"

end



	
