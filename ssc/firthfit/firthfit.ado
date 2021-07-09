* ==========================================================
* firthfit: compute model fit for Firth's logit models
* Author: Alexander Staudt 
* Version 1.0.0, 2016-04-18
* ==========================================================
*! version 1.0.0, Alexander Staudt, 18apr2016

program define firthfit, rclass
	
	version 13.1
	
	if ("`e(cmd)'" != "firthlogit" & "`e(cmd)'" != "logit") {
		display as error "please use fitstat instead."
	} 
	
	else {
		
		* weights
		* check for weights in firthlogit
        * e(wexp) : "= swgt"
        * e(wtype) : "fweight"
		
		
		
		* aic/bic, pseudo R2 preparations
		tempname n k ll ilog ll_0
		tempname aic bic
		
		scalar `n' = e(N)
		scalar `k' = e(k)
		scalar `ll' = e(ll)
		matrix `ilog' = e(ilog)
		scalar `ll_0' = `ilog'[1, 1]
		
		* pseudo R2 - preparations
		tempvar xbeta yhat y
		tempvar sum_y_yhat2 sum_y_ybar2
		tempname var_xbeta var_epsilon ybar
		tempname r2_cs r2_cu_n r2_e r2_mf adj_r2_mf r2_mz r2_t
		
		* linear predictor/latent variable
		predict `xbeta' if e(sample), xb
		
		* predicted values
		gen `yhat' = invlogit(`xbeta')
		
		* outcomes
		gen `y' = `e(depvar)' if e(sample)
		
		* mean of y
		quietly sum `y'
		scalar `ybar' = r(mean)
		
		* Variance of latent variable
		quietly sum `xbeta'
		scalar `var_xbeta' = `r(Var)'

		* Variance of error of latent variable
		scalar `var_epsilon' = (_pi^2) / 3
		
		* ESS/TSS in logit context
		egen `sum_y_yhat2' = total((`y' - `yhat')^2)
		egen `sum_y_ybar2' = total((`y' - `ybar')^2)
		
		
		
		* compute aic/bic
		* aic
		scalar `aic' = 2 * `k' - 2 * `ll'
		
		* bic
		scalar `bic' = -2 * `ll' + `k' * ln(`n')
		
		
		
		* compute R^2
		* Cox-Snell
		scalar `r2_cs' = 1 - exp(2 * (`ll_0' - `ll') / `n')
		
		* Craig & Uhler/Nagelkerke
		scalar `r2_cu_n' = (1 - exp(2 * (`ll_0' - `ll') / `n')) / (1 - exp(2 * `ll_0' / `n'))
		
		* Efron
		scalar `r2_e' = 1 - (`sum_y_yhat2' / `sum_y_ybar2')
		
		* McFadden
		scalar `r2_mf' = 1 - (`ll' / `ll_0')
		
		* McFadden (adjusted)
		scalar `adj_r2_mf' = 1 - ((`ll' - `k') / `ll_0')
		
		* McKelvey & Zavoina
		scalar `r2_mz' = `var_xbeta' / (`var_xbeta' + `var_epsilon')
		
		* Tjur's D
		quietly ttest `yhat', by(`y')
		scalar `r2_t' = abs(`r(mu_1)' - `r(mu_2)')
		
		
		
		* results matrix
		tempname loglik
		tempname aicbic
		tempname r2
		
		mat `loglik' = (`ll_0' \ `ll')
		mat rownames `loglik' = "Intercept only" "Full model"
		mat roweq `loglik' = "Log-likelihood"
		
		mat `aicbic' = (`aic' \ `bic')
		mat rownames `aicbic' = "AIC" "BIC"
		mat roweq `aicbic' = "Information criteria"
		
		mat `r2' = (`r2_cs' \ `r2_cu_n' \ `r2_e' \ `r2_mf' \ `adj_r2_mf' \ `r2_mz' \ `r2_t')
		mat rownames `r2' = "Cox-Snell/ML" "Cragg-Uhler/Nagelkerke" "Efron" "McFadden" "McFadden (adj)" "McKelvey & Zavoina" "Tjur's D"
		mat roweq `r2' = "R^2"
		
		mat res_mat = (`loglik' \ `aicbic' \ `r2')
		mat colnames res_mat = "`e(cmd)'"
		
		
		
		* return results
		matlist res_mat, twidth(24) format(%11.3f) border(bottom)
		
		
		
		* return scalars to r()
		return clear
		return scalar N = `n'
		return scalar k = `k' 
		return scalar ll_0 = `ll_0' 
		return scalar ll = `ll'
		return scalar aic = `aic'
		return scalar bic = `bic'
		return scalar r2_cs = `r2_cs'
		return scalar r2_cu_n = `r2_cu_n'
		return scalar r2_e = `r2_e'
		return scalar r2_mf = `r2_mf'
		return scalar adj_r2_mf = `adj_r2_mf'
		return scalar r2_mz = `r2_mz'
		return scalar r2_t = `r2_t'
		
	}
end
