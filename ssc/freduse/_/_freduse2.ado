*! version 1.0.2  16sep2005
program define _freduse2

	version 9.0 

	syntax using/ , 		///
		[			///
		clear			///
		]
		
	tempname fh

	file open `fh' using `"`using'"', read

	local j     = 1 
	local done  = 0
	local notes = 0
	local note2 = 0
	local c     = 0

	while `done' < 1 {
		file read `fh' line
			
		hlineparse , line(`"`line'"') notes(`notes')

		local done   = r(done)
		local notes  = r(notes)

		if "`r(vname)'" != "" {
			local vname "`r(vname)'"
		}
		
		if `done'==0 & `notes' == 0 {
			local ++c
			local cat`c'  `"`r(cat)'"'
			local desc`c' `"`r(desc)'"'
		}
		else {
			if `done'==0 & `notes' != 0 {
				if `note2' > 0 {
					local notesv `"`notesv' `r(desc)'"'
				}	
				else {
					local notesv `"`notesv'`r(desc)'"'
					local ++note2
				}
			}
		}

		local ++j
	}
	local ++j


	file close `fh'

	infix `j' first str10 date 1-10 double `vname' 11-80 using	///
		`"`using'"' , `clear'

	qui gen daten = date(date,"ymd")
	format %td daten

	forvalues i = 1/`c' {
		char define `vname'[`cat`i''] `"`desc`i''"'
	}

	if `"`notesv'"' != "" {
		char define `vname'[Notes] `"`notesv'"'
	}

	local vlab : char `vname'[Title]
	label variable `vname' `"`vlab'"'
	label variable date "fed string date"
	label variable daten "numeric (daily) date"
end

program define hlineparse , rclass
	
	syntax , 					///
		[					///
		line(string) 				///
		notes(integer 0)			///
		]

	if `"`line'"' == "" {
		ret scalar done = 1 
		exit
	}


	if `"`line'"' != "" & `notes' > 0  {

		local line = trim(`"`line'"')	
		
		ret local desc `"`line'"'	
		ret scalar done  = 0
		ret scalar notes = 1
		exit
	}

	gettoken cat desc: line , parse(":")
	gettoken tmp desc: desc , parse(":")

	local desc = trim(`"`desc'"')	
	local cat : subinstr local cat " " "_", all

	if `"`cat'"' == "" & `"`desc'"' == "" {
		ret scalar done = 1
		exit
	}

	if `"`cat'"' == "Title" | `"`cat'"' == "Source"  	///
			| `"`cat'"' == "Release" 		///
			| `"`cat'"' == "Seasonal_Adjustment" 	///
			| `"`cat'"' == "Frequency" 		///
			| `"`cat'"' == "Units" 			///
			| `"`cat'"' == "Date_Range" 		///
			| `"`cat'"' == "Last_Updated" 	{
		ret local cat  `"`cat'"'	
		ret local desc `"`desc'"'	
		ret scalar done = 0
		ret scalar notes = 0
		exit
	}

	if `"`cat'"' == "Series_ID" {
		ret local cat  `"`cat'"'	
		ret local desc `"`desc'"'	
		ret scalar done = 0
		ret scalar notes = 0
		capture noi confirm name `desc'
		
		if _rc {
			di as err "Series ID specifies invalid name"
			exit 498
		}
		ret local vname  `"`desc'"'
		exit
	}

	if `"`cat'"' == "Notes" {
		ret local cat  `"`cat'"'	
		ret local desc `"`desc'"'	
		ret scalar done = 0
		ret scalar notes = 1
		exit
	}


//	ERROR IF here

	di as error "header entry of unknown type encountered"
	di as error `"      unknown header type  = `cat'"'
	di as error `"   value of unknown header = `desc'"'

	exit 498

end

