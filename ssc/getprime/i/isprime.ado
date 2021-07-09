*! isprime v1.0.1
*! 17 April 2014
*! Alfonso Sanchez-Penalver

capture program drop isprime
program define isprime, rclass
	version 10.1
	syntax anything(name=num) [, Print]
	
	** Checks and Balances
	* Check whether the argument is an integer
	capture confirm integer number `num'
	if _rc {
		di as error "number has to be an integer."
		error 198
	}
	
	** Finding if number is prime
	tempname p
	scalar `p' = 1
	* Notice that 2 and 3 are primes but that the square root of both of them
	* are less than 2 so if those values are passed this loop will never be run
	* and the program will return true, i.e. 1
	local max = floor(sqrt(`num'))
	forval i = 2(1)`max' {
		if mod(`num',`i') == 0 {
			scalar `p' = 0
			continue, break
		}
	}
	
	** Displaying results
	if "`print'" == "print" {
		if `p' == 0  di as result `num' as text " is not a prime number."
		else di as result `num' " is a prime number."
	}
	
	** Returning values
	return scalar prime = `p'
	return scalar rnum = `num'
end

* 1.0.1 Allows abbreviation of print to at most p
* 1.0.0 Basic functionality, print had to be fully spelled
