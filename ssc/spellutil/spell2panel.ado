*! version 1.0.2 26mar2003 E. Leuven
program define spell2panel
	version 7
	syntax [anything], spell(varlist min=2 max=2) p(string) [by(varlist) Nojoin]
	tokenize `spell'
	local date0 `1'
	local date1 `2'
	local all `anything'
	
	tempvar touse
	mark `touse'
	markout `touse' `spell'
	qui count if `touse'==0
	if (r(N)>0) {
		di as text r(N) " observations dropped due to missing values in the date variables"
		keep if `touse'
	}
	
	/* set default statistic */
	local current "mean"
	gettoken left anything : anything, match(prns)
	while "`left'"!="" {
		if "`prns'"!="" {
			if !inlist("`left'","mean","sum") {
				di as error "Statistic `left' not supported"
				exit 198
			}
			if ("`nojoin'"!="") {
				di as error "With option nojoin only a varlist is allowed"
				exit 198
			}
			local current "`left'"
		}
		else {
			local xvars `xvars' `left'
		}
		gettoken left anything : anything, match(prns)
	}
	if ("`xvars'"!="") {
		confirm var `xvars'
	}
		
	quietly {
		/* join overlapping spells */
		if ("`nojoin'"=="") {
			spellsplit `all', spell(`date0' `date1') by(`by')
			drop _count
		}
		/* expand data with number of periods the spell covers */
		g _`p' = `p'ofd(`date1') - `p'ofd(`date0') + 1
		expand _`p'
		/* calculate proper period per observation */
		sort `by' `date0'
		by `by' `date0': replace _`p' = `p'ofd(`date0') + (_n - 1)
		/* calculate length of spell */
		g _length = min(`date1', dof`p'(_`p' + 1)) - max(`date0', dof`p'(_`p'))
		/* weigh time varying var's with spell length */
		sort `by' _`p'
		for var `xvars': by `by' _`p': replace X = sum(_length*X)
		/* sum of all spell per state/period */
		by `by' _`p': replace _length = sum(_length)
		/* we only need the total sum */
		by `by' _`p': keep if _n==_N
		/* calculate final average of time varying var's */
		for var `xvars': replace X = X/_length
		/* clean up */
                drop `date0' `date1'
                drop if _length==0
		format _`p' %t`p'
	}

end
