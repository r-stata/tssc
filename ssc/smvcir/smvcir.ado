*! version 1.0.0  10dec2013
program smvcir, eclass sortpreserve
	version 13.0
        if replay() {
                if "`e(cmd)'" != "smvcir" {
                        error 301
                }
                Display `0'
                exit
        }
	gettoken cmd rest: 0, parse(" ,")
	if ("`cmd'" == "plot") {
		SmvcirPlot `rest'
		exit
	}
	else if ("`cmd'" == "std") {
		SmvcirStdCoeff `rest'
		exit
	}
	Estimate `0'
end

program Estimate, eclass sortpreserve
syntax  varlist [if] [in], 			/*        
	*/ [    Level(cilevel)  		/*
	*/		DISCLevel(integer 100)  /*
	*/		notest         		/*
	*/		noscree 		/*
	*/		noeigen			/* undoc
	*/		]

	local cmd smvcir
	local cmdline smvcir `0'
	capture assert `disclevel' > 0 
	if (_rc) {
		di as error "{bf:disclevel()} be a positive integer"
		exit 198
	}

	capture drop _smvcir*
	capture mata: mata drop _smvcir*
	tokenize `varlist'
	local groupvar `1'
	local 1 " "
	local preds `"`*'"'
	local k: word count `preds' 

	capture confirm numeric variable `groupvar'
	if (_rc > 0) {
		di as error "dependent variable is not numeric."
		exit 198
	}
	capture confirm numeric variable `preds'
	if (_rc > 0) {
		di as error "predictors are not numeric."
		exit 198 
	} 
	
	marksample touse
	qui count if `touse'
	local n = r(N)

	tempvar oorder
	gen `oorder' = _n	

	tempname GroupValues
	qui tab `groupvar' if `touse', matrow(`GroupValues')
	local g = r(r)
	
	qui by `touse' `groupvar' (`oorder'), sort : ///
		gen _smvcirgroup = 1 if _n == 1 & `touse'
	qui by `touse': replace _smvcirgroup = sum(_smvcirgroup) if `touse'

	local smvcirlist ""
	forvalues i = 1/`k' {
		qui gen double _smvcir`i' = .
		label variable _smvcir`i' "SMVCIR `i'"
		local smvcirlist `"`smvcirlist' _smvcir`i'"'
	}

	// calculate spanset
	tempname Spanset m sdiag
	SpansetUnbiased `preds' if `touse', ///
		group(_smvcirgroup) k(`k') g(`g') 		
	matrix `Spanset' = r(spanset)
	matrix `m' = r(m)
	matrix `sdiag' = r(sdiag)

	// calculate SVD of spanset
	mata: _smvcir_U = J(`k',`k',.)
	mata: _smvcir_Vt = J(2*`g'+`g'*`k'*`k', 2*`g'+`g'*`k'*`k',.)
	mata: _smvcir_s = J(`k',1,.)	
	mata: fullsvd(st_matrix("`Spanset'"),_smvcir_U, ///
		_smvcir_s,_smvcir_Vt)	
	tempname U Vt Sv
	mata: st_matrix("`U'",_smvcir_U)
	mata: st_matrix("`Vt'",_smvcir_Vt)
	mata: st_matrix("`Sv'",_smvcir_s')

	// calculate kernel and its eigen decomposition
	tempname Kernel
	matrix `Kernel' = `Spanset'*(`Spanset'')
	if ("`eigen'" != "noeigen") {
		tempname Spanset_eigvecs Spanset_eigvals
		mata: _smvcir_eigen_vectors = J(`k',`k',.)
		mata: _smvcir_eigen_values = J(`k',1,.)
		mata: symeigensystem( 				        ///
			st_matrix("`Kernel'"), ///
			_smvcir_eigen_vectors, _smvcir_eigen_values)
		mata: _smvcir_eigen_values = sort(_smvcir_eigen_values',(-1))
		mata: st_matrix("`Spanset_eigvecs'",_smvcir_eigen_vectors)
		mata: st_matrix("`Spanset_eigvals'",_smvcir_eigen_values')
	}

	// transform data
	local i = 1
        foreach var of varlist `preds' {
		tempvar std_`var'
		gen double `std_`var'' = (`var'-`m'[`i',1])* ///
			`sdiag'[`i',`i'] if `touse'
		local stdpreds `stdpreds' `std_`var''
		local i = `i' + 1
	}
	if ("`eigen'" != "noeigen") {
		local evpassin _smvcir_eigen_vectors
	}
	else {
		local evpassin _smvcir_U
	}
	mata: st_store(., tokens(`"`smvcirlist'"'), 	///
		`"`touse'"',				///
		st_data(.,tokens(`"`stdpreds'"'), 	///
		"`touse'")*`evpassin')

	// calculate covariance of spanset
	if (`"`test'"'!= "notest") {
		mata: _smvcir_spanset_biasest = ///
			J(`k',2*`g'+`g'*`k',.)
		mata: _smvcir_spanset_covest = ///
			J(2*`g'*`k' + `g'*`k'*`k', 2*`g'*`k' + `g'*`k'*`k',.)
		mata: SpansetCovariance(`"`g'"',`"`k'"', 	///
			`"`n'"',"`preds'", 	  		///
			"_smvcirgroup","`touse'",		///
			_smvcir_spanset_biasest, 		///
			_smvcir_spanset_covest)
	}

	// perform dimensionality test
	if (`"`test'"' != "notest") {
		tempname pvals
		if ("`eigen'" == "noeigen") {
			local evpassin _smvcir_s
		}
		else {
			local evpassin _smvcir_eigen_values
		}
		mata: PValues(`k',`n',"`pvals'", 	 ///
				 _smvcir_U,_smvcir_Vt,	 ///
				 _smvcir_spanset_covest, ///
				 _smvcir_s,"`eigen'",`evpassin')
	}
	
	ereturn post , obs(`n') esample(`touse')
	ereturn matrix Spanset = `Spanset'
	ereturn matrix Spanset2 = `Kernel'
	ereturn matrix Sv = `Sv'
	ereturn matrix Spanset_U = `U'
	ereturn matrix Spanset_Vt = `Vt'
	ereturn scalar d = -1	
	if ("`eigen'" != "noeigen") {
		ereturn matrix Spanset2_eigvecs = `Spanset_eigvecs'
		ereturn matrix Spanset2_eigvals = `Spanset_eigvals'
	}	
	ereturn scalar k = `k'
	ereturn scalar g = `g'
	ereturn local predictors `preds'
	ereturn local group `groupvar'
	ereturn local predict smvcir_p
	ereturn local level `level'
	ereturn local disclevel `disclevel'
	if (`"`test'"' != "notest") {
		ereturn hidden matrix Pvals = `pvals'
		ereturn hidden local test test
	}
	else {
		ereturn hidden local test `test'
	}
	ereturn local title "SMVCIR Dimensions"
	ereturn local cmd `cmd'
	ereturn local cmdline `cmdline'
	ereturn hidden matrix GroupValues = `GroupValues'
	ereturn hidden matrix m = `m'
	ereturn hidden matrix Sndiag = `sdiag'
	ereturn hidden local noeigen `eigen'

	Display, `scree'
end

program Display
	syntax, [level(string) disclevel(string) noscree noeigen]
	if "`level'" != "" {
		CheckLevel, level(`level')
		if ("`e(test)'" == "") {
			di as text "Computing dimensionality test."
			smvcir `e(groupvar)' `e(predictors)' , ///
			level(`level') disclevel(`disclevel') `scree' `eigen'
		}
		else {
			mata: st_numscalar("e(level)",`level')
		}
	}
	else {
		local level = e(level)
	}

	if "`disclevel'" != "" {
		capture CheckDisclevel, disclevel(`disclevel')
		if (_rc) {
			di as error ///
				"{bf:disclevel()} be a positive integer"
			exit 198
		}
		mata: st_numscalar("e(disclevel)",`disclevel')
	}
	else {
		local disclevel = e(disclevel)
	}

	local k = e(k)
	di ""
	di "`e(title)'"
	di ""
	tempname mats
	matrix `mats' = e(Sv)
	forvalues i =2/`k' {
		matrix `mats'[1,`i'] = `mats'[1,`i'-1]+`mats'[1,`i']	
	}
	forvalues i=1/`k' {
		matrix `mats'[1,`i'] = `mats'[1,`i']/`mats'[1,`k']
	}
	matrix `mats' = 100*`mats''
	matrix `mats' = 0 \ `mats'
	tempname discperc
	qui svmat double `mats', names(`"`discperc'"')
	tempvar oorder
	local kbert = `k' + 1
	qui gen `oorder' = _n-1 in 1/`kbert'
	
	qui sum `oorder' if `discperc' >= `disclevel'
	local powd = r(min)
	if "`scree'" != "noscree" {
		twoway line `discperc' `oorder', ytitle("%") 	///
			xtitle("Dimensions") 			///
			yscale(r(0 100)) xscale(r(0 `k')) 	///
			`options' yline(`disclevel', 		///
			lpattern(dash) lcolor(red)) 		///
			xline(`powd', lpattern(dash) lcolor(red))
	}

	if ("`e(test)'" != "notest") {
		tempname apempmat
		matrix `apempmat' = e(Pvals)
		local apempd = -1
		forvalues i = 1/`k' {
			if ((1-`level'/100)<=`apempmat'[`i',1]) {
				local apempd = `i'-1
				continue, break	
			}
		}
		if (`apempd'==-1) {
			local apempd = e(k)
		}
		mata: st_numscalar("e(d_test)",`apempd')
		local maxd = min(`apempd',`powd')
	}
	else {
		local maxd = `powd'
	}
	mata: st_numscalar("e(d_prac)",`powd')
	mata: st_numscalar("e(d)",`maxd')	
	
	if ("`e(test)'"!= "notest") {

               di as text "        d " _col(11) "{c |}" _col(15) ///
			"    P > l"  _col(30) "% SVD"
               di as text `"{hline 10}{c +}{hline 25}"'
	       local j = `k'-1
               forvalues i = 0/`j' {
                        local apf as text
                        local df as text
                        if (`i' == `apempd') {
                                local apf as result
                        }
                        if (`i' == `powd') {
                                local df as result
                        }

                        di as text %9.0g `i' _col(11) "{c |}" ///
                                _col(15) `apf' %9.0g `apempmat'[`i'+1,1] ///
                                _col(30) `df' %5.2f `mats'[`i'+1,1]
                }
	}
	else {
	       di as text "        d " _col(11) "{c |}" _col(15) "% SVD"
               di as text `"{hline 10}{c +}{hline 20}"'
	       local j = `k'-1
               forvalues i = 0/`j' {
                        local df as text
                        if (`i' == `powd') {
                                local df as result
                        }

                        di as text %9.0g `i' _col(11) "{c |}" ///
                                _col(15) `df' %5.2f `mats'[`i'+1,1]
                }
	}

	local cde
	forvalues i=1/`maxd' {
		local cde `cde' _smvcir`i'
	}
        tempname corrmat
	qui corr `cde'
	matrix `corrmat' = r(C)	
	tempname cmax
	mata: CorrMax("`corrmat'","`cmax'")
	di
	di "Maximum Correlation in `maxd' dimensions: " %9.0g `cmax' 
end


program SpansetUnbiased, rclass
	syntax varlist [if] [in], group(string) k(string) g(string)
	marksample touse
	local preds `varlist'
	qui count if `touse'
	local totcount = r(N)
	qui mean `preds' if `touse'
	tempname m sdiag
	matrix `m' = e(b)
	matrix `m' = `m''
	matrix `sdiag' = vecdiag(e(V)*e(N))
	mata: st_matrix("`sdiag'",diag(1:/sqrt(st_matrix("`sdiag'"))))
	tempname Sp gr
	matrix `Sp' = J(`k',`k',0)
	matrix `gr' = J(1,`g',0)
	local mlist
	local Slist
	forvalues i = 1/`g' {
		qui mean `preds' if `group' == `i' & `touse'
		tempname m`i' S`i' g`i'
		matrix `m`i'' = e(b)
		matrix `m`i'' = `m`i'''
		matrix `S`i'' = e(V)
		matrix `S`i'' = e(N)*`S`i''
		matrix `gr'[1,`i'] = e(N)/`totcount'
		matrix `Sp' = `Sp'+`gr'[1,`i']*`S`i''
		local mlist `mlist' `m`i''
		local Slist `Slist' `S`i''
	}
	matrix `gr' = `gr''
	tempname spanset
	mata: Spanset(`k',`g',"`spanset'","`m'","`sdiag'","`gr'", ///
			 "`Sp'","`mlist'","`Slist'")
	local rowlabels `preds'
	local collabels 
	forvalues i = 1/`g' {
		local collabels `collabels' M_G`i'		
	}	
	forvalues i = 1/`g' {
		foreach var of varlist `preds' {
			local collabels `collabels' CV_`var'_G`i' 
		}
	}
	forvalues i = 1/`g' {
		local collabels `collabels' V_G`i'
	}
	matrix rownames `spanset' = `rowlabels'
	matrix colnames `spanset' = `collabels'
	return matrix spanset = `spanset'
	return matrix m = `m'
	return matrix sdiag = `sdiag'
end

program CheckLevel
	syntax, level(cilevel)
end

program CheckDisclevel
	syntax, disclevel(integer) 
	assert `disclevel' > 0 
	if (_rc) {
		di as error "{bf:disclevel()} must be a positive integer"
		exit 198
	}
end

program SmvcirStdCoeff, rclass
	syntax, [Dimensions(numlist)]
	tempname touse
	gen byte `touse' = e(sample)
	if "`dimensions'" == "" {
		local d = e(d)
		local dimensions 1/`d'
	}
	tempname m Sndiag
	matrix `m' = e(m)
	matrix `Sndiag' = e(Sndiag)
	local i = 1
	local stdpreds
        foreach var of varlist `e(predictors)' {
		tempvar std_`var'
		gen double `std_`var'' = (`var'-`m'[`i',1])* ///
		`Sndiag'[`i',`i'] if `touse'
		local stdpreds `stdpreds' `std_`var''
		local i = `i' + 1
	}
	tempname estres b stdmat
	estimates store `estres'
	local k = e(k)
	local i = 1
	local collist 
	foreach num of numlist `dimensions' {
		qui regress _smvcir`num' `stdpreds' if `touse'
		matrix `b' = e(b)
		mata:st_matrix("`b'",st_matrix("`b'")[1,1..`k']:/ ///
			sum(st_matrix("`b'")[1,1..`k']:^2))
		if (`i' == 1) {
			matrix `stdmat' = `b''
		}
		else {
			matrix `stdmat' = `stdmat',`b''
		}
		local collist `collist' D`num'
		local i = `i' + 1
	}
	qui estimates restore `estres'
	matrix colnames `stdmat' = `collist'
	matrix rownames `stdmat' = `e(predictors)'		
	matrix list `stdmat', noheader format(%6.0g)
	return matrix Stdcoeff = `stdmat'
end

program SmvcirPlot 
	syntax , [Dimensions(numlist)  Groups(numlist) *]
	tempname touse
	gen byte `touse' = e(sample)	
	local esy0 "O"
	local esy1 "D"
	local esy2 "T"
	local esy3 "S"
	local esy4 "+"
	local esy5 "X"
	local esy6 "Oh"
	local esy7 "Dh"
	local esy8 "Th"
	local esy9 "Sh"
	local esy10 "o"
	local esy11 "d"
	local esy12 "t"
	local esy13 "s"
	local esy14 "x"
	local esy15 "oh"
	local esy16 "dh"

	if "`dimensions'" == "" {
		// Choose dimension automatically
		local asd = e(d)
		local dimensions 1/`asd'
	}
	if "`groups'" == "" {
		local gtop = e(g)
		local groups 1/`gtop'
	}
	numlist `"`dimensions'"'
	local dimensions `r(numlist)'
	numlist `"`groups'"'
	local groups `r(numlist)'
	local topd: word count `dimensions'
	local topg: word count `groups'

	// check plot/line options
	forvalues i = 1/`topg' {
		local plotopts `plotopts' plot`i'opts(string)
		local lineopts `lineopts' line`i'opts(string)	
	}
	local 0 , `options'
	syntax, [`plotopts' `lineopts' 	///
		YCOMmon			///
		XCOMmon			///
		title(passthru)		///
		subtitle(passthru)	///
		note(passthru)		///
		caption(passthru)	///
		t1title(passthru)	/// /* title options*/
		t2title(passthru)	///
		b1title(passthru)	///
		b2title(passthru)	///
		l1title(passthru)	///
		l2title(passthru)	///
		r1title(passthru)	///
		r2title(passthru)	///
		ysize(passthru)		/// /*region options*/
		xsize(passthru)		///
		graphregion(passthru)	///
		plotregion(passthru)	///
		COMmonscheme		///
		SCHeme(passthru)	///
		name(passthru)		///		
		saving(passthru) ]		

	local vlist
	local i = 1
	local gtot = e(g)
	forvalues i = 1/`gtot' {
		local j = mod(`i'+1,15) -1
		local s`i' p`j'
		local c`i' p`j'
		local sy`i' `esy`j''
	}
	local i = 1
	foreach num of numlist `groups' {
		local g`i' `num'
		local i = `i' + 1
	}

	
	local i = 1
	foreach num of numlist `dimensions' {
		local v`i' _smvcir`num'
		local vlist `vlist' `v`i''
		local i = `i' + 1
	}
	
	local group _smvcirgroup

	local topg2 = `topg' + `topg'
	local ordlist 
	forvalues i = 1/`topg2' {
		if mod(`i',2)==1 {
			local ordlist `ordlist' `i'
		}
	}
	local labellist
	tempname grvalues
	matrix `grvalues' = e(GroupValues)
	local f: variable label `e(group)'
	if ("`f'" == "") {
		local f `e(group)'
	}
	local valf: value label `e(group)'

	forvalues i = 1/`topg' {
		local j: word `i' of `ordlist'
		local lab = `grvalues'[`g`i'',1]
		if ("`valf'" != "") {
			local lab: label `valf' `lab'
		}
		local labellist `labellist' label(`j' `f' `lab')		
	}
	local legact legend(order(`ordlist') `labellist' cols(1))
	
	local combgmac xcommon ycommon
	tempvar tx ty
	gen `tx' = 0
	gen `ty' = 0
	local holeit = ""
	tokenize `vlist'
	foreach v of local vlist {
		qui sum `v' if `touse'
		local `v'_M = r(max)
		local `v'_m = r(min)
	}
	forvalues i = 1/`topd' {
		forvalues j = `i'/`topd' {
			tempname graph_`i'_`j'
			if(`j' == `i') {
				local f: variable label ``j''
				twoway scatter `tx' `ty', 	///
				mcolor(white) yscale(off) 	///
				xscale(off)  			///
				ylabel(,nogrid) 		///
				title(`"`f'"', position(0)  	///
				size(huge)) 			///
				name(`graph_`i'_`j'') 		///
				nodraw  aspectratio(1) xsize(5) ysize(5)
			}
			else {
				local graphmac "twoway"
				forvalues m = 1/`topg' {
					local leg
					if `m' ==`topg' {
						local leg `legact'
					}
					else {
						local leg legend(off)
					}
					local graphmac `graphmac' 	///
					scatter ``i'' ``j'' if 	  	///
					`group' == `g`m'' & `touse' 	///
					, mstyle(`s`g`m''') 		///
					msymbol(`sy`g`m''') 		///
					`plot`g`m''opts' ||		///
					lfit ``i'' ``j'' if `group' ==  ///
					`g`m'' & `touse', 		///
					range(```j''_m' ```j''_M') 	///
					lstyle(`s`g`m'''mark) 		///
					`line`g`m''opts'
					if `m' != `topg' {
						local graphmac `graphmac' ||
					}
				}
				`graphmac' xtitle(`""') 	///
				ytitle(`""') aspectratio(1) 	///
				xsize(5) ysize(5) 		///
				name(`graph_`i'_`j'') nodraw `leg'
				local a = (`j'-1)*`topd' + `i'
				local holelist `"`holelist' `a'"'
			}
			local comblist `comblist' `graph_`i'_`j''
		}
	}
	local topd1 = `topd' - 1
	if ("`xsize'" == "") {
		local xsize xsize(5)
	}
	if ("`ysize'" == "") {
		local ysize ysize(5)
	}
	grc1leg `comblist', holes(`holelist') rows(`topd') cols(`topd')  ///
	legendfrom(`graph_`topd1'_`topd'') position(8) 			 ///
	ring(0) span `ycommon' `xcommmon' `title' `subtitle' `note'      ///
	`caption' `t1title' `t2title' `b1title' `b2title' `l1title' 	 ///
	`l2title' `r1title' `r2title' `ysize' `xsize' `graphregion'	 ///
	`plotregion' `commonscheme' `scheme' `draw' `name' `saving' 
end

mata:

void	CorrMax(string scalar CM, string scalar scalstor) {
	real matrix Ha
	Ha = st_matrix(CM)
	st_numscalar(scalstor,max(Ha - diag(diag(Ha))))
}

void	PValues(real scalar k, real scalar n, 	  		 ///
		   string scalar strpvals, real matrix U, 	 ///
		   real matrix Vt, real matrix S, real matrix s, ///
		   string scalar noeigen, real matrix eigen_values) {
	real matrix gamma0
	real matrix psi0	
	real matrix vD
	real scalar tstat
	real matrix trdcmat
	real matrix trdcmat2
	real matrix dnum
	real scalar scalecorrectstat
	real matrix Pvals
	Pvals = J(k,1,.)
	for(i=1;i<=k;i++) {
		gamma0 = U[,i::cols(U)]
		psi0 = Vt'[,i::cols(Vt)]
		vD = ///
		((psi0' # gamma0') * S * (psi0 # gamma0))
		vals = symeigenvalues(vD)
		devals = vals'
		if (noeigen!= "noeigen") {
			tstat = n*sum(eigen_values[ ///
				(i)::rows(eigen_values),])
		}	
		else {
			tstat=n*sum(s[i..rows(s),]:^2)
        }
		trdcmat = sum(devals)
		trdcmat2 = sum(symeigenvalues(cross(vD',vD)))
		d_num = round((trdcmat^2)/trdcmat2)
		scalecorrectstat = tstat*((trdcmat/d_num)^(-1))
		Pvals[i,1] = 1-chi2(d_num,scalecorrectstat)
	}
	st_matrix(strpvals,Pvals)
}	

void	Spanset(real scalar k, real scalar g,	   		 ///	
		   string scalar strspanset, string scalar strm, ///
		   string scalar strsdiag, string scalar strg,   ///
		   string scalar strSp, string scalar strmlist,  ///
		   string scalar strSlist) {

	real matrix spanset
	real matrix sdiag
	real colvector m
	real colvector gprop
	real matrix Sp
	m = st_matrix(strm)
	sdiag = st_matrix(strsdiag)
	gprop = st_matrix(strg)
	spanset = J(k,g+g*k + g,.)
	Mtoks = tokens(strmlist)
	Stoks = tokens(strSlist)
	Sp = st_matrix(strSp)
	for(i=1;i<=g;i++) {
		spanset[,i] = sqrt(gprop[i])*sdiag*(st_matrix(Mtoks[i])-m) 
		spanset[,((g+(i-1)*k+1)..(g+i*k))] = 
			sdiag*(st_matrix(Stoks[i])-Sp)*sdiag
		spanset[,(g+g*k+i)] = diagonal(spanset[, ///
			((g+(i-1)*k+1)..(g+i*k))])
		spanset[,((g+(i-1)*k+1)..(g+i*k))] =  ///
			spanset[,((g+(i-1)*k+1)..(g+i*k))] - ///
			diag(spanset[,(g+g*k+i)])
		spanset[,((g+(i-1)*k+1)..(g+i*k))] = sqrt(gprop[i])* ///
			spanset[,((g+(i-1)*k+1)..(g+i*k))] 
		spanset[,(g+g*k+i)] = sqrt(gprop[i])*spanset[,(g+g*k+i)] 
	}
	st_matrix(strspanset,spanset)
}

void SpansetCovariance(string scalar gi,
		string scalar ki, 
		string scalar ni,
		string scalar preds,
		string scalar group,
		string scalar selectvar,
		real matrix est, 
		real matrix covest) {
	g = strtoreal(gi)
	k = strtoreal(ki)
	n = strtoreal(ni)
	tordlist= tokens(preds)
	groupvar = st_data(.,group,selectvar)
	realizes = (	J(n,g,.),
			st_data(.,tordlist,selectvar),
			J(n,g*k+k*(k+1)/2+g*k*(k+1)/2,.))

	//realizes is n x g+k+g*k+k*(k+1)/2+g*k*(k+1)/2
	for(i=1;i<=g;i++) {
		realizes[1::n,i] = (groupvar:==i)
	}

	for (i=1;i<=g;i++) {
		realizes[1::n,(g+k+(i-1)*k+1)..(g+k+i*k)] = 
			(groupvar:==i) :* realizes[1::n,(g+1)..(g+k)]
	}

	d=1
	for (i=1;i<=k;i++) {
	    for (j=1;j<=i;j++) {
		    realizes[1::n,(g+k+g*k+d)] = 
			realizes[1::n,g+i]:*realizes[1::n,g+j]
			d=d+1
	    }
	}

	for (git=1;git<=g;git++) {
	    for (i=1;i<=k;i++) {
        	for (j=1;j<=i;j++) {
	        	realizes[1::n,(g+k+g*k+d)] = 
				(groupvar:==git):*
				(realizes[1::n,g+i]:*realizes[1::n,g+j])
	            	d=d+1
	        }
	    }
	}

	// formerly g+k+g*k+k*(k+1)/2+g*k*(k+1)/2
	// will arrange covariance matrix and mean vector such that
	// g+g*k+g*k*k+k+k*k

	covit = quadmeanvariance(realizes) 
	meanit = covit[1,.]'
	covit = covit[|2,1\.,.|]

	eu = J(g+g*k+g*k*k+k+k*k,1,.)
	eu[1::g,1] = meanit[1::g,1]

	eu[(g+g*k+g*k*k+1)::(g+g*k+g*k*k+k),1] = meanit[(g+1)::(g+k),1]
	eu[(g+1)::(g+g*k),1] = meanit[(g+k+1)::(g+k+g*k),1]

	d=1
	for (i=1;i<=k;i++) {
		for (j=1;j<=i;j++) {
		    eu[g+g*k+g*k*k+k+(i-1)*k+j,1] = meanit[(g+k+g*k+d),1]
		    eu[g+g*k+g*k*k+k+(j-1)*k+i,1] = meanit[(g+k+g*k+d),1]	
		    d=d+1
		}
	}

	for (git=1;git<=g;git++) {
    		for (i=1;i<=k;i++) {
        		for (j=1;j<=i;j++) {
				eu[g+g*k+(git-1)*k*k+(i-1)*k+j,1] = 
					meanit[(g+k+g*k+d),1]
				eu[g+g*k+(git-1)*k*k+(j-1)*k+i,1] =
					meanit[(g+k+g*k+d),1]
			        d=d+1
        		}
    		}
	}

	vu = J(g+g*k+g*k*k+k+k*k,g+g*k+g*k*k+k+k*k,.)
	vu[1::(g+g*k),1..(g+g*k)] = 
		covit[	(1::g)\((g+k+1)::(g+k+g*k)),
			((1..g),((g+k+1)..(g+k+g*k)))]
	vu[(g+g*k+g*k*k+1)::(g+g*k+g*k*k+k),(g+g*k+g*k*k+1)..(g+g*k+g*k*k+k)]=
		covit[(g+1)::(g+k),(g+1)..(g+k)]
	vu[(g+g*k+g*k*k+1)::(g+g*k+g*k*k+k),1..(g+g*k)] = 
		covit[(g+1)::(g+k),((1..g),((g+k+1)..(g+k+g*k)))]
	vu[1::(g+g*k),(g+g*k+g*k*k+1)::(g+g*k+g*k*k+k)] = 
		covit[(1::g)\((g+k+1)::(g+k+g*k)),(g+1)..(g+k)]

	dijg=0
	for (git=0;git<=g;git++) {
    		for (i=1;i<=k;i++) {
	        	for (j=1;j<=i;j++) {
        	        	dijg=dijg+1
            			//with mean
            			for (im=1;im<=k;im++) {
                			for (gim=0;gim<=g;gim++) {
                    //cov xi xj in group git (0 marginal)
                    // with
                    // xim in group gim
// formerly g+k+g*k+k*(k+1)/2+g*k*(k+1)/2
//// g+g*k+g*k*k+k+k*k
            					if (gim == 0) {
                					if(git==0) {
vu[g+g*k+g*k*k+im,g+g*k+g*k*k+k+(i-1)*k+j]= covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+g*k*k+k+(i-1)*k+j,g+g*k+g*k*k+im]= covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+g*k*k+im,g+g*k+g*k*k+k+(j-1)*k+i]= covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+g*k*k+k+(j-1)*k+i,g+g*k+g*k*k+im]= covit[g+k+g*k+dijg,g+gim*k+im]
                					}
                					else {
vu[g+g*k+g*k*k+im,g+g*k+(git-1)*k*k+(i-1)*k+j]= covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+(git-1)*k*k+(i-1)*k+j,g+g*k+g*k*k+im]= covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+g*k*k+im,g+g*k+(git-1)*k*k+(j-1)*k+i]= covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+(git-1)*k*k+(j-1)*k+i,g+g*k+g*k*k+im]= covit[g+k+g*k+dijg,g+gim*k+im]
                					}
            					}
	            				else {
							if(git==0) {
				// i,j	x
				// j,i	x
				// x	i,j
				// x	j,i
vu[g+(gim-1)*k+im,g+g*k+g*k*k+k+(i-1)*k+j] =covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+g*k*k+k+(i-1)*k+j,g+(gim-1)*k+im] =covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+(gim-1)*k+im,g+g*k+g*k*k+k+(j-1)*k+i] =covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+g*k*k+k+(j-1)*k+i,g+(gim-1)*k+im] =covit[g+k+g*k+dijg,g+gim*k+im]
							}
							else {
vu[g+(gim-1)*k+im,g+g*k+(git-1)*k*k+(i-1)*k+j] = covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+(git-1)*k*k+(i-1)*k+j,g+(gim-1)*k+im] = covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+(gim-1)*k+im,g+g*k+(git-1)*k*k+(j-1)*k+i] =covit[g+k+g*k+dijg,g+gim*k+im]
vu[g+g*k+(git-1)*k*k+(j-1)*k+i,g+(gim-1)*k+im] =covit[g+k+g*k+dijg,g+gim*k+im]
							}
            					}
					}
            			}
		            	//with proportions
	            		for (gip =1;gip<=g;gip++) {
		                //cov xi xj in group git (0 marginal)
		                // with
                		// group proportion gip
					if(git==0) {
vu[g+g*k+g*k*k+k+(i-1)*k+j,gip] = covit[g+k+g*k+dijg,gip]
vu[gip,g+g*k+g*k*k+k+(j-1)*k+i] = covit[g+k+g*k+dijg,gip]
vu[gip,g+g*k+g*k*k+k+(i-1)*k+j] = covit[g+k+g*k+dijg,gip]
vu[g+g*k+g*k*k+k+(j-1)*k+i,gip] = covit[g+k+g*k+dijg,gip]
					}
					else {
vu[g+g*k+(git-1)*k*k+(i-1)*k+j,gip] = covit[g+k+g*k+dijg,gip]
vu[gip,g+g*k+(git-1)*k*k+(j-1)*k+i] = covit[g+k+g*k+dijg,gip]
vu[gip,g+g*k+(git-1)*k*k+(i-1)*k+j] = covit[g+k+g*k+dijg,gip]
vu[g+g*k+(git-1)*k*k+(j-1)*k+i,gip] = covit[g+k+g*k+dijg,gip]
					}
        	    		}
			        //with other variances
	            		odijg=0
				for (ogit=0;ogit<=g;ogit++) {
			        	for (oi=1;oi<=k;oi++) {
                				for (oj=1;oj<=oi;oj++) {
		        	        		odijg=odijg+1
							if(git == 0) {
								if(ogit==0) {
								// i,j	x
								// j,i	x
								// x	i,j
								// x	j,i

								// i,j	 oi,oj
								// j,i	 oi,oj
								// oi,oj i,j
								// oi,oj j,i
			
								// i,j	 oj,oi
								// j,i	 oj,oi
								// oj,oi i,j
								// oj,oi j,i
vu[g+g*k+g*k*k+k+(i-1)*k+j,g+g*k+g*k*k+k+(oi-1)*k+oj] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(j-1)*k+i,g+g*k+g*k*k+k+(oi-1)*k+oj] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(oi-1)*k+oj,g+g*k+g*k*k+k+(i-1)*k+j] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(oi-1)*k+oj,g+g*k+g*k*k+k+(j-1)*k+i] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(i-1)*k+j,g+g*k+g*k*k+k+(oj-1)*k+oi] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(j-1)*k+i,g+g*k+g*k*k+k+(oj-1)*k+oi] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(oj-1)*k+oi,g+g*k+g*k*k+k+(i-1)*k+j] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(oj-1)*k+oi,g+g*k+g*k*k+k+(j-1)*k+i] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
								}
								else {
vu[g+g*k+g*k*k+k+(i-1)*k+j,g+g*k+(ogit-1)*k*k+(oi-1)*k+oj] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(j-1)*k+i,g+g*k+(ogit-1)*k*k+(oi-1)*k+oj] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(ogit-1)*k*k+(oi-1)*k+oj,g+g*k+g*k*k+k+(i-1)*k+j] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(ogit-1)*k*k+(oi-1)*k+oj,g+g*k+g*k*k+k+(j-1)*k+i] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(i-1)*k+j,g+g*k+(ogit-1)*k*k+(oj-1)*k+oi] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(j-1)*k+i,g+g*k+(ogit-1)*k*k+(oj-1)*k+oi] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(ogit-1)*k*k+(oj-1)*k+oi,g+g*k+g*k*k+k+(i-1)*k+j] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(ogit-1)*k*k+(oj-1)*k+oi,g+g*k+g*k*k+k+(j-1)*k+i] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
								}
							}
							else {
								if(ogit==0) {
vu[g+g*k+(git-1)*k*k+(i-1)*k+j,g+g*k+g*k*k+k+(oi-1)*k+oj] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(git-1)*k*k+(j-1)*k+i,g+g*k+g*k*k+k+(oi-1)*k+oj] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(oi-1)*k+oj,g+g*k+(git-1)*k*k+(i-1)*k+j] =
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(oi-1)*k+oj,g+g*k+(git-1)*k*k+(j-1)*k+i] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(git-1)*k*k+(i-1)*k+j,g+g*k+g*k*k+k+(oj-1)*k+oi] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(git-1)*k*k+(j-1)*k+i,g+g*k+g*k*k+k+(oj-1)*k+oi] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(oj-1)*k+oi,g+g*k+(git-1)*k*k+(i-1)*k+j] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+g*k*k+k+(oj-1)*k+oi,g+g*k+(git-1)*k*k+(j-1)*k+i] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
								}
								else {
vu[g+g*k+(git-1)*k*k+(i-1)*k+j,g+g*k+(ogit-1)*k*k+(oi-1)*k+oj] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(git-1)*k*k+(j-1)*k+i,g+g*k+(ogit-1)*k*k+(oi-1)*k+oj] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(ogit-1)*k*k+(oi-1)*k+oj,g+g*k+(git-1)*k*k+(i-1)*k+j] =
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(ogit-1)*k*k+(oi-1)*k+oj,g+g*k+(git-1)*k*k+(j-1)*k+i] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(git-1)*k*k+(i-1)*k+j,g+g*k+(ogit-1)*k*k+(oj-1)*k+oi] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(git-1)*k*k+(j-1)*k+i,g+g*k+(ogit-1)*k*k+(oj-1)*k+oi] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(ogit-1)*k*k+(oj-1)*k+oi,g+g*k+(git-1)*k*k+(i-1)*k+j] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
vu[g+g*k+(ogit-1)*k*k+(oj-1)*k+oi,g+g*k+(git-1)*k*k+(j-1)*k+i] = 
	covit[g+k+g*k+dijg,g+k+g*k+odijg]
								}	
							}
        	            			}
                			}
	            		}         
        		}
	    	}
	}

	// Delta 1
	//calculate expectation
	d1ef = eu
	gprop = eu[1::g,1]

	for(i=1;i<=g;i++) {
		d1ef[(g+(i-1)*k+1)::(g+i*k),1] = 
			d1ef[(g+(i-1)*k+1)::(g+i*k),1]:/gprop[i,1]
		d1ef[(g+g*k+(i-1)*k*k+1)::(g+g*k+i*k*k),1] = 
			d1ef[(g+g*k+(i-1)*k*k+1)::(g+g*k+i*k*k),1]:/gprop[i,1]
	}

	//#now variance
	d1 = diag(J(g+g*k+g*k*k+k+k*k,1,1))
	duvdp = J(g*k + g*k*k,g,0)
	for(l=1;l<=g;l++) {
		for(i=1;i<=k;i++) {
			for(j=1;j<=g;j++) {
				if(j==l) {
duvdp[(l-1)*k+i,j] = -eu[g+(l-1)*k+i,1]/(gprop[j,1]^2)
				}
			}
		}
	}
	for (l=1;l<=g;l++) {
		for (i=1;i<=k;i++) {
			for (f=1;f<=k;f++) {
				for(j=1;j<=g;j++) {
					if(j==l) {
duvdp[g*k+(l-1)*k*k+(i-1)*k+f,j] =
	-eu[g+g*k+(l-1)*k*k+(i-1)*k+f,1]/(gprop[j,1]^2)
					}
				}
			}
		}
	}

	duvdmv = diag(J(g*k+g*k*k,1,1))
	for(i=1;i<=g;i++) {
		for(j=1;j<=k;j++) {
			duvdmv[(i-1)*k+j,(i-1)*k+j] = 1/gprop[i,1]
		}
	}
	for(i=1;i<=g;i++) {
		for(j=1;j<=k;j++) {
			for(l=1;l<=k;l++) {
duvdmv[g*k+(i-1)*k*k+(j-1)*k+l,g*k+(i-1)*k*k+(j-1)*k+l] = 1/gprop[i,1]
			}
		}
	}

	d1[(g+1)::(g+g*k+g*k*k),1..g] = duvdp
	d1[(g+1)::(g+g*k+g*k*k),(g+1)..(g+g*k+g*k*k)] = duvdmv	

	//Delta 2
	d2ef = d1ef
	for (i=1;i<=g;i++) {
		for (j=1;j<=k;j++) {
			for (l=1;l<=k;l++) {
d2ef[g + g*k + (i-1)*k*k + (j-1)*k+l,1] = 
	d2ef[g + g*k + (i-1)*k*k + (j-1)*k+l,1] - 
	d2ef[g + (i-1)*k+j,1]*d2ef[g + (i-1)*k+l,1]
			}
		}
	}
	for (j=1;j<=k;j++) {
		for(l=1;l<=k;l++) {
d2ef[g + g*k + g*k*k + k + (j-1)*k+l,1] =
	d2ef[g + g*k + g*k*k + k + (j-1)*k+l,1] -
	d2ef[g + g*k + g*k*k + j,1]*d2ef[g + g*k + g*k*k + l,1]
		}
	}


	d2 = diag(J(g+g*k+g*k*k+k+k*k,1,1))
	dsigdmu = J(g*k*k,g*k,0) 
	for (l=1;l<=g;l++) {
		for (i=1;i<=k;i++) {
			for (f=1;f<=k;f++) {
				for (j=1;j<=k;j++) {
					if(j == i & i != f) {
dsigdmu[(l-1)*k*k+(i-1)*k+f,(l-1)*k+j] = -d1ef[g+(l-1)*k+f,1]
					}
					if(j == i & i == f) {
dsigdmu[(l-1)*k*k+(i-1)*k+f,(l-1)*k+j] = -2*d1ef[g+(l-1)*k+i,1]
					}	
					if(j==f & i != f) {
dsigdmu[(l-1)*k*k+(i-1)*k+f,(l-1)*k+j] = -d1ef[g+(l-1)*k+i,1]
					}
				}
			}
		}
	}
	dsigmardmumar = J(k*k,k,0)
	for (i=1;i<=k;i++) {
		for(f=1;f<=k;f++) {
			for(j=1;j<=k;j++) {
				if(j==i & i!=f) {
dsigmardmumar[(i-1)*k+f,j] = -d1ef[g+g*k+g*k*k+f,1]
				}
				if(j==i & i==f) {
dsigmardmumar[(i-1)*k+f,j] = -2*d1ef[g+g*k+g*k*k+i,1]
				}
				if(j==f & i!=f) {
dsigmardmumar[(i-1)*k+f,j] = -d1ef[g+g*k+g*k*k+i,1]
				}
			}
		}
	}

	d2[(g+g*k+1)::(g+g*k+g*k*k),(g+1)..(g+g*k)] = dsigdmu
	d2[	(g+g*k+g*k*k+k+1)::(g+g*k+g*k*k+k+k*k),
		(g+g*k+g*k*k+1)..(g+g*k+g*k*k+k)] 	= dsigmardmumar

	//Delta 3
	d3ef = d2ef[1::(g+g*k+g*k*k),1]

	//# center means
	for(i=1;i<=g;i++) {
		for(j=1;j<=k;j++) {
d3ef[g+(i-1)*k+j,1] = (d3ef[g+(i-1)*k+j,1]-d2ef[g+g*k+g*k*k+j,1])
		}
	}

	//# scale centered means
	for(i=1;i<=k;i++) {
		for (j=1;j<=g;j++) {
d3ef[g+(j-1)*k+i,1] = 
	d3ef[g+(j-1)*k+i,1]/sqrt(d2ef[g+g*k+g*k*k+k+1+(i-1)*(k+1),1])
		}
	}

	//# scale variances 
	for(lg=1;lg<=g;lg++) {
		for(i=1;i<=k;i++) {
			for(j=1;j<=k;j++) {
(d3ef[g+g*k+(lg-1)*k*k+(i-1)*k+j,1] = 
	d3ef[g+g*k+(lg-1)*k*k+(i-1)*k+j,1]/(
		sqrt(d2ef[g+g*k+g*k*k+k+1+(i-1)*(k+1),1])*sqrt(
			d2ef[g+g*k+g*k*k+k+1+(j-1)*(k+1),1])))
			}		
		}
	}

	d3 = J(g+g*k+g*k*k,g+g*k+g*k*k+k+k*k,0)
	dmuzdmu = diag(J(g*k,1,1))
	for (i=1;i<=g;i++) {
		for(j=1;j<=k;j++) {
			dmuzdmu[(i-1)*k+j,(i-1)*k+j] = 
			1/sqrt(d2ef[g+g*k+g*k*k+k+1+(j-1)*(k+1),1])
		}
	}
	dsigzdsig = diag(J(g*k*k,1,1))
	for (i=1;i<=g;i++) {
 		for(j=1;j<=k;j++) {
			for(l=1;l<=k;l++) {
dsigzdsig[(i-1)*k*k+(j-1)*k+l,(i-1)*k*k+(j-1)*k+l]=
	1/(sqrt(d2ef[g+g*k+g*k*k+k+1+(j-1)*(k+1),1])*
	   sqrt(d2ef[g+g*k+g*k*k+k+1+(l-1)*(k+1),1]))  
			}
		}
	}

	dmuzdmumar = J(g*k,k,0)
	for (i=1;i<=g;i++) {
		for (j=1;j<=k;j++) {
			dmuzdmumar[(i-1)*k+j,j] =
			-1/sqrt(d2ef[g+g*k+g*k*k+k+1+(j-1)*(k+1),1])	
		}
	}

	dmuzdsigmar = J(g*k,k*k,0)
	for (i=1;i<=g;i++) {
		for(j=1;j<=k;j++) {
			for(l=1;l<=k;l++) {
				if(j==l) {
dmuzdsigmar[(i-1)*g+l,(j-1)*k+l] = 
	(-.5*(d2ef[g+(i-1)*k+l,1]-d2ef[g+g*k+g*k*k+l,1])/(
	d2ef[g+g*k+g*k*k+k+1+(l-1)*(k+1),1]*sqrt(
	d2ef[g+g*k+g*k*k+k+1+(l-1)*(k+1),1])))
				}
			}
		}
	}
	dsigzdsigmar = J(g*k*k,k*k,0)
	for(i=1;i<=g;i++) {
		for(j=1;j<=k;j++) {
			for(f=1;f<=k;f++) {
				for(l=1;l<=k;l++) {
					for(m=1;m<=k;m++) {
						if(f==m) {
							if(f==j & j!=l) {
dsigzdsigmar[(i-1)*k*k+(j-1)*k+l,(f-1)*k+m] =
	(-.5*d2ef[g+g*k+(i-1)*k*k+(j-1)*k+l,1]/
	((d2ef[g+g*k+g*k*k+k+1+(j-1)*(k+1),1]*sqrt(
	d2ef[g+g*k+g*k*k+k+1+(j-1)*(k+1),1])) * sqrt(
	d2ef[g+g*k+g*k*k+k+1+(l-1)*(k+1),1])))
							}
							if(f==l & l!=j) {
dsigzdsigmar[(i-1)*k*k+(j-1)*k+l,(f-1)*k+m] =
	(-.5*d2ef[g+g*k+(i-1)*k*k+(j-1)*k+l,1]/
	((d2ef[g+g*k+g*k*k+k+1+(l-1)*(k+1),1]*sqrt(
	d2ef[g+g*k+g*k*k+k+1+(l-1)*(k+1),1])) * sqrt(
	d2ef[g+g*k+g*k*k+k+1+(j-1)*(k+1),1])))
							}
							if(f==j & j==l) {
dsigzdsigmar[(i-1)*k*k+(j-1)*k+l,(f-1)*k+m] =
	(-d2ef[g+g*k+(i-1)*k*k+(j-1)*k+l,1]/
	(d2ef[g+g*k+g*k*k+k+1+(l-1)*(k+1),1]*
	d2ef[g+g*k+g*k*k+k+1+(l-1)*(k+1),1]))
							}
						}
					}
				}
			}
		}
	}
	d3[1::g,1::g] = diag(J(g,1,1))
	d3[(g+1)::(g+g*k),(g+1)..(g+g*k)] = dmuzdmu
	d3[(g+g*k+1)::(g+g*k+g*k*k),(g+g*k+1)..(g+g*k+g*k*k)] = dsigzdsig
	d3[(g+1)::(g+g*k),(g+g*k+g*k*k+1)..(g+g*k+g*k*k+k)] = dmuzdmumar
	d3[(g+1)::(g+g*k),(g+g*k+g*k*k+k+1)..(g+g*k+g*k*k+k+k*k)]=dmuzdsigmar
	d3[(g+g*k+1)::(g+g*k+g*k*k),(g+g*k+g*k*k+k+1)..(g+g*k+g*k*k+k+k*k)] = 
		dsigzdsigmar

	//Delta4
	d4ef = d3ef
	wvef = d4ef
	for (i=1;i<=g;i++) {
		for (j=1;j<=k;j++) {
			for (l=1;l<=k;l++) {
				weightvar = 0
				for (m=1;m<=g;m++) {
weightvar = weightvar + gprop[m,1]*d4ef[g + g*k + (m-1)*k*k + (j-1)*k+l,1]
				}
				wvef[g + g*k + (i-1)*k*k + (j-1)*k+l,1] = 
					weightvar
			}
		}
	}
	for (i=1;i<=g;i++) {
		for (j=1;j<=k;j++) {
			for (l=1;l<=k;l++) {
d4ef[g + g*k + (i-1)*k*k + (j-1)*k+l,1] = 
	d4ef[g + g*k + (i-1)*k*k + (j-1)*k+l,1] - 
	wvef[g + g*k + (i-1)*k*k + (j-1)*k+l,1]
			}
		}
	}

	d4 = diag(J(g+g*k+g*k*k,1,1))
	dscdp = J(g*k*k,g,0)
	dscds = J(g*k*k,g*k*k,0)

	for (l=1;l<=g;l++) {
		for (q=1;q<=k;q++) {
			for (f=1;f<=k;f++) {
				for (j=1;j<=g;j++) {
dscdp[(l-1)*k*k+(q-1)*k+f,j] = -d3ef[g+g*k+(j-1)*k*k+(q-1)*k+f,1]
				}
			}
		}
	}

	for (l=1;l<=g;l++) {
		for (q=1;q<=k;q++) {
			for (h=1;h<=g;h++) {
				for (m=1;m<=k;m++) {
					for (f=1;f<=k;f++) {
						for (j=1;j<=k;j++) {
if ((h==l & m==q) & j==f) {
	dscds[(l-1)*k*k+(q-1)*k+f,(h-1)*k*k+(m-1)*k+j] = 1 - gprop[l,1]
}
if ((h!=l & m==q) & j==f) {
	dscds[(l-1)*k*k+(q-1)*k+f,(h-1)*k*k+(m-1)*k+j] = -gprop[h,1]
}
						}
					}
				}
			}
		}
	}

	d4[(g+g*k+1)::(g+g*k+g*k*k),1..g] = dscdp
	d4[(g+g*k+1)::(g+g*k+g*k*k),(g+g*k+1)..(g+g*k+g*k*k)] = dscds

	//Delta 5
	d5ef = d4ef[(g+1)::(g+g*k+g*k*k),1]
	for (i=1;i<=g;i++) {
d5ef[((i-1)*k+1)::(i*k),1] = 
	d5ef[((i-1)*k+1)::(i*k),1] :* sqrt(gprop[i,1])
d5ef[(g*k+(i-1)*k*k+1)::(g*k+i*k*k),1] = 
	d5ef[(g*k+(i-1)*k*k+1)::(g*k+i*k*k),1]:*sqrt(gprop[i,1])
	}

	d5 = J(g*k+g*k*k,g+g*k+g*k*k,0)
	dvdp = J(g*k,g,0)
	for (j=1;j<=g;j++) {
		for (m=1;m<=k;m++) {
			dvdp[(j-1)*k+m,j] = 
				d4ef[g+(j-1)*k+m,1]/(2*sqrt(gprop[j,1]))
		}
	}
	dDeldp = J(g*k*k,g,0)
	for (i=1;i<=g;i++) {
		for (j=1;j<=k;j++) {
			for (m=1;m<=k;m++) {
dDeldp[(i-1)*k*k+(j-1)*k+m,i] =
	d4ef[g+g*k+(i-1)*k*k+(j-1)*k+m]/(2*sqrt(gprop[i,1]))
			}
		}
	}

	dvdmu = diag(J(g*k,1,1))
	dDeldsc = diag(J(g*k*k,1,1))

	for (i=1;i<=g;i++) {
		for (j=1;j<=k;j++) {
			dvdmu[(i-1)*k+j,(i-1)*k+j] = sqrt(gprop[i,1])
		}
	}
	for (i=1;i<=g;i++) {
		for(j=1;j<=k;j++) {
			for(l=1;l<=k;l++) {
dDeldsc[(i-1)*k*k+(j-1)*k+l,(i-1)*k*k+(j-1)*k+l] = 
	sqrt(gprop[i,1])
			}
		}
	}

	d5[1::(g*k),1..g] = dvdp
	d5[1::(g*k),(g+1)..(g+g*k)] = dvdmu
	d5[(g*k+1)::(g*k+g*k*k),1..g] = dDeldp
	d5[(g*k+1)::(g*k+g*k*k),(g+g*k+1)..(g+g*k+g*k*k)] =dDeldsc

	ef =J(g*k+g*k*k+g*k,1,0)
	vf =J(g*k+g*k*k+g*k,g*k+g*k*k+g*k,0)
	ef[(1::(g*k+g*k*k)),1] = d5ef

	dmat = d5*d4*d3*d2*d1
	d5vf = dmat * vu * dmat' 

	vf[(1::(g*k+g*k*k)),(1::(g*k+g*k*k))] = d5vf 
	IDP = diag(J(g*k+g*k*k+g*k,1,1))
	Perm = IDP
	for (i=1;i<=g;i++) {
		for (z=1;z<=k;z++) {
			Perm[g*k+k*k*(i-1)+1+(z-1)*(k+1),.] = 
				IDP[g*k+g*k*k+z+(i-1)*k,.]
			Perm[g*k+g*k*k+z+(i-1)*k,.] = 
				IDP[g*k+k*k*(i-1)+1+(z-1)*(k+1),.]
		}
	}

	ef = Perm*ef
	vf = Perm*vf*Perm'
	est = ef
	covest = vf
}

end
