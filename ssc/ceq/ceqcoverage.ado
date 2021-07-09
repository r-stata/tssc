** ADO FILE FOR FISCAL INTERVENTIONS SHEET OF CEQ MASTER WORKBOOK SECTION E

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.8 01jun2017 For use with July 2017 version of CEQ Master Workbook 2016
** v1.7 02apr2017 For use with Oct 2016 version of CEQ Master Workbook 2016
** v1.6 08mar2017 For use with Oct 2016 version of CEQ Master Workbook 2016
** v1.5 06feb2017 For use with Sep 2016 version of CEQ Master Workbook 2016
** v1.4 12jan2017 For use with Oct 2016 version of CEQ Master Workbook 2016
** v1.3 30oct2016 For use with Sep 2016 version of CEQ Master Workbook 2016
** v1.2 01oct2016 For use with Sep 2016 version of CEQ Master Workbook 2016
** v1.1 30sep2016 For use with Jun 2016 version of CEQ Master Workbook 2016
** v1.0 23sep2016 For use with Jun 2016 version of CEQ Master Workbook 2016
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**	 06-01-2017 Add additional options to print meta-information
**   04-02-2017 Remove the temporary variables from the negative tax warning list 
**   03-08-2017 Remove the net in-kind transfers as a broad category in accordance with the instruction that users
**				 supply net in-kind transfer variables to health/education/otherpublic options
**   02-06-2017 Add warning and error messages regarding specification of program options
**				Add if condition to allow fiscal interventions not to be specified
**				Fix issues with db and population estimates
** 	 01-12-2017 Set the data type of all newly generated variables to be double
** 				Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
**   10-30-2016 Fix bug with alltransfersp omitted from the broad categories
**   10-01-2016 Add direct beneficiaries matrix
**	  9-30-2016 Change from d1 command to `command' command in warning 
**				Add warning for negative values of fiscal interventions

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

************************
** ceqcoverage PROGRAM *
************************
** For sheet E18. Coverage Tables
// BEGIN ceqcoverage (Higgins 2015)
capture program drop ceqcoverage
program define ceqcoverage, rclass 
	version 13.0
	#delimit ;
	syntax 
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
			/* FISCAL INTERVENTIONS: */
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
			/* DIRECT BENEFICIARIES */
			RECPensions   (varlist)
			RECDTRansfers (varlist)
			PAYDTAXes     (varlist) 
			PAYCOntribs(varlist)
			RECSUbsidies  (varlist)
			PAYINDTAXes   (varlist)
			RECHEALTH     (varlist)
			RECEDUCation  (varlist)
			RECOTHERpublic(varlist)
			PAYUSERFEESHealth(varlist)
			PAYUSERFEESEduc(varlist)
			PAYUSERFEESOther(varlist)			
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

			/* VARIABLE MODIFICATON */
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
	local command ceqcoverage
	local version 1.8
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
	
	** print warning messages 
	local warning "Warnings"
	
	** make sure all newly generated variables are in double format
	set type double 
	
	** transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic userfeeshealth userfeeseduc userfeesother ///
					   /*nethealth neteducation netother */
	local rec_options ///
		pensions dtransfers subsidies health education otherpublic
	local pay_options ///
		dtaxes contribs indtaxes userfeeshealth userfeeseduc userfeesother
	local program_options /// the ones given in the options
		pensions dtransfers dtaxes contribs subsidies indtaxes ///
		health education otherpublic userfeeshealth userfeeseduc userfeesother
	foreach x of local programlist {
		local allprogs `allprogs' ``x'' // so allprogs has the actual variable names
	}
	
	** columns including disaggregated components and broader categories 
	local broadcats dtransfersp dtaxescontribs inkind userfees /*netinkind*/ alltaxes alltaxescontribs alltransfers alltransfersp
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	local userfees `userfeeshealth' `userfeeseduc' `userfeesother'
	/*local netinkind `nethealth' `neteducation' `netother'*/
	local alltransfers `dtransfers' `subsidies' `inkind' /* `userfees' */
	local alltransfersp  `pensions' `dtransfers' `subsidies' `inkind' /* `userfees' */
	local alltaxes `dtaxes' `indtaxes' // user fees are not included as tax
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	** locals to produce broad categories for direct beneficiaries  (because we need to add pay/rec prefix to the items in locals)
	local dtransfersp_n 	pensions dtransfers
	local dtaxescontribs_n 	dtaxes contribs
	local inkind_n 			health education otherpublic // these contain the variables, or blank if not specified
	local userfees_n 		userfeeshealth userfeeseduc userfeesother
	/*local netinkind_n 		nethealth neteducation netother */
	local alltransfers_n 	dtransfers subsidies inkind userfees 
	local alltransfersp_n   pensions dtransfers subsidies inkind userfees
	local alltaxes_n 		dtaxes indtaxes // user fees are not included as tax
	local alltaxescontribs_n  dtaxes contribs indtaxes	

	foreach cat of local programlist {
		if "``cat''"!="" {
			tempvar v_`cat' // in the locals section despite creating vars
			qui gen double `v_`cat''=0 // because necessary for local programcolsc 
			foreach x of local `cat' {
				qui replace `v_`cat'' = `v_`cat'' + `x' // so e.g. v_dtaxes will be sum of all vars given in dtaxes() option
			}
			
			local v_fiscal `v_fiscal' `v_`cat''           // put the variables in a local so we can keep these variables 
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
			local v_broadcat `v_broadcat' `v_`bc''
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
	
	** check direct beneficiary variables
	foreach x in "rec" "pay" {
		foreach `x'opt of local `x'_options {
			// get the corresponding option for benefit amounts (remove "rec" or "pay" from
				// beginning of option name)
			local _``x'opt' = "`x'" + "``x'opt'"  // regexr("``x'opt'","^`x'","")   
			
			// check if option used
			if "```x'opt''"=="" { // they didn't specify the option
				
				if "``_``x'opt'''"!="" { // they did specify the corresponding option 
						// for benefit amounts
					`dit' "Warning: {bf:``x'opt'} not specified; direct beneficiary results not produced"
					local warning `warning' "Warning: {bf:``x'opt'} not specified; direct beneficiary results not produced"
				}	
			}
			
			else { // they did specify the option
				// make sure length is the same
				if "``_``x'opt'''"!="" {
					cap assert wordcount("```x'opt''")==wordcount("``_``x'opt'''")
					if _rc {
						`die' "Number of variables in {bf:``x'opt'} must be the same as number in {bf:`_``x'opt''} and the variables must be in the same order. If the survey does not contain information on the direct beneficiaries, assign the household head as the direct beneficiaries."
						exit 198
					}
				}
				if "``_``x'opt'''"=="" {
					`dit' "Warning: {bf:`_``x'opt''} not specified; direct beneficiary results not produced"
					local warning `warning' "Warning: {bf:`_``x'opt''} not specified; direct beneficiary results not produced"
				}
				
				
			}
			if "``_``x'opt'''"!="" & "```x'opt''"!="" {
				local `x'list ``x'list' ``x'opt' // the option names
				local `x'vars ``x'vars' ```x'opt'' // the variable names
				local _`x'list `_`x'list'  `_``x'opt'' // option names
				local _`x'vars `_`x'vars'  ``_``x'opt''' // the variable names
			}
		}

	}
	
	
	tokenize `_recvars' 
	
	local db_count = 0
	foreach var in `recvars' { 
		local ++db_count
		local dbc_`var' ``db_count''
	}
	
	tokenize `_payvars'
	
	local db_count = 0
	foreach var in `payvars' {
		local ++db_count
		local dbc_`var' ``db_count''
	}
	
	/*
	tokenize `recvars' `payvars'
	//di "`recvars' `payvars'"
	
	local db_count = 0
	foreach var in `_recvars' `_payvars' {
		local ++db_count
		local db_`var' ``db_count''
	} 
	*/
	
	** generate db variables
	if "`hsize'"!= "" {
		local db_result = 0        // not produce db results for hh-level data
		`dit' "Warning: Household-level data used, but individual-level data strongly recommended for {cmd:ceqcoverage}. Direct beneficiary estimates will not be produced. See {stata help ceqcoverage} for details."
		local warning `warning' "Warning: Household-level data used, but individual-level data strongly recommended for {cmd:ceqcoverage}. Direct beneficiary estimates will not be produced. See {stata help ceqcoverage} for details."
		/*foreach var in `recvars' `payvars' {
			tempvar db_`var'
			qui gen `db_`var'' = `dbc_`var''
			local db_tokeep `db_tokeep' `db_`var''
		}*/
	}
	
	** create individual-level direct beneficiary vars 
	if "`hsize'"=="" {
		
		/*local uniq_recpayvars `_recvars' `_payvars' 
		local uniq_recpayvars : list uniq uniq_recpayvars
		foreach var of local uniq_recpayvars {
			tempvar temp`var'
			qui bys `hhid' : egen `temp`var'' = total(`var')
			qui replace `var' = `temp`var''
		}*/
		foreach cat of local programlist {
			if "``cat''"!="" { 
				if strpos("`pay_options'","`cat'") != 0 {
					if "`pay`cat''"!="" {                 
						tempvar db_`v_`cat''
						foreach x in `pay`cat'' {
							if wordcount("`paytotal'") > 0 local paytotal `paytotal' ,`x'
							else local paytotal `x' 
						}
						if strpos("`paytotal'",",")!=0 qui gen double `db_`v_`cat''' = max(`paytotal')    // e.g. var would be `db_v_pensions' so we can 
																										// be sure each variable is distinct even if users specify multiple options with the same variable
						else qui gen double `db_`v_`cat''' = `paytotal'
					}
				}
				if strpos("`rec_options'","`cat'") != 0 {
					if "`rec`cat''"!="" {
						tempvar db_`v_`cat''
						foreach x in `rec`cat'' {
							if wordcount("`rectotal'") > 0 local rectotal `rectotal' ,`x'
							else local rectotal `x' 
						}
						if strpos("`rectotal'",",")!=0 qui gen double `db_`v_`cat''' = max(`rectotal') 
						else qui gen double `db_`v_`cat''' = `rectotal'
					}
				}
				local db_vlist `db_vlist' `db_`v_`cat'''
				// so suppose there are two direct taxes dtr1, dtr2 and two direct taxes dtax1, dtax2
				// then `programcols' will be dtr1 dtr2 dtransfers dtax1 dtax2 dtaxes
			}
		}	
		
		foreach bc of local broadcats {
			if wordcount("``bc''")>0 {
				tempvar db_`v_`bc''
				qui gen double `db_`v_`bc''' = 0
				local payid = 0
				local recid = 0
				foreach cat of local `bc'_n {                    // so `cat' would be pensions, dtransfers, etc.
					if "``cat''"!="" {                          
						if strpos("`pay_options'","`cat'") != 0 {
							if "`pay`cat''"!="" {
								foreach x in `pay`cat'' {
									if wordcount("`paybroad'") > 0 local paybroad `paybroad' ,`x'
									else local paybroad `x' 
								}
								local payid = 1
							}
						}
						if strpos("`rec_options'","`cat'") != 0 {
							if "`rec`cat''"!="" {
								foreach x in `rec`cat'' {
									if wordcount("`recbroad'") > 0 local recbroad `recbroad' ,`x'
									else local recbroad `x' 
								}
								local recid = 1
							}					
						}
					}
				}
				if `payid' == 1 & strpos("`paybroad'",",")!=0 qui replace `db_`v_`bc''' = max(`paybroad')
				if `payid' == 1 & strpos("`paybroad'",",")==0 qui replace `db_`v_`bc''' = `paybroad'
				if `recid' == 1 & strpos("`recbroad'",",")!=0 qui replace `db_`v_`bc''' = max(`recbroad')
				if `recid' == 1 & strpos("`recbroad'",",")==0 qui replace `db_`v_`bc''' = `recbroad' 
			
				local db_vlist `db_vlist' `db_`v_`bc'''
			}
		}
	}
		
		
	** collapse to hh-level data       
	if "`hsize'"=="" { // i.e., it is individual-level data
		local db_result = 1        // not produce db results for hh-level data
		tempvar members
		sort `hhid', stable
		qui by `hhid': gen `members' = _N // # members in hh 
		
		/*foreach x in "rec" "pay" {
			foreach var of local `x'vars {
				tempvar _`var' 
				qui by `hhid' : egen `_`var'' = total(`var') // counts number of direct ben
				qui replace `var' = `_`var''
			}
		}		*/
		
		// create individual-level and direct beneficiary vars      
		foreach var in `recvars' `payvars' {
			tempvar db_`var'
			qui bys `hhid' : egen `db_`var'' = total(`dbc_`var'') // counts number of direct ben   
			local db_tokeep `db_tokeep' `db_`var''
		}
		
		foreach var of local db_vlist {
			tempvar temp`var'
			qui bys `hhid': egen `temp`var'' = total(`var')
			qui replace `var' = `temp`var''
			local db_tokeep `db_tokeep' `var'
		}
		
		qui bys `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	
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
	local relevar `varlist' `allprogs' `v_fiscal' `v_broadcat'
				  `recvars' `payvars' `_recvars' `_payvars' `db_tokeep' 
				  `w' `psu' `strata' 	
				  `hsize' `exp'
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
	
	// This section is moved up so that we can create db broad category estimates before collapsing
	
	** columns including disaggregated components and broader categories 
	/*local broadcats dtransfersp dtaxescontribs inkind userfees netinkind alltaxes alltaxescontribs alltransfers alltransfersp
	local paybroad dtaxescontribs userfees alltaxes alltaxescontribs 
	local recbroad dtransfersp inkind netinkind alltransfers alltransfersp
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	local userfees `userfeeshealth' `userfeeseduc' `userfeesother'
	local netinkind `nethealth' `neteducation' `netother'
	local alltransfers `dtransfers' `subsidies' `inkind' `userfees' 
	local alltransfersp  `pensions' `dtransfers' `subsidies' `inkind' `userfees'
	local alltaxes `dtaxes' `indtaxes' // user fees are not included as tax
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'


	** locals to produce broad categories for direct beneficiaries  (because we need to add pay/rec prefix to the items in locals)
	local dtransfersp_n 	pensions dtransfers
	local dtaxescontribs_n 	dtaxes contribs
	local inkind_n 			health education otherpublic // these contain the variables, or blank if not specified
	local userfees_n 		userfeeshealth userfeeseduc userfeesother
	local netinkind_n 		nethealth neteducation netother
	local alltransfers_n 	dtransfers subsidies inkind userfees 
	local alltransfersp_n   pensions dtransfers subsidies inkind userfees
	local alltaxes_n 		dtaxes indtaxes // user fees are not included as tax
	local alltaxescontribs_n  dtaxes contribs indtaxes	
	
	
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

	*/
	
	** programs
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
	local dtransferscols
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
	;
	local dtaxescols 
		`dtaxes' `contribs' `v_dtaxes' `v_contribs' `v_dtaxescontribs'
	;
	local subsidiescols
		`subsidies' `v_subsidies'
	;
	local indtaxescols 
		`indtaxes' `v_indtaxes'
	;
	local inkindcols
		`health' `v_health' `education' `v_education' `otherpublic' `v_otherpublic' `v_inkind'
		`userfeeshealth' `v_userfeeshealth' `userfeeseduc' `v_userfeeseduc' `userfeesother' `v_userfeesother' `v_userfees' 
		/*`nethealth' `neteducation'  `netother' `v_netinkind'*/	
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
	/* scalar _d_`v_netinkind'        = "All net inkind transfers"   scalar of specfic net inkind transfers created before */
	local d_`v_inkind'           = "All net in-kind transfers"
	local d_`v_userfeeshealth'   = "All health user fees"
	local d_`v_userfeeseduc'     = "All education user fees"
	local d_`v_userfeesother'    = "All other user fees"
	local d_`v_userfees'	     = "All user fees"
	local d_`v_alltransfers'     = "All net transfers and subsidies excl contributory pensions"
	local d_`v_alltransfersp'    = "All net transfers and subsidies incl contributory pensions"
	local d_`v_alltaxes'         = "All taxes"
	local d_`v_alltaxescontribs' = "All taxes and contributions"
	
	******************
	** PARSE OPTIONS *
	******************
	**
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
			local sheet`vrank' "E18.`_vrank' Coverage Tables" // default name of sheet in Excel files
		}
	}
	
	
	** ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		`dit' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options."
		exit 198
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
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
	
	** titles of groups
	local g1  "y < `cut1'"
	local g2  "`cut1' < y < `cut2'"
	local g3  "y < `cut2'"
	local g4  "`cut2' < y < `cut3'"
	local g5  "y < `cut3'"
	local g6  "`cut3' < y < `cut4'"
	local g7  "`cut4' < y < `cut5'"
	local g8  "y > `cut5'"
	local g9  "y > `cut4'"
	local g10 "y > `cut3'"
	
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
		`dit' "Warning: No file specified with {bf:using}; results saved in {bf:return list} but not exported to CEQ Master Workbook Section E"
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
				`dit' "Warning: `r(N)' negative values of ``v''."
				local warning `warning' "Warning: `r(N)' negative values of ``v''."
			}
		}
	}	
	
	** negative fiscal interventions
	foreach pr of local programcols {
		if "`pr'"!="" {
			qui summ `pr'
			if r(mean)>0 {
				qui count if `pr'<0
				if r(N) `dit' "Warning: `r(N)' negative values of `d_`pr''."
				if r(N) local warning `warning' "Warning: `r(N)' negative values of `d_`pr''."
			}
			if r(mean)<0 {
				qui count if `pr'>0
				if r(N) `dit' "Warning: `r(N)' positive values of `d_`pr'' (variable stored as negative values)."
				if r(N) local warning `warning' "Warning: `r(N)' positive values of `pr' (variable stored as negative values)."
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
	
	** need to replace separately so that broad categories have negative values as well

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

	******************
	** INCOME GROUPS *
	******************
	foreach v of local alllist {
		if "``v''"!="" {
			** groups
			tempvar `v'_group2
			qui gen ``v'_group2' = . 
			forval gp=1/6 {
				qui replace ``v'_group2' = `gp' if ``v'_ppp'>=`cut`=`gp'-1'' & ``v'_ppp'<`cut`gp''
				// this works because I set `cut0' = 0 and `cut6' = infinity
			}
			qui replace ``v'_group2' = 1 if ``v'_ppp' < 0
		}
	}	
	local group2 = 6
	
	**********************
	** CALCULATE RESULTS *
	**********************
	local matrices dtransfers dtaxes subsidies indtaxes inkind
	local dtransfers_rows = 15
	local dtaxes_rows     = 16
	local subsidies_rows  = 15
	local indtaxes_rows   = 15
	local inkind_rows     = 30
	
	foreach mat of local matrices {
		local `mat'_needrows = wordcount("``mat'cols'")
	}
	
	// Starting row for excel
	local dtransfers_start = 17
	local dtaxes_start     = `dtransfers_start' + `dtransfers_rows' + 1
	local subsidies_start  = `dtaxes_start' + `dtaxes_rows' + 1
	local indtaxes_start   = `subsidies_start' + `subsidies_rows' + 1
	local inkind_start     = `indtaxes_start' + `indtaxes_rows' + 1
	local bottom_start     = `inkind_start' + `inkind_rows' // no + 1 since no title row
	
	foreach v of local alllist {
		if "``v''"!="" {
			foreach suffix in "" "_ppp" {
				matrix bottom`v'`suffix' = J(3,7,.)
			}
			foreach mat of local matrices {
				if "``mat''"!="" {
					foreach suffix in "" "_ppp" "_direct" "_hh" "_all" {
						matrix `mat'`v'`suffix' = J(``mat'_needrows',7,.) // 7 is 6 income groups + total
					}
				}
				
				local pr_row = 0
				if "``mat''"!="" {
					foreach pr of local `mat'cols {
						local ++pr_row 
						
						// in LCU
						forval gp=1/6 {
							qui summ `pr' if ``v'_group2'==`gp' `aw' 
							matrix `mat'`v'[`pr_row',`gp'] = r(sum)
						}
						qui summ `pr' `aw'
						matrix `mat'`v'[`pr_row',7] = r(sum) // total
					
						// in PPP
						forval gp=1/6 {
							qui summ ``pr'_ppp' if ``v'_group2'==`gp' `aw' 
							matrix `mat'`v'_ppp[`pr_row',`gp'] = r(sum)
						}
						qui summ ``pr'_ppp' `aw'
						matrix `mat'`v'_ppp[`pr_row',7] = r(sum) // total
					
						// Direct beneficiaries
						** dsijaofpsa

						if "`db_`pr''"!="" & `db_result' == 1 {
							forval gp=1/6 {
								qui summ `db_`pr'' if ``v'_group2'==`gp' ///
									[aw=`exp'] // `db_`pr'' has number of direct beneficiaries in hh
									// use hh weight rather than hhweight*members since
									// `db_`pr'' already has number of ben per hh
								matrix `mat'`v'_direct[`pr_row',`gp'] = r(sum)
							}
						
							qui summ `db_`pr'' [aw=`exp']
							// use hh weight rather than hhweight*members since
							// `db_`pr'' already has number of ben per hh
							matrix `mat'`v'_direct[`pr_row',7] = r(sum)
						}
						if "`db_`pr''"=="" {
							forval noval = 1/7 {
								matrix `mat'`v'_direct[`pr_row',`noval'] = .
							}
						}
				
						** dfaisosapo
					
						// Beneficiary households
						forval gp=1/6 {
							qui summ `one' if ``v'_group2'==`gp' & `pr'!=0 & !missing(`pr') ///
								[aw=`exp']
							matrix `mat'`v'_hh[`pr_row',`gp'] = r(sum)
						}
						qui summ `one' if `pr'!=0 & !missing(`pr') ///
							[aw=`exp']
						matrix `mat'`v'_hh[`pr_row',7] = r(sum) // total
					
						// Direct and indirect beneficiaries
						forval gp=1/6 {
							qui summ `one' if ``v'_group2'==`gp' & `pr'!=0 & !missing(`pr') ///
								`aw'
							matrix `mat'`v'_all[`pr_row',`gp'] = r(sum)
						}
						qui summ `one' if `pr'!=0 & !missing(`pr') ///
							`aw'
						matrix `mat'`v'_all[`pr_row',7] = r(sum) // total
					} // end foreach ...cols
				} // end if 
			} // end foreach mat
			
			// Bottom matter
			foreach suffix in "" "_ppp" {
				forval gp=1/6 {
					qui summ `one' if ``v'_group2'==`gp' `aw'
					matrix bottom`v'`suffix'[1,`gp'] = r(sum)
					
					qui summ `one' if ``v'_group2'==`gp' [aw=`exp']
					matrix bottom`v'`suffix'[2,`gp'] = r(sum)

					qui summ ``v'`suffix'' if ``v'_group2'==`gp' `aw'
					matrix bottom`v'`suffix'[3,`gp'] = r(sum)
				}
				qui summ `one' `aw'
				matrix bottom`v'`suffix'[1,7] = r(sum)
				
				qui summ `one' [aw=`exp']
				matrix bottom`v'`suffix'[2,7] = r(sum)
				
				qui summ ``v'`suffix'' `aw'
				matrix bottom`v'`suffix'[3,7] = r(sum)
			}
			
		} // if "``v''"!=""
	} // foreach v of local alllist
		
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" /* " */ {
		`dit' `"Writing to "`using'"; may take several minutes"'		
		// Locals for Excel columns
		local startcol_o = 4 // this one will stay fixed (column D)
		
		// Export to Excel (matrices)
		local submatrices extp poor rest tot
		local extp_add = 0
		local poor_add = 3
		local rest_add = 5
		local tot_add = 10

		local vertincrement = 104
		local horzincrement =  14 
		foreach v of local alllist {
			if "``v''"=="" continue
			foreach mat in `matrices' "bottom" {
				if "``mat''"!= "" | "`mat'"=="bottom" {
					foreach suffix in "" "_ppp" "_direct" "_hh" "_all" {
						if "`mat'"=="bottom" & ///
							("`suffix'"=="_direct" | "`suffix'"=="_hh" | "`suffix'"=="_all") ///
							continue
						foreach sub of local submatrices {
							tempname `mat'`v'`suffix'_`sub'
						}
						matrix ``mat'`v'`suffix'_extp' = `mat'`v'`suffix'[1...,1..2]
						matrix ``mat'`v'`suffix'_poor' = `mat'`v'`suffix'[1...,3]
						matrix ``mat'`v'`suffix'_rest' = `mat'`v'`suffix'[1...,4..6]
						matrix ``mat'`v'`suffix'_tot'  = `mat'`v'`suffix'[1...,7]
					
						if ("`suffix'"=="" | "`suffix'"=="_ppp") ///
							local therow = ``mat'_start'
						else local therow = ``mat'_start' + `vertincrement'

						if ("`suffix'"=="" | "`suffix'"=="_direct") ///
							local thecol = `startcol_o'
						else if ("`suffix'"=="_ppp" | "`suffix'"=="_hh") ///
							local thecol = `startcol_o' + `horzincrement'
						else local thecol = `startcol_o' + `horzincrement'*2
						
						foreach sub of local submatrices {
							local thesubcol = `thecol' + ``sub'_add'
							returncol `thesubcol'
							local resultset`v' `resultset`v'' `r(col)'`therow'=matrix(``mat'`v'`suffix'_`sub'')
						}
					}
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
				
		// Export to Excel (row titles)
		local titlerow = 2
		returncol `titlerow'
		foreach mat of local matrices {
			local rr = ``mat'_start'
			foreach pr of local `mat'cols {
				local titles `titles' `r(col)'`rr'=("`d_`pr''")
				local ++rr
			}
		}	
				
		// Export to Excel (group cutoffs)
		local startcol = `startcol_o'
		local cutoffrow = 15
		forval i=1/10 {
			returncol `startcol'
			local cutoffs `cutoffs' `r(col)'`cutoffrow'=("`g`i''")
			local ++startcol
		}
		
		// Print warning message on Excel sheet 
		local warningrow = 623
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
		local warningprint `warningprint' A5=("`warningcount' important warning messages are printed starting on row 662.") 
		
		// putexcel
		foreach vrank of local alllist {
			if "``vrank''"!="" {
				qui putexcel `titlesprint' `versionprint'  ///
					`resultset`vrank'' `titles' `cutoffs' `warningprint' using `"`using'"', /// "
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
	
end	// END ceqcoverage
