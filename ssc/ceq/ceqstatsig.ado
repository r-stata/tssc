** ADO FILE FOR POPULATION SHEET OF CEQ OUTPUT TABLES

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.5 02jun2017 For use with July 2017 version of CEQ Master Workbook
** v1.4 12jan2017 For use with Oct 2016 version of CEQ Master Workbook
** v1.3 24dec2016 For use with Oct 2016 version of CEQ Master Workbook
** v1.2 30sep2016 For use with Jul 2016 version of CEQ Master Workbook
** v1.1 25aug2016 For use with Jul 2016 version of CEQ Master Workbook
** v1.0 02jul2016 For use with Jul 2016 version of CEQ Master Workbook
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   06-01-2017 Add additional options to print meta-information
** 	 01-12-2017 Set the data type of all newly generated variables to be double
** 				Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**   12-24-2016 Change the looping letter from w to r to avoid repetition of weight variable local
**	 10-01-2016 Print warning messages to MWB sheets
**				Change from d1 command to `command' command in warning 
**			    Changed warning contents and add exit when ppp option is not specified 
**				Move up preserve and modify section to avoid issuing a wrong warning for negatives
**    8-25-2016 Change sort to sort, stable and gen to gen double to ensure precision
**				Change the way of checking excel extension so it works with files with "." in the 
**				 the file names
** NOTES

** TO DO

*************************
** PRELIMINARY PROGRAMS *
*************************
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol

// BEGIN diff_and_pvalue
//  Command that produces differences and pvalues of a statistical significance test
//   of H0: difference = 0. Commands from DASP (Araar and Duclos) that perform the
//   statistical test will be used.
cap program drop diff_and_pvalue
program define diff_and_pvalue
	#delimit ;
	syntax varlist(min=2 max=2) ,
		diffs(string) 
		pvals(string)
		command(string) 
		row(real) 
		col(real)
		[ cmdoptions(string) ]
	;
	#delimit cr
	confirm matrix `diffs'
	confirm matrix `pvals'
	qui `command' `varlist', `cmdoptions' // uses svyset info that was implemented above
		// (note: don't use hsize() option since that has already been incorporated
		//  into the weights for each unit in this household-collapsed data set)
	tempname e_di _p
	matrix `e_di' = e(di)
	matrix `diffs'[`row',`col'] = `e_di'[1,1]
	scalar `_p' = e(p)
	if `_p'<1e-9 scalar `_p' = 0 // to avoid really small numbers in scientific notation
	matrix `pvals'[`row',`col'] = `_p'
end // END diff_and_pvalue

***********************
** ceqstatsig PROGRAM *
***********************
** For sheet E7. Statistical Significance
// BEGIN ceqstatsig (Higgins 2016)
capture program drop ceqstatsig
program define ceqstatsig, rclass 
	version 13.0
	#delimit ;
	syntax 
		[using/]
		[if] [in] [pweight/] 
		[, 
			/* INCOME CONCEPTS: */
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			/* PPP CONVERSION */
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			/* SURVEY INFORMATION */
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname)
			/* POVERTY LINES */
			PL1(real 1.25)
			PL2(real 2.50)
			PL3(real 4.00)
			NATIONALExtremepl(string)   
			NATIONALModeratepl(string)  
			OTHERExtremepl(string)      
			OTHERModeratepl(string)
			PROPortion(real 0.5)
			/* EXPORTING TO CEQ MASTER WORKBOOK: */
			sheet(string)
			OPEN
			/* INFORMATION CELLS */
			COUNtry(string)
			SURVeyyear(string) /* string because could be range of years */
			AUTHors(string)
			BASEyear(real -1)
			SCENario(string)
			GROUp(string)
			PROJect(string)
			/* OTHER OPTIONS */
			NOGini
			NOAbsgini
			NOTheil
			NO9010
			NOConc
			/* DROP MISSING VALUES */
			IGNOREMissing
		]
	;
	#delimit cr
	
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqstatsig
	local version 1.5
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org)"
	
	** income concepts
	local m `market'
	local mp `mpluspensions'
	local n `netmarket'
	local g `gross'
	local t `taxable'
	local d `disposable'
	local c `consumable'
	local f `final'
	local alllist m mp n g t d c f
	local cols = wordcount("`alllist'")
	local origlist m mp n g d
	tokenize `alllist' // so `1' contains m; to get the variable you have to do ``1''
	local varlist ""
	local counter = 1
	foreach y of local alllist {
		local varlist `varlist' ``y'' // so varlist has the variable names
		// reverse tokenize:
		local _`y' = `counter' // so _m = 1, _mp = 2 (regardless of whether these options included)
		local ++counter
	}
	scalar _d_m      = "Market Income"
	scalar _d_mp     = "Market Income + Pensions"
	scalar _d_n      = "Net Market Income"
	scalar _d_g      = "Gross Income"
	scalar _d_t      = "Taxable Income"
	scalar _d_d      = "Disposable Income"
	scalar _d_c      = "Consumable Income"
	scalar _d_f      = "Final Income"
	
	** poverty lines
	local povlines `pl1' `pl2' `pl3' `nationalextremepl' `nationalmoderatepl' `otherextremepl' `othermoderatepl'
	local plopts pl1 pl2 pl3 nationalextremepl nationalmoderatepl otherextremepl othermoderatepl
	foreach p of local plopts {
		if "``p''"!="" {
			cap confirm number ``p'' // `p' is the option name eg pl125 so ``p'' is what the user supplied in the option
			if !_rc scalar _`p'_isscalar = 1 // !_rc = ``p'' is a number
			else { // if _rc, i.e. ``p'' not number
				cap confirm numeric variable ``p''
				if _rc {
					`die' "Option " in smcl "{opt `p'}" as error " must be specified as a scalar or existing variable."
					exit 198
				}
				else scalar _`p'_isscalar = 0 // else = if ``p'' is numeric variable
			}
		}
	}
	scalar _relativepl_isscalar = 1 // `relativepl' created later
	if !(`proportion'>0 & `proportion'<1) {
		`die' "{bf:proportion} (relative poverty line's proportion of median income) must be between 0 and 1"
		exit 198
	}
	
	** results
	#delimit ;
	local matrices 
		gini
		absgini
 		theil
		ninetyten
	;
	#delimit cr
	forval i=0/2 { // FGT(0), FGT(1), FGT(2)
		forval pp=1/3 { // three international poverty lines
			local matrices `matrices' p`i'_pl`pp'
		}
 		local matrices `matrices' p`i'_nationalextremepl
		local matrices `matrices' p`i'_nationalmoderatepl
		local matrices `matrices' p`i'_otherextremepl     
		local matrices `matrices' p`i'_othermoderatepl
		local matrices `matrices' p`i'_relativepl
	}
	foreach v of local alllist {
		local matrices `matrices' conc`v'
	}	
	
	** print warning messages 
	local warning "Warnings"
	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** make sure all newly generated variables are in double format
	/*set type double */
	
	******************
	** PARSE OPTIONS *
	******************
	** Check if all income and fisc variables are in double format
	local inctypewarn
	foreach var of local varlist {
		if "`var'"!="" {
			local vartype: type `var'
			if "`vartype'"!="double" {
				if wordcount("`inctypewarn'")>0 local inctypewarn `inctypewarn', `var'
				else local inctypewarn `var'
			}
		}
	}
	if wordcount("`inctypewarn'")>0 `dit' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	if wordcount("`inctypewarn'")>0 local warning `warning' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	
	** ado file specific
	if "`sheet'"=="" local sheet "E7. Statistical Significance" // default name of sheet in Excel files
	
	** weight (if they specified hhsize*hhweight type of thing)
	if strpos("`exp'","*")> 0 { // TBD: what if they premultiplied w by hsize?
		`die' "Please use the household weight in {weight}; this will automatically be multiplied by the size of household given by {bf:hsize}"
		exit
	}
	
	** ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Option {bf:ppp} required."
		exit 198
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local warning `warning' "Warning: daily, monthly, or yearly options not specified; variables assumed to be in yearly local currency units."
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	
	** NO... options
	if wordcount("`nodecile' `nogroup' `nocentile' `nobin'")==4 {
		`die' "All options {bf:nodecile}, {bf:nogroup}, {bf:nocentile}, {bf:nobin} specified; no results to produce"
		exit 198
	}
	if "`nodecile'"=="" local _dec dec
	if "`nogroup'"=="" local _group group
	if "`nocentile'"=="" local _cent cent
	if "`nobin'"=="" local _bin bin
	
	** make sure using is xls or xlsx
	cap putexcel clear
	if `"`using'"'!="" {
		qui di " // for Notepad++ syntax highlighting
		if !strpos(`"`using'"' /* " */ , ".xls") {
			`die' "File extension must be .xls or .xlsx to write to an existing CEQ Master Workbook (requires Stata 13 or newer)"
			exit 198
		}
		confirm file `"`using'"'
		qui di "
	}
	else { // if "`using'"==""
		`dit' "Warning: No file specified with {bf:using}; results saved in {bf:return list} but not exported to Output Tables"
	}
	if strpos(`"`using'"'," ")>0 & "`open'"!="" { // has spaces in filename
		qui di "
		`dit' `"Warning: `"`using'"' contains spaces; {bf:open} option will not be executed. File can be opened manually after `command' runs."'
		local open "" // so that it won't try to open below
	}	

	** negative incomes
	foreach v of local alllist {
		if "``v''"!="" {
			qui count if ``v''<0 // note `v' is e.g. m, ``v'' is varname
			if r(N) `dit' "Warning: `r(N)' negative values of ``v''"
			if r(N) local warning `warning' "Warning: `r(N)' negative values of ``v''"
		}
	}	

	** hsize and hhid
	if wordcount("`hsize' `hhid'")!=1 {
		`die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or "
		`die' "{bf:hhid} (unique household identifier for individual-level data)"
		exit 198
	}

	************************
	** PRESERVE AND MODIFY *
	************************
	
	** collapse to hh-level data
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid', stable
		qui bys `hhid': gen `members' = _N // # members in hh 
		qui bys `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	***********************
	** SVYSET AND WEIGHTS *
	***********************
	cap svydes
	scalar no_svydes = _rc
	if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
		local warning `warning' "Warning: weights not specified in svydes or the command. Hence, equal weights (simple random sample) assumed."
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen double `weightvar' = `w'*`hsize'
			local w `weightvar'
		}
		else local w "`hsize'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}
	else if "`r(su1)'"=="" & "`psu'"=="" {
		di as text "Warning: primary sampling unit not specified in svydes or the `command' command's psu() option"
		di as text "P-values will be incorrect if sample was stratified"
		local warning `warning' "Warning: primary sampling unit not specified in svydes or the `command' command's psu() option. P-values will be incorrect if sample was stratified."
	}
	if "`psu'"=="" & "`r(su1)'"!="" {
		local psu `r(su1)'
	}
	if "`strata'"=="" & "`r(strata1)'"!="" {
		local strata `r(strata1)'
	}
	if "`strata'"!="" {
		local opt strata(`strata')
	}
	** now set it:
	if "`exp'"!="" qui svyset `psu' `pw', `opt'
	else           qui svyset `psu', `opt'
	
	**************************
	** VARIABLE MODIFICATION *
	**************************

	foreach pl of local plopts {
		if "``pl''"!="" {
			if _`pl'_isscalar == 0 {
				local pl_tokeep `pl_tokeep' ``pl''
			}
		}
	}
	
	** keep the variables used in the ado file only  
	#delimit ;
	local relevar `varlist' `allprogs'      
				  `w' `psu' `strata' `exp'		
				  `pl_tokeep'
	;
	#delimit cr
	quietly keep `relevar' 
	
	** missing income concepts
	foreach var of local varlist {
		qui count if missing(`var')  
		if "`ignoremissing'"=="" {
			if r(N) {
				`die' "Missing values not allowed; `r(N)' missing values of `var' found" 
				exit 198
			}
		}
		else {
			if r(N) {
				qui drop if missing(`var')
				`dit' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
				local warning `warning' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified the ignoremissing option."
			}
		}
    }
	
	** PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}
	}	
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	**********************
	** CALCULATE RESULTS *
	**********************
	foreach mat of local matrices {
		tempname `mat'_diffs `mat'_pvals // temporary matrices
		matrix ``mat'_diffs' = J(`cols',`cols',.) // square matrix for point estimate of difference 
			// in Ginis for pairs of core income concepts
		matrix ``mat'_pvals' = J(`cols',`cols',.) // statistical significance of above difference in Ginis
	}
	local col = 0
	foreach v of local alllist {
		local row = 0
		local ++col
		if "``v''"=="" continue // income concept option not included by user
		foreach r of local alllist {
			local ++row
			if `row'<=`col' continue // blacked out part of matrix (since symmetric, 
				// and no comparison between income concept and itself)
			if "``r''"=="" continue // income concept option not included by user

			#delimit ;
			/* GINI */
			local mat gini ;
			diff_and_pvalue ``v'' ``r'' , 
				command(ceqdigini) 
				diffs(``mat'_diffs') pvals(``mat'_pvals')    
				row(`row') col(`col')
			;
			
			/* ABSOLUTE GINI */
			local mat absgini ;
			diff_and_pvalue ``v'' ``r'' , 
				command(ceqdigini) cmdoptions(type(abs)) 
				diffs(``mat'_diffs') pvals(``mat'_pvals')    
				row(`row') col(`col')
			;

			/* THEIL */
			local mat theil ;
			diff_and_pvalue ``v'' ``r'' , 
				command(ceqdientropy) cmdoptions(theta(1)) 
				diffs(``mat'_diffs') pvals(``mat'_pvals')    
				row(`row') col(`col')
			;
			
			/* 90/10 */
			local mat ninetyten ;
			diff_and_pvalue ``v'' ``r'' , 
				command(ceqdinineq) cmdoptions(p1(0.90) p2(0.10)) 
				diffs(``mat'_diffs') pvals(``mat'_pvals')    
				row(`row') col(`col')
			;
			
			#delimit cr
			
			/* POVERTY: INTERNATIONAL POVERTY LINES */
			if wordcount("`povlines'")>0 { // otherwise produces inequality only
				forval pp=1/3 { 
					forval i=0/2 { // values of alpha
						local mat p`i'_pl`pp' 
						#delimit ;
						diff_and_pvalue ``v'_ppp' ``r'_ppp' , 
							command(ceqdifgt) 
							cmdoptions(alpha(`i') pline1(`pl`pp'') pline2(`pl`pp''))
							diffs(``mat'_diffs') pvals(``mat'_pvals')  
							row(`row') col(`col')
						;
						#delimit cr
					}
				} 
				
				/* POVERTY: NATIONAL POVERTY LINES */
				foreach p in `plopts' { // plopts includes all lines
					if "``p''"=="" continue	
					if substr("`p'",1,2)=="pl" continue // these are the PPP lines, done above
					if _`p'_isscalar==1 {   // if pov line is scalar, // (note this local defined above)
						local _pline = ``p'' // set `_pline' as that scalar and
						foreach x in v r {
							local `x'touse ```x'''   // use original income variable
						}
					}
					else if _`p'_isscalar==0 { // if pov line is variable,
						foreach x in v r {
							tempvar ``x''_normalized  // create temporary variable that is income...
							qui gen ```x''_normalized' = ```x'''/``p'' // normalized by pov line
							local `x'touse ```x''_normalized' // use normalized income in the calculations
						}
						local _pline = 1 // and normalized pov line is 1
					}
					forval i=0/2 { // values of alpha
						local mat p`i'_`p'
						#delimit ;
						diff_and_pvalue `vtouse' `rtouse' , 
							command(ceqdifgt) 
							cmdoptions(alpha(`i') pline1(`_pline') pline2(`_pline'))
							diffs(``mat'_diffs') pvals(``mat'_pvals')  
							row(`row') col(`col')
						;
						#delimit cr
					}
				}
			}
			
			/* POVERTY: RELATIVE POVERTY LINES */
			foreach x in v r {
				qui summ ```x''' `aw', d
				local rel_pl_`x' = `proportion'*r(p50) // half of median income
				tempvar ``x''_normalized
				qui gen ```x''_normalized' = ```x'''/`rel_pl_`x''
				local `x'touse ```x''_normalized'
			}
			local _pline = 1 // normalized poverty line
			forval i=0/2 { // values of alpha
				local mat p`i'_relativepl
				#delimit ;
				diff_and_pvalue `vtouse' `rtouse',
					command(ceqdifgt)
					cmdoptions(alpha(`i') pline1(`_pline') pline2(`_pline'))
					diffs(``mat'_diffs') pvals(``mat'_pvals')  
					row(`row') col(`col')
				;
				#delimit cr
			}
			
			/* CONCENTRATION COEFFICIENTS */
			foreach rankby of local alllist {
				if "``rankby''"=="" continue
				#delimit ;
				local mat conc`rankby' ;
				diff_and_pvalue ``v'' ``r'' , 
					command(ceqdigini) 
					cmdoptions(rank1(``rankby'') rank2(``rankby''))
					diffs(``mat'_diffs') pvals(``mat'_pvals')    
					row(`row') col(`col')
				;
				#delimit cr
			}
			
		} // foreach r of local alllist (loop through second income var)
	} // foreach v of local alllist (loop through first income var)
	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" /* " */ { 
		`dit' `"Writing to "`using'"; may take several minutes"'
		local startcol_o = 3 // this one will stay fixed (column C)
		local startrow_o = 10

		// Print information
		local date `c(current_date)'		
		local titlesprint
		local titlerow = 3
		local titlecol = 1
		local titlelist country surveyyear authors date ppp baseyear cpibase cpisurvey ppp_calculated ///
				scenario group project
		foreach title of local titlelist {
			returncol `titlecol'
			if "``title''"!="" & "``title''"!="-1" ///
				local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''")
			local titlecol = `titlecol' + 1
		}

		// Print version number on Excel sheet
		local versionprint A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'")
				
		// Export to Excel (matrices)
		local vertincrement = 13
		local horzincrement = `cols' + 2
		local resultset ""
		local startrow = `startrow_o'
		foreach mat of local matrices {
			foreach x in diffs pvals {
				if "`x'"=="diffs" local startcol = `startcol_o'
				else if "`x'"=="pvals" local startcol = `startcol_o' + `horzincrement'
				// Loop through elements of matrix and add each one to `resultset' individually
				//  (have to do this to keep the blacked-out cells' formatting)
				forval ro=1/`=rowsof(``mat'_`x'')' { 
					forval co=1/`=colsof(``mat'_`x'')' {
						local therow = `startrow' + `ro' - 1
						local thecol = `startcol' + `co' - 1 
						returncol `thecol'
						tempname mytemp
						if !missing(``mat'_`x''[`ro',`co']) {
							scalar `mytemp' = ``mat'_`x''[`ro',`co']
							local resultset `resultset' `r(col)'`therow'=(`mytemp')
						}
						else local resultset `resultset' `r(col)'`therow'= (.)
					}
				}
			}
			local startrow = `startrow' + `vertincrement'
		}
		
		// Print warning message on Excel sheet 
		local warningrow = 474
		local warningcount = -1
		foreach x of local warning {
			local warningprint `warningprint' A`warningrow'=("`x'")
			local ++warningrow
			local ++warningcount
		}
		// overwrite the obsolete warning messages if there are any
		forval i=0/100 {
			local warningprint `warningprint' A`=`warningrow'+`i''=("")
		}
		// count warning messages and print at the top of MWB
		local warningprint `warningprint' I4=("`warningcount' important warning messages are printed starting on row 473.")     // I4 since A5 has contents

		// putexcel
		qui putexcel `titlesprint' `versionprint' `resultset' `warningprint' using `"`using'"', modify keepcellformat sheet("`sheet'") // "
	}
	
    *********
    ** OPEN *
    *********
    if "`open'"!="" & "`c(os)'"=="Windows" {
         shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
    }
    else if "`open'"!="" & "`c(os)'"=="MacOSX" {
         shell open `using'
    }
    else if "`open'"!="" & "`c(os)'"=="Unix" {
         shell xdg-open `using'
    }

	
	*************
	** CLEAN UP *
	*************
	quietly putexcel clear
	restore // note this also restores svyset
	
end	// END ceqstatsig
