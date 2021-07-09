*!writeinput - create example of dataset for -input- via a .do file
*!Eric A. Booth  <ebooth@tamu.edu>
*!version 1.0.1 Mar2011

program def writeinput
syntax varlist [if] [in/] using/  [, Replace noCLEAR Note(str asis) ]
version 9.2

**check using and convert to .do file**
   loc check:subinstr loc using ".do" "", count(loc howmany)
   if "`howmany'" == "0" {
   		di as smcl in red `"Using must have ".do" extension"'
   		exit 198
   	}
   	
**check replace option**
 cap confirm file `"`using'"'
      if !_rc {
			if `"`replace'"'=="" {
				di as smcl in red `"File {browse "`using'"} exists; Specify "replace" option"'
				exit 198
                }
            }
        
**touse**
marksample touse

qui {
preserve
if "`if'" != "" keep `if'

		**find last variable in list**
		loc howmany:word count `varlist'
		loc lastvar:word `howmany' of `varlist'
		
		
**write to file**
cap file close mh
file open mh using "`using'", write text replace

**header**

		**clear**
		if `"`clear'"' != "noclear" file write mh "clear" _n
		**input statement**
		file write mh "inp   " 
		**write variable & var type list**
		foreach v in `varlist' {
				loc type_`v':format `v'
					**parse var format**
					foreach c in "-" "%" "~" {
						loc type_`v':subinstr loc type_`v' "`c'" "", all
						}
					loc strings:subinstr loc type_`v' "s" "", count(loc stringcount)
					if `"`stringcount'"' != "0"  loc newtype_`v' "str`strings'"
       			**check for last var in list (add _n)**
       			loc addto  
       			if `"`lastvar'"' == "`v'" loc addto "_n"
       			***write vars***
				file write mh `"`newtype_`v'' `v'"'  _tab(1) `addto'
				}
				

**values**
	**write values**
			**noi list i year id
		 if "`in'" == "" loc in "1/`=_N'"
	     forval n = `in' {
   			foreach v in `varlist' {
   				if `n' <= `=_N' {
	      	 	**check for type of var**
	       		  	cap confirm string variable `v'
	               		if !_rc {
							qui replace `v' = `""`=`v'[`n']'""' in `n'
		               	 }
		              ** noi di in r "`v': `n'"
	       		**check for last var in list (add _n)**
	       			loc addto`n'  "  "
	       			if `"`lastvar'"' == "`v'" loc addto`n' "_n"
	        	**write -->
	        		 file write mh `"`=`v'[`n']'"'  _tab(1) `addto`n''
         }
	}        
}


**footer, notes, and end**
file write mh "end   "  _n
if `"`note'"' != ""  file write mh  `"** `note' "'  _n
noi di as smcl `"Output file written to:  {browse `using'}"'

**file close & restore**
cap file close mh
restore
}

end



/*

//examples//
sysuse auto, clear
g make2 = make
writeinput make mpg price for in 1/5  using "test1.do", repl
writeinput make mpg price for if for==0 in 20/60 using "test2.do", r n(Here's some notes)
writeinput make price  if for==1 & pri>200 in 1/50 using "test3.do", r n(notes here)
type "test3.do"

*/



