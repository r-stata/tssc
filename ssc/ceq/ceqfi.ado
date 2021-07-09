** ADO FILE FOR FISCAL IMPOVERISHMENT AND GAINS OF THE POOR SHEETS
**  OF CEQ MASTER WORKBOOK PART II

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v3.3 01jun2017 For use with May 2017 version of Output Tables
** v3.2 28mar2017 For use with Oct 2016 version of Output Tables
** v3.1 06feb2017 For use with Oct 2016 version of Output Tables
** v3.0 03feb2017 For use with Oct 2016 version of Output Tables
** v2.6 12jan2017 For use with Oct 2016 version of Output Tables
** v2.5 30sep2016 For use with Jun 2016 version of Output Tables
** v2.4 9aug2016 For use with Jun 2016 version of Output Tables
** v2.3 6jun2016 For use with Jun 2016 version of Output Tables
** v2.2 10feb2016 For use with Feb 2016 version of Output Tables
** v2.1 14dec2015 For use with Dec 7 2015 version of Output Tables
** v2.0 19nov2015 For use with Nov 19 2015 version of Output Tables
** v1.5 16oct2015 For use with Oct 4 2015 version of Output Tables
** v1.4 12oct2015 For use with Oct 4 2015 version of Output Tables
** v1.3 9oct2015 For use with Oct 4 2015 version of Output Tables
** v1.1 15sep2015 For use with Sep 4 2015 version of Output Tables
** v1.0 2sep2015 
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   3-28-2017 Fix cell alignment for income bins
**   2-06-2017 Fix bug introduced in Feb 3rd changes, pointed out by Sandra Martinez 
**              (fix omission of producing by income bin and correct poverty line local specfication on line 557)
**   2-03-2017 Fix bug for national poverty lines pointed out by Sandra Martinez
**			   Add printing user-specified poverty line to MWB, pointed out by Stephen Younger
** 	 1-12-2017 Set the data type of all newly generated variables to be double
** 			   Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**   9-30-2016 Print warning messages to MWB sheets
**			   Change from d1 command to `command' command in warning
**			   Changed warning contents and add exit when ppp option is not specified 
**			   Move up preserve and modify section to avoid issuing a wrong warning for negatives
**   8-09-2016 Change sort to sort, stable to ensure precision
**			   Change the way of checking excel extension so it works with files with "." in the 
**				the file names
**   6-06-2016 Keep needed variables only to increase speed
**	           Add ignoremissing option for missing values of income concepts 
**   2-10-2016 Fixed bug from deleting count_bin local 
**			   (bug pointed out by Stephen Younger)
**  12-14-2015 Added national extreme and moderate poverty lines
**  11-19-2015 Expanded the measures included on FI and FGP sheets to include 
**              FI headcount among post-fisc poor, FI per impoverished,
**              FI per impoverished as a proportion of income
**  10-16-2015 Fixed bug that occurred if didn't specify all income concepts
**  10-10-2015 Fixed errors from headcount, ... options (particular with normalized since it 
**              begins with no; had to change option to NORMalized)
**  10-09-2015 If none of headcount, ... options are specified, added default to produce
**              all results (previously if none specified it would encounter
**              -option fimatrices() required- error emssage, pointed out by Sandra
**              Martinez)
**			  Fixed unnecessary Excel looping now that I have returncol command

** NOTES

** TO DO

************************
** PRELIMINARY PROGRAMS *
************************
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol

// BEGIN _fifgp (Higgins 2015)
//  Calculates fiscal impoverishemnt and fiscal gains of the poor
//   measures for a specific poverty line and two income concepts
capture program drop _fifgp
program define _fifgp
	syntax varlist [aweight], ///
		fimatrices(string) fgmatrices(string) ///
		z(string) row(real) col(real) ///
		[HEADcount HEADCOUNTPoor TOTal PERcapita NORMalized ]
	local y0 = word("`varlist'",1)
	local y1 = word("`varlist'",2)
	
	local mat_list headcount headcountpoor total percapita normalized 
	foreach sheet in fi fg {
		local i=0
		foreach mat of local mat_list {
			if "``mat''"!="" {
				local ++i
				local `sheet'_`mat' = word("``sheet'matrices'",`i')
			}
		}
	}
	tempvar h_fi h_fg d_fi d_fg p_fi p_fg i_fi i_fg n_fi n_fg
	qui gen `h_fi' = (`y1' < `y0' & `y1' < `z') 
	qui gen `h_fg' = (`y0' < `y1' & `y0' < `z')
	qui gen `d_fi' = min(`y0',`z') - min(`y0',`y1',`z')
	qui gen `d_fg' = min(`y1',`z') - min(`y0',`y1',`z')
	qui gen `n_fi' = (min(`y0',`z') - min(`y0',`y1',`z'))/`z'
	qui gen `n_fg' = (min(`y1',`z') - min(`y0',`y1',`z'))/`z'
	qui gen `p_fi' = (`y1' < `z') // for FI it's post fisc poverty
	qui gen `p_fg' = (`y0' < `z') 
	qui gen `i_fi' = `d_fi'/`y0'
	qui gen `i_fg' = `d_fg'/`y0'
	
	foreach sheet in fi fg {        
		if "`headcount'"!="" {
			qui summ `h_`sheet'' [`weight' `exp'], meanonly
			matrix ``sheet'_headcount'[`row',`col'] = r(mean)
		}
		if "`headcountpoor'"!="" {
			qui summ `h_`sheet'' if `p_`sheet''==1 [`weight' `exp'] 
			matrix ``sheet'_headcountpoor'[`row',`col'] = r(mean)
		}
		if "`total'`percapita'`normalized'"!="" {
			qui summ `d_`sheet'' [`weight' `exp'], meanonly
			if "`total'"!="" matrix ``sheet'_total'[`row',`col'] = r(sum)
			if "`percapita'"!="" matrix ``sheet'_percapita'[`row',`col'] = r(mean)
			if "`normalized'"!="" {
				qui summ `n_`sheet'' [`weight' `exp'], meanonly
				matrix ``sheet'_normalized'[`row',`col'] = r(mean)
			}					
		}
	}
end // END _fifgp

*****************
** ceqfi PROGRAM *
*****************
** For sheet E6. Fisc. Impoverishment
// BEGIN ceqfi (Higgins 2015)
capture program drop ceqfi
program define ceqfi, rclass 
	version 13.0
	#delimit ;
	syntax 
		[using/]
		[if] [in] [pweight/] 
		[, 
			/** INCOME CONCEPTS: */
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			/** PPP CONVERSION */
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			/** SURVEY INFORMATION */
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname)  
			/** EXPORTING TO CEQ MASTER WORKBOOK: */
			SHEETFI(string)
			SHEETFG(string)
			OPEN
			/** POVERTY LINES */
			PL1(real 1.25)
			PL2(real 2.50)
			PL3(real 4.00)
			NATIONALExtremepl(string)   
			NATIONALModeratepl(string)  
			/** INFORMATION CELLS */
			COUNtry(string)
			SURVeyyear(string) /** string because could be range of years */
			AUTHors(string)
			BASEyear(real -1)
			SCENario(string)
			GROUp(string)
			PROJect(string)
			/** OTHER OPTIONS (left all even though NOBin is only relevant one, 
				just to avoid error message if they accidentally specify others as well) */
			NODecile
			NOGroup
			NOCentile
			NOBin
			HEADcount HEADCOUNTPoor TOTal PERcapita NORMalized 
			/** DROP MISSING VALUES */
			IGNOREMissing
		]
	;
	#delimit cr
	
	**********
	** LOCALS *
	**********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqfi
	local version 3.3
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
	local alllist_no_t = subinstr("`alllist'","t","",1)
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
	local varlist_no_t : list varlist - t // varlist without taxable income
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
	
	** results
	local supercols_all headcount headcountpoor total percapita normalized 
	if "`headcount'`headcontpoor'`total'`percapita'`normalized'"=="" {
		foreach x of local supercols_all {
			local `x' "`x'"
		}
	}
	local supercols `headcount' `headcountpoor' `total' `percapita' `normalized' 

	** print warning messages 
	local warning "Warnings"
	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** make sure all newly generated variables are in double format
	set type double 

	*****************
	** PARSE OPTIONS *
	*****************
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
	if "`sheetfi'"=="" local sheetfi "E5. Fisc. Impoverishment" // default name of sheet in Excel files
	if "`sheetfg'"=="" local sheetfg "E6. Fisc. Gains to the Poor"
	
	
	
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
	cap assert `pl1'<`pl2'<`pl3'
	if _rc {
		`die' "Group cut-off options must be specified such that {bf:PL1}<{bf:PL2}<{bf:PL3}"
		exit 198
	}	
	
	** NO... options
	if wordcount("`nogroup' `nobin'")==2 {
		`die' "Both options {bf:nogroup} and {bf:nobin} specified; no results to produce"
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
	
	************************
	** PRESERVE AND MODIFY *
	************************
	
	** collapse to hh-level data
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid', stable
		qui by `hhid': gen `members' = _N // # members in hh 
		qui by `hhid': drop if _n>1 // faster than duplicates drop
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
	
	** keep the variables used in ceqdes  
	foreach pl of local plopts {
		if "``pl''"!="" {
			if _`pl'_isscalar == 0 {
				local pl_tokeep `pl_tokeep' ``pl''
			}
		}
	}	
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
		foreach p of local plopts {
			tempvar `p'_ppp
			if substr("`p'",1,2)!="pl" {
				if "``p''"!="" qui gen ``p'_ppp' = (``p''/`divideby')*(1/`ppp_calculated')
			}
		}		
	}	
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	
	
	***************************
	** INCOME GROUPS AND BINS *
	***************************
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
				}
			}
		}
	}
	
	local group2 = 6
	if `_ppp' & "`nobin'"=="" local bin = `count_bins' // need if condition here b/c o.w. `count_bins' doesn't exist	
	
	**********************
	** CALCULATE RESULTS *
	**********************
	local already
	
	// Poverty results frontmatter
	if "`nogroup'"=="" {
		local pov_cols = wordcount("`alllist_no_t'")
		local pov_rows = 5 // socioeconomic groups
		matrix poverty = J(`pov_rows',`pov_cols',.)
		local col = 0
		foreach y0 of local alllist_no_t {
			local ++col
			if "``y0''"!="" {
				local zz=0
				foreach p of local plopts {
					local ++zz
					tempvar poor
					if "``p''"!="" {
						if substr("`p'",1,2)=="pl" { // these are the PPP lines
							local _pline = ``p''
							local y0touse ``y0'_ppp'
						}
						else if _`p'_isscalar==1  { // if pov line is scalar (not PPP line)
							local _pline = ``p'' // set `_pline' as that scalar and
							local y0touse ``y0''   // use original income variable
						}
						else if _`p'_isscalar==0 {    // if pov line is variable,
							tempvar `y0'_normalized  // create temporary variable that is income...
							qui gen ``y0'_normalized' = ``y0''/``p'' // normalized by pov line
							local y0touse ``y0'_normalized' // use normalized income in the calculations
							local _pline = 1                       // and normalized pov line is 1
						}
						gen `poor' = (`y0touse' < `_pline')
						summ `poor' `aw', meanonly
						matrix poverty[`zz',`col'] = r(mean)
					}
				}	
			}
		}
	}
	
	// Fiscal impoverishment 
	foreach y0 of local alllist_no_t {
		if "`y0'"=="f" continue
		local already `already' `y0'
		local y1list : list alllist_no_t - already // varlist has the variable names
		foreach sheet in fi fg {
			foreach suf in "" "_bins" {
				local `sheet'_mcs`suf' // set locals blank before loop below
			}
		}
		
		// this is outside of if condition because we need blank matrices for the rowsof() later
		local ncols = wordcount("`y1list'")
		foreach ss of local supercols_all {
			foreach sheet in fi fg {
				matrix `ss'_`sheet'_`y0' = J(5,`ncols',.) // a patch since later use rowsof() even if they specify suboptions
				if "`nobin'"=="" {
					matrix `ss'_`sheet'_`y0'_bins = J(`=`bin'-1',`ncols',.)
				}
			}
		}
			
		if "``y0''"!="" { 
			foreach ss of local supercols_all {
				foreach sheet in fi fg {
					if "``ss''"!="" {
						local `sheet'_mcs ``sheet'_mcs' `ss'_`sheet'_`y0'
						if "`nobin'"=="" {
							local `sheet'_mcs_bins ``sheet'_mcs_bins' `ss'_`sheet'_`y0'_bins
						}
					}
				}
			}
		
			local yy=0
			foreach y1 of local y1list {
				local ++yy
				if "``y1''"!="" {
					// GROUPS 
					if "`nogroup'"=="" {
						local zz=0
						foreach p of local plopts {
							local ++zz
							if "``p''"!="" {
								if substr("`p'",1,2)=="pl" { // these are the PPP lines
									local _pline = ``p''
									local y0touse ``y0'_ppp'
									local y1touse ``y1'_ppp'
								}
								else /* if _`p'_isscalar==1 */ { // if pov line is scalar (not PPP line)  
									local _pline  ``p'_ppp' // set `_pline' as that scalar or varname
									local y0touse ``y0'_ppp'   // use original income variable
									local y1touse ``y1'_ppp'
								}
								** else if _`p'_isscalar==0 { // if pov line is variable,
									** forval i=0/1 {
										** tempvar `y`i''_normalized  // create temporary variable that is income...
										** qui gen ``y`i''_normalized' = ``y`i'''/``p'' // normalized by pov line
										** local y`i'touse ``y`i''_normalized' // use normalized income in the calculations
									** }
									** local _pline = 1                       // and normalized pov line is 1
								** }
								_fifgp `y0touse' `y1touse' `aw', ///
									fimatrices(`fi_mcs') fgmatrices(`fg_mcs') ///
									z(`_pline') row(`zz') col(`yy') ///
									`supercols'
							}
						}	
					}
					// BINS
					if "`nobin'"=="" {
						local zz=0
						foreach z of numlist 0.05(0.05)10.00 10.25(0.25)50 100 {
							local ++zz
							_fifgp ``y0'_ppp' ``y1'_ppp' `aw', ///
								fimatrices(`fi_mcs_bins') fgmatrices(`fg_mcs_bins') ///
								z(`z') row(`zz') col(`yy') ///
								`supercols'				
						}
					}
				}
			}
		}
	}

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
		local startcol_o = 4
		
		** Poverty results
		if "`nogroup'"=="" {
			local startrow = 7
			returncol `startcol_o'
			foreach sheet in fi fg {
				local resultset_`sheet' `resultset_`sheet'' `r(col)'`startrow'=matrix(poverty)
			}
		}
		
		** Fiscal impoverishment results
		local vertincrement = 8
		local horzincrement = 3
		local rgroup = 17 // row where first group starts (note no deciles on this sheet)
		local rbin = `rgroup' + `vertincrement'
				
		foreach sheet in fi fg {
			local startcol = `startcol_o'
			foreach ss of local supercols_all {
				foreach y0 of local alllist_no_t {
					if "`y0'"=="f" continue
					returncol `startcol'
					if "`nogroup'"=="" & "``ss''"!="" local resultset_`sheet' `resultset_`sheet'' `r(col)'`rgroup'=matrix(`ss'_`sheet'_`y0') 
					if "`nobin'"==""   & "``ss''"!="" local resultset_`sheet' `resultset_`sheet'' `r(col)'`rbin'=matrix(`ss'_`sheet'_`y0'_bins)
					// still need to add columns to startcol even if "``ss''"=="":
					if "`nogroup'"=="" local startcol = `startcol' + colsof(`ss'_`sheet'_`y0') + `horzincrement'
					else               local startcol = `startcol' + colsof(`ss'_`sheet'_`y0'_bins) + `horzincrement' 
						// `ss'_fi_`y0' and `ss'_fi_`y0'_bins will have same # cols, but the if else is becauses the mx won't exist if the user
						//  specified the nogroup option
				}
			}
		}

		// Export to Excel (group cutoffs and poverty lines)
		local lowcol = 1 
		local hicol = 2
		foreach x in low hi {
			returncol ``x'col'
			local _`x'col `r(col)'
		}
		forval i=1/3 {
			foreach rg in 7 17 { // two rows where poverty lines start
				local therow = `rg' + `i' - 1
				local cutoffs `cutoffs' `_hicol'`therow'=(`pl`i'')
			}
		}
		
		// Print warning message on Excel sheet 
		local warningrow = 387
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
		local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 387.") 

		// putexcel   
		foreach sheet in fi fg {
			qui putexcel `titlesprint' `versionprint' `resultset_`sheet'' `warningprint' `cutoffs' using `"`using'"', modify keepcellformat sheet("`sheet`sheet''")
			qui di "
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
	*/
end	// END ceqfi
