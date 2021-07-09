*! tslist 1.0.4  30jul2004 CFBaum & Michael Hanson
* 1.0.2: revise for index
* 1.0.3: revise for sepby on q, m
* 1.0.4: revise for sepby on all fqs

program tslist
	syntax varlist [if] [in] [, notimevar *]
	version 8.2
	marksample touse, novarlist
	qui count if `touse'
	if r(N) == 0 error 2000
	capt tsset
	local unit1 `r(unit1)'
	local tv `r(timevar)'
	if _rc>0 | "`unit1'" == "." {
		list `varlist' if `touse' ,`options'
		exit
		}
	local wh = index("qmhwdy","`unit1'")
	local sepno 4 12 2 13 7 10
	local achc y y y q w y
	local sep : word `wh' of `sepno' 
	local aggr : word `wh' of `achc'
	if "`timevar'" != ""  local tv ""
	tempvar yyy
	if `wh' < 5 {
		qui g `yyy' = `aggr'ofd(dof`unit1'(`tv'))
		list `tv' `varlist' if `touse', sepby(`yyy') noobs `options'
		}
	else if `wh' == 5 {
		qui g `yyy' = dow(`tv')
		qui replace `yyy' = . if `yyy' ~= 0
		qui replace `yyy' = sum(`yyy'+1)
		list `tv' `varlist' if `touse', sepby(`yyy') noobs `options'
		}
	else {
		list `tv' `varlist' if `touse', sep(`sep') noobs `options'
		}
	exit
end


