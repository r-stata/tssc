*! stcompadj 0.0.2 EC 15aug2009
*! Adjusted Cumulative Incidence in the Presence of Competing Events

program define stcompadj,sortpreserve
	version 10
	st_is 2 analysis
	syntax anything(name=com equalok) [if] [in] , COMPET(numlist)  [ MAINEFfect(varlist) COMPETEFfect(varlist) ///          
	GENerate(namelist) SAVEXPanded(string asis) BOOTCI REPs(integer 1000) SIze(integer 0) Level(cilevel) ///
	SHOWMOD EFRon noHR noLOG  FLExible CI DF(passthru)   ]

	marksample touse

*** 1 From -adjust- command: Non standard parsing of the varlist 
	ParseVar `com'
	local covars "`s(vnames)'" /* Covariates to be set */
	local covals "`s(values)'" /* Values to set the covariates or "mean" */
	markout `touse' `covars'
	qui count if `touse'
	if r(N) == 0  error 2000  
	qui replace `touse' = 0 if _st==0
	local type : set type
	set type double

*** 2 Checks
		/* previous stset statement must be as required by stcompet */
	if "`_dta[st_bd]'"=="" | "`_dta[st_ev]'"=="" {   	
	    di as err  "failure variable must have been specified as failure(varname==numlist) " /*
        */ _n "on the stset command prior to using this command"
		exit 198
        }

		/* multiple records per subjects not allowed */
	local id : char _dta[st_id]
	if "`id'"!="" {
		cap bysort `_dta[st_id]' : assert _N==1
		if _rc {
			di in smcl as err "{p}Multiple records per subjects not allowed.{p_end}"
			exit 198
		}
	}

		/* competing and interest events must be different */
	local main "`_dta[st_ev]'"   /* main event */ 
	local a : list main & compet
	if "`a'" != "" {	
		di in smcl as err "{p}`a' specified as code for two competing events.{p_end}"
                exit 198
        }

	       /* Variables specified in the following options must be in the anything-varlist. Note that, if not specified
	          the command assumes that the anything-varlist have the same effect on the main and on the competing event */
	if "`maineffect'" != "" {
		local a : list maineffect - covars
		if "`a'" != "" {	
			di in smcl as err "{p}maineffect option incorrectly specified: `a' is not a variable to be adjusted{p_end}"
               		exit 198
		}
	}
	if "`competeffect'" != "" {
		local a : list competeffect - covars
		if "`a'" != "" {	
			di in smcl as err "{p}competeffect option incorrectly specified: `a' is not a variable to be adjusted{p_end}"
               		exit 198
		}
	}

		/* The command generates two variables containing the cumulative incidence function for the main and competing events.			
		   If generate() is not specified, the default names for these variable are CI_Main and CI_Compet */
	if "`generate'" != ""{
		local a : word count `generate'
		if `a' != 2 {
			di in smcl as err "{p}Two new variables must be specified in generate().{p_end}"
               		exit 198
		}
		local i = 1
		foreach name of local generate {
			capture confirm new var `name', exact
			if _rc {
				di in smcl as err "{p}generate option incorrectly specified: `name' already defined.{p_end}"
               			exit 198
			}
			else local name`i' `name'
			local ++i
		}
	}
	else {
		confirm new var CI_Main CI_Compet
		local name1 CI_Main
		local name2 CI_Compet
	}     

		/* Expanded data file can be useful to test if the effect of a covariate is different on the main and the competing event and to 
		   test if the hazard of the main event is different from the hazard of competing event under the quite hard assumption that
		   the hazards for two events are proportional (a better test to this last aim should be the so called KLY test). */
	if "`savexpanded'" != "" {
		gettoken savfile savexpanded : savexpanded, parse(",")
		gettoken comma   savexpanded : savexpanded, parse(",") 
		if `"`comma'"' == "," { 
			gettoken outfile savexpanded : savexpanded, parse(" ,")
			gettoken comma savexpanded : savexpanded, parse(" ,")
			if `"`outfile'"' != "replace" | `"`comma'"'!="" { 
				di as err "option savexpanded() invalid"
			exit 198
			}
		}
		else if `"`comma'"' != "" {
			di as err "option savexpanded() invalid"
			exit 198
		}
		else 	confirm new file `"`savfile'.dta"'
	}

*** 3 Preparing expanded data set
	/* Estimates will be saved by merging with the original data file */ 
	sort _t
	preserve
	quietly {
		keep if `touse'
		sort _t `_dta[st_bd]'
		keep _* `covars' `_dta[st_bd]' `id'
		local evvar "`_dta[st_bd]'"
		drop `touse'
		qui count
		local nobs `r(N)'
		tempvar stratvar Dvar dall 
		expand 2
		g byte `stratvar' = 1 + (_n>`nobs')   
		g byte `Dvar' = 0
		g byte `dall' = 0
		foreach num of local main {
			replace `Dvar' = 1 if `_dta[st_bd]'==`num' & `stratvar'==1	
			replace `dall' = 1 if `_dta[st_bd]'==`num'	
		}
		foreach num of local compet {
			replace `Dvar' = 1 if `_dta[st_bd]'==`num' & `stratvar'==2
			replace `dall' = 1 if `_dta[st_bd]'==`num'
		}
	/* listvar must contain 1) the list of the variables having the same effect on both causes */
		local listvar : list covars  - maineffect
		local listvar : list listvar - competeffect
	/* 2) The list of the variables having a different effect on the main event */
		if "`maineffect'"!="" {
			tokenize `maineffect'
			while "`1'" != "" {
				g Main_`1' = cond(`stratvar'==1, `1',0)
				local listvar "`listvar' Main_`1'"
				mac shift
			}
		}
	/* and 3) The list of the variables having a different effect on the competing event */
		if "`competeffect'"!="" {
			tokenize `competeffect'
			while "`1'" != "" {
				g Compet_`1' = cond(`stratvar'==2, `1',0)
				local listvar "`listvar' Compet_`1'"
				mac shift
			}
		}	
*Saving expanded data file
		su _t0, meanonly
		if `r(max)' > 0	local enter "enter(time _t0)"
		stset _t, f(`Dvar') `enter'
		if "`savfile'" != "" save "`savfile'", `outfile'
	}

*** 4 Stratified Cox or Flexible Parametric Model
	tempvar H h xb hazsum S0
	if "`flexible'" == "" & "`ci'"=="" {
			if "`bootci'" != "" {
				tempfile tfile
				qui {
					count
					local nobs = `r(N)' / 2
					if `size' > 0 {
						capture assert `size' <= `nobs'
						if c(rc) {
							di as err "size() must not be greater than `nobs'"
						exit 498
						}
						else nobs = `size'
					}
					save `tfile'
					mata: tuniq("_t" )
				}
			}

			if "`showmod'" != "" {
				di 
				di in smcl as txt "{p}Stratified Cox Model in data set expanded in two strata to allow simultaneous assessment"  ///
						" of covariates effect on two competing risks.{p_end}"  
				di in smcl as txt "{p}Covariates whose name is not changed have the same effect on both events.{p_end}"
				di in smcl as txt "{p}Covariates whose name is prefixed by" as res " Main_ " as txt "have effect only on the main event.{p_end}"
				di in smcl as txt "{p}Covariates whose name is prefixed by" as res " Compet_ " as txt "have effect only on the competing event.{p_end}"
				di
			}
			else	local q 	quietly
			`q' stcox `listvar', strata(`stratvar') basech(`H') `efron' `hr' `log' nosh
	}
	else {
		if "`df'" == ""		local df  "df(4)"
		if "`showmod'" != "" {
			di 
			di in smcl as txt "{p}Stratified Flexible Parametric Model in data set expanded in two strata to allow simultaneous assessment"  ///
						" of covariates effect on two competing risks.{p_end}"  
				di in smcl as txt "{p}Covariates whose name is not changed have the same effect on both events.{p_end}"
				di in smcl as txt "{p}Covariates whose name is prefixed by" as res " Main_ " as txt "have effect only on the main event.{p_end}"
				di in smcl as txt "{p}Covariates whose name is prefixed by" as res " Compet_ " as txt "have effect only on the competing event.{p_end}"
				di
		}
		else	local q 	quietly
*		`q' stpm `listvar' `stratvar', stratify(`stratvar')  scale(hazard)   `df'   `log'     // Lambert 12.6.09 -> For now strata var must be included also in the linear predictor
		`q' stpm2 `listvar' `stratvar', stratify(`stratvar')  scale(hazard)   `df'   `log'  
		if "`ci'" !=  ""		local levci	level(`level')
	}

	quietly {
*** 5 Set the listvar to the values in covals or to their mean if coval says "mean". (Adapted from SetCovars in Adjust command)
 		local ncov : word count `covars'
		forval i = 1/`ncov' {
			local covari : word `i' of `covars'
			local covali : word `i' of `covals'
			if "`covali'" == "mean" {
				su `covari', meanonly
				if "`flexible'" == "" & "`ci'"=="" {
					replace `covari'   = `r(mean)'
					cap replace Main_`covari' = `r(mean)' if `stratvar'==1
					cap replace Compet_`covari' = `r(mean)' if `stratvar'==2
				}
				else {
					cap confirm var Main_`covari' Compet_`covari'
					if _rc 	local listat "`listat'  `covari' `r(mean)'"
					cap confirm var Main_`covari'
					if !_rc 	local listatm "`listatm'  Main_`covari' `r(mean)' Compet_`covari' 0"
					cap confirm var Compet_`covari'
					if !_rc 	local listatc "`listatc'  Compet_`covari' `r(mean)' Main_`covari' 0"
				}
			}
			if "`covali'" != "mean" {
				if "`flexible'" == "" & "`ci'"=="" {
					replace `covari' = `covali' 
					cap replace Main_`covari' = `covali' if `stratvar'==1
					cap replace Compet_`covari' = `covali' if `stratvar'==2
				}
				else {
					cap confirm var Main_`covari' Compet_`covari'
					if _rc 	local listat "`listat'  `covari' `covali'"
					cap confirm var Main_`covari'
					if !_rc 	local listatm "`listatm'  Main_`covari' `covali'" // Compet_`covari' 0
					cap confirm var Compet_`covari'
					if !_rc 	local listatc "`listatc'  Compet_`covari' `covali'" //  Main_`covari' 0
				}
			}
		}
*** 6 Adjusted Cumulative Hazard 
***If Cox
		if "`flexible'" == "" & "`ci'"=="" {
				predict `xb', xb
				replace `H' = `H' * exp(`xb')
		}
***If Flexible parametric
		else {
			tempvar H1 H2 
			predict `H1' if `stratvar'==1  ,  at(`listat' `listatm' ) survival   `ci'   `levci'
			predict `H2' if `stratvar'==2  ,  at(`listat' `listatc' )  survival   `ci'   `levci'
			replace `H1' = -log(`H1')
			replace `H2' = -log(`H2')
*			g double `H' = cond(`stratvar'==1, exp(`H1'), exp(`H2'))
			g double `H' = cond(`stratvar'==1, `H1',`H2')
			if "`ci'" != "" {
				replace `H1'_uci = -log(`H1'_uci) 
				replace `H2'_uci = -log(`H2'_uci)
				replace `H1'_lci = -log(`H1'_lci)
				replace `H2'_lci = -log(`H2'_lci)
				g double `H'_uci = cond(`stratvar'==1, `H1'_lci,`H2'_lci)	// Upper CI of S function is Lower CI of H function
				g double `H'_lci  = cond(`stratvar'==1, `H1'_uci,`H2'_uci)
			}
		}
*		save filecheck, replace

*** 7 Hazard increments
		g byte `touse' = `dall'>0
		bysort `stratvar' `touse' _t    : replace `touse' = 0 if `touse'==1 & _n>1  // for ties
		keep if `touse'
		bysort `stratvar' (_t) : g double `h' = cond(_n==1,`H',`H'-`H'[_n-1])  
		if "`ci'" != "" {
				bysort `stratvar' (_t) : g double `h'_uci = cond(_n==1,`H'_uci,`H'_uci-`H'_uci[_n-1])  
				bysort `stratvar' (_t) : g double `h'_lci = cond(_n==1,`H'_lci,`H'_lci-`H'_lci[_n-1])  
				keep `h' `h'_uci `h'_lci `stratvar' _t  
* Put data in wide format for each type failure time
				reshape wide `h' `h'_uci `h'_lci, i(_t) j(`stratvar')	//   `H'
		}
		else	{
			keep `h' `stratvar' _t  
			reshape wide `h' , i(_t) j(`stratvar')	//   `H'
		}

*** 8 Survival for all events 
		g double `hazsum'  = `h'1 + `h'2
		sort _t
		g double `S0' = exp(sum(log(1-`hazsum'))) 

*** 9 Cumulative Incidences 
		g double `name1' = cond(_n==1,1*`h'1, `S0'[_n-1]*`h'1)  
		replace  `name1' = sum(`name1')
		g double `name2' = cond(_n==1,1*`h'2, `S0'[_n-1]*`h'2)
		replace  `name2' = sum(`name2')
	}

***10 Confidence limits according to flexible parametric approach
	if "`ci'" !="" {
		tempvar hs_uci hs_lci S0_uci S0_lci
		g double `hs_uci'  = `h'_uci1 + `h'_uci2
		sort _t
		g double `S0_uci' = exp(sum(log(1-`hs_uci'))) 
		g double `hs_lci'  = `h'_lci1 + `h'_lci2
		g double `S0_lci' = exp(sum(log(1-`hs_lci'))) 
		g double `name1'_uci = cond(_n==1,1*`h'_uci1, `S0_uci'[_n-1]*`h'_uci1)  
		qui replace  `name1'_uci = sum(`name1'_uci)
		g double `name1'_lci = cond(_n==1,1*`h'_lci1, `S0_lci'[_n-1]*`h'_lci1)  
		qui replace  `name1'_lci = sum(`name1'_lci)
		g double `name2'_uci = cond(_n==1,1*`h'_uci2, `S0_uci'[_n-1]*`h'_uci2)  
		qui replace  `name2'_uci = sum(`name2'_uci)
		g double `name2'_lci = cond(_n==1,1*`h'_lci2, `S0_lci'[_n-1]*`h'_lci2)  
		qui replace  `name2'_lci = sum(`name2'_lci)
		local cinames  `name1'_uci  `name1'_lci  `name2'_uci `name2'_lci  
	}

*** 11 Saving Estimates
	sort _t
	tempfile studyfile
	if "`ci'"	== ""	qui keep _t `name1'  `name2'
	else				qui keep _t `name1'  `name1'_uci  `name1'_lci `name2' `name2'_uci `name2'_lci
	qui save `studyfile'
	
*** 12 Bootstrap Confidence Intervals
	if "`bootci'" != "" {
		quietly {	
			forval i= 1/`reps'{
				use `tfile',clear
				bsample `nobs', cluster(`_sortindex')
				stcox `listvar', strata(`stratvar') basech(`H') 
				forval a = 1/`ncov' {
					local covari : word `a' of `covars'
					local covali : word `a' of `covals'
					if "`covali'" == "mean" {
						su `covari', meanonly
						replace `covari'   = `r(mean)'
						cap replace Main_`covari' = `r(mean)' if `stratvar'==1
						cap replace Compet_`covari' = `r(mean)' if `stratvar'==2
					}
					else { 
						replace `covari' = `covali' 
						cap replace Main_`covari' = `covali' if `stratvar'==1
						cap replace Compet_`covari' = `covali' if `stratvar'==2
					}
				}
				predict `xb', xb
				replace `H' = `H' * exp(`xb')
				g byte `touse' = `dall'>0
				bysort `stratvar' `touse' _t    : replace `touse' = 0 if `touse'==1 & _n>1 
				keep if `touse'
*				keep `H' `stratvar' _t  
				bysort `stratvar' (_t) : g double `h' = cond(_n==1,`H',`H'-`H'[_n-1])  
				keep `h' `stratvar' _t  
				reshape wide `h'  , i(_t) j(`stratvar')	// `H'
				g double `hazsum'  = `h'1 + `h'2
				sort _t
				g double `S0' = exp(sum(log(1-`hazsum'))) 
				g double `name1' = cond(_n==1,1*`h'1, `S0'[_n-1]*`h'1)  
				replace  `name1' = sum(`name1')
				g double `name2' = cond(_n==1,1*`h'2, `S0'[_n-1]*`h'2)
				replace  `name2' = sum(`name2')
				mata: merg_ci("_t", "`name1'","`name2'", *tuniq_S)
			}
			local plow = ((100 - `level')/2) / 100
			local phig  = (`level' + (100 - `level')/2) / 100
			use `tfile',clear
			bysort _t : keep if _n==1
			keep _t
			mata: cb_ci(*tuniq_S, `plow', `phig')
			rename `Mhig' Hi_`name1'
			rename `Mlow' Lo_`name1'
			rename `Chig' Hi_`name2'
			rename `Clow' Lo_`name2'
			sort _t
			save,replace
		}
	}
	restore
	qui merge _t using `studyfile', keep(`name1' `name2' `cinames')
	label var `name1' "Adjusted cumulative incidence for the main event"
	label var `name2' "Adjusted cumulative incidence for the competing event"
	if "`ci'" !="" {
		label var `name1'_uci "Flexible `level'% high confidence bound of `name1'"
		label var `name2'_uci "Flexible `level'% high confidence bound of `name2'"
		label var `name1'_lci "Flexible `level'% low confidence bound of `name1'"
		label var `name2'_lci "Flexible `level'% low confidence bound of `name2'"
		rename `name1'_uci Hi_`name1'
		rename `name1'_lci  Lo_`name1'
		rename `name2'_uci Hi_`name2'
		rename `name2'_lci  Lo_`name2'
	}
	drop _m
	if "`bootci'" != "" {
		sort _t
		qui {
			merge _t using `tfile', keep(Hi_`name1' Lo_`name1' Hi_`name2' Lo_`name2')
			replace Hi_`name1'= . if `name1'==.
			replace Lo_`name1'= . if `name1'==. 
			replace Hi_`name2'= . if `name2'==. 
			replace Lo_`name2'= . if `name2'==. 
			label var Hi_`name1' "Bootstrapped `level'% high confidence bound of `name1'"
			label var Lo_`name1' "Bootstrapped `level'% low confidence bound of `name1'"
			label var Hi_`name2' "Bootstrapped `level'% high confidence bound of `name2'"
			label var Lo_`name2' "Bootstrapped `level'% low confidence bound of `name2'"
			drop _m
		}
	}
	if "`savfile'"!="" {
		preserve
		qui use `savfile',clear
		rename `stratvar' stratum
		qui drop `dall' `Dvar' `_sortindex'
		label var stratum "Stratum indicator"
		label var _d "Failure-Stratum indicator"
		qui save, replace
	}
end


* From -adjust- command
* ParseVar parses the var[= #][var[= #]...] syntax and returns the variable
* names in s(vnames) and the values (or the word "mean") in s(values).  It
* will handle the * and - expansions.
program ParseVar  /* <varlist> */ , sclass
	tokenize "`*'", parse(" =-*")
	local i 1
	while "``i''" != "" {
		if "``i''" == "=" | "``i''" == "-" | "``i''" == "*" {
			di in red "``i'' used improperly in varlist"
			exit 198
		}
		local j = `i' + 1
		if "``j''" == "*" {  /*  * expansions */
			local k = `j' + 1
			if "``k''" == "-" {  /* * expansion with - */
				local m = `k' + 1
				unab tmpvar : ``i''``j''``k''``m''
				local varlist "`varlist' `tmpvar'"
				local temp : word count `tmpvar'
				local h 1
				while `h' <= `temp' {
					local vallist "`vallist' mean"
					local h = `h' + 1
				}
				local i = `i' + 4
			}
			else {  /*  * expansion without - */
				unab tmpvar : ``i''``j''
				local varlist "`varlist' `tmpvar'"
				local temp : word count `tmpvar'
				local h 1
				while `h' <= `temp' {
					local vallist "`vallist' mean"
					local h = `h' + 1
				}
				local i = `i' + 2
			}
		}
		else if "``j''" == "-" {  /* - expansion */
			local k = `j' + 1
			unab tmpvar : ``i''``j''``k''
			local varlist "`varlist' `tmpvar'"
			local temp : word count `tmpvar'
			local h 1
			while `h' <= `temp' {
				local vallist "`vallist' mean"
				local h = `h' + 1
			}
			local i = `i' + 3
		}
		else {  /* no * or - expansion */
			unab tmpvar : ``i''
			local varlist "`varlist' `tmpvar'"
			if "``j''" == "=" {  /* var=# syntax */
				local k = `j' + 1
				if "``k''" == "-" { /* negative sign */
					local neg "-"
					local k = `k' + 1
					local i = `i' + 1
				}
				else { /* no negative sign */
					local neg
				}
				capture noi confirm number `neg'``k''
				if _rc != 0 {
					di in red /*
			*/ "only numbers allowed in var = # form of varlist"
					exit _rc
				}
				local vallist "`vallist' `neg'``k''"
				local i = `i' + 3
			}
			else {  /* no *, -, or =  */
				local vallist "`vallist' mean"
				local i = `i' + 1
			}
		}
	}
	sret local vnames "`varlist'"
	sret local values "`vallist'"
end

version 10
mata:
mata set matastrict on

void tuniq(string scalar _t)
{
	rmexternal("tuniq_S")
	real matrix A
	pointer() scalar pA
	st_view(A = . , ., (_t))
	A = sort(A,1)
	info = panelsetup(A,1)
	tuniq_S = J(rows(info),1,.)
	for (i=1; i<=rows(info); i++) {
    		C = panelsubmatrix(A, i, info)
      		tuniq_S[i,.] = colmin(C[.,1])     
	}
	tuniq_S = tuniq_S,J(rows(tuniq_S),2,.)
	pointer(pointer() vector) scalar p
	p  = crexternal("tuniq_S")
	*p = (&tuniq_S)
}

void merg_ci(string scalar _t, string scalar main, string scalar compet, real matrix S)
{
	st_view(B = . , ., (_t, main,compet))
	C=S[1..missing(S[.,2]),1] , J(missing(S[.,2]),2,.)
	for (i=1;i<=rows(B);i++) {
		C[mm_which(C[.,1]:==B[i,1]),2]=1
	}
	C[.,2] = runningsum(C[.,2])
	for (i=1;i<=rows(B);i++) {
		M=J(rows(C),1,i)
		X = mm_which(C[.,2]:==M)
		C[X,2]=J(rows(X),1,B[i,2])
		C[X,3]=J(rows(X),1,B[i,3])
	}
	_editmissing(C,0)
	S = S \ C
}


void cb_ci(real matrix S, real scalar plow, real scalar phig)
{
	S  = select(S, rowmissing(S):==0)
	S  = sort(S,1)
	ID = S[.,1]
	S  = S[., (2,3)]
	X = _mm_collapse(S, 1, ID, &mm_quantile(), plow)
	Y = _mm_collapse(S, 1, ID, &mm_quantile(), phig)
	(void) st_addvar("double", Mlow = st_tempname())
	(void) st_addvar("double", Mhig = st_tempname())
	(void) st_addvar("double", Clow = st_tempname())
	(void) st_addvar("double", Chig = st_tempname())
	st_store(.,Mlow, X[.,2])
	st_store(.,Mhig, Y[.,2])
	st_store(.,Clow, X[.,3])
	st_store(.,Chig, Y[.,3])
	st_local("Mlow", Mlow)
	st_local("Mhig", Mhig)
	st_local("Clow", Clow)
	st_local("Chig", Chig)
	rmexternal("tuniq_S")
}
end
