*! version 0.4  24apr2015

*-------------------------------------------------------------------------------
*            
*  Recommended citation (APA Style, 6th ed.): 
*  Roßmann, J. (2015): RSPEEDINDEX: Computation of a response speed index and 
*  outlier identification (Version: 0.4) [Computer Software]. 
*  Chestnut Hill, MA: Boston College.
*
*-------------------------------------------------------------------------------

program rspeedindex
version 12.1
syntax varlist(numeric) [if] [in], INDEXname(string) FLAGname(string) [MISSing(numlist miss)] CUToffmethod(string) [LOwercutoff(numlist max=1 >=0 <=99)] [UPpercutoff(numlist max=1 >=0 <=99)] [QUIetly]

*--- Check input ---*
if "`flagname"!="" & "`cutoffmethod'"!="percent" & "`cutoffmethod'"!="mean" & "`cutoffmethod'"!="absolute" {
	dis as error "Option cutoffmethod must either be 'percent', 'mean', or 'absolute'."
	exit
}

if "`cutoffmethod'"=="percent" {
	if "`lowercutoff'"!="" & "`uppercutoff'"=="" {
		if (`lowercutoff'!=1 & `lowercutoff'!=5 & `lowercutoff'!=10 & `lowercutoff'!=25) {
			dis as error "If cutoffmethod is 'percent', lowercutoff has to be 1, 5, 10, or 25."
			exit
		}
	}
	else if "`lowercutoff'"=="" & "`uppercutoff'"!="" {
		if (`uppercutoff'!=75 & `uppercutoff'!=90 & `uppercutoff'!=95 & `uppercutoff'!=99) {
			dis as error "If cutoffmethod is 'percent', uppercutoff has to be 75, 90, 95, or 99."
			exit
		}
	}
	else if "`lowercutoff'"!="" & "`uppercutoff'"!="" {
		if (`lowercutoff'!=1 & `lowercutoff'!=5 & `lowercutoff'!=10 & `lowercutoff'!=25) | ///
			(`uppercutoff'!=75 & `uppercutoff'!=90 & `uppercutoff'!=95 & `uppercutoff'!=99) {
			dis as error "If cutoffmethod is 'percent', lowercutoff has to be 1, 5, 10, or 25 and uppercutoff has to be 75, 90, 95, or 99."
			exit
		}
	}
}

if "`cutoffmethod'"=="mean" {
	if "`lowercutoff'"!="" & "`uppercutoff'"=="" {
		if (`lowercutoff'<0 | `lowercutoff'>5) {
			dis as error "If cutoffmethod is 'mean', lowercutoff should be in the range of 0 >= x <= 5."
			exit
		}
	}
	else if "`lowercutoff'"=="" & "`uppercutoff'"!="" {
		if (`uppercutoff'<0 | `uppercutoff'>5) {
			dis as error "If cutoffmethod is 'mean', uppercutoff should be in the range of 0 >= x <= 5."
			exit
		}
	}
	else if "`lowercutoff'"!="" & "`uppercutoff'"!="" {
		if (`lowercutoff'<0 | `lowercutoff'>5) | ///
			(`uppercutoff'<0 | `uppercutoff'>5) {
			dis as error "If cutoffmethod is 'mean', lower- and uppercutoff should be in the range of 0 >= x <= 5."
			exit
		}
	}
}

if "`cutoffmethod'"=="absolute" {
	if "`lowercutoff'"!="" & "`uppercutoff'"=="" {
		if (`lowercutoff'<0 | `lowercutoff'>1) {
			dis as error "If cutoffmethod is 'absolute', lowercutoff should be in the range of 0 >= x <= 1."
			exit
		}
	}
	else if "`lowercutoff'"=="" & "`uppercutoff'"!="" {
		if (`uppercutoff'<1 | `uppercutoff'>2) {
			dis as error "If cutoffmethod is 'absolute', uppercutoff should be in the range of 1 >= x <= 2."
			exit
		}
	}
	else if "`lowercutoff'"!="" & "`uppercutoff'"!="" {
		if (`lowercutoff'<0 | `lowercutoff'>1) | ///
			(`uppercutoff'<1 | `uppercutoff'>2) {
			dis as error "If cutoffmethod is 'absolute', lowercutoff should be in the range of 0 >= x <= 1 and uppercutoff in the range of 1 >= x <= 2."
			exit
		}
	}
}

*--- Optional if-condition ---*
	marksample touse, novarlist

*--- Speeder index for item or page level response times ---*
	tempvar tempvar values npages rspeedindex error
	quietly gen `tempvar'=0 if `touse'
	quietly gen `npages'=0 if `touse'
	quietly gen `values'=0 if `touse'
	quietly gen `rspeedindex'=0 if `touse'
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
		quietly replace `npages'=`npages'+1 if `tempvar'!=. & `touse'
		if "`quietly'"=="" {
			sum `values'
			}
		quietly sum `values'
		quietly replace `error'=1 if (r(min)<0 | r(max)>2) & r(max)!=.
		quietly replace `rspeedindex'=`rspeedindex'+`values' if `values'!=. & `touse'
		}
	quietly replace `rspeedindex'=`rspeedindex'/`npages' if `rspeedindex'!=. & `npages'!=. & `touse'
	quietly sum `rspeedindex'
	quietly replace `error'=1 if (r(min)<0 | r(max)>2) & r(max)!=.
	quietly gen `indexname' = `rspeedindex' if `touse'
	lab var `indexname' "Response speed index"
	quietly sum `indexname'
	quietly replace `error'=1 if (r(min)<0 | r(max)>2) & r(max)!=.
	quietly replace `error'=1 if (r(mean)<.95 | r(mean)>1.05) & r(max)!=.
	
*--- Generate flag variable ---*
	quietly gen `flagname'=0 if `touse'
	if "`cutoffmethod'"=="percent" & "`lowercutoff'"!="" & "`uppercutoff'"=="" {
		quietly sum `indexname' if `touse', d
		quietly replace `flagname'=1 if `indexname'<=r(p`lowercutoff') & `touse'
		}
	else if "`cutoffmethod'"=="percent" & "`lowercutoff'"!="" & "`uppercutoff'"!="" {
		quietly sum `indexname' if `touse', d
		quietly replace `flagname'=1 if `indexname'<=r(p`lowercutoff') & `touse'
		quietly replace `flagname'=1 if `indexname'>=r(p`uppercutoff') & `touse'
		}
	else if "`cutoffmethod'"=="percent" & "`lowercutoff'"=="" & "`uppercutoff'"!="" {
		quietly sum `indexname' if `touse', d
		quietly replace `flagname'=1 if `indexname'>=r(p`uppercutoff') & `touse'
		}
	else if "`cutoffmethod'"=="mean" & "`lowercutoff'"!="" & "`uppercutoff'"=="" {
		quietly sum `indexname' if `touse', d
		quietly replace `flagname'=1 if `indexname'<=(r(mean)-`lowercutoff'*r(sd)) & `touse'
		}
	else if "`cutoffmethod'"=="mean" & "`lowercutoff'"!="" & "`uppercutoff'"!="" {
		quietly sum `indexname' if `touse', d
		quietly replace `flagname'=1 if `indexname'<=(r(mean)-`lowercutoff'*r(sd)) & `touse'
		quietly replace `flagname'=1 if `indexname'>=(r(mean)+`uppercutoff'*r(sd)) & `touse'
		}
	else if "`cutoffmethod'"=="mean" & "`lowercutoff'"=="" & "`uppercutoff'"!="" {
		quietly sum `indexname' if `touse', d
		quietly replace `flagname'=1 if `indexname'>=(r(mean)+`uppercutoff'*r(sd)) & `touse'
		}
	else if "`cutoffmethod'"=="absolute" & "`lowercutoff'"!="" & "`uppercutoff'"=="" {
		quietly sum `indexname' if `touse', d
		quietly replace `flagname'=1 if `indexname'<=`lowercutoff' & `touse'
		}
	else if "`cutoffmethod'"=="absolute" & "`lowercutoff'"!="" & "`uppercutoff'"!="" {
		quietly sum `indexname' if `touse', d
		quietly replace `flagname'=1 if `indexname'<=`lowercutoff' & `touse'
		quietly replace `flagname'=1 if `indexname'>=`uppercutoff' & `touse'
		}
	else if "`cutoffmethod'"=="absolute" & "`lowercutoff'"=="" & "`uppercutoff'"!="" {
		quietly sum `indexname' if `touse', d
		quietly replace `flagname'=1 if `indexname'>=`uppercutoff' & `touse'
		}
		
	lab var `flagname' "Response speed outlier"
	lab def `flagname' 0 "Other" 1 "Outlier", replace
	lab val `flagname' `flagname'
				
*--- Option: QUIetly 
if "`quietly'"=="" {
	quietly sum `error'
		if r(min)==1 {
			dis as error "An error occured. Please check input and results."
			}
		sum `npages' `indexname' `flagname' 
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
