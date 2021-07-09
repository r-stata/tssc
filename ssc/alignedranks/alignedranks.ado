*! version 1.0.1 Ariel Linden 11aug2014 fixed error when strata was not specified
*! version 1.0.0 Ariel Linden 12july2014
*! code based on ranksum version 2.4.4 (09aug2006), and ranksumex version 1.0.0 (07jun2012)

program define alignedranks, rclass byable(recall)
	version 13.0
	syntax varlist(numeric min=1 max=1) [if] [in], BY(varname) [ Strata(varname) LOCation(string) EXact porder ]

	local origby "`by'"
	capture confirm numeric variable `by'
	if _rc {
		tempvar numby
		encode `by', generate(`numby')
		local by "`numby'"
	}
	
	if ("`strata'" != "") {
	local origstrata "`strata'"
	capture confirm numeric variable `strata'
	if _rc {
		tempvar numstrata
		encode `strata', generate(`numstrata')
		local strata "`numstrata'"
		}
	}
	
	if ("`strata'" == "") &  ("`location'" != "") {
		display in smcl as error "location cannot be specified without strata being specified"
        error 198
    }
		
	local location = cond("`location'" == "", "mean", "`location'")
		if !inlist("`location'", "mean", "median", "sd", "hl") { 
                display in smcl as error "location type not recognized"
                error 198
        }
	
	marksample touse
	markout `touse' `by' `strata'

	quietly count if `touse'
		if r(N) >25 & "`exact'" !="" {
		display in smcl as error "The exact option cannot be specified for sample sizes greater than 25"
        error 198
    }
	
	local x "`varlist'"

	tempname g1 g2 w1 w2 v unv z
	tempvar ranks resid place

	quietly {
		summarize `by' if `touse' //, meanonly
		if r(N) == 0  noisily error 2000 
		if r(min) == r(max) {
			di in red `"1 group found, 2 required"'
			exit 499
		}
		
		scalar `g1' = r(min)    
		scalar `g2' = r(max)    

		count if `by'!=`g1' & `by'!=`g2' & `touse'
		if r(N) != 0 {
			di in red `"more than 2 groups found, only 2 allowed"'
			exit 499
		}

	// this is where the alignment and ranking occurs
	if ("`strata'" != "") & ("`location'" != "hl") {
	
		bys `strata': egen `place' = `location'(`x') if `touse'
		gen `resid' = `x' - `place' if `touse'
		egen double `ranks' = rank(`resid') if `touse'	 
	}
	
	else if ("`strata'" != "") & ("`location'" == "hl") {
		
		tempvar `x'_1 `x'_2 meandiff 
		tempname median
		
		gen `resid' = .
		levelsof `strata', local(levels)
		foreach st of local levels {
		preserve
		gen `x'_1= `x' if `strata' ==`st' & `touse'
		gen `x'_2= `x' if `strata' ==`st' & `touse'
		fillin `x'_*
		sort `x'_*
		drop if   `x'_1 >= `x'_2 
		drop _fillin
		gen `meandiff' = (`x'_1 + `x'_2)/2 if `touse'
		sum `meandiff', det 
		scalar `median' = r(p50)
		restore
		replace `resid' = `x' - `median' if `strata' ==`st' & `touse'
		}
		egen double `ranks' = rank(`resid') if `touse'	
	}
	
	// this is the default "Two-sample Wilcoxon rank-sum (Mann-Whitney) test"
	else if ("`strata'" == "") {
		egen double `ranks' = rank(`x') if `touse'
	}

	// this is where the stats are calculated
	summarize `ranks' if `by'==`g1' & `touse', meanonly
		local   n1   = r(N)
		scalar `w1'  = r(sum)

	summarize `ranks' if `touse'
		local   n    = r(N)
		local   n2   = `n' - `n1'
		scalar `v'   = `n1'*`n2'*r(Var)/`n'
		scalar `unv' = `n1'*`n2'*(`n'+1)/12
		scalar `z'   = (`w1'-`n1'*(`n'+1)/2)/sqrt(`v')
	}

   if `n' <= 25 & "`exact'" !="" {
		local wM = `n1'
        local wX = `w1'
        sort `by' `ranks'
        if `n1' > `n2'  {
        local wM = `n2'
        local wX = `w2'
        gsort -`by' `ranks'
        }
                        
	GetMinMax `ranks' `touse' `wM'
		local wMin = r(minval)
        local wMax = r(maxval)
                        
    mata: MannWhitneyExact( "`ranks'", "`touse'", `wM', `wX', `wMin', `wMax')
		tempname signif
        scalar `signif' = (`r(num1)'+`r(num2)')/`r(den)'
        local num1 = r(num1)
        local num2 = r(num2)
        local lft  = r(lft)
        local rgt  = r(rgt)
        local den  = r(den)
    }
	
	local holdg1 = `g1' 
	local g1 = `g1'
	local g2 = `g2'

	local valulab : value label `by'
	if `"`valulab'"'!=`""' {
		local g1 : label `valulab' `g1'
		local g2 : label `valulab' `g2'
	}

	local by "`origby'"
	if "`strata'" != "" { 
	di in gr _n `"Two-sample aligned rank-sum (Hodges-Lehmann) test"' _n
	}
	else {
	di in gr _n `"Two-sample Wilcoxon rank-sum (Mann-Whitney) test"' _n
	}
	di in smcl in gr %12s abbrev(`"`by'"',12) /*
		*/ " {c |}      obs    rank sum    expected"
	di in smcl in gr "{hline 13}{c +}{hline 33}"
	ditablin `"`g1'"' `n1' `w1' `n1'*(`n'+1)/2
	ditablin `"`g2'"' `n2' `n'*(`n'+1)/2-`w1' `n2'*(`n'+1)/2
	di in smcl in gr "{hline 13}{c +}{hline 33}"
	ditablin combined `n' `n'*(`n'+1)/2 `n'*(`n'+1)/2

	if `unv' < 1e7 local vfmt `"%10.2f"' 
	else             local vfmt `"%10.0g"'

	local xab = abbrev("`x'",8)
	local byab = abbrev("`by'",8)

	
    if `n' > 25 | `n' <= 25 & "`exact'" =="" {	

	di in smcl in gr _n `"unadjusted variance"' _col(22)				///
	   in ye  `vfmt' `unv' _n											///
	   in gr  `"adjustment for ties"' _col(22)							///
	   in ye  `vfmt' `v'-`unv' _n										///
	   in gr _col(22) "{hline 10}" _n									///
	   in gr `"adjusted variance"' _col(22)								///
	   in ye  `vfmt' `v' _n(2)											///
	   in gr `"Ho: `xab'(`byab'==`g1') = `xab'(`byab'==`g2')"' _n		///
	   in gr _col(14) `"z = "'											///
	   in ye %7.4f `z' _n												///
	   in gr _col(5) `"Prob > |z| = "'									///
	   in ye %7.4f 2*normprob(-abs(`z')) 

	return scalar  group1   = `holdg1' 
	return scalar  sum_obs  = `w1'
	return scalar  sum_exp  = `n1'*(`n'+1)/2
	return scalar  z        = `z'
	return scalar  Var_a    = `v'
	return scalar  N_1      = `n1'
	return scalar  N_2      = `n2'
	}

	else {

	di _n in gr "Exact statistics" _n in gr `"Ho: `xab'(`byab'==`g1') = `xab'(`byab'==`g2')"' _n  ///
		in gr _col(5) `"Prob <= "' in ye %9.0g `lft' in gr `" = "' in ye %6.4f (`num1'/`den')  _n ///
        in gr _col(5) `"Prob >= "' in ye %9.0g `rgt' in gr `" = "' in ye %6.4f (`num2'/`den')  _n /// 
        in gr _col(5) `"Two-sided p-value = "' in ye %6.4f `signif' 
	
    return scalar p   = `signif'
    return scalar den = `den'
    return scalar nx2 = `num2'
    return scalar nx1 = `num1'
    return scalar x2  = `rgt'
    return scalar x1  = `lft'
    }
		
	if "`porder'"=="porder" {
		tempname porder
		scalar `porder' = (`w1'-`n1'*(`n1'+1)/2)/(`n1'*`n2')
		return scalar porder = `porder'
		di _n in smcl as text /*
		  */ `"P{`xab'(`byab'==`g1') > `xab'(`byab'==`g2')} = "' /*
		        */ as result %5.4f `porder' 
	}

end

program define ditablin
	if length(`"`1'"') > 12 {
		local 1 = substr(`"`1'"',1,12)
	}
      
    di in smcl in gr %12s `"`1'"' " {c |}" in ye 	///
		_col(17) %7.0g `2'							///
        _col(26) %10.0g `3'							///
        _col(38) %10.0g `4' 
end 

program define GetMinMax, rclass
        args ranks touse m
        
        preserve
        gsort -`touse' `ranks'
        qui count if `touse'
        local np1 = `r(N)' + 1
        local minval = 0
        local maxval = 0
        forvalues i=1/`m' {
                local minval = `minval' + `ranks'[`i']
                local maxval = `maxval' + `ranks'[`np1'-`i']
        }
        ret scalar minval = `minval'
        ret scalar maxval = `maxval'
        restore
end

version 12
mata:
void MannWhitneyExact(string scalar rrvar, string scalar tvar, real scalar m, real scalar val, real scalar minsum, real scalar maxsum) {
        real colvector wxrank
        st_view(wxrank, ., rrvar, tvar)
        
        N       = length(wxrank)
        np1     = N+1
        aminsum = 0
        amaxsum = 0
        for(i=1; i<=m; i++) {
                aminsum = aminsum + i
                amaxsum = amaxsum + (np1-i)
        }       
        lll = val
        rrr = (amaxsum - val + aminsum) 
        if (lll > rrr) {
                tmp = lll
                lll = rrr
                rrr = tmp
        }
        
        L      = 2
        Q      = 2^ceil(log(L*amaxsum)/log(2))
        wxrank = L*wxrank
        psi    = J(Q, 1, 0+1i)
        phit   = J(Q, 1, 0+1i)
        eitsk  = J(N, 1, 0+1i)
        t1     = J(N, 1, 0+1i)
        t2     = J(N, 1, 0+1i)
        
        for (jj=1; jj<=Q; jj++) {
                u = -2*pi()*(jj-1)/Q
                for (kk=1; kk<=N; kk++) {
                        eitsk[kk] = C(cos(wxrank[kk]*u), sin(wxrank[kk]*u))
                }
                psi[1] = eitsk[1]
                for (kk=2; kk<=N; kk++) {
                        for (mm=1; mm<kk; mm++) {
                                t1[mm+1] = psi[mm]
                                t2[mm]   = psi[mm]
                        }
                        t1[1]  = C(1, 0)
                        t2[mm] = C(0, 0)
                        for(mm=1; mm<=kk; mm++) {
                                psi[mm] = eitsk[kk]*t1[mm] + t2[mm]
                        }
                }
                phit[jj] = psi[m]
        }
        a = round(Re(fft(phit))/Q)

        j1 = L*aminsum+1
        j2 = L*lll+1
        j3 = L*rrr+1
        j4 = L*amaxsum+1

        lft = 0
        for (j=j1;j<=j2;j++) {
                lft = lft + a[j]
        }
        rgt=0
        for(j=j3; j<=j4; j++) {
                rgt = rgt + a[j]
        }
        den = sum(a)

        st_numscalar("r(num1)", lft)
        st_numscalar("r(num2)", rgt)
        st_numscalar("r(den)",  den)
        st_numscalar("r(lft)",  lll)
        st_numscalar("r(rgt)",  rrr)
}
end

exit



