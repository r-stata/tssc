*! version 2.0.1 27jan2017 daniel klein
pr corsp , by(o) // rclass
	vers 10.1
	
	tempname rr
	
	if (c(stata_version) < 12) {
		cap _ret drop `rr'
	}
	
	if (replay()) {
		if (_by()) {
			err 190
		}
		_ret hold `rr'
		_ret res `rr' , h
		cap n corsp_report `0'
		if (_rc) {
			_ret res `rr'
		}
		e _rc
			/* done */
	}
	
	if (_by()) {
		loc By by `_byvars' `_byrc0' :
	}
	
	_return hold `rr'
	`By' _corsp `0'
end

pr _corsp , by(r)
	vers 10.1
	
	syntax varlist(min = 2 num) [if] [in] [ , * ]
	
	corsp_parse_opts norecall , `options'
	
	corsp_get_lo_up , `lower' `upper'
	
	/*
		set locals
			
			tit_<dim> 	= Pearson 	| Spearman	| Kendall
			cmd_<dim> 	= corsp_cor | spearman 	| ktau
			mat_<dim> 	= r(C) 		| r(Rho) 	| r(Tau_{a|b})
			coef_<dim> 	= r 		| rho 		| taua|taub
			
			<dim> 		= lower|upper
	*/
	
	loc issym = ("`coef_lower'" == "`coef_upper'")
	
	if ("`pw'" != "") {
		loc nov nov
	}
	
	marksample touse , `nov'
	qui cou if (`touse')
	if (r(N) < 2) {
		err 2001
	}
	
	/*
		estimate */
		
	tempname Lower Upper P_lower P_upper Nobs
	
	foreach dim in lower upper {
		loc Dim = strproper("`dim'")
		
		qui `cmd_`dim'' `varlist' if (`touse') , mat `pw' `adjust'
		
		mat ``Dim'' 	= r(`mat_`dim'')
		mat `P_`dim'' 	= r(P)
		mat `Nobs' 		= r(Nobs)
		
		if (`issym') {
			continue , br
		}
	}
	
	if (`issym') {
		mat `Upper' 	= `Lower'
		mat `P_upper' 	= `P_lower'
	}
	
	/*
		return */
	
	corsp_return , ///
		lowercoef(`coef_lower') 	///
		uppercoef(`coef_upper') 	///
		lowername(`mat_lower') 		///
		uppername(`mat_upper') 		///
		lowermatrix(`Lower') 		///
		uppermatrix(`Upper') 		///
		lowerp(`P_lower') 			///
		upperp(`P_upper') 			///
		nobs(`Nobs')
	
	/*
		report */
		
	corsp , ///
		`switch' 			///
		`sig' 				///
		`pvalues' 			///
		print(`print') 		///
		format(`format') 	///
		`obs' 				///
		`returnrp'
end

pr corsp_report , rclass
	vers 10.1
	
	syntax [ , * ]
	
	if ("`r(cmd)'" != "corsp") {
		syntax varlist
			/* error */
	}
	
	corsp_parse_opts , `options'
	
	corsp_get_lo_up , `lower' `upper'
	
	/*
		set locals
			
			tit_<dim> 	= Pearson 	| Spearman	| Kendall
			cmd_<dim> 	= corsp_cor | spearman 	| ktau
			mat_<dim> 	= r(C) 		| r(Rho) 	| r(Tau_{a|b})
			coef_<dim> 	= r 		| rho 		| taua|taub
			
			<dim> 		= lower|upper
	*/
	
	if mi("`switch'") {
		loc lo `mat_lower'
		loc up `mat_upper'
		loc LOWER lower
		loc UPPER upper
	}
	else {
		loc lo `mat_upper'
		loc up `mat_lower'
		loc LOWER upper
		loc UPPER lower
	}
	
	conf mat r(`lo')
	conf mat r(`up')
	
	tempname R P Nobs Print Rdotz Pdotz Nobsdotz
	
	if ("`coef_`LOWER''" == "`coef_`UPPER''") {
		loc title "`tit_`LOWER''"
		mat `R' = r(`lo')
		mat `P' = r(`lo'_p)
	}
	else {
		loc title "`tit_`LOWER''/`tit_`UPPER''"
		m : corsp_lo_up("r(`lo')", "r(`up')", "`R'")
		m : corsp_lo_up("r(`lo'_p)", "r(`up'_p)", "`P'")
		
		loc names : colnames r(`lo')
		foreach mat in R P {
			mat rown ``mat'' = `names'
			mat coln ``mat'' = `names'
		}
	}
	
	if mi("`sig'`pvalues'`obs'`print'") {
		mat `Print' = `R'
	}
	else {
		mat `Nobs' = r(Nobs)
		if ("`print'" != "") {
			mat `Rdotz' = `R'
			mat `Pdotz' = `P'
			mat `Nobsdotz' = `Nobs'
			m : corsp_to_dotz( ///
				"`Rdotz'", 		///
				"`Pdotz'", 		///
				"`Nobsdotz'", 	///
				`print')
			loc dotz dotz
		}
		forv j = 1/`= rowsof(`R')' {
			mat `Print' = nullmat(`Print')\ `R`dotz''[`j', 1...]
			if ("`sig'`pvalues'`obs'" != "") {
				if ("`sig'`pvalues'" != "") {
					mat `Print' = `Print'\ `P`dotz''[`j', 1...]
				}
				if ("`obs'" != "") {
					mat `Print' = `Print'\ `Nobs`dotz''[`j', 1...]
				}
				mat `Print' = `Print'\ J(1, colsof(`R'), .z)
				if ("`coef_`LOWER''" == "`coef_`UPPER''") {
					m : corsp_makesymmetric("`Print'", `j')
				}
			}
		}
		loc names : colnames `R'
		mat coln `Print' = `names'
		
		local n_us	: word count `sig'`pvalues' `obs'
		if (`n_us') {
			local _us 	: display _dup(`= `n_us' + 1') " _ "
			local names : subinstr local names " " " `_us' " , all
			local under under
		}
		mat rown `Print' = `names' `_us'
		loc opts nodotz `under'
	}
	
	di as txt _n "`title' correlation matrix" _n
	matlist `Print' , format(`format') `opts'
	
	ret add
	
	ret loc lower `coef_`LOWER''
	ret loc upper `coef_`UPPER''
	
	ret mat P = `P'
	ret mat R = `R'
	
	if ((("`pvalues'" != "") & mi("`obs'`print'")) ///
	| ("`returnrp'" != "")) {
		if ((c(stata_version) >= 12) & mi("`returnrp'")) {
			loc hidden , "hidden"
		}
		m : st_matrix("r(RP)", st_matrix("`Print'")`hidden')
		m : st_matrixrowstripe("r(RP)", st_matrixrowstripe("`Print'"))
		m : st_matrixcolstripe("r(RP)", st_matrixcolstripe("`Print'"))
		ret add
	}
end

pr corsp_parse_opts
	vers 10.1
	
	if (!replay()) {
		loc PW PW
		loc Bonferroni Bonferroni
		loc SIDak SIDak
	}
	
	syntax [ anything ] ///
	[ , ///
		`PW' 								///
		LOwer(passthru) 					///
		UPper(passthru) 					///
		SWITCH 								///
		SIG 								///
		PValues 							/// no longer documented
		Print(numlist max = 1 >= 0 <= 1) 	///
		`Bonferroni' 						///
		`SIDak' 							///
		Format(str) 						/// no longer documented
		Obs 								/// not documented
		RETURNRP 							///
	]
	
	local adjust "`bonferroni' `sidak'"
	opts_exclusive "`adjust'"
	
	if ("`format'" != "") {
		cap n conf numeric fo `format'
		if (_rc) {
			e 198
		}
	}
	else {
		loc format %7.4f
	}
	
	loc c_opts pw lower upper switch sig ///
		pvalues print adjust format obs returnrp
	foreach opt of loc c_opts {
		c_local `opt' ``opt''
	}
end

pr corsp_get_lo_up
	vers 10.1
	
	syntax ///
	[ , ///
		LOwer(str) 	///
		UPper(str) 	///
	]
	
	if ("`r(cmd)'" == "corsp") {
		loc default_lower `r(lower)'
		loc default_upper `r(upper)'
	}
	else {
		loc default_lower r
		loc default_upper rho
	}
	
	if mi("`lower'") {
		loc lower `default_lower'
	}
	if mi("`upper'") {
		loc upper `default_upper'
	}
	
	foreach dim in lower upper {
		loc `dim' = strlower("``dim''")
		loc len : length loc `dim'
		if inlist("``dim''", "r", ///
		substr("correlate", 1, max(3, `len'))) {
			loc `dim' r
			loc tit Pearson
			loc cmd corsp_cor
			loc mat C
		}
		else if inlist("``dim''", "rho", "spearman") {
			loc `dim' rho
			loc tit Spearman
			loc cmd spearman
			loc mat Rho
		}
		else if inlist("``dim''", "taua", "taub") {
			loc tit Kendall
			loc cmd ktau
			loc mat = "Tau_" + substr("``dim''", -1, .)
		}
		else {
			di as err "{bf}`dim'(){sf} must be one of " ///
				"{bf:r{sf:,} rho{sf:,} taua{sf: or} taub}"
			e 198
		}
		
		foreach prop in tit cmd mat {
			c_local `prop'_`dim' ``prop''
		}
		
		c_local coef_`dim' ``dim''
	}
end

pr corsp_cor , rclass
	vers 10.1
	
	syntax varlist if [ , MATrix PW BONFERRONI SIDAK ]
	
	marksample touse , nov
	
	tempname C N P r N2 p adj_k
	
	loc nvar : word count `varlist'
	
	if ("`bonferroni'`sidak'" != "") {
		sca `adj_k' = `nvar'*(`nvar' - 1)/2
	}
	
	if ("`pw'" != "") {
		mat `C' = J(`nvar', `nvar', .)
		mat `N' = J(`nvar', `nvar', .)
	}
	else {
		qui cor `varlist' if (`touse')
		mat `C' = r(C)
		mat `N' = J(`nvar', `nvar', r(N))
	}
	mat `P' = J(`nvar', `nvar', .)
	
	token `varlist'
	forv j = 1/`nvar' {
		forv k = `j'/`nvar' {
			if ("`pw'" != "") {
				cap cor ``j'' ``k'' if (!mi(``j'', ``k'')) & (`touse')
				mat `C'[`j', `k'] = r(rho)
				mat `N'[`j', `k'] = r(N)
			}
			sca `r' = `C'[`j', `k']
			sca `N2' = `N'[`j', `k'] - 2
			if (`r' != .) {
				if (`r' == 1) {
					mat `P'[`j', `k'] = 0
				}
				else {
					sca `p' = 2*ttail(`N2', ///
						abs(`r')*sqrt(`N2')/sqrt(1-`r'^2))
					if ("`bonferroni'" != "") {
						sca `p' = min(1, `p'*`adj_k')
					}
					else if ("`sidak'" != "") {
						sca `p' = min(1, 1 - (1 - `p')^(`adj_k'))
					}
					mat `P'[`j', `k'] = `p'
				}
			}
			if (`j' != `k') {
				if ("`pw'" != "") {
					mat `C'[`k', `j'] = `C'[`j', `k']
					mat `N'[`k', `j'] = `N'[`j', `k']
				}
				mat `P'[`k', `j'] = `P'[`j', `k']
			}
		}
	}
	
	foreach mat in C P N {
		mat rown ``mat'' = `varlist'
		mat coln ``mat'' = `varlist'
	}
	
	ret mat C 		= `C'
	ret mat P 		= `P'
	ret mat Nobs 	= `N'
end

pr corsp_return , rclass
		vers 10.1
		
		syntax , ///
			LOWERCOEF(name) 	///
			UPPERCOEF(name) 	///
			LOWERNAME(name) 	///
			UPPERNAME(name) 	///
			LOWERMATRIX(name) 	///
			UPPERMATRIX(name) 	///
			LOWERP(name) 		///
			UPPERP(name) 		///
			NOBS(name)
		
		ret loc upper `uppercoef'
		ret loc lower `lowercoef'
		ret loc cmd "corsp"
		
		ret mat Nobs = `nobs'
		foreach dim in lower upper {
			ret mat ``dim'name'_p 	= ``dim'p'
			ret mat ``dim'name' 	= ``dim'matrix'
		}
end

vers 10.1

m :

void corsp_lo_up(string scalar lo,
				string scalar up,
				string scalar name)
{
	real matrix Lo, Up
	
	Lo = st_matrix(lo)
	Up = st_matrix(up)
	
	st_matrix(name, (lowertriangle(Lo) + uppertriangle(Up, 0)))
}

void corsp_to_dotz(string scalar Rmat, 
				string scalar Pmat,
				string scalar Nmat,
				real scalar print)
{
	real matrix R, P, N
	
	R = st_matrix(Rmat)
	P = st_matrix(Pmat)
	N = st_matrix(Nmat)
	
	for (r = 1; r <= rows(P); ++r) {
		for (c = 1; c <= cols(P); ++c) {
			if (P[r, c] > print) {
				R[r, c] = P[r, c] = N[r, c] = .z
			}
		}
	}
	
	st_matrix(Rmat, R)
	st_matrix(Pmat, P)
	st_matrix(Nmat, N)
}

void corsp_makesymmetric(string scalar name, 
						real scalar col)
{
	real matrix Z
	
	Z = st_matrix(name)
	if (col < cols(Z)) {
		Z[., (col+1)..cols(Z)] =J(rows(Z), cols(Z) - col, .z)
		st_matrix(name, Z)
	}
}

end
e

2.0.1 	27jan2017	bug fix: rownames with option sig
					new option returnrp
2.0.0	17aug2016	additional returned results
					may replay results
					optionally estimate ktau
					new option pw uses pairwise deletion
					new options upper, lower and switch
					new option print
					renamed option pvalues sig
					bonferroni and sidak adjusted pvalues
					new option obs (not documented)
1.1.1	13jan2014	Stata version 10.1 required
					fix bug loop for X matrix
					fix bug run -spearman- with option -matrix-
					sent to SSC
1.1.0	12jan2014	add option -pvalues- and -format-
					fix bug with -if- and -in- qualifiers
					change output
					posted on Statalist (12jan2014)
1.0.0	09oct2013	posted on Statalist (11jan2014)
