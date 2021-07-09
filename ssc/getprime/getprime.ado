*! getprime v1.0.1
*! 17 April 2014
*! Alfonso Sanchez-Penalver
*! Version history at the bottom

capture program drop getprime
program define getprime, rclass
	version 10.1
	syntax anything(name=num) [, Above PRint SCAlar(string)]
	
	** Checks and Balances
	*  First check that the argument is an integer
	capture confirm integer number `num'
	if _rc {
		di as error "number has to be an integer"
		error 198
	}
	* Now check that isprime has the right version
	cap isprimeversion
	if _rc | "`r(version)'" < "01.00.00" {
		di as err "Error: {cmd:getprime} works with {cmd:isprime} version " ///
			"1.0.0 or later."
		di `"To install or update it, type or click on {stata "ssc install isprime, replace"}. Then restart Stata."'
		exit 601
	}
	
	** Finding the prime number
	tempname p
	scalar `p' = 2
	* We set the step (increment) and the maximum (minimum) value for the loop.
	* I choose 1000 as the range for the lookup, but it would very seldomly be
	* above 10. Since the loop has the "continue, break" clause for when it
	* finds the prime number, this guarantees that it would never get that far.
	if "`above'" != "above" {
		local step = -1
		local end = `num' - 1000
	}
	else {
		local step = 1
		local end = `num' + 1000
	}
	forval i = `num'(`step')`end' {
		isprime `i'
		if `r(prime)' == 1 {
			scalar `p' = `i'
			continue, break
		}
	}
	
	** Displaying the results
	if "`print'" == "print" {
		if "`above'" == "above" 											///
			di as text "The prime number closer to, but greater than, " as	///
				result `num' as text " is " as result `p' as text "."
		else 																///
			di as text "The prime number closer to, but less than, " as		///
				result `num' as text " is " as result `p' as text "."
	}
	
	** Setting the scalar
	if "`scalar'" != ""														///
		scalar `scalar' = `p'
	
	** Returning values
	return scalar pnum = `p'
	return scalar rnum = `num'
end

* 1.0.1 Allows abbreviation of above to a, added print and scalar options, and
*		checks version of isprime.

* 1.0.0 Allowed getting prime number above and below, used the whole word above
*		for option
