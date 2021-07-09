*! 1.4.0 MLB 01Sep2010
*! combine version 1.3.0 and 1.2.0
*! 1.3.0 MLB 02Aug2010
*! use weights and allow if condition for individual latent variables
*! 1.2.0 MLB 01Aug2010
*! added the beta option
*! 1.1.0 MLB 04Jan2010
*! analytic derivatives for the delta method
*! 1.0.8 MLB 21Dec2009
*! Allow user to specify key variable in each variable block to determine the sign of the latent variables
*! 1.0.7 MLB 14Dec2009
*! Improve the display of the results and add the equation() option
*! 1.0.6 MLB 29Aug2009
*! improved labeling of control variables when the -eform- option is specified
*! 1.0.5 MLB 02Feb2009
*! various smaller improvements
*! 1.0.4 MLB 31Jan2009
*! using Mata to create the nlcom command in order to bypass limits in # of recursive definition of macros
*! 1.0.2 MLB 26Jan2009
*! correct bug in covariance matrix 
*! shorten the local containing the transformation for nlcom
*! 1.0.1 MLB 26Jan2009
*! makes calculation of covariance matrix and noheader option compatible with Stata 9.
*! 1.0.0 MLB 25Jan2009


program define sheafcoef, rclass
	version 9.0
	syntax , LATent(string) [EQuation(string) post iterate(passthru) level(passthru) eform beta]

// Default is to look at the first equation
// except in version 11 where with mlogit and mprobit where the first equation could be the base outcome
	if "`equation'" == "" {
		if c(stata_version)>= 11 & ( ("`e(cmd)'" == "mlogit" &  e(k_eq_base) == 1) | ///
		                             ("`e(cmd)'" == "mprobit" & e(i_base)== 1) ) {
			local equation "#2"
		}
		else {
			local equation "#1"
		}
	}
	else{
		if `: word count `equation'' > 1 {
			di as err "Only one equation can be specified in the equation() option"
			exit 198
		}
	}
	
// check if previous command stores coefficients in e(b)
	capture confirm matrix e(b)
	if _rc {
		di as err "previous estimation command did not store coefficients in e(b)"
		exit 198
	}

// beta can only be used with -regress-, -logit-, -probit-, -ologit-, or -oprobit-.	
	if "`beta'" != "" & !inlist("`e(cmd)'", "regress", "logit", "logistic", "probit") {
		di as err "the beta option can only be specified after estimating a model with either"
		di as err "regress, logit, logistic, or probit"
		exit 198
	}
// beta may not be combined with the svy prefix or cluster option
	if "`beta'" != "" & "`e(prefix)'" == "svy" {
		di as err "the beta option may not be specified after an estimation command that used the svy prefix"
		exit 198
	}
	if "`beta'" != "" & "`e(clustvar)'" != "" {
		di as err "the beta option may not be specified after an estimation command that used clustered standard errors"
		exit 198
	}
	
// beta and eform cannot be specified together
	if "`beta'" != "" & "`eform'" != "" {
		di as err "the beta and eform options cannot be specified together"
		exit 198
	}

// breaking latent() up 
	local k = 0
	local colon ":"
	while "`latent'" != "" {
		gettoken lat`++k' latent: latent, parse(;)
		local lat`k' : subinstr local lat`k' ":" " : "
		if `: list colon in lat`k'' {
			gettoken name`k' lat`k' : lat`k', parse(":")
			gettoken garbage lat`k' : lat`k', parse(":")
			local name`k' : list retokenize name`k'
		}
		else {
			local name`k' "lvar_`k'"
		}
		Parseif `lat`k''
		local lat`k' `s(lat)'
		local if`k' `s(if)'
		gettoken semicolon latent : latent, parse(;)
	}

// check if options
	forvalues i = 1/`k' {
		if "`if`i''" != "" {
			capture count `if`i'' & e(sample)
			if _rc {
				di as err "the if condition for latent variable `lvar_`i'' produced an error"
				exit 198
			}
			if r(N) == 0 {
				di as err "the if condition for latent variable `lvar`i'' in combination" 
				di as err "with the estimation sample resulted in zero observations"
				exit 2000
			}
		}
	}
// turn if conditions into weigths
	// find weights used in last estimation command
	if "`e(wexp)'" != "" {
		local wname "`e(wexp)'"
		gettoken equal wname : wname, parse("=")
		tempname w 
		qui gen double `w' = `wname'
	}
	else {
		tempname w
		qui gen byte `w' = 1
	}
	tempvar touse_w
	qui gen byte `touse_w' = 0 if e(sample)
	forvalues i = 1/`k' {
		quietly {
			replace `touse_w' = 0 if e(sample)
			replace `touse_w' = 1 `if`i''
			tempvar w_`i' 
			gen double `w_`i'' = `w'*`touse_w'
		}
	}
	
// find the key variable
	local plus "+"
	local minus "-"
	forvalues i = 1/`k'{
		local k`i' : word count `lat`i''
		tokenize `lat`i''
		local minus`i' = 0
		forvalues j = 1/`k`i'' {
			local `j' : subinstr local `j' "+" " + ", all
			local `j' : subinstr local `j' "-" " - ", all
			local tminus`i' : list minus in `j'
			local minus`i' = `minus`i'' + `tminus`i''
			local plus`i' : list plus in `j'
			if `tminus`i'' | `plus`i'' {
				local `j' : subinstr local `j' "+" "", all
				local `j' : subinstr local `j' "-" "", all
				unab var : ``j''
				local key`i' "`key`i'' `var'"
			}
		}
		if `: word count `key`i''' > 1 {
			di as err "each block of variables in the latent() option can contain only one key variable"
			exit 198
		}
		if "`key`i''" == "" {
			local sign`i' = 1
		}
		else {
			local sign`i' = cond(`minus`i'', -1, 1)*sign([`equation']_b[`key`i''])
		}
		
		local lat`i' : subinstr local lat`i' "+" "", all
		local lat`i' : subinstr local lat`i' "-" "", all
		unab lat`i' : `lat`i''
		if `: word count `lat`i''' < 2 {
			di as err "latent variable `k' is determined by less than 2 variables"
			exit 198
		}
		local raw "`raw' `lat`i''"
	}	
// check no dups inside latent()
	local dups : list dups raw
	if "`dups'" != "" {
		di as err "`: list uniq dups' appear multiple times in latent()"
		exit 198
	}  

// check latent in varlist
	Indeplist, eq(`equation')
	local x "`r(X)'"
	local check : list raw - x
	if "`check'" != "" {
		di as err "`check' where not used as explanatory variables in last `e(cmd)' model"
		exit 198
	}  

// collect the other variables
	local other : list x - raw
	
// collect the coeficient and var-cov matrices (left behind by -Indeplist-)
	tempname b v
	matrix `b' = r(b)
	matrix `v' = r(v)
	
// make matrices containing the locations of the relevant variables
	local cons "_cons"
	local vars : list x - cons
	local other_vars : list other - cons
	
	local colnames : colnames `b'
	forvalues i = 1/`k' {
		local k`i' : word count `lat`i''
		tempname ilat`i'
		matrix `ilat`i'' = J(1,`k`i'',.)
		tokenize `lat`i''
		forvalues j = 1/`k`i'' {
			matrix `ilat`i''[1,`j'] = `: list posof "``j''" in colnames'
		}
	}
	tempname iother
	local kother : word count `other'
	matrix `iother' = J(1,`kother',.)
	tokenize `other'
	forvalues i = 1 / `kother' {
		matrix `iother'[1,`i'] = `: list posof "``i''" in colnames'
	}
// similar but now for the v matrix
	forvalues i = 1/`k' {
		local v_var "`v_var' `lat`i''"
	}
	local v_var "`v_var' `other_vars'"
	tempname iv
	matrix `iv' = J(1, `:word count `v_var'',.)
	local i = 1
	foreach var of varlist `v_var' {
		matrix `iv'[1,`: list posof "`var'" in colnames'] = `i'
		local i = `i' + 1
	}


// perform delta method calculations
	tempvar touse
	gen byte `touse' = e(sample)
	capture di [`equation']_b[_cons]
	local nocons = _rc != 0

	mata: parse_sheaf()

	if "`beta'" != "" {
		tempname b_old v_old
		matrix `b_old' = `b'
		matrix `v_old' = `v'
		local old "b_old(`b_old') v_old(`v_old')"
		local pos_cons: list posof "main:_cons_b" in colname
		tempname sd_y
		if "`e(cmd)'" == "regress" {
			qui sum  `e(depvar)' if e(sample)
			scalar `sd_y' = r(sd)
		}
		if "`e(cmd)'" == "logit" | "`e(cmd)'" == "logistic" {
			tempvar xb
			predict double `xb', xb
			qui sum `xb' if e(sample)
			scalar `sd_y' = sqrt(r(Var) + (_pi^2)/3)
			drop `xb'
		}
		if "`e(cmd)'" == "probit" {
			tempvar xb
			predict double `xb', xb
			qui sum `xb' if e(sample)
			scalar `sd_y' = sqrt(r(Var) + 1)
			drop `xb'
		}

		mata : mk_beta()
		local cons "main:_cons_b"
		local  colname : list colname - cons
	}
	
	matrix  colnames `b' = `colname'
	matrix  colnames `v' = `colname'
	matrix  rownames `v' = `colname'

	tempname mod
	est store `mod'
	Post, b(`b') v(`v') depname(`e(depvar)') obs(`e(N)') esample(`touse') `old'
	ereturn display , `level'
	if "`eform'" != "" {
		di as txt "(_e) indicates the variables whose coefficients have been exponentiated"
	}
	if "`beta'" != "" {
		di as txt "(_b) indicates standardized coefficients"
	}
	if "`post'" == "" {
		qui est restore `mod'
	}
end

program define Parseif, sclass
	syntax anything [if]
	sreturn local lat `"`anything'"'
	sreturn local if `"`if'"'
end

program define Indeplist, rclass
		syntax , eq(string)
        version 7
		if strpos("`eq'", "#") {
			local eqnr = substr("`eq'",2,.)
			local eqns : coleq e(b), quoted
			local eqns : list uniq eqns
			local eqname : word `eqnr' of `eqns'
		}
		else {
			local eqname `eq'
		}
        tempname b v
        matrix `b' = e(b)
        matrix `b' = `b'[1,"`eqname':"]
		matrix `v' = e(V)
		matrix `v' = `v'["`eqname':","`eqname':"]
        local names : colnames `b'
        local dropped ""
        foreach var of local names {
            if [`eq']_b[`var'] == 0 & [`eq']_se[`var'] == 0 {
                local dropped "`dropped'`var' "
            }
        }
        local dropped : list retokenize dropped
        if "`dropped'" != "" {
            local names : list names - dropped
        }
        if "`names'" != "" {
            return local X "`names'"
        }
		return local eqname
		return matrix b = `b'
		return matrix v = `v'
end

program define Post, eclass
	syntax, b(name) v(name) depname(passthru) esample(passthru) obs(passthru) [b_old(name) v_old(name)]
	ereturn post `b' `v', `depname' `esample' `obs'
	ereturn local cmd "sheafcoef"
	if "`b_old'" != "" {
		ereturn matrix V_raw = `v_old'
		ereturn matrix b_raw = `b_old'
	}
end

mata:
void parse_sheaf() {
	k = strtoreal(st_local("k"))
	eq = "[" + st_local("equation") + "]"
	b = st_matrix(st_local("b"))
	V = st_matrix(st_local("v"))
	iother = st_matrix(st_local("iother"))
	
// ================= compute weighted variance matrix ============
	nvars= cols(tokens(st_local("vars")))
	v = J(nvars,nvars,0)
	x = .
	w = .
    start = 1
	for(i=1 ; i <= k ; i++) { 	
		st_view(x,.,tokens(st_local("lat" + strofreal(i))),st_local("touse"))
		st_view(w,.,tokens(st_local("w_"  + strofreal(i))),st_local("touse")) 
		fine = start + cols(x) - 1
		v[|start, start \fine, fine|] = variance(x,w)
		start = start + cols(x)
	}
	if ( st_local("other_vars") != "" ) {
		st_view(x,.,tokens(st_local("other_vars")),st_local("touse"))
		st_view(w,.,st_local("w"),st_local("touse"))
		fine = start + cols(x) - 1
		v[|start, start \fine, fine|] = variance(x,w)
		start = start + cols(x)	
	}
	p = st_matrix(st_local("iv"))
	v = v[p',p]

// =================== compute coefficients ====================
// effects OF latent variable (p)
	p = J(1,k, .)
	for(i=1 ; i<=k ; i++) {
		ilat = st_matrix(st_local("ilat" + strofreal(i)))

		p[1,i] = v[ilat[1],ilat[1]]* b[ilat[1]]^2
		for(j=2; j<=length(ilat); j++) {
			p[1,i] = p[1,i] + v[ilat[j],ilat[j]] *b[ilat[j]]^2
		}
		for(j=1 ; j <=length(ilat) ; j++) {
			for(l=1; l < j; l++) {
				p[1,i] = p[1,i] + 2*v[ilat[j],ilat[l]]*b[ilat[j]] * b[ilat[l]]
			}
		}
		p[1,i] = strtoreal(st_local("sign" + strofreal(i)))*sqrt(p[1,i])
	}
	if (st_local("eform")!="") {
		pp = exp(p)
	}
	else {
		pp = p
	}

// other control variables
	bother = J(1, length(iother),.)
	for(i=1 ; i <= length(iother) ; i++) {
		bother[1,i] = b[iother[i]]
		if (st_local("eform")!="") {
			bother[1,i] = exp(bother[1,i])
		} 
	}

// effects ON latent variables (a)
	nl = 0
	for(i=1 ; i <= k; i++){
		ilat = st_matrix(st_local("ilat" + strofreal(i)))
		nl = nl + length(ilat)
	}
	a = J(1,nl,.)
	l = 1
	for(i=1; i <= k ; i++) {
		ilat = st_matrix(st_local("ilat" + strofreal(i)))
		for(j=1; j <= length(ilat) ; j++){
			a[1,l] = b[ilat[j]]/p[i]
			l = l + 1
		}
	}
	
// =================== compute standard errors ====================
	G = J(length(b)+k , length(b), 0)

	iG = 1
// d p / d x
	for(i=1 ; i <= k ; i++) {
		ilat = st_matrix(st_local("ilat" + strofreal(i)))
		for(j=1 ; j <= length(ilat); j++) {
			dpdx = 0
			for(l=1;l<=length(ilat);l++) {
				dpdx = dpdx + v[ilat[j],ilat[l]]*b[ilat[l]]
			}
			G[i,ilat[j]] = dpdx/p[i]
			if (st_local("eform")!="") {
				G[i,ilat[j]] = G[i,ilat[j]]*exp(p[i])
			}
		}
		iG = iG + 1
	}

// d other / d x
	for(i=1 ; i <= length(iother); i++){
		if (st_local("eform")!="") {
			G[iG,iother[i]] = bother[1,i]
		}
		else {
			G[iG,iother[i]] = 1
		}
		iG = iG + 1
	}
// d a / d x
	for(i = 1 ; i <= k; i++){
		ilat = st_matrix(st_local("ilat" + strofreal(i)))
		for(j = 1; j<= length(ilat); j++) {
			for(l = 1; l <= length(ilat) ; l++) {
				dadx = 0
				for(m=1; m <= length(ilat) ; m++) {
					dadx = dadx + v[ilat[l], ilat[m]]*b[ilat[m]]
				}
				G[iG, ilat[l]] = (j==l)/p[i] - ( b[ilat[j]]* dadx) / (p[i]^3)
			}
			iG = iG + 1
		}
	}
	st_matrix(st_local("b"), (pp, bother, a) )
	st_matrix(st_local("v"), G*V*G')

// ========================= column names ========================
	if (st_local("eform")!= "") {
		colname = "main:" + st_local("name1") + "_e"
		for(i = 2 ; i <= k ; i++) {
			colname = colname + " main:" + st_local("name" + strofreal(i)) + "_e"
		}
		other = tokens(st_local("other"))
		for(i=1; i<=length(other);i++){
			colname = colname + " main:" + other[1,i] + "_e"
		}
	}
	else if (st_local("beta") != "") {
		colname = "main:" + st_local("name1") + "_b"
		for(i = 2 ; i <= k ; i++) {
			colname = colname + " main:" + st_local("name" + strofreal(i)) + "_b"
		}
		other = tokens(st_local("other"))
		for(i=1; i<=length(other);i++){
			colname = colname + " main:" + other[1,i] + "_b"
		}
	}
	else{
		colname = "main:" + st_local("name1")
		for(i = 2 ; i <= k ; i++) {
			colname = colname + " main:" + st_local("name" + strofreal(i))
		}
		other = tokens(st_local("other"))
		for(i=1; i<=length(other);i++){
			colname = colname + " main:" + other[1,i]
		}
	}
	
	if (st_local("beta") != "") {
		for(i=1; i <= k; i++) {
			lat = tokens(st_local("lat" + strofreal(i)))
			for(j=1; j<=length(lat); j++){
				colname = colname + " on_" + st_local("name" + strofreal(i)) + ":" + lat[1,j] + "_b"
			}
		}
	}
	else {
		for(i=1; i <= k; i++) {
			lat = tokens(st_local("lat" + strofreal(i)))
			for(j=1; j<=length(lat); j++){
				colname = colname + " on_" + st_local("name" + strofreal(i)) + ":" + lat[1,j]
			}
		}
	}
	st_local("colname", colname)
}

end

mata
void mk_beta() {
	k = strtoreal(st_local("k"))
	b = st_matrix(st_local("b"))
	V = st_matrix(st_local("v"))
	iother = st_matrix(st_local("iother"))
	x = .
	st_view(x,.,tokens(st_local("vars")),st_local("touse"))
	v = variance(x)
	sd_y=.
	sd_y = st_numscalar(st_local("sd_y"))
	
//============================== remove the constant (standardized constant == 0)
	pos_cons = strtoreal(st_local("pos_cons"))
	if (pos_cons != 0) {
		before = pos_cons - 1
		after = pos_cons + 1
		fine = length(b)
		b = b[1 .. before], b[after .. fine]
		V = V[1 .. before  , 1 .. before], V[1 .. before  , after .. fine] \
			V[after .. fine, 1 .. before], V[after .. fine, after .. fine]
		}

//================================================== make a vector of multipliers
// to standarize effect of latent variables on dependent variable
	mult = J(1, fine - 1, .)
	for (i = 1; i <= k; i++) {
		mult[i] = 1/sd_y
	}

// to standardize effect of other variables on dependent variable	
	if (pos_cons != 0 ) {
		l = length(iother) - 1
	}
	else {
		l = length(iother)
	}
	j = k + 1
	for(i=1 ; i <= l ; i++) {
		mult[1,j] = sqrt(v[iother[i], iother[i]]):/sd_y
		j = j + 1 
	}

// to standardize effect of observed variables on latent variable	
	for(i=1; i <= k ; i++) {
		ilat = st_matrix(st_local("ilat" + strofreal(i)))
		for(m=1; m <= length(ilat) ; m++){
			mult[1,j] = sqrt(v[ilat[m], ilat[m]])
			j = j + 1
		}
	}
//=========================================== return standardized effects and
//========================================== their variance-covariance matrix	
	st_matrix(st_local("b"), (mult:*b) )
	st_matrix(st_local("v"), (mult:*V:*mult') )
}
end

