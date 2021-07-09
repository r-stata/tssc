*! version 1.1 01oct2014 \ Philip M Jones, pjones8@uwo.ca
/* csit.ado: Wrapper program for csi to use total number of patients. */
/* Example: for 13 events in 130 patients in one group, 23 events in 127 patients in another group */
/* "csti 13/130 23/127" */
/* all options for -csi- will continue to work as they are passed along */

program define csti
	version 9
	
	syntax anything [, *]
	
	tokenize `anything'
	
	local g1 "`1'"
	local g2 "`2'"

	tokenize `g1', parse("/")
	local n1 `1'
	local N1 `3'

	tokenize `g2', parse("/")
	local n2 `1'
	local N2 `3'

	// error detection
	local error = 0
	
	if (`n1' > `N1') | (`n2' > `N2') {
		local error = 1
	}
	
	if `error'== 1 {		// user hasn't entered syntax correctly
		di as error "Example Syntax: csti 13/130 23/127"
		di as error "The number of events to the left of the slash character"
		di as error "must be less than or equal to the total number to the right of the slash."
		exit
	}
	
	local N_1 = `N1' - `n1'
	local N_2 = `N2' - `n2'

	csi `n1' `n2' `N_1' `N_2', `options'

end
