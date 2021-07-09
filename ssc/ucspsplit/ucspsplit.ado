*-------------------------------------------------------------------------------
*
*	"uscpsplit: Stata program to extract paradata from ucsp paradata strings"  
*	Version 1.0
*	Authors: Kai Willem Weyandt (GESIS) & Lars Kaczmirek (GESIS)
*
*-------------------------------------------------------------------------------

program define ucspsplit
version 10
syntax varlist(string) [if], [Visits(string)] [Generate(string)]

marksample touse, novarlist
tempvar ucspsplit

/*
option generate() to specify which of the following variables are to be generated, default is "all"
	vsts	
	dac
	ms1stclk
	ms2ndlstclk
	mslstclk
	nclk
	ndblclk
	winx
	winy
	scrollx
	scrolly
	ms1stkey
	mslastkey
	cntblur
	msblur
	
option visits()
	number of visits to be splittet, default == 1 
*/

/* local definitions	
part		element of varlist
ucspcplit 	temporary variable copy of part
length		number of existing visits in part
visits 		number of visits specified by user to be generated
visitsWalk 	run parameter per part
hesher 		run parameter for the splitted vars of ucspsplit
*/

foreach part of varlist `varlist' { //go through all elements of varlist

cap drop __* //drop previously defined temporary variables
qui gen `ucspsplit' = `part' `if' //gen temporary variable ucspsplit

cap assert !regexm(`ucspsplit', "^#6#") //check version number of ucsp-string
if !_rc {
	di in red "Variable `part' does not seem to contain data that matches UCSP version 6!" 
}

//check for incorrect specified options
if "`generate'"!="" {
	local optioncheck = "vsts dac ms1stclk ms2ndlstclk mslstclk nclk ndblclk winx winy scrollx scrolly ms1stkey mslastkey cntblur msblur"
	foreach element of local generate {
		if regexm("`optioncheck'","`element'")!=1 { 
			drop `ucspsplit'*
			error 198
		}
	}
}

cap assert !regexm(`ucspsplit', "^#6#") //if version 6 then proceed
if _rc {
	
	*** split ucsp ***
	qui replace `ucspsplit'= subinstr(`ucspsplit', "#6#","",1)  //get rid of the first #6#
	qui replace `ucspsplit'= subinstr(`ucspsplit', "/",";",.)   //replace delimiter for 2+ visits
	qui split `ucspsplit', parse(#6#)  //parse string
	qui tokenize `r(varlist)'  //tokenize return list of split command
	qui local length = wordcount(r(varlist)) //get number of total visits 
	
	local visitsWalk = "`visits'"

	*** option: vistits ***
	cap assert "`visits'"<="`length'" //assert that number of visits specified in option are smaller or equal actual visits
	if _rc {
		*drop `ucspsplit'*	
		di in yellow "More visits specified for `part' than actually existent! Visits set to maximum: `length'"
		local visitsWalk = "`length'"
	}
	
	cap assert "`visits'"!="" //if option visits is not specified, set default to 1
	if _rc {
		local visitsWalk = 1
	}
	
	
	*** loop for 1+ visits ***
	forval hesher=1(1)`visitsWalk'{ //go through all 15 variables embodied in the string, destring and rename
		qui split ``hesher'', parse(";")
		
		capture destring ``hesher''1, replace
		capture replace  ``hesher''2 = regexr(``hesher''2,"^dac","1")
		capture destring ``hesher''2, replace 
		capture destring ``hesher''3, replace 
		capture destring ``hesher''3, replace
		capture destring ``hesher''4, replace
		capture destring ``hesher''5, replace
		capture destring ``hesher''6, replace
		capture destring ``hesher''7, replace
		capture destring ``hesher''8, replace ignore("undefined")
		capture destring ``hesher''9, replace ignore("undefined")
		capture destring ``hesher''10, replace
		capture destring ``hesher''11, replace
		capture destring ``hesher''12, replace
		capture destring ``hesher''13, replace
		capture destring ``hesher''14, replace
		capture destring ``hesher''15, replace
		
		capture label var ``hesher''1 "previous visits"
		capture label var ``hesher''2 "do-answer-check"
		capture label var ``hesher''3 "pageload to 1st click (ms)"
		capture label var ``hesher''4 "pageload to 2nd last click (ms)"
		capture label var ``hesher''5 "pageload to last click (ms)"
		capture label var ``hesher''6 "click count"
		capture label var ``hesher''7 "double-click count"
		capture label var ``hesher''8 "window width"
		capture label var ``hesher''9 "window height"
		capture label var ``hesher''10 "horizontal scroll maximium (pixel)"
		capture label var ``hesher''11 "vertical scroll maximium (pixel)"
		capture label var ``hesher''12 "pageload to first keystroke (ms)"
		capture label var ``hesher''13 "pageload to last keystroke (ms)"
		capture label var ``hesher''14 "blur-event count"
		capture label var ``hesher''15 "pageload to last blurevent (ms)"
		
		
		
		
		if regexm("`generate'","vsts")==1 {
			cap confirm variable `part'`hesher'_vsts
			if !_rc {
				di in red "Variable `part'`hesher'_vsts already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''1 `part'`hesher'_vsts
		}
		if regexm("`generate'","dac")==1 {
			cap confirm variable `part'`hesher'_dac
			if !_rc {
				di in red "Variable `part'`hesher'_dac already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''2 `part'`hesher'_dac
		}
		if regexm("`generate'","ms1stclk")==1 {
			cap confirm variable `part'`hesher'_ms1stclk
			if !_rc {
				di in red "Variable `part'`hesher'_ms1stclk already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''3 `part'`hesher'_ms1stclk
		}
		if regexm("`generate'","ms2ndlstclk")==1 {
			cap confirm variable `part'`hesher'_ms2ndlstclk
			if !_rc {
				di in red "Variable `part'`hesher'_ms2ndlstclk already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''4 `part'`hesher'_ms2ndlstclk
		}
		if regexm("`generate'","mslstclk")==1 {
			cap confirm variable `part'`hesher'_mslstclk
			if !_rc {
				di in red "Variable `part'`hesher'_mslstclk already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''5 `part'`hesher'_mslstclk
		}
		if regexm("`generate'","nclk")==1 {
			cap confirm variable `part'`hesher'_nclk
			if !_rc {
				di in red "Variable `part'`hesher'_nclk already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''6 `part'`hesher'_nclk
		}
		if regexm("`generate'","ndblclk")==1 {
			cap confirm variable `part'`hesher'_ndblclk
			if !_rc {
				di in red "Variable `part'`hesher'_ndblclk already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''7 `part'`hesher'_ndblclk
		}
		if regexm("`generate'","winx")==1 {
			cap confirm variable `part'`hesher'_winx
			if !_rc {
				di in red "Variable `part'`hesher'_winx already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''8 `part'`hesher'_winx
		}
		if regexm("`generate'","winy")==1 {
			cap confirm variable `part'`hesher'_winy
			if !_rc {
				di in red "Variable `part'`hesher'_winy already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''9 `part'`hesher'_winy
		}
		if regexm("`generate'","scrollx")==1 {
			cap confirm variable `part'`hesher'_scrollx
			if !_rc {
				di in red "Variable `part'`hesher'_scrollx already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''10 `part'`hesher'_scrollx
		}
		if regexm("`generate'","scrolly")==1 {
			cap confirm variable `part'`hesher'_scrolly
			if !_rc {
				di in red "Variable `part'`hesher'_scrolly already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''11 `part'`hesher'_scrolly
		}
		if regexm("`generate'","ms1stkey")==1 {
			cap confirm variable `part'`hesher'_ms1stkey
			if !_rc {
				di in red "Variable `part'`hesher'_ms1stkey already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''12 `part'`hesher'_ms1stkey
		}
		if regexm("`generate'","mslastkey")==1 {
			cap confirm variable `part'`hesher'_mslastkey
			if !_rc {
				di in red "Variable `part'`hesher'_mslastkey already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''13 `part'`hesher'_mslastkey
		}
		if regexm("`generate'","cntblur")==1 {
			cap confirm variable `part'`hesher'_cntblur
			if !_rc {
				di in red "Variable `part'`hesher'_cntblur already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''14 `part'`hesher'_cntblur
		}
		if regexm("`generate'","msblur")==1 {
			cap confirm variable `part'`hesher'_msblur
			if !_rc {
				di in red "Variable `part'`hesher'_msblur already exists! Variable will not be replaced!"
			}
			cap rename ``hesher''15 `part'`hesher'_msblur
		}
		
		if "`generate'"=="" { //if no generate option is specified, all variables will be generated, as long as they do not already exist
			foreach subscript in vsts dac ms1stclk ms2ndlstclk mslstclk nclk ndblclk winx winy scrollx scrolly ms1stkey mslastkey cntblur msblur {
				cap confirm variable `part'`hesher'`subscript'
				if !_rc {
					di in red "Variable `part'`hesher'_`subscript' already exists! Variable will not be replaced!"
				}
			}
			
			cap rename ``hesher''1 `part'`hesher'_vsts
			cap rename ``hesher''2 `part'`hesher'_dac
			cap rename ``hesher''3 `part'`hesher'_ms1stclk
			cap rename ``hesher''4 `part'`hesher'_ms2ndlstclk
			cap rename ``hesher''5 `part'`hesher'_mslstclk
			cap rename ``hesher''6 `part'`hesher'_nclk
			cap rename ``hesher''7 `part'`hesher'_ndblclk
			cap rename ``hesher''8 `part'`hesher'_winx
			cap rename ``hesher''9 `part'`hesher'_winy
			cap rename ``hesher''10 `part'`hesher'_scrollx
			cap rename ``hesher''11 `part'`hesher'_scrolly
			cap rename ``hesher''12 `part'`hesher'_ms1stkey
			cap rename ``hesher''13 `part'`hesher'_mslastkey
			cap rename ``hesher''14 `part'`hesher'_cntblur
			cap rename ``hesher''15 `part'`hesher'_msblur
		}

	}
	}
	
	drop `ucspsplit'*
}

end
