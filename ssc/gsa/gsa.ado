/********************************
			WHAT'S NEW			

 7. CORRELATION OPTION IS ADDED.
 8. RESIDUAL FROM LOGIT
 8. rho_res_yx & rho_res_tx RECORDED IN DATA.
 9. probit OPTION
10. ALGORITHM OF iter_c1_1st CHANGED
10. OPTION FOR iter_c2 ADDED
10. WARNING MESSAGE FOR FEW CONVERGENCE.
10. CONTINUOUS TREATMENT OPTION
11. MAKE CONTINUOUS U DEFAULT AND BINARY U OPTIONAL
11. LOGIT OPTION (DOES NOTHING JUST TO AVOID RETURNING ERROR MESSAGE.)
12. SHOW PREDICTED TIME.
13. REWRITE PROGRAM SO THAT IT DOES NOT CHANGE ORIGINAL DATA. (1/2)
14. Cont'd: REWRITE PROGRAM SO THAT IT DOES NOT CHANGE ORIGINAL DATA. (2/2)
14. OPTION [noDOTS] ADDED.
15. LOCAL VARNAMES CHANGED.
16. CUTOFF POINT BASED ON T-VALUE ADDED.
17. ALL VARIABLES GENERATED HAVE GSA_ IN THE TOP OF THEIR NAMES.
17. GRAPH LEGEND IS CORRECTED17. SOME MINOR ERRORS FIXED.
18. GSAGRAPH PROGRAM ADDED
19. GSAGRAPH INTEGRATED TO GSA COMMAND.
20. CHANGE DEFINITION OF TAU FROM CHANGE TO LEVEL
21. BINARY OUTCOME VARIABLE IS AVAILABLE.
22. ADD QUITELY TO SOME COMANDS.
23. PARTIAL RSQ FOR LOGIT IS CALCULATED IN DIFFERENT WAY
24. RECORD QOIS AS SCALARS FIRST AND SAVE AS VAR IN THE END.
25. TIMER PROGRAM MODIFIED
26. DEBUG
26. FORMATTED FOR DISTRIBUTION
27. STANDARDIZE VALUES (EXCEPT T AND BINARY U) BEFORE CALCULATION --REMOVED
28. MAJOR UPDATE - MORE EFFICIENT ALGORITHM
29. THE WAY PSEUDO R-SQ IS CALCULATED IS CHANGED
29. BUG FIXED.
29. BUG (LOGIT X {BINU, CONTU}) FIXED
30. CALCULATION ERROR IN PSEUDO R-SQ FIXED
31. BUG "res_yo already defined" FIXED
32. RESUME LPM OPTION, WARNING FOR ROBUST SE.
33. RESOLVING THE ERROR IN CALCULATING PARTIAL EFFECTS WITH VERY LONG VARLIST
33. ADDED ERROR MESSAGES


********************************/
program define gsa

	version  9
	syntax varlist [if] [in], [vce(passthru)] [TAU(numlist)] [TSTAT(numlist)] [PRECision(real 5)] ///
	[maxc1(real 2)] [maxc2(real .5)] [RESolution(int 100)] [OBServation(int 200)] [BINU] ///
	[CORrelation] [YPROBIT] [YLOGIT] [YLPM] [YCONTinuous] [LOGIT] [PROBIT] [LPM] [CONTinuous] ///
	[noDOTS] [SEED(int 1)] [noPRINT] [FRACtional] [QUADratic] [LOWEss] [nplots(passthru)] [SCATTER] ///
	[gsa_pu_precision(passthru)] [gsa_binpu_precision(passthru)] [gsa_range_res(int 2000)] [iter_tolerance(int 10)]
	
	*	DELETING VARIABLES, SCALARS AND MATRICES
	qui foreach var in res_to hat_to res_yu res_yo res_to2 gsa_pseudo_u{
		capture drop `var'
	}

	qui foreach scl in scl_alpha scl_delta scl_covUT nvar_sub3 nvar_sub2 nvar_sub1 nvar {
			capture scalar drop `scl'
	}
	qui foreach scl1 in b_tau_ se_tau_ t_tau_ sigma_sqy sigma_sqt {
		foreach scl2 in o u {
			capture scalar drop scl_`scl1'`scl2'
		}
	}
	qui foreach scl1 in rsq var {
		foreach scl2 in yo to yu tu {
			capture scalar drop scl_`scl1'_`scl2'
		}
	}
		
	qui foreach mat1 in B V subB subV VAR {
		foreach mat2 in yo to yu tu {
			capture matrix drop mat_`mat1'_`mat2'
		}
	}

	*	RENAMING OLD QOI
	qui foreach var in  gsa_c1 gsa_c2 gsa_alpha gsa_delta gsa_partial_rsq_y gsa_partial_rsq_t gsa_rho_res_yu gsa_rho_res_tu gsa_partial_rsq_yx gsa_partial_rsq_tx gsa_rho_res_yx gsa_rho_res_tx {
		capture drop old_`var'
		capture rename `var' old_`var'
		capture drop `var'
	}
	
	marksample touse
	gettoken y rhs : varlist
	gettoken t X :rhs
	
	set seed `seed'

	display ""
	display "-------------------------------------------"
	display "STEP1: CHECKING THE CONSISTENCY OF THE DATA"
	display "-------------------------------------------"
	
	*	DETERMINING WHETHER OUTCOME AND TREATMENT ARE BINARY OR CONTINUOUS.
	qui inspect `t' if `touse' 
	local unique_val_t = r(N_unique)
	qui inspect `y' if `touse' 
	local unique_val_y = r(N_unique)	
	
	if "`tau'" == "" & "`tstat'" == "" {	/* ADDED IN V16 */
		display ""
		display as error "Error: either tau( ) or tstat( ) needs to be specified."
		exit
	}
	
	if "`tau'" != "" & "`tstat'" != "" {	/* ADDED IN V16 */
		display ""
		display as error "Error: only either tau( ) or tstat( ) can be specified."
		exit
	}	
	
	if "`tau'"!="" {	/* ADDED IN V28 */
		if `tau'<0 {
			display ""
			display as error "Error: tau( ) needs to be equal or greater than 0."
			exit
		}
	}
	else {	/* ADDED IN V28 */
		if `tstat'<0 {
			display ""
			display as error "Error: tstat( ) needs to be equal or greater than 0."
			exit
		}
	}
		
	if `unique_val_t'!=2 & ("`logit'" != "" | "`probit'" != "" | "`lpm'" != "") {			/* ADDED IN V21 */
		display ""
		display as error "Error: the treatment variable is not binary. Use continuous option."
		exit
	}
	
	if `unique_val_y'!=2 & ("`ylogit'" != "" | "`yprobit'" != "" | "`ylpm'" != "") {		/* ADDED IN V21 */
		display ""
		display as error "Error: the outcome variable is not binary. Use continuous option."
		exit
	}
	
	if ("`ylpm'" != "" | "`lpm'" != "") {		/* ADDED IN V31 */
		display ""
		display as text "Linear Probability Model is selected. Make sure that you specify robust or clustered standard error option."
	}
	
	
	if `unique_val_t'==2 & "`continuous'" != "" {			/* ADDED IN V31 */
		display ""
		display as error "Error: the treatment variable is binary. Use logit/probit/lpm option."
		exit
	}
	
	if `unique_val_y'==2 & "`ycontinuous'" != "" {			/* ADDED IN V31 */
		display ""
		display as error "Error: the outcome variable is binary. Use ylogit/yprobit/ylpm option."
		exit
	}
	
	if `unique_val_y'!=2 & "`ycontinuous'" == "" {			/* ADDED IN V21 */
		local ycontinuous "ycontinuous"
		display ""
		display as text "No option is selected for the non-binary outcome variable. Continuous option is selected."
	}
	
	if `unique_val_t'!=2 & "`continuous'" == "" {			/* ADDED IN V21 */
		local continuous "continuous"
		display ""
		display as text "No option is selected for the non-binary treatment variable. Continuous option is selected."
	}
	
	if `unique_val_y'==2 & "`ylogit'" == "" & "`yprobit'" == "" & "`ylpm'" == "" {			/* ADDED IN V21 */
		local ylogit "ylogit"
		display ""
		display as text "No option is selected for the binary outcome variable. Logit model is selected."
	}

	if `unique_val_t'==2 & "`logit'" == "" & "`probit'" == "" & "`lpm'" == "" {				/* ADDED IN V21 */
		local logit "logit"
		display ""
		display as text "No option is selected for the binary treatment variable. Logit model is selected."
	}
	
	if "`yprobit'" != "" | "`probit'" != "" {										/* ADDED IN V21 */
		local correlation "correlation"
		display ""
		display as text "Probit model is selected. -gsa- reports partial correlations instead of partial R-sqs."
	}

	qui sum `t' if `touse'
	if (r(max)!=1 | r(min)!=0)  & ("`logit'" != "" | "`probit'" != "" | "`lpm'" != "") {		/* ADDED IN V31 */
		display ""
		display as error "Error: the treatment variable is not coded as 0 and 1."
		exit
	}
	
	qui sum `y' if `touse'
	if (r(max)!=1 | r(min)!=0)  & ("`ylogit'" != "" | "`yprobit'" != "" | "`ylpm'" != "") {		/* ADDED IN V31 */
		display ""
		display as error "Error: the outcome variable is not coded as 0 and 1."
		exit
	}

	local restX_0b `X'													/* ADDED IN V33 */
	forvalues i9b = 0/9 {
		local j9b = `i9b'+1
		gettoken `j9b'b restX_`j9b'b : restX_`i9b'b
	}
	local fst10b `1b' `2b' `3b' `4b' `5b' `6b' `7b' `8b' `9b' `10b'
	if  length("`fst10b'")>244	{
		display ""
		display as error "Error: please make variable names shorter. The total length of the first 10 control variables' names must be less than 244 words including spaces."
		exit
	}	

	
	*	VARIABLES AND TEMPVARS
	*------------------------------------------------

	*GENERATING VARIABLES INTO WHICH THE ESTIMATES ARE RECORDED
	foreach var in c1 c2 alpha delta partial_rsq_y partial_rsq_t rho_res_yu rho_res_tu {
		gen gsa_`var' = .
	}
	
	*	DEFINING TEMPVARS AND TEMPNAMES
	
	local tempvar_list c2_0 tau_diff temp_c1 temp_c2 utilde ucont pseudo_u ///
	hat_temp hat_to res_to2 hat_tu res_yo res_to res_yu res_tu res_utx res_ux
	
	qui foreach var in `tempvar_list' {
		tempvar `var'
		gen ``var'' = .
	}
	
	tempname scl_tau_diff scl_median scl_alpha scl_delta scl_flg_badu ///
	scl_b_tau_o scl_se_tau_o scl_t_tau_o scl_sigma_sqyo scl_sigma_sqto scl_var_yo scl_rsq_yo scl_var_to scl_rsq_to ///
	scl_b_tau_u scl_se_tau_u scl_t_tau_u scl_sigma_sqyu scl_sigma_sqtu scl_var_yu scl_rsq_yu scl_var_tu scl_rsq_tu ///
	scl_rho_res_yu scl_rho_res_tu scl_abs_rho_res_yu scl_abs_rho_res_tu scl_partial_rsq_y scl_partial_rsq_t ///
	scl_hat_alpha scl_rho_hto_htu scl_max_c1 scl_max_c2 scl_c1 scl_c2 scl_c2_0 ///	
	mat_B_yo mat_V_yo mat_subB_yo mat_subV_yo mat_VAR_yo ///
	mat_B_yu mat_B_tu mat_subB_yu mat_subV_yu mat_VAR_yu ///
	mat_B_to mat_V_to mat_subB_to mat_subV_to mat_VAR_to ///
	mat_V_yu mat_V_tu mat_subB_tu mat_subV_tu mat_VAR_tu
	

	*	CALCULATING THE NUMBER OF VARIABLES
	local nvar = 0
	foreach var in `varlist' {
		local nvar = `nvar'+1
	}
	scalar nvar = `nvar'
	scalar nvar_sub1 = scalar(nvar)-1
	scalar nvar_sub2 = scalar(nvar)-2
	scalar nvar_sub3 = scalar(nvar)-3

	local nvar_sub1 = scalar(nvar_sub1)
	local nvar_sub2 = scalar(nvar_sub2)
	local nvar_sub3 = scalar(nvar_sub3)


	*	SETTING CUTOFF VALUES OF THE FOLLOWING IF CONDITION
	if "`tau'" != "" {							/* ADDED IN V16 */
		local cutoff_tau_diff_ub = `tau'*(1+`precision'/100)					/* IMPORTANT PARAMETER */
		local cutoff_tau_diff_lb = `tau'*(1-`precision'/100)					/* IMPORTANT PARAMETER */
	}
	else {
		local cutoff_tau_diff_ub = `tstat'*(1+`precision'/100)			/* IMPORTANT PARAMETER */
		local cutoff_tau_diff_lb = `tstat'*(1-`precision'/100)				/* IMPORTANT PARAMETER */	
	}
*noisily display "tau=" `tau'	
*noisily display "cutoff_tau_diff_ub=" `cutoff_tau_diff_ub'	
*noisily display "cutoff_tau_diff_lb=" `cutoff_tau_diff_lb'	
	
	
	*************************************************************
	*	ESTIMATION OF ORIGINAL MODEL
	*************************************************************

	*	"ORIGINAL MODEL" & "OUTCOME EQ."
	*-----------------------------------------------------------
		
	capture drop res_yo
	
	display ""
	display "---------------------------------------------"
	display "STEP2: ESTIMATING ORIGINAL EQUATIONS"
	display "---------------------------------------------"
	display ""
	display "ESTIMATES OF ORIGINAL OUTCOME EQ."
	
	if "`ycontinuous'" != "" | "`ylpm'" != "" {	
		reg `varlist' if `touse' , `vce'
		qui predict res_yo if `touse', resid
	}
	
	if "`yprobit'" != "" {
		probit `varlist' if `touse' , `vce'
		qui predict res_yo if `touse', deviance
	}
	
	if "`ylogit'" != "" {
		logit `varlist' if `touse' , `vce'
		qui predict res_yo if `touse', deviance
	}

	matrix mat_B_yo = e(b)
	matrix mat_V_yo = e(V)
	scalar scl_b_tau_o = mat_B_yo[1,1]
	scalar scl_se_tau_o = sqrt(mat_V_yo[1,1])
	scalar scl_t_tau_o = scl_b_tau_o/scl_se_tau_o
	local temp = scl_b_tau_o
	local temp2 = scl_t_tau_o
	*	ERROR MESSAGES FOR INAPPROPRIATE TAU AND TSTAT
	if `temp' < 0  {
		display ""
		display as error "Error: the treatment effect must be positive."
		exit
	}
	if "`tau'" != "" {
		if `temp' <`tau'  {	
			display ""
			display as error "Error: the target coefficient must be smaller than that of the original model."
			exit
		}
	}
	else {
		if `temp2'<`tstat'  {	
			display ""
			display as error "Error: the target t-statistics must be smaller than that of the original model."
			exit
		}	
	}
	
	if "`ycontinuous'" != "" | "`ylpm'" != "" {	
		sum res_yo if `touse'
		scalar scl_sigma_sqyo = r(Var)	
	}
	
	if "`ylogit'" != "" {	
		matrix mat_subB_yo = J(1, `nvar_sub1', .)
		forvalues c = 1/`nvar_sub1' {
			matrix mat_subB_yo[1, `c'] = mat_B_yo[1, `c']
		}
		qui cor `rhs' if `touse', cov
		matrix mat_subV_yo = r(C)
		matrix mat_VAR_yo = mat_subB_yo*mat_subV_yo*mat_subB_yo'
		scalar scl_var_yo = mat_VAR_yo[1,1]
		scalar scl_rsq_yo = scl_var_yo/(scl_var_yo + _pi^2/3)	
	}


	*	"ORIGINAL MODEL" & "TREATMENT ASSIGNMENT EQ."
	*------------------------------------------------
	
	*	CALCULATING RESIDUAL & THAT WITH OLS
	qui reg `rhs' if `touse', `vce'
	capture drop res_to
	capture drop hat_to
	qui predict res_to if `touse', resid
	qui predict hat_to if `touse', xb

	display ""
	display "ESTIMATES OF ORIGINAL TREATMENT ASSIGNMENT EQ."
	
	if "`continuous'" != "" | "`lpm'" != "" { 				/* ADDED IN V10 */
		reg `t' `X' if `touse' , `vce'	
		matrix mat_B_to = e(b)
		matrix mat_V_to = e(V)
		capture drop res_to2
		qui predict res_to2 if `touse', resid
	}
	if "`probit'" != "" {					/* ADDED IN V9 */
		probit `t' `X' if `touse' , `vce'
		matrix mat_B_to = e(b)
		matrix mat_V_to = e(V)
		capture drop res_to2
		qui predict res_to2 if `touse', deviance
	}
	if "`logit'" != "" {
		logit `t' `X' if `touse' , `vce'
		matrix mat_B_to = e(b)
		matrix mat_V_to = e(V)
		capture drop res_to2
		qui predict res_to2 if `touse', deviance
	}

	matrix mat_subB_to = J(1, `nvar_sub2', .)
	forvalues c = 1/`nvar_sub2' {
		matrix mat_subB_to[1, `c'] = mat_B_to[1, `c']
	}

	qui cor `X' if `touse', cov
	matrix mat_subV_to = r(C)
		
	if "`continuous'" != "" | "`lpm'" != "" {		
		qui sum res_to if `touse'
		scalar scl_sigma_sqto = r(Var)	
	}
	if "`logit'" != "" {	
		matrix mat_VAR_to = mat_subB_to*mat_subV_to*mat_subB_to'
		scalar scl_var_to = mat_VAR_to[1,1]
		scalar scl_rsq_to = scl_var_to/(scl_var_to + _pi^2/3)	
	}
*capture noisily di "scl_rsq_to="scl_rsq_to
	
	*************************************************************
	*	
	*	ESTIMATION WITH UNOBSERVABLE
	*
	*	1ST ROUND: FIX C1 CHANGE C2
	*
	*************************************************************
	
	display as txt ""
	display "-----------------------------------------------------------"
	display "STEP3: 1ST CYCLE - FIX C1 CHANGE C2"
	display "CHECKING THE INITIAL VALUES OF C1 AND C2"
	display "-----------------------------------------------------------"
	*
	*	CHECKING WHETHER LOWERRIGHT LIMIT IS BELOW THE CONTOUR.
	*
	
	local flg_lr = 0
	capture drop gsa_pseudo_u
	qui gen gsa_pseudo_u = . if `touse'
	
	qui forvalues i = 1/10 {
	
		*	GENERATING TEMPORARY CONTINUOUS PSEUDO-UNOBSERVABLES (PU)
		gsa_pu `rhs' if `touse' , c1(`maxc1') c2(0) `gsa_pu_precision'

		*	CALCULATING TAU WITH PSEUDO UNOBSERVABLE
		if "`ycontinuous'" != "" | "`ylpm'" != "" {	
			reg `varlist' gsa_pseudo_u if `touse' , `vce'
		}
		if "`yprobit'" != "" {
			probit `varlist' gsa_pseudo_u if `touse' , `vce'
		}
		if "`ylogit'" != "" {
			logit `varlist' gsa_pseudo_u if `touse' , `vce'
		}
		matrix mat_B_yu = e(b)
		matrix mat_V_yu = e(V)
		scalar scl_b_tau_u = mat_B_yu[1,1]
		scalar scl_se_tau_u = sqrt(mat_V_yu[1,1])
		scalar scl_t_tau_u = scl_b_tau_u/scl_se_tau_u	

		if "`tau'" != "" {
			if scl_b_tau_u > `tau' {
				continue, break
			}
		}
		else {
			if scl_t_tau_u > `tstat' {
				continue, break
			}
		}
		local flg_lr = `flg_lr'+1
	}

	if `flg_lr'==10 {
		noisily display ""
		noisily display as error "Error: something is wrong with the data."
		exit
	}
	
	*
	*	CHECKING WHETHER UPPERRIGHT LIMIT IS ABOVE THE CONTOUR.
	*
	local flg_ur = 0
	qui forvalues i = 1/10 {

		*	GENERATING TEMPORARY CONTINUOUS PSEUDO-UNOBSERVABLES (PU)
		*	TRANSFORMING CONTINUOUS PU TO BINARY PU
		if "`binu'" != "" {							/* ADDED IN V11 */
			gsa_binpu `rhs' if `touse', c1(`maxc1') c2(`maxc2') `gsa_binpu_precision'
		}
		else {
			gsa_pu `rhs' if `touse', c1(`maxc1') c2(`maxc2') `gsa_pu_precision'
		}

		*	CALCULATING TAU WITH PSEUDO UNOBSERVABLE
		if "`ycontinuous'" != "" | "`ylpm'" != "" {	
			reg `varlist' gsa_pseudo_u if `touse' , `vce'
		}			
		if "`yprobit'" != "" {
			probit `varlist' gsa_pseudo_u if `touse' , `vce'
		}			
		if "`ylogit'" != "" {
			logit `varlist' gsa_pseudo_u if `touse' , `vce'
		}	
		matrix mat_B_yu = e(b)
		matrix mat_V_yu = e(V)
		scalar scl_b_tau_u = mat_B_yu[1,1]
		scalar scl_se_tau_u = sqrt(mat_V_yu[1,1])
		scalar scl_t_tau_u = scl_b_tau_u/scl_se_tau_u	

*noisily display "scl_b_tau_u="scl_b_tau_u

		*	ADD 1 TO flg_ur 
		if "`tau'" != "" {
			if scl_b_tau_u <= `tau' {
				continue, break
			}
		}
		else {
			if scl_t_tau_u <= `tstat' {
				continue, break
			}
		}
		local flg_ur = `flg_ur'+1
	}
	
	*	ERROR CODE WHEN C1 & C2 ARE TOO SMALL
	if `flg_ur'==10 {
		noisily display ""
		noisily display as error "Error: c1 and/or c2 are too small."
		exit
	}
	
	display "Done."	
	display ""
	display "-----------------------------------------------------------"
	display "STEP4: 1ST CYCLE - FIX C1 CHANGE C2"
	display "DETERMINING THE MAX VALUE OF C2"
	display "-----------------------------------------------------------"	

	local diff_range_1 = `maxc2'/`gsa_range_res'
	
	qui forvalues inv_c2_range_1 = 0(`diff_range_1')`maxc2' {
		local c2_range_1 = `maxc2'-`inv_c2_range_1'
		*	GENERATING TEMPORARY CONTINUOUS PSEUDO-UNOBSERVABLES (PU)
		*	TRANSFORMING CONTINUOUS PU TO BINARY PU
		if "`binu'" != "" {							/* ADDED IN V11 */
			gsa_binpu `rhs' if `touse', c1(`maxc1') c2(`c2_range_1') `gsa_binpu_precision'
		}
		else {
			gsa_pu `rhs' if `touse', c1(`maxc1') c2(`c2_range_1') `gsa_pu_precision'
		}
					
		*	CALCULATING TAU WITH PSEUDO UNOBSERVABLE
		if "`ycontinuous'" != "" | "`ylpm'" != "" {	
			reg `varlist' gsa_pseudo_u if `touse' , `vce'
		}			
		if "`yprobit'" != "" {
			probit `varlist' gsa_pseudo_u if `touse' , `vce'
		}			
		if "`ylogit'" != "" {
			logit `varlist' gsa_pseudo_u if `touse' , `vce'
		}	
		matrix mat_B_yu = e(b)
		matrix mat_V_yu = e(V)
		scalar scl_b_tau_u = mat_B_yu[1,1]
		scalar scl_se_tau_u = sqrt(mat_V_yu[1,1])
		scalar scl_t_tau_u = scl_b_tau_u/scl_se_tau_u	


* noisily display "scl_t_tau_u="scl_t_tau_u	

		if "`tau'" != "" {
			if scl_b_tau_u > `tau' {
				continue, break
			}
		}
		else {
			if scl_t_tau_u > `tstat' {
				continue, break
			}
		}	
	}
	local tempmax_1 = `c2_range_1'*1.2
	local round_maxc2 = round(`tempmax_1',.001)

	noisily display "Max c2 is set to `round_maxc2'."
	

	display ""
	display "-----------------------------------------------------------"
	display "STEP5: 1ST CYCLE - FIX C1 CHANGE C2"
	display "ESTIMATING ALPHA AND DELTA"
	display "-----------------------------------------------------------"	

	local local_maxc2_1 = `round_maxc2'
	local diff_c1_1 = `maxc1'/`observation'
	local diff_est_1 = `local_maxc2_1'/`resolution'
	local iter_id = 0
	local stop_iter_1 = 0
	local flg_dot = 0
	
	qui forvalues inv_c1_1 = 0(`diff_c1_1')`maxc1' {
	local c1_1 = `maxc1'-`inv_c1_1'
		forvalues c2_1 = 0(`diff_est_1')`local_maxc2_1' {
			*	GENERATING PSEUDO UNOBSERVABLES.
			if "`binu'" != "" {						/* ADDED IN V11 */
				gsa_binpu `rhs' if `touse', c1(`c1_1') c2(`c2_1') `gsa_binpu_precision'
			}
			else {
				gsa_pu `rhs' if `touse', c1(`c1_1') c2(`c2_1') `gsa_pu_precision'
			}
			
			*	CALCULATING TAU WITH PSEUDO UNOBSERVABLE
			if "`ycontinuous'" != "" | "`ylpm'" != "" {	
				reg `varlist' gsa_pseudo_u if `touse' , `vce'
				capture drop res_yu
				predict res_yu if `touse', resid
			}
			if "`yprobit'" != "" {
				probit `varlist' gsa_pseudo_u if `touse' , `vce'
			}
			if "`ylogit'" != "" {
				logit `varlist' gsa_pseudo_u if `touse' , `vce'
			}
			matrix mat_B_yu = e(b)
			matrix mat_V_yu = e(V)
			scalar scl_b_tau_u = mat_B_yu[1,1]
			scalar scl_se_tau_u = sqrt(mat_V_yu[1,1])
			scalar scl_t_tau_u = scl_b_tau_u/scl_se_tau_u		
			scalar scl_delta = mat_B_yu[1,`nvar']
			
			*	SETTING TAU OR TSTAT AS QUANTITY OF INTEREST
			if "`tau'" != "" {							/* ADDED IN V16 */
				local qoi scl_b_tau_u
			}
			else {
				local qoi scl_t_tau_u
			}

			*	CALCULATE QUANTITY OF INTERESTS IF PU SATISFIES CRITERIA.
			if `qoi'<`cutoff_tau_diff_ub' & `qoi'>`cutoff_tau_diff_lb' {
				gsa_qoi gsa_pseudo_u `rhs' if `touse', `vce' `ylogit' `yprobit' `ylpm' `ycontinuous' `probit' `logit' `lpm' `continuous' `binu'
*capture noisily di "scl_rsq_tu="scl_rsq_tu
				local iter_id = `iter_id' + 1
				local stop_iter_1 = 0
				tempname scl_partial_rsq_y`iter_id' scl_partial_rsq_t`iter_id' scl_rho_res_yu`iter_id' ///
				scl_rho_res_yu`iter_id' scl_rho_res_tu`iter_id' scl_alpha`iter_id' scl_delta`iter_id' ///
				scl_c1`iter_id' scl_c2`iter_id'
				scalar `scl_c1`iter_id'' = `c1_1'
				scalar `scl_c2`iter_id'' = `c2_1'
				if "`yprobit'" == "" { 
					scalar `scl_partial_rsq_y`iter_id'' = scalar(scl_partial_rsq_y)
				}
				if "`probit'" == "" { 
					scalar `scl_partial_rsq_t`iter_id'' = scalar(scl_partial_rsq_t)
				}
				scalar `scl_rho_res_yu`iter_id'' = scalar(scl_rho_res_yu)
				scalar `scl_rho_res_tu`iter_id'' = scalar(scl_rho_res_tu)
				scalar `scl_alpha`iter_id'' = scalar(scl_alpha)
				scalar `scl_delta`iter_id'' = scalar(scl_delta)
				foreach scl in scl_partial_rsq_y scl_partial_rsq_t scl_rho_res_yu scl_rho_res_tu scl_alpha scl_delta {
					capture scalar drop `scl'
				}
				local flg_dot = 0
				continue, break
			}
			local flg_dot = `flg_dot' + 1
		}
		
		local stop_iter_1 = `stop_iter_1' + 1

		*	SHOW # OF ITERATION IN DOTS and X
		noisily if "`dots'" != "nodots" {
			if `flg_dot' < `resolution' {
				display as txt "." _continue
			}
			else {
				display in red "x" _continue
			}
		}
			
/*
noisily di "c1_1="`scl_c1_1_`iter_id''
noisily di "c2_1="`scl_c2_1_`iter_id''
noisily di "scl_partial_rsq_y="`scl_partial_rsq_y`iter_id''
noisily di "scl_partial_rsq_t="`scl_partial_rsq_t`iter_id''
noisily di "scl_rho_res_yu="`scl_rho_res_yu`iter_id''
noisily di "scl_rho_res_tu="`scl_rho_res_tu`iter_id''
noisily di "alpha="`scl_alpha`iter_id''
noisily di "delta="`scl_delta`iter_id''
noisily di "iter_id="`iter_id'
*/	
		
		* EXIT LOOP IF GSA CANNOT FIND ALPHA & DELTA IN THIS LOOP
		if `stop_iter_1'>=`iter_tolerance' {
			continue, break
		}
		
		*	INCREASE THE NUMBER OF OBSERVATION
		qui if _N<`iter_id' {
			set obs `iter_id'
		}
		
		* RECORDING VARIABLES
		foreach var in c1 c2 alpha delta partial_rsq_y partial_rsq_t rho_res_yu rho_res_tu {
			capture replace gsa_`var' = `scl_`var'`iter_id'' if [_n]==`iter_id'
		}
	}
	
	*************************************************************
	*	
	*	ESTIMATION WITH UNOBSERVABLE
	*
	*	2ND ROUND: CHANGE C1 FIX C2
	*
	*************************************************************
	display as txt ""
	display "-----------------------------------------------------------"
	display "STEP6: 2ND CYCLE - FIX C2 CHANGE C1"
	display "CHECKING THE INITIAL VALUES OF C1 AND C2"
	display "-----------------------------------------------------------"
	
	*
	*	CHECKING WHETHER UPPERLEFT LIMIT IS TO THE LEFT THE CONTOUR.
	*
	local flg_ul = 0
	capture drop gsa_pseudo_u
	qui gen gsa_pseudo_u = . if `touse'
	
	qui forvalues i = 1/10 {
	
		*	GENERATING TEMPORARY CONTINUOUS PSEUDO-UNOBSERVABLES (PU)
		gsa_pu `rhs' if `touse', c1(0) c2(`maxc2') `gsa_pu_precision'

		*	CALCULATING TAU WITH PSEUDO UNOBSERVABLE
		if "`ycontinuous'" != "" | "`ylpm'" != "" {	
			reg `varlist' gsa_pseudo_u if `touse' , `vce'
		}
		if "`yprobit'" != "" {
			probit `varlist' gsa_pseudo_u if `touse' , `vce'
		}
		if "`ylogit'" != "" {
			logit `varlist' gsa_pseudo_u if `touse' , `vce'
		}
		matrix mat_B_yu = e(b)
		matrix mat_V_yu = e(V)
		scalar scl_b_tau_u = mat_B_yu[1,1]
		scalar scl_se_tau_u = sqrt(mat_V_yu[1,1])
		scalar scl_t_tau_u = scl_b_tau_u/scl_se_tau_u	

		if "`tau'" != "" {
			if scl_b_tau_u > `tau' { /*PROGRAM ENDS IF VALUE IS OK */
				continue, break
			}
		}
		else {
			if scl_t_tau_u > `tstat' {
				continue, break
			}
		}
		local flg_ul = `flg_ul'+1
	}

	if `flg_ul'==10 {
		noisily display ""
		noisily display as error "Error: something is wrong with the data."
		exit
	}

	*
	*	CHECKING WHETHER UPPERRIGHT LIMIT IS TO THE RIGHT OF THE CONTOUR.
	*
	local flg_ur2 = 0
	qui forvalues i = 1/10 {

		*	GENERATING TEMPORARY CONTINUOUS PSEUDO-UNOBSERVABLES (PU)
		*	TRANSFORMING CONTINUOUS PU TO BINARY PU
		if "`binu'" != "" {							/* ADDED IN V11 */
			gsa_binpu `rhs' if `touse', c1(`maxc1') c2(`maxc2') `gsa_binpu_precision'
		}
		else {
			gsa_pu `rhs' if `touse', c1(`maxc1') c2(`maxc2') `gsa_pu_precision'
		}

		*	CALCULATING TAU WITH PSEUDO UNOBSERVABLE
		if "`ycontinuous'" != "" | "`ylpm'" != "" {	
			reg `varlist' gsa_pseudo_u if `touse' , `vce'
		}			
		if "`yprobit'" != "" {
			probit `varlist' gsa_pseudo_u if `touse' , `vce'
		}			
		if "`ylogit'" != "" {
			logit `varlist' gsa_pseudo_u if `touse' , `vce'
		}	
		matrix mat_B_yu = e(b)
		matrix mat_V_yu = e(V)
		scalar scl_b_tau_u = mat_B_yu[1,1]
		scalar scl_se_tau_u = sqrt(mat_V_yu[1,1])
		scalar scl_t_tau_u = scl_b_tau_u/scl_se_tau_u	

*noisily display "scl_t_tau_u="scl_t_tau_u

		*	ADD 1 TO flg_ur2
		if "`tau'" != "" {
			if scl_b_tau_u <= `tau' { /*PROGRAM ENDS IF VALUE IS OK */
				continue, break
			}
		}
		else {
			if scl_t_tau_u <= `tstat' {
				continue, break
			}
		}
		local flg_ur2 = `flg_ur2'+1
	}
	
	*	ERROR CODE WHEN C1 & C2 ARE TOO SMALL
	if `flg_ur2'==10 {
		noisily display ""
		noisily display as error "Error: c1 and/or c2 are too small."
		exit
	}

	display "Done."
	display ""
	display "-----------------------------------------------------------"
	display "STEP7: 2ND CYCLE - FIX C2 CHANGE C1"
	display "DETERMINING THE MAX VALUE OF C1"
	display "-----------------------------------------------------------"	
	
	local diff_range_2 = `maxc1'/`gsa_range_res'
	
	qui forvalues inv_c1_range_2 = 0(`diff_range_2')`maxc1' {
		local c1_range_2 = `maxc1'-`inv_c1_range_2'
		*	GENERATING TEMPORARY CONTINUOUS PSEUDO-UNOBSERVABLES (PU)
		*	TRANSFORMING CONTINUOUS PU TO BINARY PU
		if "`binu'" != "" {							/* ADDED IN V11 */
			gsa_binpu `rhs' if `touse', c1(`c1_range_2') c2(`maxc2') `gsa_binpu_precision'
		}
		else {
			gsa_pu `rhs' if `touse', c1(`c1_range_2') c2(`maxc2') `gsa_pu_precision'
		}
					
		*	CALCULATING TAU WITH PSEUDO UNOBSERVABLE
		if "`ycontinuous'" != "" | "`ylpm'" != "" {	
			reg `varlist' gsa_pseudo_u if `touse' , `vce'
		}			
		if "`yprobit'" != "" {
			probit `varlist' gsa_pseudo_u if `touse' , `vce'
		}			
		if "`ylogit'" != "" {
			logit `varlist' gsa_pseudo_u if `touse' , `vce'
		}	
		matrix mat_B_yu = e(b)
		matrix mat_V_yu = e(V)
		scalar scl_b_tau_u = mat_B_yu[1,1]
		scalar scl_se_tau_u = sqrt(mat_V_yu[1,1])
		scalar scl_t_tau_u = scl_b_tau_u/scl_se_tau_u	

*noisily display "scl_t_tau_u="scl_t_tau_u	

		if "`tau'" != "" {
			if scl_b_tau_u > `tau' {
				continue, break
			}
		}
		else {
			if scl_t_tau_u > `tstat' {
				continue, break
			}
		}	
	}

	local tempmax_2 = `c1_range_2'*1.2
	local round_maxc1 = round(`tempmax_2',.001)
	noisily display "Max c1 is set to `round_maxc1'." 
	
	display ""
	display "-----------------------------------------------------------"
	display "STEP8: 2ND CYCLE - FIX C2 CHANGE C1"
	display "ESTIMATING ALPHA AND DELTA"
	display "-----------------------------------------------------------"	
	
	local local_maxc1_2 = `round_maxc1'
	local diff_c2_2 = `maxc2'/`observation'
	local diff_est_2 = `local_maxc1_2'/`resolution'
	local iter_id = `iter_id'
	local stop_iter_2 = 0
	local flg_dot = 0
	
	qui forvalues inv_c2_2 = 0(`diff_c2_2')`maxc2' {
	local c2_2 = `maxc2'-`inv_c2_2'
		forvalues c1_2 = 0(`diff_est_2')`local_maxc1_2' {

			if "`binu'" != "" {						/* ADDED IN V11 */
				gsa_binpu `rhs' if `touse', c1(`c1_2') c2(`c2_2') `gsa_binpu_precision'
			}
			else {
				gsa_pu `rhs' if `touse', c1(`c1_2') c2(`c2_2') `gsa_pu_precision'
			}
			
			*	CALCULATING TAU WITH PSEUDO UNOBSERVABLE
			if "`ycontinuous'" != "" | "`ylpm'" != "" {	
				reg `varlist' gsa_pseudo_u if `touse' , `vce'
				capture drop res_yu
				predict res_yu if `touse', resid
			}
			if "`yprobit'" != "" {
				probit `varlist' gsa_pseudo_u if `touse' , `vce'
			}
			if "`ylogit'" != "" {
				logit `varlist' gsa_pseudo_u if `touse' , `vce'
			}
			matrix mat_B_yu = e(b)
			matrix mat_V_yu = e(V)
			scalar scl_b_tau_u = mat_B_yu[1,1]
			scalar scl_se_tau_u = sqrt(mat_V_yu[1,1])
			scalar scl_t_tau_u = scl_b_tau_u/scl_se_tau_u		
			scalar scl_delta = mat_B_yu[1,`nvar']
			
*noisily display "scl_t_tau_u=" scl_t_tau_u	

			*	SETTING TAU OR TSTAT AS QUANTITY OF INTEREST
			if "`tau'" != "" {							/* ADDED IN V16 */
				local qoi scl_b_tau_u
			}
			else {
				local qoi scl_t_tau_u
			}

			*	CALCULATE QUANTITY OF INTERESTS IF PU SATISFIES CRITERIA.
			if `qoi'<`cutoff_tau_diff_ub' & `qoi'>`cutoff_tau_diff_lb' {
				gsa_qoi gsa_pseudo_u `rhs' if `touse', `vce' `ylogit' `yprobit' `ylpm' `ycontinuous' `probit' `logit' `lpm' `continuous' `binu'
				local iter_id = `iter_id' + 1
				local stop_iter_2 = 0
				tempname scl_partial_rsq_y`iter_id' scl_partial_rsq_t`iter_id' scl_rho_res_yu`iter_id' ///
				scl_rho_res_yu`iter_id' scl_rho_res_tu`iter_id' scl_alpha`iter_id' scl_delta`iter_id' ///
				scl_c1`iter_id' scl_c2`iter_id'
				scalar `scl_c1`iter_id'' = `c1_2'
				scalar `scl_c2`iter_id'' = `c2_2'
				if "`yprobit'" == "" { 
					scalar `scl_partial_rsq_y`iter_id'' = scalar(scl_partial_rsq_y)
				}
				if "`probit'" == "" { 
					scalar `scl_partial_rsq_t`iter_id'' = scalar(scl_partial_rsq_t)
				}
				scalar `scl_rho_res_yu`iter_id'' = scalar(scl_rho_res_yu)
				scalar `scl_rho_res_tu`iter_id'' = scalar(scl_rho_res_tu)
				scalar `scl_alpha`iter_id'' = scalar(scl_alpha)
				scalar `scl_delta`iter_id'' = scalar(scl_delta)
				foreach scl in scl_partial_rsq_y scl_partial_rsq_t scl_rho_res_yu scl_rho_res_tu scl_alpha scl_delta {
					capture scalar drop `scl'
				}
				local flg_dot = 0
				continue, break
			}
			local flg_dot = `flg_dot' + 1
		}
		
		local stop_iter_2 = `stop_iter_2' + 1

		*	SHOW # OF ITERATION IN DOTS and X
		noisily if "`dots'" != "nodots" {
			if `flg_dot' < `resolution' {
				display as txt "." _continue
			}
			else {
				display in red "x" _continue
			}
		}
		
/*
noisily di "c1_2="`scl_c1_2`iter_id''
noisily di "c2_2="`scl_c2_2`iter_id''
noisily di "scl_partial_rsq_y="`scl_partial_rsq_y`iter_id''
noisily di "scl_partial_rsq_t="`scl_partial_rsq_t`iter_id''
noisily di "scl_rho_res_yu="`scl_rho_res_yu`iter_id''
noisily di "scl_rho_res_tu="`scl_rho_res_tu`iter_id''
noisily di "alpha="`scl_alpha`iter_id''
noisily di "delta="`scl_delta`iter_id''
noisily di "iter_id="`iter_id'
*/

		* EXIT LOOP IF GSA CANNOT FIND ALPHA & DELTA IN THIS LOOP
		if `stop_iter_2'>=`iter_tolerance' {
			continue, break
		}
	
		*	INCREASE THE NUMBER OF OBSERVATION
		qui if _N<`iter_id' {
			set obs `iter_id'
		}
		
		* RECORDING QUANTITY OF INTERESTS INTO VARIABLES
		foreach var in c1 c2 alpha delta partial_rsq_y partial_rsq_t rho_res_yu rho_res_tu {
			capture replace gsa_`var' = `scl_`var'`iter_id'' if [_n]==`iter_id'
		}		
	}

	display as txt ""

	display ""
	display "-----------------------------------------------------------"
	display "STEP9: ESTIMATING ALPHA AND DELTA OF EACH CTRL VARIABLES"
	display "-----------------------------------------------------------"		
	
	*GENERATING VARIABLES INTO WHICH THE ESTIMATES ARE RECORDED
	qui foreach var in gsa_partial_rsq_yx gsa_partial_rsq_tx gsa_rho_res_yx gsa_rho_res_tx {
		gen `var' = . if `touse'
	}

			
	*	DE-SELECTING EACH X FROM VARLIST

	if nvar_sub2 <= 10	{											/* ADDED IN V33 */
		local iter_step9 = nvar_sub2
	}
	else	{
		local iter_step9 = 10
	}

	qui forvalues k = 1/`iter_step9' {

		if nvar_sub2 <= 10 {
			tokenize `X'
			local X_`k' = subinword("`X'","``k''","",.)
		}
		else {													/* ADDED IN V33 */
			local restX_0 `X'
			forvalues i9 = 0/9 {
				local j9 = `i9'+1
				gettoken `j9' restX_`j9' : restX_`i9'
			}
			local fst10 `1' `2' `3' `4' `5' `6' `7' `8' `9' `10'
			local fst10_`k' = subinword("`fst10'","``k''","",.)
			local X_`k' `fst10_`k'' `restX_10'
		}

		*	ESTIMATING X-OMITTED PARTIAL R-SQ FOR OUTCOME EQ.
		*	UPDATING "res_yo" EXCLUDING ONE OF COVARIATES.
		if "`ycontinuous'" != "" | "`ylpm'" != "" {	
			reg `y' `t' `X_`k'' if `touse' , `vce'
			capture drop res_yu
			predict res_yu if `touse', resid								/* for gsa_qoi */
			capture drop res_yo
			predict res_yo if `touse', resid								/* for gsa_qoi	not problem b/c scl_sigma_sqyo is unchanged. */
		}	
		if "`yprobit'" != "" {
			probit `y' `t' `X_`k'' if `touse' , `vce'
			capture drop res_yo
			predict res_yo if `touse', deviance
		}	
		if "`ylogit'" != "" {
			logit `y' `t' `X_`k'' if `touse' , `vce'
			capture drop res_yo
			predict res_yo if `touse', deviance
		}
		matrix mat_B_yu = e(b)
		matrix mat_V_yu = e(V)
		scalar scl_b_tau_u = mat_B_yu[1,1]
		scalar scl_se_tau_u = sqrt(mat_V_yu[1,1])
		scalar scl_t_tau_u = scl_b_tau_u/scl_se_tau_u		
		scalar scl_delta = 0	/* added to avoid error in gsa_qoi	*/

		matrix mat_subB_yu = J(1, `nvar_sub2', .)
		forvalues c = 1/`nvar_sub2' {
			matrix mat_subB_yu[1, `c'] = mat_B_yu[1, `c']
		}

		qui cor `t' `X_`k'' if `touse', cov
		matrix mat_subV_yu = r(C)
		matrix mat_VAR_yu = mat_subB_yu*mat_subV_yu*mat_subB_yu'
		scalar scl_var_yu = mat_VAR_yu[1,1]
		scalar scl_rsq_yu = scl_var_yu/(scl_var_yu + _pi^2/3)	
		
		*	ESTIMATING X-OMITTED PARTIAL R-SQ FOR TREATMENT EQ.
		if "`continuous'" != "" | "`lpm'" != "" {		
			reg `t' `X_`k'' if `touse' , `vce'
			capture drop res_to2
			predict res_to2 if `touse', resid
			sum res_to2 if `touse'
			scalar scl_sigma_sqtu = r(Var)	
		}
		
		if "`probit'" != "" {					/* ADDED IN V9 */
			probit `t' `X_`k'' if `touse' , `vce'
			capture drop res_to2
			predict res_to2 if `touse', deviance
			sum res_to2 if `touse'
		}
	
		*	UPDATING "scl_rsq_to" EXCLUDING ONE OF COVARIATES.
		if "`logit'" != "" {
			logit `t' `X_`k'' if `touse' , `vce'
			capture drop res_to2
			predict res_to2 if `touse', deviance
			sum res_to2 if `touse'
			matrix mat_B_tu = e(b)
			matrix mat_V_tu = e(V)
			matrix mat_subB_tu = J(1, `nvar_sub3', .)
			forvalues c = 1/`nvar_sub3' {
				matrix mat_subB_tu[1, `c'] = mat_B_tu[1, `c']
			}
		
			qui cor `X_`k'' if `touse', cov
			matrix mat_subV_tu = r(C)
			
			matrix mat_VAR_tu = mat_subB_tu*mat_subV_tu*mat_subB_tu'
			scalar scl_var_tu = mat_VAR_tu[1,1]
			scalar scl_rsq_tu = scl_var_tu/(scl_var_tu + _pi^2/3)
		}
	
				
		*	CALCULATE QUANTITY OF INTERESTS.
		gsa_qoi ``k'' `t' `X_`k'' if `touse', `vce' `ylogit' `yprobit' `ylpm' `ycontinuous' `probit' `logit' `lpm' `continuous' `binu'		

		
		*	RECORDING QUANTITY OF INTERESTS
		tempname scl_partial_rsq_yx`k' scl_partial_rsq_tx`k' scl_rho_res_yx`k' scl_rho_res_tx`k'
		if "`ycontinuous'" != "" | "`ylpm'" != "" { 
			scalar `scl_partial_rsq_yx`k'' = scalar(scl_partial_rsq_y)
		}
		if "`ylogit'" != "" { 
			scalar `scl_partial_rsq_yx`k'' = abs((scl_rsq_yu - scl_rsq_yo)/(1-scl_rsq_yo))
		}
		if "`continuous'" != "" | "`lpm'" != "" {
			scalar `scl_partial_rsq_tx`k'' = abs((scl_sigma_sqto - scl_sigma_sqtu)/scl_sigma_sqto)
		}
		if "`logit'" != "" {	
			scalar `scl_partial_rsq_tx`k'' = abs((scl_rsq_tu - scl_rsq_to)/(1-scl_rsq_to))
		}
		scalar `scl_rho_res_yx`k'' = scalar(scl_rho_res_yu)
		scalar `scl_rho_res_tx`k'' = scalar(scl_rho_res_tu)
		foreach scl in scl_partial_rsq_y scl_partial_rsq_t scl_rho_res_yu scl_rho_res_tu scl_alpha  {
			capture scalar drop `scl'
		}		
		* RECORDING QUANTITY OF INTERESTS INTO VARIABLES
		foreach var in partial_rsq_yx partial_rsq_tx rho_res_yx rho_res_tx {
			capture replace gsa_`var' = `scl_`var'`k'' if _n==`k'	
		}
	}

	display "Done."	
	display ""
	display "-----------------------------------------------------------"
	display "STEP10: DRAWING CONTOUR"
	display "-----------------------------------------------------------"	
	
	if "`print'" != "noprint" {	
		gsagraph `varlist' if gsa_alpha>0 & gsa_delta>0, tau(`tau') tstat(`tstat') `correlation' `fractional' `quadratic' `lowess' `nplots' `scatter'
	}

	*	DELETING VARIABLES, SCALARS AND MATRICES
	qui foreach var in res_to hat_to res_yu res_yo res_to2 gsa_pseudo_u{
		capture drop `var'
	}

	qui foreach scl in scl_alpha scl_delta scl_covUT nvar_sub3 nvar_sub2 nvar_sub1 nvar {
			capture scalar drop `scl'
	}
	qui foreach scl1 in b_tau_ se_tau_ t_tau_ sigma_sqy sigma_sqt {
		foreach scl2 in o u {
			capture scalar drop scl_`scl1'`scl2'
		}
	}
	qui foreach scl1 in rsq var {
		foreach scl2 in yo to yu tu {
			capture scalar drop scl_`scl1'_`scl2'
		}
	}
		
	qui foreach mat1 in B V subB subV VAR {
		foreach mat2 in yo to yu tu {
			capture matrix drop mat_`mat1'_`mat2'
		}
	}
	
end	
