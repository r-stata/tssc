prog drop _all
*! xtiletest  1.0.0  cfb 11dec2015
// based on Use of Pearson’s Chi-Square for Testing
// Equality of Percentile Profiles across
// Multiple Populations, WD Johnson et al.,
// Open Journal of Statistics, 2015, 5, 412-420
// http://dx.doi.org/10.4236/ojs.2015.55043 
prog xtiletest, rclass
version 12
syntax varname(numeric) [if] [in], BY(string) XTile(string)
tempvar touse rcode
tempname fmat rowprop df
marksample touse
confirm numeric variable `by', exact
capt _pctile `varlist' if `touse', p(`xtile')
if _rc != 0 {
	di as err _n "Error: percentiles in xtile() must be integer in ascending order"
	error 198
}
loc nxt: word count `xtile'
loc nbin = `nxt' + 1
loc ir "`varlist',"
forv i=1/`nxt' {
	loc ir "`ir' `r(r`i')', "
}
loc ir "`ir' ."
g `rcode' = irecode(`ir')
qui levelsof `by', loc(byl)
loc byc: word count `byl'
lab var `rcode' "`nbin' bins of `varlist' demarcated by quantiles `xtile' "
di as res _n "Evaluating equality of quantiles of `varlist' by `by'"
di "Quantiles `xtile' define `nbin' bins"
di "H0: quantiles do not differ by `by'"

tab `by' `rcode' if `touse', row chi2 matcell(`fmat')
sca `df' = (`r(r)' - 1)*(`r(c)' - 1)
return local cmdname xtiletest
return local varname `varlist'
return local bygroup `by'
return local xtile `xtile'
return scalar chi2  = `r(chi2)'
return scalar df = `df'
return scalar pval =  `r(p)'

/* doublecheck logic with Mata
// compute row totals
mata: zz= st_matrix("`fmat'"); rtot = rowsum(zz) 
// compute column proportions
mata: zcol = (zz' * J(`byc',1,1))'; zcol = zcol :/ (zcol * J(`nbin',1,1))
// compute expected frequencies from marginals
mata: zexp = trunc(rtot * zcol)
// compute chisq = ((observed - expected) ^2 ] / expected
mata: zchi = sum((( zz - zexp) :^2) :/ zexp); st_numscalar("zchi", zchi)
di zchi
*/
end
