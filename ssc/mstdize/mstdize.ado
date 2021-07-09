*! 1.2.0 NJC 13 April 2006 
* 1.1.0 NJC 24 March 1999
* 1.0.1 NJC 1 July 1998
program mstdize
	version 8.2
	syntax varlist(min=3 max=3) [if] [in], BY(varlist min=2 max=2) ///
	[ Generate(str) TOLerance(real 1e-3) CENter Format(str) * ] 
	tokenize `varlist'
	args data rowtot coltot
	tokenize `by'
	args row col

	tempvar guess pguess Rowtot Coltot diff
	marksample touse

	quietly {
		count if `touse' 
		if r(N) == 0 error 2000 
		
		su `rowtot' if `touse', meanonly
		local sumrow = r(sum)
		tab `col' if `touse'
		local sumrow = `sumrow' / r(r)

		su `coltot' if `touse', meanonly
	 	local sumcol = r(sum)
		tab `row' if `touse'
		local sumcol = `sumcol' / r(r)

	    	if abs(`sumrow' - `sumcol') > `tolerance' {
			di as err "totals of rows and columns do not agree"
			exit 198
	    	}

	    	gen `guess' = `data' if `touse'
	    	gen `pguess' = .
	    	gen `Rowtot' = .
	    	gen `Coltot' = .
	    	gen `diff' = .

	    	local max .
	    	while `max' > `tolerance' {
			replace `pguess' = `guess'
			bysort `row' : replace `Rowtot' = sum(`guess')
			by `row' : replace `Rowtot' = `Rowtot'[_N]
			replace `guess' = `guess' * `rowtot' / `Rowtot'
			bysort `col' (`row') : replace `Coltot' = sum(`guess')
			by `col' : replace `Coltot' = `Coltot'[_N]
			replace `guess' = `guess' * `coltot' / `Coltot'
			replace `diff' = abs(`pguess' - `guess')
			su `diff', meanonly
			local max = r(max)
	    	}
	}

	if "`format'" == "" local format "%9.2f"
	if "`center'" == "" local center "center"
	tabdisp `row' `col' if `touse', ///
	c(`guess') f(`format') `center' `options'

	if "`generate'" != "" {
	    confirm new variable `generate'
	    gen `generate' = `guess'
	}
end

/* J program used as basis

ms =. 3 : 0
NB. marginal standardisation
NB. NJC 23 February 1998
scores =. 1 $~ $y.
rowsum =. +/"1 scores
colsum =. +/ scores
(rowsum ; colsum) ms y.
:
rowsum =. > {. x.
colsum =. > {: x.
guess =. y.
whilst. -. oldguess -: guess do.
    oldguess =. guess
    guess =. guess * rowsum % +/"1 guess
    guess =. guess *"1 colsum % +/ guess
end.
guess
)

*/
