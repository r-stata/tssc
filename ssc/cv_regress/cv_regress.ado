capture program drop cv_regress
program define cv_regress, rclass
syntax ,[cvwgt(varname) generr(str) genlev(str) genhat(str)]
* Step 1. Verify the right command was excecuted in the previous step
	version 7.
	if e(cmd)!="regress" {
		display in red ("Last estimates not found or not a regress command")
		display in red ("This version  of the program only allows for regress command")
		exit 
	}
	if "`e(wtype)'"!="" {
		if e(wtype)=="pweight" {
			display in red ("Program not compatible with Robust estimation")
			display in red ("Use aweights, iweights or fweights")
			exit	
		}
	}	
	** determine subsample
	tempvar esample
	qui:gen `esample'=e(sample)
	** determine dependent variable and weight
	local yy: word 2 of `e(cmdline)'
	local aux=e(cmdline)
	local wgtwgt:word 2 of `e(wexp)'
	 
	** estimate model predicted value
	tempvar yy_hat lvrg
	qui:predict double `yy_hat',
	qui:predict double `lvrg', hat
	** Estimate leverage adjustment
	tempvar lv_adj
	qui:gen double `lv_adj'=1
	if "`e(wtype)'"=="aweight" {
		qui:sum `wgtwgt' if `esample'==1, meanonly
		qui:replace `lvrg'=`lvrg'*`wgtwgt'/r(mean)
	}
	if "`e(wtype)'"=="fweight" | "`e(wtype)'"=="iweight" {
		qui:replace `lvrg'=`lvrg'*`wgtwgt'
	}
	** Estimate out of sample prediction
	tempvar yloo_hat
	qui:gen double `yloo_hat'=`yy'-(`yy'-`yy_hat')/(1-`lvrg')
	** Estimate estatistcs of interest
	tempvar _mse _mae 
	gen double `_mse'=(`yy'-`yloo_hat')^2
	gen double `_mae'=abs(`yy'-`yloo_hat')
	
	if "`cvwgt'"=="" {
		sum `_mse' if `esample'==1, meanonly
		local mse=r(mean)
		sum `_mae' if `esample'==1, meanonly 
		local mae=r(mean)
		capture:qui:corr `yy' `yloo_hat' if `esample'==1
		capture:matrix c=r(C)
		capture:local pr2=c[1,2]^2
		local rmse=(`mse')^0.5
		local lmse=ln(`mse')
	}
	
	else {
		sum `_mse' [aw=`cvwgt'] if `esample'==1, meanonly
		local mse=r(mean)
		sum `_mae' [aw=`cvwgt'] if `esample'==1, meanonly
		local mae=r(mean)
		capture: qui:corr `yy' `yloo_hat' if `esample'==1 [aw=`cvwgt']
		capture:matrix c=r(C)
		capture:local pr2=c[1,2]^2
		local rmse=(`mse')^0.5
		local lmse=ln(`mse')
	}
	
	display _newline
	display as text "Leave-One-Out Cross-Validation Results "
	if "`cvwgt'"!="" {
	display as text "Statistics are estimated using -`cvwgt'- as weights"
	}
	di as text "{hline 25}{c TT}{hline 15}"		
	di as text "         Method          {c |}" _col(30) " Value"
	di as text "{hline 25}{c +}{hline 15}"	
	display as text "Root Mean Squared Errors {c |}" _col(30) as result  %10.4f `rmse'
	display as text "Log Mean Squared Errors  {c |}" _col(30) as result  %10.4f `lmse'
	display as text "Mean Absolute Errors     {c |}" _col(30) as result  %10.4f `mae'
	display as text "Pseudo-R2                {c |}" _col(30) as result  %10.5f `pr2'
	di as text "{hline 25}{c BT}{hline 15}"		

	if "`generr'"!="" {
	qui:gen double `generr'=(`yy'-`yloo_hat') if `esample'==1
	display as text "A new Variable -`generr'- was created with (y-E(y_-i|X))"
	}
	if "`genhat'"!="" {
	qui:gen double `genhat'=`yloo_hat' if `esample'==1
	display as text "A new Variable -`genhat'- was created with E(y_-i|X)"
	}
	if "`genlev'"!="" {
	qui:gen double `genlev'=`lvrg' if `esample'==1
	display as text "A new Variable -`genhat'- was created with Leverage h(x)"
	}
	return scalar pr2=`pr2'
	return scalar lmse=`lmse'
	return scalar rmse=`rmse'
	return scalar mae=`mae'
end
