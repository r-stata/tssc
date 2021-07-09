*! version 0.4 Januar 31, 2013 @ 10:25:38 UK
*! Clickable list of .dta files

* 0.1 Initial version
* 0.2 File names sorted alphabetically
* 0.3 Allow filename stubs, rclass type
* 0.4 User string is search pattern

program ldta, rclass
version 10.0

syntax [name] [, Erase]

local names: dir `"`c(pwd)'"' files "*`namelist'*.dta"
local names: list sort names

foreach name of local names {
	if "`erase'" != "" 					/// 
	  local eitem `"[{stata `"erase "`name'""':{err}erase}]"'
	display 							///  
	  `"{txt}`eitem'"' 	///  
	  `" [{stata `"describe using "`name'", short"':des}]"'   ///
	  `" [{stata `"describe using "`name'""':describe}]"' ///
	  `" [{stata `"use "`name'""':use}]"' 	///
	  `" {res} `name' "'
}

display _n `"{txt}Click [{stata `"ldir"':here}] for other links"'

return local files `"`names'"' 
end

exit

Author: Ulrich Kohler
	Tel +49 (0)30 25491 361
	Fax +49 (0)30 25491 360
	Email kohler@wzb.eu



