*! version 0.13.03  6mar2013
cap program drop mod11i
prog def mod11i, rclass
	syntax anything(name=numero)
	
	vers 9.0
	
	return clear
	
	// Obtiene el largo del registro
	local ndigits = length("`numero'")
		
	// Parte el RUT
	forval i = 1/`ndigits' {
		local v`i' =  floor(mod(`numero', 10^(`i'))/10^(`i'-1))
	}
	
	// Multiplica y suma por serie 2 3 4 5 6 7 2 ...
	local dv = `v1'*2
	local j 2
	forval i = 2/`ndigits' {
		if `j' == 7 local j = 1
		local dv = `dv' + `v`i''*`++j'
	}
	
	// Genera modulo
	local dv = 11 - mod(`dv',11)
	
	// Reemplaza por ceros y k
	if "`dv'" == "10" local dv = "k"
	if "`dv'" == "11" local dv = "0"

	return scalar number = `numero'
	return local dv = "`dv'"
	
	di as text "Digito Verificador: " as result "`dv'"
end
