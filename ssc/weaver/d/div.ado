/*** DO NOT EDIT THIS LINE -----------------------------------------------------
Version: 1.0.0
Title: div
Description: __div__ performs Stata command and echoes the command or output or both
to the HTML log file. This command belongs to {bf:{help weaver}} packages.
----------------------------------------------------- DO NOT EDIT THIS LINE ***/

/***
Syntax
======

    Perform command and echo command and output to the HTML log
	
	{cmdab:div} [{cmdab:c:ode} | {cmdab:r:esult}] {it:command}

If the {cmdab:c:ode} subcommand is specified, only the command will be included, 
supressing the output from Weaver log. In contrast, if the {cmdab:r:esult} 
subcommand is specified, only the output will be included in the Weaver log and 
the command will be ignored. 

Description
===========

__div__ run Stata _command_ and echo the command and output in the HTML log
in {help weaver} package. If {help weaver} is not in use (i.e. there is not HTML
log open), __div__ run the command and return the output and at the end, it
also return a warning that the HTML log is not on.

{pstd}
The {cmdab:c:ode} subcommand can be added to __div__ command to only echo
the _command_ in the HTML log and suppress the output from the HTML log. Although
it continues to print the output in Stata results window.

{pstd}
The {cmdab:r:esult} subcommand can be added to __div__ command to only echo the
output in the HTML log and suppress {it:command} from the HTML log.
Although it continues to print the output in Stata results window.

Example(s)
=================

   {bf:div} echoes the command and output to the Weaver log. 

        . sysuse auto, clear
        . div regress mpg weight foreign headroom

    the {cmdab:r:esult} only includes the output in the weaver log

        . div r code misstable summarize
		
    the {cmdab:c:ode} subcommand only includes the command in the weaver log
	
        . div c generate newvar = price

Author
======

__E. F. Haghish__     
Center for Medical Biometry and Medical Informatics     
University of Freiburg, Germany     
_and_        
Department of Mathematics and Computer Science       
University of Southern Denmark     
haghish@imbi.uni-freiburg.de     
      
[Weaver Homepage](www.haghish.com/weaver)         
Package Updates on [Twitter](http://www.twitter.com/Haghish)    

- - -

_This help file was dynamically produced by[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/)_ 
***/


program define div

	
	****************************************************************************
	* Searching for "codes" and "results" subcommands
	*
	* - if the command includes at least 2 words, check for subcommands
	* - if a subcommand is found, remove the subcommand name from the command
	* - define a local macro "jump" if no subcommand is found
	****************************************************************************
	local line = `"`macval(0)'"'						// Save the macro
	tokenize `"`line'"'
	if !missing("`2'") {
		if "`1'" == "c" | "`1'" == "co" | "`1'" == "cod" | "`1'" == "code"  {
			local 0 : subinstr local 0 "`1'" ""		
			codes `0'
		}
		else if "`1'" == "r" | "`1'" == "re" | "`1'" == "res" | "`1'" == "resu" ///
			| "`1'" == "resul" | "`1'" == "result" {
			local 0 : subinstr local 0 `"`1'"' ""		
			results `0'
		}

		else {
			local jump = 1	
			if "`1'" == "mata:" local mata 1
		}	
	} 

	****************************************************************************
	* the "div" command
	*
	* - 
	****************************************************************************
	if missing("`2'") | "`jump'" == "1" {
		
		//cap set linesize $width
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
		
		// NOTE: The `c(userversion)' is not available on Stata 12. This can be 
		//		 replaced with `c(stata_version)'
		
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
		* Print the command to Weaver log 
		********************************************************************
		if "$weaverstyle" == "minimal" {
			cap file write `canvas' `"<pre class="sh_stata" >. "' 				///
			`"`macval(0)'"' _n 							//add dot
		}
		else {
			cap file write `canvas' `"<pre class="sh_stata" >"' 				///
			`"`macval(0)'"' _n 
		}
				
		cap file write `canvas' "</pre>" _n(3) 			// close syn highlighter
		
		********************************************************************
		* Append the temporary log to Weaver log 
		*
		* - append the content of the temporary log file to Stata log
		* - only write the results if there is at least 1 line in the log
		********************************************************************
		tempname canvas needle
		cap file open `canvas' using `"$weaverFullPath"', write text append
		cap file open `needle' using "`text'", read
		cap file read `needle' line
		
		if "$weaverMarkup" == "html" {
			if "$weaverstyle" == "minimal" {
				cap file write `canvas' `"<pre class="sh_stata" >. "' 			///
				`"`macval(0)'"' _n 
			}
			else {
				cap file write `canvas' `"<pre class="sh_stata" >"' 			///
				`"`macval(0)'"' _n 
			}
			cap file write `canvas' "</pre>" _n(3) 
		}
		
		if "$weaverMarkup" == "latex" {
			if "$weaverstyle" == "empty" | "$weaversynoff" == "synoff" {
				qui file write `canvas'  										///
				`"\begin{verbatim}. `macval(0)'\end{verbatim}"' 
			}
			else {
				qui file write `canvas'  										///
				"\begin{statax}" _n												///
				`". `macval(0)'\end{statax}"' 
			}
		}
	
	
		*if r(eof)==0 {
			if "$weaverMarkup" == "html"  cap file write `canvas' `"<pre class="output" >"'	
			if "$weaverMarkup" == "latex" cap file write `canvas' _n "\begin{verbatim}" _n
		*	local close close								//indicator
		*}
		while r(eof)==0 {
			cap file write `canvas' `"`macval(line)'"' _n      
			cap file read `needle' line
		}
		
		*if !missing("`close'") {
			if "$weaverMarkup" == "html" cap file write `canvas' "</pre>" _n(2)
			if "$weaverMarkup" == "latex" cap file write `canvas' "\end{verbatim}" _n(2)
		*}
		
		
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
			di as txt "{help weaver}'s html log file is off!" 
			di as txt "{hline}{smcl}"	_n
		}   
	}
		
end

// DYNAMIC HELP FILE
// ===================================

*markdoc div.ado, export(sthlp) replace

