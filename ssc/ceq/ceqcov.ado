** ADO FILE FOR COVARIANCE SHEET OF CEQ MASTER WORKBOOK SECTION E

** VERSION AND NOTES (changes between versions described under CHANGES
*! v1.5 01jun2017 For use with July 2017 version of Output Tables
** v1.4 08mar2017 For use with Oct 2016 version of Output Tables
** v1.3 12jan2017 For use with Oct 2016 version of Output Tables
** v1.2 30oct2016 For use with Jun 2016 version of Output Tables
** v1.1 24sep2016 For use with Jun 2016 version of Output Tables
** v1.0 03sep2016 For use with Jun 2016 version of Output Tables
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**	 06-01-2017 Add additional options to print meta-information
**   03-08-2017 Remove the net in-kind transfers as a broad category in accordance with the instruction that users
**				 supply net in-kind transfer variables to health/education/otherpublic options
** 	 01-12-2017 Set the data type of all newly generated variables to be double
** 				Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**   10-30-2016 Fix bug with alltransfersp omitted from the broad categories
**	  9-24-2016 Print warning messages to MWB sheets 
**				Change from d1 command to `command' command in warning 
**				Add a check for open parentheses; changed from strrpos() to strpos() for compatibility
**				 with Stata 13.0

** NOTES

** TO DO

**************************
** PRELIMINARY PROGRAMS **
**************************
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol

// BEGIN covrank (Higgins 2015)
//  Produce covariance between varname and fractional rank of `rank'
cap program drop covrank
program define covrank, rclass sortpreserve
	syntax varname [if] [in] [pw aw iw fw/], [rank(varname)]
	preserve
	marksample touse
	qui keep if `touse' // drops !`if', !`in', and any missing values of `varname'
	local 1 `varlist'
	if "`rank'"=="" {
		local rank `1'
		local _return gini
		local _returndi Gini
	}
	else {
		local _return conc
		local _returndi Concentration Coefficient
	}
	sort `rank' `1', stable // sort in increasing order of ranking variable; break ties with other variable
	tempvar F wnorm wsum // F is adjusted fractional rank, wnorm normalized weights,
		// wsum sum of normalized weights for obs 1, ..., i-1
	if "`exp'"!="" { // with weights
		local aw [aw=`exp'] // with = since I used / in syntax
		tempvar weight
		gen `weight' = `exp'
		qui summ `weight'
		qui gen `wnorm' = `weight'/r(sum) // weights normalized to sum to 1
		qui gen double `wsum' = sum(`wnorm')
		qui gen double `F' = `wsum'[_n-1] + `wnorm'/2 // from Lerman and Yitzhaki (1989)
		qui replace `F' = `wnorm'/2 in 1
		qui corr `1' `F' `aw', cov
		local cov = r(cov_12)
	}
	else { // no weights
		qui gen `F' = _n/_N // sorted so this works in unweighted case; 
			// cumul `1', gen(`F') would also work
		qui corr `1' `F', cov
		local cov = r(cov_12)
	}
	local _return = ((r(N)-1)/r(N))*`cov' // the (N-1)/N term adjusts for
		// the fact that Stata does sample cov
	return scalar cov = `_return'
	restore
end // END covrank

********************
** ceqcov PROGRAM **
********************
** For sheet E1. Descriptive Statistics
// BEGIN ceqcov (Higgins 2015)
capture program drop ceqcov
program define ceqcov, rclass 
	version 13.0
	#delimit ;
	syntax 
		[using/]
		[if] [in] [pweight/] 
		[, 
			/** INCOME CONCEPTS: **/
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			/** FISCAL INTERVENTIONS: **/
			Pensions   (varlist)
			DTRansfers (varlist)
			DTAXes     (varlist) 
			CONTribs   (varlist)
			SUbsidies  (varlist)
			INDTAXes   (varlist)
			HEALTH     (varlist)
			EDUCation  (varlist)
			OTHERpublic(varlist)
			USERFEESHealth(varlist)
			USERFEESEduc(varlist)
			USERFEESOther(varlist)
			/** PPP CONVERSION
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily **/
			/** SURVEY INFORMATION **/
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname) 
			/** INFORMATION CELLS **/
			COUNtry(string)
			SURVeyyear(string) /** string because could be range of years **/
			AUTHors(string)
			SCENario(string)
			GRoup(string)
			PROJect(string)
			/** DROP MISSING VALUES **/
			IGNOREMissing
			/** EXPORTING TO CEQ MASTER WORKBOOK: **/
			sheet(string)
			OPEN
		]
	;
	#delimit cr
	
	************
	** LOCALS **
	************
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqcov
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
	local incomes = wordcount("`alllist'")
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
	
	*************************
	** PRESERVE AND MODIFY **
	*************************
	  
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** make sure all newly generated variables are in double format
	set type double 
	
	** transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic userfeeshealth userfeeseduc userfeesother /* nethealth neteducation netother */
	foreach x of local programlist {
		local allprogs `allprogs' ``x'' // so allprogs has the actual variable names
	}
	
	** weight (if they specified hhsize*hhweight type of thing)  // previously under *parse options*, moved up to realize the keep var function
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
	
	local fisctypewarn
	foreach var of local allprogs {
		if "`var'"!="" {
			local vartype: type `var'
			if "`vartype'"!="double" {
				if wordcount("`fisctypewarn'")>0 local fisctypewarn `fisctypewarn', `var'
				else local fisctypewarn `var'
			}
		}
	}
	if wordcount("`fisctypewarn'")>0 `dit' "Warning: Fiscal intervention variable(s) `fisctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	if wordcount("`fisctypewarn'")>0 local warning `warning' "Warning: Fiscal intervention variable(s) `fisctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	
	************************
	** SVYSET AND WEIGHTS **
	************************ 
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
	
	** keep the variables used in ceqcov   

	#delimit ;
	local relevar `varlist' `allprogs'      
				  `w' `psu' `strata' 	  
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
	
	
	** columns including disaggregated components and broader categories 
	local broadcats dtransfersp dtaxescontribs inkind userfees /*netinkind*/ alltaxes alltaxescontribs alltransfers alltransfersp
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	local userfees `userfeeshealth' `userfeeseduc' `userfeesother'
	/*local netinkind `nethealth' `neteducation' `netother'*/
	local alltransfers `dtransfers' `subsidies' `inkind' /* `userfees' */
	local alltransfersp `pensions' `dtransfers' `subsidies' `inkind' /* `userfees' */
	local alltaxes `dtaxes' `indtaxes' 
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	foreach cat of local programlist {
		if "``cat''"!="" {
			tempvar v_`cat'
			qui gen `v_`cat''=0
			foreach x of local `cat' {
				qui replace `v_`cat'' = `v_`cat'' + `x' // so e.g. v_dtaxes will be sum of all vars given in dtaxes() option
			}
				// so suppose there are two direct taxes dtr1, dtr2 and two direct taxes dtax1, dtax2
				// then `programcols' will be dtr1 dtr2 dtransfers dtax1 dtax2 dtaxes
		}	
	}
	foreach bc of local broadcats {
		if wordcount("``bc''")>0 { // i.e. if any of the options were specified; for bc=inkind this says if any options health education or otherpublic were specified
			tempvar v_`bc'
			qui gen `v_`bc'' = 0
			foreach var of local `bc' { // each element will be blank if not specified
				qui replace `v_`bc'' = `v_`bc'' + `var'
			}
		}
	}	

	#delimit ;
	local programcols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`dtaxes' `contribs' `v_dtaxes' `v_contribs' `v_dtaxescontribs'
		`subsidies' `v_subsidies' `indtaxes' `v_indtaxes'
		`v_alltaxes' `v_alltaxescontribs'
		`health' `v_health' `education' `v_education' `otherpublic' `v_otherpublic' `v_inkind'
		`userfeeshealth' `v_userfeeshealth' `userfeeseduc' `v_userfeeseduc' `userfeesother' `v_userfeesother' `v_userfees' 
		/*`nethealth' `neteducation'  `netother' `v_netinkind'*/
		`v_alltransfers' `v_alltransfersp'
	;
	local transfercols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`subsidies' `v_subsidies'
		`health' `education' `otherpublic'
		`v_health' `v_education' `v_otherpublic' `v_inkind'
		/*`nethealth' `neteducation'  `netother' `v_netinkind'*/
		`v_alltransfers' `v_alltransfersp'
	;
	local taxcols: list programcols - transfercols; // set subtraction;
	#delimit cr
	local cols = wordcount("`programcols'") // + 1 for income column

	** labels for fiscal intervention column titles
	foreach pr of local allprogs { // allprogs has variable names already
		local d_`pr' : var label `pr'
		if "`d_`pr''"=="" { // ie, if the var didnt have a label
			local d_`pr' `pr'
			`dit' "Warning: variable `pr' not labeled"
			local warning `warning' "Warning: variable `pr' not labeled."
		}
		if strpos("`d_`pr''","(")!=0 {
			if strpos("`d_`pr''",")")==0 {
				`die' "`d_`pr'' must have a closed parenthesis"
				exit 198
			}
		}
	}
	
	local d_`v_pensions'         = "All contributory pensions"
	local d_`v_dtransfers'       = "All direct transfers excl contributory pensions"
	local d_`v_dtransfersp'      = "All direct transfers incl contributory pensions"
	local d_`v_contribs'         = "All contributions"
	local d_`v_dtaxes'           = "All direct taxes"
	local d_`v_dtaxescontribs'   = "All direct taxes and contributions"
	local d_`v_subsidies'        = "All indirect subsidies"
	local d_`v_indtaxes'         = "All indirect taxes"
	local d_`v_health'           = "Net health transfers"
	local d_`v_education'        = "Net education transfers"
	local d_`v_otherpublic'      = "Net other public transfers" // LOH need to fix that this is showing up even when I don't specify the option
	local d_`v_inkind'           = "All net in-kind transfers"
	local d_`v_userfeeshealth'   = "All health user fees"
	local d_`v_userfeeseduc'     = "All education user fees"
	local d_`v_userfeesother'    = "All other user fees"
	local d_`v_userfees'	     = "All user fees"
    /* scalar _d_`v_netinkind'        = "All net inkind transfers"   scalar of specfic net inkind transfers created before */
	local d_`v_alltransfers'     = "All net transfers and subsidies excl contributory pensions"
	local d_`v_alltransfersp'    = "All net transfers and subsidies incl contributory pensions"
	local d_`v_alltaxes'         = "All taxes"
	local d_`v_alltaxescontribs' = "All taxes and contributions"
	
	** results
	local supercols totLCU totPPP pcLCU pcPPP shares cumshare
	
	** titles 
	local _totLCU = "CONCENTRATION TOTALS (LCU)"
	local _totPPP = "CONCENTRATION TOTALS (US PPP DOLLARS)"
	local _pcLCU  = "CONCENTRATION PER CAPITA (LCU)"
	local _pcPPP  = "CONCENTRATION PER CAPITA (US PPP DOLLARS)"
	local _shares  = "CONCENTRATION SHARES"
	local _cumshare = "CONCENTRATION CUMULATIVE SHARES"
	foreach v of local alllist {
		local uppered = upper("`d_`v''")
		local _fi_`v' = "FISCAL INCIDENCE WITH RESPECT TO `uppered'"
	}
	
	*******************
	** PARSE OPTIONS **
	*******************
	** ado file specific
	if "`sheet'"=="" local sheet "E15. Covariance"
	
	/** ppp conversion (leaving this here in case we add PPP converted to sheet later)
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: results by income group and bin not produced since {bf:ppp} option not specified."
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
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365
	**/

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
	
	** negative fiscal interventions
	foreach pr of local allprogs {
		if "`pr'"!="" {
			qui summ `pr'
			if r(mean)>0 {
				qui count if `pr'<0
				if r(N) `dit' "Warning: `r(N)' negative values of `pr'."
				if r(N) local warning `warning' "Warning: `r(N)' negative values of `d_`pr''."
			}
			else {
				qui count if `pr'>0
				if r(N) `dit' "Warning: `r(N)' positive values of `pr' (`pr' stored as negatived values)."
				if r(N) local warning `warning' "Warning: `r(N)' positive values of `pr' (`d_`pr'' stored as negatived values)."
			}
		}
	}
	
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
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	

	***********************
	** CALCULATE RESULTS **
	***********************
	matrix results = J(`=`incomes'+1',`=`incomes'+`cols'',.)	
		// +1 in the row is for the mean row
	local col=0
	foreach v of local alllist {
		local row = 1
		local ++col
		if "``v''"!="" {
			qui summ ``v'' `aw' 
			matrix results[`row',`col'] = r(mean)
			foreach vrank of local alllist {
				local ++row
				if "``vrank''"!="" {
					qui covrank ``v'' `pw', rank(``vrank'')
					matrix results[`row',`col'] = r(cov)
				}
			}
		}
	}
	foreach pr of local programcols {
		local row = 1
		local ++col
		if "`pr'"!="" {
			qui summ `pr' `aw' 
			matrix results[`row',`col'] = r(mean)
			foreach vrank of local alllist {
				local ++row
				if "``vrank''"!="" {
					qui covrank `pr' `pw', rank(``vrank'')
					matrix results[`row',`col'] = r(cov)
				}
			}
		}
	}

	******************
	** SAVE RESULTS **
	******************
	if `"`using'"'!="" {
		qui di "
		`dit' `"Writing to "`using'"; may take several minutes"'
		local startcol_o = 3 // this one will stay fixed (column C)
		
		local titlecol = 1
		local startcol = 3
		local startrow = 10
		
		// Print information
		local date `c(current_date)'
		local titlesprint
		local titlerow = 3
		local titlecol = 1
		local titlelist country surveyyear authors date scenario group project // ppp baseyear cpibase cpisurvey ppp_calculated
		foreach title of local titlelist {
			returncol `titlecol'
			if "``title''"!="" & "``title''"!="-1" ///
				local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''")
			local titlecol = `titlecol' + 1
		}
	
		// Print version number on Excel sheet
		local versionprint A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'")
		
		// Export to Excel (matrices)
		returncol `startcol'
		local resultset `r(col)'`startrow'=matrix(results)
		
		// Export to Excel (column titles)
		local tcol = `startcol' + `incomes'
		local trow = `startrow' - 1
		foreach pr of local programcols {
			returncol `tcol'
			local titles `titles' `r(col)'`trow'=("`d_`pr''")
			local ++tcol
		}	
		
		// Print warning message on Excel sheet 
		local warningrow = 103
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
		local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 103.") 	

		// putexcel
		foreach vrank of local alllist {
			if "``vrank''"!="" {
				qui putexcel `titlesprint' `versionprint' `titles' `resultset' `warningprint' using `"`using'"', /// "
					modify keepcellformat sheet("`sheet'")
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
	

	**********
	** OPEN **
	**********
	if "`open'"!="" & "`c(os)'"=="Windows" {
		shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
	}
	else if "`open'"!="" & "`c(os)'"=="MacOSX" {
		shell open `using'
	}
	else if "`open'"!="" & "`c(os)'"=="Unix" {
		shell xdg-open `using'
	}
	
	**************
	** CLEAN UP **
	**************
	quietly putexcel clear
	restore // note this also restores svyset
	
end	// END ceqcov
