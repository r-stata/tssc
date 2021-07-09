*! version 1.4.3 28Apr2017 Malte Kaukal
*!***************************************
*! Title: scandata.ado
*! Description: Ado to check variables for certain characteristics and distributions
*! Author: Malte Kaukal, GESIS - Leibniz Institute for the Social Sciences
*! Version 1.1.0: Infinite loop in correcting mutated vowels in uppercase-letters fixed;
*!   Threshold of value label length adapted					
*! Version 1.2.0: Mutated vowels correction has been improved and check for variable names has been adde
*! Version 1.3.0: title of tables wasn't always underlined; r-class elements renamed; corrections in help file (spelling);
*!   senseless if/in command erased; getting rid of complicated syntax; Infinite loop in correcting mutated vowels fixed (standalone mutated vowels couldn't be handled)
*! Version 1.3.1: error in nolabel option concerning 'too many values' error fixed
*! Version 1.4.0: implementation of a replace procedure for mutated vowels in open answers (strings); output corrections
*! Version 1.4.1: little bugfixes, performance improvements; correction of string option for mutated vowels; tempnames for locals are used
*! Version 1.4.2: correction of mutated vowels in strings is now optional and can be used on its own
*! Version 1.4.3: bug of infinite loop fixed
*!* ************************************************************************************************************

program scandata, rclass
	version 12
	syntax , [UPpercase] [LENgth(string asis)] [ODDvar(string asis)] [UMlaut] [STRUMlaut] [NOLabel] [ALL] [CORrect] [NOPrint]

	if `"`uppercase'"' == "" & `"`length'"' == ""  & `"`oddvar'"' == "" & `"`umlaut'"' == "" & `"`strumlaut'"' == "" & `"`nolabel'"' == ""  & `"`all'"' == "" {
		display as error "At least one option or {bf:all} has to be chosen"
		exit
	}

	capture which labellist
	if _rc == 111 {
		display as error "Ado {it:labellist} not found which is necessary to execute {it:scandata}."
		display as error "Type {input: ssc install labellist} to get the ado"
		exit
	}

	*Temporary names for input locals
	tempname vallabel varlabel varname crit1 crit2 crit3 crit1_out crit2_out

	*Parsing of length/oddvar criteria
	if "`all'" != "" & `"`length'"' == "" {
		local `vallabel' = 119
		local `varlabel' = 79
		local `varname' = 8
	}

	if "`all'" != "" & `"`oddvar'"' == "" {
		local `crit1' = 0.01
		local `crit2' = 0.95
		local `crit3' = 1
		local `crit1_out': display %4.2f ``crit1''*100
		local `crit2_out': display %4.2f ``crit2''*100
	}

	if "`length'" != "" | "`oddvar'" != "" {
		tempname option
		if  "`length'" != "" {
			local `option' = "length"
		}
		if "`oddvar'" != "" {
			local `option' = "oddvar"
		}
		if "`length'" != "" & "`oddvar'" != "" {
			local `option' = "length oddvar"
		}
		foreach par in ``option'' {
			tempname parse_`par'
			local `parse_`par'' = `"``par''"'
			if `"``parse_`par'''"' != "" {
				forvalue x = 1/3 {
					gettoken s`x' `parse_`par'': `parse_`par''
					gettoken w_`x' x_`x': s`x', pars("(")
					gettoken y_`x' z_`x' : x_`x', pars("(")
					gettoken `par'_s`x' : z_`x', pars(")")
				}
				foreach k in vallabel varname varlabel crit1 crit2 crit3 {
					forvalue  x = 1/3 {
						if strmatch(`"`s`x''"',"*`k'*") == 1 {
							if `"`k'"' == "vallabel" {
								local `vallabel' = 119
								if `"``par'_s`x''"' != ")" {
									local `vallabel' = ``par'_s`x''
								}
							}
							else if `"`k'"' == "varname" {
								local `varname' = 8
								if `"``par'_s`x''"' != ")" {
									local `varname' = ``par'_s`x''
								}
							}
							else if `"`k'"' == "varlabel" {
								local `varlabel' = 79
								if `"``par'_s`x''"' != ")" {
									local `varlabel' = ``par'_s`x''
								}
							}
							else if `"`k'"' == "crit1" {
								local `crit1' = 0.01
								if `"``par'_s`x''"' != ")" {
									local `crit1' = ``par'_s`x''
								}
								local `crit1_out': display %4.2f ``crit1''*100
							}
							else if `"`k'"' == "crit2" {
								local `crit2' = 0.95
								if `"``par'_s`x''"' != ")" {
									local `crit2' = ``par'_s`x''
								}
								local `crit2_out': display %4.2f ``crit2''*100
							}
							else if `"`k'"' == "crit3" {
								local `crit3' = 1
								if `"``par'_s`x''"' != ")" {
									local `crit3'=``par'_s`x''
								}
							}
						}
					}
				}
			}
		}
	}
	* Setting temporary names for variable loop
	tempname u ustr uppercase1 length_varname length_varlabel length_vallabel crashnote ///
	 				 u1 u2 u3 u4 um3 um4 um5 umlautvarname1 umlautvar1 numcount umlautval1 umlauttext ///
	 			 	 umlautcontrol umlaut_varname umlautdouble um2 lab_help lab1 lab2 lab3 lab4 lab5 lab_k_help ///
					 umlauttext numcount alllab crash varlab labpercent oddvar1 oddvar2 oddvar3 proport propercent ///
					 crashvar oddvar0 oddvar_or oddvar_and vallabel_var varlabel_var varname_var z nolabel1 ///
					 capvar1 check_rename

	*Check criteria
	*Different commands for Version 14
	if c(stata_version) >= 14 {
		local `u' u		// prefix for unicode commands
		local `ustr' ustr
	}

	*Setting locals independet of variables
	local `um3' : display ``u''char(220) ``u''char(196) ``u''char(214)							// Locals for checking of uppercase or lowercase transformation is needed
	local `um4' : display ``u''char(252) ``u''char(228) ``u''char(246)
	local `um5' : display ``u''char(223)
	local `u1' = ``u''char(220)
	local `u2' = ``u''char(196)
	local `u3' = ``u''char(214)
	local `u4' = ``u''char(223)

	foreach var of varlist _all {
		local `uppercase1' = ``u''lower(`"`var'"')
		local `length_varname' = ``u''length(`"`var'"')
		local `length_varlabel' = ``u''length(`"`:variable label `var''"')
		local `length_vallabel' = 0
		local `crashnote' = 0


		if `"`umlaut'"' != "" | `"`strumlaut'"' != "" | `"``vallabel''"' != "" | `"`all'"' != "" { // Check for mutated vowels in variable and labels
			if `"`umlaut'"'!="" | `"`all'"' != "" {
				*Variable names
				if ``ustr''regexm(`"`var'"',`"[``um3''``um4''``um5'']"') == 1 {
					local `umlautvarname1' `"``umlautvarname1'' `var'"'
					local `umlautvarname1' : list uniq `umlautvarname1'
				}

				*Variable labels
				if ``ustr''regexm(`"`:variable label `var''"',`"[``um3''``um4''``um5'']"') == 1 {
					local `umlautvar1' `"``umlautvar1'' `var'"'
					local `umlautvar1': list uniq `umlautvar1'
				}

				*Labels
				capture confirm numeric variable `var'
				if !_rc {
					local `numcount' = ``numcount''+1
					qui labellist `var'					// Ado by Daniel Klein
					foreach k in `r(values)' {

						if  ``u''length(`"`: label `:value label `var'' `k''"') > ``length_vallabel'' {				// Searching for greatest label length
							local `length_vallabel' = ``u''length(`"`: label `:value label `var'' `k''"')
						}

						if `"`umlaut'"' != "" | `"`all'"' != "" {
							if ``ustr''regexm(`"`:label `:value label `var'' `k''"',`"[``um3''``um4''``um5'']"') == 1 {
								local `umlautval1' `"``umlautval1'' `var'"'
								local `umlautval1' : list uniq `umlautval1'
							}
						}
					}
				}
			}
			if `"`strumlaut'"'!="" | `"`all'"' != "" {
				*Strings
				capture confirm string variable `var'
				if !_rc {
					qui tab1 `var' if ``ustr''regexm(`var',`"[``um3''``um4''``um5'']"') == 1
					if r(N) != 0 {
						local `umlauttext' `"``umlauttext'' `var'"'
						local `umlauttext' : list uniq `umlauttext'
					}
				}
			}


			if `"`correct'"' != "" {
				if (`"`umlaut'"' != "" | `"`all'"' != "") {
					*Variable names
					local `umlautcontrol' = 0
					if ``ustr''regexm(`"`var'"',`"[``um3''``um4''``um5'']"') == 1 {
							local `umlautcontrol' = 1
							local `umlaut_varname' = `"`var'"'
					}
					while ``umlautcontrol'' == 1 {
						foreach p in ``u''char(220) ``u''char(196) ``u''char(214) ``u''char(223) {
							local `umlautdouble' = 1
							while ``umlautdouble'' == 1 {
								local `um2' = `p'
								if ``ustr''regexm(`"``umlaut_varname''"',`"([``um2''][A-Z``um3'']+)|([A-Z``um3'']+[``um2''])"') == 1 {			// Checking for uppercase letters before or behind
									if "`p'" == "``u''char(220)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(220),``u''char(85) + ``u''char(69),1)
									}
									else if "`p'" == "``u''char(196)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(196),``u''char(65) + ``u''char(69),1)
									}
									else if "`p'" == "``u''char(214)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(214),``u''char(79) + ``u''char(69),1)
									}
									else if "`p'" == "``u''char(223)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(223),2*``u''char(83),1)
									}
								}
								if ``ustr''regexm(`"``umlaut_varname''"',`"([``um2''][a-z``um4'']+)|([a-z``um4'']+[``um2''])"') == 1 { 			// Checking for lowercase letters before or behind
									if "`p'" == "``u''char(220)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(220),``u''char(85) + ``u''char(101),1)
									}
									else if "`p'" == "``u''char(196)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(196),``u''char(65) + ``u''char(101),1)
									}
									else if "`p'" == "``u''char(214)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(214),``u''char(79) + ``u''char(101),1)
									}
									else if "`p'" == "``u''char(223)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(223),2*``u''char(115),1)
									}
								}
								if ``ustr''regexm(`"``umlaut_varname''"',`"(^[``um2'']$)"') == 1 { 			// Checking for standalone uppercase mutated vowels
									if "`p'" == "``u''char(220)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(220),``u''char(85) + ``u''char(69),1)
									}
									else if "`p'" == "``u''char(196)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(196),``u''char(65) + ``u''char(69),1)
									}
									else if "`p'" == "``u''char(214)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(214),``u''char(79) + ``u''char(69),1)
									}
									else if "`p'" == "``u''char(223)" {
										local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(223),2*``u''char(83),1)
									}
								}
								if ``ustr''regexm(`"``umlaut_varname''"',"[``um2'']") == 0 {
									local `umlautdouble' = 0
								}
							}
						}
						local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(228),``u''char(97) + ``u''char(101),1)
						local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(246),``u''char(111) + ``u''char(101),1)
						local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(252),``u''char(117) + ``u''char(101),1)
						local `umlaut_varname' = ``u''subinstr(`"``umlaut_varname''"',``u''char(223), 2*``u''char(83),1)

						local `umlautcontrol' = 0
						if ``ustr''regexm(`"``umlaut_varname''"',`"[``um3''``um4''``um5'']"') == 1 {
								local `umlautcontrol' = 1
						}
					}

					*Variable labels
					local `lab_help' = subinstr(`"`:variable label `var''"',``u''char(34),``u''char(7),.)		// Replacing quotation marks due to problems in word parsing
					local `lab_help' = subinstr(`"``lab_help''"',``u''char(39),``u''char(8),.)
					lab var `var' `"``lab_help''"'

					local `umlautcontrol' = 0
					if ``ustr''regexm(`"`:variable label `var''"',`"[``um3''``um4''``um5'']"') == 1 {
							local `umlautcontrol' = 1
					}
					while ``umlautcontrol'' == 1 {
						foreach x of numlist 1/`:word count `:variable label `var''' {
							foreach p in ``u''char(220) ``u''char(196) ``u''char(214) ``u''char(223) {
								local `umlautdouble' = 1
								while ``umlautdouble'' == 1 {
									local `um2' = `p'
									if ``ustr''regexm(`"`:word `x' of `:variable label `var'''"',`"([``um2''][A-Z``um3'']+)|([A-Z``um3'']+[``um2''])"') ==1  {			// Checking for uppercase letters before or behind
										if "`p'" == "``u''char(220)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(220),``u''char(85) + ``u''char(69),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
										else if "`p'" == "``u''char(196)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(196),``u''char(65) + ``u''char(69),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
										else if "`p'" == "``u''char(214)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(214),``u''char(79) + ``u''char(69),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
										else if "`p'" == "``u''char(223)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(223),2*``u''char(83),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
									}
									if ``ustr''regexm(`"`:word `x' of `:variable label `var'''"',`"([``um2''][a-z``um4'']+)|([a-z``um4'']+[``um2''])"') == 1 { 			// Checking for lowercase letters before or behind
										if "`p'" == "``u''char(220)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(220),``u''char(85) + ``u''char(101),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
										else if "`p'" == "``u''char(196)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(196),``u''char(65) + ``u''char(101),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
										else if "`p'" == "``u''char(214)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(214),``u''char(79) + ``u''char(101),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
										else if "`p'" == "``u''char(223)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(223),2*``u''char(115),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
									}
									if ``ustr''regexm(`"`:word `x' of `:variable label `var'''"',`"(^[``um2'']$)"') == 1 {			// Checking for standalone uppercase mutated vowels
										if "`p'" == "``u''char(220)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(220),``u''char(85) + ``u''char(69),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
										else if "`p'" == "``u''char(196)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(196),``u''char(65) + ``u''char(69),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
										else if "`p'" == "``u''char(214)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(214),``u''char(79) + ``u''char(69),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
										else if "`p'" == "``u''char(223)" {
											local `lab1' = ``u''subinstr(`"`:word `x' of `:variable label `var'''"',``u''char(223),2*``u''char(83),1)
											local `lab2' = ``u''subinstr(`"`:variable label `var''"',`"`:word `x' of `:variable label `var'''"',"``lab1''",1)
											label variable `var' `"``lab2''"'
										}
									}

									if ``ustr''regexm(`"`:word `x' of `:variable label `var'''"',"[``um2'']") == 0 {
										local `umlautdouble' = 0
									}
								}
							}
						}
						local `lab2' = ``u''subinstr(`"`:variable label `var''"',``u''char(228),``u''char(97) + ``u''char(101),1)
						local `lab3' = ``u''subinstr(`"``lab2''"',``u''char(246),``u''char(111) + ``u''char(101),1)
						local `lab4' = ``u''subinstr(`"``lab3''"',``u''char(252),``u''char(117) + ``u''char(101),1)
						local `lab5' = ``u''subinstr(`"``lab4''"',``u''char(223), 2*``u''char(83),1)
						label variable `var' `"``lab5''"'

						local `umlautcontrol' = 0
						if ``ustr''regexm(`"`:variable label `var''"',`"[``um3''``um4''``um5'']"') == 1 {
								local `umlautcontrol' = 1
						}
					}

					local `lab_help' = ``u''subinstr(`"`:variable label `var''"',``u''char(7),``u''char(34),.)		// Restoring quotation marks
					local `lab_help' = ``u''subinstr(`"``lab_help''"',``u''char(8),``u''char(39),.)
					lab var `var' `"``lab_help''"'

					*Labels
					qui labellist `var'
					foreach k in `r(values)' {
						if `"`:label `:value label `var'' `k''"' != `"`k'"' {
							local `lab_k_help' = ``u''subinstr(`"`:label `:value label `var'' `k''"',``u''char(34),``u''char(7),.)  // Replacing quotation marks due to problems in word parsing
							local `lab_k_help' = ``u''subinstr(`"``lab_k_help''"',``u''char(39),``u''char(8),.)
							lab def `:value label `var'' `k' `"``lab_k_help''"', modify

							local `umlautcontrol' = 0
							if ``ustr''regexm(`"`:label `:value label `var'' `k''"',`"[``um3''``um4''``um5'']"') == 1 {
									local `umlautcontrol' = 1
							}
							while ``umlautcontrol'' == 1 {
								foreach x of numlist 1/`:word count `:label `:value label `var'' `k''' {
									local `umlautdouble' = 1
									while ``umlautdouble'' == 1 {
										foreach p in ``u''char(220) ``u''char(196) ``u''char(214) ``u''char(223) {
											local `um2' = `p'
											if ``ustr''regexm(`"`:word `x' of `:label `:value label `var'' `k'''"',`"([``um2''][A-Z``um3'']+)|([A-Z``um3'']+[``um2''])"') == 1 {  	// Checking for uppercase letters before or behind
												if "`p'" == "``u''char(220)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(220),``u''char(85) + ``u''char(69),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
												else if "`p'" == "``u''char(196)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(196),``u''char(65) + ``u''char(69),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
												else if "`p'" == "``u''char(214)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(214),``u''char(79) + ``u''char(69),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
												else if "`p'" == "``u''char(223)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(223),2*``u''char(83),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
											}
											if ``ustr''regexm(`"`:word `x' of `:label `:value label `var'' `k'''"',`"([``um2''][a-z``um4'']+)|([a-z``um4'']+[``um2''])"') == 1 {				// Checking for lowercase letters before or behind
												if "`p'" == "``u''char(220)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(220),``u''char(85) + ``u''char(101),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
												else if "`p'" == "``u''char(196)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(196),``u''char(65) + ``u''char(101),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
												else if "`p'" == "``u''char(214)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(214),``u''char(79) + ``u''char(101),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
												else if "`p'" == "``u''char(223)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(223),2*``u''char(115),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
											}
											if ``ustr''regexm(`"`:word `x' of `:label `:value label `var'' `k'''"',`"^[``um2'']$"') == 1 {  	// Checking for standalone uppercase mutated vowels
												if "`p'" == "``u''char(220)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(220),``u''char(85) + ``u''char(69),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
												else if "`p'" == "``u''char(196)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(196),``u''char(65) + ``u''char(69),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
												else if "`p'" == "``u''char(214)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(214),``u''char(79) + ``u''char(69),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
												else if "`p'" == "``u''char(223)" {
													local `lab1' = ``u''subinstr(`"`:word `x' of `:label `:value label `var'' `k'''"',``u''char(223),2*``u''char(83),1)
													local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',`"`:word `x' of `:label `:value label `var'' `k'''"',"``lab1''",1)
													label def `:value label `var'' `k' `"``lab2''"', modify
												}
											}
										}
										if ``ustr''regexm(`"`:word `x' of `:label `:value label `var'' `k'''"',"[``um2'']") == 0 {
											local `umlautdouble' = 0
										}
									}
								}
								local `lab2' = ``u''subinstr(`"`:label `:value label `var'' `k''"',``u''char(228),``u''char(97) + ``u''char(101),1)
								local `lab3' = ``u''subinstr(`"``lab2''"',``u''char(246),``u''char(111) + ``u''char(101),1)
								local `lab4' = ``u''subinstr(`"``lab3''"',``u''char(252),``u''char(117) + ``u''char(101),1)
								local `lab5' = ``u''subinstr(`"``lab4''"',``u''char(223), 2*``u''char(83),1)
								label def `:value label `var'' `k' `"``lab5''"', modify

								local `umlautcontrol' = 0
								if ``ustr''regexm(`"`:label `:value label `var'' `k''"',`"[``um3''``um4''``um5'']"') == 1 {
										local `umlautcontrol' = 1
								}
							}
							local `lab_k_help' = ``u''subinstr(`"`:label `:value label `var'' `k''"',``u''char(7),``u''char(39),.)  // Restoring quotation marks
							local `lab_k_help' = ``u''subinstr(`"``lab_k_help''"',``u''char(8),``u''char(39),.)
							lab def `:value label `var'' `k' `"``lab_k_help''"', modify
						}
					}
				}
				*Text
				if (`"`strumlaut'"'!="" | `"`all'"' != "") {
					capture confirm string variable `var'
					if !_rc {
						quietly {
							qui tab1 `var' if ``ustr''regexm(`var',`"[``um3''``um4''``um5'']"') == 1
							if r(N) != 0 {
								local `umlauttext' `"``umlauttext'' `var'"'
								local `umlauttext': list uniq `umlauttext'

								gen `var'_cmv = `var'
								lab var `var'_cmv `"`:variable label `var'' [corrected mutated vowels]"'

								replace `var'_cmv = subinstr(`var'_cmv,``u''char(10),``u''char(32),.) // Linefeed is transformed in space
								replace `var'_cmv = subinstr(`var'_cmv,``u''char(13),``u''char(32),.) // Carriage return is transformed in space

								*uppercase following/preceeding
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(85) + ``u''char(69) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[ ]*)([``u1''])([A-Z``um3'']+.*)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(65) + ``u''char(69) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[ ]*)([``u2''])([A-Z``um3'']+.*)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(79) + ``u''char(69) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[ ]*)([``u3''])([A-Z``um3'']+.*)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(83) + ``u''char(83) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[ ]*)([``u4''])([A-Z``um3'']+.*)"') == 1

								replace `var'_cmv = ``u''char(85) + ``u''char(69) + ``ustr''regexs(2) if ``ustr''regexm(`var'_cmv,`"^([``u1''])([A-Z``um3'']+.*)"') == 1
								replace `var'_cmv = ``u''char(65) + ``u''char(69) + ``ustr''regexs(2) if ``ustr''regexm(`var'_cmv,`"^([``u2''])([A-Z``um3'']+.*)"') == 1
								replace `var'_cmv = ``u''char(79) + ``u''char(69) + ``ustr''regexs(2) if ``ustr''regexm(`var'_cmv,`"^([``u3''])([A-Z``um3'']+.*)"') == 1
								replace `var'_cmv = ``u''char(83) + ``u''char(83) + ``ustr''regexs(2) if ``ustr''regexm(`var'_cmv,`"^([``u4''])([A-Z``um3'']+.*)"') == 1

								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(85) + ``u''char(69) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[A-Z``um3'']+)([``u1''])([ ]*.*)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(65) + ``u''char(69) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[A-Z``um3'']+)([``u2''])([ ]*.*)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(79) + ``u''char(69) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[A-Z``um3'']+)([``u3''])([ ]*.*)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(83) + ``u''char(83) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[A-Z``um3'']+)([``u4''])([ ]*.*)"') == 1

								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(85) + ``u''char(69) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[A-Z``um3'']+)([``u1''])($)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(65) + ``u''char(69) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[A-Z``um3'']+)([``u2''])($)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(79) + ``u''char(69) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[A-Z``um3'']+)([``u3''])($)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(83) + ``u''char(83) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[A-Z``um3'']+)([``u4''])($)"') == 1

								*lowercase following
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(85) + ``u''char(101) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[ ]*)([``u1''])([a-z``um4'']+.*)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(65) + ``u''char(101) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[ ]*)([``u2''])([a-z``um4'']+.*)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(79) + ``u''char(101) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[ ]*)([``u3''])([a-z``um4'']+.*)"') == 1
								replace `var'_cmv = ``ustr''regexs(1) + ``u''char(83) + ``u''char(115) + ``ustr''regexs(3) if ``ustr''regexm(`var'_cmv,`"(.*[ ]*)([``u4''])([a-z``um4'']+.*)"') == 1

								replace `var'_cmv = ``u''char(85) + ``u''char(101) + ``ustr''regexs(2) if ``ustr''regexm(`var'_cmv,`"^([``u1''])([a-z``um4'']+.*)"') == 1
								replace `var'_cmv = ``u''char(65) + ``u''char(101) + ``ustr''regexs(2) if ``ustr''regexm(`var'_cmv,`"^([``u2''])([a-z``um4'']+.*)"') == 1
								replace `var'_cmv = ``u''char(79) + ``u''char(101) + ``ustr''regexs(2) if ``ustr''regexm(`var'_cmv,`"^([``u3''])([a-z``um4'']+.*)"') == 1
								replace `var'_cmv = ``u''char(83) + ``u''char(115) + ``ustr''regexs(2) if ``ustr''regexm(`var'_cmv,`"^([``u4''])([a-z``um4'']+.*)"') == 1

								*lowercase mutated vowels
								replace `var'_cmv = ``u''subinstr(`var'_cmv,``u''char(252),``u''char(117) + ``u''char(101),.)
								replace `var'_cmv = ``u''subinstr(`var'_cmv,``u''char(228),``u''char(97) + ``u''char(101),.)
								replace `var'_cmv = ``u''subinstr(`var'_cmv,``u''char(246),``u''char(111) + ``u''char(101),.)
								replace `var'_cmv = ``u''subinstr(`var'_cmv,``u''char(223),``u''char(115) + ``u''char(115),.)

							}
						}
					}
				}
			}
		}

		if `"`oddvar'"' != "" | `"`nolabel'"' != "" | `"`all'"' != "" {                                   // Check for odd distributions in variables
			capture confirm numeric variable `var'
			if `"`umlaut'"' == "" & `"`all'"' == "" {
				local `numcount' = ``numcount'' + 1
			}
			if !_rc {
				capture qui label list `:value label `var''
				local `alllab' = r(k)

				capture qui tab1 `var', matcell(matval) matrow(values)
				if _rc == 134 {
					if `"``crash''"' == "" {
						local `crash' = "`var'"
						local `crashnote' = 1
					}
					else {
						local `crash' = "``crash''" + " `var'"
					}
				}
				else {
					local `varlab' = r(r)
					if `"`oddvar'"' != "" | `"`all'"' != "" {
						local `labpercent' = ``varlab''/``alllab''							    // Percentage of all values used in variable being in the value label available

						if "``crit1''" != "" & "`:value label `var''" != "" {
							if ``labpercent'' < ``crit1'' {									// Odd distribution criterion 1: Percentage of used values regarding all labels
								local `oddvar1' = "``oddvar1'' `var'"
								local `oddvar1': list uniq `oddvar1'
							}
						}

						if "``crit2''" != "" | "``crit3''" != "" {
							forval x = 1/``varlab'' {
								local `proport' = el(matval,`x',1)
								local `propercent' = ``proport''/c(N)							    // Percentage of oberservations per value regarding all observations
								if "``crit2''" != "" {
									if  ``propercent'' > ``crit2'' & ``propercent'' < .  {		// Odd distribution criterion 2: Threshold of classifying value as having to many observations
										local `oddvar2' = "``oddvar2'' `var'"
										local `oddvar2': list uniq `oddvar2'
									}
								}
								if "``crit3''" != "" {
									if ``proport'' <= ``crit3'' {					// Odd distribution criterion 3: Threshold of classifying values as having too little observations
										local `oddvar3' = "``oddvar3'' `var'"
										local `oddvar3': list uniq `oddvar3'
									}
								}
							}
						}
					}
				}
			}

			local `crashvar': list clean `crash'

			if ("``crit1''" != "" & ("``crit2''" != "" | "``crit3''" != "")) | ///
			   ("``crit2''" != "" & ("``crit1''" != "" | "``crit3''" != "")) | ///
			   ("``crit3''" != "" & ("``crit1''" != "" | "``crit2''" != "")) {
					local `oddvar0': list `oddvar1' | `oddvar2'			          // Grouping odd variables
					local `oddvar_or': list `oddvar0' | `oddvar3'
					local `oddvar_or': list sort `oddvar_or'                                // Fitting one criteria out of all
			}

			if "``crit1''" != "" & "``crit2''" != "" & "``crit3''" != "" {
				local `oddvar_and': list `oddvar1' & `oddvar2'
				local `oddvar_and': list `oddvar_and' & `oddvar3'
				local `oddvar_and': list sort `oddvar_and'                            // Fitting all criteria apllied
			}
			else if "``crit1''" == "" & "``crit2''" != "" & "``crit3''" != "" {
				local `oddvar_and': list `oddvar2' & `oddvar3'
				local `oddvar_and': list sort `oddvar_and'                            // Fitting all criteria apllied
			}
			else if "``crit1''" != "" & "``crit2''" == "" & "``crit3''" != "" {
				local `oddvar_and': list `oddvar1' & `oddvar3'
				local `oddvar_and': list sort `oddvar_and'                            // Fitting all criteria apllied
			}
			else if "``crit1''" != "" & "``crit2''" != "" & "``crit3''" == "" {
				local `oddvar_and': list `oddvar1' & `oddvar2'
				local `oddvar_and': list sort `oddvar_and'                            // Fitting all criteria apllied
			}

			else if "``crit1''" != "" & "``crit2''" == "" & "``crit3''" == "" {
				local `oddvar_and': list sort `oddvar1'                            // Just one criterion chosen
			}
			else if "``crit1''" == "" & "``crit2''" != "" & "``crit3''" == "" {
				local `oddvar_and': list sort `oddvar2'                            // Just one criterion chosen
			}
			else if "``crit1''" == "" & "``crit2''" == "" & "``crit3''" != "" {
				local `oddvar_and': list sort `oddvar3'                            // Just one criterion chosen
			}
		}

		if `"`length'"' != "" | `"`all'"' != "" { 								// Check for length of variable name
			foreach k of newlist vallabel varlabel varname {
				if `"```k'''"' != "" {
					if ``length_`k''' > ```k''' {
						local ``k'_var' "```k'_var'' `var'"
						local ``k'_var': list uniq ``k'_var'
					}
				}
			}
		}

		if (`"`nolabel'"' != "" | `"`all'"' != "") & `"`:value label `var''"' != "" & "``crashnote''" == "0" {				// Searching for unlabeled values
			forval x = 1/``varlab'' {
				local `z' = el(values,`x',1)
				if `"`: label `:value label `var'' ``z'', strict'"' == "" {
					local `nolabel1' `"``nolabel1'' `var'"'
					local `nolabel1': list uniq `nolabel1'
				}
			}
		}

		if `"`uppercase'"' != "" | `"`all'"' != "" { 							// Check for uppercase letters
			if "``uppercase1''" != "`var'" | strmatch(`"`var'"',`"*``um5''*"') == 1 {
				local `capvar1' "``capvar1'' `var'"
				local `capvar1': list uniq `capvar1'
				if `"`correct'"' != "" {
					if (`"`umlaut'"' != "" | `"`all'"' != "") & strmatch("``umlautvarname1''",`"*`var'*"') == 1 {
						local `umlaut_varname' = ``u''strlower(`"``umlaut_varname''"')
						rename `var' ``umlaut_varname''
						local `check_rename' = 1
					}
					else {
						rename `var' ``uppercase1''
					}
				}
			}
		}

		if (`"`umlaut'"' != "" | `"`all'"' != "") & `"`correct'"' != "" & `"``check_rename''"' != "1" &  ``ustr''regexm(`"``umlautvarname1''"',`"(^`var'$)|([A-Za-z0-9]*[ ]`var'[ A-Za-z0-9]*)"') == 1 {
			 rename `var' ``umlaut_varname''
			 local `check_rename' = 0
		}
	}

	*Generating Output
	tempname number1 number2 wordn wordn2 y1 y2 ncol col hlpcol ctrl hlpcount hlich1 hlich2 capcount vallabel_count varlabel_count varname_count uml0count uml1count uml2count uml3count ///
					nolabelcount oddvar_or_count oddvar_or1_count oddvar_and_count check
	tempname done1 done2 done3 done4 done51 done52 done53 done54 done6 done7
	tempname done11 done12 done13 done14 done151 done152 done153 done154 done16 done17

	foreach output of newlist `capvar1' `vallabel_var' `varlabel_var' `varname_var' `umlautvarname1' `umlautvar1' `umlautval1' `umlauttext' `nolabel1' `oddvar_or' `oddvar_and' `crashvar' {

		*Defining locals I
		local `number1' = 0
		local `number2' = 0

		*Preparation for output/ defining locals II
		local `wordn' : word count ``output''
		local `y2' = 8
		forval z = 1/``wordn'' {
			local `y1' = length("`:word `z' of ``output'''")		// Checking length of variables
			if ``y1'' > ``y2'' {
				local `y2' = ``y1''
			}
		}

		local `ncol' = floor(c(linesize)/(``y2'' + 2))						// Locals needed for table output
		local `ctrl' = 1
		local `hlpcount' = 0
		local `wordn2' = ceil(``wordn''/``ncol'')
		local `hlich1' = (``y2'' + 2)*``wordn''
		local `hlich2' = (``y2'' + 2)*``ncol''

		local `capcount': word count ``capvar1''
		local `vallabel_count': word count ``vallabel_var''
		local `varlabel_count': word count ``varlabel_var''
		local `varname_count': word count ``varname_var''
		local `uml0count': word count ``umlautvarname1''
		local `uml1count': word count ``umlautvar1''
		local `uml2count': word count ``umlautval1''
		local `uml3count': word count ``umlauttext''
		local `nolabelcount': word count ``nolabel1''
		local `oddvar_or_count': word count ``oddvar_or''
		local `oddvar_or1_count': word count ``oddvar_or1''
		local `oddvar_and_count': word count ``oddvar_and''


		*Output

		if "`noprint'" == "" {
			if `"``output''"' != "" | `"`all'"' != "" {
				display ""
					if `"`output'"' == "`capvar1'" {
						display "{text} {bind:Variables with upper-case characters (``capcount'' of `c(k)' variables)}"
					}
					else if `"`output'"' == "`vallabel_var'"  & "``vallabel''" != "" {
						display "{text} {bind:Value labels with more than ``vallabel'' characters (``vallabel_count'' of ``numcount'' numeric variables)}"
					}
					else if `"`output'"' == "`varlabel_var'" & "``varlabel''" != "" {
						display "{text} {bind:Variable labels with more than ``varlabel'' characters (``varlabel_count'' of `c(k)' variables)}"
					}
					else if `"`output'"' == "`varname_var'" & "``varname''" != "" {
						display "{text} {bind:Variable names with more than ``varname'' characters (``varname_count'' of `c(k)' variables)}"
					}
					else if `"`output'"' == "`umlautvarname1'" {
						display "{text} {bind:Variables with mutated vowels in {ul:variable names} (``uml0count'' of `c(k)' variables)}"
					}
					else if `"`output'"' == "`umlautvar1'" {
						display "{text} {bind:Variables with mutated vowels in {ul:variable} labels (``uml1count'' of `c(k)' variables)}"
					}
					else if `"`output'"' == "`umlautval1'" {
						display "{text} {bind:Variables with mutated vowels in {ul:value} labels (``uml2count'' of ``numcount'' numeric variables)}"
					}
					else if `"`output'"' == "`umlauttext'" {
						display "{text} {bind:Variables with mutated vowels in {ul:string} variables (``uml3count'' of `c(k)' variables)}"
					}
					else if `"`output'"' == "`nolabel1'" {
						display "{text} {bind:Variables with unlabeled values (``nolabelcount'' of ``numcount'' numeric variables)}"
					}
					else if `"`output'"' == "`oddvar_or'" {
						display "{text} {bind:Variables fitting at least one criterion of an odd variable distribution (``oddvar_or_count'' of ``numcount'' numeric variables)}"
					}
					else if `"`output'"' == "`oddvar_and'" {
						display "{text} {bind:Variables fitting all criteria of an odd variable distribution (``oddvar_and_count'' of ``numcount'' numeric variables)}"
					}
					else if `"`output'"' == "`crashvar'" & "``crashvar''" != "" {
						display "{error} {bind:{ul:Variables being skipped while checking due to 'too many values' error}}"
					}

				if ``wordn'' <= ``ncol'' & ``hlich1'' > 99 & `"`output'"' != "`crashvar'" {
					display "{text} {hline ``hlich1''}"
				}
				else if ``wordn'' > ``ncol'' & ``hlich2'' > 99  & `"`output'"' != "`crashvar'" {
					display "{text} {hline ``hlich2''}"
				}
				else if  (``hlich1'' <= 99 | ``hlich2'' <= 99) & c(linesize)>99  & `"`output'"' != "`crashvar'"  {
					display "{text} {hline 99}"
				}
				else if c(linesize)<=99 & `"`output'"' != "`crashvar'"  {
					local line = c(linesize)-1
					display "{text} {hline `line'}"
				}

				while ``ctrl'' <= ``wordn2'' & ``hlpcount'' <= ``wordn'' {
					local `col' = 1
					local `hlpcol' = 1
					while ``col'' <= ``ncol'' & ``hlpcount'' <= ``wordn'' {
						local `hlpcount' = ``hlpcount'' + 1
						display "{result}{col ``hlpcol''} {bind: `:word ``hlpcount'' of ``output'''}" _continue
						local `hlpcol' = ``hlpcol'' + ``y2'' + 2
						local `col' = ``col'' + 1
					}
					display _newline _continue
					local `ctrl' = ``ctrl'' + 1
				}
				if `"`correct'"' != "" & `"``hlpcount''"' != "0" & (`"`output'"' != "`vallabel_var'" & `"`output'"' != "`varlabel_var'" & `"`output'"' != "`varname_var'" & `"`output'"' != "`nolabel1'") ///
					& strmatch(`"`output'"',"`oddvar_or'") != 1 & strmatch(`"`output'"',"`oddvar_and'") != 1 & strmatch(`"`output'"',"`crashvar'") != 1  {
					display "{text} {bind:Variables found have been corrected}"
				}
				if `"`correct'"'=="" & `"``hlpcount''"' != "0" & (`"`output'"' != "`vallabel_var'" & `"`output'"' != "`varlabel_var'" & `"`output'"' != "`varname_var'" & `"`output'"' != "`nolabel1'") ///
					& strmatch(`"`output'"',"`oddvar_or'") != 1 & strmatch(`"`output'"',"`oddvar_and'") != 1 & strmatch(`"`output'"',"`crashvar'") != 1  {
					display "{error} {bind:Variables found have {ul:not} been corrected}"
				}
			}

			if  `"`output'"' == "`capvar1'" & `"``output''"' == "" & "`uppercase'" != "" & "``done1''" != "1" {
				display ""
				display "{result} {bind:No variables with upper-case characters in the dataset}"
				local `done1' = 1
			}
			else if  `"`output'"' == "`vallabel_var'" & `"``output''"' == "" & strmatch("`length'","*vallabel*") == 1 & "``done2''" != "1" {
				display ""
				display "{result} {bind:No value labels with more than ``vallabel'' characters in the dataset}"
				local `done2' = 1
			}
			else if  `"`output'"' == "`varlabel_var'" & `"``output''"' == "" & strmatch("`length'","*varlabel*") == 1 & "``done3''" != "1" {
				display ""
				display "{result} {bind:No variable labels with more than ``varlabel'' characters in the dataset}"
				local `done3' = 1
			}
			else if  `"`output'"' == "`varname_var'" & `"``output''"' == "" & strmatch("`length'","*varname*") == 1 & "``done4''" != "1" {
				display ""
				display "{result} {bind:No variable names with more than ``varname'' characters in the dataset}"
				local `done4' = 1
			}
			else if  (`"`output'"' == "`umlautvar1'") & `"``output''"' == "" & "`umlaut'" != "" & "``done51''" != "1" {
				display ""
				display "{result} {bind:No variable labels with mutated vowels in the dataset}"
				local `done51' = 1
			}
			else if  (`"`output'"' == "`umlautval1'") & `"``output''"' == "" & "`umlaut'" != "" & "``done52''" != "1" {
				display ""
				display "{result} {bind:No labels with mutated vowels in the dataset}"
				local `done52' = 1
			}
			else if  (`"`output'"' == "`umlautvarname1'") & `"``output''"' == "" & "`umlaut'" != "" & "``done53''" != "1" {
				display ""
				display "{result} {bind:No variable names with mutated vowels in the dataset}"
				local `done53' = 1
			}
			else if  (`"`output'"' == "`umlauttext'") & `"``output''"' == "" & "`strumlaut'" != "" & "``done54''" != "1" {
				display ""
				display "{result} {bind:No strings with mutated vowels in the dataset}"
				local `done54' = 1
			}
			else if  `"`output'"' == "`nolabel1'" & `"``output''"' == "" & "`nolabel'" != "" & "``done6''" != "1" {
				display ""
				display "{result} {bind:No variables with unlabeled values in the dataset}"
				local `done6' = 1
			}
			else if  (strmatch(`"`output'"',"`oddvar_or'") == 1 | strmatch(`"`output'"',"`oddvar_and'") == 1) & (`"``oddvar_or''"' == "" & `"``oddvar_and''"' == "")  & "`oddvar'" != "" & "``done7''" != "1" {
				display ""
				display "{result} {bind:No variables with an odd distribution in the dataset}"
				local `done7' = 1
			}
		}


		if "`noprint'" != "" {
			if "``check''" != "1" {
				display _newline
				display "{text} {bind:{ul:Summary of variables found in the dataset}}"
				local `check' = 1
			}
			if `"``output''"' != "" | `"`all'"' != "" {
				if `"`output'"' == "`capvar1'" {
					display "{result} {bind:Variables with upper-case characters {text:({result:``capcount''} of `c(k)' variables)}}"_newline
				}
				else if `"`output'"' == "`vallabel_var'" & "``vallabel''" != "" {
					display "{result} {bind:Value labels with more than ``vallabel'' characters {text:({result:``vallabel_count''} of ``numcount'' numeric variables)}}"_newline
				}
				else if `"`output'"' == "`varlabel_var'" & "``varlabel''" != "" {
					display "{result} {bind:Variable labels with more than ``varlabel'' characters {text:({result:``varlabel_count''} of `c(k)' variables)}}"_newline
				}
				else if `"`output'"' == "`varname_var'" & "``varname''" != "" {
					display "{result} {bind:Variable names with more than ``varname'' characters {text:({result:``varname_count''} of `c(k)' variables)}}"_newline
				}
				else if `"`output'"' == "`umlautvarname1'" {
					display "{result} {bind:Variables with mutated vowels in variable names {text:({result:``uml0count''} of `c(k)' variables)}}"_newline
				}
				else if `"`output'"' == "`umlautvar1'" {
					display "{result} {bind:Variables with mutated vowels in variable labels {text:({result:``uml1count''} of `c(k)' variables)}}"_newline
				}
				else if `"`output'"' == "`umlautval1'" {
					display "{result} {bind:Variables with mutated vowels in value labels {text:({result:``uml2count''} of ``numcount'' numeric variables)}}"_newline
				}
				else if `"`output'"' == "`umlauttext'" {
					display "{result} {bind:Variables with mutated vowels in string variables {text:({result:``uml3count''} of `c(k)' variables)}}"_newline
				}
				else if `"`output'"' == "`nolabel1'" {
					display "{result} {bind:Variables with unlabeled values {text:({result:``nolabelcount''} of ``numcount'' numeric variables)}}"_newline
				}
				else if `"`output'"' == "`oddvar_or'" {
					display "{result} {bind:Variables fitting at least one criterion of an odd variable distribution {text:({result:``oddvar_or_count''} of ``numcount'' numeric variables)}}"_newline
				}
				else if `"`output'"' == "`oddvar_and'" {
					display "{result} {bind:Variables fitting all criteria of an odd variable distribution {text:({result:``oddvar_and_count''} of ``numcount'' numeric variables)}}" _newline
				}
				else if `"`output'"' == "`crashvar'" & "``crashvar''" != "" {
					display "{error} {bind:There are variables being skipped while checking due to 'too many values' error}"
				}
			}

			if  `"`output'"' == "`capvar1' " & `"``output''"' == "" & "`uppercase'" != "" & "``done11''" != "1" {
				display "{result} {bind:No variables with upper-case characters in the dataset}"
				local `done11' = 1
			}
			else if  `"`output'"' == "`vallabel_var'" & `"``output''"' == "" & "`length'" != "" & "``done12''" != "1" {
				display ""
				display "{result} {bind:No value labels with more than ``vallabel'' characters in the dataset}"
				local `done12' = 1
			}
			else if  `"`output'"' == "`varlabel_var'" & `"``output''"' == "" & "`length'" != "" & "``done13''" != "1" {
				display ""
				display "{result} {bind:No variable labels with more than ``varlabel'' characters in the dataset}"
				local `done13' = 1
			}
			else if  `"`output'"' == "`varname_var'" & `"``output''"' == "" & "`length'" != "" & "``done14''" != "1" {
				display ""
				display "{result} {bind:No variable names with more than ``varname'' characters in the dataset}"
				local `done14' = 1
			}
			else if  (`"`output'"' == "`umlautvar1'") & `"``output''"' == "" & "`umlaut'" != "" & "``done151''" != "1" {
				display ""
				display "{result} {bind:No variable labels with mutated vowels in the dataset}"
				local `done151' = 1
			}
			else if  (`"`output'"' == "`umlautval1'") & `"``output''"' == "" & "`umlaut'" != "" & "``done152''" != "1" {
				display ""
				display "{result} {bind:No labels with mutated vowels in the dataset}"
				local `done152' = 1
			}
			else if  (`"`output'"' == "`umlautvarname1'") & `"``output''"' == "" & "`umlaut'" != "" & "``done153''" != "1" {
				display ""
				display "{result} {bind:No variable names with mutated vowels in the dataset}"
				local `done153' = 1
			}
			else if  (`"`output'"' == "`umlauttext'") & `"``output''"' == "" & "`strumlaut'" != "" & "``done154''" != "1" {
				display ""
				display "{result} {bind:No strings with mutated vowels in the dataset}"
				local `done154' = 1
			}
			else if  `"`output'"' == "nolabel1" & `"``output''"' == "" & "`nolabel'" != "" & "``done16''" != "1" {
				display "{result} {bind:No variables with unlabeled values in the dataset}"
				local `done16' = 1
			}
			else if  (strmatch(`"`output'"',"`oddvar_or'") == 1 | strmatch(`"`output'"',"`oddvar_and'") == 1) & (`"``oddvar_or''"' == "" & `"``oddvar_or1''"' == "" & `"``oddvar_and''"' == "")  & "`oddvar'" != "" & "``done17''" != "1" {
				display "{result} {bind:No variables with odd distribution in the dataset}"
				local `done17' = 1
			}
		}
	}

	if `"`correct'"' != "" & "`noprint'" != "" & (`"`uppercase'"' != "" | `"`umlaut'"' != "" | `"`all'"' != "") ///
		& ("``capvar1''" != "" | "``vallabel_var''" != "" | "``varlabel_var''" != "" | "``varname_var''" != "" | "``umlautvarname1''" != "" | "``umlautvar1''" != "" | "``umlautval1''" != "" | "``umlauttext''" != "") {
		display "{text} {bind:Variables found have been corrected}"
	}
	if `"`correct'"' == "" & "`noprint'" != "" & (`"`uppercase'"' != "" | `"`umlaut'"' != "" | `"`all'"' != "") ///
		& ("``capvar1''" != "" | "``vallabel_var''" != "" | "``varlabel_var''" != "" | "``varname_var''" != "" | "``umlautvarname1''" != "" | "``umlautvar1''" != "" | "``umlautval1''" != "" | "``umlauttext''" != "") {
		display "{error} {bind:Variables found have {ul:not} been corrected}"
	}

	if  `"`oddvar'"' != "" | `"`all'"' != "" {
		display ""
		display "{text} {bind:{ul:Applied criteria of an odd distribution are:}}"
		if "``crit1''" != "" {
			display "{text} {bind:  (1) Less than ``crit1_out'' percent of values being available in value label have been chosen}"
		}
		if "``crit2''" != "" {
			display "{text} {bind:  (2) More than ``crit2_out'' percent of all observations are assigned to a single value}"
		}
		if "``crit3''" != "" {
			display "{text} {bind:  (3) Equal to or less than ``crit3'' observation(s) are assigned to a single value}"
		}
	}

	*Storing results
	return local capvar "``capvar1''"
	return local length_val "``vallabel_var''"
	return local length_var "``varlabel_var''"
	return local length_name "``varname_var''"
	return local umlaut_name "``umlautvarname1''"
	return local umlaut_var "``umlautvar1''"
	return local umlaut_val "``umlautval1''"
	return local umlaut_str "``umlauttext''"
	return local mis_lab "``nolabel1''"
	return local odd_or "``oddvar_or''"
	return local odd_and "``oddvar_and''"
end
