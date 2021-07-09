*! -stcomlist- version 1.3 Phil Clayton 2016-01-11
* wrapper for stcompet that lists cumulative incidence function at specific
* times, +/- by a stratifying variable

* phil clayton

* 2016-01-11	Version 1.3 - allow noci option for increased speed
* 2014-09-25	Version 1.2 - allow by() variable to be string
*							  at() now optional
* 2014-05-01	Version 1.1 - use marksample, fixes bug with using if/in
* 2014-04-14	Version 1.0

capture program drop stcomlist
program define stcomlist, sortpreserve
	version 11
	syntax [if] [in] , COMPET1(numlist missingokay) /*
				*/	 [ COMPET2(numlist missingokay) /*
                */     COMPET3(numlist missingokay) /*
				*/	   COMPET4(numlist missingokay) /*
				*/	   COMPET5(numlist missingokay) /*
                */     COMPET6(numlist missingokay) /*
				*/	   at(numlist ascending >0) /*
				*/	   by(varname) ALLIGNol Level(integer $S_level) noci /*
				*/	   saving(string asis) ]
	
	marksample touse
	
	* ensure -stcompet- is installed
	capture which stcompet
	if _rc {
		di as error "stcomlist requires the SSC package -stcompet-"
		error 498
	}
	
	* determine if by() variable is string, and if so, its maximum length
	capture confirm string variable `by'
	if !_rc {
		local bystring str
		tempvar length
		quietly gen `length'=length(`by') if `touse'
		sum `length', meanonly
		local bylength=r(max)
		drop `length'
	}
	
	* calculate values using -stcompet- (SSC)
	tempvar cif se ub lb
	if "`ci'"=="" {
		stcompet `cif'=ci `se'=se `lb'=lo `ub'=hi if `touse', ///
			compet1(`compet1') compet2(`compet2') compet3(`compet3') ///
			compet4(`compet4') compet5(`compet5') compet6(`compet6') ///
			by(`by') `allignol' level(`level')
	}
	else {
		stcompet `cif'=ci if `touse', ///
			compet1(`compet1') compet2(`compet2') compet3(`compet3') ///
			compet4(`compet4') compet5(`compet5') compet6(`compet6') ///
			by(`by') `allignol'
	}
		
	* flag observations by observation number, sorted by time
	sort `touse' `by' _t
	tempvar group n
	quietly egen `group'=group(`by') if `touse'
	summarize `group', meanonly // now r(max) is the number of by-groups
	local groupcount=r(max)
	gen long `n'=_n
	
	* set up postfile if saving() option specified
	if `"`saving'"'!="" {
		tempname postout
		if "`ci'"=="" {
			postfile `postout' compet `bystring'`bylength' `by' ///
				_t cif se lb ub using `saving'
		}
		else {
			postfile `postout' compet `bystring'`bylength' `by' ///
				_t cif using `saving'
		}
	}

	* now loop through all types of failure given by the user
	local failcount=2
	forvalues i=2/6 {
		if "`compet`i''"!="" local failcount=`failcount' + 1
	}
	local compet0 `_dta[st_ev]'
	
	forvalues f=1/`failcount' {
	
		* show survival settings
		di
		if `f'>1 di
		di as text "            failure:  " ///
			as result "`_dta[st_bd]' == `compet`=`f'-1''"
		local faillist=subinstr("`compet`=`f'-1''", " ", ", ", .)
		forvalues i=0/6 {
			local c`i' `compet`i''
			if `f'==`=`i'+1' local c`i'
		}
		local comptext=itrim(trim("`c0' `c1' `c2' `c3' `c4' `c5' `c6'"))
		di as text " competing failures:  " ///
				as result "`_dta[st_bd]' == `comptext'"

		* heading
		di
		if "`ci'"=="" {
			di "    Time       CIF         SE     [`level'% Conf. Int.]"
			di "{hline 50}"
		}
		else {
			di "    Time       CIF"
			di "{hline 18}"
		}
		
		* now we loop through the by-groups and determine the CIF at each time
		tempname time cit set lbt ubt last_cit

		forvalues i=1/`groupcount' {
			* last_cit scalar records the previous CIF to prevent reporting
			* tied failure times over and over
			scalar `last_cit'=0
			
			* heading for the by-group if program is run with by()
			if "`by'"!="" {
				if "`bystring'"=="str" {
					summarize `n' if `group'==`i', meanonly
					di "`by'=" `by'[`r(mean)']
					local byval = `"""' + `by'[`r(mean)'] + `"""'
				}
				else {
					summarize `by' if `group'==`i', meanonly
					local byval=r(mean)
					di "`by'=`: label (`by') `byval''"
				}
			}
			
			* if at() is specified, report the CIF at each of those times
			local timevals `at'
			
			* if at() is not specified, report the CIF at the times it
			* increases
			if "`at'"=="" {
				quietly levelsof `n' if `group'==`i' & !missing(`cif') ///
					& inlist(`_dta[st_bd]', `faillist'), local(timevals)
			}
			
			* now loop through all the time points
			foreach t of numlist `timevals' {
				if "`at'"=="" {
					summarize `n' if `n'==`t', meanonly
					scalar `time'=_t[`r(max)']
				}
				else {
					summarize `n' if `group'==`i' & ///
						inlist(`_dta[st_bd]', `faillist') & _t<`t', meanonly
					scalar `time'=`t'
				}
				if r(N)>0 {
					scalar `cit'=`cif'[`r(max)']
					if "`ci'"=="" {
						scalar `set'=`se'[`r(max)']
						scalar `lbt'=`lb'[`r(max)']
						scalar `ubt'=`ub'[`r(max)']
					}
				}
				else {
					scalar `cit'=.
					if "`ci'"=="" {
						scalar `set'=.
						scalar `lbt'=.
						scalar `ubt'=.
					}
				}
				
				* if the CIF has increased then we'll report +/- save it
				* if at() has been specified then we'll report the CIF even if
				* it hasn't increased
				if `cit'>`last_cit' | "`at'"!="" {
					if "`ci'"=="" {
						di %8.0g `time' "    " %5.4f `cit' "     " %5.4f `set' "     " ///
							%5.4f `lbt' "    " %5.4f `ubt'
					}
					else {
						di %8.0g `time' "    " %5.4f `cit'
					}
					
					* save if requested
					if `"`saving'"'!="" {
						if "`by'"!="" {
							if "`ci'"=="" {
								post `postout' ///
									(`=`f'-1') (`byval') (`t') (`cit') ///
									(`set') (`lbt') (`ubt')
							}
							else {
								post `postout' ///
									(`=`f'-1') (`byval') (`t') (`cit')
							}
						}
						else {
							if "`ci'"=="" {
								post `postout' ///
									(`=`f'-1') (`time') (`cit') (`set') (`lbt') (`ubt')
							}
							else {
								post `postout' ///
									(`=`f'-1') (`time') (`cit')
							}
						}
					}
				}
				
				* update latest CIF
				scalar `last_cit'=`cit'
			}
		}
	
	} // end loop over competing outcomes
	
	if `"`saving'"'!="" {
		postclose `postout'
	}	
end

