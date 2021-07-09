** ADO FILE FOR POPULATION SHEET OF CEQ OUTPUT TABLES

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v3.8 07may2018 For use with Feb 2018 version of Output Tables
** v3.7 29jun2017 For use with July 2017 version of Output Tables
** v3.6 01jun2017 For use with June 2017 version of Output Tables
** v3.5 12jan2017 For use with Oct 2016 version of Output Tables
** v3.4 24sep2016 For use with Jun 2016 version of Output Tables
** v3.3 19aug2016 For use with Jun 2016 version of Output Tables
** v3.2 9aug2016 For use with Jun 2016 version of Output Tables
** v3.1 6jun2016 For use with Jun 2016 version of Output Tables
** v3.0 17nov2015 For use with Feb 2016 version of Output Tables
** v2.8 06oct2015 For use with Oct 4 2015 version of Output Tables
** v2.7 17sep2015 For use with Sep 4 2015 version of Output Tables
** v2.6 3sep2015 For use with Sep 3 2015 version of Output Tables
** v2.5 19aug2015 For use with Aug 14 2015 version of Output Tables
** v2.4 13aug2015 For use with Aug 14 2015 version of Output Tables
** v2.3 8jul2015 For use with July 2 2015 version of Output Tables
** v2.2 27jun2015 For use with June 12 2015 version of Output Tables
** v2.1 20jun2015 For use with June 12 2015 version of Output Tables
** v2.0 15jun2015 For use with June 12 2015 version of Output Tables 
** v1.11 28may2015 was dII.ado, for use with Jan 8 2015 version of Disaggregated Tables
** ... // omitting version information since name of ado file changed
** v1.0 20oct2014 
*! (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   05-07-2018 Fix issues with total amounts by decile
**   06-29-2017 Replacing covcon with improved version by Paul Corral
**	 06-01-2017 Add additional options to print meta-information
** 	 01-12-2017 Set the data type of all newly generated variables to be double
** 				Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**	  9-24-2016	Print warning messages to MWB sheets
**				Change from d1 command to `command' command in warning 
**				Add negatives option for allowing negative values of income concepts
**				Issue warning and not produce indicators for income concepts with negative values
**    8-19-2016 Include negative values of core income concepts in the first income group and bin
**    8-09-2016 Change sort to sort, stable to ensure number precision
**				Change the way of checking excel extension so it works with files with "." in the 
**				 the file names
**    6-06-2016 Keep needed variables only to increase speed
**	            Add ignoremissing option for missing values of income concepts 
**   11-17-2015 More efficient MWB: for results by decile and bin, only calculate 
**				Lorenz totals
**   10-06-2015 
**    9-17-2015 Fix open option so it works on Mac and Unix (bug pointed out by 
**               Sandra Martinez)
**    9-03-2015 Instead of old way of doing Excel columns, switched to Mata's 
**               numtobase26() function
**    8-19-2015 Fixed { required error that I introduced with PPP printing changes
**    8-13-2015 Print information in row 3
**    7-08-2015 Fixed problem I introduced when debugging quantiles issue 
**               (issue pointed out by Barbara Sparrow)
**    6-27-2015 Added version command and reporting version number
**              Add stable option to quantiles (discovered this after email about 
**               problem with different decile amounts from Sandra Martinez
**    6-19-2015 `"`using'"'.xlsx bug if `using' didn't contain ".xlsx"; changed to 
**               `"`using'.xlsx"'
**    6-15-2015 Separate ado file created for Population Sheet 
** ... // omiting prior changes history since name of ado file changed

** NOTES
**  Requires installation of -quantiles- (Osorio 2006)

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
end

*********************
** ceqconc PROGRAM **
*********************
** For sheet E10. Concentration
// BEGIN ceqconc (Higgins 2015)
capture program drop ceqconc
program define ceqconc, rclass 
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
			sheetm(string)
			sheetmp(string)
			sheetn(string)
			sheetg(string)
			sheett(string)
			sheetd(string)
			sheetc(string)
			sheetf(string)
			OPEN
			/** GROUP CUTOFFS */
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)
			/** INFORMATION CELLS */
			COUNtry(string)
			SURVeyyear(string) /** string because could be range of years */
			AUTHors(string)
			BASEyear(real -1)
			SCENario(string)
			GROUp(string)
			PROJect(string)
			/** OTHER OPTIONS */
			NODecile
			NOGroup
			NOCentile
			NOBin
			/** DROP MISSING VALUES */
			IGNOREMissing
			/** ALLOW NEGATIVE VALUES */
			NEGATIVES
		]
	;
	#delimit cr
	
	set seed 1234
	
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqconc
	local version 3.8
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
	
	** results
	local supercols totLCU totPPP pcLCU pcPPP shares cumshare
	
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
	
	** print warning messages on MWB
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

	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** make sure all newly generated variables are in double format
	set type double 
	
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
			local sheet`vrank' "E10.`_vrank' Concentration" // default name of sheet in Excel files
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
			if "`negatives'"=="" {
				if r(N) `dit' "Warning: `r(N)' negative values of ``v''. Concentration coefficient, redistributive effect, Reynolds-Smolensky and reranking effect thus not produced for ``v''. To produce specify {bf:negatives}"
				if r(N) local warning `warning' "Warning: `r(N)' negative values of ``v''. Concentration coefficient, redistributive effect, Reynolds-Smolensky and reranking effect thus not produced for ``v''. To produce specify the {negatives} option."
			}
			else if "`negatives'"!="" {
				if r(N) `dit' "Warning: `r(N)' negative values of ``v''. Concentration coefficient, redistributive effect, Reynolds-Smolensky and reranking effect are no longer well behaved"
				if r(N) local warning `warning' "Warning: `r(N)' negative values of ``v''. Concentration coefficient, redistributive effect, Reynolds-Smolensky and reranking effect are no longer well behaved."
			}
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
	// Mean, median, standard deviation, concentration coefficient, reranking, etc.
	matrix frontmatter_constant = J(3,`cols',.) // same for each E10 sheet
	foreach v of local alllist {
		if "``v''"!="" {
			local row = 1
			// Mean, median
			qui summ ``v'' `aw', d
			local mean = r(mean) // need this again later so save as local
			matrix frontmatter_constant[`row',`_`v''] = `mean' // mean
			local ++row
			matrix frontmatter_constant[`row',`_`v''] = r(p50) // median
			local ++row 
			local relativepl = 0.5*r(p50) // relative pov line, half median income
			// Standard deviation (accounting for complex sampling)
			// see http://www.stata.com/support/faqs/statistics/weights-and-summary-statistics/
			qui svy: mean ``v'' // svy incorporates weight automatically (use svy to get correct s.d.)
			matrix V_srs = e(V_srs) 
			scalar v_srs = V_srs[1,1]
			matrix frontmatter_constant[`row',`_`v''] = sqrt(e(N) * v_srs) // estimate of standard deviation
			local ++row
		}
	}
	** Ginis for redistributive effect, etc.
	foreach v of local alllist {
		if "``v''"!="" {
			qui covconc ``v'' `pw' // gini
			local gini`v' = r(gini)
		}
	}
	foreach vrank of local alllist {
		if "``vrank''"!="" {
			matrix frontmatter`vrank' = J(4,`cols',.) // changes with each E10 sheet
			foreach v of local alllist {
				if "``v''"!="" {
					// Concentration coef of `v' wrt `vrank'
					// if the user does not specify allowing negative values
					if "`negatives'"=="" {
						qui summ ``v''
						if r(min)<0 {
							matrix frontmatter`vrank'[1,`_`v''] = .
							local noindicator=1
						}
						else {
							qui covconc ``v'' `pw', rank(``vrank'') 
							matrix frontmatter`vrank'[1,`_`v''] = r(conc)
							local noindicator=0
						}
						// Not producing any indicators when negative values exist
						if `noindicator'==1 {   
							matrix frontmatter`vrank'[2,`_`v''] = .
							matrix frontmatter`vrank'[3,`_`v''] = .
							matrix frontmatter`vrank'[4,`_`v''] = .
						}
						if `noindicator'==0 {
							// Redistributive effect (different in Ginis)
							matrix frontmatter`vrank'[2,`_`v''] = `gini`vrank''-`gini`v''
							// Reynolds-Smolensky (= VE)
							matrix frontmatter`vrank'[3,`_`v''] = `gini`vrank''-r(conc)
							// Reranking effect
							matrix frontmatter`vrank'[4,`_`v''] = `gini`v''-r(conc)
						}
					}
					// if the user does specify allowing negative values
					else if "`negatives'"!="" {
						qui covconc ``v'' `pw', rank(``vrank'') 
						matrix frontmatter`vrank'[1,`_`v''] = r(conc)
						// Redistributive effect (different in Ginis)
						matrix frontmatter`vrank'[2,`_`v''] = `gini`vrank''-`gini`v''
						// Reynolds-Smolensky (= VE)
						matrix frontmatter`vrank'[3,`_`v''] = `gini`vrank''-r(conc)
						// Reranking effect
						matrix frontmatter`vrank'[4,`_`v''] = `gini`v''-r(conc)
					}
				}
			}
		}
	}
	
	// Rest of sheet
	// Note: mata used in some places below to vectorize things and increase efficiency
	foreach x in `_dec' `_group2' `_cent' `_bin' {
		mata: J`x' = J(1,``x'',1) // row vector of 1s to get column sums
		mata: tri`x' = lowertriangle(J(`=``x''+1',`=``x''+1',1)) // for cumulative shares
	}
	foreach vrank of local alllist {
		if "``vrank''"!="" {
			foreach x in `_dec' `_group2' {
				** create empty mata matrices for results
				foreach ss in totLCU pcLCU totPPP pcPPP {
					mata: C`vrank'_`ss'_`x' = J(``x'',`cols',.)
				}
				foreach ss in totLCU pcLCU totPPP pcPPP {
					mata: C`vrank'_`ss'_`x'_totalrow = J(1,`cols',.)
				}		
				
				foreach ss in shares cumshare {
					mata: C`vrank'_`ss'_`x' = J(`=``x''+1',`cols',.)
				}
				foreach v of local alllist {
					if "``v''"!=""  {	
						forval i=1/``x'' { // 1/100 for centiles, etc.
							** LORENZ
							// Lorenz LCU
							qui summ ``v'' if ``vrank'_`x'' == `i' `aw'
							if r(sum)==0 local mean = 0
							else local mean = `r(mean)'
							mata: C`vrank'_totLCU_`x'[`i',`_`v''] = `r(sum)'
							mata:  C`vrank'_pcLCU_`x'[`i',`_`v''] = `mean'
							if `_ppp' {
								// Lorenz PPP
								qui summ ``v'_ppp' if ``vrank'_`x''==`i' `aw'
								if r(sum)==0 local mean = 0
								else local mean = `r(mean)'
								mata: C`vrank'_totPPP_`x'[`i',`_`v''] = `r(sum)'
								mata:  C`vrank'_pcPPP_`x'[`i',`_`v''] = `mean'	
								
							}
						}

						qui summ ``v'' `aw'	
						if r(sum)==0 local mean = 0		
						else local mean = `r(mean)'	
						mata: C`vrank'_totLCU_`x'_totalrow[1,`_`v''] = `r(sum)'
						mata:  C`vrank'_pcLCU_`x'_totalrow[1,`_`v''] = `mean'	

						if `_ppp' {
							// Lorenz PPP
							qui summ ``v'_ppp' `aw'
							if r(sum)==0 local mean = 0
							else local mean = `r(mean)'
							mata: C`vrank'_totPPP_`x'_totalrow[1,`_`v''] = `r(sum)'
							mata:  C`vrank'_pcPPP_`x'_totalrow[1,`_`v''] = `mean'			
						}										
					}
				}
				** totals rows
				foreach ss in totLCU pcLCU totPPP pcPPP {
					* mata: C`vrank'_`ss'_`x'_totalrow = J`x'*C`vrank'_`ss'_`x'
					// add totals rows to matrix:
					mata: C`vrank'_`ss'_`x' = C`vrank'_`ss'_`x' \ C`vrank'_`ss'_`x'_totalrow 
				}

				foreach v of local alllist { // have to do it col by col due to possible missing values
					if "`v'"!="" {
						** shares matrix 
						// divide by the row vector of totals using matrix operations
						mata: C`vrank'_shares_`x'[.,`_`v''] = (C`vrank'_totLCU_`x'_totalrow[.,`_`v'']^-1)*C`vrank'_totLCU_`x'[.,`_`v'']
						** cumulative shares matrix
						mata: C`vrank'_cumshare_`x'[.,`_`v''] = tri`x'*C`vrank'_shares_`x'[.,`_`v'']
						mata: C`vrank'_cumshare_`x'[`=``x''+1',`_`v''] = C`vrank'_cumshare_`x'[``x'',`_`v''] // last row
					}
				}	

				** fiscal incidence
				mata: C`vrank'_fi_`vrank'_`x' = diag(C`vrank'_totLCU_`x'[.,`_`vrank'']:^-1)*C`vrank'_totLCU_`x' ///
					- J(`=``x''+1',`cols',1) // subtract off 1 so no change is 0%

				** residual progression - leave for later
				// Matrices from Mata to Stata
				foreach ss in `supercols' fi_`vrank' {
					mata: st_matrix("C`vrank'_`ss'_`x'",C`vrank'_`ss'_`x')
				}
			}
			foreach x in `_cent' `_bin' {
				** create empty mata matrices for results
				local ss totLCU
				mata: C`vrank'_`ss'_`x' = J(``x'',`cols',.)
				foreach v of local alllist {
					if "``v''"!="" {	
						forval i=1/``x'' { // 1/100 for centiles, etc.
							** LORENZ
							// Lorenz LCU
							qui summ ``v'' if ``vrank'_`x''==`i' `aw'
							mata: C`vrank'_totLCU_`x'[`i',`_`v''] = `r(sum)'
						}				
					}
				}
				** totals rows
				mata: C`vrank'_`ss'_`x'_totalrow = J`x'*C`vrank'_`ss'_`x'
				// add totals rows to matrix:
				mata: C`vrank'_`ss'_`x' = C`vrank'_`ss'_`x' \ C`vrank'_`ss'_`x'_totalrow 

				** residual progression - leave for later
				
				// Matrices from Mata to Stata
				mata: st_matrix("C`vrank'_`ss'_`x'",C`vrank'_`ss'_`x')
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
		
		// Export to Excel (matrices)
		local vertincrement = 3
		local horzincrement = 4
		local startcol_o = 4
		local resultset
		local rfrontmatter_constant = 9
		local rfrontmatter_specific = `rfrontmatter_constant' + 3
		local rdec   = 18 // row where decile results start
		local rgroup2 = `rdec' + `dec' + `vertincrement'
		local rcent  = `rgroup2' + `group2' + `vertincrement'
		local rbin   = `rcent' + `cent' + `vertincrement'
		foreach vrank of local alllist {
			if "``vrank''"!="" {
				local startpop = `startcol_o'
				returncol `startpop'
				local resultset`vrank' `resultset`vrank'' `r(col)'`rfrontmatter_constant'=matrix(frontmatter_constant)
				local resultset`vrank' `resultset`vrank'' `r(col)'`rfrontmatter_specific'=matrix(frontmatter`vrank')
				foreach x in `_dec' `_group2' {
					local startcol = `startcol_o'
					foreach ss in `supercols' fi_`vrank' {
						cap confirm matrix C`vrank'_`ss'_`x' // to deal with fi_`v' for ``v''==""
						if !_rc {
							returncol `startcol'
							local resultset`vrank' `resultset`vrank'' `r(col)'`r`x''=matrix(C`vrank'_`ss'_`x')
						}
						local startcol = `startcol' + `cols'
					}
				}
				foreach x in `_cent' `_bin' {
					local startcol = `startcol_o'
					local ss totLCU
					cap confirm matrix C`vrank'_`ss'_`x' // to deal with fi_`v' for ``v''==""
					if !_rc {
						returncol `startcol'
						local resultset`vrank' `resultset`vrank'' `r(col)'`r`x''=matrix(C`vrank'_`ss'_`x')
					}
					local startcol = `startcol' + `cols'
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
		
		// Export to Excel (group cutoffs)
		local lowcol = 1 
		local hicol = 2
		foreach x in low hi {
			returncol ``x'col'
			local _`x'col `r(col)'
		}
		forval i=1/6 {
			local therow = `rgroup2' + `i' - 1
			returncol `lowcol'
			if `i'==1 { 
				local cutoffs `cutoffs' `_hicol'`therow'=(`cut`i'')
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
				qui putexcel `titlesprint' `versionprint' `resultset`vrank'' `cutoffs' `warningprint' using `"`using'"', modify keepcellformat sheet("`sheet`vrank''")
				qui di "
			}
		}
	}
	
	// In return list
	foreach vrank of local alllist {
		if "``vrank''"!="" {
			foreach x in `_dec' `_group2' {
				foreach ss in `supercols' fi_`vrank' {
					return matrix C`vrank'_`ss'_`x' = C`vrank'_`ss'_`x'
					cap matrix drop C`vrank'_`ss'_`x'
				}
			}
			foreach x in `_cent' `_bin' {
				local ss totLCU
				return matrix C`vrank'_`ss'_`x' = C`vrank'_`ss'_`x'
				cap matrix drop C`vrank'_`ss'_`x'
			}
			cap matrix drop frontmatter`vrank'
		}
	}
	cap matrix drop frontmatter_constant
	
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
	
end	// END ceqconc
