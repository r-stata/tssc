*! version 1.0.2, Ben Jann, 28jun2005

program define smithwelch, rclass sortpreserve

	version 8.2
	syntax anything(name=estimates id="estimates") [ , ///
	 Reference(str) ///
	 Benchmark(str) ///
	 Adjust(passthru) ///
	 Detail Detail2(passthru) ///
	 eform ///
	 noNotes ]
	if `"`detail2'"'!="" local detail detail

//expand estimates names
	est_expand `"`estimates'"'
	local estimates "`r(names)'"
	local estimates: list uniq estimates
	if `:word count `estimates''<4 {
		di as err "too few estimates specified"
		exit 198
	}
	local est11: word 1 of `estimates'
	local est21: word 2 of `estimates'
	local est12: word 3 of `estimates'
	local est22: word 4 of `estimates'

//determine benchmark estimates
	if `"`benchmark'"'=="1" {
		local bm 1
	}
	else if `"`benchmark'"'=="2" {
		local bm 2
	}
	else if `"`benchmark'"'!="" {
		est_expand `"`benchmark'"'
		local benchmark "`r(names)'"
		local benchmark: list uniq benchmark
		if `:word count `benchmark''<2 {
			di as err "too few benchmark estimates specified"
			exit 198
		}
		local 1bm: word 1 of `benchmark'
		local 2bm: word 2 of `benchmark'
		if "`est11'"=="`1bm'" & "`est21'"=="`2bm'" local bm 1
		else if "`est12'"=="`1bm'" & "`est22'"=="`2bm'" local bm 2
		else {
			local bm bm
			local est1bm `1bm'
			local est2bm `2bm'
		}
		local 1bm
		local 2bm
	}

//determine reference estimates
	if `"`reference'"'=="1" {
		local ref 1
	}
	else if `"`reference'"'=="2" {
		local ref 2
	}
	else if `"`reference'"'!="" {
		est_expand `"`reference'"'
		local reference "`r(names)'"
		local refbm: word 3 of `reference'
		forv t=1/2 {
			local ref`t': word `t' of `reference'
		}
		local reference "`ref1' `ref2'"
		local reference: list uniq reference
		if `:word count `reference'' < 2 {
			di as err "too few reference estimates specified"
			exit 198
		}
		if ("`bm'"=="bm" & "`refbm'"=="") {
			di as err "too few reference estimates specified"
			exit 198
		}
		if "`est11'"=="`ref1'" & "`est12'"=="`ref2'"  ///
		 & ( "`bm'"!="bm" | "`est1bm'"=="`refbm'" ) local ref 1
		else if "`est21'"=="`ref1'" & "`est22'"=="`ref2'"  ///
		 & ( "`bm'"!="bm" | "`est2bm'"=="`refbm'" ) local ref 2
		else {
			local ref ref
			local estref1 `ref1'
			local estref2 `ref2'
			if "`bm'"=="bm" local estrefbm `refbm'
		}
		local ref1
		local ref2
		local refbm
	}

//get coefficients etc. from estimates
	nobreak {
		tempname hcurrent
		_est hold `hcurrent', restore nullok estsystem
		foreach gt in 11 21 12 22 1bm 2bm ref1 ref2 refbm {
			if "`est`gt''"=="" continue
			if "`est`gt''"=="." _est unhold `hcurrent'
			else qui estimates restore `est`gt''
			tempvar s`gt'
			qui gen byte `s`gt'' = e(sample)
			local wgt`gt' `e(wtype)'
			local wgt`gt': subinstr local wgt`gt' "pw" "aw"
			local wgt`gt' "`wgt`gt''`e(wexp)'"
			tempname B`gt'
			mat `B`gt'' = e(b)
			if "`est`gt''"=="." _est hold `hcurrent', restore nullok estsystem
		}
		_est unhold `hcurrent'
	}

//prepare coefficients vectors: first eqation only, transpose, harmonize varlist
	PrepareCoefs `B11' `B21' `B12' `B22' `B1`bm'' `B2`bm'' `B`ref'1' ///
	 `B`ref'2' `B`ref'`bm'' , `adjust'

//compute vectors of means
	foreach gt in 11 21 12 22 1bm 2bm ref1 ref2 refbm {
		if "`est`gt''"=="" continue
		tempname X`gt'
		GetMeans "`vvars'" "`avars'" `X`gt'' `s`gt'' "`wgt`gt''"
	}

//decomposition of differentials
	foreach t in 1 2 bm  {
		if "`t'"=="bm" & "`bm'"!="bm" continue
		forv g=1/2 {
			if "`ref'"!="" local B`g'r`t' `B`ref'`t''
			else local B`g'r`t' `B`g'`t''
		}
	}
	tempname D
	forv t=1/2 {
		mat `D' = nullmat(`D') , (`X1`t''*`B1`t''-`X2`t''*`B2`t'') , ///
		 (`X1`t''-`X2`t'')*`B2r`t'' , ///
		 `X1`t''*(`B1`t''-`B1r`t'') + `X2`t''*(`B1r`t''-`B2`t''), ///
		 (`X1`t''-`X2`t'') * (`B1r`t''-`B2r`t'')
	}
	mat rown `D' = Total
	mat coln `D' = s1:D s1:E s1:C s1:EC s2:D s2:E s2:C s2:EC

	if "`detail'"!="" {
		tempname Dv
		forv t=1/2 {
			mat `Dv' = nullmat(`Dv'), diag(`B1`t'')*`X1`t''' - diag(`B2`t'')*`X2`t''' , ///
			 diag(`B2r`t'')*(`X1`t''-`X2`t'')', ///
			 diag(`B1`t''-`B1r`t'')*`X1`t''' + diag(`B1r`t''-`B2`t'')*`X2`t''', ///
			 diag(`B1r`t''-`B2r`t'') * (`X1`t''-`X2`t'')'
		}
		mat rown `Dv' = `vars'
		CollapseMat `Dv' , `detail2'
		mat coln `Dv' = s1:D s1:E s1:C s1:EC s2:D s2:E s2:C s2:EC
	}

//decomposition of change in differentials
	forv t=1/2 {
		forv g=1/2 {
			if "`bm'"!="" {
				local B`g'`t'b `B`g'`bm''
				if "`ref'"!="" local B`g'r`t'b `B`ref'`bm''
				else local B`g'r`t'b `B`g'`bm''
			}
			else {
				local B`g'`t'b `B`g'`t''
				if "`ref'"!="" local B`g'r`t'b `B`ref'`t''
				else local B`g'r`t'b `B`g'`t''
			}
		}
	}
	tempname DD
	mat `DD' = (`X12'-`X22')*`B2r2' - (`X11'-`X21')*`B2r1', ///
	 ((`X12'-`X22')-(`X11'-`X21'))*`B2r1b' , ///
	 (`X12'-`X22')*(`B2r2'-`B2r2b') + (`X11'-`X21')*(`B2r2b'-`B2r1') , ///
	 ((`X12'-`X22')-(`X11'-`X21'))*(`B2r2b'-`B2r1b') , ///
	 (`X12'*(`B12'-`B1r2') + `X22'*(`B1r2'-`B22')) ///
	  - (`X11'*(`B11'-`B1r1') + `X21'*(`B1r1'-`B21')) , ///
	 (`X12'-`X11')*(`B11b'-`B1r1b') + (`X22'-`X21')*(`B1r1b'-`B21b') , ///
	 `X12'*((`B12'-`B1r2')-(`B12b'-`B1r2b')) ///
	  + `X22'*((`B1r2'-`B22')-(`B1r2b'-`B22b')) ///
	  + `X11'*((`B12b'-`B1r2b')-(`B11'-`B1r1')) ///
	  + `X21'*((`B1r2b'-`B22b')-(`B1r1'-`B21')) , ///
	 (`X12'-`X11')*((`B12b'-`B1r2b')-(`B11b'-`B1r1b')) ///
	  + (`X22'-`X21')*((`B1r2b'-`B22b')-(`B1r1b'-`B21b')) , ///
	 (`X12'-`X22')*(`B1r2'-`B2r2') - (`X11'-`X21')*(`B1r1'-`B2r1') , ///
	 ((`X12'-`X22')-(`X11'-`X21'))*(`B1r1b'-`B2r1b') , ///
	 (`X12'-`X22')*((`B1r2'-`B2r2')-(`B1r2b'-`B2r2b')) ///
	  + (`X11'-`X21')*((`B1r2b'-`B2r2b')-(`B1r1'-`B2r1')) , ///
	 ((`X12'-`X22')-(`X11'-`X21'))*((`B1r2b'-`B2r2b')-(`B1r1b'-`B2r1b'))
	mat rown `DD' = Total
	mat coln `DD' = dE:D dE:E dE:C dE:EC dC:D dC:E dC:C dC:EC dEC:D dEC:E dEC:C dEC:EC

	if "`detail'"!="" {
		tempname DDv
		mat `DDv' = diag(`B2r2')*(`X12'-`X22')' - diag(`B2r1')*(`X11'-`X21')', ///
		 diag(`B2r1b')*((`X12'-`X22')-(`X11'-`X21'))' , ///
		 diag(`B2r2'-`B2r2b')*(`X12'-`X22')' + diag(`B2r2b'-`B2r1')*(`X11'-`X21')' , ///
		 diag(`B2r2b'-`B2r1b')*((`X12'-`X22')-(`X11'-`X21'))' , ///
		 (diag(`B12'-`B1r2')*`X12'' + diag(`B1r2'-`B22')*`X22'') ///
		  - (diag(`B11'-`B1r1')*`X11'' + diag(`B1r1'-`B21')*`X21'') , ///
		 diag(`B11b'-`B1r1b')*(`X12'-`X11')' + diag(`B1r1b'-`B21b')*(`X22'-`X21')' , ///
		 diag((`B12'-`B1r2')-(`B12b'-`B1r2b'))*`X12'' ///
		  + diag((`B1r2'-`B22')-(`B1r2b'-`B22b'))*`X22'' ///
		  + diag((`B12b'-`B1r2b')-(`B11'-`B1r1'))*`X11'' ///
		  + diag((`B1r2b'-`B22b')-(`B1r1'-`B21'))*`X21'' , ///
		 diag((`B12b'-`B1r2b')-(`B11b'-`B1r1b'))*(`X12'-`X11')' ///
		  + diag((`B1r2b'-`B22b')-(`B1r1b'-`B21b'))*(`X22'-`X21')' , ///
		 diag(`B1r2'-`B2r2')*(`X12'-`X22')' - diag(`B1r1'-`B2r1')*(`X11'-`X21')' , ///
		 diag(`B1r1b'-`B2r1b')*((`X12'-`X22')-(`X11'-`X21'))' , ///
		 diag((`B1r2'-`B2r2')-(`B1r2b'-`B2r2b'))*(`X12'-`X22')' ///
		  + diag((`B1r2b'-`B2r2b')-(`B1r1'-`B2r1'))*(`X11'-`X21')' , ///
		 diag((`B1r2b'-`B2r2b')-(`B1r1b'-`B2r1b'))*((`X12'-`X22')-(`X11'-`X21'))'
		mat rown `DDv' = `vars'
		CollapseMat `DDv' , `detail2'
		mat coln `DDv' = dE:D dE:E dE:C dE:EC dC:D dC:E dC:C dC:EC dEC:D dEC:E dEC:C dEC:EC
	}

	tempname tDD
	forv j=1/4 {
		mat `tDD' = nullmat(`tDD'), `D'[1,`j'+4]-`D'[1,`j']
	}
	mat rown `tDD' = Total
	mat coln `tDD' = dD dE dC dEC
	if "`Dv'"!="" {
		tempname tDDv
		forv j=1/4 {
			mat `tDDv' = nullmat(`tDDv'), `Dv'[1...,`j'+4]-`Dv'[1...,`j']
		}
		mat rown `tDDv' = `: rownames `Dv''
		mat coln `tDDv' = dD dE dC dEC
	}

//display results
	if "`adjust'"!="" di as txt "(adjusted for: `adjust')"

	di _n as txt "Decompositions of individual differentials:"
	MakeTable `D' `Dv', panels("Sample 1" "Sample 2") ///
	 cols(`=4-("`ref'"!="")') skip(`=("`ref'"!="")') `eform'

	di _n as txt "Difference in (components of) differentials:"
	MakeTable `tDD' `tDDv', panels(" ") ///
	 cols(`=4-("`ref'"!="")') skip(`=("`ref'"!="")') `eform'

	di _n as txt "Decomposition of difference in differentials:"
	MakeTable `DD' `DDv', panels(`=cond("`ref'"=="","dE dC dEC","dE dC")') ///
	 cols(`=4-("`bm'"!="")') skip(`=("`bm'"!="")') `eform'

	if "`notes'"=="" {
		di _n as txt "D  = differential / difference in component of differential"
		di as txt "E  = part of D due to differences in endowments"
		di as txt "C  = part of D due to differences in coefficients"
		if "`bm'"=="" | "`ref'"=="" di as txt "EC = interaction E x C"
	}

//returns
	if "`bm'"=="bm" & "`ref'"=="ref" {
		mat `B`ref'bm' = `B`ref'bm''
		mat rown `B`ref'bm' = r1
		ret mat brb = `B`ref'bm'
	}
	if "`ref'"=="ref" {
		forv t=2(-1)1 {
			mat `Bref`t'' = `Bref`t'''
			mat rown `Bref`t'' = r1
			ret mat br`t' = `Bref`t''
		}
	}
	if "`bm'"=="bm" {
		forv g=2(-1)1 {
			mat `B`g'bm' = `B`g'bm''
			mat rown `B`g'bm' = r1
			ret mat b`g'b = `B`g'bm'
		}
	}
	forv t=2(-1)1 {
		forv g=2(-1)1 {
			ret mat X`g'`t' = `X`g'`t''
			mat `B`g'`t'' = `B`g'`t'''
			mat rown `B`g'`t'' = r1
			ret mat b`g'`t' = `B`g'`t''
		}
	}
	if "`DDv'"!="" {
		mat `DD' = `DDv' \ `DD'
	}
	ret mat DD = `DD'
	if "`Dv'"!="" {
		mat `D' = `Dv' \ `D'
	}
	ret mat D = `D'
end

program define PrepareCoefs
	syntax anything [ , adjust(str) ]
	local anything: list uniq anything
	foreach B of local anything {
		local eq: coleq `B'
		local eq: word 1 of `eq'
		mat `B' = `B'[1,"`eq':"]
		local vars "`vars'`: colnames `B'' "
	}
	local vars: list uniq vars
	if `"`adjust'"'!="" {
		capt unab temp: `adjust'
		if _rc==0 local adjust "`temp'"
		foreach var of local adjust {
			if !`:list var in vars' {
				di as err "`var' does not occur in any of the models"
				exit 198
			}
		}
		local vars: list vars - adjust
	}
	foreach var of local vars {
		capt confirm v `var'
		if _rc local avars "`avars'`var' "
		else local vvars "`vvars'`var' "
	}
	local vvars: list retok vvars
	local avars: list retok avars
	local vars: list vvars | avars
	tempname temp
	foreach B of local anything {
		mat rename `B' `temp'
		foreach var of local vars {
			local c = colnumb(`temp',"`var'")
			if `c'<. mat `B' = nullmat(`B') \ `temp'[1,`c']
			else mat `B' = nullmat(`B') \ 0
		}
		mat rown `B' = `vars'
		mat drop `temp'
	}
	c_local vars `vars'
	c_local vvars `vvars'
	c_local avars `avars'
	c_local adjust `adjust'
end

program define GetMeans, rclass
	args varlist avars mat s w
	tempname trash
	qui mat accum `trash' = `varlist' [`w'] if `s', nocons means(`mat')
	local n `r(N)'
	if substr("`w'",1,2)=="fw" sum `s' [`w'] if `s', mean
	else qui count if `s'
	if `n'!=`r(N)' {
		di as err "something's wrong: sample has missing values"
		exit 499
	}
	local n: word count `avars'
	if `n' {
		mat `mat' = `mat' , J(1,`n', 1)
	}
	mat coln `mat' = `varlist' `avars'
	mat rown `mat' = r1
end

program define CollapseMat
	syntax name [ , Detail2(str) ]
	if "`detail2'"=="" exit
	tempname temp1 temp2
	local vars: rownames `namelist'
	local ncol = colsof(`namelist')
	mat rename `namelist' `temp1'
	tokenize "`detail2'", parse(",")
	while "`1'"!="" {
		gettoken gname 1: 1, parse("=")
		mat `temp2' = J(1,`ncol',0)
		gettoken trash 1: 1, parse("=")
		unab 1: `1'
		local 1: list vars & 1
		local vars: list vars - 1
		if "`1'"!="" {
			foreach var of local 1 {
				mat `temp2' = `temp2' + `temp1'[rownumb(`temp1',"`var'"),1...]
			}
			mat rown `temp2' = `gname'
			mat `namelist' = nullmat(`namelist') \ `temp2'
			mat drop `temp2'
		}
		mac shift
		mac shift
	}
	foreach var of local vars {
		mat `namelist' = nullmat(`namelist') \ `temp1'[rownumb(`temp1',"`var'"),1...]
	}
end

prog def MakeTable
	syntax namelist(max=2) [, Panels(str asis) Cols(int 1) Skip(int 0) eform noTop Plus ]
	if "`eform'"!="" local eform exp
	local T: word 1 of `namelist'
	local D: word 2 of `namelist'
	if "`D'"!="" local vars: rownames `D'
	local cnames: colnames `T'
	local hline = `cols'*11
	if "`top'"=="" di as txt "{hline 13}{c TT}{hline `hline'}"
	local p 0
	foreach panel of local panels {
		if `p'>0 & "`D'"!="" di as txt "{hline 13}{c +}{hline `hline'}"
		if `p'==0 | "`D'"!="" {
			if "`D'"=="" di as txt _col(14) "{c |}" _c
			else di as txt %12s abbrev("`panel'",12) " {c |}" _c
			forv c=1/`cols' {
				di as txt "  " %9s "`:word `=`p'+`c'' of `cnames''" _c
			}
			di _n as txt "{hline 13}{c +}{hline `hline'}
		}
		if  "`D'"!="" {
			local r 0
			foreach var of local vars {
				local ++r
				di as txt %12s abbrev("`var'",12) " {c |}" _c
				forv c=1/`cols' {
					di as res "  " %9.0g `eform'(`D'[`r',`p'+`c']) _c
				}
				di
			}
			di as txt "{hline 13}{c +}{hline `hline'}
		}
		if "`D'"=="" di as txt %12s abbrev("`panel'",12) " {c |}" _c
		else di as txt %12s abbrev("Total",12) " {c |}" _c
		forv c=1/`cols' {
			di as res "  " %9.0g `eform'(`T'[1,`p'+`c']) _c
		}
		di
		local p = `p' + `cols' + `skip'
	}
	if "`plus'"!="" di as txt "{hline 13}{c +}{hline `hline'}
	else di as txt "{hline 13}{c BT}{hline `hline'}
end
