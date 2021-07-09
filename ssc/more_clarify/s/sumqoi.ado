*! sumqoi v1.0 10may2014 JavierMarquez 
program sumqoi, rclass
	version 11.2

	syntax varlist(numeric) ///
		[if] [in] ///
		[, Statistics(str) ///
		Level(cilevel) ///
		CENTile ///
		NORMal * ]

	marksample touse, novarlist

	//ci options
	opts_exclusive "`centile' `normal'"
	if mi("`centile'`normal'") local centile centile

	// summary statistics
	qui tabstat `varlist' if `touse', statistics(count mean sd) save
	tempname matstats
	mat `matstats' = r(StatTotal)'
	matrix colnames `matstats' = Obs Mean "Std Dev"
	
	// user defined
	if "`statistics'" != "" {
		qui tabstat `varlist' if `touse', statistics(`statistics') save
		tempname userstats
		mat `userstats' = r(StatTotal)'
		mat `matstats' = `matstats',`userstats'
	}

	// level
	tempname matci
	local lower = (100-`level')/2
	local upper = `level'+ (100-`level')/2
	mat `matci' = J(`:word count `varlist'',2,.)
	matrix colnames `matci' = "[`level'% Conf" "Interval]"
	*if centile based...
	if "`centile'" == "centile" {
		local row = 0
		foreach var of varlist `varlist' {
			_pctile `var' if `touse', p(`lower' `upper')
			matrix `matci'[`++row',1] = r(r1)
			matrix `matci'[`row',2]   = r(r2)
		}
		matrix coleq `matci' = "Percentile-based"
	}
	*if normal based...
	if "`normal'" == "normal" {
		local row = 0
		foreach var of varlist `varlist' {
			matrix `matci'[`++row',1] = `matstats'[`row',2] - invnormal(`upper'/100)*`matstats'[`row',3]
			matrix `matci'[`row',2]   = `matstats'[`row',2] + invnormal(`upper'/100)*`matstats'[`row',3]
		}
		matrix coleq `matci' = "Normal-based"
	}
	
	// Output
	tempname Results
	matrix `Results' = `matstats',`matci'
	
	// Display
	matlist `Results', lines(oneline) rowtitle(Variable) border(rows) showcoleq(combined) twidth(11) `format' `options'
	
	// Return
	tempname foo
	local i = 0
	local outnames sims mean se lb ub
	foreach name of local outnames {
		matrix `foo' = `Results'[1...,`++i']
		return matrix `name' = `foo'
	}
	matrix colnames `Results' = `outnames' 
	return matrix Results = `Results'
end

