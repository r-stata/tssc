** ADO FILE FOR FISCAL INTERVENTIONS SHEET OF CEQ MASTER WORKBOOK SECTION E

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.3 02jun2017 For use with July 2017 version of CEQ Master Workbook 
** v1.2 12jan2017 For use with Oct 2016 version of CEQ Master Workbook 
** v1.1 30sep2016 For use with Jun 2016 version of CEQ Master Workbook
** v1.0 25sep2016 For use with Jun 2016 version of CEQ Master Workbook
*! (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   06-01-2017 Add additional options to print meta-information
** 	 1-12-2017 Set the data type of all newly generated variables to be double
** 			   Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**	 9-30-2016 Changed warning contents and add exit when ppp option is not specified
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
** ceqinfra PROGRAM **
**********************
** For sheet E21. Infrastructure Access
// BEGIN ceqinfra (Higgins 2016)
capture program drop ceqinfra
program define ceqinfra, rclass 
	version 13.0
	#delimit ;
	syntax varlist /* varlist is for the infrastructure access variables */
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
			/* OTHER OPTIONS */
			NODecile
			NOGroup
			NOCentile
			NOBin
			/* VARIABLE MODIFICATON */
			IGNOREMissing
			/* ALLOW NEGATIVE VALUES */
			NEGATIVES
		]
	;
	#delimit cr
	
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqinfra
	local version 1.3
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org)"
	
	** infrastructure access variables
	if wordcount("`varlist'")>8 {
		`dit' "{bf:`command'} can only accommodate up to 8 infrastructure access variables; omitting additional variables" 
		local warning `warning' "`command' can only accommodate up to 8 infrastructure access variables; omitting additional variables" 
	}
	tokenize `varlist'
	forval ii = 1/8 {
		local infrastructures `infrastructures' ``ii'' 
			// to only keep the first 8 elements of `varlist' in `infrastructures'
	}
		// (note that later create a new `varlist' local so needed this one to have
		//  a new name)
	
	** characteristic variables
	local characteristics `varlist'
		// because later I make `varlist' the income concepts
	
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
	
	local d_m      "Market Income"
	local d_mp     "Market Income + Pensions"
	local d_n      "Net Market Income"
	local d_g      "Gross Income"
	local d_t      "Taxable Income"
	local d_d      "Disposable Income"
	local d_c      "Consumable Income"
	local d_f      "Final Income"
	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in' 
	
	** make sure all newly generated variables are in double format
	set type double 
	
	** weight (if they specified hhsize*hhweight type of thing)
	if strpos("`exp'","*")> 0 { // TBD: what if they premultiplied w by hsize?
		`die' "Please use the household weight in {weight}; this will automatically be multiplied by the size of household given by {bf:hsize}"
		exit
	}
	
	** hsize and hhid
	if wordcount("`hsize' `hhid'")!=1 {
		`die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or "
		`die' "{bf:hhid} (unique household identifier for individual-level data)"
		exit 198
	}
	
	** collapse to hh-level data 
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid', stable
		foreach char of local infrastructures {
			tempvar mean_char
			qui by `hhid': egen `mean_char' = mean(`char')
			cap assert `char'==`mean_char'
			if _rc {
				`die' "Variable `char' is not the same for all members within household"
				exit 198
			}
		}
		qui by `hhid': gen `members' = _N // # members in hh 
		qui by `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	** print warning messages 
	local warning "Warnings"

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
	#delimit ;
	local relevar `infrastructures' 
				  `varlist'     
				  `w' `exp' `psu' `strata' 	  
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
	** missing infrastructures
	foreach var of local infrastructures {
		qui count if missing(`var') 
		if "`ignoremissing'"=="" {
			if r(N) {
				`die' "Missing values not allowed; `r(N)' missing values of `var' found"
				`die' "For households that do not have access, assign 0"
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
	
	** make sure dummies
	foreach char of local infrastructures {
		cap assert (`char'==0 | `char'==1)
		if _rc {
			`die' "Infrastructure access variable `char' should be a dummy variable equal to 0 or 1 for all observations"
			exit 198
		}
	}	
	
	** labels for characteristic variable column titles
	foreach char of local infrastructures { // allprogs has variable names already
		local d_`char' : var label `char'
		if "`d_`char''"=="" { // ie, if the var didnt have a label
			local d_`char' `char' // then we will print the variable name to MWB
			`dit' "Warning: variable `char' not labeled"
			local warning `warning' "Warning: variable `char' not labeled."
		}
		if strpos("`d_`char''","(")!=0 {
			if strpos("`d_`char''",")")==0 {
				`die' "`d_`char'' must have a closed parenthesis"
				exit 198
			}
		}
	}

	******************
	** PARSE OPTIONS *
	******************	
	** ado file specific
	if "`sheet'"=="" local sheet "E21. Infrastructure Access"
	
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

	***********************
	** OTHER MODIFICATION *
	***********************
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
			** bins and groups
			if `_ppp' {
				tempvar `v'_group2
				qui gen ``v'_group2' = . 
				forval gp=1/6 {
					qui replace ``v'_group2' = `gp' if ``v'_ppp'>=`cut`=`gp'-1'' & ``v'_ppp'<`cut`gp''
					// this works because I set `cut0' = 0 and `cut6' = infinity
				}
				qui replace ``v'_group2' = 1 if ``v'_ppp' < 0 // negatives go in <`cut1' group
			}
		}
	}
	
	local group2 = 6
	
	**********************
	** CALCULATE RESULTS *
	**********************
	foreach incname of local alllist {
		if "``incname''"!="" local inc_used `inc_used' ``incname''
	}

	local rows = 10 // wordcount("`infrastructures'") + 2 // +2 is for bottom matter
	foreach v of local alllist {
		if "``v''"!="" {
			foreach suffix in "_hh" "_ind" {
				matrix results`suffix'`v' = J(`rows',7,.) // changes with each E11 sheet
			}
			local row = 1
			foreach char of local infrastructures { // already varnames
				forval gp=1/6 {
					qui summ `char' if ``v'_group2'==`gp' [aw=`exp']
					matrix results_hh`v'[`row',`gp'] = r(sum)
					
					qui summ `char' if ``v'_group2'==`gp' `aw'
					matrix results_ind`v'[`row',`gp'] = r(sum)
				}
				qui summ `char' [aw=`exp']
				matrix results_hh`v'[`row',7] = r(sum)
				
				qui summ `char' `aw'
				matrix results_ind`v'[`row',7] = r(sum)
				
				local ++row
			}
			
			// Total number of households/individuals row
			local row = 9 // since fixed 8 rows for infrastructure vars
			forval gp=1/6 {
				qui summ `one' if ``v'_group2'==`gp' [aw=`exp']
				matrix results_hh`v'[`row',`gp'] = r(sum)
				
				qui summ `one' if ``v'_group2'==`gp' `aw'
				matrix results_ind`v'[`row',`gp'] = r(sum)
			}
			qui summ `one' [aw=`exp']
			matrix results_hh`v'[`row',7] = r(sum)
			
			qui summ `one' `aw'
			matrix results_ind`v'[`row',7] = r(sum)
			
			local ++row
			
			// Total income row
			forval gp=1/6 {
				qui summ ``v'' if ``v'_group2'==`gp' `aw'
				matrix results_hh`v'[`row',`gp'] = r(sum)
				matrix results_ind`v'[`row',`gp'] = r(sum)
			}
			qui summ ``v'' `aw'
			matrix results_hh`v'[`row',7] = r(sum)
			matrix results_ind`v'[`row',7] = r(sum)
		}
	}
	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" /* " */ {
		`dit' `"Writing to "`using'"; may take several minutes"'
		// Export to Excel (matrices)
		local submatrices extp poor rest tot
		local extp_add = 0
		local poor_add = 3
		local rest_add = 5
		local tot_add = 10
		
		local vertincrement = 45
		local horzincrement = 14
		local startcol_o = 4
		local startrow_o = 16
		local resultset
		
		local startrow = `startrow_o'
		
		foreach v of local alllist {
			if "``v''"!="" {
				foreach mat in "results_hh" "results_ind" {
					foreach sub of local submatrices {
						tempname `mat'`v'_`sub'
					}
					matrix ``mat'`v'_extp' = `mat'`v'[1...,1..2]
					matrix ``mat'`v'_poor' = `mat'`v'[1...,3]
					matrix ``mat'`v'_rest' = `mat'`v'[1...,4..6]
					matrix ``mat'`v'_tot'  = `mat'`v'[1...,7]
					
					if regexm("`mat'","_hh$") ///
						local thecol = `startcol_o'
					else /// _ind 
						local thecol = `startcol_o' + `horzincrement'
					
					foreach sub of local submatrices {
						local thesubcol = `thecol' + ``sub'_add'
						returncol `thesubcol'
						local resultset `resultset' `r(col)'`startrow'=matrix(``mat'`v'_`sub'')
					}
				}
			}
			local startrow = `startrow' + `vertincrement'
		}

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
				
		// Export to Excel (row titles)
		local tcol = 2
		returncol `tcol'
		local trow = `startrow_o'
		local startcol = `startcol_o'
		foreach char of local infrastructures {
			local titles `titles' `r(col)'`trow'=("`d_`char''")
			local ++trow
		}	
		
		// Export to Excel (group cutoffs)
		local startcol = `startcol_o'
		local cutoffrow = 15
		forval i=1/10 {
			returncol `startcol'
			local cutoffs `cutoffs' `r(col)'`cutoffrow'=("`g`i''")
			local ++startcol
		}
		
		// Print warning message on Excel sheet 
		local warningrow = 370
		local warningcount = -1
		foreach x of local warning {
			local warningprint `warningprint' A`warningrow'=("`x'")
			local ++warningrow
			local ++warningcount
		}
		** // overwrite the obsolete warning messages if there are any
		** forval i=0/100 {
			** local warningprint `warningprint' A`=`warningrow'+`i''=("")
		** }
		// count warning messages and print at the top of MWB
		local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 507.") 
		
		// putexcel
		qui putexcel `titlesprint' `versionprint' `titles' ///
			`resultset' `cutoffs' `warningprint' using `"`using'"', /// " 
			modify keepcellformat sheet("`sheet'")
		
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
	
end	// END ceqinfra
