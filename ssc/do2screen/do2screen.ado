*! Version 3.0 <13dec2017>
*! Author: R.Andres Castaneda -- acastanedaa@worldbank.org
*! Author: Santiago Garriga   -- santiago.garriga@psestudent.eu

/* *===========================================================================
Do2screen: Program to display do-files in result's screen
-------------------------------------------------------------------
Created: 		06Feb2013	(Santiago Garriga & Andres Castaneda) 
Modified: 	29Dec2015	(Santiago Garriga & Andres Castaneda) 
Modified: 	26Apr2016	(Andres Castaneda) 
Modified: 	15aug2017	(Andres Castaneda) 
Modified: 	23sep2017	(Andres Castaneda) 
version:		02.3 
Dependencies: 	THE WORLD BANK
*===========================================================================*/
version 14

program define do2screen, rclass

syntax  [using/],								      ///
[															        ///
VARiables(string)							        ///
find(string)								          ///
lines(int 5) 								          ///
range(numlist min=1 max=2)	          ///
folder(string)							          ///
text(string)								          ///
replace											          ///
labels timer								          ///
noprevious	comments  		            ///
varout(passthru)	nolinenumbers       ///
lrep(passthru) rrep(passthru)         ///
dblq(passthru) SCALARname(passthru)   ///
]

* ========================================================
* ===============================1.ERROR Messages=========
* =========================================================

* Display Options (Find, Variables and Range)

qui {
	preserve 
	timer clear
	local aux = 0
	cap confirm existence `variables'
	if (_rc == 0 ) local ++aux
	cap confirm existence `find'
	if (_rc == 0 ) local ++aux
	cap confirm existence `range'
	if (_rc == 0 ) local ++aux
	
	if (`aux' > 1) {
		disp in red "Options variable, find and range are mutually exclusive. " ///
		" You must chose only one of them"
		error
	}
	
	if (`aux' == 0) {
		disp in red "You should choose at least one option: variable, find and range."
		error
	}
	
	if (!missing("`previous'") & missing("`variables'")) {
		disp in red "noprevious option must be specified with variables option"
		error
	}
	if (!missing("`previous'") & (!missing("`find'") | !missing("`range'"))) {
		disp in red "noprevious option cannot be specified with option find or range"
		error
	}
	
	
	* ===============================================================
	* ============2. Set Default Options============================= 
	* ===============================================================
	
	* Folder
	if (`"`folder'"' != `""') {
		if regexm(`"`folder'"', `"[\]$"') ///
		local folder = reverse(substr(reverse(`"`folder'"'), 2, .))
		if regexm(`"`folder'"', `"[a-zA-Z0-9]$"') local folder "`folder'/"
		local cdir "`c(pwd)'"
		cd "`folder'"
	}
	
	* Range and lines (default option for the range)
	if ("`range'" != "" ) {
		local start: word 1 of `range'
		if (wordcount("`range'") == 1) {
			local end = `start' + `lines'
		} //  range == 1
		else {
			local end: word 2 of `range'
			local lines = `end' - `start'
		} // range == 2
	}
	
	* text option is selected
	if ("`text'" != "") {
		tempname textfile
		if (regexm("`text'","^.*\.txt$") == 0 ) local text "`text'.txt"
		log using "`text'", text name(`textfile') `replace'
	}
	
	
	* If using
	if (`"`using'"' == `""') local dofiles: dir . files "*.do"
	
	if `"`using'"' != `""' {
		local dofiles `""`using'""'
		if (substr(reverse(`dofiles'),1,3) != "od.") {
			local dofiles `"`dofiles'.do"'
			
		}
	}
	
	
	* scalar name
	if ("`scalarname'" == "") local scalarname = "scalarname(s_varcode)" 
	
	* ===================================================================
	* ====================3. Run sub-programs============================
	* ===================================================================
	
	foreach dofile of local dofiles {
		
		noi dis as text _new "{p 4 4 2}{cmd:do-file:} "	in y  "  `dofile'" 	 ///
		`"{browse "`folder'`dofile'":{space 10}Open }"'" {p_end}" 
		noi dis as text "{hline 96}" 
		
		cap noi do2screen_display, variables(`variables')     ///
		find(`"`find'"') dofile(`dofile') range(`range')    ///
		lines(`lines') start(`start') end(`end') `previous' ///
		`labels' `varout' `lrep' `rrep' `dblq' `scalarname' ///
		`comments' `linenumbers'
	}
	
	/*================================================================
	3.2 Display option								
	=================================================================*/
	
	
	* Close text file
	if ("`text'" != "") {
		log close `textfile'
		noi disp as text `"note: results saved to `text'"'
	}
	
	if ("`folder'" != "") cd "`cdir'"
	
	if ("`timer'" != "") noi timer list
	
} // end of qui
end

* ==============================================================================
* =========================do2screen_display program============================
* ==============================================================================

program define do2screen_display, rclass

syntax [anything]								///
[if] [in],										///
[															///
variables(string)							///
find(string)									///
range(numlist)	lrep(string)	///
lines(numlist)	rrep(string)	///
start(numlist)	dblq(string)	///
end(numlist)									///
dofile(string)								///
labels	SCALARname(string)		///
noprevious	comments				  ///
varout(string) nolinenumbers  ///
]

qui {
	
	/*====================================================================
	1: Initial conditions
	====================================================================*/
	
	*--------------------1.1: Load Information of the do-file
	
	tempfile h
	filefilter "`dofile'" `h', from(\n) to(\n\BS\BS\RQ\RQ\BS\BS\BS) replace
	
	import delimited using `h', clear  ///
	delimiters("thisisadelimiter,itshouldworkfine", asstring)
	rename v1 oricode
	replace oricode = subinstr(oricode, `"\\''\\\"', "", .)
	gen oriline = _n
	gen selection = .
	
	gen precode = oricode
	
	*** comments long comments
	timer on 2
	if ("`comments'" == "") {
		tempvar o c open close open1 close1
		
		gen `o'        = 1 if (regexm(oricode, `"/\*"'))
		gen `c'        = 1 if (regexm(oricode, `"\*/"'))
		
		gen `open'     = sum(`o') if `o' == 1
		gen `close'    = sum(`c') if `c' == 1
		clonevar `open1'  = `open'  
		clonevar `close1' = `close' 
		
		replace `open1'  = `open1'[_n-1]  if `open1' ==. 
		replace `close1' = `close1'[_n-1] if `close1' ==. 
		replace `close'  = `close' - 1    if `close1' > `open1'
		
		count if regexm(precode, `"/\*[^(/\*).]*\*/"')
		while r(N)>0 {
			replace precode = regexr(precode, `"/\*[^(/\*).]*\*/"', " ")
			count if regexm(precode, `"/\*[^(/\*).]*\*/"')
		}
		
		levelsof `open' if (`open' != `close'), local(sections)
		foreach section of local sections {
			sum oriline if (`open' == `section' | `close' == `section'), meanonly 
			replace precode = "" if inrange(oriline, r(min),r(max) )
		}
	}
	timer off 2
	
	// fix precode 
	replace precode = ltrim(rtrim(itrim(precode)))
	replace precode = subinstr(precode, "`=char(9)'", " ",.)
	if ("`lrep'" == "") local lrep "LlLl"
	if ("`rrep'" == "") local rrep "RrRr"
	if ("`dblq'" == "") local dblq "DQDQ"
	
	replace precode = subinstr(precode, char(96), "`lrep'",.)  // replace `
	replace precode = subinstr(precode, char(39), "`rrep'",.)  // replace '
	replace precode = subinstr(precode, char(34), "`dblq'",.)  // replace '
	
	// Delimiter
	timer on 3
	gen line = .
	gen code = ""
	sum oriline, meanonly
	local maxline = r(max)
	
	local i = 0
	local u = 1
	local delimit =0
	qui while (`i' < `maxline') {
		local ++i
		local line = precode[`i']
		if regexm(`"`macval(line)'"', `"^[ ]*$"')  {
			replace line = `u' in `u'
			replace code = "" in `u'
			local ++u
			continue
		}
		if regexm(`"`macval(line)'"', "#[ ]?delimit[ ]?;") {
			local delimit = 1
			continue
		}
		if regexm(`"`macval(line)'"', "#[ ]?delimit[ ]?cr") {
			local delimit = 0
			continue
		}
		if (`delimit' == 0) {
			replace line = `u' in `u'
			replace code = `"`macval(line)'"' in `u'
			local ++u
		}
		else {
			if regexm(`"`macval(line)'"', ";") {
				tokenize `"`macval(line)'"', parse(;)
				local s = 1
				while (`"``s''"' != "") {
					if  (`"``s''"' != ";" & `"``=`s'+1''"' != "") {
						replace line = `u' in `u'
						if (`s' == 1) replace code = `"`trailcode' ``s''"' in `u'
						else replace code = `"``s''"' in `u'
						local ++u
					}
					local ++s
				}
				// when the last part of code is not ;
				if (`"``--s''"' != ";") local trailcode `"``s''"'
				else                  local trailcode ""
			} // end of ; in line 
			
			else { 
				local trailcode "`trailcode'"
				while !regexm(`"`macval(line)'"', ";") & `i' < `maxline' {
					local trailcode `"`trailcode' `macval(line)'"'
					local ++i
					local line = precode[`i']
				}
				local --i
			} // end of lines without ;
			
		} // end of delimit end of lines when ; is there
		
	}  // end of delimit
	timer off 3
	
	replace code = subinstr(code, ";", "",.) 
	clonevar origcode = code  // anchor 
	drop if line == .
	compress 
	
	/*====================================================================
	2: Algorithm for Variables condition
	====================================================================*/
	
	if ("`variables'" != "" ) { // Condition if the user wants to see specific variable
		
		local crlf "`=char(10)'`=char(13)'"
		
		timer on 4
		foreach var of local variables { // analysis for each variable desired
			
			replace code = origcode  // use anchor for new variables
			replace selection = .
			*--------------------2.1: Initial conditions of algorithm
			tempname D 
			matrix `D'=J(1,1000,1)
			local i=1
			
			local mainvar "`var'"
			local doughter`var' "nope"	  // e.g., ipcf is doughter of itf, which is `var'  
			local prevars`var' "`var'" 
			
			
			*--------------------2.2:
			local stay = 1
			
			** create variable to check that no variable is checked more than once
			tempvar content 
			gen `content' = ""
			local cc = 0
			
			qui while (`stay' == 1) {
				
				if ("`previous'" == "noprevious") local stay = 0
				local j=`D'[1,`i']
				if (`"`: word `j' of `prevars`var'''"' != `""') {
					
					local var : word `j' of `prevars`var''
					if ("`var'" == "`doughter`var''") {
						disp in red "variable `var' presents circular creation [i.e, x = f(X)]"
						matrix `D'[1,`i']=`D'[1,`i']+1
						continue
					}
					
					* Exclusion of `varout' in analysis
					if ("`var'" == "`varout'") {
						matrix `D'[1,`i']=`D'[1,`i']+1
						continue
					}
					
					** Identify whether one variable has been already checked
					count if `content' == "`var'"
					if r(N) == 0 {
						local ++cc
						replace `content' = "`var'" in `cc'
					}
					else {
						* disp in w "variable `var' already checked. "
						matrix `D'[1,`i']=`D'[1,`i']+1
						continue
					}
					
					
					** exclusion 
					**** Code to identify previous variables
					local way1 = 0
					local way2 = 0
					local fline ""
					
					tempvar a
					gen `a' = ""
					* gen, egen, replace
					replace `a' = regexs(2) if ///
					regexm(code, `"^(.*[:]?[ ]*[a-z]+ `var'[ ]*=)([ a-z0-9\.\("]+.*)$"')
					
					* rename
					replace `a' = regexs(1) if ///
					regexm(code, `"[ ]*ren[ame]*[ ]+\(?([a-zA-Z_]*[a-zA-Z0-9_ ]*)\)?[ ]+\(?([a-zA-Z_]*[a-zA-Z0-9_ ]*`var'[a-zA-Z_]*[a-zA-Z0-9_ ]*)\)?"')
					
					* encode, destring, and similar commands 
					replace `a' = regexs(1) if ///
					regexm(code, `"(^.*),.*[a-z]+\(([a-zA-Z0-9_ ]*[ ]+`var'|[ ]*`var')([ ]*\)|[ ]+[a-zA-Z0-9_ ]*\))"') 
					
					replace `a' = "" if regexm(code, `"^[ ]*(egen|gen).*,.*`var'"') 
					
					sum line if `a' != `""', meanonly
					if r(N) != 0 {
						levelsof line if (`a' != `""'), local(tlines)
						foreach tline of local tlines {
							* noi disp in red `a'[`tline']
							local fline "`fline' `: disp `a'[`tline']'" 
						}
					}					
					if (`"`fline'"' != `""') local way1 = 1
					
					** In case variable is not created
					if (`way1' == 0 & `way2' == 0) {
						matrix `D'[1,`i']=`D'[1,`i']+1
						local var "`doughter`var''"
						continue
					}
					
					*** Code for after the variable is created****
					if ("`mainvar'" == "`var'") {
						sum line if `a' != `""', meanonly
						local bfrlines = r(max)
						do2screen_aftervar `var' , `labels' 
					}
					else do2screen_aftervar `var' , `labels' maxline(`bfrlines')
					replace selection = 1 if (`a' != `""' & line <= `bfrlines') 
					
					**************************
					** creation of variables 
					*************************
					
					local tofind = `"`fline'"'
					
					lstrfun tofind, regexr(`"`tofind'"', `"[a-zA-Z]+\("', "")	// functions opening
					foreach symb in ")" "+" "-" "/" "*" ">=" "<=" ">" "<" "==" "!=" ///
					"~=" " if " " . " " ." "|" "(" "&" "#" "%" "^"  {
						local tofind: subinstr local tofind "`symb'" "  ", all  // functions closing
					}
					lstrfun tofind, regexr(`"`tofind'"', `" \[[ ]*[a-z]+[ ]*=[ ]*[a-zA-Z0-9]+[ ]*\]"', "")	// weigths
					lstrfun tofind, regexr(`"`tofind'"', `"^.*="', "")			// everything before equal
					lstrfun tofind, regexr(`"`tofind'"', `",.*"', "")			// everything after comma
					
					* number with decimals
					local b ""
					foreach x of local tofind {
						if !regexm(`"`x'"', `"[0-9]+\.[0-9]+"')  local b "`b' `x'"
					}
					local tofind `"`b'"'
					
					* Regular Numbers
					local c ""
					foreach x of local tofind {
						if !regexm(`"`x'"', `"^[0-9]+"')  local c "`c' `x'"
					}
					local tofind `"`c'"'
					
					local tofind = ltrim(rtrim(itrim(`"`tofind'"')))
					local tofind: list uniq tofind
					
					
					* noi disp in g "prevar of `var': " in y `"`tofind'"'
					
					if (`"`tofind'"' != `""') {
						
						local eqvars = 0
						local d ""
						foreach nvar of local tofind {
							if ("`nvar'" != "`var'") local d "`d' `nvar'"
							else local eqvars = 1
						}
						local tofind `"`d'"'
						
						local tofind = ltrim(rtrim(itrim(`"`tofind'"')))  // just in case
						local tofind: list uniq tofind  // just in case
						
						
						
						* if (`eqvars' == 0) {
						if (`"`tofind'"' != `""') {
							local prevars`var' "`tofind'"
							foreach nvar of local tofind {
								local doughter`nvar' "`var'"
							}
							* local oldvar "`var'"
							local ++i
						}
						else {
							matrix `D'[1,`i']=`D'[1,`i']+1
							local var "`doughter`var''"
						}
					}
					else {
						matrix `D'[1,`i']=`D'[1,`i']+1
						local var "`doughter`var''"
					}
				}
				else {
					matrix `D'[1,`i']=1
					local i=`i'-1
					if (`i'==0) continue, break
					matrix `D'[1,`i']=`D'[1,`i']+1
					local var "`doughter`var''"
				}
				
			} // end of while stay == 1
			
			local crlf "`=char(10)'`=char(13)'"
			replace code = subinstr(code, "`lrep'", char(96),.)  // replace back `
			replace code = subinstr(code, "`rrep'", char(39),.)  // replace back '
			replace code = subinstr(code, "`dblq'", char(34),.)  // replace "
			
			replace code = subinstr(code, "`=char(96)'", "`=char(92)'`=char(96)'",.) 
			scalar s_varcode = "" 
			levelsof line if selection == 1, local(lines) 
			
			noi disp as text _new "Line   {c |}" _col(20) "{cmd: Writing code for:} {result: `mainvar'}" 
			noi disp as text "{hline 7}{c +}{hline 90}" 
			local linenumber ""
			foreach line of local lines {
				if ("`linenumbers'" == "") {
					local space: disp _dup(`=6-length("`line'")') " "
					local linenumber "`space'`line': "
				} 
				local lcode: disp code[`line'] 
				scalar s_varcode = s_varcode + `"`crlf'`linenumber'`lcode'"'
				* noi disp in g "`space'`line':" in y " `lcode'"
				noi disp in g `"`linenumber'"' in y `" `lcode'"'
			} 
			
			* noi disp in y s_varcode  
			* noi tabdisp line if `check' == 1, cell(code) 
			noi disp as text  _col(60) "{hline 10}" " (end of analysis of `mainvar')" _newline 
			
		} // End of variables loop  
		timer off 4
	} 	// End of variables conditions
	
	
	/* -----------------------------------
	If 'find' option is selected
	-----------------------------------*/ 
	
	if ( `"`find'"' != `""' ) { // lookfor whatever the user needs to see
		replace code = subinstr(code, "`=char(96)'", "`=char(92)'`=char(96)'",.)
		local t = 0
		foreach tofind of local find { // analysis for each variable desired
			local ++t
			replace selection = .
			
			* Display title and horizontal lines
			noi di as text _new  "Line {c |}		{cmd: Writing code for:}  {result: `tofind'}"
			noi di as text "{hline 5}{c +}{hline 90}"
			
			replace selection = -1 if  strpos(code,`"`tofind'"')!=0
			count if selection == -1
			if (r(N) >= 1) {
				levelsof line if selection == -1, local(nlines)
				local section = 0
				foreach line of local nlines {		// lines where tofind was found
					
					scalar `scalarname' = ""
					local ++section		// number of sections for the same finding
					foreach i of numlist 0/`lines' {
						
						local space: disp _dup(`=4-length("`=`line'+`i''")') " "
						local lcode: disp code[`=`line'+`i''] 
						scalar `scalarname' = `scalarname' + `"`crlf'`space'`=`line'+`i'': `lcode'"' 
						
					}
					
					noi disp in y `scalarname'  
					noi di as text  _column(35)  "{hline 10}" ///
					" (end of section `section' for `tofind') " "{hline 10}" _newline
					
				}  // end of loop for line with foreach 
				
			}  // end of of condition when something found. 
			else {
				noi disp in red "nothing found for " in y " `tofind'"
			}
			noi di as text  _column(60)  "{hline 10}" " (end of analysis of `tofind')" _newline
		} // End of tofind loop		
	} // end of find condition
	
	
	/* -----------------------------------
	If 'range' option is selected
	-----------------------------------*/ 
	if ( "`range'" != "" ) { // look for whatever the user needs to see
		
		* Display title and horizontal lines
		noi di as text _new  "Line {c |}		{cmd: Writing code between lines:}  {result: `start' & `end'}"
		noi di as text "{hline 5}{c +}{hline 90}"
		
		local crlf "`=char(10)'`=char(13)'" 
		replace code = subinstr(code, "`=char(96)'", "`=char(92)'`=char(96)'",.) 
		scalar `scalarname' = "" 
		
		foreach line of numlist `start'/`end' {
			local space: disp _dup(`=4-length("`line'")') " "
			local lcode: disp code[`line'] 
			scalar `scalarname' = `scalarname' + `"`crlf'`space'`line': `lcode'"' 
		} 
		
		noi disp in y `scalarname'  
		noi di as text  _column(45)  "{hline 10}" " (end of analysis of lines between `start' & `end')" _newline
	} // end of range condition
	
}
end

/*====================================================================
4: identification of code after creation
====================================================================*/

program do2screen_aftervar, rclass

syntax anything(name=var), [labels maxline(numlist)]

if ("`maxline'" == "") local maxline = _N

qui {
	
	
	* drop 
	cap replace selection = 1 if (regexm(code, `"^[ ]*drop[ ]+[a-zA-Z0-9_ ]*`var'"')) ///
	& line < `maxline'
	
	*----------------------4.2: Display Labels
	if (!missing("`labels'")) {
		cap replace selection = 1 if (regexm(code, ///
		`"^[ ]*l(a|ab|abe|abel)[ ]+va(r|ri|ria|riab|riabl|riable)[ ]+`var'[ ]+.*"')) ///
		& line < `maxline'
		
		cap replace selection = 1 if (regexm(code, ///
		`"^[ ]*l(a|ab|abe|abel)[ ]+val(u|ue|ues)[ ]+.*`var'"')) ///
		& line < `maxline'
	}
	
	*----------------------4.3: Foreach loops
	
	cap replace selection = 2 ///
	if (regexm(code, `"^[ ]*foreach[ ]+[a-zA-Z0-9_]+[ ]+(in|of)[ ]+.*`var'.*{$"')) ///
	& line < `maxline'
	
	count if selection == 2
	if (r(N) >= 1) {
		levelsof line if selection == 2, local(nlines)
		foreach line of local nlines {
			local inloop = 0
			local i = 0 
			while (`inloop' == 0) {
				local ++i
				local loopline: disp code[`=`line'+`i'']
				if (regexm(`"`macval(loopline)'"',`"}"') == 1) local inloop = 1
				replace selection = 1 in `=`line'+`i''
			} // end of while 
		} // end of loop for line with foreach 
	}
	replace selection = 1 if selection == 2
	
}
end

exit 

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

* =============================================================================
* ============================History of the file==============================
* =============================================================================
*! Version 2.4    <20nov2017>
*! Version 2.3    <23sep2017>
*! Version 2.2    <15aug2017>
*! Version 2.1    <26Apr2016>
*! Version 2.0    <29Dec2015>
*! Version 1.1    <05Mar2015>
*! Version 0.0    <06Feb2015>   


*---------- NOTES--------------------
dom_2004_enft_v01_m_v03_a_sedlac_02
bol_2006_eh_v01_m_v02_a_sedlac_02

local using dom_2004_enft_v01_m_v03_a_sedlac_02.do
do2screen using `using', var(casa)


do2screen using test.do, var(edlev)
do2screen using test.do, var(secondary)


do2screen using test2.do, var(ho7)
do2screen using test2.do, var(ho7a)



tempvar a
gen `a' = regexs(2) if regexm(code, `"^(.*[:]?[ ]*[a-z]+ `var'[ ]*=)([ a-z0-9\.\("]+.*)$"')

sum line if `a' != `""', meanonly
if r(N) != 0 {
	if ("`mainvar'" == "`var'") local bfrlines = r(max)
	levelsof line if (`a' != `""'), local(tlines)
	foreach tline of local tlines {
		* noi disp in red `a'[`tline']
		local fline "`fline' `: disp `a'[`tline']'" 
	}
}
if (`"`fline'"' != `""') local way1 = 1
else {		// in case of other way to generate variables
	tempvar b
	gen `b' = regexm(code, `"^.*,.*[a-z]+\(([a-zA-Z0-9_ ]*[ ]+`var'|[ ]*`var')([ ]*\)|[ ]+[a-zA-Z0-9_ ]*\))"')
	sum line if `b' == 1, meanonly
	if r(N) != 0 {
		if ("`mainvar'" == "`var'") local bfrlines = r(max)
		local fline: disp code[r(min)]
		local way2 = 1
	}
}






drop _all
set obs 500000
tempname myfile
local file "`dofile'" 

gen oriline = .
gen strL oricode = ""



file open `myfile' using `file'  , read 
file read `myfile' oriline
local i = 1

timer on 1
qui while r(eof)==0 {
	replace oriline = `i' in `i'
	replace oricode = `"`macval(oriline)'"' in `i'
	file read `myfile' oriline
	local ++i
}
timer off 1





*-------------------4.1: Comments;

* A. Beginning with Opening and closing comments in the same line;
cap replace selection = 3 if (regexm(code, `"^[ ]*(/\*.*\*/)(.*)"');

* B. Begin comment in one line and closing in other line;
replace selection = 4 if regexm(code, `"^(.*)/\*"');

count if selection  == 4;
if (r(N) > 1 ) {;
	levelsof line if selection == 4, local(lines);
	foreach line of local lines {;
		local inloop = 0;
		local i = -1 ;
		while (`inloop' == 0) {;
			local ++i;
			if regexm(code, `"^(.*)/\*"') in `=`line'+`i'' 
			local partA = regexs(1);
			if regexm(code, `"^(.*)(\*/)(.*)$"') in `=`line'+`i'' 
			local partB = regexs(3);
			if regexm(code, `"\*/"') in `=`line'+`i'' local inloop = 1;
		};
		
		if regexm(`"`partA' `partB'"', "^.* `var' .*") {;
			replace code = `"`partA' `partB'"' in `line';
			replace selection = 1 in `line';
			if (`i'!= 0) replace code = "" in `=`line'+1'/`=`line'+`i'';
		};
		else replace code = "" in `line'/`=`line'+`i'';
	} ; // end of line loop;
} ; // end of ;
replace selection = . if selection == 4;

* C. Identify * comments;
replace code = "" if regexm(code, `"^[ ]*\*"');

* D. Identify comments at the end of the line //;
replace code = regexs(1) if regexm(code, `"^(.*)(//.*)"');

* E. comment /*  */ after and in the middle of the line of code. Ex. gen var = var2 /* gen var1 */;

count if regexm(code, `".*/\*.*\*/.*"');
while r(N) > 0 {;
	replace code = regexs(1) + " " + regexs(3)  if regexm(code, `"^(.*)(/\*.*\*/)(.*)"');
	count if regexm(code, `".*/\*.*\*/.*"');
};

replace code = ltrim(rtrim(itrim(code)));

*----------------------4.2.1:  General comments;

cap replace selection = 1 `in' if (regexm(code,
`"^.*(:)?[ ]*(egen|g|g(e|en|ene|ener|enera|enerat|enerate)|replace|loc|loc(a|al))[ ]*(byte|int|long|float|double)?[ ]+`var'[ ]?=[ ]?"'));

cap replace selection = 1 `in'   if (regexm(code,
`"^[ ]*recode.*[ ]*(g|g(e|en|ene|ener|enera|enerat|enerate))\(([a-zA-Z0-9_ ]*[ ]+`var'|[ ]*`var')([ ]*\)|[ ]+[a-zA-Z0-9_ ]*\))"'));

cap replace selection = 1  `in'  if (regexm(code,
`"^[ ]*(en|(en|de(c|co|cod|code))).*[ ]*(g|g(e|en|ene|ener|enera|enerat|enerate))\([ ]*`var'[ ]*\)"'));

cap replace selection = 1  `in'  if (regexm(code,
`"^[ ]*(de|to)string(.*)(g|g(e|en|ene|ener|enera|enerat|enerate))\(([a-zA-Z0-9_ ]*[ ]+`var'|[ ]*`var')([ ]*\)|[ ]+[a-zA-Z0-9_ ]*\))"'));

cap replace selection = 1 `in'   if (regexm(code,
`"^[ ]*(de|to)string[ ]+([a-zA-Z0-9_ ]*[ ]+`var'|`var')([ ]*,|[ ]+[a-zA-Z0-9_ ]*,).*replace"'));

cap replace selection = 1 `in'   if (regexm(code,
`"^[ ]*re(n|na|nam|name)[ ]+[a-zA-Z0-9_]+[ ]+`var'[ ]*($|,.*)"'));

/* 
cap replace selection = 1 `in'   if (regexm(code,
`"^[ ]*re(n|na|nam|name)[ ]+\(.*\)[ ]+\(([a-zA-Z0-9_ ]*[ ]+`var'|`var')([ ]*\)|[ ]+[a-zA-Z0-9_ ]*\))[ ]*($|,.*)"'));
*/	
cap replace selection = 1 `in'   if (regexm(code,
`"^[ ]*re(n|na|nam|name)[ ]+[a-zA-Z_]+[a-zA-Z0-9_]*[ ]+`var'[ ]*($|,.*)"'));

cap replace selection = 1 `in'   if (regexm(code,
`"^[ ]*re(n|na|nam|name)[ ]+\(.*\)[ ]+\([a-zA-Z_]*[a-zA-Z0-9_ ]*`var'.*\)[ ]*($|,.*)"'));

cap replace selection = 1 `in'   if (regexm(code,
`"^[ ]*re(n|na|nam|name)[ ][a-zA-Z_]*[a-zA-Z0-9_ ]*`var'.*[ ]*,(u[per]*|l[ower]*|p[rope]*)"'));


cap replace selection = 2  if (regexm(code, 
`"^[ ]*foreach[ ]+[a-zA-Z0-9_]+[ ]+(in|of (varlist|newlist|local|numlist))[ ]+([a-zA-Z0-9_ ]*[ ]+`var'|`var')([ ]*|[ ]+[a-zA-Z0-9_ ]*)"'));
