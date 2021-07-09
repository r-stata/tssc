*! version 1.0.0  14May2012
program define poparms_p

	version 12.1
	syntax newvarname [if] [in] , [Equation(string)]

	_predict `typlist' `varlist' `if' `in', equation(`equation')

end
