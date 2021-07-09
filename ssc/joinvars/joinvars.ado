*! version 1.0.4 11jun2011 Daniel Klein
* for history see end of file

program joinvars ,by(o)
	vers 9.2
	
	syntax anything(id ="varlist" equalok) [if][in] ///
	[, DOUBLE UPDATE OVERWRITE MISSok]	
	
	/*parse anything
	-----------------*/
	loc anything : subinstr loc anything "=" " " ,all
	gettoken newvar varlist : anything
	
	conf new v `newvar'
	unab varlist : `varlist' 

	marksample touse ,nov s
	qui count if `touse'
	if r(N) == 0 err 2000
	
	/*check varlist is numeric or string
	-------------------------------------*/
	loc first : word 1 of `varlist'
	loc varlist : list varlist - first
	if (`: word count `varlist'' < 1) err 102
	cap conf string v `first'
	if _rc conf numeric v `varlist'
	else {
		if ("`double'" != "") err 109
		conf string v `varlist'
	}
	
	/*setting
	----------*/
	if _by() loc _byc by `_byvars' `_byrc0' :
	if ("`overwrite'" != "") loc update update
	if ("`update'" != "") loc update
	else loc update & mi(`newvar')
		
	/*join variables
	-----------------*/
	qui `_byc' g `double' `newvar' = `first' if `touse'
	foreach v of loc varlist {
		if ("`missok'" != "") {	
			qui `_byc' replace `newvar' = `v' ///
			if `touse' `update'
		}
		else {
			qui `_byc' replace `newvar' = `v' ///
			if `touse' & !mi(`v') `update'
		}
	}
end
exit

History

1.0.4	11jun2011	add -double- option
					-update- must be spelled out (-overwrite- as synonym)
					change input parse
					version 9.2 supported
1.0.3	01mar2011	version no longer checked (only 11.1 supported)
