*!version 1.0.2 05/04/05	     (STB-56: sg149)
/*	Mark S. Pearce, University of Newcastle upon Tyne			*/
/* 	Tests for seasonality with a variable population at risk			*/
/* 	Follows the tests given in Walter & Elwood (1975), Edwards (1961)	*/
/* 	Default is Walter & Elwood test using equal month lengths		*/ 

/*	05/04/05 Corrections to fitted (expected) frequencies and angle of maximum rate */

/*	We have become aware of a problem when the program calculates the fitted, or expected, frequencies.  In some instances, these frequencies are actually flipped around the horizontal axis, simply because the calculation of the angle has also been inverted.  The angle flips is because tan(theta) = tan(theta+pi) = tan(theta-pi). Therefore, when the atan function is calculated, it picks an angle restricted to +- pi/2 and cannot produce any angles outside this range.  In other words, no maximum rates could be predicted to lie outside October to March.  A correction has been made by adding pi to thstar if xbar-xhat <0 (i.e. when the peak is April to September).

We are grateful to Darren Greenwood for helpful discussions with this problem.*/

program define seast
version 6.0
local options "EDwards EXAct NOTab Generate(string) SECtor(string) LENgth(string)"
local varlist "req ex min(1) max(2)"
parse "`*'"
parse "`varlist'", parse(" ")
local obs="`1'"
if "`2'"=="" {
	tempvar pop
	local nopop=1	
	gen `pop'=1
}
else {
	local pop ="`2'"
	local nopop=0
}

if "`generate'"!="" {
	confirm new var `generate'
}

if "`sector'"=="" {
	local sector="month"
}

tempvar theta weight xmean ymean srtm cosbit sinbit sumcos sumsin nmi totb totc sumnmi ci days x ex1 ey1 ex2 ey2 sumci exp ti sumti oe2 gfit suml rate rank 

quietly {

summ `sector'
local k=r(max)

egen `totb'=sum(`pop')
summ `totb'
local M=r(max)

egen `totc'=sum(`obs')
summ `totc'
local N=r(max)

local pi=3.1415927

if "`length'"!="" {
	egen `suml'=sum(`length')
	summ `suml'
	gen `x'=(360/`suml')*`length'*(1/57.296)
	gen `theta'=`pi'/`k'
	local stheta=`pi'/`k'
	local i=2
	while `i'<=`k' {
		summ `x' if `sector'==`i'-1
		replace `theta'=`stheta'+r(max) if `sector'==`i'
		local stheta=`stheta'+r(max)
		local i=`i'+1
	}
}	

else {
	if "`exact'"=="" {
		gen `theta' =`pi'/`k'*((2*`sector')-1)
	}
	else {
		if `k'==12 {
			gen `days'=28+2/9 if `sector'==2
			for num 1 3 5 7 8 10 12: replace `days'=31 if `sector'==X
			replace `days'=30 if `days'==.
			gen `x'=(360/365.25)*`days'*(1/57.296)
			gen `theta'=`pi'/12
			local stheta=`pi'/12
			local i=2
			while `i'<=12 {
				summ `x' if `sector'==`i'-1
				replace `theta'=`stheta'+r(max) if `sector'==`i'
				local stheta=`stheta'+r(max)
				local i=`i'+1
			}
		}
		else {
			if "`length'"=="" {
		di in red "Can only use exact with monthly data or by using the length option"
			e 100
			}
		}
	}	
}
egen `weight'=sum(sqrt(`obs'))
summ `weight'
local W=r(max)

*Calcluate observed centre point
egen `xmean'=sum((sqrt(`obs'))*(cos(`theta')))	
summ `xmean'
local xbar=r(max)/`W'

egen `ymean'=sum((sqrt(`obs'))*(sin(`theta')))
summ `ymean'
local ybar=r(max)/`W'

*Getting expected centre point

if "`edwards'"=="" {
	egen `srtm' = sum(sqrt(`pop'))
	summ `srtm'
	local srmi=r(max)
	gen `ex1'= (sqrt(`pop'))*(cos(`theta'))
	egen `ex2'=sum(`ex1')
	gen `ey1' =(sqrt(`pop'))*(sin(`theta'))
	egen `ey2'=sum(`ey1')
	summ `ex2'
	local xhat=r(max)/`srmi'
	summ `ey2'
	local yhat=r(max)/`srmi'
}
else {
	local xhat=0
	local yhat =0
}

*Variances
gen `cosbit'=0.25*(cos(`theta'))*(cos(`theta'))
gen `sinbit'=0.25*(sin(`theta'))*(sin(`theta'))
egen `sumcos'=sum(`cosbit')
summ `sumcos'
local vx1=r(max)
egen `sumsin'=sum(`sinbit')
summ `sumsin'
local vy1=r(max)

if "`edwards'"=="" {
	gen `nmi'=sqrt(`N'*`pop'/`M')
	egen `sumnmi'=sum(`nmi')
	summ `sumnmi'
	local v2=r(max)*r(max)

	local varx= `vx1'/`v2'
	local vary=`vy1'/`v2'
}

local dsq=((`xbar'-`xhat')^2)+((`ybar'-`yhat')^2)
local d=sqrt(`dsq')

local thstar=atan((`ybar'-`yhat')/(`xbar'-`xhat'))
if (`xbar'-`xhat'<0) {
	local thstar=_pi+`thstar'
}

local alpha = 4*`d'

if "`edwards'"!="" {
	gen `ci'=(1+`alpha'*(cos(`theta'-`thstar')))
	egen `sumci'=sum(`ci')
	summ `sumci'
	gen `exp'=`N'*`ci'/r(max)
	local test = 0.5*`alpha'*`alpha'*`N'
}
else {
	gen `ci'=`pop'*(1+`alpha'*(cos(`theta'-`thstar')))
	egen `sumci'=sum(`ci')
	summ `sumci'
	gen `exp'=`N'*`ci'/r(max)
	local test = (((`xbar'-`xhat')/sqrt(`varx'))^2) + (((`ybar'-`yhat')/sqrt(`vary'))^2)
}

gen `oe2'=((`obs'-`exp')^2)/`exp'
egen `gfit'=sum(`oe2')
summ `gfit'
local fit=r(max)

} *end of quietly

local thstar = `thstar'*57.296

if "`notab'"=="" {
	di in green _dup(50) "-"
	if `k'==12 {
		di in green "Month" _col(20) "|" _col(22) "Observed" _col(35) "Expected" 
	}
	else {
		di in green "Sector" _col(20) "|" _col(22) "Observed" _col(35) "Expected" 
	}
	di in green _dup(19) "-" _col(20) "+" _dup(30) "-"
	local i=1
	while `i'<=`k' {
		quietly summ `obs' if `sector'==`i'
		local obsi=r(max)
		quietly summ `exp' if `sector'==`i'
		local expi=r(max)
		if `k'!=12 {
			di in gr `i' _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
		}
		else {
			if `i'==1 {
				di in gr "January" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==2 {
				di in gr "February" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==3 {
				di in gr "March" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==4 {
				di in gr "April" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==5 {
				di in gr "May" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==6 {
				di in gr "June" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==7 {
				di in gr "July" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==8 {
				di in gr "August" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==9 {
			          di in gr "September" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==10 {
				di in gr "October" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==11 {
			            di in gr "November" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
			else if `i'==12 {
			          di in gr "December" _col(20) "|" in ye _col(22) `obsi' _col(35) `expi'
			}
		}
		local i=`i'+1
	}
	di in green _dup(50) "-"
}
di _n
if "`edwards'"!="" {
	di in gr "Edwards Test" 
	di _n
}
else {
	if "`exact'"!="" {
		di in green "Walter & Elwood Test (using exact month lengths)" 
	}
	else {
		di in gr "Walter & Elwood Test"
	}
	di _n
}

quietly {
	tempvar sumobs
	gen `sumobs'=sum(`obs')
	summ `sumobs'
	local totobs=r(max)
}

di in green "Total Number of Cases =  " in yel `totobs'
di _n
di in green "Seasonality Test" _col(50) "Goodness of fit test"

di in green "chi2(" in yel "2" in gr ")" _col(15) "= " in yel %9.4f `test' _col(50) in gr "chi2(" in yel "2" in gr ")" _col(65) "=" in yel %9.4f `fit'
di in green "Prob > chi2" _col(15) "= " in yel  %9.4f chiprob(2,`test') _col(50) in gr "Prob > chi2" _col(65) "=" in yel %9.4f chiprob(`k'-1,`fit')
di _n
di in green _dup(50) "-"
di in green "Parameter" _col(38) "|"_col(40) "Estimate"
di in green _dup(37) "-" _col(38) "+" _dup(12) "-"
di in green "Amplitude of cyclic variation" _col(38) "|" _col(40) in yellow `alpha'
di in green  "Angle of maximum rate" _col(38) "|" _col(40) in yellow `thstar'
di in green _dup(50) "-"

if "`generate'"!="" {
	gen `generate'=`exp'
}

end



