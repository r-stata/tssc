*! version 1.1.4 MLB 13Jan2010
* version 1.1.0 MLB 31Mar2008
* bootstrap standard errors
* version 1.0.2 MLB 22Feb2008
* fix a bug in in the -normal- option
program define ldecomp, eclass properties(or)
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
	NORMal                               ///
	*                                    /// 
	]

// find number of equations
	marksample touse
	markout `touse' `direct' `indirect'
	qui levelsof `direct' if `touse'
	local levs "`r(levels)'"
	local n : word count `levs'
	local k = comb(`n',2)

// collect bootstrap options	
	local bsopts "`reps' `strata' `size' `cluster' `idcluster' `saving' `bca' `mse'" 
	local bsopts "`bsopts' `level' `nodots' `seed' `jackknifeopts'"

// nodecomp implies nolegend
if "`decomp'" != "" {
	local legend "legend"
}

// bootstrap and display results	
	if "`bootstrap'`decomp'" == "" {
		local 0 : list 0 - or
		if "`weight'" != "" {
			di as err ///
			"weights not allowed, specify the nobootstrap option"
			exit 101
		}
		bootstrap , notable `bsopts' : _ldecomp `0'
		if "`rindirect'" == "" {
			_coef_table, neq(`k') `or'
		}
		else {
			_coef_table, `or'
		}
	}
// no bootstrap and display results
	else {
		tempname b 
		_ldecomp `0'
		if "`decomp'" == "" {
			matrix `b' = e(b)'
			if "`or'" == "" {
				matrix colname `b' = Coef
				if "`rindirect'" == "" {
					local k2 = 5*`k'
					matrix `b' = `b'[1..`k2',1]
					matlist `b', border(rows) format(%10.7g)
				}
				else {
					matlist `b', border(rows) format(%10.7g)
				}
			}
			else {
				tempname b1 b2
				local k2 = 5*`k'
				matrix `b1' = `b'[1..`k2++',1]
				matrix `b2' = `b'[`k2'...,1]
				mata: decomp_or()
				if "`rindirect'" == "" {
					matrix colname `b1' = Odds_ratio
					matlist `b1', underscore border(rows) format(%10.7g)
				}
				else {
					matrix `b' = `b1' \ `b2'
					matrix colname `b' = Odds_ratio
					matlist `b', underscore border(rows) format(%10.7g)
				}
			}
		}
	}
	
// Legend
	if "`legend'" == "" {
		Legend, direct(`direct') `or' `rindirect'
	}

	
// display other tables
	
	if "`normal'" != "" {
		local title2 "(assuming that `indirect' is normally distributed)"
	}	
	
	if "`obspr'" != "" {
		di _n as txt "actual proportions"
		matlist e(prop_obs), underscore format(%11.3g) noblank border(rows) 
	}
	
	if "`predpr'" != "" {
		di as txt _n "predicted and counterfactual proportions"
		
		if "`title2'" != "" di as txt "`title2'"
		matlist e(prop_pred), underscore showcoleq(c) rowtitle("distribution") format(%11.3g) noblank border(rows) 
	}
	
	if "`predodds'" != "" {
		di as txt _n "predicted and counterfactual odds"
	
		if "`title2'" != "" di as txt "`title2'"
		matlist e(odds_pred), underscore showcoleq(c) rowtitle("distribution") format(%11.3g) noblank border(rows) 
	}
end

program define Legend
	syntax, direct(varlist) [or rindirect]
	if "`or'" == "" {
		di as txt "in equation i/j (comparing groups i and j)"
		di as txt "let the fist subscript of Odds be the distribution of the the indirect variable"
		di as txt "let the second subscript of Odds be the conditional probabilities"
		di as txt "Method 1: Indirect effect = ln(Odds_ij/Odds_jj)"
		di as txt "          Direct effect = ln(Odds_ii/Odds_ij)"
		di as txt "Method 2: Indirect effect = ln(Odds_ii/Odds_ji)"
		di as txt "          Direct effect = ln(Odds_ji/Odds_jj)"
	}
	else {
		di as txt "in equation i/j (comparing groups i and j)"
		di as txt "let the fist subscript of Odds be the distribution of the the indirect variable"
		di as txt "let the second subscript of Odds be the conditional probabilities"
		di as txt "Method 1: Indirect effect = Odds_ij/Odds_jj"
		di as txt "          Direct effect = Odds_ii/Odds_ij"
		di as txt "Method 2: Indirect effect = Odds_ii/Odds_ji"
		di as txt "          Direct effect = Odds_ji/Odds_jj"
	}
	
	if "`rindirect'" != "" {
		di as text _n "the size of the indirect effect relative to the total effect are shown in" "
		di as text "equations i/jr"
	}

	if "`: value label `direct''" != "" {
		di _n "value labels"
		qui levelsof `direct'
		foreach i in `r(levels)' {
			di as txt %4.0f `i' " `: label (`direct') `i''"
		}
	}
	
end

mata:
void decomp_or() {
	matname = st_local("b1")
	mat = st_matrix(matname)
	mat = exp(mat)
	stripe = st_matrixrowstripe(matname)
	st_matrix(matname, mat)
	st_matrixrowstripe(matname, stripe)
}
end

