*! version 1.2 Januar 31, 2013 @ 10:25:55 UK
*! Clickable list of smcl files

* History
* 0.1 Initial version
* 0.2 Forgot to implement erase. -> fixed
* 0.3 File names sorted alphabetically
* 0.4 Allow filename stubs, rclass type
* 0.5 Wrong caller for tops button -> fixed
* 1.0 External program ltrans now internal
* 1.1 Option erase did not worked -> fixed
* 1.2 User string is search pattern

// Caller Program
// --------------

program lsmcl, rclass
	version 10.0

	gettoken subcmd rest: 0
	if "`subcmd'"=="LTRANS" {
	   LTRANS `rest'
	}
	else {
	     LISTIT `0'
	     return local files `"`r(files)'"'
	}
end

program LISTIT, rclass

syntax [name] [, Erase]

local names: dir `"`c(pwd)'"' files "*`namelist'*smcl"
local names: list sort names

foreach name of local names {
	if "`erase'" != "" 					/// 
	  local eitem `"[{stata `"erase "`name'""':{err}erase}]"'
	display 							///  
	  `"{txt}`eitem'"' 	///  
	  `" [{stata `"view "`name'""':view}]"'   ///
	  `" [{stata `"lsmcl LTRANS "`name'", txt"':totxt}]"'   ///
	  `" [{stata `"lsmcl LTRANS "`name'", ps"':tops}]"'   ///
	  `" {res} `name' "'
}

display _n `"{txt}Click [{stata `"ldir"':here}] for other links"'

return local files `"`names'"' 
end


// Translator Program
// -----------------

program LTRANS
version 10.0

syntax anything [, txt ps]

if c(os)=="Unix" local open xdg-open
else if c(os)=="Windows" local open start
else if c(os)=="MacOSX" local open open

if "$MYEDITOR" == "" global MYEDITOR doedit

local fname = subinstr(`anything',".smcl","",1)

if "`txt'" == "txt" {
	quietly translate "`fname'.smcl" "`fname'.txt", translator(smcl2txt) replace
	display 							///  
	  `" {res} `fname'.txt {txt}created "' ///
	  `" {txt} [{stata `"view "`fname'.txt""':view}]"'   ///
	  `" [{stata `"$MYEDITOR "`fname'.txt""':edit}]"'   
}

if "`ps'" == "ps" {
	quietly translate "`fname'.smcl" "`fname'.ps", translator(smcl2ps) replace
	display 							///  
	  `" {res} `fname'.ps {txt}created "' ///
	  `" [{stata `"!`open' "`fname'.ps""':open}]"'  
}
end
exit

Author: Ulrich Kohler
	Tel +49 (0)30 25491 361
	Fax +49 (0)30 25491 360
	Email kohler@wzb.eu


