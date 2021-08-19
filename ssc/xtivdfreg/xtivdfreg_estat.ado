*! version 1.0.3  12feb2021
*! Sebastian Kripfganz, www.kripfganz.de
*! Vasilis Sarafidis, sites.google.com/view/vsarafidis

*==================================================*
***** postestimation statistics after xtivdfreg *****

program define xtivdfreg_estat, rclass
	version 13.0
	if "`e(cmd)'" != "xtivdfreg" {
		error 301
	}
	gettoken subcmd rest : 0, parse(" ,")
	if "`subcmd'" == substr("overid", 1, max(4, `: length loc subcmd')) {
		loc subcmd			"overid"
	}
	if "`subcmd'" != "" {
		xtivdfreg_estat_`subcmd' `rest'
	}
	else {
		estat_default `0'
	}
	ret add
end

*==================================================*
**** computation of overidentification test statistics ****
program define xtivdfreg_estat_overid, rclass
	version 13.0

	if "`e(estimator)'" == "mg" {
		di as err "Hansen test not valid after mean-group estimation"
		exit 321
	}
	di _n as txt "Hansen test of the overidentifying restrictions" _col(56) "chi2(" as res e(df_J) as txt ")" _col(68) "=" _col(70) as res %9.4f e(chi2_J)
	if e(df_J) {
		di as txt "H0: overidentifying restrictions are valid" _c
	}
	else {
		di as txt "note: coefficients are exactly identified" _c
	}
	di _col(56) as txt "Prob > chi2" _col(68) "=" _col(73) as res %6.4f e(p_J)

	ret sca p			= e(p_J)
	ret sca df			= e(df_J)
	ret sca chi2		= e(chi2_J)
end
