*! version 0.13.03  5mar2013

// Valor cuota de los fondos
cap program drop valcuofon_afc
program def valcuofon_afc
	syntax [, Agno(integer 2013) Save(string) Clear]
	
	vers 9.0
	
	if length(`"`save'"') != 0 preserve
	else if ((c(N)+c(k)) != 0) & length("`clear'") == 0 {
		di as error "No, los datos en la memoria se perder{c a'}n" as text " (use la opci{c o'}n " as result "clear)"
		exit 4
	}
	
	qui insheet ///
		fecha valor_cuota_cic valor_patrimonio_cic  valor_cuota_fcs valor_patrimonio_fcs ///
			using "http://www.spensiones.cl/apps/vcuofon/vcfAFCxls.php?aaaa=`agno'", ///
			delim(";") clear
	qui drop in 1/2
	
	// Arreglando valores numericos
	quietly {
		foreach var of varlist valor* {
			replace `var' = subinstr(`var', ".", "", .)
			destring `var', replace dpcomma
		}
	}
	
	// Etiquetando variables
	lab var valor_cuota_cic "Valor cuota CIC"
	lab var valor_cuota_fcs "Valor cuota FCS"
	lab var valor_patrimonio_cic "Patrimonio CIC"
	lab var valor_patrimonio_fcs "Patrimonio FCS"
	
	// Arreglando fecha
	gen fecha2 = date(fecha, "YMD")
	drop fecha
	ren fecha2 fecha
	format fecha %td
	
	order _all
	label data "Valores cuota y patrimonio diarios de los Fondos de Cesantia durante el `agno'"
	
	if length(`"`save'"') != 0 save `save', replace
end
