** ADO FILE FOR MARGINAL EFFECTS

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.9 31oct2018 For use with July 2017 version of Output Tables
** v1.8 5sep2018 For use with July 2017 version of Output Tables
** v1.7 10jun2018 For use with July 2017 version of Output Tables
** v1.6 29jun2017 For use with July 2017 version of Output Tables
** v1.5 02jun2017 For use with Jun 2017 version of Output Tables
** v1.4 16may2017 For use with Oct 2016 version of Output Tables
** v1.3 06apr2017 For use with Oct 2016 version of Output Tables
** v1.2 27mar2017 For use with Oct 2016 version of Output Tables
** v1.1 08mar2017 For use with Oct 2016 version of Output Tables
** v1.0 12feb2017 For use with Oct 2016 version of Output Tables
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   10-31-2018 Make the negatives option effective for cases where post intervention incomes are negative (previously )
**   09-05-2018 Make the negatives option effective for negative income + fiscal intervention values
**   06-10-2018 Add the negatives option
**   06-29-2017 Replacing covconc with improved version by Paul Corral
**   05-27-2017 Add additional options to print meta-information
**   05-16-2017 Fix command name mistake
**   04-06-2017 Remove the warning about negative tax values
**   03-08-2017 Remove the net in-kind transfers as a broad category in accordance with the instruction that users
**				 supply net in-kind transfer variables to health/education/otherpublic options
**	 03-23-2017 Fix cell alignment 

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

// BEGIN ceqpov (Higgins 2017)
capture program drop ceqpov
program define ceqpov, rclass sortpreserve
	syntax varlist(max=1) [if] [in] [aw], z(string)
	preserve
	marksample touse
	qui keep if `touse' // drops !`if', !`in', and any missing values of `varname'
	
	local _pline `z' // just a patch since I previously coded with `_pline'
	local vtouse `varlist'
	
	tempvar zyz0 zyz1 zyz2
	qui gen `zyz0' = (`vtouse'<`_pline')                 // =1 if poor, =0 otherwise
	qui gen `zyz1' = max((`_pline'-`vtouse')/`_pline',0) // normalized povety gap of each individual
	qui gen `zyz2' = `zyz1'^2                            // square of normalized poverty gap

	forval i=0/2 {
		qui summ `zyz`i'' [`weight'`exp'], meanonly // `if' `in' restrictions already taken care of by `touse' above
		scalar _pov`i' = r(mean)
		return scalar pov`i' = _pov`i'
	}
end

**********************
** ceqmarg PROGRAM *
**********************
** For sheet E13. Marg. Contrib.
// BEGIN ceqmarg (Higgins 2015)
capture program drop ceqmarg
program define ceqmarg, rclass 
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
			/** POVERTY LINES */
			PL1(real 1.25)
			PL2(real 2.50)
			PL3(real 4.00)
			NATIONALExtremepl(string)   
			NATIONALModeratepl(string)  
			OTHERExtremepl(string)      
			OTHERModeratepl(string)	
			PROPortion(real 0.5) 			
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
	local command ceqmarg
	local version 1.9
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

	foreach y of local alllist {
		local varlist `varlist' ``y'' // so varlist has the variable names
		// reverse tokenize:
		local _`y' = `counter' // so _m = 1, _mp = 2 (regardless of whether these options included)
		if "``y''"!="" local `y'__ `y' // so `m__' is e.g. m if market() was specified, "" otherwise
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
	foreach pl of local plopts {
		if "``pl''"!="" {
			if _`pl'_isscalar == 0 {
				local pl_tokeep `pl_tokeep' ``pl''
			}
		}
	}
	
	** keep the variables used in ceqdes   
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
	local alltransfersp `pensions' `dtransfers' `subsidies' `inkind' /* `userfees' */
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

    // for display of negative fiscal intervention warning
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
	local d_`v_userfees'	       = "All user fees"
	/* local _d_`v_netinkind'        = "All net inkind transfers"   local of specfic net inkind transfers created before */
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
			local sheet`vrank' "E13.`_vrank' Marg. Contrib." // default name of sheet in Excel files
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
	if "`nogroup'"=="" & (`_ppp') local _group group
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
					`dit' "Warning: `r(N)' negative values of ``v''. Concentration Coefficient, Kakwani Index, and Marginal Contribution not produced. To produce specify the option {bf:negatives}"
					local warning `warning' "Warning: `r(N)' negative values of ``v''. Concentration Coefficient, Kakwani Index, and Marginal Contribution not produced. To produce specify the option {negatives}."
				}
				else {
					`dit' "Warning: `r(N)' negative values of ``v''. Concentration Coefficient, Kakwani Index, and Marginal Contribution are not well behaved."
					local warning `warning' "Warning: `r(N)' negative values of ``v''. Concentration Coefficient, Kakwani Index, and Marginal Contribution are not well behaved."
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
					if "`negatives'"=="" {
						`dit' "Warning: `negcount' negative values of `d_`pr''. Concentration Coefficient, Kakwani Index, and Marginal Contribution not produced. To produce specify the option {bf:negatives}."
						local warning `warning' "Warning: `negcount' negative values of `d_`pr''. Concentration Coefficient, Kakwani Index, and Marginal Contribution not produced. To produce specify the option {negatives}."
					}
					else {
						`dit' "Warning: `negcount' negative values of `d_`pr''. Concentration Coefficient, Kakwani Index, and Marginal Contribution are not well behaved."
						local warning `warning' "Warning: `negcount' negative values of `d_`pr''. Concentration Coefficient, Kakwani Index, and Marginal Contribution are not well behaved."
					}
				}
			}
			else {
				qui count if `pr'>0
				local negcount = r(N)
				if `negcount'>0 {
					if "`negatives'"=="" {
						`dit' "Warning: `negcount' positive values of `d_`pr'' (variable stored as negative values). Concentration Coefficient and Kakwani Index not produced. To produce specify the option {bf:negatives}."
						local warning `warning' "Warning: `negcount' positive values of `d_`pr'' (variable stored as negative values). Concentration Coefficient and Kakwani Index not produced. To produce specify the option {negatives}."
					}
					else {
						`dit' "Warning: `negcount' negative values of `d_`pr'' (variable stored as negative values). Concentration Coefficient and Kakwani Index are not well behaved."
						local warning `warning' "Warning: `negcount' positive values of `d_`pr'' (variable stored as negative values). Concentration Coefficient and Kakwani Index are not well behaved."
					}
				}
			}
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
	/* if wordcount("`postax'")>0 {
		`dit' "Taxes appear to be positive values for variable(s) `postax'; replaced with negative for calculations"
	} */
	
	** create extended income variables
	foreach pr in `pensions' `v_pensions' { // did it this way so if they're missing loop is skipped over, no error
		foreach y in `m__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `mp__' `n__' `g__' `d__' `c__' `f__' { // t excluded bc unclear whether pensions included
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}
	foreach pr in `dtransfers' `v_dtransfers' {
		foreach y in `m__' `mp__' `n__' {
			tempvar `y'_`pr' 
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}
	foreach pr in `v_dtransfersp' {
		foreach y in `m__' { // can't include mp or n here bc they incl pens but not dtransfers
			tempvar `y'_`pr' 
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}

	foreach pr in `dtaxes' `v_dtaxes' `contribs' `v_contribs' `v_dtaxescontribs' {
		foreach y in `m__' `mp__' `g__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			noi su ``y'_`pr''
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr' // written as minus since taxes thought of as positive values
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `n__' `t__' `d__' `c__' `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}
	foreach pr in `subsidies' `v_subsidies' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr' 
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}
	foreach pr in `indtaxes' `v_indtaxes' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr' 
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}
	foreach pr in `v_alltaxes' `v_alltaxescontribs' {
		foreach y in `m__' `mp__' `g__' `t__' { // omit n, d which have dtaxes subtr'd but not indtaxes
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr' 
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}
	foreach pr in `health' `education' `otherpublic' ///
	`v_health' `v_education' `v_otherpublic' `v_inkind' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' `c__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}
	
	foreach pr in `userfeeshealth' `v_userfeeshealth' `userfeeseduc' `v_userfeeseduc' `userfeesother' `v_userfeesother' `v_userfees' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' `c__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `f__' {  
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}
	/*foreach pr in `nethealth' `neteducation' `netother' `v_netinkind' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' `c__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
	}*/
	foreach pr in `v_alltransfers' {
		foreach y in `m__' `mp__' `n__' { // omit g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'			
		}
	}
	foreach pr in `v_alltransfersp' {
		foreach y in `m__' { // omit mplusp, n which have pensions, g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local `y'_wo_`pr' ``y'' // income without the intervention
			local `y'_w_`pr'  ``y'_`pr'' // income with the intervention
			local zip_marg`y' `zip_marg`y'' `pr'			
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local `y'_wo_`pr' ``y'_`pr'' // income without the intervention
			local `y'_w_`pr'  ``y'' // income with the intervention			
			local zip_marg`y' `zip_marg`y'' `pr'
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
		
	**********************
	** CALCULATE RESULTS *
	**********************
	// Mean, median, standard deviation, concentration coefficient, reranking, etc.
	foreach v of local alllist {
		if "``v''"!="" {
			matrix frontmatter`v' = J(4,`cols',.) 
			matrix VE_RR`v'       = J(15,`cols',.)
			matrix poverty`v'     = J(21,`cols',.)
			local col = 1
			
			// Totals
			qui summ ``v'' `aw', meanonly
			scalar _total_`v' = r(sum)
			
			// Gini for Kakwani
			qui covconc ``v'' `pw'
			scalar _G_`v' = r(gini)
			
			foreach pr in `programcols' { // already varnames
				local row = 1

				// Relative size
				qui summ `pr' `aw', meanonly
				matrix frontmatter`v'[`row',`col'] = r(sum)/_total_`v' // relative size
				local ++row

				// Concentration coefficient
				qui covconc `pr' `pw', rank(``v'')
				scalar _C_`v'_pr = r(conc)
				//  check for negatives

				if "``v'_wo_`pr''"!="" & "``v'_w_`pr''"!="" {
					qui summ ``v'_wo_`pr''
					if r(mean)>0 {
						qui count if ``v'_wo_`pr''<0
						local negcount1 = r(N)
					}
					else {
						qui count if ``v'_wo_`pr''>0
						local negcount1 = r(N)
					}
					qui summ ``v'_w_`pr''
					if r(mean)>0 {
						qui count if ``v'_w_`pr''<0
						local negcount2 = r(N)
					}
					else {
						qui count if ``v'_w_`pr''>0
						local negcount2 = r(N)
					}					
				}
				else {
					local negcount1 = 0
					local negcount2 = 0
				}

				qui summ `pr'
				if r(mean)>0 {
					qui count if `pr'<0
					local negcount3 = r(N)
				}
				else {
					qui count if `pr'>0
					local negcount3 = r(N)
				}
				local negcount = `negcount1' + `negcount2' + `negcount3'
				if `negcount'>0 {
					if "`negatives'"=="" {
						matrix frontmatter`v'[`row',`col'] = .
						local nokakwani = 1
					}
					else {
						matrix frontmatter`v'[`row',`col'] = _C_`v'_pr
						local nokakwani = 0
					}
				}
				else {
					matrix frontmatter`v'[`row',`col'] = _C_`v'_pr
					local nokakwani = 0 
				}
				local ++row

				// Kakwani (Kakwani_transfer is -Kakwani_transfer)
				if `nokakwani'==1 {
					if strpos("`transfercols'","`pr'") { // i.e., if a transfer
						scalar _K_`v'_pr = _G_`v' - _C_`v'_pr
						matrix frontmatter`v'[`row',`col'] = .
					}
					else { // a tax
						scalar _K_`v'_pr = _C_`v'_pr - _G_`v'
						matrix frontmatter`v'[`row',`col'] = .
					}
				}
				else {
					if strpos("`transfercols'","`pr'") { // i.e., if a transfer
						scalar _K_`v'_pr = _G_`v' - _C_`v'_pr
						matrix frontmatter`v'[`row',`col'] = _K_`v'_pr
					}
					else { // a tax
						scalar _K_`v'_pr = _C_`v'_pr - _G_`v'
						matrix frontmatter`v'[`row',`col'] = _K_`v'_pr
					}
				}
				local ++row
				
				// Marginal contribution to redistributive effect
				//  (note some with/withouts don't exist, 
				//   e.g. for 'contributory pensions plus direct transfers' wrt 
				//   market income plus pensions, there is no clear 'without' income concept)
				if "``v'_wo_`pr''"!="" & "``v'_w_`pr''"!="" {
					qui covconc ``v'_wo_`pr'' `pw'
					scalar _gini_wo = r(gini)
					qui covconc ``v'_w_`pr'' `pw'
					scalar _gini_w = r(gini)
					
					if `nokakwani'==1 {
						matrix frontmatter`v'[`row',`col'] = .
					}
					else {
						matrix frontmatter`v'[`row',`col'] = _gini_wo - _gini_w
					}
				} // else leave it as missing
				local ++row
				
				// Marginal contribution to vertical equity, reranking, 
				//  and their derivatives
				//  (Recall `alllist' = m mp n g t d c f, and we did a reverse 
				//   tokenize so `_m' = 1, `_mp' = 2, etc.)
				local row = 1
				foreach Z in d c f { 
					if `_`v'' < `_`Z'' & "``Z''"!="" & "``Z'_wo_`pr''"!="" {
						// Calculate the necessary Ginis 
						qui covconc ``Z'' `pw'
						scalar _G_`Z' = r(gini)
						qui covconc ``Z'_wo_`pr'' `pw'
						scalar _G_`Z'_wo_pr = r(gini)
						
						// Calculate the necessary concentration coefficients
						qui covconc ``Z'' `pw', rank(``v'') 
						scalar _C_`v'_`Z' = r(conc) // first letter is ranking var
						qui covconc ``v'' `pw', rank(``Z'')
						scalar _C_`Z'_`v' = r(conc)
						qui covconc ``Z'_wo_`pr'' `pw', rank(``v'')
						scalar _C_`v'_`Z'_wo_pr = r(conc)
						qui covconc `pr' `pw', rank(``Z'')
						scalar _C_`Z'_pr = r(conc)
						
						// Calculate the necessary Kakwani indices
						if strpos("`transfercols'","`pr'") { // i.e., if a transfer
							scalar _K_`Z'_pr = _C_`Z'_`v' - _C_`Z'_pr
						}
						else { // a tax
							scalar _K_`Z'_pr = _C_`Z'_pr - _C_`Z'_`v'
						}
							// see equations 9 in "Formulas for Sheet E13" from Ali Enami
						
						// Calculate denominator for derivatives
						summ ``Z'' `aw', meanonly
						scalar _total_`Z' = r(sum)
						scalar _`v'_to_`Z'_denom = _total_`Z'/_total_`v'
						
						// Marginal contribution to vertical equity
						scalar _MVE_pr = (_G_`v' - _C_`v'_`Z') - (_G_`v' - _C_`v'_`Z'_wo_pr)
							// see eqn 6 in "Formulas for Sheet E13" from Ali Enami
							
						// Marginal contribution to reranking
						scalar _MRR_pr = (_C_`v'_`Z' - _G_`Z') - (_C_`v'_`Z'_wo_pr - _G_`Z'_wo_pr)
							// see eqn 7 in "Formulas for Sheet E13" from Ali Enami
						
						// dM/dg (discussing with Ali)
						if strpos("`transfercols'","`pr'") { // i.e., if a transfer
							scalar _dM_dg = (_K_`Z'_pr - (_C_`Z'_`v' - _G_`v')) ///
								/_`v'_to_`Z'_denom
						}
						else { // a tax
							scalar _dM_dg = (_K_`Z'_pr - (_G_`v' - _C_`Z'_`v')) ///
								/_`v'_to_`Z'_denom
						}
						
						// dMVE/dg
						if strpos("`transfercols'","`pr'") { // i.e., if a transfer 
							scalar _dMVE_dg = _K_`v'_pr - (_G_`v' - _C_`v'_`Z') ///
								/_`v'_to_`Z'_denom
						}
						else { // a tax
							scalar _dMVE_dg = _K_`v'_pr + (_G_`v' - _C_`v'_`Z') ///
								/_`v'_to_`Z'_denom
						}
						
						// dMRR/dg
						scalar _dMRR_dg = _dM_dg - _dMVE_dg
						
						// Put results in matrix
						if `nokakwani'==1 {
							matrix VE_RR`v'[`row',`col'] = .
							local ++row
							matrix VE_RR`v'[`row',`col'] = .
							local ++row 
							matrix VE_RR`v'[`row',`col'] = .
							local ++row
							matrix VE_RR`v'[`row',`col'] = .
							local ++row 
							matrix VE_RR`v'[`row',`col'] = .
							local ++row 
						}
						else {
							matrix VE_RR`v'[`row',`col'] = _MVE_pr
							local ++row
							matrix VE_RR`v'[`row',`col'] = _MRR_pr
							local ++row 
							matrix VE_RR`v'[`row',`col'] = _dM_dg
							local ++row
							matrix VE_RR`v'[`row',`col'] = _dMVE_dg
							local ++row 
							matrix VE_RR`v'[`row',`col'] = _dMRR_dg
							local ++row 
						}
					}
					else {
						local row = `row' + 5 // rows for that starting and ending income concept will be blank
					}
				}
				
				// Marginal contributions to poverty
				if "``v'_wo_`pr''"!="" & "``v'_w_`pr''"!="" {
					local row = 1
					if (`_ppp') {
						** PPP converted variables
						tempvar wo_ppp w_ppp
						qui gen `wo_ppp' = (``v'_wo_`pr''/`divideby')*(1/`ppp_calculated')
						qui gen `w_ppp' = (``v'_w_`pr''/`divideby')*(1/`ppp_calculated')
					}
					if wordcount("`povlines'")>0 {
						foreach p in `plopts' { // plopts includes all lines
							if "``p''"!="" {	
								if substr("`p'",1,2)=="pl" { // these are the PPP lines
									local _pline = ``p''
									local v_wo_touse `wo_ppp'
									local v_w_touse `w_ppp'
								}
								

								else if _`p'_isscalar==1 {   // if pov line is scalar, // (note this local defined above)
									local _pline = ``p'' // set `_pline' as that scalar and
									local v_wo_touse ``v'_wo_`pr''   // use original income variable
									local v_w_touse ``v'_w_`pr''   // use original income variable
								}
								else if _`p'_isscalar==0 { // if pov line is variable,
									tempvar wo_normalized w_normalized  // create temporary variable that is income...
									qui gen `wo_normalized' = ``v'_wo_`pr''/``p'' // normalized by pov line
									qui gen `w_normalized' = ``v'_w_`pr''/``p'' // normalized by pov line
									local _pline = 1                       // and normalized pov line is 1
									local v_wo_touse `wo_normalized' // use normalized income in the calculations
									local v_w_touse `w_normalized' // use normalized income in the calculations
								}
								qui ceqpov `v_wo_touse' `aw', z(`_pline')
								forval i=0/2 {
									scalar _pov_wo_`i' = r(pov`i')
								}
								
								qui ceqpov `v_w_touse' `aw', z(`_pline')
								if `nokakwani'==1 {
									forval i=0/2 {
										matrix poverty`v'[`=`row'+`i'',`col'] = .
									}
								}
								else {
									forval i=0/2 {
										scalar _pov_w_`i' = r(pov`i')
										matrix poverty`v'[`=`row'+`i'',`col'] = _pov_wo_`i' - _pov_w_`i'
									}
								}
							}
							local row = `row' + 3 // want to add three whether or not `p' option specified since those matrices are in the MWB
						}
					}
				}

				local ++col
			}
		}
	}
	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" /* " */ { 
		`dit' `"Writing to "`using'"; may take several minutes"'
		// Locals for Excel columns
		local startcol_o = 4 // this one will stay fixed (column D)
		returncol `startcol_o' 
		local startcol_alph `r(col)'
		
		// Export to Excel (matrices)
		local rfrontmatter =  9
		local rVE_RR       = 13
		local rpoverty     = 28

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
		
		foreach pr of local programcols {
			returncol `startcol'
			local titles `titles' `r(col)'`trow'=(_d_`pr')
			local ++startcol
		}
		
		// Export to Excel (poverty lines)
		local rpovlines = 28
		forval i=1/3 {
			local cutoffs `cutoffs' B`rpovlines'=(`pl`i'')
			local rpovlines = `rpovlines'+3
		}
		
		// Print warning message on Excel sheet 
		local warningrow = 50
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
		local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row `warningrow'.") 
		
		// putexcel

		foreach vrank of local alllist {
			if "``vrank''"!="" {
				qui putexcel `titlesprint' `versionprint' `titles' ///
					`startcol_alph'`rfrontmatter'=matrix(frontmatter`vrank') ///
					`startcol_alph'`rVE_RR'=matrix(VE_RR`vrank') ///
					`startcol_alph'`rpoverty'=matrix(poverty`vrank') ///
					`cutoffs' `warningprint' using `"`using'"', /// " 
					modify keepcellformat sheet("`sheet`vrank''")
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
	
end	// END ceqmarg
