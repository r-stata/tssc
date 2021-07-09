*! Part of package matrixtools v. 0.24
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk

* TODO crossmat option hide

program define crossmat, rclass
	version 12.1
	syntax varlist(min=1 max=2) [if] [in] [fweight aweight iweight], ///
		[Exact(integer 0) Label Missing Verbose]
	tokenize `varlist'

	mata: chitabulate("`1'", "`2'", "`if'", "`in'", "`weight'`exp'", `exact', ///
						"`verbose'" != "", "`missing'" != "", "`label'" != "")
	capture confirm matrix __mc
	if ! _rc {
		return matrix counts = __mc
		return matrix pct __pct
		if "`2'" != "" {
			return matrix expected = __exp
			return matrix tests __tests
			return matrix greeks __greeks
			return matrix rpct __rpct
			return matrix cpct __cpct
			return matrix chi2 = __chi2
			return matrix lrchi2 = __lrchi2
		}
	}
	else display "{error:Nothing to return. Try running crossmat with option {bf:v}erbose to see why}"
	capture matrix drop __lblc
	capture matrix drop __lblr
	*/
end

mata:
	void chitabulate(	string scalar var1, 
						string scalar var2,
						string scalar str_if, 
						string scalar str_in, 
						string scalar str_weight,
						real scalar exactno,
						real scalar verbose,
						real scalar missing,
						real scalar no_vlbl)
	{
		class nhb_mt_chi2tabulate scalar chi2
		
		if ( verbose ) chi2.verbose(1,0)
		chi2.set(var1, var2, str_if, str_in, str_weight, exactno, missing, no_vlbl)
		chi2.counts_with_totals().to_matrix("__mc", 1) // 1 = replace
		chi2.proportions().to_matrix("__pct", 1)
		if ( var2 != "" ) {
			chi2.expected().to_matrix("__exp", 1)
			chi2.tests().to_matrix("__tests", 1)
			chi2.greeks().to_matrix("__greeks", 1)
			chi2.row_proportions().to_matrix("__rpct", 1)
			chi2.column_proportions().to_matrix("__cpct", 1)
			chi2.pearson_chisquare_parts().to_matrix("__chi2", 1)
			chi2.likelihood_ratio_chisquare_parts().to_matrix("__lrchi2", 1)
		}
	}
end
