capture program drop drawwage
program drawwage

	drop _all
	set obs 5000 /* set up temp dataset to store 5000 randomly selected quantiles */
	gen byte q = 1 + int(99 * uniform()) /* random integer from 1 to 99, i.e. every percentile */

	sort q
	by q: gen numsel = _N /* no of times each quantile is chosen */
	by q: keep if _n==1 /* just keep one obs of each q and number of times it is chosen */
	local numq = _N /* number of different quantiles */

	assert `numq'>2

	* Read selected quantiles and number of times selected into matrices for later use

	matrix quan = q[1] /* read in first quantile */
	forval i = 2 (1) `numq' { /* now add others to form row vector */
		matrix quan = quan, q[`i']
	}

	matrix numdraw = numsel[1] /* read in number of times first quantile selected */
	forval i = 2 (1) `numq' { /* now add others to form row vector */
		matrix numdraw = numdraw, numsel[`i']
	}

	di
	di
	di "Quantiles to be used"
	matrix list quan 
	di
	di
	di "No of times each quantile selected"
	matrix list numdraw

	* Step through quantile matrix. At each different quantile, randomly sample
	* a number of these predictions equal to the number of times that quantile was originally selected.

	forval i = 1/`numq' {

		local q = quan[1,`i'] /* read element of quantile matrix */
		local numpred = numdraw[1,`i'] /* read element of number of draws matrix */
		use tmp/x`1'b`2'`q', clear
		bsample `numpred', cluster(pid) /* randomly sample predictions, same number of times quantile was originally drawn */
		drop pid

		if `i'==1 {
			quietly save tmp/x`1'b`2', replace /* save all predictions */
		}
		else {
			set more on
			set more off
			append using tmp/x`1'b`2' /* add previous predictions */
			quietly save tmp/x`1'b`2', replace /* save all predictions */
		}

	} /* End of 5000 draws */

end /* of program drawwage */




