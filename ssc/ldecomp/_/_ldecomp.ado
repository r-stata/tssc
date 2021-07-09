*! version 1.1.6 MLB 15Jan2014
* version 1.1.5 MLB 27Okt2010
* version 1.1.4 MLB 13Jan2010
* version 1.1.2 MLB 22Jun2009
* remove a -set trace on-
* version 1.1.1 MLB 22Nov2008
* fixed bug with obspr option
* version 1.1.0 MLB 31Mar2008
* bootstrap standard errors
* version 1.0.2 MLB 22Feb2008
* fix a bug in in the -normal- option
program define _ldecomp, eclass properties(or)
	version 9.0
	syntax varlist [if] [in] [fw iw pw], ///
	Direct(varname)                      ///
	Indirect(varlist)                    /// 
	[                                    /// 
	at(string)                           ///
	OBSpr                                ///
	PREDPr                               ///
	PREDOdds                             ///
	RIndirect                            ///
	or                                   ///
	noLEGend                             ///
	noDEComp                             ///
	INTeractions                         ///
	NORMal                               ///
	range(numlist min=2 max=2)           ///
	nip(integer 1000)                    ///
	Reps(passthru)                       ///
	STRata(passthru)                     ///
	SIze(passthru)                       ///
	CLuster(passthru)                    ///
	IDcluster(passthru)                  ///
	SAVing(passthru)                     ///
	bca                                  ///
	mse                                  ///
	Level(passthru)                      ///
	nodots                               ///
	seed(passthru)                       ///
	JACKknifeopts(passthru)              ///
	noBOOTstrap                          ///
	]
	
	marksample touse
	markout `touse' `direct' `indirect'
	
	// remove the direct and indirect variables from varlist
	local varlist : list varlist - direct
	local varlist : list varlist - indirect

	// split varlist into dependent (lhs) and control (rhs) variables
	gettoken lhs rhs : varlist
	

	local wgt "[`weight'`exp']"
	if "`weight'" == "pweight" {
		local swgt "[aw`exp']"
	}
	else {
		local swgt "[`weight'`exp']"
	}
	
	if "`range'" != "" & "`normal'" == "" {
		di as err "option range() may only be specified if option normal is also specified"
		exit 198
	}
	if `nip' != 1000 & "`normal'" == "" {
		di as err "option nip() may only be specified if option normal is also specified"
		exit 198
	}
	if `: word count `indirect'' > 1 & "`normal'" != "" {
		di as err "option indirect() may contain only one variable if option normal is specified"
		exit 198
	}
	
	// Parse at()
	local i = 1
	while "`at'" != "" {
		gettoken block at : at, parse(";")
		local ok = `: word count `block'' == 2
		local atvar`i' : word 1 of `block'
		local atval`i' : word 2 of `block'
		capture unab atvar`i' : `atvar`i'', max(1)
		if _rc local ok = 0
		if !`: list atvar`i' in rhs' local ok = 0
		capture confirm number `atval`i'' 
		if _rc {
			capture confirm scalar `atval`i''
			if _rc local ok = 0
		}
		gettoken semicolon at : at, parse(";")
		if  !`ok' {
			di as error "each element in the at() option must contain of two elements"
			di as error "the first element is one of the control variables and the second element its value"
			exit 198
		}
		local atvars "`atvars' `atvar`i''"
		local `i++'
	}
	local k_at = `i' - 1
	local rest : list rhs - atvars

	// compute predicted and counterfactual proportions
	preserve
	
	qui levelsof `direct' if `touse'
	local levs "`r(levels)'"
	
	local i = 1

	tempname prop odds prop_obs b
	local k : word count `levs'
	matrix `prop_obs' = J(`k',1,.)
	
	foreach lev in `levs' {
		tempvar d`lev'
		qui gen byte `d`lev'' = `direct' == `lev' if `touse'
		local dirvars "`dirvars' `d`lev''"
		if "`interactions'" != "" {
			foreach var of varlist `indirect' {
				tempvar d`lev'X`var'
				qui gen `d`lev'X`var'' = `d`lev'' * `var' if `touse'
				local dirvars "`dirvars' `d`lev'X`var''"
			}
		}
	}
	
	if "`interactions'" == "" {
		local indir "`indirect'"
	}
	else {
		local indir ""
	}
	
	qui logit `lhs' `rhs' `indir' `dirvars' if `touse' `wgt', nocons
	
	if "`normal'" == "" {
		forvalues i = 1/`k_at' {
			qui replace `atvar`i'' = `atval`i''
		}
		if "`rest'" != "" {
			foreach var of varlist `rest' {
				sum `var' if `touse' `swgt', meanonly
				qui replace `var' = r(mean)
			}
		}
		local i = 1
		foreach lev in `levs' {
			qui replace `d`lev'' = 1 if `touse'
			if "`interactions'" != "" {
				foreach var of varlist `indirect' {
					qui  replace `d`lev'X`var'' = `var' if `touse'
				}
			}
			local restvals : list levs - lev
			foreach rest in `restvals' {
				qui replace `d`rest'' = 0 if `touse'
				if "`interactions'" != "" {
					foreach var of varlist `indirect' {
						qui  replace `d`rest'X`var'' = 0 if `touse'
					}
				}
			}
			tempvar pr`lev'
			local pr "`pr' `pr`lev''"
			qui predict double `pr`lev'' if `touse', pr
			local vallab : label (`direct') `lev' 
			local vallab : subinstr local vallab " " "_", all
			local coln "`coln' association:`vallab'"
			local rown "`rown' `vallab'"
			sum `lhs' if `direct' == `lev' & `touse' `swgt', meanonly
			matrix `prop_obs'[`i',1] = `r(mean)'
			local `i++'
		}
		collapse (mean) `pr' if `touse' `wgt', by(`direct')
		mkmat `pr', matrix(`prop')
	}
	
	if "`normal'" != ""{
		foreach lev in `levs' {
			tempname m`lev' sd`lev'
			qui sum `indirect' if `direct' == `lev' & `touse' `swgt'
			scalar `m`lev'' = r(mean)
			scalar `sd`lev'' = r(sd)
		}
	
		tempvar y x
	
		if "`range'" == "" {
			qui sum `indirect' if `touse' `swgt', meanonly
			local low =  r(min) - .1*(r(max) - r(min))
			local high = r(max) + .1*(r(max) - r(min))
			qui range `x' `low' `high' `nip'
		}
		else {
			qui range `x' `range' `nip'
		}
		qui gen `y' = .
		
		matrix `prop' = J(`k', `k', .)
		
		forvalues i = 1/`k_at' {
			local fixat "_b[`atvar`i'']*`atval`i'' + `fixat'"
		}
		if "`rest'" != "" {
			foreach var of varlist `rest' {
				sum `var' if `touse', meanonly
				local fixrest "_b[`var']*`r(mean)' + `fixrest'"
			}
		}
		local i = 1
		foreach lev in `levs' {
			local j = 1
			if "`interactions'" == "" {
				local indir "_b[`indirect']*`x' + "
				local int ""
			}
			else {
				local indir ""
				local int "+ _b[`d`lev'X`indirect'']*`x'"
			}
			foreach lev2 in `levs' {
				qui replace `y' = normalden(`x', scalar(`m`lev2''), scalar(`sd`lev2''))* ///
					          invlogit(`indir' `fixat' `fixrest' _b[`d`lev''] `int') 
				qui integ `y' `x'
				matrix `prop'[`j', `i'] = `r(integral)'
				local `j++'	
			}
			sum `lhs' if `direct' == `lev' & `touse' `swgt', meanonly
			matrix `prop_obs'[`i',1] = `r(mean)'
			local `i++'
			local vallab : label (`direct') `lev' 
			local vallab : subinstr local vallab " " "_", all
			local coln "`coln' association:`vallab'"
			local rown "`rown' `vallab'"
			local title2 "(assuming that `indirect' is normally distributed)"
		}
	}
	
	restore	

// decompose total effect into direct and indirect effects	
	mata: decomp_lor()

// display results	
	matrix rownames `prop_obs' = `rown'
	matrix colnames `prop_obs' = "proportion"

	matrix rownames `prop' = `rown'
	matrix colnames `prop' = `coln'
	matrix rownames `odds' = `rown'
	matrix colnames `odds' = `coln'

	forvalues i= 1/`k' {
		local l = `i' + 1
		forvalues j = `l'/`k'{
			local eq "`: word `j' of `levs''/`:word `i' of `levs''"
			local rown2 "`rown2' `eq':total `eq':indirect1 `eq':direct1 `eq':indirect2 `eq':direct2 " 
		}
	}
	forvalues i= 1/`k' {
		local l = `i' + 1
		forvalues j = `l'/`k'{
			local eq "`: word `j' of `levs''/`:word `i' of `levs''"
			local rown2 "`rown2' `eq'r:method1 `eq'r:method2 `eq'r:average"
		}
	}
	matrix colnames `b'  = b
	matrix rownames `b'  = `rown2'
	matrix `b' = `b''
	ereturn post `b', esample(`touse')
	ereturn scalar k_eform = comb(`: word count `levs'',2)
	ereturn matrix prop_obs = `prop_obs'
	ereturn matrix prop_pred = `prop'
	ereturn matrix odds_pred = `odds'
end

mata:
void decomp_lor() {
	matname = st_local("prop")
	matodds = st_local("odds")
	matdist = st_local("b")
	prop = st_matrix(matname)
	odds = prop :/ (1:- prop)
	st_matrix(matodds, odds)
	r = 
	b = J(comb(rows(prop),2):*8,1,.)
	k=1
	for(i=1;i<=rows(odds);i++){
		for(j=i+1;j<=rows(odds);j++) {
			b[k,1] = ln(odds[j,j]/odds[i,i])
			k = k + 1
			b[k,1] = ln(odds[j,i]/odds[i,i])
			k = k + 1
			b[k,1] = ln(odds[j,j]/odds[j,i])
			k = k + 1
			b[k,1] = ln(odds[j,j]/odds[i,j])
			k = k + 1
			b[k,1] = ln(odds[i,j]/odds[i,i])
			k = k + 1
		}
	}	
	l=1
	for(i=1;i<=rows(odds);i++) {
		for(j=i+1;j<=rows(odds);j++) {
			b[k,1] = b[l+1,1]/b[l,1]
			k = k + 1
			b[k,1] = b[l+3,1]/b[l,1]
			k = k + 1
			b[k,1] = (b[k-1,1]+b[k-2,1])/2
			k = k + 1
			l=l+5
		}
	}
	st_matrix(matdist, b)
}
end
