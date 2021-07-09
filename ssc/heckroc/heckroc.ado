*!  version 1.0.0 28feb2017

program heckroc, rclass
    version 12
	
	syntax varlist (numeric min=2 max=2) [if] [in] [fweight], SELect(string) ///
			[																 ///
			collinear Level(cilevel) table 									 ///
			noci NOGraph NOEMPirical NOREFline cbands vce(string) Robust	 ///
			DIFficult TECHnique(string) TOLerance(real 1e-6) 	 			 ///
			LTOLerance(real 1e-7) NRTOLerance(real 1e-5)					 ///
			*																 ///
			]

	local maxopts `difficult' tech(`technique') tol(`tolerance') 			 ///
		ltol(`ltolerance') nrtol(`nrtolerance') 
	_get_gropts, graphopts(`options') getallowed(irocopts erocopts rlopts cbopts)
	local twowayopts `"`s(graphopts)'"'
	local rlopts	`"`s(rlopts)'"'
	local irocopts	`"`s(irocopts)'"'
	local erocopts	`"`s(erocopts)'"'
	local cbopts	`"`s(cbopts)'"'
	_check4gropts irocopts, opt(`irocopts')
	_check4gropts erocopts, opt(`erocopts')
	_check4gropts rlopts, opt(`rlopts')
	_check4gropts cbopts, opt(`cbopts')
	
	if "`cbands'"!="" & "`ci'"!="" {
		di as err "{p}option {bf:noci} may not be specified with {bf:cbands}{p_end}"
		exit 198
	}
/* Call preserve because we will need to create new variables later for integration*/
	preserve
	
/* Standardize */
	gettoken y rhs : varlist
	qui sum `rhs'
	local mean =r(mean)
	local sd   =r(sd)
	tempvar std_rhs
	gen `std_rhs' =(`rhs'-`mean')/`sd'

/* Display table*/
	if `"`table'"' != "" table `y' `rhs', row col
	
/* Get the empirical AUC for later */
	quietly roctab `y' `rhs'
	local emp_auc= r(area)

	
/* Call heckprob and derive estimates from the output */
	cap qui heckprob `y' `std_rhs' `if' `in' `fweight', select(`select') 	 ///
		`collinear' `maxopts' vce(`vce') `robust'
	if _rc {
		if e(converged)==0 {
			di as err "{p}{bf:heckprobit} failed to converge{p_end}"
			exit 198
		}
		else {
			heckprob `y' `std_rhs' `if' `in' `weight',select(`select') 		 ///
				`collinear' `maxopts' vce(`vce') `robust'
		}
	}
	
	local rho_ap = sign([`y']_b[`std_rhs'])*([`y']_b[`std_rhs']^2/(1+		 ///
		[`y']_b[`std_rhs']^2))^.5
	local p_star = ([`y']_cons)*(1-`rho_ap'^2)^.5
	
	
/* Create confidence intervals for rho_ap and p_star */
	tempvar heckprob_var
	matrix `heckprob_var'=e(V)
	local rho_ap_lb=sign([`y']_b[`std_rhs']-invnormal(1-`level'/200)*		 ///
		`heckprob_var'[1,1]^.5)*(([`y']_b[`std_rhs']-invnormal(0.975)*		 ///
		`heckprob_var'[1,1]^.5)^2/(1+([`y']_b[`std_rhs']-invnormal(0.975)*   ///
		`heckprob_var'[1,1]^.5)^2))^.5
	local rho_ap_ub=sign([`y']_b[`std_rhs']+invnormal(1-`level'/200)*		 ///
		`heckprob_var'[1,1]^.5)*(([`y']_b[`std_rhs']+invnormal(0.975)*		 ///
		`heckprob_var'[1,1]^.5)^2/(1+([`y']_b[`std_rhs']+invnormal(0.975)*	 ///
		`heckprob_var'[1,1]^.5)^2))^.5
	if sign(`rho_ap_lb'*`rho_ap_ub'){
		if abs(`rho_ap_lb') < abs(`rho_ap_ub') {
			local p_star_lb=([`y']_cons-invnormal(1-`level'/200)*			 ///
				`heckprob_var'[2,2]^.5)*(1-(`rho_ap_lb')^2)^.5
			local p_star_ub=([`y']_cons+invnormal(1-`level'/200)*			 ///
				`heckprob_var'[2,2]^.5)*(1-(`rho_ap_ub')^2)^.5
		}
		else {
			local p_star_lb=([`y']_cons-invnormal(1-`level'/200)*			 ///
				`heckprob_var'[2,2]^.5)*(1-(`rho_ap_ub')^2)^.5
			local p_star_ub=([`y']_cons+invnormal(1-`level'/200)*			 ///
			`heckprob_var'[2,2]^.5)*(1-(`rho_ap_lb')^2)^.5
		}
	}
	else{
		if abs(`rho_ap_lb') < abs(`rho_ap_ub') {
			local p_star_lb=([`y']_cons-invnormal(1-`level'/200)*			 ///
				`heckprob_var'[2,2]^.5)*(1-0)^.5
			local p_star_ub=([`y']_cons+invnormal(1-`level'/200)*			 ///
				`heckprob_var'[2,2]^.5)*(1-(`rho_ap_ub')^2)^.5
		}
		else {
			local p_star_lb=([`y']_cons-invnormal(1-`level'/200)*			 ///
				`heckprob_var'[2,2]^.5)*(1-0)^.5
			local p_star_ub=([`y']_cons+invnormal(1-`level'/200)*			 ///
				`heckprob_var'[2,2]^.5)*(1-(`rho_ap_lb')^2)^.5
		}
	}
	/* End of creating CI for rho_ap and p_star  */
	
	di as text _n "Estimating inferred ROC curve..."
/*
  I am creating the variables x_for_integ and y_for_integ to calcuate the integrals using integ.
      The values from integ (when 1000 points are used) are very similar to those obtained by
	  using the user-written command "integrate".
  I am using min(max((...),0),1) out of an abundance of caution.
*/
	tempvar TPR FPR
	tempvar x_for_integ y_for_integ
	qui range `x_for_integ' -4 10 1000
	qui gen `y_for_integ'=normalden(`x_for_integ')*(1-normal((`p_star'-`rho_ap'*`x_for_integ')/			 ///
		(1-`rho_ap'^2)^.5))
	qui integ `y_for_integ' `x_for_integ'
	matrix `TPR'=min(max((r(integral)/(1-normal(`p_star'))),0),1)
	qui drop `x_for_integ'
	qui range `x_for_integ' -10 -4 1000
	qui replace `y_for_integ'=normalden(`x_for_integ')*(normal((`p_star'-`rho_ap'*`x_for_integ')/			 ///
		(1-`rho_ap'^2)^.5))
	qui integ `y_for_integ' `x_for_integ'
	matrix `FPR'=min(max((r(integral)/normal(`p_star')),0),1)
    forval c = -3.9(.1)4 {
		qui drop `x_for_integ'
		qui range `x_for_integ' `c' 10 1000
		qui replace `y_for_integ'=normalden(`x_for_integ')*(1-normal((`p_star'-`rho_ap'*`x_for_integ')/			 ///
		(1-`rho_ap'^2)^.5))
		qui integ `y_for_integ' `x_for_integ'
    	matrix `TPR'=`TPR' \ min(max((r(integral)/(1-normal(`p_star'))),0),1)
		qui drop `x_for_integ'
		qui range `x_for_integ' -10 `c' 1000
		qui replace `y_for_integ'=normalden(`x_for_integ')*(normal((`p_star'-`rho_ap'*`x_for_integ')/			 ///
		(1-`rho_ap'^2)^.5))
		qui integ `y_for_integ' `x_for_integ'
	    matrix `FPR'=`FPR' \ min(max((r(integral)/normal(`p_star')),0),1)
    }
	
	svmat `TPR'
	svmat `FPR'
	qui replace `FPR' = 1 - `FPR'
	/* Calling rocreg to facilitate adding the empirical ROC curve to plot */
	qui rocreg `y' `rhs', nobootstrap
	
	qui integ `TPR' `FPR'
	local AUC=r(integral)
	
	if "`ci'" == "" {	
		if sign(`p_star_lb'*`p_star_ub'){
			if abs(`p_star_lb') < abs(`p_star_ub') {
				local p_star_for_lb_ROC = abs(`p_star_lb')
				local p_star_for_ub_ROC = abs(`p_star_ub')
			}
			else {
				local p_star_for_lb_ROC = abs(`p_star_ub')
				local p_star_for_ub_ROC = abs(`p_star_lb')
			}
		} 
		else {
			if abs(`p_star_lb') < abs(`p_star_ub') {
				local p_star_for_lb_ROC = 0
				local p_star_for_ub_ROC = abs(`p_star_ub')
			}
			else {
				local p_star_for_lb_ROC = 0
				local p_star_for_ub_ROC = abs(`p_star_lb')
			}
		}
		/* Creating lower bound for inferred ROC curve */
		tempvar TPR_lb FPR_lb
		qui drop `x_for_integ'
		qui range `x_for_integ' -4 10 1000
		qui replace `y_for_integ'=normalden(`x_for_integ')*(1-normal((`p_star_for_lb_ROC'-		 ///
			`rho_ap_lb'*`x_for_integ')/(1-`rho_ap_lb'^2)^.5))
		qui integ `y_for_integ' `x_for_integ'
		matrix `TPR_lb'=min(max((r(integral)/(1-normal(`p_star_lb'))),0),1)
		qui drop `x_for_integ'
		qui range `x_for_integ' -10 -4 1000
		qui replace `y_for_integ'=normalden(`x_for_integ')*(normal((`p_star_for_lb_ROC'-			 ///
			`rho_ap_lb'*`x_for_integ')/(1-`rho_ap_lb'^2)^.5))
		qui integ `y_for_integ' `x_for_integ'
		matrix `FPR_lb'=min(max((r(integral)/normal(`p_star_for_lb_ROC')),0),1)
		forval c = -3.9(.1)4 {
			qui drop `x_for_integ'
			qui range `x_for_integ' `c' 10 1000
			qui replace `y_for_integ'=normalden(`x_for_integ')*(1-normal((`p_star_for_lb_ROC'-		 ///
				`rho_ap_lb'*`x_for_integ')/(1-`rho_ap_lb'^2)^.5))
			qui integ `y_for_integ' `x_for_integ'
			matrix `TPR_lb'=`TPR_lb' \ min(max((r(integral)/(1-normal(`p_star_for_lb_ROC'))),0),1)
			qui drop `x_for_integ'
			qui range `x_for_integ' -10 `c' 1000
			qui replace `y_for_integ'=normalden(`x_for_integ')*(normal((`p_star_for_lb_ROC'-			 ///
				`rho_ap_lb'*`x_for_integ')/(1-`rho_ap_lb'^2)^.5))
			qui integ `y_for_integ' `x_for_integ'
			matrix `FPR_lb'=`FPR_lb' \ min(max((r(integral)/normal(`p_star_for_lb_ROC')),0),1)
		}
		svmat `TPR_lb'
		svmat `FPR_lb'
		qui replace `FPR_lb' = 1 - `FPR_lb'
		/* Creating upper bound for inferred ROC curve*/
		tempvar TPR_ub FPR_ub
		qui drop `x_for_integ'
		qui range `x_for_integ' -4 10 1000
		qui replace `y_for_integ'=normalden(`x_for_integ')*(1-normal((`p_star_for_ub_ROC'-		 ///
			`rho_ap_ub'*`x_for_integ')/(1-`rho_ap_ub'^2)^.5))
		qui integ `y_for_integ' `x_for_integ'
		matrix `TPR_ub'=min(max((r(integral)/(1-normal(`p_star_for_ub_ROC'))),0),1)
		qui drop `x_for_integ'
		qui range `x_for_integ' -10 -4 1000
		qui replace `y_for_integ'=normalden(`x_for_integ')*(normal((`p_star_for_ub_ROC'-			 ///
			`rho_ap_ub'*`x_for_integ')/(1-`rho_ap_ub'^2)^.5))
		qui integ `y_for_integ' `x_for_integ'
		matrix `FPR_ub'=min(max((r(integral)/normal(`p_star_for_ub_ROC')),0),1)
		forval c = -3.9(.1)4 {
			qui drop `x_for_integ'
			qui range `x_for_integ' `c' 10 1000
			qui replace `y_for_integ'=normalden(`x_for_integ')*(1-normal((`p_star_for_ub_ROC'-	 ///
				`rho_ap_ub'*`x_for_integ')/(1-`rho_ap_ub'^2)^.5))
			qui integ `y_for_integ' `x_for_integ'
			matrix `TPR_ub'=`TPR_ub' \ min(max((r(integral)/(1-normal(`p_star_for_ub_ROC'))),0),1)
			qui drop `x_for_integ'
			qui range `x_for_integ' -10 `c' 1000
			qui replace `y_for_integ'=normalden(`x_for_integ')*(normal((`p_star_for_ub_ROC'-		 ///
				`rho_ap_ub'*`x_for_integ')/(1-`rho_ap_ub'^2)^.5))
			qui integ `y_for_integ' `x_for_integ'
			matrix `FPR_ub'=`FPR_ub' \ min(max((r(integral)/normal(`p_star_for_ub_ROC')),0),1)
		}
	
		svmat `TPR_ub'
		svmat `FPR_ub'
		qui replace `FPR_ub' = 1 - `FPR_ub'

		/* Report estimates  */
		
		qui integ `TPR_lb' `FPR_lb'
		local AUC_lb=r(integral)
		qui integ `TPR_ub' `FPR_ub'
		local AUC_ub=r(integral)
		
		di as txt _n "{col 2}Empirical {col 15}Inferred {col 31} Inferred AUC"
		di as txt "{col 2}ROC area {col 15}ROC area {col 28} `level'% Conf. Interval"
		
		di as txt "{hline 50}
		di as res %8.04f `emp_auc' _col(14) %8.04f `AUC' _col(28) %8.04f 	 ///
			`AUC_lb' _col(40) %8.04f `AUC_ub'
		di as txt "{hline 50}
	}
	else {
		
		di as txt _n "{col 2}Empirical {col 15}Inferred"
		di as txt "{col 2}ROC area {col 15}ROC area"
		
		di as txt "{hline 23}
		di as res %8.04f `emp_auc' _col(14) %8.04f `AUC'
		di as txt "{hline 23}
	}
	
	return local cmdline = "`0'" 
	return scalar EmpAUC = `emp_auc'
	return scalar AUC = `AUC'
	if "`ci'"=="" {
		return scalar AUC_lb = `AUC_lb'
		return scalar AUC_ub = `AUC_ub'
	}
	
/* Graphs */
	if "`nograph'"=="" {
		local titles ytitle("Sensitivity") xtitle("1 - Specificity")
		local line1 (line `TPR' `FPR', `irocopts') 
		if `"`norefline'"'==""	{
			local line2 (line `FPR' `FPR', `rlopts')
			local legend 1 "Inferred ROC" 2 "Reference"
		}
		else local legend 1 "Inferred ROC"
		if `"`noempirical'"'=="" {
			local scatter (scatter _roc_ _fpr_, connect(L) sort `erocopts')
			if `"`norefline'"'=="" local legend `legend' 3 "Empirical ROC"
			else local legend `legend' 2 "Empirical ROC"
		}
		if "`cbands'"!="" {
			local cbands (line `TPR_lb' `FPR_lb', lpattern(dash) `cbopts') 	 ///
				(line `TPR_ub' `FPR_ub', lpatter(dash) `cbopts')
			if `"`norefline'"'=="" & `"`noempirical'"'=="" {
				local legend `legend' 4 "`level'% Lower bound" 5 			 ///
				"`level'% Upper bound"
			}
			else if (`"`norefline'"'=="" & `"`noempirical'"'!="") | 		 ///
				(`"`norefline'"'!="" & `"`noempirical'"'=="") {
				local legend `legend' 3 "`level'% Lower bound" 4 			 ///
				"`level'% Upper bound"
			}
			else {
				local legend `legend' 2 "`level'% Lower bound" 3 			 ///
				"`level'% Upper bound"
			}
		}
		graph twoway `line1' `line2' `scatter' `cbands' , `twowayopts' 		 ///
			legend(order(`legend')) `titles' || `addplot'
	}
/* Call restore to remove variables created for integration */
	restore
end
