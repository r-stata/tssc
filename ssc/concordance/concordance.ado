program define concordance
	version 14
	syntax varlist (min=3 max=3)
	args oldcode newcode year
	
	foreach var of local varlist {
		tostring `var', replace
	}

	javacall ch.bell.concordances.ConcordanceStataWrapper getGroupcodes `varlist', args(productcode year endyear groupcode)

	tab groupcode, nofreq
	display "number of observations: " `r(N)'
	display "number of groupcodes: " `r(r)'
	browse
end
