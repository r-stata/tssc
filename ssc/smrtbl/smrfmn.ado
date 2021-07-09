*! 2.0.0 Adam Ross Nelson 10mar2018 // Made ifable, inable, and byable.
*! 1.0.3 Adam Ross Nelson 29jan2018 // Corrected type mismatch error.
*! 1.0.2 Adam Ross Nelson 01jan2018 // Added error checing for desc option.....
*! 1.0.1 Adam Ross Nelson 20nov2017 // Merged smrfmn, smrcol, and smrtbl to same package.
*! 1.0.0 Adam Ross Nelson 19nov2017 // Original version.
*! Original author : Adam Ross Nelson
*! Description     : Produces table of means filtered by list of indicators (through putdocx).
*! Maintained at   : https://github.com/adamrossnelson/smrput

capture program drop smrfmn
program smrfmn
	
	version 15
	syntax varlist(min=2 numeric) [if] [in] [, NOCond DESCription(string) TItle(string)]

	// Test for an active putdocx.
	capture putdocx describe
	if _rc {
		di as error "ERROR: No active docx."
		exit = 119
	}

	// Test that subsample with temp var touse is not empty.
	marksample touse
	quietly count if `touse'
	if `r(N)' == 0 {
		di as error "ERROR: No observations after if or in qualifier."
		error 2000
	}

	// Test that variables (after first) are binary 0 or 1.
	local argcnt : word count `varlist'
	forvalues cntr = 2/`argcnt' {
		local cntr = subinstr("``cntr''",",","",.)
		qui sum `cntr'
		capture assert `cntr' == 1 | `cntr' == 0 | `cntr' == .
		if _rc {
			di as error "ERROR: Inidcator variables must be numberic & binary."
			exit = 452
		}
	}
	
	preserve
	qui keep if `touse'

	putdocx paragraph
	putdocx text ("Table title: ")
	if "`title'" == "" {
		local title = "filtered_means_of_`1'_table"
	}
	putdocx text ("`title'"), italic linebreak
	if "`description'" == "" {
		local description = "smrfmn generated _`1'_tbl varlist : `varlist'"
	}
	putdocx text ("Description: `description'")
	smrgivconditions `if' `in', `nocond'
	local totrows = `argcnt'
	putdocx table filt_means_`1'_tbl = (`totrows',6)
	putdocx table filt_means_`1'_tbl(1,2) = ("Ind = 1"), halign(center)
	putdocx table filt_means_`1'_tbl(1,3) = ("Mean, Median, S.D."), halign(center)
	putdocx table filt_means_`1'_tbl(1,4) = ("25pctl, 75pctl"), halign(center)
	putdocx table filt_means_`1'_tbl(1,5) = ("Trimmed Mean, Median, S.D."), halign(center)
	putdocx table filt_means_`1'_tbl(1,6) = ("Min, Max"), halign(center)
	local cntrow = 2
	forvalues cntr = 2/`argcnt' {
		local cntr = subinstr("``cntr''",",","",.)
		local vardesc: variable label `cntr'
		// Handle variables with empty variable label.  If no label, provide generic.
		if "`vardesc'" == "" {
			local vardesc = "Varname: `cntr'"
		}
		qui {
			putdocx table filt_means_`1'_tbl(`cntrow',1) = ("`vardesc'"), halign(center)
			count if `cntr' == 1
			putdocx table filt_means_`1'_tbl(`cntrow',2) = (`r(N)'), halign(center)
			sum `1' if `cntr' == 1, detail
			putdocx table filt_means_`1'_tbl(`cntrow',3) = ( ///
			string(r(mean),"%-10.2f") +  ///
			string(r(p50),"%-10.2f") + ///
			string(r(sd),"%-10.2f")), halign(center)
			putdocx table filt_means_`1'_tbl(`cntrow',4) = ( ///
			string(r(p25),"%-10.2f") + ///
			string(r(p75),"%-10.2f")), halign(center)
			sum `1' if `cntr' == 1 & (`1' >= r(p25) & `1' <= r(p75)), detail
			putdocx table filt_means_`1'_tbl(`cntrow',5) = ( ///
			string(r(mean),"%-10.2f") + ///
			string(r(p50),"%-10.2f") + ///
			string(r(sd),"%-10.2f")), halign(center)
			sum `1' if `cntr' == 1
			putdocx table filt_means_`1'_tbl(`cntrow',6) = ( ///
			string(r(min),"%-10.2f") + ///
			string(r(max),"%-10.2f")), halign(center)
			local cntrow = `cntrow' + 1
		}
	}
	
	restore
	
	di "smrfmn Table production successful. Table named: filtered_means_of_`1'_table"

end

