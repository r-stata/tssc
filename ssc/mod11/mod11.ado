*! version 0.13.03  6mar2013
cap program drop mod11
prog def mod11
	syntax varlist(max=1 numeric), Generate(name) [Replace]
	
	vers 9.0
	
	// Tempvar
	tempvar dv
	
	// Obtiene el largo del registro
	summ `varlist', meanonly
	local ndigits = length("`r(max)'")
	
	// Genera lista de variables a generar
	local randomprefix = abs(round(rnormal()*100))
	forval i=1/`ndigits' {
		local newlist `newlist' v`randomprefix'_`i'
	}
	
	cap findfile nsplit.ado
	if _rc != 0 ssc install nsplit
	
	capture {
		// Parte el RUT
		
		qui nsplit `varlist', d(1) g(`newlist')
		
		if length("`replace'") != 0 cap drop `generate'
		
		// Multiplica y suma por serie 2 3 4 5 6 7 2 ...
		cap gen `dv' = v`randomprefix'_`ndigits'*2
		local j 2
		forval i=`--ndigits'(-1)1 {
			if `j' == 7 local j = 1
			replace `dv' = `dv' + v`randomprefix'_`i'*`++j'
		}
		
		// Genera modulo
		replace `dv' = 11 - mod(`dv',11)
		tostring `dv', replace
		
		// Reemplaza por ceros y k
		replace `dv' = "k" if `dv' == "10"
		replace `dv' = "0" if `dv' == "11"
		
		drop `newlist'
	}
	if _rc != 0 {
		// En caso de error
		local err = _rc
		cap drop `newlist'
		exit `err'
	}
	else gen `generate' = `dv'
end
