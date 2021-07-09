*! 1.0.0 Ariel Linden 18nov2019

program define metafrag, rclass
version 16.0

	syntax  [,	///
		FORest	FORest2(str asis) /// plot forestplot
		EForm	/// exponentiated
	* ]                    

	qui { 
		preserve
	
		/* Ensure that data are meta set */
		cap confirm variable _meta_es _meta_se
		if _rc {
			di as err "data not {bf:meta} set"
			di as err "{p 4 4 2}You must declare your meta-analysis " "data using {helpb meta esize}.{p_end}"
			exit 119
		}
	
		/* Extract chars from -meta esize- */
		local datatype "`_dta[_meta_datatype]'"
		local cmdlne "`_dta[_meta_setcmdline]'"
		local events1  "`_dta[_meta_n11var]'"
		local nonevents1 "`_dta[_meta_n12var]'"
		local events2 "`_dta[_meta_n21var]'"
		local nonevents2 "`_dta[_meta_n22var]'"
		local ifexp "`_dta[_meta_ifexp]'"
		local inexp "`_dta[_meta_inexp]'"
		local estype "`_dta[_meta_estype]'"
		local vars "`_dta[_meta_datavars]'"

		/* Ensure that data are binary */
		if "`datatype'" != "binary" {
			di as err "{p}invalid {bf:meta esize()} specification: specify {bf:lnoratio}, " "{bf:lnrratio}, {bf:rdiff}, or {bf:lnorpeto}{p_end}"
			exit 184
		}

		/* assess model choice and eform */
		if "`estype'" == "rdiff" | "`eform'" == "" {
			local border = 0
		}
		else local border = 1
		
		/* keep observations meeting [if][in] expression used in -meta esize- */
		tempvar touse
		gen `touse' = 1 `ifexp' `inexp'
		keep if `touse' == 1
		
		/* rerun meta esize using cmdline stripped of [if/in] */
		local right = reverse("`cmdlne'")
		local right = substr("`right'", 1, strpos("`right'", ",") - 1)
		local right = reverse("`right'")

		local cleancmd meta esize `vars', `right'
		`cleancmd'
		
		meta summarize, `eform'
		
		/* Exponentiate stats if eform */
		if "`eform'" != "" {
			local init = exp(r(theta)) // initial pooled esize (exponentiated)
			local ci_up = exp(r(ci_ub)) // initial upper CI
			local ci_low = exp(r(ci_lb)) // initial lower CI
		}
		else {
			local init = r(theta) // initial pooled esize (exponentiated)
			local ci_up = r(ci_ub) // initial upper CI
			local ci_low = r(ci_lb) // initial lower CI
		}
		
		tempvar alt_events1 alt_noevents1 alt_events2 alt_noevents2 add subt
		gen `alt_events1' = `events1'
		gen `alt_noevents1' = `nonevents1'
		gen `alt_events2' = `events2'
		gen `alt_noevents2' = `nonevents2'

		gen double `add' = .
		gen double `subt' = .

		local frag = 0

		count
		local N = r(N)
	} // end qui
		di _n
		di as txt "Computing the fragility index. Please wait..."
	qui {
		
		*******************************************************
		* if the upper CI is less than 1 (eform) or 0 (linear)
		*******************************************************
		if `init' < `border' {

			while `ci_up' <  `border' {

				* Add events to first group of each study
				forval i = 1/`N' {
					replace `events1' in `i' =  `events1'[`i'] + 1 if `events1'[`i'] <= (`events1'[`i'] + `nonevents1'[`i']) // add 1 event if events <= N1
					replace `events1' in `i' = 0 if `events1'[`i'] > (`events1'[`i'] + `nonevents1'[`i']) // switch events to 0 if they are > N1
					replace `nonevents1' in `i' =  `nonevents1'[`i'] - 1 // subtract 1 from Group 1 non-events to ensure N1 is always the same
					replace `nonevents1' in `i' =  0 if `nonevents1'[`i'] <= 0 // witch events to 0 if they equal 0
					`cleancmd'
					meta summarize, `eform'
					if "`eform'" != "" {
						local ucl = exp(r(ci_ub)) // get exponentiated upper CI
					}
					else local ucl = r(ci_ub)
					replace `add' in `i' = `ucl' // post CI to related study ID
					replace `events1' in `i' =  `alt_events1'[`i'] // return test events to original value
					replace `nonevents1' in `i' = `alt_noevents1'[`i'] // return test non-events to original value
				} //  end forval add

				* Subtract events from second group of each study
				forval i = 1/`N' {
					replace `events2' in `i' =  `events2'[`i'] - 1 if `events2'[`i'] > 0 // subtract 1 event if events > 0 
					replace `events2' in `i' =  0 if `events2'[`i'] <= 0 // switch events to 0 if they are <= 0
					replace `nonevents2' in `i' =  `nonevents2'[`i'] + 1 // add 1 to Group 2 non-events to ensure N2 is always the same
					replace `nonevents2' in `i' = 0 if `nonevents2'[`i'] > (`events2'[`i'] + `nonevents2'[`i']) // switch events to 0 if they are > N2
					`cleancmd'
					meta summarize, `eform'
					if "`eform'" != "" {
						local ucl = exp(r(ci_ub)) // get exponentiated upper CI
					}
					else local ucl = r(ci_ub)
					replace `subt' in `i' = `ucl' // post CI to related study ID
					replace `events2' in `i' =  `alt_events2'[`i'] // return test events to original value
					replace `nonevents2' in `i' =  `alt_noevents2'[`i'] // return test non-events to original value
				} // end subtract
			
				* find max CI values
				sum `add', meanonly
				local add_max =  r(max)
				sum `subt', meanonly
				local subt_max =  r(max)
		 
				* Modify original event and non-event data according to max CI value
				if `subt_max' == 0 | `add_max' > `subt_max' {
					replace `events1' = `events1' + 1 if `add' == `add_max'
					replace `nonevents1' = `nonevents1' - 1 if `add' == `add_max'
					local ci_up = `add_max'
				}
				else if `add_max' < `subt_max' {
					replace `events2' = `events2' - 1 if `subt' == `subt_max'
					replace `nonevents2' = `nonevents2' + 1 if `subt' == `subt_max'
					local ci_up = `subt_max'
				}
			
				* set original data to match modified data
				replace `alt_events1' = `events1'
				replace `alt_noevents1' = `nonevents1'
				replace `alt_events2' = `events2'
				replace `alt_noevents2' = `nonevents2'

				local frag = `frag' + 1
		
			} // end while ci_up < `border'
		
		} // end if init < `border'	
	
		*********************************************************
		* if the lower CI is greater than 1 (eform) or 0 (linear)
		*********************************************************	
		else if `init' > `border' {
		
			while `ci_low' > `border' {
			
				* Add events to second group of each study
				forval i = 1/`N' {
					replace `events2' in `i' =  `events2'[`i'] + 1 if `events2'[`i'] <= (`events2'[`i'] + `nonevents2'[`i']) // add 1 event if events <= N2
					replace `events2' in `i' = 0 if `events2'[`i'] > (`events2'[`i'] + `nonevents2'[`i']) // switch events to 0 if they are > N1
					replace `nonevents2' in `i' =  `nonevents2'[`i'] - 1 // subtract 1 from Group 2 non-events to ensure N1 is always the same
					replace `nonevents2' in `i' =  0 if `nonevents2'[`i'] <= 0 // witch events to 0 if they equal 0
					`cleancmd'
					meta summarize, `eform'
					if "`eform'" != "" {
						local lcl = exp(r(ci_lb)) // get exponentiated upper CI
					}
					else local lcl = r(ci_lb)
					replace `add' in `i' = `lcl' // post CI to related study ID
					replace `events2' in `i' =  `alt_events2'[`i'] // return test events to original value
					replace `nonevents2' in `i' = `alt_noevents2'[`i'] // return test non-events to original value
				} //  end add
		
				* Subtract events from first group of each study
				forval i = 1/`N' {
					replace `events1' in `i' =  `events1'[`i'] - 1 if `events1'[`i'] > 0 // subtract 1 event if events > 0 
					replace `events1' in `i' =  0 if `events1'[`i'] <= 0 // switch events to 0 if they are <= 0
					replace `nonevents1' in `i' =  `nonevents1'[`i'] + 1 // add 1 to Group 2 non-events to ensure N2 is always the same
					replace `nonevents1' in `i' = 0 if `nonevents1'[`i'] > (`events1'[`i'] + `nonevents1'[`i']) // switch events to 0 if they are > N2
					`cleancmd'
					meta summarize, `eform'
					if "`eform'" != "" {
						local lcl = exp(r(ci_lb)) // get exponentiated upper CI
					}
					else local lcl = r(ci_lb)
					replace `subt' in `i' = `lcl' // post CI to related study ID
					replace `events1' in `i' =  `alt_events1'[`i'] // return test events to original value
					replace `nonevents1' in `i' =  `alt_noevents1'[`i'] // return test non-events to original value
				} // end subtract
			
				* find min CI values
				sum `add', meanonly
				local add_min =  r(min)
				sum `subt', meanonly
				local subt_min =  r(min)
		 
				* Modify original event and non-event data according to max CI value
				if `subt_min' == 0 | `add_min' < `subt_min' {
					replace `events2' = `events2' + 1 if `add' == `add_min'
					replace `nonevents2' = `nonevents2' - 1 if `add' == `add_min'
					local ci_low = `add_min'
				}
				else if `add_min' > `subt_min' {
					replace `events1' = `events1' - 1 if `subt' == `subt_min'
					replace `nonevents1' = `nonevents1' + 1 if `subt' == `subt_min'
					local ci_low = `subt_min'
				}
		
				* set original data to match test data (with modifications)
				replace `alt_events1' = `events1'
				replace `alt_noevents1' = `nonevents1'
				replace `alt_events2' = `events2'
				replace `alt_noevents2' = `nonevents2'

				di as txt "   Computing the fragility index: " as result %1.0f `frag'
				local frag = `frag' + 1

			} // end while ci_low > `border'	
		} // end init > `border'

		`cleancmd'
			
		/* Generate forestplot */
		if `"`forest'`forest2'"' != "" { 
			meta forestplot, nullrefline `eform' ///
				columnopts(_data1, supertitle(Group 1)) columnopts(_data2, supertitle(Group 2)) ///
				columnopts(_a _c, title("Events")) columnopts(_b _d, title("Non-events")) `forest2'
		}
		
	} // end qui	
		
		/* Display result */
		di _n
		di as txt "   Fragility Index: " as result %1.0f `frag'
		di _n
		di as txt "   The pooled treatment effect turns statistically non-significant after " %1.0f `frag' " event-status modifications." 


		// return list
		return scalar frag = `frag'

end


