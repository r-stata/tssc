*! version 1.2.0 11dec2015 daniel klein

pr rotate2
	vers 9.2
	
	syntax ///
	[ ,	///
		noSORT 			///
		UNIQueness		///
		VARNames 		///
		noLabel 		///
		SPARE 			///
		TWidth(str)		///
		noTRIM			///
		MATrix(name) 	///
		BLanks(numlist max=1 >=0) ///
		FORmat(str)		///
		* ///
	]
	
	if ("`spare'" != "") {
		loc qui qui
	}
	
	if ("`blanks'" != "") {
		loc options `options' bl(`blanks')
	}
	
	if ("`format'" != "") {
		cap n conf numeric fo `format'
		if (_rc) {
			e 198
		}
		loc options `options' for(`format')
	}
	else {
		loc format %8.4f
	}
	
	if ("`twidth'" != "") {
		cap n conf integer n `twidth'
		if !(_rc) {
			cap as inrange(`twidth', 8, 32)
		}
		if (_rc) {
			di as err "twidth() invalid"
			e 198
		}
	}
	/* no else statement on purpose
		Mata resets twidth */
	
	
	/*
		main */
		
	`qui' rot ,`options'
	
	conf mat e(r_L)
	if ("`uniqness'" != "") {
		conf mat e(Psi)
	}
	
	tempname L
	m : mf_rotate2("`L'")
	
	/*
		display results */
		
	loc dopts `sort' `uniqueness' blanks(`blanks')
	loc dopts `dopts' fmt(`format') tw(`twidth') 
	Display `L' , `dopts'
	
	/*
	
		return matirx */
	
	if ("`matrix'" != "") {
		mat `matrix' = `L'
	}
end

pr Display
	
	vers 9.2
	
	syntax anything(name = L) ///
	[ , SORT UNIQUENESS BLANKS(str) FMT(str) TW(str) ]

	if (e(cmd) == "factor") {
		loc title "factor loadings"
	}
	else if (e(cmd) == "pca") {
		loc title "components"
	}
	else {
		loc title `e(cmd)'
	}
	if mi("`sort'") {
		loc title `"`title' (sorted)"'
	}
	loc title `"Rotated `title'"'
	
	loc nrow = rowsof(`L')
	loc ncol = colsof(`L') - ("`uniqueness'" != "")
	
	forv r = 2/`nrow' {
		loc rsp `rsp' &
	}
	loc rsp --`rsp'-
	
	forv c = 2/`ncol' {
		loc csp `csp' & `fmt' 
	}
	loc csp o4 & %`tw's | `fmt' `csp'
	
	if ("`uniqueness'" != "") {
		loc csp `csp' | C w12 `fmt'
	}
	loc csp `csp' o1 &
	
	if ("`blanks'" != "") {
		loc note {txt}(blanks represent ///
		abs(loading)<{res}`blanks'{txt})
		loc note di "{col 4}`note'"
	}
	
	matlist `L' ,csp(`csp') rsp(`rsp') ///
	tit(`"`title'"') row("Variable") nodotz under
	`note'
end

vers 9.2

m :

void mf_rotate2(string scalar Lnam)
{
	real matrix L, Psi, S
	string rowvector coln, varn, varl
	real scalar blk
	
	L = st_matrix("e(r_L)")
	coln = st_matrixcolstripe("e(r_L)")[., 2]
	varn = st_matrixrowstripe("e(r_L)")[., 2]
	
	/*
		sort loadings
		
		matrix S is rows(L) x 3
		
		S[., 1] :== variable position
		S[., 2] :== factor number of max (row) loading
		S[., 3] :== max (row) loading
		
		we sort on factor number and loading
		
		we only keep S[., 1] as our sort index vector
	*/
		
	if (st_local("sort") == "") {
		
		/*
			build sorting index */
		
		S = (1::rows(L)), J(rows(L), 2, .)
		for (r = 1; r <= rows(L); ++r) {
			S[r, 3] = max(abs(L[r, .]))[1, 1]
			S[r, 2] = select((1..cols(L)), ///
			(abs(L[r, .]) :== S[r, 3]))[1, 1]
		}
		S = sort(S, (2, -3))[., 1]
		
		/*
			sort varnames and loadings matrix */
		
		varn = varn[S]
		L = L[S, .]
	}
	
	/*
		blanks option */
	
	if (st_local("blanks") != "") {
		blk = strtoreal(st_local("blanks"))
		for (r = 1; r <= rows(L); ++r) {
			for (c = 1; c <= cols(L); ++c) {
				if (abs(L[r, c]) <= blk) {
					L[r, c] = .z
				}
			}
		}
	}
	
	/*
		add sorted uniqueness vector */
		
	if (st_local("uniqueness") != "") {
		Psi = st_matrix("e(Psi)")'
		if (st_local("sort") == "") {
			Psi = Psi[S]
		}
		coln = coln\ st_matrixrowstripe("e(Psi)")[., 2]
		L = (L, Psi)
	}
	
	/*
		row names */
	
	if (st_local("label") != "") {
		varl = varn
	}
	else {
		varl = J(rows(varn), 1, "")
		for (i = 1; i <= rows(varl); ++i) {
			varl[i] = st_varlabel(varn[i])
			if (varl[i] == "") {
				varl[i] = varn[i]
			}
		}
		if (st_local("trim") == "") {
			varl = strtrim(stritrim(varl))
		}
		
		/*
			strip invalid characters 
			from variable labels
			
			we use them as matrix rownames
		*/
		
		varl = subinstr(varl, char(46), "")
		varl = subinstr(varl, char(58), "")
		varl = subinstr(varl, char(34), "")
		varl = subinstr(varl, char(96), "")
		varl = subinstr(varl, char(32), char(95))
		
		if (st_local("varnames") != "") {
			varl = "(" :+ varn :+ ")_" :+ varl
		}
		varl = abbrev(varl, 31)
	}
	
	/*
		reset twidth for display */
	
	if (st_local("twidth") == "") {
		st_local("twidth", strofreal(max((max(strlen(varl)), 12))))
	}
	
	/*
		return matrix */
	
	st_matrix(Lnam, L)
	st_matrixrowstripe(Lnam, (J(rows(L), 1, ""), varl))
	st_matrixcolstripe(Lnam, (J(cols(L), 1, ""), coln))
}

end
e

1.2.0	11dec2015	new option -matrix- returns results matrix
1.1.0	05may2015	new subroutine displays new output
					new option -nolabel-
					rewrite options -format- and -twidth-
					fix bug option blank affected uniqeness
1.0.0	10oct2014	based on lab_e_r_L
					wrapper for -rotate-
