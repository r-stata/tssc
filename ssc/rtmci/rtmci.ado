*! 1.2.0 Ariel Linden 07mar2013 - added figure option
*! 1.1.0 Ariel Linden 16feb2013 - added %RTM
*! 1.0.0 Ariel Linden 09feb2013 

capture program drop rtmci
program define rtmci, rclass byable(recall)
	version 11.0
	syntax varlist(min=2 max=2) [if] [in] , CUToff(string) [PERiod(int 1) SEED(integer 1234) REPS(integer 1000) SIZE(string) LEVel(real 95) SAVING(string) Format(str) FIGure ] 

	preserve
	
	tokenize `varlist'
	local pretest `1'
	local posttest `2'

	marksample touse 
	quietly count if `touse' 
	if r(N) == 0 error 2000
	local N = r(N) 


	if "`format'" != "" { 
		confirm numeric format `format' 
	}
	else local format %05.3f 
	
// set the seed
	if "`seed'" != "" {
	`version' set seed `seed'
	}
	
	local seed `seed'

	local m = `period'

	local k = `cutoff'

	
*	if `"`n'"' == "_N" {
*    local `n' 
*	}
		
	if `"`size'"' == "_N" {
    local `size' 
	}
	
	if "`level'" != "" {
    set level `level'
	local level `level'
	}	
	
//Return values
	ret scalar k = `k'
	ret scalar m = `m'

	bootstrap mu = r(mu) sd = r(sd) rho = r(rho) firstval_high = r(firstval_high) secondval_high = r(secondval_high) rtmhigh = r(rtm_high) pct_rtm_high = r(pct_rtm_high) ///
	firstval_low = r(firstval_low) secondval_low=r(secondval_low) rtmlow = r(rtm_low) pct_rtm_low = r(pct_rtm_low), seed(`seed') reps(`reps') size(`size') level(`level') saving(`saving'): ///
	rtm_calc `varlist' if `touse', k(`k') m(`m') seed(`seed') reps(`reps') size(`size') level(`level') saving(`saving')

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


