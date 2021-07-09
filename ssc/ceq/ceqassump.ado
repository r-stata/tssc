** ADO FILE FOR POPULATION SHEET OF CEQ Master Workbook Section E

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.6 11jun2018 For use with July 2017 version of Output Tables
** v1.5 29jun2017 For use with July 2017 version of Output Tables
** v1.4 01jun2017 For use with June 2017 version of Output Tables
** v1.3 27mar2017 For use with Oct 2016 version of Output Tables
** v1.2 12jan2017 For use with Oct 2016 version of Output Tables
** v1.1 1oct2016 For use with Jun 2016 version of Output Tables
** v1.0 8aug2016 For use with Jun 2016 version of Output Tables
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   06-11-2018 Fix issue with income distribution by group
**   06-29-2017 Replacing covcon with improved version by Paul Corral
**	  06-01-2017 Add additional options to print meta-information
**    03-27-2017 Fix row alignmnet (bug pointed out by Sandra Martinez)
** 	  01-12-2017 Set the data type of all newly generated variables to be double
** 				 Add a check of the data type of income and fiscal variables and issue a warning if
**				  they are not double
**	  10-01-2016 Print warning messages to MWB sheets
**				 Change from d1 command to `command' command in warning 
**				 Update cells for plx() and for group cutoffs to be consistent with MWB
**               Update to allow some indicators to be produced when ppp is not specified
**				 Move up preserve and modify section to avoid issuing a wrong warning for negatives

** NOTES
**  Requires installation of -quantiles- (Osorio 2006) and -sgini- (Van Kerm 2010)

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



// BEGIN _theil 
// (code adapted from inequal7, Van Kerm 2001, revision of inequal, Whitehouse 1995)
capture program drop _theil
cap program define _theil, rclass sortpreserve
	syntax varname [if] [in] [pw fw aw iw]
	quietly {
		local var `varlist'
		preserve
		marksample touse
		qui keep if `touse'
		sort `var'
		qui count
		local N = r(N)
		if "`exp'"!="" {  
			local aw [aw`exp']
			local pw [pw`exp']
		}
		else {
			local aw ""
			local pw ""
		}
		foreach x in temp_theil i tmptmp {
			tempvar `x'
			qui gen ``x''=.
		}
		local wt = word("`exp'",2) // (word 1 is "=")
		if "`wt'"=="" {
			qui replace `i' = _n
			local wt = 1
		}
		else {
			qui replace `tmptmp' = sum(`wt')
			qui replace `i' = ((2*`tmptmp')-`wt'+1)/2
		}
		qui summ `var' `aw' if `var'>0
		local mean = r(mean)
		local sumw = r(sum_w)
		// note that the following two lines from inequal7 were changed
		// by Azevedo in ainequal and the two differ in the 3rd dec place
		qui replace `temp_theil' = sum(`wt'*((`var'/`mean')*(log(`var'/`mean'))))
		local theil = `temp_theil'[`N']/`sumw'
		return scalar theil = `theil'
		restore
	} // end quietly
end // END _theil

**********************
** ceqassump PROGRAM *
**********************
** For sheet E27. Assumption Testing
// BEGIN ceqassump (Higgins 2016)
capture program drop ceqassump
program define ceqassump, rclass 
	#delimit ;
	syntax varlist
		[using/]
		[if] [in] [pweight/] 
		[, 
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
			/* IGNOREMISSING */
			IGNOREMissing
		]
	;
	#delimit cr
	
	*************
	** VERSION **
	*************
	if `"`using'"'!="" /* " */ {
		version 13 
	} // needs to write to MWB
	else {
		version 10
	}
	
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqassump
	local version 1.6
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org)"
	
	** income concepts
	local cols = wordcount("`varlist'")
	tokenize `varlist' // so `1' contains m; to get the variable you have to do ``1''
	local counter = 1
	foreach y of local varlist {
		// reverse tokenize:
		local _`y' = `counter' // so _m = 1, _mp = 2 (regardless of whether these options included)
		local ++counter
	}
	
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
	
	** print warning messages on MWB
	local warning "Warnings"  
	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** make sure all newly generated variables are in double format
	set type double 

	** labels for column titles
	foreach var of local varlist { // allprogs has variable names already
		local d_`var' : var label `var'
		if "`d_`var''"=="" { // ie, if the var didnt have a label
			local d_`var' `var'
			`dit' "Warning: variable `var' not labeled"
			local warning `warning' "Warning: variable `var' not labeled"
			
		}
		scalar _d_`var' = "`d_`var''" // need it as scalr later
		if strpos("`d_`var''","(")!=0 {
			if strpos("`d_`var''",")")==0 {
				`die' "`d_`var'' must have a closed parenthesis"
				exit 198
			}
		}
	}
	
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
	
	** check if quantiles installed
	if "`nodecile'"=="" {
		cap which quantiles
		if _rc {
			`die' "{bf:quantiles} not installed; to install: {stata ssc install quantiles:ssc install quantiles}"
			exit
		}
	}
	
	** ado file specific
	if "`sheet'"=="" local sheet "E28. Assumption Testing" // default name of sheet in Excel files
	
	** weight (if they specified hhsize*hhweight type of thing)
	if strpos("`exp'","*")> 0 { // TBD: what if they premultiplied w by hsize?
		`die' "Please use the household weight in {weight}; this will automatically be multiplied by the size of household given by {bf:hsize}"
		exit
	}
	
	
	** ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "Warning: poverty results and results by group not produced since {bf:ppp} option not specified."
		local warning `warning' "Warning: poverty results and results by group not produced since ppp option not specified."
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
	if "`nodecile'"=="" local _dec dec
	if "`nogroup'"=="" & (`_ppp') local _group2 group2
	
	** make sure using is xls or xlsx
	cap putexcel clear
	if `"`using'"'!="" { // " 
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
	if strpos(`"`using'"'," ")>0 & "`open'"!="" { // " // has spaces in filename
		`dit' `"Warning: `"`using'"' contains spaces; {bf:open} option will not be executed. File can be opened manually after `command' runs."'
		local open "" // so that it won't try to open below
	}	
	
	** negative incomes
	foreach v of local varlist {
		qui count if `v'<0 // note `v' is e.g. m, `v' is varname
		if r(N) `dit' "Warning: `r(N)' negative values of `v'"
		if r(N) local warning `warning' "Warning: `r(N)' negative values of ``v''."
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
		sort `hhid'
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
		local warning `warning'"Warning: weights not specified in svydes or the command. Hence, equal weights (simple random sample) assumed."
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
	
	** keep the variables used in ceqdes   
	#delimit ;
	local relevar `varlist'    
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
		foreach v of local varlist {
			tempvar `v'_ppp
			qui gen ``v'_ppp' = (`v'/`divideby')*(1/`ppp_calculated')
		}
	}	
	
	** temporary variables
	tempvar one
	qui gen `one' = 1

	******************************
	** INCOME GROUPS AND DECILES *
	******************************
	foreach v of local varlist {
		** groups
		if `_ppp' {
			if "`nogroup'"=="" {
				tempvar `v'_group2
				qui gen ``v'_group2' = . 
				forval gp=1/6 {
					qui replace ``v'_group2' = `gp' if ``v'_ppp'>=`cut`=`gp'-1'' & ``v'_ppp'<`cut`gp''
					// this works because I set `cut0' = 0 and `cut6' = infinity
				}
			}
		}
		
		** deciles
		tempvar `v'_dec
		if "`nodecile'"==""  qui quantiles `v' `aw', gen(``v'_dec') n(10)   stable
	}
	
	local group2 = 6
	local dec = 10
	
	**********************
	** CALCULATE RESULTS *
	**********************
	// Mean, median, standard deviation, inequality measures, poverty measures
	matrix frontmatter = J(31,`cols',.)
	foreach v of local varlist {
		local row = 1
		// Mean, median
		qui summ `v' `aw', d
		local mean = r(mean) // need this again later so save as local
		matrix frontmatter[`row',`_`v''] = `mean' // mean
		local ++row
		matrix frontmatter[`row',`_`v''] = r(p50) // median
		local ++row 
		local relativepl = 0.5*r(p50) // relative pov line, half median income
		// Standard deviation (estimate of population standard deviation,
		//  accounting for complex sampling)
		// see http://www.stata.com/support/faqs/statistics/weights-and-summary-statistics/
		qui svy: mean `v' // svy incorporates weight automatically (use svy to get correct s.d.)
		matrix V_srs = e(V_srs) 
		scalar v_srs = V_srs[1,1]
		matrix frontmatter[`row',`_`v''] = sqrt(e(N) * v_srs) // estimate of standard deviation
		local ++row
		// Gini and absolute Gini
		qui covconc `v' `pw'
		matrix frontmatter[`row',`_`v''] = r(gini)
		local ++row
		matrix frontmatter[`row',`_`v''] = r(gini)*`mean'
		local ++row
		// Theil
		qui _theil `v' `pw'
		matrix frontmatter[`row',`_`v''] = r(theil)
		local ++row
		// 90/10
		_pctile `v' `pw', n(100) // note I tested and confirmed this method is faster than the example from MIT workshop
		matrix frontmatter[`row',`_`v''] = r(r90)/r(r10)
		local ++row
		// Poverty 
		if `_ppp' == 0 {
			if wordcount("`povlines'")>0 { // otherwise produces inequality only
				foreach p in `plopts' relativepl { // plopts includes all lines
					if "``p''"!="" {	
						forval i=0/2 {
							matrix frontmatter[`=`row'+`i'',`_`v''] = .
						}
					}
					local row = `row' + 3 // want to add three whether or not `p' option specified since those matrices are in the MWB
				}
			}
		}
		if `_ppp' == 1 {
			if wordcount("`povlines'")>0 { // otherwise produces inequality only
				foreach p in `plopts' relativepl { // plopts includes all lines
					if "``p''"!="" {	
						if substr("`p'",1,2)=="pl" { // these are the PPP lines
							local _pline = ``p''
							local vtouse ``v'_ppp'
						}
						else if _`p'_isscalar==1 {   // if pov line is scalar, // (note this local defined above)
							local _pline = ``p'' // set `_pline' as that scalar and
							local vtouse `v'   // use original income variable
						}
						else if _`p'_isscalar==0 { // if pov line is variable,
							tempvar `v'_normalized  // create temporary variable that is income...
							qui gen ``v'_normalized' = `v'/``p'' // normalized by pov line
							local _pline = 1                       // and normalized pov line is 1
							local vtouse ``v'_normalized' // use normalized income in the calculations
						}
					
						tempvar zyz0 zyz1 zyz2
						qui gen `zyz1' = max((`_pline'-`vtouse')/`_pline',0) // normalized povety gap of each individual
						qui gen `zyz0' = (`vtouse'<`_pline')                 // =1 if poor, =0 otherwise
						qui gen `zyz2' = `zyz1'^2                            // square of normalized poverty gap
					
						forval i=0/2 {
							qui summ `zyz`i'' `aw', meanonly // `if' `in' restrictions already taken care of by `touse' above
							matrix frontmatter[`=`row'+`i'',`_`v''] = r(mean)
						}
					}
					local row = `row' + 3 // want to add three whether or not `p' option specified since those matrices are in the MWB
				}
			}
		}
	}
	
	// Rest of sheet
	// Note: mata used in some places below to vectorize things and increase efficiency
	foreach x in `_dec' `_group2' { // separated _dec _group from _bin _centile since we decided to only have LCU total by bin and centile
		mata: J`x' = J(1,``x'',1) // row vector of 1s to get column sums
		** create empty mata matrices for results
		foreach ss in totLCU {
			mata: L_`ss'_`x' = J(``x'',`cols',.)
		}
		foreach v of local varlist {
			forval i=1/``x'' { // 1/100 for centiles, etc.
				** LORENZ
				// Lorenz LCU
				qui summ `v' if ``v'_`x''==`i' `aw'
				if r(sum)==0 local mean = 0
				else local mean = `r(mean)'
				mata: L_totLCU_`x'[`i',`_`v''] = `r(sum)'
			}				
		}
		** totals rows
		foreach ss in totLCU {
			mata: L_`ss'_`x'_totalrow = J`x'*L_`ss'_`x'
			// add totals rows to matrix:
			mata: L_`ss'_`x' = L_`ss'_`x' \ L_`ss'_`x'_totalrow 
			// matrix to Stata:
			mata: st_matrix("L_`ss'_`x'",L_`ss'_`x')
		}
	}
	
	*******************
	** PRINT RESULTS **
	*******************
	local mat_list "frontmatter" 
	foreach x in `_dec' `_group2' {
		local mat_list `mat_list' L_totLCU_`x'
	}
	local colname_list ""
	foreach v of local varlist {
		local colname_list `" `colname_list' "`v'" "' // "
	}
	foreach mat of local mat_list {
		matrix colnames `mat' = `colname_list'
	}
	// finish this later so results can also be printed on screen
	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" {
		qui di "
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
		local vertincrement = 3
		local horzincrement = 4
		local startcol_o = 4
		local resultset
		local rfrontmatter = 9
		local rdec   = 43 // row where decile results start
		local rgroup2 = `rdec' + `dec' + `vertincrement' + 1
		local startpop = `startcol_o'
		returncol `startpop'
		local resultset `resultset' `r(col)'`rfrontmatter'=matrix(frontmatter)
		foreach x in `_dec' `_group2' {
			local startcol = `startcol_o'
			foreach ss in totLCU {
				returncol `startcol'
				cap confirm matrix L_`ss'_`x' // to deal with fi_`v' for `v'==""
				if !_rc local resultset `resultset' `r(col)'`r`x''=matrix(L_`ss'_`x')
				local startcol = `startcol' + `cols'
			}
		}
		
		// Export to Excel (column titles)
		local trow = 8
		local coltitles
		local col = `startcol_o'
		foreach v of local varlist {
			returncol `col' 
			local coltitles `coltitles' `r(col)'`trow'=(_d_`v')
			local ++col
		}	
		
		// Export to Excel (group cutoffs and poverty lines)
		local lowcol = 1 
		local hicol = 2
		foreach x in low hi {
			returncol ``x'col'
			local _`x'col `r(col)'
		}
		forval i=1/6 {
			local therow = `rgroup2' + `i' - 1
			if (`i' < 6) {
				local cutoffi_lo = "`_lowcol'`therow'=(`cut`=`i'-1'')"
				local cutoffi_hi = "`_hicol'`therow'=(`cut`i'')"
			}
			else {
				local final_cutoff = "`cut5' And More"
				local cutoffi_lo   = `"`_lowcol'`therow'=("`final_cutoff'")"'
			}
			local cutoffi = `"`cutoffi_lo' `cutoffi_hi'"'
			local cutoffs = `"`cutoffs' `cutoffi'"'
		}
		local rpovlines = 16 
		forval i=1/3 {
			local cutoffs `cutoffs' `_lowcol'`rpovlines'=(`pl`i'')
			local rpovlines = `rpovlines'+3
		}
		
		// Print warning message on Excel sheet 
		local warningrow = 65
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
		local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 65.") 
		
		// putexcel
		qui putexcel `titlesprint' `versionprint' `coltitles' `warningprint' `resultset' `cutoffs' using `"`using'"', modify keepcellformat sheet("`sheet'")
		qui di "
	}
	
	// In return list
	return matrix frontmatter = frontmatter
	foreach x in `_dec' `_group2' {
		foreach ss in totLCU {
			cap confirm matrix L_`ss'_`x'
			if !_rc {
				return matrix L_`ss'_`x' = L_`ss'_`x' // auto drops matrix
			}
		}
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
	
end	// END ceqassump
