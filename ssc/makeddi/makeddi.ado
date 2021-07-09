*! Version 1.0.0 - 24 Mar 2015                               
*! Author: Andres Castaneda -- r.andres.castaneda@gmail.com 
*! Author: Santiago Garriga -- garrigasantiago@gmail.com    

/* *===========================================================================
	makeddi: Program to create DDIs
-------------------------------------------------------------------
Created: 		13Feb2015	(Santiago Garriga & Andres Castaneda) 
version:		01 
*===========================================================================*/

version 10 

cap program drop makeddi
program define makeddi, rclass

syntax  using/,										///
	[												///
	VARiables(string)								///
	name(string)									/// name of the DDI no be created (or modified)
	rootddi(string)									/// folder -> DDI will be saved
	data(string)									/// data to get variables to be documented
	sort											/// sort variables in data in alphabetical order
	exclude(string)									/// variables from data to be excluded
	add(string)										/// add variables documentation to existing DDI
	replace											/// replace existing DDI
	clear											///
	]

* ==================================================================================================
* =========================================1.ERROR Messages======================================== 
* ==================================================================================================

qui {

* Either Data or variables option
if ("`data'" != "") & ("`variables'" != "") {
	disp in red "Options variables and data are mutually exclusive. You must chose only one of them"
	error
}   

* Exclude is valid only when option data is selected
if ("`data'" == "") & ("`exclude'" != "") {
	disp in red "Exclude option is valid only when data option is selected"
	error
}



* ==================================================================================================
* =========================================2. Set Default Options=================================== 
* ==================================================================================================


* If `using'
if `"`using'"' != "" {
	local dofile `"`using'"'
	if (substr(reverse("`dofile'"),1,3) != "od.") {
		  local dofile "`dofile'.do"
	}
}

* If `add'
if `"`add'"' != "" {
	if (substr(reverse("`add'"),1,4) != "lmx.") {
		  local add "`add'.xml"
	}
}



/*======================
Define locals for paths
=======================*/

* Current directory
local currentdir = c(pwd) // local to preserve the current directory
 
* Local with the directory where the XML will be saved
if ("`rootddi'" == "") local rootddi "`currentdir'"




if ("`data'" != "") {
	describe using "`data'",  varlist
	local variables `r(varlist)'
	noi disp "`variables'"
	if ("`sort'" != "") local variables : list sort variables
	noi disp "`variables'"
	if ("`exclude'" != "") local variables : list variables - exclude
} 


* ==================================================================================================
* ======================================= 3. Create DDi ============================================
* ==================================================================================================

noi disp in y "Message from mkddi: " in g "I'm working on creating your DDI. Please wait...."

* Local Template
if ("`add'" == "") { 
	findfile makeddi.ado
	local tempxml = r(fn)
	local tempxml: subinstr local tempxml ".ado" "_template.xml"
}

if ("`add'" != "") { 
	local tempxml "`add'"
}

* copy XMl template
tempfile  temp1 temp2 temp3 temp4					// Generate temporary file1 which hold the xml

* Copy XML file
copy "`tempxml'" `temp1', replace

* Copy do-file 
filefilter "`dofile'" `temp3', from("\t") to(" ") replace 	// Get rid of Tabs in do-file

	* Check locals replacement
	filefilter `temp3' `temp4', from("left quote") to("") replace
	local trial1 = `r(occurrences)' 
	filefilter `temp3' `temp4', from("right quote") to("") replace
	local trial2 = `r(occurrences)' 
					
	if `trial1' == 0 & `trial2' == 0 {	// if check replacement is ok
		
		* Replace symbols for locals
		filefilter `temp3' `temp4', from("\LQ") to("left quote") replace
		filefilter `temp4' `temp3', from("\RQ") to("right quote") replace
	}
	
	else {	
		di in red `"It's not possible to replace the single quotes in the temporary do file"'
		error
	}
	



*** Template Variables ***
foreach var of local variables {		// Loop for variables

	
	* Temporal files and names	
	tempfile temp2  							// Generate temporary file
	tempname in out									// Generate temporary names

	******************Identify the section of the XML to be modified*******************************
	* Open file
	file open `in' using `temp1', read 			// Open copied file
	file read `in' line 						// Read file

	* Generate local counting lines
	local linenum = 0
	while r(eof)==0 {
		local ++linenum
		file read `in' line
		
		* Option I
		/*
		</dataDscr></codeBook>
		*/
		if  (regexm(`"`macval(line)'"',"^.*</dataDscr></codeBook>")) {
			local end = `linenum' 
			continue, break
		} 		//  end of condition to find the end of the XML file
		
		* Option II
		/*
		 </dataDscr>
		</codeBook>
		*/
		
		* Identify variable section	
		if  (regexm(`"`macval(line)'"',"^.*</codeBook>")) {
			local end = `linenum' - 1
			continue, break
		} 		//  end of condition to find the end of the XML variable
	}
	file close `in'


	********************** Generate section 1 of the final XML*************************************

	* Open copied file to read
	file open `in' using `temp1', read
	* Open copied file to write
	file open `out' using `temp2', write replace
	* Read file
	file read `in' line

	* Generate local counting lines
	local linenum = 0		

	while r(eof)==0  {	// write file
		local ++linenum		
		if `linenum' >= 1 &  `linenum' <= `end'  file write `out' `"`macval(line)'"' _n
		file read `in' line
	} 	// end loop of write file
	file close _all


	*************************** Generate section 2 of the final XML********************************

	* Open copied file to read
	file open `in' using `temp3', read
	* Open copied file to write
	file open `out' using `temp2', write append
	* Read file
	file read `in' line
	
	* Text to be added before each variable code
	file write `out' `"<var ID="V1" name="`var'" files="F1" dcml="0" intrvl="contin">"' _n
	file write `out' `"<codInstr>"' _n
	file write `out' `"<![CDATA["' _n
	
	while r(eof)==0  {	// write file

		local line = ltrim(rtrim(itrim(`"`macval(line)'"'))) // avoid internal, leading and trailing blanks

*------------------------------------3.1: Identification of comments ------------------------------

		* A. Beginning with Opening and closing comments in the same line 
		if regexm(`"`macval(line)'"', `"^[ ]*(/\*.*\*/)(.*)"') 	local line = regexs(2)
			
		* B. Begin comment in one line and closing in other line
		if regexm(`"`macval(line)'"', `"^(.*)/\*"') {
			local partA = regexs(1) 
			while regexm(`"`macval(line)'"', `"\*/"') == 0 {
				file read `in' line				
			}

			* Close comment and nothing after
			if regexm(`"`macval(line)'"', `"\*/$"') == 1 {
				local line `"`macval(partA)'"'
			}
			* Close comment and something after
			else {
				if regexm(`"`macval(line)'"', `"^(.*)(\*/)(.*)$"') {
					local line = `"`macval(partA)'"' + " " + regexs(3) 
				}
			}
		} 
		
		* C. Identify * comments
		if regexm(`"`macval(line)'"', `"^[ ]*\*"') {
			file read `in' line
			continue
		}

		* D. Identify comments at the end of the line //
		if regexm(`"`macval(line)'"', `"^(.*)(//.*)"') local line = regexs(1) 
		
		* E. comment /*  */ after and in the middle of the line of code. Ex. gen var = var2 /* gen var1 */
		if regexm(`"`macval(line)'"', `"^(.*)(/\*.*\*/)(.*)"') local line = regexs(1) + " " + regexs(3) 

		local line = ltrim(rtrim(itrim(`"`macval(line)'"'))) // avoid internal, leading and trailing blanks

*------------------------------------3.2: Regular Commands ----------------------------------------
		
		*  Gen, egen, replace
		if (regexm(`"`macval(line)'"',`"^.*(:)?[ ]*(egen|g|g(e|en|ene|ener|enera|enerat|enerate)|replace)[ ]*(byte|int|long|float|double)?[ ]+`var'[ ]?=[ ]?"')) {
			file write `out' `"`macval(line)'"' _n
			file read `in' line
			continue
		}
		
		* Recode
		if (regexm(`"`macval(line)'"',`"^[ ]*recode.*[ ]*(g|g(e|en|ene|ener|enera|enerat|enerate))\(([a-zA-Z0-9_ ]*[ ]+`var'|[ ]*`var')([ ]*\)|[ ]+[a-zA-Z0-9_ ]*\))"')) {
			file write `out' `"`macval(line)'"' _n
			file read `in' line
			continue
		}
		
		* Encode and decode
		if (regexm(`"`macval(line)'"',`"^[ ]*(en|(en|de(c|co|cod|code))).*[ ]*(g|g(e|en|ene|ener|enera|enerat|enerate))\([ ]*`var'[ ]*\)"')) {
			file write `out' `"`macval(line)'"' _n
			file read `in' line
			continue
		}
		
		*destring and tostring generate
		if (regexm(`"`macval(line)'"',`"^[ ]*(de|to)string(.*)(g|g(e|en|ene|ener|enera|enerat|enerate))\(([a-zA-Z0-9_ ]*[ ]+`var'|[ ]*`var')([ ]*\)|[ ]+[a-zA-Z0-9_ ]*\))"')) {
			file write `out' `"`macval(line)'"' _n
			file read `in' line
			continue
		}
		
		*destring and tostring replace
		if (regexm(`"`macval(line)'"',`"^[ ]*(de|to)string[ ]+([a-zA-Z0-9_ ]*[ ]+`var'|`var')([ ]*,|[ ]+[a-zA-Z0-9_ ]*,).*replace"')) {
			file write `out' `"`macval(line)'"' _n
			file read `in' line
			continue
		}
		
		* rename option 1:  rename old new
		if (regexm(`"`macval(line)'"',`"^[ ]*re(n|na|nam|name)[ ]+[a-zA-Z0-9_]+[ ]+`var'[ ]*($|,.*)"')) {
			file write `out' `"`macval(line)'"' _n
			file read `in' line
			continue
		}
		
		* rename option 2: rename (old1 old2 ...) (new1 new2 ...) [, options1]
		if (regexm(`"`macval(line)'"',`"^[ ]*re(n|na|nam|name)[ ]+\(.*\)[ ]+\(([a-zA-Z0-9_ ]*[ ]+`var'|`var')([ ]*\)|[ ]+[a-zA-Z0-9_ ]*\))[ ]*($|,.*)"')) {
			file write `out' `"`macval(line)'"' _n
			file read `in' line
			continue
		}
		
		* Foreach loops
		if (regexm(`"`macval(line)'"', `"^[ ]*foreach[ ]+[a-zA-Z0-9_]+[ ]+(in|of (varlist|newlist))[ ]+([a-zA-Z0-9_ ]*[ ]+`var'|`var')([ ]*|[ ]+[a-zA-Z0-9_ ]*){"'))  {
			local a : word 2 of `line'
			file read `in' line
			while (regexm(`"`macval(line)'"',`"}"')) == 0 {
				local line : subinstr local line "left quote`a'right quote" "`var'", all
				local line = ltrim(rtrim(itrim(`"`macval(line)'"'))) 
				if (regexm(`"`macval(line)'"',`"`var'"')) file write `out' `"`macval(line)'"' _n
				file read `in' line
			}
			if (regexm(`"`macval(line)'"',`"}"')) == 1 {
				file read `in' line
				continue
			}
		}		
		file read `in' line
	} 	// end loop of write file	
	* Text to be added after each variable code
	file write `out' `"]]>"' _n
	file write `out' `"</codInstr>"' _n
	file write `out' `"</var>"' _n
	file write `out' `"</dataDscr></codeBook>"' _n
	
	file close _all
	copy `temp2' `temp1', replace 			// temp1 will be the new xml file to be modified with the next variable
}		// End Loop for variables
	
		

* Text to be added at the end of each XML file
filefilter `temp1' `temp2' , from("<![CDATA[\W") to("<![CDATA[") replace
filefilter `temp2' `temp1' , from("\W]]>") to("]]>") replace
* filefilter `temp1' `temp2' , from("HERE-ADD-VAR-CODE-INFO") to("</dataDscr></codeBook>") replace

filefilter `temp1' `temp2', from("right quote") to("\RQ") replace	
filefilter `temp2' `temp1', from("left quote") to("\LQ") replace

copy `temp1' "`rootddi'\\`name'.xml", `replace'
noi disp in y "Message from mkddi: " in g "I'm done with your DDI. You can use Stata for something else"
noi disp in y "Message from mkddi: " in g "DDI created: " in y "`name'.xml" `"{ browse "`rootddi'\\`name'.xml" :{space 10}Open}"' _n
	
} // end of qui


end
exit 	





