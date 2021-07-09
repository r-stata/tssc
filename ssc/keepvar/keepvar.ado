*! Author: P. Wilner Jeanty
*! Date March 20, 2008
program define keepvar
	version 9.2
 	syntax varlist, [asis]
  	if `"`asis'"'=="" keep `varlist'  
  	else {
  		keep `varlist' 
  		order `varlist'
  	}
end
  
* Note: The keep command pays no regard to the order of variables in the varlist. 
