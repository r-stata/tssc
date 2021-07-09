*! version 3.0.0 02May 2020

program randcmd, eclass
	version 13.1
	syntax anything , treatvars(string) [calc1(string) calc2(string) calc3(string) calc4(string) calc5(string) calc6(string) calc7(string) calc8(string) calc9(string) calc10(string) calc11(string) calc12(string) calc13(string) calc14(string) calc15(string) calc16(string) calc17(string) calc18(string) calc19(string) calc20(string) reps(integer 1000) strata(string) groupvar(string) seed(integer 1) saving(string) sample]
	tempname b f bb ff fff info T ResB ResSE ResF list ResCoef ResEqn ResMult cov
	tempvar U Order M MM n

preserve

	local oldseed = "`c(seed)'"

*Extracting list of treatment variables and post-treatment calculations, establishing sample (treatvars ~= .)
	unab treatvars: `treatvars'
	local calc = 0
	forvalues k = 1/20 {
		if ("`calc`k''" ~= "") local calc = `k'
		}
	local error = 0
	foreach var in `treatvars' {
		quietly sum `var'
		if (r(sum) == 0) {
			display as error "All treatvars must be numeric and vary across the dataset."
			local error = 1
			}
		}
	if (`error' == 1) exit
	foreach var in `treatvars' {
		quietly drop if `var' == .
		}

*Baseline estimating equations
	local eqn = 0
	local treatnumber = 0
	local error = 0
	while "`anything'" ~= "" {
		local eqn = `eqn' + 1
		gettoken eqn`eqn' anything: anything, match(match)
		gettoken treat`eqn' eqn`eqn': eqn`eqn', match(match)
		local treatnumber = `treatnumber' + wordcount("`treat`eqn''")
		if (wordcount("`treat`eqn''") == 0) {
			display as error "No treatment variables specified for equation `eqn'."
			local error = 1
			}
		}
	if (`error' == 1) exit	
	matrix `f' = J(`eqn',3,.)
	matrix `b' = J(`treatnumber',2,.)
	local c = 0
	local length = 0
	if ("`sample'" ~= "") gen `M' = 0
	forvalues k = 1/`eqn' {
		*In case of bootstrap with user set seed
		local tempseed = "`c(seed)'"
		`eqn`k''
		set seed `tempseed'
		if ("`sample'" ~= "") quietly replace `M' = `M' + e(sample)
		local test`k'  = ""
		foreach var in `treat`k'' {
			local length = max(`length',length("`var'"))
			local c = `c' + 1
			capture matrix `b'[`c',1] = _b[`var'], _se[`var']
			if (_rc ~= 0) {
				display as error "`var' cannot be found in estimating equation `k'."
				local error = 1
				}
			local test`k' = "`test`k''" + "(_b[`var']==0)"
			}
		if (`error' == 1) continue, break
		test `test`k''
		local f`k' = r(df)
		if (r(df_r) ~= .) local ftype`k' = "r(F)"
		if (r(df_r) == .) local ftype`k' = "r(chi2)"
		matrix `f'[`k',1] = `ftype`k'', r(p), `f`k''
		display " "
		}
	if (`error' == 1) exit
	if ("`sample'" ~= "") {
		quietly keep if `M' > 0
		quietly drop `M'
		}
	matrix `info' = J(`eqn',2,1)
	forvalues k = 1/`eqn' {
		matrix `info'[`k',2] = `info'[`k',1] + wordcount("`treat`k''") - 1
		if (`k' < `eqn') matrix `info'[`k'+1,1] = `info'[`k',2] + 1
		}

*Checking consistency of groupings & strata
	local error = 0
	if ("`groupvar'" ~= "") {
		foreach var in `treatvars' {
			quietly egen `M' = sd(`var'), by(`groupvar')
			quietly sum `M'
			if (r(mean) > 0 & r(mean) ~= .) {
				display as error "`var' varies within `groupvar'.  Base treatment variables should not vary within treatment groupings."
				display " "
				local error = 1
				}
			quietly drop `M'
			}
		if ("`strata'" ~= "") {
			quietly egen `M' = group(`strata'), missing
			quietly egen `MM' = sd(`M'), by(`groupvar')
			quietly sum `MM'
			if (r(mean) > 0 & r(mean) ~= .) {
				display as error "`strata' varies within `groupvar'.  Strata should not vary within treatment groupings."
				display " "
				local error = 1
				}
			quietly drop `M' `MM'
			}
		}
	if (`error' == 1) exit
	if ("`groupvar'" ~= "") {
		quietly egen `M' = group(`groupvar')
		quietly sum `M'
		if (r(N) ~= _N) {
			display as error "`groupvar' is missing for some observations.  Randcmd will treat missing values as one randomization group."
			display " "
			}	
		quietly drop `M'
		}
	if ("`strata'" ~= "") {
		quietly egen `M' = group(`strata')
		quietly sum `M'
		if (r(N) ~= _N) {
			display as error "`strata' is missing for some observations.  Randcmd will treat missing values as one strata."
			display " "
			}	
		quietly drop `M'
		}

*Displaying treatment variables so that user can confirm that programme has correctly identified treatment variables and interaction equations
	display as text "Treatment variables determined directly by randomization: `treatvars'.", _newline
	display "Post-randomization treatment based calculations:  `calc'."
	forvalues k = 1/`calc' {
		display "  `k':   `calc`k''"
		}
	display " "
	forvalues k = 1/`eqn' {
		display "Treatment based variables tested in equation `k': `treat`k''."
		if  ("`treat`k''" == "") {
			display as error "No treatment variables in equation `k'."
			local error = 1
			}
		}
	if (`error' == 1) exit
	display " "

*Preparing variables and matrices to be used in randomization analysis
	set seed `seed'
	if ("`groupvar'" ~= "") {
		egen `M' = group(`groupvar'), missing
		quietly sum `M'
		local N = r(max)
		quietly bysort `M': gen `n' = _n
		sort `n' `strata' `M'
		quietly generate `Order' = _n
		}
	if ("`groupvar'" == "") {
		local N = _N
		quietly generate `Order' = _n	
		sort `strata' `Order'
		}
	quietly generate double `U' = .

	mata `list' = J(1,0,"")
	foreach var in `treatvars' {
		mata `list' = `list', "`var'"
		}
	mata `T' = st_data((1,`N'),`list'); `ResB' = J(`reps',`treatnumber',.); `ResSE' = J(`reps',`treatnumber',.); `ResF' = J(`reps',`eqn',.)

display " "
display "Running `reps' randomization iterations:"

*Randomization iterations
	forvalues count = 1/`reps' {
		if (ceil(`count'/10)*10 == `count') display "`count'", _continue

*Randomizing direct treatment and recalculating treatment based variables
		if ("`groupvar'" == "") {
			quietly sort `strata' `Order'
			quietly replace `U' = uniform()
			quietly sort `strata' `U'	
			mata st_store(.,`list',`T')
			}
		if ("`groupvar'" ~= "") {
			quietly sort `n' `strata' `Order'  
			quietly replace `U' = uniform() if _n <= `N'
			quietly sort `strata' `U' in 1/`N'
			mata st_store((1,`N'),`list',`T')
			quietly sort `M' `n'
			foreach var in `treatvars' {
				quietly replace `var' = `var'[_n-1] if `n' > 1
				}
			}						
		forvalues k = 1/`calc' {
			quietly `calc`k''
			}

*Estimating equations
		matrix `bb' = J(`treatnumber',2,.)
		matrix `ff' = J(`eqn',1,.)
		forvalues k = 1/`eqn' {
			local tempseed = "`c(seed)'"
			capture `eqn`k''
			set seed `tempseed'
			if (_rc == 0) {
				local c = `info'[`k',1]
				foreach var in `treat`k'' {
					capture matrix `bb'[`c',1] = _b[`var'], _se[`var']
					local c = `c' + 1
					}
				capture test `test`k''
				if (_rc == 0 & r(drop) == 0 & r(df) == `f`k'') capture matrix `ff'[`k',1] = `ftype`k''
				}
			}
		mata `bb' = st_matrix("`bb'"); `ff' = st_matrix("`ff'"); `ResB'[`count',1...] = `bb'[1...,1]'; `ResSE'[`count',1...] = `bb'[1...,2]'; `ResF'[`count',1...] = `ff'[1...,1]'
		}

display, _newline

*Calculating p-values
	mata `b' = st_matrix("`b'"); `f' = st_matrix("`f'"); `ResCoef' = J(`treatnumber',6,.); `ResEqn' = J(`eqn'+1,6,.); `ResMult' = J(`eqn'+1,6,.)
*Coefficients
	forvalues c = 1/`treatnumber' {
		mata `bb' = (`ResB'[1...,`c']:~=.); `bb' = `bb':*(`ResSE'[1...,`c']:~=.); `bb' = `bb':*(`ResSE'[1...,`c']:~=0)
		mata `ff' = select(`ResB'[1...,`c'],`bb'); `ff' = (abs(`ff'):>abs(`b'[`c',1])*1.000001), (abs(`ff'):>abs(`b'[`c',1])*.999999); `ff' = colsum(`ff'), rows(`ff')
		mata `ResCoef'[`c',1..3] = `ff'[1,1]/(`ff'[1,3]+1), (`ff'[1,2]+1)/(`ff'[1,3]+1), `ff'[1,3]
		mata `ff' = select(`ResB'[1...,`c']:/`ResSE'[1...,`c'],`bb'); `ff' = (abs(`ff'):>abs(`b'[`c',1]/`b'[`c',2])*1.000001), (abs(`ff'):>abs(`b'[`c',1]/`b'[`c',2])*.999999); `ff' = colsum(`ff'), rows(`ff')
		mata `ResCoef'[`c',4..6] = `ff'[1,1]/(`ff'[1,3]+1), (`ff'[1,2]+1)/(`ff'[1,3]+1), `ff'[1,3]
		}
*Joint tests
	forvalues e = 1/`eqn' {
		if (wordcount("`treat`e''") > 1) {
			mata `bb' = (`ResF'[1...,`e']:~=.)
			local a1 = `info'[`e',1]
			local a2 = `info'[`e',2]
			forvalues c = `a1'/`a2' {
				mata `bb' = `bb':*(`ResB'[1...,`c']:~=.); `bb' = `bb':*(`ResSE'[1...,`c']:~=.); `bb' = `bb':*(`ResSE'[1...,`c']:~=0)
				}
			mata `ff' = select(`ResB'[1...,`a1'..`a2'],`bb'); `cov' = `ff':-mean(`ff'); `cov' = `cov''*`cov'/rows(`cov'); `cov' = invsym(`cov')
			mata `ff' = rowsum(`ff'*`cov':*`ff'); `fff' = `b'[`a1'..`a2',1]'*`cov'*`b'[`a1'..`a2',1]
			mata `ff' = (`ff':>`fff'*1.000001), (`ff':>`fff'*.999999); `ff' = colsum(`ff'), rows(`ff')
			mata `ResEqn'[`e',1..3] = `ff'[1,1]/(`ff'[1,3]+1), (`ff'[1,2]+1)/(`ff'[1,3]+1), `ff'[1,3]
			mata `ff' = select(`ResF'[1...,`e'],`bb'); `ff' = (`ff':>`f'[`e',1]*1.000001), (`ff':>`f'[`e',1]*.999999); `ff' = colsum(`ff'), rows(`ff')
			mata `ResEqn'[`e',4..6] = `ff'[1,1]/(`ff'[1,3]+1), (`ff'[1,2]+1)/(`ff'[1,3]+1), `ff'[1,3]
			}
		}
	if (`treatnumber' > 1 & `eqn' > 1) {
		mata `bb' = J(`reps',1,1)
		forvalues c = 1/`treatnumber' {
			mata `bb' = `bb':*(`ResB'[1...,`c']:~=.); `bb' = `bb':*(`ResSE'[1...,`c']:~=.); `bb' = `bb':*(`ResSE'[1...,`c']:~=0)
			}
		mata `ff' = select(`ResB',`bb'); `cov' = `ff':-mean(`ff'); `cov' = `cov''*`cov'/rows(`cov'); `cov' = invsym(`cov')
		mata `ff' = rowsum(`ff'*`cov':*`ff'); `fff' = `b'[1...,1]'*`cov'*`b'[1...,1]
		mata `ff' = (`ff':>`fff'*1.000001), (`ff':>`fff'*.999999); `ff' = colsum(`ff'), rows(`ff')
		mata `ResEqn'[`eqn'+1,1..3] = `ff'[1,1]/(`ff'[1,3]+1), (`ff'[1,2]+1)/(`ff'[1,3]+1), `ff'[1,3]
		}

	mata `bb' = uniform(rows(`ResCoef'),1); `ResCoef' = `ResCoef'[1...,1..2], `ResCoef'[1...,1]+`bb':*(`ResCoef'[1...,2]-`ResCoef'[1...,1]), `ResCoef'[1...,4..5], `ResCoef'[1...,4]+`bb':*(`ResCoef'[1...,5]-`ResCoef'[1...,4]), `ResCoef'[1...,6]
	mata `bb' = uniform(rows(`ResEqn'),1); `ResEqn' = `ResEqn'[1...,1..2], `ResEqn'[1...,1]+`bb':*(`ResEqn'[1...,2]-`ResEqn'[1...,1]), `ResEqn'[1...,4..5], `ResEqn'[1...,4]+`bb':*(`ResEqn'[1...,5]-`ResEqn'[1...,4]), `ResEqn'[1...,3]
	mata st_matrix("`ResCoef'",`ResCoef'); st_matrix("`ResEqn'",`ResEqn') 

*Multiple testing for regressions - Westfall/Young
	forvalues e = 1/`eqn' {
		if (wordcount("`treat`e''") > 1) {		
			drop _all
			quietly set obs `reps'
			local a1 = `info'[`e',1]
			local a2 = `info'[`e',2]
			forvalues c = `a1'/`a2' {
				quietly generate double c`c' = .
				quietly generate double t`c' = .
				}
			aorder
			mata st_store(.,.,(`ResB'[1...,`a1'..`a2'],`ResSE'[1...,`a1'..`a2']))
			local rep1 = `reps' + 1
			quietly set obs `rep1'
			forvalues c = `a1'/`a2' {
				quietly replace c`c' = `b'[`c',1] if _n == `rep1'
				quietly replace t`c' = `b'[`c',2] if _n == `rep1'
				}
			quietly generate Order = _n
			forvalues c = `a1'/`a2' {
				quietly replace t`c' = abs(c`c'/t`c')
				quietly replace c`c' = abs(c`c')
				quietly drop if (c`c' == . | t`c' == . )
				}
			quietly generate double ptmin = .
			quietly generate double pcmin = .
			forvalues c = `a1'/`a2' {
				quietly gsort -t`c' Order
				quietly generate I = (t`c' < t`c'[_n-1]*.99999999)
				quietly generate T`c' = 1 if _n == 1
				quietly replace T`c' = T`c'[_n-1] + I if _n > 1
				quietly gsort T`c' -I Order
				by T`c': egen count = count(T`c')
				quietly generate double cumcount = count if _n == 1
				quietly replace cumcount = cumcount[_n-1] + I*count if _n > 1
				quietly replace count = count/_N
				quietly replace cumcount = cumcount/_N
				quietly generate double pt`c' = cumcount - count*uniform()
				capture drop I count cumcount T`c'
		
				quietly gsort -c`c' Order
				quietly generate I = (c`c' < c`c'[_n-1]*.99999999)
				quietly generate C`c' = 1 if _n == 1
				quietly replace C`c' = C`c'[_n-1] + I if _n > 1
				quietly gsort C`c' -I Order
				by C`c': egen count = count(C`c')
				quietly generate double cumcount = count if _n == 1
				quietly replace cumcount = cumcount[_n-1] + I*count if _n > 1
				quietly replace count = count/_N
				quietly replace cumcount = cumcount/_N
				quietly generate double pc`c' = cumcount - count*uniform()
				capture drop I count cumcount C`c'
	
				quietly replace ptmin = min(ptmin,pt`c')
				quietly replace pcmin = min(pcmin,pc`c')
				}
			local NN = _N
			quietly sort Order
			quietly sum pcmin if pcmin < .999999*pcmin[_N]
			mata `ResMult'[`e',1] = `r(N)'/`NN'
			quietly sum pcmin if pcmin < 1.000001*pcmin[_N]
			mata `ResMult'[`e',2] = `r(N)'/`NN'
			quietly sum ptmin if ptmin < .999999*ptmin[_N]
			mata `ResMult'[`e',4] = `r(N)'/`NN'
			quietly sum ptmin if ptmin < 1.000001*ptmin[_N]
			mata `ResMult'[`e',5] = `r(N)'/`NN'
			mata `ResMult'[`e',6] = `NN' - 1
			}
		}

*Ombnibus Multiple Test - Westfall/Young
	if (`treatnumber' > 1 & `eqn' > 1) {
		drop _all
		quietly set obs `reps'
		forvalues i = 1/`treatnumber' {
			quietly generate double c`i' = .
			quietly generate double t`i' = .
			}
		aorder
		mata st_store(.,.,(`ResB',`ResSE'))
		local rep1 = `reps' + 1
		quietly set obs `rep1'
		forvalues i = 1/`treatnumber' {
			quietly replace c`i' = `b'[`i',1] if _n == `rep1'
			quietly replace t`i' = `b'[`i',2] if _n == `rep1'
			}
		quietly generate Order = _n
		forvalues i = 1/`treatnumber' {
			quietly replace t`i' = abs(c`i'/t`i')
			quietly replace c`i' = abs(c`i')
			quietly drop if (c`i' == . | t`i' == . )
			}
		quietly generate double ptmin = .
		quietly generate double pcmin = .
		forvalues i = 1/`treatnumber' {
			quietly gsort -t`i' Order
			quietly generate I = (t`i' < t`i'[_n-1]*.99999999)
			quietly generate T`i' = 1 if _n == 1
			quietly replace T`i' = T`i'[_n-1] + I if _n > 1
			quietly gsort T`i' -I Order
			by T`i': egen count = count(T`i')
			quietly generate double cumcount = count if _n == 1
			quietly replace cumcount = cumcount[_n-1] + I*count if _n > 1
			quietly replace count = count/_N
			quietly replace cumcount = cumcount/_N
			quietly generate double pt`i' = cumcount - count*uniform()
			capture drop I count cumcount T`i'
			
			quietly gsort -c`i' Order
			quietly generate I = (c`i' < c`i'[_n-1]*.99999999)
			quietly generate C`i' = 1 if _n == 1
			quietly replace C`i' = C`i'[_n-1] + I if _n > 1
			quietly gsort C`i' -I Order
			by C`i': egen count = count(C`i')
			quietly generate double cumcount = count if _n == 1
			quietly replace cumcount = cumcount[_n-1] + I*count if _n > 1
			quietly replace count = count/_N
			quietly replace cumcount = cumcount/_N
			quietly generate double pc`i' = cumcount - count*uniform()
			capture drop I count cumcount C`i'
	
			quietly replace ptmin = min(ptmin,pt`i')
			quietly replace pcmin = min(pcmin,pc`i')
			}
		local NN = _N
		quietly sort Order
		quietly sum pcmin if pcmin < .999999*pcmin[_N]
		mata `ResMult'[`eqn'+1,1] = `r(N)'/`NN'
		quietly sum pcmin if pcmin < 1.000001*pcmin[_N]
		mata `ResMult'[`eqn'+1,2] = `r(N)'/`NN'
		quietly sum ptmin if ptmin < .999999*ptmin[_N]
		mata `ResMult'[`eqn'+1,4] = `r(N)'/`NN'
		quietly sum ptmin if ptmin < 1.000001*ptmin[_N]
		mata `ResMult'[`eqn'+1,5] = `r(N)'/`NN'
		mata `ResMult'[`eqn'+1,6] = `NN' - 1
		}

	mata `bb' = uniform(rows(`ResMult'),1); `ResMult' = `ResMult'[1...,1..2], `ResMult'[1...,1]+`bb':*(`ResMult'[1...,2]-`ResMult'[1...,1]), `ResMult'[1...,4..5], `ResMult'[1...,4]+`bb':*(`ResMult'[1...,5]-`ResMult'[1...,4]), `ResMult'[1...,6]; st_matrix("`ResMult'",`ResMult') 


*Displaying results
local length = `length' + 3 + (`eqn' > 9)
local length = max(`length',9)
local a1 = `length' + 6
forvalues k = 2/7 {
	local a`k' = `a1' + 13*(`k'-1)
	}
local aa1 = `a1' - 4
local aa2 = floor(`length'/2)-1
local aa3 = `a2' - 3
local aa5 = `a5' - 3

display as text " "
display "Randomization p-values for individual coefficients:", _newline
display as text _col(`aa3') %15s  "randomization-c" _col(`aa5') "randomization-t" 
display as text _col(`aa2') %8s "equation:" _col(`a1') %8s "minimum" _col(`a2') %8s "maximum" _col(`a3') %10s "randomized" _col(`a4') %8s "minimum" _col(`a5') %8s "maximum" _col(`a6') %10s "randomized" _col(`a7') %10s "successful"
display as text _col(`aa2') %8s "variable" _col(`a1') %8s "p-value" _col(`a2') %8s "p_value" _col(`a3') %8s "p-value" _col(`a4') %8s "p-value" _col(`a5') %8s "p-value" _col(`a6') %8s "p-value" _col(`a7') %10s "iterations"
display as text "{hline `aa1'}{c +}{hline 90}"
	local i = 0
	forvalues e = 1/`eqn' {
		foreach var in `treat`e'' {
			local i = `i' + 1
			display as text _col(2) %-`length's "`e': `var'" _col(`aa1') " {c |}" , _continue
			display as result _col(`a1') %7.6g `ResCoef'[`i',1] _col(`a2') %7.6g `ResCoef'[`i',2] _col(`a3') %7.6g `ResCoef'[`i',3] _col(`a4') %7.6g `ResCoef'[`i',4] _col(`a5') %7.6g `ResCoef'[`i',5] _col(`a6') %7.6g `ResCoef'[`i',6] _col(`a7') %7.6g `ResCoef'[`i',7]  
			}
		}
display as text "{hline `aa1'}{c BT}{hline 90}", _newline

if (`treatnumber' > 1) {
	display " "
	display "Randomization p-values for joint tests of treatment significance:", _newline
	display as text _col(24) %15s  "randomization-c" _col(63) "randomization-t" 
	display as text _col(14) %8s "minimum" _col(27) %8s "maximum" _col(39) %10s "randomized" _col(53) %8s "minimum" _col(66) %8s "maximum" _col(78) %7s "randomized" _col(93) %10s "successful"
	display as text _col(2) %8s "equation" _col(14) %8s "p-value" _col(27) %8s "p_value" _col(41) %7s "p-value" _col(53) %8s "p-value" _col(66) %8s "p-value" _col(80) %7s "p-value" _col(93) %10s "iterations"
	display as text "{hline 9}{c +}{hline 92}"
		forvalues e = 1/`eqn' {
			if (wordcount("`treat`e''") > 1) {
				display as text _col(5) %-12s `e' _col(10) "{c |}" , _continue
				display as result _col(14) %7.6g `ResEqn'[`e',1] _col(27) %7.6g `ResEqn'[`e',2] _col(40) %7.6g `ResEqn'[`e',3] _col(53) %7.6g `ResEqn'[`e',4] _col(66) %7.6g `ResEqn'[`e',5] _col(79) %7.6g `ResEqn'[`e',6] _col(93) %7.6g `ResEqn'[`e',7]  
				}
			}
	if (`eqn' > 1) {
		display as text _col(4) %-6s "all" _col(3) "{c |}" , _continue
		display as result _col(14) %7.6g `ResEqn'[`eqn'+1,1] _col(27) %7.6g `ResEqn'[`eqn'+1,2] _col(40) %7.6g `ResEqn'[`eqn'+1,3] "    randcmd does not calculate a t-version"  _col(93) %7.6g `ResEqn'[`eqn'+1,7]  
		}
	display as text "{hline 9}{c BT}{hline 92}", _newline
	}

if (`treatnumber' > 1) {
	display " "
	display "Randomization p-value for Westfall-Young multiple testing of treatment significance:", _newline
	display as text _col(24) %15s  "randomization-c" _col(63) "randomization-t" 
	display as text _col(14) %8s "minimum" _col(27) %8s "maximum" _col(39) %10s "randomized" _col(53) %8s "minimum" _col(66) %8s "maximum" _col(78) %7s "randomized" _col(93) %10s "successful"
	display as text _col(2) %8s "equation" _col(14) %8s "p-value" _col(27) %8s "p_value" _col(41) %7s "p-value" _col(53) %8s "p-value" _col(66) %8s "p-value" _col(80) %7s "p-value" _col(93) %10s "iterations"
	display as text "{hline 9}{c +}{hline 92}"
		forvalues e = 1/`eqn' {
			if (wordcount("`treat`e''") > 1) {
				display as text _col(5) %-12s `e' _col(10) "{c |}" , _continue
				display as result _col(14) %7.6g `ResMult'[`e',1] _col(27) %7.6g `ResMult'[`e',2] _col(40) %7.6g `ResMult'[`e',3] _col(53) %7.6g `ResMult'[`e',4] _col(66) %7.6g `ResMult'[`e',5] _col(79) %7.6g `ResMult'[`e',6] _col(93) %7.6g `ResMult'[`e',7]  
				}
			}
	if (`eqn' > 1) {
		display as text _col(4) %-6s "all" _col(3) "{c |}" , _continue
		display as result _col(14) %7.6g `ResMult'[`eqn'+1,1] _col(27) %7.6g `ResMult'[`eqn'+1,2] _col(40) %7.6g `ResMult'[`eqn'+1,3] _col(53) %7.6g `ResMult'[`eqn'+1,4] _col(66) %7.6g `ResMult'[`eqn'+1,5] _col(79) %7.6g `ResMult'[`eqn'+1,6] _col(93) %7.6g `ResMult'[`eqn'+1,7]  
		}
	display as text "{hline 9}{c BT}{hline 92}", _newline
	}

*ereturn matrices
matrix colnames `ResCoef' = "min-c pvalue" "max-c pvalue" "rand-c pvalue" "min-t pvalue" "max-t pvalue" "rand-t pvalue" "iterations"
matrix colnames `ResEqn' = "min-c pvalue" "max-c pvalue" "rand-c pvalue" "min-t pvalue" "max-t pvalue" "rand-t pvalue" "iterations"
matrix colnames `ResMult' = "min-c pvalue" "max-c pvalue" "rand-c pvalue" "min-t pvalue" "max-t pvalue" "rand-t pvalue" "iterations"
local list2 = ""
forvalues e = 1/`eqn' {
	foreach var in `treat`e'' {
		local list2 = "`list2'" + " `e':`var' "
		}
	}
matrix rownames `ResCoef' = `list2'
local list2 = ""
forvalues e = 1/`eqn' {
	local list2 = "`list2'" + " equation:`e' "
	}
local list2 = "`list2'" + " all"
matrix rownames `ResEqn' = `list2'
matrix rownames `ResMult' = `list2'

ereturn matrix RCoef = `ResCoef', copy
ereturn matrix REqn = `ResEqn', copy
ereturn matrix RMult = `ResMult', copy

set seed `oldseed'

*Saving, if user requested
if ("`saving'" ~= "") {
	quietly drop _all
	quietly set obs `reps'
	forvalues k = 1/`treatnumber' {
		quietly generate double ResB`k' = .
		}
	forvalues k = 1/`treatnumber' {
		quietly generate double ResSE`k' = .
		}
	forvalues k = 1/`eqn' {
		quietly generate double ResF`k' = .
		}
	mata st_store(.,.,(`ResB', `ResSE', `ResF'))
	save `saving'
	}

foreach object in b bb f ff fff info T ResB ResSE ResF ResCoef ResEqn ResMult cov list {
	capture mata mata drop ``object''
	}

restore

end

