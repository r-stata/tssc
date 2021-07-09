** ADO FILE FOR POPULATION SHEET OF CEQ OUTPUT TABLES

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.5 01jun2017 For use with July 2017 version of Output Tables
** v1.4 12jan2017 For use with Oct 2016 version of Output Tables
** v1.3 01oct2016 For use with Jun 2016 version of Output Tables
** v1.2 10sep2016 For use with Jun 2016 version of Output Tables
** v1.1 12aug2016 For use with Jun 2016 version of Output Tables
** v1.0 6aug2016 For use with Jun 2016 version of Output Tables

** CHANGES
** 	06-06-2017 Changed minimum abbreviation for GROUPby to GROUPBy
**			   due to new option for GRoup.
** 	01-06-2017 Include Scenario, Group, and Project as opitions to be inputed into excel.
** 	01-12-2017 Set the data type of all newly generated variables to be double
** 			   Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**	10-01-2016 Move up preserve and modify section to avoid issuing a wrong warning for negatives
**	09-10-2016 Print warning messages to MWB sheets 
**  08-12-2016 Fixed local ... : unab --> unab ... : (pointed out by Rosie Li)


** NOTES
**  Uses oppincidence (part of -ceq- package)

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

// BEGIN uniquevals (Higgins 2015) 
//  Counts unique values of a variable or list of variables
//  (Runs significantly faster than duplicates report)
capture program drop uniquevals
program define uniquevals, byable(recall) rclass sortpreserve
	syntax [varlist] [if] [in] [, Count SEParately Sorted]
	preserve
	if "`if'`in'"!="" {
		qui keep `if' `in'
	}
	if _by()==1 {
		qui drop if `_byindex' != _byindex()
	}
	if "`sorted'"=="" local sort "sort"
	else local sort ""
	tempvar unique
	if "`separately'"!="" foreach var in `varlist' {
		by`sort' `var': gen `unique' = (_n==1)
		qui count if `unique'
		di as result r(N) as text " unique values of " as result "`var'"
		return scalar unique = r(N)
	}
	else {
		by`sort' `varlist': gen `unique' = (_n==1)
		qui count if `unique'
		di as result r(N) as text " unique values of " as result "`varlist'"
		return scalar unique = r(N)
	}
	if "`count'"!="" {
		qui count
		di as result r(N) as text " observations" // already dropped other obs
		return scalar N = r(N)
	}
end

*******************
** ceqiop PROGRAM *
*******************
** For sheet E4. Inequality of Opportunity
// BEGIN ceqpop (Higgins 2015)
capture program drop ceqiop
program define ceqiop, rclass 
	version 13.0
	#delimit ;
	syntax 
		[using/]
		[if] [in] [pweight/] 
		, 
			/* CIRCUMSTANCES */
			GROUPBy(varlist)
		[	
			/* INCOME CONCEPTS: */
			Market(varname)
			MPluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			/* SURVEY INFORMATION */
			HEad(string)
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname)
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
	local command ceqiop
	local version 1.5
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org)"
	
	** general CEQ ado files
	local m `market'
	local mp `mpluspensions'
	local n `netmarket'
	local g `gross'
	local t `taxable'
	local d `disposable'
	local c `consumable'
	local f `final'
	local alllist m mp n g t d c f
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
	
	local startcol_o = 3 // this one will stay fixed (column C)
	
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
	
	** ** check if iop installed
	** if "`nodecile'"=="" & "`nocentile'"=="" {
		** cap which iop
		** if _rc {
			** `die' "{bf:iop} not installed; to install: {net install st0361.pkg:net install st0361.pkg}"
		** }
	** }
	
	** ado file specific
	if "`sheet'"=="" local sheet "E4. Inequality of Opportunity" // default name of sheet in Excel files
	
	** weight (if they specified hhsize*hhweight type of thing)
	if strpos("`exp'","*")> 0 { // TBD: what if they premultiplied w by hsize?
		`die' "Please use the household weight in {weight}; this will automatically be multiplied by the size of household given by {bf:hsize}"
		exit
	}
	
	** hsize, hhid, head
	if wordcount("`hsize' `hhid'")!=1 {
		`die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or "
		`die' "{bf:hhid} (unique household identifier for individual-level data)"
		exit 198
	}
	if "`hhid'"!="" & "`head'"=="" {
		`die' "When using individual level data sets and {bf:hhid}, must also specify a variable"
		`die' "that identifies the household head in the {bf:head} option"
		exit 198
	}
	if "`hsize'"!="" & "`head'"!="" {
		`die' "{bf:head} option is only used with individual-level data, but you"
		`die' "specified the {bf:hsize} option which indicates household-level data"
		exit 198
	}
	if "`head'"!="" {
		if strpos("`head'","=") & !strpos("`head'","==") {
			`die' "Condition in {bf:head} option only has one = sign; should have two"
			exit 198
		}
		if strpos("`head'","==")==0 {
			cap confirm var `head'
			if _rc {
				`die' "variable `head' (specified in {bf:head} option) not found"
				exit 198
			}
			`dit' "Warning: no condition specified; assuming household head satisfies"
			`dit' "the condition `head'==1"
			local warning `warning' "Warning: no condition specified; assuming household head satisfies the condition that `head' equals to 1."
			unab headvar : `head'
			local head "`headvar'==1"
		}	
		sort `hhid', stable
		tempvar is_head n_head tag
		qui gen `is_head' = (`head') // dummy =1 if hh head
		by `hhid' : egen `n_head' = total(`is_head') // sum number of hh heads
		by `hhid' : gen `tag' = (_n==1) // tag one obs per hh
		qui count if `tag'==1 & `n_head'==0
		if r(N) {
			`die' "`r(N)' households with no member identified as head (`head')"
			exit 198
		}
		qui count if `tag'==1 & `n_head'>1 
		if r(N) {
			`die' "`r(N)' households with more than one member identified as head (`head')"
			exit 198
		}
	}
	
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
	
	** negative and zero incomes (set to 0.01 for inequality calculations)
	foreach v of local alllist {
		if "``v''"!="" {
			qui count if ``v''<0 // note `v' is e.g. m, ``v'' is varname
			if r(N) {
				`dit' "Warning: `r(N)' negative values of ``v''"
				local warning `warning' "Warning: `r(N)' negative values of ``v''"
				local negatives = 1
			}
			else local negatives = 0
			qui count if ``v''==0
			if r(N) {
				`dit' "Warning: `r(N)' values of 0 of ``v''"
				local warning `warning' "Warning: `r(N)' values of 0 of ``v''"
				local zeros = 1
			}
			else local zeros = 0
			if `negatives'==1 | `zeros'==1 {
				`dit' "     Since mean log deviation is used and ln(y) is undefined for y<=0,"
				`dit' "     income is set to 0.01 for these observations."
			}
			qui replace ``v''=0.01 if ``v''<0.01
		}
	}
	

	************************
	** PRESERVE AND MODIFY *
	************************
	
	** collapse to hh-level data
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid', stable
		qui by `hhid': gen `members' = _N // # members in hh 
		qui by `hhid': drop if !(`head') // keep only hh head
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
	// no standard errors on this sheet so I commented out those parts
	** else if "`r(su1)'"=="" & "`psu'"=="" {
		** di as text "Warning: primary sampling unit not specified in svydes or the d1 command's psu() option"
		** di as text "P-values will be incorrect if sample was stratified"
	** }
	** if "`psu'"=="" & "`r(su1)'"!="" {
		** local psu `r(su1)'
	** }
	** if "`strata'"=="" & "`r(strata1)'"!="" {
		** local strata `r(strata1)'
	** }
	** if "`strata'"!="" {
		** local opt strata(`strata')
	** }
	** now set it:
	** if "`exp'"!="" qui svyset `psu' `pw', `opt'
	** else           qui svyset `psu', `opt
	
	**************************
	** VARIABLE MODIFICATION *
	**************************
	
	** keep the variables used in ceqdes   
	local relevar `varlist' `w' `hsize' `exp' `groupby' // only income concepts and weight are needed    		  
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
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	**********************
	** CALCULATE RESULTS *
	**********************
	local multiply = 1
	local print_sets = ""
	local count = 0
	`dit' ""
	`dit' "Number of circumstance sets:"
	foreach var of varlist `groupby' {
		local ++count
		if `count'==1 local comma ""
		else local comma ", "
		uniquevals `var'
		local multiply = `multiply'*`r(unique)'
		local print_sets "`print_sets'`comma'`r(unique)' groups of `var'"
	}
	`dit' "==> " as result "`multiply'" as text " circumstance sets"
	local print_sets "`print_sets' ==> `multiply' circumstance sets"
	local rows = wordcount("`alllist'")
	tempname levels ratios
	matrix `levels' = J(`rows',1,.)
	matrix `ratios' = J(`rows',1,.)
	oppincidence `varlist' `aw', groupby(`groupby')
	// Matrices with blanks for non-specified:
	tempname r_levels r_ratios
	matrix `r_levels' = r(levels)
	matrix `r_ratios' = r(ratios)
	local row = 0
	local r_row = 0
	foreach v of local alllist {
		local ++row
		if "``v''"!="" {
			local ++r_row
			foreach mat in levels ratios {
				matrix ``mat''[`row',1] = `r_`mat''[`r_row',1]
			}
		}
	}
	
	*****************
	** SAVE RESULTS *
	*****************
	`dit' ""
	`dit' `"Writing to "`using'"; may take several minutes"'
	// Export to Excel (matrices)
	local vertincrement = 9
	local resultset
	local start = 3
	local therow = 9
	returncol `start'
	foreach mat in levels ratios {
		local resultset `resultset' `r(col)'`therow'=matrix(``mat'')
		local therow = `therow' + `vertincrement'
	}

	// Print information
	local date `c(current_date)'
	local titlesprint
	local titlerow = 3
	local titlecol = 1
	local titlelist country surveyyear authors date scenario group project
	foreach title of local titlelist {
		returncol `titlecol'
		if "``title''"!="" & "``title''"!="-1" ///
			local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''")
		local titlecol = `titlecol' + 1
	}

	// Print version number on Excel sheet
	local versionprint A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'")

	// Print info on circumstance sets
	local print_sets A5=("`print_sets'")
	
	// Print warning message on Excel sheet 
	local warningrow = 35
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
	local warningprint `warningprint' G4=("`warningcount' important warning messages are printed starting on row 35.") // G4 since A5 has circumstance sets info

	// putexcel
	if `"`using'"' /* " */ != "" {
		qui putexcel `titlesprint' `versionprint' `print_sets' `resultset' `warningprint' using `"`using'"', modify keepcellformat sheet("`sheet'") // "
	}
	
	// In return list
	return matrix levels = `levels'
	return matrix ratios = `ratios'
	
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
	
end	// END ceqpop
