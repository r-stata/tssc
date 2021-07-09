*! version 0.4 Juni 6, 2014 @ 08:41:33
*! Clickable list of .do files

* 0.1 Initial version
* 0.2 User string is search pattern
* 0.4 Make setting MYEDITOR easiear for Unix

program ldo, rclass
version 10.0
	
	syntax [name] [, Erase]
	

	if "$MYEDITOR" == "" local open doedit
	else {								
		local open $MYEDITOR
		if c(os)=="Unix" local back ">& /dev/null &"
	}
	
	
	local names: dir `"`c(pwd)'"' files "*`namelist'*.do"
	local names: list sort names
	
	
	foreach name of local names {
		if "`erase'" != "" 					/// 
		  local eitem `"[{stata `"erase "`name'""':{err}erase}]"'
		display 							///  
		  `"{txt}`eitem'"' 	///  
		  `" [{stata `"view "`name'""':view}]"'   ///
		  `" [{stata `"`open' "`name'" `back'"':edit}]"' ///
		  `" [{stata `"do "`name'""':do}]"' 	///
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


