*! underid version 1.0.01 2july2020
*! authors mes & fw
*! see end of file for version comments

program define underid, rclass byable(recall) sortpreserve
	version 13.1
	local lversion 01.0.01

	syntax [, 								///
		underid								/// default
		overid								///
		kp									///
		JGMM2s								///
		Jcue								///
		j2lr								///
		j2l									///
		wald								///
		lr									///
		small								/// small-sample adjustment
		sw									/// triggers looping through jgmm2s by regressor
		vceopt(string)						/// overrides default VCE
		rkopt(string)						/// additional ranktest options
		NOCENTER							/// MUST APPEAR BEFORE CENTER IN OPTION LIST
		center								/// 
		repstata							/// specific to EC2SLS and Hausman-Taylor only
		usemeans							/// specific to EC2SLS and Hausman-Taylor only
		NOREPORT							/// specific to xtabond2
		VERsion 							///
		debug								///
		EQxtabond2(string)					/// specific to xtabond2: diff, lev or sys
		keepall								/// specific to xtabond2: don't drop omitted etc.
		MAINeqn(string)						/// for debugging - re-run IV eqn using retrieved data
		NOPARTIAL							/// for debugging - suppresses partialling out for non-cue
		NOIsily								///
		]

	if "`version'" != "" {					//  Report program version number, then exit.
		di in gr "`lversion'"
		return local version `lversion'
		exit
	}
	
	// check if command is supported
	local legalcmd	"ivregress ivreg2 ivreg2h xtivreg xthtaylor xtivreg2 xtabond2 xtdpdgmm"
	local cmd		"`e(cmd)'"
	local legal		: list cmd in legalcmd
	if ~`legal' {
		di as err "underid not supported for command `e(cmd)'"
		error 301
	}

	// check if essential component ranktest is installed and version is 2.0.03 or higher
	cap ranktest, version
	if _rc > 0 {
		di as err "Error: must have ranktest version 02.0.03 or greater installed"
		di as err "To install, from within Stata type " _c
		di in smcl "{stata ssc install ranktest :ssc install ranktest}"
		exit 601
	}
	local vernum "`r(version)'"
	if ("`vernum'" < "02.0.03") | ("`vernum'" > "09.9.99") {
		di as err "Error: must have ranktest version 02.0.03 or greater installed"
		di as err "Currently installed version is " as text "`vernum'"
		di as err "To update, from within Stata type " _c
		di in smcl "{stata ssc install ranktest, replace :ssc install ranktest, replace}"
		exit 601
	}
	
	// set various flags etc.
	if "`noisily'"=="" {
		local qui qui
	}
	if "`noreport'"~="" {
		local noreport qui
	}
	
	if "`underid'`overid'"=="" {
		//  default
		local underidflag	1
		local overidflag	0
	}
	else {
		local underidflag	="`underid'"~=""
		local overidflag	="`overid'"~=""
	}
	
	local swflag			="`sw'"~=""
	local repstataflag		="`repstata'"~=""
	local usemeansflag		="`usemeans'"~=""
	if `repstataflag' & `usemeansflag' {
		di as err "incompatible options: repstata and usemeans"
		exit 198
	}
	// special treatment below
	local jgmm2sflag		="`jgmm2s'"~=""
	// debugging/undocumented options
	local debugflag			=("`debug'"~="")

	if "`kp'`jgmm2s'`jcue'`j2lr'`j2l'`lr'"=="" {
		// set default
		local rkstat		jcue
	}
	else {
		// check syntax - can choose only one
		local check			: word count `kp' `jgmm2s' `jcue' `j2lr' `j2l' `lr'
		if `check'==1 {
			local rkstat	`kp' `jgmm2s' `jcue' `j2lr' `j2l' `lr'
		}
		else {
			di as err "synax error: incompatible options "`kp' `jgmm2s' `jcue' `j2lr' `j2l' `lr'"
			exit 198
		}
	}
	// check syntax - can choose only one
	local check			: word count `center' `nocenter'
	if `check' > 1 {
		di as err "synax error: incompatible options center nocenter"
		exit 198
	}

***************************************************************************************************


************************* ASSEMBLE MODEL AND OPTION SPECS *****************************************

	// Save command line
	local cmdline "underid `0'"

	// esample = touse, except for xtabond2 where esample = original e(sample) in estimation
	// use touse unless need to refer explicitly to original sample (e.g. when expanding factor vars)
	tempvar esample
	qui gen byte `esample'=e(sample)

	// If data already preserved, OK; if preserve fails for other reasons, exit with error
	capture preserve
	if _rc > 0 & _rc~=621 {
		di as err "Internal underid error - preserve failed"
		exit 498
	}

	// Create temp variables that will be changed by subroutines
	tempvar touse wvar
	qui gen byte `touse'=.
	qui gen double `wvar'=1

	// Get underid options from command line
	// Pass additional args to get_option_specs; bind needed in case of constructs like "l(1,2).abmi"
	gettoken first opts : 0 , parse(",") bind
	if "`first'"~="," {									//  args in macro `first' so run again
		gettoken first opts : opts , parse(",") bind	//  to get rid of comma
	}

	// Get model specs from active model
	`noreport' get_model_specs,					/// Gets model specs from prev model. Catches some illegals.
		`opts'								/// 
		touse(`touse')						/// Applies to possibly-expanded current estimation sample
		esample(`esample')					/// Applies to original data estimation sample
		wvar(`wvar')						///
		eqxtabond2(`eqxtabond2')			/// specific to xtabond2 - use only diff or lev data/eqn
		`keepall'							/// specific to xtabond2 - don't drop omitteds etc.
		debugflag(`debugflag')

	if `debugflag' {
		return list
	}

	local cmd			`r(cmd)'
	local model			`r(model)'
	local xtmodel		`r(xtmodel)'		//  empty if not estimated using panel data estimator
	local depvar		`r(depvar)'
	local inexog		`r(inexog)'
	local endo			`r(endo)'
	local exexog		`r(exexog)'
	local TVexog		`r(TVexog)'			//  specific to xthtaylor
	local TVendo		`r(TVendo)'			//  specific to xthtaylor
	local TIexog		`r(TIexog)'			//  specific to xthtaylor
	local TIendo		`r(TIendo)'			//  specific to xthtaylor
	local noconstant	`r(noconstant)'		//  "noconstant" if no constant in original model specification
	local cons			`r(cons)'			//  0 if no constant in original model
	local nendog		`r(nendog)'
	local nexexog		`r(nexexog)'
	local ninexog		`r(ninexog)'
	local nexog			`r(nexog)'
	local robust		`r(robust)'
	local cluster		`r(cluster)'		// = cluster( <varname> ) or cluster( <varlist> )
	local clustvar		`r(clustvar)'		//  ="clustvar1" if 1-way, ="clustvar1 clustvar2" if 2-way
	local clustvar1		`r(clustvar1)'
	local clustvar2		`r(clustvar2)'
	local bw			`r(bw)'
	local kernel		`r(kernel)'
	local wtexp			`r(wtexp)'
	local wtype			`r(wtype)'
	local exp			`r(exp)'
	local wf			`r(wf)'
	local N				`r(N)'
	local N_clust		`r(N_clust)'		//  With 2-way clustering, is min(N_clust1,N_clust2)
	local N_clust1		`r(N_clust1)'
	local N_clust2		`r(N_clust2)'
	local N_g			`r(N_g)'			//  #panel groups
	local g_min			`r(g_min)'
	local g_max			`r(g_max)'
	local g_avg			`r(g_avg)'
	local Tbar			`r(Tbar)'
	local sig_e2		`r(sig_e2)'
	local sig_u2		`r(sig_u2)'
	local singleton		`r(singleton)'		//  #panel singletons
	local dofminus		`r(dofminus)'		//  0 unless set by ivreg2
	local psd			`r(psd)'
	local gmm2s			`r(gmm2s)'
	local ivar			`r(ivar)'
	local tvar			`r(tvar)'
	local esmall		`r(small)'			//  small option used for estimator
	local ecenter		`r(center)'			//  center option used for estimator
	if "`center'`nocenter'"=="" {			//  if nocenter is specified, then center macro will be empty
		local center	`r(center)'			//  if not specified by user, override
	}
	// xtabond2 is a special case
	if "`cmd'" == "xtabond2" {
		if "`vceopt'"~="" {
			di as err "Error: vceopt(.) option not supported with xtabond2"
			exit 198
		}	
*		if "`j2l'`j2lr'"~="" {
*			di as err "Error: j2l and j2lr options not supported with xtabond2"
*			exit 198
*		}	
		tempname A1 A2 S1 S2 H
		mat `A1'		= r(A1)
		mat `A2'		= r(A2)
		// matrices may be missing - caught later
		cap mat `S1'	= invsym(`A1')*1/`N'
		cap mat `S2'	= invsym(`A2')*1/`N'
		mat `H'			= r(H)				//  H matrix
		local h			= r(h)				//  h = 1, 2 or 3
		local panelvar	`r(panelvar)'
		local timevar	`r(timevar)'
		local eqvar		`r(eqvar)'
		local hvar		`r(hvar)'
		local haslevel	= `r(haslevel)'
		local uselevel	= `r(uselevel)'
		local hasdiff	= `r(hasdiff)'
		local usediff	= `r(usediff)'
		local transform	`r(transform)'		//  "first differences" or "orthogonal deviations"
		// following maybe unneeded
		local gmminsts1	`r(gmminsts1)'
		local gmminsts2	`r(gmminsts2)'
		local ivinsts1	`r(ivinsts1)'
		local ivinsts2	`r(ivinsts2)'
		local pca		`r(pca)'
	}

	// create or process vceopt:
	if "`vceopt'"=="" {
		// take VCE options from previous estimation
		if "`clustvar1'" ~= "" {
			local clusterarg	`clustvar1' `clustvar2'
			local clusterarg	: list clean clusterarg
			local vceopt		cluster(`clusterarg')
		}
		if "`kernel'" ~= "" {
			local vceopt		bw(`bw') kernel(`kernel')
		}
		local vceopt			`robust' `vceopt'
		local iidflag			="`robust'`clusterarg'`bw'`kernel'"==""
	}
	else if "`vceopt'"=="iid" {
		// VCE is unrobust iid version
		local vceopt
		// overwrite iidflag
		local iidflag			= 1
	}
	else {
		local iidflag			= 0
	}
	// create clustflag
	local vceopt : subinstr local vceopt "cluster" "cluster", count(local clustflag)


	// within transformation for FE models
	if "`xtmodel'" == "fe" {

		foreach vlist in depvar endo inexog exexog {
			fvrevar ``vlist'' if `touse'
			local `vlist' `r(varlist)'
		}

		tempvar T_i		
		sort `ivar' `touse'
		
		// Only iw and fw use weighted observation counts
		if "`wtype'" == "iweight" | "`wtype'" == "fweight" {
			qui by `ivar' `touse': gen long `T_i' = sum(`wvar') if `touse'
		}
		else {
			qui by `ivar' `touse': gen long `T_i' = _N if `touse'
		}
		qui by `ivar' `touse': replace  `T_i' = . if _n~=_N
		qui count if `T_i' < .
		local allvars "`depvar' `endo' `inexog' `exexog'"
		foreach var of local allvars {
			tempvar `var'_m
			// To get weighted means
			qui by `ivar' `touse' : gen double ``var'_m'=sum(`var'*`wvar')/sum(`wvar') if `touse'
			qui by `ivar' `touse' : replace    ``var'_m'=``var'_m'[_N] if `touse' & _n<_N
			// This guarantees that the demeaned variables are doubles
			qui by `ivar' `touse' : replace ``var'_m'=`var'-``var'_m'[_N]	   if `touse'
			drop `var'
			rename ``var'_m' `var'
		}

	}	// end within transform


	// GLS transformation for RE models
	if "`xtmodel'" == "g2sls" | "`xtmodel'" == "ec2sls" {

		foreach vlist in depvar endo inexog exexog {
			fvrevar ``vlist'' if `touse'
			local `vlist' `r(varlist)'
		}

		tempvar i_obs theta

		sort `ivar' `touse'
		qui by `ivar': egen `i_obs'=count(`touse') if `touse'
		qui sum `i_obs' if `touse'
		local balanced = (r(min)==r(max))

		qui gen double `theta' = 1 - sqrt( `sig_e2'/(`sig_u2'*`i_obs' +`sig_e2' ) ) if `touse'
		
		if `cons' {
			tempvar __cons
			qui gen double `__cons' = 1 -`theta' if `touse'
		}

		tempvar mean
		qui by `ivar' `touse': gen double `mean'=sum(`depvar') if `touse'
		qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
		recast double `depvar'
		qui replace `depvar' =`depvar'-`theta'*`mean'

		foreach var of varlist `endo' {
			tempvar mean
			qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
			qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
			recast double `var'
			qui replace `var' =`var'-`theta'*`mean'
		}
		if "`inexog'" ~= "" {
			foreach var of varlist `inexog' {
				tempvar mean omean dm gls
				qui sum `var' if `touse', meanonly
				scalar `omean'=r(mean)
				qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
				qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
				// Don't add group-invariant vars to m OR dm lists - causes collinearity problems
				qui sum `mean' if `touse'
				if r(sd) ~= 0 {
					local inexog_m "`inexog_m' `mean'"
					tempvar dm
					qui gen double `dm' = `var' - `mean' + `omean' if `touse'
					// Don't add time-invariant vars to dm list if balanced - causes collinearity problems
					// nb: can also cause collinearity in SOME unbalanced panels, e.g., 2 time-invariant vars, but OK
					qui sum `dm' if `touse'
					if ~`balanced' | r(sd) ~= 0 {
						local inexog_dm "`inexog_dm' `dm'"
					}
				}
				recast double `var'
				qui replace `var' =`var'-`theta'*`mean'
			}
		}
		foreach var of varlist `exexog' {
			tempvar mean omean dm gls
			qui sum `var' if `touse', meanonly
			scalar `omean'=r(mean)
			qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
			qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
			// Don't add group-invariant vars to m list - causes collinearity problems
			qui sum `mean' if `touse'
			if r(sd) ~= 0 {
				local exexog_m "`exexog_m' `mean'"
			}
			qui gen double `dm' = `var' - `mean' + `omean' if `touse'
			// Don't add time-invariant vars to dm list if balanced panel - causes collinearity problems
			qui sum `dm' if `touse'
			if ~`balanced' | (r(sd) ~= 0) {
				local exexog_dm "`exexog_dm' `dm'"
			}
			recast double `var'
			qui replace `var' =`var'-`theta'*`mean'
		}
		
		local cons 0
		local noconstant noconstant

		if "`xtmodel'"=="g2sls" {
			local inexog	`inexog' `__cons'
		}

		if "`xtmodel'"=="ec2sls" {
			if `repstataflag' & ~`balanced' {
				// strange but true - if unbalanced, to replicate
				// official xtivreg treat inexog as endogenous
				local endo		`inexog' `endo'
				local inexog	`__cons'
				local exexog	`exexog_dm' `exexog_m' `inexog_dm' `inexog_m'
			}
			else if `balanced' | ~`usemeansflag' {
				// default behavior
				// for balanced panels, can use inexog_dm or inexog_m
				// for unbalanced panels, default is to use inexog_dm
				local inexog	`inexog' `__cons'
				local exexog	`exexog_dm' `exexog_m' `inexog_dm'
			}
			else if `usemeansflag' {
				// for unbalanced panels, use inexog_m instead of inexog_dm
				local inexog	`inexog' `__cons'
				local exexog	`exexog_dm' `exexog_m' `inexog_m'
			}
			else {
				di as err "internal underid error after ec2sls"
				exit 198
			}
		}

	}

	// Hausman-Taylor-type RE models
	if "`xtmodel'" == "htaylor" | "`xtmodel'" == "amacurdy" {

		foreach vlist in depvar TVexog TVendo TIexog TIendo {
			fvrevar ``vlist'' if `touse'
			local `vlist' `r(varlist)'
		}
	
		tempvar i_obs theta

		sort `ivar' `touse'
		qui by `ivar' `touse': egen `i_obs'=count(`touse') if `touse'
		qui sum `i_obs' if `touse'
		local balanced = (r(min)==r(max))

		qui gen double `theta' = 1 - sqrt( `sig_e2'/(`sig_u2'*`i_obs' +`sig_e2' ) ) if `touse'

		if `cons' {
			tempvar __cons
			qui gen double `__cons' = 1 -`theta' if `touse'
		}
		local cons 0
		local noconstant noconstant

		// Dep var
		tempvar mean
		qui by `ivar' `touse': gen double `mean'=sum(`depvar') if `touse'
		qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
		recast double `depvar'
		qui replace `depvar' = `depvar'-`theta'*`mean'

		// Time-varying exog => demeaned and mean (HT)
		//                   => demeaned and current/leads/lags (AM) (balanced panels only)
		
		// do this first, before transforming TVexog
		if "`xtmodel'" == "amacurdy" {
			if "`TVexog'"~="" {
				sort `ivar' `touse' `tvar'
				foreach var of varlist `TVexog' {
					forvalues i = 1/`Tbar' {
						tempvar t
						qui by `ivar' `touse': gen double `t'=`var'[`i'] if `touse'
						// Don't add group-invariant vars to t list - causes collinearity problems
						qui sum `t' if `touse'
						if r(sd) ~= 0 {
							local TVexog_t "`TVexog_t' `t'"
						}
					}
				}
			}
		}

		if "`TVexog'"~="" {
			foreach var of varlist `TVexog' {
				tempvar mean
				qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
				qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
				// Don't add group-invariant vars to m list - causes collinearity problems
				qui sum `mean' if `touse'
				if r(sd) ~= 0 {
					local TVexog_m "`TVexog_m' `mean'"
				}
				tempvar dm
				qui gen double `dm' = `var' - `mean' if `touse'
				// Don't add group-invariant vars to dm list if balanced - causes collinearity problems
				if ~`balanced' | r(sd) ~= 0 {
					local TVexog_dm "`TVexog_dm' `dm'"
				}
				recast double `var'
				qui replace `var' = `var'-`theta'*`mean' if `touse'
			}
		}

		// TVendo => demeaned and gls only
		if "`TVendo'"~="" {
			foreach var of varlist `TVendo' {
				tempvar mean
				qui by `ivar' `touse': gen double `mean'=sum(`var') if `touse'
				qui by `ivar' `touse': replace `mean' =`mean'[_N]/_N if `touse'
				tempvar dm
				qui gen double `dm' = `var' - `mean' if `touse'
				local TVendo_dm "`TVendo_dm' `dm'"
				recast double `var'
				qui replace `var' = `var'-`theta'*`mean' if `touse'
			}
		}

		// TIexog are rescaled by theta but also need original
		// ... but since time-invariant, same thing as TIexog_m
		if "`TIexog'"~="" {
			foreach var of varlist `TIexog' {
				tempvar orig
				qui gen double `orig' = `var'
				local TIexog_m `TIexog_m' `orig'
				qui recast double `var'
				qui replace `var' = `var'-`theta'*`var' if `touse'
			}
		}

		// TIendo are rescaled by theta
		if "`TIendo'"~="" {
			foreach var of varlist `TIendo' {
				recast double `var'
				qui replace `var' = `var'-`theta'*`var' if `touse'
			}
		}

		if "`xtmodel'" == "htaylor" {
			if `repstataflag' & ~`balanced' {
				// strange but true - if unbalanced, to replicate
				// official xthtaylor treat inexog as endogenous
				local inexog	`__cons'
				local endo		`TVendo' `TIendo' `TVexog' `TIexog'
				local exexog	`TVendo_dm' `TVexog_dm' `TVexog_m' `TIexog_m'
			}
			else if `balanced' | ~`usemeansflag' {
				// default behavior
				// for balanced panels, can use TVexog_dm or TVexog_m
				// for unbalanced panels, default is to use TVexog_dm
				local inexog	`TVexog' `TIexog' `__cons'
				local endo		`TVendo' `TIendo'
				local exexog	`TVendo_dm' `TVexog_dm'
			}
			else if `usemeansflag' {
				// for unbalanced panels, use TVexog_m instead of TVexog_dm
				local inexog	`TVexog' `TIexog' `__cons'
				local endo		`TVendo' `TIendo'
				local exexog	`TVendo_dm' `TVexog_m'
			}
			else {
				di as err "internal underid error after xthtaylor"
				exit 198
			}
		}
		else if "`xtmodel'" == "amacurdy" {
				local inexog	`TVexog' `TIexog' `__cons'
				local endo		`TVendo' `TIendo'
				local exexog	`TVexog_t' `TVendo_dm'
		}
		else {
			di in red "error: unknown model `xtmodel'"
			exit 198
		}

	}

	
	// special treatment for xtabond2
	// xtabond2 settings:
	// xtmodel = diff, lev or sys
	// transform = first differences or orthogonal deviations
	// flags: haslevel, uselevel, hasdiff, usediff, clustflag
	// cluster-robust required
	
	// no H matrix is equivalent to H=I
	// just diff w/FD, h(1):           no H matrix
	// just diff w/FD, h(2) or h(3):   use H matrix
	// just diff w/OD:                 no H matrix
	// just lev:                       no H matrix
	// sys = FD + lev, h(1):           no H matrix
	//          h(2) or  h(3):         use H matrix
	// sys = OD + lev, h(1) or h(2):   no H matrix
	//                 h(3):           use H matrix

	if "`cmd'"=="xtabond2" {

		if `clustflag'==0 {
			di as err "Error: underid supports xtabond2 with a cluster-robust VCE only"
			exit 198
		}
		
		local xtabond2options		ivar(`panelvar')
	
		if "`transform'"=="first differences" & `h'>=2 {
			local xtabond2options	`xtabond2options' h(`H') hvar(`hvar')
		}
		if "`transform'"=="orthogonal deviations" & `uselevel' & `h'==3 {
			local xtabond2options	`xtabond2options' h(`H') hvar(`hvar')
		}

	}

***************************************************************************************************

	// Counts
	local nendog	: word count `endo'
	local nexexog	: word count `exexog'
	local ninexog	: word count `inexog'
	// Count modified to include constant if appropriate
	local ninexog	= `ninexog' + `cons'
	local nexog		= `nexexog' + `ninexog'

	// Error checking
	if "`endo'"=="" {
		di as err "error - no endogenous regressors specified"
		exit 198
	}

	if `debugflag' {

		di "model:       `model'"
		di "xtmodel:     `xtmodel'"
		di "vceopt:      `vceopt'"
		di "cons:        `cons'"
		di "cons var:    `__cons'"
		di "nocons:      `noconstant'"
		di "depvar:      `depvar'"
		di "inexog:      `inexog'"
		di "endo:        `endo'"
		di "todrop:      `todrop'"
		di "exexog:      `exexog'"
		di "clustvar:    `clustvar'"
		di "clustvar1:   `clustvar1'"
		di "clustvar2:   `clustvar2'"
		di "robust:      `robust'"
		di "kernel:      `kernel'"
		di "bw:          `bw'"
		di "nendog:      `nendog'"
		di "ninexog:     `ninexog'"
		di "nexexog:     `nexexog'"
		di "wtexp:       `wtexp'"
		di "wtype:       `wtype'"
		di "dofminus:    `dofminus'"
		di "ivar:        `ivar'"
		di "panelvar:    `panelvar'"
		
		foreach vlist in depvar endo inexog exexog {
			di "`vlist':"
			if "``vlist''"~="" {
				sum ``vlist'' if `touse'
			}
		}
		if "`clustvar'" ~= "" {
			sum `clustvar' if `touse'
		}
	}

	if "`nopartial'" == "" {
		local partialinexog "partial(`inexog')"
	}


	// maineq option
	di
	if "`maineqn'" == "iv" {
		// Store IV estimation for later restore.
		tempname ivestimate
		_estimates hold `ivestimate', restore
		di as text "MAIN EQUATION USING IVREG2 AND RETRIEVED DATA: BASIC IV"
		ivreg2 `depvar' (`endo' = `exexog') `inexog' `wtexp' if `touse'	///
			,															///
			`vceopt'													///
			`noconstant'												///
			`partialinexog'												///
			`ecenter'													/// center option specified in original eqn
			`esmall'													/// small option specified in original eqn
			dofminus(`dofminus')
		di
		_estimates unhold `ivestimate'
	}
	else if "`maineqn'" == "gmm2s" {
		// Store IV estimation for later restore.
		tempname ivestimate
		_estimates hold `ivestimate', restore
		di as text "MAIN EQUATION USING IVREG2 AND RETRIEVED DATA: TWO-STEP GMM"
		ivreg2 `depvar' (`endo' = `exexog') `inexog' `wtexp' if `touse'	///
			,															///
			`vceopt'													///
			`noconstant'												///
			gmm2s														///
			`partialinexog'												///
			`ecenter'													/// center option specified in original eqn
			`esmall'													/// small option specified in original eqn
			dofminus(`dofminus')
		di
		_estimates unhold `ivestimate'
	}
	else if "`maineqn'" == "cue" {
		// Store IV estimation for later restore.
		tempname ivestimate
		_estimates hold `ivestimate', restore
		di as text "MAIN EQUATION USING IVREG2 AND RETRIEVED DATA: CUE GMM"
		di as text "  (with included exog partialled out)"
		ivreg2 `depvar' (`endo' = `exexog') `inexog' `wtexp' if `touse'	///
			,															///
			`vceopt'													///
			`noconstant'												///
			partial(`inexog')											///
			`ecenter'													/// center option specified in original eqn
			`esmall'													/// small option specified in original eqn
			cue															///
			dofminus(`dofminus')
		di
		_estimates unhold `ivestimate'
	}
	else if "`maineqn'" ~= "" {
		di as err "overid error: unknown estimation method `maineqn'"
		exit 198
	}


****************************** overid and underid **********************************************

	// used in all ranktest calls - augment user-supplied rkopt macro
	local rkopt		`rkopt' `wald' `small'

	// special treatment for xtabond2 + KP stat; requires ranktest option nosvd
	// option ignored by ranktest if rkstat is not KP
	if "`rkstat'"=="kp" & "`cmd'"=="xtabond2" {
		local hasnosvd	: list posof "nosvd" in rkopt
		if ~`hasnosvd' {
			// nosvd is not in the options for ranktest, so add it
			local rkopt	`rkopt' nosvd
		}
	}

	if `overidflag' {

		local overid_options		///
			partial(`inexog')		///
			`rkstat'				///
			full					///
			`vceopt'				///
			`rkopt'					///
			`center'				///
			`noconstant'			///
			`xtabond2options'		///
			dofminus(`dofminus')
		local overid_options	: list clean overid_options

		`qui' di as text "Calling ranktest to obtain overid statistic..."
		`qui' di as text "Options passed to ranktest: `overid_options'"
		`qui' ranktest (`depvar' `endo') (`exexog') `wtexp' if `touse', `overid_options'
		if `debugflag' {
			return list
		}
		`qui' di

		tempname j_oid p_oid b_oid b0_oid S_oid V_oid
		local N				= r(N)
		local N_clust		= r(N_clust)
		scalar `j_oid'		= r(chi2)
		scalar `p_oid'		= r(p)
		local df_oid		= r(df)
		local testdesc		`r(testdesc)'
		local vcedesc1		`r(vcedesc1)'
		local vcedesc2		`r(vcedesc2)'
		local vcedesc3		`r(vcedesc3)'
		mat `b_oid'			= r(b)
		mat `b0_oid'		= r(b0)
		mat `S_oid'			= r(S)
		mat `V_oid'			= r(V)

		// check that original equation wasn't exactly identified
		if r(K1)>r(K2) {
			// was exactly identified, so replace J with zero etc.
			scalar `j_oid'	= 0
			scalar `p_oid'	= 1
			local df_oid	= 0
		}

		di as text "Overidentification test: `testdesc'"
		if "`vcedesc1'"~="" {
			di as text "  `vcedesc1'"
		}
		if "`vcedesc2'"~="" {
			di as text "  `vcedesc2'"
		}
		if "`vcedesc3'"~="" {
			di as text "  `vcedesc3'"
		}
		di as text "j=" as res %8.2f `j_oid' as text "  Chi-sq(" as res %3.0f `df_oid' as text ") p-value=" as res %6.4f `p_oid' _c
		if `df_oid'==0 {
			di as text "    (equation exactly identified)"
		}
		else {
			di
		}
	
	}

	if `underidflag' {

		if `overidflag' {
			di // blank line to separate from overid
		}
		local underid_options		///
			partial(`inexog')		///
			`rkstat'				///
			full					///
			`vceopt'				///
			`rkopt'					///
			`center'				///
			`noconstant'			///
			`xtabond2options'		///
			dofminus(`dofminus')
		`qui' di as text "Calling ranktest to obtain underid statistic..."
		`qui' di as text "Options passed to ranktest: `underid_options'"
		`qui' ranktest (`endo') (`exexog') `wtexp' if `touse', `underid_options'
		if `debugflag' {
			return list
		}
		`qui' di
	
		tempname j_uid p_uid K L b_uid b0_uid S_uid V_uid
		local N				= r(N)
		local N_clust		= r(N_clust)
		scalar `j_uid'		= r(chi2)
		scalar `p_uid'		= r(p)
		local df_uid		= r(df)
		scalar `K'			= r(K)
		scalar `L'			= r(L)
		local testdesc		`r(testdesc)'
		local vcedesc1		`r(vcedesc1)'
		local vcedesc2		`r(vcedesc2)'
		local vcedesc3		`r(vcedesc3)'
		mat `b_uid'			= r(b)
		mat `b0_uid'		= r(b0)
		mat `S_uid'			= r(S)
		mat `V_uid'			= r(V)
		
		di as text "Underidentification test: `testdesc'"
		if "`vcedesc1'"~="" {
			di as text "  `vcedesc1'"
		}
		if "`vcedesc2'"~="" {
			di as text "  `vcedesc2'"
		}
		if "`vcedesc3'"~="" {
			di as text "  `vcedesc3'"
		}
		di as text "j=" as res %8.2f `j_uid' as text "  Chi-sq(" as res %3.0f `df_uid' as text ") p-value=" as res %6.4f `p_uid'

		// swflag = jgmm2s, regressor-by-regressor
		// always use xtabond2 options if available
		if `swflag' & `K'>1 {
			tempname umat
			local nendo			: word count `endo'
			
			if `jgmm2sflag' {
				// no need to repeat results for first regressor
				mat `umat' = (`j_uid', `p_uid')
	
				// set up loop for other endog
				gettoken v1 vrest	: endo
				local vlist			`vrest' `v1'
				local firstvar 2
			}
			else {
				local vlist `endo'
				local firstvar 1
			}
			local sw_options								///
					partial(`inexog')						///
					jgmm2s									/// force jgmm2s
					full									///
					`vceopt'								///
					`rkopt'									///
					`center'								///
					`noconstant'							///
					`xtabond2options'						///
					dofminus(`dofminus')
			
			forvalues i=`firstvar'/`nendo' {
				gettoken v1 vrest	: vlist
				`qui' di as text "Calling ranktest to obtain jgmm2s underid statistic with first var=`v1'..." _c
				`qui' di as text "Options passed to ranktest: `sw_options'"
				`qui' ranktest (`v1' `vrest') (`exexog') `wtexp' if `touse', `sw_options'
				mat `umat' = nullmat(`umat') \ (`r(chi2)', `r(p)')
				local vlist			`vrest' `v1'
			}
			mat colnames `umat'	= chi2 p
			mat rownames `umat'	= `endo'
			
			di
			di as text "2-step GMM J underidentification stats by regressor:"
			tokenize `endo'
			forvalues i=1/`nendo' {
				di	as text "j=" as res %8.2f el(`umat',`i',1)					///
					as text "  Chi-sq(" as res %3.0f `df_uid'					///
					as text ") p-value=" as res %6.4f el(`umat',`i',2)			///
					as text _col(40) "``i''"
			}
		}
		
	}

******************* estimations complete ************************************************

	return scalar N				= `N'
	if `N_clust'~=. {
		return scalar N_clust	= `N_clust'
	}
	if `overidflag' {
		return scalar j_oid		= `j_oid'
		return scalar p_oid		= `p_oid'
		return scalar df_oid	= `df_oid'
		if `b_oid'[1,1] ~= . {
			return matrix b0_oid	= `b0_oid'
			return matrix S_oid		= `S_oid'
			return matrix V_oid		= `V_oid'
			return matrix b_oid		= `b_oid'
		}
	}
	if `underidflag' {
		return scalar j_uid		= `j_uid'
		return scalar p_uid		= `p_uid'
		return scalar df_uid	= `df_uid'
		if `swflag' & `K'>1 {
			return mat	sw_uid	= `umat'
		}
		if `b_uid'[1,1] ~= . {
			return matrix b0_uid	= `b0_uid'
			return matrix S_uid		= `S_uid'
			return matrix V_uid		= `V_uid'
			return matrix b_uid		= `b_uid'
		}
	}
	return local vceopt			`vceopt'
	return local rkstat			`rkstat'
	return local rkopt			`rkopt'

end		// end underid


********************************************************************************

program define get_model_specs, rclass
	version 13.1
	syntax  [ ,											///
				esample(varname)						/// specifically refers to original estimation sample
				touse(varname)							/// may refer to created sample with more obs as in xtabond2
				wvar(varname)							///
				EQxtabond2(string)						/// specific to xtabond2
				keepall									/// specific to xtabond2
				debugflag(int 0)						///
				*										///
		]

	return clear
	// Need to pass `wvar' so that values saved in e(wt) can be assigned to it
	if "`e(cmd)'" == "xtabond2" {
		// require matafavor = speed
		if c(matafavor) ~= "speed" {
			di as err "error: support for xtabond2 requires matafavor to be set to speed"
			di as err "       see {help mata_set:help mata set}"
			exit 198
		}
		make_xtabond2_data, wvar(`wvar') touse(`touse') eq(`eqxtabond2') `keepall' debugflag(`debugflag')
	}
	if "`e(cmd)'"=="xtdpdgmm" {
		make_xtdpdgmm_data, touse(`touse') wvar(`wvar') debugflag(`debugflag')
	}
	if "`e(cmd)'"=="ivreg2" | "`e(cmd)'"=="ivreg2h" {
		parse_ivreg2, touse(`touse') wvar(`wvar')
	}
	if "`e(cmd)'"=="ivregress" {
		parse_ivregress, touse(`touse') wvar(`wvar')
	}
	if "`e(cmd)'"=="xtivreg2" {
		parse_xtivreg2, touse(`touse') wvar(`wvar')
	}
	if "`e(cmd)'"=="xtivreg" {
		parse_xtivreg, touse(`touse') wvar(`wvar')
	}
	if "`e(cmd)'"=="xthtaylor" {
		parse_xthtaylor, touse(`touse') wvar(`wvar')
	}


	// Assemble options spec for vce calc by avar
	// `cluster' = "cluster( <varlist> )"
	// `clustvar' = "`clustvar1' `clustvar2'"
	local vceopt	"`r(robust)' `r(cluster)' bw(`r(bw)') kernel(`r(kernel)') `r(psd)'"

	return add

	return local cmd		"`e(cmd)'"

	return local vceopt		"`vceopt'"

end		// end get_model_specs


program define parse_ivreg2, rclass
	version 13.1
	syntax	[ ,								///
				touse(varname)				///
				wvar(varname)				///
		]
		
	if `e(endog_ct)'==0 {
		di as err "error - no endogenous regressors in IV estimation"
		exit 198
	}

	qui replace `touse'=e(sample)
	if "`e(wexp)'"~="" {
		qui replace `wvar' `e(wexp)'
	}

	local kernel			`e(kernel)'
	local bw				`e(bw)'
	if "`e(vcetype)'"=="Robust" {
		local robust		robust
	}
	if "`e(clustvar)'"~="" {							//  enter if 1- or 2-way clustering
		local cluster		cluster(`e(clustvar)')		//  = "cluster( <varlist> )"
		local clustvar		`e(clustvar)'				//  = <varlist> (1- or 2-way clustering)
		if "`e(clustvar1)'"=="" {
			local clustvar1		`clustvar'				//  1-way clustering
		}
		else {
			local clustvar1		`e(clustvar1)'			//  var1 of 2-way clustering
		}
		if "`e(clustvar2)'"~="" {						//  2-way clustering
			local clustvar2		`e(clustvar2)'
		}
	}

	local cons		= e(cons) + e(partialcons)		// spec of ORIGINAL model, not after cons possibly partialled out
	if ~`cons' {
		local noconstant noconstant
	}
	local small				`e(small)'
	local depvar			`e(depvar)'
	local endo				`e(instd)'
	local inexog			`e(inexog)'
	local exexog			`e(exexog)'
	if e(center) {
		local center		center
	}

	// ivreg2h generated instruments
	if "`e(cmd)'"=="ivreg2h" {
		local exexog `exexog' `e(geninsts)'
	}
	// ivreg2h panel option(s) not currently supported
	if "`e(cmd)'"=="ivreg2h" & "`e(xtmodel)'"~="" {
		di as err "Error: ivreg2h panel-data estimation not currently supported"
		exit 601
	}

	// misc
	if "`e(vce'"=="psd0" | "`e(vce'"=="psda" {
		local psd	`e(vce)'
	}

* Return values
	return local depvar			`depvar'
	return local endo			`endo'
	return local inexog			`inexog'
	return local exexog			`exexog'
	return scalar N				= e(N)
	return scalar N_clust		= e(N_clust)			//  in case of 2-way clustering, N_clust=min(N_clust1,N_clust2)
	return scalar N_clust1		= e(N_clust1)
	return scalar N_clust2		= e(N_clust2)
	return local cluster		`cluster'				//  = "cluster( <varlist> )"
	return local clustvar		`clustvar'				//  = <varlist> = list of cluster variables (can be 1 or 2)
	return local clustvar1		`clustvar1'				//  = <varname 1>
	return local clustvar2		`clustvar2'				//  = <varname 2>
	return local kernel			`kernel'
	return local bw				`bw'
	return scalar dofminus		= e(dofminus)
	return local psd			`psd'
	return scalar cons			= `cons'
	return local noconstant		`noconstant'
	return local small			`small'
	return local robust			`robust'
	return local wtype			`e(wtype)'
	return local wexp			`e(wexp)'
	return local wtexp			[`e(wtype)'`e(wexp)']
	return local center			`center'

	if "`model'"=="gmm2s" {
		return local gmm2s		gmm2s
	}

end			//  end parse_ivreg2

program define parse_xtivreg2, rclass
	version 13.1
	syntax	[ ,								///
				touse(varname)				///
				wvar(varname)				///
			]

	local xtmodel		"`e(xtmodel)'"
	if "`xtmodel'"~="fe" & "`xtmodel'"~="fd" {
		di as err "error - only FE and FD estimation supported with xtivreg2"
		exit 198
	}

	// Most of the parsing is done by parse_ivreg2
	parse_ivreg2, touse(`touse') wvar(`wvar')

	if "`xtmodel'"=="fe" {
		local singleton		"`e(singleton)'"
	}
	else {
		local singleton		=0
	}

	// Add macros to those returned by parse_ivreg2
	return add
	return local singleton		`singleton'
	return local xtmodel		`xtmodel'
	return local ivar			`e(ivar)'
	return scalar N_g			= e(N_g)
	return scalar g_min			= e(g_min)
	return scalar g_max			= e(g_max)
	return scalar g_avg			= e(g_avg)
	return scalar dofminus		= e(dofminus)		//  For iid FE case sigmas, adjustment for #groups needed

end			//  end parse_xtivreg2

program define parse_xtivreg, rclass
	version 13.1
	syntax	[ ,								///
				touse(varname)				///
				wvar(varname)				///
		]

	qui replace `touse'=e(sample)		
	if "`e(wexp)'"~="" {
		qui replace `wvar' `e(wexp)'
	}
	
	local xtmodel		`e(model)'
	if "`xtmodel'"=="fe" {
		local dofminus	= e(N_g)			//  For iid FE case sigmas, adjustment for #groups needed
	}
	else {
		local dofminus	= 0
	}
	// xtivreg uses small-sample adjustment; "small" option changes only z or t etc.
	local small			"small"
	// Bizarrely, xtivreg,fd puts a D operator in front of depvar but nowhere else
	local depvar		"`e(depvar)'"
	tsunab depvar 		: `depvar'
	if "`xtmodel'"=="fd" {
		local endo		"d.(`e(instd)')"
		tsunab endo		: `endo'
		local insts		"d.(`e(insts)')"
		tsunab insts	: `insts'
	}
	else {
		local endo		"`e(instd)'"
		tsunab endo		: `endo'
		local insts		"`e(insts)'"
		tsunab insts	: `insts'
	}

	// Full colnames have TS operators in front of them already
	local x					: colfullnames(e(b))
	local x					: subinstr local x "_cons" "", count(local cons)
	local inexog			: list x - endo
	local exexog			: list insts - inexog

	// Exog to include in tests ... but check first
	local check				: list tinexog - inexog
	local check				: word count `check'
	if `check' > 0 {
		di as err "syntax error - variable listed in testexog(.) but not in exogenous regressors"
		exit 198
	}
	local inexog			: list inexog - tinexog		// remove from inexog and add to endo
	local endo				: list endo   | tinexog
	local exexog			: list exexog | tinexog

	if "`xtmodel'"=="fe" {					//	We impose no constant in FE model
		local cons 			=0					//  Overrides cons created by count above
	}
	if ~`cons' {
		local noconstant	"noconstant"		
	}

	tokenize `e(vce)'
	if "`e(vce)'" == "robust" {
		local robust		"robust"
	}
	if "`e(clustvar)'"~="" {							//  1-way clustering
		local cluster		"cluster(`e(clustvar)')"	//  = "cluster( <varname> )"
		local clustvar1		"`e(clustvar)'"				//  = <varname>
		local robust		"robust"					//  cluster=>robust
	}

	// Return values
	return local tvar			`e(tvar)'
	return local ivar			`e(ivar)'
	return local depvar			`depvar'
	return local endo			`endo'
	return local inexog			`inexog'
	return local exexog			`exexog'

	return local cons			= `cons'
	return local noconstant		`noconstant'
	return local small			`small'
	return local robust			`robust'
	return local cluster		`cluster'				//  = "cluster( <varlist> )"
	return local clustvar		`clustvar'				//  = <varlist> = list of cluster variables (can be 1 or 2)
	return local clustvar1		`clustvar1'				//  = <varname 1>
	return scalar N				= e(N)
	return scalar dofminus		= `dofminus'
	return scalar N_g			= e(N_g)
	return scalar g_min			= e(g_min)
	return scalar g_max			= e(g_max)
	return scalar g_avg			= e(g_avg)
	return scalar Tbar			= e(Tbar)
	return local xtmodel		`xtmodel'
	return scalar sig_e2		= (e(sigma_e))^2
	return scalar sig_u2		= (e(sigma_u))^2

******* zeros by default or if not supported  ********
	return local singleton		=0

end			//  end parse_xtivreg

program define parse_xthtaylor, rclass
	version 13.1
	syntax	[ ,								///
				touse(varname)				///
				wvar(varname)				///
		]

	qui replace `touse'=e(sample)		
	if "`e(wexp)'"~="" {
		qui replace `wvar' `e(wexp)'
	}

	if "`e(title)'"=="Amemiya-MaCurdy" {
		local xtmodel	amacurdy
	}
	else {
		local xtmodel	htaylor
	}	
	local dofminus	= 0

	local depvar			`e(depvar)'
	local TVexog			`e(TVexogenous)'
	local TVendo			`e(TVendogenous)'
	local TIexog			`e(TIexogenous)'
	local TIendo			`e(TIendogenous)'

	// Full colnames have TS operators in front of them already
	local x					: colfullnames(e(b))
	local x					: subinstr local x "_cons" "", count(local cons)
	if ~`cons' {
		local noconstant	"noconstant"		
	}

	tokenize `e(vce)'
	if "`e(vce)'" == "robust" {
		local robust		"robust"
	}
	if "`e(clustvar)'"~="" {							//  1-way clustering
		local cluster		cluster(`e(clustvar)')		//  = "cluster( <varname> )"
		local clustvar1		`e(clustvar)'				//  = <varname>
		local robust		robust						//  cluster=>robust
	}

	// Return values
	return local tvar			`e(tvar)'
	return local ivar			`e(ivar)'
	return local depvar			`depvar'
	return local endo			`endo'
	return local TVexog			`TVexog'
	return local TVendo			`TVendo'
	return local TIexog			`TIexog'
	return local TIendo			`TIendo'

	return local cons			= `cons'
	return local noconstant		`noconstant'
	return local small			`small'
	return local robust			`robust'
	return local cluster		`cluster'				//  = "cluster( <varlist> )"
	return local clustvar		`clustvar'				//  = <varlist> = list of cluster variables (can be 1 or 2)
	return local clustvar1		`clustvar1'				//  = <varname 1>
	return scalar N				= e(N)
	return scalar dofminus		= `dofminus'
	return scalar N_g			= e(N_g)
	return scalar g_min			= e(g_min)
	return scalar g_max			= e(g_max)
	return scalar g_avg			= e(g_avg)
	return scalar Tbar			= e(Tbar)
	return local xtmodel		`xtmodel'
	return scalar sig_e2		= (e(sigma_e))^2
	return scalar sig_u2		= (e(sigma_u))^2

******* zeros by default or if not supported  ********
	return local singleton		=0

end			//  end parse_xthtaylor


program define parse_ivregress, rclass
	version 13.1
	syntax	[ ,								///
				touse(varname)				///
				wvar(varname)				///
		]

	qui replace `touse'=e(sample)
	if "`e(wexp)'"~="" {
		qui replace `wvar' `e(wexp)'
	}

	tokenize `e(vce)'
	if "`1'" == "hac" {
		local kernel		"`e(hac_kernel)'"
		local bw			=`3'+1
		local robust		"robust"
	}
	if "`e(vce)'" == "robust" {
		local robust		"robust"
	}
	if "`e(clustvar)'"~="" {							//  1-way clustering
		local cluster		"cluster(`e(clustvar)')"	//  = "cluster( <varname> )"
		local clustvar1		"`e(clustvar)'"				//  = <varname>
		local robust		"robust"					//  cluster=>robust
	}

	if "`e(moments)'"=="centered" {
		local center		center
	}

	local noconstant		`e(constant)'
	local cons				= ~("`noconstant'"=="noconstant")
	local small				`e(small)'
	local depvar			`e(depvar)'
	local endo 				`e(instd)'
	local inexog			`e(exogr)'
	local insts				`e(insts)'
	local exexog			: list insts - inexog


	// Return values
	return local depvar		`depvar'
	return local endo		`endo'
	return local inexog		`inexog'
	return local exexog		`exexog'
	return local cluster	`cluster'			//  = "cluster( <varname> )"
	return local clustvar	`clustvar1'			//  = <varname>
	return local clustvar1	`clustvar1'			//  = <varname>
	return local kernel		`kernel'
	return local bw			`bw'
	return scalar N			= e(N)
	return scalar N_clust	= e(N_clust)
	return scalar dofminus	= 0
	return local cons		= `cons'
	return local noconstant	`noconstant'
	return local small		`small'
	return local robust		`robust'
	return local wtype		`e(wtype)'
	return local wexp		`e(wexp)'
	return local wtexp		[`e(wtype)'`e(wexp)']
	return local center		`center'

end			//  end parse_ivregress


*******************************************************************************

*******************************************************************************
************************* misc utilities **************************************
*******************************************************************************

// internal version of fvstrip 1.01 ms 24march2015
// identical to ivreg2_fvstrip in ivreg2 4.1.01
// takes varlist with possible FVs and strips out b/n/o notation
// returns results in r(varnames)
// optionally also omits omittable FVs
// expand calls fvexpand either on full varlist
// or (with onebyone option) on elements of varlist

program define fvstrip, rclass
	version 12.1
	syntax [anything] [if] , [ dropomit expand onebyone NOIsily ]
	if "`expand'"~="" {												//  force call to fvexpand
		if "`onebyone'"=="" {
			fvexpand `anything' `if'								//  single call to fvexpand
			local anything `r(varlist)'
		}
		else {
			foreach vn of local anything {
				fvexpand `vn' `if'									//  call fvexpand on items one-by-one
				local newlist	`newlist' `r(varlist)'
			}
			local anything	: list clean newlist
		}
	}
	foreach vn of local anything {									//  loop through varnames
		if "`dropomit'"~="" {										//  check & include only if
			_ms_parse_parts `vn'									//  not omitted (b. or o.)
			if ~`r(omit)' {
				local unstripped	`unstripped' `vn'				//  add to list only if not omitted
			}
		}
		else {														//  add varname to list even if
			local unstripped		`unstripped' `vn'				//  could be omitted (b. or o.)
		}
	}
// Now create list with b/n/o stripped out
	foreach vn of local unstripped {
		local svn ""											//  initialize
		_ms_parse_parts `vn'
		if "`r(type)'"=="variable" & "`r(op)'"=="" {			//  simplest case - no change
			local svn	`vn'
		}
		else if "`r(type)'"=="variable" & "`r(op)'"=="o" {		//  next simplest case - o.varname => varname
			local svn	`r(name)'
		}
		else if "`r(type)'"=="variable" {						//  has other operators so strip o but leave .
			local op	`r(op)'
			local op	: subinstr local op "o" "", all
			local svn	`op'.`r(name)'
		}
		else if "`r(type)'"=="factor" {							//  simple factor variable
			local op	`r(op)'
			local op	: subinstr local op "b" "", all
			local op	: subinstr local op "n" "", all
			local op	: subinstr local op "o" "", all
			local svn	`op'.`r(name)'							//  operator + . + varname
		}
		else if"`r(type)'"=="interaction" {						//  multiple variables
			forvalues i=1/`r(k_names)' {
				local op	`r(op`i')'
				local op	: subinstr local op "b" "", all
				local op	: subinstr local op "n" "", all
				local op	: subinstr local op "o" "", all
				local opv	`op'.`r(name`i')'					//  operator + . + varname
				if `i'==1 {
					local svn	`opv'
				}
				else {
					local svn	`svn'#`opv'
				}
			}
		}
		else if "`r(type)'"=="product" {
			di as err "ivreg2_fvstrip error - type=product for `vn'"
			exit 198
		}
		else if "`r(type)'"=="error" {
			di as err "ivreg2_fvstrip error - type=error for `vn'"
			exit 198
		}
		else {
			di as err "ivreg2_fvstrip error - unknown type for `vn'"
			exit 198
		}
		local stripped `stripped' `svn'
	}
	local stripped	: list retokenize stripped						//  clean any extra spaces
	
	if "`noisily'"~="" {											//  for debugging etc.
		di as result "`stripped'"
	}

	return local varlist	`stripped'								//  return results in r(varlist)
end

* Utility to provide matching names.
* varnames is list of names to look up.
* namelist1 is where the names are looked for.
* namelist2 has the corresponding names that are selected/returned.
program define matchnames, rclass
	version 12.1
	args	varnames namelist1 namelist2

	local k1 : word count `namelist1'
	local k2 : word count `namelist2'
/*
	if `k1' ~= `k2' {
		di as err "namelist error - lengths of two lists do not match"
		exit 198
	}
*/
	foreach vn in `varnames' {
		local i : list posof `"`vn'"' in namelist1
		if `i' > 0 {
			local newname : word `i' of `namelist2'
		}
		else {
* Keep old name if not found in list
			local newname "`vn'"
		}
		local names "`names' `newname'"
	}
	local names	: list clean names
	return local names "`names'"
end

* Utility to list varnames
program define Disp 
	version 8.2
	syntax [anything] [, _col(integer 15) ]
	local len = 80-`_col'+1
	local piece : piece 1 `len' of `"`anything'"'
	local i 1
	while "`piece'" != "" {
		di in gr _col(`_col') "`first'`piece'"
		local i = `i' + 1
		local piece : piece `i' `len' of `"`anything'"'
	}
	if `i'==1 { 
		di 
	}
end


// Utility for creating xtabond2-transformed data
* make_xtabond2_data version 1.00.01 2jul2020
* author mes

program define make_xtabond2_data, rclass
	version 12.1
	syntax [ ,								///
				wvar(name)					///
				touse(name)					/// will refer to created sample with more obs
				panelvar(name)				///
				eqvar(name)					///
				timevar(name)				///
				hvar(name)					///
				consvar(name)				///
				cluster(namelist)			///
				keepall						///
				eq(string)					/// lev, diff, sys; default is estimation used
				REPORTonly					/// report only; restore data after running
				debugflag(int 0)			///
				debug						///
		]
	
	// All these will need to be created based on saved xtabond2 matrices:
	//   depvar endo inexog insts exexog clustvar1 clustvar2 wvar
	
	// flags
	local robustflag		= "`e(robust)'"~=""
	local debugflag			= `debugflag' | "`debug'"~=""
	local reportonlyflag	= "`reportonly'"~=""
	local weightflag		= "`e(wtype)'"~=""
	local pcaflag			= "`e(pca)'"~=""

	// In case of weights, need to work out mean of original weight variable, so do this first.
	if `weightflag' {
		local wtype "`e(wtype)'"
		// summarize doesn't like pweights but aweights will yield same results
		if "`wtype'"=="pweight" {
			local wtype "aweight"
		}
		tempvar tempwvar
		qui gen double `tempwvar' `e(wexp)' if e(sample)	//  xtabond2 saved normalized weights for pw and aw
		if "`wtype'"=="aweight" | `robustflag' {
			sum `tempwvar' if e(sample), meanonly			//  so get mean of original for later de-normalizing
			local wvarmean = r(mean)
		}
		else {												//  ...but not for fweights + classical VCE.
			local wvarmean = 1
		}
	}

	// before going further, preserve if this is only for reporting purposes
	if `reportonlyflag' {
		preserve
	}

	// defaults	
	if "`touse'"=="" {
		// default touse variable = __touse
		local touse		__touse
		qui gen byte	`touse' = .
	}
	else {
		cap confirm numeric variable `touse'
		if _rc {
			qui gen byte `touse' = .
		}
	}
	if "`wvar'"=="" & `weightflag' {
		// default weight variable = __wvar
		local wvar		__wvar
		qui gen double	`wvar' = .
	}
	else if `weightflag' {
		cap confirm numeric variable `wvar'
		if _rc {
			qui gen double `wvar' = .
		}
		else {
			qui recast double `wvar'
		}
	}
	// default names: __id, __eq, __t
	if "`panelvar'"=="" {
		local panelvar __id
		qui gen long `panelvar' = .
	}
	else {
		cap confirm numeric variable `panelvar'
		if _rc {
			qui gen long `panelvar' = .
		}
	}
	if "`eqvar'"=="" {
		local eqvar __eq
		qui gen long `eqvar' = .
	}
	else {
		cap confirm numeric variable `eqvar'
		if _rc {
			qui gen long `eqvar' = .
		}
	}
	if "`timevar'"=="" {
		local timevar __t
		qui gen long `timevar' = .
	}
	else {
		cap confirm numeric variable `timevar'
		if _rc {
			qui gen long `timevar' = .
		}
	}
	if "`consvar'"=="" {
		local consvar __cons
		qui gen double `consvar' = .
	}
	else {
		cap confirm numeric variable `consvar'
		if _rc {
			qui gen double `consvar' = .
		}
	}
	if "`hvar'"=="" {
		local hvar __h
		qui gen long `hvar' = .
	}
	else {
		cap confirm numeric variable `hvar'
		if _rc {
			qui gen long `hvar' = .
		}
	}

	// do this before manipulating data; needed for H matrix
	qui xtset
	local tmin		`r(tmin)'
	local tmax		`r(tmax)'
	local delta		`r(tdelta)'
	
	tempname b V Y X Z ideqt wt clustmat1 clustmat2 A1 A2 H		//  used for matrices
	mat `Y'			= e(Y)
	mat `X'			= e(X)
	mat `Z'			= e(Z)
	mat `A1'		= e(A1)
	mat `A2'		= e(A2)
	mat `H'			= e(H)
	// A2 may be missing
	local A2missing	= (`A2'[1,1]==.)
	// If one of Y, X or Z is missing, it's because svmat option wasn't used.
	if rowsof(`Y')==1 & `Y'[1,1]==. {
		di as err "Error: svmat option of xtabond2 required."
		exit 198
	}
	
	// increase number of obs
	local nobs = rowsof(`Y')
	// `nobs' can be < obs in untransformed dataset if there are unused rows etc.
	if `nobs' > _N {
		set ob `nobs'
	}
	
	// ideqt matrix added in xtabond2 version 03.04.00. Catch if not present.
	mat `ideqt'=e(ideqt)
	if rowsof(`ideqt')==1 & `ideqt'[1,1]==. {
		di as err "Error: xtabond2 saved matrix e(ideqt) not found"
		di as err "Must have xtabond2 version 03.04.00 or greater installed"
		di as err "To install, from within Stata type " _c
		di in smcl "{stata ssc install xtabond2 :ssc install xtabond2}"
		exit 111
	}

	// weight variable (if needed)
	if `weightflag' {
		mat `wt'=e(wt)									//  retrieve saved weight variable
		if rowsof(`wt')==1 & `wt'[1,1]==. {				//  and put values into tempvar `wvar'
			di as err "Error: xtabond2 weights variable e(wt) missing from saved results"
			exit 198
		}
		qui svmat double `wt'							//  xtabond2 weight variable has been normalized to mean=1;
		qui replace `wvar' = `wt'						//  will fix this below using `wvarmean'
		local wtexp "[`wtype'=`wvar']"					//  e.g. "[aw=<name of wvar>]"; used below
	}

	// clustvar matrices may or may not exist
	// apparently #1 is panel if only 1-way, #1 is time and #2 is panel if 2-way
	// if neither exist, either there is no clustering (e(robust) empty)
	// or the cluster variable is the id variable
	mat `clustmat1'	= e(clustid2)
	if rowsof(`clustmat1')==1 {
		// if the above didn't work, then e(clustid1) has the matrix if it exists
		mat `clustmat1'	= e(clustid1)
	}
	else  {
		// it worked, so e(clustid1) has the 2nd clustermatrix
		mat `clustmat2'	= e(clustid1)
	}	

	// Panel id (1), equation number (2), and time variable (3)
	// rename cols of matrix so that vars created have these names
	tempvar ideqt1 ideqt2 ideqt3
	mat colnames `ideqt'	= `ideqt1' `ideqt2' `ideqt3'
	qui svmat long `ideqt', names(col)
	qui replace `panelvar'	= `ideqt1'
	qui replace `eqvar'		= `ideqt2'
	qui replace `timevar'	= `ideqt3'
	// (re-)create panel and id vars
	local ivar		`e(ivar)'
	local tvar		`e(tvar)'
	cap drop `ivar'
	cap drop `tvar'
	qui gen	`ivar'	= `panelvar'
	qui gen `tvar'	= `timevar'


	// Work out whether to use levels data, diff data or both.
	tempname iv gmm ivgmm
	mat `iv'		=e(ivequation)
	mat `gmm'		=e(gmmequation)
	mat `ivgmm'		= nullmat(`iv') , nullmat(`gmm')
	qui count if `eqvar'==0

	local hasdiff	= r(N)>0 & r(N)<.
	qui count if `eqvar'==1
	local haslevel	= r(N)>0 & r(N)<.
	local usediff	= 0
	local uselevel	= 0
	local numcols=colsof(`ivgmm')
	forvalues i=1/`numcols' {
		if `ivgmm'[1,`i']==0 {
			local uselevel	=1
		}
		if `ivgmm'[1,`i']==1 {
			local usediff	=1
		}
		if `ivgmm'[1,`i']==2 {
			local uselevel	=1
			local usediff	=1
		}
	}

	// Above is overridden by user-provided eq(.) if provided
	if "`eq'" ~= "" {
		if "`eq'"=="diff" {			// diff data always present
			local usediff	=1
			local uselevel	=0
		}
		else if "`eq'"=="lev" {		// but level data might not be present
			if `haslevel'==0 {
				di as err "error - xtabond2 did not save level equation data"
				exit 198
			}
			local usediff	=0
			local uselevel	=1
		}
		else if "`eq'"=="sys" {		// but level data might not be present
			if `haslevel'==0 {
				di as err "error - xtabond2 did not save level equation data"
				exit 198
			}
			local usediff	=1
			local uselevel	=1
		}
		else {
			di as err "illegal option: eq(`eq')"
			exit 198
		}
	}

	// Set touse and xtmodel macro.
	// xtmodel corresponds to underid estimation rather than original xtabond2 estimation.
	if `usediff' {
		qui replace `touse'=1 if `eqvar'==0
	}
	if `uselevel' {
		qui replace `touse'=1 if `eqvar'==1
	}
	qui replace `touse'=0 if `touse'==.
	
	if `usediff' & `uselevel' {
		local xtmodel	sys
	}
	else if `usediff' {
		local xtmodel	diff
	}
	else if `uselevel' {
		local xtmodel	lev
	}
	else {						// should never reach here
		di as err "internal underid error in parsing xtabond2"
		exit 198
	}

	// e(esttype) = "system" or "difference"
	// ... except estimation may use level equation only and still call it "system".
	// e(transform) = "first differences" or "orthogonal deviations"
	// ... estimation may use level equation only so no transform implied
	if `usediff' {
		local transform		`e(transform)'
	}
	
	if `debugflag' {
		di "hasdiff  = `hasdiff'"
		di "usediff  = `usediff'"
		di "haslevel = `haslevel'"
		di "uselevel = `uselevel'"
	}
		
	// Clustering
	tokenize `e(clustvar)'									//  may be empty, 1 var or 2 vars
	local clustname1		`1'								//  at least 1-way clustering
	local clustname2		`2'								//  possibly 2-way clustering
	if ("`e(clustvar)'"=="") & ~`robustflag' {				//  no clustering unusual in xtabond2 estimation but allowed
		local clustvar1										//  ... so do nothing and clear macros just in case
		local clustvar2
		local N_clust			= .
		local N_clust1			= .
		local N_clust2			= .
		local vceopt
	}
	else if ("`e(clustvar)'"=="") & `robustflag' {			//  in xtabond2, robust => cluster on default id variable
		local clustvar1			`ivar'
		local clustvar2
		local clustname1		`ivar'						// for display purposes
		local clustname2
		local N_clust			= `e(N_g)'
		local N_clust1			= `e(N_g)'
		local N_clust2			= .
		local vceopt			cluster(`ivar')
	}
	else if "`clustname1'"~="" & "`clustname2'"=="" {		// one clustvar specified in e(.) matrix
		tempvar c1											// name of column = name of variable
		mat colnames `clustmat1' = `c1'
		svmat long `clustmat1', names(col)					// cluster variable is now tempvar `c1'
		if "`cluster'"=="" {
			// no variable or varname provided
			local clustvar1		__cluster_`clustname1'		// in case the name is already used by e.g. ivar
			rename `c1'			__cluster_`clustname1'
		}
		else {
			// use first one only
			tokenize `cluster'
			local clustvar1 `1'
			cap confirm numeric variable `clustvar1'
			if _rc {
				qui gen long `clustvar1' = `c1'
			}
			else {
				qui recast long `clustvar1', force
				qui replace `clustvar1' = `c1'
			}
		}
		local clustvar2
		local clustname2
		local N_clust			= `e(Nclust1)'
		local N_clust1			= `e(Nclust1)'
		local N_clust2			= .
		local vceopt			cluster(`clustvar1')
	}
	else if "`clustname1'"~="" & "`clustname2'"~="" {		// two clustvars specified in e(.) matrix
		tempvar c1 c2										// name of column = name of variable
		mat colnames `clustmat1' = `c1'
		mat colnames `clustmat2' = `c2'
		svmat long `clustmat1', names(col)
		if "`cluster'"=="" {
			// no variable or varname provided
			local clustvar1		__cluster_`clustname1'		// in case the name is already used by e.g. ivar
			rename `c1'			__cluster_`clustname1'
		}
		else {
			// use first one only
			tokenize `cluster'
			local clustvar1 `1'
			cap confirm numeric variable `clustvar1'
			if _rc {
				qui gen long `clustvar1' = `c1'
			}
			else {
				qui recast long `clustvar1', force
				qui replace `clustvar1' = `c1'
			}
		}
		svmat long `clustmat2', names(col)
		if "`cluster'"=="" {
			// no variable or varname provided
			local clustvar2		__cluster_`clustname2'		// in case the name is already used by e.g. ivar
			rename `c2'			__cluster_`clustname2'
		}
		else {
			// use second one only
			tokenize `cluster'
			local clustvar2 `2'
			cap confirm numeric variable `clustvar2'
			if _rc {
				qui gen long `clustvar2' = `c2'
			}
			else {
				qui recast long `clustvar2', force
				qui replace `clustvar2' = `c2'
			}
		}
		local N_clust			= `e(Nclust1)'
		local N_clust1			= `e(Nclust1)'
		local N_clust2			= `e(Nclust2)'
		local vceopt			cluster(`clustvar1' `clustvar2')
	}
	else {
		di as err "Error: cannot determine cluster variables if any"
		exit 198
	}

	// Now clustering, set remaining vars

	// Create lists of col names of X and Z matrices.
	local Xnames	: colnames `X'
	local Znames	: colfullnames `Z'
	// Fix spaces in full names
	local Znames	: subinstr local Znames "Diff eq:"   "Diff_eq:"   , all
	local Znames	: subinstr local Znames "Levels eq:" "Levels_eq:" , all
	local Znames	: subinstr local Znames "Orthog eq:" "Orthog_eq:" , all
	if `debugflag' {
		di
		di "Column dimensions:"
		di "X:      " colsof(`X')
		di "Z:      " colsof(`Z')
		di "A1:     " colsof(`A1')
		di "A2:     " colsof(`A2')
		di "H:      " colsof(`H')
		di "Znames: `: word count `Znames''"
		di
	}
	// xtabond2 e(Z) matrix may have empty (all zeros) column at the RHS.
	// These may NOT have column names.
	// Hence the number of columns of Z may > number of colnames of Z.
	// Address this here by removing empty columns.
	local lastZcol	: word count `Znames'
	if `lastZcol' < colsof(`Z') {
		// Have to do this in Mata since matrix too big for Stata's matrix commands.
		mata: st_matrix("`Z'", st_matrix("`Z'")[ ., (1..`lastZcol')])
		mat `A1'		= `A1'[1..`lastZcol', 1..`lastZcol']
		if ~`A2missing' {
			mat `A2'		= `A2'[1..`lastZcol', 1..`lastZcol']
		}
		if `debugflag' {
			di "Removing extraneous columns from Z..."
			di "Column dimensions:"
			di "X:      " colsof(`X')
			di "Z:      " colsof(`Z')
			di "A1:     " colsof(`A1')
			di "A2:     " colsof(`A2')
			di "Znames: `: word count `Znames''"
		}
	}

	// Y (depvar)
	local depvar "`e(depvar)'"
	tempvar depvar_t
	mat colnames `Y' = `depvar_t'
	qui svmat double `Y', names(col)

	// X (regressors)
	local colsofX = colsof(`X')
	forvalues i=1/`colsofX' {
		tempvar x`i'
		local Xnames_t `Xnames_t' `x`i''
	}
	mat colnames `X' = `Xnames_t'
	qui svmat double `X', names(col)
	// Z (IVs)
	local colsofZ = colsof(`Z')
	forvalues i=1/`colsofZ' {
		tempvar z`i'
		local Znames_t `Znames_t' `z`i''
	}
	mat colnames `Z' = `Znames_t'
	qui svmat double `Z', names(col)

	if `weightflag' {									//  xtabond2 incorporates weights in Y and Xs, so remove
		foreach var of varlist `depvar_t' `Xnames_t' {
			qui replace `var' = `var'/`wvar'
		}
		if ("`e(wtype)'"~="fweight") {
			qui replace `wvar' = `wvar' * `wvarmean'	//  and now finally recreate weight var by de-normalizing
		}
	}

	// Get original Stata names of endo and inexog variables from e(b).
	mat `b'=e(b)
	mat `V'=e(V)
	// xtabond2 may not have marked vars as omitted
	_ms_findomitted `b' `V'
	local bnames : colfullnames `b'
	local cons : list posof "_cons" in bnames
	local cons = (`cons'>0)
	
	// Collect list of omitted regressors.
	// Will exclude these from both X and Z lists unless keepall option specified.
	// Note that a var may be marked as omitted in b but not x or visa-versa,
	// so go through both and remove duplicates.
	local consomitflag		=0
	foreach var in `Xnames' `bnames' {
		_ms_parse_parts `var'
		if r(omit) {
			local omitted		`omitted' `var'
			local consomitflag	=("`var'"=="_cons")
		}
	}
	local omitted			: list uniq omitted
	// omitted macro has clean varnames with no b/n/o operators.
	fvstrip `omitted'
	local omitted_stripped	`r(varlist)'
	if `debugflag' {
		di "omitted: `omitted'"
		di "         `omitted_stripped'"
	}

	// Process Xs and Zs.
	
	// X = endo + inexog
	// Z = inexog + exexog

	// First Zs = inexog + exexog
	// Znames have FV notation in Xs and spaces removed from Z,
	// e.g. 1982b.year and Diff_eq:L4.y/1987

	if `debugflag' {
		di
		di "Znames (`: word count `Znames''): `Znames'"
		di "Znames_t (`: word count `Znames_t''): `Znames_t'"
		di
	}

	// pre-process pca names
	// pca option means "varnames" are numbers
	// change to have "pca_" prefix
	if `pcaflag' {
		local zcount	: word count `Znames'
		tokenize `Znames'
		local Znames	// clear it
		forvalues i=1/`zcount' {
			if real("``i''")<. {
				local Znames	`Znames' pca:``i''
			}
			else {
				local Znames	`Znames' ``i''
			}
		}
	}

	// Process Xnames and Znames.
	// if names the same and eq name prefix is used (GMM style), Z vars are identifiable by name,
	//   and if the name is the same the variable should be identical
	// if names the same and no eq name prefix is used (IV) style, Z vars can be different
	//   depending on whether they appear in the lev eqn, diff eqn, or both
	// relevent only for sys estimation
	local numXnames : word count `Xnames'
	local numZnames : word count `Znames'
	// classify regressors as sys, diff-only, level-only
	if (`hasdiff' & `haslevel') {
		// sys estimation so both eqns present
		forvalues i=1/`numXnames' {
			local Xvar		: word `i' of `Xnames'
			local Xvar_t 	: word `i' of `Xnames_t'
			qui count if `Xvar_t'~=0 & `touse' & `eqvar'==0
			local isdiff = r(N)>0
			qui count if `Xvar_t'~=0 & `touse' & `eqvar'==1
			local islevel = r(N)>0
			if `isdiff' & `islevel' {
				local Xnames_sys `Xnames_sys' `Xvar'
			}
			else if `isdiff' {
				local Xnames_diff_only `Xnames_diff_only' `Xvar'
			}
			else {
				local Xnames_lev_only `Xnames_lev_only' `Xvar'
			}
		}
	}
	if (`hasdiff' & `haslevel') {
		// sys estimation so both eqns present
		// restart Znames list
		// nb: prefix = "Orthog_eq:" treated the same as prefix = "Diff_eq:"
		forvalues i=1/`numZnames' {
			local Zvar		: word `i' of `Znames'
			local Zvar_t 	: word `i' of `Znames_t'
			local Zvar		: subinstr local Zvar ":" ":", count(local has_eq_prefix)
			local Zvar		: subinstr local Zvar "Diff_eq:"   "Diff_eq:",   count(local has_diff_prefix)
			local Zvar		: subinstr local Zvar "Orthog_eq:" "Orthog_eq:", count(local has_orthog_prefix)
			local Zvar		: subinstr local Zvar "Levels_eq:" "Levels_eq:", count(local has_level_prefix)
			local Zvar		: subinstr local Zvar "pca:"       "pca:",       count(local has_pca_prefix)
			if ~`has_eq_prefix' {
				// no equation prefix
				// 3 possibilities: variable is IV for diff only, lev only, or both
				// if diff only or lev only, change name
				qui count if `Zvar_t'~=0 & `touse' & `eqvar'==0
				local isdiff = r(N)>0
				qui count if `Zvar_t'~=0 & `touse' & `eqvar'==1
				local islevel = r(N)>0
				if `isdiff' & ~`islevel' {
					// IV for diff eqn but not level eqn
					local Znames_new `Znames_new' Diff_eq:`Zvar'
					local Znames_diff_only `Znames_diff_only' Diff_eq:`Zvar'
				}
				else if ~`isdiff' & `islevel' {
					// IV for level eqn but not diff eqn
					local is_X_lev_only		: list posof "`Zvar'" in Xnames_lev_only
					if `is_X_lev_only' {
						// if also a regressor, then should treat as exogenous and no renaming needed
						local Znames_new `Znames_new' `Zvar'
						local Znames_lev_only `Znames_lev_only' `Zvar'
					}
					else {
						// not a regressor, so renaming needed
						local Znames_new `Znames_new' Levels_eq:`Zvar'
						local Znames_lev_only `Znames_lev_only' Levels_eq:`Zvar'
					}
				}
				else {
					// IV for both diff and level eqns
					local Znames_new `Znames_new' `Zvar'
					local Znames_sys_only `Znames_sys_only' `Zvar'
				}
			}
			else {
				// IV has equation prefix so nothing to change
				// will be either diff prefix or orthog prefix
				local Znames_new `Znames_new' `Zvar'
				if `has_diff_prefix' | `has_orthog_prefix' {
					local Znames_diff_only `Znames_diff_only' `Zvar'
				}
				else if `has_level_prefix' {
					local Znames_lev_only `Znames_lev_only' `Zvar'
				}
				else {
					local Znames_sys_only `Znames_sys_only' `Zvar'
				}
			}
		}
		if `debugflag' {
			di "Znames     (`: word count `Znames'') = `Znames'"
			di "Znames_new (`: word count `Znames_new'') = `Znames_new'"
		}
		local Znames `Znames_new'
	}
	else if `hasdiff' {
		// only diff eqn present
		local Znames_diff_only	`exexog'
	}
	else if `haslevel' {
		// only lev eqn present
		local Znames_lev_only	`exexog'
	}
	else {
		di as err "internal make_xtabond2_data error"
		exit 198
	}

	local endo			: list Xnames - Znames
	matchnames "`endo'" "`Xnames'" "`Xnames_t'"
	local endo_t		`r(names)'
	local Xinexog		: list Xnames - endo
	matchnames "`Xinexog'" "`Xnames'" "`Xnames_t'"
	local Xinexog_t		`r(names)'
	local exexog		: list Znames - Xinexog
	matchnames "`exexog'" "`Znames'" "`Znames_t'"
	local exexog_t		`r(names)'
	local Zinexog		: list Znames - exexog
	matchnames "`Zinexog'" "`Znames'" "`Znames_t'"
	local Zinexog_t		`r(names)'
	if `hasdiff' {
		local exexog_diff	: list exexog      - Znames_lev_only
		local exexog_diff	: list exexog_diff - Znames_sys_only
		matchnames "`exexog_diff'" "`Znames'" "`Znames_t'"
		local exexog_diff_t	`r(names)'
	}
	if `haslevel' {
		local exexog_lev	: list exexog      - Znames_diff_only
		local exexog_lev	: list exexog_lev  - Znames_sys_only
		matchnames "`exexog_lev'" "`Znames'" "`Znames_t'"
		local exexog_lev_t	`r(names)'
	}
	if `hasdiff' & `haslevel' {
		local exexog_sys	: list exexog      - Znames_lev_only
		local exexog_sys	: list exexog_sys  - Znames_diff_only
		matchnames "`exexog_sys'" "`Znames'" "`Znames_t'"
		local exexog_sys_t	`r(names)'
	}

	if `debugflag' {
		di
		di "Xnames (`: word count `Xnames''): `Xnames'"
		di "Xnames_t (`: word count `Xnames_t''): `Xnames_t'"
		di "Znames (`: word count `Znames''): `Znames'"
		di "Znames_t (`: word count `Znames_t''): `Znames_t'"
		di "Znames_diff_only (`: word count `Znames_diff_only'') = `Znames_diff_only'"
		di "Znames_lev_only (`: word count `Znames_lev_only'') = `Znames_lev_only'"
		di "Znames_sys_only (`: word count `Znames_sys_only'') = `Znames_sys_only'"
		di
		di "endo   (`: word count `endo''): `endo'"
		di "endo_t (`: word count `endo_t''): `endo_t'"
		di "Xinexog   (`: word count `Xinexog''): `Xinexog'"
		di "Xinexog_t (`: word count `Xinexog_t''): `Xinexog_t'"
		di "Zinexog   (`: word count `Zinexog''): `Zinexog'"
		di "Zinexog_t (`: word count `Zinexog_t''): `Zinexog_t'"
		di "exexog       (`: word count `exexog''): `exexog'"
		di "exexog_t     (`: word count `exexog_t''): `exexog_t'"
		di "exexog_diff  (`: word count `exexog_diff''): `exexog_diff'"
		di "exexog_lev   (`: word count `exexog_lev''): `exexog_lev'"
		di "exexog_sys   (`: word count `exexog_sys''): `exexog_sys'"
		di
	}

	// create macro with first lags used in diff eqn
	local num_exexog_diff	: word count `exexog_diff'
	if `num_exexog_diff' & ~`pcaflag' {
		mata: M = J(0,3,"")
		foreach vn of local exexog_diff {
			_ms_parse_parts `vn'
			local ts_op `r(ts_op)'
			if "`ts_op'"=="L" {
				local ts_op L1
			}
			mata: M = M \ ("`vn'", "`ts_op'", "`r(name)'")
		}
		mata: M = sort(M,(3,2))
		local numz : word count `exexog_diff'
		mata: st_local("thisvar", M[1,3])
		mata: st_local("firstlags", M[1,1])
		forvalues i=1/`numz' {
			mata: st_local("var", M[`i',3])
			if "`var'"~="`thisvar'" {
				mata: st_local("thislag", M[`i',1])
				local firstlags `firstlags' `thislag'
				local thisvar `var'
			}
		}
		matchnames "`firstlags'" "`Znames'" "`Znames_t'"
		local firstlags_t	`r(names)'
	}

	
	// Error checks
	if `: word count `exexog'' ~= `: word count `exexog_t'' {
		di as err "internal underid/xtabond2 error - number of exexog names differs from number of temp names"
		exit 198
	}
	if `: word count `Xinexog'' ~= `: word count `Xinexog_t'' {
		di as err "internal underid/xtabond2 error - number of inexog names differs from number of temp names"
		exit 198
	}
	if `: word count `Zinexog'' ~= `: word count `Zinexog_t'' {
		di as err "internal underid/xtabond2 error - number of inexog names differs from number of temp names"
		exit 198
	}
	if `: word count `endo'' ~= `: word count `endo_t'' {
		di as err "internal underid/xtabond2 error - number of endo names differs from number of temp names"
		exit 198
	}
	local X_missing	: list Zinexog - Xinexog
	if "`X_missing'" ~= "" {
		di as err "internal make_xtabond2_data error: `X_missing' from Zinexog"
		exit 198
	}
	local Z_missing	: list Xinexog - Zinexog
	if "`Z_missing'" ~= "" {
		di as err "internal make_xtabond2_data error: `Z_missing' from Xinexog"
		exit 198
	}

	// Now create final list of included exogenous
	local inexog	`Xinexog'
	local inexog_t	`Xinexog_t'

	// Remove omitted vars and base factor vars from inexog and endo lists.
	// Also remove factor variable b/n/o notation.
	if "`omitted'"~="" & "`keepall'"=="" {
		di as text "Dropping `omitted' (omitted or base factor variable)..."
		
		// First endo.
		fvstrip `endo'
		local endo_stripped	`r(varlist)'
		local endo_dropped	: list omitted_stripped & endo_stripped
		if "`endo_dropped'" ~= "" {
			// Remove from endo list.
			matchnames "`endo_dropped'" "`endo_stripped'" "`endo_t'"
			local endo_dropped_t	`r(names)'
			local endo				: list endo_stripped - endo_dropped
			local endo_t			: list endo_t - endo_dropped_t
		}

		// inexog
		fvstrip `inexog'
		local inexog_stripped	`r(varlist)'
		if `debugflag' {
			di
			di "omitted=`omitted'"
			di "omitted_stripped=`omitted_stripped'"
			di "inexog=`inexog'"
			di "inexog_stripped=`inexog_stripped'"
			di
		}
		local inexog_dropped	: list omitted_stripped & inexog_stripped
		if "`inexog_dropped'" ~= "" {
			// Remove from inexog list.
			matchnames "`inexog_dropped'" "`inexog_stripped'" "`inexog_t'"
			local inexog_dropped_t	`r(names)'
			local inexog				: list inexog_stripped - inexog_dropped
			local inexog_t			: list inexog_t - inexog_dropped_t
		}
	}

	// useful macros
	local consname_old _cons
	local consname_new `consvar'
	// _cons, if it exists, needs special treatment, since _cons not a legal varname.
	// NB: won't exist or be used if level data not used.
	// replace with name __cons (default) or what user provied
	local Xnames		: subinstr local Xnames "`consname_old'" "`consname_new'", word
	local Znames		: subinstr local Znames "`consname_old'" "`consname_new'", word
	local inexog		: subinstr local inexog "`consname_old'" "`consname_new'", word


	// Clean lists
	local exexog	: list clean exexog
	local exexog_t	: list clean exexog_t
	local inexog	: list clean inexog
	local inexog_t	: list clean inexog_t
	local endo		: list clean endo
	local endo_t	: list clean endo_t

	if `debugflag' {
		di
		di "exexog (`: word count `exexog''): `exexog'"
		di "exexog_t (`: word count `exexog_t''): `exexog_t'"
		di "inexog (`: word count `inexog''): `inexog'"
		di "inexog_t (`: word count `inexog_t''): `inexog_t'"
		di "endo (`: word count `endo''): `endo'"
		di "endog_t (`: word count `endo_t''): `endo_t'"
		di
	}

	// Check: does original number of coeffs match number of Xs?
	if colsof(`X') ~= colsof(`b') {
		di as err "underid/xtabond2 error - number of coefficients does not match number of columns in e(X)"
		exit 103
	}

	if `debugflag' {
		di
		di "exexog (`: word count `exexog''): `exexog'"
		di "exexog_t (`: word count `exexog_t''): `exexog_t'"
		di "inexog (`: word count `inexog''): `inexog'"
		di "inexog_t (`: word count `inexog_t''): `inexog_t'"
		di "endo (`: word count `endo''): `endo'"
		di "endog_t (`: word count `endo_t''): `endo_t'"
		di
	}

	// If level data available, constant can appear in coef list bnames.
	// But if using only diff data, won't appear in inexogcnames.
	// So remove.
	if `haslevel'==1 & `uselevel'==0 & `cons' {
		local posofcons			: list posof "`consname_new'" in inexog
		local consname_new_t	: word `posofcons' of `inexog_t'
		local inexog			: list inexog   - consname_new
		local inexog_t			: list inexog_t - consname_new_t
		di as text "Dropping constant (in lev but not in diff data)..."
	}

	if `debugflag' {
		di
		di "exexog (`: word count `exexog''): `exexog'"
		di "exexog_t (`: word count `exexog_t''): `exexog_t'"
		di "inexog (`: word count `inexog''): `inexog'"
		di "inexog_t (`: word count `inexog_t''): `inexog_t'"
		di "endo (`: word count `endo''): `endo'"
		di "endog_t (`: word count `endo_t''): `endo_t'"
		di
	}

	// Error checks
	if `: word count `exexog'' ~= `: word count `exexog_t'' {
		di as err "internal underid/xtabond2 error - number of exexog names differ from number of temp names"
		exit 198
	}
	if `: word count `inexog'' ~= `: word count `inexog_t'' {
		di as err "internal underid/xtabond2 error - number of inexog names differ from number of temp names"
		exit 198
	}
	if `: word count `endo'' ~= `: word count `endo_t'' {
		di as err "internal underid/xtabond2 error - number of endo names differ from number of temp names"
		exit 198
	}
	
	// deal with duplicates in IV list
	local exexog_unique	: list uniq exexog
	local exexog_dups	: list dups exexog
	if "`exexog_dups'"~="" {
		// Remove from exexog list.
		matchnames "`exexog_unique'" "`exexog'" "`exexog_t'"
		local exexog_unique_t	`r(names)'
		local exexog			`exexog_unique'
		local exexog_t			`exexog_unique_t'
	}
	
	// Variable counts.
	local nendog	: word count `endo_t'
	local ninexog	: word count `inexog_t'
	local nexexog	: word count `exexog_t'

	// Prepare and report basic xtabond2 estimation details
	// Do this now so that counts refer to xtabond2 estimation
	sum `touse' `wtexp' if `touse', meanonly
	local N = r(N)
	// Observation counts reported to user
	if `usediff' {
		sum `touse' if `eqvar'==0 `wtexp', meanonly
		local N_diff = r(N)
	}
	else {
		local N_diff = 0
	}
	if `uselevel' {
		sum `touse' if `eqvar'==1 `wtexp', meanonly
		local N_lev = r(N)
	}
	else {
		local N_lev = 0
	}
	di
	di as text "Estimation using xtabond2-transformed data:"
	di as text "Number of obs:     diff eqn = " `N_diff' ", lev eqn = " `N_lev' ", total = " `N'
	di as text "Number of panels:  `e(N_g)'"
	if "`clustname1'`clustname2'"~="" {
		di as text "Clustering on:     `clustname1' `clustname2'"
	}
	di as text "Dep var:           `depvar'""
	di as text "Endog Xs (`nendog'):" _c
	Disp `endo', _col(20)
	di as text "Exog Xs (`ninexog'):" _c
	Disp `inexog', _col(20)
	di as text "Excl IVs (`nexexog'):" _c
	Disp `exexog', _col(20)

	// Now rename variables etc.
	local dict_o `depvar' `inexog' `endo' `exexog'
	local dict_t `depvar_t' `inexog_t' `endo_t' `exexog_t'

	if `debugflag' {
		di
		di as text "xtabond2 initial dictionary names:"
		di as res "dict_o `: word count `dict_o'': `dict_o'"
		di as res "dict_t `: word count `dict_t'': `dict_t'"
		di
	}

	// Start creating display names in dict_d.
	// If any factor variables in varlists, prefix with "FV_"
	foreach vn in `depvar' `inexog' `endo' `exexog' {
		_ms_parse_parts `vn'
		if r(type)=="factor" {
			local dict_d `dict_d' FV_`vn'
		}
		else {
			local dict_d `dict_d' `vn'
		}
	}
	
	// get rid of "/", ":", "." and replace with "_"
	local dict_d	: subinstr local dict_d "/" "_", all
	local dict_d	: subinstr local dict_d ":" "_", all
	local dict_d	: subinstr local dict_d "." "_", all

	if `debugflag' {
		di
		di as text "xtabond2 dictionary names:"
		di as res "dict_t `: word count `dict_t'': `dict_t'"
		di as res "dict_d `: word count `dict_d'': `dict_d'"
		di
	}
	
	// error check
	if `: word count `dict_d'' ~= `: word count `dict_t'' {
		di as err "error - list of varnames and tempnames have different number of elements"
		exit 499
	}

	// Rename variables in varlists
	matchnames "`endo'" "`dict_o'" "`dict_d'"
	local endo_o		`endo'
	local endo			`r(names)'
	matchnames "`inexog'" "`dict_o'" "`dict_d'"
	local inexog_o		`inexog'
	local inexog		`r(names)'
	matchnames "`exexog'" "`dict_o'" "`dict_d'"
	local exexog_o		`exexog'
	local exexog		`r(names)'
	matchnames "`exexog_diff'" "`dict_o'" "`dict_d'"
	local exexog_diff_o	`exexog_diff'
	local exexog_diff	`r(names)'
	matchnames "`exexog_lev'" "`dict_o'" "`dict_d'"
	local exexog_lev_o	`exexog_lev'
	local exexog_lev	`r(names)'
	matchnames "`exexog_sys'" "`dict_o'" "`dict_d'"
	local exexog_sys_o	`exexog_sys'
	local exexog_sys	`r(names)'
	matchnames "`firstlags'" "`dict_o'" "`dict_d'"
	local firstlags_o	`firstlags'
	local firstlags		`r(names)'
	matchnames "`Znames'" "`dict_o'" "`dict_d'"
	local Znames_o		`Znames'
	local Znames		`r(names)'

	if `debugflag' {
		di
		di "exexog (`: word count `exexog''): `exexog'"
		di "inexog (`: word count `inexog''): `inexog'"
		di "Znames (`: word count `Znames''): `Znames'"
		di "endo (`: word count `endo''): `endo'"
		di
	}
	
	// Put matrix stripes on A matrices
	// Need to allow for special case of vars that are endog and exog in diff eqns
	matchnames "`Znames'" "`old_inexog'" "`new_exexog'"
	local newstripe		`r(names)'
	mat colnames `A1' = `newstripe'
	mat rownames `A1' = `newstripe'
	if ~`A2missing' {
		mat colnames `A2' = `newstripe'
		mat rownames `A2' = `newstripe'
	}
	
	// Put matrix stripes on H matrix.
	// Time range is for all obs in dataset, even if not used.
	// Two strips needed if level equation also used.
	if `hasdiff' {
		forvalues t=`tmin'(`delta')`tmax' {
			local hstripe `hstripe' Diff:t`t'
		}
	}
	if `haslevel' {
		forvalues t=`tmin'(`delta')`tmax' {
			local hstripe `hstripe' Lev:t`t'
		}
	}
	mat colnames `H'	= `hstripe'
	mat rownames `H'	= `hstripe'

	// drop original vars, keep temp vars and rename
	keep `dict_t' `touse' `clustvar1' `clustvar2' `wvar' `panelvar' `eqvar' `timevar' `hvar'
	if `debugflag' {
		di
		di "dict_t (`: word count `dict_t''): `dict_t'"
		di "dict_d (`: word count `dict_d''): `dict_d'"
		rename (`dict_t') (`dict_d'), dryrun
		di
	}
	rename (`dict_t') (`dict_d')

	if "`exexog_dups'"~="" {
		di as text "Duplicates found in excluded IV list:"
		di as text "{p 0 10}Removing `exexog_dups'{p_end}"
		di as text "from exexog."
	}

	// create identifier for H matrix
	local tlength		= (`hasdiff'+`haslevel')*((`tmax' - `tmin')/`delta' + 1)
	qui replace `hvar'	= _n - `tlength'*(ceil(_n/`tlength')-1)
	order `hvar', after(`timevar')

	// Collinearity check (xtabond2 can keep in list of vars even if dropped).
	if "`keepall'"=="" {
		// Put cons at start so it's dropped last.
		// But only if level data being used, since diff has no constant.
		if `cons' & `uselevel' & `consomitflag'==0 {
			local inexog	: list inexog - consname_new
			local inexog	`consname_new' `inexog'
		}
		qui _rmcollright `inexog' `exexog' if `touse', nocons
		local collin	`r(dropped)'
		if "`collin'" ~= "" {
			matchnames "`collin'" "`dict_d'" "`dict_o'"
			di as text "Collinearities/empty variables detected within exog Xs & IVs:"
			di as text "{p 0 9}Removing `r(names)'{p_end}"
			di as text "from inexog and/or exexog."
			local inexog	: list inexog - collin
			local exexog	: list exexog - collin
		}
		// and then put it back at the end
		if `cons' & `uselevel' & `consomitflag'==0 {
			local inexog	: list inexog - consname_new
			local inexog	`inexog' `consname_new'
		}
		// now loop through A1 and A2 matrices, dropping rows/columns
		tempname A1temp A2temp
		// foreach var of local Znames {
		foreach var of local newstripe {
			local notdropped	: list var - collin
			if "`notdropped'"~="" {
				mat `A1temp' = nullmat(`A1temp'), `A1'[1...,"`var'"]
				if ~`A2missing' {
					mat `A2temp' = nullmat(`A2temp'), `A2'[1...,"`var'"]
				}
			}
		}
		mat drop `A1'
		if ~`A2missing' {
			mat drop `A2'
		}
		// foreach var of local Znames {
		foreach var of local newstripe {
			local notdropped	: list var - collin
			if "`notdropped'"~="" {
				mat `A1' = nullmat(`A1') \ `A1temp'["`var'", 1...]
				if ~`A2missing' {
					mat `A2' = nullmat(`A2') \ `A2temp'["`var'", 1...]
				}
			}
		}
	}

	if `weightflag' {
		// use original weight type
		return local wtexp		[`e(wtype)'=`wvar']
		return local weightvar	`wvar'
	}
	return local hvar			`hvar'
	return local panelvar		`panelvar'
	return local timevar		`timevar'
	return local eqvar			`eqvar'
	return local depvar			`depvar'
	return local endo_o			`endo_o'
	return local inexog_o		`inexog_o'
	return local exexog_o		`exexog_o'
	return local exexog_diff_o	`exexog_diff_o'
	return local exexog_lev_o	`exexog_lev_o'
	return local exexog_sys_o	`exexog_sys_o'
	return local firstlags_o	`firstlags_o'
	return local endo			`endo'
	return local inexog			`inexog'
	return local exexog			`exexog'
	return local exexog_diff	`exexog_diff'
	return local exexog_lev		`exexog_lev'
	return local exexog_sys		`exexog_sys'
	return local firstlags		`firstlags'
	return local omitted		`omitted_stripped'
	return local collin			`collin'
	return local pca			`e(pca)'
	return local touse			`touse'
	return local wvar			`wvar'
	return local cluster		`cluster'
	return local clustvar		`clustvar1' `clustvar2'
	return local clustvar1		`clustvar1'
	return local clustvar2		`clustvar2'
	return scalar N				= `N'
	return scalar N_clust		= `N_clust'
	return scalar N_clust1		= `N_clust1'
	return scalar N_clust2		= `N_clust2'
	return scalar N_g			= `e(N_g)'
	return scalar g_min			= `e(g_min)'
	return scalar g_max			= `e(g_max)'
	return scalar g_avg			= `e(g_avg)'
	return local model			linear
	return local transform		`transform'
	return local xtmodel		`xtmodel'
	return local robust			`e(robust)'			//  always ="robust" under clustering
	return scalar cons			= 0					//  if constant present, xtabond2 will have 1s column in the data matrix
	return scalar h				= e(h)				//  = 1, 2 or 3. note case!
	return scalar haslevel		= `haslevel'
	return scalar uselevel		= `uselevel'
	return scalar hasdiff		= `hasdiff'
	return scalar usediff		= `usediff'
	return local noconstant		noconstant
	return local small			`e(small)'
	if "`e(twostep)'"~="" {
		return local gmm2s		gmm2s
	}
	return scalar dofminus		= 0
	return local robust			`robust'
	return local vceopt			`vceopt'

	return matrix A1			= `A1'	
	return matrix A2			= `A2'	
	return matrix H				= `H'

	if `reportonlyflag' {
		restore
	}

end		//  end make_xtabond2_data


// utility for creating xtdpdgmm-transformed data
* make_xtdpdgmm_data version 1.00.00 18jul2019
* author mes

program define make_xtdpdgmm_data, rclass
	version 12.1
	syntax	[ ,								///
				touse(varname)				///
				wvar(varname)				///
				NOIsily						///
				debugflag(int 0)			///
		]
	
	if "`noisily'"=="" {
		loc qui qui
	}

	if "`touse'"=="" {
		qui gen byte touse = e(sample)
		local touse touse
	}
	else {
		qui replace `touse'=e(sample)		
	}
	
	// code doesn't support nonlinear moment conditions
	if e(zrank_nl) >0 {
		di as err "error - nonlinear moment conditions not supported"
		exit 198
	}
	
	// xtdpdgmm doesn't yet support weights but keep the code anyway
	if "`wvar'"=="" & "`e(wexp)'"==""  {
		qui gen byte wvar=1
		local wvar wvar
	}
	else if "`wvar'"=="" & "`e(wexp)'"~="" {
		qui gen double wvar `e(wexp)'
		local wvar wvar
	}
	else if "`wvar'"~="" & "`e(wexp)'"==""  {
		qui replace `wvar' = 1
	}
	else {
		qui replace `wvar' `e(wexp)'
	}
	
	local N_clust		= e(N_clust)
	if `N_clust' < . {
		// clustering
		local cluster	cluster(`e(ivar)')
		local clustvar1	`e(ivar)'
	}	

	tempname b
	mat `b'				= e(b)
	loc indepvars		: coln `b'
	// indepvars does not include the constant
	loc indepvars		: subinstr loc indepvars "_cons" "", w c(loc cons)
	if `cons' {
		// use for display
		local consname _cons
	}
	else {
		// returned local
		local noconstant noconstant
	}

	cap drop __alliv_*
	qui predict double __alliv_*, iv
	unab alliv			: __alliv_*

	*--------------------------------------------------*
	// The only included exogenous variable is the constant (if present).
	// All other regressors are treated as endogenous.
	loc depvar			`e(depvar)'
	loc endo			`indepvars'
	loc exexog			`alliv'
	*--------------------------------------------------*

	loc N_endo			: word count `endo'
	// N_inexog does not include the constant
	loc N_inexog		: word count `inexog'
	loc N_exexog		= e(zrank) - `N_inexog' - `cons'
	loc N_iv			= e(zrank) - `cons'

	di as text "Number of obs:     `e(N)'"
	di as text "Number of panels:  `e(N_g)'"
	
	di as text "Dep var:           `depvar'""
	di as text "Endog Xs (`N_endo'):" _c
	Disp `endo', _col(20)
	di as text "Exog Xs (" `N_inexog'+`cons' "):" _c
	Disp `inexog' `consname', _col(20)
	di as text "Excl IVs (`N_exexog'):" _c
	Disp `exexog', _col(20)

	if `debugflag' {
	di "cons=`cons'"
		di as text "underidindepvars:   `indepvars'"
		di as text "underidivvars:      `e(ivvars)'"
		di as text "underidgmmivvars:   `e(gmmivvars)'"
		di as text "underiddivvars:     `e(divvars)'"
		di as text "underiddgmmivvars:  `e(dgmmivvars)'"
		di as text "underidecivvars:    `e(ecivvars)'"
		di as text "underidecgmmivvars: `e(ecgmmivvars)'"
		di as text "underidmdivvars:    `e(mdivvars)'"
		di as text "underidmdgmmivvars: `e(mdgmmivvars)'"
	}

	return local panelvar		`panelvar'
	return local timevar		`timevar'
	return local depvar			`depvar'
	return local endo			`endo'
	return local inexog			`inexog'
	return local exexog			`exexog'
	return local tinexog		`tinexog'

	return local cluster		`cluster'			//  = "cluster( <varname> )"
	return local clustvar		`clustvar1'			//  = <varname>
	return local clustvar1		`clustvar1'			//  = <varname>
	return scalar N				= e(N)
	return scalar N_clust		= e(N_clust)
	return scalar dofminus		= 0
	return local cons			= `cons'
	return local noconstant		`noconstant'
	return local robust			`robust'


end		// end make_xtdpdgmm_data


exit

* 1.0.00  (2 July 2020) Final version of v1 release.
