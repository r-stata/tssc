*! version 0.6 Januar 31, 2013 @ 10:25:42 UK
*! Clickable list of eps files

* 0.1 Initial version (Printing for Linux only, do not distribute)
* 0.2 Adds shell open 
* 0.3 Bug in option erase -> fixed
* 0.4 Open viewer in the background
* 0.5 Debug version for windows. 
* 0.6 User string is search pattern

// Main caller
// -----------

program define leps, rclass
version 10.0
	
	gettoken subcmd rest: 0
	if "`subcmd'"=="TOPDF" {
		TOPDF `rest'
	}
	else if "`subcmd'"=="LP_WINDOWS" {
		LP_WINDOWS `rest'
	}
	else {
		LISTIT `0'
		return local files `"`r(files)'"'
	}
end

// LISTIT
// ------

program define LISTIT, rclass
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
	}
	
	local names: dir `"`c(pwd)'"' files `"*`namelist'*.eps"'
	local names: list sort names
	
	foreach name of local names {
		if "`erase'" != "" 					/// 
		  local eitem `"[{stata `"erase "`name'""':{err}erase}]"'
		if c(os)=="Unix" local name `""`name'""'
		display 							///  
		  `"{txt}`eitem'"' 	///  
		  `" [{stata `"!`open' `name' `back'"':open}]"'   ///
		  `" [{stata `"`print' `name'"':print}]"'   ///
		  `" [{stata `"leps TOPDF `name'"':topdf}]"'   ///
		  `" {res} `name' "'
	}
	
	display _n ///
	  `"{txt}Convert {stata `"leps TOPDF `namelist', many"':all} files to PDF"'
	
	display _n `"{txt}Click [{stata `"ldir"':here}] for other links"'
	
	return local files `"`names'"' 
end

// Translate to PDF
// ----------------

program define TOPDF
version 10.0

	syntax [anything] [, many]
	
	if c(os)=="Unix" {
		local open xdg-open
		local back ">& /dev/null &"
	}
	else if c(os)=="Windows" local open start
	else if c(os)=="MacOSX" local open open
	
	if `"`anything'"' == `"`""'"' _macro drop _anything
	
	if "`many'" != "" local names: dir `"`c(pwd)'"' files `"`anything'*.eps"'
	else local names `"`anything'"'
	foreach name in `names' {
		local fname = subinstr("`name'",".eps","",1)
		
		if c(os) == "Unix" | c(os) == "MacOSX" {
			local epsname `""`fname'.eps""'
			local pdfname `""`fname'.pdf""'
		}
		if c(os) == "Windows" {
			local epsname `fname'.eps
			local pdfname `fname'.pdf
		}
		
		quietly !epstopdf `epsname'
		capture confirm file `pdfname'
		if _rc {
			di as error ///
			  `"`pdfname' not created. May not have installed ghostscript properly"'
			exit
		}
		else if "`many'"=="" display 							///  
		  `" {res} `pdfname' {txt}created "' ///
		  `" [{stata `"!`open' `pdfname' `back'"':open}]"'  
	}
end

program define LP_WINDOWS
	
	args filename
	
	capture confirm file __gvpath.txt
	if !_rc {
		erase __gvpath.txt
	}
	
	!reg export "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\gsview32.exe" __gvpath.txt
	
	capture confirm file __gvpath.txt
	if _rc {
		!reg export "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\gsview64.exe" __gvpath.txt
	}
	
	capture confirm file __gvpath.txt
	if _rc {
		di as err "Ghostview/Ghostscript seems not to be installed"
	}
	else {
		!CHCP 1252
		!TYPE __gvpath.txt > __gvpathasci.txt
		
		file open myfile using "__gvpathasci.txt", read
		file read myfile line
		while r(eof)==0 {
			local pathfound = strmatch(`"`line'"',"?Path?=*")
			if "`pathfound'"=="1" {
				local path = `"`line'"'
			}
			file read myfile line
		}
		file close myfile
		
		gettoken no path : path, parse(=)
		local path `path'
		global path = subinstr("`path'","\\","/",.)
		! "$path/gsprint" -noprinter -query `filename'
		
		erase __gvpath.txt
		erase __gvpathasci.txt
	}
	
end

exit


Author: Ulrich Kohler
	Tel +49 (0)30 25491 361
	Fax +49 (0)30 25491 360
	Email kohler@wzb.eu

