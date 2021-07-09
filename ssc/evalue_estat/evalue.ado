*! 1.3.0 Ariel Linden 23Sep2019 // changed instances of "substr()" to "substr()" because of Stata version issues
*! 1.2.0 Ariel Linden 05Aug2019 // made "rare" the default for OR and HR, and made "common" the user-specified option
								// added CI to figure

*! 1.1.0 Ariel Linden 26Jan2019 // added figure option, streamlined code
*! 1.0.0 Ariel Linden 24Jan2019

program define evalue, rclass
version 11.0

			syntax anything  [, 				///
				Lcl(numlist max=1)				///
				Ucl(numlist max=1)				///
				SE(numlist max=1)				///
				COMMon							///
				TRue(numlist max=1)				///
				LEVel(cilevel)					///
				GRid(real 0.0001)				///
				FIGure FIGure2(str asis)		///  
				]                    


		gettoken estype anything : anything, parse(" ")
        local lcmd = length("`estype'")
   
		// Confirm numeric arguments, depending on model type 
		if "`estype'" == substr("rd", 1, max(2,`lcmd')) { 
			numlist "`anything'", min(4) max(4)
			tokenize `anything', parse(" ")

			local a `1'
			local b `2'
			local c `3'
			local d `4'

			confirm integer number `a'
			confirm integer number `b'
			confirm integer number `c'
			confirm integer number `d'
			
			if `a'<0 | `b'<0 | `c'<0 | `d'<0 { 
                di in red "negative numbers invalid"
                exit 411
			}
		}
		else numlist "`anything'", min(1) max(1)

		
		// Confirm that point estimate and true estimates are positive for RR, OR, and HR 
		if inlist("`estype'", substr("rr", 1, max(2,`lcmd')), substr("or", 1, max(2,`lcmd')), substr("hr", 1, max(2,`lcmd'))) {
			if `anything' < 0 {
				di as err "point estimate cannot be negative" 
				exit 411
			}
			if "`true'" != "" {
				if `true' < 0 {
					di as err "true value cannot be negative" 
				exit 411
				}
			}
			
			// Confirm that point estimate is within the confidence interval
			if "`lcl'" != "" {
				if `anything' < `lcl' {
				di as err "point estimate cannot be lower than LCL" 
				exit 198
				}
			}	
			if "`ucl'" != "" {
				if `anything' > `ucl' {
				di as err "point estimate cannot be higher than UCL" 
				exit 198 
				}
			}
			
		} // end inlist
		
		// set default true value to 0 for RD and SMD, and 1 for all other models
		if inlist("`estype'", substr("rd", 1, max(2,`lcmd')), substr("smd", 1, max(3,`lcmd'))) & "`true'" == "" {
				local true = 0 
		}
		if !inlist("`estype'", substr("rd", 1, max(2,`lcmd')), substr("smd", 1, max(3,`lcmd'))) & "`true'" == "" {
				local true = 1 	
		}

		
		tempname estimate ci
		// set ci to null for later use in return scalar
		scalar `ci' = .
			
		*************************
		**  risk or rate ratio **
        *************************
		if "`estype'" == substr("rr", 1, max(2,`lcmd')) {

			// if point estimate <= 1
			if inrange(`anything',0, 1) {
				
				* when true is lower than point estimate
				if `true' < `anything' {
					scalar `estimate' = (`anything'/`true') + sqrt((`anything'/`true') * ((`anything'/`true') - 1))
				}
				else scalar `estimate' = 1/(`anything'/`true') + sqrt( 1/(`anything'/`true') * (1/(`anything'/`true') - 1))
				
				if `true' < `anything' & "`lcl'" != "" {
					local ll = (`lcl'/`true') + sqrt((`lcl'/`true') * ((`lcl'/`true') - 1))
				}	
				else if "`lcl'" != "" {
					local ll = 1/(`lcl'/`true') + sqrt( 1/(`lcl'/`true') * (1/(`lcl'/`true') - 1))
				}
				if `true' < `anything' & "`ucl'" != "" {
						local ul = (`ucl'/`true') + sqrt((`ucl'/`true') * ((`ucl'/`true') - 1))
				}
				else if "`ucl'" != "" {
					local ul = 1/(`ucl'/`true') + sqrt( 1/(`ucl'/`true') * (1/(`ucl'/`true') - 1))
				}
			} // end <=1
			
			
			// if point estimate > 1
			else if `anything' > 1 {
				
				* when true is higher than point estimate
				if `true' > `anything' {
					scalar `estimate' = (`true'/`anything') + sqrt((`true'/`anything') * ((`true'/`anything') - 1))
				}
				else scalar `estimate' = (`anything'/`true') + sqrt((`anything'/`true') * ((`anything'/`true') - 1))
				
				if `true' > `anything' & "`lcl'" != "" {
					local ll = (`true'/`lcl') + sqrt((`true'/`lcl') * ((`true'/`lcl') - 1))
				}
				else if "`lcl'" != "" {
					local ll = (`lcl'/`true') + sqrt((`lcl'/`true') * ((`lcl'/`true') - 1))
				}
				if `true' > `anything' & "`ucl'" != "" {
					local ul = (`true'/`ucl') + sqrt((`true'/`ucl') * ((`true'/`ucl') - 1))
				}
				else if "`ucl'" != "" {
					local ul = (`ucl'/`true') + sqrt((`ucl'/`true') * ((`ucl'/`true') - 1))
				}
			} // end >1

		} // end RR

		*****************
		**  odds ratio **
        *****************
         else if "`estype'" == substr("or", 1, max(2,`lcmd')) {
			
			// if point estimate <= 1 & common
			if inrange(`anything',0, 1) & "`common'" != "" {
				// if point estimate <= 1 & common
				if `true' < `anything' {
					scalar `estimate' = sqrt(`anything'/`true') + sqrt(sqrt(`anything'/`true') * (sqrt(`anything'/`true') - 1))
				}
				else scalar `estimate' = (sqrt(1/`anything') + sqrt(sqrt(1/`anything') * (sqrt(1/`anything') - sqrt(1/`true')))) / sqrt(1/`true')			

				if `true' < `anything' & "`lcl'" != "" {
					local ll = sqrt(`lcl'/`true') + sqrt(sqrt(`lcl'/`true') * (sqrt(`lcl'/`true') - 1))
				}
				else if "`lcl'" != "" {
					local ll = (sqrt(1/`lcl') + sqrt(sqrt(1/`lcl') * (sqrt(1/`lcl') - sqrt(1/`true')))) / sqrt(1/`true')
				}	
				if `true' < `anything' & "`ucl'" != "" {
					local ul = sqrt(`ucl'/`true') + sqrt(sqrt(`ucl'/`true') * (sqrt(`ucl'/`true') - 1))
				}
				else if "`ucl'" != "" {
					local ul = (sqrt(1/`ucl') + sqrt(sqrt(1/`ucl') * (sqrt(1/`ucl') - sqrt(1/`true')))) / sqrt(1/`true')
				}
			} // end <=1
			
			// if point estimate > 1 & common
			else if `anything' > 1 & "`common'" != "" {
				if `true' > `anything' {
					scalar `estimate' = sqrt(`true'/`anything') + sqrt(sqrt(`true'/`anything') * (sqrt(`true'/`anything') - 1))
				}
				else scalar `estimate' = (sqrt(`anything') + sqrt(sqrt(`anything') * (sqrt(`anything') - sqrt(`true')))) / sqrt(`true')

				if `true' > `anything' & "`lcl'" != "" {
					local ll = sqrt(`true'/`lcl') + sqrt(sqrt(`true'/`lcl') * (sqrt(`true'/`lcl') - 1))	
				}
				else if "`lcl'" != "" {
					local ll = (sqrt(`lcl') + sqrt(sqrt(`lcl') * (sqrt(`lcl') - sqrt(`true')))) / sqrt(`true')
				}	
				if `true' > `anything' & "`ucl'" != "" {
					local ul = sqrt(`true'/`ucl') + sqrt(sqrt(`true'/`ucl') * (sqrt(`true'/`ucl') - 1))	
				}
				else if "`ucl'" != "" {
					local ul = (sqrt(`ucl') + sqrt(sqrt(`ucl') * (sqrt(`ucl') - sqrt(`true')))) / sqrt(`true')
				}
			
			} // end >1
			
			// if point estimate <= 1 & rare
			else if inrange(`anything',0, 1) & "`common'" == "" {
				if `true' < `anything' {
					scalar `estimate' = (`anything'/`true') + sqrt((`anything'/`true') * ((`anything'/`true') - 1))
				}
				else scalar `estimate' = (1/`anything' + sqrt(1/`anything' * (1/`anything' - 1/`true'))) / (1/`true')
				
				if `true' < `anything' & "`lcl'" != "" {
					local ll = (`lcl'/`true') + sqrt((`lcl'/`true') * ((`lcl'/`true') - 1))	
				}
				else if "`lcl'" != "" {
					local ll = (1/`lcl' + sqrt(1/`lcl' * (1/`lcl' - 1/`true'))) / (1/`true')
				}	
				if `true' < `anything' & "`ucl'" != "" {
					local ul = (`ucl'/`true') + sqrt((`ucl'/`true') * ((`ucl'/`true') - 1))	
				}		
				else if "`ucl'" != "" {
					local ul = (1/`ucl' + sqrt(1/`ucl' * (1/`ucl' - 1/`true'))) / (1/`true')
				}
			} // end <=1
			
			// if point estimate > 1 & common
			else if `anything' > 1 & "`common'" == "" {
				if `true' > `anything' {
					scalar `estimate' = (`true'/`anything') + sqrt((`true'/`anything') * ((`true'/`anything') - 1))
				}
				else scalar `estimate' = (`anything' + sqrt(`anything' * (`anything' - `true'))) / `true'
								
				if `true' > `anything' & "`lcl'" != "" {
					local ll = (`true'/`lcl') + sqrt((`true'/`lcl') * ((`true'/`lcl') - 1))
				}
				else if "`lcl'" != "" {
					local ll = (`lcl' + sqrt(`lcl' * (`lcl' - `true'))) / `true'
				}	
				if `true' > `anything' & "`ucl'" != "" {
					local ul = (`true'/`ucl') + sqrt((`true'/`ucl') * ((`true'/`ucl') - 1))
				}	
				else if "`ucl'" != "" {
					local ul = (`ucl' + sqrt(`ucl' * (`ucl' - `true'))) / `true'
				}
			} // end >1

		} // end OR
        
		*******************
		**  hazard ratio **
        *******************
        else if "`estype'" == substr("hr", 1, max(2,`lcmd')) {
			
			// Conversion if prevalence > 15% (common)
			if "`common'" != "" {
				local anything = (1 - 0.5^sqrt(`anything')) / ( 1 - 0.5^sqrt(1/`anything'))
				local true = (1 - 0.5^sqrt(`true')) / ( 1 - 0.5^sqrt(1/`true'))
				
				if "`lcl'" != "" {
					local lcl = (1 - 0.5^sqrt(`lcl')) / ( 1 - 0.5^sqrt(1/`lcl'))
				}
				if "`ucl'" != "" {
					local ucl = (1 - 0.5^sqrt(`ucl')) / ( 1 - 0.5^sqrt(1/`ucl'))
				}
			}
			// if point estimate <= 1
			if inrange(`anything',0, 1) {
				if `true' < `anything' {
					scalar `estimate' = (`anything'/`true') + sqrt((`anything'/`true') * ((`anything'/`true') - 1))
				}
				else scalar `estimate' = (1/`anything' + sqrt(1/`anything' * (1/`anything' - 1/`true'))) / (1/`true')			
								
				if `true' < `anything' & "`lcl'" != "" {
					local ll = (`lcl'/`true') + sqrt((`lcl'/`true') * ((`lcl'/`true') - 1))
				}		
				else if "`lcl'" != "" {
					local ll = (1/`lcl' + sqrt(1/`lcl' * (1/`lcl' - 1/`true'))) / (1/`true')
				}	
				if `true' < `anything' & "`ucl'" != "" {
					local ul = (`ucl'/`true') + sqrt((`ucl'/`true') * ((`ucl'/`true') - 1))
				}		
				else if "`ucl'" != "" {		
						local ul = (1/`ucl' + sqrt(1/`ucl' * (1/`ucl' - 1/`true'))) / (1/`true')
				}
			} // end <=1
			
			// if point estimate > 1
			else if `anything' > 1  {
				if `true' > `anything' {
					scalar `estimate' = (`true'/`anything') + sqrt((`true'/`anything') * ((`true'/`anything') - 1))
				}
				else scalar `estimate' = (`anything' + sqrt(`anything' * (`anything' - `true'))) / `true'
				
				if `true' > `anything' & "`lcl'" != "" {
					local ll = (`true'/`lcl') + sqrt((`true'/`lcl') * ((`true'/`lcl') - 1))	
				}
				else if "`lcl'" != "" {		
					local ll = (`lcl' + sqrt(`lcl' * (`lcl' - `true'))) / `true'
				}	
				if `true' > `anything' & "`ucl'" != "" {
					local ul = (`true'/`ucl') + sqrt((`true'/`ucl') * ((`true'/`ucl') - 1))	
				}
				else if "`ucl'" != "" {	
					local ul = (`ucl' + sqrt(`ucl' * (`ucl' - `true'))) / `true'
				}
			} // end >1
			
		} // end HR	

		***********************************
		**  Standardized mean difference **
        ***********************************
		else if "`estype'" == substr("smd", 1, max(3,`lcmd')) {
		
			// Conversions to rr
			if "`se'" != "" {
				if `se' < 0 {
					di as err "se cannot be negative" 
					exit 411
				}
				local lcl = exp( 0.91 * `anything' - 1.78 * `se' )
				local ucl = exp( 0.91 * `anything' + 1.78 * `se' )
			}
			local anything = exp(0.91 * `anything')
			local true = exp(0.91 * `true')
			
			// if point estimate <= 1
			if `anything' <= 1 {
				if `true' < `anything' {
					scalar `estimate' = (`anything'/`true') + sqrt((`anything'/`true') * ((`anything'/`true') - 1))
				}
				else scalar `estimate' = (1/`anything' + sqrt(1/`anything' * (1/`anything' - 1/`true'))) / (1/`true')
				
				if `true' < `anything' & "`se'" != "" {
					local ll = (`lcl'/`true') + sqrt((`lcl'/`true') * ((`lcl'/`true') - 1))
					local ul = (`ucl'/`true') + sqrt((`ucl'/`true') * ((`ucl'/`true') - 1))
				}
				else if "`se'" != "" {
					local ll = (1/`lcl' + sqrt(1/`lcl' * (1/`lcl' - 1/`true'))) / (1/`true')
					local ul = (1/`ucl' + sqrt(1/`ucl' * (1/`ucl' - 1/`true'))) / (1/`true')
				}
			} // end <=1
			
			// if point estimate > 1
			else if `anything' > 1 {
				if `true' > `anything' {
					scalar `estimate' = (`true'/`anything') + sqrt((`true'/`anything') * ((`true'/`anything') - 1))
				}
				else scalar `estimate' = (`anything' + sqrt(`anything' * (`anything' - `true'))) / `true'
				
				if `true' > `anything' & "`se'" != "" {
					local ll = (`true'/`lcl') + sqrt((`true'/`lcl') * ((`true'/`lcl') - 1))
					local ul = (`true'/`ucl') + sqrt((`true'/`ucl') * ((`true'/`ucl') - 1))
				}
				else if "`se'" != "" {
					local ll = (`lcl' + sqrt(`lcl' * (`lcl' - `true'))) / `true'
					local ul = (`ucl' + sqrt(`ucl' * (`ucl' - `true'))) / `true'
				}
			} // end >1
						
		} // end SMD

		**********************
		**  Risk difference **
        **********************
		else if "`estype'" == substr("rd", 1, max(2,`lcmd')) {
		
			quietly {	
			
				tempvar bfsearch rdsearch fsearch lowsearch
			
				preserve
				clear
	
				local iz = invnorm(1-(1-`level'/100)/2)
				local n1 = `a' + `b' 
				local n0 = `c' + `d'
				local N = `a' + `b' + `c' + `d'
  
				local f = (`n1') / (`N')
				local p1 = `a' / (`n1')
				local p0 = `c' / (`n0')
				local rd = `p1' - `p0'
			
				if `p1' < `p0' {
					di as err "RD < 0; please relabel the exposure such that the risk difference > 0." 
					exit 198
				}	
			
				if `rd' <= `true' {
					local rd1 = round(`rd',.0001)
					di as err " To compute the risk difference, the true value must be less than or equal to the point estimate (`rd1') "
					exit 198
				}	
			
			
				local se_p0 = sqrt( `p0' * (1-`p0') / `n0' )
				local se_p1 = sqrt( `p1' * (1-`p1') / `n1' )
				local se_f = `f'*(1-`f')/`N'
				local s2_p1  = `se_p1'^2
				local s2_p0  = `se_p0'^2
				local s2_f = `se_f'^2
				local diff = `p0' * (1 - `f') - `p1' * `f'
				local low_ci = `rd' - `iz' * sqrt(`s2_p1' + `s2_p0')
  
				local B = ( sqrt( ( `true' + `diff' )^2 + 4 * `p1' * `p0' * `f' * (1-`f') ) - ( `true' + `diff' ) ) / (2 * `p0' * `f')
				scalar `estimate' = (`B') + sqrt((`B') * ((`B') - 1)) 
		
				local obs = 1 + ceil((`B'- 1)/`grid')
				set obs `obs'			
				gen `bfsearch' = 1 + (_n - 1) * `grid'
				drop if (`bfsearch' > `B')
		
				gen `rdsearch' = `p1' - `p0' * `bfsearch'
				gen `fsearch' = `f' + (1- `f') / `bfsearch'
				gen `lowsearch' = `rdsearch' * `fsearch' - `iz' * sqrt((`s2_p1' + `s2_p0' * `bfsearch'^2) * `fsearch'^2 + `rdsearch'^2 * (1-(1/`bfsearch'))^2 * `s2_f' )
		
				sum	`bfsearch' if `lowsearch' > `true', meanonly
				local lcl = r(max)
				scalar `ci' = (`lcl') + sqrt((`lcl') * ((`lcl') - 1))
		
				restore
			} // end qui
		} // end RD
		
		******************
		* invalid command
		******************
		else {
			di as err `"unknown subcommand of {bf:evalue}: `estype'"'
			exit 198
		}

		******************************************************************
		// Presenting E-values for point estimate and confidence interval
		******************************************************************
		di as txt "   E-value (point estimate): " as result %5.3f `estimate' 
		
		*************
		// CI For SMD
		*************
		if "`estype'" == substr("smd", 1, max(3,`lcmd')) {
			if "`se'" != "" {
				if `anything' <= 1 {
					if `true' <= `anything' {
						if `ll' ==. scalar `ci' = 1
						else scalar `ci' = `ll'
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}	
					else if `true' > `anything' {
						if `ul' ==. scalar `ci' = 1
						else scalar `ci' = `ul'
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}	
				} // <=1

				if `anything' > 1 {
					if `true' <= `anything' {
						if `ll' ==. scalar `ci' = 1
						else scalar `ci' = `ll'
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}	
					else if `true' > `anything' {
						if `ul' ==. scalar `ci' = 1
						else scalar `ci' = `ul'
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}	
				} // >1
			}	// end if se != ""
		} // end smd
		
		*************
		// CI For RD
		*************
		
		else if "`estype'" == substr("rd", 1, max(2,`lcmd')) {
			if `low_ci' <= `true' scalar `ci' = 1
			di as txt "   E-value (CI): " as result %5.3f `ci'
		}
		
		***********************************
		// CI for other models (RR, OR, HR)
		***********************************
		else if inlist("`estype'", substr("rr", 1, max(2,`lcmd')), substr("or", 1, max(2,`lcmd')), substr("hr", 1, max(2,`lcmd'))) {
		
			if `anything' <= 1 {
				if `true' == `anything' {
					if "`lcl'" != "" | "`ucl'" != "" {
						scalar `ci' = 1
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}
				}	
				else if `true' < `anything' {
					if "`lcl'" != "" {
						if `ll' ==. scalar `ci' = 1
						else scalar `ci' = `ll'
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}	
				}
				else if `true' > `anything' {
					if "`ucl'" != "" {
						if `ul' ==. scalar `ci' = 1
						else scalar `ci' = `ul'
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}	
				}
			} // <=1
			if `anything' > 1 {
				if `true' == `anything' {
					if "`lcl'" != "" | "`ucl'" != "" {
						scalar `ci' = 1
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}
				}
				if `true' < `anything' {
					if "`lcl'" != "" {	
						if `ll' ==. scalar `ci' = 1
						else scalar `ci' = `ll'
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}
				}
				else if `true' > `anything' {
					if "`ucl'" != "" {
						if `ul' ==. scalar `ci' = 1
						else scalar `ci' = `ul'
						di as txt "   E-value (CI): " as result %5.3f `ci'
					}	
				}
			} // >1
		} // end estype not SMD

		**********************
		// Generate figure
		**********************
		if `"`figure'`figure2'"' != "" {
		
		  quietly {
			preserve
			clear
			
			tempvar x y c
			
			** RR, SMD, OR/HR with rare outcomes
			if "`estype'" == substr("rr", 1, max(2,`lcmd')) | "`estype'" == substr("hr", 1, max(2,`lcmd')) ///
				| "`estype'" == substr("or", 1, max(2,`lcmd')) & "`common'" == "" | "`estype'" == substr("smd", 1, max(3,`lcmd')) {
					
				* for estimate
				local B = `anything' / `true'
				if `B' < 1 local B = 1/`B'	
			
				* for CI
				if `anything' < 1 & "`ucl'" !="" {
					local C = `ucl' / `true'
					if `C' < 1 local C = 1/`C'
				}
				if `anything' > 1 & "`lcl'" !="" {
					local C = `lcl' / `true'
					if `C' < 1 local C = 1/`C'
				}
					
			} // end RR, SMD, OR/HR with rare outcomes
	
			** OR with common outcomes
			if "`estype'" == substr("or", 1, max(2,`lcmd')) & "`common'" != "" {
				
				* for estimate
				local B = sqrt(`anything' / `true')
				if `B' < 1 local B = 1/`B'	
		
				* for CI
				if `anything' < 1 & "`ucl'" !="" {
					local C = sqrt(`ucl' / `true')
					if `C' < 1 local C = 1/`C'
				}
				if `anything' > 1 & "`lcl'" !="" {
					local C = sqrt(`lcl' / `true')
					if `C' < 1 local C = 1/`C'
				}		

			} // end OR with common outcomes
			
			
			** RD
			if "`estype'" == substr("rd", 1, max(2,`lcmd')) {
				
				* for estimate
				local B = `B'
				if `B' < 1 local B = 1/`B'	
		
				* for CI
				local C = `lcl'
		
			}
			
			local E = round(`estimate', 0.01)
			local xmin = 1
			local xmax = `E' * 3

			local grid = 0.01
			local obs = 1 + ceil((`xmax'- 1)/`grid')
			set obs `obs'			
			gen `x' = `xmin' + (_n - 1) * `grid'
			gen `y' = (`B' * (1 - `x'))/(`B' - `x')
			

			if  "`C'" !="" & `ci' != 1 {

				local CI = round(`ci', 0.01)
				gen `c' = (`C' * (1 - `x'))/(`C' - `x')
			
				* if CI is available, then plug these lines into twoway code 
				local cline (line `c' `x' if inrange(`c', `xmin',`xmax'))
				local cscati (scatteri `CI' `CI' (2) "E-value (CI): (`CI', `CI')", mlabgap(*3))

			}	

			* Plot it
			tw(line `y' `x' if inrange(`y', `xmin',`xmax')) ///
				`cline'  ///
				`cscati' ///
				(scatteri `E' `E' (2) "E-value: (`E', `E')", mlabgap(*3)), ///
				ytitle(Risk ratio for confounder-outcome relationship) xtitle(Risk ratio for exposure-confounder relationship) ///
				legend(off) `figure2'
	

			restore
			
		  } // end quietly
		} // end figure

		******************
		// Return results
		******************
		return scalar eval_est = `estimate'
  		if `ci' != . {
			return scalar eval_ci = `ci'
		}
end

