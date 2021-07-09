*! version 0.3 Juni 6, 2014 @ 08:51:20
*! Clickable list of .mata files

* 0.1 Initial version
* 0.2 User string is search pattern
* 0.3 Make setting of MYEDITOR easier for UNIX

program lmata, rclass
version 10.0
	
	syntax [name] [, Erase]
	local names: dir `"`c(pwd)'"' files "*`namelist'*.mata"
	local names: list sort names
	
	if "$MYEDITOR" == "" local open doedit
	else {								
		local open $MYEDITOR
		if c(os)=="Unix" local back ">& /dev/null &"
	}
	
	foreach name of local names {
		if "`erase'" != "" 					/// 
		  local eitem `"[{stata `"erase "`name'""':{err}erase}]"'
		display 							///  
		  `"{txt}`eitem'"' 	///  
		  `" [{stata `"view "`name'""':view}]"'   ///
		  `" [{stata `"`open' "`name'" `back'"':edit}]"' ///
		  `" [{stata `"do "`name'""':compile}]"' 	///
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


