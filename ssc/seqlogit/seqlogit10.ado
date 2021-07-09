*! 1.1.15 MLB 22Mar2012
*! 1.1.13 MLB 03Aug2010
*! 1.1.12 MLB 11Jun2010
*! 1.1.9  MLB 28Apr2010
*! 1.1.8  MLB 08Apr2010
*! 1.1.3  MLB 07Aug2009
*! 1.1.1  MLB 14Jul2009
*! 1.1.0  MLB 07Sep2008
*! 1.0.3  MLB 24Aug2008
*! 1.0.2  MLB 07Jun2007
*! 1.0.1  MLB 15May2007

/*------------------------------------------------ playback request */
program seqlogit10, eclass byable(onecall) sortpreserve
	version 9.2
	if replay() {
		if "`e(cmd)'" != "seqlogit10" {
			di as err "results for seqlogit not found"
			exit 301
		}
		if _by() error 190 
		Display `0'
		exit `rc'
	}
	if _by() by `_byvars'`_byrc0': Estimate `0'
	else Estimate `0'
end

/*------------------------------------------------ estimation */
program Estimate, eclass byable(recall)
	syntax varlist [if] [in] [pw fw iw] , ///
	tree(string) *

// start with a clean slate	
	macro drop S_*
	
	Parsetree `tree'
	Displaytree
	gettoken y x: varlist
	Chcktree `y'
	global S_eqs = `s(eqs)'
	global S_Ntrans = `s(Ntrans)'
	global S_treelevels  "`s(treelevels)'"
	forvalues t = 1/$S_Ntrans {
		global S_eqstr`t' = "`s(eqstr`t')'"
		global S_Nchoice`t' = `s(Nchoice`t')'
		local end = ${S_Nchoice`t'} - 1
		forvalues c = 0/`end' {
			global S_tr`t'choice`c' = "`s(tr`t'choice`c')'"
			global S_eqtr`t'c`c' = "`s(eqtr`t'c`c')'"
		}
	}
	forvalues eq = 1/$S_eqs {
		local treq`eq' = `s(treq`eq')'
	}
	global S_maxchoice = `s(maxchoice)'
	forvalues trans = 1/$S_Ntrans {
		local transvarsopt "`transvarsopt' x`trans'(varlist)"
		local transvars "`transvars' x`trans'"
	}
	
	syntax varlist [if] [in] [pw fw iw] , ///
	tree(string) [                        ///
	OFINTerest(varlist numeric max=1)     ///
	over(varlist numeric)                 ///
	Levels(string)                        ///
	Robust                                ///
	Cluster(varname)                      ///
	Level(integer $S_level)               ///
	Constraints(passthru)                 ///
	sd(numlist missingok)                 ///
	deltasd(string)                       /// 
	rho(numlist max=1 >=-.95 <=.95)       ///
	pr(numlist >= 0)                      ///
	mn(string)                            ///
	uniform                               ///
	draws(numlist max=1 >=1 integer)      ///
	drawstart(numlist max=1 >=1 integer)  ///
	noLOG                                 ///
	OR                                    ///
	`transvarsopt'                        ///
	* ]

// find the estimation sample	
	marksample touse 
	local transvars : list retokenize transvars
	local transvars : subinstr local transvars " " "' `", all
	local transvars "``transvars''"
	markout `touse' `ofinterest' `over' `transvars'
	qui count if `touse'
	if r(N) == 0 {
		di as error "no observations"
		exit 2000
	}
	
	if "`sd'" == "" & "`draws'`drawstart'" != "" {
		di as err "options draws(), and drawstart() can only be specified when sd() is specified"
		exit 198
	}
	if "`sd'" == "" & "`rho'" != "" {
		di as err "option rho() can only be specified when sd() is specified"
		exit 198
	}
	if "`ofinterest'" == "" & "`rho'" != "" {
		di as err "option rho() can only be specified when ofinterest() is specified"
		exit 198
	}
	if "`pr'" != "" & "`sd'" == "" {
		di as err "the pr() option can only be specified when the sd() option is specified"
		exit 198
	}
	if "`mn'" != "" & "`sd'" == "" {
		di as err "the mn() option can only be specified when the sd() option is specified"
		exit 198
	}
	if "`uniform'" != "" & "`sd'" == "" {
		di as err "the uniform option can only be specified when the sd() option is specified"
		exit 198
	}
	if "`mn'" != "" & "`pr'`uniform'" != "" {
		di as err "the mn(), pr(), and uniform options can not be specified together"
		exit 198
	}
	if "`pr'" != "" & "`mn'`uniform'" != "" {
		di as err "the mn(), pr(), and uniform options can not be specified together"
		exit 198
	}
	if "`deltasd'" != "" & "`sd'" == "" {
		di as err "the deltasd option cannot be specified without specifying the sd option"
		exit 198
	}
	
	local vars `ofinterest' `over'
	local doub : list dups vars
	if "`doub'" != "" {
		di as err "variables specified in ofinterest cannot be specied in over"
		exit 198
	}
	if "`over'" != "" & "`ofinterest'" == "" {
		di as err "the ofinterest() option needs to be specified when the over() option is spefied"
		exit 198
	}
	
	if "`over'" != "" {
		tempvar testvar
		qui gen `testvar' = .
		foreach var of varlist `over' {
			capture confirm variable _`ofinterest'_X_`var'
			if _rc {
				qui gen _`ofinterest'_X_`var' = `ofinterest'*`var'
			}
			else {
				qui replace `testvar' = `ofinterest'*`var'
				capture assert _`ofinterest'_X_`var' == `testvar'
				if _rc {
					di as err _`ofinterest'_X_`var' already defined
					exit 110
				}
			}
			local inter "`inter' _`ofinterest'_X_`var'"
		}
		qui drop `testvar'
	}
	
	local varlist "`varlist' `ofinterest' `inter'"
	local varlist : list uniq varlist
	
	local wtype `weight'
	local wtexp `"`exp'"'
	if "`weight'" != "" local wgt `"[`weight'`exp']"'  
	
	if "`cluster'" != "" { 
		local robust "robust"
		local clopt "cluster(`cluster')" 
	}
	
	if "`level'" != "" local level "level(`level')"
	local log = cond("`log'" == "", "noisily", "quietly") 
		
	mlopts mlopts, `options'
	
	local transvaropt ""
	forvalues i = 1/$S_Ntrans {
		local transvaropt "`transvaropt' x`i'(`x`i'')"
	}
	
	Parsemodel `varlist', `transvaropt'
	Starting `varlist' if `touse' `wgt'
	tempname init
	matrix `init' = r(init)
	local k_eform = r(df)

// parse sd option	
	local Nsd : word count `sd'
	if `Nsd' > 1 & `Nsd' != $S_eqs {
		di as err "When using the sd() option the number of standard deviations must either equal 1 or the number of equation ($S_eqs)"
		exit 198
	}
	if `Nsd' == 1 {
		local numsd = `sd'
		forvalues i = 2 / $S_eqs {
			local sd "`sd' `numsd'"
		}
	}
	
// parse deltasd option
	if "`deltasd'" != "" {
		gettoken sd_var deltasd : deltasd
		capture confirm numeric variable `sd_var'
		if _rc {
			di as err the first element in the deltasd option must be a numeric variable
			exit 198
		}
		unab sd_var : `sd_var'
		if `: word count deltasd' > 1 & `: word count deltasd' != $S_eqs {
			di as err "When using the deltasd() option the number of standard deviations must either equal 1 or the number of equation ($S_eqs)"
			exit 198	
		}
		if `: word count deltasd' == 1 {
			local numdelta = `deltasd'
			forvalues i = 2 / $S_eqs {
				local deltasd "`deltasd' `numdelta'"
			}
		}
	}
	
// parse the pr() option
	if "`pr'" != "" {
		tempname mpnts
		
		// This function creates equally spaced masspoints such that mean(e) = 0 & sd(e) = 1
		// Leaves these masspoints behind in $S_mpnts and matrix `mpnts'
		// Leaves pr behind in $S_pr
		// Leaves the sum of pr behind in local sum_pr
		mata masspoints()
		
		if abs(`sum_pr' - 1) > .01 {
			di as err "The probabilities in the pr() option must add up to 1"
			exit 198
		}
		
		// make matrix pretty for later display
		matrix rownames `mpnts' = "mass_point" "proportion"
		forvalues i = 1/ `:word count `pr'' {
			local coln = `"`coln' "point_`i'""'
		}
		matrix colnames `mpnts' = `coln'
	}
// parse the mn() option
	if "`mn'" != "" {
		local i = 0
		while "`mn'" != "" {
			local i = `i' + 1
			gettoken d mn : mn, pars(",")
			capture assert `: word count `d'' == 2
			if _rc {
				di as err "the mn() option should consist of multiple elements separated by commas"
				di as err "each elemen should consist of two numbers: a proportion and a mean"
				di as err "the `i'th element contains `: word count `d'' numbers"
				exit 198
			}
			gettoken p_temp m_temp : d
			capture assert `p_temp' > 0 & `p_temp' <1
			if _rc {
				di as err "the mn() option should consist of multiple elements separated by commas"
				di as err "each elemen should consist of two numbers: a proportion and a mean"
				di as err "the probability in the `i'th element contains a number smaller than 0 or larger than 1"
				exit 198				
			}
			capture confirm number `m_temp'  
			if _rc {
				di as err "the mn() option should consist of multiple elements separated by commas"
				di as err "each elemen should consist of two numbers: a proportion and a mean"
				di as err "the mean in the `i'th element is not a number"
				exit 198
			}
			local pr_mn "`pr_mn' `p_temp'"
			local m_mn "`m_mn' `m_temp'"
			gettoken comma mn : mn, pars(",")
		}
		local pr_mn : list retokenize pr_mn
		local m_mn : list retokenize m_mn
		if `i' < 2 {
			di as err "the mn() option should consist of multiple elements separated by commas"
			di as err "only `i' element was found"
			exit 198
		}
		if `: word count `: list dups m_mn'' != 0 {
			di as err "the mn() option should consist of multiple elements separated by commas"
			di as err "each elemen should consist of two numbers: a proportion and a mean"
			di as err "the means specified in the mn() option must be distinct"
			exit 198
		}
		
		tempname means_mn
		// This function shifts the means of the components such that the mean of e = 0
		// and creates standard deviations for the components that are equal such that sd(e) = 1
		// Leaves sd's behind in $S_sd_mn and matrix `means_mn'
		// Leaves pr_mn behind in $S_pr_mn
		// Leaves sd_mn behind in $S_m_mn
		// Leaves the sum of pr_mn behind in local sum_pr
		mata means_mn()		
		if `error_mn' {
			di as err "the proportions and means specified in the mn() option cannot produce a variable with a variance of 1"
			exit 198
		}

		if abs(`sum_pr' - 1) > .01 {
			di as err "The probabilities in the mn() option must add up to 1"
			exit 198
		}
		
		// make matrix pretty for later display
		matrix rownames `means_mn' = "mean" "sd" "proportion"
		forvalues i = 1/ `:word count `pr_mn'' {
			local coln = `"`coln' "component_`i'""'
		}
		matrix colnames `means_mn' = `coln'
	}

// parse uniform option
	global S_uniform `uniform'

// parse levels option	
	if "`levels'" != "" {
		Checklevel,                     ///
		    levels(`levels')            ///
		    treelevels($S_treelevels) ///
		    y(`y')
	}

// estimation	
	if "`sd'" == "" | "`sd'" == "0" {
		`log' ml model lf seqlogit_lf `s(mod)' `wgt' if `touse',          ///
			lf0(`r(df)' `r(ll_0)') maximize init(`init') search(off)  ///
			`robust' `clopt' `level' `mlopts' `stdopts' `modopts' `constraints'
		if "`sd'" == "0"{
			ereturn scalar sigma = `sd'
		}
	}
	else {
		global S_sigma "`sd'"
		global S_sd_var "`sd_var'"
		global S_deltasd "`deltasd'"
		if "`draws'" == "" local draws = 100
		if "`drawstart'" == "" {
			global S_drawstart = 15
		}
		else {
			global S_drawstart = `drawstart'
		}
		global S_draws = `draws'
		if "`rho'" != "" {
			global S_rho = `rho'
			qui sum `ofinterest' if `touse'
			global S_sdx = r(sd)
			global S_mx = r(mean)
			global S_ofinterest "`ofinterest'"
		}
		Parselikelihood
		`log' ml model lf seqlogit_uh_lf `s(mod)'  `wgt' if `touse',          ///
			lf0(`r(df)' `r(ll_0)') maximize init(`init') search(off)  ///
			`robust' `clopt' `level' `mlopts' `stdopts' `modopts' `constraints'
		ereturn local sigma `sd'
		if "$S_sd_var" != "" {
			ereturn local sd_var $S_sd_var 
			ereturn local sd_delta $S_deltasd
		}
		ereturn scalar draws = `draws'
		if "`rho'" != "" {
			ereturn scalar rho = `rho'
		}
		if "$S_pr" != "" {
			ereturn matrix mpnts `mpnts'
			ereturn local pr    $S_pr
			ereturn local strmpnts $S_mpnts
		}
		if "$S_pr_mn" != "" {
			ereturn matrix means_mn `means_mn'
			ereturn local sd_mn    $S_sd_mn
			ereturn local pr_mn    $S_pr_mn
			ereturn local m_mn     $S_m_mn	
			ereturn local opt_mn   `mn'
		}
		if "$S_uniform" != "" {
			ereturn local uniform "uniform"
		}
	}
	
	ereturn local cmd "seqlogit10"	
	ereturn local levels "`levels'"
	ereturn scalar k_eform = `k_eform'
	local k_cat : word count $S_treelevels
	ereturn scalar k_cat = `k_cat'
	ereturn local predict "seqlogit10_p"	
	
	ereturn scalar Ntrans = $S_Ntrans
	ereturn local treelevels "${S_treelevels}"
	ereturn scalar eqs = $S_eqs
	forvalues t = 1/$S_Ntrans {
		ereturn scalar Nchoice`t' = ${S_Nchoice`t'}
		ereturn local eqstr`t' = "${S_eqstr`t'}"
		local end = ${S_Nchoice`t'} - 1
		forvalues c = 0/`end' {
			if `c' != 0 {
				ereturn scalar eqtr`t'c`c' = ${S_eqtr`t'c`c'}
			}
			ereturn local tr`t'choice`c' "${S_tr`t'choice`c'}"
		}
	}
	forvalues eq = 1/$S_eqs {
		ereturn scalar treq`eq' = `treq`eq''
	}
	ereturn local ofinterest "`ofinterest'"
	ereturn local over "`over'"
	ereturn local cmdline `"seqlogit `: list retokenize 0'"'
	
	Display, `level' `diopts' `or'
end

/*-------------------------------------------------- parse the tree */
program define Parsetree, sclass
	/*list of all levels*/
	local treelevels : subinstr local 0 ":" " ", all
	local treelevels : subinstr local treelevels "," " ", all
	local treelevels : list uniq treelevels
	sreturn local treelevels "`treelevels'"
	
	/*count number of transitions*/
	tokenize `"`0'"', parse(",")
	local k = 0
	local i = 1
	while "``i''" != "" {
		if "``i''" != "," {
			local ++k
			local tr`k' "``i''"
		}
		local ++i
	}
	sreturn local Ntrans = `k'

	/*choices and choices per transition*/
	local maxchoice = 0
	local equ = 1
	forvalues i = 1/`k' {
		tokenize `"`tr`i''"', parse(:)
		local j = 0 
		local c = 1
		while "``c''" != "" {
			if "``c''" != ":" {
				local `c' : list retokenize `c'
				sreturn local  tr`i'choice`j' "``c''"
				if `j' != 0 {
					sreturn local eqtr`i'c`j' "`equ'"
					local eqstr`i' "`eqstr`i'' `equ'"
					sreturn local treq`equ' = `i'
					local ++equ
				}
				sreturn local eqstr`i' "`eqstr`i''"
				local ++j
			}
			local ++c
		}
		sreturn local Nchoice`i' = `j'
		local maxchoice = max(`maxchoice', `j')
	}
	sreturn local maxchoice = `maxchoice' 
	sreturn local eqs = `equ' - 1
end


/*-------------------------------------------------- Display the tree */
program define Displaytree
	di
	di as txt "Transition tree:"
	di
	forvalues i = 1/`s(Ntrans)' {
		local choices "`s(tr`i'choice0)'"
		local end = `s(Nchoice`i')' -1
		forvalues j = 1/`end' {
			local choices "`choices' : `s(tr`i'choice`j')'"
		}
		di as txt "Transition `i':" _col(15) as result "`choices'"
	}
	di
end


/*-------------------------------------------------- Check the tree */
program define Chcktree
	syntax varname
	
	/*Check whether all values in tree also occur in varlist and vice versa*/
	local treelevels "`s(treelevels)'"
	qui levelsof `varlist', local(datalevels)
		
	local ok = 1
	local intree : list treelevels - datalevels
	if "`intree'" != "" {
		di as error "Values " as result "`intree'" as err " specified in the tree option"
		di as error "are not part of variable " as result "`varlist'."
		local ok = 0
	}
	local indata : list datalevels - treelevels
	if "`indata'" != "" {
		di as error "Values " as result "`indata'" as err " of variable " as result "`varlist'" 
		di as error "are not specified in the tree option."
		local ok = 0
	}
	if !`ok' exit 198
	
	// first transition must involve all levels
	local end = `s(Nchoice1)' -1
	forvalues i = 0/`end' {
		local levs1 "`levs1' `s(tr1choice`i')'"
	}
	local intree : list treelevels - levs1
	
	if "`intree'" != "" {
		local k : word count `intree'
		local s = cond(`k' >= 2, "s", "")
		local are = cond(`k' >= 2, "are", "is")
		di as err "the first transition must involve all values of variable " as result "`varlist'"
		di as err "the missing value`s' `are' " as result "`intree'"
		exit 198
	}
	
	/*Check if all levels can be achieved through one and only one route*/
	forvalues i = 1/`s(Ntrans)' {
		local end = `s(Nchoice`i')' -1
		forvalues j = 0/`end' {
			local k : word count `s(tr`i'choice`j')'
			if `k' == 1 local final "`final' `s(tr`i'choice`j')'"
		}
	}
		
	local dups : list dups final
	if "`dups'" != "" {
		local dups : list uniq dups
		di as error "Values " as result "`dups'" as err " can be reached through multiple paths."
		local ok = 0
	}
		
	local leftover : list treelevels - final
	if "`leftover'" != "" {
		di as error "No path in the tree leads to values " as result "`leftover'" as err "."
		local ok = 0
	}
	if !`ok' exit 198
	
end

/*-------------------------------------------------- check level() */
program define Checklevel
	syntax, levels(string) treelevels(string) y(string)
	local rest "`treelevels'"
	while "`levels'" != "" {
		gettoken exp levels : levels, parse(",")
		gettoken level value : exp, parse("=")
		if !`: list level in treelevels' {
			di as err ///
			"level `level' specified in option levels() was not found in variable `y'"
			exit 198
		}
		local rest : list rest - level
		gettoken comma levels : levels, parse(",")
	}
	if "`rest'" != "" {
		di as err ///
		"levels `rest' were present in variable `y' but not specified in option levels()"
		exit 198
	}
end

/*-------------------------------------------------- parse the model */
program define Parsemodel, sclass
	forvalues i = 1/$S_Ntrans {
		local opts "`opts' x`i'(varlist)"
	}
	syntax varlist	, [`opts']
	gettoken y x : varlist
	local y1 "`y'="
	local eq = 1

	forvalues i = 1/$S_Ntrans {
		local tr`i'choice0 = "${S_tr`i'choice0}"
		local ref : subinstr local tr`i'choice0 " " "_", all
		local end = ${S_Nchoice`i'} - 1
		forvalues j = 1/`end' {
			local tr`i'choice`j' = "${S_tr`i'choice`j'}"
			local choice : subinstr local tr`i'choice`j' " " "_", all
			local mod "`mod' (_`choice'v`ref': `y`eq++''`x' `x`i'')"
		}
	}
	sreturn local mod "`mod'"	
end

/*------------------------------------------------ parse likelihood */
program define Parselikelihood
	foreach lev in $S_treelevels {
		forvalues t = 1/$S_Ntrans{
			local end = ${S_Nchoice`t'} - 1
			forvalues c = 0/`end'{
				local temp ${S_tr`t'choice`c'}
				if (`: list lev in temp') {
					local c`lev' "`c`lev'' `c'"
					local t`lev' "`t`lev'' `t'"
				}
			}
		}
		global S_c`lev' "`c`lev''"
		global S_t`lev' "`t`lev''"
	}
end

/*-------------------------------------------------- starting values */
program define Starting, rclass
	syntax varlist [if] [pw fw iw]
	marksample touse
	
	if "`weight'" != "" local wgt `"[`weight'`exp']"'
	
	gettoken y x : varlist
	
	/*define group at risk*/
	forvalues i = 1/$S_Ntrans {
		local end = ${S_Nchoice`i'} - 1
		forvalues j = 0/ `end' {
			local in`i' "`in`i'' ${S_tr`i'choice`j'}"	
		}
		local in`i' : list retokenize in`i'
		local in`i' : subinstr local in`i' " " "| `y' == ", all
	}
	
	/*create dependent variables*/
	forvalues i = 1/$S_Ntrans {
		tempvar tr`i'
		qui gen byte `tr`i'' = .
		local end = ${S_Nchoice`i'} -1
		forvalues j = 0/`end'{
			local tr`i'choice`j' = "${S_tr`i'choice`j'}"
			local choice : subinstr local tr`i'choice`j' " " "| `y' == ", all
			qui replace `tr`i'' = `j' if (`y' == `choice') & (`y' == `in`i'')
		}
	}
	/*estimate (m)logits*/
	tempname b init ll0 df
	di as txt "Computing starting values for: "
	di
	if $S_Nchoice1 == 2 {
		di as txt "Transition " as result "1"
		qui logit `tr1' `x' if `touse' `wgt'
		matrix `b' = e(b)
		local tr1choice0 = "$S_tr1choice0"
		local tr1choice1 = "$S_tr1choice1"
		local ref : subinstr local tr1choice0 " " "_", all
		local choice : subinstr local tr1choice1 " " "_", all
		matrix coleq `b' = _`choice'v`ref'
		matrix `init' = `b'
		scalar `ll0' = e(ll_0)
	}
	else{
		di as txt "Transition " as result "1"
		qui mlogit `tr1' `x' if `touse' `wgt', base(0)
		matrix `b' = e(b)
		matrix `b' = `b'[1,"1:"]
		local tr1choice0 = "$S_tr1choice0"
		local tr1choice1 = "$S_tr1choice1"
		local ref : subinstr local tr1choice0 " " "_", all
		local choice : subinstr local tr1choice1 " " "_", all
		matrix coleq `b' = _`choice'v`ref'		
		matrix `init' = `b'
		local end = $S_Nchoice1 - 1
		forvalues j = 2/`end'{
			matrix `b' = e(b)
			matrix `b' = `b'[1,"`j':"]
			local tr1choice`j' = "${S_tr1choice`j'}"
			local choice : subinstr local tr1choice`j' " " "_", all
			matrix coleq `b' = _`choice'v`ref'
			matrix `init' = `init', `b'
		}
		scalar `ll0' = e(ll_0)
	}
	forvalues i = 2/$S_Ntrans {
		if ${S_Nchoice`i'} == 2 {
			di as txt "Transition " as result "`i'"	
			qui logit `tr`i'' `x' if `touse' `wgt'
			matrix `b' = e(b)
			local tr`i'choice0 = "${S_tr`i'choice0}"
			local tr`i'choice1 = "${S_tr`i'choice1}"
			local ref : subinstr local tr`i'choice0 " " "_", all
			local choice : subinstr local tr`i'choice1 " " "_", all
			matrix coleq `b' = _`choice'v`ref'
			matrix `init' = `init', `b'
			scalar `ll0' = `ll0' + e(ll_0)
		}
		else{
			di as txt "Transition " as result "`i'"
			qui mlogit `tr`i'' `x' if `touse' `wgt', base(0)
			local end = ${S_Nchoice`i'} - 1
			local tr`i'choice0 = "${S_tr`i'choice0}"
			local ref : subinstr local tr`i'choice0 " " "_", all
			forvalues j = 1/`end'{
				matrix `b' = e(b)
				matrix `b' = `b'[1,"`j':"]
				local tr`i'choice`j' = "${S_tr`i'choice`j'}"
				local choice : subinstr local tr`i'choice`j' " " "_", all
				matrix coleq `b' = _`choice'v`ref'
				matrix `init' = `init', `b'
			}
			scalar `ll0' = `ll0' + e(ll_0)
		}
	}
	return matrix init = `init'
	return scalar ll_0 = `ll0'
	return scalar df = $S_eqs 
end

/*-------------------------------------------------- display the results */
program Display
	syntax [, Level(int $S_level) *]
	local diopts "`options'"
	if `level' < 10 | `level' > 99 local level = 95
	ml display, level(`level') `or' `diopts'
	capture confirm matrix e(mpnts)
	if !_rc {
		di as txt "Distribution of the standardized unobserved variable is:"
		matlist e(mpnts), underscore
		di _n
	}
	capture confirm matrix e(means_mn)
	if !_rc {
		di as txt "Distribution of the standardized unobserved variable is:"
		matlist e(means_mn), underscore
		di _n
	}
	if "`e(uniform)'" != "" {
		di as txt "The standardized unobserved variable follows a uniform distribution"
		di _n
	}
	if "`e(sigma)'" != "" {
		tempname b 
		matrix `b' = e(b)
		local eqs : coleq `b'
		local eqs : list uniq eqs
		local sd "`e(sigma)'"
		if "`e(sd_var)'" == "" {
			di as txt "The effect of the standardized unobserved variable is fixed at:"
			di as txt "{hline 12}{c TT}{hline 7}"
			di as txt "equation {col 13}{c |} sd" 
			di as txt "{hline 12}{c +}{hline 7}"
			forvalues i = 1/`e(eqs)' {
				di as txt "`: word `i' of `eqs'' {col 13}{c |} " as result `: word `i' of `sd''
			}
			di as txt "{hline 12}{c BT}{hline 7}"
		}
		else {
			di as txt "The effect of the standardized unobserved variable is fixed at:"
			di as txt "{hline 12}{c TT}{hline 27}"
			di as txt "equation {col 13}{c |} sd" 
			di as txt "{hline 12}{c +}{hline 27}"
			forvalues i = 1/`e(eqs)' {
				di as txt "`: word `i' of `eqs'' {col 13}{c |} " as result `: word `i' of `sd'' " + " `: word `i' of `e(sd_delta)'' " * `e(sd_var)'"
			}
			di as txt "{hline 12}{c BT}{hline 27}"
		}
	}
	if "`e(rho)'" != "" {
		di as txt "The initial correlation between the unobserved variable and `e(ofinterest)' is fixed at " as result `e(rho)'
	}
end


/*----------- computes mass points when the pr() option is specified*/
mata:
void masspoints() {
	pr = strtoreal(tokens(st_local("pr")))

	// initial guesses for mpnts
	// centered around 0, each category 1 appart
	Np = length(pr)
	mpnts = (1..Np):- (Np+1)/2


	// pr*mpnts' is the mean
	mpnts = mpnts :- (pr*mpnts')

	// pr*(mpnts :* mpnts)' is the variance
	mpnts = mpnts :/ sqrt(pr*(mpnts :* mpnts)')
	
	// return results
	str_mpnts = strofreal(mpnts[1])
	for(i=2; i<= length(mpnts); i++){
		str_mpnts = str_mpnts + " " + strofreal(mpnts[i])
	} 
	st_global("S_mpnts", str_mpnts)
	st_global("S_pr", st_local("pr"))
	st_matrix(st_local("mpnts"), mpnts \ pr)
	
	// return sum of pr to check if adds up to 1
	st_local("sum_pr", strofreal(sum(pr)))
}
end		
		
/*----------- computes sd of components when the mn() option is specified*/
mata:
void means_mn() {
	pr_mn = strtoreal(tokens(st_local("pr_mn")))
	m_mn = strtoreal(tokens(st_local("m_mn")))

	// pr_mn*m_mn' is the mean
	m_mn = m_mn :- (pr_mn*m_mn')

	// rowsum((means_mn:*means_mn :+ sd_mn:*sd_mn) :* pr_mn ) is the variance

	SD = sqrt(1:-rowsum(pr_mn*(m_mn:*m_mn)'))
	if (SD != . & SD != 0) {
		sd_mn = J(1,cols(pr_mn), SD)

		// return results
		str_sd_mn = strofreal(SD)
		for(i=2; i<= length(pr_mn); i++){
			str_sd_mn = str_sd_mn + " " + strofreal(SD)
		}

		st_global("S_sd_mn", str_sd_mn)
		st_global("S_pr_mn", st_local("pr_mn"))
		st_global("S_m_mn", st_local("m_mn"))
		st_matrix(st_local("means_mn"), m_mn \ sd_mn \ pr_mn)

		// return sum of pr to check if adds up to 1
		st_local("sum_pr", strofreal(sum(pr_mn)))
		st_local("error_mn", strofreal(0))
	}
	else {
		st_local("error_mn", strofreal(1))
	}
}
end		
		
