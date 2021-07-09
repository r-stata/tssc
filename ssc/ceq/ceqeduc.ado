** ADO FILE FOR POPULATION SHEET OF CEQ Master Workbook Section E

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.4 01jun17 For use with July 2017 version of CEQ Master Workbook Section E
** v1.3 27mar17 For use with Oct 2016 version of CEQ Master Workbook Section E
** v1.2 12jan17 For use with Oct 2016 version of CEQ Master Workbook Section E
** v1.1 01dec16 For use with Oct 2016 version of CEQ Master Workbook Section E
** v1.0 29sep16 For use with Sep 2016 version of CEQ Master Workbook Section E
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**  06-01-2017  Add additional options to print meta-information
**  03-27-2017  Adjust started row of warning messages (bug pointed out by Sandra Martinez)
** 	01-12-2017  Set the data type of all newly generated variables to be double
** 			    Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**	12-01-2016  Fixed bug with estimates on Target attending public/private (bug pointed out by Maynor Cabrera)
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

**********************
** ceqeduc PROGRAM *
**********************
** For sheet E20. Edu Enrollment Rates
// BEGIN ceqeduc (Higgins 2015)
capture program drop ceqeduc
program define ceqeduc, rclass 
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
			PSU(varname) 
			Strata(varname)
			/* EDUCATION DUMMIES */
			PREschool(varname)
			PRImary(varname)
			SECondary(varname)
			TERtiary(varname)
			PRESCHOOLAGE(varname)
			PRIMARYAGE(varname)
			SECONDARYAGE(varname)
			TERTIARYAGE(varname)
			PUBlic(varname)
			/* EXPORTING TO CEQ MASTER WORKBOOK: */
			sheet(string)
			OPEN
			/* GROUP CUTOFFS */
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)
			/* INFORMATION CELLS */
			COUNtry(string)
			SURVeyyear(string) /* string because could be range of years */
			AUTHors(string)
			BASEyear(real -1)
			SCENario(string)
			GROUp(string)
			PROJect(string)
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
	local command ceqeduc
	local version 1.4
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org)"
	
	** education levels 
	local educ_levels preschool primary secondary tertiary
	local age_levels preschoolage primaryage secondaryage tertiaryage
	local educ_vars `preschool' `primary' `secondary' `tertiary'
	local age_vars `preschoolage' `primaryage' `secondaryage' `tertiaryage'
	
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
	
	** results
	local supercols totLCU totPPP pcLCU pcPPP shares cumshare
	foreach v of local origlist {
		local supercols `supercols' fi_`v' // even if ``v''=="", to add space
	}
	
	** print warning messages 
	local warning "Warnings"
	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'

	** make sure all newly generated variables are in double format
	set type double 
	
	******************
	** PARSE OPTIONS *
	******************
	** Check if all income variables are in double format
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
	
	** education variables
	foreach var in `educ_levels' `age_levels' {
		cap assert ``var''==0 | ``var''==1
		if _rc {
			`die' "{bf:`var'} option should contain a dummy variable equal to 0 or 1 for all observations"
			exit
		}	
	}
	cap assert `public'==0 | `public'==1 | `public'==.
	if _rc {
		`die' "{bf:public} option should contain a dummy variable equal to 0 or 1 for all observations"
		exit
	}
	qui count if `public'==.
	if r(N)==0 {
		`dit' "Warning: {bf:public} should be missing for those who do not attend school"
		local warning `warning' "Warning: public should be missing for those who do not attend school"
	}
	
	** ado file specific
	if "`sheet'"=="" local sheet "E20. Edu Enrollment Rates" // default name of sheet in Excel files
	
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
	
	** group cut-offs
	local cut0 = 0
	local cut6 = . // +infinity
	cap assert `cut0'<`cut1'<`cut2'<`cut3'<`cut4'<`cut5'<`cut6'
	if _rc {
		`die' "Group cut-off options must be specified such that 0<{bf:cut1}<{bf:cut2}<{bf:cut3}<{bf:cut4}<{bf:cut5}"
		exit 198
	}
	// titles of groups
	local g1  "y < `cut1'"
	local g2  "`cut1' < y < `cut2'"
	local g3  "y < `cut2'"
	local g4  "`cut2' < y < `cut3'"
	local g5  "y < `cut3'"
	local g6  "`cut3' < y < `cut4'"
	local g7  "`cut4' < y < `cut5'"
	local g8  "y > `cut5'"
	local g9  "y > `cut4'"
	local g10 "y > `cut3'"
	
	** NO... options
	if wordcount("`nodecile' `nogroup' `nocentile' `nobin'")==4 {
		`die' "All options {bf:nodecile}, {bf:nogroup}, {bf:nocentile}, {bf:nobin} specified; no results to produce"
		exit 198
	}
	if "`nodecile'"=="" local _dec dec
	if "`nogroup'"=="" local _group2 group2
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
		`dit' "Warning: No file specified with {bf:using}; results saved in {bf:return list} but not exported to CEQ Master Workbook Section E"
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
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}
	/* 	else if "`r(su1)'"=="" & "`psu'"=="" {
		di as text "Warning: primary sampling unit not specified in svydes or the `command' command's psu() option"
		di as text "P-values will be incorrect if sample was stratified"
		local warning `warning' "Warning: primary sampling unit not specified in svydes or the `command' command's psu() option. P-values will be incorrect if sample was stratified."
	} */
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

	** keep the variables used in ceqdes   
	#delimit ;
	local relevar `varlist' `allprogs'      
				  `w' `psu' `strata' `exp'		
				  `educ_vars' `age_vars' `public'
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
	
	***************************************************
	** INCOME GROUPS AND BINS, DECILES, AND QUANTILES *
	***************************************************
	foreach v of local alllist {
		if "``v''"!="" {
			** groups
			if `_ppp' {
				*tempvar `v'_group2
				qui gen `v'_group2 = . 
				forval gp=1/6 {
					qui replace `v'_group2 = `gp' if ``v'_ppp'>=`cut`=`gp'-1'' & ``v'_ppp'<`cut`gp''
					// this works because I set `cut0' = 0 and `cut6' = infinity
				}
				qui replace `v'_group2 = 1 if ``v'_ppp' < 0
			}
		}
	}
	local group2 = 6

	**********************
	** CALCULATE RESULTS *
	**********************

	local _0_ "pri"
	local _1_ "pub"
	local matrices_list target total_pub total_pri target_pub target_pri
	matrix ones = J(6,1,1) // for totals
	foreach v of local alllist {
		if "``v''"!="" {
			foreach mat of local matrices_list {
				tempname `v'_`mat'
				matrix ``v'_`mat'' = J(4,6,.)
			}
			tab `v'_group2 `public'
			forval gp = 1/6 {
				local ee = 0
				foreach educ of local educ_levels {
					local ++ee
					if "``educ''"=="" continue
					/*tab `public' if  ``educ'' == 1
					tab `public' if  ``educ'age' == 1 */
					// Target population

					qui summ `one' if ``educ'age'==1 & `v'_group2==`gp' `aw'
					matrix ``v'_target'[`ee',`gp'] = r(sum)
					
					// Total attending public/private
					forval pp=0/1 {
						
						qui summ `one' if ``educ''==1 & `public'==`pp' ///
							& `v'_group2==`gp' `aw'
							
						matrix ``v'_total_`_`pp'_''[`ee',`gp'] = r(sum)
						// `_`pp'_' is "pri" or "pub"
						
					}
					
					// Target attending public/private
					forval pp=0/1 {
						qui summ `one' if ``educ'age'==1 & `public'==`pp' /// 
							& `v'_group2==`gp'  & ``educ''==1  `aw' 
						matrix ``v'_target_`_`pp'_''[`ee',`gp'] = r(sum)
					}
					
					// Totals row
					foreach mat of local matrices_list {
						tempname `v'_`mat'_totrow
						matrix ``v'_`mat'_totrow' = ``v'_`mat'' * ones
						matrix `v'_`mat' = ``v'_`mat'' , ``v'_`mat'_totrow'
					}
				}
			}
		}
	}

	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" /* " */ {
		`dit' `"Writing to "`using'"; may take several minutes"'
		local startcol_o = 4 // this one will stay fixed (column D)

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
		local submatrices extp poor rest tot
		local extp_add = 0
		local poor_add = 3
		local rest_add = 5
		local tot_add = 10
		
		local startcol = `startcol_o'
		local startrow = 11
		local vertincrement = 34
		local pp_increment = 7
		local horzincrement = 13
		
		local therow = `startrow'
		foreach v of local alllist {
			if "``v''"!="" {
				
				foreach mat of local matrices_list {
					foreach sub of local submatrices {
						tempname `v'_`mat'_`sub'
					} 

					matrix ``v'_`mat'_extp' = `v'_`mat'[1...,1..2] // Marc: need to re make these temp mats
					matrix ``v'_`mat'_poor' = `v'_`mat'[1...,3]
					matrix ``v'_`mat'_rest' = `v'_`mat'[1...,4..6]
					matrix ``v'_`mat'_tot'  = `v'_`mat'[1...,7]

					/*
					if strpos("`mat'","pri") {
						noi mat list  ``v'_`mat'_extp' 
						noi mat list  ``v'_`mat'_poor' 
						noi mat list  ``v'_`mat'_rest' 
						noi mat list  ``v'_`mat'_tot' 
					} */

					
					
					if "`mat'"=="target" local thecol `startcol_o'
					else if strpos("`mat'","pub") ///
						local thecol = `thecol' + `horzincrement'
					// if "pri" it goes below, not to the side

					if !strpos("`mat'","pri") local putrow = `therow'
					else local putrow = `therow' + `pp_increment'
					
					foreach sub of local submatrices {
						local thesubcol = `thecol' + ``sub'_add'
						returncol `thesubcol'
						local resultset `resultset' `r(col)'`putrow'=matrix(``v'_`mat'_`sub'')
					}
				}
				
			}
			local therow = `therow' + `vertincrement'
		}

		// Export to Excel (group cutoffs)
		local startcol = `startcol_o'
		local cutoffrow = 10
		forval i=1/10 {
			returncol `startcol'
			local cutoffs `cutoffs' `r(col)'`cutoffrow'=("`g`i''")
			local ++startcol
		}
		
		// Print warning message on Excel sheet 
		local warningrow = 222
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
		local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 542.") 	
		
		// putexcel
		qui putexcel `titlesprint' `versionprint' `resultset' `cutoffs' `warningprint' using `"`using'"', modify keepcellformat sheet("`sheet'")
		// "
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
	
end	// END ceqeduc
