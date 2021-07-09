** ADO FILE FOR EXTENDED INCOME CONCEPTS SHEET OF CEQ MASTER WORKBOOK SECTION E

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.7 01jun2017 For use with July 2017 version of CEQ Master Workbook 
** v1.6 06apr2017 For use with Oct 2016 version of CEQ Master Workbook 
** v1.5 08mar2017 For use with Oct 2016 version of CEQ Master Workbook 
** v1.4 12jan2017 For use with Oct 2016 version of CEQ Master Workbook
** v1.3 13nov2016 For use with Oct 2016 version of CEQ Master Workbook
** v1.2 30oct2016 For use with July 2016 version of CEQ Master Workbook
** v1.1 30sep2016 For use with July 2016 version of CEQ Master Workbook
** v1.0 12sep2016 For use with July 2016 version of CEQ Master Workbook
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**   06-01-2017 Add additional options to print meta-information
**   04-06-2017 Remove the warning about negative tax values
**   03-08-2017 Remove the net in-kind transfers as a broad category in accordance with the instruction that users
**				 supply net in-kind transfer variables to health/education/otherpublic options
** 	 01-12-2017 Set the data type of all newly generated variables to be double
** 				Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**   11-13-2016 Change the looping letter from w to r to avoid repetition of weight variable local, updated cell numbers to align results
**   10-30-2016 Fix bug with alltransfersp omitted from the broad categories
**	  9-30-2016	Print warning messages to MWB sheets 
** 				Changed warning contents and add exit when ppp option is not specified

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

// BEGIN diff_and_pvalue
//  Command that produces differences and pvalues of a statistical significance test
//   of H0: difference = 0. Commands from DASP (Araar and Duclos) that perform the
//   statistical test will be used.
cap program drop diff_and_pvalue
program define diff_and_pvalue
	#delimit ;
	syntax varlist(min=2 max=2) ,
		diffs(string) 
		pvals(string)
		command(string) 
		row(real) 
		col(real)
		[ cmdoptions(string) ]
	;
	#delimit cr
	confirm matrix `diffs'
	confirm matrix `pvals'
	qui `command' `varlist', `cmdoptions' // uses svyset info that was implemented above
		// (note: don't use hsize() option since that has already been incorporated
		//  into the weights for each unit in this household-collapsed data set)
	tempname e_di _p
	matrix `e_di' = e(di)
	matrix `diffs'[`row',`col'] = `e_di'[1,1]
	scalar `_p' = e(p)
	if `_p'<1e-9 scalar `_p' = 0 // to avoid really small numbers in scientific notation
	matrix `pvals'[`row',`col'] = `_p'
end // END diff_and_pvalue

**********************
** ceqextsig PROGRAM *
**********************
** Quick and dirty way to fix too many variables problem: 
**  run the command separately for each income concep
capture program drop ceqextsig
program define ceqextsig
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
	local command ceqextsig
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
	local list_opt2 ""
	foreach incname of local inc_opt_used {
		local `incname'_opt "`incname'(``incname'')" // `incname' will be e.g. market
			// and ``incname'' will be the varname 
		local list_opt2 `list_opt2' `incname'2(``incname'') 
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
		//	to open only on last iteration of _ceqextsig,
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
		_ceqextsig `using' `if' `in' [`weight' `exp'], ///
			``incname'_opt' `list_opt2' `options' `open_opt' `nodisplay_opt' 
			/*_version("`version'") */
	}
end

** For sheet E12. Extended Income Concepts
// BEGIN _ceqextsig (Higgins 2015)
capture program drop _ceqextsig  
program define _ceqextsig, rclass 
	version 13.0
	#delimit ;
	syntax 
		[using]
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
			/** REPEAT FOR CONCENTRATION MATRIX */
			/** (temporary hack-y patch) */
			market2(varname)
			mpluspensions2(varname)
			netmarket2(varname) 
			gross2(varname)
			taxable2(varname)
			disposable2(varname) 
			consumable2(varname)
			final2(varname)
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
			
			// Displayed in syntax command below to get around options dilemna 
			
			/*_version(string)*/
			/** IGNOREMISSING */
			
			
			*
		]
	;
	
	#delimit cr
	if "`exp'"!="" local pw "[`weight'=`exp']"  // tp get around Stata option limit
	if `"`using'"'!="" local using "`using'"
	local 0  `"`using' `if' `in' `pw', `options'"'   //
    syntax [if] [in] [using/] [pweight/]  [, IGNOREMissing OPEN  NODecile NOGroup NOCentile NOBin NODIsplay]
		
		
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit if "`nodisplay'"=="" display as text in smcl 
	local ditall display as text in smcl 
	local die display as error in smcl
	local command ceqextsig
	local version 1.7 //`_version'	
	
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
	local alllist2 m2 mp2 n2 g2 t2 d2 c2 f2
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
	
	** results
	#delimit ;
	local matrices 
		gini
		absgini
 		theil
		ninetyten
	;
	#delimit cr
	forval i=0/2 { // FGT(0), FGT(1), FGT(2)
		forval pp=1/3 { // three international poverty lines
			local matrices `matrices' p`i'_pl`pp'
		}
 		local matrices `matrices' p`i'_nationalextremepl
		local matrices `matrices' p`i'_nationalmoderatepl
		local matrices `matrices' p`i'_otherextremepl     
		local matrices `matrices' p`i'_othermoderatepl
		local matrices `matrices' p`i'_relativepl
	}
	foreach v of local alllist {
		local matrices `matrices' conc`v'
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
						userfeeshealth userfeeseduc userfeesother nethealth neteducation netother
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
	foreach pl of local plopts {
		if "``pl''"!="" {
			if _`pl'_isscalar == 0 {
				local pl_tokeep `pl_tokeep' ``pl''
			}
		}
	}
	local relevar `varlist2' `allprogs' ///
				  `w' `psu' `strata' ///
				  `pl_tokeep' 
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
		else {
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
	local alltransfers `dtransfers' `subsidies' `inkind' `userfees'
	local alltransfersp `pensions' `dtransfers' `subsidies' `inkind' `userfees'
	local alltaxes `dtaxes' `indtaxes'
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	foreach cat of local programlist {
		if "``cat''"!="" {
			tempvar v_`cat' // in the locals section despite creating vars
			qui gen double `v_`cat''=0 // because necessary for local programcols 
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
		`dtaxes' `v_dtaxes' `contribs' `v_contribs' `v_dtaxescontribs'
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
	scalar _d_`v_alltransfers'     = "All transfers and subsidies excl contributory pensions"
	scalar _d_`v_alltransfersp'    = "All transfers and subsidies incl contributory pensions"
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
			if "`vrank'"=="mp" local sheet`vrank' "E16.m+p Extended Inc Stat Sig"
			else {
				local sheet`vrank' "E16.`vrank' Extended Inc Stat Sig" // default name of sheet in Excel files
			}
		}
	}
	
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

	** make sure -sgini- installed
	cap which sgini
	if _rc {
		`dit' "Warning: {bf:sgini} not installed; S-Gini results not produced"
		`dit' `"To install: {stata "net install sgini, from(http://medim.ceps.lu/stata)"}"'
		local warning `warning' "Warning: sgini not installed; S-Gini results not produced. To install: stata net install sgini, from(http://medim.ceps.lu/stata)"
	}
	
	** create new variables for program categories

	if wordcount("`allprogs'")>0 ///
	foreach pr of local taxcols {
		qui summ `pr', meanonly
		if r(mean)>0 {
			if wordcount("`postax'")>0 local postax `postax', `pr'
			else local postax `x'
			qui replace `pr' = -`pr' // replace doesnt matter since we restore at the end
		}
	}
	/*if wordcount("`postax'")>0 {
		`dit' "Taxes appear to be positive values for variable(s) `postax'; replaced with negative for calculations"
	}*/
	
	foreach y of local alllist {
		local marg`y' ``y''
	}	
	** create extended income variables
	foreach pr in `pensions' `v_pensions' { // did it this way so if they're missing loop is skipped over, no error
		foreach y in `m__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `mp__' `n__' `g__' `d__' `c__' `f__' { // t excluded bc unclear whether pensions included
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `dtransfers' `v_dtransfers' {
		foreach y in `m__' `mp__' `n__' {
			tempvar `y'_`pr' 
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `v_dtransfersp' {
		foreach y in `m__' { // can't include mp or n here bc they incl pens but not dtransfers
			tempvar `y'_`pr' 
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''			
		}
	}
	foreach pr in `dtaxes' `v_dtaxes' `contribs' `v_contribs' `v_dtaxescontribs' {
		foreach y in `m__' `mp__' `g__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr' // written as minus since taxes thought of as positive values
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `n__' `t__' `d__' `c__' `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `subsidies' `v_subsidies' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr' 
			qui gen double ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `indtaxes' `v_indtaxes' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr' 
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `v_alltaxes' `v_alltaxescontribs' {
		foreach y in `m__' `mp__' `g__' `t__' { // omit n, d which have dtaxes subtr'd but not indtaxes
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''			
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen double ``y'_`pr'' = ``y'' - `pr' 
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `health' `education' `otherpublic' ///
	`v_health' `v_education' `v_otherpublic' `v_inkind' {
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
	}
	foreach pr in `v_alltransfersp' {
		foreach y in `m__' { // omit mplusp, n which have pensions, g, t, d, c which have some transfers
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
	}
	
	** get length of marg`y'
	local maxlength = 0
	foreach v of local alllist {
		if "``v''"!="" {
			local length = wordcount("`marg`v''")
			local maxlength = max(`maxlength',`length')
		}
	}
	local colsneeded = (wordcount("`supercols'") + 8)*`maxlength' // +8 is for fi matrices for each income concept

	** PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach r of local alllist2 {
			local r_ = subinstr("`r'","2","",.)
			if "``r''"!="" {
				tempvar `r_'_ppp
				qui gen ``r_'_ppp' = (``r''/`divideby')*(1/`ppp_calculated')
			}
		}	
		foreach y of local alllist {
			foreach ext of local marg`y' {
				tempvar `ext'_ppp
				qui gen ``ext'_ppp' = (`ext'/`divideby')*(1/`ppp_calculated')
			}
		}
	}
	
	** check and issue warnings for negative values
	foreach y of local alllist {
		if "``y''"!="" {
			foreach v of local marg`y' {
				qui count if `v'<0
				local negcount=r(N)
				local _d_`v' = _d_`v'
				if `negcount'>0 {
					`ditall' "Warning: `_d_`v'' has `negcount' negative values."
					/*local warning `warning' "Warning: `_d_`v'' has `negcount' negative values."*/
				}
			}
		}
	}
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	
	**********************
	** CALCULATE RESULTS *
	**********************
	foreach y of local alllist { // should only include one in wrapped command
		if "``y''"=="" continue 
		local cols = wordcount("`marg`y''")
		foreach mat of local matrices {
			tempname `mat'_diffs `mat'_pvals // temporary matrices
			matrix ``mat'_diffs' = J(`incomes',`cols',.) // square matrix for point estimate of difference 
				// in Ginis for pairs of core income concepts
			matrix ``mat'_pvals' = J(`incomes',`cols',.) // statistical significance of above difference in Ginis
		}
		local col = 0
		foreach ext of local marg`y' {
			local v ext // quick compatibility patch with code copied from ceqstatsig
				// since `v' = ext ==> ``v'' = `ext'
			
			local row = 0
			local ++col
			foreach r of local alllist2 {
				local r_ = subinstr("`r'","2","",.)
				
				local ++row
				
				if "``r''"=="" continue // income concept option not included by user
	
				#delimit ;
				/* GINI */
				local mat gini ;
				diff_and_pvalue `ext' ``r'' , 
					command(ceqdigini) 
					diffs(``mat'_diffs') pvals(``mat'_pvals')    
					row(`row') col(`col')
				;
				
				/* ABSOLUTE GINI */
				local mat absgini ;
				diff_and_pvalue `ext' ``r'' , 
					command(ceqdigini) cmdoptions(type(abs)) 
					diffs(``mat'_diffs') pvals(``mat'_pvals')    
					row(`row') col(`col')
				;
	
				/* THEIL */
				local mat theil ;
				diff_and_pvalue `ext' ``r'' , 
					command(ceqdientropy) cmdoptions(theta(1)) 
					diffs(``mat'_diffs') pvals(``mat'_pvals')    
					row(`row') col(`col')
				;
				
				/* 90/10 */
				local mat ninetyten ;
				diff_and_pvalue `ext' ``r'' , 
					command(ceqdinineq) cmdoptions(p1(0.90) p2(0.10)) 
					diffs(``mat'_diffs') pvals(``mat'_pvals')    
					row(`row') col(`col')
				;
				
				#delimit cr
				
				/* POVERTY: INTERNATIONAL POVERTY LINES */
				if wordcount("`povlines'")>0 { // otherwise produces inequality only
					forval pp=1/3 { 
						forval i=0/2 { // values of alpha
							local mat p`i'_pl`pp' 
							
							#delimit ;
							diff_and_pvalue ``ext'_ppp' ``r_'_ppp' , 
								command(ceqdifgt) 
								cmdoptions(alpha(`i') pline1(`pl`pp'') pline2(`pl`pp''))
								diffs(``mat'_diffs') pvals(``mat'_pvals')  
								row(`row') col(`col')
							;
							#delimit cr
						}
					} 
					
					/* POVERTY: NATIONAL POVERTY LINES */
					foreach p in `plopts' { // plopts includes all lines
						if "``p''"=="" continue	
						if substr("`p'",1,2)=="pl" continue // these are the PPP lines, done above
						if _`p'_isscalar==1 {   // if pov line is scalar, // (note this local defined above)
							local _pline = ``p'' // set `_pline' as that scalar and
							foreach x in v r {
								local `x'touse ```x'''   // use original income variable
							}
						}
						else if _`p'_isscalar==0 { // if pov line is variable,
							foreach x in v r {
								tempvar ``x''_normalized  // create temporary variable that is income...
								qui gen ```x''_normalized' = ```x'''/``p'' // normalized by pov line
								local `x'touse ```x''_normalized' // use normalized income in the calculations
							}
							local _pline = 1 // and normalized pov line is 1
						}
						forval i=0/2 { // values of alpha
							local mat p`i'_`p'
							#delimit ;
							diff_and_pvalue `vtouse' `rtouse' , 
								command(ceqdifgt) 
								cmdoptions(alpha(`i') pline1(`_pline') pline2(`_pline'))
								diffs(``mat'_diffs') pvals(``mat'_pvals')  
								row(`row') col(`col')
							;
							#delimit cr
						}
					}
				} 
				
				/* POVERTY: RELATIVE POVERTY LINES */
				foreach x in v r {
					qui summ ```x''' `aw', d
					local rel_pl_`x' = `proportion'*r(p50) // half of median income
					tempvar ``x''_normalized
					qui gen ```x''_normalized' = ```x'''/`rel_pl_`x''
					local `x'touse ```x''_normalized'
				}
				local _pline = 1 // normalized poverty line
				forval i=0/2 { // values of alpha
					local mat p`i'_relativepl
					#delimit ;
					diff_and_pvalue `vtouse' `rtouse',
						command(ceqdifgt)
						cmdoptions(alpha(`i') pline1(`_pline') pline2(`_pline'))
						diffs(``mat'_diffs') pvals(``mat'_pvals')  
						row(`row') col(`col')
					;
					#delimit cr
				} 
				
				/* CONCENTRATION COEFFICIENTS */
				foreach rankby of local alllist {
					if "``rankby''"=="" continue
					#delimit ;
					local mat conc`rankby' ;
					diff_and_pvalue `ext' ``r'' , 
						command(ceqdigini) 
						cmdoptions(rank1(``rankby'') rank2(``rankby''))
						diffs(``mat'_diffs') pvals(``mat'_pvals')    
						row(`row') col(`col')
					;
					#delimit cr
				}
				
			} // foreach r of local alllist2 (loop through core income concepts)
		} // foreach ext of local marg`y' (loop through extended income concepts)
	} // foreach y of local alllist (wrapped by ceqextsig)
	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" /* " */ { 
		`dit' `"Writing to "`using'"; may take several minutes"'
		local startcol_o = 3 // this one will stay fixed (column C)
		local startrow_o = 10

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
		
		// Export to Excel column titles
		local horzincrement = `cols' + 2
		local vertincrement = 13
		
		foreach y of local alllist {
			local startpop = `startcol_o'
			local startpval =`startcol_o' + `horzincrement'
			local trow1 = 9
			forval x = 2/29 {
				local trow`x' = 9 - `vertincrement' + `x' * `vertincrement'
			}
			
			if "``y''"!="" {
				foreach ext of local marg`y' {
					returncol `startpop'
					// Titles	
					forval x = 1/29 {
						local incometitles`y' `incometitles`y'' `r(col)'`trow`x''=(_d_`ext')
					}
					local ++startpop
				}
				foreach ext of local marg`y' {
					returncol `startpval'
					forval x = 1/29 {
						local incometitles`y' `incometitles`y'' `r(col)'`trow`x''=(_d_`ext')
					}
					local ++startpval					
				}
			}
		}
		
		// Print version number on Excel sheet
		local versionprint A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'")
		
		// Print warning message on Excel sheet 
		local warningrow = 384
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
		local warningprint `warningprint' I4=("`warningcount' important warning messages are printed starting on row 382.") 
				
		// Export to Excel (matrices)
		local vertincrement = 13
		local horzincrement = `cols' + 2
		local resultset ""
		local startrow = `startrow_o'
		local concrow = 374
		
			
		foreach x in diffs pvals {
			if "`x'"=="diffs" local startcol = `startcol_o'
			else if "`x'"=="pvals" local startcol = `startcol_o' + `horzincrement'	
			local startrow = `startrow_o'
			returncol `startcol'
			foreach mat of local matrices {
				if strpos("`mat'","conc")==0 {                        // i.e. the matrice is not the concentration coefficient
					local resultset `resultset' `r(col)'`startrow'=matrix(``mat'_`x'')	
				}	
				local startrow = `startrow' + `vertincrement'		 // this is fine because after all inequality and poverty matrices 
																	 // are placed into the resultset local we don't need the startrow any more
			}
			foreach mat of local matrices {
				if strpos("`mat'","conc")!=0 {
					local concname = regexr("`mat'", "conc", "")
					if "``concname''"!="" {
						returncol `startcol'
						local resultset `resultset' `r(col)'`concrow'=matrix(``mat'_`x'')             // concrow the same in each sheet
					}
				}
			}
		}
		
		

		// putexcel
		foreach y of local alllist {
			if "``y''"!="" {
				qui putexcel `titlesprint' `versionprint' `warningprint' `resultset' `incometitles`y'' using `"`using'"', modify keepcellformat sheet("`sheet`y''") // "
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
	
end	// END ceqextsig
