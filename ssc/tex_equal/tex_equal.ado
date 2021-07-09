*! Version 1.0.0 - 29 July 2014                                             		
*! Author: Santiago Garriga                                                     
*! garrigasantiago@gmail.com      


/* *===========================================================================
	tex_equal: Program to compare ASCII text or binary files
	Reference: 
-------------------------------------------------------------------
Created: 		29Jul2014	Santiago Garriga
Modified:		
version:		01 
*===========================================================================*/

cap program drop tex_equal
program define tex_equal, rclass
	version 8.1
	syntax [anything]									///
		[if] [in],										///
		[												///
		file1(string)									///
		file2(string)									///
			display										///
			range(numlist min=1 max=2)					///
			lines(numlist max=1)						///
		]

*------------------------------------1.1: Error Messages ------------------------------------------

* Specify both files
if ("`file1'" == "" ) | ("`file2'" == "" ) {	
	disp in red "Both files, file1 and file2, should be specified"
	error
}	

* Existence of both files
if ("`file1'" != "" ) & ("`file2'" != "" ) {	
	cap confirm file `file1'
	if _rc != 0 {
		disp in red "File 1 does not exist"
		error
	}
	cap confirm file `file2'
	if _rc != 0 {
		disp in red "File 2 does not exist"
		error
	}
}	

* Rage values greater than one - No more than two range values

if ("`range'" != "" ) {
	
	if (wordcount("`range'") == 1) {
		if `range' < 1	{
			disp in red "Only positive numbers are valid in the range option"
			error			
		}
	} //  range == 1
	
	if (wordcount("`range'") == 2) {
		
		local start: word 1 of `range'
		local end: word 2 of `range'
		
		if `start' < 1	{
			disp in red "Only positive numbers are valid in the range option"
			error			
		}
	
	if `start' >= `end' {
			disp in red "The elements in the range options are not valid"
			error			
		}
	} //  range == 2
}

* Lines greater than Zero - No more than one line value
if ("`lines'" != "" ) {
	
	if (wordcount("`lines'") == 1) {
		if `lines' < 0	{
			disp in red "Only positive numbers are valid in the range option"
			error			
		}
	} //  lines == 1
	
	if (wordcount("`lines'") > 2) {	
		disp in red "The quantity of elements in the line option is not valid"
		error
	}	//  lines > 1
	
	if (wordcount("`range'") == 2) & (wordcount("`lines'") == 1){	
		disp in red "Range and lines options are not correct. Lines option is valid only with one range element"
		error
	}	
	
	
}


*------------------------------------1.2: Default Options ------------------------------------------
* Range and lines (default option for the range)
if ("`range'" != "" ) {
	local start: word 1 of `range'
	if (wordcount("`range'") == 1) & (wordcount("`lines'") == 1)	{
		local end = `start' + `lines'
	} //  range == 1
	else {
		local end: word 2 of `range'
		local lines = `end' - `start'
	} // range == 2
}

if "`start'" == "" local start = 1
if "`end'" == "" local end = .
		
*------------------------------------1.3: Program --------------------------------------------------
qui {
		
	global file1 "`file1'"
	global file2 "`file2'"
	
	* Temporal files and names
	tempfile temp1 temp2 									// Generate temporary file
	tempname in1 in2										// Generate temporary names

	* Copy Files
	copy "$file1"  `temp1', replace 						// Copy do file	1st file
	copy "$file2"  `temp2', replace 						// Copy do file	2nd file
	
	
	* Display Files names

	noi dis as text _new "{p 4 4 2}{cmd:File I :} " in y  "  $file1" `"{browse "$file1":{space 10}Open }"'" {p_end}" 
	noi dis as text _new "{p 4 4 2}{cmd:File II:} " in y  "  $file2" `"{browse "$file2":{space 10}Open }"'" {p_end}" 
	noi dis as text "{hline 106}" 
	
	** File I **
	
	* Open copied file to read
	file open `in1' using `temp1', read
	* Read file
	file read `in1' line
	
	** File II **	
	
	* Open copied file to read
	file open `in2' using `temp2', read
	* Read file
	file read `in2' line2
	

	* Generate local counting lines
	local linenum = 1						// Line number
	local dif = 0							// Number of differences
	
	
	* Generate local counting lines
	while r(eof) == 0 & `linenum' < `start'  {	// Jump from the first line to the start line
		local ++linenum		
		file read `in1' line
		file read `in2' line2	
	}
	
	
	* Analyze relevant section of the file
	while r(eof) == 0  & `linenum' >= `start' &  `linenum' <= `end'  {	// Search use and save in do file
		
		if `"`macval(line)'"'!=`"`macval(line2)'"' {
			
			if "`display'" == "display" {
			
				noi display in g `"`linenum' : "' _col(8) _asis in y `"`macval(line)'"' _newline(1) _col(8) _asis in y `"`macval(line2)'"' _newline(1) 
			}
			local ++dif		
		}
		local ++linenum		
		file read `in1' line
		file read `in2' line2			
	}

	* Display Results
	if `dif' == 0 {
		noi di _skip(1) in g "Perfect comparison"
		local comparison = 1
		local dif = 0
	}
	else {
		local comparison = 0
		if "`display'" == "display" noi dis as text "{hline 106}" 
		noi di "Number of differences: `dif'"
	}		
	
	* Return values
	return local file2 "`file2'"
	return local file1 "`file1'"
	return local ndif = `dif'
	return local comparison = `comparison'

}	

end 

exit
