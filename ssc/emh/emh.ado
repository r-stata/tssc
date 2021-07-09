*! emh.ado Version 1.0 JRC 2010-10-12
program define emh, rclass byable(onecall)
	version 11.1
	syntax varlist(min=2 max=2 numeric) [if] [in] [fweight], [Strata(varlist) Correlation ///
		Anova General Transformation(string)]

	// Validate input
	local model `correlation' `anova' `general'
	if (1 < `: word count `model'') {
		display in smcl as error "Only one of " as input "`model'" as error " may be specified"
		error 178
	}

	local transformation = cond("`transformation'" == "", "table", "`transformation'")
	if !inlist("`transformation'", "table", "rank", "ridit", "modridit") &  ///
		!inlist("`transformation'", "logrank", "savage", "median", "mood", "klotz", "vdw") {
		display in smcl as error "`transformation' scores not recognized"
		error 178
	}

	marksample touse
	markout `touse' `strata', strok

	// Generate column of ones for -summarize-
	tempname ones
	generate byte `ones' = 1

	// Generate unique identifier to strata variable combinations
	tempvar strata_var
	local strata_tally : word count `strata'
	if (`strata_tally' == 1) {
		local strata_type : type `strata'
		if (substr("`strata_type'", 1, 3) == "str") {
			createUniqueStrataVariable `strata_var' if `touse', strata(`strata') one string
		}
		else if inlist("`strata_var'", "float", "double") {
			createUniqueStrataVariable `strata_var' if `touse', strata(`strata')
		}
		else {
			createUniqueStrataVariable `strata_var' if `touse', strata(`strata') one
		}
	}
	else if (1 < `strata_tally') {
		createUniqueStrataVariable `strata_var' if `touse', strata(`strata')
	}
	else {
		quietly generate byte `strata_var' = 1 if `touse'
	}

	// Process weight option
	local weight = cond("`weight'" == "", "", "[`weight' `exp']")

	// Set up model
	tempname G V R C
	if inlist("`model'", "correlation", "") { // Default is Correlation
		local model correlation
		quietly correlate `varlist' if `touse'
		local df = !missing(r(rho))
	}
	else {
		// ANOVA and General Association need the list of levels of row variable (union set over all strata)
		gettoken Y X : varlist
		quietly tabulate `X' if `touse', matrow(`R')
		local df = r(r) - 1
		// General Association needs also the list of levels of column variable (union set over all strata)
		if ("`model'" == "general") {
			quietly tabulate `Y' if `touse', matrow(`C')
			local df = `df' * (r(r) - 1)
		}
	}

	if (`df' == 0) {
		display in smcl as error "Insufficient variation in data"
		error 178
	}

	matrix define `G' = J(`df', 1, 0)
	matrix define `V' = J(`df', `df', 0)

	// Process strata, cumulating G and V
	tempname Gh Vh
	summarize `strata_var', meanonly
	forvalues stratum = 1/`r(max)' {
		`model' `varlist' if `touse' & `strata_var' == `stratum',  ///
			weight("`weight'") transformation(`transformation') ///
			ones(`ones') r(`R') c(`C') g(`Gh') v(`Vh')
		matrix define `G' = `G' + `Gh'
		matrix define `V' = `V' + `Vh'
	}

	// Invert V
	tempname invV
	matrix define `invV' = invsym(`V')

	// Compute Q and p
	tempname Q
	if 0 < diag0cnt(`invV') {
		local singularity_warning (Covariance matrix is singular)
		return scalar chi2 = .
	}
	else {
		matrix define `Q' = `G'' * `invV' * `G'
		return scalar chi2 = `Q'[1, 1]
	}

	return scalar df = `df'
	return scalar p = chi2tail(`df', return(chi2))

	// Get formal name of transformation score type
	tempname ScoreType
	if "`transformation'" == "table" {
		scalar define `ScoreType' = "Table Scores (Untransformed Data)"
	}
	else if "`transformation'" == "rank" {
		scalar define `ScoreType' = "Ranks"
	}
	else if "`transformation'" == "ridit" {
		scalar define `ScoreType' = "Ridits"
	}
	else if "`transformation'" == "modridit" {
		scalar define `ScoreType' = "Standardized Midranks (Modified Ridits)"
	}
	else if inlist("`transformation'", "logrank", "savage") {
		scalar define `ScoreType' = "Savage (log-rank) Scores"
	}
	else if "`transformation'" == "median" {
		scalar define `ScoreType' = "Median Scores"
	}
	else if "`transformation'" == "mood" {
		scalar define `ScoreType' = "Mood Scores"
	}
	else if "`transformation'" == "klotz" {
		scalar define `ScoreType' = "Klotz Scores"
	}
	else if "`transformation'" == "vdw" {
		scalar define `ScoreType' = "van der Waerden Scores"
	}
	else {
		scalar define `ScoreType' = ""
	}
	return local scoretype = "`transformation'"
	return local ScoreType = `ScoreType'

	// Display results
	display in smcl as text _newline(1) ///
		"Extended Mantel-Haenszel (Cochran-Mantel-Haenszel) Stratified Test of Association"
	if ("`model'" == "general") {
		local statistic General Association
	}
	else if ("`model'" == "anova") {
		local statistic ANOVA (Row Mean Scores)
	}
	else {
		local statistic Correlation
	}
	display in smcl as text _newline(1) "`statistic' Statistic:"
	display in smcl as text "Q (" as result `df' as text ") = " as result %7.4f return(chi2) _continue
	display in smcl as text ", P = " as result %06.4f return(p) as text " `singularity_warning'"
	display in smcl as text "Transformation: " `ScoreType' _newline(1)
end

program define createUniqueStrataVariable
	version 11.1
	syntax anything [if], strata(varlist) [one string]

	if ("`one'" == "") {
		preserve
		quietly keep `if'
		contract `strata'
		drop _freq
		generate long `anything' = _n

		tempfile tmpfil0
		quietly save "`tmpfil0'"

		restore
		quietly merge m:1 `strata' using "`tmpfil0'", assert(match master) nogenerate
		erase "`tmpfil0'"
	}
	else {
		tempname Label
		if ("`string'" == "") {
			tempvar tmpvar0
			generate str `tmpvar0' = string(`strata')
			encode `tmpvar0' `if', generate(`anything') label(`Label')
			drop `tmpvar0'
		}
		else {
			encode `strata' `if', generate(`anything') label(`Label')
		}
		label drop `Label'
	}
end

program define correlation
	version 11.1
	syntax varlist [if], [weight(string)] transformation(string) ///
			[ones(varname) r(name) c(name)] g(name) v(name)

	quietly count `if'
	if r(N) < 2 {
		matrix define `g' = J(1, 1, 0)
		matrix define `v' = J(1, 1, 0)
		exit
	}

	summarize `ones' `if' `weight', meanonly
	local nh `r(N)'

	gettoken response groupvar : varlist

	// Get boldnh
	tempname boldnh
	quietly tabulate `response' `groupvar' `if' `weight', matcell(`boldnh')
	matrix define `boldnh' = vec(`boldnh')

	// Get Phstardot
	tempname Phstardot Rh
	quietly tabulate `groupvar' `if' `weight', matcell(`Phstardot') matrow(`Rh')
	getTransformation , scores(`transformation') marginaltotals(`Phstardot') values(`Rh')
	matrix define `Phstardot' = `Phstardot' / `nh'

	// Get Phdotstar
	tempname Phdotstar Ch
	quietly tabulate `response' `if' `weight', matcell(`Phdotstar') matrow(`Ch')
	getTransformation , scores(`transformation') marginaltotals(`Phdotstar') values(`Ch')
	matrix define `Phdotstar' = `Phdotstar' / `nh'

	computeGV , boldnh(`boldnh') phdotstar(`Phdotstar') phstardot(`Phstardot') ///
		rh(`Rh') ch(`Ch') nh(`nh') g(`g') v(`v')
end

program define anova
	version 11.1
	syntax varlist [if], [weight(string)] transformation(string) ///
			ones(varname) r(name) [c(name)] g(name) v(name)

	local R = rowsof(`r')
	local df = `R' - 1

	quietly count `if'
	if r(N) < 2 {
		matrix define `g' = J(`df', 1, 0)
		matrix define `v' = J(`df', `df', 0)
		exit
	}

	summarize `ones' `if' `weight', meanonly
	local nh `r(N)'

	gettoken response groupvar : varlist

	// Get boldnh
	tempname C boldnh
	quietly tabulate `response' `if', matrow(`C')
	forvalues row = 1/`R' {
		forvalues index = 1/`=rowsof(`C')' {
			summarize `ones' ///
				`if' & `groupvar' == `r'[`row', 1] & `response' == `C'[`index', 1] ///
				`weight', meanonly
			matrix define `boldnh' = (nullmat(`boldnh') \ r(N))
		}
	}

	// Get Phstardot
	tempname Phstardot
	matrix define `Phstardot' = J(`R', 1, 0)
	forvalues row = 1/`R' {
		summarize `ones' ///
			`if' & `groupvar' == `r'[`row', 1] ///
			`weight', meanonly
		matrix define `Phstardot'[`row', 1] = r(N) / `nh'
	}

	// Get Rh
	tempname Rh
	matrix define `Rh' = ( I(`df') , J(`df', 1, -1) )

	// Get Phdotstar
	tempname Phdotstar Ch
	quietly tabulate `response' `if' `weight', matcell(`Phdotstar') matrow(`Ch')
	getTransformation , scores(`transformation') marginaltotals(`Phdotstar') values(`Ch')
	matrix define `Phdotstar' = `Phdotstar' / `nh'

	computeGV , boldnh(`boldnh') phdotstar(`Phdotstar') phstardot(`Phstardot') ///
		rh(`Rh') ch(`Ch') nh(`nh') g(`g') v(`v')
end

program define general
	version 11.1
	syntax varlist [if], [weight(string)] [transformation(string)] ///
			ones(varname) r(name) c(name) g(name) v(name)

	local R = rowsof(`r')
	local C = rowsof(`c')
	local dfR = `R' - 1
	local dfC = `C' - 1

	quietly count `if'
	if r(N) < 2 {
		local df = `dfR' * `dfC'
		matrix define `g' = J(`df', 1, 0)
		matrix define `v' = J(`df', `df', 0)
		exit
	}

	summarize `ones' `if' `weight', meanonly
	local nh `r(N)'

	gettoken response groupvar : varlist

	// Get boldnh
	tempname boldnh
	matrix define `boldnh' = J(`=`R' * `C'', 1, 0)
	forvalues row = 1/`R' {
		local RC = (`row' - 1) * `C'
		forvalues index = 1/`C' {
			summarize `ones' ///
				`if' & `groupvar' == `r'[`row', 1] & `response' == `c'[`index', 1] ///
				`weight', meanonly
			local ++RC
			matrix define `boldnh'[`RC', 1] = r(N)
		}
	}

	// Get Phstardot
	tempname Phstardot
	matrix define `Phstardot' = J(`R', 1, 0)
	forvalues row = 1/`R' {
		summarize `ones' ///
			`if' & `groupvar' == `r'[`row', 1] ///
			`weight', meanonly
		matrix define `Phstardot'[`row', 1] = r(N) / `nh'
	}

	// Get Bh
	tempname Rh
	matrix define `Rh' = ( I(`dfR') , J(`dfR', 1, -1) )

	// Get Phdotstar
	tempname Phdotstar
	matrix define `Phdotstar' = J(`C', 1, 0)
	forvalues index = 1/`C' {
		summarize `ones' ///
			`if' & `response' == `c'[`index', 1] ///
			`weight', meanonly
		matrix define `Phdotstar'[`index', 1] = r(N) / `nh'
	}

	// Get Ch
	tempname Ch
	matrix define `Ch' = ( I(`dfC') , J(`dfC', 1, -1) )

	computeGV , boldnh(`boldnh') phdotstar(`Phdotstar') phstardot(`Phstardot') ///
		rh(`Rh') ch(`Ch') nh(`nh') g(`g') v(`v')
end

program define computeGV
	version 11.1
	syntax , boldnh(name) phdotstar(name) phstardot(name) rh(name) ch(name) nh(integer) g(name) v(name)

	// Get expected row marginal frequencies under the null hypothesis
	tempname mh
	matrix define `mh' = `nh' * (`phstardot' # `phdotstar')

	// Get variance of row marginal frequencies under the null hypothesis
	tempname var
	matrix define `var' = `nh' * `nh' / (`nh' - 1) * ///
		(diag(`phstardot') - `phstardot' * `phstardot'') # ///
		(diag(`phdotstar') - `phdotstar' * `phdotstar'')

	// Get Bh
	tempname Bh
	matrix define `Bh' = `rh' # `ch'

	// Compute Gh, VGh
	matrix define `g' = `Bh' * (`boldnh' - `mh')
	matrix define `v' = `Bh' * `var' * `Bh''
end

program define getTransformation 
	version 11.1
	syntax , scores(string) marginaltotals(name) values(name)
	if ("`scores'" == "table") {
		// Do nothing
	}
	else {
		local row_tally = rowsof(`values')

		if ("`scores'" == "integer") {
			forvalues index = 1/`row_tally' {
				matrix define `values'[`index', 1] = `index'
			}
		}
		else {
			matrix define `values' = J(`row_tally', 1, 0)
			tempname cumulator

			if ("`scores'" == "savage") {
				tempname n
				scalar define `n' = 0
				forvalues i = 1/`row_tally' {
					scalar define `n' = `n' + `marginaltotals'[`i', 1]
				}
				tempname A
				matrix define `A' = J(`n', 1, 0)
				forvalues rank = 1/`=`n'' {
					matrix define `A'[`rank', 1] = 1 / (`n' - `rank' + 1)
				}
				forvalues rank = 2/`=`n'' {
					matrix define `A'[`rank', 1] = `A'[`=`rank'-1', 1] + `A'[`rank', 1]
				}

				tempname B start_value cumulator marginaltotal
				matrix define `B' = `values'
				scalar define `start_value' = 1

				forvalues Bindex = 1/`=rowsof(`B')' {
					scalar define `cumulator' = 0
					scalar define `marginaltotal' = `marginaltotals'[`Bindex', 1]
					forvalues Aindex = `=`start_value''/`=`start_value' + `marginaltotal' - 1' {
						scalar define `cumulator' = `cumulator' + `A'[`Aindex', 1]
					}
					matrix define `B'[`Bindex', 1] = `cumulator' / `marginaltotal' - 1
					scalar define `start_value' = `start_value' + `marginaltotal'
				}

				matrix define `values' = `B'
			}
			else if ("`scores'" == "logrank") {
			// Taken from Stokes, Davis & Koch, Page 73, which differs from other algorithms

				forvalues j = 1/`row_tally' {
					forvalues k = 1/`j' {
						scalar define `cumulator' = 0
						forvalues m = `k'/`row_tally' {
							scalar define `cumulator' = `cumulator' + `marginaltotals'[`m', 1]
						}
					matrix define `values'[`j', 1] = `values'[`j', 1] + `marginaltotals'[`k', 1] / `cumulator'
					}
				}
				matrix define `values' = J(`row_tally', 1, 1) - `values'
			}
			else {
				scalar define `cumulator' = 0
				forvalues index = 1/`row_tally' {
					matrix define `values'[`index', 1] = `cumulator' + (`marginaltotals'[`index', 1] + 1) / 2
					scalar define `cumulator' = `cumulator' + `marginaltotals'[`index', 1]
				}

				if ("`scores'" == "rank") {
					// Do nothing
				}
				else if ("`scores'" == "ridit") {
					matrix define `values' = `values' / `cumulator'
				}
				else if inlist("`scores'", "modridit", "vdw", "klotz") {
					matrix define `values' = `values' / (`cumulator' + 1)
					if ("`scores'" == "modridit") {
						// Do nothing
					}
					else {
						forvalues index = 1/`row_tally' {
							matrix define `values'[`index', 1] = invnormal(`values'[`index', 1])
						}
						if ("`scores'" == "vdw") {
							// Do nothing
						}
						else {
							tempname XtX
							if  `row_tally' < 2500 { // < 50 megabyte matrix
								matrix define `XtX' = `values' * `values''
								matrix define `values' = vecdiag(`XtX')'
							}
							else {
								forvalues index = 1/`row_tally' {
									`values'[`index', 1] = `values'[`index', 1] * `values'[`index', 1]
								}
							}
						}
					}
				}
				else if inlist("`scores'", "median", "mood") {
					tempname average_rank // Location of median
					scalar define `average_rank' = (`cumulator' + 1) / 2
					if ("`scores'" == "median") {
						forvalues index = 1/`row_tally' {
							matrix define `values'[`index', 1] = (`values'[`index', 1] > `average_rank')
						}
					}
					else {
						forvalues index = 1/`row_tally' {
							matrix define `values'[`index', 1] = (`values'[`index', 1] - `average_rank')^2
						}
					}
				}
				else {
					display in smcl as error "`scores' transformation not yet implemented"
					exit 178
				}
			}
		}
	}
	matrix define `values' = `values''
end
