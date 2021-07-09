capture program drop twowayfeweights
program twowayfeweights, eclass
	version 12.0
	syntax varlist(min=4 numeric) [if] [in]  [, type(string) test_random_weights(varlist numeric) controls(varlist numeric) breps(integer 0) brepscluster(varlist) path(string)]
	if "`type'"==""{
	di as error"Please select the weights you want to estimate using type()"
	}
	if "`type'"=="feTR"{
	qui{
	
	tempvar outcome group time meantreat
	tokenize `varlist'
	gen `outcome'=`1'
	gen `group'=`2'
	gen `time'=`3'
	gen `meantreat'=`4'
	preserve
	*Keeping if sample
	if `"`if'"' != "" {
	keep `if'
	}
	* Keeping only sample used in estimation of regression
	foreach var of varlist `varlist' {
	drop if `var'==.
	}
	if "`controls'"!=""{
	foreach var of varlist `controls' {
	drop if `var'==.
	}
	}
	*Replacing individual level controls by (g,t)-level controls
	if "`controls'"!=""{
	local count=1
	foreach var of varlist `controls' {
	bys `group' `time': egen `var'_gt=mean(`var')
	bys `group' `time': egen `var'_sd_gt=sd(`var')
	sum `var'_sd_gt
	if r(mean)>0&r(mean)!=.{
	noisily di as text "The control variable " `count' " varies within some group * period cells."
	noisily di as text "The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2018) on two-way fixed effects regressions" _newline "with controls apply to group * period level controls."
	noisily di as text "The command will replace control variable " `count' " by its average value in each group * period cell."
	noisily di as text "The results below apply to the regression with control variable " `count' " averaged at the group * period level."
	noisily di as text ""
	replace `var'=`var'_gt
	local count=`count'+1
	}
	drop `var'_gt `var'_sd_gt
	}
	}
	*Computing the natural weights
	sum `meantreat'
	scalar mean_D=r(mean)
	sum `outcome'
	scalar obs=r(N)
	bys `group' `time': egen P_gt=count(`1')
	replace P_gt=P_gt/obs 
	gen nat_weight= P_gt*`meantreat'/mean_D
	* Computing W and weight
	*areg `meantreat' i.`time', absorb(`group')
	areg `meantreat' i.`time' `controls', absorb(`group')
	predict eps_1, residuals 
	gen eps_1_E_D_gt=eps_1*`meantreat'
	sum eps_1_E_D_gt
	scalar denom_W=r(mean)
	gen W=eps_1*mean_D/denom_W
	gen weight=W*nat_weight
	*Computing beta
	if "`controls'"!=""{
	areg `outcome' i.`time' `meantreat' `controls' , absorb(`group')
	scalar beta=_b[`meantreat']
	}
	if "`controls'"==""{
	areg `outcome' i.`time' `meantreat', absorb(`group')
	scalar beta=_b[`meantreat']
	}
	* Keeping only one observation in each group * period cell
	bys `group' `time': gen group_period_unit=(_n==1)	
	drop if group_period_unit==0
	drop group_period_unit
	* Computing the sum and the number of positive/negative weights
	egen total_weight_plus=total(weight) if weight>0
	egen total_weight_minus=total(weight) if weight<0
	sum total_weight_plus
	scalar nplus=r(N)
	scalar sumplus=r(mean)
    sum total_weight_minus
	scalar nminus=r(N)
	scalar summinus=r(mean)
	*Computing the sensitivity measure
	sum W [aweight=nat_weight]
	scalar sensibility=abs(beta)/r(sd)
	*Computing the number of weights
	sum `outcome' if weight!=0
	scalar nweights=r(N)
	* Regressing the variables in test_random_weights on the weights
	matrix A =0,0,0,0
	matrix C =0,0,0,0
	if "`test_random_weights'"!=""{
	foreach var of varlist `test_random_weights' {
	reg `var' W [pweight=nat_weight], cluster(`group') 
	matrix A =A\_b[W],_se[W],_b[W]/_se[W], ((_b[W]>=0)-(_b[W]<0))*sqrt(e(r2)) 
	}
	matrix B = A[2..., 1...]
	matrix colnames B = Coef SE t-stat Correlation
	matrix rownames B= `test_random_weights'
	}
	if "`path'"!=""{
	gen G= `group'
	gen T=`time'
	keep G T weight W nat_weight
	save "`path'", replace
	}
	*Computing the new sensitivity measure
	if summinus<0{
	keep if weight!=0
	gsort -W
	sum W
	gen P_k=.
	gen S_k=.
	gen T_k=.
	replace P_k=nat_weight if _n==`r(N)'
	replace S_k=weight if _n==`r(N)'
	replace T_k=nat_weight*W^2 if _n==`r(N)'
	forvalue i=1/`=`r(N)'-1'{
	replace P_k=nat_weight+P_k[_n+1] if _n==`r(N)'-`i'
	replace S_k=weight+S_k[_n+1] if _n==`r(N)'-`i'
	replace T_k=nat_weight*W^2+T_k[_n+1] if _n==`r(N)'-`i'
	}
	gen sens_measure2=abs(beta)/sqrt(T_k+S_k^2/(1-P_k))
	gen ind=(W<-S_k/(1-P_k))
	replace ind=0 if _n==1 
	// Filling holes
	replace ind=max(ind,ind[_n-1])
	// Count
	egen tot_ind=total(ind)
	sum tot_ind
	sum sens_measure2 if _n==r(N)-r(mean)+1
	scalar sensibility2=r(mean)
	}
	if summinus==0{
	scalar sensibility2=9*10^15
	}
	}
	di as text "Under the common trends assumption, beta estimates a weighted sum of " nweights " ATTs. " _newline nplus " ATTs receive a positive weight, and " nminus " receive a negative weight." _newline "The sum of the negative weights is equal to " summinus "."
	di as text "beta is compatible with a DGP where the average of those ATTs is equal to 0," _newline "while their standard deviation is equal to " sensibility "."
	if summinus<0{
	di as text "beta is compatible with a DGP where those ATTs all are of a different sign than beta," _newline "while their standard deviation is equal to " sensibility2 "."
	}
	if summinus==0{
	di as text "All the weights are positive, so beta cannot be of a different sign than all those ATTs."
	}
	ereturn clear 
	ereturn scalar sum_neg_w = summinus
	ereturn scalar lb_se_te = sensibility
	if summinus<0{
	ereturn scalar lb_se_te2 = sensibility2
	}
	ereturn scalar beta = beta
	if "`test_random_weights'"!=""{
	di  as result  _newline "Regression of variables possibly correlated with the treatment effect on the weights"
	matrix list B
	ereturn matrix randomweightstest1 = B
	}
	restore
	if "`breps'"!="0"{
	set seed 1
	matrix R=0,0
	local i 1
	while `i'<=`breps'{
	qui{
	preserve
	if "`brepscluster'"==""{
	bsample
	}
	if "`brepscluster'"!=""{
	bsample, cluster(`brepscluster')
	}
	twowayfeweights `outcome' `group' `time' `meantreat' , type(feTR) controls(`controls')
	matrix R=R\sensibility,sensibility2
	restore
	local i `i'+1
	}
	}
	preserve
	qui{
	drop _all
	svmat R
	drop if _n==1
	sort R1
	scalar down = round(0.025*`breps')
	scalar up = round(0.975*`breps')
	sum R1 if _n== down
	scalar lowerbound = r(mean)
	sum R1 if _n== up
	scalar upperbound = r(mean)
	sort R2
	sum R2 if _n== down
	scalar lowerbound2 = r(mean)
	sum R2 if _n== up
	scalar upperbound2 = r(mean)
	}
	di as result "Inference Measures"
	di as text "The 95% confidence interval of the standard deviation of the ATTs compatible with beta and an ATT of 0 is [" lowerbound "," upperbound "]."
	if summinus<0{
	di as text "The 95% confidence interval of the standard deviation of the ATTs compatible with beta of a different sign than all the ATTs is [" lowerbound2 "," upperbound2 "]."
	}
	restore
	qui{
	if "`test_random_weights'"!=""{
	twowayfeweights `outcome' `group' `time' `meantreat' , type(feTR) controls(`controls') test_random_weights(`test_random_weights')
	}
	if "`test_random_weights'"==""{
	twowayfeweights `outcome' `group' `time' `meantreat' , type(feTR) controls(`controls')
	}
	ereturn scalar lb_ci_lb_se_te = lowerbound
	ereturn scalar ub_ci_lb_se_te = upperbound
	if summinus<0{
	ereturn scalar lb_ci_lb_se_te2 = lowerbound2
	ereturn scalar ub_ci_lb_se_te2 = upperbound2
	}
	}
	}
	}
	if "`type'"=="feS"{
		qui{
	tempvar outcome group time meantreat
	tokenize `varlist'
	gen `outcome'=`1'
	gen `group'=`2'
	gen `time'=`3'
	gen `meantreat'=`4'
	preserve
	*Keeping if sample
	if `"`if'"' != "" {
	keep `if'
	}
	* Keeping only sample used in estimation of regression
	foreach var of varlist `varlist' {
	drop if `var'==.
	}
	if "`controls'"!=""{
	foreach var of varlist `controls' {
	drop if `var'==.
	}
	}
	*Replacing individual level controls by (g,t)-level controls
	if "`controls'"!=""{
	local count=1
	foreach var of varlist `controls' {
	bys `group' `time': egen `var'_gt=mean(`var')
	bys `group' `time': egen `var'_sd_gt=sd(`var')
	sum `var'_sd_gt
	if r(mean)>0&r(mean)!=.{
	noisily di as text "The control variable " `count' " varies within some group * period cells."
	noisily di as text "The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2018) on two-way fixed effects regressions" _newline "with controls apply to group * period level controls."
	noisily di as text "The command will replace control variable " `count' " by its average value in each group * period cell."
	noisily di as text "The results below apply to the regression with control variable " `count' " averaged at the group * period level."
	noisily di as text ""
	replace `var'=`var'_gt
	local count=`count'+1
	}
	drop `var'_gt `var'_sd_gt
	}
	}
	*Variables needed to compute the weights, and that need to be computed before keeping only one observation in each group * period cell
	sum `outcome'
	scalar obs=r(N)
	bys `group' `time': egen P_gt=count(`outcome')
	replace P_gt=P_gt/obs
	*areg `meantreat' i.`time', absorb(`group')
	areg `meantreat' i.`time' `controls', absorb(`group')
	predict eps_1, residuals
	gen E_eps_1_g_geqt=.
	egen newt=group(`time')
	replace newt=newt-1 
	sum newt
	local tmax=r(max)
	forvalue t=0/`tmax'{
	bys `group': egen E_eps_1_g_geqt_aux=mean(eps_1) if newt>=`t' 
	replace E_eps_1_g_geqt=E_eps_1_g_geqt_aux if newt==`t'
	drop E_eps_1_g_geqt_aux
	}
	*Computing beta
	if "`controls'"!=""{
	areg `outcome' i.`time' `meantreat' `controls' , absorb(`group')
	scalar beta=_b[`meantreat']
	}
	if "`controls'"==""{
	areg `outcome' i.`time' `meantreat', absorb(`group')
	scalar beta=_b[`meantreat']
	}
	* Keeping only one observation in each group * period cell	
	bys `group' `time': gen group_period_unit=(_n==1)
	drop if group_period_unit==0
	drop group_period_unit
	*Computing the natural weights
	sort `group' `time'
	gen Delta_D=`meantreat'-`meantreat'[_n-1] if `group'==`group'[_n-1]&newt-1==newt[_n-1]
	*NB: the condition newt-1==newt[_n-1] ensures that the computation is right when panel has holes (a group there from period 1 to t0, then disappears, and reappears at t0+k).
	drop if Delta_D==. 
	gen s_gt=(Delta_D>0)-(Delta_D<0)
	gen abs_Delta_D=abs(Delta_D)
	drop Delta_D 
	gen nat_weight= P_gt*abs_Delta_D
	egen P_S=total(nat_weight)
	replace nat_weight=nat_weight/P_S
	*Computing Om
	gen om_tilde_1=s_gt*E_eps_1_g_geqt/P_gt
	sum om_tilde_1 [aweight=nat_weight]
	scalar denom_Om=r(mean)
	gen Om=om_tilde_1/denom_Om
	gen weight=Om*nat_weight
	* Computing the sum and the number of positive/negative weights
	egen total_weight_plus=total(weight) if weight>0
	egen total_weight_minus=total(weight) if weight<0
	sum total_weight_plus
	scalar nplus=r(N)
	scalar sumplus=r(mean)
    sum total_weight_minus
	scalar nminus=r(N)
	scalar summinus=r(mean)
	*Computing the sensitivity measure
	sum Om [aweight=nat_weight]
	scalar sensibility=abs(beta)/r(sd)
	*Computing the number of weights
	sum `1' if weight!=0
	scalar nweights=r(N)
	* Regressing the variables in test_random_weights on the weights
	matrix A =0,0,0,0
	matrix C =0,0,0,0
	if "`test_random_weights'"!=""{
	foreach var of varlist `test_random_weights' {
	reg `var' Om [pweight=nat_weight], cluster(`group') 
	matrix A =A\_b[Om],_se[Om],_b[Om]/_se[Om],((_b[Om]>=0)-(_b[Om]<0))*sqrt(e(r2))  
	}
	matrix B = A[2..., 1...]
	matrix colnames B = Coef SE t-stat Correlation
	matrix rownames B= `test_random_weights'
	}
	if "`path'"!=""{
	gen G= `group'
	gen T=`time'
	keep G T weight Om nat_weight
	save "`path'", replace
	}
	*Computing the new sensitivity measure
	if summinus<0{
	keep if weight!=0
	gsort -Om
	sum Om
	gen P_k=.
	gen S_k=.
	gen T_k=.
	replace P_k=nat_weight if _n==`r(N)'
	replace S_k=weight if _n==`r(N)'
	replace T_k=nat_weight*Om^2 if _n==`r(N)'
	forvalue i=1/`=`r(N)'-1'{
	replace P_k=nat_weight+P_k[_n+1] if _n==`r(N)'-`i'
	replace S_k=weight+S_k[_n+1] if _n==`r(N)'-`i'
	replace T_k=nat_weight*Om^2+T_k[_n+1] if _n==`r(N)'-`i'
	}
	gen sens_measure2=abs(beta)/sqrt(T_k+S_k^2/(1-P_k))
	gen ind=(Om<-S_k/(1-P_k))
	replace ind=0 if _n==1
	// Filling holes
	replace ind=max(ind,ind[_n-1])
	// Count
	egen tot_ind=total(ind)
	sum tot_ind
	sum sens_measure2 if _n==r(N)-r(mean)+1
	scalar sensibility2=r(mean)
	}
	if summinus==0{
	scalar sensibility2=9*10^15
	}
	}
	di as text "Under the common trends, treatment monotonicity, and stable treatment effect assumptions,"_newline "beta estimates a weighted sum of " nweights " LATEs. " _newline nplus " LATEs receive a positive weight, and " nminus " receive a negative weight."_newline "The sum of the negative weights is equal to " summinus "."
	di as text "beta is compatible with a DGP where the average of those LATEs is equal to 0," _newline "while their standard deviation is equal to " sensibility "."
	if summinus<0{
	di as text "beta is compatible with a DGP where those LATEs all are of a different sign than beta," _newline "while their standard deviation is equal to " sensibility2 "."
	}
	if summinus==0{
	di as text "All the weights are positive, so beta cannot be of a different sign than all those LATEs."
	}
	ereturn clear 
	ereturn scalar sum_neg_w = summinus
	ereturn scalar lb_se_te = sensibility
	if summinus<0{
	ereturn scalar lb_se_te2 = sensibility2
	}
	ereturn scalar beta = beta
	if "`test_random_weights'"!=""{
	di  as result _newline "Regression of variables possibly correlated with the treatment effect on the weights"
	matrix list B
	ereturn matrix randomweightstest1 = B
	}
	restore
	if "`breps'"!="0"{
	set seed 1
	matrix R=0,0
	local i 1
	while `i'<=`breps'{
	qui{
	preserve
	if "`brepscluster'"==""{
	bsample
	}
	if "`brepscluster'"!=""{
	bsample, cluster(`brepscluster')
	}
	twowayfeweights `outcome' `group' `time' `meantreat' , type(feS) controls(`controls')
	matrix R=R\sensibility,sensibility2
	restore
	local i `i'+1
	}
	}
	preserve
	qui{
	drop _all
	svmat R
	drop if _n==1
	sort R1
	scalar down = round(0.025*`breps')
	scalar up = round(0.975*`breps')
	sum R1 if _n== down
	scalar lowerbound = r(mean)
	sum R1 if _n== up
	scalar upperbound = r(mean)
	sort R2
	sum R2 if _n== down
	scalar lowerbound2 = r(mean)
	sum R2 if _n== up
	scalar upperbound2 = r(mean)
	}
	di as result "Inference Measures"
	di as text "The 95% confidence interval for the standard deviation of the LATEs compatible with beta and a LATE of 0 is [" lowerbound "," upperbound "]."
	if summinus<0{
	di as text "The 95% confidence interval of the standard deviation of the LATEs compatible with beta of a different sign than all the LATEs is [" lowerbound2 "," upperbound2 "]."
	}
	restore
	qui{
	if "`test_random_weights'"!=""{
	twowayfeweights `outcome' `group' `time' `meantreat' , type(feS) controls(`controls') test_random_weights(`test_random_weights')
	}
	if "`test_random_weights'"==""{
	twowayfeweights `outcome' `group' `time' `meantreat' , type(feS) controls(`controls')
	}
	ereturn scalar lb_ci_lb_se_te = lowerbound
	ereturn scalar ub_ci_lb_se_te = upperbound
	if summinus<0{
	ereturn scalar lb_ci_lb_se_te2 = lowerbound2
	ereturn scalar ub_ci_lb_se_te2 = upperbound2
	}
	}
	}
	}
	if "`type'"=="fdS"{
	qui{
	tempvar outcome group time meantreatgroup 
	tokenize `varlist'
	gen `outcome'=`1'
	gen `group'=`2'
	gen `time'=`3'
	gen `meantreatgroup'=`4'
	preserve
	*Keeping if sample
	if `"`if'"' != "" {
	keep `if'
	}
	* Keeping only sample used in estimation of regression & observations with non missing D
	foreach var of varlist `varlist' {
	drop if `var'==.
	}
	if "`controls'"!=""{
	foreach var of varlist `controls' {
	drop if `var'==.
	}
	}
	*Replacing individual level controls by (g,t)-level controls
	if "`controls'"!=""{
	local count=1
	foreach var of varlist `controls' {
	bys `group' `time': egen `var'_gt=mean(`var')
	bys `group' `time': egen `var'_sd_gt=sd(`var')
	sum `var'_sd_gt
	if r(mean)>0&r(mean)!=.{
	noisily di as text "The control variable " `count' " varies within some group * period cells."
	noisily di as text "The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2018) on two-way fixed effects regressions" _newline "with controls apply to group * period level controls."
	noisily di as text "The command will replace control variable " `count' " by its average value in each group * period cell."
	noisily di as text "The results below apply to the regression with control variable " `count' " averaged at the group * period level."
	noisily di as text ""
	replace `var'=`var'_gt
	local count=`count'+1
	}
	drop `var'_gt `var'_sd_gt
	}
	}
	*Variables needed to compute the weights, and that need to be computed before keeping only one observation in each group * period cell
	sum `outcome'
	scalar obs=r(N)
	bys `group' `time': egen P_gt=count(`outcome')
	replace P_gt=P_gt/obs
	*reg `meantreatgroup' i.`time'
	reg `meantreatgroup' i.`time' `controls'
	predict eps_2, residuals
	*Computing beta
	if "`controls'"!=""{
	areg `outcome' `meantreatgroup' `controls', absorb(`time')
	scalar beta=_b[`meantreatgroup']
	}
    if "`controls'"==""{
	areg `outcome' `meantreatgroup', absorb(`time')
	scalar beta=_b[`meantreatgroup']
	}
	* Keeping only one observation in each group * period cell	
	bys `group' `time': gen group_period_unit=(_n==1)
	drop if group_period_unit==0
	drop group_period_unit
	*Computing the natural weights
	gen s_gt=(`meantreatgroup'>0)-(`meantreatgroup'<0)
	gen abs_Delta_D=abs(`meantreatgroup')
	gen nat_weight= P_gt*abs_Delta_D
	egen P_S=total(nat_weight)
	replace nat_weight=nat_weight/P_S
	*Computing Om
	gen Om=s_gt*eps_2
	sum Om [aweight=nat_weight]
	scalar denom_Om=r(mean)
	replace Om=Om/denom_Om
	gen weight=Om*nat_weight
	* Computing the sum and the number of positive/negative weights
	egen total_weight_plus=total(weight) if weight>0
	egen total_weight_minus=total(weight) if weight<0
	sum total_weight_plus
	scalar nplus=r(N)
	scalar sumplus=r(mean)
    sum total_weight_minus
	scalar nminus=r(N)
	scalar summinus=r(mean)
	*Computing the sensitivity measure
	sum Om [aweight=nat_weight]
	scalar sensibility=abs(beta)/r(sd)
	*Computing the number of weights
	sum `1' if weight!=0
	scalar nweights=r(N)
	* Regressing the variables in 5 on the weights
	matrix A =0,0,0,0
	matrix C =0,0,0,0
	if "`test_random_weights'"!=""{
	foreach var of varlist `test_random_weights' {
	reg `var' Om [pweight=nat_weight], cluster(`group') 
	matrix A =A\_b[Om],_se[Om],_b[Om]/_se[Om],((_b[Om]>=0)-(_b[Om]<0))*sqrt(e(r2))  
	}
	matrix B = A[2..., 1...]
	matrix colnames B = Coef SE t-stat Correlation
	matrix rownames B= `test_random_weights'
	}
	if "`path'"!=""{
	gen G= `group'
	gen T=`time'
	keep G T weight Om nat_weight
	save "`path'", replace
	}
	*Computing the new sensitivity measure
	if summinus<0{
	keep if weight!=0
	gsort -Om
	sum Om
	gen P_k=.
	gen S_k=.
	gen T_k=.
	replace P_k=nat_weight if _n==`r(N)'
	replace S_k=weight if _n==`r(N)'
	replace T_k=nat_weight*Om^2 if _n==`r(N)'
	forvalue i=1/`=`r(N)'-1'{
	replace P_k=nat_weight+P_k[_n+1] if _n==`r(N)'-`i'
	replace S_k=weight+S_k[_n+1] if _n==`r(N)'-`i'
	replace T_k=nat_weight*Om^2+T_k[_n+1] if _n==`r(N)'-`i'
	}
	gen sens_measure2=abs(beta)/sqrt(T_k+S_k^2/(1-P_k))
	gen ind=(Om<-S_k/(1-P_k))
	replace ind=0 if _n==1
	// Filling holes
	replace ind=max(ind,ind[_n-1])
	// Count
	egen tot_ind=total(ind)
	sum tot_ind
	sum sens_measure2 if _n==r(N)-r(mean)+1
	scalar sensibility2=r(mean)
	}
	if summinus==0{
	scalar sensibility2=9*10^15
	}
	}
	di as text "Under the common trends, treatment monotonicity, and stable treatment effect assumptions,"_newline "beta estimates a weighted sum of " nweights " LATEs. " _newline nplus " LATEs receive a positive weight, and " nminus " receive a negative weight."_newline "The sum of the negative weights is equal to " summinus "."
	di as text "beta is compatible with a DGP where the average of those LATEs is equal to 0," _newline "while their standard deviation is equal to " sensibility "."
	if summinus<0{
	di as text "beta is compatible with a DGP where those LATEs all are of a different sign than beta," _newline "while their standard deviation is equal to " sensibility2 "."
	}
	if summinus==0{
	di as text "All the weights are positive, so beta cannot be of a different sign than all those LATEs."
	}
	ereturn clear 
	ereturn scalar sum_neg_w = summinus
	ereturn scalar lb_se_te = sensibility
	if summinus<0{
	ereturn scalar lb_se_te2 = sensibility2
	}
	ereturn scalar beta = beta
	if "`test_random_weights'"!=""{
	di  as result _newline "Regression of variables possibly correlated with the treatment effect on the weights"
	matrix list B
	ereturn matrix randomweightstest1 = B
	}
	restore
	if "`breps'"!="0"{
	set seed 1
	matrix R=0,0
	local i 1
	while `i'<=`breps'{
	qui{
	preserve
	if "`brepscluster'"==""{
	bsample
	}
	if "`brepscluster'"!=""{
	bsample, cluster(`brepscluster')
	}
	twowayfeweights `outcome' `group' `time' `meantreatgroup' , type(fdS) controls(`controls')
	matrix R=R\sensibility,sensibility2
	restore
	local i `i'+1
	}
	}
	preserve
	qui{
	drop _all
	svmat R
	drop if _n==1
	sort R1
	scalar down = round(0.025*`breps')
	scalar up = round(0.975*`breps')
	sum R1 if _n== down
	scalar lowerbound = r(mean)
	sum R1 if _n== up
	scalar upperbound = r(mean)
	sort R2
	sum R2 if _n== down
	scalar lowerbound2 = r(mean)
	sum R2 if _n== up
	scalar upperbound2 = r(mean)
	}
	di as result "Inference Measures"
	di as text "The 95% confidence interval for the standard deviation of the LATEs compatible with beta and a LATE of 0 is [" lowerbound "," upperbound "]."
	if summinus<0{
	di as text "The 95% confidence interval of the standard deviation of the LATEs compatible with beta of a different sign than all the LATEs is [" lowerbound2 "," upperbound2 "]."
	}
	restore
	qui{
	if "`test_random_weights'"!=""{
	twowayfeweights `outcome' `group' `time' `meantreatgroup' , type(fdS) controls(`controls') test_random_weights(`test_random_weights')
	}
	if "`test_random_weights'"==""{
	twowayfeweights `outcome' `group' `time' `meantreatgroup' , type(fdS) controls(`controls')
	}
	ereturn scalar lb_ci_lb_se_te = lowerbound
	ereturn scalar ub_ci_lb_se_te = upperbound
	if summinus<0{
	ereturn scalar lb_ci_lb_se_te2 = lowerbound2
	ereturn scalar ub_ci_lb_se_te2 = upperbound2
	}
	}
	}
	}
	if "`type'"=="fdTR"{
	qui{
	tempvar outcome group time meantreatgroup treatment
	tokenize `varlist'
	gen `outcome'=`1'
	gen `group'=`2'
	gen `time'=`3'
	gen `meantreatgroup'=`4'
	gen `treatment'=`5'
	preserve
	*Keeping if sample
	if `"`if'"' != "" {
	keep `if'
	}
	* Keeping only sample used in estimation of regression & observations with non missing D
	keep if (`time'!=.&`outcome'!=.&`meantreatgroup'!=.)|`treatment'!=.
	if "`controls'"!=""{
	foreach var of varlist `controls' {
	drop if (`time'!=.&`outcome'!=.&`meantreatgroup'!=.)&`var'==.
	}
	}
	*Replacing individual level controls by (g,t)-level controls
	if "`controls'"!=""{
	local count=1
	foreach var of varlist `controls' {
	bys `group' `time': egen `var'_gt=mean(`var')
	bys `group' `time': egen `var'_sd_gt=sd(`var')
	sum `var'_sd_gt
	if r(mean)>0&r(mean)!=.{
	noisily di as text "The control variable " `count' " varies within some group * period cells."
	noisily di as text "The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2018) on two-way fixed effects regressions" _newline "with controls apply to group * period level controls."
	noisily di as text "The command will replace control variable " `count' " by its average value in each group * period cell."
	noisily di as text "The results below apply to the regression with control variable " `count' " averaged at the group * period level."
	noisily di as text ""
	replace `var'=`var'_gt
	local count=`count'+1
	}
	drop `var'_gt `var'_sd_gt
	}
	}
	*Computing the natural weights
	sum `treatment'
	scalar mean_D=r(mean)
	gen counter=1
	sum counter
	scalar obs=r(N)	
	bys `group' `time': egen P_gt=count(counter)
	replace P_gt=P_gt/obs 
	gen nat_weight= P_gt*`treatment'/mean_D
	* Computing the regression residuals
	*reg `meantreatgroup' i.`time'
	reg `meantreatgroup' i.`time' `controls'
	predict eps_2, residuals
	// line below sets eps_2=0 for the first period when a group is observed, according to formula in paper
	replace eps_2=0 if eps_2==.
	*Computing beta
	if "`controls'"!=""{
	areg `outcome' `meantreatgroup' `controls', absorb(`time')
	scalar beta=_b[`meantreatgroup']
	}
	if "`controls'"==""{
	areg `outcome' `meantreatgroup', absorb(`time')
	scalar beta=_b[`meantreatgroup']
	}
	* Keeping only one observation in each group * period cell
	bys `group' `time': gen group_period_unit=(_n==1)	
	drop if group_period_unit==0
	drop group_period_unit
	*Computing the weights W
	egen newt=group(`time')
	sort `group' newt
	gen w_tilde_2=eps_2-eps_2[_n+1]*P_gt[_n+1]/P_gt if `group'==`group'[_n+1]&newt+1==newt[_n+1]
	//the condition newt+1==newt[_n+1] above ensures that the computation is right when panel has holes (a group there from period 1 to t0, then disappears, and reappears at t0+k).
	// line below sets w_tilde_2=eps_2 for the last period when a group is observed, according to formula in paper
	replace w_tilde_2=eps_2 if w_tilde_2==.
	gen w_tilde_2_E_D_gt=w_tilde_2*`treatment'
	sum w_tilde_2_E_D_gt [aweight=P_gt]
	scalar denom_W=r(mean)
	gen W=w_tilde_2*mean_D/denom_W
	gen weight=W*nat_weight
	* Computing the sum and the number of positive/negative weights
	egen total_weight_plus=total(weight) if weight>0
	egen total_weight_minus=total(weight) if weight<0
	sum total_weight_plus
	scalar nplus=r(N)
	scalar sumplus=r(mean)
    sum total_weight_minus
	scalar nminus=r(N)
	scalar summinus=r(mean)
	*Computing the sensitivity measure
	sum W [aweight=nat_weight]
	scalar sensibility=abs(beta)/r(sd)
	*Computing the number of weights
	sum counter if weight!=0
	scalar nweights=r(N)
	drop counter
	* Regressing the variables in 5 on the weights
	matrix A =0,0,0,0
	matrix C =0,0,0,0
	if "`test_random_weights'"!=""{
	foreach var of varlist `test_random_weights' {
	reg `var' W [pweight=nat_weight], cluster(`group') 
	matrix A =A\_b[W],_se[W],_b[W]/_se[W], ((_b[W]>=0)-(_b[W]<0))*sqrt(e(r2)) 
	}
	matrix B = A[2..., 1...]
	matrix colnames B = Coef SE t-stat Correlation
	matrix rownames B= `test_random_weights'
	}
	if "`path'"!=""{
	gen G= `group'
	gen T=`time'
	keep G T weight W nat_weight
	save "`path'", replace
	}
	*Computing the new sensitivity measure
	if summinus<0{
	keep if weight!=0
	gsort -W
	sum W
	gen P_k=.
	gen S_k=.
	gen T_k=.
	replace P_k=nat_weight if _n==`r(N)'
	replace S_k=weight if _n==`r(N)'
	replace T_k=nat_weight*W^2 if _n==`r(N)'
	forvalue i=1/`=`r(N)'-1'{
	replace P_k=nat_weight+P_k[_n+1] if _n==`r(N)'-`i'
	replace S_k=weight+S_k[_n+1] if _n==`r(N)'-`i'
	replace T_k=nat_weight*W^2+T_k[_n+1] if _n==`r(N)'-`i'
	}
	gen sens_measure2=abs(beta)/sqrt(T_k+S_k^2/(1-P_k))
	gen ind=(W<-S_k/(1-P_k))
	replace ind=0 if _n==1
	// Filling holes
	replace ind=max(ind,ind[_n-1])
	// Count
	egen tot_ind=total(ind)
	sum tot_ind
	sum sens_measure2 if _n==r(N)-r(mean)+1
	scalar sensibility2=r(mean)
	}
	if summinus==0{
	scalar sensibility2=9*10^15
	}
	}
	di as text "Under the common trends assumption, beta estimates a weighted sum of " nweights " ATTs. " _newline nplus " ATTs receive a positive weight, and " nminus " receive a negative weight." _newline "The sum of the negative weights is equal to " summinus "."
	di as text "beta is compatible with a DGP where the average of those ATTs is equal to 0," _newline "while their standard deviation is equal to " sensibility "."
	if summinus<0{
	di as text "beta is compatible with a DGP where those ATTs all are of a different sign than beta," _newline "while their standard deviation is equal to " sensibility2 "."
	}
	if summinus==0{
	di as text "All the weights are positive, so beta cannot be of a different sign than all those ATTs."
	}
	ereturn clear 
	ereturn scalar sum_neg_w = summinus
	ereturn scalar lb_se_te = sensibility
	if summinus<0{
	ereturn scalar lb_se_te2 = sensibility2
	}
	ereturn scalar beta = beta
	if "`test_random_weights'"!=""{
	di  as result _newline "Regression of variables possibly correlated with the treatment effect on the weights"
	matrix list B
	ereturn matrix randomweightstest1 = B
	}
	restore
	if "`breps'"!="0"{
	set seed 1
	matrix R=0,0
	local i 1
	while `i'<=`breps'{
	qui{
	preserve
	if "`brepscluster'"==""{
	bsample
	}
	if "`brepscluster'"!=""{
	bsample, cluster(`brepscluster')
	}
	twowayfeweights `outcome' `group' `time' `meantreatgroup' `treatment' , type(fdTR) controls(`controls')
	matrix R=R\sensibility,sensibility2
	restore
	local i `i'+1
	}
	}
	preserve
	qui{
	drop _all
	svmat R
	drop if _n==1
	sort R1
	scalar down = round(0.025*`breps')
	scalar up = round(0.975*`breps')
	sum R1 if _n== down
	scalar lowerbound = r(mean)
	sum R1 if _n== up
	scalar upperbound = r(mean)
	sort R2
	sum R2 if _n== down
	scalar lowerbound2 = r(mean)
	sum R2 if _n== up
	scalar upperbound2 = r(mean)
	}
	di as result "Inference Measures"
	di as text "The 95% confidence interval of the standard deviation of the ATTs compatible with beta and an ATT of 0 is [" lowerbound "," upperbound "]."
	if summinus<0{
	di as text "The 95% confidence interval of the standard deviation of the ATTs compatible with beta of a different sign than all the ATTs is [" lowerbound2 "," upperbound2 "]."
	}
	restore
	qui{
	if "`test_random_weights'"!=""{
	twowayfeweights `outcome' `group' `time' `meantreatgroup' `treatment' , type(fdTR) controls(`controls') test_random_weights(`test_random_weights')
	}
	if "`test_random_weights'"==""{
	twowayfeweights `outcome' `group' `time' `meantreatgroup' `treatment' , type(fdTR) controls(`controls')
	}
	ereturn scalar lb_ci_lb_se_te = lowerbound
	ereturn scalar ub_ci_lb_se_te = upperbound
	if summinus<0{
	ereturn scalar lb_ci_lb_se_te2 = lowerbound2
	ereturn scalar ub_ci_lb_se_te2 = upperbound2
	}
	}
	}
	}
	//Arranging data set saved in the end, XX: change "keep" line when done with tests
	preserve	
	if "`path'"!=""{
	use "`path'", clear
	*keep G T weight
	save "`path'", replace
	}
	restore
end
