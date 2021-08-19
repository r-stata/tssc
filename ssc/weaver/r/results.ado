/*

							  Stata Weaver Package
					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de

		
                  The Weaver Package comes with no warranty    	

	Description
	===========
	
	This command preserves the output of a Stata command and appends it to 
	Weaver log. The function of the program changes based on status of Stata
	log:
	
	1- If Stata log is "on"
		
		- if the log type is smcl, create a temporary smcl log, translate it 
		  to text, append the text version to Weaver log, and then append the 
		  smcl version to Stata log
		  
		- if the log is in text, create a text log and then append it to both 
		  Weaver and Stata logs
		  
	2- If the Stata log is "off" or "closed" just create a text log and append 
	   it to Weaver log. 
*/


program define results
//version 11

    tempname canvas needle
	tempfile smcl								//smcl log
	tempfile text								//txt log
    set more off  
	
	********************************************************************
	* CHECK THE CURRENT LOG
	********************************************************************
    quietly log query    
	if `"`r(filename)'"' != "" {
		local name   `"`r(filename)'"'		//save the log name
		local status `"`r(status)'"'		// status of the log
		local type   "`r(type)'"			//save the log type
	}
	
	********************************************************************
	* If log is ON 
	*
	* - save in information of the current log and then close it
	* - execute the code and save the output in a temporary log
	********************************************************************
	
	if "`name'" != "" {
		capture quietly log close
		if "`type'" == "text" cap qui log using `text', replace text
		if "`type'" == "smcl" cap qui log using `smcl', replace smcl
	}	
	else cap qui log using `text', replace text
	version `c(stata_version)': `0'
	cap quietly log close
			
	********************************************************************
	* if log is SMCL
	*
	* - if the log is SMCL, save the smcl2txt translator details
	* - translate the smcl log to text
	* - reset the smcl2txt translator's default settings
	* - append the smcl or text temp log to the Stata log file
	********************************************************************
	if "`type'" == "smcl" { 
		qui translator query smcl2txt
		local savelinesize `r(linesize)'
		local lm `r(lmargin)'
		translator set smcl2txt linesize `c(linesize)'
		translator set smcl2txt lmargin 0
		if "`r(cmdnumber)'" == "on" {
			local savecmdnumber on
			translator set smcl2txt cmdnumber off
		}
		if "`r(logo)'" == "on" {
			local savelogo on
			translator set smcl2txt logo off
		}
		cap qui translate `smcl' `text', trans(smcl2txt) replace
		
		if "`savecmdnumber'" == "on" translator set smcl2txt cmdnumber on
		if "`savelogo'" == "on" translator set smcl2txt logo on
		if !missing("`lm'") translator set smcl2txt lmargin `lm'
		translator set smcl2txt linesize `savelinesize'
	}
	
	********************************************************************
	* If log was ON 
	*
	* - append the content of the temporary log file to Stata log
	********************************************************************	
	if "`name'" != "" {
		cap file open `canvas' using "`name'", write append 
		if "`type'" == "smcl" cap file open `needle' using "`smcl'", read
		if "`type'" == "text" cap file open `needle' using "`text'", read
		cap file read `needle' line	
			
		while r(eof)==0 {
			cap file write `canvas' `"`macval(line)'"' _n      
			cap file read `needle' line
		}
			
		cap file close `canvas' 
		cap file close `needle'
	}	
	
	
	********************************************************************
	* Append the temporary log to Weaver log 
	*
	* - append the content of the temporary log file to Stata log
	* - only write the results if there is at least 1 line in the log
	********************************************************************
	
	cap file open `canvas' using `"$weaverFullPath"', write text append
	cap file open `needle' using "`text'", read
	cap file read `needle' line
	
	if r(eof)==0 {
		if "$weaverMarkup" == "html"  cap file write `canvas' `"<pre class="output" >"'	
		if "$weaverMarkup" == "latex" cap file write `canvas' _n "\begin{verbatim}" _n
		local close close								//indicator
	}
	
	while r(eof)==0 {
        cap file write `canvas' `"`macval(line)'"' _n      
        cap file read `needle' line
	}
	
	if !missing("`close'") {
		if "$weaverMarkup" == "html" cap file write `canvas' "</pre>" _n(2)
		if "$weaverMarkup" == "latex" cap file write `canvas' "\end{verbatim}" _n(2)
	}
	
	
	********************************************************************
	* Reopen Stata log, if it was open
	********************************************************************
    if !missing("`name'") {
		quietly log using "`name'", append `type'
        if "`status'" != "on" quietly log `status'
	}
		
	// Make sure the weaver html log is open
	if "$weaver" == "" {
		di as txt _n(2) "{hline}"
		di as error "{bf:Warning}" 
		di as txt "{help weaver}'s log file is off!" 
		di as txt "{hline}{smcl}"	_n
	}    
end
	

	
