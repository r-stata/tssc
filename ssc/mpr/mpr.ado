*! 1.1.0 Ariel Linden 20Oct2018	// made touse more efficient
								// changed fill_end_dt to include -1
								// changed supply to include +1
								// added labels to output variable
*! 1.0.0 Ariel Linden 28Sep2018         

program define mpr
version 11.0

	syntax varlist(min=2 max=2 numeric) [if] [in] ,		///
			[ID (string)								/// for multiple panels in data
			DRug(string)								/// for multiple drug types in data
			STArt(string)								/// study start-date must be in DMY format (e.g. 01jan2013)
			LENgth(numlist int max=1 >0)				///
			END(string)									/// study end-date must be in DMY format (e.g. 12dec2013)
			NOCOLL										/// no collapse - undocumented
			]                               

	quietly {
        
		// Get filldate and days_supply variables
		gettoken filldate daysup : varlist
        
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		keep if `touse' 
		keep `id' `drug' `filldate' `daysup'

		/* Generate the date when the current Rx runs out */
		gen fill_end_dt = `filldate' + `daysup' - 1
		format fill_end_dt %td
		
		/* Case types (base-case is single ID, single drug) */
		* Single ID, multiple drugs *
		if "`id'" == "" & "`drug'" != "" {
			local bydrug "bys `drug' (`filldate') : "
		}
		* Multiple IDs, single drug *
		else if "`id'" != "" & "`drug'" == "" {
			local byid "bys `id' (`filldate') : "
		}
		* Multiple IDs and multiple drugs *
		else if "`id'" != "" & "`drug'" != "" {
			local byiddrug "bys `id' `drug' (`filldate') : "
		}

		*******************************
		/* Generate study start date */
		*******************************
		if "`start'" !="" {
			if length("`start'") < 9  {
				di as err "start() requires 9 characters, e.g. 01jan2013"
				exit 198
			}
			local start1 = lower(substr("`start'", 3, 1))

			if !index("jfmasond", "`start1'") {
				di as err "Start() must contain a valid 3-letter month"
				exit 198
			}
			gen study_start_dt = td("`start'")
		} // end if start != ""
		
		* If start is not specified, use first filldate
		else if "`start'" =="" {
			* Single ID, single drug
			if "`id'" == "" & "`drug'" == "" {
				sum `filldate', meanonly
				gen study_start_dt = r(min)
			}
			* Single ID, multiple drugs
			else if "`id'" == "" & "`drug'" != "" {
				`bydrug' gen study_start_dt = `filldate'[1]
			}
			* Multiple IDs, single drug *
			else if "`id'" != "" & "`drug'" == "" {
				`byid' gen study_start_dt = `filldate'[1]
			}
			* Multiple IDs and multiple drugs *
			else if "`id'" != "" & "`drug'" != "" { 
				`byiddrug' gen study_start_dt = `filldate'[1]
			}
		} // end if start == ""
		format study_start_dt %td

		*****************************
		/* Generate study end date */
		*****************************
		* If end and length are specified, generate error
		if "`end'" !="" & "`length'" != "" {
				di as err "either end() or length() may be specified, but not both"
				exit 198
		}
		* Verify date is correctly specified
		if "`end'" !="" {
			if length("`end'") < 9  {
				di as err " end() requires 9 characters, e.g. 31dec2013"
				exit 198
			}
			local end1 = lower(substr("`end'", 3, 1))

			if !index("jfmasond", "`end1'") {
				di as err "`end' must contain a valid 3-letter month"
				exit 198
			}
			gen study_end_dt = td("`end'")
		} // end if end != ""

		* If end and length are not specified, use fill_end_dt (filldate + days supply)
		if "`end'" =="" & "`length'" == "" {
			* Single ID, single drug *
			if "`id'" == "" & "`drug'" == "" {
				sum fill_end_dt, meanonly
				gen study_end_dt = r(max)
			}
			* Single ID, multiple drugs *
			else if "`id'" == "" & "`drug'" != "" {
				`bydrug' gen study_end_dt = fill_end_dt[_N]
			}
			* Multiple IDs, single drug *
			else if "`id'" != "" & "`drug'" == "" {
				`byid' gen study_end_dt = fill_end_dt[_N]
			}
			* Multiple IDs and multiple drugs *
			else if "`id'" != "" & "`drug'" != "" { 
				`byiddrug' gen study_end_dt = fill_end_dt[_N]
			}
		} // end if end == "" & "`length'" == ""
		
		* If only length is specified, compute end date using start date and length
		if "`end'" == "" & "`length'" != "" {
			gen study_end_dt = (study_start_dt + `length') -1
		}
		format study_end_dt %td
	
		*****************************
		/* Compute Rx supply on hand */
		*****************************
		gen supply = .

		* Before study starts (not needed, but added here for completeness)
		replace supply = . if fill_end_dt < study_start_dt

		* Covers cases where first fill was before or after study starts and ends before study ends 
		replace supply = (fill_end_dt - max( study_start_dt, `filldate' ) + 1) if fill_end_dt >= study_start_dt & fill_end_dt <= study_end_dt
		
		* Covers cases where last fill was before end of study but carries on afterwards
		replace supply = (study_end_dt - `filldate') + 1 if fill_end_dt > study_end_dt & `filldate' <= study_end_dt
		
		******************************
		/* Collapse and compute MPR */
		******************************
		if "`nocoll'" != "" {
			exit
		}
		else if "`nocoll'" == "" {
		* Single ID, single drug *
			if "`id'" == "" & "`drug'" == "" {
				collapse (min) study_start_dt (max) study_end_dt (sum) supply
			}
			* Single ID, multiple drugs *
			else if "`id'" == "" & "`drug'" != "" {
				collapse (min) study_start_dt (max) study_end_dt (sum) supply, by(`drug')
			}
			* Multiple IDs, single drug *
			else if "`id'" != "" & "`drug'" == "" {
				collapse (min) study_start_dt (max) study_end_dt (sum) supply, by(`id')
			}
			* Multiple IDs and multiple drugs *
			else if "`id'" != "" & "`drug'" != "" { 
				collapse (min) study_start_dt (max) study_end_dt (sum) supply, by(`id' `drug')
			}
	
			gen study_days = (study_end_dt - study_start_dt) + 1
			order study_days, after(study_end_dt) // for consistent layout with PDC
			gen mpr = supply/ study_days
			label var study_start_dt "Start of observation period"
			label var study_end_dt "End of observation period"
			label var study_days "Number of days in observation period"
			label var supply "Total supply on hand"
			label var mpr "Medication Possession Ratio"			
		} // end "nocoll == ""
	} // end quietly	

end	
