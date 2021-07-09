*! 1.1.0 Ariel Linden 15Apr2019 || Changed the "credit" option to shift the next refill to start the day after the last refill is exhausted   
*! 1.0.0 Ariel Linden 17Oct2018         

program define pdc
version 11.0

	syntax varlist(min=2 max=2 numeric) [if] [in] ,		///
			[ID (string)								/// for multiple panels in data
			DRug(string)								/// for multiple drug types in data
			STArt(string)								/// study start-date must be in DMY format (e.g. 01jan2013)
			LENgth(numlist int max=1 >0)				///
			END(string)									/// study end-date must be in DMY format (e.g. 12dec2013)
			CREDit										/// shift filldates to avoid overlap
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
				sum `filldate' , meanonly
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
				sum fill_end_dt , meanonly
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

		*******************************
		/* Reshape from long to wide */
		*******************************
		* Single ID, single drug
		if "`id'" == "" & "`drug'" == "" {
			tempvar i n
			gen `i' = 1
			gen `n' = _n
			sum `n', meanonly
			local fillmax = r(max)
			reshape wide `filldate' `daysup' fill_end_dt , i( `i' ) j( `n')
		}
		* Single ID, multiple drug
		if "`id'" == "" & "`drug'" != "" {
			tempvar n
			`bydrug' gen `n' = _n	
			sum `n', meanonly
			local fillmax = r(max)
			reshape wide `filldate' `daysup' fill_end_dt , i(`drug') j(`n')
		}
		* Multiple IDs, single drug *
		else if "`id'" != "" & "`drug'" == "" {
			tempvar n
			`byid' gen `n' = _n	
			sum `n', meanonly
			local fillmax = r(max)
			reshape wide `filldate' `daysup' fill_end_dt , i(`id') j( `n')
		}
		* Multiple IDs, multiple drugs *
		else if "`id'" != "" & "`drug'" != "" { 
			tempvar n
			`byiddrug' gen `n' = _n	
			sum `n', meanonly
			local fillmax = r(max)
			reshape wide `filldate' `daysup' fill_end_dt, i( `id' `drug' ) j(`n')
		}
		
		***********************************************
		/* Generate daily tallies of drug possession */
		***********************************************
		gen study_days = (study_end_dt - study_start_dt) + 1
		sum study_days, meanonly
		local obsmax = r(max)
		
		* Shift filldate to avoid overlapping days
		if "`credit'" != "" {
			forval u = 2/`fillmax' {
				local v = `u' - 1
				replace `filldate'`u' = fill_end_dt`v' + 1 if `filldate'`u' <= fill_end_dt`v'
				replace fill_end_dt`u' = (`filldate'`u' + `daysup'`u' - 1)
			}
		}
		* Generate day dummies = 0 to represent observation days 
		forval i = 1/`obsmax' {
			gen Day`i' = 0
		}
		* Replace the day dummies = 1 if they correspond to days with medication on hand
		forval i = 1/`obsmax' {
			forval ii = 1/`fillmax' {
				replace Day`i' = 1 if (study_start_dt + `i' - 1) >= `filldate'`ii'  & (study_start_dt + `i' - 1) <= min((fill_end_dt`ii'), study_end_dt)

			}
		}

		egen supply = rowtotal(Day*)

		if "`nocoll'" != "" {
			exit
		}
		else if "`nocoll'" == "" {
		* Single ID, single drug *
			if "`id'" == "" & "`drug'" == "" {
				keep study_start_dt study_end_dt supply study_days
			}
			* Single ID, multiple drugs *
			else if "`id'" == "" & "`drug'" != "" {
				keep `drug' study_start_dt study_end_dt supply study_days
			}
			* Multiple IDs, single drug *
			else if "`id'" != "" & "`drug'" == "" {
				keep `id' study_start_dt study_end_dt supply study_days
			}
			* Multiple IDs and multiple drugs *
			else if "`id'" != "" & "`drug'" != "" { 
				keep `id' `drug' study_start_dt study_end_dt supply study_days
			}
	
			gen pdc = supply/ study_days
			label var study_start_dt "Start of observation period"
			label var study_end_dt "End of observation period"
			label var study_days "Number of days in observation period"
			label var supply "Total supply on hand"
			
			if "`credit'" != "" {
				label var pdc "Proportion of days covered - with credit"	
			}
			else {
				label var pdc "Proportion of days covered"
			}	
				
		} // end "nocoll == ""
		
	} // quietly
end	

