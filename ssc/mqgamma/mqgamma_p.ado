*! version 2.0.0  03Jun2014
program define mqgamma_p
	version 13.1

	syntax newvarname [if] [in] , [Equation(string)]

	_predict `typlist' `varlist' `if' `in' , xb equation(`equation')
end
