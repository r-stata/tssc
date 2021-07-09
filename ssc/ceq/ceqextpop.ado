** ADO FILE FOR POPULATION SHEET OF CEQ OUTPUT TABLES

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.6 01jun2017 For use with July 2017 version of Output Tables
** v1.5 08mar2017 For use with Oct 2016 version of Output Tables
** v1.4 12jan2017 For use with Oct 2016 version of Output Tables
** v1.3 30oct2016 For use with Jun 2016 version of Output Tables 
** v1.2 01oct2016 For use with Jun 2016 version of Output Tables 
** v1.1 8aug2016 For use with Jun 2016 version of Output Tables 
** v1.0 6aug2016 For use with Jun 2016 version of Output Tables 
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   06-01-2017 Add additional options to print meta-information
**   03-08-2017 Remove the net in-kind transfers as a broad category in accordance with the instruction that users
**				 supply net in-kind transfer variables to health/education/otherpublic options
** 	 01-12-2017 Set the data type of all newly generated variables to be double
** 				Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**   10-30-2016 Fix bug with alltransfersp omitted from the broad categories
**	 10-01-2016	Print warning messages to MWB sheets 
**				Change from d1 command to `command' command in warning 
**				Add a check for open parentheses; changed from strrpos() to strpos() for compatibility
**				 with Stata 13.0		 
**				Fix bug with sheet E2c. results not being produced (bug reported by Sandra Martinez)
** 				Update to allow some indicators to be produced when ppp is not specified
**    8-26-2016 Change sort to sort, stable and gen to gen double to ensure precision
**              Include negative values of core income concepts in the first income group and bin
**    8-08-2016 Fix bug with v_dtaxes and v_contribs omitted from local programcols
**               (pointed out by Stephen Younger for ceqextend)

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
end // END returncol

**********************
** ceqextend PROGRAM *
**********************
** Quick and dirty way to fix too many variables problem: 
**  run the command separately for each income concep
capture program drop ceqextpop
program define ceqextpop
	#delimit ;
	syntax 
		[using]
		[if] [in] [pweight] 
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
			OPEN
			*
		]
	;
	#delimit cr
	
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqextpop
	local version 1.6
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org)"
	
	** income concept options
	#delimit ;
	local inc_opt
		market
		mpluspensions
		netmarket
		gross
		taxable
		disposable
		consumable
		final
	;
	#delimit cr
	local inc_opt_used ""
	foreach incname of local inc_opt {
		if "``incname''"!="" local inc_opt_used `inc_opt_used' `incname' 
	}
	foreach incname of local inc_opt_used {
		local `incname'_opt "`incname'(``incname'')" // `incname' will be e.g. market
			// and ``incname'' will be the varname 
	}
	
	** negative incomes
	foreach v of local inc_opt {
		if "``v''"!="" {
			qui count if ``v''<0 // note `v' is e.g. m, ``v'' is varname
			if r(N) `dit' "Warning: `r(N)' negative values of ``v''"
		}
	}	
	
	** Check if all income variables are in double format
	local inctypewarn
	foreach var of local inc_opt {         /* varlist2 so that all income concepts will be checked and displayed once */
		if "``var''"!="" {
			local vartype: type ``var''
			if "`vartype'"!="double" {
				if wordcount("`inctypewarn'")>0 local inctypewarn `inctypewarn', ``var''
				else local inctypewarn ``var''
			}
		}
	}
	if wordcount("`inctypewarn'")>0 `dit' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	if wordcount("`inctypewarn'")>0 local warning `warning' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	
	local counter=1
	local n_inc_opts = wordcount("`inc_opt_used'")
	foreach incname of local inc_opt_used {
		// preliminary: 
		//	to open only on last iteration of _ceqextend,
		//  only print warnings and messages once
		if "`open'"!="" & `counter'==`n_inc_opts' {
			local open_opt "open"
		}
		else {
			local open_opt ""
		}
		if `counter'==1 {
			local nodisplay_opt "" 
		}
		else {
			local nodisplay_opt "nodisplay"
		}
		
		local ++counter
	
		// let's do this:
		_ceqextpop `using' `if' `in' [`weight' `exp'], ///
			``incname'_opt' `options' `open_opt' `nodisplay_opt' ///
			_version("`version'") 
	}
end

**********************
** ceqextpop PROGRAM *
**********************
** For sheets E2b.m-E2b.f Ext. Population
// BEGIN _ceqextpop (Higgins 2016)
capture program drop _ceqextpop  
program define _ceqextpop, rclass 
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
			/** FISCAL INTERVENTIONS: */
			Pensions   (varlist)
			DTRansfers (varlist)
			DTAXes     (varlist) 
			CONTribs(varlist)
			SUbsidies  (varlist)
			INDTAXes   (varlist)
			HEALTH     (varlist)
			EDUCation  (varlist)
			OTHERpublic(varlist)
			USERFEESHealth(varlist)
			USERFEESEduc(varlist)
			USERFEESOther(varlist)
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
			GRoup(string)
			PROJect(string)
			/** OTHER OPTIONS */
			NODecile
			NOGroup
			NOCentile
			NOBin
			NODIsplay
			_version(string)
			/** DROP MISSING VALUES */
			IGNOREMissing
		]
	;
	#delimit cr
		
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit if "`nodisplay'"=="" display as text in smcl
	local die display as error in smcl
	local ditall display as text in smcl
	local command ceqextpop
	local version `_version'
	
	
	** income concepts
	local m `market'
	local mp `mpluspensions'
	local n `netmarket'
	local g `gross'
	local t `taxable'
	local d `disposable'
	local c `consumable'
	local f `final'
	local m2 `market2'
	local mp2 `mpluspensions2'
	local n2 `netmarket2'
	local g2 `gross2'
	local t2 `taxable2'
	local d2 `disposable2'
	local c2 `consumable2'
	local f2 `final2'
	local alllist m mp n g t d c f
	local incomes = wordcount("`alllist'")
	local origlist m mp n g d
	tokenize `alllist' // so `1' contains m; to get the variable you have to do ``1''
	local varlist ""
	local varlist2 ""
	local counter = 1
	
	foreach y of local alllist {
		local varlist `varlist' ``y'' // so varlist has the variable names
		local varlist2 `varlist2' ``y'2'
		// reverse tokenize:
		local _`y' = `counter' // so _m = 1, _mp = 2 (regardless of whether these options included)
		if "``y''"!="" local `y'__ `y' // so `m__' is e.g. m if market() was specified, "" otherwise
		local ++counter
	}
	
	local d_m      = "Market Income"
	local d_mp     = "Market Income + Pensions"
	local d_n      = "Net Market Income"
	local d_g      = "Gross Income"
	local d_t      = "Taxable Income"
	local d_d      = "Disposable Income"
	local d_c      = "Consumable Income"
	local d_f      = "Final Income"
	
	foreach y of local alllist {
		if "``y''"!="" {
			scalar _d_``y'' = "`d_`y''"
		}
	}
	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** make sure all newly generated variables are in double format
	set type double 
	
	** transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic ///
	                   userfeeshealth userfeeseduc userfeesother /*nethealth neteducation netother*/
	foreach x of local programlist {
		local allprogs `allprogs' ``x'' // so allprogs has the actual variable names
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
	
	
	** collapse to hh-level data         
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid', stable
		qui bys `hhid': gen `members' = _N // # members in hh 
		qui bys `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	** print warning messages on MWB
	local warning "Warnings"
	
	** Check if all fisc variables are in double format
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
	local relevar `varlist' `allprogs' `w' `hsize' `exp' `psu' `strata' 
	quietly keep `relevar' 
	
	** missing income concepts
	foreach var of local varlist2 {
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
		if "`ignoremissing'"!="" {
			if r(N) {
				qui drop if missing(`var')
				`dit' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
				local warning `warning' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified the ignoremissing option."
			}
		}
	}
	
	** columns including disaggregated components and broader categories
	local broadcats dtransfersp dtaxescontribs inkind /*netinkind*/ userfees alltaxes alltaxescontribs alltransfers alltransfersp
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	/*local netinkind `nethealth' `neteducation' `netother'*/
	local userfees `userfeeshealth' `userfeeseduc' `userfeesother'
	local alltransfers `dtransfers' `subsidies' `inkind'
	local alltransfersp `pensions' `dtransfers' `subsidies' `inkind' /*`userfees'*/
	local alltaxes `dtaxes' `indtaxes'
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	foreach cat of local programlist {
		if "``cat''"!="" {
			tempvar v_`cat' // in the locals section despite creating vars
			qui gen `v_`cat''=0 // because necessary for local programcols
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
		`health' `v_health' `education' `v_education' `otherpublic' `v_otherpublic' `v_inkind'
		/*`nethealth' `neteducation'  `netother' `v_netinkind'*/
		`v_alltransfers' `v_alltransfersp'
	;
	local taxcols: list programcols - transfercols; // set subtraction;
	#delimit cr

	** labels for fiscal intervention column titles
	foreach pr of local allprogs { // allprogs has variable names already
		local d_`pr' : var label `pr'
		if "`d_`pr''"=="" { // ie, if the var didnt have a label
			local d_`pr' `pr'
			`dit' "Warning: variable `pr' not labeled"
			local warning `warning' "Warning: variable `pr' not labeled."
		}
		scalar _d_`pr' = "`d_`pr''"
		if strpos("`d_`pr''","(")!=0 {
			if strpos("`d_`pr''",")")==0 {
				`die' "`d_`pr'' must have a closed parenthesis"
				exit 198
			}
		}
	}
	scalar _d_`v_pensions'         = "All contributory pensions"
	scalar _d_`v_dtransfers'       = "All direct transfers excl contributory pensions"
	scalar _d_`v_dtransfersp'      = "All direct transfers incl contributory pensions"
	scalar _d_`v_contribs'         = "All contributions"
	scalar _d_`v_dtaxes'           = "All direct taxes"
	scalar _d_`v_dtaxescontribs'   = "All direct taxes and contributions"
	scalar _d_`v_subsidies'        = "All indirect subsidies"
	scalar _d_`v_indtaxes'         = "All indirect taxes"
	scalar _d_`v_health'           = "Net health transfers"
	scalar _d_`v_education'        = "Net education transfers"
	scalar _d_`v_otherpublic'      = "Net other public transfers" // LOH need to fix that this is showing up even when I don't specify the option
	scalar _d_`v_inkind'           = "All net in-kind transfers"
	scalar _d_`v_userfeeshealth'   = "All health user fees"
	scalar _d_`v_userfeeseduc'     = "All education user fees"
	scalar _d_`v_userfeesother'    = "All other user fees"
	scalar _d_`v_userfees'	       = "All user fees"
	/* scalar _d_`v_netinkind'        = "All net inkind transfers"   scalar of specfic net inkind transfers created before */
	scalar _d_`v_alltransfers'     = "All net transfers and subsidies excl contributory pensions"
	scalar _d_`v_alltransfersp'    = "All net transfers and subsidies incl contributory pensions"
	scalar _d_`v_alltaxes'         = "All taxes"
	scalar _d_`v_alltaxescontribs' = "All taxes and contributions"
	
	** results
	local supercols totLCU totPPP pcLCU pcPPP shares cumshare
	foreach y of local alllist {
		if "``y''"!="" local supercols `supercols' fi_`y'
	}
	
	** titles 
	local _totLCU   = "LORENZ TOTALS (LCU)"
	local _totPPP   = "LORENZ TOTALS (US PPP DOLLARS)"
	local _pcLCU    = "LORENZ PER CAPITA (LCU)"
	local _pcPPP    = "LORENZ PER CAPITA (US PPP DOLLARS)"
	local _shares   = "LORENZ SHARES"
	local _cumshare = "LORENZ CUMULATIVE SHARES"
	foreach v of local alllist {
		local uppered = upper("`d_`v''")
		local _fi_`v' = "FISCAL INCIDENCE WITH RESPECT TO `uppered'"
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
			if "`vrank'"=="mp" local sheet`vrank' "E2b.m+p Ext. Population"
			else {
				local sheet`vrank' "E2b.`vrank' Ext. Population" // default name of sheet in Excel files
			}
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
		local warning `warning' "Warning: daily, monthly, or yearly options not specified; variables assumed to be in yearly local currency units"
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
	** if wordcount("`nodecile' `nogroup' `nocentile' `nobin'")==4 {
		** `die' "All options {bf:nodecile}, {bf:nogroup}, {bf:nocentile}, {bf:nobin} specified; no results to produce"
		** exit 198
	** }
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
	
	foreach y of local alllist {
		local marg`y' ``y''
	}	
	** create extended income variables
	foreach pr in `pensions' `v_pensions' { // did it this way so if they're missing loop is skipped over, no error
		foreach y in `m__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `mp__' `n__' `g__' `d__' `c__' `f__' { // t excluded bc unclear whether pensions included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `dtransfers' `v_dtransfers' {
		foreach y in `m__' `mp__' `n__' {
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `v_dtransfersp' {
		foreach y in `m__' { // can't include mp or n here bc they incl pens but not dtransfers
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''			
		}
	}
	foreach pr in `dtaxes' `v_dtaxes' `contribs' `v_contribs' `v_dtaxescontribs' {
		foreach y in `m__' `mp__' `g__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr' // written as minus since taxes thought of as positive values
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `n__' `t__' `d__' `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `subsidies' `v_subsidies' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `indtaxes' `v_indtaxes' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr' 
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `v_alltaxes' `v_alltaxescontribs' {
		foreach y in `m__' `mp__' `g__' `t__' { // omit n, d which have dtaxes subtr'd but not indtaxes
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''			
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr' 
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `health' `education' `otherpublic' ///
	`v_health' `v_education' `v_otherpublic' `v_inkind' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' `c__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `userfeeshealth' `v_userfeeshealth' `userfeeseduc' `v_userfeeseduc' `userfeesother' `v_userfeesother' `v_userfees' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' `c__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `f__' {  
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	/*foreach pr in `nethealth' `neteducation' `netother' `v_netinkind' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' `c__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}*/
	foreach pr in `v_alltransfers' {
		foreach y in `m__' `mp__' `n__' { // omit g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''		
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''		
		}
	}
	foreach pr in `v_alltransfersp' {
		foreach y in `m__' { // omit mplusp, n which have pensions, g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''		
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''		
		}		
	}

	** PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" {
				qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
				foreach ext of local marg`v' {
					tempvar `ext'_ppp
					qui gen ``ext'_ppp' = (`ext'/`divideby')*(1/`ppp_calculated')
				}
			}
		}	
	}
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	** check and issue warnings for negative values
	foreach y of local alllist {
		if "``y''"!="" {
			foreach v of local marg`y' {
				qui count if `v'<0
				local negcount=r(N)
				local _d_`v' = _d_`v'
				if `negcount'>0 {
					`ditall' "Warning: `_d_`v'' has `negcount' negative values."
					local warning `warning' "Warning: `_d_`v'' has `negcount' negative values."
				}
			}
		}
	}
	
	***************************************************
	** INCOME GROUPS AND BINS, DECILES, AND QUANTILES *
	***************************************************
	foreach y of local alllist {
		if "``y''"!="" foreach v of local marg`y' {
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
				if "`nogroup2'"=="" {
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
			if "`nocentile'"=="" qui quantiles `v' `aw', gen(``v'_cent') n(100) stable
			if "`nodecile'"==""  qui quantiles `v' `aw', gen(``v'_dec') n(10)   stable
		}
	}
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
			if "`nocentile'"=="" qui quantiles ``v'' `aw', gen(``v'_cent') n(100)
			if "`nodecile'"==""  qui quantiles ``v'' `aw', gen(``v'_dec') n(10)
		}
	}
	
	local group2 = 6
	local dec = 10
	local cent = 100
	
	if `_ppp' & "`nobin'"=="" local bin = `count_bins' // need if condition here b/c o.w. `count_bins' doesn't exist	
	
	**********************
	** CALCULATE RESULTS *
	**********************
	foreach x in `_dec' `_group2' `_cent' `_bin' {
		matrix J`x' = J(1,``x'',1) // row vector of 1s to get column sums
		foreach y of local alllist {
			if "``y''"!="" {
				foreach v of local marg`y' {
					matrix `x'_`v'pop = J(`=``x''+1',4,.)
				
					forval i=1/``x'' { // 1/10 for decile, etc.
						** POPULATIONS
						qui summ `one' if ``v'_`x''==`i'
						matrix `x'_`v'pop[`i',1] = r(sum)
						qui summ `one' if ``v'_`x''==`i' [aw=`hsize']
						matrix `x'_`v'pop[`i',2] = r(sum)
						qui summ `one' if ``v'_`x''==`i' [aw=`exp']  
						matrix `x'_`v'pop[`i',3] = r(sum)
						qui summ `one' if ``v'_`x''==`i' `aw'
						matrix `x'_`v'pop[`i',4] = r(sum)
					}	
					** TOTALS ROWS
					local i=``x''+1
					qui summ `one' 
					matrix `x'_`v'pop[`i',1] = r(sum)
					qui summ `one' [aw=`hsize']
					matrix `x'_`v'pop[`i',2] = r(sum)
					qui summ `one' [aw=`exp']
					matrix `x'_`v'pop[`i',3] = r(sum)
					qui summ `one' `aw'
					matrix `x'_`v'pop[`i',4] = r(sum)
				}
			}
		}
	}
	
	*****************
	** SAVE RESULTS *
	*****************
	`dit' `"Writing to "`using'"; may take several minutes"'
	// Column Titles
	local coltitle1 "Number of Households in Sample"
	local coltitle2 "Number of Individuals in Sample"
	local coltitle3 "Number of Households in Expanded Sample"
	local coltitle4 "Number of Individuals in Expanded Sample"
	
	// Export to Excel 
	foreach y of local alllist {
		local vertincrement = 4
		local horzincrement = 4
		local startcol_o = 4
		local resultset
		local incometitles`y'
		local coltitles`y'
		local trow = 8
		local coltrow = 9
		local rdec   = 11 // row where decile results start
		local rgroup2 = `rdec' + `dec' + `vertincrement'
		local rcent  = `rgroup2' + `group2' + `vertincrement'
		local rbin   = `rcent' + `cent' + `vertincrement'
		local startpop = `startcol_o'
		if "``y''"!="" {
			foreach ext of local marg`y' {
				returncol `startpop'
				// Matrices
				foreach x in `_dec' `_group2' `_cent' `_bin' {
					local resultset`y' `resultset`y'' `r(col)'`r`x''=matrix(`x'_`ext'pop)
				}
				// Titles
				local incometitles`y' `incometitles`y'' `r(col)'`trow'=(_d_`ext')
				forval r=1/4 {
					local mycol = `startpop' + `r' - 1
					returncol `mycol'
					local coltitles`y' `coltitles`y'' `r(col)'`coltrow'=("`coltitle`r''")
				}
				local startpop = `startpop' + `horzincrement'
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
		
	// Print warning message on Excel sheet 
	local warningrow = 503
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
	local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 503.") 
    	
	// Export to Excel (group cutoffs)
	local lowcol = 1 
	local hicol = 2
	foreach x in low hi {
		returncol ``x'col'
		local _`x'col `r(col)'
	}
	forval i=1/6 {
		local therow = `rgroup2' + `i' - 1
		if `i'==1 { 
				local cutoffs `cutoffs' `_hicol'`therow'=(`cut`i'')
		}
		else {
			local cutoffs `cutoffs' `_lowcol'`therow'=(`cut`=`i'-1'') `_hicol'`therow'=(`cut`i'')
		}
	}
	
	// putexcel
	foreach y of local alllist {
		if "``y''"!="" {
			qui putexcel `titlesprint' `versionprint' `incometitles`y'' ///
				`coltitles`y'' `resultset`y'' `cutoffs' `warningprint' using `"`using'"' /* " */ ///
				, modify keepcellformat sheet("`sheet`y''") // "
		}
	} 

	** // In return list
	** foreach x in `_dec' `_group' `_cent' `_bin' {
		** foreach v of local alllist {
			** if "``v''"!="" {
				** return matrix E`y'_`ss'_`x' = E`y'_`ss'_`x'
				** matrix drop E`y'_`ss'_`x'
			** }
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
	
end	// END ceqextpop
