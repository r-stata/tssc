*! splitit, v2.0.1, Klaudia Erhardt & Ralf Kuenster, last updated: 2018-05-09
*! update v2.0.1 bug: misvals instead of values in splitvars of one-spell-cases (files with more than 200,000 obs) is now corrrected
*! update v2.0.0 adapted to Stata14

capture program drop splitit
program splitit
	version 11.2
	syntax varlist (min=5 max=5) [,SRT(varlist) PORtions(integer 0) CVars]
	display "   "
	display "{col 3}splitit v2.0.0, written by Klaudia Erhardt & Ralf Kuenster, last updated:  2017-01-09"
	display "   "
	
/*##################################################################################################################
############################                                           #############################################
############################  A) DEFINITION OF PARAMETERS              #############################################
############################                                           ###########################################*/

	tempfile spfile cid temp_usp datum_1 datum_2 datum_wide
	tempvar temp tempn nid h1 nsc datum x y z first first2 spell2 spid n_epidat
	tempname recn time hrs min sec cmax port port_add resid span b a max_t 	  		/* naming scalars with tempnames */
	scalar `time' = 0	/* initialising the scalars */
	scalar `hrs' = 0
	scalar `min' = 0
	scalar `sec' = 0
	scalar `cmax' = 0 
	scalar `port' = 0
	scalar `port_add' = 0
	scalar `resid' = 0
	scalar `span' =  0
	scalar `b' = 0
	scalar `a' = 0
	scalar `max_t' = 0
	scalar `recn' = 0

	tokenize `varlist'
	local id `1'			
	local start `2'			
	local end `3'
	local sptype `4'
	local spellid `5'
	
	local fivevars `varlist'	

	local fmt : format `start'		/* determine the format of the start date variable in the source file */
	
	local u ""
	if c(stata_version)>=14 {
		local u "u"		/* prefix for unicode commands */
	}

	/* #####################    capture the state of the file and the settings and set timer on ################# */

	local varabr = c(varabbrev)
	set varabbrev off 
	set more off
	
	timer clear
	timer on 1		/* Measuring the runtime of the program */		
	
	/* #####################      definition of the names of program generated variables        ################# */
	
	local v1 "`start'_split"					/* start date of the split spells */
	local v2 "`end'_split"						/* end date of the split spells */
	local v3 "sid_split"						/* spell ID of the split spells */
	local v4 "nspell"							/* number of spells within a case after splitting */
	local v5 "levela"							/* running number of the isochronic spells per case and spelltype */
	local v6 "levelb"							/* running number of the isochronic spells per case */
	local v7 "nlevela"							/* number of the isochronic spells per case and spelltype */
	local v8 "nlevelb"							/* number of the isochronic spells per case */

	
	/* finding new names if one ore more of the above named variables already exist */
	
		capture confirm new variable `v1' `v2' `v3' `v4' `v5' `v6' `v7' `v8', exact
		local x = ""
		while _rc != 0 {
			local x = `x' + 1
			capture confirm new variable `v1'`x' `v2'`x' `v3'`x' `v4'`x' `v5'`x' `v6'`x' `v7'`x' `v8'`x', exact
		}
	
	local bege "`v1'`x'"						/* start date of the split spells */
	local ende "`v2'`x'"						/* end date of the split spells */
	local spneu "`v3'`x'"						/* spell ID of the split spells */
	local nsp "`v4'`x'"							/* number of spells within a case after splitting */
	if `u'strlen("`cvars'") > 0 {
		local lev1 "`v5'`x'"					/* count of isochronic spells per case and spelltype */
		local lev2 "`v6'`x'"					/* count of isochronic spells per case */
		local nlev1 "`v7'`x'"					/* sum of isochronic spells per case and spelltype */
		local nlev2 "`v8'`x'"					/* sum of isochronic spells per case */
	}

/*##################################################################################################################
############################                                           #############################################
############################  B) CHECK INPUT AND SET DEFAULTS          #############################################
############################                                           ###########################################*/

	/*	##############   assert that the variables id, start, end, sptype, spellid  have no missing values  ##### */	

	local i ""
    foreach x of varlist `fivevars' {
		local vt : type `x'
		if `u'strpos("`vt'", "str") == 0  { /* if variable is not type string */
			capture assert `x' < . 
		}
		if `u'strpos("`vt'", "str") > 0  { /* if variable is type string */
			capture assert trim(`x') != "" 
		}
		if _rc != 0 {
			local i = "`i'" + "`x'" + " "
		}
	}
	
	/*	##############   assert that the variables start, end are integers      ################################# */		
	local j ""
    foreach x of varlist `start' `end' {
		capture assert `x' == int(`x') 
		if _rc != 0 {
			local j = "`j'" + "`x'" + " "
		}
	}
	
	if `u'strlen("`i'") > 0 | `u'strlen("`j'") > 0 {
		if `u'strlen("`i'") > 0 {
			local message "There are missings or empty strings in variable(s) `i' - please correct this problem."
			display as err " `message' "
			display "   "
		}
		if `u'strlen("`j'") > 0 {
			local message "Some values of variable(s) `j' are no integers -  please correct this problem."
			display as err " `message' "
			display "   "
		}
		exit
	}

	/*	##############   assert that always end > = start (spell duration is not negative)  ##################### */

	capture assert `end'-`start' >= 0
	if _rc != 0 {
		local message "The duration of some spells (`end' minus `start') is negative." _n ///
		"Please correct this problem. "
		display as err " `message' "
		display "   "
		exit		
	}

	/*	#############   assert if the arguments form unique spell identifier within a case  ##################### */
	
		
	bysort `fivevars' `srt': gen byte `temp' = _N
	capture assert `temp' == 1
	if _rc != 0 {
		if `u'strlen("`srt'") > 0	{
			local message "{col 3}Note: The variables `fivevars' and the sort variable(s) `srt'" _n ///
			"{col 3}don't identify the spells uniquely. Spells with duplicate combinations of  " _n ///
			"{col 3}the variables `fivevars' `srt' will be sorted at random."
		}
		else {
			local message "{col 3}Note: The variables `fivevars' " _n ///
			"{col 3}don't identify the spells uniquely. Spells with duplicate combinations of  " _n ///
			"{col 3}the variables `fivevars' will be sorted at random."		
		}
		display "   "
		display " `message' "
		display "  "
	}
	drop `temp'


		
	/* ##################### Log of the arguments the program uses ############################################## */

	if `u'strlen("`cvars'") > 0 {
		display "{col 3}Note: optional count variables will be generated " _n ///
		"{col 3}-------------------------------------- " 
		display "    "
	}


/*##################################################################################################################
############################                                           #############################################
############################      BEGIN OF THE CORE PROGRAM            #############################################
############################                                           ###########################################*/

	/* #####################    prepare the working file: only variables that are necessary for splitting  #######*/
	
	local message "{col 3}Start of the core programm at $S_TIME on $S_DATE " _n ///
				"    " _n ///
				"{col 3}Processing.... Please wait while sorting and generating temporary variables... " _n ///
				"    "
	display "`message'  "

	/* 	####### drop one-spell cases --> runtime reduction in large files, runtime penalty in small files ####### */
	
	scalar `recn' = _N 				/* determine N of obs. */
	if `recn' > 200000	{	
		preserve
		keep `fivevars' `srt' 
		by `id': gen `nsc' = _N		/* n of spells per case, used for sorting the file later on */		
		quietly keep if `nsc' > 1	/* drop one-spell cases */
	}
	else	{
		preserve
		keep `fivevars' `srt' 
		by `id': gen `nsc' = _N		/* n of spells per case, used for sorting the file later on */
	}
	by `fivevars' `srt': gen long `tempn' = _n  /* generate a key for merging later on */
	
	/* 	#############   determine the number of portions if not specified / if input for option was not valid ## */ 
	
	scalar `recn' = _N 				/* determine N of obs. */
	
	quietly {
		by `id': gen byte `temp' = 1 if _n==1
		count if `temp' == 1
		scalar `cmax' = r(N)		/* determine no of cases */
		drop `temp'
	}
	if `portions' <= 0 | `portions' > `cmax' {   /* set default if no portions-option or portions-option invalid */
		if `recn' <= 25000 {
			scalar `port' = 1
		}
		else   {
			scalar `port' = int(`recn' / 25000)
		}
		/* --> 1 portion up to 49.999 obs.  */
	}
	else {  /* if portions option is valid, user specified number of portions will be processed */
		scalar `port' = `portions'
	}
	
	local message "{col 3}Start dividing the working file into portions at $S_TIME on $S_DATE " _n ///
	"   "  _n ///
	"{col 3}Processing.... Please wait while determining the number of cases per portion... "

	if `port' > 1 {
		display " `message' "
		display "   "
	}
	
	/* #### generate new consecutive case ID  and determine the number of cases per portion  #### */

	sort `nsc' `id'
	gen byte `h1' = cond(`id' != `id'[_n-1], 1, 0)	/* instead of egen group(), performs quicker ?*/
	gen `nid' = sum(`h1')
	drop `h1'
	quietly save `cid', replace
	scalar `cmax' = `nid'[_N]
	scalar `span' =  int(`cmax'/`port') /* determine the number of cases per portion */
	scalar `resid' = `cmax' - (`span' * `port') 
	if `resid' > `span' {	/* if resid < span the remaining cases will be added to last portion  */
		scalar `port_add' = int(`resid'/`span')
		scalar `port' = `port' + `port_add'
	}
	
	local message "{col 3}Portions no. 1 - " `port'-1  " contain " `span' " cases each, " _n ///
	"{col 3}Portion no. " `port' " contains " (`cmax') - ((`port'-1) * `span') " cases." _n ///
	"    " _n ///
	"{col 3}Processing.... Please wait .... " _n ///
	"    "
	if `port' > 1 {
		display " `message' "
		display "   "
	}
	
	/*##################################################################################################################
	###################   Spell splitting in a loop over the portions which are extracted one after   ##################
	###################    the other from the working file                                            ##################
	################################################################################################################# */
	
	local portions = `port'		/* scalar `port' cannot be used for counting the loop */

	forvalues k = 1(1)`portions' {
		scalar `b' = `cmax' - `span' * (`k'-1)	/* b is set to the highest case number belonging to the portion */
		scalar `a' = `b' - `span' + 1			/* a is set to the smallest case number belonging to the portion */
		if `k' < `portions' {
			quietly use "`cid'" if `nid' >= `a' & `nid' <= `b', clear
		}
		else if `k' == `portions' {		
			quietly use "`cid'" if `nid' >= 1 & `nid' <= `b', clear  
			/* --> the last portion contains the rest of the cases up to the highest case number */
		}	
		drop `nid'							/* the new case number is of no further use and can be dropped */

			
		/* An additional spell-ID is generated, which counts the spells per case from 1 to highest. */
		sort `fivevars' `srt'
		quietly {
			by `id': gen int `spell2' = _n 
			save "`temp_usp'", replace  /* The temporary file temp_usp stands for the portioned data file just being 
										   processed */
		}   
		/* Storing start date, case-ID and the newly generated spell-ID in a separate file */
		keep `id' `start'
		quietly {
			rename `start' `datum'
			save "`datum_1'", replace
		}

		/* The end date is increased by 1 time unit (because potential splits of a spell are adjacent, i.e. beginning 
		   one time unit later than the end of the preceding split) and also stored into a separate file . */
		quietly use "`temp_usp'", clear
		keep `id' `end'
		quietly {
			rename `end' `datum'
			replace `datum' = `datum' + 1
			save "`datum_2'", replace
		}
	
		/* The two temporary "datum"-files get united and sorted  */
		quietly use "`datum_2'", clear
		append using "`datum_1'"
		sort `id' `datum'

		/* Duplicate dates within a case are deleted */
		by `id' `datum': gen `y' = _n 
		quietly drop if `y' > 1
		drop `y'
			
		/* Assessing the maximum number of date specifications that ever occur in a case. This number is stored to 
			max_t and determines the number of date variables being generated in the next step. Also this number 
			serves as a loop enumerator. */
		by `id': gen int `z' = _N
		quietly sum `z', meanonly
		scalar `max_t' = r(max) 
		drop `z'

		/* The "datum" temporary file is reshaped from long to wide and saved as such. In the process 
			an index number running from 1 to max_t is appended automatically to the variable name "datum". */
		by `id': gen int `y' = _n
		quietly {
			reshape wide `datum', i(`id') j(`y')
			save "`datum_wide'", replace
		}
				
		/* The "datum" variables are merged casewise to the portioned data file */
		quietly {
			use "`temp_usp'", clear
			merge m:1 `id' using "`datum_wide'"
			drop _merge
		}
	
		/* The following loop goes over the "datum" variables and determines which of the data specifications
		   lie within the boundaries of the respective spell. If they lie outside they are declared missing. 
		   "n_epidat" counts how many data specifications lie within the boundary of the respective spell. */
		quietly gen int `n_epidat' = 0
		local md = `max_t'
		
		forvalues i = 1(1)`md'{
			quietly {
				replace `datum'`i' = . if `datum'`i' < `start' | `datum'`i' > `end'
				replace `n_epidat' = `n_epidat' + 1 if `datum'`i' != .
			}
		}
			
		/* The following loop determines which of the "datum" variable holds the first nonmissing value and stores
			the the respective index number in the variable "first" for later use. */
		quietly gen int `first' = 0
		
		forvalues i = 1(1)`md'{
			quietly replace `first' = `i' if `datum'`i' != . & `first' == 0
		}

		/* The spells get multiplicated by the number of date specifications that lie within their boundaries - that
		   number has been stored in n_epidat. After that the expanded file is sorted and a count variable for the 
		   splits is generated (after expansion the spell counter is no more unique, because all expanded splits 
		   have the same value as their "mother" spell).  */
		quietly expand `n_epidat'
		sort `id' `spell2' 
		quietly by `id' `spell2': gen int `spid' = _n
			
		/* The next step assesses the index of the "datum" variable where the start date 
			is to be found for each split episode. The index is calculated as the index of the variable that holds
			the start date of the non-split episode (which is the first variable with a nonmissing value) plus the 
			value of the split count variable, minus 1. */
		quietly gen int `first2' = `first' + `spid' - 1
		
		/* After that the determined start date for each episode is transferred to a newly generated variable that 
			designates the start date of the split episode. This is done in a loop over the "datum" variables. */
		quietly gen int `bege' = .
		format `bege' `fmt'   /* adopting the format of the start date variable in the unsplit source file. */
		forvalues i = 1(1)`md'{
			quietly replace `bege' = `datum'`i' if `i' == `first2'

		}
		
		/* The end date variable of the splits is generated. As the splits of each episode are sorted in chonologic 
			order, the end date can be derived from the start date of the next split stemming from the same
			episode. If there is no next split the end date of the split is the same as the end date of the 
			unsplit spell. */
		quietly {
			gen int `ende' = .
			format `ende' `fmt'
			by `id' `spell2': replace `ende' = `bege'[_n+1] - 1 
			replace `ende' = `end' if `ende' == .
			}

		/* Deletion of all variables that are no more needed, save the split portion file, and confirmation
			message. */ 
	
		tempfile tempf`k'
		keep `fivevars' `srt' `bege' `ende' `tempn'
		quietly save "`tempf`k''", replace	
		if `port' > 1 {
			local message "{col 3}Portion no. `k' processed at $S_TIME on $S_DATE " 
		}
		else {
			local message "{col 3}File processed at $S_TIME on $S_DATE "
		}
		display " `message' "
	}
	scalar drop `max_t'
	 
	/*##############################################################################################################
	###################   Cumulate the portions into a temporary  all-up data file     #############################
	############################################################################################################# */

	local message "{col 3}Please wait while the portions are accumulated..." 
	display "    "
	display "`message'"
	display "    "
	
	local k = 1
	quietly use "`tempf`k''", clear 
		 
	if `port' > 1 {			
		forvalues k = 2(1)`portions' {	
			quietly append using "`tempf`k''", nolabel
		}   
		local message "{col 3}File portions accumulated at $S_TIME on $S_DATE.  "
		display "  "
		display " `message' "
		display "  "
	}
	
	/*##############################################################################################################
	###################   merge the split file to the original file                    #############################
	############################################################################################################# */

	
	local message "{col 3}Processing.... Please wait while the splits are merged to original file... "
	display " `message' "
	display " 	 "
	
	quietly save "`spfile'", replace
	restore 
	by `fivevars' `srt': gen long `tempn' = _n  /* generate the key for merging */	
	quietly merge 1:m `fivevars' `srt' `tempn' using "`spfile'"
	drop _merge
	drop `tempn'
	
	/* replacing the missvals in unsplit spells */
	replace `bege' = `start' if `bege' == .
	replace `ende' = `end' if `ende' == .

	/*##################################################################################################################
	############################   new casewise spell count and total no of spells per case  variables  ################
	##################################################################################################################*/
	*/

	sort `id' `bege' `sptype' `srt' 
	quietly {
		by `id': gen int `spneu' = _n  	/* New casewise spell count variable (due to the splitting the original spell  
										   counting is no more unique) */
		by `id': gen int `nsp' = _N		/* New total number of spells per case  */
		
	}
	lab var `bege' "split spell start date"
	lab var `ende' "split spell end date"
	lab var `spneu' "spell ID after splitting"
	lab var `nsp' "n of split spells per case"

	/*##################################################################################################################
	############################   Optional generation of spell count variables        #################################
	##################################################################################################################*/
	*/
	if `u'strlen(trim("`cvars'")) > 0 {
		sort `id' `bege' `sptype' `srt' `spneu' 
		quietly {
			by `id' `bege' `sptype': gen byte `lev1'=_n-1  // 
			by `id' `bege': gen int `lev2'=_n-1
			by `id' `bege' `sptype': gen byte `nlev1'=_N
			by `id' `bege': gen int `nlev2'=_N
		}
		lab var `lev1' "by `id' `sptype': count of isochronic spells"
		lab var `lev2' "by `id': count of isochronic spells"
		lab var `nlev1' "by `id' `sptype': sum of isochronic spells"
		lab var `nlev2' "by `id': sum of isochronic spells"
	}

	scalar drop `cmax' `span' `a' `b'	

	sort `id' `bege' `sptype' `srt' `spneu'
	describe, short
	
/*##################################################################################################################
############################                                           #############################################
############################      DISPLAY RUNTIME OF THE PROGRAM       #############################################
############################                                           ###########################################*/

	timer off 1
	quietly timer list
	scalar `time'=(r(t1))
	scalar `hrs' = int(`time'/3600)
	scalar `time' = (r(t1)) - (`hrs' * 3600)
	scalar `min' = int(`time'/60)
	scalar `sec' = round(`time' - (`min' * 60), .01)
	local message "{col 3}END spell splitting at $S_TIME on $S_DATE "  _n ///
	"  "  _n ///
	"{col 3}runtime of the program: " `hrs' " hrs " `min' " min " `sec' " sec " _n ///
	"   "

	display "   "  _n ///
	" {col 3}variables generated: "  _n ///
	" {col 3}--------------------  "  _n ///
	"	`bege'  {col 24}start date of the split spells"  _n ///
	"	`ende'  {col 24}end date of the split spells"  _n ///
	"	`spneu'  {col 24}enumerator of the split spells"  _n ///
	"	`nsp'  {col 24}sum of spells by `id' after splitting"
	if `u'strlen("`cvars'") > 0 {
		display "   "  _n ///
		"{col 3}optional count variables generated: " _n ///
		"{col 3}-----------------------------------   "  _n ///
		"	`lev1'  {col 24}count of isochronic spells by `id' and `sptype'"  _n ///
		"	`lev2'  {col 24}count of isochronic spells by `id'"   _n ///
		"	`nlev1'  {col 24}sum of isochronic spells by `id' and `sptype'"   _n ///
		"	`nlev2'  {col 24}sum of isochronic spells by `id'"		
	}
	display "   "
	display " `message' "
	
	scalar drop _all
	/* ### restore settings  ### */
	set varabbrev `varabr'
end	


