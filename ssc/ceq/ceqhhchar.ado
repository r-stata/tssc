** ADO FILE FOR FISCAL INTERVENTIONS SHEET OF CEQ MASTER WORKBOOK SECTION E

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.4 01jun2017 For use with July 2017 version of CEQ Master Workbook 
** v1.3 01jun2017 For use with May 2017 version of CEQ Master Workbook 
** v1.2 12jan2017 For use with Oct 2016 version of CEQ Master Workbook 
** v1.1 01oct2016 For use with Jun 2016 version of CEQ Master Workbook 
** v1.0 25sep2016 For use with Jun 2016 version of CEQ Master Workbook 
*! (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   06-29-2017 Replacing covconc with improved version by Paul Corral
**   06-01-2017 Add additional options to print meta-information
** 	 01-12-2017 Set the data type of all newly generated variables to be double
** 				Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**	 10-01-2016 Update to allow some indicators to be produced when ppp is not specified
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
** ceqhhchar PROGRAM **
**********************
** For sheet E22. GroupSociodemoCharac
// BEGIN ceqhhchar (Higgins 2015)
capture program drop ceqhhchar
program define ceqhhchar, rclass 
	version 13.0
	#delimit ;
	syntax varlist /* varlist is for the characteristic variables */
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
			sheetm(string)
			sheetmp(string)
			sheetn(string)
			sheetg(string)
			sheett(string)
			sheetd(string)
			sheetc(string)
			sheetf(string)
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
	local command ceqhhchar
	local version 1.4
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org)"
	
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
		qui by `hhid': gen `members' = _N // # members in hh 
		qui by `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	** print warning messages 
	local warning "Warnings"

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
	local relevar `characteristics' 
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
	** missing fiscal interventions 
	foreach var of local allprogs {
		qui count if missing(`var') 
		if "`ignoremissing'"=="" {
			if r(N) {
				`die' "Missing values not allowed; `r(N)' missing values of `var' found"
				`die' "For households that did not receive/pay the tax/transfer, assign 0"
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
	
	** labels for characteristic variable column titles
	foreach char of local characteristics { // allprogs has variable names already
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
	** check if quantiles installed
	if "`nodecile'"=="" & "`nocentile'"=="" {
		cap which quantiles
		if _rc {
			`die' "{bf:quantiles} not installed; to install: {stata ssc install quantiles:ssc install quantiles}"
			exit
		}
	}
	
	** ado file specific
	foreach vrank of local alllist {
		if "`sheet`vrank''"=="" {
			if "`vrank'"=="mp" local _vrank "m+p"
			else local _vrank "`vrank'"
			local sheet`vrank' "E22.`_vrank' GroupSociodemoCharac" // default name of sheet in Excel files
		}
	}
	
	** ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group and bin not produced since {bf:ppp} option not specified."
		local warning `warning' "Warning: results by income group and bin not produced since ppp option not specified."
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
	
	** NO... options
	if wordcount("`nodecile' `nogroup' `nocentile' `nobin'")==4 {
		`die' "All options {bf:nodecile}, {bf:nogroup}, {bf:nocentile}, {bf:nobin} specified; no results to produce"
		exit 198
	}
	if "`nodecile'"=="" local _dec dec
	if "`nogroup'"=="" & (`_ppp') local _group2 group2
	if "`nocentile'"=="" local _cent cent
	if "`nobin'"=="" & (`_ppp') local _bin bin
	
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
		`dit' "Warning: No file specified with {bf:using}; results saved in {bf:return list} but not exported to Master Workbook"
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
	
	** create new variables for program categories

	if wordcount("`allprogs'")>0 ///
	foreach pr of local taxcols {
		qui summ `pr', meanonly
		if r(mean)>0 {
			if wordcount("`postax'")>0 local postax `postax', `pr'
			else local postax `pr'
			qui replace `pr' = -`pr' // replace doesnt matter since we restore at the end
		}
	}
	
	** PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
		}	
		foreach pr of local programcols {
			tempvar `pr'_ppp
			qui gen ``pr'_ppp' = (`pr'/`divideby')*(1/`ppp_calculated')
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
				if "`nobin'"=="" {
					tempvar `v'_bin 
					qui gen ``v'_bin' = .
					local i=1
					local bl = 0
					while `bl' < 10 {
						local bh = round(`bl' + 0.05, .01) // Stata was introducing rounding errors
						qui replace ``v'_bin' = `i' if ``v'_ppp' >= `bl' & ``v'_ppp' < `bh'
						local bl = `bh'
						local ++i
					}
					while `bl' < 50 { // it is >= 10 from previous loop
						local bh = round(`bl' + 0.25, .01) // Stata was introducing rounding errors
						qui replace ``v'_bin' = `i' if ``v'_ppp' >= `bl' & ``v'_ppp' < `bh'
						local bl = `bh'
						local ++i
					}	
					qui replace ``v'_bin' = `i' if ``v'_ppp' >= 50 & ``v'_ppp' < 100
					local ++i
					qui replace ``v'_bin' = `i' if ``v'_ppp' >= 100
					local count_bins = `i'
					qui replace ``v'_bin' = 1 if ``v'_ppp' < 0
				}
				if "`nogroup'"=="" {
					tempvar `v'_group2
					qui gen ``v'_group2' = . 
					forval gp=1/6 {
						qui replace ``v'_group2' = `gp' if ``v'_ppp'>=`cut`=`gp'-1'' & ``v'_ppp'<`cut`gp''
						// this works because I set `cut0' = 0 and `cut6' = infinity
					}
					qui replace ``v'_group2' = 1 if ``v'_ppp' < 0
				}
			}
			
			** percentiles and deciles
			tempvar `v'_cent `v'_dec
			if "`nocentile'"=="" qui quantiles ``v'' `aw', gen(``v'_cent') n(100) stable
			if "`nodecile'"==""  qui quantiles ``v'' `aw', gen(``v'_dec') n(10)   stable
		}
	}
	
	local group2 = 6
	local dec = 10
	local cent = 100
	if `_ppp' & "`nobin'"=="" local bin = `count_bins' // need if condition here b/c o.w. `count_bins' doesn't exist	
	
	**********************
	** CALCULATE RESULTS *
	**********************
	foreach incname of local alllist {
		if "``incname''"!="" local inc_used `inc_used' ``incname''
	}
	// Mean, median, standard deviation, concentration coefficient, reranking, etc.
	local cols = wordcount("`characteristics'")
	foreach v of local alllist {
		if "``v''"!="" {
			matrix frontmatter`v' = J(3,`cols',.) // changes with each E11 sheet
			local col = 1
			foreach char in `characteristics' { // already varnames
				local row = 1
				// Mean, median
				qui summ `char' `aw', d
				local mean = r(mean) // need this again later so save as local
				matrix frontmatter`v'[`row',`col'] = `mean' // mean
				local ++row
				matrix frontmatter`v'[`row',`col'] = r(p50) // median
				local ++row 
				// Standard deviation (accounting for complex sampling)
				// see http://www.stata.com/support/faqs/statistics/weights-and-summary-statistics/
				qui svy: mean `char' // svy incorporates weight automatically (use svy to get correct s.d.)
				matrix V_srs = e(V_srs) 
				scalar v_srs = V_srs[1,1]
				matrix frontmatter`v'[`row',`col'] = sqrt(e(N) * v_srs) // estimate of standard deviation
				local ++row
				
				local ++col
				*mat list frontmatter`v'
			}
		}
	}
	
	// Rest of sheet
	foreach vrank of local alllist {
		if "``vrank''"!="" {
			foreach x in `_dec' `_group2' `_cent' `_bin' {
				** create empty mata matrices for results
				matrix results`vrank'_`x' = J(`=``x''+1',`cols',.)
				
				local col = 0
				
				foreach char of local characteristics {
					local ++col
					forval i=1/``x'' {
						qui summ `char' if ``vrank'_`x''==`i' `aw'
						matrix results`vrank'_`x'[`i',`col'] = r(mean)
					}
					// overall mean
					qui summ `char' `aw'
					matrix results`vrank'_`x'[`=``x''+1',`col'] = r(mean)
				}
				// Population totals
				matrix pop`vrank'_`x' = J(`=``x''+1',2,.)
				forval i=1/``x'' {
					qui summ `one' if ``vrank'_`x''==`i' [aw=`exp']
					matrix pop`vrank'_`x'[`i',1] = r(sum)
					
					qui summ `one' if ``vrank'_`x''==`i' // no weights to get sample pop
					matrix pop`vrank'_`x'[`i',2] = r(sum)
				}
				// total row
				qui summ `one' [aw=`exp']
				matrix pop`vrank'_`x'[`=``x''+1',1] = r(sum)
				
				qui summ `one' 
				matrix pop`vrank'_`x'[`=``x''+1',2] = r(sum)

				
			}
		}
	}
	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" {
		// "
		`dit' `"Writing to "`using'"; may take several minutes"'
		// Export to Excel (matrices)
		local vertincrement = 3
		local popcol = 1
		local startcol_o = 6
		local resultset
		local rfrontmatter = 9
		local rdec   = 14 // row where decile results start
		local rgroup2 = `rdec' + `dec' + `vertincrement' // dec = 10
		local rcent  = `rgroup2' + `group2' + `vertincrement' // group2 = 6
		local rbin   = `rcent' + `cent' + `vertincrement'
		

		foreach vrank of local alllist {
			if "``vrank''"!="" {
				local startcol = `startcol_o'
				returncol `startcol_o'
				local resultset`vrank' `resultset`vrank'' `r(col)'`rfrontmatter'=matrix(frontmatter`vrank') // Starts col 6
				*nois di `" `r(col)'`rfrontmatter'=matrix(frontmatter`vrank') "'
				*mat list frontmatter`vrank'
				foreach x in `_dec' `_group2' `_cent' `_bin' {
					returncol `startcol'
					local resultset`vrank' `resultset`vrank'' `r(col)'`r`x''=matrix(results`vrank'_`x')
					returncol `popcol'
					local resultset`vrank' `resultset`vrank'' `r(col)'`r`x''=matrix(pop`vrank'_`x')
				}
			}
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
				
		// Export to Excel (column titles)
		local trow = 8
		local startcol = `startcol_o'
		foreach char of local characteristics {
			returncol `startcol'
			local titles `titles' `r(col)'`trow'=("`d_`char''")
			local ++startcol
		}	
		
		// Export to Excel (group cutoffs)
		local lowcol = 3 
		local hicol = 4
		foreach x in low hi {
			returncol ``x'col'
			local _`x'col `r(col)'
		}
		forval i=1/6 {
			local therow = `rgroup2' + `i' - 1
			if `i'==1 { 
				local cutoffs `cutoffs' `_hicol'`therow'=(`cut`i'')
				nois di "`_hicol'`therow'"
			}
			else {
			local cutoffs `cutoffs' `_lowcol'`therow'=(`cut`=`i'-1'') `_hicol'`therow'=(`cut`i'')
			
			}
		}
		
		// Print warning message on Excel sheet 
		local warningrow = 507
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
		local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 507.") 
		
		// putexcel
		foreach vrank of local alllist {
			if "``vrank''"!="" {
				*set trace on
				qui putexcel `titlesprint' `versionprint' `titles' ///
					`resultset`vrank'' `cutoffs' `warningprint' using `"`using'"', /// " 
					modify keepcellformat sheet("`sheet`vrank''")
				*set trace off
			}
		}
	}
	
	** // In return list
	** foreach vrank of local alllist {
		** if "``vrank''"!="" {
			** foreach x in `_dec' `_group' `_cent' `_bin' {
				** foreach ss in `supercols' fi_`vrank' {
					** return matrix I`vrank'_`ss'_`x' = I`vrank'_`ss'_`x'
					** cap matrix drop I`vrank'_`ss'_`x'
				** }
			** }
			** cap matrix drop frontmatter`vrank'
		** }
	** }
	

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
	
end	// END ceqhhchar
