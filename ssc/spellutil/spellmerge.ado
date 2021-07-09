*! version 1.0.0 2mar2003 E. Leuven
program define spellmerge
	version 7
	syntax, spell(varlist min=2 max=2) [by(varlist) gap(integer 1)]

	tokenize `spell'
	local date0 `1'
	local date1 `2'
	
	if ("`by'")=="" {
		tempvar by
		g byte `by' = 1
	}
	
	tempvar groupit
	by `by' (`date0'), sort: g `groupit' = sum(cond(_n>1 & (`date0'-`date1'[_n-1])>`gap',1,.))
	qui by `by' `groupit' (`date0'), sort: replace `date1' = `date1'[_N]
	qui by `by' `groupit' (`date0'), sort: keep if _n==1
end
