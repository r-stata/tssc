*! version 1.0.7, Ben Jann, 07oct2005
*! 25oct2006: renamed from -jmp- to -jmpierce-

program define jmpierce, rclass sortpreserve

	version 8.2
	syntax [anything] [ , Reference(str) Statistics(str) Blocks(passthru) ///
	 SAVe(namelist max=2) RESiduals(name) ]

//new variables
	if "`save'"!="" {
		if `: list sizeof save'==1 {
			local save=substr("`save'",1,30)
			local save1 "`save'1"
			local save2 "`save'2"
		}
		else {
			local save1: word 1 of `save'
			local save2: word 2 of `save'
		}
		confirm new variable `save1'
		confirm new variable `save2'
	}
	if "`residuals'"!="" {
		confirm new variable `residuals'
	}

//expand statistics
	Stats `statistics'

//expand estimates names
	est_expand `"`anything'"'
	local anything "`r(names)'"
	if `:word count `anything''<2 {
		di as err "to few models specified"
		exit 198
	}
	if "`:list uniq anything'"!="`anything'" {
		di as err "models not unique"
		exit 198
	}
	local est1: word 1 of `anything' //estimates of first group
	local est2: word 2 of `anything' //estimates of second group
	if `"`reference'"'=="0" local reference
	else if `"`reference'"'=="1" local reference `est1'
	else if `"`reference'"'=="2" local reference `est2'
	if `"`reference'"'!="" {
		est_expand `"`reference'"'
		local estp: word 1 of `r(names)' //reference estimates
	}

//preserve current estimates
	tempname hcurrent
	_est hold `hcurrent', restore nullok estsystem
	nobreak {

//prepare some temporary variables
		tempvar y2 r cdf
		foreach var in y2 r cdf {
			qui gen ``var'' = .
		}

//replay group estimates: compute linear prediction,
//residuals, and the cdf of the residuals
		forv g=1/2 {
			if "`est`g''"=="." _est unhold `hcurrent'
			else qui estimates restore `est`g''
			tempvar g`g' ty2 tr tcdf
			qui gen byte `g`g'' = e(sample)
			local depvar`g': word 1 of `e(depvar)'
			qui predict `ty2' if `g`g''
			cap predict `tr' if `g`g'', res
			if _rc {
				di as err "`e(cmd)' not supported; cannot compute residual distribution"
				exit 499
			}
			if "`e(wtype)'"=="pweight" local weight`g' aweight
			else local weight`g' `e(wtype)'
			local wexp`g' "`e(wexp)'"
			cumul `tr' [`weight`g''`wexp`g''] if `g`g'', g(`tcdf') equal
			foreach var in y2 r cdf  {
				qui replace ``var'' = `t`var'' if `g`g''
				drop `t`var''
			}
			if "`est`g''"=="." _est hold `hcurrent', restore nullok estsystem
		}

//apply some consistency checks
		capt assert !( `g1' & `g2' )
		if _rc {
			di as err "samples not disjunctive"
			exit 459
		}
		if ("`weight1'`wexp1'"!="`weight2'`wexp2'") {
			di as txt "(warning: models use different weights)"
		}

//replay reference estimates: compute linear prediction
		if "`estp'"=="" { //use average coefficients
			forv g=1/2 {
				if "`est`g''"=="." _est unhold `hcurrent'
				else qui estimates restore `est`g''
				if `"`blocks'"'!="" {
					tempname B`g'
					mat `B`g'' = e(b)
				}
				tempname y1`g'
				qui predict `y1`g'' if ( `g1' | `g2' )
				if "`est`g''"=="." _est hold `hcurrent', restore nullok estsystem
			}
			if `"`blocks'"'!="" {
				tempname B
				MakeAverageB `B' `B1' `B2'
				mat drop `B1' `B2'
			}
			tempname y1
			qui gen `y1' = (`y11' + `y12')/2 if ( `g1' | `g2' )
			drop `y11' `y12'
		}
		else { //use coefficients from reference model
			if "`estp'"=="." _est unhold `hcurrent'
			else qui estimates restore `estp'
			if `"`blocks'"'!="" {
				tempname B
				mat `B' = e(b)
				local firsteq: coleq `B', quoted
				local firsteq: word 1 of `firsteq'
				mat `B' = `B'[1,"`firsteq':"]
			}
			tempvar y1
			qui predict `y1' if ( `g1' | `g2' )
		}
	}

//compute average cdf of residuals
	tempvar acdf rhyp
	qui gen `rhyp' = .
	if "`estp'"=="`est1'" {
		qui gen `acdf' = `cdf' if `g1'
		qui replace `rhyp' = `r' if `g1'
	}
	else if "`estp'"=="`est2'" {
		qui gen `acdf' = `cdf' if `g2'
		qui replace `rhyp' = `r' if `g2'
	}
	else {
		cumul `r' [`weight1'`wexp1'] if ( `g1' | `g2' ) , g(`acdf') equal
	}

//compute hypothetical residuals
	tempvar trhyp
	invcdf `cdf' if `rhyp'>=. & ( `g1' | `g2' ), ref(`r' if `acdf'<.  & ( `g1' | `g2' )) ///
	 cdf(`acdf') g(`trhyp')
	qui replace `rhyp' = `trhyp' if `rhyp'>=.
	drop `trhyp'

//compute hypothetical wages
	qui replace `y1' = `y1' + `rhyp' if ( `g1' | `g2' )
	qui replace `y2' = `y2' + `rhyp' if ( `g1' | `g2' )

//calculate statistics
	local nstats: word count `stats'
	forv g=1/2 {
		tempname stats`g'
		mat `stats`g'' = J(`nstats',3,.z)
		mat rown `stats`g'' = `stats'
		mat coln `stats`g'' = y1 y2 y3
		qui su `y1' [`weight`g''`wexp`g''] if `g`g'' , `sutype'
		local r 0
		foreach stex of local stexpr {
			mat `stats`g''[`++r',1] = `stex'
		}
		qui su `y2' [`weight`g''`wexp`g''] if `g`g'' , `sutype'
		local r 0
		foreach stex of local stexpr {
			mat `stats`g''[`++r',2] = `stex'
		}
		qui su `depvar`g'' [`weight`g''`wexp`g''] if `g`g'' , `sutype'
		local r 0
		foreach stex of local stexpr {
			mat `stats`g''[`++r',3] = `stex'
		}
	}

//calculate quantity effect for groups of variables
	if `"`blocks'"'!="" {
		tempname blk
		BlockWise `blk' `B' `rhyp' `g1' "`weight1'`wexp1'" `g2' "`weight2'`wexp2'", ///
		 `blocks' stats(`stats') stexpr(`stexpr') sutype(`sutype')
	}

//compute/display decomposition components
	tempname D
	mat `D' = `stats1'[1...,3]-`stats2'[1...,3] , `stats1'[1...,1]-`stats2'[1...,1]
	mat `D' = `D', `stats1'[1...,2]-`stats2'[1...,2] - `D'[1...,2]
	mat `D' = `D', ///
	 `stats1'[1...,3]-`stats2'[1...,3] - (`stats1'[1...,2]-`stats2'[1...,2])
	mat coln `D' = T Q P U
	mat rown `D' = `stats'
	di _n as txt "Juhn-Murphy-Pierce decomposition (reference estimates: " _c
	if "`estp'"=="" di as txt "avarage coefficients)"
	else di as res "`estp'" as txt ")"
	mat list `D', nohead
	di _n as txt "T = Total difference (" as res "`est1'" as txt "-" as res "`est2'" as txt ")"
	di as txt "Q = Contribution of differences in observable quantities"
	di as txt "P = Contribution of differences in observable prices"
	di as txt ///
	 "U = Contribution of differences in unobservable quantities and prices"
	if `"`blocks'"'!="" {
		di _n as txt "Quantity effect of (blocks of) variables:"
		mat list `blk', nohead
	}

//returns
	if "`save'"!="" {
		qui gen `save1' = `y1'
		lab var `save1' ///
		 "Hypothetical distribution with fixed prices and unobservables"
		qui gen `save2' = `y2'
		lab var `save2' "Hypothetical distribution with fixed unobservables"
	}
	if "`residuals'"!="" {
		qui gen `residuals' = `rhyp'
		lab var `residuals' "Hypothetical residuals"
	}
	if `"`blocks'"'!="" {
		ret mat Qblocks = `blk'
	}
	ret mat stats2 = `stats2'
	ret mat stats1 = `stats1'
	ret mat D = `D'

end

program define Stats
	local statslist mean sd p5 p10 p25 p50 median p75 p90 p95 /*
	 */d7525 iqr d9010 d5010 d9050
	if "`0'"=="" {
		local 0 "mean"
	}
	else {
		local 0 = lower("`0'")
	}
	foreach st of local 0 {
		if substr("mean",1,max(2,length("`st'")))=="`st'" local st mean
		else if substr("median",1,max(3,length("`st'")))=="`st'" local st median
		if !`:list st in statslist' {
			di in err `"unknown statistic: `st'"'
			exit 198
		}
		local stst `st'
		if "`st'"=="median" {
			local stst p50
		}
		else if "`st'"=="iqr" {
			local stst d7525
		}
		if "`st'"=="mean" {
			if "`sutype'"=="" local sutype mean
		}
		else if "`st'"=="sd" {
			if "`sutype'"!="detail" local sutype normal
		}
		else local sutype detail
		local names "`names'`st' "
		if index("`stst'","d")==1 {
			local expr `"`expr'r(p`=substr("`stst'",2,2)')-r(p`=substr("`stst'",4,2)') "'
		}
		else {
			local expr "`expr'r(`stst') "
		}
	}
	if "`sutype'"=="normal" local sutype
	c_local sutype `sutype'
	c_local stats "`names'"
	c_local stexpr "`expr'"
end

program define MakeAverageB
	args B B1 B2
	forv g=1/2 {
		local firsteq: coleq `B`g'', quoted
		local firsteq: word 1 of `firsteq'
		mat `B`g'' = `B`g''[1,"`firsteq':"]
		local vars`g': colnames `B`g''
	}
	local vars: list vars1 | vars2
	foreach var of local vars {
		local one: list posof "`var'" in vars1
		local two: list posof "`var'" in vars2
		mat `B' = nullmat(`B'), (cond(`one',`B1'[1,`one'],0) + cond(`two',`B2'[1,`two'],0))/2
	}
	mat coln `B' = `vars'
end

program define BlockWise
	syntax anything(name=0 equalok), blocks(str) stats(str) stexpr(str) [ sutype(str) ]
	args blk B rhyp g1 weight1 g2 weight2
	local vars: colnames `B'
	tokenize `"`blocks'"', parse(",")
	while `"`1'"'!="" {
		gettoken bname 1: 1, parse("=")
		local bname: list retok bname
		gettoken trash 1: 1, parse("=")
		unab 1: `1'
		local 1: list vars & 1
		local vars: list vars - 1
		if "`1'"!="" {
			local bnames `"`bnames'`"`bname'"' "'
			local bvars `"`bvars'"`1'" "'
		}
		mac shift
		mac shift
	}
	local nblocks: word count `bnames'
	local nstats: word count `stats'
	if `nblocks'==0 c_local blocks
	else {
		tempname score btmp
		mat `blk' = J(`nstats',`nblocks',0)
		mat rown `blk' = `stats'
		mat coln `blk' = `bnames'
		if colnumb(`B',"_cons")<. { // this is for precission reasons only
			mat `btmp' = `B'[1,"_cons"]
		}
*		forv j=1/`nblocks' {
*			local vars: word `j' of `bvars' // will break if length(vars)>503
		local j 0
		foreach vars of local bvars {
			local ++j
			foreach var of local vars {
				mat `btmp' = nullmat(`btmp'), `B'[1,"`var'"]
			}
			matrix score `score' = `btmp' if `g1' | `g2'
			qui replace `score' = `score' + `rhyp' if `g1' | `g2'
			local sign "+"
			forv g=1/2 {
				qui su `score' [`weight`g''] if `g`g'' , `sutype'
				local i 0
				foreach stex of local stexpr {
					local ++i
					mat `blk'[`i',`j'] = `blk'[`i',`j'] `sign' ( `stex' )
				}
				local sign "-"
			}
			drop `score'
		}
		forv j=`nblocks'(-1)2 {
			forv i=1/`nstats' {
				mat `blk'[`i',`j'] = `blk'[`i',`j'] - `blk'[`i',`j'-1]
			}
		}
	}
end

* version 1.0.2, Ben Jann, 13jun2005
program define invcdf, byable(onecall) sort
	version 8.2
	syntax varname(numeric) [if] [in] [fw aw] , Reference(str) Generate(name) [ cdf(varname) ]
	marksample touse
	confirm new var `generate'
	capt assert inrange(`varlist',0,1) if `touse'
	if _rc {
		di as error "`varlist' not in [0,1]"
		exit 459
	}
	gettoken refvar refif: reference
	if _by() local by "by `_byvars':"
	if "`cdf'"=="" {
		tempvar cdf
		`by' cumul `refvar' `refif' [`weight'`exp'] , generate(`cdf') equal
	}
	else {
		capt assert inrange(`cdf',0,1) | ( `cdf'>=. & `refvar'>=. ) `refif'
		if _rc {
			di as error "`cdf' not in [0,1] or is incomplete"
			exit 459
		}
	}
	quietly {
		nobreak {
			tempvar id x u
			gen `: type `refvar'' `generate' = `refvar' `refif'
			expand 2 if `generate'<. & `touse'
			sort `_sortindex'
			by `_sortindex': gen byte `id' = _n
			replace `touse' = 0 if `id'==2
			replace `generate' = . if `touse'
			gen `: type `refvar'' `u' = `refvar' if `generate'<.
			gen `: type `varlist'' `x' = 1 - `varlist' if `touse'
			replace `x' = 1 - `cdf' if `generate'<. & !`touse'
			replace `generate' = -`generate' if `generate'<.
			sort `_byvars' `x' `id' `generate'
			`by' replace `u' = `u'[_n-1] if `touse'
			replace `x' = 1 - `x'
			replace `generate' = -`generate' if `generate'<.
			sort `_byvars' `x' `touse' `generate'
			`by' replace `generate' = `generate'[_n-1] if `x'==`x'[_n-1] & `touse'
			`by' replace `generate' = cond( `generate'>=. , `u' , ///
			     cond( `u'>=. , `generate', (`generate'+`u')/2 ) ) if `touse'
			replace `generate' = . if !`touse'
			drop if `id'==2
		}
	}
end
