*!sgpvalue-examples.do
*!Some more examples for how to use sgpvalue
*!Based on the example for the original R-code
*!Rewrote from ado-file to a do-file
// capture program drop sgpvalue_examples
// program sgpvalue_examples
	version 12.0
	set more off
	args argument
	`0'

// end

*Example t-test with simulated data
capture program drop ttest_sim
// program ttest_sim
if "`argument'"=="ttest_sim"{
	preserve
	clear
	set seed 1776
	qui set obs 15
	qui gen x1 = rnormal(0,2) 
	qui gen x2 = rnormal(3,2)
	qui ttest x1==x2
	local ci1 = (`r(mu_1)'-`r(mu_2)')- `r(se)'*invt(`=_N-2',0.975)
	local ci2 = (`r(mu_1)'-`r(mu_2)')+`r(se)'*invt(`=_N-2',0.975)
	 sgpvalue, estlo(`ci1') esthi(`ci2') nulllo(-1) nullhi(1) 
	restore

	preserve
	clear
	set seed 2019
	qui set obs 15
	qui gen x1 = rnormal(0,2) 
	qui gen x2 = rnormal(3,2)
	qui ttest x1==x2 
	local ci1 = (`r(mu_1)'-`r(mu_2)')- `r(se)'*invt(`=_N-2',0.975) // This formula is extracted from ttest-command. The CI's are not reported directly by Stata :-(
	local ci2 = (`r(mu_1)'-`r(mu_2)')+ `r(se)'*invt(`=_N-2',0.975)
	 sgpvalue, estlo(`ci1') esthi(`ci2') nulllo(-1) nullhi(1)
	restore
	exit
	}
// end


*Simulated two-group dichotomous data for different parameters
// capture program drop dichdata_sim
// program dichdata_sim
 if "`argument'"=="dichdata_sim"{
	preserve
	clear
	set seed 1492 
	local n 30
	local x1 = rbinomial(30,0.15)
	local x2 = rbinomial(30,0.5)
	* On the difference in proportions
	qui prtesti	30 `x1' 30 `x2',count
	local ci1 = (`r(P_1)'-`r(P_2)') - 1.96*sqrt((`r(P_1)'*(1-`r(P_1)')/`n')+(`r(P_2)'*(1-`r(P_2)')/`n'))
	local ci2 = (`r(P_1)'-`r(P_2)') + 1.96*sqrt((`r(P_1)'*(1-`r(P_1)')/`n')+(`r(P_2)'*(1-`r(P_2)')/`n'))
	noisily sgpvalue, estlo(`ci1') esthi(`ci2') nulllo(-0.2) nullhi(0.2)

	*On the log odds ratio scale
	local a `x1'
	local b `x2'
	local c = 30-`x1'
	local d = 30-`x2'
	local cior1 = log(`a'*`d'/(`b'*`c')) - 1.96*sqrt(1/`a'+1/`b'+1/`c'+1/`d') // Delta-method SE for log odds ratio
	local cior2 = log(`a'*`d'/(`b'*`c')) + 1.96*sqrt(1/`a'+1/`b'+1/`c'+1/`d') // Delta-method SE for log odds ratio
	noisily sgpvalue, estlo(`cior1') esthi(`cior2') nulllo(`=log(1/1.5)') nullhi(`=log(1.5)')
	restore
	exit
	}
// end
