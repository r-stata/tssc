pr dftolgraph
	version 12
	syntax [, Conf(numlist >0 <100 max=1) r(numlist sort integer >=1 <=500 min=1 max=14)]
	if "`conf'" == "" local conf = 95 
	if "`r'" == "" local r "1 2 3 4 5 7 10 15 20 30 50 100 200 400"
	qui set obs 1000
	tempvar n
	local lr: word count `r'
	forvalues i = 1/`lr' { // this loop is to ensure that the storage order of the temporary variables `logitbeta`i'' is correlative
		tempvar beta`i'
		qui gen `beta`i'' = .
	}
	gen `n' = _n
	local rmin: word 1 of `r'
	local i 1
	foreach val of local r {
		tempvar logitbeta`i'
		forvalues j = 1/`c(N)' {
			scalar scbeta = .
			local ln = `n'[`j']
			mata: st_numscalar("scbeta", invibeta(`ln' - `val' + 1, `val', 1 - `conf'/100))
			qui replace `beta`i'' = scbeta in `j'
		}
		qui gen `logitbeta`i'' = logit(`beta`i'')
		qui replace `logitbeta`i'' = . if `beta`i'' < .02
		label var `logitbeta`i'' "`val'"
		local ++i
	}
	local macrmin = max(floor(`rmin'/10)*10, 10)
	if (`macrmin' <= 100) local tags "`macrmin'(10)100 200(100)1000"
	else local tags "`macrmin'(100)1000"
		twoway line `logitbeta1'-`logitbeta`lr'' `n' if `n' >= `macrmin', ///
			title("Nonparametric Tolerance Intervals") ///
			subtitle("Confidence level: (1 {&minus} {it:{&alpha}})% = `conf'%") ///
			legend(on position(10) ring(0) cols(7) symxsize(2.5) rowgap(0.2) colgap(2) keygap(.6) size(*.5) title("Number of blocks removed ({it:r})", size(*.5))) /// 
			xtitle("Sample size ({it:n})", size(*.7)) ///
			xlabel(`tags', grid angle(60) labsize(*.6)) ///
			xscale(log) ///
			ytitle("Percentage of the population enclosed ({it:{&beta}}%)", size(*0.7)) ///
			ylabel(-3.892 "2" -2.944 "5" -2.197 "10" -1.386 "20" -0.8473 "30" -0.4055 "40" 0 "50" 0.4055 "60" 0.8473 "70" 1.386 "80" 2.197 "90" 2.944 "95" 3.892 "98" 4.595 "99" 5.293 "99.5" 6.213 "99.8", grid gmax angle(0) labsize(*.6))
end
