*! 1.3.0 Ariel Linden 07mar2013 - added figure option
*! 1.2.0 Ariel Linden 16feb2013 - added %RTM to program
*! 1.1.0 Ariel Linden 14feb2013 - had corr2data generate posttest. Have rtmcii call rtm_calc. 
*! 1.0.0 Ariel Linden 07feb2013 

capture program drop rtmcii
program define rtmcii, rclass
	version 11.0
	syntax anything(id="argument numlist") [, PERiod(int 1) N(int 1000) SEED(integer 1234) REPS(integer 1000) SIZE(string) LEVel(real 95) SAVING(string) Format(str) FIGure ] 

	preserve
	clear


	if "`format'" != "" { 
		confirm numeric format `format' 
	}
	else local format %05.3f 
	
	local variable_tally : word count `anything'
    if (`variable_tally' > 4) exit = 103
    if (`variable_tally' < 4) exit = 102
	
	gettoken mu1 0 : 0 				// mean of "pre" period
	confirm number  `mu1'			
	gettoken sd1 0 : 0, parse(" ,") // sd of "pre" period 
	confirm number  `sd1'
	gettoken k 0 : 0, parse(" ,")  // cutoff on baseline period variable
	confirm number  `k'
	gettoken rho 0 : 0, parse(" ,")  // corr between "pre and "post" periods
	confirm number  `rho'

// set the seed
	if "`seed'" != "" {
	`version' set seed `seed'
	}
	
	local seed `seed'
	local m = `period'

	if `"`size'"' == "_N" {
    local `size' 
	}
	
	if "`level'" != "" {
    set level `level'
	local level `level'
	}	
	
	ret scalar k = `k'
	ret scalar rho = `rho'
	ret scalar m = `m'


// Create matrices of means, sds, and rho in order for corr2data to generate pre- and post-test data	
	matrix means = (`mu1',`mu1')  
	matrix sds = (`sd1',`sd1') 
	matrix C = (1, `rho' \ `rho', 1)
	corr2data pretest posttest, n(`n') corr(C) means(means) sds(sds)
	
*	corr2data pretest, n(`n') means(`mu1') sds(`sd1') /// in version 1.0.0 rtmcii generated only pretest.


// Call rtm_calc to run bootstrap
	bootstrap mu = r(mu) sd = r(sd) rho = r(rho) firstval_high = r(firstval_high) secondval_high = r(secondval_high) rtmhigh = r(rtm_high) pct_rtm_high = r(pct_rtm_high) ///
	firstval_low = r(firstval_low) secondval_low=r(secondval_low) rtmlow = r(rtm_low) pct_rtm_low = r(pct_rtm_low), seed(`seed') reps(`reps') size(`size') level(`level') saving(`saving'): ///
	rtm_calc pretest posttest , k(`k') m(`m') seed(`seed') reps(`reps') size(`size') level(`level') saving(`saving')

/// Generate figure 
if "`figure'" == "figure" {
qui eretu list
qui matr def eclmat=(e(b))',(e(ci_normal))'
qui matr colnames eclmat = "estimate" "lcl" "ucl"
qui matr list eclmat
qui xsvmat eclmat, rownames(parameter) names(col) norestore
sencode parameter, replace

keep if inlist( parameter,4,5,8,9)
gen period = cond(inlist(parameter,4,8),"Pre-test","Post-test")
sencode period, replace
gen highlow = cond(inlist(parameter,4,5),"Above cutoff","Below cutoff")
sencode highlow, replace

eclplot estimate lcl ucl period, eplottype(connected) ///
rplottype(rcap) supby( highlow,) estopts(connect(l) lpattern(solid)) ///
estopts1(msymbol(o)) estopts2(msymbol(s)) ciopts(blcolor(black)) xtitle("") xscale(range(1 2)) ///
xlabel(1(1)2, valuelabel angle()) yla(, ang(h)) plotregion(margin(l=20 r=20)) ///
scheme(s1manual) ytitle("Expected Y variable range")
}
	
	restore
	
end
*estat bootstrap, all
