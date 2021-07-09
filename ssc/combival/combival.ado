*! combival, v3.0.0, Klaudia Erhardt & Ralf Kuenster, last updated: 2017-01-09
*! update v3.0.0 adapted to Stata14. A bug concerning variables with more than 28 levels has been fixed.

capture program drop combival
program combival
	version 11.2
	syntax varname, GRoup(varlist) [MD(str) NChar(integer 5) FRom(integer 1) VLab(str)] 
	display "   "
	display "combival v3.0.0, written by Klaudia Erhardt & Ralf Kuenster, last updated:  2017-01-09"
	display "   "

/*##################################################################################################################
############################                                           #############################################
############################  A) AUTOMATIC DEFINITION OF PARAMETERS -  #############################################
############################                                           ###########################################*/	

	tempfile idfile
	tempvar grtxp qstr temp temp1
	tempname time
	scalar `time' = 0
	
	local u ""
	if c(stata_version)>=14 {
		local u "u"		/* prefix for unicode commands */
	}

	local q = `u'char(34)		/* the double quote character */
	local qb = `u'char(96)		/* beginning compound quote character */
	local qe = `u'char(39)		/* ending compound quote character */
	
	local sct : type `varlist'		/* extract the type of the source variable */
	
	
/*##################################################################################################################
############################                                           #############################################
############################       B) CHECK IF INPUT IS VALID          #############################################
############################                                           ###########################################*/

	/*	### check if the mode specification is valid and assign default value if md is empty ### */
	
	if `u'strpos("`sct'", "str") > 0	{	/* if source variable is type string */

		/* if users' input was invalid */
		if `u'strlen(`u'strtrim("`md'")) > 1 | (`u'strlen(`u'strtrim("`md'")) == 1 & `u'strpos("sm",`u'strtrim("`md'")) == 0) {
			local message "The mode parameter you entered is not valid." _n ///
			"The source variable `varlist' is a string variable. Allowed modes are: 's' or 'm'. " _n ///
			"You entered '`md''. Your input will be substituted with 's' - a string combi variable " _n ///
			"using unique short labels over group `group' will be generated. "
			display "   "
			display " `message' "
			local md "s"
		}
		/* if mode was not set */
		if `u'strlen(`u'strtrim("`md'")) == 0	{
			local md "s"		/* default mode for string source variables is 's' */
		}
		/* remaining possibilities for md: length md == 1 & (s | m) --> users' input is valid, 
			nothing happens, `md' retains its value */
	}
	else {		/* if source variable is type numeric */

		/* assign number of levels of the source var to local nlev */
		quietly tab `varlist', nofreq  
		local nlev = r(r)
		
		/* if users' input was invalid */
		if `u'strlen(`u'strtrim("`md'")) > 1 | (`u'strlen(`u'strtrim("`md'")) == 1 & `u'strpos("nsm",`u'strtrim("`md'")) == 0) {    
			if `nlev' > 28	{
				local message "The mode parameter you entered is not valid. You entered '`md''. " _n ///
					"The numeric source variable `varlist' has `nlev' levels. To generate a numeric   " _n ///
					"combi variable, the source variable may not have more than 28 levels. " _n ///
					"Therefore mode is set to 's' - a string combi variable using unique short labels over " _n ///
					"group `group' will be generated. "
					local md "s"
			}
			if `nlev' <= 28	{
				local message "The mode parameter you entered is not valid." _n ///
				"The source variable `varlist' is a numeric variable. Allowed modes are: 'n' or 's' or 'm'. " _n ///
				"You entered '`md''. Your input will be substituted with 'n' - a numeric and a string  " _n ///
				"combi variable using unique short labels over group `group' will be generated. "	
				local md "n"
			}
			display "   "
			display " `message' "
			
		}

		/* if users' input was valid "n" but source variable has too many levels */
		else if `u'strlen(`u'strtrim("`md'")) == 1 & `u'strpos("n",`u'strtrim("`md'")) > 0 & `nlev' > 28	{
			local message "The numeric source variable `varlist' has `nlev' levels. To generate a numeric " _n ///
					"combi variable, the source variable may not have more than 28 levels. " _n ///
					"Therefore mode is set to 's' - a string combi variable using unique short labels over " _n ///
					"group `group' will be generated. "
			local md "s"		/* default mode for numeric variables with more than 28 levels is 's' */
			display "   "
			display " `message' "		
		}
		
		
		/* if mode was not set */
		if `u'strlen(`u'strtrim("`md'")) == 0 	{
			if `nlev' > 28	{	
				local message "The numeric source variable `varlist' has `nlev' levels. To generate a numeric " _n ///
					"combi variable, the source variable may not have more than 28 levels. " _n ///
					"Therefore mode is set to 's' - a string combi variable using unique short labels over " _n ///
					"group `group' will be generated. "			
				local md "s"		/* default mode for numeric variables with more than 28 levels is 's' */
				display "   "
				display " `message' "
			}
			if `nlev' <= 28	{
				local md "n"		/* default mode for numeric source variables is 'n' */			
			}
		}	
	
		/* remaining possibilities for md: length md == 1 & (s | m) --> users' input is valid, nlevels of source var
			is irrelevant, nothing happens, `md' retains its value */	

	}

	/*  ### check if the N-of-characters input is valid and replace with default if it is not ### */

	capture assert `nchar' > 0 & `nchar' < 11
	if _rc != 0 {
		local message1 "Your input for the maximum number of characters used from the value labels or " _n ///
		"string values of `varlist' is not valid." _n ///
		"Allowed are only integers from 1 to 10. Your input was: '`nchar''. " _n ///
		"Your input will be replaced by the default value of 5 characters . "
		display "   "
		display " `message' "
		local nchar = 5
	}


	/*  ### check if the "from" input is valid and replace with default if it is not ### */

	capture assert `from' > 0 & `from' < 11
	if _rc != 0 {
		local message `"Your input for the "from"-option  "' _n ///
		"of `varlist' is not valid." _n ///
		"Allowed are only integers from 1 to 10. Your input was: '`from''. " _n ///
		"Your input will be replaced by the default value. The extraction of characters " _n ///
		"from the labels or string values of the source variable will start at position 1. "
		display "   "
		display `" `message' "'
		local from = 1
	}

	
	/*  ### Find names for numeric and string combination variables that do not conflict with existing variables */
	
	local cn "combi"
	local cstr "combistr"
	capture confirm new variable `cn' `cstr', exact
	local a = ""
	while _rc != 0 {
		local a = `a' + 1
		capture confirm new variable `cn'`a' `cstr'`a', exact
	}
	local con "`cn'`a'"
	local costr "`cstr'`a'"
	
	capture label drop `con'  /* to fix the problem that the labels did not change in the tempfile */
	
	/*	### Generate the lists `typcodes' and `shortlabels' from users' vlab-input */

	if `u'strlen("`vlab'") == 0  {	  /* initialize macro vlab */
		local vlab ""
	}
	


	/* ### Divide users' input into the lists `typcodes' and `shortstrings' ### */
	
	if `u'strlen(`u'strtrim("`vlab'")) > 2 & `u'strpos("`vlab'", " ") > 0	{	/* at least 1 value/label pair */
		local nw : word count `vlab'
		local typcodes = word("`vlab'", 1)
		local shortstrings = word("`vlab'", 2)
		forvalues i = 3(1)`nw' {
			local str = word("`vlab'",`i')
			if int(`i'/2) < `i'/2  {	// odd position number
				local typcodes = "`typcodes'" + " " + "`str'"
			}
			else if int(`i'/2) == `i'/2 {	// even position number
				local shortstrings = "`shortstrings'"  + " " + "`str'"
			}
		}
	
		/* ### check for numeric scource variables: were values and labels entered alternately, 
			beginning with a value? ### */		
		if `u'strpos("`sct'", "str") == 0 {  /*  if source variable is numeric */
			capture numlist "`typcodes'", integer
			if _rc == 121	{
				local message "Your input for the values/labels list was invalid" _n ///
					"allowed are only integers and strings alternately. " _n ///
					"Your input was: `vlab' "
				display "   "
				display as err "`message'"
				exit
			}
		}
		/* ### check: same number of codes and labels? ### */
		local n1 : word count `typcodes'
		local n2 : word count `shortstrings'
		if `n1' != `n2'	{
			local message "Your input for the values/labels list was invalid" _n ///
			"the number of values is not equal to the number of labels" _n ///
			"Your input was: `vlab' "
			display "   "
			display as err "`message'"
			exit
		}
		
		/* for string source variables: assign quote marks to users' vlab-input */
		if `u'strpos("`sct'", "str") > 0 {  /*  if source variable is string */
			local str : word 1 of `typcodes'
			local str1 "`qb'`q'`str'`q'`qe'"
			local tctemp "`str1'"
			forvalues i = 2(1)`n1'	{
				local str : word `i' of `typcodes'
				local str1 "`qb'`q'`str'`q'`qe'"
				local tctemp "`tctemp' `str1'"
			}
			local typcodes "`tctemp'"
		}
	}

	else {		/* vlab is empty or something was put in, but not a value/label pair */
		local vlab ""
	}
	
	/*	### Generate `typcodes' and `shortlabels' from values and labels of the source var if `vlab' is empty ### */
	
	if "`vlab'" == ""	{

		quietly levelsof `varlist', local(typcodes)  /* extract values of typ-variable */
		local n1 : word count `typcodes'
		
		/* ### a) numeric source variable ### */

		if `u'strpos("`sct'", "str") == 0	{	/* if the source variable is not type string */
			local t1 : value label `varlist'	/* extract value lab definition of source variable */
			if `u'strlen("`t1'") > 0 	{		/* if there is a value lab definition */
				local val : word 1 of `typcodes'
				local x : label `t1' `val' 		/* extract the value label of value 'val' */
				local x = `u'subinstr(`u'strtrim(`"`x'"'), `"`q'"', "",.) /* remove all double quotes within the labels */
				local x = `u'subinstr(`u'strtrim(`"`x'"'), `"`qe'"', "",.) /* remove all single quotes within the labels */			
				local x = `u'substr(`u'strtrim(`"`x'"'), `from', `nchar') /* extract nchar char. from the string*/
				local x = `u'subinstr(`u'strtrim(`"`x'"'), " ", "-",.) /* replace all blanks within the labels with - */
				local shortstrings = "`x'"
				forvalues i = 2(1)`n1' {		/* loop over number of values in list typcodes */
					local val : word `i' of `typcodes'
					local x : label `t1' `val'
					local x = `u'subinstr(`u'strtrim(`"`x'"'), `"`q'"', "",.) 
					local x = `u'subinstr(`u'strtrim(`"`x'"'), `"`qe'"', "",.) 
					local x = `u'substr(`u'strtrim(`"`x'"'), `from', `nchar')
					local x = `u'subinstr(`u'strtrim("`x'"), " ", "-",.)
					local shortstrings = "`shortstrings'" + " " + "`x'"
				}
			}	
			else {		/* if there is no value lab definition */
				local shortstrings = "`typcodes'"
				local message "No value label definition found for variable `varlist'. " _n ///
				"The values of `varlist' will be used for short labels."
				display "   "
				display "`message'"
			}
		}

		/* ### b) String source variable ### */
		
		if `u'strpos("`sct'", "str") > 0 {	/* if the source variable is type string --> no val lab definition available */
			local val : word 1 of `typcodes'		
			local x = `"`val'"'
			local x = `u'subinstr(`u'strtrim(`"`x'"'), `"`q'"', "",.) /* remove all double quotes within the string */
			local x = `u'subinstr(`u'strtrim(`"`x'"'), `"`qe'"', "",.) /* remove all single quotes within the string */		
			local x = `u'substr(`"`x'"', `from', `nchar')	/* extract nchar characters from the string*/
			local x = `u'subinstr(`u'strtrim(`"`x'"'), " ", "-",.) /* replace all blanks inside the string */
			local shortstrings = "`x'"
			forvalues i = 2(1)`n1' {		/* loop over number of values in list typcodes */
					local val : word `i' of `typcodes'
					local x = `"`val'"'
					local x = `u'subinstr(`u'strtrim(`"`x'"'), `"`q'"', "",.)
					local x = `u'subinstr(`u'strtrim(`"`x'"'), `"`qe'"', "",.)
					local x = `u'substr(`"`x'"', `from', `nchar')	
					local x = `u'subinstr(`u'strtrim(`"`x'"'), " ", "-",.)
					local shortstrings = "`shortstrings'" + " " + `"`x'"'
			}		
		}
	}

	/* ##################### Log of the arguments the program uses ############################################## */

	display "  "
	display "Log of the arguments the program uses:	"
	display "-------------------------------------- "
	local a ""
	if "`md'" == "n" {
		local a "(string and numeric combi variable with unique entries of shortlabels)"
	}
	if "`md'" == "s" {
		local a "(string combi variable with unique entries of shortlabels)"
	}
	if "`md'" == "m"  {
		local a "(multiple entries of shortlabels --> only string combi variable will be generated)"
	}
	display "Source variable: `varlist' (type `sct') "
	display "Grouping variable: `group' "	
	display "Mode: `md' `a' "
	display "uses the following codes from `varlist':"
	display `"   `typcodes'"'
	display "short labels used for the combination variables: "
	display "   `shortstrings'"
	display "-------------------------------------- "
	display "   "
	

/*##################################################################################################################
############################                                           #############################################
############################      BEGIN OF THE CORE PROGRAM            #############################################
############################                                           ###########################################*/


	/* #####################    capture the state of the file and the settings and set timer on ################# */

	quietly describe, varlist
	local seq = r(varlist)
	local sortorig = r(sortlist)
	local varabr = c(varabbrev)
	set varabbrev off 
	set more off
	
	timer clear
	timer on 1		/* Measuring the runtime of the program */	

	local message "BEGIN generation of the combination variable(s) with program combival at $S_TIME on $S_DATE "
	display "     "
	display " `message' "
	sort `group' `varlist'	 /* sort all records by defined groups and source variable  */

	/* #####################################    prepare the working file #########################################*/
	
	by `group' `varlist': gen int `temp' = _n  /* generate a unique key for merging later on */
	preserve
	
	if `u'strpos("`md'", "m") == 0 {   /* if mode n or s desired (unique entries), duplicates are dropped */ 
		by `group' `varlist': gen byte `temp1' = cond(_n == 1, 1, 0)
		quietly drop if `temp1' != 1
		capture drop `temp1'
		/* used this syntax because "duplicates drop" is slower */
	}
	keep `group' `varlist' `temp'
	
	/* #######################  generate the string combination variable ######################################## */

	
	local message "Processing.... Please wait..... "
	display "    "
	display " `message' "

	local n1 : word count `typcodes'

	/* #### a) source variable is numeric and has 28 levels maximally #### */

	if `u'strpos("`sct'", "str") == 0	{
		if "`vlab'" == ""	{		/* if no values/labels list was put in*/
			gen long `grtxp' = `varlist'
		}
		else	{
			gen long `grtxp' = 0
		}
		lab def `grtxp' 0 "", modify	/* new label definition is created and assigned to `grtxp'  */
		lab val `grtxp' `grtxp' 
		
		if `n1' <=28	{
			forvalues i = 1(1)`n1' {		/* `n1' indicates the number of words in list typcodes or shortstrings */
				quietly replace `grtxp' = 2^(`n1'-`i') if `varlist' == real(word("`typcodes'",-`i')) 
									/* here -`i' denominates the`i'th entry in the list counted from the end on. */
				local a = 2^(`n1'-`i')						/* here -`i' means: subtract `i' (from `n')  */
				local b = word("`shortstrings'",-`i')
				local c "lab def `grtxp' `a' `qb'`q'`b'`q'`qe', modify"
				`c'
			}
		}
		
		if `n1' > 28	{
			forvalues i = 1(1)`n1' {		/* `n1' indicates the number of words in list typcodes or shortstrings */		
				/* in this case, no numeric combi variable is created and using 2^-values is not necessary */
				quietly replace `grtxp' = (`n1'-`i') if `varlist' == real(word("`typcodes'",-`i'))
				local a = (`n1'-`i')
				local b = word("`shortstrings'",-`i')
				local c "lab def `grtxp' `a' `qb'`q'`b'`q'`qe', modify"
				`c'
			}
		}
		
		decode `grtxp', gen(`qstr')	/* generate string var `qstr' and assign short labels of `grtxp' as values. */
	}
	
	/* #### b) source variable is string  #### */
	
	if `u'strpos("`sct'", "str") > 0	{
	
		local n1 : word count `typcodes'
		quietly gen str`nchar' `qstr' = "" /* generate a string variable as source for the combination variable */
		forvalues i = 1(1)`n1' {
			local a : word `i' of `typcodes'
			local b : word `i' of `shortstrings'
			quietly replace `qstr' =  "`b'" if `varlist' == `"`a'"'
		}
	}
	
		quietly gen str `costr' = `qstr' 
		
		quietly describe, varlist
		local sortact = r(sortlist)
		if "`sortact'" != "`group' `varlist'"	{
			sort `group' `varlist'
		}
		quietly {
			by `group': replace `costr' = `costr'[_n-1]+"+"+`costr' if _n > 1	/*stepwise collecting the short labs */
			by `group': replace `costr' = `costr'[_N]	/* assign the last (complete) string to all obs. of the group */

			/* replace unnecessary "+" characters stemming from missings in the source variable. Orphan "+" characters
			   can occur only at the beginning and at the end of the `costr'-string */
			capture assert `u'strpos(`costr', "++") == 0 	/* assert if no "++" is to be found in `costr' */
			while _rc != 0	{
				replace `costr' = `u'subinstr(`costr', "++", "+",.)
				capture assert `u'strpos(`costr', "++") == 0
			}
			replace `costr' = `u'substr(`costr', 2, `u'strlen(`costr')-1) if `u'substr(`costr', 1, 1) == "+"
			replace `costr' = `u'substr(`costr', 1, `u'strlen(`u'strtrim(`costr'))-1) if ///
							  `u'substr(`costr', `u'strlen(`u'strtrim(`costr')), 1) == "+"
		}
*	}

	/* #######################  generate the numeric combination variable ####################################### */	
	/*                          (only when mode n was ordered --> implies unique entries)                         */

	if `u'strpos("`md'", "n") > 0 {   
		local message "Processing.... Please wait..... "
		display "    "
		display " `message' "

		/* ### Construction of the numeric var `con', which sums up the values of `grtxp' for the defined groups */
		quietly  {
			by `group': gen long `temp1'=sum(`grtxp')
			by `group': gen long `con'=`temp1'[_N]
		}
		format `con' %20.0f
		capture drop `temp1'

		/* ### Produce Labels for the numeric combination variable `con'  ### */

		quietly save "`idfile'"	/* the next step is processed over only unique occurences of each label of `con' */
		sort `con'
		by `con': gen byte `temp1' = cond(_n == 1, 1, 0)
		quietly drop if `temp1' != 1
		capture drop `temp1'
	
		/* ### copy the values of `con' and `costr' into the lists `alist' and `blist', for use in the  next step */
		quietly levelsof `con', local(alist)

		/* ### provide for value 0 in con, stemming from missings in source variable ### */
		if real(word("`alist'",1)) == 0 {
			local beg = 2
		}
		else	{
			local beg = 1
		}

		local na : word count `alist'
		local blist = ""
		forvalues i = 1(1)`na'	{
			local a : word `i' of `alist'
			local b = `costr'[`i']
			local blist = "`blist' `b'"
		}
		
		/* ### recall the previous file and label variable `con' ### */
		
		use "`idfile'", clear
		lab def `con' 0 "missing or not used for combination", modify
		lab val `con' `con'
		if `beg' == 2 { /* provide for value 0 in con, stemming from missings in source variable */	
			local k = 2
		}
		else {
			local k = 1
		}
		forvalues i = `k'(1)`na'{
			if `beg' == 2 {	/* provide for value 0 in con, stemming from missings in source variable */	
				local j = `i' - 1	
			}
			else {
				local j = `i'
			}
			local a : word `i' of `alist'
			local b : word `j' of `blist'
			local c "lab def `con' `a' `qb'`q'`b'`q'`qe', modify"
			`c'	
		}
	}

	/* ########## all modes and variable types: merge new variables to original file and restore settings ############*/

	quietly save "`idfile'", replace
	restore
	
	if `u'strpos("`md'", "m") > 0 {   /* if multiple entries were ordered */
		quietly  merge 1:1 `group' `varlist' `temp' using "`idfile'"
		drop _merge
	}
	if `u'strpos("`md'", "m") == 0 {   /* if unique entries (numeric and strings) were ordered */
		quietly  merge m:1 `group' `varlist'  using "`idfile'"
		drop _merge
	}

	/* ### drop the temp-variables ### */
	capture drop `grtxp'
	capture drop `qstr' 
	capture drop `temp' 
	
	/* ### label the new variables ### */
	capture confirm variable `con', exact   
	if _rc == 0 {   /* if `con' exists */
		lab var `con' "uComb_`varlist' over `group'"
	}
	if `u'strpos("`md'", "m") > 0   {
		lab var `costr' "mComb_`varlist' over `group'"
	}
	if `u'strpos("`md'", "m") == 0	{
		lab var `costr' "uComb_`varlist' over `group'"
	}
	
	/* ### restore settings, sort and variable order  ### */
	set varabbrev `varabr'
	capture confirm variable `con', exact
	if _rc == 0 {   /* if `con' exists */
		order `seq' `con' `costr'
	}
	if _rc != 0 {
		order `seq' `costr'
	}
	quietly describe, varlist
	local sortnow = r(sortlist)
	if "`sortorig'" != "."  & "`sortnow'" != "`sortorig'"	{
		sort `sortorig'
	}

/*##################################################################################################################
############################                                           #############################################
############################      DISPLAY RUNTIME OF THE PROGRAM       #############################################
############################                                           ###########################################*/

	timer off 1
	quietly timer list
	scalar `time'=(r(t1))
	local hrs = int(`time'/3600)
	scalar `time' = (r(t1)) - (`hrs' * 3600)
	local min = int(`time'/60)
	local sec = round(`time' - (`min' * 60), .01)
	local message "runtime of the program: `hrs' hrs `min' min `sec' sec  " _n ///
	"END at $S_TIME on $S_DATE " 
	display "   "
	display " `message' "
	capture confirm variable `con', exact  
	if _rc == 0 {   /* if `con' exists */
		local message "the numeric combi variable is named `con' "
		display "   "
		display " `message' "
	}
	local message 	"the string-combi variable is named `costr'"
	display "   "
	display " `message' "	
	timer clear
end	

