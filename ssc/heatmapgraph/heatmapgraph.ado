***************************
**   Maximo Sangiacomo   **
** Sep 2018. Version 1.0 **
***************************
program define heatmapgraph
version 13
syntax anything(name=fileinfo id="Info file name") [if] [in], /// 
infoid(str) category(str) component(str) turnon(integer) winsize(passthru) RESults(str) MAWin(integer) /// 
[ save(str) exclude(varlist) include(passthru) infopath(passthru) indexname(str)  /// 
GRAPHSeries LABELS noSTAGE1 catxcoord(real .25)]

qui {
tempfile `save'1 b_event b_mean b_`component' b_`category' b_index b_hm_mean b_hm_mean_graph b_rank b_correlation
local fileseries "`c(filename)'"
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
tempvar id pos
local tvar `r(timevar)'
local frequency `r(unit1)'
if ("`frequency'"=="y"|"`frequency'"==".") {
	local frequency y
	local ftvar y
}
else {
	local ftvar = substr("`r(tsfmt)'",2,2)
}
if `turnon' < 1 {
	noisily disp in r "{bf:turnon(#)} should be an integer equal or greather than 1"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
if `mawin' < 2 {
	noisily disp in r "{bf:mawin(#)} should be an integer equal or greather than 2"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
else {
local `mawin' = `mawin' - 1
}
local fileinfo1: subinstr local fileinfo ".dta" "", count(local infock) all
if `infock'==0 {
	local idta .dta
	local fileinfo: list fileinfo | idta
	local fileinfo: subinstr local fileinfo " " "", all
}

if "`save'"!="" {
	local save1: subinstr local save ".dta" "", count(local saveck) all
	if `saveck'==0 {
		local sdta .dta
		local save: list save | sdta
		local save: subinstr local save " " "", all
		local filesck : list fileseries == save
		if `filesck'==1 {
			noisily disp in red "Option {bf:save(`save')} has the same file name of master database"
			use `fileseries', clear
			tset `tvar'
			exit 198
		}
	}
}
local resultsw `results'.docx
local resultse `results'.xlsx
local resultsg `results'.png
if "`r(timevar)'"=="" {
	noisily disp in red "No TIME variable defined: Please use {it:{help tset}} before {bf:heatmapgraph} command"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
if "`frequency'"=="m" {
	local smhp = 14400
	local tdist = 6
}
else if "`frequency'"=="q" {
	local smhp = 1600
	local tdist = 2
}
else if "`frequency'"=="y" {
	local smhp = 100
	local tdist = 1
}
else {
	noisily disp in red "{bf:frequency} could be one of the following possibilities:"
	noisily disp in red "{bf} m: monthly"
	noisily disp in red "{bf} q: quarterly"
	noisily disp in red "{bf} y: yearly" 
	use `fileseries', clear
	tset `tvar'
	exit 198
}
local winsize: subinstr local winsize "winsize(" "", all
local winsize: subinstr local winsize ")" "", all
local winsize: subinstr local winsize "," " ", all
local nwindows1: word count `winsize'
if mod(`nwindows1', 2) != 0 {
	noisily disp in red `"winsize(`winsize') should have an even number of windows"'
	use `fileseries', clear
	tset `tvar'
	exit 198
}
else {
	local nwindows = `nwindows1'/2
}
local winsize1: subinstr local winsize "m" "", count(local mck) all
local winsize1: subinstr local winsize "q" "", count(local qck) all

if (`mck'!=`nwindows1'&"`ftvar'"=="tm") {
	noisily di in red "{bf:`winsize'} reference format should be monthly (i.e. 2018m9)"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
if (`qck'!=`nwindows1'&"`ftvar'"=="tq") {
	noisily di in red "{bf:`winsize'} reference format should be quarterly (i.e. 2018q3)"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
if "`frequency'"=="y" {
	foreach num of numlist 1/`nwindows' {
		capture disp y(`c`num'min') 
		if _rc {
			noisily disp in red "{bf:`winsize'} reference format should be yearly (i.e. 2018)"
			use `fileseries', clear
			tset `tvar'
			exit 198
		}
		else {
			capture disp y(`c`num'max') 
			if _rc {
				noisily disp in red "{bf:`winsize'} reference format should be yearly (i.e. 2018)"
				use `fileseries', clear
				tset `tvar'
				exit 198
			}
			else {
				continue
			}
		}
	}
}
tokenize "`winsize'"
local j = 1
foreach num of numlist 1/`nwindows' {
	local c`num'min ``j''
	local j = `j' + 1
	local c`num'max ``j''
	local j = `j' + 1
}
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
local per_nwindows = 0
foreach num of numlist 1/`nwindows' {
	local t`num'min: disp `ftvar'(`c`num'min')
	local t`num'max: disp `ftvar'(`c`num'max')
	local t`num'ck = `t`num'max' - `t`num'min'
	if `t`num'ck' < 0 {
		noisily  disp in r "Window size `c`num'min' - `c`num'max' confilct"
		use `fileseries', clear
		tset `tvar'
		exit 198
	}
	else {
		local per_nwindows = `per_nwindows' + `t`num'max' - `t`num'min' + 1
	}
}
local ntos = (2/3)*`per_nwindows'
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
local include: subinstr local include "include(" "", all
local include: subinstr local include ")" "", all
if ("`if'"!=""&"`in'"!="") {
	noisily disp in r "`if' and `in' options could not be simultaneously specified"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
if ( "`save'"==""&"`labels'"!="") {
	noisily disp in r "Warring: as {bf:save()} was not specified, {bf:`labels'} would no work."
}
if ( "`save'"==""&("`if'"!=""|"`in'"!="")) {
	noisily disp in r "Warring: as {bf:save()} was not specified, {bf:conditional if/in} would no work."
}
local u1 = .5
local u2 = .7
local u3 = .9
if "`indexname'"=="" {
	local indexname Index
}
if "`infopath'"!="" {
	local infopath: subinstr local infopath "infopath(" "", all
	local infopath: subinstr local infopath ")" "", all
	local infopath1 = substr("`infopath'", length("`infopath'"),1)
	if "`infopath1'"!="\" {
		local infopath "`infopath'\"
	}
	local fileinfo : list infopath | fileinfo
	local fileinfo: subinstr local fileinfo " " "", all
}
***********************************************************************
***********************************************************************
use `fileinfo', clear
capture confirm var `infoid', exact
if _rc {
	noisily disp in r "Var {bf:`infoid'} not found in `fileinfo'"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
else {
	order `infoid'
	ds
	local listu `r(varlist)'
	gettoken listf list: listu
	local list: subinstr local list "_" " ", all
	local n2w: list posof "2w" in list
	local n1w: list posof "1w" in list
	local ni: list posof "i" in list
	if `n2w'==0&`n1w'>0&`ni'==0 {
		ds *_1w 
		local ilist `r(varlist)'
		ds *_1w
		local var_1w `r(varlist)'
		local var_1wsh: subinstr local var_1w "_1w" "", all
		rename *_1w *
	}
	else if `n2w'==0&`n1w'==0&`ni'>0 {
		ds *_i
		local ilist `r(varlist)'
		ds *_i
		local var_i `r(varlist)'
		local var_ish: subinstr local var_i "_i" "", all
		rename *_i *
	}
	else if `n2w'>0&`n1w'==0&`ni'==0 {
		ds *_2w 
		local ilist `r(varlist)'
		ds *_2w
		local var_2w `r(varlist)'
		local var_2wsh: subinstr local var_2w "_2w" "", all
		rename *_2w *
	}
	else if `n2w'==0&`n1w'>0&`ni'>0 {
		ds *_1w *_i
		local ilist `r(varlist)'
		ds *_1w
		local var_1w `r(varlist)'
		local var_1wsh: subinstr local var_1w "_1w" "", all
		ds *_i
		local var_i `r(varlist)'
		local var_ish: subinstr local var_i "_i" "", all
		rename *_1w *
		rename *_i *
	}
	else if `n2w'>0&`n1w'==0&`ni'>0 {
		ds *_2w *_i
		local ilist `r(varlist)'
		ds *_2w
		local var_2w `r(varlist)'
		local var_2wsh: subinstr local var_2w "_2w" "", all
		ds *_i
		local var_i `r(varlist)'
		local var_ish: subinstr local var_i "_i" "", all
		rename *_i *
		rename *_2w *
	}
	else if `n2w'>0&`n1w'>0&`ni'==0 {
		ds *_2w *_1w
		local ilist `r(varlist)'
		ds *_2w
		local var_2w `r(varlist)'
		local var_2wsh: subinstr local var_2w "_2w" "", all
		ds *_1w
		local var_1w `r(varlist)'
		local var_1wsh: subinstr local var_1w "_1w" "", all
		rename *_1w *
		rename *_2w *
	}
	else if `n2w'>0&`n1w'>0&`ni'>0 {
		ds *_1w *_i *_2w
		local ilist `r(varlist)'
		ds *_1w
		local var_1w `r(varlist)'
		local var_1wsh: subinstr local var_1w "_1w" "", all
		ds *_i
		local var_i `r(varlist)'
		local var_ish: subinstr local var_i "_i" "", all
		ds *_2w
		local var_2w `r(varlist)'
		local var_2wsh: subinstr local var_2w "_2w" "", all
		rename *_1w *
		rename *_i *
		rename *_2w *
	}
	else {
		noisily disp in red "No variable classification in terms of vulnerabilities relationship (one way, inverted or two way)"
		use `fileseries', clear
		tset `tvar'
		exit 198
	}
	local ilistsh: subinstr local ilist "_i" "", all count(local nitot)
	local ilistsh: subinstr local ilistsh "_1w" "", all count(local n1wtot)
	local ilistsh: subinstr local ilistsh "_2w" "", all count(local n2wtot)
	local ntot = `n2wtot' + `n1wtot' + `nitot'
	gen `pos' = _n
	if "`labels'" != "" {
		sum `pos'
		if r(N) != 3 {
			noisily disp in r "As {bf:labels} was specified {bf:`fileinfo'} should have 3 observations"
			use `fileseries', clear
			tset `tvar'
			exit 198
		}
	}
	if ("`labels'"==""&"`save'"!="") {
		sum `pos'
		if r(N) != 2 {
			noisily disp in r "As {bf:labels} was not specified {bf:`fileinfo'} should have 2 observations"
			use `fileseries', clear
			tset `tvar'
			exit 198
		}
	}
	tab `listf'
	if r(r)==r(N) {
		local nvals = r(r)
		foreach i of numlist 1/`nvals' {
			local idval = `infoid'[`i']
			local idvals "`idvals' `idval'"
		}
		local idvals = trim("`idvals'")
		if "`labels'" != "" {
			local aux01 "`component' `category' labels"
			local fick: list idvals === aux01
			if `fick'==0 {
				noisily disp in r "Info var " in ye "`infoid' " in r "contents " in ye "`idvals' " in r "differ from " in ye "`component', `category' and labels." 
				use `fileseries', clear
				tset `tvar'
				exit 198
			}
		}
		if ("`labels'"==""&"`save'"!="") {
			local aux02 "`component' `category'"
			local fick: list idvals === aux02
			if `fick'==0 {
				noisily disp in r "Info var " in ye "`infoid' " in r "contents " in ye "`idvals' " in r "differ from " in ye "`component' and `category'." 
				use `fileseries', clear
				tset `tvar'
				exit 198
			}
		}
		foreach v of local idvals {
			sum `pos' if `listf'=="`v'"
			local p_`v' = r(mean)
		}
		foreach var of varlist `ilistsh' {
			foreach v of local idvals {
				if "`v'"=="`component'" {
					local `var'_`v' = subinstr(proper("`=`var'[`p_`v'']'")," ","",.)
				}
				else {
					local `var'_`v' "`=`var'[`p_`v'']'"
				}
			}
		}
	}
	else {
		noisily disp "{bf:`listf'} should have unique variable information criteria. Repeated values in rows"
		use `fileseries', clear
		tset `tvar'
		exit 198
	}
}
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
use `fileinfo', clear
rename * v_*
rename v_`infoid' `infoid'
reshape long v_, i(`infoid') j(var) string
reshape wide v_, i(var) j(`infoid') string
rename v_* *
egen `id'=tag(`component')
keep if `id'==1
keep `component' `category' `id'
order `id'
replace `component' = subinstr(proper(`component')," ","",.)
reshape wide `category', i(`id') j(`component') string
rename `category'* *
order `id'
ds 
local listc `r(varlist)'
gettoken listc1 comp: listc
*Map components into categories	
foreach v of local comp {
	local `v'_cat "`=`v'[1]'"
}
*****************************************************************************************************
*****************************************************************************************************
use `fileseries', clear
if "`save'"=="" {
	capture ds sthp* 
	if !_rc {
		drop *_*	
	}
	else {
		noisily disp in r "Check that {bf:`fileseries'} contains cycles, trends and standardized vars" 
		use `fileseries', clear
		tset `tvar'
		exit 198
	}
}
order `tvar'
ds
local ilist_series `r(varlist)'
gettoken ilist_series1 ilist_series: ilist_series
local ntotck: word count `ilist_series'
if `ntot'!=`ntotck' {
	noisily disp in r "Some variables in {bf:`fileinfo'} are not classified in terms of vulnerabilities relationship (one way, inverted or two way)"
	use `fileseries', clear
	tset `tvar'
	exit 198
}	
local varl_comp: list ilist_series === ilistsh
if `varl_comp'==0 {
	noisily disp in r "Varlist in {bf:`fileinfo'} and {bf:`fileseries'} do not match"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
if "`save'"!="" {
	if "`labels'" != "" {
		foreach var of varlist `ilistsh' {
			label variable `var' "``var'_labels'" 			// check labels
		}
	}
************
* TENDENCY *
************
	if ("`if'"!=""|"`in'"!="") {
		keep `if' `in'
	}
	sum `tvar'
	local obs2 = r(N)/2
	if `mawin'>=`obs2' {
		noisily disp in r "{bf:mawin(#)} should be an integer smaller than one-half the number of observations in the sample."
		use `fileseries', clear
		tset `tvar'
		exit 198
	}
* HP, HP1S y DEMEAN
	tset `tvar', `frequency'
	foreach var of varlist `ilistsh' {
		tsreport `var'
		if r(N_gaps1) > 0 {
			ipolate `var' `tvar', generate(`var'2)
			drop `var'
			rename `var'2 `var'
			label variable `var' "``var'_labels'" 			// check labels
		}
*HP
		tsfilter hp `var'_hp = `var', trend(`var'_hp_tr) smooth(`smhp')
		label var `var'_hp "Two sided cycle"
		label var `var'_hp_tr "Two sided trend"
*HP1S
		constraint drop _all
		constraint 1 [mu]l.mu = 1
		constraint 2 [mu]l.beta = 1
		constraint 3 [beta]l.beta = 1
		constraint 4 [`var']mu = 1
		scalar sl = sqrt(1 / `smhp')
		constraint 5 ([beta]e.beta) = sl*(["`var'"]e."`var'")
		capture sspace (mu l.mu l.beta , state noconstant) (beta l.beta e.beta, state noconstant) ("`var'" mu e."`var'", noconstant), covstate(identity) covobserved(identity) constraints(1/5)
		if _rc == 0 {
			predict double `var'_hp1s_tr, state smethod(filter) eq(mu)
			gen `var'_hp1s = `var' - `var'_hp1s_tr
			label var `var'_hp1s "One sided cycle"
			label var `var'_hp1s_tr "One sided trend"
		}
		else {
			gen `var'_hp1s_tr = .
			gen `var'_hp1s = .
			label var `var'_hp1s "One sided cycle"
			label var `var'_hp1s_tr "One sided trend"
		}
		
*Moving average
		tset `tvar', `frequency'
		tssmooth ma `var'_dem_tr = `var', window(`mawin' 1)
		gen `var'_dem = (`var' - `var'_dem_tr)
		label var `var'_dem "Moving average cycle"
		label var `var'_dem_tr "Moving average trend"
	}      
*Change cycle for inverted vars
	foreach var of varlist `var_ish' {
		replace `var'_hp = (-1)*`var'_hp
		replace `var'_hp1s = (-1)*`var'_hp1s 
		replace `var'_dem = (-1)*`var'_dem
	}
*Two way vars ((-1) HP discret, original continuous akdensity -see standardization-
	if `n2w'>0 {
		foreach var of varlist `var_2wsh' {
			gen `var'_hp1 = `var'_hp 
			replace `var'_hp = (-1)*`var'_hp if `var'_hp<0
			gen `var'_hp1s1 = `var'_hp1s 
			replace `var'_hp1s = (-1)*`var'_hp1s if `var'_hp1s<0
			gen `var'_dem1 = `var'_dem 
			replace `var'_dem = (-1)*`var'_dem if `var'_dem<0
		}
	}
*******************
* Standardization *
*******************
	if `n1w'>0 {
		foreach var of varlist `var_1wsh' {
			egen sd_`var' = sd(`var')
			gen sthp_`var' = `var'_hp / sd_`var'
			label var sthp_`var' "Standardized two sided HP"
			gen sthp1s_`var' = `var'_hp1s / sd_`var'
			label var sthp1s_`var' "Standardized one sided HP"
			gen stdem_`var' = `var'_dem / sd_`var'
			label var stdem_`var' "Standardized moving average"
			drop sd_`var'
		}
	}
	if `ni'>0 {
		foreach var of varlist `var_ish' {
			egen sd_`var' = sd(`var')
			gen sthp_`var' = `var'_hp / sd_`var'
			label var sthp_`var' "Standardized two sided HP"
			gen sthp1s_`var' = `var'_hp1s / sd_`var'
			label var sthp1s_`var' "Standardized one sided HP"
			gen stdem_`var' = `var'_dem / sd_`var'
			label var stdem_`var' "Standardized moving average"
			drop sd_`var'
		}
	}
	if `n2w'>0 {
		foreach var of varlist `var_2wsh' {
			egen sd_`var' = sd(`var')
			gen sthp_`var' = `var'_hp1 / sd_`var'
			label var sthp_`var' "Standardized two sided HP"
			gen sthp1s_`var' = `var'_hp1s1 / sd_`var'
			label var sthp1s_`var' "Standardized one sided HP"
			gen stdem_`var' = `var'_dem1 / sd_`var'
			label var stdem_`var' "Standardized moving average"
			drop sd_`var'
		}
	}
	save `save1', replace
	if `n2w'>0 {
		foreach var of varlist `var_2wsh' {
			drop `var'_hp1 `var'_hp1s1 `var'_dem1 
		}
	}
	save `save', replace
}
*****************************************************************************
*****************************************************************************
***********
* STAGE I *
***********
if  "`save'"=="" {
	use `fileseries', clear
}
else {
	use `save1', clear
}
sum `tvar'
local tmin = `r(min)'
local tmax = `r(max)'
foreach num of numlist 1/`nwindows' {
	if (`t`num'min'<`tmin'|`t`num'min'>`tmax') {
		noisily disp in r "Window size `c`num'min' - `c`num'max' out of range"
		use `fileseries', clear
		tset `tvar'
		exit 198
	}
	else {
		continue
	}
}
*Sigma and confidence intervals
foreach var of varlist `ilistsh' {
	gen `var'_hpsq = `var'_hp^2
	gen `var'_hp1ssq = `var'_hp1s^2
	gen `var'_demsq = `var'_dem^2
*HP
	sum `var'_hpsq
	scalar sig_hp_`var' = sqrt((1/(r(N)-1))*r(sum))
*HP1S
	sum `var'_hp1ssq
	scalar sig_hp1s_`var' = sqrt((1/(r(N)-1))*r(sum))
*DEMEAN
	sum `var'_demsq
	scalar sig_dem_`var' = sqrt((1/(r(N)-1))*r(sum))
	local j = 1
	foreach num of numlist 1/4 {
		scalar sig_hp_`var'`num' = `j'*scalar(sig_hp_`var')
		scalar sig_hp1s_`var'`num' = `j'*scalar(sig_hp1s_`var')
		scalar sig_dem_`var'`num' = `j'*scalar(sig_dem_`var')
		local j = `j' + .25
	}
*Cycle and thresholds
	foreach num of numlist 1/4 {
		gen hp`num'_`var' = cond(`var'_hp>scalar(sig_hp_`var'`num')&`var'_hp!=.,1,0)
		gen hp1s`num'_`var' = cond(`var'_hp1s>scalar(sig_hp1s_`var'`num')&`var'_hp1s!=.,1,0)
		gen dem`num'_`var' = cond(`var'_dem>scalar(sig_dem_`var'`num')&`var'_dem!=.,1,0)
		gen hm_hp`num'_`var' = cond(`var'_hp>scalar(sig_hp_`var'`num')&`var'_hp!=.,1,cond(`var'_hp<-scalar(sig_hp_`var'`num'),-1,0))
		gen hm_hp1s`num'_`var' = cond(`var'_hp1s>scalar(sig_hp1s_`var'`num')&`var'_hp1s!=.,1,cond(`var'_hp1s<-scalar(sig_hp1s_`var'`num'),-1,0))
		gen hm_dem`num'_`var' = cond(`var'_dem>scalar(sig_dem_`var'`num')&`var'_dem!=.,1,cond(`var'_dem<-scalar(sig_dem_`var'`num'),-1,0))
		replace hp`num'_`var' = . if `var'_hp==.
		replace hp1s`num'_`var' = . if `var'_hp1s==.
		replace dem`num'_`var' = . if `var'_dem==.
		replace hm_hp`num'_`var' = . if `var'_hp==.
		replace hm_hp1s`num'_`var' = . if `var'_hp1s==.
		replace hm_dem`num'_`var' = . if `var'_dem==.
	}
}
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*Check behaviour in overheating windows
gen n_window = cond(`tvar'>=`ftvar'(`c1min')&`tvar'<=`ftvar'(`c1max'),1,0)
local n_window n_window==1
if `nwindows' > 1 {
	foreach num of numlist 2/`nwindows' {
		replace n_window = cond(`tvar'>=`ftvar'(`c`num'min')&`tvar'<=`ftvar'(`c`num'max'),`num',n_window)
		local n_window `n_window'|n_window==`num'
	}
}
save `b_event', replace
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
keep `tvar' n_window hp* hp1s* dem*
*Implement stage I
if "`stage1'" == "" {
	collapse (sum) hp* dem*, by(n_window)
	drop if n_window==0
	rename * v*
	rename vn_window n_window
	reshape long v, i(n_window) j(var) string
* Screening overheating signals
	drop if v < `turnon' 
	preserve
	rename v turn_on_times
	export excel using `resultse', sheet("Stage1") firstrow(var) sheetreplace
	restore
	reshape wide v, i(n_window) j(var) string
	rename v* *
	drop n_window
	ds
	local varselect1 `r(varlist)'
}
else {
	drop `tvar' n_window
	ds 
	local varselect1 `r(varlist)'
} 
* Include / exclude
if "`exclude'" != "" {
	local nexc : word count `exclude'
	tokenize `exclude'
	foreach num of numlist 1/`nexc' {
		ds *_``num''
		local vs`num' `r(varlist)'
		local varselect1: list varselect1 - vs`num'
	}
}
if "`include'" != "" {
	local varselect1: list varselect1 | include
}
*****************************************************************************
*****************************************************************************
************
* STAGE II *
************
*Loss function 
set matsize 5000
use `b_event', clear
scalar u1 = `u1'
scalar u2 = `u2'
scalar u3 = `u3'
local nvars : word count `varselect1'
mat mst2 = J(`nvars',4,.)
mat rownames mst2 = `varselect1'
local i = 1
foreach var of varlist `varselect1' {
	gen event = cond((`n_window')&`var'==1,1,cond((`n_window')&`var'==0,0,.))
	gen no_event = cond((n_window==0)&`var'==0,1,cond((n_window==0)&`var'==1,0,.))
	count if event==1
	scalar a = r(N)
	count if event==0
	scalar c = r(N)
	count if no_event==0
	scalar b = r(N)
	count if no_event==1
	scalar d = r(N)
	scalar p = (scalar(a)+scalar(c)) / (scalar(a)+scalar(b)+scalar(c)+scalar(d))
	scalar t1 = scalar(c) / (scalar(a)+scalar(c))
	scalar t2 = scalar(b) / (scalar(b)+scalar(d))
	scalar s = scalar(a) / (scalar(a)+scalar(c))
	foreach num of numlist 1/3 {
		scalar l`num'`var' = scalar(u`num')*scalar(p)*scalar(t1) + (1-scalar(u`num'))*(1-scalar(p))*scalar(t2)
	}
	if scalar(a)>=`ntos' {
		scalar l4`var' = scalar(t2) / scalar(s)
	}
	else {
		scalar l4`var' = .
	}
	mat mst2[`i',1] = scalar(l1`var') 
	mat mst2[`i',2] = scalar(l2`var') 
	mat mst2[`i',3] = scalar(l3`var') 
	mat mst2[`i',4] = scalar(l4`var') 
	drop event no_event
	local ++i
}
svmat2 mst2, rnames(id_method)
keep id_method mst21 mst22 mst23 mst24
order id_method mst21 mst22 mst23 mst24
drop if id_method==""
egen id_var = ends(id_method), punct("_") tail
foreach num of numlist 1/4 {
	bys id_var: egen mst2`num'_min = min(mst2`num')
	gen d`num' = cond(mst2`num'_min==mst2`num',1,0)
}
replace d4=. if mst24_min==.
egen number_models=rowtotal(d1 d2 d3 d4)
drop mst21_min mst22_min mst23_min mst24_min
bys id_var: egen id_sum_max = max(number_models)
gen id_fin = cond(id_sum_max==number_models,1,0)
keep if id_fin==1
drop id_sum_max d1 d2 d3 d4
foreach num of numlist 1/4 {
	rename mst2`num' model`num'
}
egen loss_mean = rowmean(model1 model2 model3)
sort id_var loss_mean
order id_method model1 model2 model3 model4 loss_mean number_models
preserve 
keep id_method id_var model1 model2 model3 model4 loss_mean number_models
order id_method id_var model1 model2 model3 model4 loss_mean number_models
export excel using `resultse', sheet("Stage2") firstrow(var) sheetreplace
restore
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
****************
* STAGE II END *
****************
*For each var chooses the method with smallest loss function 
sort loss_mean id_var
egen id = tag(id_var)
keep if id==1
gen rank = _n
preserve
keep id_method id_var model1 model2 model3 model4 loss_mean number_models rank
order id_method id_var model1 model2 model3 model4 loss_mean number_models rank
export excel using `resultse', sheet("Stage2end") firstrow(var) sheetreplace
keep id_var rank
save `b_rank', replace
restore
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
keep id_method id id_fin
reshape wide id, i(id_fin) j(id_method) string
rename id* *
drop _fin
rename * hm_*
ds
local method `r(varlist)'
*****************************************************************************************************
*****************************************************************************************************
**********************************
* STAGE III - Correlation matrix *
**********************************
*Identify relevant var cycles
use `b_event', clear
keep `tvar' `method'
reshape long hm_, i(`tvar') j(var2) string
egen var = ends(var2), punct("_") tail
egen head1 = ends(var2), punct("_") head
gen head=substr(head1,1,length(head1)-1)
egen v1=concat(var head),  punct("_")
egen id=tag(v1)
keep if id==1
keep v1 id
gen id2 = 1
reshape wide id, i(id2) j(v1) string
drop id2
rename id* *
ds
local cycle `r(varlist)'
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*Correlation calculation
use `b_event', clear
matpwcorr `cycle', gen
keep var1 var2 corr 
save `b_correlation', replace
egen id_var = ends(var1), punct("_") head
merge m:1 id_var using `b_rank', keep(match master) nogen norep
rename rank var1_rank
drop id_var 
egen id_var = ends(var2), punct("_") head
merge m:1 id_var using `b_rank', keep(match master) nogen norep
rename rank var2_rank
drop id_var 
gen diff_rank = var1_rank - var2_rank
gsort -corr
export excel using `resultse', sheet("correlation") firstrow(var) sheetreplace
****************************************************************************************************
****************************************************************************************************
*********************
* Standardized vars *  recover relevant standardized vars once the best method is identified (in stage II end)
*********************
use `b_event', clear
keep `tvar' `method'
reshape long hm_, i(`tvar') j(var2) string
egen var = ends(var2), punct("_") tail
egen head1 = ends(var2), punct("_") head
gen head=substr(head1,1,length(head1)-1)
gen st="st"
egen v1=concat(st head) 
egen v2=concat(v1 var),  punct("_")
egen id=tag(v2)
keep if id==1
keep v2 id
gen id2=1
reshape wide id, i(id2) j(v2) string
drop id2
rename id* *
ds
local std `r(varlist)'
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
use `b_event', clear
keep `tvar' `std'
foreach v of varlist `std' {
	akdensity `v', nograph cdf(d_`v') kernel(gaussian) at(`v') noadapt
}
*Invert kernel cdf and standardized vars for two way vars
if `n2w'>0 {
	local aux01 sthp sthp1s stdem
	foreach var of local var_2wsh {
		local h`var': subinstr local std "_`var'" "", count(local n`var')
		if `n`var'' != 0 {
			local head: list h`var' & aux01
			centile d_`head'_`var', c(50)
			replace d_`head'_`var' = 1 - d_`head'_`var' if d_`head'_`var' < `r(c_1)'
			centile `head'_`var', c(50)
			replace `head'_`var' = (-1)*`head'_`var' if `head'_`var' < `r(c_1)'
		}
	}
}
save `b_mean', replace
****************************************************************************************************
****************************************************************************************************
******************************************
* Components, categories, agregate index *
******************************************
use `b_mean', clear
keep `tvar' st*
rename st*_* .*
order `tvar'
ds
local listh `r(varlist)'
gettoken listh1 listh: listh
rename * v_*
rename v_`tvar' `tvar'
reshape long v_, i(`tvar') j(var) string
rename v_ values
gen `component'=""
foreach var of local listh {
	replace `component' = "``var'_`component''" if var=="`var'"
}
collapse (mean) values, by(`component' `tvar')
gen `category'=""
foreach var of local comp {
	replace `category' = "``var'_cat'" if `component'=="`var'"
}
sort `category' `component'
save `b_`component'', replace
****************************************************************
****************************************************************
collapse (mean) values, by(`category' `tvar')
rename `category' `component'
save `b_`category'', replace
****************************************************************
****************************************************************
collapse (mean) values, by(`tvar')
gen `component'="Index"
save `b_index', replace
****************************************************************
****************************************************************
*Save heatmap results
use `b_`component'', clear
append using `b_`category''
append using `b_index'
keep `tvar' `component' values
replace `component' = subinstr(proper(`component')," ","",.)
reshape wide values, i(`tvar') j(`component') string
rename values* *
order `tvar'
ds
local list_t `r(varlist)'
gettoken list_t1 list: list_t
foreach var of varlist `list' {
	akdensity `var', nograph cdf(d_`var') kernel(gaussian) at(`var') noadapt
}
keep `tvar' d_*
rename d_* *
sum `tvar'
if (`catxcoord'<0|`catxcoord'>1) {
	noisily disp in r "catxcoord = `catxcoord' should be inside [0, 1] interval"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
local catts = `r(N)' * `catxcoord'
export excel using `resultse', sheet("heatmap") firstrow(var) sheetreplace
*******************************************************************************************
*******************************************************************************************
*Build graph
use `b_`component'', clear
append using `b_index'
keep `tvar' `component' values
reshape wide values, i(`tvar') j(`component') string
rename values* *
order `tvar'
ds
local list_j `r(varlist)'
gettoken list_j1 listj: list_j
foreach var of varlist `listj' {
	akdensity `var', nograph cdf(d_`var') kernel(gaussian) at(`var') noadapt
}
keep `tvar' d_*
gen d_Index2 = d_Index
reshape long d_, i(`tvar') j(`component') string
sort `component' `tvar'
rename d_ values
gen `category'=""
foreach var of local comp {
	replace `category' = "``var'_cat'" if `component'=="`var'"
}
sort `category' `component'
egen id2 = group(`category' `component')
sum id2
replace id2=`r(max)'+1 if `component'=="Index"
sum id2
replace id2=`r(max)'+1 if `component'=="Index2"
replace `category'="Index" if `component'=="Index"
replace `category'="Index2" if `component'=="Index2"
order `category' `component' `tvar' values
sort id `tvar'
save `b_hm_mean', replace
****************************************************************
****************************************************************
use `b_hm_mean', clear
egen ident = tag(`category')
gen id_cat = sum(ident)
gen id = .
replace id = id2 + id_cat 
sum id
replace id = `r(max)'-1 if id==`r(max)'
*Fill blanks
tab id, matrow(Vals) 
local nvals = r(r)
local i = 1
while `i' <= `nvals' {
	local val = Vals[`i',1]
	local vals "`vals' `val'"
	local ++i 
}
sum id
local idmin1 = `r(min)' + 1
local idmax1 = `r(max)' - 1
local idmax = `r(max)' + 1
local N = r(N)
*sum `tvar'
*local tmin = `r(min)'
foreach num of numlist `idmin1'/`idmax1' {
	local n`num': list posof "`num'" in vals
	if `n`num'' == 0 {
		local listn "`listn' `num'"
	}
}
local listnt "1`listn' `idmax'"
local ncomp : word count `listnt'
local obs = `N' + `ncomp'
set obs `obs'
foreach num of numlist 1/`ncomp' {
	local obs`num' = `N' + `num'
}
local j = 1
foreach i of local listnt {
	replace id = `i' in `obs`j''
	replace `tvar' = `tmin' in `obs`j''
	local ++j
}
tsset id `tvar', `frequency'
tsfill, full
gen id3 = id
save `b_hm_mean_graph', replace
****************************************************************
****************************************************************
*********
* GRAPH *
*********
use `b_hm_mean_graph', clear
sum id
local idmax = r(max)
sum `tvar'
local tmin2: disp `r(tsfmt)' `r(min)'
local tmax2: disp `r(tsfmt)' `r(max)'
local catt = `r(min)' - `catts'
preserve
egen identc=tag(`component')
drop if `component'=="Index"|`component'=="Index2"
keep if identc==1
sum id
foreach i of numlist 1/`r(N)' {
	local y1 = id[`i']
	local y2 = `component'[`i']
	local ylabel "`ylabel' `y1' "`y2'""
}
egen identcat=tag(`category')
keep if identcat==1
sum id_cat
local ncat = `r(N)'
if (`ncat' < 2| `ncat' > 10) {
	noisily disp in r "{bf:`category'} should have between 2 and 10 different classifications"
	use `fileseries', clear
	tset `tvar'
	exit 198
}
foreach i of numlist 1/`ncat' {
	local y1 = `category'[`i']
	local ycat "`ycat' "`y1'""
}
restore
egen id_comp = tag(`component')
egen id_cat2 = tag(`category')
sum id if id_comp==1&(`component'=="Index"|`component'=="Index2")
local yindex = r(mean)
local j = 1
foreach cat of local ycat {
	sum id3 if id_comp==1&`category'=="`cat'"
	local y`j' = r(mean)
	if `r(N)'==1 {
		local `y`j'' = `y`j'' - .5
	}
	local ++j
}
tokenize `"`ycat'"'
foreach num of numlist 1/`ncat' {
	local cat`num': word count ``num''
	if `cat`num'' >= 3 {
		gettoken f1`num' r1`num': `num'
		gettoken f2`num' `num'b: r1`num'
		local `num'a "`f1`num'' `f2`num''"
		if length("``num'a'") > 15 {
			local `num'a = subinstr(abbrev(subinstr(proper("``num'a'"," ","",.),15),"~","_",.)
		}
		if length("``num'b'") > 15 {
			local `num'b = subinstr(abbrev(subinstr(proper("``num'b'"," ","",.),15),"~","_",.)
		}
	}
	else {
		local `num'a  "``num''"
		if length("``num'a'") > 15 {
			local `num'a = subinstr(abbrev(subinstr(proper("``num'a'"," ","",.),15),"~","_",.)
		}
	}
}
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
if `ncat'==10 {
twoway contour values id `tvar' if id<=`idmax', heatmap levels(500) zlabel(0 .5 1, labsize(small)) ztick(none) ztitle("") int(none) /// 
ytitle("") xtitle("") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) clegend(width(*.5))  graphregion(color(ebg)) plotregion(color(ebg)) /// 
text(`y10' `catt' "{bf:`10a'}" "{bf:`10b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y9' `catt' "{bf:`9a'}" "{bf:`9b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y8' `catt' "{bf:`8a'}" "{bf:`8b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y7' `catt' "{bf:`7a'}" "{bf:`7b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y6' `catt' "{bf:`6a'}" "{bf:`6b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y5' `catt' "{bf:`5a'}" "{bf:`5b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y4' `catt' "{bf:`4a'}" "{bf:`4b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y3' `catt' "{bf:`3a'}" "{bf:`3b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y2' `catt' "{bf:`2a'}" "{bf:`2b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y1' `catt' "{bf:`1a'}" "{bf:`1b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
ylabel(`ylabel' `yindex' "{it:`indexname'}", angle(0) labsize(vsmall) nogrid)
graph export hm_`resultsg', replace
}
if `ncat'==9 {
twoway contour values id `tvar' if id<=`idmax', heatmap levels(500) zlabel(0 .5 1, labsize(small)) ztick(none) ztitle("") int(none) /// 
ytitle("") xtitle("") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) clegend(width(*.5))  graphregion(color(ebg)) plotregion(color(ebg)) /// 
text(`y9' `catt' "{bf:`9a'}" "{bf:`9b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y8' `catt' "{bf:`8a'}" "{bf:`8b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y7' `catt' "{bf:`7a'}" "{bf:`7b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y6' `catt' "{bf:`6a'}" "{bf:`6b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y5' `catt' "{bf:`5a'}" "{bf:`5b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y4' `catt' "{bf:`4a'}" "{bf:`4b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y3' `catt' "{bf:`3a'}" "{bf:`3b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y2' `catt' "{bf:`2a'}" "{bf:`2b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y1' `catt' "{bf:`1a'}" "{bf:`1b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
ylabel(`ylabel' `yindex' "{it:`indexname'}", angle(0) labsize(vsmall) nogrid)
graph export hm_`resultsg', replace
}
if `ncat'==8 {
twoway contour values id `tvar' if id<=`idmax', heatmap levels(500) zlabel(0 .5 1, labsize(small)) ztick(none) ztitle("") int(none) /// 
ytitle("") xtitle("") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) clegend(width(*.5))  graphregion(color(ebg)) plotregion(color(ebg)) /// 
text(`y8' `catt' "{bf:`8a'}" "{bf:`8b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y7' `catt' "{bf:`7a'}" "{bf:`7b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y6' `catt' "{bf:`6a'}" "{bf:`6b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y5' `catt' "{bf:`5a'}" "{bf:`5b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y4' `catt' "{bf:`4a'}" "{bf:`4b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y3' `catt' "{bf:`3a'}" "{bf:`3b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y2' `catt' "{bf:`2a'}" "{bf:`2b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y1' `catt' "{bf:`1a'}" "{bf:`1b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
ylabel(`ylabel' `yindex' "{it:`indexname'}", angle(0) labsize(vsmall) nogrid)
graph export hm_`resultsg', replace
}
if `ncat'==7 {
twoway contour values id `tvar' if id<=`idmax', heatmap levels(500) zlabel(0 .5 1, labsize(small)) ztick(none) ztitle("") int(none) /// 
ytitle("") xtitle("") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) clegend(width(*.5))  graphregion(color(ebg)) plotregion(color(ebg)) /// 
text(`y7' `catt' "{bf:`7a'}" "{bf:`7b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y6' `catt' "{bf:`6a'}" "{bf:`6b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y5' `catt' "{bf:`5a'}" "{bf:`5b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y4' `catt' "{bf:`4a'}" "{bf:`4b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y3' `catt' "{bf:`3a'}" "{bf:`3b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y2' `catt' "{bf:`2a'}" "{bf:`2b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y1' `catt' "{bf:`1a'}" "{bf:`1b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
ylabel(`ylabel' `yindex' "{it:`indexname'}", angle(0) labsize(vsmall) nogrid)
graph export hm_`resultsg', replace
}
if `ncat'==6 {
twoway contour values id `tvar' if id<=`idmax', heatmap levels(500) zlabel(0 .5 1, labsize(small)) ztick(none) ztitle("") int(none) /// 
ytitle("") xtitle("") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) clegend(width(*.5))  graphregion(color(ebg)) plotregion(color(ebg)) /// 
text(`y6' `catt' "{bf:`6a'}" "{bf:`6b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y5' `catt' "{bf:`5a'}" "{bf:`5b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y4' `catt' "{bf:`4a'}" "{bf:`4b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y3' `catt' "{bf:`3a'}" "{bf:`3b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y2' `catt' "{bf:`2a'}" "{bf:`2b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y1' `catt' "{bf:`1a'}" "{bf:`1b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
ylabel(`ylabel' `yindex' "{it:`indexname'}", angle(0) labsize(vsmall) nogrid)
graph export hm_`resultsg', replace
}
if `ncat'==5 {
twoway contour values id `tvar' if id<=`idmax', heatmap levels(500) zlabel(0 .5 1, labsize(small)) ztick(none) ztitle("") int(none) /// 
ytitle("") xtitle("") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) clegend(width(*.5))  graphregion(color(ebg)) plotregion(color(ebg)) /// 
text(`y5' `catt' "{bf:`5a'}" "{bf:`5b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y4' `catt' "{bf:`4a'}" "{bf:`4b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y3' `catt' "{bf:`3a'}" "{bf:`3b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y2' `catt' "{bf:`2a'}" "{bf:`2b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y1' `catt' "{bf:`1a'}" "{bf:`1b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
ylabel(`ylabel' `yindex' "{it:`indexname'}", angle(0) labsize(vsmall) nogrid)
graph export hm_`resultsg', replace
}
if `ncat'==4 {
twoway contour values id `tvar' if id<=`idmax', heatmap levels(500) zlabel(0 .5 1, labsize(small)) ztick(none) ztitle("") int(none) /// 
ytitle("") xtitle("") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) clegend(width(*.5))  graphregion(color(ebg)) plotregion(color(ebg)) /// 
text(`y4' `catt' "{bf:`4a'}" "{bf:`4b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y3' `catt' "{bf:`3a'}" "{bf:`3b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y2' `catt' "{bf:`2a'}" "{bf:`2b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y1' `catt' "{bf:`1a'}" "{bf:`1b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
ylabel(`ylabel' `yindex' "{it:`indexname'}", angle(0) labsize(vsmall) nogrid)
graph export hm_`resultsg', replace
}
if `ncat'==3 {
twoway contour values id `tvar' if id<=`idmax', heatmap levels(500) zlabel(0 .5 1, labsize(small)) ztick(none) ztitle("") int(none) /// 
ytitle("") xtitle("") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) clegend(width(*.5))  graphregion(color(ebg)) plotregion(color(ebg)) /// 
text(`y3' `catt' "{bf:`3a'}" "{bf:`3b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y2' `catt' "{bf:`2a'}" "{bf:`2b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y1' `catt' "{bf:`1a'}" "{bf:`1b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
ylabel(`ylabel' `yindex' "{it:`indexname'}", angle(0) labsize(vsmall) nogrid)
graph export hm_`resultsg', replace
}
if `ncat'==2 {
twoway contour values id `tvar' if id<=`idmax', heatmap levels(500) zlabel(0 .5 1, labsize(small)) ztick(none) ztitle("") int(none) /// 
ytitle("") xtitle("") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) clegend(width(*.5))  graphregion(color(ebg)) plotregion(color(ebg)) /// 
text(`y2' `catt' "{bf:`2a'}" "{bf:`2b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
text(`y1' `catt' "{bf:`1a'}" "{bf:`1b'}", orientat(rvertical) placement(c) size(vsmall)) /// 
ylabel(`ylabel' `yindex' "{it:`indexname'}", angle(0) labsize(vsmall) nogrid)
graph export hm_`resultsg', replace
}
****************************************************************
****************************************************************
***********************
* Series individuales *
***********************
if "`graphseries'" == "graphseries" {
	local method: subinstr local method "hm_" "", all
	local nmet: word count `method'
	local div = `nmet'/4
	local int = int(`div')
	local rest = `div' - `int'
	local block = `int' * 4
	local int1 = `int' + 1
	tokenize `method'
	foreach num of numlist 1/`nmet' {
		gettoken met`num'1 var`num': `num', parse("_")
		local  var`num': subinstr local  var`num' "_" "", all
		local met`num' = substr("`met`num'1'",1,length("`met`num'1'")-1)
		local sc`num' = substr("`met`num'1'",length("`met`num'1'"),1)
*		disp in gr "var = " in r "`var`num'' " in y "-" in gr " met = " in r "`met`num'' " in y "-" in gr " sc = " in r "`sc`num''" "
	}
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	use `b_event', clear
	if `nwindows' > 1 {
		foreach num of numlist 2/`nwindows' {
			local range`num' "| inrange(`tvar', `t`num'min', `t`num'max')"
			local bar_range "`bar_range' `range`num''"
		}
	}
	foreach num of numlist 1/`nmet' {
		gen `var`num''_s = `var`num''_`met`num''_tr + scalar(sig_`met`num''_`var`num''`sc`num'')
		gen `var`num''_r = `var`num''_`met`num''_tr - scalar(sig_`met`num''_`var`num''`sc`num'')
		local title : variable label `var`num''
		sum `var`num''
		local min = r(min) - r(sd)
		gen `var`num''_bar = r(max)+r(sd) if inrange(`tvar', `t1min', `t1max') `bar_range'
		two (bar `var`num''_bar `tvar', bcolor(gs14) base(`min')) (rarea `var`num''_s `var`num''_r `tvar', sort color(forest_green) fintensity(inten30) lwidth(none) scheme(s1color)) /// 
		(line `var`num'' `tvar') (line `var`num''_`met`num''_tr  `tvar'), legend(off) xtitle("") title("`title'") tlabel(`tmin2'(`tdist')`tmax2', angle(90) labsize(vsmall)) /// 
		saving(g_`var`num'', replace)
		drop `var`num''_s `var`num''_r
	}
	local s = 1
	local m = 1
	while `s'<=`block' {
		local j = 1
		while `j' <= 4 {
			local list`m' "`list`m'' g_`var`s''.gph "
			local ++s
			local ++j
		}
		local ++m
	}
	if `rest' > 0 {
		if `rest' == .25 {
			local list`int1' "g_`var`nmet''.gph"
		}
		if `rest' == .5 {
			local nmet1 = `nmet' - 1
			local list`int1' "g_`var`nmet1''.gph g_`var`nmet''.gph"
		}
		if `rest' == .75 {
			local nmet1 = `nmet' - 1
			local nmet2 = `nmet' - 2
			local list`int1' "g_`var`nmet2''.gph g_`var`nmet1''.gph g_`var`nmet''.gph"
		}
	}
	if `rest' == 0 {
		foreach m of numlist 1/`int' {
			graph combine `list`m'', scheme(s1color) 
			graph export gc`m'.png, replace
		}
	}
	else {
		foreach m of numlist 1/`int1' {
			graph combine `list`m'', scheme(s1color) 
			graph export gc`m'.png, replace
		}
	}
***********************************************************************************
***********************************************************************************
	putdocx begin
	putdocx paragraph
	putdocx text ("pre-nwindows"), bold
	putdocx paragraph
	putdocx text ("T1: `c1min' - `c1max'")
	if `nwindows' > 1 {
		foreach num of numlist 2/`nwindows' {
			putdocx paragraph
			putdocx text ("T`num': `c`num'min' - `c`num'max'")
		}
	}
	putdocx paragraph
	putdocx paragraph, halign(center)
	if `rest' == 0 {
		foreach m of numlist 1/`int' {
			putdocx image gc`m'.png
		}
	}
	else {
		foreach m of numlist 1/`int1' {
			putdocx image gc`m'.png 
		}
	} 
	putdocx save `resultsw', replace
noisily disp in gr "See " in ye "individual time series graphs " in gr "in Word file: " in ye "{bf:`c(pwd)'\" "`resultsw'}"
***********************************************************************************
***********************************************************************************
}
use `fileseries', clear
tset `tvar'
noisily disp in gr "See " in ye "RESULTS " in gr "in Excel file: " in ye "{bf:`c(pwd)'\" "`resultse'}"
noisily disp in gr "See " in ye "HEATMAP graph " in gr "file: " in ye "{bf:`c(pwd)'\" "hm_`resultsg'}"
if "`save'"!="" {
	noisily disp in gr "See " in ye "cycles, trends and standardized vars " in gr "in Stata file: " in ye "{bf:`c(pwd)'\" "`save'}"
}
}
end
