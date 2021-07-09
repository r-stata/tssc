*! A.Discacciati, V.Oskarsson, N.Orsini
*! 20150617
*! v 1.6

capture program drop stphcoxrcs
program define stphcoxrcs, rclass
version 12

syntax varlist(min=1 max=1 fv), ///
	[ ///
	SPLITEVERY(string) ///
	SPLITAT(string) ///
	NKnots(integer 3) ///
	GOPTS(string) ///
	NOGraph ///
	Level(string) ///
	LNTime ///
	NOCI ///
	SAVING(string) ///
	NOYREF ///
	IC ///
	MYCHECK /// /* leave undocumented, only used to check results with stcox + tvc */
	RANGE(string) ///
	LRTest ///
	]  

local myvarlist "`varlist'"

***initial checks

*data stset'ed
st_is 2 analysis

*id variable set
if "`_dta[st_id]'" == "" {
	di as err "stphcoxrcs requires that you have previously stset an id() variable"
	exit 198
}

*last command is cox
if e(cmd) != "cox" {
	di in red "last command must be stcox"
	exit 198
}
else {
	tempname oldcox
	est store `oldcox'

	local oldstcox = "`e(cmdline)'"
	local oldhr = exp(_b[`myvarlist'])

	local 0 : subinstr local oldstcox "stcox" "" 
	syntax varlist(fv) [if] [in] [, * ]
	local oldvarlist "`varlist'"
	*local oldif "`if'"
	local oldoptions "`options'"
	*mac li
	
	if strpos("`oldoptions'", "tvc") != 0 | ///
		strpos("`oldoptions'", "texp") != 0 {
	di as err "you cannot use tvc() and/or texp() options in stcox"
	exit 198
	}
}

*split
if "`splitevery'" != "" & "`splitat'" != "" {
	di as err "please specify only splitevery() or splitat()"
	exit 198
}
if "`splitevery'" == "" & "`splitat'" == "" {
	local splitat "failures"
}

*knots between 3 and 5
if `nknots' < 3 | `nknots' > 5 {
	di as err "nknots() must be between 3 and 5"
	exit 198
}
if "`mycheck'" != "" local nknots = 2

*level
if "`level'" == "" {
	local level = c(level)
}
if `level' <10 | `level'>99 { 
		di as err "level() must be between 10 and 99"
		exit 198
} 

*range
if "`range'" != "" {
	local nrange : word count `range'
	if `nrange' != 2 {
		di as err "specify 2 values in the option range()"
		exit 198
	}
	else {
		tokenize "`range'"
		if "`lntime'" == "" {
			local minrange = `1'
			local maxrange = `2'
		}
		else {
			if `1' == 0 {
				di as err "lower limit in range() cannot be 0 if the option lntime is also specified"
				exit 198
				}
			local minrange = log(`1')
			local maxrange = log(`2')
		}
	}
}


***clean dataset
preserve 
qui keep if e(sample)

***stsplit
if "`splitat'" != "" {
	qui stsplit, at(`splitat') nopreserve
}
else if "`splitevery'" != "" {
	tempvar split
	qui stsplit `split', every(`splitevery') nopreserve
}


***rcs transformations of time
tempvar lntimev timev
gen double `lntimev' = ln((_t + _t0) / 2)
gen double `timev' = ((_t + _t0) / 2)

if `nknots' == 3 {
	_pctile `lntimev' if _d == 1, p(10 50 90)
	local myknots "`r(r1)' `r(r2)' `r(r3)'"
	mkspline __splxx = `lntimev', cubic knots(`myknots')
}
else if `nknots' == 4 {
	_pctile `lntimev' if _d == 1, p(5 35 65 95)
	local myknots "`r(r1)' `r(r2)' `r(r3)' `r(r4)'" 
	mkspline __splxx = `lntimev', cubic knots(`myknots')
}
else if `nknots' == 5 {
	_pctile `lntimev' if _d == 1, p(5 27.5 50 72.5 95)
	local myknots "`r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)'" 
	mkspline __splxx = `lntimev', cubic knots(`myknots')
}
else if `nknots' == 2 {
	gen double __splxx1 = ln(_t)
}

return scalar N_knots = r(N_knots)

*tempname retknots
*mat `retknots' = r(knots)
*mat rownames `retknots' = timescale
*return matrix knots = `retknots'

local interactions ""
local j = 1
foreach i of numlist 1/`=`nknots'-1' {
	tempvar inter`i'
	qui gen `inter`i'' = `myvarlist' * __splxx`i'
	local interactions "`interactions' `inter`i''"
	local j++	
}


***test for non PH
tempname tvccox tempcox

if "`lrtest'" == "" {
	qui stcox `oldvarlist' `interactions', `oldoptions'

	qui testparm `interactions'
	local testtype "Wald"
}
else {
	qui stcox `oldvarlist', `oldoptions'
	est store `tempcox'
	
	qui stcox `oldvarlist' `interactions', `oldoptions'
	est store `tvccox'

	qui lrtest `tvccox' `tempcox'
	local testtype "Likelihood ratio"	
}

di in gr _newline(1) "`testtype' test of proportional-hazards assumption for `myvarlist'"

di as text _newline(1) _col(5) "chi2(" r(df) ") = " as result %5.2f r(chi2)
di as text _col(5) "Prob > chi2 = " as result %6.4f chi2tail(r(df), r(chi2))
di as text _newline(1) _col(5) ///
	"Note: time scale modeled using Restricted Cubic Splines with `nknots' knots"

return scalar p = chi2tail(r(df), r(chi2))
return scalar df = r(df)
return scalar chi2 = r(chi2)

`=cond("`ic'"=="", "qui", "")' estat ic
tempname icmat
mat `icmat' = r(S)

return matrix S  = `icmat'


***graph
if "`nograph'" != "nograph" | "`saving'" != "" {
	tempvar loghr hr lo hi lb ub tag
	
	local mypredictnl ""
	foreach i of numlist 1/`=`nknots'-1' {
		if `i' == 1 {
			local plus ""
		}
		else {
			local plus = "+"
		}
		local brick "`plus' _b[`inter`i'']*(__splxx`i')"
		local mypredictnl "`mypredictnl' `brick'"
	}
	
	qui egen `tag' = tag(_t)
	
	qui predictnl `loghr' = _b[`myvarlist'] + `mypredictnl' ///
		if `tag', ci(`lo' `hi') level(`level')
	qui gen `hr' = exp(`loghr')
	qui gen `lb' = exp(`lo')
	qui gen `ub' = exp(`hi')
}

if "`range'" != "" {
	qui su `=cond("`lntime'"=="", "`timev'", "`lntimev'")' ///
		if inrange(`=cond("`lntime'"=="", "`timev'", "`lntimev'")', `minrange', `maxrange'), meanonly	
	local tmin = r(min)
	local tmax = r(max)
}
else {	
	qui su `=cond("`lntime'"=="", "`timev'", "`lntimev'")', meanonly
	local tmin = r(min)
	local tmax = r(max)
}
	
if "`nograph'" != "nograph" {	
	tw (function y = `oldhr', range(`tmin' `tmax') lc(gs10) lw(medium) n(2)) /// /* referent line time-fixed HR */
	`=cond("`noyref'"!="", "", "(function y = 1 , range(`tmin' `tmax') lc(gs10) lw(medium) n(2) lp(_))")' /// /* referent line at HR=1 */
	(line `hr' `=cond("`noci'"=="", "`ub' `lb' ", " ")' /// /* y variables */
	 `=cond("`lntime'"=="", "`timev'", "`lntimev'")' /// /* x variable */
	 `=cond("`range'"!= "", "if inrange(`=cond("`lntime'"=="", "`timev'", "`lntimev'")', `minrange', `maxrange')", "")', /// /* range opt */
	 sort lp(l `=cond("`noci'"=="", "- -", " ")') lc(black `=cond("`noci'"=="", "black black", "")') /// /* lines options */
		lw(medthick `=cond("`noci'"=="", "medthick medthick", "")')), /// /* lines options */
	 yscale(log) legend(order(`=cond("`noyref'"=="", "3", "2")' "Time-varying Hazard Ratio" ///
	 1 "Time-fixed Hazard Ratio") rows(2)) ///
	 scheme(s1mono)  ytitle("Hazard Ratio") xtitle("Time scale") ///
	 plotregion(style(none)) ///
	 ylabel(#5 `oldhr' `=cond("`noyref'"!="", "", "1")', ///
	 angle(horiz) format(%4.2fc)) ///
	 xlabel(#7) ///
	 `gopts'
}

if "`saving'" != "" {
	ParseSaving `saving'
	
	qui keep if `tag'

	qui gen _hr = `hr'
	qui gen _lb_`level'ci = `lb'
	qui gen _ub_`level'ci = `ub'
	qui gen _timescale = `timev'
	if "`lntime'" != "" {
		qui gen _lntimescale = `lntimev'
	}
		
	label variable _hr "Hazard Ratio"
	label variable _lb_`level'ci "Lower bound `level'% CI"
	label variable _ub_`level'ci "Upper bound `level'% CI"
	label variable _timescale "Time scale"
	if "`lntime'" != "" {
		label variable _lntimescale "ln(Time scale)"
	}	
	
	qui keep _hr _lb_* _ub_* _timescale `=cond("`lntime'"!="", "_lntimescale", "")'

	qui saveold "`s(fn)'", `s(replace)'
}
restore

qui est restore `oldcox'
end


capture program drop ParseSaving
program define ParseSaving, sclass
        * fn[,replace]

        sret clear
        if `"`0'"' == "" {
                exit
        }
        gettoken fn      0 : 0, parse(",")
        gettoken comma   0 : 0
        if length("`comma'") > 1 {
		local 0 = substr("`comma'",2,.) + "`0'"
 		local comma = substr("`comma'", 1,1)
	}
        gettoken replace 0 : 0
	
	local fn = trim(`"`fn'"')
        local 0 = trim(`"`0'"')
        if `"`fn'"'!="" & `"`0'"'=="" {
                if `"`comma'"'=="" | (`"`comma'"'=="," & `"`replace'"'=="") {
                        sret local fn `"`fn'"'
                        exit
                }
                if `"`comma'"'=="," & `"`replace'"'=="replace" {
                        sret local fn `"`fn'"'
                        sret local replace "replace"
                        exit
                }
        }
        di as err "option saving() misspecified"
        exit 198
end
exit



