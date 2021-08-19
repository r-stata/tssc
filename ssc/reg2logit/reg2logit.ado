/* Version 1.0 */
/* Programmers: Paul von Hippel, Rich Williams, Paul Allison */
/* October 28, 2020 */

program define reg2logit
	syntax varlist (fv) [if] [in] [, ITERate(int 0)]
	version 12
	quietly reg `varlist'
	local y = e(depvar)
	
	/* Suppressing the following error check there are situations where we would not require y to be binary, at least when using iter(0). */
//	capture assert `y' == 0 | `y' == 1 if e(sample)
//	if _rc != 0 {
//	    display as error "You must use a binary 0/1 dependent variable"
//		exit
//	}
// 	tempname beta c dim k p q ldmbeta
	
	matrix beta = e(b)
	local dim `e(rank)'
 	local c = beta[1, `dim']
	local k = `e(N)'/`e(rss)'
	sum `y', meanonly
	local p = `r(mean)'
	local q = 1 - `p'
	matrix ldmbeta = beta * `k'
	mat ldmbeta[1, `dim'] = ln(`p'/`q') + `k'*(`c'-.5) + .5*(1/`p' - 1/`q')
//	mat list ldmbeta

	logit `varlist', from(ldmbeta) iter(`iterate')

end