*! version 1.0.0  // 08feb2019  Ariel Linden

program define sequence
version 11.0

	syntax newvarname, [ From(numlist max=1) To(numlist max=1) by(numlist max=1) ]

	quietly {
	
		*********************************************
		// When _N == 0 (no observations in the data)
		*********************************************
		if _N == 0 {

			if "`to'" == "" {
				di as err "A value for -to- must be specified if there are no observations currently in the data" 
				exit 198 
			}
			if "`from'" == "" & "`by'" != "" {
				local from = mod(`to', `by')
			}
			if "`from'" != "" & "`by'" == "" {
				local by = abs((`to' - `from') / (`to'- 1))
			}
			if "`from'" == "" & "`by'" == "" {
				local from = 1
				local by = 1
			}
			
			// Ensure correct value specifications
			if `to' <= `from' {
				di as err "  -to(`to')- must be greater than -from(`from')-" 
				exit 198 
			}
			if `by' < 0 {
				di as err "  -by(`by')- must be a positive value" 
				exit 198 
			}
		
			// set number of observations
			if `from' < 0 {
				local obs = 1 + ceil((`to'- `from')/`by')
			}
***			else local obs = 1 + ceil((`to'- 1)/`by')
			else local obs = 1 + ceil((`to')/`by')
			set obs `obs'			
		
		} // end if _N == 0

		
		******************************************
		// When _N > 0 (the data has observations)
		******************************************
		else if _N > 0 {

			if "`by'" != "" {
				di as err " -by()- is not an available option when there are observations currently in the data" 
				exit 198 
			}
			if "`to'" == "" {
				local to = _N
			}
			if "`from'" == "" {
				local from = 1
			}
			
			// Ensure correct ordering
			if `to' <= `from' {
				di as err "  -to(`to')- must be greater than -from(`from')-" 
				exit 198 
			}
			local by = (`to' - `from') / (_N-1)
					
		} // end _N > 0
		
		**************************
		// generate the sequence!
		**************************
		gen `varlist' = `from' + (_n - 1) * `by'
		drop if (`varlist' > `to')
		
	} // end quietly
	
end
