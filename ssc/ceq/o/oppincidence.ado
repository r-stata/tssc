** oppincidence.ado
*! version 1.1 skh 7aug2016
** Created July 2012
** Sean Higgins; shiggins@tulane.edu

capture program drop mld
program mld, rclass
	** mean log deviation
	version 10.0
	syntax varlist(min=1 max=1 numeric) [if] [in] [aweight fweight iweight]
	quietly summ `varlist' `if' `in' [`weight' `exp']
	local mean_`varlist' = r(mean)
	tempvar ld
	quietly gen `ld' = ln(`mean_`varlist''/`varlist')
	quietly summ `ld' `if' `in' [`weight' `exp']
	return scalar mld = `r(mean)'
end

capture program drop oppincidence
program oppincidence, rclass
	** opportunity-adjusted fiscal incidence
	version 10.0
	syntax varlist(numeric) [if] [in] [aweight fweight iweight] , GRoupby(varlist)
		** varlist is the list of income variables (eg market, net market, disposable, post-fisal, final)
		** groupby is the list of categorical variables that define the different types
	preserve
	marksample touse
	quietly drop if `touse'==0
	** question: what to do with zero incomes? 
	** for now I drop incomes that are zero for any income definition, because ln(0) does not exist
	** and I want the same observations to be used for mean log deviation of each income definition
	foreach income in `varlist'	{
		quietly drop if `income'<=0
	}
	quietly sort `groupby'
	tempvar type
	egen `type' = group(`groupby') // now `type' is a categorical var with a distinct value for each type
								   // eg, everyone with {female, black, graduate, urban} would have type==1,
								   // everyone with {female, black, graduate, rural} would have type==2, etc
	quietly summ `type'
	local Ngroup = r(max)
	foreach income in `varlist' {
		tempvar smoothed_`income' // this is the mean for `income' by type
		quietly gen `smoothed_`income''=.
		** note: I had to do the following round-about way to calculate mean incomes by type
		** because egen `smoothed_`income'' = mean(`income'), by(`type') does not appear to allow weights
		forval i = 1/`Ngroup' {
			quietly summ `income' if `type'==`i' [`weight' `exp']
			quietly replace `smoothed_`income'' = `r(mean)' if `type'==`i'
		}
		** mean log deviation for smoothed distribution:
		mld `smoothed_`income'' [`weight' `exp']
		scalar mld_`income'_smoothed = r(mld)
		** mean log deviation for actual distribution:
		mld `income' [`weight' `exp']
		scalar mld_`income' = r(mld)
		** ratio of smoothed distribution inequality to actual inequality:
		scalar mldratio_`income' = mld_`income'_smoothed/mld_`income'
	}
	
	** Display and store results:
	local n_income = wordcount("`varlist'")
	tokenize `varlist'
	tempname levels ratios
	matrix `levels' = J(`n_income',1,.)
	matrix `ratios' = J(`n_income',1,.)
	forval i=1/`n_income' {
		matrix `levels'[`i',1] = mld_``i''_smoothed
		matrix `ratios'[`i',1] = mldratio_``i''
	}
	local title_levels "In levels (MLD of smoothed distribution)"
	local title_ratios "In ratios (MLD of smoothed/MLD of actual)"
	foreach mat in levels ratios {
		matrix rownames ``mat'' = `varlist'
		matrix colnames ``mat'' = "Ineq of Opp"
		matlist ``mat'', title("`title_`mat''") format(%11.5f) border(all) ///
			twidth(14) rowtitle("Income concept")
		return matrix `mat' = ``mat''
	}
	restore
end
