*! version 3.0 10jul2019, Benjamin R. Shear and sean f. reardon

* requires hetop_lf.ado

 capture program drop hetop
 program define hetop , eclass
	
	version 13.1

	syntax namelist(min=2 max=2) , 		/// arg1 is the group id variable; arg2 is the stem for the category counts variable
		NUMCats(integer)				/// technically redundant but a good check that there are the expected number of categories
		[ 											///
			MODtype(string) 						/// "hetop" or "homop"
			IDentify(string)						/// "sums" or "refgroup" or "cuts"
			SETRef(integer 0) 						/// group to use as reference group, if identify == refgroup
			PHOP(string)							/// 0/1 indicator; constrain groups with `phop'==1 to have a common SD, can optionally specify "mean"
			SETCuts(numlist ascending min=1 max=9)	/// set known cut scores
			PKVALS(varname numeric max=1) 			/// name of variable containing group proportions in population; default is to use observed group proportions
			STARTFRom(namelist max=1)				/// matrix with desired starting values
			KAPPA(integer 1)					 	/// use a specified value of kappa in calculations
			SAVE(string)							/// if specified, save estimates as new variables in sheet with names like mstarstring; optional to include se's
			ADDCONStraints(string)					/// use pre-defined constraints
			MINSIZE(integer 1)						/// drop groups smaller than this
			INITVALS 								/// compute initial values
			GAPS 									/// return matrix of gaps and SEs of gaps
			NOIsily		 							/// display -oglm- output during estimation
			HOMOP									/// easier way to specify a homop model
			CSD(real -1)							/// constrain common SD to this value for HOMOP models; default will change to 1 if left as -1
			*										/// ML options
		]

	preserve
	
	tokenize `namelist'
	local grpid `1'
	local catname `2'

	mlopts mlopts , `options'
	
	// set default options:

	if "`modtype'" == "" {
		if "`homop'" == "homop"	local modtype "homop"
		if "`homop'" == ""		local modtype "hetop"
	}
	if "`modtype'" == "hetop" & "`homop'" == "homop" {
		noi di in red "WARNING: modtype(hetop) and homop options are not " ///
		"consistent. homop model will be fit."
		local modtype "homop"
	}
	if `setref' > 0 & "`identify'" == ""	local identify "refgroup"
	if "`identify'" == ""					local identify "refgroup"
	local ref_group "n"		// default, only gets reset if identify=refgroup
	
	// evaluate and parse syntax
	
	* if setcuts is specified, ignore any other identification options
	if "`setcuts'" != "" {
		
		local identify "setcuts"

		local num_setcuts : word count `setcuts'
		if `=`numcats'-1' != `num_setcuts' {
			noi di as error "number of cutscores != K-1"
			error 499
		}

		forv i = 1/`num_setcuts' {
			local set_c`i' : word `i' of `setcuts'
		}

		* maybe add if `num_setcuts' == 1 {local modtype "homop"}

	}

	* verify that id variable integer > 0 and uniquely identifies groups
	qui capture assert `grpid' == int(`grpid')
	qui sum `grpid'
	if r(min) < 1 | _rc != 0 {
		noi di in red "ID variable must be positive integer values only"
		error 499
	}

	cap bys `grpid' : assert _N==1
	if _rc != 0 {
		noi di in red 	"ID variable `grpid' does not uniquely "///
						"identify observations"
		error 499
	}
	
	* can't do HETOP with fewer than 3 categories
	if "`modtype'" == "hetop" & `numcats' < 3 {
		noi di in red "ERROR: must have > 2 categories to fit HETOP model."
		error 499
	}

	* verify that variable save names not taken
	if "`save'" != "" {
		parse_save_opt `save'
		local newvarnames "`s(allvarnames)'"
		foreach v in `newvarnames' {
			cap confirm variable `v' , exact
			if _rc == 0 {
				noi di in red "variable `v' exists but save option " ///
					"specified to use this name. please rename `v' or alter " ///
					"save variable name options."
				error 499
			}		
		}		
	}

	* confirm identification
	if inlist("`identify'", "sums", "refgroup", "cuts", "setcuts") == 0 {
		noi di in red "ERROR: identify() option must be 'sums', 'refgroup'," ///
		" or 'cuts'."
		error 499
	}
	
	* confirm modeltype selection
	if inlist("`modtype'", "hetop", "homop") == 0 {
		noi di in red "ERROR: modtype() must be 'hetop' or 'homop'."
		error 499
	}
	
	* confirm phopvar is only 0 and 1 and not specified with homop option
	* ignore phop if fitting model with a single group
	if _N == 1 {
		if "`phop'" != "" {
			noi di in yellow "NOTE: only 1 group; ignoring PHOP variable."
		}
		local phop ""
	}
	if "`phop'" != "" & "`modtype'" == "homop" {
		noi di in red "WARNING: phop option with homop model is redundant. " ///
			"Ignoring phop variable."
		local phop ""
	}
	if "`phop'" != "" {
		parse_phop_opt `phop'
		local phop `s(phopvar)'
		local phop_mean `s(phop_mean)'
		qui count if (`phop'!=0 & `phop'!=1)
		if r(N) > 0 {
			noi di in red "ERROR: phop variable can only contain 0 or 1."
			error 499			
		}	
	}

	* can't specify STARTFROM and INITVALS
	if "`startfrom'" != "" {
		if "`initvals'" != "" {
			noi di in red "ERROR: cannot specify both startfrom() and initvals."
			error 499
		}
		cap confirm matrix `startfrom'
		if _rc != 0 {
			noi di in red "ERROR: `startfrom' must be a matrix."
			exit _rc
		}
	}
			
	// check and clean frequency count data
	
	* replace any missing frequencies with 0s
	qui foreach var of varlist `catname'* {
		qui count if `var' == .
		if r(N) > 0 noi di in yellow ///
			"NOTE: replaced " r(N) " missing frequencies in `var' with 0."
		replace `var' = 0 if `var' == .
	}
	
	* verify category name & number of category variables match
	unab vars : `catname'*
	local numcatsfound = `: word count `vars''
	if `numcatsfound' != `numcats' {
		noi di in red 	"ERROR: Number of categories found does not match " ///
						"number supplied to numcats."
		error 499
	}
	local numcuts = `numcats' - 1

	// restrict sample and issue warnings about existence
	
	tempvar Nk
	egen `Nk' = rowtotal(`catname'*)	
	
	* drop groups with no observations or that are below `minsize' 
	qui count if `Nk' < `minsize'	// `minsize'=1 by default
	if r(N) > 0 noi di in red _n "WARNING: dropping " r(N) ///
		" groups with N<`minsize'"
	qui drop if `Nk' < `minsize'
	
	* check for categories with no observations across entire sample
	foreach var of varlist `catname'* {
		qui sum `var'
		if (r(sum) <= 0 | r(sum) == .) & "`identify'" != "setcuts" {
			noi di in red "ERROR: `var' contains no observations (possibly" ///
			" after removing groups below the minsize() threshold."		///
			" All categories must have at least 1 observation"	///
			" in the total sample."
			error 499
		}
		if (r(sum) <= 0 | r(sum) == .) & "`identify'" == "setcuts" {
			noi di in red "WARNING: at least one category has no " ///
			"observations, but estimation with fixed cut scores will proceed."
		}		
	}	
	
	* issue warning about groups with data in 2 cells for HETOP
	tempvar num0
	egen `num0' = anycount(`catname'*) , val(0)
	qui count if `num0' == (`numcats'-2)
	if "`modtype'" == "hetop" & r(N) > 0 {
		di in red "WARNING: some groups have data in only 2 " ///
		"categories and ML estimates may not be properly defined."
	}
	
	* now issue warnings/errors for groups with data in only 1 category
	qui count if `num0' == (`numcats'-1)
	
	* error for 1-count groups with only 2 categories and HOMOP
	if "`modtype'" == "homop" & r(N) > 0 & `numcats' == 2 {
		noi di in red "ERROR: cannot fit HOMOP model when some groups have " ///
			"data in only 1 category and numcats=2. There are " r(N) ///
			" such groups."
		error 499
	}
	else if r(N) > 0 {
		// this scenario possible with PHOP
		noi di in red "WARNING: some groups have data in only 1 " ///
		"category and ML estimates may not be properly defined."
	}
		

					// !! sample is now finalized !!  //

	
	// create additional variables and subset to analytic sample
	
	* sort by grpid, restrict variables
	sort `grpid'
	qui sum `grpid'
	local K = r(N)		// number of groups
	keep `grpid' `catname'* `pkvals' `Nk' `phop'
	sort `grpid'	
	
	* create pk values if none are supplied
	if "`pkvals'" == "" {
		tempvar pk
		qui sum `Nk'
		gen double `pk' = `Nk' / r(sum)
		local pkvals "`pk'"
		noi di in yellow "NOTE: no pk values specified; " ///
			"using nk/N as proportions."
	}

	sort `grpid'
	
	* these will be used below

	tempname P nk nkHI
	mkmat `pkvals' , matrix(`P')
	matrix `P' = `P''
	mkmat `Nk' , matrix(`nk')
	matrix `nk' = `nk''
	matrix `nkHI' = J(1 , `K' , 0)
	forv i = 1/`K' {
		matrix `nkHI'[1,`i'] = 1/`nk'[1,`i']
	}
	
	// set up identifying constraints
	
	if "`identify'" == "refgroup" {

		* check specified ref group or automatically generate one
		if `setref' == 0 {			
			noi di in yellow "NOTE: no reference group (or 0) specified; " ///
				"automatic group will be specified."
			qui get_ref , refrank(1) catname(`catname') grpid(`grpid') ///
							numcats(`numcats')
			local ref_group = r(refid)
		}

		else {
			qui count if `grpid' == `setref'
			if r(N) != 1 {
				noi di "specified reference group `setref' not found"
				error 499
			}
			local ref_group = `setref'
			noi di in yellow "NOTE: user specified `setref' as reference group."
		}
	}
	else if "`identify'" == "cuts" {

		noi di in yellow "NOTE: setting cut scores for model identification."

		* if only 1 cut score, or HOMOP fix to 0
		if `numcats' == 2 & "`modtype'" == "homop" {
			constraint free
			constraint `=r(free)' [cut1]_cons = 0
			local cutconstraints "`=r(free)'"
		}
		else if `numcats' > 2 & "`modtype'" == "homop" {
			constraint free
			constraint `=r(free)' [cut2]_cons = 0
			local cutconstraints "`=r(free)'"
		}
		else {
			* if 2 or more and HETOP, fix to -1 and 0
			constraint free
			constraint `=r(free)' [cut1]_cons = -1
			local cutconstraints "`=r(free)'"
			constraint free
			constraint `=r(free)' [cut2]_cons = 0
			local cutconstraints "`cutconstraints' `=r(free)'"			
		}

	}
	else if "`identify'" == "sums" {
		
		noi di in yellow "NOTE: using constraint on sum of estimates " ///
			"to identify model."
		
		qui levelsof `grpid' , local(grpconstraints)

		local w1 `: word 1 of `grpconstraints''
		local mnconstraints "`=`P'[1,1]' * [mean]:`w1'.`grpid'"
		local sdconstraints "`=`P'[1,1]' * [lnsigma]:`w1'.`grpid'"
		
		forv i = 2/`K' {
			
			local w1 `: word `i' of `grpconstraints''
			local mnconstraints "`mnconstraints' + `=`P'[1,`i']' * [mean]:`w1'.`grpid'"
			local sdconstraints "`sdconstraints' + `=`P'[1,`i']' * [lnsigma]:`w1'.`grpid'"
		
		}

		local mnconstraints "`mnconstraints' = 0"
		local sdconstraints "`sdconstraints' = 0"

		constraint free
		local pmc = r(free)
		constraint `pmc' `mnconstraints'
		
		if "`modtype'" == "hetop" {
			constraint free
			local smc = r(free)
			constraint `smc' `sdconstraints'
		}
		
		local sumconstraints "`pmc' `smc'"
	}
	else if "`identify'" == "setcuts" {

		local cutconstraints ""
		forv i = 1/`=`numcats'-1' {
			constraint free
			constraint `=r(free)' [cut`i']_cons = `set_c`i''
			local cutconstraints "`cutconstraints' `=r(free)'"
		}

	}
	***
	
	* add phop constraints if phop indicator supplied
	
	if "`phop'" != "" & "`modtype'" == "hetop" {
		
		qui count if `phop' == 1
		if r(N) == _N {
			noi di in red "WARNING: Constant `phop' means this is a HOMOP model " ///
				"and should probably be respecified."
		}
		qui count if `phop' == 0
		if r(N) == _N {
			noi di in red "WARNING: `phop'=0 for all observations. Model is " ///
				"equivalent to HETOP and will ignore `phop'."
			local phop ""
			local phop_mean = 0
		}
		
		if "`phop'" != "" {
			
			qui levelsof `grpid' if `phop' == 1 , local(grpconstraints)
			qui count if `phop' == 1
			local numconstraints = r(N) - 1
			local grpconstraints "`grpconstraints'"
			
			forv i = 1/`numconstraints' {
				
				local w1 `: word `i' of `grpconstraints''
				local w2 `: word `=`i'+1' of `grpconstraints''
				capture constraint free
				
					if _rc != 0 {
						noi di in red "ERROR: attempting to set too many " ///
							"constraints with the phop command. " ///
							"May need to use an alternative model."
						error _rc
						exit
					}
				
				local smc = r(free)
				constraint `smc' [lnsigma]:`w1'.`grpid' = [lnsigma]:`w2'.`grpid'
				local phopconstraints "`phopconstraints' `smc'"
				
			}				
		}

		if "`phop_mean'" == "1" {

			qui count if `phop' == 1
			
			if r(N) < _N {

				// define extra row of Cns matrix for the mean constraint

				tempname cnsaddrow
				tempvar phopfree_cns
				qui g double `phopfree_cns' = 0
				qui count if `phop' == 0
				scalar sumwt = 1/`r(N)'
				qui replace `phopfree_cns' = -1*scalar(sumwt) if `phop'==0
				qui sum `grpid' if `phop' == 1
				qui replace `phopfree_cns' = 1 if `grpid' == r(min)
				qui mkmat `phopfree_cns' , mat(`cnsaddrow')
				mat `cnsaddrow' = `cnsaddrow''

				tempname cnsaddrow_l cnsaddrow_r
				mat `cnsaddrow_l' = J(1,`K',0)
				mat `cnsaddrow_r' = J(1,`=`numcuts'+1',0)
				mat `cnsaddrow' = `cnsaddrow_l', `cnsaddrow', `cnsaddrow_r'

				local cnsaddrow_true = 1

			}
		}
	}
	*****


	****************************************************************************
	* set up equations and globals for hetop_lf, run -ml-

	local eq1label mean
	local eq2label lnsigma
	
	unab vlist : `catname'*
	local vlist : subinstr local vlist "`catname'" "" , all
	numlist "`vlist'" , sort
	local j=1
	foreach i in `r(numlist)' {
		global FW_`j' "`catname'`i'"
		local j=`j'+1
	}

	* equation for means

	local eqs (`eq1label':ib`ref_group'.`grpid', noconstant)
	ereturn local mean_eq "(`eq1label':ib`ref_group'.`grpid', noconstant)"

	* equation for ln(SD)
	if "`modtype'" == "homop" {
		if "`setcuts'" == "" {
			global fixedsd = 1
			if `csd' < 0 local csd = 1
			global clsd = `=ln(`csd')'
			local num_b_parms = `=`K'+`numcuts''
		}
		else {
			if `num_setcuts' == 1 {
				global fixedsd = 1
				if `csd' < 0 local csd = 1
				global clsd = `=ln(`csd')'
				local num_b_parms = `=`K'+`numcuts''		
			}
			else {
				if `csd' < 0 {
					local csd = 1
					global fixedsd = 0
					local eqs 				 "`eqs' (`eq2label': )"
					ereturn local lnsigma_eq "(`eq2label': )"
					local num_b_parms = `=`K'+1+`numcuts''
				}
				else {
					global fixedsd = 1
					global clsd = `=ln(`csd')'
					local num_b_parms = `=`K'+`numcuts''
				}
			}
		}
	}
	else if "`modtype'" == "hetop" {
		local csd = 1
		global fixedsd = 0

		local eqs 		   "`eqs' (`eq2label':ib`ref_group'.`grpid', noconstant)"
		ereturn local lnsigma_eq "(`eq2label':ib`ref_group'.`grpid', noconstant)"

		local num_b_parms = `=2*`K'+`numcuts''
	}

	* cut score equations
	forval i = 1/`numcuts' {
		local eqs "`eqs' (cut`i':)"
	}

	local allconstraints ///
		`refgroup_constraints' `sumconstraints' `phopconstraints' ///
		`cutconstraints' `homopconstraints' `addconstraints' 

	if "`allconstraints'" != "" | "`cnsaddrow_true'" != "" {

		// set up Cns constraints matrix

		tempname cnsb cnsV cnsmat

		local cnsb_m_names
		local cnsb_s_names
		local cnsb_c_names

		qui levelsof `grpid' , local(grpid_levels)

		// note: names must reflect the ib`refgroup' equation in order to 
		// correctly set constraints in makecns
		foreach lev in `grpid_levels' {
			if "`lev'" != "`ref_group'" {
				local cnsb_m_names `cnsb_m_names' `eq1label':`lev'.`grpid'
			}
			else {
				local cnsb_m_names `cnsb_m_names' `eq1label':`lev'b.`grpid'
			}
		}
		foreach lev in `grpid_levels' {
			if "`lev'" != "`ref_group'" {
				local cnsb_s_names `cnsb_s_names' `eq2label':`lev'.`grpid'
			}
			else {
				local cnsb_s_names `cnsb_s_names' `eq2label':`lev'b.`grpid'
			}
		}
		forv i = 1/`numcuts' {
			local cnsb_c_names `cnsb_c_names' cut`i':_cons
		}

		// dummy solutions
		if "`modtype'" == "hetop" {
			mat `cnsb' = J(1,`num_b_parms',0)
			mat colnames `cnsb' = `cnsb_m_names' `cnsb_s_names' `cnsb_c_names' 
		}
		else if "`modtype'" == "homop" {
			mat `cnsb' = J(1,`num_b_parms',0)
			if `num_b_parms' == `=`K'+`numcuts'' {
				mat colnames `cnsb' = `cnsb_m_names' `cnsb_c_names' 
			}
			else if `num_b_parms' == `=`K'+1+`numcuts'' {
				mat colnames `cnsb' = `cnsb_m_names' `eq2label':_cons `cnsb_c_names' 
			}
		}

		mat `cnsV' = `cnsb''*`cnsb'
		ereturn post `cnsb' `cnsV'
		
		makecns `allconstraints'
		mat `cnsmat' = e(Cns)

		// add extra phop,mean row if necessary
		if "`cnsaddrow_true'" == "1" {
			mat `cnsmat' = `cnsmat' \ `cnsaddrow'
		}

		local constraintcommand "constraints(`cnsmat')"

	}

	****************************************************************************
	* NOTES to user
	
	if "`modtype'" == "hetop" {
		
		if "`phop'" != "" di in yellow "NOTE: fitting heteroskedastic " ///
			"ordered probit model with constraints in `phop'."
		
		if "`phop'" == "" di in yellow "NOTE: fitting heteroskedastic " ///
			"ordered probit model."
		
		*local scale_equation "hetero(ib`ref_group'.`grpid')"
	
	}
	
	else if "`modtype'" == "homop" {
		
		di in yellow "NOTE: fitting homoskedastic ordered probit model " ///
			"with common ln(SD) set to `=ln(`csd')'"

	}
			
	di in yellow "NOTE: user specified --`grpid'-- as group id variable."
	di in yellow "NOTE: user specified --`catname'*-- as category variables."
	di in yellow "NOTE: user specified `numcats' categories."
	if "`initvals'" != "" {
		di in yellow "NOTE: custom starting values will be used."
	}

	****************************************************************************
	* starting values

	tempname initvalsmat
	if "`startfrom'" != "" {
		matrix `initvalsmat' = `startfrom'
	}
	else {
		di in yellow "calculating initial values..."
		get_initial_values , grpid(`grpid') refgroup(`ref_group') ///
					catname(`catname') numgrps(`K') modtype(`modtype') ///
					numcuts(`numcuts') weighttype(iweight) ///
					identify(`identify') ///
					setcuts(`setcuts') `initvals'
		mat `initvalsmat' = r(initvalsmat)
	}
	local startvalcall "init(`initvalsmat', skip)"

	****************************************************************************
	* estimate model

	* get total sample size
	qui sum `Nk'
	local totaln = r(sum)

	* workaround to estimate fixed cut score model with single group
	* warning: single-group estimation not recommended
	if _N == 1 {
		noi di in red "WARNING: only 1 group used for estimation."
		qui expand 2
		qui foreach var of varlist `catname'* {
			replace `var' = `var'/2
		}
		local docollapse 1
	}
	
	di in yellow "...estimating model..."

	capture `noisily' ml model lf hetop_lf `eqs' , ///
		maximize ///
		`constraintcommand' ///
		`startvalcall' ///
		`mlopts' ///
		obs(`totaln') ///
		wald(0)
	
	if "`docollapse'" == "1" {
		qui collapse (sum) `catname'*  (mean) `Nk' `pk' , by(`grpid')
	}
	
	local numcuts2 `numcuts'
	local numcuts3 `numcuts'
	ereturn scalar k_aux = `numcuts2'
	ereturn scalar k_exp = `numcuts3'
	ereturn scalar k_eq_model = e(k_eq) - e(k_aux)
	ereturn local equation "`eqs'"
		
	****************************************************************************

	// process and return results
	
	if _rc != 0 {
	
		noi di in red "WARNING: estimation error code _rc = " _rc
		constraint drop `allconstraints'
		macro drop fixedsd FW_* clsd
		error 499
		
	}
	
	else if _rc == 0 {

		di in yellow "...estimation done."
		
		if e(converged) == 0 noi di in red "WARNING: model failed to converge."

		sort `grpid'
		
		** SE calculations and dereferencing
		
		tempvar ninv1 ninv
		
		tempname Vfull Bfull P2 One PI n ntilde Q a ///
			Mprime Gprime Sprime Cprime ///
			Mprime_se Sprime_se Gprime_se Cprime_se ///
			Vprime Omegaprime Lambdaprime Wprime Zprime ///
			sigmaw sigmab sigmaprime ///
			Mstar Sstar Mstar_se Sstar_se Cstar Cstar_se ///
			icchatratio icchat R T varsigprime Vstar Wstar Zstar icchatvar ///
			S G Gvar1 ///
			Braw Bprime Aprime Dprime U Bstar Astar Dstar ///
			Mraw Sraw Mraw_se Sraw_se Craw Craw_se ///
			Zraw Wraw Vraw
			
		matrix `Vfull' = e(V)
		matrix `Bfull' = e(b)'

		matrix `P2' = hadamard(`P', `P')
		matrix `One' = J(1,`K',1)
		matrix `PI' = I(`K') - `One''*`P'

		gen double `ninv1' = 1 / (`Nk' - 1)
		mkmat `ninv1' , mat(`ninv1')
		drop `ninv1'
		
		mkmat `Nk' , mat(`n')
		matrix `n' = `n''
		
		* adjust the "omega-hat-bar-G" (ohbg) term for model type
		
		qui if "`modtype'" == "hetop" {
			matrix `ntilde' = ( (1/`K') * (`One' * `ninv1') )
			matrix `ntilde' = invsym(`ntilde')
			local ohbg = 1 / (2*`ntilde'[1,1])
			mat drop `ntilde'
		}
		
		qui if "`modtype'" == "homop" {
			qui sum `Nk'
			if $fixedsd == 0 local ohbg = 1 / (2 * (r(sum)-`K'))
			if $fixedsd == 1 local ohbg = 0
		}
		
		qui if "`modtype'" == "hetop" & "`phop'" != "" {
			tempvar nt
			g double `nt' = `Nk' - 1
			qui sum `nt' if `phop' == 1
			replace `nt' = r(sum) if `phop' == 1
			replace `nt' = 1/(2*`nt')
			qui sum `nt'
			local ohbg = (1/`K')*r(sum)			
		}
		
		g double `ninv' = 1/`Nk'
		mkmat `ninv' , mat(`ninv')
		drop `ninv'
		
		matrix `Q' = (1/(1+(2*`ohbg'))) * ///
			hadamard( hadamard( `ninv'' , (`P' + `n' - `One') ) , `P' )

		/*
		
		create the following vectors/matrices.
		
		Mprime: estimated means in estimation metric.
		Vprime: estimated sampling variance/covariance of the Mprime vector
		Gprime: estimated ln(SD) in estimation metric.
		Omegaprime: estimated sampling variance/covariance of Gprime vector
		Lambdaprime: sampling covariances of Mprime and Gprime
		Cprime: estimated thresholds
		Bprime: sampling variance/covariance of thresholds
		Sprime: exp(Gprime)
		Wprime: estimated sampling variance/covariance of Sprime
		Zprime: estimated covariance of Mprime and Sprime		
		Aprime: sampling var/cov of means X cuts
		Dprime: sampling var/cov of gammas X cuts
		
		*/
		
		qui levelsof `grpid' , local(nameid)
		local mnames
		local snames
		forv i = 1/`K' {
			local j : word `i' of `nameid'
			local mnames	"`mnames' `j'.`grpid'"
			local snames 	"`snames' `j'.`grpid'"
		}

		matrix `Mprime' = `Bfull'[1 .. `K', 1]
		matrix `Vprime' = `Vfull'[1..`K',1..`K']
				
		if "`modtype'" == "hetop" {
			
			matrix `Gprime' = `Bfull'[`=`K'+1' .. `=`K'*2', 1]
			matrix `Omegaprime' = `Vfull'[`=`K'+1'..`=2*`K'',`=`K'+1'..`=2*`K'']
			matrix `Lambdaprime' = `Vfull'[1..`K',`=`K'+1'..`=2*`K'']
			matrix `Cprime' = `Bfull'[`=`K'*2+1' .. `=`K'*2+`numcuts'' , 1]
			matrix `Bprime' = `Vfull'[`=`K'*2+1' .. `=`K'*2+`numcuts'' , ///
				`=`K'*2+1' .. `=`K'*2+`numcuts'']
			matrix `Aprime' = `Vfull'[1..`K',`=`K'*2+1' .. `=`K'*2+`numcuts'']
			matrix `Dprime' = `Vfull'[`=`K'+1'..`=2*`K'', ///
				`=`K'*2+1' .. `=`K'*2+`numcuts'']
			
		}
		
		else {
			// else model is homop			
			if $fixedsd == 1 {
				matrix `Gprime' = J(`K',1,`=${clsd}')
				matrix `Omegaprime' = J(`K',`K',0)
				matrix `Lambdaprime' = J(`K',`K',0)
				matrix `Cprime' = `Bfull'[`=`K'+1' .. `=`K'+`numcuts'' , 1]
				matrix `Bprime' = `Vfull'[`=`K'+1' .. `=`K'+`numcuts'' , ///
				                             `=`K'+1' .. `=`K'+`numcuts'']
				matrix `Aprime' = `Vfull'[1..`K',`=`K'+1' .. `=`K'+`numcuts'']
				matrix `Dprime' = J(`K',`numcuts',0)
			}
			else if $fixedsd == 0 {
				// only here if "`identify'"=="setcuts"
				local sdest = `Bfull'[`=`K'+1',1]
				matrix `Gprime' = J(`K',1,`sdest')
				matrix `Omegaprime' = J(`K',`K',`Vfull'[`=`K'+1',`=`K'+1'])
				matrix `Lambdaprime' = `Vfull'[`=`K'+1',1..`K']
				matrix `Lambdaprime' = `Lambdaprime''*`One'
				matrix `Cprime' = `Bfull'[`=`K'+2' .. `=`K'+`numcuts'+1' , 1]
				matrix `Bprime' = `Vfull'[`=`K'+2' .. `=`K'+`numcuts'+1' , ///
				                          `=`K'+2' .. `=`K'+`numcuts'+1']
				matrix `Aprime' = J(`K',`numcuts',0)
				matrix `Dprime' = J(`K',`numcuts',0)
			}
			
		}

		* store the means and SDs in the estimation "raw" metric

		matrix `Mraw' = `Mprime'
		matrix `Vraw' = `Vprime'
		matrix `Mraw_se' = vecdiag(`Vraw')'
	
		matrix roweq	`Mraw' = mean:
		matrix rownames `Mraw' = `mnames'
		matrix roweq	`Mraw_se' = mean:
		matrix rownames `Mraw_se' = `mnames'

		matrix roweq	`Vraw' = mean:
		matrix coleq	`Vraw' = mean:
		matrix rownames `Vraw' = `mnames'
		matrix colnames `Vraw' = `mnames'

		matrix `Sraw' = `Gprime'
		forv k = 1/`K' {
			matrix `Sraw'[`k',1] = exp(`Sraw'[`k',1])
			matrix `Mraw_se'[`k',1] = `Mraw_se'[`k',1]^.5
		}

		matrix `Wraw' = diag(`Sraw') * `Omegaprime' * diag(`Sraw')
		matrix `Sraw_se' = vecdiag(`Wraw')'
		forv k = 1/`K' {
			matrix `Sraw_se'[`k',1] = `Sraw_se'[`k',1]^.5
		}

		matrix roweq	`Wraw' = sigma:
		matrix coleq	`Wraw' = sigma:
		matrix rownames `Wraw' = `snames'
		matrix colnames `Wraw' = `snames'

		matrix `Zraw' = `Lambdaprime'*diag(`Sraw')

		matrix roweq	`Zraw' = mean:
		matrix coleq	`Zraw' = sigma:
		matrix rownames `Zraw' = `mnames'
		matrix colnames `Zraw' = `snames'

		matrix roweq	`Sraw' = sigma:
		matrix rownames `Sraw' = `snames'
		matrix roweq	`Sraw_se' = sigma:
		matrix rownames `Sraw_se' = `snames'

		matrix `Braw' = `Bprime'
		matrix `Craw' = `Cprime'
		matrix `Craw_se' = vecdiag(`Bprime')'
		forv i = 1/`=`numcats'-1' {
			mat `Craw_se'[`i',1] = `Craw_se'[`i',1]^.5
		}
		
		if "`identify'" != "sums" {

			// convert from double-prime/raw to single-prime metric if

			tempname A OneK1 MprimeS
			matrix `A' = `P' * `Gprime'
			local a = `A'[1,1]

			local kap = 1
			if `kappa' == 2 {
				matrix `varPG' = `P' * `Omegaprime' * `P''
				local kap = (1 + (1/2) * `varPG'[1,1])
			}
			
			local delta = exp(`a')
			matrix `OneK1' = J(1,`numcuts',1)
			matrix `MprimeS' = (exp(`a')^-1) * ( `PI' * `Mprime' )	// single prime Mprime vector

			matrix `Cprime' = (`delta'^(-1))*(`Cprime' - `OneK1''*(`P'*`Mprime'))	// convert to single prime Cprime
			
			matrix `Bprime' = ///
				exp(-2*`a')* ///
				(`kap'^2 *(`Bprime'-(`Aprime''*`P'')*`OneK1'-`OneK1''*(`P'*`Aprime')+`OneK1''*(`P'*`Vprime'*`P'')*`OneK1') ///
				-(`delta'/`kap')*hadamard(`Cprime'*`OneK1',(`OneK1''*`P'*`Dprime'-`OneK1''*(`P'*`Lambdaprime'*`P'')*`OneK1')) ///
				-(`delta'/`kap')*hadamard(`OneK1''*`Cprime'',(`Dprime''*`P''*`OneK1'-`OneK1''*(`P'*`Lambdaprime'*`P'')*`OneK1')) ///
				+((`delta'^2)/(`kap'^4))*hadamard(hadamard((`Cprime'*`OneK1'),(`OneK1''*`Cprime'')),(`OneK1''*(`P'*`Omegaprime'*`P'')*`OneK1')))
			
			matrix `Aprime' = (1/`delta'^2) * (`kap'^2) * ///
				(`PI'*(`Aprime'-`Vprime'*`P''*`OneK1')) ///
				- (`delta'*`kap')^(-1)*hadamard(`MprimeS'*`OneK1',`One''*`P'*`Dprime'-`One''*(`P'*`Lambdaprime'*`P'')*`OneK1') ///
				- (`delta'*`kap')^(-1)*hadamard(`One''*`Cprime'', `PI'*`Lambdaprime'*`P''*`OneK1') ///
				+ (`kap')^(-4)*hadamard(hadamard(`MprimeS'*`OneK1', `One''*`Cprime''), `One''*(`P'*`Omegaprime'*`P'')*`OneK1')
			
			matrix `Dprime' = (`kap'/`delta') * ///
				(`PI'*(`Dprime'-`Lambdaprime''*`P''*`OneK1')) - ///
				`kap'*hadamard(`One''*`Cprime'', `PI'*(`Omegaprime''*`P''*`OneK1'))
			
			matrix `Vprime' = (exp(`a')^-2) * ( ///
											( `kap'^2 * `PI' * `Vprime' * `PI'' ) ///
											- (`kap'^(-1)) * (`PI' * `Mprime' * `P' * `Lambdaprime'' * `PI'' + `PI' * `Lambdaprime' * `P'' * `Mprime'' * `PI'' ) ///
											+ (`kap'^(-4)) * (`PI' * `Mprime' * `Mprime'' * `PI'' * ( `P' * `Omegaprime' * `P'') ) ///
											)

			matrix `Lambdaprime' = (exp(`a')^-1) * ( ( `kap' * `PI' * `Lambdaprime' * `PI'') - (`kap'^(-2)) * `PI' * `Mprime' * `P' * `Omegaprime' * `PI'' )
			
			matrix `Mprime' = (exp(`a')^-1) * ( `PI' * `Mprime' )
			matrix `Gprime' = `PI' * `Gprime'
			matrix `Omegaprime' = `PI' * `Omegaprime' * `PI''
		
		}

		* create Sprime, Wprime and Zprime

		matrix `Sprime' = `Gprime'
		forv k = 1/`K' {
			matrix `Sprime'[`k',1] = exp(`Sprime'[`k',1])
		}
				
		matrix roweq	`Mprime' = mean:
		matrix rownames `Mprime' = `mnames'
		matrix roweq	`Vprime' = mean:
		matrix coleq	`Vprime' = mean:
		matrix rownames `Vprime' = `mnames'
		matrix colnames `Vprime' = `mnames'
		
		matrix roweq	`Aprime' = mean:
		matrix rownames	`Aprime' = `mnames'
		
		matrix roweq	`Sprime' = sigma:
		matrix rownames	`Sprime' = `snames'
		
		matrix `Wprime' = diag(`Sprime') * `Omegaprime' * diag(`Sprime')
		matrix `Zprime' = `Lambdaprime' * diag(`Sprime')
		
		if `K' > 1 {	// standardizing, etc. not appropriate when number of groups = 1

			* --------------------------------- *
			* Mstar and Sstar
			* --------------------------------- *
			
			matrix `sigmaw' = (1/(1+(2*`ohbg'))) * (`P' * hadamard( `Sprime' , `Sprime' ))
			matrix `sigmab' = (`P' * hadamard( `Mprime' , `Mprime' )) + ( (1/(1+(2*`ohbg'))) * ( hadamard( `ninv'' , (`P2' - `P') ) * hadamard( `Sprime' , `Sprime' ) ) )
			
			matrix `sigmaprime' = cholesky( `P' * hadamard(`Mprime',`Mprime') + `Q' * hadamard(`Sprime', `Sprime') )
			
			matrix `Mstar' = invsym(`sigmaprime')*`Mprime'
			matrix `Sstar' = invsym(`sigmaprime')*`Sprime'
			matrix `Cstar' = invsym(`sigmaprime')*`Cprime'
			
			matrix `icchatratio' = `sigmab' * invsym(`sigmaw' + `sigmab')
			matrix `icchat' = 1 - ((1/(1+(2*`ohbg'))) * `P' * hadamard(`Sstar', `Sstar'))
			
			* --------------------------------- *
			* Vstar and Wstar and Zstar
			* --------------------------------- *

			capture {
				
				matrix `R' = `P' * diag(`Mstar') * `Vprime' + `Q' * diag(`Sstar') * `Zprime''
				matrix `T' = `P' * diag(`Mstar') * `Zprime' + `Q' * diag(`Sstar') * `Wprime'
				matrix `varsigprime' = invsym(hadamard(`sigmaprime', `sigmaprime')) * (`P' * diag(`Mprime') * `Vprime' * diag(`Mprime') * `P'' + `Q' * diag(`Sprime') * `Wprime' * diag(`Sprime') * `Q'' + 2 * `P' * diag(`Mprime') * `Zprime' * diag(`Sprime') * `Q'')
				matrix `Vstar' = invsym(hadamard(`sigmaprime', `sigmaprime')) * (`Vprime' - (`Mstar' * `R' + `R'' * `Mstar'') + `Mstar' * `Mstar'' * `varsigprime')
				matrix `Wstar' = invsym(hadamard(`sigmaprime', `sigmaprime')) * (`Wprime' - (`Sstar' * `T' + `T'' * `Sstar'') + `Sstar' * `Sstar'' * `varsigprime')				
				matrix `Zstar' = invsym(hadamard(`sigmaprime', `sigmaprime')) * (`Zprime' - (`Mstar' * `T' + `R'' * `Sstar'') + `Mstar' * `Sstar'' * `varsigprime')
				
				matrix `icchatvar' = 4*(1/(1+(2*`ohbg')))^2 * `P'*(diag(`Sstar')*`Wstar'*diag(`Sstar'))*`P''
				
				matrix `U' = `P'*diag(`Mstar')*`Aprime'+`Q'*diag(`Sstar')*`Dprime'

				matrix `Bstar' = invsym(hadamard(`sigmaprime', `sigmaprime'))*(`Bprime'-(`Cstar'*`U'+`U''*`Cstar'')+(`Cstar'*`Cstar'')*`varsigprime')
				matrix `Astar' = invsym(hadamard(`sigmaprime', `sigmaprime'))*(`Aprime'-(`Mstar'*`U'+`R''*`Cstar'')+`Mstar'*`Cstar''*`varsigprime')
				matrix `Dstar' = invsym(hadamard(`sigmaprime', `sigmaprime'))*(`Dprime'-(`Sstar'*`U'+`T''*`Cstar'')+`Sstar'*`Cstar''*`varsigprime')

			}
			*****
		
			local varmatsRC = _rc		// record errors
					
			* standard errors
			local mseRC = 0
			cap matrix `Mstar_se' = vecdiag(cholesky(diag(vecdiag(`Vstar'))))'
			if _rc != 0 {
				matrix `Mstar_se' = J(`K' , 1 , .)
				local mseRC = _rc
			}

			local cseRC = 0
			cap matrix `Cstar_se' = vecdiag(cholesky(diag(vecdiag(`Bstar'))))'
			if _rc != 0 {
				matrix `Cstar_se' = J(`numcuts' , 1 , .)
				local cseRC = _rc
			}
			
			local sseRC = 0
			cap matrix `Sstar_se' = vecdiag(cholesky(diag(vecdiag(`Wstar'))))'
			if _rc != 0 {
				matrix `Sstar_se' = J(`K' , 1 , .)
				local sseRC = _rc
			}

			* --------------------------------- *
			* Gaps matrix G if requested
			* --------------------------------- *

			if "`gaps'" != "" {
			
				// gap matrix G
				matrix `S' = (1/2)*(hadamard(`Sstar'*`One', `Sstar'*`One')+hadamard(`One''*`Sstar'', `One''*`Sstar''))
				matrix `G' = J(`K',`K',0)
				forv i = 1/`K' {
					forv j = 1/`K' {
						
						mat `S'[`i',`j'] = `S'[`i',`j']^.5
						mat `G'[`i',`j'] = 1 / `S'[`i',`j']
						
					}
				}
				
				matrix `G' = hadamard( `Mstar' * `One' - `One'' * `Mstar'' , `G' )
				
				* sampling variances, appendix formula B3
				
				forv i = 1/1 {
					matrix `Gvar`i'' = J(`K', `K', 0)
				}
				
				
				forv g = 1/`K' {
					forv h = 1/`K' {
						if `g' != `h' {
							
							local deltagh = (`Vstar'[`g',`g'] + `Vstar'[`h',`h'] - 2*`Vstar'[`g',`h'])
							local etagh = 1/(4*`S'[`g',`h']^2)*(`Sstar'[`g',1]^2*`Wstar'[`g',`g']+ `Sstar'[`h',1]^2*`Wstar'[`h',`h'] + 2*`Sstar'[`g',1]*`Sstar'[`h',1]*`Wstar'[`g',`h'])
							
							matrix `Gvar1'[`g',`h'] = `deltagh'/`S'[`g',`h']^2 * (1 + `G'[`g',`h']^2 * (`etagh'/`deltagh') - (`etagh'/`S'[`g',`h']^2))
							
						}
					}
				}
			}
		}
	}  // conclude calculations done
	*****

	// returns
	
	* matrices
	
	ereturn matrix pk = `P'
	ereturn matrix PI = `PI'
	
	* return matrix with order of "best" reference groups
	tempname rr
	qui get_ref , refrank(1) catname(`catname') grpid(`grpid') numcats(`numcats')
	mat `rr' = r(refrank)
	ereturn matrix refrank = `rr'

	* return initial values if used
	ereturn matrix initvalsmat = `initvalsmat'
	if "`initvals'" == "" & "`startfrom'" == "" {
		ereturn scalar initvals = 0
	}
	else {
		ereturn scalar initvals = 1
	}

	* return prime and star estimates

	if "`identify'" != "setcuts" {
		matrix `Cprime_se' = vecdiag(cholesky(diag(vecdiag(`Bprime'))))'
	}
	else if "`identify'" == "setcuts" {
		matrix `Cprime_se' = vecdiag(cholesky(diag(vecdiag(`Bprime'))))'
	}

	if `K' > 1 matrix `Mprime_se' = vecdiag(cholesky(diag(vecdiag(`Vprime'))))'

	if "`modtype'" == "hetop" & `K' > 1 {
		cap matrix `Gprime_se' = vecdiag(cholesky(diag(vecdiag(`Omegaprime'))))'
		if _rc != 0 matrix `Gprime_se' = J(`K',1,.)
		cap matrix `Sprime_se' = vecdiag(cholesky(diag(vecdiag(`Wprime'))))'
		if _rc matrix `Sprime_se' = J(`K',1,.)
	}
	else {
		matrix `Gprime_se' = J(`K',1,0)
		matrix `Sprime_se' = J(`K',1,0)
		matrix roweq `Gprime_se' = lnsigma:
		matrix roweq `Sprime_se' = sigma:
		matrix rownames `Sprime_se' = `snames'
		matrix rownames `Gprime_se' = `snames'
	}

	ereturn matrix Braw = `Braw'
	ereturn matrix Zraw = `Zraw'
	ereturn matrix Wraw = `Wraw'
	ereturn matrix Vraw = `Vraw'
	ereturn matrix craw_se = `Craw_se'
	ereturn matrix craw = `Craw'
	ereturn matrix sraw_se = `Sraw_se'
	ereturn matrix sraw = `Sraw'
	ereturn matrix mraw_se = `Mraw_se'
	ereturn matrix mraw = `Mraw'

	if `K' > 1 {

	* return gap estimates
	if "`gaps'" != "" {
		ereturn matrix G = `G'
		ereturn matrix Gvar1 = `Gvar1'	// formula version 1
	}

	ereturn matrix Bprime = `Bprime'
	ereturn matrix Aprime = `Aprime'
	ereturn matrix Zprime = `Zprime'
	ereturn matrix Wprime = `Wprime'
	ereturn matrix Vprime = `Vprime'

	ereturn matrix cprime_se = `Cprime_se'
	ereturn matrix cprime = `Cprime'

	ereturn matrix gprime_se = `Gprime_se'
	ereturn matrix gprime = `Gprime'
	
	ereturn matrix sprime_se = `Sprime_se'
	ereturn matrix sprime = `Sprime'
	
	ereturn matrix mprime_se = `Mprime_se'
	ereturn matrix mprime = `Mprime'
	
	ereturn matrix Bstar = `Bstar'
	ereturn matrix Astar = `Astar'
	ereturn matrix Dstar = `Dstar'
	ereturn matrix Zstar = `Zstar'
	ereturn matrix Wstar = `Wstar'
	ereturn matrix Vstar = `Vstar'

	ereturn matrix cstar_se = `Cstar_se'
	ereturn matrix cstar = `Cstar'

	ereturn matrix sstar_se = `Sstar_se'
	ereturn matrix sstar = `Sstar'
	
	ereturn matrix mstar_se = `Mstar_se'
	ereturn matrix mstar = `Mstar'

	* scalars and strings
	ereturn scalar mseRC = `mseRC'
	ereturn scalar sseRC = `sseRC'
	ereturn scalar cseRC = `cseRC'
	ereturn scalar varmatsRC = `varmatsRC'
	
	if `mseRC' != 0 | `sseRC' != 0 | `cseRC' != 0 | `varmatsRC' != 0 {
		noi di in red "Warning: problem with de-referenced SEs. " ///
		"See mseRC, sseRC and/or varmatsRC."
	}
	
	* estimated icc and SE
	ereturn scalar icchat = `icchat'[1,1]
	ereturn scalar icchatratio = `icchatratio'[1,1]		// alternate formula: sigmab / (sigmab + sigmaw)
	ereturn scalar icchat_var  = `icchatvar'[1,1]
	
	* sigmaprime estimate
	ereturn scalar sigmaprime = `sigmaprime'[1,1]
	ereturn scalar sigmaw = `sigmaw'[1,1]
	ereturn scalar sigmab = `sigmab'[1,1]
	ereturn scalar varsigprime = `varsigprime'[1,1]

	}

	ereturn scalar numgrps = `K'

	if "`identify'" != "refgroup" {
		ereturn scalar refgrp = 0
	}
	else {
		ereturn scalar refgrp = `ref_group'
	}

	ereturn local identify 	= "`identify'"			// "sums" or "refgroup"
	ereturn local modtype 	= "`modtype'"			// "hetop" or "homop"
	if "`phop'" == "" local phop "."
	ereturn local phop 		= "`phop'"				// phop constraint variable, blank if not used
	ereturn local cmd 		= "hetop"
	if "`modtype'" == "homop" ereturn local csd=`csd'
	if "`modtype'" != "homop" ereturn local csd=.
	ereturn local levelvars = "`vars'"

	// cleanup constraints and macros
	
	constraint drop `allconstraints'
	macro drop FW_* fixedsd clsd
	

	*************************************************
	***** save estimates if requested *****	
	
	if "`save'" != "" {

		sort `grpid'

		parse_save_opt `save'

		foreach v in `s(stypes)' {
			
			do_save `v' , `s(se)' `s(cov)' savename(`s(stubname)')

		}

		keep `grpid' `newvarnames'
		tempfile results
		qui save "`results'"		
	}

	************************************************
	* restore and return original data file

	restore
	
	qui if "`save'" != "" {
		tempvar curorder
		g `curorder' = _n
		merge 1:1 `grpid' using "`results'" , nogen
		sort `curorder'
	}
	
	ereturn local grpid 	= "`grpid'"

end
	
*************************************************


*************************************************
* parse PHOP options
cap program drop parse_phop_opt
program define parse_phop_opt , sclass
	version 13.1
	syntax varname [ , mean weight ]
	tokenize `varlist'
	local phop `1'
	sreturn local phopvar `phop'
	if "`mean'" != "" sreturn local phop_mean = 1
end
*************************************************


*************************************************
* getsubmat, 21jun2017
* helper function to get matrix subset
* based somewhat on -matselrc- from nick cox
* programmed here to avoid need for external package

cap program drop getsubmat
program define getsubmat
	version 13.1
	syntax namelist(min=2 max=2) , [ Row(numlist) Col(numlist) ]
	tokenize `namelist'
	local m1 `1'
	local m2 `2'
	
	tempname a1 a2
	
	if "`row'" == "" {
		local nr = rowsof(`m1')
		qui numlist "1(1)`nr'"
		local row "`r(numlist)'"
	}
	if "`col'" == "" {
		local nc = colsof(`m1')
		qui numlist "1(1)`nc'"
		local col "`r(numlist)'"
	}

	local i = 1
	foreach num in `row' {
		if `i' == 1 matrix `a1' = `m1'[`num',1...]
		if `i' != 1 matrix `a1' = `a1' \ `m1'[`num',1...]
		local i = `i'+1
	}
	local i = 1
	foreach num in `col' {
		if `i' == 1 matrix `a2' = `a1'[1...,`num']
		if `i' != 1 matrix `a2' = `a2' , `a1'[1...,`num']
		local i = `i'+1
	}

	matrix `m2' = `a2'

end

*************************************************


*************************************************
* parse save syntax

cap program drop parse_save_opt 
program define parse_save_opt , sclass
	version 13.1

	syntax [ anything ] [ , STAR PRIME RAW SE COV ]

	tokenize `anything'
	local stubname `1'

	local allvarnames

	foreach v in `star' `prime' `raw' {
		local allvarnames "`allvarnames' m`v'`stubname' s`v'`stubname'"
		if "`se'" != "" local allvarnames "`allvarnames' m`v'`stubname'_se s`v'`stubname'_se"
		if "`cov'" != "" local allvarnames "`allvarnames' z`v'`stubname'_cov"
	}
	
	sreturn local stubname `stubname'
	sreturn local se `se'
	sreturn local cov `cov'
	sreturn local stypes "`star' `prime' `raw'"
	sreturn local allvarnames "`allvarnames'"

end

*************************************************


*************************************************
* run save command

cap program drop do_save
program define do_save
	version 13.1
	syntax anything [ , SE COV SAVENAME(string) ]
	
	tokenize `anything'
	local savetype `1'

	foreach v in m s {
		tempname m
		mat `m' = e(`v'`savetype')
		svmat `m'
		rename `m'1 `v'`savetype'`savename'
	}

	if "`se'" != "" {
		foreach v in m s {
			tempname m
			mat `m' = e(`v'`savetype'_se)
			svmat `m'
			rename `m'1 `v'`savetype'`savename'_se
		}
	}

	if "`cov'" != "" {
		tempname z
		matrix `z' = e(Z`savetype')
		matrix `z' = vecdiag(`z')'
		svmat `z'
		rename `z'1 z`savetype'`savename'_cov
	}

end

*************************************************


*************************************************
* determine best reference groups

cap program drop get_ref
program define get_ref , rclass
	version 13.1
	syntax , ///
		[ ///
		REFRANK(integer 1) CATNAME(string) GRPID(string) NUMCATS(integer 0) ///
		]

	* limit to those with at least 3 non-zero cells
	* identify those above median size (of those with at least 3 cells)
	* then sort on proportion distance metric (binned)
	* then sort on sample size	
	
	tempname refmat

	preserve
	
		qui reshape long `catname', i(`grpid') j(y)
		qui levelsof y , local(ylevels)
		reshape wide 
		
		egen Nk = rowtotal(`catname'*)

		qui su Nk , d
		local Ntot = r(sum)

		egen num0s = anycount(`catname'*) , val(0)
		gen has3 = 0
		replace has3 = 1 if (`numcats' - num0s) > 2

		qui sum Nk if has3 == 1 , detail
		local medN = r(p50)
		gen abvmed = 0
		replace abvmed = 1 if (Nk >= `medN')
		
		foreach i in `ylevels' {
			qui su `catname'`i'
			gen ptmp`i' = (( `catname'`i' / Nk ) / ( r(sum) / `Ntot' )) - 1
			gen abstmp`i' = abs(ptmp`i')
		}
		
		egen psum = rowtotal(abstmp*)
		gen psumrd = round(psum, .25)
		
		gen Nkrank = 1/Nk
		
		gsort -has3 -abvmed +psumrd +Nkrank +`grpid'
		g tmp_refgrp_rank = _n
		
		mkmat `grpid' , mat(`refmat')
		
		qui sum `grpid' if tmp_refgrp_rank == `refrank'
		local useid = r(mean)
	
	restore
	
	return matrix refrank = `refmat'
	return scalar refid = `useid'
	
end
*************************************************


*************************************************
* generate starting values

cap program drop get_initial_values
program define get_initial_values , rclass
	version 13.1
	syntax , ///
	[ ///
		grpid(string) refgroup(string) catname(string) csd(integer 1) ///
		numgrps(integer 0) modtype(string) numcuts(integer 0) ///
		weighttype(string) identify(string) ///
		setcuts(numlist ascending min=1 max=9) ///
		initvals ///
	]
	
	local K = `numgrps'
	if "`refgroup'" == "n" local refgroup = -1

	tempname bc IV

	mat `IV' = J(1,`=`K'*2',0)

	preserve
		keep `catname'* `grpid'
		qui reshape long `catname' , i(`grpid') j(y)
		qui replace `catname' = 0 if `catname' == .

		* cut scores in standard normal
		qui proportion y [`weighttype' = `catname']
		mat `bc' = e(b)
		mat `bc' = `bc'[1,1..`numcuts']
		forval j = 2/`numcuts' {
			local i = `j' - 1
			mat `bc'[1,`j'] = `bc'[1,`j'] + `bc'[1,`i']
		}
		forv j = 1/`numcuts' {
			if `bc'[1,`j'] == 0 mat `bc'[1,`j'] = 1/10000
			if `bc'[1,`j'] == 1 mat `bc'[1,`j'] = 1-(1/10000)
			mat `bc'[1,`j'] = invnormal(`bc'[1,`j'])
		}

		* means and SDs in standard normal
		tempvar N M S dev
		bys `grpid' : egen `N' = sum(`catname')
		bys `grpid' : egen `M' = sum(y*`catname')
		qui replace `M' = (1/`N')*`M'
		qui generate `dev' = (y-`M')^2
		bys `grpid' : egen `S' = sum(`dev'*`catname')
		qui replace `S' = ((1/`N')*`S')^.5
		qui sum y [`weighttype'=`catname']
		qui replace `M' = (`M'-`r(mean)')/`r(sd)'
		qui replace `S' = `S'/`r(sd)'

		qui collapse `M' `S' `N' , by(`grpid')
		qui replace `M' = 0 if `M' == .
		qui replace `S' = 1 if `S' == 0 | `S' == .

		* re-scale based on identification
		if "`identify'" == "refgroup" {
			qui sum `M' if `grpid' == `refgroup'
			local rm = `r(mean)'
			qui sum `S' if `grpid' == `refgroup'
			local rs = `r(mean)'
			qui replace `M' = (`M'-`rm')/`rs'
			qui replace `S' = `S'/`rs'
			tempname rmatm rmats
			matrix `rmatm' = J(1,`numcuts',`=-1*`rm'')
			matrix `bc' = (`bc'+`rmatm')*(1/`rs')		
		}
		else if "`identify'" == "cuts" {		
			if `numcuts' == 1 {
				qui sum `S'
				local rs = `r(mean)'/`csd'
				local rm = `bc'[1,1]
				qui replace `M' = `M'/`rs'-`rm' // (`M'-`rm')/`rs'
				matrix `bc'[1,1]=0
			}
			else {
				local c1 = `bc'[1,1]
				local c2 = `bc'[1,2]
				local rslp = 1/(`c2'-`c1')
				local rint = -1*(`rslp'*`c2')
				qui replace `M' = `rslp'*`M'+`rint'
				qui replace `S' = `rslp'*`S'
				forv i = 1/`numcuts' {
					matrix `bc'[1,`i'] = `bc'[1,`i']*`rslp'+`rint'
				}
			}
		}
		else if "`identify'" == "setcuts"{
			if `numcuts' == 1 {
				qui sum `S'
				local rs = `r(mean)'/`csd'
				local rm = `setcuts'-`bc'[1,1]
				qui replace `M' = `M'/`rs'+`rm'
				matrix `bc'[1,1]=`setcuts'
			}
			else {
				tempname X Y B
				qui mata: st_matrix("`Y'", strtoreal(tokens(st_local("setcuts"))))
				matrix `Y' = `Y''
				matrix `X' = J(`numcuts',1,1) , `bc''
				matrix `B' = invsym(`X''*`X')*`X''*`Y'
				qui replace `M' = `B'[2,1]*`M'+`B'[1,1]
				qui replace `S' = `B'[2,1]*`S'
				forv i = 1/`numcuts' {
					local c : word `i' of `setcuts'
					matrix `bc'[1,`i'] = `c'
				}
			}
		}

		qui replace `S' = ln(`S')

		if "`identify'" == "sums" {
			qui sum `M' [`weighttype'=`N']
			local gm = r(mean)
			qui sum `S' [`weighttype'=`N']
			qui replace `S' = `S'-`r(mean)'
			qui replace `M' = (`M'-`gm')/exp(`r(mean)')
		}

		* create initial value matrix and column names
		sort `grpid'
		qui levelsof `grpid' , local(grplevels)
		qui forval k = 1/`K' {
			local j : word `k' of `grplevels'
			local Minitcolumns `Minitcolumns' mean:`j'.`grpid'
			local Sinitcolumns `Sinitcolumns' lnsigma:`j'.`grpid'
		}
		if "`modtype'" == "hetop" local numparms = `numgrps'*2
		if "`modtype'" == "homop" & $fixedsd == 0 {
			local numparms = `numgrps'+1
			local Sinitcolumns "lnsigma:_cons"
		}
		if "`modtype'" == "homop" & $fixedsd == 1 {
			local numparms = `numgrps'
			local Sinitcolumns ""
		}
		matrix `IV' = J(1,`numparms',0)

		* add appropriate initial values
		if "`initvals'" != "" {
			if "`modtype'" == "hetop" {
				qui levelsof `grpid' , local(grplevels)
				qui forval k = 1/`K' {
					local j : word `k' of `grplevels'
					qui sum `M' if `grpid' == `j'
					matrix `IV'[1,`k'] = `r(mean)'
					qui sum `S' if `grpid' == `j'
					matrix `IV'[1,`=`K'+`k''] = `r(mean)'
				}

			}
			else if "`modtype'" == "homop" & $fixedsd == 0 {
				qui levelsof `grpid' , local(grplevels)
				qui forval k = 1/`K' {
					local j : word `k' of `grplevels'
					qui sum `M' if `grpid' == `j'
					matrix `IV'[1,`k'] = `r(mean)'
				}
				qui sum `S' [`weighttype'=`N']
				matrix `IV'[1,`=`numgrps'+1'] = `r(mean)'
			}
			else {
				// "`modtype'" == "homop" & $fixedsd == 1 
				qui levelsof `grpid' , local(grplevels)
				qui forval k = 1/`K' {
					local j : word `k' of `grplevels'
					qui sum `M' if `grpid' == `j'
					matrix `IV'[1,`k'] = `r(mean)'
				}
			}			
		}
		
		* label matrix columns		
		forval i = 1/`numcuts' {
			local bcnames `bcnames' cut`i':_cons
		}
		matrix colnames `bc' = `bcnames'
		matrix colnames `IV' = `Minitcolumns' `Sinitcolumns' 
		matrix `IV' = `IV' , `bc'

	restore	

	return matrix initvalsmat = `IV'			
	
end

*************************************************

