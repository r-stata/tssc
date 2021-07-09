*! v 1.0.3 PR 10oct2003.
program define mlsurvlf
/*
	Compute loglikelihood for spline model for Z or H for censored data.
	Allows for late entry and/or interval censoring.
*/
local d $S_dead
local df $S_df
local sbasis $S_sbasis
local obasis $S_obasis
local t0basis $S_sb_t0
local lbasis $S_left
local late="`t0basis'"!=""			/* late entry yes/no */
local intcens="`lbasis'"!=""			/* interval censoring yes/no */

local ll `1'
mac shift
if $S_spline==0 {				/* spline is estimated */
	local i 0
	while `i'<`df' {
		local i1=`i'+1
		local s`i' `1'				/* spline linear predictor terms */
		local svar`i':  word `i1' of `sbasis'	/* spline basis vars for ln(_t)  */
		if `late' {				/* spline basis vars for ln(_t0) */
			local svar0`i': word `i1' of `t0basis'
		}
		if `intcens' {				/* spline basis vars for ln(left)*/
			local svarl`i': word `i1' of `lbasis'
		}
		if `i'>0 {
			local ovar`i': word `i' of `obasis' /* spline deriv basis vars */
		}
		local i `i1'
		mac shift
	}
}
local xb `1'					/* covariate linear predictor */
if "`xb'"=="" {
	local xb 0
}			/* model with no xb part at all */
if "$S_theta"=="" {
	local theta 1
}
else if "$S_theta"=="." {			/* theta estimated on log scale */
	mac shift
	local theta=exp(`1')
}
else local theta $S_theta
tempvar f Zhat lnS				/* lnS = log survival function */
quietly {
/*
	Evaluate Zhat and its derivative with respect to ln t.
*/
	gen double `Zhat'=`xb'
	if "$S_offset"!="" {
		replace `Zhat'=`Zhat'+$S_offset
	}
	if `late' {
		tempvar Zhat0
		gen double `Zhat0'=`xb'
	}
	if `intcens' {
		tempvar Zhatl Sleft
		gen double `Zhatl'=`xb'
	}
	if $S_spline==0 {
		local i 0
		while `i'<`df' {
			replace `Zhat'=`Zhat'+`s`i''*`svar`i''
			if `late' {
				replace `Zhat0'=`Zhat0'+`s`i''*`svar0`i''
			}
			if `intcens' {
				replace `Zhatl'=`Zhatl'+`s`i''*`svarl`i''
			}
			if `i'==0 {
				gen double `f'=`s0'
			}
			else {
				replace `f'=`f'+`s`i''*`ovar`i''
			}
			local i=`i'+1
		}
	}
	else {
		replace `Zhat'=`Zhat'+`sbasis'
		gen double `f'=`obasis'
	}
	if $S_H {
		gen double `lnS'=-exp(`Zhat')
		if `intcens' {
			gen double `Sleft'=cond(ML_ic==-1, 1, exp(-exp(`Zhatl')))
		}
		local ldens "ln(`f')+`lnS'+`Zhat'"
		local lnS0 "-exp(`Zhat0')"
	}
	else if $S_L {
		gen double `lnS'=-ln(1+exp(`theta'*`Zhat'))/`theta'
		if `intcens' {
			gen double `Sleft'=cond(ML_ic==-1, 1, /*
			 */ (1+exp(`theta'*`Zhatl'))^(-1/`theta'))
		}
		local ldens "ln(`f')+`theta'*`Zhat'+(1+`theta')*`lnS'"
		local lnS0 "-ln(1+exp(`theta'*`Zhat0'))/`theta'"
	}
	else {		
		gen double `lnS'=ln(normprob(-`Zhat'))
		if `intcens' {
			gen double `Sleft'=cond(ML_ic==-1, 1, normprob(-`Zhatl'))
		}
		local ldens "ln(`f'*normd(`Zhat'))"
		local lnS0 "ln(normprob(-`Zhat0'))"
	}
	if `intcens' {
		replace `ll'=cond(`d'==0, `lnS', /*
		 */ cond(abs(ML_ic)==1, ln(`Sleft'-exp(`lnS')), `ldens'))
	}
	else {
		replace `ll'=cond(`d'==0, `lnS', `ldens')
	}
	if `late' {
		replace `ll'=`ll'-(`lnS0') if `svar00'!=. /* svar00 is first basis var for lnt0 */
	}
}
end
exit
/*
	replace `ll'=. if `f'<=0	/* zero or neg derivative => nonmono baseline dist fn */
	if "$S_fixll"!="" {
		replace `ll'=-1e30 if `ll'==.
	}
*/
}
end
