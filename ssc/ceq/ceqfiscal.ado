** ADO FILE FOR FISCAL INTERVENTIONS SHEET OF CEQ OUTPUT TABLES

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v5.1 07may2018 For use with Feb 2018 version of Output Tables
** v5.0 029jun2017 For use with July 2017 version of Output Tables
** v4.9 01jun2017 For use with May 2017 version of Output Tables
** v4.8 22may2017 For use with Oct 2016 version of Output Tables
** v4.7 16may2017 For use with Oct 2016 version of Output Tables
** v4.6 06apr2017 For use with Oct 2016 version of Output Tables
** v4.5 08mar2017 For use with Oct 2016 version of Output Tables
** v4.4 12jan2017 For use with Oct 2016 version of Output Tables
** v4.3 30oct2016 For use with Jun 2016 version of Output Tables 
** v4.2 01oct2016 For use with Jun 2016 version of Output Tables 
** v4.1 19aug2016 For use with Jun 2016 version of Output Tables
** v4.0 8aug2016 For use with Jun 2016 version of Output Tables
** v3.2 6jun2016 For use with Jun 2016 version of Output Tables
** v3.1 27dec2015 For use with Feb 2016 version of Output Tables
** v3.0 17nov2015 For use with Nov 4 2015 version of Output Tables
** v2.8 28sep2015 For use with Sep 4 2015 version of Output Tables
** v2.7 17sep2015 For use with Sep 4 2015 version of Output Tables
** v2.6 3sep2015 For use with Sep 3 2015 version of Output Tables
** v2.5 13aug2015 For use with Aug 14 2015 version of Output Tables
** v2.4 07aug2015 For use with Aug 5 2015 version of Output Tables
** v2.3 08jul2015 For use with July 2 2015 version of Output Tables
** v2.2 27jun2015 For use with July 2 2015 version of Output Tables
** v2.1 20jun2015 For use with June 12 2015 version of Output Tables
** v2.0 15jun2015 For use with June 12 2015 version of Output Tables 
** v1.11 28may2015 was dII.ado, for use with Jan 8 2015 version of Disaggregated Tables
** ... // omitting version information since name of ado file changed
** v1.0 20oct2014 
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   05-07-2018 Fix issues with total amounts by decile
**   06-29-2017 Replacing covconc with improved version by Paul Corral
**   06-09-2017 Chaning locals prior to(5-27-2017) with group in name to group2
**   05-27-2017 Add additional options to print meta-information
**   05-22-2017 Mata calculation of fiscal incidence had a bug (pointed out by Esmeralda Shehaj)
**   05-16-2017 Fix name of command mistake
**   04-06-2017 Remove the temporary variables from the negative tax warning list 
**   03-08-2017 Remove the net in-kind transfers as a broad category in accordance with the instruction that users
**				 supply net in-kind transfer variables to health/education/otherpublic options
** 	 01-12-2017 Set the data type of all newly generated variables to be double
** 				Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**   10-30-2016 Fix bug with alltransfersp omitted from the broad categories
**	 10-01-2016	Print warning messages to MWB sheets 
**			    Add a check for open parentheses; changed from strrpos() to strpos() for compatibility
**				 with Stata 13.0
**				Add negatives option allowing concentration coefficient and kakwani index to
**	     		 be produced for incomes and fiscal interventions with negative values 
**				Change from d1 command to `command' command in warning 
**				Change title printing to include income concepts in the title row
**			    Update to allow some indicators to be produced when ppp is not specified
**    8-19-2016 Include negative values of core income concepts in the first income group and bin
**    8-09-2016 Change sort to sort, stable and gen to gen double to ensure precision
**				Change the way of checking excel extension so it works with files with "." in the 
**				 the file names
**	  8-08-2016 Add three new options for user fees and update corresponding broad categories 
**				Produce warnings and not produce concentration coefficient and kakwani index for 
**	     		 incomes and fiscal interventions with negative values 
**    6-06-2016 Keep needed variables only to increase speed
**	            Add ignoremissing option for missing values of income concepts and 
**			     fiscal interventions
**   12-27-2015 Add broad categories for all direct taxes, all contributions, health, education
**   11-17-2015 More efficient MWB: for results by decile and bin, only calculate 
**				Lorenz totals
**    9-28-2015 Fix error where poverty line was being printed as blank if they 
**               didn't specify it (pointed out separately by Maynor Cabrera and 
**               Luciana de la Flor)
**    9-17-2015 Fix open option so it works on Mac and Unix (bug pointed out by 
**               Sandra Martinez)
**    9-03-2015 Instead of old way of doing Excel columns, switched to Mata's 
**               numtobase26() function
**    8-13-2015 Print information in row 3
**    8-07-2015 Was missing two broad categories: indirect taxes and indirect subsidies
**               (pointed out by Rodrigo Aranda and Luis Felipe Munguia)
**    7-08-2015 Fixed columns bug if >26^2 columns needed (i.e. columns extend beyond
**               AZ to AAA,AAB,... in Excel
**    6-27-2015 Added version command and reporting version number
**              Add stable option to quantiles (discovered this after email about 
**               problem with different decile amounts from Sandra Martinez
**    6-19-2015 `"`using'"'.xlsx bug if `using' didn't contain ".xlsx"; changed to 
**               `"`using'.xlsx"'
**    6-15-2015 Separate ado file created for each sheet
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
end // END returncol


**********************
** ceqfiscal PROGRAM *
**********************
** For sheet E10. Concentration
// BEGIN ceqfiscal (Higgins 2015)
capture program drop ceqfiscal
program define ceqfiscal, rclass 
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
			GROUp(string)
			PROJect(string)
			/** OTHER OPTIONS */
			NODecile
			NOGroup
			NOCentile
			NOBin
			/** VARIABLE MODIFICATON */
			IGNOREMissing
			/** ALLOW NEGATIVE VALUES */
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
	local command ceqfiscal
	local version 5.1
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
	
	** transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic userfeeshealth userfeeseduc userfeesother ///
					   /*nethealth neteducation netother */
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
	local alltransfers `dtransfers' `subsidies' `inkind' /*`userfees' */
	local alltransfersp `pensions' `dtransfers' `subsidies' `inkind' /*`userfees'*/
	local alltaxes `dtaxes' `indtaxes' // user fees are not included as tax
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	
	foreach cat of local programlist {
		if "``cat''"!="" {
			tempvar v_`cat' // in the locals section despite creating vars
			qui gen double `v_`cat''=0 // because necessary for local programcolsc 
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
			qui gen double `v_`bc'' = 0 
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
	local cols = wordcount("`programcols'") + 1 // + 1 for income column

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
	/* scalar _d_`v_netinkind'        = "All net inkind transfers"   scalar of specfic net inkind transfers created before */
	local d_`v_userfeeshealth'   = "All health user fees"
	local d_`v_userfeeseduc'     = "All education user fees"
	local d_`v_userfeesother'    = "All other user fees"
	local d_`v_userfees'	     = "All user fees"
	local d_`v_alltransfers'     = "All net transfers and subsidies excl contributory pensions"
	local d_`v_alltransfersp'    = "All net transfers and subsidies incl contributory pensions"
	local d_`v_alltaxes'         = "All taxes"
	local d_`v_alltaxescontribs' = "All taxes and contributions"
	
	** results
	local supercols totLCU totPPP pcLCU pcPPP shares cumshare 
	local colsneeded = (wordcount("`supercols'") + 8)*`cols' // +8 is for fi matrices for each income concept
	
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
			local sheet`vrank' "E11.`_vrank' FiscalInterventions" // default name of sheet in Excel files
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
			if r(N) {
				if "`negatives'"=="" {
					`dit' "Warning: `r(N)' negative values of ``v''. Concentration Coefficient and Kakwani Index not produced. To produce specify the option {bf:negatives}"
					local warning `warning' "Warning: `r(N)' negative values of ``v''. Concentration Coefficient and Kakwani Index not produced. To produce specify the option {negatives}."
				}
				if "`negatives'"!="" {
					`dit' "Warning: `r(N)' negative values of ``v''. Concentration Coefficient and Kakwani Index are not well behaved."
					local warning `warning' "Warning: `r(N)' negative values of ``v''. Concentration Coefficient and Kakwani Index are not well behaved."
				}
			}
		}
	}	
	
	** negative fiscal interventions
	foreach pr of local programcols {
		if "`pr'"!="" {
			qui summ `pr'
			if r(mean)>0 {		
				qui count if `pr'<0
				local negcount = r(N)
				if `negcount'>0 {
					if "`negative'"=="" {
						`dit' "Warning: `negcount' negative values of `d_`pr''. Concentration Coefficient and Kakwani Index not produced. To produce specify the option {bf:negatives}."
						local warning `warning' "Warning: `negcount' negative values of `d_`pr''. Concentration Coefficient and Kakwani Index not produced. To produce specify the option {negatives}."
					}
					if "`negatives'"!="" {
						`dit' "Warning: `negcount' negative values of `d_`pr''. Concentration Coefficient and Kakwani Index are not well behaved."
						local warning `warning' "Warning: `negcount' negative values of `d_`pr''. Concentration Coefficient and Kakwani Index are not well behaved."
					}
				}
			}
			else {
				qui count if `pr'>0
				local negcount = r(N)
				if `negcount'>0 {
					if "`negative'"=="" {
						`dit' "Warning: `negcount' positive values of `d_`pr'' (variable stored as negative values). Concentration Coefficient and Kakwani Index not produced. To produce specify the option {bf:negatives}."
						local warning `warning' "Warning: `negcount' positive values of `d_`pr'' (variable stored as negative values). Concentration Coefficient and Kakwani Index not produced. To produce specify the option {negatives}."
					}
					if "`negatives'"!="" {
						`dit' "Warning: `negcount' positive values of `d_`pr'' (variable stored as negative values). Concentration Coefficient and Kakwani Index are not well behaved."
						local warning `warning' "Warning: `negcount' positive values of `d_`pr'' (variable stored as negative values). Concentration Coefficient and Kakwani Index are not well behaved."
					}
				}
			}
		}
	}

	***********************
	** OTHER MODIFICATION *
	***********************
	
	** separate warning so that the temporary variables do not show on the command screen
	if wordcount("`allprogs'")>0 ///
	foreach tax of local taxlist {
		foreach pr in ``tax'' {
			qui summ `pr', meanonly
			if r(mean)>0 {
				if wordcount("`taxwarning'")>0 local taxwarning `taxwarning', `pr'
				else local taxwarning `pr'
			}	
		}
	}
	if wordcount("`taxwarning'")>0 {
		`dit' "Taxes appear to be positive values for variable(s) `taxwarning'; replaced with negative for calculations"
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
	// Mean, median, standard deviation, concentration coefficient, reranking, etc.
	foreach v of local alllist {
		if "``v''"!="" {
			matrix frontmatter`v' = J(5,`cols',.) // changes with each E11 sheet
			local col = 1
			// Gini for Kakwani
			qui covconc ``v'' `pw'
			local gini`v' = r(gini)
			foreach pr in ``v'' `programcols' { // already varnames
				local row = 1
				// Mean, median
				qui summ `pr' `aw', d
				local mean = r(mean) // need this again later so save as local
				matrix frontmatter`v'[`row',`col'] = `mean' // mean
				local ++row
				matrix frontmatter`v'[`row',`col'] = r(p50) // median
				local ++row 
				// Standard deviation (accounting for complex sampling)
				// see http://www.stata.com/support/faqs/statistics/weights-and-summary-statistics/
				qui svy: mean `pr' // svy incorporates weight automatically (use svy to get correct s.d.)
				matrix V_srs = e(V_srs) 
				scalar v_srs = V_srs[1,1]
				matrix frontmatter`v'[`row',`col'] = sqrt(e(N) * v_srs) // estimate of standard deviation
				local ++row
				qui summ `pr'
				if r(mean)>0 {
					qui count if `pr'<0
					local negcount = r(N)
				}
				else {
					qui count if `pr'>0
					local negcount = r(N)
				}
				if `negcount'>0 {
					if "`negatives'"=="" {
						matrix frontmatter`v'[`row',`col'] = .
						local nokakwani=1
					}
					if "`negatives'"!="" {
						qui covconc `pr' `pw', rank(``v'')
						matrix frontmatter`v'[`row',`col'] = r(conc)
						local nokakwani=0
					}
				}
				else {
					qui covconc `pr' `pw', rank(``v'')
					matrix frontmatter`v'[`row',`col'] = r(conc)
					local nokakwani=0 
				}
				local ++row
				
				// Kakwani (Kakwani_transfer is -Kakwani_transfer)
				if `nokakwani'==1 {
					matrix frontmatter`v'[`row',`col'] = .
				}
				if `nokakwani'==0 {
					if strpos("`transfercols'","`pr'") { // i.e., if a transfer
						matrix frontmatter`v'[`row',`col'] = `gini`v'' - r(conc)
					}
					else { // a tax
						matrix frontmatter`v'[`row',`col'] = r(conc) - `gini`v''
					}
				}
				local ++col
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
					mata: I`vrank'_`ss'_`x' = J(``x'',`cols',.)
				}
				foreach ss in totLCU pcLCU totPPP pcPPP {
					mata: I`vrank'_`ss'_`x'_totalrow = J(1,`cols',.)
				}					
				foreach ss in shares cumshare {
					mata: I`vrank'_`ss'_`x' = J(`=``x''+1',`cols',.)
				}
				local col = 1
				foreach pr in ``vrank'' `programcols' {
					if "`pr'"!="" {	
						forval i=1/``x'' { // 1/100 for centiles, etc.
							foreach var of varlist `pr' {
								local varname "`var'"
							}
							** CONCENTRATION
							// Concentration totals LCU
							qui summ `pr' if ``vrank'_`x''==`i' `aw'
							if r(sum)==0 local mean = 0
							else local mean = `r(mean)'
							mata: I`vrank'_totLCU_`x'[`i',`col'] = `r(sum)'
							mata:  I`vrank'_pcLCU_`x'[`i',`col'] = `mean'
							if `_ppp' {
								// Concentration totals PPP
								if strpos("`market'`mpluspensions'`netmarket'`gross'`taxable'`disposable'`consumable'`final'","`varname'")!=0 {
									qui summ ``vrank'_ppp' if ``vrank'_`x''==`i' `aw'
								}
								else {
									qui summ ``pr'_ppp' if ``vrank'_`x''==`i' `aw'
								}
								if r(sum)==0 local mean = 0
								else local mean = `r(mean)'
								mata: I`vrank'_totPPP_`x'[`i',`col'] = `r(sum)'
								mata:  I`vrank'_pcPPP_`x'[`i',`col'] = `mean'						
							}
						}

						qui summ `pr' `aw'	
						if r(sum)==0 local mean = 0		
						else local mean = `r(mean)'	
						mata: I`vrank'_totLCU_`x'_totalrow[1,`col'] = `r(sum)'
						mata:  I`vrank'_pcLCU_`x'_totalrow[1,`col'] = `mean'	
						if `_ppp' {
							// Lorenz PPP
							qui summ ``pr'_ppp' `aw'
							if r(sum)==0 local mean = 0
							else local mean = `r(mean)'
							mata: I`vrank'_totPPP_`x'_totalrow[1,`col'] = `r(sum)'
							mata:  I`vrank'_pcPPP_`x'_totalrow[1,`col'] = `mean'			
						}					
					}
					local ++col
				}

				** totals rows
				foreach ss in totLCU pcLCU totPPP pcPPP {
					* mata: I`vrank'_`ss'_`x'_totalrow = J`x'*I`vrank'_`ss'_`x' 
					// add totals rows to matrix:
					mata: I`vrank'_`ss'_`x' = I`vrank'_`ss'_`x' \ I`vrank'_`ss'_`x'_totalrow  
				}
				local col = 1
				foreach pr in ``v'' `programcols' { 
					** shares matrix 
					// divide by the row vector of totals using matrix operations
					mata: I`vrank'_shares_`x'[.,`col'] = (I`vrank'_totLCU_`x'_totalrow[.,`col']^-1)*I`vrank'_totLCU_`x'[.,`col']
					** cumulative shares matrix
					mata: I`vrank'_cumshare_`x'[.,`col'] = tri`x'*I`vrank'_shares_`x'[.,`col']
					mata: I`vrank'_cumshare_`x'[`=``x''+1',`col'] = I`vrank'_cumshare_`x'[``x'',`col'] // last row
					local ++col
				}	
				** fiscal incidence
				mata: I`vrank'_fi_`vrank'_`x' = diag(I`vrank'_totLCU_`x'[.,1]:^-1)*I`vrank'_totLCU_`x' 
					// should be [.,1] not [,`_`vrank''] because first column of I`vrank'_totLCU_`x' has total `vrank' income
					//  (fixed May 22, 2017)

				// Matrices from Mata to Stata
				foreach ss in `supercols' fi_`vrank' {
					mata: st_matrix("I`vrank'_`ss'_`x'",I`vrank'_`ss'_`x')
				}
			}
			foreach x in `_cent' `_bin' {
				** create empty mata matrices for results
				local ss totLCU
				mata: I`vrank'_`ss'_`x' = J(``x'',`cols',.)
				local col = 1
				foreach pr in ``vrank'' `programcols' {
					if "`pr'"!="" {	
						forval i=1/``x'' { // 1/100 for centiles, etc.
							** CONCENTRATION
							// Concentration totals LCU
							qui summ `pr' if ``vrank'_`x''==`i' `aw'
							mata: I`vrank'_totLCU_`x'[`i',`col'] = `r(sum)'
						}				
					}
					local ++col
				}
				** totals rows
				mata: I`vrank'_`ss'_`x'_totalrow = J`x'*I`vrank'_`ss'_`x'
				// add totals rows to matrix:
				mata: I`vrank'_`ss'_`x' = I`vrank'_`ss'_`x' \ I`vrank'_`ss'_`x'_totalrow 
				local col = 1

				// Matrices from Mata to Stata
				mata: st_matrix("I`vrank'_`ss'_`x'",I`vrank'_`ss'_`x')
			}
		}
	}
	
	// Population totals 
	foreach x in `_dec' `_group2' `_cent' `_bin' {
		mata: J`x' = J(1,``x'',1) // row vector of 1s
		foreach v of local alllist {
			if "``v''"!="" {
				mata: `x'_`v'pop = J(``x'',1,.)
				forval i=1/``x'' {
					qui summ `one' if ``v'_`x''==`i' `aw'
					mata: `x'_`v'pop[`i',1] = `r(sum)'
				}
				mata: `x'_`v'pop_total = J`x'*`x'_`v'pop[`i',1]
				mata: `x'_`v'pop = `x'_`v'pop \ `x'_`v'pop_total
				mata: `x'_`v'popshare = (`x'_`v'pop_total^-1)*`x'_`v'pop
				mata: `x'_`v'pop = `x'_`v'pop , `x'_`v'popshare
				mata: st_matrix("`x'_`v'pop",`x'_`v'pop)
			}
		}
	}

	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" {
		qui di "
		`dit' `"Writing to "`using'"; may take several minutes"'
		// Locals for Excel columns
		local startcol_o = 4 // this one will stay fixed (column D)
		
		// Export to Excel (matrices)
		local vertincrement = 3
		local horzincrement = 4
		local startcol_o = 6
		local resultset
		local rfrontmatter = 9
		local rdec   = 16 // row where decile results start
		local rgroup2 = `rdec' + `dec' + `vertincrement'
		local rcent  = `rgroup2' + `group2' + `vertincrement'
		local rbin   = `rcent' + `cent' + `vertincrement'
		foreach vrank of local alllist {
			if "``vrank''"!="" {
				local startpop = `startcol_o'
				returncol `startpop'
				local resultset`vrank' `resultset`vrank'' `r(col)'`rfrontmatter'=matrix(frontmatter`vrank')
				foreach x in `_dec' `_group2' {
					local startcol = `startcol_o'
					foreach ss in `supercols' fi_`vrank' {
						cap confirm matrix I`vrank'_`ss'_`x' // to deal with fi_`v' for ``v''==""
						returncol `startcol'
						if !_rc local resultset`vrank' `resultset`vrank'' `r(col)'`r`x''=matrix(I`vrank'_`ss'_`x')
						local startcol = `startcol' + `cols'
					}
					returncol `=`startcol_o'-2'
					local popresults`vrank' `popresults`vrank'' `r(col)'`r`x''=matrix(`x'_`vrank'pop)
				}
				foreach x in `_cent' `_bin' {
					local startcol = `startcol_o'
					local ss totLCU
					cap confirm matrix I`vrank'_`ss'_`x' // to deal with fi_`v' for ``v''==""
					returncol `startcol'
					if !_rc local resultset`vrank' `resultset`vrank'' `r(col)'`r`x''=matrix(I`vrank'_`ss'_`x')
					local startcol = `startcol' + `cols'
					returncol `=`startcol_o'-2'
					local popresults`vrank' `popresults`vrank'' `r(col)'`r`x''=matrix(`x'_`vrank'pop)
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
		local supercolnum = wordcount("`supercols'") + 1  // to get right number of repetitions of title (since local supercols has one short)
		
		foreach v of local alllist { 
			if "``v''"!="" {
				local startcol = `startcol_o'
				returncol `startcol'     
				local titles`v' `titles`v'' `r(col)'`trow'=("`d_`v''") 
				local ++startcol
				foreach pr of local programcols {
					returncol `startcol'
					local titles`v' `titles`v'' `r(col)'`trow'=("`d_`pr''")
					local ++startcol
				}
				foreach ss in `supercols' {
					returncol `startcol'     
					local titles`v' `titles`v'' `r(col)'`trow'=("`d_`v''") 
					local ++startcol
					foreach pr of local programcols {
						returncol `startcol'
						local titles`v' `titles`v'' `r(col)'`trow'=("`d_`pr''")
						local ++startcol
					}
				}
			}
		}	

		foreach v of local alllist {
			if "``v''"!="" {
				foreach x in `_dec' `_group2' {
					local startcol = `startcol_o'
					local mattrow = `r`x'' - 1 // one row above where the results start
					foreach ss in `supercols' fi_`v' {
						returncol `startcol'
						local mattitles`v' `mattitles`v'' `r(col)'`mattrow'=("`_`ss''")
						local startcol = `startcol' + `cols'
					}
				}
			}
		}
		
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
		
		// Print warning message on Excel sheet 
		local warningrow = 505
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
		local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 505.") 
		
		// putexcel
		foreach vrank of local alllist {
			if "``vrank''"!="" {
				qui putexcel `titlesprint' `versionprint' `titles`vrank'' `mattitles`vrank'' `popresults`vrank'' ///
					`resultset`vrank'' `cutoffs' `warningprint' using `"`using'"', ///
					modify keepcellformat sheet("`sheet`vrank''")
				qui di "
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
	
end	// END ceqfiscal
