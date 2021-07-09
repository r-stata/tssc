*! version 0.5 Januar 31, 2013 @ 10:25:52 UK
*! Clickable list of pdf files

* 0.1 Initial version 
* 0.5 User string is search pattern

// Main caller
// -----------

program lpdf, rclass
	version 10.0

	gettoken subcmd rest: 0
	if "`subcmd'"=="TOPS" {
	   TOPS `rest'
	}
	else {
	     LISTIT `0'
	     return local files `"`r(files)'"'
	}
end

// LISTIT
// ------

program LISTIT, rclass
syntax [name] [, Erase]

if c(os)=="Unix" {								
  local open xdg-open
  local back ">& /dev/null &"
  local print "!lp"
}
else if c(os)=="Windows" {
  local open start
  local print "leps LP_WINDOWS"
}
else if c(os)=="MacOSX" {
  local open open
  local print "!lp"
}										// CT: .......
	
local names: dir `"`c(pwd)'"' files `"*`namelist'*.pdf"'
local names: list sort names

foreach name of local names {
	if "`erase'" != "" 					/// 
	  local eitem `"[{stata `"erase "`name'""':{err}erase}]"'
	display 							///  
	  `"{txt}`eitem'"' 	///  
	  `" [{stata `"!`open' `name' `back'"':open}]"'   ///	
	  `" [{stata `"`print' "`name'""':print}]"'      ///		
	  `" [{stata `"lpdf TOPS "`name'""':tops}]"'     ///
	  `" {res} `name' "'
}

display _n ///
`"{txt}Convert {stata `"lpdf TOPS `namelist', many"':all} files to PS"'

display _n `"{txt}Click [{stata `"ldir"':here}] for other links"'

return local files `"`names'"' 
end


// Translate to PS							
// ---------------

program TOPS
version 10.0

syntax [anything] [, many]

if c(os)=="Unix" {
  local open xdg-open
  local back ">& /dev/null &"
}
else if c(os)=="Windows" local open start
else if c(os)=="MacOSX" local open open

if `"`anything'"' == `"`""'"' _macro drop _anything

if "`many'" != "" local names: dir `"`c(pwd)'"' files `"`anything'*.pdf"'
else local names `anything'
foreach name in `names' {
    local fname = subinstr("`name'",".pdf","",1)
    quietly !pdf2ps "`fname'.pdf" "`fname'.ps"	
    capture confirm file "`fname'.ps"
    if _rc {
		di as error ///
		  "`fname'.ps not created. May not have installed ghostscript properly"
		exit
	}
	else if "`many'"=="" display 	///  
	  `" {res} `fname'.ps {txt}created "' ///
	  `" [{stata `"!`open' "`fname'.ps" `back'"':open}]"'  
}
end
exit


Author: Ulrich Kohler
	Tel +49 (0)30 25491 361
	Fax +49 (0)30 25491 360
	Email kohler@wzb.eu

