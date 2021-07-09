// Companion code for Brodeur, Cook and Heyes (2020) Speccheck
// module for specification checking
// this code comes with no warranties, but we welcome your questions at ncook@uottawa.ca

*** Speccheck

capture program drop speccheck

program speccheck // define the command's call

quietly {

version 11.0

syntax varlist(min=2 max=20 numeric fv ts) [if] [, method(string) absorb(string) xt(string) vce(string) nocon(string) always(string)] // require what gets fed into it be numeric, allow factor variables, time series

args yvar xvar xvar1 xvar2  // first argument is yvar

local pos = strpos("`varlist'", " ") + 1 // position to cut user input into yvar xvars

local xvars = substr("`varlist'", `pos', .) // cut varlist into yvar xvars

local pos = strpos("`xvars'", " ") + 1 // position to cut xvars into xvar xvars

local xvars = substr("`xvars'", `pos', .) // cut xvars into xvar xvars

if "`always'" != "1" & "`always'" != "2"  {
local xvar1 = ""
local xvar2 = ""
}
if "`always'" == "1" {
local xvar2 = ""
}
if "`always'" == "2" {
}

if "`always'" == "1" {

	local pos = strpos("`xvars'", " ") + 1 // position to cut xvars into xvar xvars

	local xvars = substr("`xvars'", `pos', .) // cut xvars into xvar xvars

}

if "`always'" == "2" {

	local pos = strpos("`xvars'", " ") + 1 // position to cut xvars into xvar xvars

	local xvars = substr("`xvars'", `pos', .) // cut xvars into xvar xvars

	local pos = strpos("`xvars'", " ") + 1 // position to cut xvars into xvar xvars

	local xvars = substr("`xvars'", `pos', .) // cut xvars into xvar xvars

}

*reg `varlist' 

di "`yvar'"

di "`xvars'"
	
di "`if'"

di "`vce'"
	
*ssc install tuples 

tuples `xvars', di
global tuple0 " "

di "`tuple1'"

local ticker 0

capture drop betas
gen betas = .
capture drop tstats
gen tstats = .
capture drop stds
gen stds = .
capture drop numcoeffs
gen numcoeffs = .
capture drop numobs
gen numobs = .

local wordcount = wordcount("`xvars'")
di `wordcount'

local n = (2^`wordcount')-1
local numruns = (2^`wordcount')-1


forval i = 0(1)`n' {
di `i'
di "`tuple`i''"
      
	
if "`method'" == "" | "`method'" == "reg" {
	local method = "reg"
	reg `yvar' `xvar' `xvar1' `xvar2' `tuple`i'' `if' , vce(`vce')
	}
else if "`method'" == "areg" {
	areg `yvar' `xvar' `xvar1' `xvar2'   `tuple`i'' `if', absorb(`absorb') `vce'
	}
else if "`method'" == "xtreg" {
	xtreg `yvar' `xvar' `xvar1' `xvar2'   `tuple`i'' `if', `xt' `vce'
	}	

	local ticker = `ticker' + 1
	di `ticker'

	matrix B =  e(b)
	local b B[1,1]
	replace betas = `b' in `ticker'
	
	matrix V =  e(V)
	local t B[1,1]/(V[1,1]^0.5)
	replace tstats = `t' in `ticker'
	
	local std (V[1,1]^0.5)
	replace stds = `std' in `ticker'
	
	local wordtuple = wordcount("`tuple`i''")
	replace numcoeffs = `wordtuple' in `ticker'	
	replace numobs = `e(N)'
}

replace tstats = abs(tstats)
*replace betas = abs(betas)

if "`nocon'" == "Yes" {

local numruns = (2^`wordcount')-1

hist tstats if tstats!=0 & _n>2 , width() start(0) xline(1.96) title("t-Curve") xtitle("t-Statistic") saving(1.gph, replace) graphregion(color(white)) scheme(s1mono) percent color(none) lwidth(medium) lcolor(black) nodraw

hist betas if tstats!=0 & _n>2 , width() start() xline(0) title("Effect Curve") xtitle("Effect Size") saving(2.gph, replace) graphregion(color(white)) scheme(s1mono) percent color(none) lwidth(medium) lcolor(black) nodraw

graph box tstats if tstats!=0 & _n>2 , over(numcoeffs) yline() title("t-Statistic by # of controls") ytitle("t-Statistic") saving(3.gph, replace) graphregion(color(white)) ylab(, nogrid) scheme(s1mono) marker(1, msize(small) mlcolor(none) mfcolor(black)) box(1, fcolor(white) lcolor(black)) medline(lcolor(black) lwidth(medthin)) graphregion(color(white)) nodraw

graph box betas if tstats!=0 & _n>2 , over(numcoeffs) yline(0) title("Effect Size by # of controls") ytitle("Effect Size") saving(4.gph, replace) graphregion(color(white)) ylab(, nogrid) scheme(s1mono) marker(1, msize(small) mlcolor(none) mfcolor(black)) box(1, fcolor(white) lcolor(black)) medline(lcolor(black) lwidth(medthin)) graphregion(color(white)) nodraw

}
else {

local numruns = (2^`wordcount')

hist tstats if tstats!=0  , width() start(0) xline(1.96) title("t-Curve") xtitle("t-Statistic") saving(1.gph, replace) graphregion(color(white)) scheme(s1mono) percent color(none) lwidth(medium) lcolor(black) nodraw

hist betas if tstats!=0  , width() start() xline(0) title("Effect Curve") xtitle("Effect Size") saving(2.gph, replace) graphregion(color(white)) scheme(s1mono) percent color(none) lwidth(medium) lcolor(black) nodraw

graph box tstats if tstats!=0  , over(numcoeffs) yline() title("t-Statistic by # of controls") ytitle("t-Statistic") saving(3.gph, replace) graphregion(color(white)) ylab(, nogrid) scheme(s1mono) marker(1, msize(small) mlcolor(none) mfcolor(black)) box(1, fcolor(white) lcolor(black)) medline(lcolor(black) lwidth(medthin)) graphregion(color(white)) nodraw

graph box betas if tstats!=0  , over(numcoeffs) yline(0) title("Effect Size by # of controls") ytitle("Effect Size") saving(4.gph, replace) graphregion(color(white)) ylab(, nogrid) scheme(s1mono) marker(1, msize(small) mlcolor(none) mfcolor(black)) box(1, fcolor(white) lcolor(black)) medline(lcolor(black) lwidth(medthin)) graphregion(color(white)) nodraw

} 

sum numobs if numobs != .
local my1 = r(N)
local my2 = r(mean)
local my3 = r(sd)

graph combine 1.gph 2.gph 3.gph 4.gph ,   graphregion(color(white))  ///
caption( ///
"`method' `varlist' `if', always(`always')" ///
"Displaying estimates for: `xvar' " ///
"Always included: `xvar1' `xvar2'" ///
"Total Permutations: `numruns'" ///
"Sample Size Mean: `my2' S.D.: `my3'" , size(*0.6))
*graph export speccheck.png, replace  width(2000) 


di "`yvar'"

di "`xvars'"
	
di "`if'"

di "`vce'"

}

end

**** Examples

* ssc install tuples 

* bcuse wagepan, clear

* speccheck lwage educ union married black exper expersq , nocon(Yes)

*speccheck lwage educ union married black exper expersq if south==1

*speccheck lwage educ union married black exper expersq , vce(robust)

*speccheck lwage educ union married black exper expersq , vce(cluster nr)

*speccheck lwage educ union married black exper expersq , absorb(nr) method(areg)

*xtset nr year
*speccheck lwage educ union married black exper expersq , xt( ) method(xtreg)

