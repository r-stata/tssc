*! version 1.5 Juni 12, 2014 @ 07:56:32
*! Clickable list of .do files

* 0.1 Initial version
* 0.2 Allow filename stubs, rclass type
* 1.0 Rework. Make ltextypset internal
* 1.1 Bug with option erase -> fixed
* 1.2 Drop note _ltex.tex not found
* 1.3 User string is search pattern
* 1.4 Make setting MYEDITOR easiser for Unix
* 1.5 Erase message _ltex not found


// Caller Program
// --------------

program ltex, rclass
	version 10.0

	gettoken subcmd rest: 0
	if "`subcmd'"=="TeX" {
	   TEXIT `rest'
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
	local names: dir `"`c(pwd)'"' files "*`namelist'*.tex"
	local names: list sort names

	if "$MYEDITOR" == "" local open doedit
	else {								
		local open $MYEDITOR
		if c(os)=="Unix" local back ">& /dev/null &"
	}

	
	foreach name of local names {
		if "`erase'" != "" /// 
		   local eitem `"[{stata `"erase "`name'""':{err}erase}]"'
		display 	///  
	  	`"{txt}`eitem'"' 	///  
	  	`" [{stata `"view "`name'""':view}]"'   ///
	  	`" [{stata `"`open' "`name'" `back'"':edit}]"' ///
	  	`" [{stata `"ltex TeX  "`name'""':trypdf}]"' 	///
	  	`" {res} `name' "'
	}

	display _n `"{txt}Click [{stata `"ldir"':here}] for other links"'

	return local files `"`names'"'
end


// TEXIT
// -----

program TEXIT
	version 10.0

	quietly CHECKIT `0'
	
	if "`=r(type)'" == "full" PREAMPLE `0', full
	else if "`=r(type)'" == "table" PREAMPLE `0', table(`=r(cols)')
	else if "`=r(type)'" == "stlog" PREAMPLE `0', stlog
		
	TRYPDF `0'	
end

// CHECKIT
// -------

program CHECKIT, rclass
	version 10.0
	args file

	tempname texfile
	local full 0
	file open `texfile' using "`file'", read

	local i 1
	file read `texfile' line
	while r(eof)==0 & `i' < 30 {
              
	      // STLOG?
	      if `i++'==1 & `"`=substr(`"`=trim(`"`line'"')'"',1,1)'"' == `"."' {
	      	 file close `texfile'
	      	 return local type "stlog"
	      	 exit
	      }
              
	      // FULL?	      
              local line: subinstr local line "documentclass" "" ///
	      , all count(local full)
	      if `full'>0 {
	      	 file close `texfile'
	      	 return local type "full"
	      	 exit
	      }
              
	      // TABLE?
		local line: subinstr local line "{tabular}" "" ///
		  , all count(local tabular)
		if `tabular'>0 {
			file close `texfile'
			return local type "table"
			return local cols "0"
			exit
		}
		
		// TABLE STUB?
		local x: subinstr local line "multicolumn" "" ///
		  , all count(local skip)
		if `skip'==0 {
			local line: subinstr local line "\\" "@"
			gettoken row:line, parse("@")
			local x:subinstr local row "&" "&", all count(local cols)
			if `cols' > 0 {
	      	      file close `texfile'
				return local type "table"
				return local cols `cols'
				exit
			}
		}
		file read `texfile' line
	}
}
end

// CREATE PREAMPLE
// ---------------

program PREAMPLE
syntax anything [, stlog full table(int -1) ]	

// Allready complete
if "`full'" != "" quietly cp `anything' _ltex.tex, replace

// Other files
else {
     
     tempname main
     quietly file open `main' using _ltex.tex, write replace
        
     // Standard Preamble
     file write `main' ///
     _n `"\documentclass{article}"'  ///
     _n `"\usepackage{amsmath}"'     ///  I think these are pretty standard
     _n `"\usepackage{amssymb}"'     ///

     if "stlog" != "" file write `main' _n `"\usepackage{stata}"'
  
     file write `main' _n `"\begin{document}"'

     // Begin tabulate, if necessary
     if `table' > 0 {
     	local init l
     	forv i=1/`table' {
	     local init `init'c
	}
     	file write `main' _n `"\begin{tabular}{`init'}"'
     }

     // Begin stlog, if necessary
     if "`stlog'" > "" file write `main' _n `"\begin{stlog}"'

     // Add original TeX-file
     tempname texfile
     file open `texfile' using `anything', read
     file read `texfile' line 
     while r(eof)==0 {
         file write `main' _n `"`line'"'
         file read `texfile' line
     }
     file close `texfile'
        
     // Close environments, if necessary
     if "`init'" != "" file write `main' _n `"\end{tabular}"'
     if "`stlog'" != "" file write `main' _n `"\end{stlog}"'
     
     // Finish
     file write `main' _n `"\end{document}"'
     file close `main'
 }
end


// TRYPDF
// ------

program TRYPDF

if c(os)=="Unix" {
	local open xdg-open
	local back ">& /dev/null &"
}
else if c(os)=="Windows" local open start
else if c(os)=="MacOSX" local open open


capture erase _ltex.pdf
quietly !pdflatex _ltex

capture confirm file _ltex.pdf
if _rc {
   // noi di as error `"Could not typeset `0'"'
   
   noi di as text "Check out {view _ltex.tex} and errors in {view _ltex.log}"
   erase _ltex.aux
   exit
} 
else {
     ! `open' _ltex.pdf `back'
     erase _ltex.tex
     erase _ltex.aux
     erase _ltex.log
}
    
end
exit
    
Author: Ulrich Kohler
    Tel +49 (0)30 25491 361
    Fax +49 (0)30 25491 360
    Email kohler@wzb.eu
    
    
    






end




















exit

Author: Ulrich Kohler
	Tel +49 (0)30 25491 361
	Fax +49 (0)30 25491 360
	Email kohler@wzb.eu


