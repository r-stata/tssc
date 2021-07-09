*! version 1.0.5 13feb2013 Daniel Klein

pr mivif
	vers 11.2
	
	// check basic setting
	u_mi_assert_set flong
	
	loc M `_dta[_mi_M]'
	if !(`M') {
		di as err "no imputations"
		e 459
	}
	
	// parse user
	syntax [varlist(default = none num fv)] ///
	[if/][in/] [aw fw iw pw] /// weights not documented
	[, m(numlist int sort) /// synonym for imputations()
	Imputations(numlist int sort) UNCentered nofisherz ///
	nosort FORmat(passthru) /// not documented
	coef vif ] // retained from older version
	
	// synonym
	if ("`imputations'" != "") {
		if ("`m'" != "") & ("`m'" != "`imputations'") {
			di as err "imputations() and m() missmatch"
			e 198
		}
		loc m `imputations'
	}
	
	// post estimation or user specified varlist
	if ("`varlist'" != "") {
		loc postest 0
		fvexpand `varlist'
		foreach v in `r(varlist)' {
			if strmatch("`v'", "*bn.*") {
				di as err "ibn. operator not allowed with mivif"
				e 198
			}
			if (strmatch("`v'", "*b*.*")) continue
			loc rnams `rnams' `v'
			fvrevar `v'
			loc rhs `rhs' `r(varlist)'
		}
	}
	else {
		loc postest 1
		foreach x in if in weight {
			if ("``x''" != "") {
				di as err "`x' not allowed"
				e 101
			}
		}
		if ("`e(cmd_mi)'" != "regress") {
			di as err "estimation command must be " ///
			"{bf:mi estimate : regress}"
			e 301
		}
		if ("`e(prefix)'" != "") {
			di as err "`e(prefix)' not allowed with mivif"
			e 198
		}
	}
	
	// m option
	if ("`m'" == "") {
		if !(`postest') {
			numlist "1/`M'" ,int r(>=0 <=`M') sort
			loc m `r(numlist)'
		}
		else loc m `e(m_est_mi)'
		loc nm : word count `m'
	}
	else {
		loc m : list uniq m
		loc nm : word count `m'
		if (`: word 1 of `m'' < 0) | (`: word `nm' of `m'' > `M') {
			di as err "imptations() must be between 0 and `M'"
			e 125
		}
	}
			
	// get regress command and rhs
	loc hascons 0
	if (`postest') {
		loc 0 `e(cmdline)'
		syntax anything [if/][in/][aw fw iw pw][, *]
		
		tempname bmi
		mat `bmi' = e(b_mi)
		loc vars : coln `bmi'
		foreach v of loc vars {
			if ("`v'" == "_cons") {
				loc hascons 1
				continue
			}
			if (`bmi'[1, `: list posof "`v'" in vars']) {
				loc rnams `rnams' `v'
				fvrevar `v'
				loc rhs `rhs' `r(varlist)'
			}
		}
		if !(`hascons') {
			di as txt "(note: computing uncetered VIFs)"
			loc uncentered implied
		}
	}
		
	// get number of rhs variables
	loc nrows : word count `rhs'
	if !(`nrows') {
		di as err "no right-hand-side variables"
		e 111
	}
	
	// set if in and weight
	if (`"`macval(if)'"' != "") loc and & 
	if ("`in'" != "") {
		loc in : subinstr loc in "/" ", "
		if !(`postest') {
			su _mi_id ,mean
			if (max(`in') > r(max)) {
				di as err "Obs. nos. out of range"
				e 198
			}
		}
		loc if `if' `and' inrange(_mi_id, `in')
		loc and &
		loc in
	}
	if ("`weight'" != "") loc weight [`weight' `exp']
	
	// uncentered
	if ("`uncentered'" != "") {
		if (`hascons') {
			tempvar _cons
			qui mi pas : g byte `_cons' = 1
			loc rnams `rnams' _cons
			loc rhs `rhs' `_cons'
			loc ++nrows
		}
		loc noc noc
	}
	
	// fisherz
	if ("`fisherz'" != "") loc fz sqrt(e(r2))
	else loc fz atanh(sqrt(e(r2)))
	
	// set up results matrix and save elist
	tempname vif elst
	mat `vif' = J(`nrows', 1, 0)
	cap _est hold `elst'
	
	// run regression and collect Fisher transormed R
	cap n {
		forv j = 1/`nrows' {
			foreach mid of loc m {
				qui reg `rhs' if `if' `and' (_mi_m == `mid') ///
				`weight' ,`noc'
				mat `vif'[`j', 1] = `vif'[`j', 1] + `fz'
			}				
			gettoken first rhs : rhs
			loc rhs `rhs' `first'
		}
	}
	
	// restore elist and exit if error
	loc rc = _rc
	cap _est unhold `elst'
	if (`rc') e `rc'
	
	// calculate VIF and return in r()
	m : mfmivif(st_matrix("`vif'"), ///
	`nm', "`rnams'", "`fisherz'", "`sort'")
	
	// output
	if ("`format'" == "") loc format format(%9.2f)
	matlist r(mivif) ,row("Variable") lin(rowt) nodotz `format'
end

vers 11.2
m :
void mfmivif(real matrix vif, 
			real scalar nm, 
			string scalar rnams,
			| string scalar fz,
			string scalar sort)
{	
	string matrix ronams
	
	ronams = tokens(rnams)'
	
	if (fz == "") {
		vif = 1 :/ (1 :- tanh(vif :/ nm) :^ 2)
	}
	else vif = 1 :/ (1 :- (vif :/ nm) :^2)
	
	if (sort == "") {
		vif = vif, (1::rows(vif))
		vif = sort(vif, (-1))
		ronams = ronams[vif[., 2]]
		vif = vif[., 1]
	}
	ronams = ronams\ "Mean VIF"
	ronams = J(rows(ronams), 1, ""), ronams
	
	vif = vif\ mean(vif)
	vif = vif, (1 :/ vif[., 1])
	vif[rows(vif), 2] = .z
	
	st_rclear()
	st_matrix("r(mivif)", vif)
	st_matrixcolstripe("r(mivif)", (("", "VIF")\ ("", "1/VIF")))
	st_matrixrowstripe("r(mivif)", ronams)
}
end
e

1.0.5	13feb2013	user supplied varlist allowed
					new option -nofisherz-
					option -imputations- match -mi est- syntax
					handle -in- qualifier
					add Mata function
					fix potential problems with -uncentered-
					-version- is 11.2 (was 11.1)
					code polish
1.0.4	29apr2012	complete rewrite code
					calculate VIFs on Fisher transformed Rs
1.0.3	23apr2012	(beta) fix bug with weights
1.0.2	25apr2011 	no longer drop program -mivif-
					use u_mi_assert_set
					exit if M=0 with proper error
					minor changes to make code more readable
1.0.1	20mar2011 	major changes: mivif_srcm.ado no longer needed
					matrix __vif_matrix_42_ no longer created
					mean VIF default m = 1, ..., M was m = 0, ..., M
