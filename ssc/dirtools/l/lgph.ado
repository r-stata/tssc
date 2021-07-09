*! version 1.2 Juni 11, 2014 @ 23:20:43
*! Clickable list of gph files

* 0.1 Initial version
* 0.2 File names sorted alphabetically
* 0.3 Allow filename stubs, rclass type
* 1.0 Makes lgphout intern
* 1.1 Bug with ouption erase -> fixed
* 1.2 Open eps in the backround

// Caller Program
// --------------

program lgph, rclass
	version 10.0

	gettoken subcmd rest: 0
	if "`subcmd'"=="GPHOUT" {
	   GPHOUT `rest'
	}
	else {
	     LISTIT `0'
	     return local files `"`r(files)'"'
	}
end

// LISTIT
// ------

program LISTIT, rclass
version 10.0

syntax [name] [, Erase]

local names: dir `"`c(pwd)'"' files "`namelist'*.gph"
local names: list sort names

foreach name of local names {
	if "`erase'" != "" 					/// 
	  local eitem `"[{stata `"erase "`name'""':{err}erase}]"'
	display 							///  
	  `"{txt}`eitem'"' 	///  
	  `" [{stata `"graph use "`name'""':display}]"'   ///
	  `" [{stata `"lgph GPHOUT "`name'", print"':print}]"'   ///
	  `" [{stata `"lgph GPHOUT "`name'", export"':toeps}]"'   ///
	  `" {res} `name' "'
}

display _n `"{txt}Click [{stata `"ldir"':here}] for other links"'

return local files `"`names'"' 
end

// Tranfer GPH-Files
// -----------------

program GPHOUT
version 10.0

syntax anything [, export print]

if c(os)=="Unix" {
    local open shell xdg-open
    local back ">& /dev/null &"
}
else if c(os)=="Windows" local open winexec start
else if c(os)=="MacOSX" local open shell open

if "`export'" == "export" {
		graph use `anything'
		local fname = subinstr(`anything',".gph","",1)
		quietly graph export "`fname'.eps", replace

   display 							///  
	  `" {res} `fname'.eps {txt}created "' ///
	  `" [{stata `"`open' "`fname'.eps" `back'"':open}]"'  
}

if "`print'" == "print" {
	graph use `anything'
	graph print 
}


end
exit

Author: Ulrich Kohler
	Tel +49 (0)30 25491 361
	Fax +49 (0)30 25491 360
	Email kohler@wzb.eu










exit

Author: Ulrich Kohler
	Tel +49 (0)30 25491 361
	Fax +49 (0)30 25491 360
	Email kohler@wzb.eu



