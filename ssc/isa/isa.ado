*capture program drop isa

/********************************
			WHAT'S NEW			

16. option names modified.
17. option names shortened.
17. vce() option added.
18. alpha point-selecting mechanism changed
19. curve changed from line to mspline
20. "ml init" option
21. "mspline" option
22. "tstat" option
23. bug in isa_rsq_treat fixed.
24. weight added
25. "quick" option
26. if `touse'
26. capability of handling long varlist
27. fix error in step2
27. return error for miscoded treatment variable.
27. "showcheck" option added
********************************/

/********************************
			FUTURE UPDATES	
********************************/

*********************************************************************
*	MAIN PROGRAM
program define isa
	version 9
	syntax varlist [if] [in] [fw aw], [vce(passthru)] [TAU(numlist >0)] [TSTAT(numlist >0)] ///
	[OBServation(int 20)] [RESolution(int 20)] [PRECision(real .1)] [quick] ///
	[MINAlpha(real 0)] [MAXAlpha(real 10)] [MINDelta(real 0)] [MAXDelta(real 5)] ///
	[SMINAlpha(real 999)] [SMAXAlpha(real 999)] [SMINDelta(real 999)] [SMAXDelta(real 999)] ///
	[ml_iterate(passthru)] [nplots(passthru)] [NOGRAPH] [noDOTS] [SKIPRangecheck] [SHOWRangecheck]
	
	marksample touse
	gettoken y rhs : varlist
	gettoken t X :rhs


	*	DROPPING SCALAR
	local num_ctrl = `num_coef_t'-1
	forvalues n = 1/`num_ctrl' {
		capture scalar drop partial_rsq_yx`n'
		capture scalar drop partial_rsq_tx`n'
		capture scalar drop rsq_t_x`n'
	}
	foreach scl in sigma_sqx rsq_t_x1 tau_diff sigma_squ rsq_tu t se tau sigma_sqo rsq_to t_o se_o tau_o tempinit_y {
		capture scalar drop `scl'
	}

	*	DROPPING MATRICES
	foreach mat in from tempinit_t tempinit_o {
		capture matrix drop `mat'
	}


	*	RENAMING OLD QOI
	qui foreach var in isa_tau isa_se isa_t isa_alpha isa_delta isa_partial_rsq_y isa_partial_rsq_t isa_converge isa_partial_rsq_yx isa_partial_rsq_tx isa_plotvar {
		capture drop old_`var'
		capture rename `var' old_`var'
		capture drop `var'
	}

	
	*	ERROR CODES
	if "`tau'" == "" & "`tstat'" == "" {
		display as error "Error: either tau( ) or tstat( ) needs to be specified."
		error 121
	}

	if `minalpha'<0 | `mindelta'<0 | `maxalpha'<0 | `maxdelta'<0 {
		display ""
		display as error "The values of min and max must be positive."
		error 121
	}
	
	if `minalpha'>`maxalpha' | `mindelta'>`maxdelta' {
		display ""
		display as error "The minimum value cannot be larger than the maximum value."
		error 121
	}

	qui sum `t' if `touse'
	if (r(max)!=1 | r(min)!=0) {		/* ADDED IN V31 */
		display ""
		display as error "Error: the treatment variable is not coded as 0 and 1."
		exit
	}


	*	GENERATING VARIABLES
	qui foreach var in isa_tau isa_se isa_t isa_alpha isa_delta isa_partial_rsq_y isa_partial_rsq_t isa_converge {
		gen `var' = .
	}
	
	*	SETTING INITIAL VALUES
	tempvar res_yo
	qui reg `y' `rhs' if `touse' [`weight'`exp'], `vce'
	matrix tempinit_o = e(b)
	qui predict `res_yo' if `touse', resid
	qui sum `res_yo' if `touse'
	scalar tempinit_y = r(sd)
	qui logit `t' `X' if `touse' [`weight'`exp'], `vce'
	matrix tempinit_t = e(b)
	
	local num_coef_o = 1	/* intercept */
	foreach var in `rhs' {
		local num_coef_o = `num_coef_o'+1
	}
	
	local num_coef_t = `num_coef_o'-1 /* num_coef_o - coef of treatment(b/c its in lhs) */
	local initcol = `num_coef_o' + `num_coef_t' + 1 /* num_coef_o + num_coef_t + overall variance */
	matrix from = J(1,`initcol',0)
	
	forvalues j = 1/`num_coef_o' {
		matrix from[1,`j'] = tempinit_o[1,`j']
	}

	forvalues k = 1/`num_coef_t' {
		local k2 = `k'+`num_coef_o'
		matrix from[1,`k2'] = tempinit_t[1,`k']
	}
	
	local l = `num_coef_o' + `num_coef_t' + 1
	matrix from[1,`l'] = scalar(tempinit_y)

	display ""
	display "---------------------------------------------"
	display "STEP1: ESTIMATING ORIGINAL EQUATIONS"
	display "---------------------------------------------"
	display ""
	
	*	ESTIMATING ORIGINAL TREATMENT EFFECT
	isa_est `varlist' if `touse' [`weight'`exp'], alpha(0) delta(0) `vce' `ml_iterate'
	matrix matB = e(b)
	matrix matV = e(V)
	scalar tau_o = matB[1,1]
	scalar se_o = sqrt(matV[1,1])
	scalar t_o = scalar(tau_o)/scalar(se_o)
	
	
	*	ESTIMATING ORIGINAL R-SQ FOR TREATMENT ASSIGNMENT EQ.	
	isa_rsq_treat `varlist' if `touse' [`weight'`exp'], alpha(0)
	scalar rsq_to = scalar(rsq_t)
	scalar drop var_t rsq_t
		
		
	*	ESTIMATING ORIGINAL R-SQ FOR OUTCOME EQ.	
	isa_rsq_outcome `varlist'
	scalar sigma_sqo = scalar(sigma_sq)
	scalar drop sigma_sq

	display ""
	display "-------------------------------------------------"
	display "STEP2: CHECKING THE CONSISTENCY OF THE PARAMETERS"
	display "-------------------------------------------------"	
	display ""
	*	INITIAL CHECK OF WHETHER DELTA THAT SATISFIES BIAS EXISTS OR NOT GIVEN ALPHA

	if "`showrangecheck'" == "" {											/* ADDED IN V27 */
		local step2_qui = "qui"
	}
	else	{
		local step2_qui = ""
	}

	if "`skiprangecheck'" == "" {
		`step2_qui' isa_rangecheck `varlist' if `touse' [`weight'`exp'], `vce' tau(`tau') tstat(`tstat') ///
		minalpha(`minalpha') maxalpha(`maxalpha') mindelta(`mindelta') maxdelta(`maxdelta') ///
		`ml_iterate'
	display "Done."
	}
	else{
	display "Skipped by the user."
	}
	*	SET NUMBER OF OBSERVATION 1
	local num_obs = `observation'
	if `num_obs'>_N {
		set obs `num_obs'
	}

	display ""
	display "-----------------------------------------------------------"
	display "STEP3: 1ST RUN - FIX ALPHA CHANGE DELTA"
	display "-----------------------------------------------------------"
	display ""
	
	* 1ST RUN: FIX ALPHA CHANGE DELTA
	isa_1st_loop `varlist' if `touse' [`weight'`exp'], tau(`tau') tstat(`tstat') `vce' observation(`observation') resolution(`resolution') ///
	minalpha(`minalpha') maxalpha(`maxalpha') mindelta(`mindelta') maxdelta(`maxdelta') ///
	`ml_iterate' `nodots' `quick'


	foreach name in minalpha maxalpha mindelta maxdelta {
		if `s`name'' == 999 {
			local s`name' = ``name''
		}
	}	
	
	
	*	SET NUMBER OF OBSERVATION 2
	local num_obs = `observation'*2
	if `num_obs'>_N {
		set obs `num_obs'
	}

	display as text "Done."
	display ""
	display "-----------------------------------------------------------"
	display "STEP4: 2ND RUN - FIX DELTA CHANGE ALPHA"
	display "-----------------------------------------------------------"
	display ""
	* 2ND RUN: FIX ALPHA CHANGE DELTA
	isa_2nd_loop `varlist' if `touse' [`weight'`exp'], tau(`tau') tstat(`tstat') `vce' observation(`observation') resolution(`resolution') ///
	minalpha(`sminalpha') maxalpha(`smaxalpha') mindelta(`smindelta') maxdelta(`smaxdelta') ///
	`ml_iterate' `nodots' `quick'
	
	display as text "Done."
	display ""
	display "-----------------------------------------------------------"
	display "STEP5: ESTIMATING ALPHA AND DELTA OF EACH CTRL VARIABLES"
	display "-----------------------------------------------------------"	
	display ""
	
	qui isa_xplots `varlist' if `touse' [`weight'`exp']

	display "Done."
	display ""
	display "-----------------------------------------------------------"
	display "STEP6: DRAWING CONTOUR"
	display "-----------------------------------------------------------"	
	display ""
		
	if "`nograph'" ~= "" {
		display "Skipped by the user."	
	}
	else{	
		isa_graph `varlist', tau(`tau') tstat(`tstat') `nplots'
	}

	*	DROPPING SCALAR
	local num_ctrl = `num_coef_t'-1
	forvalues n = 1/`num_ctrl' {
		capture scalar drop partial_rsq_yx`n'
		capture scalar drop partial_rsq_tx`n'
		capture scalar drop rsq_t_x`n'
	}
	foreach scl in sigma_sqx rsq_t_x1 tau_diff sigma_squ rsq_tu t se tau sigma_sqo rsq_to t_o se_o tau_o tempinit_y {
		capture scalar drop `scl'
	}

	*	DROPPING MATRICES
	foreach mat in from tempinit_t tempinit_o {
		capture matrix drop `mat'
	}

end
