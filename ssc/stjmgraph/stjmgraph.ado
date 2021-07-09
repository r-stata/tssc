*! version 1.0.4 21apr2015 MJC

/*
History
MJC 21apr2015: version 1.0.4 - adjust, nodata options added
MJC 09aug2012: version 1.0.3 - added indcensgraphopts() and indeventgraphopts().
MJC 01jun2012: version 1.0.2 - lowess option added.
MJC 14oct2011: version 1.0.1 - Help file improved and example dataset changed.
MJC 12oct2011: version 1.0.0
*/

program define stjmgraph, sortpreserve
version 11.2
	st_is 2 analysis
	syntax varlist(min=1 max=1) [if] [in], 									///
											Panel(varname) 					///
																			///
											[								///
												CENSGraphopts(string)		///
												INDCENSGraphopts(string)	///
												EVENTGraphopts(string)		///
												INDEVENTGraphopts(string)	///
												COMBINEopts(string)			///
												ADJUST						///
												DRAW						///
												LOWess						///
												NOdata						///
											]
	
	tokenize `varlist'
	
	marksample touse
	
	if "`nodata'"!="" & "`lowess'"=="" {
		di as error "nodraw can only be used with lowess"
		exit 198
	}
	
	if "`draw'"=="" {
		local nodraw "nodraw"
	}
	
	
	quietly{
		sort `panel' _t0
		preserve
			drop if `touse'!=1
			tempvar _lagtime _died tempid
			if "`adjust'"!="" {
				local defaultxtitle `"xtitle("Time before censoring")"'
				bys `panel': gen `_lagtime' = _t-_t[_N] if `touse'==1
			}
			else {
				local defaultxtitle `"xtitle("Measurement time")"'
				gen `_lagtime' = _t0 if `touse'==1
			}
			bys `panel': gen `_died' = 0 if _d[_N]==0 & `touse'==1
			bys `panel': replace `_died' = 1 if _d[_N]==1 & `touse'==1
			local line_cens
			keep if `_died'==0 & `touse'==1
			egen `tempid' = group(`panel')
			su `tempid' if `touse'==1, mean
			local n=r(max)
			if "`lowess'"=="" {
				forvalues i=1/`n' {
					local line_cens "`line_cens' (line `1' `_lagtime' if `tempid'==`i' &`touse'==1, lcol(black) lpat(solid) `indcensgraphopts')"
				}
			}
			else {
				if "`nodata'"=="" {
					forvalues i=1/`n' {
						local line_cens "`line_cens' (line `1' `_lagtime' if `tempid'==`i' &`touse'==1, lcol(gray*0.6) lpat(solid) `indcensgraphopts')"
					}
				}
				local line_cens "`line_cens' (lowess `1' `_lagtime' if `touse', lwidth(thick) lcol(black) lpat(solid))"
			}

			tempname jmg1 jmg2
			twoway `line_cens', legend(off) `defaultxtitle' ytitle("Longitudinal response") title("Censored") name(`jmg1') `nodraw' plotregion(margin(zero)) `censgraphopts'
		restore
		preserve
			drop if `touse'!=1
			tempvar _lagtime _died tempid
			if "`adjust'"!="" {
				local defaultxtitle `"xtitle("Time before event")"'
				bys `panel': gen `_lagtime' = _t-_t[_N] if `touse'==1
			}
			else {
				local defaultxtitle `"xtitle("Measurement time")"'
				gen `_lagtime' = _t0 if `touse'==1			
			}
			bys `panel': gen `_died' = 0 if _d[_N]==0 & `touse'==1
			bys `panel': replace `_died' = 1 if _d[_N]==1 & `touse'==1
			local line_cens
			keep if `_died'==1 & `touse'==1
			egen `tempid' = group(`panel') if `touse'==1
			su `tempid' if `touse'==1, mean
			local n=r(max)
			if "`lowess'"=="" {
				forvalues i=1/`n' {
					local line_cens "`line_cens' (line `1' `_lagtime' if `tempid'==`i' &`touse'==1, lcol(black) lpat(dash) `indeventgraphopts')"
				}
			}
			else {
				if "`nodata'"=="" {
					forvalues i=1/`n' {
						local line_cens "`line_cens' (line `1' `_lagtime' if `tempid'==`i' &`touse'==1, lcol(gray*0.6) lpat(dash) `indeventgraphopts')"
					}
				}
				local line_cens "`line_cens' (lowess `1' `_lagtime' if `touse', lwidth(thick) lcol(black) lpat(dash))"
			}

			twoway `line_cens', legend(off) `defaultxtitle' ytitle("Longitudinal response") title("Event") name(`jmg2') `nodraw' plotregion(margin(zero)) `eventgraphopts'
			
			graph combine `jmg1' `jmg2', ycommon xcommon `combineopts'
		restore	
	}

end
