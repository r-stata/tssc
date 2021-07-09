*! version 1.5  08Jan2019
*! Joao Pedro Azevedo, Minh Cong Nguyen, Viviane Sanfelice
*  version 1.5  06Aug2018
*  Add: report equation check by years
*  version 1.4  06Aug2018
*  Add: middle distribution (from bottom xx% to before top yy%)
*  version 1.3  24Oct2013
*  Add: top xx% of the distribution (mean and ratio to all sample), add growth method
*  version 1.2  16May2013
*  Add: bottom xx% of the distribution (mean and ratio to all sample)
*  version 1.1  01Dec2012
*  Joao Pedro Azevedo, Minh Cong Nguyen, Viviane Sanfelice
*  version 1.0  15Mar2012
*  Joao Pedro Azevedo, Minh Cong Nguyen, Viviane Sanfelice

cap program drop adecomp
program define adecomp, rclass sortpreserve byable(recall)
	version 12, missing
	if c(more)=="on" set more off
	local version : di "version " string(_caller()) ", missing:"
	syntax varlist(numeric) [if] [in] [aweight fweight], by(varname numeric) EQuation(string)  	    ///
			[varpl(varname numeric) INdicator(string) mpl(numlist sort) gic(numlist max=1)   		///
			Rank(string) ID(varname numeric) PERCentile(numlist max=1)                              ///
			GRoup(varname numeric) oneway RESidual std strata(varname min=1 max=10) 				///
			Bottom(numlist max=1 integer <=99 integer>=1) Top(numlist max=1 integer <=99 integer>=1) ///
			MIDdle(numlist max=2 integer <=99 integer>=1 sort) MRatio Method(string) svy bootstrap(numlist max=1) Stats(string)]                            		
	
	***	Error messages
	if ("`id'"!="")&(("`rank'"!="")|("`percentile'"!="")|("`strata'"!="")) {
		di in red "ID options cannot be combined with STRATA, Rank or PERCentile options"
		exit 198
	}
	if ("`strata'"!="")&("`percentile'"!="") {
		di in red "Strata and PERCentile options cannot be combined"
		exit 198
	}
	if ("`indicator'"=="")&("`gic'"=="") {
		di in red "You must use the INdicator or/and GIC option"
		exit 198
	}
	if ("`varpl'"=="")&("`mpl'"!="") {
		di in red "The MPL option must be combined with the VARPL option"
		exit 198
	}
	if ("`varpl'"!="")&("`indicator'"=="") {
		di in red "The VARPL option must be used for fgt0, fgt1 and fgt2 - INdicator option"
		exit 198
	}
	if ("`method'"~="") {		
		if ("`method'"!="difference") & ("`method'"!="growth") {	
			di in red "Only difference or growth options are possible"
			exit 198
		}
	}
	else {
		local method difference	
	}
	if ("`mratio'"!="")&("`bottom'"=="") {
		di in red "The mratio option must be used together with the bottom() option"
		exit 198
	}
	if ("`indicator'"!="") {
		tempname nofgt
		local `nofgt' =  regexm("`indicator'","fgt")
		if (``nofgt''!=0)&("`varpl'"=="") {
			di in red "You must specify a poverty line. Use the VARPL option"
			exit 198
		}
		if (``nofgt''==0)&("`varpl'"!="") {
			di in red "The VARPL option must be used for fgt0, fgt1 and fgt2 - INdicator option"
			exit 198
		}
		if (``nofgt''==0) {
			tempname pline
			qui gen `pline' = 10
			local varpl "`pline'"
		}
	}
	*** Add indicator for Top/Bottom x percentiles and indicators' label
	label define index 0 "FGT(0)" 1 "FGT(1)" 2 "FGT(2)" 3 "Gini" 4 "Theil" 5 "Mean", add modify
	if ("`bottom'"!="") & ("`top'"!="") {
		if ("`mratio'"!="") local indicator "`indicator' bottom top ratio"
		if ("`mratio'"=="") local indicator "`indicator' bottom top"
	}
	if ("`bottom'"!="") & ("`top'"=="") {
		if ("`mratio'"!="") local indicator "`indicator' bottom ratio"
		if ("`mratio'"=="") local indicator "`indicator' bottom"
	}
	if ("`bottom'"=="") & ("`top'"!="") local indicator "`indicator' top"
	if ("`middle'"!="") local indicator "`indicator' middle"
	
	tempname ind
	local `ind' "`indicator'"
	if ("`indicator'"=="")&("`gic'"!="") {
		tempname pline
		qui gen `pline' = 10
		local varpl "`pline'"
		local indicator "fgt0"
	}
	local n_comp = wordcount("`varlist'") - 1
	tempname check_eq aux
	local `check_eq' "`equation'"
	local `aux' 0
	forvalues i = `n_comp'(-1)1 {
		if regexm("``check_eq''","c`i'")==1 local `aux' = ``aux''+1
		local `check_eq' = subinstr("``check_eq''","c`i'","",1)
	}
	local `check_eq' =  regexm("``check_eq''","c")
	if (``check_eq''!=0) | (``aux''!=`n_comp') {
		di in red "The equation (`equation') does not match with the number of components variables, `n_comp'."
		exit 198
	}
	if ("`rank'"!="") {
		tempname nocomp
		local `nocomp' =  regexm("`varlist' components","`rank'")
		if (``nocomp''==0)|("`rank'"=="`1'") {
			di in red "The variable in Rank option must be a component variable."
			exit 198
		}
	}	
		
	local cmdline: copy local 0
	marksample touse, strok
	tempvar  aleat
	preserve
	
	tokenize `varlist'
	*** Comparison variable
	tempname matc
	cap tab `by' if `touse', matrow(`matc')
	local ct = r(N)
	local c1 = `matc'[1,1]
	local c2 = `matc'[2,1]
	local yrdif = abs(`c1'-`c2')	
	if r(N)==0 error 2000	
	if (`r(r)'~=2)|(_rc==134) {
		di in red "Only 2 groups allow"
		exit 198
	}		

	*** ID option
	if ("`id'"!="") {
	tempname aux
		cap tab `by' if `touse' , matcell(`aux')
		if (`aux'[1,1]!=`aux'[2,1]) {
			di in red "Not balanced panel in ID option"
			exit 198
		}
	local rank "`id'"	
	}	

	*** Control sort
	set seed 120
	cap gen `aleat' = uniform() if `touse'

	*** Number of quantiles
	local nquantiles = 200
	if ("`percentile'"!="") local nquantiles = `percentile'
	
	*** Strata option
	if ("`strata'"=="") {
		tempvar strata
		qui gen double `strata' = 1 if `touse'
	}
		
	*** Group options
	if ("`group'"=="") {
		tempvar grv
		qui gen `grv' = 1
		local grvar "`grv'"
	}
	else {
		if (`:word count `group''==1) { // one group variable
			local grvar `group'
		}		
		else { // more than one group variable
			tempvar grmv
			qui egen `grmv' = group(`group'), label truncate(16)
			local grvar "`grmv'"
		}
	}
	
	*** Weights
	if ("`weight'"=="") {
		tempvar w
		qui gen `w' = 1
		local wvar "`w'"
	}	
	else {
		local weight "[`weight'`exp']"				
		local wvar : word 2 of `exp'
	}
	*** Check equation
	local lhs `1'
	macro shift
	local varlist : list varlist - lhs	
	local n_comp = wordcount("`varlist'")
	**tokenize `varlist'
	local eq "`equation'"	
	forvalues i=`n_comp'(-1)1 {	
		local eq =  trim(subinstr("`eq'", "c`i'", "``i''",.))
	}
	di
	di as txt "Check the equation:"
	di in yellow "`lhs' = `eq'"
	cap drop equation
	qui gen double equation = `eq'
	tabstat `lhs' `weight'  if `touse' , by(`by') stat(N mean sd min max) notota
	tabstat equation `weight'  if `touse' , by(`by') stat(N mean sd min max) nototal
	sum `lhs' if `touse', meanonly
	local aux1 = round(r(mean),2)
	local aux3 = r(N)
	sum equation if `touse', meanonly
	local aux2 = round(r(mean),2)
	local aux4 = r(N)
	if (`aux1'!=`aux2') | (`aux3'!=`aux4') {
		di in red _n "Warning: The computed equation (`equation') differs from the welfare measure, `lhs'."
		di as txt    "(The calculation is based on the equation and therefore, on the observations of the component variables)"
	}
		
	*** Keep useful variables
	if ("`rank'"!="" & "`rank'"!="components") local aux_rank "`rank'"
	qui keep `lhs' `varlist' `wvar' `by' `varpl' `grvar' `touse' `aleat' equation `aux_rank' `strata'
	qui markout `touse' `lhs' `varlist' `wvar' `by' `varpl' `grvar' `aleat' equation `aux_rank' `strata', strok
	qui keep if `touse'
		
	*** All possible combination of incomes
	local str1 "0 1"
	local t=1	
	while `t'<`n_comp' {
		local str2
		foreach var of local str1 {
			forv i=0(1)1 {
				local str2 "`str2' `var'`i'"
			}
		}
		local str1 "`str2'"
		local ++t
	}
	
	local rankvar "equation"
	if ("`rank'"~="components" & "`rank'"~="") local rankvar "`rank'"	
	foreach var of varlist `varlist' {	
	
		*** Bug inequality indicators fixing
		cap sum `var' if `by'==`c1', meanonly
		if `r(mean)' == 0 & `r(max)' == 0 {
			qui replace `var' = 0.00001 if `by'==`c1'
		}
		cap sum `var' if `by'==`c2', meanonly
		if `r(mean)' == 0 & `r(max)' == 0 {
			qui replace `var' = 0.00001 if `by'==`c2'
		}		
	
		*** Create temporary variables
		tempvar `var'_1
		cap gen double ``var'_1'=.

		*** Change the distributions	
		if ("`rank'"=="components") {
			if ("`percentile'"!="")  mata: _fchangeadd("`rankvar'", "`var'", "`by'", "`wvar'", "`touse'", "``var'_1'")
			else qui rescale, rvar(`var') svar(`var') byv(`by') strvar(`strata') ovar(``var'_1') seed(`aleat')
		}
		else {
			if ("`percentile'"!="")  mata: _fchangeadd("`rankvar'", "`var'", "`by'", "`wvar'", "`touse'", "``var'_1'")
			else qui rescale, rvar(`rankvar') svar(`var') byv(`by') strvar(`strata') ovar(``var'_1') seed(`aleat')
		}
	}
	
	*** Loops over all paths - Calculate income combination based on the given equation	
	local n=0
	foreach j of local str2 {				
		local eq "`equation'"	
		forvalues i=`n_comp'(-1)1 {	
			if(substr("`j'",`i',1)=="1") local eq = subinstr("`eq'", "c`i'", "```i''_1'",.)			
			else                         local eq = subinstr("`eq'", "c`i'", "``i''",.)			
		}			
		cap gen double i`n' = `eq'
		if (_rc>0) {			
			noi dis in red "The variable i`n' is already available, rename that variable."
			exit 110	
		}		
		local inclist "`inclist' i`n'"
		local ++n
	}
	
	** Statistics
	if ("`stats'"~="") {
		** for indicators
		mata: _fstats("`lhs'", "`by'", "`wvar'", "`varpl'", "`grvar'", "`touse'")
		** for factors
		qui tabstat `lhs' `varlist' `weight' if `touse', by(`by') stat(`stats') save nototal
		mat mallx  = vec(r(Stat1)), vec(r(Stat2))
		mat colnames mallx = `r(name1)' `r(name2)'
		return matrix statsvar = mallx		
	}
	
	** Decomposition
	mata: _fmethod("`inclist'", "`by'", "`wvar'", "`varpl'", "`grvar'", "`touse'")
	
	*** Display results
	qui su `by', meanonly
	local ct = r(N)
	qui levelsof `grvar', local(lvl)
	cap label drop beffect index			
	forvalues i = 1(1)`n_comp'{
		label define beffect `i' "``i''", add
	}			     	
	//label define beffect `=`n_comp'+1' "total change", add
	label define beffect `=`n_comp'+1' "total `method'", add
	label define beffect `=`n_comp'+2' "residual", add	
	
	*** Add indicator for Top/Bottom x percentiles and indicators' label
	label define index 0 "FGT(0)" 1 "FGT(1)" 2 "FGT(2)" 3 "Gini" 4 "Theil" 5 "Mean", add modify
	if ("`bottom'"!="") & ("`top'"!="") {
		if ("`mratio'"!="") label define index 6 "Bottom(`bottom')" 7 "Top(`top')" 8 "Bottom(`bottom')/Mean", add modify
		if ("`mratio'"=="") label define index 6 "Bottom(`bottom')" 7 "Top(`top')", add modify
	}
	if ("`bottom'"!="") & ("`top'"=="") {
		if ("`mratio'"!="") label define index 6 "Bottom(`bottom')" 8 "Bottom(`bottom')/Mean", add modify
		if ("`mratio'"=="") label define index 6 "Bottom(`bottom')", add modify
	}
	if ("`bottom'"=="") & ("`top'"!="") label define index 7 "Top(`top')", add modify
	if ("`middle'"~="") label define index 9 "Middle(`middle')", add modify
	
	di
	if ("`stats'"~="") {
		di in txt _new "Summary statistics:"
		mat colnames rstats = bind beff bsta		
		svmat double rstats, n(col)				
		label val bind index
		label var bind "Welfare Indicator"
		if ("`method'"=="growth") local mtd annualized growth
		if ("`method'"=="difference") local mtd difference
		la def beff 1 "`c1'" 2 "`c2'" 3 "`mtd'"
		la val beff beff	
		la var beff "Year"
		label var bsta "Statistics"
		tabdisp beff bind if bind!=., cell(bsta) format(%12.3fc)
		return matrix stats = rstats
	}
	
	if ("`std'"=="") di in txt _new "Shapley decomposition:"
	else di in txt _new "Shapley decomposition - standard errors are below their estimates:"
	di as txt "Number of obs      = " as res %7.0f `ct'
	local factorial = round(exp(lnfactorial(`n_comp')),1)
  	di as txt "Number of paths    =   `factorial'"
	di as txt "Number of factors  =   `n_comp'"
	di as txt "Method             =   `method'"
	
	return scalar N = `ct'
	return scalar path = `factorial'
	return scalar component = `n_comp'
	if ("`method'"=="growth")	local pct (annualized %)
	if ("``ind''"~="") {				
		foreach lv of local lvl {
			local lvlgr `"`lvlgr' _rate`lv'"'
			if ("`std'"~="") local lvlgrstd `"`lvlgrstd' _std`lv'"'			
		}
		mat colnames rindrate = bindex beffect `lvlgr'
		if ("`std'"~="") mat colnames rindstd  = bindexstd beffectstd `lvlgrstd'
		svmat double rindrate, n(col)
		if ("`std'"~="") svmat double rindstd, n(col)
		label val beffect beffect	
		label val bindex index
		label var bindex "Welfare Indicator `pct'"
		label var beffect "Effect"		
		foreach lv of local lvl {
			local grname : label (`grvar') `lv'
			if (`:word count `lvl''==1) noi di as txt _new "Shapley decomposition - Welfare Indicator"
			else noi di as txt _new "Shapley decomposition - Welfare Indicator for group: `grname'"
			if ("`std'"=="") tabdisp beffect bindex if bindex!=., cell(_rate`lv') format(%12.3fc)
			else             tabdisp beffect bindex if bindex!=., cell(_rate`lv' _std`lv') format(%12.3fc)
		}
		
		return matrix b = rindrate
		if ("`std'"~="") return matrix sd = rindstd

		tempfile temp1
		cap save `temp1', replace
	}
	if  ("`mpl'"~="") {		
		local mpl0 = subinstr("`mpl'",".","_",.)
		foreach lv of local lvl {
			foreach ln of local mpl0 {			
				local lvlgrmpl `"`lvlgrmpl' _mpl`ln'_`lv'"'
				if ("`std'"~="") local lvlgrmplstd `"`lvlgrmplstd' _std`ln'_`lv'"'				
			}
			local lvlgrmpl `"`lvlgrmpl' _mpl`ln'm_`lv'"'
			if ("`std'"~="") local lvlgrmplstd `"`lvlgrmplstd' _std`ln'm_`lv'"'			
		}
		mat colnames rmplrate = b2index b2effect `lvlgrmpl'		
		if ("`std'"~="") mat colnames rmplstd = b2indexstd b2effectstd `lvlgrmplstd'		
		svmat double rmplrate, n(col)
		if ("`std'"~="") svmat double rmplstd, n(col)
		label val b2effect beffect	
		label val b2index index
		label var b2index "Multiple poverty lines"
		label var b2effect "Effect"		
		foreach lv of local lvl {
			if (`:word count `lvl''==1) {
				noi di as txt _new "Shapley decomposition with multiple poverty lines (`mpl')"
				if ("`std'"=="") tabdisp b2effect b2index if b2index<=2, cell(`lvlgrmpl') format(%12.3fc)
				//else             tabdisp b2effect b2index if b2index<=2, cell(`lvlgrmpl' `lvlgrmplstd') format(%12.3fc)
				else             tabdisp b2effect b2index if b2index<=2, cell(`lvlgrmpl') format(%12.3fc)
			}
			else {
				local grname : label (`grvar') `lv'
				local lvlgrmpl0
				noi di as txt _new "Shapley decomposition with MPL (`mpl') for group: `grname'"
				foreach ln of local mpl0 {
					if ("`std'"=="") local lvlgrmpl0 `"`lvlgrmpl0' _mpl`ln'_`lv'"'
					//else             local lvlgrmpl0 `"`lvlgrmpl0' _mpl`ln'_`lv' _std`ln'_`lv'"'
					else local lvlgrmpl0 `"`lvlgrmpl0' _mpl`ln'_`lv'"'
				}
				if ("`std'"=="") local lvlgrmpl0 `"`lvlgrmpl0' _mpl`ln'm_`lv'"'
				//else             local lvlgrmpl0 `"`lvlgrmpl0' _mpl`ln'm_`lv' _std`ln'm_`lv'"'
				else local lvlgrmpl0 `"`lvlgrmpl0' _mpl`ln'm_`lv'"'
				tabdisp b2effect b2index if b2index<=2, cell(`lvlgrmpl0') format(%12.3fc)
			}
		}
		if ("`std'"~="") return matrix sd = rmplstd
		return matrix b = rmplrate
	}
	if  ("`gic'"~="") {		
		foreach lv of local lvl {
			local lvlgr2 `"`lvlgr2' _binrate`lv'"'
			if ("`std'"~="") local lvlgr2std `"`lvlgr2std' _binstd`lv'"'			
		}		
		mat colnames rbinrate = b1index b1effect `lvlgr2'
		if ("`std'"~="") mat colnames rbinstd = b1indexstd b1effectstd `lvlgr2std'
		svmat double rbinrate, n(col)
		if ("`std'"~="") svmat double rbinstd, n(col)
		label values b1effect beffect	
		su `by', meanonly
		label var b1index `"% change in "`lhs'" from `=r(min)' to `=r(max)'"'
		label var b1effect "Effect"
		foreach lv of local lvl {
			local grname : label (`grvar') `lv'
			if (`:word count `lvl''==1) noi di as txt _new `"Shapley decomposition of variable "`lhs'" with `gic' bins"'
			else  noi di as txt _new `"Shapley decomposition of variable "`lhs'" with `gic' bins for group: `grname'"'			
			if ("`std'"=="") tabdisp b1effect b1index if b1index!=., cell(_binrate`lv') format(%12.3fc)
			else             tabdisp b1effect b1index if b1index!=., cell(_binrate`lv' _binstd`lv') format(%12.3fc)
		}
		if ("`std'"~="") return matrix gic_sd = rbinstd
		return matrix gic = rbinrate
	}		
	restore
	** Bootstrap	
	if `"`bootstrap'"' ~= "" {
		local bscmd `cmdline'	
		if "`svy'"=="" {
			local bsopt reps(`bootstrap') seed(123455) 				
			local sape = strpos("`bscmd'", "bootstrap")
			global bsrun = substr("`bscmd'",1,`sape'-1)				
			di _newline			
			bootstrap _b, `bsopt' ti(Decomposition) notable noh nol nowarn: bs_decompso
		}
		else {			
			local sape = min(`=strpos("`bscmd'", "svy")', `=strpos("`bscmd'", "bootstrap")')			
			global bsrun = substr("`bscmd'",1,`sape'-1)				
			tempvar bw
			noi bsweights `bw'bs , reps(`bootstrap') n(0) 			
			qui svyset [pw=`wvar'], vce(bootstrap) bsrweight(`bw'bs*) 			
			svy bootstrap _b, ti(Decomposition) notable noh nol nowarn: bs_decompso			
			*bs4rw, rw(`bw'bs*): bs_decompso			
		}
		tempname eff1 std1 eff2
		mat `eff1' = e(b)
		mata: st_matrix("`std1'", sqrt(diagonal(st_matrix("e(V)"))))
		preserve
		cap use `temp1', clear
		mkmat bindex beffect _rate1 if bindex!=., matrix(b1)
		mat `eff2' = b1, `eff1'', `std1'
		
		tempvar mt1 mt2 mt3 mt4 mt5
		mat colnames `eff2' = `mt1' `mt2' `mt3' `mt4' `mt5'
		svmat `eff2', n(col)
		label var `mt1' "Indicator"
		label var `mt2' "Effect"
		label var `mt3' "Rate"
		label var `mt4' "Bootstrapped rates"
		label var `mt5' "Bootstrapped standard error"
		label values `mt1' index
		label values `mt2' beffect
		tabdisp `mt2' `mt1' if `mt1'!=., cell(`mt4' `mt5') format(%12.3fc)
		restore
	}

end

// ----------------- OTHER SUB-PROGRAMS NEEDED IN THIS PROGRAM -----------------
cap program drop rescale
program define rescale, nclass
	syntax, rvar(varname numeric) svar(varname numeric) byv(varname numeric) strvar(string) ovar(varname numeric)	seed(varname numeric)
	local by "`byv'"
	local var "svar"
	local strata "`strvar'"
	tempfile temp1 temp2
	su `by', meanonly
	local univ1 = r(min)
	local univ2 = r(max)
	tempvar rank rank_c univ
		
	sort `by' `strata' `rvar' `aleat', stable
	bysort `by' `strata': gen `rank' = _n
	tempname r1 r2
	tempvar `r1' `r2'
	egen  ``r1'' = max(`rank') if (`by'==`univ1'), by(`strata')
	egen  ``r2'' = max(`rank') if (`by'==`univ2'), by(`strata')
	sort  `strata' ``r1'', stable
	bysort `strata': replace ``r1'' = ``r1''[_n-1] if (``r1''==.)
	sort `strata' ``r2'', stable
	bysort `strata': replace ``r2'' = ``r2''[_n-1] if (``r2''==.)
	gen double `rank_c' = round((``r2''/``r1'')* `rank',1) if `by'==`univ1'
	replace `rank_c' = round((``r1''/``r2'')* `rank',1) if `by'==`univ2'	
	replace `rank_c' = 1 if `rank_c'==0
	save `temp1', replace	
	
	* organizing data to switch between two periods
	gen `univ' = `univ2' if `by'==`univ1'
	replace `univ' = `univ1' if `by'==`univ2'
	keep `univ' `strata' `rank' `svar'
	rename `rank' `rank_c'
	tempvar `var'_1
	rename `svar' ``var'_1'	
	sort `univ' `strata' `rank_c', stable
	save `temp2', replace
					
	use `temp1', replace			
	gen `univ'  = `by' 	 		
	sort `univ' `strata' `rank_c', stable
	merge `univ' `strata' `rank_c' using `temp2', nokeep
	sum _merge if _merge==1, meanonly
	if `r(N)'!=0  di in red "Warning: `r(N)' observations were not matched. Please, revise the STRATA or ID option"
	drop _merge `univ'
		
	* keep original mean
	tempname mean1 mean2
	cap sum `svar'  if `by'==`univ2', meanonly
	local `mean1' = r(mean)
	cap sum ``var'_1'  if `by'==`univ1', meanonly
	local `mean2' = r(mean)
	cap replace ``var'_1'=``var'_1'*(``mean1''/``mean2'') if  `by'==`univ1'	
	cap sum `svar'  if `by'==`univ1', meanonly
	local `mean1' = r(mean)
	cap sum ``var'_1'  if  `by'==`univ2', meanonly
	local `mean2' = r(mean)
	cap replace ``var'_1'=``var'_1'*(``mean1''/``mean2'') if `by'==`univ2'
	replace `ovar' = ``var'_1'
	
end

*** Bootstraping of the decomposition ***
capture program drop bs_decompso
program bs_decompso, eclass
	version 10, missing
	tempname b
	qui decomp $bsrun
	matrix `b' = r(b)
	matrix `b' = `b'[1..rowsof(`b'),3]
	matrix `b' = `b''
	ereturn post `b'	
end

// -------------------------------- Mata code ------------------------
version 12
mata:
mata clear
mata drop *()
mata set matalnum off
mata set mataoptimize on
mata set matafavor speed

void _fstats(string scalar inclst, string scalar byvar, string scalar w, string scalar pline0, string scalar groups, string scalar tousename) {
	inclist = st_data(.,tokens(inclst), tousename)
	by      = st_data(.,tokens(byvar), tousename)	
	wt      = st_data(.,tokens(w), tousename)
	pline   = st_data(.,tokens(pline0), tousename)
	group   = st_data(.,tokens(groups), tousename)
	method  = st_local("method")
	indlist = tokens(st_local("indicator"))
	minmax  = colminmax(by)	
	y0 = J(0,1,.)
	for (i=1; i<=cols(indlist); i++) {
		if (indlist[i]=="fgt0")  y0 = y0 \ 0
		if (indlist[i]=="fgt1")  y0 = y0 \ 1
		if (indlist[i]=="fgt2")  y0 = y0 \ 2
		if (indlist[i]=="gini")  y0 = y0 \ 3
		if (indlist[i]=="theil") y0 = y0 \ 4
		if (indlist[i]=="mean")  y0 = y0 \ 5
		if (indlist[i]=="bottom") y0 = y0 \ 6
		if (indlist[i]=="top")   y0 = y0 \ 7
		if (indlist[i]=="ratio")  y0 = y0 \ 8
		if (indlist[i]=="middle")  y0 = y0 \ 9
	}

	indt0 = _fcompind(_fsubmatrix((inclist, wt, pline, group, by), 5, minmax[1,1]))	
	indt1 = _fcompind(_fsubmatrix((inclist, wt, pline, group, by), 5, minmax[2,1]))	
	if (method=="difference") {
		met = indt1 :- indt0
	}
	if (method=="growth") {
		met = 100:*(ln(indt1:/indt0):/(minmax[2,1]-minmax[1,1]))
	}
	//stats = (minmax[1,1] \ indt0), (minmax[2,1] \ indt1), (. \ met)
	stats = (y0, J(rows(y0),1,1), indt0) \ (y0, J(rows(y0),1,2), indt1) \ (y0, J(rows(y0),1,3), met)
	st_matrix("rstats", stats)
}

void _fmethod(string scalar inclst, string scalar byvar, string scalar w, string scalar pline0, string scalar groups, string scalar tousename) {
	inclist = st_data(.,tokens(inclst), tousename)
	by      = st_data(.,tokens(byvar), tousename)	
	wt      = st_data(.,tokens(w), tousename)
	pline   = st_data(.,tokens(pline0), tousename)
	group   = st_data(.,tokens(groups), tousename)
	method  = st_local("method")
	yrdiff  = strtoreal(st_local("yrdif"))
	st_rclear()	
	est = _fdecomp(inclist, by, wt, pline, group)
	if (st_local("oneway")=="") {
		est2 = _fdecomp(inclist, -1:*by, wt, pline, group)
		if (st_local("indicator")~="") {
			if (method=="difference") m1 = (*est[1,1])[.,1::2], 0.5:* (*est[1,1])[.,3::cols((*est[1,1]))] :- 0.5:* (*est2[1,1])[.,3::cols((*est2[1,1]))]
			if (method=="growth") m1 = (*est[1,1])[.,1::2], (100/yrdiff)*(0.5:* (*est[1,1])[.,3::cols((*est[1,1]))] :- 0.5:* (*est2[1,1])[.,3::cols((*est2[1,1]))])
			if (st_local("std")~="") s1 = (*est[2,1])[.,1::2], 0.5:* (*est[2,1])[.,3::cols((*est[2,1]))] :- 0.5:* (*est2[2,1])[.,3::cols((*est2[2,1]))]
		}
		if (st_local("mpl")~="") {
			if (method=="difference") m2 = (*est[1,2])[.,1::2], 0.5:* (*est[1,2])[.,3::cols((*est[1,2]))] :- 0.5:* (*est2[1,2])[.,3::cols((*est2[1,2]))]
			if (method=="growth") m2 = (*est[1,2])[.,1::2], (100/yrdiff)*(0.5:* (*est[1,2])[.,3::cols((*est[1,2]))] :- 0.5:* (*est2[1,2])[.,3::cols((*est2[1,2]))])
			if (st_local("std")~="") s2 = (*est[2,2])[.,1::2], 0.5:* (*est[2,2])[.,3::cols((*est[2,2]))] :- 0.5:* (*est2[2,2])[.,3::cols((*est2[2,2]))]
		}
		if (st_local("gic")~="") {
			if (method=="difference") m3 = (*est[1,3])[.,1::2], 0.5:* (*est[1,3])[.,3::cols((*est[1,3]))] :- 0.5:* (*est2[1,3])[.,3::cols((*est2[1,3]))]
			if (method=="growth") m3 = (*est[1,3])[.,1::2], (100/yrdiff)*(0.5:* (*est[1,3])[.,3::cols((*est[1,3]))] :- 0.5:* (*est2[1,3])[.,3::cols((*est2[1,3]))])
			if (st_local("std")~="") s3 = (*est[2,3])[.,1::2], 0.5:* (*est[2,3])[.,3::cols((*est[2,3]))] :- 0.5:* (*est2[2,3])[.,3::cols((*est2[2,3]))]
		}
	}
	else {
		if (st_local("indicator")~="") {
			if (method=="difference") {
				m1 = *est[1,1]
				if (st_local("std")~="") s1 = *est[2,1]
			}
			if (method=="growth") {
				m1 = *est[1,1]
				m1 = m1[.,1::2], (100/yrdiff)*m1[.,3::cols(m1)]
				if (st_local("std")~="") s1 = *est[2,1]
			}
		}
		if (st_local("mpl")~="") {
			if (method=="difference") {
				m2 = *est[1,2]
				if (st_local("std")~="") s2 = *est[2,2]
			}
			if (method=="growth") {
				m2 = ln(*est[1,2])
				m2 = m2[.,1::2], (100/yrdiff)*m2[.,3::cols(m2)]
				if (st_local("std")~="") s2 = *est[2,2]
			}
		}
		if (st_local("gic")~="") {
			if (method=="difference") {
				m3 = *est[1,3]
				if (st_local("std")~="") s3 = *est[2,3]
			}
			if (method=="growth") {
				m3 = ln(*est[1,3])
				m3 = m3[.,1::2], (100/yrdiff)*m3[.,3::cols(m3)]
				if (st_local("std")~="") s3 = *est[2,3]
			}
		}
	}
	st_matrix("rindrate", m1)
	st_matrix("rmplrate", m2)
	st_matrix("rbinrate", m3)
	st_matrix("rindstd", s1)
	st_matrix("rmplstd", s2)
	st_matrix("rbinstd", s3)
}

function _fdecomp(real matrix inclist, real matrix by, real matrix wt, real matrix pline, real matrix group) {
	pointer(pointer(pointer(real matrix) rowvector) rowvector) colvector incstep	
	pointer(real rowvector) rowvector incpos
	pointer(real matrix) rowvector ind0, fest
	ncomp   = strtoreal(st_local("n_comp"))
	indlist = tokens(st_local("indicator"))
	mpl     = tokens(st_local("mpl"))
	bin     = strtoreal(st_local("gic"))
	method  = st_local("method")
	steps   = _fsteps(_fpaths(ncomp))
	minmax  = colminmax(by)	
	gr0     = uniqrows(group)
	incstep = J(rows(steps),1,NULL)
		
	fest = (st_local("std")~="" ? J(2,3,NULL) : J(1,3,NULL)) 			
	for (i=1; i<=rows(steps); i++) { // compute indicator for each path	
		path = tokens(*steps[i,1])
		pos = tokens(*steps[i,2])
		incpos = J(1,cols(pos),NULL)
		for (j=1; j<=cols(path); j++) {						
			X = _fsubmatrix((inclist[.,strtoreal(pos[j])], wt, pline, group, by), 5, minmax[1,1])	
			if (i==rows(steps) & st_local("residual")=="") X = _fsubmatrix((inclist[.,1], wt, pline, group, by), 5, minmax[2,1])	
			ind0 = J(1,3,NULL)						
			if (st_local("indicator")~="") ind0[1] = &(_fcompind(X))           // a==1 is indicator list
			if (st_local("mpl")~="")       ind0[2] = &(_fcompindcmpl(X))       // a==2 is MPL list		
			if (st_local("gic")~="")       ind0[3] = &(_fcompincbins(X))	   // a==3 is income bins
			incpos[j] = pointer_clone(ind0)
		} // for j
		incstep[i] = pointer_clone(incpos)
	} // for i
		
	if (st_local("indicator")~="" | st_local("mpl")~="") { // index of the indicators
		y0 = J(0,1,.)
		for (i=1; i<=cols(indlist); i++) {
			if (indlist[i]=="fgt0")  y0 = y0 \ 0
			if (indlist[i]=="fgt1")  y0 = y0 \ 1
			if (indlist[i]=="fgt2")  y0 = y0 \ 2
			if (indlist[i]=="gini")  y0 = y0 \ 3
			if (indlist[i]=="theil") y0 = y0 \ 4
			if (indlist[i]=="mean")  y0 = y0 \ 5
			if (indlist[i]=="bottom") y0 = y0 \ 6
			if (indlist[i]=="top")   y0 = y0 \ 7
			if (indlist[i]=="ratio")  y0 = y0 \ 8
			if (indlist[i]=="middle")  y0 = y0 \ 9
		}
		beffind = J(0,3+rows(gr0),.)
		beffmpl = J(0,3+rows(gr0)*(cols(mpl)+1),.)
	}
	if (st_local("gic")~="") {  // index for income bins
		index = runningsum(J(bin,1,1))
		beffect = J(0,3+rows(gr0),.)
	}
	for (i=2; i<=rows(steps); i++) { // compute the effects
		path = tokens(*steps[i,1])
		pos = tokens(*steps[i,2])		
		path_a = tokens(*steps[i-1,1])
		for (a=1; a<=cols(path_a); a++) {
			for (j=1; j<=cols(path); j++) {			
				out = _fcheck(path[j], path_a[a])
				if (out[1,1]==1) {
					if (st_local("indicator")~="") { // structure: beffect = bindex, bstep, beffect, brate*group
						if (method=="difference") diff = *(*(*incstep[i])[j])[1] :- *(*(*incstep[i-1])[a])[1]
						if (method=="growth")      diff = ln(*(*(*incstep[i])[j])[1] :/ *(*(*incstep[i-1])[a])[1])												
						beffind = beffind \ (y0, J(rows(diff),1,i-1), J(rows(diff),1,out[1,2]), diff)
					}
					if (st_local("mpl")~="") { // structure: beffect = bindex, bstep, beffect, brate*mpl*group
						if (method=="difference") diff = *(*(*incstep[i])[j])[2] :- *(*(*incstep[i-1])[a])[2]
						if (method=="growth") diff = ln(*(*(*incstep[i])[j])[2] :/ *(*(*incstep[i-1])[a])[2])						
						beffmpl = beffmpl \ (y0, J(rows(diff),1,i-1), J(rows(diff),1,out[1,2]), diff)
					}
					if (st_local("gic")~="") {	// structure: beffect = bindex, bstep, beffect, brate*group		 		
						if (method=="difference") diff = *(*(*incstep[i])[j])[3] :- *(*(*incstep[i-1])[a])[3]
						if (method=="growth") diff = ln(*(*(*incstep[i])[j])[3] :/ *(*(*incstep[i-1])[a])[3])
						beffect = beffect \ (index, J(rows(diff),1,i-1), J(rows(diff),1,out[1,2]), diff)
					}
				} // if
			} // for a
		} // for j
	} // for i
		
	// residual and total change		
	X1 = _fsubmatrix((inclist[.,1], wt, pline, group, by), 5, minmax[2,1])	
	X2 = _fsubmatrix((inclist[.,1], wt, pline, group, by), 5, minmax[1,1])
	X3 = _fsubmatrix((inclist[.,cols(inclist)], wt, pline, group, by), 5, minmax[1,1])
	fact = round(exp(lnfactorial(ncomp)),1)/ncomp
	
	if (st_local("indicator")~="") { // a==1 is indicator list
		beffind_t1 = _fcompind(X1)
		beffind_t2 = _fcompind(X2)
		beffind_t3 = _fcompind(X3)	
		if (method=="difference") {
			beffind = beffind \ (y0, J(rows(beffind_t1),1,.), J(rows(beffind_t1),1,ncomp+1), beffind_t1 :- beffind_t2) // Total change
			if (st_local("residual")~="") beffind = beffind \ (y0, J(rows(beffind_t1),1,.), J(rows(beffind_t1),1,ncomp+2), beffind_t1 :- beffind_t3) // Residual change			
		}
		if (method=="growth") {
			beffind = beffind \ (y0, J(rows(beffind_t1),1,.), J(rows(beffind_t1),1,ncomp+1), ln(beffind_t1 :/ beffind_t2)) // Total ratio
			if (st_local("residual")~="") beffind = beffind \ (y0, J(rows(beffind_t1),1,.), J(rows(beffind_t1),1,ncomp+2), ln(beffind_t1 :/ beffind_t3)) // Residual ratio			
		}

		_sort(beffind, (1,2,3))				
		weight_path = fact:/mm_freq2(beffind[.,1::3])		
		m1 = _fgrmean2(beffind[.,4..cols(beffind)], (beffind[.,1], beffind[.,3]), weight_path)		
		m1 = m1[.,cols(m1)-1], m1[.,cols(m1)], m1[.,1::cols(m1)-2]		
		fest[1,1] = &(m1)
		if (st_local("std")~="") {
			s1 = _fgrstd2(beffind[.,4..cols(beffind)], (beffind[.,1], beffind[.,3]), weight_path)
			s1 = s1[.,cols(s1)-1], s1[.,cols(s1)], s1[.,1::cols(s1)-2]	
			fest[2,1] = &(s1)
		}
	}
	if (st_local("mpl")~="") {       // a==2 is MPL list
		beffmpl_t1 = _fcompindcmpl(X1)
		beffmpl_t2 = _fcompindcmpl(X2)
		beffmpl_t3 = _fcompindcmpl(X3)	
		if (method=="difference") {
			beffmpl = beffmpl \ (y0, J(rows(beffmpl_t1),1,.), J(rows(beffmpl_t1),1,ncomp+1), beffmpl_t1 :- beffmpl_t2) // Total change		
			if (st_local("residual")~="") beffmpl = beffmpl \ (y0, J(rows(beffmpl_t1),1,.), J(rows(beffmpl_t1),1,ncomp+2), beffmpl_t1 :- beffmpl_t3) // Residual change				
		}
		if (method=="growth") {
			beffmpl = beffmpl \ (y0, J(rows(beffmpl_t1),1,.), J(rows(beffmpl_t1),1,ncomp+1), ln(beffmpl_t1 :/ beffmpl_t2)) // Total ratio		
			if (st_local("residual")~="") beffmpl = beffmpl \ (y0, J(rows(beffmpl_t1),1,.), J(rows(beffmpl_t1),1,ncomp+2), ln(beffmpl_t1 :/ beffmpl_t3)) // Residual ratio				
		}
		_sort(beffmpl, (1,2,3))		
		weight_path = fact:/mm_freq2(beffmpl[.,1::3])			
		m2 = _fgrmean2(beffmpl[.,4..cols(beffmpl)], (beffmpl[.,1], beffmpl[.,3]), weight_path)
		m2 = m2[.,cols(m2)-1], m2[.,cols(m2)], m2[.,1::cols(m2)-2]		
		fest[1,2] = &(m2)
		if (st_local("std")~="") {
			s2 = _fgrstd2(beffmpl[.,4..cols(beffmpl)], (beffmpl[.,1], beffmpl[.,3]), weight_path)
			s2 = s2[.,cols(s2)-1], s2[.,cols(s2)], s2[.,1::cols(s2)-2]	
			fest[2,2] = &(s2)
		}
	}
	if (st_local("gic")~="") {      // a==3 is income bins
		beffect_t1 = _fcompincbins(X1)
		beffect_t2 = _fcompincbins(X2)
		beffect_t3 = _fcompincbins(X3)
		X2a = (minmax[1,1] > 0 ? _fsubmatrix((inclist[.,1], wt, pline, group, by), 5, minmax[1,1]) : _fsubmatrix((inclist[.,1], wt, pline, group, by), 5, minmax[2,1]))
		beffect_t2a = _fcompincbins(X2a)
		if (method=="difference") {
			beffect = beffect \ (index, J(rows(beffect_t1),1,.), J(rows(beffect_t1),1,ncomp+1), beffect_t1 :- beffect_t2) // Total change		
			if (st_local("residual")~="") beffect = beffect \ (index, J(rows(beffect_t1),1,.), J(rows(beffect_t1),1,ncomp+2), beffect_t1 :- beffect_t3) // Residual change				
		}
		if (method=="growth") {
			beffect = beffect \ (index, J(rows(beffect_t1),1,.), J(rows(beffect_t1),1,ncomp+1), ln(beffect_t1 :/ beffect_t2)) // Total ratio		
			if (st_local("residual")~="") beffect = beffect \ (index, J(rows(beffect_t1),1,.), J(rows(beffect_t1),1,ncomp+2), ln(beffect_t1 :/ beffect_t3)) // Residual ratio				
		}

		_sort(beffect, (1,2,3))		
		weight_path = fact:/mm_freq2(beffect[.,1::3])				
		m3 = _fgrmean2(beffect[.,4..cols(beffect)], (beffect[.,1], beffect[.,3]), weight_path)		
		m3 = m3[.,cols(m3)-1], m3[.,cols(m3)], m3[.,1::cols(m3)-2]:/(beffect_t2a#J((st_local("residual")~="" ? ncomp+2 : ncomp+1),1,1))				
		fest[1,3] = &(m3)
		if (st_local("std")~="") {
			s3 = _fgrstd2(beffect[.,4..cols(beffect)], (beffect[.,1], beffect[.,3]), weight_path)		
			s3 = s3[.,cols(s3)-1], s3[.,cols(s3)], s3[.,1::cols(s3)-2]:/(beffect_t2a#J((st_local("residual")~="" ? ncomp+2 : ncomp+1),1,1))				
			//s3 = s3[.,cols(s3)-1], s3[.,cols(s3)], s3[.,1::cols(s3)-2]
			fest[2,3] = &(s3)
		}		
	}
	return(fest)
}

// function to get mean, keep group vars in
function _fgrmean2(real matrix X, real matrix gr, |real colvector w) {
	if (args()==2) w = J(rows(X),1,1)
	gr0 = _fgroup2var(gr)	
	data = runningsum(J(rows(X),1,1)), X, gr, w, gr0
	_sort(data,cols(data))
	info = panelsetup(data,cols(data))
	if (rows(info)~=max(gr0)) {
		_error(3200, "Mismatch between the number of groups and observations - check the number of sum(weight)/bins")
		exit(error(3200))
	}
	means = J(rows(info),cols(X)+cols(gr),.)
	for (i=1; i<=rows(info); i++) {
		Xi = data[|info[i,1],2            \ info[i,2],cols(data)-2|]
		wi = data[|info[i,1],cols(data)-1 \ info[i,2],cols(data)-1|]
		means[i,.] = mean(Xi,wi)
	}
	return(means)
}

// function to get standard errors, keep group vars in
function _fgrstd2(real matrix X, real matrix gr, |real colvector w) {
	if (args()==2) w = J(rows(X),1,1)
	gr0 = _fgroup2var(gr)	
	data = runningsum(J(rows(X),1,1)), X, gr, w, gr0
	_sort(data,cols(data))
	info = panelsetup(data,cols(data))
	if (rows(info)~=max(gr0)) {
		_error(3200, "Mismatch between the number of groups and observations - check the number of sum(weight)/bins")
		exit(error(3200))
	}
	vars = J(rows(info),cols(X)+cols(gr),.)
	for (i=1; i<=rows(info); i++) {
		Xi = data[|info[i,1],2            \ info[i,2],cols(data)-2|]
		wi = data[|info[i,1],cols(data)-1 \ info[i,2],cols(data)-1|]		
		vars[i,.] = diagonal(sqrt(quadvariance(Xi,wi)))'
	}
	return(vars)
}

// function to compute income bin, X = inclist, wt, pline, group
function _fcompincbins(real matrix X) {
	bin = strtoreal(st_local("gic"))
	gr = uniqrows(X[.,4])
	indgr = J(bin,0,.)
	for (j=1; j<=rows(gr); j++) {
		X1 = (rows(gr)==1 ? X : _fsubmatrix(X, 4, gr[j,1]))
		indgr = indgr, _fgrmean(X1[.,1], _fpctile(X1[.,1], bin, X1[.,2]), X1[.,2])
	}
	return(indgr)
}

// function to compute indicators with MPL, X = inclist, wt, pline, group
function _fcompindcmpl(real matrix X) {
	indlist = tokens(st_local("indicator"))
	gr = uniqrows(X[.,4])
	mpl = strtoreal(tokens(st_local("mpl")))
	btm = strtoreal(st_local("bottom"))
	top = strtoreal(st_local("top"))
	mid = strtoreal(tokens(st_local("middle")))
	indgr = J(cols(indlist),0,.)
	for (j=1; j<=rows(gr); j++) {
		X1 = (rows(gr)==1 ? X : _fsubmatrix(X, 4, gr[j,1]))
		for (a=1; a<=cols(mpl)+1; a++) {
			y = J(0,1,.)
			z0 = (a==1|a==cols(mpl)+1 ? J(rows(X1),1,0) : mpl[1,a-1]:*X1[.,3])
			z1 = (a==cols(mpl)+1 ? mpl[cols(mpl)]:*X1[.,3] : mpl[1,a]:*X1[.,3])
			for (i=1; i<=cols(indlist); i++) {
				if (indlist[i]=="fgt0")  y = y \ _ffgt0(X1[.,1], z0, z1, X1[.,2])
				if (indlist[i]=="fgt1")  y = y \ _ffgt1(X1[.,1], z0, z1, X1[.,2])
				if (indlist[i]=="fgt2")  y = y \ _ffgt2(X1[.,1], z0, z1, X1[.,2])
				if (indlist[i]=="gini")  y = y \ _fgini(X1[.,1], z0, z1, X1[.,2])
				if (indlist[i]=="theil") y = y \ _ftheil(X1[.,1], z0, z1, X1[.,2])			
				if (indlist[i]=="mean")  y = y \ _fmean(X1[.,1], z0, z1, X1[.,2])			
				if (indlist[i]=="bottom") y = y \ _fbottom(X1[.,1], z0, z1, X1[.,2], btm)							
				if (indlist[i]=="top")   y = y \ _ftop(X1[.,1], z0, z1, X1[.,2], top)			
				if (indlist[i]=="ratio") y = y \ _fratio(X1[.,1], z0, z1, X1[.,2], btm)			
				if (indlist[i]=="middle") y = y \ _fmiddle(X1[.,1], z0, z1, X1[.,2], mid[1,1], mid[1,2])			
			} // for i - each indicator
			indgr = indgr, y
		} // for each mpl value		
	} // for each group j
	return(indgr)
}

// function to compute indicators, X = inclist, wt, pline, group
function _fcompind(real matrix X) {
	indlist = tokens(st_local("indicator"))
	btm = strtoreal(st_local("bottom"))
	top = strtoreal(st_local("top"))
	mid = strtoreal(tokens(st_local("middle")))
	gr = uniqrows(X[.,4])
	indgr = J(cols(indlist),0,.)	
	for (j=1; j<=rows(gr); j++) {
		X1 = (rows(gr)==1 ? X : _fsubmatrix(X, 4, gr[j,1]))		
		y = J(0,1,.)		
		z0 = J(rows(X1),1,0)
		for (i=1; i<=cols(indlist); i++) {
			if (indlist[i]=="fgt0")  y = y \ _ffgt0(X1[.,1], z0, X1[.,3], X1[.,2])
			if (indlist[i]=="fgt1")  y = y \ _ffgt1(X1[.,1], z0, X1[.,3], X1[.,2])
			if (indlist[i]=="fgt2")  y = y \ _ffgt2(X1[.,1], z0, X1[.,3], X1[.,2])
			if (indlist[i]=="gini")  y = y \ _fgini(X1[.,1], z0, X1[.,3], X1[.,2])
			if (indlist[i]=="theil") y = y \ _ftheil(X1[.,1], z0, X1[.,3], X1[.,2])			
			if (indlist[i]=="mean")  y = y \ _fmean(X1[.,1], z0, X1[.,3], X1[.,2])			
			if (indlist[i]=="bottom") y = y \ _fbottom(X1[.,1], z0, X1[.,3], X1[.,2], btm)						
			if (indlist[i]=="top")   y = y \ _ftop(X1[.,1], z0, X1[.,3], X1[.,2], top)			
			if (indlist[i]=="ratio") y = y \ _fratio(X1[.,1], z0, X1[.,3], X1[.,2], btm)
			if (indlist[i]=="middle") y = y \ _fmiddle(X1[.,1], z0, X1[.,3], X1[.,2], mid[1,1], mid[1,2])			
		}
		indgr = indgr, y
	}	
	return(indgr)
}

function _fgroup2var(real matrix X) {
	data =  runningsum(J(rows(X),1,1)), X
	out = J(rows(X),1,.)
	_sort(data,(2,3))
	pathfreq = mm_freq(data[.,2::3])
	t = s0 = 1		
	s1 = 0
	for (i=1; i<=rows(pathfreq); i++) {				
		s = pathfreq[i,1]
		s1 = s1 + s
		out[s0..s1,1] = J(s,1,t)
		t = t + 1
		s0 = s0 + s		
	}
	data = data, out
	_sort(data,1)
	return(data[.,4])
}

pointer (transmorphic matrix) scalar pointer_clone(transmorphic matrix X) {
	transmorphic matrix Y
	return(&(Y = X))
}

// generate all possible combination of paths
function _fpaths(factors) {
	str0 = str1 = tokens("0 1")		
	t=1	
	while (t<factors) {
		str2 = J(1, 0, "")
		for (j=1; j<=cols(str1); j++) {				
			for (i=1; i<=cols(str0); i++) str2 = str2, str1[j] + str0[i]												
		}
		str1 = str2
		t++
	}
	return(str2)
}

// return paths into steps, starting with step1 (only 0000...), then step2,.... step(factor+1) and return to a pointer
function _fsteps(rowvector x) {
	pointer(string scalar) matrix steps	
	steps = J(strlen(x[1,1])+1,2,NULL)	
	for (i=1; i<=rows(steps); i++) {
		steps[i,1] = &(" ")
		steps[i,2] = &(" ")
	}	
	for (j=1; j<=cols(x); j++) {	
		a = colsum(_fmatrix(x[j]))			
		for (i=1; i<=rows(steps); i++) {
			if (i == a+1) {
				steps[i,1] = &(*steps[i,1] + " " + x[j])						
				steps[i,2] = &(*steps[i,2] + " " + strofreal(j))						
			}
		}						
	}	
	return(steps)
}

// mean by groups
function _fgrmean(real matrix X, real colvector gr, |real colvector w) {
	if (args()==2) w = J(rows(X),1,1)
	data = runningsum(J(rows(X),1,1)), X, w, gr
	_sort(data,cols(data))
	info = panelsetup(data,cols(data))
	if (rows(info)~=max(gr)) {
		_error(3200, "Mismatch between the number of groups and observations - some weight is larger than a bin weight")
		exit(error(3200))
	}
	means = J(rows(info),cols(X),.)
	for (i=1; i<=rows(info); i++) {
		Xi = data[|info[i,1],2            \ info[i,2],cols(data)-2|]
		wi = data[|info[i,1],cols(data)-1 \ info[i,2],cols(data)-1|]
		means[i,.] = mean(Xi,wi)
	}
	return(means)
}

// function to keep the original mean after swaping
function _fsamemean(real matrix Xold, real matrix Xnew, real colvector by, |real colvector w) {
	if (args()==3) w = J(rows(Xold),1,1)	
	minmax  = colminmax(by)
	data = runningsum(J(rows(Xold),1,1)), Xold, Xnew, w, by
	X1 = _fsubmatrix(data, 5, minmax[1,1])
	X2 = _fsubmatrix(data, 5, minmax[2,1])
	X1m = mean(X1)
	X2m = mean(X2)
	y = X1[.,1], X1[.,3]:*(X2m[1,2]/X1m[1,3]) \ X2[.,1], X2[.,3]:*(X1m[1,2]/X2m[1,3])
	_sort(y,1)
	return(y[.,2])
}

void function _fchangeadd(string scalar rvar, string scalar var, string scalar byvar, string scalar w, string scalar tousename, string scalar newvar) {
	rv = st_data(.,tokens(rvar), tousename)
	X  = st_data(.,tokens(var), tousename)
	by = st_data(.,tokens(byvar), tousename)
	wt = st_data(.,tokens(w), tousename)	
	nq = strtoreal(st_local("nquantiles"))	
	if (st_local("rank")=="components") { // component rank
		if (st_local("percentile")!="") nvar = _fsamemean(X, _fdistchange(X, X, by, nq, wt), by, wt) // percentile method
		//else                            nvar = _fsamemean(X, _frescale(X, X, by, wt), by, wt)        // rescale method (slow)
	}
	else {  // income or variable rank
		if (st_local("percentile")!="") nvar = _fsamemean(X, _fdistchange(rv, X, by, nq, wt), by, wt)  // percentile method
		//else                            nvar = _fsamemean(X, _frescale(rv, X, by, wt), by, wt)         // rescale method (slow)
	}
	st_store(., newvar, nvar)
}


function _frescale(real matrix Y, real matrix X, real colvector by, |real colvector wt) {
	if (args()==3) wt = J(rows(X),1,1)
	minmax = colminmax(by)
	data = runningsum(J(rows(X),1,1)), Y, X, wt, by
	_sort(data, (5,2,4))
	X1 = _fsubmatrix(data, 5, minmax[1,1])
	X2 = _fsubmatrix(data, 5, minmax[2,1])
	X1 = runningsum(J(rows(X1),1,1)), X1
	X2 = runningsum(J(rows(X2),1,1)), X2
	X1a = round(X1[.,1]:*rows(X2)/rows(X1)), X1
	X2a = round(X2[.,1]:*rows(X1)/rows(X2)), X2
	X1b = J(rows(X1a),1,.)
	X2b = J(rows(X2a),1,.)
	for (i=1; i<=rows(X1a); i++) X1b[i,1] = _fsubmatrix((X2a[.,2], X2a[.,5]), 1, X1a[i,1])
	for (i=1; i<=rows(X2a); i++) X2b[i,1] = _fsubmatrix((X1a[.,2], X1a[.,5]), 1, X2a[i,1])
	y = X1, X1b \ X2, X2b
	_sort(y, 2)
	return(y[.,cols(y)])
}
// function to lookup a value in matrix (value, part) and return the part, _fvlookup/_fsubmatrix
function _fsubmatrix(real matrix X, real scalar ncol, real scalar c) {
	if (ncol > cols(X)) {
		_error(3200, "The lookup column is out of range")
		exit(error(3200))
	}
	y = select(X, X[.,ncol]:==c)
	if (ncol==1)                 y = y[.,2::cols(y)]
	if (ncol==cols(X))           y = y[.,1::cols(y)-1]
	if (ncol>1 & ncol<cols(X))   y = y[.,1::ncol-1], y[.,ncol+1::cols(y)]	
	return(y)
}

// change distributions for matrix X - swap means for each column
function _fchangeX(real matrix X, real colvector by, real scalar nq, |real colvector w) {
	pointer(real matrix) matrix vari
	if (args()==3) w = J(rows(X),1,1)
	vari = J(cols(X),2,NULL)
	for (i=1; i<=cols(X); i++) {
		vari[i,1] = &(X[.,i])
		vari[i,2] = &(_fdistchange(X[.,i], X[.,i], by, nq, w))		
	}
	return(vari)
}
// Create variable containing percentiles
function _fpctile(real colvector X, real scalar nq, |real colvector w) {
	if (args()==2) w = J(rows(X),1,1)
	if (rows(X) < nq) {
		_error(3200, "Number of bins is more than the number of observations")
		exit(error(3200))	
	}
	data = runningsum(J(rows(X),1,1)), X, w
	_sort(data,(2,1))
	nq0 = quadsum(data[.,3])/nq	
	q = trunc((quadrunningsum(data[.,3]):/nq0):-0.0000000000001):+1	
	data = data, q
	_sort(data,1)
	return(data[.,4])
}

// change distribution - swap means for 1 vector, _fdistchange(rank vector, calculate vector, by, nw, wt)
function _fdistchange(real colvector Y, real colvector X, real colvector by, real scalar nq, |real colvector w) {
	if (args()==4) w = J(rows(X),1,1)
	pointer(real matrix) vector Xi, means, Mi, infoi
	y1=y2=J(0,1,.)	
	data = runningsum(J(rows(X),1,1)), Y, X, w, by
	_sort(data,cols(data))
	info = panelsetup(data,cols(data))
	Xi = Mi = means = infoi = J(rows(info),1,NULL)
	for (i=1; i<=rows(info); i++) {
		Xi[i] = &(data[|info[i,1],1 \ info[i,2],cols(data)-1|])
		_sort(*Xi[i],(2,1))
		nq0 = quadsum((*Xi[i])[.,4])/nq		
		q = trunc((quadrunningsum((*Xi[i])[.,4]):/nq0):-0.0000001):+1				
		means[i] = &(_fgrmean((*Xi[i])[.,3], q, (*Xi[i])[.,4]))		
		Mi[i] = &(*Xi[i], q, J(rows(*Xi[i]),1,1))
		infoi[i] = &(panelsetup(*Mi[i],5))
	}	
	for (i=1; i<=rows(*infoi[1]); i++) y1 = y1 \ (*Mi[1])[|(*infoi[1])[i,1],6 \ (*infoi[1])[i,2],6|]#(*means[2])[i]
	for (i=1; i<=rows(*infoi[2]); i++) y2 = y2 \ (*Mi[2])[|(*infoi[2])[i,1],6 \ (*infoi[2])[i,2],6|]#(*means[1])[i]	
	y = (*Mi[1], y1) \ (*Mi[2], y2)		
	_sort(y,1)
	return(y[.,7])
}

// sum of all elements in a path
function _fmatrix(string x) {	
	outm = J(strlen(x), 1, .)
	for (i=1; i<=strlen(x); i++) outm[i,1] = strtoreal(substr(x,i,1))
	return(outm)
}

// check condition of 2 eligible paths
function _fcheck(string v, string u) {
	out = J(1,2,.)
	v1u1 = _fmatrix(v) :- _fmatrix(u)
	min = colmin(v1u1)
	if (min[1,1] < 0) {
		out[1,1] = 0
	}
	else {
		out[1,1] = 1	
		for (i=1; i<=rows(v1u1); i++) if (v1u1[i]==1) out[1,2] = i					
	}
	return(out)
}

// theil index, alpha=1
function _ftheil(x, z0, z1, w) {	
	return(mean((x:/mean(x)):*ln(x:/mean(x))))
}
// mean function
function _fmean(x, z0, z1, w) {
	return(mean(x, w))
}

// bottom mean function
function _fbottom(x, z0, z1, w, btm) {
	x1 = x, w, _fpctile(x, 100, w)
	x2 = select(x1, x1[.,cols(x1)]:<=btm)
	return(mean(x2[.,1], x2[.,2]))
}
// top mean function
function _ftop(x, z0, z1, w, top) {
	x1 = x, w, _fpctile(x, 100, w)
	x2 = select(x1, x1[.,cols(x1)]:>=top)
	return(mean(x2[.,1], x2[.,2]))
}
// ratio of bottom mean over all mean
function _fratio(x, z0, z1, w, btm) {
	x1 = x, w, _fpctile(x, 100, w)
	x2 = select(x1, x1[.,cols(x1)]:<=btm)
	return(mean(x2[.,1], x2[.,2])/mean(x,w))
}
// middle mean function
function _fmiddle(x, z0, z1, w, mid1, mid2) {
	x1 = x, w, _fpctile(x, 100, w)	
	x2 = select(x1, (x1[.,cols(x1)]:>mid1) :+ (x1[.,cols(x1)]:<mid2) :-1)
	return(mean(x2[.,1], x2[.,2]))
}

// gini coefficient (fastgini formula)
function _fgini(x, z0, z1, w) {
	t = x,w
	_sort(t,1)
	x=t[.,1]
	w=t[.,2]
	xw = x:*w
	rxw = quadrunningsum(xw) :- (xw:/2)
	return(1- 2*((quadcross(rxw,w)/quadcross(x,w))/quadcolsum(w)))
}

// function to return 1 if matrix is between z0, z1
function _franges(inc, z0, z1) {
	if (z0[1]==0) {		
		return(inc:< z1)
	}
	else {
		a = z0 :<= inc
		b = inc:< z1
		c = a:+b
		return(c:==2)
	}	
}

function _ffgt(inc, z0, z1, wt, alpha) {
	return(mean(_franges(inc, z0, z1):*(((z1:-inc):/z1):^alpha),wt))
}

function _ffgt0(inc, z0, z1, wt) {	
	return(100*mean(_franges(inc, z0, z1):*(((z1:-inc):/z1):^0),wt))
}

function _ffgt1(inc, z0, z1, wt) {				
	return(100*mean(_franges(inc, z0, z1):*(((z1:-inc):/z1):^1),wt))
}

function _ffgt2(inc, z0, z1, wt) {		
	return(100*mean(_franges(inc, z0, z1):*(((z1:-inc):/z1):^2),wt))
}

function _fclk(inc, z0, z1, wt, alpha) {
	return(mean(_franges(inc, z0, z1):*((1:-((inc:/z1):^alpha)):/alpha), wt))
}

function _fwatts(inc, z0, z1, wt) {
	return(mean(_franges(inc, z0, z1):*(ln(z1):-ln(inc)),wt))
}

// adopted from moremata mm_freq
real colvector mm_freq(transmorphic matrix x, | real colvector w, transmorphic matrix levels) {
	real colvector p
	if (args()<2) w = 1
	if (args()<3) levels = .
	if (cols(x)==0) return(_mm_freq(x, w, levels))
	if (rows(w)==1) return(_mm_freq(sort(x,1..cols(x)), w, levels))
	p = order(x,1..cols(x))
	return(_mm_freq(x[p,], w[p,], levels))
}

real colvector _mm_freq(transmorphic matrix x, | real colvector w, transmorphic matrix levels) {
	real scalar    i, j, l
	real colvector result
	if (args()<2) w = 1
	if (args()<3) levels = .
	if (rows(w)!=1 & rows(w)!=rows(x)) _error(3200)
	if (levels==.) levels = _mm_uniqrows(x)
	if (rows(x)==0) return(J(0,1, .))
	l = rows(levels)
	result = J(l,1,0)
	j = 1
	for (i=1; i<=rows(x); i++) {
			for (;j<=l;j++) {
					if (x[i,]==levels[j,]) break
			}
			if (j>l) break
			result[j] = result[j] + (rows(w)!=1 ? w[i] : w)
	}
	return(result)
}

real colvector mm_freq2(transmorphic matrix x,| real colvector w) {
    real colvector p
    if (args()<2) w = 1
    if (cols(x)==0) return(_mm_freq2(x, w))
    p = order(x,1..cols(x))
    if (rows(w)==1) return(_mm_freq2(x[p,],w)[invorder(p)])
    return(_mm_freq2(x[p,],w[p,])[invorder(p)])
}

real colvector _mm_freq2(transmorphic matrix x,| real colvector w) {
    real scalar    i, j
    real colvector result
    if (args()<2) w = 1
    if (rows(w)!=1 & rows(w)!=rows(x)) _error(3200)
    if (rows(x)==0) return(J(0, 1, .))
    result = J(rows(x),1,.)
    j = 1
    for (i=2; i<=rows(x); i++) {
        if (x[i,]!=x[i-1,]) {
            result[|j \ i-1|] = J(i-j, 1, (rows(w)==1 ? (i-j)*w : sum(w[|j \ i-1|])))
            j = i
        }
    }
    result[|j \ i-1|] = J(i-j, 1, (rows(w)==1 ? (i-j)*w : sum(w[|j \ i-1|])))
    return(result)
}

transmorphic matrix _mm_uniqrows(transmorphic matrix x) {
	real scalar             i, j, n, ns
	transmorphic matrix     res
	if (rows(x)==0) return(J(0,cols(x), missingof(x)))
	if (cols(x)==0) return(J(1,0, missingof(x)))
	ns = 1
	n = rows(x)
	for (i=2;i<=n;i++) {
			if (x[i-1,]!=x[i,]) ns++
	}
	res = J(ns, cols(x), x[1,1])
	res[1,] = x[1,]
	for (i=j=2;i<=n;i++) {
			if (x[i-1,]!=x[i,]) res[j++,] = x[i,]
	}
	return(res)
}

end
