*capture program drop isa_2nd_loop

*********************************************************************
*	MAIN PROGRAM
program define isa_2nd_loop
	version 9
	syntax varlist [if] [in] [fw aw], [vce(passthru)] [TAU(numlist >0)] [TSTAT(numlist >0)] ///
	[MINAlpha(real 0)] [MAXAlpha(real 10)] [MINDelta(real 0)] [MAXDelta(real 5)] ///
	[OBServation(int 20)] [RESolution(int 20)] [PRECision(real 0.1)] ///
	[ml_iterate(passthru)] [noDOTS] [quick]

	marksample touse
	
	if "`tau'" != "" {
		local qoi = `tau'
		local est_qoi "scalar(tau)"
	}
	else {
		local qoi = `tstat'
		local est_qoi "scalar(t)"
	}
	
	local diff_delta = (`maxdelta' - `mindelta')/(`observation'-1)
	forvalue inv_delta = 0(`diff_delta')`maxdelta' {
		
		*	(RE)SETTING PARAMETERS
		local delta = `maxdelta'- `inv_delta'
		local maxalpha2 = `maxalpha'
		local counter_res = 0
		local alpha_base = 0
		local iter_alpha = 0
		
		forvalues z = 1/99999999 {
			local counter_res = `counter_res'+1
			if `counter_res' > `resolution' {
				noisily if "`dots'" != "nodots" {
					display in red "x" _continue
				}		
				continue, break
			}
			local iter_alpha = `iter_alpha'+1
			local alpha = (`maxalpha2'-`alpha_base')/2^`iter_alpha'+`alpha_base'
			capture isa_est `varlist' if `touse' [`weight'`exp'], alpha(`alpha') delta(`delta') `vce'
			local converge = e(converged)
			scalar tau = .
			scalar se = .
			scalar t = .			
			if `converge'==1 {
				matrix matB = e(b)
				matrix matV = e(V)
				scalar tau = matB[1,1]
				scalar se = sqrt(matV[1,1])
				scalar t = scalar(tau)/scalar(se)
			}
			else {		
				noisily if "`dots'" != "nodots" {
					display in red "x" _continue
				}	
				continue, break
			}
			
			* 	RECORD ESTIMATES IF THEY ARE CLOSE ENOUGH TO THE TARGET VALUE
			if abs(`est_qoi' - `qoi') < `qoi'*(`precision'/100) {
				*	ESTIMATING UPDATED R-SQ FOR TREATMENT ASSIGNMENT EQ.	
				isa_rsq_treat `varlist' if `touse' [`weight'`exp'], alpha(`alpha')
				scalar rsq_tu = scalar(rsq_t)
					
				*	ESTIMATING UPDATED R-SQ FOR OUTCOME EQ.	
				isa_rsq_outcome `varlist' 
				scalar sigma_squ = scalar(sigma_sq)

				*	CALCULATING PARTIAL R-SQUARES for OUTCOME AND TREATMENT EQUATIONS
				local partial_rsq_y = (sigma_sqo - sigma_squ)/sigma_sqo
				local partial_rsq_t = (rsq_tu - rsq_to)/(1-rsq_to)
				
				*	RECORDING QUANTITIES OF INTEREST TO EACH CELL
				local row = round(`inv_delta'/`diff_delta'+1+`observation',1)
				qui replace isa_tau = scalar(tau) if [_n] ==`row'
				qui replace isa_se = scalar(se) if [_n] ==`row'
				qui replace isa_t = scalar(t) if [_n] ==`row'
				qui replace isa_converge = `converge'  if [_n] ==`row'
				qui replace isa_alpha = `alpha' if [_n] ==`row'
				qui replace isa_delta = `delta' if [_n] ==`row'
				qui replace isa_partial_rsq_y = `partial_rsq_y' if [_n] ==`row'
				qui replace isa_partial_rsq_t = `partial_rsq_t' if [_n] ==`row'
				noisily if "`dots'" != "nodots" {
					display as txt "." _continue
				}				
				continue, break
			}
			
			*	END THE 2ND ITERATION IF `maxdelta'*.75 IS ABOVE CONTOUR 
			if "`quick'" != "" {
				if `est_qoi' > `qoi' & `alpha'>=`maxalpha'*.75 {
					noisily if "`dots'" != "nodots" {
						display in red "x" _continue
					}	
					continue, break
				}
			}
			
			if `est_qoi' > `qoi' {
				local maxalpha2 = (`alpha'-`alpha_base')*2 +`alpha_base'
				local iter_alpha = 0
				local alpha_base = `alpha'
			}
		}

		if "`quick'" != "" {
			if `est_qoi'>`qoi' & `alpha'>=`maxalpha'*.75 & `converge'==1 {
				continue, break
			}
		}
	}
	
end	
	
	
	
