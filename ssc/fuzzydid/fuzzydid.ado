/*
fuzzydid.ado performs the following operations:
1) It checks that the estimators requested by the user can be computed.
In particular, it checks that there are no inconsistencies between the various 
options requested by the user.
2) It calls estim_wrapper, which computes the Wald-DID, Wald-TC, 
Wald-CIC and LQTE point estimates requested by the user.
3) If the user requested the standard errors of those point estimates, it 
bootstraps estim_wrapper, using Stata's internal bootstrap command.
4) It posts results to the user, and stores them.
*/

quietly capture program drop fuzzydid
quietly program fuzzydid, byable(recall) eclass sortpreserve
 
	version 13.1
	
	/*command's syntax*/
	syntax varlist(min=4 max=5 numeric) [if] [in] ///
	[, CLuster(varlist numeric) ///
	EQTest DID TC CIC LQTE ///
	NEWCateg(numlist min=2) ///
	CONTinuous(varlist numeric) QUALItative(varlist numeric fv) ///
	breps(numlist int>=2 max=1) NOSE ///
	modelx(namelist min=2 max=3) SIEVES ///
	SIEVEOrder(numlist int>=2) NUMerator PARTial TAGobs]
	
	/*temp scalars, matrices and variables*/				
	tempname N
	tempvar nouse_cont nouse_quali new_categ_varname Dbis Gbis Tbis indiv_id
	tempfile used_data
	
	/*if tagobs option required, check if no variable named tagobs already 
	exists in the dataset.*/
	if "`tagobs'"!="" {
	
		capture confirm variable tagobs
		
		if _rc==0 {
		
			display as err _newline(1) "There already exists a " ///
			"variable named tagobs in your dataset. " ///
			"Rename it before using the tagobs option." _newline(1)
			ereturn clear
			exit
		}
	}
	
	gen `indiv_id'=_n
	
	preserve
	
	xtset, clear
		
	tokenize `varlist', parse(" ,")
	
	local varlist_count=wordcount("`varlist'")
	

	tempvar touse
	
	quietly gen byte `touse'=1 `if' `in'
	quietly replace `touse'=0 if `touse'==.	
	
	
	/*temp: due to change of name of the moreoutput option (new name eqtest),
	trick to avoid changing all the code*/
	if "`eqtest'"=="" {
	
		local moreoutput ""
	}
	else {
	
		local moreoutput "moreoutput"
	}
	
	
	
	/*rename outcome, group, time and treatment and identify mechanically
	missing values in Gb and Gf and replace those with -3*/
	if `varlist_count'==4 {
	
		args Y G T D
		quietly count if (`G'!=0 & `G'!=1 & `G'!=.) & `touse'
		
		if r(N)!=0 {
		
			display as err _newline(1) "When only one G variable is specified " ///
			"by the user, that variable must either be equal to 0, 1, or be missing. " ///
			"See section 4.2 of the paper in the Stata journal for more details " ///
			"on how to create the G variables." _newline(1)
			ereturn clear
			exit
		}
	}
	
	
	
	
	if `varlist_count'==5 {
	
		args Y Gb Gf T D
		
		local G_list "`Gb' `Gf'"
		local G_issue=0
		
		foreach A of local G_list {
		
			quietly count if (`A'!=-1 & `A'!=0 & `A'!=1 & `A'!=.) & `touse'
			
			if r(N)!=0 {
			
				display as err _newline(1) "The group variable `A' takes " ///
				"values outside \{-1,0,1,.\}." _newline(1)			
				local G_issue=1
				continue, break
			}			
		}
		
		if `G_issue'!=0 {
		
			ereturn clear
			exit
		}
																
		tempname min_T max_T
		quietly sum `T' if `touse'
		scalar `min_T'=r(min)
		scalar `max_T'=r(max)
		
		if `min_T'!=`max_T' {
		
			quietly replace `Gb'=-3 if `T'==`min_T' & `Gf'!=. & `touse'
			quietly replace `Gf'=-3 if `T'==`max_T'	& `Gb'!=. & `touse'	
		}
		else {
			
			display as err _newline(1) "There must be at least two " ///
			"time periods in the sample." _newline(1)
			ereturn clear
			exit
		}
	}
	
	/*identification of the estimation sample (markout=internal to stata)*/
	*marksample touse
	if `varlist_count'==4 {
	
		quietly markout `touse' `G'
	}
	
	if `varlist_count'==5 {
	
		quietly replace `touse'=0 if `Gb'==. & `Gf'==.
	}
	
	quietly markout `touse' `Y' `D' `T'
	
	ereturn clear	
	
	/*if no estimator required, error*/
	if "`did'"=="" & "`tc'"=="" & "`cic'"=="" & "`lqte'"=="" {
	
		display as err _newline(1) "At least one of " ///
		"the DID, TC, CIC, or LQTE estimators must be indicated." _newline(1)
		ereturn clear
		exit
	}

	
	/*drop obs for which continuous/qualitative covs or cluster var are missing*/	
	if "`continuous'"!="" {
	
		quietly markout `touse' `continuous'
	}
	
	if "`qualitative'"!="" {
	
		quietly markout `touse' `qualitative'
	}
	
	if "`cluster'"!="" {
	
		quietly markout `touse' `cluster'
	}

	/*create a list with all covariates*/
	if "`continuous'"!="" | "`qualitative'"!="" {
	
		local covariates "`continuous' `qualitative'"
	}
	else {
	
		local covariates ""
	}
	
	/*count number of obs in estimation sample*/
	quietly count if `touse'
	scalar `N'=r(N)
	
	if `N'==0 {
	
		display as err _newline(1) ///
		"No observations in the sample." _newline(1)
		ereturn clear
		exit
	}
	
	
	quietly {
		
		
		/*keep only variables that are necessary in the computation
		(temporary drop of variables)*/
		
		if "`covariates'"!="" {
		
			keep `varlist' `covariates' `touse' `cluster' `indiv_id'
		}
		else {
		
			keep `varlist' `touse' `cluster' `indiv_id'			
		}
		
		
		/*keep only  observations labelled as ok and save them in tempfile
		in order to identify observations used in the original dataset*/
		keep if `touse'
		save "`used_data'"
	}	
		
	/*count number of different levels of the treatment and the outcome*/
	local issue_treatment=0
	capture tab `D', nofreq
	
	if _rc!=0 {
		
		if "`lqte'"!="" {
			
			display _newline(1) as error ///
			"Local quantile treatment effects can only be estimated " ///
			"with a binary treatment variable." _newline(1)			
			local issue_treatment=1
		}
		
		if "`newcateg'"=="" {
		
			if "`tc'"!="" | "`cic'"!="" {
			
				display as err _newline(1) "The treatment variable " ///
				"takes too many values. Use ncateg." _newline(1)
				local issue_treatment=1
			}	
		}
		
		if `issue_treatment'==1 {
		
			ereturn clear
			exit
		}
		else {
		
			local ncateg=.
		}
	}
	else {
	
		local ncateg=r(r)
	}
	
	capture tab `Y', nofreq
	
	if _rc!=0 {
	
		local y_ncateg=.
	}
	else {
	
		local y_ncateg=r(r)
	}

	
	/*incoherent to require no standard errors and give a number of 
	bootstrap replications so in that case -> error*/
	
	if "`breps'"!="" & "`nose'"!="" {
	
		display as err _newline(1) "nose and breps cannot be " ///
		"used together." _newline(1)
		ereturn clear
		exit
	}	
	
	/*since bootstrap is compulsory, when breps not filled in, number of
	bootstrap replications set to default=50*/
	
	if "`breps'"=="" {
	
		local breps=50
	}	
	
	/*incoherent to require no standard errors and give an index to define
	cluster standard errors -> error*/
	
	if "`cluster'"!="" & "`nose'"!="" {
	
		display as err _newline(1) "nose and cluster cannot be " ///
		"used together." _newline(1)
		ereturn clear
		exit
	}	

	
	
	/***************************************************************/
	
	
	tempname min_D max_D
	quietly sum `D' 
	scalar `max_D'=r(max)
	scalar `min_D'=r(min)	
	
	
	/*create a "new" treatment with values coded as 1,2,...,cardinality(treatment)*/
	quietly egen `Dbis'=group(`D')
	
	/*treatment check (at least 2 treatment levels in the whole sample)*/
	if `ncateg'<2 {
		
		display _newline(1) as error ///
		"The treatment variable must take " ///
		"at least two different values." _newline(1)
		ereturn clear
		exit			
	}	
	
		
	/*checks of group variable*/
		
	if `varlist_count'==4 {
	
		local G_list "`G'"
	}
	else {
	
		local G_list "`Gb' `Gf'"
	}
	
	local issue_G=0
	
	foreach A of local G_list {
		
		/*check there are obs in stable group*/
		quietly count if `A'==0
		
		if r(N)==0 {
		
			local issue_G=1
		}
	}

	if `issue_G'==1 {
	
		display _newline(1) as error ///
		"The group variable `G' must take the value 0 for some observations " ///
		"in the sample." _newline(1)
		ereturn clear
		exit	
	}	
	
	
	/*reindex T and check that at least 2 periods*/	
	tempname ncateg_T
	quietly egen `Tbis'=group(`T')
	quietly replace `T'=`Tbis'
	quietly drop `Tbis'
	capture tab `T', nofreq
	
	if _rc!=0 {
	
		scalar `ncateg_T'=.
	}
	else {
	
		scalar `ncateg_T'=r(r)
	}
	
	if `ncateg_T'<2 {
		
		display _newline(1) as error ///
		"The fuzzydid package requires at least " ///
		"two time periods. " _newline(1)
		ereturn clear
		exit
	}
	
	if `ncateg_T'==. {
	
		display as error _newline(1) ///
		"There are too many time periods." _newline(1)
		ereturn clear
		exit
	}
	
		
	if `ncateg_T'>2 & `varlist_count'==4 {
	
		display _newline(1) as error ///
		"With more than two time periods, the forward and backward " ///
		"group identifiers Gb and Gf must be used." _newline(1)
		ereturn clear
		exit
	}		
		
	/*cluster check*/
	if "`cluster'"!="" {
				
		local clustnum=wordcount("`cluster'")
		
		if `clustnum'>1 {
		
			display _newline(1) as error ///
			"Only one clustering variable allowed." _newline(1)
			ereturn clear
			exit
		}	
	}
	
	
	/*check if option newcateg useful or not*/
	tempname new_categ_useless
	scalar `new_categ_useless'=1
		
	if "`tc'"!="" {
	
		if `ncateg'>2 & "`newcateg'"!="" {
	
			scalar `new_categ_useless'=0
		}
	}
	
	if "`cic'"!="" {
	
		if `ncateg'>2 & "`newcateg'"!="" {

			scalar `new_categ_useless'=0
		}
	}		
	
	
	/*check if lqte required with an ordered treatment*/		
	if `ncateg'!=2 & "`lqte'"!="" {

		display _newline(1) as error ///
		"Local quantile treatment effects can only be estimated " ///
		"with a binary treatment variable." _newline(1)
		ereturn clear
		exit
	}
	
	/*check if lqte required with more than two groups or more than two periods*/
	if "`lqte'"!="" {
		
		if `ncateg_T'>2 {
		
			display _newline(1) as err "lqte cannot be used when there " ///
			"are more than two periods." _newline(1)
			ereturn clear
			exit			
		}
		
		/*if `varlist_count'==4 {
		
			local G_list "`G'"
		}
		else {
		
			local G_list "`Gb' `Gf'"
		}*/
		
		local pb_lqte=0
		
		foreach A of local G_list {
			
			/*if there are obs both in group where treatment increases
			and decreases, lqte cannot be computed*/
			quietly count if `A'==-1
			local decrease=r(N)
			quietly count if `A'==1
			local increase=r(N)
			
			if (`decrease'!=0 & `increase'!=0) {
			
				local pb_lqte=1
			}
		}
		
		if `pb_lqte'==1 {
		
			display _newline(1) as err "lqte cannot be used when there " ///
			"are more than two groups." _newline(1)
			ereturn clear
			exit
		}
	}
	
	/*numerator(), partial() and eqtest() options' checks*/
	if "`numerator'"!="" & "`did'"=="" & "`tc'"=="" & "`cic'"=="" {
	
		display _newline(1) as error ///
		"numerator can only be used in combination " ///
		"with did, tc or cic." _newline(1)
		ereturn clear
		exit
	}
	
	
	if "`numerator'"!="" {
	
		if `ncateg_T'>2 {
	
			display _newline(1) as error ///
			"numerator can only be used with " ///
			"two time periods." _newline(1)
			ereturn clear
			exit
		}
		
		local pb_num=0
		
		foreach A of local G_list {
			
			capture tab `A' if `A'!=-3, nofreq
			
			if r(r)>2 {
			
				local pb_num=1
			}
		}
		
		if `pb_num'==1 {
		
			display _newline(1) as error ///
			"numerator can only be used with " ///
			"two treatment groups." _newline(1)
			ereturn clear
			exit		
		}
	}	
	
		
	if "`eqtest'"!="" & ("`numerator'"!="" | "`nose'"!="") {
		
		display _newline(1)	as err "eqtest cannot be used with " ///
		"numerator or nose." _newline(1)
		ereturn clear
		exit
	}
		
	
	if "`partial'"!="" {
	
		if "`tc'"=="" {
			
			display _newline(1) as err ///
			"partial can only be used with the tc estimator." ///
			_newline(1)
			ereturn clear
			exit		
		}
		
		if "`covariates'"!="" {
		
			display _newline(1) as err ///
			"partial can only be used without covariates." ///
			_newline(1)	
			ereturn clear
			exit
		}
		
		if "`numerator'"!="" {
			
			display _newline(1) as err ///
			"partial cannot be used with numerator." ///
			_newline(1)
			ereturn clear
			exit
		}
		
		if `ncateg_T'>2 {
	
			display _newline(1) as error ///
			"partial can only be used with " ///
			"two time periods." _newline(1)
			ereturn clear
			exit
		}
		
		local pb_partial=0
		
		foreach A of local G_list {
			
			capture tab `A' if `A'!=-3, nofreq
			
			if r(r)>2 {
			
				local pb_partial=1
			}
		}
		
		if `pb_partial'==1 {
		
			display _newline(1) as error ///
			"partial can only be used with " ///
			"two treatment groups." _newline(1)
			ereturn clear
			exit		
		}				
	}
			
	
	/*if newcateg option useful and required, enter*/
	if `new_categ_useless'==0 {
		
		/*count number of new treatment statuses*/
		local n_newcateg=wordcount("`newcateg'")				
		local error_new_treatment_cat_order=0
		
		
		if `n_newcateg'>`ncateg' {
		
			display _newline(1) as error ///
			"newcateg must have fewer values than the treatment variable." ///
			_newline(1)
		
			ereturn clear
			exit
		}		
		
		if `n_newcateg'<2 {
		
			display _newline(1) as error ///
			"newcateg must have at least two values." ///
			_newline(1)
		
			ereturn clear
			exit
		}		
			
		/*check that the grouping limits were given in increasing order*/
		forvalues i=1(1)`n_newcateg' {
			
			local new_categ_`i': word `i' of `newcateg'
			
			if `i'>1 {
					
				local i_bis=`i'-1
			
				if `new_categ_`i''<=`new_categ_`i_bis'' {
					
					display _newline(1) as error ///
					"The values indicated in newcateg " ///
					"must be strictly increasing." _newline(1)
					
					local error_new_treatment_cat_order=1
					continue, break
				}
			}
		}
		
		if `error_new_treatment_cat_order'==1 {
		
			ereturn clear
			exit
		}

		/*if first grouping value strictly smaller than min treatment value 
		in sample or larger or equal to max treatment value in sample, error*/
		if (`new_categ_1'<`min_D' | `new_categ_1'>=`max_D') {

			display _newline(1) as error ///
			"First element of newcateg must be at least equal to the minimum " ///
			"value of the treament and strictly smaller " ///
			"than the maximum value of the treatment." _newline(1)
			ereturn clear
			exit				
		}		
		
		/*if last grouping value smaller than max treatment value in sample, error*/
		if `new_categ_`n_newcateg''<`max_D' {

			display _newline(1) as error ///
			"Last element of newcateg must be at least equal to the maximum " ///
			"value of the treament." _newline(1)
			ereturn clear
			exit				
		}				
		
		/*create new treatment variable according to the bounds given in newcateg*/
		capture create_new_D `D', touse(`touse') ///
		new_categ(`newcateg') new_categ_varname(`new_categ_varname') ///
		max_D(`max_D')
		
		if _rc!=0 {
		
			display as err _newline(1) "Computation of the recategorized " ///
			"treatment variable indicated in newcateg failed." _newline(1)
			ereturn clear
			exit
		}
		
		local final_D_var "`new_categ_varname'"
		local ncateg_fin "`n_newcateg'"
	}
	
	if "`newcateg'"=="" | `new_categ_useless'==1 {
	
		local final_D_var "`Dbis'"
		local ncateg_fin "`ncateg'"
	}	
	

	/*check covariates-specific options*/
	if "`covariates'"!="" {
	
		local covariates_message ""
			
		if "`lqte'"!="" | "`cic'"!="" {
		
			display as err _newline(1) "continuous and qualitative cannot be used in combination with cic or lqte." _newline(1)
			ereturn clear
			exit
		}		
	}
	
	/*error if both modelx() and sieves used*/
	if "`modelx'"!="" & ("`sieves'"!="" | "`sieveorder'"!="") {
	
		display as error _newline(1) ///
		"modelx cannot be used in combination with sieves/sieveorder." ///
		_newline(1)
		ereturn clear
		exit
	}
	
	if "`sieves'"=="" & "`sieveorder'"!="" {
	
		display as error _newline(1) ///
		"sieveorder cannot be used without sieves." ///
		_newline(1)
		ereturn clear
		exit	
	}
	
	if "`modelx'"!="" & "`covariates'"!="" {
	
		/*count number of words in option modelx: if two words and D is not binary, error*/
		local how_many_words=wordcount("`modelx'")
		
		if `how_many_words'!=3 & `ncateg'!=2 {
		
			display as error _newline(1) "As the treatment variable takes more than two values, " ///
			"three estimation methods must be specified " ///
			"in modelx: one to estimate E(Y|X), one " ///
			"to estimate E(D|X), and one for P(D=d|X)." _newline(1)
			ereturn clear
			exit
		}
		
		if `how_many_words'!=3 {
		
			/*extract words from option modelx*/
			local ymethod: word 1 of `modelx'					
			local dmethod1: word 2 of `modelx'
			local dmethod2: word 2 of `modelx'
			local verif1=0		
		}
		else {
		
			/*extract words from option modelx*/
			local ymethod: word 1 of `modelx'					
			local dmethod1: word 2 of `modelx'
			local dmethod2: word 3 of `modelx'
			local verif1=0		
		}
		
		
		/*store appropriate regression method for Y*/
		if "`ymethod'"=="ols" {
		
			local y_reg_met "reg"
		}
		
		if "`ymethod'"=="probit" {
		
			if `y_ncateg'==2 {
			
				local y_reg_met "probit"
			}
			else {
				
				local verif1=1
			}			
		}
		
		if "`ymethod'"=="logit" {
		
			if `y_ncateg'==2 {
			
				local y_reg_met "logit"
			}
			else {
					
				local verif1=1
			}
		}
		
		/*if reg method is different from ols, logit or probit, error*/
		if "`ymethod'"!="ols" & "`ymethod'"!="probit" & ///
		"`ymethod'"!="logit" {
			
			display as error _newline(1) "Method specified to estimate E(Y|X) " ///
			"not valid. One of the following must be chosen: " ///
			"ols, probit, or logit." _newline(1)
			ereturn clear
			exit
		}

		/*store appropriate regression method for D*/		
		if "`dmethod1'"=="ols" {
		
			local d_reg_met "reg"							
		}
		
		if "`dmethod1'"=="probit" {
		
			if `ncateg'==2 {
			
				local d_reg_met "probit"					
			}
			else {
				
				local verif1=1
			}
		}
		
		if "`dmethod1'"=="logit" {
		
			if `ncateg'==2 {
			
				local d_reg_met "logit"
			}
			else {
				
				local verif1=1
			}
		}

		if "`dmethod2'"=="ols" {
		
			local d_reg_met2 "reg"
		}		
		
		if "`dmethod2'"=="probit" {
			
			local d_reg_met2 "probit"
		}
		
		if "`dmethod2'"=="logit" {

			local d_reg_met2 "logit"	
		}
		
				
		/*if reg method is different from ols, logit or probit, error*/		
		if ("`dmethod1'"!="ols" & "`dmethod1'"!="probit" & ///
		"`dmethod1'"!="logit") | ("`dmethod2'"!="ols" & "`dmethod2'"!="probit" ///
		& "`dmethod2'"!="logit") {
		
			display as error _newline(1) "Method specified to estimate E(D|X) " ///
			"not valid. One of the following must be chosen: ols, probit " ///
			"or logit." _newline(1)
			ereturn clear
			exit
		}
		
		/*if probit/logit required for nonbinary outcome variables, error*/
		if `verif1'==1 {
		
			display as error _newline(1) "The outcome variable Y or " ///
			"the treatment variable D are not binary. Therefore E(Y|X) " ///
			"or E(D|X) cannot be estimated via probit or logit." _newline(1)
			ereturn clear
			exit
		}			
		
		local inf_method "param"
	}
	
	if "`sieves'"!="" & "`covariates'"!="" {
		
		local inf_method "sieve"
		
		if "`continuous'"=="" {
		
			display as err _newline(1) ///
			"sieves requires continuous " ///
			"covariates." _newline(1)
			ereturn clear
			exit
		}	
		
		if "`sieveorder'"!="" {
		
			local how_many_words=wordcount("`sieveorder'")
			
			if `how_many_words'!=2 {
			
				display as error _newline(1) "Two sieve " ///
				"orders must be specified in sieveorder: one to estimate E(Y|X) " ///
				"and one to estimate E(D|X)." _newline(1)
				ereturn clear
				exit
			}
		}
	}
	
	quietly {
	
		if "`covariates'"!="" & "`modelx'"=="" & "`sieves'"=="" {
			
			/*if covariates but no regression method supplied (either param or nonparam)
			method set to ols*/
			local covariates_message "No method was specified to estimate E(Y|X), E(D|X) and P(D=d|X). Method set to default: ols."
			local y_reg_met "reg"
			local d_reg_met "reg"
			local d_reg_met2 "reg"
			local inf_method "param"
		}		
		
		*cluster local vars for internal stata commands
		local clust ""
		
		if "`cluster'"!="" {
		
			local clust "cluster(`cluster')"
		}	
				
		
		local ncateg_t_bis=`ncateg_T'-1
		local outer_error_counter=0
		local is_special_case=0

		/*Checks of potential support issues for the treatment
		variable*/	
		if ("`tc'"!="" | "`cic'"!="" | "`lqte'"!="") {
			
			local ncateg_t=`ncateg_T'
			tempvar indic_t G_star indic_decrease indic_increase
			
			forvalues t=2(1)`ncateg_t' {
							
				local t_bis=`t'-1
				local is_special_case_temp=0
				gen `indic_t'=(`T'==`t')
				replace `indic_t'=. if (`T'!=`t' & `T'!=`t_bis')
				count if `indic_t'!=.
				local N_t=r(N)
				
				if `varlist_count'==4 {
				
					gen `G_star'=`G' if `indic_t'!=.
				}
				else {
				
					gen `G_star'=`indic_t'*`Gb'+(1-`indic_t')*`Gf' if `indic_t'!=.
				}
				
				count if `G_star'==0
				
				if r(N)!=0 {
					
					/*check if support of recategorised treatment variable in 
					the control group is a 
					singleton at period t. If so, then we are in 
					"partially-sharp treatment design" that
					we correct for. N.B: important to use 
					recategorised treatment in this check, because it is
					possible to not be in this special case with initial
					treatment and be in it with recategorised one.*/
					
					capture tab `final_D_var' if `G_star'==0, nofreq

					if _rc==0 {
					
						if r(r)==1 {
							
							local is_special_case_temp=1
							local is_special_case=1
						}
					}
					
					/*check if treatment support coincides in different subgroups. 
					special_cases is another subprogram. */
					if `is_special_case_temp'==0 {
						
						local error_part_sharp1=1
						local error_part_sharp2=1
						
						count if `G_star'==-1
						
						if r(N)!=0 {
							
							tempname is_part_sharp_1
							gen `indic_decrease'=(`G_star'==-1) ///
							if `indic_t'!=. & `G_star'!=1
							special_cases `indic_decrease' `indic_t' ///
							`final_D_var', ///
							ncateg(`ncateg_fin') is_part_sharp(`is_part_sharp_1')	
							
							if `is_part_sharp_1'==0 {
						
								local error_part_sharp1=0
							}
							
							drop `indic_decrease'
						}

						count if `G_star'==1
						
						if r(N)!=0 {
							
							tempname is_part_sharp_2
							gen `indic_increase'=(`G_star'==1) ///
							if `indic_t'!=. & `G_star'!=-1
							special_cases `indic_increase' `indic_t' ///
							`final_D_var', ///
							ncateg(`ncateg_fin') is_part_sharp(`is_part_sharp_2')	
							
							if `is_part_sharp_2'==0 {
						
								local error_part_sharp2=0
							}
							
							drop `indic_increase'
						}
						
						if `error_part_sharp1'==1 & `error_part_sharp2'==1 {
						
							local outer_error_counter=`outer_error_counter'+1
						}
					}
				}
				else {
				
					local outer_error_counter=`outer_error_counter'+1
				}
					
				drop `G_star' `indic_t'
			}
		}
	}
	
			
	/*second check: impossible to estimate treatment effects at any pair of consecutive
	dates*/	
	if `outer_error_counter'==`ncateg_T'-1 {
	
		display _newline(1) as err "Given the data structure, " ///
		"impossible to estimate tc, cic or lqte. Often, this error arises " ///
		"because the treatment takes too many values. " ///
		"It can then be solved using newcateg." _newline(1) 
		ereturn clear
		exit
	}
	
		
	if "`partial'"!="" & `is_special_case'==1 {

		/*if partial option used and we are in partially-sharp design, error
		because bounds not computed in that design*/	

		display _newline(1) as err ///
		"Given the data structure, partial cannot be used (see Section 3.4.2 of de Chaisemartin and D'Haultfoeuille (2018) for details)." _newline(1)
		ereturn clear
		exit
	}
	
	/////////// creation of new variables in case of sieve estimation*/
	if "`inf_method'"=="sieve" {
		
		tempname orderY orderD
		
		local message_CV1 ""		
		
		if "`sieveorder'"=="" {
											
			/*computation of sieve order if no order specified*/
			local message_CV1 "No order specified for sieve estimation. Order selected via cross validation." 
			
			/*order selection for outcome*/				
			capture five_fold_cv `Y' `G_list' `T', continuous(`continuous') ///
			qualitative(`qualitative') cluster(`cluster') sieve_order(`orderY')
						
			if _rc!=0 {
								
				display as error _newline(1) "Cross-validation to select " ///
				"the polynomial order in the model for Y failed. " ///
				"Try user-chosen orders with sieveorder " ///
				"or use modelx." _newline(1)
				ereturn clear
				exit
			}
			else {
			
				if `orderY'==0 | `orderY'==. {
				
					display as error _newline(1) "Cross-validation to select " ///
					"the polynomial order in the model for Y failed. " ///
					"Try user-chosen orders with sieveorder " ///
					"or use modelx." _newline(1)
					ereturn clear
					exit
				}
			}	
			
			
			/*order selection for treatment*/				
			capture five_fold_cv `D' `G_list' `T', continuous(`continuous') ///
			qualitative(`qualitative') cluster(`cluster') sieve_order(`orderD')
						
			if _rc!=0 {
								
				display as error _newline(1) "Cross-validation to select " ///
				"the polynomial order in the model for D failed. " ///
				"Try user-chosen orders with sieveorder " ///
				"or use modelx." _newline(1)
				ereturn clear
				exit
			}
			else {
			
				if `orderD'==0 | `orderD'==. {
				
					display as error _newline(1) "Cross-validation to select " ///
					"the polynomial order in the model for D failed. " ///
					"Try user-chosen orders with sieveorder " ///
					"or use modelx." _newline(1)
					ereturn clear
					exit
				}
			}	
			
			local ncont=wordcount("`continuous'")
			local order_Y=`orderY'
			local order_D=`orderD'
			local n_new_vars_Y=comb(`ncont'+`order_Y',`order_Y')
			local n_new_vars_D=comb(`ncont'+`order_D',`order_D')
		}
		else {
			
			/*if order specified but too many polynomial
			terms to compute, error*/
			local ncont=wordcount("`continuous'")
			local order_Y: word 1 of `sieveorder'
			local order_D: word 2 of `sieveorder'
			local n_new_vars_Y=comb(`ncont'+`order_Y',`order_Y')
			local n_new_vars_D=comb(`ncont'+`order_D',`order_D')
						
			if max(`n_new_vars_Y',`n_new_vars_D')>min(4800,`N'/5) {
										
				display as error _newline(1) "Polynomial order indicated in sieveorder too large. " _newline(1)
				ereturn clear
				exit					
			}
			else {
			
				scalar `orderY'=`order_Y'
				scalar `orderD'=`order_D'					
			}
		}			
		
		/*if no error, build the power expansion at required sieve order*/	
		local n_new_vars=max(`n_new_vars_Y',`n_new_vars_D')
		local varz ""
				
		/*list of empty variables to collect the polynomial terms*/
		forvalues i=1(1)`n_new_vars' {
		
			tempvar v`i'
			local varz "`varz' `v`i''"
		}
		
		/*creation of the polynomial terms*/
		local order_Y=`orderY'
		local order_D=`orderD'
		capture legendrisation, continuous_var(`continuous') ///
		order1(`order_Y') order2(`order_D') new_vars(`varz')
				
		if _rc!=0 {
		
			display as error _newline(1) "Construction of sieve polynomial " ///
			"variables failed. Try modelx instead." _newline(1)
			ereturn clear
			exit
		}
		
		if `n_new_vars_Y'<=`n_new_vars_D' {
		
			local varlist_Y "`e(list_bis)'"
			local varlist_D "`varz'"
		}
		else {
		
			local varlist_D "`e(list_bis)'"
			local varlist_Y "`varz'"		
		}		
	}
	
	
	/*********************************************************************/	
	/*********************************************************************/	
	/*START OF THE SECTION SPECIFIC TO ESTIMATORS WITHOUT STANDARD ERRORS*/		
	/*********************************************************************/	
	/*********************************************************************/		
		
	if "`nose'"!="" {
	
		ereturn clear
		
		estim_wrapper `Y' `G_list' `T' `final_D_var', ///
		true_D(`D') tot_obs(`N') ///
		continuous(`continuous') qualitative(`qualitative') ///
		y_reg_method(`y_reg_met') d_reg_method(`d_reg_met') ///
		d_reg_method2(`d_reg_met2')	inf_method(`inf_method') ///
		sieve_expansion_Y(`varlist_Y') sieve_expansion_D(`varlist_D') ///		
		`did' `tc' `cic' `lqte' ///
		`numerator' `partial'
				
		if "`lqte'"!="" {
			
			tempname LQTE
			matrix `LQTE'=e(LQTE)
			
			forvalues i=1(1)19 {
									
				if (`LQTE'[`i',1]<=-999999999999999 | `LQTE'[`i',1]>=999999999999999) {
					
					matrix `LQTE'[`i',1]=.
				}
			}
		}
		
		tempname no_se_res_mat W_DID W_TC W_CIC ///
		DID_num TC_num CIC_num TC_inf TC_sup
		local done1=0
		local rownames ""
		local obs=`N'
		
		/*if no pb above, store results in temporary variables
		and prepare results' tables*/		
		if "`did'"!="" {
			
			if "`numerator'"!="" {
				
				if (e(DID_num)<=-999999999999999 | e(DID_num)>=999999999999999) {
				
					scalar `DID_num'=.
				}
				else {
				
					scalar `DID_num'=e(DID_num)
				}
				
				matrix `no_se_res_mat'=`DID_num'
				local rownames "`rownames' DID_num"
				local done1=1
			}
			else {
			
				if (e(W_DID)<=-999999999999999 | e(W_DID)>=999999999999999) {
					
					scalar `W_DID'=.
				}
				else {
					
					scalar `W_DID'=e(W_DID)
				}			
			
				matrix `no_se_res_mat'=`W_DID'
				local rownames "`rownames' W_DID"
				local done1=1					
			}
		}
		
		if "`tc'"!="" {
			
			if "`partial'"!="" {
				
				if (e(TC_inf)<=-999999999999999 | e(TC_inf)>=999999999999999) {
				
					scalar `TC_inf'=.
				}
				else {
				
					scalar `TC_inf'=e(TC_inf)
				}				
				
				if (e(TC_sup)<=-999999999999999 | e(TC_sup)>=999999999999999) {
				
					scalar `TC_sup'=.
				}
				else {
				
					scalar `TC_sup'=e(TC_sup)
				}				
				
				if `done1'==1 {
				
					matrix `no_se_res_mat'=`no_se_res_mat' \ `TC_inf' \ `TC_sup'	
				}
				else {
				
					matrix `no_se_res_mat'=`TC_inf' \ `TC_sup'
					local done1=1
				}
				
				local rownames "`rownames' TC_inf TC_sup"
			}
			else {
			
				if "`numerator'"!="" {
				
					if `done1'==0 {
						
						if (e(TC_num)<=-999999999999999 | e(TC_num)>=999999999999999) {
						
							scalar `TC_num'=.
						}
						else {
						
							scalar `TC_num'=e(TC_num)
						}						
						
						matrix `no_se_res_mat'=`TC_num'
						local rownames "`rownames' TC_num"
						local done1=1
					}
					else {
						
						if `is_special_case'==0 | `ncateg_T'>2 {
							
							if (e(TC_num)<=-999999999999999 | e(TC_num)>=999999999999999) {
							
								scalar `TC_num'=.
							}
							else {
							
								scalar `TC_num'=e(TC_num)
							}							
							
							matrix `no_se_res_mat'= `no_se_res_mat' \ `TC_num'
							local rownames "`rownames' TC_num"
						}
					}					
				}
				else {
					
					if (e(W_TC)<=-999999999999999 | e(W_TC)>=999999999999999) {
					
						scalar `W_TC'=.
					}
					else {
					
						scalar `W_TC'=e(W_TC)
					}					
		
					if `done1'==0 {
						
						matrix `no_se_res_mat'=`W_TC'
						local rownames "`rownames' W_TC"
						local done1=1
					}
					else {
						
						if `is_special_case'==0 | `ncateg_T'>2 {
						
							matrix `no_se_res_mat'= `no_se_res_mat' \ `W_TC'
							local rownames "`rownames' W_TC"
						}
					}										
				}
			}
		}
			
		if "`cic'"!="" {
								
			if "`numerator'"!="" {
				
				if (e(CIC_num)<=-999999999999999 | e(CIC_num)>=999999999999999) {
				
					scalar `CIC_num'=.
				}
				else {
				
					scalar `CIC_num'=e(CIC_num)
				}				
				
				if `done1'==1 {
					
					matrix `no_se_res_mat'= `no_se_res_mat' \ `CIC_num'
				}
				else {
				
					matrix `no_se_res_mat'=`CIC_num'
				}
			
				local rownames "`rownames' CIC_num"
			}
			else {
			
				if (e(W_CIC)<=-999999999999999 | e(W_CIC)>=999999999999999) {
				
					scalar `W_CIC'=.
				}
				else {
				
					scalar `W_CIC'=e(W_CIC)
				}			
							
				if `done1'==1 {
				
					matrix `no_se_res_mat'= `no_se_res_mat' \ `W_CIC'	
				}
				else {
				
					matrix `no_se_res_mat'=`W_CIC'
				}	
				
				local rownames "`rownames' W_CIC"
			}
		}
		
		
		ereturn clear
		
		/*some output messages*/
		
		if `is_special_case'==1 {
			
			/*if two periods and we are in special case, DID and TC mechanically equal*/
			if `ncateg_T'==2 {
			
				display _newline(1) as res ///
				"The treatment takes only one value in the control group." ///
				_newline(1)
								
				if "`did'"!="" & "`tc'"!="" {
					
					if "`numerator'"=="" {
					
						display _newline(1) as res ///
						"Because the treatment takes only one value in the control group, " /// 
						"the W_DID and W_TC estimators are mechanically equal." _newline(1)
					}
					else {
					
						display _newline(1) as res ///
						"Because the treatment takes only one value in the control group, " /// 
						"the W_DID and W_TC estimators are mechanically equal." _newline(1)	
					}
				}				
			}
			else {
			
				/*if more than two periods and special case, DID and TC 
				mechanically equal only at those periods.*/
				display _newline(1) as res ///
				"At at least one time period, the treatment takes only one value in the control group." _newline(1)
								
				if "`did'"!="" & "`tc'"!="" {
					
					if "`numerator'"=="" {
					
						display _newline(1) as res ///
						"Because the treatment takes only one value in the control group, " /// 
						"the W_DID and W_TC estimators are mechanically equal at those time periods." _newline(1)
					}
					else {
					
						display _newline(1) as res ///
						"Because the treatment takes only one value in the control group, " /// 
						"the W_DID and W_TC estimators are mechanically equal at those time periods." _newline(1)
					}
				}			
			}
		}

		/*printing the tables*/
		if "`did'"!="" | "`tc'"!="" | "`cic'"!="" {
			
			matrix colnames `no_se_res_mat'="LATE"
			matrix rownames `no_se_res_mat'=`rownames'
			
			if "`covariates'"=="" {
			
				if "`numerator'"=="" {
					
					if "`partial'"=="" {
					
						matlist `no_se_res_mat', title("Estimator(s) " ///
						"of the average treatment " ///
						"effect without standard errors. " ///
						"Number of observations: " `obs' ".")
					}
					else {
					
						matlist `no_se_res_mat', title("Estimator(s) " ///
						"of the average treatment " ///
						"effect without standard errors. " ///
						"Estimated identification bounds for TC. " ///
						"Number of observations: " `obs' ".")					
					}
				}
				else {
									
					matlist `no_se_res_mat', title("Numerator(s) of " ///
					"estimator(s) of the average treatment " ///
					"effect without standard errors. " ///
					"Number of observations: " `obs' ".")	
				}
			}
			else {
			
				if "`numerator'"=="" {
					
					if "`partial'"=="" {
					
						matlist `no_se_res_mat', title("Estimator(s) " ///
						"of the average treatment " ///
						"effect without standard errors. " ///
						"Number of observations: " `obs' "." ///
						"Controls included in the estimation: " `covariates' ".")
					}
					else {
					
						matlist `no_se_res_mat', title("Estimator(s) " ///
						"of the average treatment " ///
						"effect without standard errors. " ///
						"Estimated identification bounds for TC. " ///
						"Number of observations: " `obs' "." ///
						"Controls included in the estimation: " `covariates' ".")					
					}
				}
				else {
									
					matlist `no_se_res_mat', title("Numerator(s) of " ///
					"estimator(s) of the average treatment " ///
					"effect without standard errors. " ///
					"Number of observations: " `obs' "." ///
					"Controls included in the estimation: " `covariates' ".")	
				}			
			}
			
			/*return DID/TC/CIC results as an eclass object to user*/
			*ereturn matrix res_table=`no_se_res_mat'
			tempname b_LATE
			matrix `b_LATE'=`no_se_res_mat'[1..rowsof(`no_se_res_mat'),1]
			ereturn matrix b_LATE=`b_LATE'
		}
		
		/*Display lqte results without standard errors*/
		if "`lqte'"!="" {
			
			/*results' table displayed*/
			matrix colnames `LQTE'="LQTE"
			matlist `LQTE', ///
			title("Estimators of local quantile treatment " ///
			"effects without standard errors. " ///
			"Number of observations: " `obs' ".")
			
			/*return LQTE results as an eclass object to user*/
			ereturn matrix b_LQTE=`LQTE'
		}		
	}	
	
	
	/******************************************************************/	
	/******************************************************************/	
	/*START OF THE SECTION SPECIFIC TO ESTIMATORS WITH STANDARD ERRORS*/		
	/******************************************************************/	
	/******************************************************************/		
	
	if "`nose'"=="" {				
		
		tempfile current_data boot_se

		bootstrap, seed(1) reps(`breps') ///
		`clust' nowarn noheader notable saving(`boot_se', double): ///
		estim_wrapper `Y' `G_list' `T' `final_D_var', ///
		true_D(`D') ///
		tot_obs(`N') continuous(`continuous') ///
		qualitative(`qualitative') ///
		y_reg_method(`y_reg_met') d_reg_method(`d_reg_met') ///
		d_reg_method2(`d_reg_met2') `did' `tc' `cic' `lqte' /// 
		inf_method(`inf_method') sieve_expansion_Y(`varlist_Y') ///
		sieve_expansion_D(`varlist_D') `numerator' `partial' ///
		boot `moreoutput'
			
		local obs=`N'	
			
		/*store share of reps that failed (used to display a warning
		message later on)*/
		local share_failures=e(N_misreps)/e(N_reps)
		
		
		tempname W_DID W_TC W_CIC se_W_DID se_W_TC ///
		se_W_CIC DID_TC DID_CIC TC_CIC se_DID_TC ///
		se_DID_CIC se_TC_CIC se_tot coef_tot se_res_mat_estimand ///
		se_res_mat_eq_test DID_num TC_num CIC_num ///
		se_DID_num se_TC_num se_CIC_num TC_inf TC_sup se_TC_inf se_TC_sup ///
		p_val ic1 ic2 ic t_stat LQTE_res conf_intervals
		
		
		/*identify "degenerate" bootstrap reps, ie those taking the +/-10^15
		value and remove them from computation of bootstrapped standard errors*/
		quietly {
			
			save "`current_data'"
			
			use "`boot_se'", clear
			recode _all (-1000000000000000=.) (1000000000000000=.)
			
			des ,short
			local count_vars `r(k)'
			ds
			local a = r(varlist)
			
			forvalues i=1(1)`count_vars' {
			
				local word_`i': word `i' of `a'
				sum `word_`i''
				
				if `i'==1 {
				
					matrix `se_tot'=r(sd)
				}
				else {
				
					matrix `se_tot'=`se_tot',r(sd)
				}
			}
			
			use "`current_data'", clear
		}
		
		
		/*constructing tables */
		matrix `coef_tot'=e(b)
		*matrix `se_tot'=e(se)	
		matrix `conf_intervals'=e(ci_percentile)
		
		if "`did'"!="" & "`tc'"!="" & "`cic'"!="" {
			
			if "`numerator'"=="" {
			
				scalar `W_DID'=`coef_tot'[1,1]
				scalar `se_W_DID'=`se_tot'[1,1]
				
				if "`eqtest'"=="" {
				
					if "`partial'"=="" {
					
						scalar `W_TC'=`coef_tot'[1,2]
						scalar `W_CIC'=`coef_tot'[1,3]
						scalar `se_W_TC'=`se_tot'[1,2]						
						scalar `se_W_CIC'=`se_tot'[1,3]
						matrix `p_val'=J(1,3,0)
						matrix `t_stat'=J(1,3,0)
						local count=3
					}
					else {
					
						scalar `TC_inf'=`coef_tot'[1,2]		
						scalar `TC_sup'=`coef_tot'[1,3]	
						scalar `W_CIC'=`coef_tot'[1,4]
						scalar `se_TC_inf'=`se_tot'[1,2]					
						scalar `se_TC_sup'=`se_tot'[1,3]
						scalar `se_W_CIC'=`se_tot'[1,4]
						matrix `p_val'=J(1,4,0)
						matrix `t_stat'=J(1,4,0)
						local count=4
					}
				}
				else {
				
					if "`partial'"=="" {
					
						scalar `W_TC'=`coef_tot'[1,2]
						scalar `W_CIC'=`coef_tot'[1,3]
						scalar `DID_TC'=`coef_tot'[1,4]
						scalar `DID_CIC'=`coef_tot'[1,5]
						scalar `TC_CIC'=`coef_tot'[1,6]	
						scalar `se_W_TC'=`se_tot'[1,2]						
						scalar `se_W_CIC'=`se_tot'[1,3]
						scalar `se_DID_TC'=`se_tot'[1,4]
						scalar `se_DID_CIC'=`se_tot'[1,5]
						scalar `se_TC_CIC'=`se_tot'[1,6]							
						matrix `p_val'=J(1,6,0)
						matrix `t_stat'=J(1,6,0)
						local count=6
					}
					else {
					
						scalar `TC_inf'=`coef_tot'[1,2]		
						scalar `TC_sup'=`coef_tot'[1,3]	
						scalar `W_CIC'=`coef_tot'[1,4]
						scalar `DID_CIC'=`coef_tot'[1,5]
						scalar `se_TC_inf'=`se_tot'[1,2]					
						scalar `se_TC_sup'=`se_tot'[1,3]
						scalar `se_W_CIC'=`se_tot'[1,4]
						scalar `se_DID_CIC'=`se_tot'[1,5]
						matrix `p_val'=J(1,5,0)
						matrix `t_stat'=J(1,5,0)
						local count=5
					}					
				}
			}
			else {
			
				scalar `DID_num'=`coef_tot'[1,1]
				scalar `TC_num'=`coef_tot'[1,2]
				scalar `CIC_num'=`coef_tot'[1,3]						
				scalar `se_DID_num'=`se_tot'[1,1]
				scalar `se_TC_num'=`se_tot'[1,2]
				scalar `se_CIC_num'=`se_tot'[1,3]
				matrix `p_val'=J(1,3,0)
				matrix `t_stat'=J(1,3,0)
				local count=3				
			}

			matrix `ic1'=`conf_intervals'[1,....]
			matrix `ic2'=`conf_intervals'[2,....]
			matrix `ic'=`ic1' \ `ic2'
			
			forvalues i=1(1)`count' {
			
				matrix `p_val'[1,`i']=2*(1-normal(abs( ///
				`coef_tot'[1,`i']/`se_tot'[1,`i'])))
				matrix `t_stat'[1,`i']=`coef_tot'[1,`i'] ///
				/`se_tot'[1,`i']
			}
							
			if `is_special_case'==0 | `ncateg_T'>2 {
			
				if "`numerator'"=="" {
				
					if "`partial'"=="" {
					
						matrix `se_res_mat_estimand'=( ///
						`coef_tot'[1,1..3]',`se_tot'[1,1..3]', ///
						`t_stat'[1,1..3]',`p_val'[1,1..3]', ///
						`ic'[1,1..3]',`ic'[2,1..3]')
											
						local rownames1 "W_DID W_TC W_CIC"
						matrix rownames `se_res_mat_estimand'= ///
						`rownames1'							
					}
					else {
					
						matrix `se_res_mat_estimand'=( ///
						`coef_tot'[1,1..4]',`se_tot'[1,1..4]', ///
						`t_stat'[1,1..4]',`p_val'[1,1..4]', ///
						`ic'[1,1..4]',`ic'[2,1..4]')
											
						local rownames1 "W_DID TC_inf TC_sup W_CIC"
						matrix rownames `se_res_mat_estimand'= ///
						`rownames1'
					}					
				
					if "`eqtest'"!="" {
					
						if "`partial'"=="" {
						
							matrix `se_res_mat_eq_test'=( ///
							`coef_tot'[1,4..6]',`se_tot'[1,4..6]', ///
							`t_stat'[1,4..6]',`p_val'[1,4..6]', ///
							`ic'[1,4..6]',`ic'[2,4..6]')
	
							local rownames2 "DID_TC DID_CIC TC_CIC"
							matrix rownames `se_res_mat_eq_test'= ///
							`rownames2'							
						}
						else {
						
							matrix `se_res_mat_eq_test'=( ///
							`coef_tot'[1,5]',`se_tot'[1,5]', ///
							`t_stat'[1,5]',`p_val'[1,5]', ///
							`ic'[1,5]',`ic'[2,5]')
												
							local rownames2 "DID_CIC"
							matrix rownames `se_res_mat_eq_test'= ///
							`rownames2'
						}
					}
				}
				else {
				
					matrix `se_res_mat_estimand'=( ///
					`coef_tot'[1,1..3]',`se_tot'[1,1..3]', ///
					`t_stat'[1,1..3]',`p_val'[1,1..3]', ///
					`ic'[1,1..3]',`ic'[2,1..3]')
										
					local rownames1 "DID_num TC_num CIC_num"
					matrix rownames `se_res_mat_estimand'= ///
					`rownames1'							
				}
			}
			else {
					
				if "`numerator'"=="" {
				
					matrix `se_res_mat_estimand'=( ///
					`coef_tot'[1,2..3]',`se_tot'[1,2..3]', ///
					`t_stat'[1,2..3]',`p_val'[1,2..3]', ///
					`ic'[1,2..3]',`ic'[2,2..3]')
										
					local rownames1 "W_DID W_CIC"
					matrix rownames `se_res_mat_estimand'= ///
					`rownames1'					
				
					if "`eqtest'"!="" {
					
						matrix `se_res_mat_eq_test'=( ///
						`coef_tot'[1,5]',`se_tot'[1,5]', ///
						`t_stat'[1,5]',`p_val'[1,5]', ///
						`ic'[1,5]',`ic'[2,5]')
											
						local rownames2 "DID_CIC"
						matrix rownames `se_res_mat_eq_test'= ///
						`rownames2'
					}
				}
				else {
				
					matrix `se_res_mat_estimand'=( ///
					`coef_tot'[1,2..3]',`se_tot'[1,2..3]', ///
					`t_stat'[1,2..3]',`p_val'[1,2..3]', ///
					`ic'[1,2..3]',`ic'[2,2..3]')
										
					local rownames1 "DID_num CIC_num"
					matrix rownames `se_res_mat_estimand'= ///
					`rownames1'							
				}
			}
		}
			

			
	
	
		if "`did'"!="" & "`tc'"!="" & "`cic'"=="" {
	
			if "`numerator'"=="" {
			
				scalar `W_DID'=`coef_tot'[1,1]
				scalar `se_W_DID'=`se_tot'[1,1]
				
				if "`eqtest'"=="" {
				
					if "`partial'"=="" {
					
						scalar `W_TC'=`coef_tot'[1,2]
						scalar `se_W_TC'=`se_tot'[1,2]						
						matrix `p_val'=J(1,2,0)
						matrix `t_stat'=J(1,2,0)
						local count=2
					}
					else {
					
						scalar `TC_inf'=`coef_tot'[1,2]		
						scalar `TC_sup'=`coef_tot'[1,3]	
						scalar `se_TC_inf'=`se_tot'[1,2]					
						scalar `se_TC_sup'=`se_tot'[1,3]
						matrix `p_val'=J(1,3,0)
						matrix `t_stat'=J(1,3,0)
						local count=3
					}
				}
				else {
				
					if "`partial'"=="" {
					
						scalar `W_TC'=`coef_tot'[1,2]
						scalar `DID_TC'=`coef_tot'[1,3]
						scalar `se_W_TC'=`se_tot'[1,2]						
						scalar `se_DID_TC'=`se_tot'[1,3]							
						matrix `p_val'=J(1,3,0)
						matrix `t_stat'=J(1,3,0)
						local count=3
					}
					else {
					
						scalar `TC_inf'=`coef_tot'[1,2]		
						scalar `TC_sup'=`coef_tot'[1,3]	
						scalar `se_TC_inf'=`se_tot'[1,2]					
						scalar `se_TC_sup'=`se_tot'[1,3]
						matrix `p_val'=J(1,3,0)
						matrix `t_stat'=J(1,3,0)
						local count=3
					}					
				}
			}
			else {
			
				scalar `DID_num'=`coef_tot'[1,1]
				scalar `TC_num'=`coef_tot'[1,2]
				scalar `se_DID_num'=`se_tot'[1,1]
				scalar `se_TC_num'=`se_tot'[1,2]
				matrix `p_val'=J(1,2,0)
				matrix `t_stat'=J(1,2,0)
				local count=2				
			}

			matrix `ic1'=`conf_intervals'[1,....]
			matrix `ic2'=`conf_intervals'[2,....]
			matrix `ic'=`ic1' \ `ic2'
			
			forvalues i=1(1)`count' {
			
				matrix `p_val'[1,`i']=2*(1-normal(abs( ///
				`coef_tot'[1,`i']/`se_tot'[1,`i'])))
				matrix `t_stat'[1,`i']=`coef_tot'[1,`i'] ///
				/`se_tot'[1,`i']
			}
							
			if `is_special_case'==0 | `ncateg_T'>2 {
			
				if "`numerator'"=="" {
				
					if "`partial'"=="" {
					
						matrix `se_res_mat_estimand'=( ///
						`coef_tot'[1,1..2]',`se_tot'[1,1..2]', ///
						`t_stat'[1,1..2]',`p_val'[1,1..2]', ///
						`ic'[1,1..2]',`ic'[2,1..2]')
											
						local rownames1 "W_DID W_TC"
						matrix rownames `se_res_mat_estimand'= ///
						`rownames1'	
						
						if "`eqtest'"!="" {

							matrix `se_res_mat_eq_test'=( ///
							`coef_tot'[1,3]',`se_tot'[1,3]', ///
							`t_stat'[1,3]',`p_val'[1,3]', ///
							`ic'[1,3]',`ic'[2,3]')
	
							local rownames2 "DID_TC"
							matrix rownames `se_res_mat_eq_test'= ///
							`rownames2'							
						}							
					}
					else {
						
						*No equality test if partial!="" and only did and tc
						matrix `se_res_mat_estimand'=( ///
						`coef_tot'[1,1..3]',`se_tot'[1,1..3]', ///
						`t_stat'[1,1..3]',`p_val'[1,1..3]', ///
						`ic'[1,1..3]',`ic'[2,1..3]')
											
						local rownames1 "W_DID TC_inf TC_sup"
						matrix rownames `se_res_mat_estimand'= ///
						`rownames1'
					}					
				}
				else {
				
					*No equality test if numerator!=""
					matrix `se_res_mat_estimand'=( ///
					`coef_tot'[1,1..2]',`se_tot'[1,1..2]', ///
					`t_stat'[1,1..2]',`p_val'[1,1..2]', ///
					`ic'[1,1..2]',`ic'[2,1..2]')
										
					local rownames1 "DID_num TC_num"
					matrix rownames `se_res_mat_estimand'= ///
					`rownames1'							
				}
			}
			else {
			
				matrix `se_res_mat_estimand'=( ///
				`coef_tot'[1,1]',`se_tot'[1,1]', ///
				`t_stat'[1,1]',`p_val'[1,1]', ///
				`ic'[1,1]',`ic'[2,1]')
									
				local rownames1 "W_DID"
				matrix rownames `se_res_mat_estimand'= ///
				`rownames1'					
			}
		}
	
	

		
		
		
		if "`did'"!="" & "`tc'"=="" & "`cic'"!="" {
		
			if "`numerator'"=="" {
			
				scalar `W_DID'=`coef_tot'[1,1]
				scalar `se_W_DID'=`se_tot'[1,1]
				scalar `W_CIC'=`coef_tot'[1,2]
				scalar `se_W_CIC'=`se_tot'[1,2]

				if "`eqtest'"=="" {
				
					matrix `p_val'=J(1,2,0)
					matrix `t_stat'=J(1,2,0)
					local count=2
				}
				else {
				
					scalar `DID_CIC'=`coef_tot'[1,3]
					scalar `se_DID_CIC'=`se_tot'[1,3]							
					matrix `p_val'=J(1,3,0)
					matrix `t_stat'=J(1,3,0)
					local count=3				
				}
			}
			else {
			
				scalar `DID_num'=`coef_tot'[1,1]
				scalar `CIC_num'=`coef_tot'[1,2]
				scalar `se_DID_num'=`se_tot'[1,1]
				scalar `se_CIC_num'=`se_tot'[1,2]
				matrix `p_val'=J(1,2,0)
				matrix `t_stat'=J(1,2,0)
				local count=2				
			}

			matrix `ic1'=`conf_intervals'[1,....]
			matrix `ic2'=`conf_intervals'[2,....]
			matrix `ic'=`ic1' \ `ic2'
			
			forvalues i=1(1)`count' {
			
				matrix `p_val'[1,`i']=2*(1-normal(abs( ///
				`coef_tot'[1,`i']/`se_tot'[1,`i'])))
				matrix `t_stat'[1,`i']=`coef_tot'[1,`i'] ///
				/`se_tot'[1,`i']
			}
							

			matrix `se_res_mat_estimand'=( ///
			`coef_tot'[1,1..2]',`se_tot'[1,1..2]', ///
			`t_stat'[1,1..2]',`p_val'[1,1..2]', ///
			`ic'[1,1..2]',`ic'[2,1..2]')
					
			if "`numerator'"=="" {
			
				local rownames1 "W_DID W_CIC"
				matrix rownames `se_res_mat_estimand'= ///
				`rownames1'	
			}
			else {
			
				local rownames1 "DID_num CIC_num"
				matrix rownames `se_res_mat_estimand'= ///
				`rownames1'					
			}
				
			if "`eqtest'"!="" {

				matrix `se_res_mat_eq_test'=( ///
				`coef_tot'[1,3]',`se_tot'[1,3]', ///
				`t_stat'[1,3]',`p_val'[1,3]', ///
				`ic'[1,3]',`ic'[2,3]')

				local rownames2 "DID_CIC"
				matrix rownames `se_res_mat_eq_test'= ///
				`rownames2'							
			}												
		}				
		
		
		



	
		if "`did'"=="" & "`tc'"!="" & "`cic'"!="" {
	
			if "`numerator'"=="" {
				
				if "`eqtest'"=="" {
				
					if "`partial'"=="" {
					
						scalar `W_TC'=`coef_tot'[1,1]
						scalar `W_CIC'=`coef_tot'[1,2]
						scalar `se_W_TC'=`se_tot'[1,1]	
						scalar `se_W_CIC'=`se_tot'[1,2]
						matrix `p_val'=J(1,2,0)
						matrix `t_stat'=J(1,2,0)
						local count=2
					}
					else {
					
						scalar `TC_inf'=`coef_tot'[1,1]		
						scalar `TC_sup'=`coef_tot'[1,2]
						scalar `W_CIC'=`coef_tot'[1,3]
						scalar `se_TC_inf'=`se_tot'[1,1]					
						scalar `se_TC_sup'=`se_tot'[1,2]
						scalar `se_W_CIC'=`se_tot'[1,3]
						matrix `p_val'=J(1,3,0)
						matrix `t_stat'=J(1,3,0)
						local count=3
					}
				}
				else {
				
					if "`partial'"=="" {
					
						scalar `W_TC'=`coef_tot'[1,1]
						scalar `W_CIC'=`coef_tot'[1,2]
						scalar `TC_CIC'=`coef_tot'[1,3]
						scalar `se_W_TC'=`se_tot'[1,1]	
						scalar `se_W_CIC'=`se_tot'[1,2]
						scalar `se_TC_CIC'=`se_tot'[1,3]							
						matrix `p_val'=J(1,3,0)
						matrix `t_stat'=J(1,3,0)
						local count=3
					}
					else {
					
						scalar `TC_inf'=`coef_tot'[1,1]		
						scalar `TC_sup'=`coef_tot'[1,2]
						scalar `W_CIC'=`coef_tot'[1,3]
						scalar `se_TC_inf'=`se_tot'[1,1]					
						scalar `se_TC_sup'=`se_tot'[1,2]
						scalar `se_W_CIC'=`se_tot'[1,3]
						matrix `p_val'=J(1,3,0)
						matrix `t_stat'=J(1,3,0)
						local count=3
					}					
				}
			}
			else {
			
				scalar `TC_num'=`coef_tot'[1,1]
				scalar `CIC_num'=`coef_tot'[1,2]
				scalar `se_TC_num'=`se_tot'[1,1]
				scalar `se_CIC_num'=`se_tot'[1,2]
				matrix `p_val'=J(1,2,0)
				matrix `t_stat'=J(1,2,0)
				local count=2				
			}

			matrix `ic1'=`conf_intervals'[1,....]
			matrix `ic2'=`conf_intervals'[2,....]
			matrix `ic'=`ic1' \ `ic2'
			
			forvalues i=1(1)`count' {
			
				matrix `p_val'[1,`i']=2*(1-normal(abs( ///
				`coef_tot'[1,`i']/`se_tot'[1,`i'])))
				matrix `t_stat'[1,`i']=`coef_tot'[1,`i'] ///
				/`se_tot'[1,`i']
			}
							

			if "`numerator'"=="" {
			
				if "`partial'"=="" {
				
					matrix `se_res_mat_estimand'=( ///
					`coef_tot'[1,1..2]',`se_tot'[1,1..2]', ///
					`t_stat'[1,1..2]',`p_val'[1,1..2]', ///
					`ic'[1,1..2]',`ic'[2,1..2]')
										
					local rownames1 "W_TC W_CIC"
					matrix rownames `se_res_mat_estimand'= ///
					`rownames1'	
					
					if "`eqtest'"!="" {

						matrix `se_res_mat_eq_test'=( ///
						`coef_tot'[1,3]',`se_tot'[1,3]', ///
						`t_stat'[1,3]',`p_val'[1,3]', ///
						`ic'[1,3]',`ic'[2,3]')

						local rownames2 "TC_CIC"
						matrix rownames `se_res_mat_eq_test'= ///
						`rownames2'							
					}							
				}
				else {
					
					*No equality test if partial!="" and only tc and cic
					matrix `se_res_mat_estimand'=( ///
					`coef_tot'[1,1..3]',`se_tot'[1,1..3]', ///
					`t_stat'[1,1..3]',`p_val'[1,1..3]', ///
					`ic'[1,1..3]',`ic'[2,1..3]')
										
					local rownames1 "TC_inf TC_sup W_CIC"
					matrix rownames `se_res_mat_estimand'= ///
					`rownames1'
				}					
			}
			else {
			
				*No equality test if numerator!=""
				matrix `se_res_mat_estimand'=( ///
				`coef_tot'[1,1..2]',`se_tot'[1,1..2]', ///
				`t_stat'[1,1..2]',`p_val'[1,1..2]', ///
				`ic'[1,1..2]',`ic'[2,1..2]')
									
				local rownames1 "TC_num CIC_num"
				matrix rownames `se_res_mat_estimand'= ///
				`rownames1'							
			}
		}	
	

	
	
		if "`did'"!="" & "`tc'"=="" & "`cic'"=="" {
							
			if "`numerator'"=="" {
			
				scalar `W_DID'=`coef_tot'[1,1]
				scalar `se_W_DID'=`se_tot'[1,1]				
				matrix `p_val'=J(1,1,0)
				matrix `t_stat'=J(1,1,0)					
				local count=1
			}
			else {
			
				scalar `DID_num'=`coef_tot'[1,1]
				scalar `se_DID_num'=`se_tot'[1,1]
				matrix `p_val'=J(1,1,0)
				matrix `t_stat'=J(1,1,0)
				local count=1
			}
			
			matrix `ic1'=`conf_intervals'[1,....]
			matrix `ic2'=`conf_intervals'[2,....]
			matrix `ic'=`ic1' \ `ic2'
			
			forvalues i=1(1)`count' {
			
				matrix `p_val'[1,`i']=2*(1-normal(abs( ///
				`coef_tot'[1,`i']/`se_tot'[1,`i'])))
				
				matrix `t_stat'[1,`i']=`coef_tot'[1,`i'] ///
				/`se_tot'[1,`i']					
			}
			
			matrix `se_res_mat_estimand'=( ///
			`coef_tot'[1,1]',`se_tot'[1,1]', ///
			`t_stat'[1,1]',`p_val'[1,1]', ///
			`ic'[1,1]',`ic'[2,1]')			
			
			if "`numerator'"=="" {

				local rownames1 "W_DID"
			}
			else {

				local rownames1 "DID_num"				
			}
			
			matrix rownames `se_res_mat_estimand'= ///
			`rownames1'			
		}			
		
		
		
		
		
		
		
		if "`did'"=="" & "`tc'"!="" & "`cic'"=="" {
						
			if "`numerator'"=="" {
				
				if "`partial'"=="" {
				
					scalar `W_TC'=`coef_tot'[1,1]
					scalar `se_W_TC'=`se_tot'[1,1]				
					matrix `p_val'=J(1,1,0)
					matrix `t_stat'=J(1,1,0)					
					local count=1
				}
				else {
				
					scalar `TC_inf'=`coef_tot'[1,1]
					scalar `TC_sup'=`coef_tot'[1,2]
					scalar `se_TC_inf'=`se_tot'[1,1]
					scalar `se_TC_sup'=`se_tot'[1,2]					
					matrix `p_val'=J(1,2,0)
					matrix `t_stat'=J(1,2,0)					
					local count=2				
				}
			}
			else {
			
				scalar `TC_num'=`coef_tot'[1,1]
				scalar `se_TC_num'=`se_tot'[1,1]
				matrix `p_val'=J(1,1,0)
				matrix `t_stat'=J(1,1,0)
				local count=1
			}
			
			matrix `ic1'=`conf_intervals'[1,....]
			matrix `ic2'=`conf_intervals'[2,....]
			matrix `ic'=`ic1' \ `ic2'
			
			forvalues i=1(1)`count' {
			
				matrix `p_val'[1,`i']=2*(1-normal(abs( ///
				`coef_tot'[1,`i']/`se_tot'[1,`i'])))
				
				matrix `t_stat'[1,`i']=`coef_tot'[1,`i'] ///
				/`se_tot'[1,`i']					
			}
			
			if "`numerator'"=="" {
				
				if "`partial'"=="" {
				
					matrix `se_res_mat_estimand'=( ///
					`coef_tot'[1,1]',`se_tot'[1,1]', ///
					`t_stat'[1,1]',`p_val'[1,1]', ///
					`ic'[1,1]',`ic'[2,1]')
					local rownames1 "W_TC"
					matrix rownames `se_res_mat_estimand'= ///
					`rownames1'
				}
				else {
				
					matrix `se_res_mat_estimand'=( ///
					`coef_tot'[1,1..2]',`se_tot'[1,1..2]', ///
					`t_stat'[1,1..2]',`p_val'[1,1..2]', ///
					`ic'[1,1..2]',`ic'[2,1..2]')
					local rownames1 "TC_inf TC_sup"
					matrix rownames `se_res_mat_estimand'= ///
					`rownames1'				
				}
			}
			else {

				matrix `se_res_mat_estimand'=( ///
				`coef_tot'[1,1]',`se_tot'[1,1]', ///
				`t_stat'[1,1]',`p_val'[1,1]', ///
				`ic'[1,1]',`ic'[2,1]')
				local rownames1 "TC_num"
				matrix rownames `se_res_mat_estimand'= ///
				`rownames1'					
			}
		}
	
	
	
	
	
		if "`did'"=="" & "`tc'"=="" & "`cic'"!="" {
							
			if "`numerator'"=="" {
			
				scalar `W_CIC'=`coef_tot'[1,1]
				scalar `se_W_CIC'=`se_tot'[1,1]				
				matrix `p_val'=J(1,1,0)
				matrix `t_stat'=J(1,1,0)					
				local count=1
			}
			else {
			
				scalar `CIC_num'=`coef_tot'[1,1]
				scalar `se_CIC_num'=`se_tot'[1,1]
				matrix `p_val'=J(1,1,0)
				matrix `t_stat'=J(1,1,0)
				local count=1
			}
			
			matrix `ic1'=`conf_intervals'[1,....]
			matrix `ic2'=`conf_intervals'[2,....]
			matrix `ic'=`ic1' \ `ic2'
			
			forvalues i=1(1)`count' {
			
				matrix `p_val'[1,`i']=2*(1-normal(abs( ///
				`coef_tot'[1,`i']/`se_tot'[1,`i'])))
				
				matrix `t_stat'[1,`i']=`coef_tot'[1,`i'] ///
				/`se_tot'[1,`i']					
			}
	
			matrix `se_res_mat_estimand'=( ///
			`coef_tot'[1,1]',`se_tot'[1,1]', ///
			`t_stat'[1,1]',`p_val'[1,1]', ///
			`ic'[1,1]',`ic'[2,1]')	
	
			if "`numerator'"=="" {
			
				local rownames1 "W_CIC"
			}
			else {

				local rownames1 "CIC_num"			
			}
			
			matrix rownames `se_res_mat_estimand'= ///
			`rownames1'			
		}
		
		if ("`did'"!="" | "`tc'"!="" | "`cic'"!="") {
		
			local rows=rowsof(`se_res_mat_estimand')
			
			forvalues i=1(1)`rows' {
				
				if (`se_res_mat_estimand'[`i',1]<=-999999999999999 | ///
				`se_res_mat_estimand'[`i',1]>=999999999999999) {
				
					forvalues j=1(1)6 {
					
						matrix `se_res_mat_estimand'[`i',`j']=.
					}
				}		
			}	
		}
		
		if "`lqte'"!="" {
						
			matrix `LQTE_res'=J(19,6,0)
			
			local q_list ""

			forvalues i=1(1)19 {
				
				local iter=`count'+`i'
				
				if (`coef_tot'[1,`iter']<=-999999999999999 | `coef_tot'[1,`iter']>=999999999999999) {
				
					forvalues j=1(1)6 {
					
						matrix `LQTE_res'[`i',`j']=.
					}
				}
				else {
				
					matrix `LQTE_res'[`i',1]=`coef_tot'[1,`iter']
					matrix `LQTE_res'[`i',2]=`se_tot'[1,`iter']
					matrix `LQTE_res'[`i',3]=`LQTE_res'[`i',1]/`LQTE_res'[`i',2]
					matrix `LQTE_res'[`i',4]=2*(1-normal(abs(`LQTE_res'[`i',3])))
					matrix `LQTE_res'[`i',5]=`conf_intervals'[1,`iter']
					matrix `LQTE_res'[`i',6]=`conf_intervals'[2,`iter']
				}
				
				local q=`i'*5
				local q_list "`q_list' q_`q'"
			}
			
			matrix rownames `LQTE_res'=`q_list'
		}
		

		ereturn clear


		/*some output messages*/
		if "`inf_method'"=="sieve" & "`message_CV1'"!="" {	
			
			display as res _newline(1) "`message_CV1'" _newline(1)										
		}
		
		if "`covariates_message'"!="" {
		
			display as res _newline(1) "`covariates_message'" _newline(1)	
		}
		
		
		if `share_failures'>=0.05 {
		
			display as err _newline(1) "At least 5 percent of bootstrap " ///
			"replications failed. This is likely to happen when the " ///
			"treatment variable takes too many values." _newline(1)
		}
		
		
		if `is_special_case'==1 {
			
			if `ncateg_T'==2 {
			
				display _newline(1) as res ///
				"The treatment variable takes only one value in the control group." _newline(1)
								
				if "`did'"!="" & "`tc'"!="" {
					
					if "`numerator'"=="" {
					
						display _newline(1) as res ///
						"Because the treatment variable takes only one value in the control group, " ///
						"the W_DID and W_TC estimators are mechanically equal." _newline(1)
					}
					else {
					
						display _newline(1) as res ///
						"Because the treatment variable takes only one value in the control group, " ///
						"the W_DID and W_TC estimators are mechanically equal." _newline(1)		
					}
				}	
			}
			else {
			
				display _newline(1) as res ///
				"There is at least one time period when the treatment variable takes only one value in the control group." _newline(1)
								
				if "`did'"!="" & "`tc'"!="" {
					
					if "`numerator'"=="" {
					
						display _newline(1) as res ///
						"Because the treatment variable takes only one value in the control group, " ///
						"the W_DID and W_TC estimators are mechanically equal at those time periods." _newline(1)	
					}
					else {
					
						display _newline(1) as res ///
						"Because the treatment variable takes only one value in the control group, " ///
						"the W_DID and W_TC estimators are mechanically equal at those time periods." _newline(1)		
					}
				}			
			}
		}
		
		/*display results*/
		if "`did'"!="" | "`tc'"!="" | "`cic'"!="" {
			
			local obs=`N'
			
			matrix colnames `se_res_mat_estimand'= ///
			"LATE" "Std_Err" "t" "p_value" "lower_ic" "upper_ic"			
			
			if "`covariates'"!="" {
			
				if "`cluster'"=="" {
					
					if "`numerator'"=="" {
						
						matlist `se_res_mat_estimand', title("Estimator(s) of the " ///
						"local average treatment effect with bootstrapped " ///
						"standard errors. Number of observations: " `obs' ". " ///
						"Controls included in the estimation: " `covariates' ".")		
					}
					else {
	
						matlist `se_res_mat_estimand', title("Numerator(s) of estimator(s) of the " ///
						"local average treatment effect with bootstrapped " ///
						"standard errors. " /// 
						"Number of observations: " `obs' ". " ///
						"Controls included in the estimation: " `covariates' ".")						
					}
				}
				else {
					
					if "`numerator'"=="" {
						
						matlist `se_res_mat_estimand', title("Estimator(s) of the" ///
						"local average treatment effect with bootstrapped " ///
						"standard errors. " ///
						"Cluster variable: `cluster'. " ///
						"Number of observations: " `obs' "." ///
						" Controls included in the estimation: " `covariates' ".")						
					}
					else {
	
						matlist `se_res_mat_estimand', title("Numerator(s) of estimator(s) of the " ///
						"local average treatment effect with bootstrapped " ///
						"standard errors. " ///
						"Cluster variable: `cluster'. " ///
						"Number of observations: " `obs' ". " ///
						"Controls included in the estimation: " `covariates' ".")							
					}
				}	
			}
			else {
			
				if "`cluster'"=="" {
					
					if "`numerator'"=="" {
						
						if "`partial'"=="" {
						
							matlist `se_res_mat_estimand', title("Estimator(s) of the" ///
							"local average treatment effect with bootstrapped " ///
							"standard errors. Number of observations: " `obs' ".")	
						}
						else {
						
							matlist `se_res_mat_estimand', title("Estimator(s) of the" ///
							"local average treatment effect with bootstrapped " ///
							"standard errors. " ///
							"Estimated identification bounds for TC. " ///
							"Number of observations: " `obs' ".")							
						}
					}
					else {
	
						matlist `se_res_mat_estimand', title("Numerator(s) of estimator(s) of the" ///
						"local average treatment effect with bootstrapped " ///
						"standard errors. " /// 
						"Number of observations: " `obs' ".")						
					}
				}
				else {
					
					if "`numerator'"=="" {
						
						if "`partial'"=="" {
						
							matlist `se_res_mat_estimand', title("Estimator(s) of the" ///
							"local average treatment effect with bootstrapped " ///
							"standard errors. " ///
							"Cluster variable: `cluster'. " ///
							"Number of observations: " `obs' ".")		
						}
						else {
						
							matlist `se_res_mat_estimand', title("Estimator(s) of the" ///
							"local average treatment effect with bootstrapped " ///
							"standard errors. " ///
							"Estimated identification bounds for TC. " ///
							"Cluster variable: `cluster'. " ///
							"Number of observations: " `obs' ".")						
						}
					}
					else {
	
						matlist `se_res_mat_estimand', title("Numerator(s) of estimator(s) of the" ///
						"local average treatment effect with bootstrapped " ///
						"standard errors. " ///
						"Cluster variable: `cluster'. " ///
						"Number of observations: " `obs' ".")							
					}
				}			
			}
			
			/*return DID/TC/CIC table as an eclass object to user*/
			*ereturn matrix res_table=`se_res_mat_estimand'
			tempname b_LATE se_LATE ci_LATE
			matrix `b_LATE'=`se_res_mat_estimand'[1..rowsof(`se_res_mat_estimand'),1]
			matrix `se_LATE'=`se_res_mat_estimand'[1..rowsof(`se_res_mat_estimand'),2]
			matrix `ci_LATE'=`se_res_mat_estimand'[1..rowsof(`se_res_mat_estimand'),5..6]
			ereturn matrix b_LATE=`b_LATE'
			ereturn matrix se_LATE=`se_LATE'
			ereturn matrix ci_LATE=`ci_LATE'
			
			if "`eqtest'"!="" {
				
				if `is_special_case'==0 & (("`did'"!="" & "`tc'"!="") | ///
				("`did'"!="" & "`cic'"!="") | ("`tc'"!="" & "`cic'"!="")) {
				
					matrix colnames `se_res_mat_eq_test'= ///
					"Delta" "Std_Err" "t" "p_value" "lower_ic" "upper_ic"			
					matlist `se_res_mat_eq_test', title( ///
					"Estimators equality test")
					
					/*return DID/TC/CIC equality test results as several eclass 
					objects to user*/
					*ereturn matrix eq_test_table=`se_res_mat_eq_test'
					tempname b_LATE_eqtest se_LATE_eqtest ci_LATE_eqtest
					matrix `b_LATE_eqtest'=`se_res_mat_eq_test'[1..rowsof(`se_res_mat_eq_test'),1]
					matrix `se_LATE_eqtest'=`se_res_mat_eq_test'[1..rowsof(`se_res_mat_eq_test'),2]
					matrix `ci_LATE_eqtest'=`se_res_mat_eq_test'[1..rowsof(`se_res_mat_eq_test'),5..6]
					ereturn matrix b_LATE_eqtest=`b_LATE_eqtest'
					ereturn matrix se_LATE_eqtest=`se_LATE_eqtest'
					ereturn matrix ci_LATE_eqtest=`ci_LATE_eqtest'
				}
				
				if `is_special_case'==1 & ( ///
				("`did'"!="" & "`cic'"!="") | ("`tc'"!="" & "`cic'"!="")) {
				
					matrix colnames `se_res_mat_eq_test'= ///
					"Delta" "Std_Err" "t" "p_value" "lower_ic" "upper_ic"			
					matlist `se_res_mat_eq_test', title( ///
					"Estimators equality test")
					
					/*return DID/TC/CIC equality test results as several eclass 
					objects to user*/
					*ereturn matrix eq_test_table=`se_res_mat_eq_test'
					tempname b_LATE_eqtest se_LATE_eqtest ci_LATE_eqtest
					matrix `b_LATE_eqtest'=`se_res_mat_eq_test'[1..rowsof(`se_res_mat_eq_test'),1]
					matrix `se_LATE_eqtest'=`se_res_mat_eq_test'[1..rowsof(`se_res_mat_eq_test'),2]
					matrix `ci_LATE_eqtest'=`se_res_mat_eq_test'[1..rowsof(`se_res_mat_eq_test'),5..6]
					ereturn matrix b_LATE_eqtest=`b_LATE_eqtest'
					ereturn matrix se_LATE_eqtest=`se_LATE_eqtest'
					ereturn matrix ci_LATE_eqtest=`ci_LATE_eqtest'	
				}	
			}
		}	
		
		
		/*Display lqte results with standard errors*/
		if "`lqte'"!="" {
			
			matrix colnames `LQTE_res'= ///
			"LQTE" "Std_Err" "t" "p_value" "lower_ic" "upper_ic"
			
			if "`cluster'"=="" {
			
				matlist `LQTE_res', ///
				title("Estimators of local quantile treatment " ///
				"effects with bootstrapped standard errors. " ///
				"Number of observations: " `obs' ".")
			}
			else {
			
				matlist `LQTE_res', ///
				title("Estimators of local quantile treatment " ///
				"effects with bootstrapped standard errors. " ///
				"Cluster variable: `cluster'. " ///
				"Number of observations: " `obs' ".")			
			}
			
			/*return lqte results as several eclass objects to user*/
			tempname b_LQTE se_LQTE ci_LQTE
			matrix `b_LQTE'=`LQTE_res'[1..rowsof(`LQTE_res'),1]
			matrix `se_LQTE'=`LQTE_res'[1..rowsof(`LQTE_res'),2]
			matrix `ci_LQTE'=`LQTE_res'[1..rowsof(`LQTE_res'),5..6]
			ereturn matrix b_LQTE=`b_LQTE'
			ereturn matrix se_LQTE=`se_LQTE'
			ereturn matrix ci_LQTE=`ci_LQTE'		
		}		
	}
	
	restore
	
	/*identify observations used in the original dataset*/
	quietly {
		
		if "`tagobs'"!="" {
		
			tempvar merge
			
			merge 1:1 `indiv_id' using "`used_data'", gen (`merge')
			count if `merge'==3
			gen tagobs=(`merge'==3)	
		}
	}
	
	ereturn scalar N=`N'
	*ereturn post, esample(`touse')	
end

/////////////////////////////////////////////////////////// End of main program

/*Subprogram called by main: creates the new D variable corresponding to newcateg option */
		
quietly capture program drop create_new_D
quietly program create_new_D


	version 12

	syntax varlist(max=1 numeric) ///
	[, touse(name) new_categ(numlist) ///
	new_categ_varname(name) max_D(name)]
		
	tokenize `varlist', parse(" ,")	
		
	args D
		
	local o=wordcount("`new_categ'")
	tempname new_categ_mat 
		
	matrix `new_categ_mat'=J(`o',1,0)
	
	/*store new treatment group bounds in a matrix*/
	forvalues i=1(1)`o' {
		
		local a`i': word `i' of `new_categ'
		matrix `new_categ_mat'[`i',1]=`a`i''
			
	}	
					
	gen `new_categ_varname'=`D' if `touse'
	
	/*if original D takes its value within the lower and upper bounds
	of the new i-th group, then new categ is equal to i*/
	forvalues i=1(1)`o' {
	
		if `i'==1 {
								
			quietly replace `new_categ_varname'=`i' ///
			if `D'<=`new_categ_mat'[`i',1] & `touse'
			
		}
				
		
		else {
				
			quietly replace `new_categ_varname'=`i' ///
			if `D'<=`new_categ_mat'[`i',1] & `D'>`new_categ_mat'[`i'-1,1] ///
			& `touse'
			
		}
		
	}	
end
