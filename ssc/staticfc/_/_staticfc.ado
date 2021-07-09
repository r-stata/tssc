*/ _staticfc  cfb 5oct2010
program _staticfc, rclass
version 10.1
syntax varlist(ts) [if], STEP(integer) // [OPTIONS(string)]
regress `varlist' `if', `options'
ret scalar enn = e(df_r)
tempvar _sn _sfc _sfcs
qui g `_sn' = _n * e(sample)
su `_sn', meanonly
loc stepahead = r(max) + `step'
ret scalar sah = `stepahead'
qui predict double `_sfc' in `stepahead', xb
qui predict double `_sfcs' in `stepahead', stdf
// noi di in r `stepahead'
// noi l `_sn' `_sfc' if ~mi(`_sfc')
ret scalar fc_`step' = `_sfc'[`stepahead']
ret scalar sfc_`step' = `_sfcs'[`stepahead']
end
