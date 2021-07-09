
*! version 1.0  2jul2014 James J Feigenbaum

/*******************************************************************************
James J Feigenbaum
July 2, 2014
jfeigenb@fas.harvard.edu
james.feigenbaum@gmail.com

keeporder.ado file
Keep and order the same set of variables
*******************************************************************************/

version 10.0

*** define program and syntax
program define keeporder, nclass
    syntax varlist
	
	keep `varlist'
	order `varlist'
	
end

