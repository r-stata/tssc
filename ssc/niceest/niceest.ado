*! 0.1 MS & HS, Jul 10, 2018
*! 0.1.1 MS, Sep 24, 2018
*! 0.2 MS, Feb 24, 2019
*! 0.2.1 MS, Mar 6, 2019
*! 0.2.2 MS, Mar 12, 2019
program define niceest
version 15.0

qui{
		syntax, outfile(string asis) [pvalues(string) se(string) ///
		  df(string) format(string) pformat(string) intercept(string) ///
		  eform level(integer 95) cidelims(string) addspace word excel raw]  

		  
		  
* Make sure that either "word" og "excel" is specified 
* If non are specified regressiontable will be exported to excel.
* (line 14/32 added version 0.2)
		local word = wordcount("`word'")
		local excel = wordcount("`excel'")
		
		
	
		
		
		if `word'+`excel' == 2 {
				di as err "Define if you want to export to either {it:excel} or {it:word}."
				di as err "It is not allowed to specify both"
				di as err "Invalid syntax"
				exit 198
				}
		if `word'+`excel' == 0 {
				local excel = 1
				}
				
* Adding pvalues, SE and DOF to exceltable if specified by user
		if "`pvalues'" !="" {
			local keepvars= "p " + "`keepvars'"
			}
	
		if "`se'" !="" {
			local keepvars= "stderr " + "`keepvars'"
			}
	
		if "`df'" !="" {
			local keepvars= "dof " + "`keepvars'"
			}


* Determine the confidence interval delimiters as defined by the user. 
* It first finds if "cidelims" is empty. If it is empty the user has not 
* defined it, and it gets defined as the default, in the bottom. If it is 
* not empty it counts if there is exactly 3 charecters before it proceeds.
* If so, it will find which delimiter the user wants
		if "`cidelims'" != "" {
			local ncidelims = strlen("`cidelims'")
			if `ncidelims' == 3 {
				local pattern = strmatch("`cidelims'","(:)")
				if `pattern' == 1 {
					local number1 = "("
					local number2 = ":"
					local number3 = ")"
					}
				local pattern = strmatch("`cidelims'","[:]")
				if `pattern' == 1 {
					local number1 = "["
					local number2 = ":"
					local number3 = "]"
					}
				local pattern = strmatch("`cidelims'","(-)")
				if `pattern' == 1 {
					local number1 = "("
					local number2 = "-"
					local number3 = ")"
					}
				local pattern = strmatch("`cidelims'","[-]")
				if `pattern' == 1 {
					local number1 = "["
					local number2 = "-"
					local number3 = "]"
					}
				local pattern = strmatch("`cidelims'","(;)")
				if `pattern' == 1 {
					local number1 = "("
					local number2 = ";"
					local number3 = ")"
					}
				local pattern = strmatch("`cidelims'","[;]")
				if `pattern' == 1 {
					local number1 = "["
					local number2 = ";"
					local number3 = "]"
					}
				}
			else {
				di as err "-cidelims- incorrectly defined. If you wish to define -cidelims- There has to be exactly 3 charecters"
				di as err "Invalid syntax"
				exit 198
				}
			}
		
		else {
			local number1 = "["
			local number2 = ";"
			local number3 = "]"
			}


	* If "number1" is empty the user has defined "cidelims" incorrectly. 
	* This happens if the user has defined "cidelims" as something else 
	* then the options we have provided.
		if "`number1'" == "" {
			di as err "-cidelims- is defined as  `cidelims'  , which is incorrect. Look at helpfile"
			di as err "Invalid syntax"
			exit 198
			}

			
* Start of code to create the Excel table with output
		local regcmd = e(cmdline)							

* Extracting the part without options, i.e. regression command
* and variable names (changed for version 0.2.1)
	
		local optsstart = strpos("`regcmd'", ",")               
		if `optsstart' != 0 {                                     
			local regcmd = substr("`regcmd'", 1, `optsstart' - 1) 
			}
		
		local optsstartif = strpos("`regcmd'", " if ")
		if `optsstartif' != 0 {                                     
			local regcmd = substr("`regcmd'", 1, `optsstartif' - 1) 
			}
			
		local optsstartin = strpos("`regcmd'", " in ")
		if `optsstartin' != 0 {                                     
			local regcmd = substr("`regcmd'", 1, `optsstartin' - 1) 
			}
					
			
		local regcmd = subinstr("`regcmd'", "#", " ", .)           
		local nwords = wordcount("`regcmd'")                       

* Collecting variable labels for all variables and the valuable
* labels for the categorical variables
		local ncv = 0                                             
		forvalues j = 3/`nwords' {                                
			local i = `j' - 2                                                                               
			local cv = word("`regcmd'", `j')                      
	
	* Continuous variables - no . in their names or "c." in the name
			if strpos("`cv'", ".") == 0 | strpos("`cv'", "c.") != 0 { 
				if strpos("`cv'", "c.") != 0 {                       
					local cvname`i' = substr("`cv'", strpos("`cv'", "c.") + 2, .) 
					}
				else {                                                
					local cvname`i' `cv'                             
					}
				local labcvname`i' : var label `cvname`i''           
				}
		 
	* If not continuous, it must be categorical
			else {                                                    
				local cvname`i' = substr("`cv'", strpos("`cv'", ".") + 1, .) 
				local labcvname`i' : var label `cvname`i''            
				levelsof `cvname`i'', local(cats)                     
					foreach k of local cats {
					local lv`cvname`i''`k' : label (`cvname`i'') `k'
		
		* If "`lv`cvname`i''`k''" is empty, it means that the catogory has no
		* valuelabel if so, the categories will be named whatever its value is
					if "`lv`cvname`i''`k''" == "" {
						local lv`cvname`i''`k' `k'
						}
					}
				}	
				
	* Counting number of variables in model
			local ncv = `ncv' + 1	
			}


* Create fundamental table with parmest
		preserve
		drop _all
		parmest, norestore `eform' level(`level')

* Generate new temporary variables to hold variable name (cvar) and
* category value (cvval is string, cvvalnum is numeric and to be used)
		tempname cvar cvval cvvalnum cvar1 cvar2 cvval1 cvval2 baseind ///
		cexp1 cexp2

		gen strL `cexp1' = substr(parm, 1, strpos(parm, "#") - 1)
		gen strL `cexp2' = substr(parm, strpos(parm, "#") + 1, .)
		gen strL `cvar1' = substr(`cexp1', strpos(`cexp1', ".") + 1, .)
		gen strL `cvar2' = substr(`cexp2', strpos(`cexp2', ".") + 1, .)


		gen strL `cvar' = `cvar1' + `cvar2' if `cvar1' != ""
		replace `cvar' = `cvar2' if `cvar1' == ""

		gen int `cvval1' = real(substr(`cexp1', 1, strpos(`cexp1', ".") - 1 ///
		- (strpos(`cexp1', "b") != 0))) if strpos(`cexp1', ".") != 0
		gen int `cvval2' = real(substr(`cexp2', 1, strpos(`cexp2', ".") - 1 ///
		- (strpos(`cexp2', "b") != 0))) if strpos(`cexp2', ".") != 0
		gen `baseind' = strpos(parm, "b.") != 0

		gen strL `cvval' = substr(parm, 1, ///
		strpos(parm, ".") - 1 - (strpos(parm, "b") != 0)) ///
		if strpos(parm, ".") != 0
		gen int `cvvalnum' = real(`cvval')

* New variable -cvlab- with variable labels pasted into its
* "observations" - we first put labels on each variable separately
* (there are two for the interaction terms)
		tempvar cvlab1 cvlab2
		gen strL `cvlab1' = ""
		gen strL `cvlab2' = ""

		forvalues i = 1 / `ncv' {
			replace `cvlab1' = "`labcvname`i''" if `cvar1' == "`cvname`i''" 
			replace `cvlab2' = "`labcvname`i''" if `cvar2' == "`cvname`i''" 
			}

* If there is a variable without label, use the variable name
		replace `cvlab1' = `cvar1' if `cvlab1' == "" 
		replace `cvlab2' = `cvar2' if `cvlab2' == "" 
	
* If "intercept" is not defined it will be named Intercept
		if "`intercept'" == "" {
			local intercept = "Intercept"
			}


		replace `cvlab2' = "`intercept'" if parm == "_cons"
		gen strL cvlab = `cvlab2' if `cvlab1' == ""
		replace cvlab = `cvlab1' + " # " + `cvlab2' if `cvlab1' != ""

* New variable -cvlabval- with value labels pasted into its
* "observations" - again separately for each variable and then joined
* together subsequently
		tempvar cvlabval1 cvlabval2 
		gen strL `cvlabval1' = ""
		gen strL `cvlabval2' = ""
		local nrows = _N
		
		forv i = 1 / `nrows' {
			forv k = 1 / 2 {
				local curval`k' = `cvval`k''[`i']
				local curvar`k' = `cvar`k''[`i']
				if `curval`k'' != . {
					replace `cvlabval`k'' = "`lv`curvar`k''`curval`k'''" ///
					if _n == `i'
					if strpos(parm[`i'], "b.") != 0 {
						replace `cvlabval`k'' = `cvlabval`k'' + " (Ref)" if _n == `i'
						}
					}
				}
			}
	
		replace `cvlabval2' = `cvlab2' if `cvlabval1' != "" ///
		& strpos(`cexp2', "c") == 1 & strpos(`cexp2', ".") != 0

		gen strL cvlabval = `cvlabval2' if `cvlabval1' == ""
		replace cvlabval = `cvlabval1' + " # " + `cvlabval2' if `cvlabval1' != ""


* Define the default format and pformat (changed for version 0.1.1)
		if "`format'" == "" {
			local format = "%10.2f"
			}

		if "`pformat'" == "" {
			local pformat = "`format'"
			}
	

* Formatting the coefficients and the confidence interval
		local ndecs = substr("`format'", strpos("`format'", ".") + 1, 1)
		replace estimate = round(estimate, 10^(-`ndecs'))

	

	* If the variable "stderr" exists, it means that the user has included 
	* the "SE"-option and it will get the same format as the estimates
		capture confirm variable stderr
		if _rc == 0 {
			replace stderr = round(stderr, 10^(-`ndecs'))
			}
			
	* Take the pformat as defined by the user(or format) and give it to 
	* the p variable like we just did with stderr
		local pndecs = substr("`pformat'", strpos("`pformat'", ".") + 1, 1)
		capture confirm variable p
			if _rc == 0 {
			replace p = round(p, 10^(-`pndecs'))
			}

	*Uses the format, cidelims and level to format confidence level	
		gen strL strci = " `number1'" + strofreal(min`level', "`format'") + ///
		"`number2' " + strofreal(max`level', "`format'") + "`number3'"
  
		replace strci = " - " if strpos(parm, "b.") != 0
	
		
		
		

* Setting column headers
		la var cvlab "Explanatory variable"
		la var cvlabval "Category"
		la var estimate "Coefficient"
		la var strci "`level'% Confidence Interval"

	* Changes the name of standard error, DOF and p-values to what the user 
	* as defined them as
		if "`se'" != "" {
			la var stderr "`se'"
			}
	
		if "`df'" !="" {
			la var dof "`df'"
			}
	
		if "`pvalues'" !="" {
			la var p "`pvalues'"
			}
	
* Only keep the variable label in the first row for each
* explanatory variable
		tempname replab
		gen `replab' = (cvlab[_n] == cvlab[_n - 1])
		replace cvlab = "" if `replab'

		
* Inserts blank line only if excel is specified
* (line 323/325 added for version 0.2)
		if `excel' == 1 {
		
	* Code to insert a blank line between explanatory variables, if specified by
	* user
			tempvar jmpbef neworder
			local newnobs = `nrows' + `ncv'
			set obs `newnobs'

			gen `jmpbef' = 1 + (cvlab[_n] != cvlab[_n - 1] & !missing(cvlab[_n]) ///
			& _n != 1)
			gen `neworder' = sum(`jmpbef')

			local cnt = 1
			forv i = 2 / `nrows' {
				if (`neworder'[`i'] - `neworder'[`i' - 1]) == 2 {
					local tmp2 = `neworder'[`i'] - 1
					replace `neworder' = `tmp2' if _n == (`nrows' + `cnt')
					local cnt = `cnt' + 1
					}
				}
			display "`addspace'"
			if "`addspace'" =="addspace" {
				sort `neworder'
				}
			}
		
	* Finds if "word" and "addspace" is specified at the same time. 
	* returns error if this is the case (line 351/360 added for version 0.2)
		if "`addspace'" =="addspace" {
			if `word' == 1 {
				di as err "options {it:word} and {it:addspace} may not be combined"
				exit 184
				}
			}
			

* Final cleaning
		if cvlab[_N] == "" {
			drop if _n == _N
			}

* Checks if there are categories. If not it drops "cvlabval"  
* (line 366/377 added for version 0.2)	
		count if cvlabval != ""
		if r(N) == 0 {
			local header = "cvlab estimate strci `keepvars'"
			local nocat = 1
			}
			else {
				local header = "cvlab cvlabval estimate strci `keepvars'"
				local nocat = 0
				}
			

			
* Makes the table to be exported, with keepvars being the p, se and df, 
* if the user has defined these	(line 380/382 changed version 0.2)		
		keep `header'
		order `header'

	
* Extract outfile and discard replace if replace occurs. 
* 1. Finds if `outfile' contains a comma, if yes, proceeds in
*    parentheses + extracts positition
* 2. Finds if `outfile' contains the word "replace", and if it
*    comes after the comma. If yes a local replace is defined
*    as replace
		local komstart = strpos("`outfile'", ",")
		if `komstart' != 0 {	
			local repstart = strpos("`outfile'", "replace")
			if `repstart' > `komstart' {
				local replace replace 
				local outfile = substr("`outfile'", 1, `komstart' -1) 
				}
			}

			
* If "excel" is specified, then run the code that exports to excel 
* (line 400/403 added for version 0.2)	
		if `excel' == 1 {
		
	*If the outfile contains a comma and the word replace, in that order, `replace'
	*will be replace, and the existing excelfile will be replaced 
			export excel "`outfile'.xlsx", firstrow(varlabels) ///
			missing(" ") `replace'


			
	*Checks if there are categories because nformat has to be defined for the 
	* right numbers. (line 411/424 added version 0.2)
	if "`nocat'" == "0" {
		local estcol C
		local fircol E
		local seccol F
		local thicol G
		}
		else {
			local estcol B
			local fircol D
			local seccol E
			local thicol F
		}
	*Enable decimals in excel sheet (added for version 0.1.1)
			if `ndecs' != 0 {
				local decim 0.
				local i 1
				while `i'<=`ndecs' {
					local decim = "`decim'"+"0"
					local ++i
					}
				}
				else local decim 0
			*(line 435/475 changed version 0.2)
			putexcel set "`outfile'.xlsx", modify
			putexcel `estcol'2:`estcol'100, overwritefmt nformat(`decim')
			putexcel `fircol'2:`thicol'100, overwritefmt nformat(`decim')
		
			if `pndecs' != `ndecs' {
				if "`pvalues'" != "" {
					local pdecim 0.
					local i 1
					while `i'<=`pndecs' {
						local pdecim = "`pdecim'"+"0"
						local ++i
						}
					local nwords3 = wordcount("`keepvars'")
					if `nwords3' == 1 {
						putexcel (`fircol'2:`fircol'100), overwritefmt nformat(`pdecim')
						}
					if `nwords3' == 2 {
						putexcel (`seccol'2:`seccol'100), overwritefmt nformat(`pdecim')
						}
					if `nwords3' == 3 {
						putexcel (`thicol'2:`thicol'100), overwritefmt nformat(`pdecim')
						}	
					}
				} 
			
			
			if "`df'" != "" {
						putexcel (`fircol'2:`fircol'100), overwritefmt nformat(0)
						}	
					
			
			putexcel close
		
		
	*Mata starts if user has not specifiet "raw" 	
			if "`raw'" == "" { 
				if `nocat'==0 {
					local nwords2 = wordcount("`keepvars'") + 4
					mata: mataformat("`outfile'.xlsx", "`nwords2'")
					}
					else {
						local nwords2 = wordcount("`keepvars'") + 3
						mata: mataformat_nocat("`outfile'.xlsx", "`nwords2'")
						}
					}
				}


* If "word" is specified, then run the code that exports to excel 
* (line 476/added for version 0.2)
		if `word' == 1 {	
			putdocx clear
			putdocx begin

			putdocx table data = data(`header'), varnames ///
			layout(autofitcontent)

			putdocx table data(1,1) = ("Explanatory variable")
			
	* Are there any categories/categorical variables? If no, "category" 
	* will not be in worddocument
			if `nocat' == 1 {
				putdocx table data(1,2) = ("Coefficient")
				putdocx table data(1,3) = ("`level'% Confidence Interval")
				local steks = 3
				}
				else {
				putdocx table data(1,2) = ("Category")
				putdocx table data(1,3) = ("Coefficient")
				putdocx table data(1,4) = ("`level'% Confidence Interval")
				local steks = 4
				}
	
	* Finds the correct order of p, stderr and df
			if "`keepvars'" != "" {
				local ppos = strpos("`keepvars'", "p") 
				local stdpos = strpos("`keepvars'", "stderr")
				local dfpos = strpos("`keepvars'", "dof")
								
				if `dfpos' != 0 {
					local dfpos1 = 1
					}
					else local dfpos1 = 0
					
				if `stdpos' != 0 {
					local stdpos1 = `dfpos1'+1
					}
					else local stdpos1 = 0
					
				if `ppos' != 0 {
					local ppos1 = `dfpos1'+`stdpos1'+1
					if `stdpos1' == 2 {
						local ppos1 = `ppos1' -1
						}
					}
				}	
			
	* Names p, stderr and df as their locals
			if "`keepvars'" != "" {
				if "`dfpos1'" != "" {
					local col1 = `steks'+`dfpos1'
					putdocx table data(1,`col1') = ("`df'")
					}
				if "`stdpos1'" != "" {
					local col1 = `steks'+`stdpos1'
					putdocx table data(1,`col1') = ("`se'")
					putdocx table data(.,`col1'), nformat(`format')
					}
				if "`ppos1'" != "" {
					local col1 = `steks'+`ppos1'
					putdocx table data(1,`col1') = ("`pvalues'")
					putdocx table data(.,`col1'), nformat(`pformat')
					}
				}
		* aligns all cells to the center
			putdocx table data(.,.), halign(center)
		
		* runs costumization of table if user has not specifiet "raw"	
			if "`raw'" == "" {
				putdocx table data(1,.), bold
				putdocx table data(.,1), bold halign(right)
				
				
				count
				local varnum1 = r(N)+1
			
				putdocx table data(2/`varnum1',1), italic
				
				if `nocat' == 0 {
					putdocx table data(2/`varnum1',2), italic
					}
				}
			
				putdocx save `outfile', `replace'
			}
		}	
end

mata:
	void mataformat(string scalar outfile, string scalar nw2)
	{
		class xl scalar b
		b=xl()
		
		b.load_book(outfile)
		
		b.set_column_width(1, 1, 30)
		b.set_column_width(2, 2, 12)
		b.set_column_width(3, 3, 12)
		b.set_column_width(4, 4, 22)
		b.set_column_width(5, 5, 9)
		b.set_column_width(6, 6, 9)
		b.set_column_width(7, 7, 9)

		cols=(1, 1)
		rows=(2, 100)
		b.set_horizontal_align(rows, cols, "right")

		scalar nwtmp
		nwtmp = strtoreal(nw2)
		cols=(1, nwtmp)
		rows=(1, 1)
		b.set_bottom_border(rows, cols, "medium")
		b.set_font_bold(rows,cols, "on")
		
		cols=(1, 1)
		rows=(1, 100)
		b.set_font_bold(rows, cols, "on")
		
		cols=(4, 4)
		rows=(1, 100)
		b.set_horizontal_align(rows, cols, "center")
		
		cols=(2, 2)
		rows=(2, 100)
		b.set_font_italic(rows, cols, "on")
		}
end

mata:
	void mataformat_nocat(string scalar outfile, string scalar nw2)
	{
		class xl scalar b
		b=xl()
		
		b.load_book(outfile)
		
		b.set_column_width(1, 1, 30)
		b.set_column_width(2, 2, 12)
		b.set_column_width(3, 3, 22)
		b.set_column_width(4, 4, 9)
		b.set_column_width(5, 5, 9)
		b.set_column_width(6, 6, 9)

		cols=(1, 1)
		rows=(2, 100)
		b.set_horizontal_align(rows, cols, "right")

		scalar nwtmp
		nwtmp = strtoreal(nw2)
		cols=(1, nwtmp)
		rows=(1, 1)
		b.set_bottom_border(rows, cols, "medium")
		b.set_font_bold(rows,cols, "on")
		
		cols=(1, 1)
		rows=(1, 100)
		b.set_font_bold(rows, cols, "on")
		
		cols=(3, 3)
		rows=(1, 100)
		b.set_horizontal_align(rows, cols, "center")
		}
end
