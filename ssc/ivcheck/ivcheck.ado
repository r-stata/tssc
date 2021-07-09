*!version 1  March 5, 2011
capture program drop ivcheck
program define ivcheck, rclass sort
version 10
qui {
	syntax [anything(name=0)] [if] [in] [aw fw/] [, SAVing(string) LOW(real -100) HIgh(real 100)]
	
	marksample touse
	
		local n 0
		gettoken lhs 0 : 0, parse(" ,[") match(paren)
		
		IsStop `lhs'
		if `s(stop)' { 
			error 198 
		}
		while `s(stop)'==0 { 
			if "`paren'"=="(" {
				local n = `n' + 1
				if `n'>1 { 
capture noi error 198
di in red `"syntax is "(all instrumented variables = instrument variables)""'
exit 198
				}
				gettoken p lhs : lhs, parse(" =")
				while "`p'"!="=" {
					if "`p'"=="" {
capture noi error 198 
di in red `"syntax is "(all instrumented variables = instrument variables)""'
di in red `"the equal sign "=" is required"'
exit 198 
					}
				
					local endo `endo' `p' 
					gettoken p lhs : lhs, parse(" =")
					
				}
				local iv `lhs'	
					local temp_ct  : word count `endo'
					if `temp_ct' > 1 {
						capture noi error 198 
						di in red `"syntax is "Only one endogenous variable is allowed""'
						exit 198 
					}				
			}
			else {
				local inexog `inexog' `lhs'
			}
			gettoken lhs 0 : 0, parse(" ,[") match(paren)
			IsStop `lhs'
		}
		local 0 `"`lhs' `0'"'
		tsunab inexog : `inexog'
		tokenize `inexog'
		local lhs "`1'"		
		local 1 " " 
		local inexog `*'

	tempvar wvar
		if "`weight'" == "fweight" | "`weight'"=="aweight" {
			local wtexp `"[`weight'=`exp']"'
			gen double `wvar'=`exp'
		}
		if "`weight'" == "iweight" {
				di in red "iweights not allowed"
				exit 101
		}
		if "`weight'" == "pweight" {
				di in red "pweights not allowed"
				exit 101
		}

		if (`low' != -100 | `high'!= 100) {
			if (abs(`low')>1 | abs(`high') > 1) {
				capture noi error 198 
				di in red `"Corr(X,e) limits out of range"'
				exit 198
			}
			else if (`low' >= `high') {
				capture noi error 198 
				di in red `"Lower limit should be strictly lower than higher limit"'
				exit 198
			}
		}	


local temp_ctw  : word count `inexog'
local temp_ctz  : word count `iv'

tempvar compz
if `temp_ctz' > 1 {
 reg `endo' `iv'  if `touse' `wtexp', robust
 predict `compz' if `touse'
}
else{
  gen `compz' = `iv' if `touse'
} 



	qui if `temp_ctw'==0 {  /* No exogenous var */
		global exog_=0
		corr `endo' `compz' if `touse' `wtexp'
		global ro_xz_ = r(rho)

		pcorr `compz' `lhs' `endo' if `touse' `wtexp'
		mat pcorr = r(p_corr)
		global pro_zy_x_=pcorr[1,1]

	}
	else {
		global exog_=1
		pcorr `endo' `compz' `inexog' if `touse' `wtexp'
		mat rho = r(p_corr)
		global ro_xz_ = rho[1,1]

		pcorr `compz' `lhs' `endo' `inexog' if `touse' `wtexp'
		mat pcorr = r(p_corr)
		global pro_zy_x_=pcorr[1,1]
	}
qui reg `endo' `iv'  if `touse'
global ss_= e(N)

preserve
clear
set obs 10000
gen ro = -1 + 2*uniform()
gen royzx= -1 + 2*uniform()

scalar ro_xz = $ro_xz_
scalar ss = $ss_

gen cond = royzx^2*(1- ro_xz^2)*(1 - ro^2) + 2*royzx*ro_xz*ro*sqrt(1- ro_xz^2)*sqrt(1 - ro^2) + (1 - ro_xz^2)/ss
gen yes = royzx if cond <0
gen no = royzx if cond >=0
gen marglo = (-ro_xz*ro - sqrt((ss*(ro^2)*ro_xz^2 + ro_xz^2 - 1)/ss))/(sqrt(1- ro_xz^2)*sqrt(1 - ro^2))
gen marghi = (-ro_xz*ro + sqrt((ss*(ro^2)*ro_xz^2 + ro_xz^2 - 1)/ss))/(sqrt(1- ro_xz^2)*sqrt(1 - ro^2))

/* define two areas */
/* for ro < 0 */.

gen low=.
gen upp=.

summ royzx if ro < 0 & yes!=.
if r(mean) > 0 {
replace low = marglo if ro < 0
replace upp = marghi if ro < 0
}
else if r(mean) < 0 {
replace low = marghi if ro < 0
replace upp = marglo if ro < 0
}

summ royzx if ro > 0 & yes!=.
if r(mean) > 0 {
replace low = marglo if ro > 0
replace upp = marghi if ro > 0
}
else if r(mean) < 0 {
replace low = marghi if ro > 0
replace upp = marglo if ro > 0
}



/* Define Scale of Plot */
egen minro = min(ro) 
egen maxro = max(ro)
*egen minro = mean(mnro)
*egen maxro=mean(mxro)

if (`low' != -100) {
   replace minro = max(minro, `low')
}
if (`high' != 100) {
   replace maxro = min(maxro, `high')
}
  


sum minro, meanonly
global minro_ =round(r(mean),0.01)
sum maxro, meanonly
global maxro_ = round(r(mean),0.01)

keep if ro >=$minro_ & ro <=$maxro_
drop if abs(marglo) > 1 | abs(marghi) > 1

/* yscale */
capture drop comp1 comp2
egen comp1 = rmax(upp low)
summ comp1
global mxysc_=r(max)
egen comp2 = rmin(upp low)
summ comp2
global mnysc_=r(min)
drop comp1 comp2

/* calculate cuoffs */
global pro_zy_x_ = round($pro_zy_x_, 0.001)
gen pro_zy_x = $pro_zy_x_

gen diff = abs(marglo - pro_zy_x) 
sort diff
scalar ro_xe = round(ro, 0.001)
global ro_xe_ = ro_xe
global ro_xe_1 = ro_xe + ($maxro_ - $minro_)/20 


gen xpro_zy_x = $minro_ + ($ro_xe_ - $minro_)* uniform()
gen xro_xe = $ro_xe_
gen yro_xe = $mnysc_ +  ($pro_zy_x_ - $mnysc_)*uniform()

		
/* Calculate coordinates for Plots */

if $pro_zy_x_ >= 0 {
global ycord_ = $pro_zy_x_ + ($mxysc_ - $mnysc_)/20 
}
else {
global ycord_ = $pro_zy_x_ - ($mxysc_ - $mnysc_)/20 
}
global xcord_ = $minro_ + ($maxro_ - $minro_)/20 


keep if ro >= $minro_ & ro <= $maxro_
keep if xpro_zy_x >= $minro_ & xpro_zy_x <= $maxro_
keep if xro_xe >= $minro_ & xro_xe <= $maxro_


scalar gap = ($maxro_ - $minro_)/4

global vls ""
forv i =1(1)4 {
 global nw= round($minro_ + gap*(`i'-1), 0.01)
 global vls "$vls $nw"
}
global vls "$vls $maxro_"
 


if $exog_==0 {
	if "`saving'" !="" {
	sort ro
	gr twoway ((rarea upp low ro if (low!=. & upp !=.) & ro < 0, color(gs10)) (rarea upp low ro if (low!=. & upp !=.) & ro >= 0, color(gs10)) ///
	(line pro_zy_x xpro_zy_x) (line yro_xe xro_xe), ///
	scheme(s1mono) legend(order(1 "Area where IV MSE < OLS MSE") ring(1) position(6)) ///
	xlab($vls) ylab(#4) xtitle("Corr(X,e)") ytitle("Partial Corr(Y,Z | X)") ///
	note("X: Endogenous Variable; Z: Instrumental Variable; Y: Outcome; MSE: Mean Squared Error") text($mnysc_ $ro_xe_ "V")   ///
	text($mnysc_  $ro_xe_1 "$ro_xe_") text($ycord_ $xcord_ "$pro_zy_x_") saving(`saving')
	}
	else {
	sort ro
	gr twoway (rarea upp low ro if (low!=. & upp !=.) & ro < 0, color(gs10)) (rarea upp low ro if (low!=. & upp !=.) & ro >= 0, color(gs10)) ///
	(line pro_zy_x xpro_zy_x) (line yro_xe xro_xe), ///
	scheme(s1mono) legend(order(1 "Area where IV MSE < OLS MSE") ring(1) position(6)) ///
	xlab($vls) ylab(#4)  xtitle("Corr(X,e)") ytitle("Partial Corr(Y,Z | X)") ///
	note("X: Endogenous Variable; Z: Instrumental Variable; Y: Outcome; MSE: Mean Squared Error") text($mnysc_ $ro_xe_ "V")   ///
	text($mnysc_  $ro_xe_1 "$ro_xe_") text($ycord_ $xcord_ "$pro_zy_x_")
	}
}
else if $exog_==1 {
	if "`saving'" !="" {
	sort ro
	gr twoway (rarea upp low ro if (low!=. & upp !=.) & ro < 0, color(gs10)) (rarea upp low ro if (low!=. & upp !=.) & ro >= 0, color(gs10)) ///
	(line pro_zy_x xpro_zy_x) (line yro_xe xro_xe), ///
	scheme(s1mono) legend(order(1 "Area where IV MSE < OLS MSE") ring(1) position(6)) ///
	xlab($vls) ylab(#4) xtitle("Partial Corr(X,e | W)") ytitle("Partial Corr(Y,Z | X, W)") ///
	note("X: Endogenous Variable; Z: Instrumental Variable; Y: Outcome; W: Other Exogenous Variables;" "MSE: Mean Squared Error") text($mnysc_ $ro_xe_ "V")   ///
	text($mnysc_  $ro_xe_1 "$ro_xe_") text($ycord_ $xcord_ "$pro_zy_x_") saving(`saving')
	}
	else {
	sort ro
	gr twoway (rarea upp low ro if (low!=. & upp !=.) & ro < 0, color(gs10)) (rarea upp low ro if (low!=. & upp !=.) & ro >= 0, color(gs10)) ///
	(line pro_zy_x xpro_zy_x) (line yro_xe xro_xe), ///
	scheme(s1mono) legend(order(1 "Area where IV MSE < OLS MSE") ring(1) position(6)) ///
	xlab($vls) ylab(#4)  xtitle("Partial Corr(X,e | W)") ytitle("Partial Corr(Y,Z | X, W)") ///
	note("X: Endogenous Variable; Z: Instrumental Variable; Y: Outcome; W: Other Exogenous Variables;" "MSE: Mean Squared Error") text($mnysc_ $ro_xe_ "V")   ///
	text($mnysc_  $ro_xe_1 "$ro_xe_") text($ycord_ $xcord_ "$pro_zy_x_")
	}
}




restore

return scalar rho_xz = $ro_xz_
return add
return scalar rho_zy_x= $pro_zy_x_
return add
return scalar cutoff_rho_xe = $ro_xe_

}

end

	
	
	**************************************************************************************
	capture program drop IsStop
	program define IsStop, sclass
				/* sic, must do tests one-at-a-time, 
				 * 0, may be very large */
	version 10
	if `"`0'"' == "[" {		
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
* per official ivreg 5.1.3
	if substr(`"`0'"',1,3) == "if(" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else	sret local stop 0
end
	
	
	
	
	
	
	
	
	
	
	
	


