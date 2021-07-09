capt program drop _all

*! staticfc v1.0.1  CFBaum 13aug2013
*! 1.0.1: released 27sep2010
*! 1.0.2: correct use of tempfile
program staticfc, rclass
version 10.1

syntax varlist(ts) [if] [in], GENerate(string) [STEP(integer 1) INIT(integer 20) ///
       GRaph(string) REPLACE NOI TItle(string) *]

// check for tsset
qui tsset
// require tdelta=1
if r(tdelta) != 1 {
	di as err "delta must be 1."
	error 198
}
loc timevar `r(timevar)'
loc tsfmt `r(tsfmt)'
// validate step
if `step' < 1 {
	di as err "invalid step()."
	error 198
}
// validate init
loc vl: word count varlist
if `init' <= `vl' {
	di as err "invalid init()."
	error 198
}
// validate new varname
confirm new variable `generate'
confirm new variable `generate'_s
confirm new variable `generate'_n
marksample touse
tempvar obsn
qui g `obsn' = _n * `touse'
su `obsn', mean
if r(max)==0 {
	error 2000
}
loc lastobs = r(max)
loc firstobs = r(max) - `step' + 1
qui replace `obsn' = . in `firstobs'/`lastobs'
markout `touse' `obsn'
tempfile rollf
tempname enn tval uplim lowlim

qui rolling __sah = r(sah) `generate' = r(fc_`step') `generate'_s = r(sfc_`step') ///
	`generate'_n = r(enn) if `touse', ///
	recursive window(`init') ///
		saving(`rollf', replace) /* noi */ : ///
		_staticfc `varlist', step(`step') /// options(`options')
		

// figure out how to suppress auto-creation of start, end? or rename them?	
if "`noi'" != "" {
	preserve
	use `rollf', clear
	desc
	su	
	restore
}
qui g __sah = _n 
qui merge 1:1 __sah using `rollf'
qui tsset
drop _merge __sah
lab var `generate' "`step'-step rolling forecast"
lab var `generate'_s "standard error of forecast"
lab var `generate'_n "residual degrees of freedom"
if "`noi'" != "" {
	l `timevar' start end `generate' `generate'_s `generate'_n if !mi(`generate')
}
qui g `tval' = invttail(`generate'_n, 0.025)
qui g `uplim' = `generate' + `tval' * `generate'_s
qui g `lowlim' = `generate' - `tval' * `generate'_s
lab var `uplim' "95% forecast interval"
lab var `lowlim' "95% forecast interval"
loc depvar: word 1 of `varlist'
if "`graph'" != "" {
	twoway (rarea `uplim' `lowlim' `timevar' if `touse', fintensity(15) lcolor(white)) ///
	(tsline `generate' if `touse', scheme(s2mono)) (tsline `depvar' if `touse', ///
	ti("`title'") saving(`graph',`replace')) 
}       
end

/* HBR
program _staticfc, rclass
version 10.1
syntax varlist [if], STEP(integer)
regress `varlist' `if'
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
*/
