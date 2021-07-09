*! version 2.9.4 Joe Long 03feb2016
program orth_out, rclass
	version 12.0
	syntax varlist [using] [if], BY(varlist) [replace] ///
		[SHEET(string) SHEETREPlace SHEETMODify BDec(numlist) PCOMPare COMPare count vcount]  ///
		[NOLAbel ARMLAbel(string asis) VARLAbel(string asis) NUMLAbel] ///
		[COLNUM Title(string asis) NOTEs(string asis) test overall] ///
		[PROPortion SEmean COVARiates(varlist)] ///
		[INTERACTion Reverse reverseall VAPPend HAPPend stars vce(passthru) latex full dta]
		
	preserve
	if `"`if'"' != "" {
		qui keep `if'
	}
	if "`compare'" != "" & "`pcompare'" != "" {
		di as err "Cannot specify compare and pcompare together"
		exit 198
	}
	if `"`using'"' == `""' & "`latex'" != "" {
		di as err "Must specify output file"
		exit 198
	}
	if "`latex'" != "" & "`dta'" != "" {
		di as err "You cannot specify both latex and dta option simultaneously"
		exit 198
	}
	if `"`using'"' == `""' & "`dta'" != "" {
		di as err "Must specify output file"
		exit 198
	}	
	* Generate single treatment variable with levels for each treatment arm
	loc ntreat: word count `by'
	if `ntreat' > 1 {
		tempvar marker
		gen `marker' = 0
		foreach var of loc by {
			cap confirm numeric var `var'
			if _rc != 0 {
				cap destring `var', replace
				if _rc != 0 {
					di as err "Cannot process non-numeric binary strings."
					exit 109
				}
			}
			qui replace `marker' = 1 if `var' == 1
		}
		tempvar treatment_type
		qui egen `treatment_type' = group(`by')
		qui replace `treatment_type' = . if !`marker'
		qui replace `treatment_type' = -`treatment_type'
		loc backwards 1
	}
	else {
		loc backwards 0
		if "`=substr("`:type `by''", 1, 3)'" == "str"{
			tempvar alt
			qui encode `by', gen(`alt')
			drop `by'
			qui rename `alt' `by'
		}
		qui levelsof `by', local(arms)
		loc n 0
		loc vallab: val lab `by'
		foreach val of loc arms {
			loc ++n
			if "`vallab'" != "" {
				loc cname: lab `vallab' `val'
			}
			else {
				loc cname: lab `by' `val'
			}
			loc cnames "`cnames' "`cname'""
		}

		loc ntreat : word count `arms'

		loc n 0
		foreach val of loc arms {
			loc ++n
			tempvar treatarm`n'
			gen `treatarm`n'' = `by' == `val'
		}

		tempvar treatment_type
		qui gen `:type `by'' `treatment_type' = `by'
		loc by
		forvalues i = 1/`ntreat' {
			loc by "`by' `treatarm`i''"
		}
	}

	loc varcount: word count `varlist'
	loc by2 `by'
	
	*Determine the number of columns 
	if "`compare'" != "" | "`pcompare'" != "" {
		loc base = (`ntreat'^2+`ntreat')/2
	}
	else {
		loc base = `ntreat'
	}

	if "`interaction'" != "" {
		loc interaction
		foreach var1 of local covariates {
			foreach var2 of local by {
				tempvar temp
				qui gen `temp' = `var1' * `var2'
				loc interaction `interaction' `temp'
			}
		}
	}
	
	*Create binary indicators for each option that will alter the dimension of the matrix to which the results are stored.
	loc count 		= 1 - mi("`count'")
	loc test 		= 1 - mi("`test'")
	loc overall		= 1 - mi("`overall'")
	loc prop    	= 1 - mi("`proportion'")
	loc sterr		= 2 - mi("`semean'")
	loc interact	= 1 - mi("`interaction'")
	loc reverse 	= 1 - mi("`reverse'")
	loc reverseall 	= 1 - mi("`reverseall'")
	loc vcount 		= 1 - mi("`vcount'")

	tempname A
	mat `A' = J(`sterr'*`varcount'+`count'+`prop', `base'+`reverse'+`reverseall'+`overall'+`test'+`vcount', .)
	loc r 0
	foreach var in `varlist' {
		loc ++r
		
		*Basic mean/se
		if 0 {
			qui tabstat `var' , by(`treatment_type') stats(mean sd) save
			forvalues n = 1/`ntreat' {
				mat `A'[`r',`n'] = r(Stat`n')
			}
			if `overall' {
				mat `A'[`r', `ntreat'+1] = r(StatTotal)
			}
		}
		if 1 {
			loc n = 0
			foreach var1 of loc by {
				loc ++n
				qui reg `var' if `var1' == 1, `vce'
				mat `A'[`r', `n'] = _b[_cons]
				if "`semean'" != "" {
					mat `A'[`r'+1, `n'] = _se[_cons]
				}
			}
			if `overall' {
				qui reg `var', `vce'
				mat `A'[`r', `ntreat'+1] = _b[_cons]
				if "`semean'" != "" {
					mat `A'[`r'+1, `ntreat'+1] = _se[_cons]
				}
			}
		}
		
		loc j = `ntreat' + `overall'
		
		*Adding mean/se for treatment arm comparisons
		if "`compare'" != "" | "`pcompare'" != "" {
			forvalues n = 1/`ntreat' {
				gettoken var1 by: by
				foreach var2 of loc by {
					qui reg `var' `var1' `covariates' `interaction' if (`var1'==1 | `var2'==1), `vce'
					loc ++j
					loc b = _b[`var1']
					loc se = _se[`var1']
					loc df = e(df_r)
					if "`pcompare'" != "" {
						mat `A'[`r',`j'] = 2*ttail(`df', abs(`b'/`se'))
					}
					else {
						mat `A'[`r',`j'] = `b'
						if "`semean'" != "" {
							mat `A'[`r'+1,`j'] = `se'
							if "`stars'" != "" {
								if 2*ttail(`df', abs(`b'/`se')) <= 0.01 {
									loc star_`j' "`star_`j''" "***"
								}
								else if 2*ttail(`df', abs(`b'/`se')) <= 0.05 {
									loc star_`j' "`star_`j''" "**"
								}
								else if 2*ttail(`df', abs(`b'/`se')) <= 0.10 {
									loc star_`j' "`star_`j''" "*"
								}
								else {
									loc star_`j' "`star_`j''" " "
								}
							}
						}
					}
				}
			}
		}
		loc by `by2'
		
		*For reverse option
		if `reverse' {
			qui reg `:word 1 of `by'' `var' `covariates' `interaction', noheader `vce'
			mat `A'[`r', `base'+`overall'+`reverse'] = _b[`var']
			if `sterr' == 2 {
				mat `A'[`r'+1, `base'+`overall'+`reverse'] = _se[`var']
				loc b _b[`var']
				loc se _se[`var']
				loc df = e(df_r)
				if "`stars'" != "" {
					if 2*ttail(`df', abs(`b'/`se')) <= 0.01 {
						loc star_`=`base'+`overall'+`reverse'' "`star_`=`base'+`overall'+`reverse'''" "***"
					}
					else if 2*ttail(`df', abs(`b'/`se')) <= 0.05 {
						loc star_`=`base'+`overall'+`reverse'' "`star_`=`base'+`overall'+`reverse'''" "**"
					}
					else if 2*ttail(`df', abs(`b'/`se')) <= 0.10 {
						loc star_`=`base'+`overall'+`reverse'' "`star_`=`base'+`overall'+`reverse'''" "*"
					}
					else {
						loc star_`=`base'+`overall'+`reverse'' "`star_`=`base'+`overall'+`reverse'''" " "
					}
				}
			}
		}
		if `test' | `vcount' {
			qui reg `var' `by' `covariates' `interaction', noheader `vce'
			
			*For adding F-test
			if `test' {
				qui test `by'
				mat `A'[`r', `base'+`overall'+`reverse'+`reverseall'+`test'] = r(p)				
			}
			
			*For adding vertical observation count
			if `vcount' {
				mat `A'[`r', `base'+`overall'+`reverse'+`reverseall'+`test'+`vcount'] = e(N)
			}
		}
		loc r = `r' + (`sterr' - 1)
	}
	
	*For second reverse option
	if `reverseall' {
		loc r 0
		qui reg `:word 1 of `by'' `varlist' `covariates' `interaction', noheader `vce'
		foreach var of local varlist {
			loc ++r
			mat `A'[`r', `base'+`overall'+`reverse'+`reverseall'] = _b[`var']
			if `sterr' == 2 {
				loc ++r
				mat `A'[`r', `base'+`overall'+`reverse'+`reverseall'] = _se[`var']
				loc b _b[`var']
				loc se _se[`var']
				loc df = e(df_r)
				if "`stars'" != "" {
					if 2*ttail(`df', abs(`b'/`se')) <= 0.01 {
						loc star_`=`base'+`overall'+`reverse'+`reverseall'' "`star_`=`base'+`overall'+`reverse'+`reverseall'''" "***"
					}
					else if 2*ttail(`df', abs(`b'/`se')) <= 0.05 {
						loc star_`=`base'+`overall'+`reverse'+`reverseall'' "`star_`=`base'+`overall'+`reverse'+`reverseall'''" "**"
					}
					else if 2*ttail(`df', abs(`b'/`se')) <= 0.10 {
						loc star_`=`base'+`overall'+`reverse'+`reverseall'' "`star_`=`base'+`overall'+`reverse'+`reverseall'''" "*"
					}
					else {
						loc star_`=`base'+`overall'+`reverse'+`reverseall'' "`star_`=`base'+`overall'+`reverse'+`reverseall'''" " "
					}
				}
			}
		}
	}
	
	*For horizontal observation count
	if `count' | `prop' {
		tempvar N
		gen `N' = 1
		qui tabstat `N', by(`treatment_type') stats(n) save
		forvalues n = 1/`ntreat' {
			if `count' {
				mat `A'[`sterr'*`varcount'+`count',`n'] = r(Stat`n')
			}
			if `prop' {
				mat `A'[`sterr'*`varcount'+`count'+`prop',`n'] = r(StatTotal)
				tempname B
				mat `B' = r(Stat`n')
				loc numerator = `B'[1,1]
				mat `A'[`sterr'*`varcount'+`count'+`prop',`n'] = `numerator'/`A'[`sterr'*`varcount'+`count'+`prop',`n']
			}
		}
		if `overall' {
			mat `A'[`sterr'*`varcount'+`count',`ntreat'+1] = r(StatTotal)
			if `prop' {
				mat `A'[`sterr'*`varcount'+`count'+`prop',`ntreat'+1] = 1
			}
		}
		if "`compare'" != "" {
			loc mm = `ntreat' + `overall'
			forvalues n = 1/`ntreat' {
				loc num "`num' `n'"
			}
			forvalues n = 1/`ntreat' {
				gettoken num1 num: num
				foreach num2 of loc num {
					loc ++mm
					mat `A'[`sterr'*`varcount'+`count',`mm'] = `A'[`sterr'*`varcount'+`count',`num1'] + `A'[`sterr'*`varcount'+`count',`num2']
				}
			}
		}
	}
	
	*Constructing locals to extract the table row/column names. 
	if "`nolabel'" == "" {
		if `"`varlabel'"' != "" {
			loc varlist2 `varlist'
			forvalues n = 1/`varcount' {
				gettoken var varlist: varlist
				loc lab`n': word `n' of `varlabel'
				la var `var' "`lab`n''"
			}
		}
		foreach var of loc varlist {
			loc rname: var la `var'
			if "`rname'" == "" {
				loc rname `var'
			}
			if "`semean'"!="" {
				loc rnames "`rnames' "`rname'" " ""
			}
			else {
				loc rnames "`rnames' "`rname'""
			}
		}
		if `count' {
			loc rnames "`rnames' "N""
		}
		if `prop' {
			loc rnames "`rnames' "Proportion""
		}
		if `"`armlabel'"'!=`""' {
			loc ccount: word count `armlabel'
			if `ccount' == `ntreat' {
				loc cnames `"`armlabel'"'
			}
		}
		else if "`numlabel'" != "" {
			forvalues n = 1/`ntreat' {
				loc cnames "`cnames' (`n')"
			}
		}
		else if `backwards' {
			foreach var of loc by {
				loc cname: var lab `var'
				if "`cname'" == "" {
					loc cname "`var'"
				}
				loc cnames "`cnames' "`cname'""
			}
		}
		forvalues n = 1/`ntreat' {
			loc num "`num' `n'"
		}
		if `overall' {
			loc cnames "`cnames' "Overall""
		}
		if "`compare'" != "" | "`pcompare'" != "" {
			forvalues n = 1/`ntreat' {
				gettoken num1 num: num
				foreach num2 of loc num {
					if "`compare'" != "" {
						loc cnames2 "`cnames2' "(`num1') vs. (`num2')""
					}
					else {
						loc cnames2 "`cnames2' "(`num1') vs. (`num2'), p-value""
					}
				}
			}
		}
		loc cnames "`cnames' `cnames2'"
		if `reverse' {
			if `sterr' == 2 {
				if "`latex'" != "" {
					loc standard "s. \& s.e."
				}
				else {
					loc standard "s. & s.e."
				}
			}
			else {
				loc standard "icients"
			}
			loc cnames "`cnames' "Coeff`standard', treatment as dep. variable""
		}
		if `reverseall' {
			if `sterr' == 2 {
				if "`latex'" != "" {
					loc standard "s. \& s.e."
				}
				else {
					loc standard "s. & s.e."
				}
			}
			else {
				loc standard "icients"
			}
			loc cnames "`cnames' "Coeff`standard', treatment as dep. variable, all balance variables together""
		}
		if `test' {
			loc cnames "`cnames' "p-value from joint orthogonality test of treatment arms""
		}
		if `vcount' {
			if `test' {
				loc cnames "`cnames' "N from orthogonality test""
			}
			else {
				loc cnames "`cnames' "N""
			}
		}
	}
	else {
		loc rnames ""
		loc cnames ""
	}
	if "`colnum'" != "" {
		loc column ""
		loc p = `base'+`reverse'+`overall'+`reverseall'+`test'+`vcount'
		forvalues n = 1/`p' {
			loc column "`column' "(`n')""
		}
	}
	if `"`title'"' == `""' {
		loc title "Orthogonality Table"
	}
	forvalues n = 1/`varcount' {
		loc req "`req' mean"
		if `sterr' == 2 {
			loc req "`req' se"
		}
	}
	if `count' {
		loc req "`req' _"
	}
	if `prop' {
		loc req "`req' _"
	}
	if "`bdec'"=="" {
		loc bdec = 3
	}
	
	*Exporting
	if `"`using'"' != "" {
		if "`latex'"  == "" {
			*Excel exporting option
			clear
			qui svmat `A'
			tempvar _n
			qui tostring _all, replace force format(%12.`bdec'f)
			*Get rid of negative zeros
			foreach var of varlist _all {
				qui replace `var' = substr(`var', 2, .) if real(`var') == 0 & substr(`var', 1, 1) == "-"
			}
			gen `_n' = _n + 2
			tempvar B0
			qui gen `B0' = ""
			if `sterr' == 2 {
			
				*Adding parentheses to standard errors
				foreach var of varlist `A'* {
					if `prop' {
						loc stipulation & _n != _N
					}
					qui replace `var' = "(" + `var' + ")" if `var' != "." & mod(`_n', 2) == 0 `stipulation'
				}
				
				*Attaching significance level stars
				if "`compare'" != "" & "`stars'" != "" {
					qui su `_n'
					forvalues j = 1/`=(`ntreat'^2-`ntreat')/2' {
						forvalues p = `r(min)'/`r(max)' {
							if mod(`p', 2) == 0 {
								qui replace `A'`=`j'+`ntreat'+`overall'' = `A'`=`j'+`ntreat'+`overall'' + "`:word `=`p'/2' of "`star_`=`j'+`ntreat'+`overall'''"'" ///
									if `_n' == `p' - 1
							}
						}
					}
				}
				if `reverse' & "`stars'" != "" {
					qui su `_n'
					forvalues p = `r(min)'/`r(max)' {
						if mod(`p', 2) == 0 {
							qui replace `A'`=`base'+`overall'+`reverse'' = `A'`=`base'+`overall'+`reverse'' + "`:word `=`p'/2' of "`star_`=`base'+`overall'+`reverse'''"'" ///
								if `_n' == `p' - 1
						}
					}
				}
				if `reverseall' & "`stars'" != "" {
					qui su `_n'
					forvalues p = `r(min)'/`r(max)' {
						if mod(`p', 2) == 0 {
							qui replace `A'`=`base'+`overall'+`reverse'+`reverseall'' = `A'`=`base'+`overall'+`reverse'+`reverseall'' + "`:word `=`p'/2' of "`star_`=`base'+`overall'+`reverse'+`reverseall'''"'" ///
								if `_n' == `p' - 1
						}
					}
				}
			}
			if `vcount' {
				qui replace `A'`=`base'+`overall'+`reverse'+`reverseall'+`test'+`vcount'' = string(real(`A'`=`base'+`overall'+`reverse'+`reverseall'+`test'+`vcount''))
			}
			
			*Attaching row/column names
			loc p = 2
			foreach name in `rnames' {
				loc ++p
				qui replace `B0' = "`name'" if `_n' == `p' & "`name'" != "_"
			}
			qui d, s
			loc N = `r(N)' + 1
			qui set obs `N'
			qui replace `_n' = 1 if `_n' == .
			sort `_n'

			forvalues i = 1/`:word count `cnames'' {
				qui replace `A'`i' = "`:word `i' of `cnames''" if `_n' == 1
			}
			if "`colnum'" != "" {
				loc N = `N' + 1
				qui set obs `N'
				qui replace `_n' = 2 if `_n' == .
				sort `_n'
				forvalues i = 1/`:word count `column'' {
					qui replace `A'`i' = "`:word `i' of `column''" if `_n' == 2
				}
			}
			if `"`title'"' != `""' {
				loc N = `N' + 1
				qui set obs `N'
				qui replace `_n' = 0 if `_n' == .
				sort `_n'
				qui replace `B0' = `"`title'"' if `_n' == 0
			}
			if `"`notes'"' != `""' {
				loc N = `N' + 1
				qui set obs `N'
				sort `_n'
				qui replace `B0' = `"`notes'"' if mi(`_n')
			}
			loc note = 1 - mi("`notes'")
			foreach var of varlist `A'* {
				if `count' {
					loc normal = `bdec' != 0
					qui replace `var' = string(real(`var')) if `B0' == "N" & "`var'" != "`B0'"
				}
			}
			qui ds, has(type string)
			foreach var of varlist `r(varlist)' {
				qui replace `var' = "" if `var' == "."
			}
			order `B0', first
			drop `_n'
			
			*Appending 
			if "`vappend'" != "" {
				qui ds
				if `:word count `r(varlist)'' > 26 {
					di as err "yo gurrrl u has 2 many treatments. pls re-evaluate yo lyfe decisions. kthx"
					error 197
				}
				forvalues q = 1/`:word count `r(varlist)'' {
					rename `:word `q' of `r(varlist)'' `:word `q' of `c(ALPHA)''
				}
				tempfile temp
				qui save `temp'
				import excel `using', clear sheet("`sheet'")
				append using `temp'
				di "table appended to `:word 2 of `using''"
				loc replace replace
			}
			if "`dta'" == "" {
				if "`happend'" != "" {
					tempvar _n
					gen `_n' = _n
					tempfile temp
					qui save `temp', replace
					import excel `using', clear sheet("`sheet'")
					gen `_n' = _n
					qui merge 1:1 `_n' using `temp', nogen
					drop `_n'
					di "table appended to `:word 2 of `using''"
					*loc replace replace
				}
				export excel _all `using', `replace' sheet("`sheet'") `sheetmodify' `sheetreplace'
			}
			* dta option starts here
			else if "`dta'" != "" {
				if "`happend'" != "" {
					tempvar _n
					gen `_n' = _n
					tempfile temp
					qui save `temp', replace
					u `using', clear
					qui ds
					loc varlist `r(varlist)'
					loc allalpha "`c(ALPHA)'"
					loc remalpha: list allalpha - varlist
					gen `_n' = _n
					qui merge 1:1 `_n' using `temp', nogen
					drop `_n'
					loc x 0
					foreach var of varlist _* {
						loc x = `x' + 1
						qui ren `var' `:word `x' of `remalpha''
					}
					di "table appended to `:word 2 of `using''"
					loc replace replace
				}
				else {
					loc firstalpha "`c(ALPHA)'"
					loc y 0
					foreach var of varlist _* {
						loc y = `y' + 1
						ren `var' `:word `y' of `firstalpha''
					}
				}
				loc dtafilename = subinstr(`"`using'"', "using ", "", 1)
				if "`replace'" == "replace" ///
					loc replacecondition 1
				else loc replacecondition 0
				save `dtafilename' `=cond(`replacecondition', ",", "")' `replace'
			}		
		}
		
		if "`latex'" != "" & "`dta'" == "" {
			*Latex export option
			cap file close handle
			file open handle `using', write replace
			if "`full'" != "" {
				file w handle `"\centering\caption {`title'}"' _n
				file w handle "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
				file w handle "\begin{tabular}{p{2.5cm}*{`=colsof(`A')'}{c}}" _n
				file w handle "\hline\hline" _n
			}
			forvalues m = 1/`=colsof(`A')' {
				file w handle "&\multicolumn{1}{c}{(`m')}"
			}
			file w handle "\\" _n
			loc extra = 0
			forvalues m = 1/`=colsof(`A')' {
				if length("`:word `m' of `cnames''") > 11 {
					if "`full" != "" {
						loc ++extra
						file w handle "&\multicolumn{1}{p{2.75cm}}{\centering `:word `m' of `cnames''}"
					}
				}
				else if "`:word `m' of `cnames''" != "N" {
					file w handle "&\multicolumn{1}{c}{`:word `m' of `cnames''}"
				}
				else {
					file w handle "&\multicolumn{1}{c}{\(N\)}"
				}
			}
			file w handle "\\" _n "\hline" _n

			forvalues n = 1/`=rowsof(`A')' {
				loc row`n' ""
				forvalues m = 1/`=colsof(`A')' {
					if "`=string(`A'[`n', `m'], "%9.`bdec'f")'" != "." {
						if "`:word `n' of `rnames''" != " "{
							if "`:word `n' of `rnames''" != "N" & !inlist("`:word `m' of `cnames''", "N", "N from orthogonality test"){
								loc row`n' "`row`n'' & `=string(`A'[`n', `m'], "%9.`bdec'f")'`:word `=`n'' of `star_`=`m''''"
							}
							else {
								loc row`n' "`row`n'' & `=string(`A'[`n', `m'], "%9.0f")'"
							}
						}
						else {
							loc row`n' "`row`n'' & (`=string(`A'[`n', `m'], "%9.`bdec'f")')" 
						}
					}
				}
				if "`:word `n' of `rnames''" != "N" {
					file write handle "`:word `n' of `rnames'' `row`n'' \\" 
				}
				else {
					file write handle "\hline" _n "\(N\) `row`n'' \\" 
				}
			}
			if "`full'" != "" {
				if "`notes'" == "" {
					if `sterr' == 2{
						loc stparen Standard errors in parentheses.
					}
					if "`stars'" != ""{
						loc starkey \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)
					}
					loc notes `stparen' `starkey'
				}
				file w handle _n "\hline" _n "\multicolumn{`=colsof(`A')+1'}{p{`=2*(1+colsof(`A'))+`extra'*0.75+0.5'cm}}{\footnotesize `notes' }\\" _n "\end{tabular}"
			}
			file close handle
		}
	}
	if `"`column'"' == "" {	
		forvalues n = 1/`=`base'+`reverse'+`overall'+`test'' {
			loc column "`column' _"
		}
	}
	*Row/column displays for in-STATA display
	mat rown   `A' = `req'
	mat coln   `A' = `column'
	mat roweq  `A' = `rnames'
	mat coleq  `A' = `cnames'
	mat li `A', noheader format(%12.`bdec'f)
	
	*Stored values
	return loc rnames `rnames'
	return loc cnames `cnames'
	return loc title  `title'
	return matrix matrix `A'
end
