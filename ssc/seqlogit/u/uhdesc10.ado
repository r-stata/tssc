*! 1.1.13 MLB 06Sep2010
*! 1.1.11 MLB 07May2010
*! 1.1.8  MLB 08Apr2010
*! 1.1.5  MLB 18Jan2010

program define uhdesc10, rclass
	syntax ,                         ///
	[                                ///        
	at(string)                       ///
	overat(string)                   ///
	overlab(string)                  ///
	draws(passthru)                  ///
	]

	preserve
	
	if "`e(cmd)'" != "seqlogit10" {
		di as err "uhdesc can only be used after seqlogit10"
		exit 198
	}
	if "`e(sigma)'" == "" {
		di as err "uhdesc can only be used after seqlogit10 when the sigma() option is specified"
		exit 198
	}
	if "`overat'" != "" {
		local overop "overat(`overat')"
	}
	local ofinterest "`e(ofinterest)'"
	local over "`e(over)'"

//Parse overat()	
	Parseoverat, `overop' 
	tempname result res p m s c t b
	local k_overat = `s(k_overat)'
	forvalues i = 1/`k_overat' {
		local overat`i' "`s(overat`i')'"
		local overatX`i' "`s(overatX`i')'"
	}
	local ovaratvars "`s(vars)'"

//Parse at()
	local k_at : word count `at'
	tokenize `at'
	forvalues i = 1/`k_at' {
		if mod(`i',2) == 1 {
			capture unab var : ``i''
			if _rc {
				di as err "every odd element in at() should be a variable"
				exit 198
			}
			if `: list var in overatvars' {
				di as err "variables specified in at() may not be specified in overat()"
				exit 198
			}
			local atvars "`atvars' `var'"
		}
		if mod(`i',2) == 0 {
			capture confirm number ``i''
			if _rc {
				capture confirm scalar ``i'' 
				if _rc {
					di as err "every even element in at() should be a number"
					exit 198
				}
			}
		}
	}
	if "`: list dups atvars'" != "" {
		di as err "each variable specified in at() may only be specified once"
		exit 198
	}
	
	if `k_overat'==0 {
		foreach var of local over {
			local posinat : list posof "`var'" in at
			if `posinat' == 0 {
				sum `var' if e(sample), meanonly
				local val = r(mean)
			}
			else {
				local posinat = `posinat' + 1
				local val : word `posinat' of `at'
			}
			qui replace _`ofinterest'_X_`var' = `ofinterest' * `val'
			local inter "`inter' _`ofinterest'_X_`var'"
		}
	}
	local checkint "`atvars' `inter'"
	if "`: list dups checkint'" != "" {
		di as err "interaction terms implicit in the over() option may not be specified in the at() option"
		exit 198
	}
	
	matrix `b' = e(b)
	local x : colnames `b'
	local x "`x' `e(sd_var)'"
	local x : list uniq x
	local cons "_cons"
	local x : list x - cons
	local x : list x - atvars
	local x : list x - inter
	local x : list x - ofinterest
	
	if "`x'" != "" {
		foreach var of varlist `x' {
			sum `var' if e(sample), meanonly
			qui replace `var' = r(mean)
		}
	}
	local i = 2
	if "`atvars'" != "" {
		foreach var of varlist `atvars' {
			if "`var'" != "`ofinterest'" {
				qui replace `var' = ``i''
			}
			local i = `i' + 2
		}
	}
	
//Parse overlab	
	if `: word count `overlab'' != `k_overat' & `: word count `overlab'' > 0 {
		di as error ///
		"number of labels specified in overlab() must equal the number of comparisons specified in overat()"
		"spaces are not allowed in a label, but underscores will be displayed in the table as a space"
		exit 198
	}
	tokenize `overlab'
	if "`overlab'" != "" {
		local allnumb = 1
	}
	else {
		local allnumb = 0
	}
	
	forvalues i = 1/`k_overat' {
		if "``i''" != "" {
			local lab`i' "``i''"
			capture confirm number ``i''
			if _rc {
				local allnumb = 0
			}
		}
		else {
			local lab`i' "`i'"
		}
		local labs "`labs' `lab`i''"
	}
	tempname b 
	matrix `b' = e(b)
	local base : coleq `b'
	local base : list uniq base
	local c_coln "`base'"
	
// creating empty matrix to store results
	if `k_overat' > 0 {
		matrix `result' = J(`=`k_overat'*`e(eqs)'',4,.)
		matrix colnames `result' = p(atrisk) mean(e) sd(e) corr(e,x)
		forvalues i = 1/`k_overat' {
			local rown`i' : subinstr local base " " " `lab`i'':", all
			local rown "`rown' `lab`i'':`rown`i''"
		}
		matrix rownames `result' = `rown'
		matrix `p' = J(`k_overat',`e(eqs)',.)
		matrix `m' = J(`k_overat',`e(eqs)',.)
		matrix `s' = J(`k_overat',`e(eqs)',.)
		matrix `c' = J(`k_overat',`e(eqs)',.)
		matrix `t' = J(`k_overat',1,.)
		matrix rownames `p' = `labs'
		matrix rownames `m' = `labs'
		matrix rownames `s' = `labs'
		matrix rownames `c' = `labs'
		matrix colnames `p' = `c_coln'
		matrix colnames `m' = `c_coln'
		matrix colnames `s' = `c_coln'
		matrix colnames `c' = `c_coln'
	}
	
// with overat() specified	
// compute the correlation (without fixing e(ofinterest)
	forvalues i = 1/`k_overat' {
		local k : word count `overat`i''
		tokenize `overat`i''
		forvalues j = 1(2)`k' {
			local l = `j' + 1
			qui replace ``j'' = ``l''
		}
		local k : word count `overatX`i''
		tokenize `overatX`i''
		forvalues j = 1(2)`k' {
			local l = `j' + 1
			qui replace ``j'' = ``l'' * `e(ofinterest)'
		}
		Analysis, `draws' corr
		matrix `res' = r(result)
		matrix `result'[`=(`i'-1)*`e(eqs)'+1',4] = `res'
		matrix `c'[`i',1] = `res''
		if `allnumb' {
			matrix `t'[`i',1] = `lab`i''
		}
	}

// fixing e(ofinterest) for other stats
	if `k_overat' > 0 {
		if `: list ofinterest in atvars' {
			local pos : list posof "`ofinterest'" in at
			local pos = `pos' + 1
			qui replace `ofinterest' = `: word `pos' of `at''
		}
		else{
			sum `ofinterest' if e(sample), meanonly
			qui replace `ofinterest' = r(mean)
		}
	}

// compute the other stats
	forvalues i = 1/`k_overat' {
			local k : word count `overat`i''
			tokenize `overat`i''
			forvalues j = 1(2)`k' {
				local l = `j' + 1
				qui replace ``j'' = ``l''
			}
			local k : word count `overatX`i''
			tokenize `overatX`i''
			forvalues j = 1(2)`k' {
				local l = `j' + 1
				qui replace ``j'' = ``l'' * `e(ofinterest)'
			}
			Analysis, `draws'
			matrix `res' = r(result)
			matrix `result'[`=(`i'-1)*`e(eqs)'+1',1] = `res'[1..., 1..3]
			matrix `p'[`i',1] = `res'[1...,1]'
			matrix `m'[`i',1] = `res'[1...,2]'
			matrix `s'[`i',1] = `res'[1...,3]'
	}
	
// compute stats if overat() is not specified
	if `k_overat' == 0 {
		Analysis, `draws' corr
		matrix `result' = J(`e(eqs)',4,.)
		matrix `result'[1,4] = r(result)
		if `: list ofinterest in atvars' {
			local pos : list posof "`ofinterest'" in at
			local pos = `pos' + 1
			qui replace `ofinterest' = `: word `pos' of `at''
		}
		else{
			sum `ofinterest' if e(sample), meanonly
			qui replace `ofinterest' = r(mean)
		}
		foreach var of local over {
			qui replace _`ofinterest'_X_`var' = `ofinterest' *`var'
		}
		Analysis, `draws'
		matrix `res' = r(result)
		matrix `result'[1,1] = `res'[1...,1..3]
		matrix rownames `result' = `base'
		matrix colnames `result' = p(atrisk) mean(e) sd(e) corr(e,x)
	}

	matlist `result', underscore format(%9.3f)
	return matrix result `result'
	if `k_overat' > 0 {
		matrix rownames `c' = `overlab'
		matrix rownames `s' = `overlab'
		matrix rownames `m' = `overlab'
		matrix rownames `p' = `overlab'
		return matrix c `c'
		return matrix s `s'
		return matrix m `m'
		return matrix p `p'
		if `allnumb' {
			return matrix t `t'
		}
	}
	restore
end

program define Parseoverat, sclass
	syntax ,               ///
	[                      ///        
	overat(string)         ///
	]

	// split overat()
	local k = 0
	while `"`overat'"' != "" {
		local `k++' 
		gettoken left overat : overat, parse(",")
		local overat`k' `left'
		sreturn local overat`k' "`overat`k''"
		gettoken comma overat : overat, parse(",")
	}
	local k_overat `k'
	sreturn local k_overat = `k_overat'
	
	// check if # elements is even
	forvalues i = 1/`k_overat' {
		local even : word count `overat`k''
		local even = `even' / 2
		capture confirm integer number `even'
		if _rc  {
			di as err "option overat() must contain an even number of elements"
			exit 198
		}
	}
	
	// check if odd elements are variables and even elements are numbers
	forvalues i = 1/`k_overat' {
		local j = 0
		foreach l of local overat`i' {
			if mod(`++j',2) == 1 {
				capture unab var : `l'
				if _rc {
					di as err "every odd element of option overat() should be a variable"
					exit 198
				}
				local vars "`vars' `var'"
			}
			if mod(`j',2) == 0 {
				capture confirm number `l'
				if _rc {
					capture confirm scalar `l'
					if _rc {
						di as err "every even element in option overat() should be a number"
						exit 198
					}
				}		
			}
		}
	}
	
	// add interaction terms between ofinterest() and over()
	local over `e(over)'
	local ofinterest `e(ofinterest)'
	
	forvalues i = 1/`k_overat' {
		foreach k of local over {
			if `: list posof "_`ofinterest'_X_`k'" in overat`i'' == 0 {
				local posinoverat : list posof "`k'" in overat`i'
				if `posinoverat' == 0 {
					di as err ///
					"the overat option needs to specify values for the variable(s) `over'"
					exit 198
				}
				local posinoverat = `posinoverat' + 1
				local valinoverat : word `posinoverat' of `overat`i''
				local val = `valinoverat'
				local overatX`i' "`overatX`i'' _`ofinterest'_X_`k' `val'"
				local vars "`vars' _`ofinterest'_X_`k'"
			}
		}
		sreturn local overatX`i' "`overatX`i''"
	}
	if "`vars'" != "" {
		local vars : list uniq vars 
		unab vars : `vars'
		sreturn local vars "`vars'"
	}

end

program define Analysis, rclass
	syntax ,                         ///
	[                                /// 
	draws(numlist max=1 >=1 integer) ///
	corr                             ///
	]
	
	forvalues i = 1/`e(eqs)' {
		tempname xb`i'
		qui predict `xb`i'', xb eq(#`i')
	}
	forvalues i = 1/`e(Ntrans)'{
		local end = `e(Nchoice`i')' - 1
		forvalues j = 0/`end' {
			local levs`i' "`levs`i'' `e(tr`i'choice`j')'"
		}
	}	
	forvalues i = 2/`e(Ntrans)'{
		local end = `i' - 1
		forvalues j = 1/`end' {
			local end2 = `e(Nchoice`j')' - 1
			forvalues k = 0/`end2' {
				local levs `e(tr`j'choice`k')'
				if `: list levs`i' in levs' {
					local t`i' "`t`i'' `j'"
					local c`i' "`c`i'' `k'"
				}
			}
		}
	}
	tempvar touse
	gen byte `touse' = e(sample)
	tempname result
	if "`draws'" == "" {
		local draws = `e(draws)'
	}
	mata comp_res(`draws')
	forvalues i = 1/`e(Ntrans)' {
		local rnames "`rnames' transition_`i'"
	}
	matrix rownames `result' = `rnames'

	if "`corr'" != "" {
		matrix colnames `result' = corr(e)
		matrix `result' = `result'[1...,4]
		return matrix result `result'
	}
	else {
		matrix colnames `result' = p mean(e) sd(e)
		matrix `result' = `result'[1...,1..3]
		return matrix result `result'
	}
end

mata
void comp_res(real scalar draws) {
	eqs     = st_numscalar("e(eqs)")
	Ntrans  = st_numscalar("e(Ntrans)")
	rho     = st_numscalar("e(rho)")
	if (st_global("e(sd_var)") != "") {
		st_var = .
		st_view(sd_var,.,st_global("e(sd_var)"), st_local("touse"))
		sd_delta = strtoreal(tokens(st_global("e(sd_delta)")))
	}
	if (st_global("e(pr)") != "") {
		mpnts   = st_matrix("e(mpnts)")[1,.]
		pr      = st_matrix("e(mpnts)")[2,.]
	}
	if (st_global("e(pr_mn)") != "" ) {
		sd_mn = strtoreal(tokens(st_global("e(sd_mn)")))
		pr_mn = strtoreal(tokens(st_global("e(pr_mn)")))
		m_mn  = strtoreal(tokens(st_global("e(m_mn)" )))
	}
	xbnames = J(1,eqs,"")
	for(i=1; i<= eqs; i++) {
		xbnames[1,i] = st_local("xb" + strofreal(i))
	}
	xb = .
	st_view(xb,.,xbnames,st_local("touse"))
	
	x=.
	st_view(x,.,st_global("e(ofinterest)"),st_local("touse"))
	if (st_global("e(pr)")!= "") {
		u = halton(draws*rows(xb), 1)
		e = J(draws*rows(xb),1,0)
		cumpr = 0
		for (i = 1; i <= length(pr); i++){
			prev_cumpr = cumpr
			cumpr = cumpr + pr[i]
			e = e :+ ( (u:<cumpr):&(u:>=prev_cumpr) ) :* mpnts[i]
		}
	}
	else if (st_global("e(pr_mn)") != "" ) {
		u = halton(draws*rows(xb), 2)
		e = J(draws*rows(xb),1,0)
		cumpr = 0
		for (i = 1; i <= length(pr_mn); i++){
			prev_cumpr = cumpr
			cumpr = cumpr + pr_mn[i]
			e = e :+ ( (u[.,1]:<cumpr):&(u[.,1]:>=prev_cumpr) ) :* ( ( invnormal(u[.,2]) :* sd_mn[i] ) :+ m_mn[i] )
		}
	}
	else if (st_global("e(uniform)") != "") {
		e = (halton(draws*rows(xb), 1) :- .5) :/ sqrt(1/12) 
	}
	else {
		e = invnormal(halton(draws*rows(xb), 1))
	}
	e = colshape(e, draws)
	
	if (!(rho == J(0,0,.) | st_local("corr") == "")) {
		mx = mean(x)
		sdx = sqrt(variance(x))
		e = (rho:*(x :- mx):/sdx :+ sqrt(1-rho^2):*e)
	}

	sigma = strtoreal(tokens(st_global("e(sigma)")))

	e = colshape(e,1)
	zero = J(rows(x),draws,0)
	x = colshape(x :+ zero, 1)
	c = J(Ntrans,1,"")
	t = J(Ntrans,1,"")
	for(i = 1; i <= Ntrans; i++ ){
		c[i] = st_local("c" + strofreal(i))
		t[i] = st_local("t" + strofreal(i))
	}
	eqstr = J(length(t),1,"")
	Nchoice = J(Ntrans,1,.)
	for(i=1; i <= Ntrans; i++) {
		Nchoice[i,1] = st_numscalar("e(Nchoice" + strofreal(i) + ")")
		eqstr[i] = st_global("e(eqstr" + strofreal(i) + ")")
	}
	
	result = J(eqs,4,.)
	l=1
	for (i=1; i<=Ntrans;i++){
		w = J(rows(x),1,0)
		ti = strtoreal(tokens(t[i]))
		ci = strtoreal(tokens(c[i]))
		for(j=1;j <= length(ti); j++){
			denom = J(rows(xb),draws,1)
			teqstr = strtoreal(tokens(eqstr[ti[j]]))
			for(k = 1; k <= (Nchoice[j,1]-1); k++) {
				if (st_global("e(sd_var)") == "") {
					t_sigma = sigma[1,teqstr[k]]
				}
				else {
					t_sigma = sigma[1,teqstr[k]] :+ (sd_delta[1,teqstr[k]] :* sd_var)
				}
				denom = denom :+ exp(xb[.,teqstr[k]] :+ (t_sigma:*colshape(e,draws))) 
			}
			if (ci[j]==0) {
				p = 1:/denom
			}
			else {
				if (st_global("e(sd_var)") == "") {
					t_sigma = sigma[1,teqstr[ci[j]]]
				}
				else {
					t_sigma = sigma[1,teqstr[ci[j]]] :+ (sd_delta[1,teqstr[ci[j]]] :* sd_var)
				}
				p = exp(xb[.,teqstr[ci[j]]]:+ (t_sigma:*colshape(e,draws))) :/ denom
			}
			w = w :+ colshape(ln(p),1)
		}
		w=exp(w)
		for (j=1; j <=(Nchoice[i,1]-1); j++) {
			if (st_global("e(sd_var)") == "") {
				t_e = sigma[1,l] :* e
			}
			else {
				t_e = ( sigma[1,l] :+ (sd_delta[1,l] :* sd_var) ) :* colshape(e,draws)
				t_e = colshape(t_e,1)
				
			}
			result[l,.] = mean(w), mean(t_e,w),sqrt(variance(t_e,w)),correlation((x,t_e),w)[2,1]
			l = l+1
		}
	}
	st_matrix(st_local("result"),result)
}
end

