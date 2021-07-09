* VERSION 9
* MARCH 7, 2007

program define sensatt, rclass
version 9.0

syntax varlist(min=2) [if] [in] [fweight iweight pweight], [alg(string) se(string) /*
*/ Reps(int 1000) p(varname) p11(real 0) p10(real 0) p01(real 0) p00(real 0) ycent(int 0) /*
*/ pscore(varname) index logit comsup BOOTstrap]

tokenize `varlist'

preserve
capture keep `if' `in'

*To distinguish between binary and continuous outcomes
capture assert (`1'==1|`1'==0|`1'==.)
scalar tmp=_rc
if tmp==0 {
local Y `1'
local SY `1'
}
else {
	if `ycent'==50|`ycent'==25|`ycent'==75 {
	local Y `1'
	qui sum `1',d
	scalar define med=r(p`ycent')
	gen simy= `1'>med
	local SY simy
	}
	else {
		if `ycent'==0 {
		local Y `1'
		qui sum `1'
		scalar define mean=r(mean)
		gen simy= `1'>mean
		local SY simy
		}
		else{
		di as error "WARNING: The option ycent() can only take three values: 25, 50, 75."
		exit 119
		}
	}
}
scalar drop tmp

*To allow only binary treatments
local T `2'
local YT: list Y|T
local rest: list varlist-YT
if ~(`T'==1|`T'==0|`T'==.) {
di as error "WARNING: The variable `T' is not a dummy.
di as error "The treatment must be binary."
exit 109
}

*To select the matching algorithm
if `"`alg'"'==""|`"`alg'"'=="attnd" {
local est attnd 
}
else {
	if `"`alg'"'=="attk" {
	local est attk
	}
	else {
		if `"`alg'"'=="attnw" {
		local est attnw
		}
		else {
			if `"`alg'"'=="attr" {
			local est attr
			}
			else {
			di as error "WARNING: You must use one of the following commands as algorithms to match treated and control units" 
			di as error "on the basis of the propensity score: attnd, attnw, attr, attk."
			exit 119
			}
		}
	}
}

*To fix the simulation parameters
if `"`p'"'!="" {
	capture assert (`p'==1|`p'==0|`p'==.)
	scalar tmp=_rc
	if tmp==0 {
	qui sum `p' if `T'==1&`SY'==1
	local p1 = r(mean)	
	qui sum `p' if `T'==1&`SY'==0
	local p2 = r(mean)	
	qui sum `p' if `T'==0&`SY'==1
	local p3 = r(mean)	
	qui sum `p' if `T'==0&`SY'==0
	local p4 = r(mean)
	}
	else {
	di as error "WARNING: The variable `p' is not a dummy."
	di as error "To simulate U so as to mimic an observable covariate, you must choose a binary variable."
	exit 109
	}
	scalar drop tmp
}
else {
	if (`p11'<=1&`p11'>=0)&(`p10'<=1&`p10'>=0)&(`p01'<=1&`p01'>=0)&(`p00'<=1&`p00'>=0) {
	local p1 `p11'
	local p2 `p10'
	local p3 `p01'
	local p4 `p00'
	}
	else {
	di as error "WARNING: The parameters pij are probabilities.
	di as error "If you define them, you must choose values between 0 and 1.
	exit 109
	}
}

*To calculate and show the baseline estimate
di in gr _newline(3) "*** THIS IS THE BASELINE ATT ESTIMATION (WITH NO SIMULATED CONFOUNDER)."
`est' `varlist' [`weight' `exp'], `comsup' `logit' pscore(`pscore') `bootstrap' `index'

*To calculate and show the simulated estimate
di in gr _newline(3) "*** THIS IS THE SIMULATED ATT ESTIMATION (WITH THE CONFOUNDER U)."

qui sum `SY' if `T'==1
local a=r(mean)
qui sum `SY' if `T'==0
local b=r(mean)
local p5=`p2'*(1-`a')+`p1'*`a'
local p6=`p4'*(1-`b')+`p3'*`b'

di in ye _newline(1) "The probability of having U=1 if T=1 and Y=1 (p11) is equal to:" %9.2f `p1'
di in ye "The probability of having U=1 if T=1 and Y=0 (p10) is equal to:" %9.2f `p2'
di in ye "The probability of having U=1 if T=0 and Y=1 (p01) is equal to:" %9.2f `p3'
di in ye "The probability of having U=1 if T=0 and Y=0 (p00) is equal to:" %9.2f `p4'
di in ye _newline(1) "The probability of having U=1 if T=1 (p1.) is equal to:" %9.2f `p5'
di in ye "The probability of having U=1 if T=0 (p0.) is equal to:" %9.2f `p6'

matrix att = J(`reps',1,0)
matrix se = J(`reps',1,0)
matrix yodds = J(`reps',1,0)
matrix todds = J(`reps',1,0)

di in ye _newline(3) " The program is iterating the ATT estimation with simulated confounder." 
di in ye " You have chosen to perform `reps' iterations. This step may take a while."

forvalues i=1/`reps' {
tempvar uni u1 u2 u3 u4
gen `uni'=uniform()
gen `u1' = `uni'<`p1'
gen `u2' = `uni'<`p2'
gen `u3' = `uni'<`p3'
gen `u4' = `uni'<`p4'
qui gen uconf=`u1' if `T'==1&`SY'==1
qui replace uconf=`u2' if `T'==1&`SY'==0
qui replace uconf=`u3' if `T'==0&`SY'==1
qui replace uconf=`u4' if `T'==0&`SY'==0

qui `est' `varlist' uconf [`weight' `exp'], `comsup' `logit' pscore(`pscore') `bootstrap' `index'
matrix att[`i',1] = r(`est')
matrix se[`i',1] = r(se`est')

qui logit `SY' uconf `rest' [`weight' `exp'] if `T'==0
local names : colnames e(b)
scalar find=strpos("`names'","uconf ")
matrix b=e(b)
	if find==0{
   	scalar odds=.
   	matrix yodds[`i',1] = odds
   	scalar drop odds
	}
	else{
   	scalar odds=exp(b[1,1])
   	matrix yodds[`i',1] = odds
   	scalar drop odds
	}
matrix drop b
scalar drop find

qui logit `T' uconf `rest' [`weight' `exp']
local names : colnames e(b)
scalar find=strpos("`names'","uconf ")
matrix b=e(b)
	if find==0{
   	scalar odds=.
   	matrix todds[`i',1] = odds
   	scalar drop odds
	}
	else{
   	scalar odds=exp(b[1,1])
   	matrix todds[`i',1] = odds
   	scalar drop odds
	}
matrix drop b
scalar drop find

drop uconf

}

qui svmat att
qui svmat se
qui svmat yodds
qui svmat todds

qui sum att1
local avgatt = r(mean)
local bse = r(sd)
local bvar = `bse'^2
qui sum se1
local wse = r(mean)
qui gen var=se1^2
qui sum var
local wvar = r(mean)
local tse = sqrt(`wvar'+(1+1/`reps')*`bvar')
qui sum yodds1
local avyodds = r(mean)
qui sum todds1
local avtodds = r(mean)

return scalar att = `avgatt'
return scalar se = `tse'
return scalar bse = `bse'
return scalar wse = `wse'
return scalar yodds = `avyodds'
return scalar todds = `avtodds'


if `"`se'"'==""|`"`se'"'=="tse" {
di _newline(3) _column(1)  in gr "ATT estimation with simulated confounder" 
di             _column(1)  in gr "General multiple-imputation standard errors" 
di in gr _newline(1) in text "{hline 47}"
di             _column(1)   in gr "      ATT" _column(13)  in gr " Std. Err." _column(25)  in gr "  Out. Eff." _column(37) in gr "  Sel. Eff."
di in gr             in text "{hline 47}"
di _newline(1) _column(1)   in ye %9.3f return(att) _column(13)  in ye %9.3f return(se) _column(26)  in ye %9.3f return(yodds) _column(38)  in ye %9.3f return(todds)
di in gr _newline(1) in text "{hline 47}"
di in gr "Note: Both the outcome and the selection effect"
di in gr "are odds ratios from logit estimations."
}
else {
	if `"`se'"'=="wse" {
	di _newline(3) _column(1)  in gr "ATT estimation with simulated confounder" 
	di             _column(1)  in gr "Within-imputation standard errors" 
	di in gr _newline(1) in text "{hline 47}"
	di             _column(1)   in gr "      ATT" _column(13)  in gr " Std. Err." _column(25)  in gr "  Out. Eff." _column(37) in gr "  Sel. Eff."
	di in gr             in text "{hline 47}"
	di _newline(1) _column(1)   in ye %9.3f return(att) _column(13)  in ye %9.3f return(wse) _column(26)  in ye %9.3f return(yodds) _column(38)  in ye %9.3f return(todds)
	di in gr _newline(1) in text "{hline 47}"
	di in gr "Note: Both the outcome and the selection effect"
	di in gr "are odds ratios from logit estimations."
	}
	else {
		if `"`se'"'=="bse" {
		di _newline(3) _column(1)  in gr "ATT estimation with simulated confounder" 
		di             _column(1)  in gr "Between-imputation standard errors" 
		di in gr _newline(1) in text "{hline 47}"
		di             _column(1)   in gr "      ATT" _column(13)  in gr " Std. Err." _column(25)  in gr "  Out. Eff." _column(37) in gr "  Sel. Eff."
		di in gr             in text "{hline 47}"
		di _newline(1) _column(1)   in ye %9.3f return(att) _column(13)  in ye %9.3f return(bse) _column(26)  in ye %9.3f return(yodds) _column(38)  in ye %9.3f return(todds)
		di in gr _newline(1) in text "{hline 47}"
		di in gr "Note: Both the outcome and the selection effect"
		di in gr "are odds ratios from logit estimations."
		}
		else {
		di as error "WARNING: You must use one of the following arguments for the option se(): tse, wse, bse."  
		di as error "The default choice is: tse."
		exit 119
		}
	}
}

restore

end

