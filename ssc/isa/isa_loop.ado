
*********************************************************************
*	LOOPING COMMAND OF ISA_EST IN THIRD DETAILED RUN

program define isa_loop
	version 9
	syntax varlist [if] [in], [vce(passthru)] [TAU(numlist)] [TSTAT(numlist)] iter_alpha(int) iter_delta(int) ///
	step(int) minalpha(real) maxalpha(real) mindelta(real) maxdelta(real)

	marksample touse
	gettoken y rhs : varlist
	gettoken t X :rhs
	
	local step_m1 = `step'-1
	
	foreach var in tau se t qoi_diff converge alpha delta partial_rsq_y partial_rsq_t {
		gen `var' = .
	}
	
	*	ESTIMATING UPDATED TREATMENT EFFECT WITH UNOBSERVABLES
	forvalues a = 1/`iter_alpha' {
		local diff_alpha = `maxalpha' - `minalpha'
		local alpha = `diff_alpha'/(`iter_alpha'-1)^3*(`a'-1)^3+`minalpha'
		
		forvalues d = 2/`iter_delta' {
			
			*	SKIP ESTIMATION IF NO POINT IS FOUND IN 1ST STEP.
			if converge`step_m1'[`a']!=1{
				continue, break
			}	
			
			local diff_delta = `maxdelta' - `mindelta'
			local d0 = delta`step_m1'[`a'] - `diff_delta'/(`iter_delta'-1)^`step_m1'
			local delta = `diff_delta'/(`iter_delta'-1)^`step'*(`d'-1) + `d0'
			isa_est `varlist' if `touse', alpha(`alpha') delta(`delta') `vce'
			matrix tempB = e(b)
			matrix tempV = e(V)
			scalar tau = tempB[1,1]
			scalar se = sqrt(tempV[1,1])
			scalar t = scalar(tau)/scalar(se)
			if "`tau'" != "" {
				scalar qoi_diff = scalar(tau) - scalar(tau_o)
				local bias = scalar(tau_o)-`tau'
			}
			else {
				scalar qoi_diff = scalar(t) - scalar(t_o)
				local bias = scalar(t_o)-`tstat'
			}
			*	ESTIMATING UPDATED R-SQ FOR TREATMENT ASSIGNMENT EQ.	
			isa_rsq_treat `varlist' if `touse', alpha(`alpha')
			scalar rsq_tu = scalar(rsq_t)
			scalar drop var_t rsq_t
				
			*	ESTIMATING X-OMITTED R-SQ FOR OUTCOME EQ.	
			isa_rsq_outcome `varlist' if `touse' 
			scalar sigma_squ = scalar(sigma_sq)
			scalar drop sigma_sq
				
			matrix drop tempB tempV
			
			if abs(scalar(qoi_diff))> `bias' | (abs(scalar(qoi_diff))<=`bias' & `d'==`iter_delta') {

				*	CALCULATING PARTIAL R-SQUARES for OUTCOME AND TREATMENT EQUATIONS
				local partial_rsq_y = (sigma_sqo - sigma_squ)/sigma_sqo
				local partial_rsq_t = (rsq_tu - rsq_to)/(1-rsq_to)
				
				*	RECORDING QUANTITIES OF INTEREST TO EACH CELL
				replace tau = scalar(tau) if [_n] ==`a'
				replace se = scalar(se) if [_n] ==`a'
				replace t = scalar(t) if [_n] ==`a'
				replace qoi_diff = scalar(qoi_diff) if [_n] ==`a'
				replace converge = e(converged) if [_n] ==`a'
				replace converge = 0 if [_n] ==`a' & (abs(scalar(qoi_diff))<`bias' & `d'==`iter_delta')
				replace converge = 0 if [_n] ==`a' & (abs(scalar(qoi_diff))>`bias' & `d'==1)
				replace alpha = `alpha' if [_n] ==`a'
				replace delta = `delta' if [_n] ==`a'
				replace partial_rsq_y = `partial_rsq_y' if [_n] ==`a'
				replace partial_rsq_t = `partial_rsq_t' if [_n] ==`a'
				
				continue, break
			}
		}
	}
	
end

