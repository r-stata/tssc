////////////////////////////////////////////////////////////////////////////////
// DOPARSER v 0.12.04 (5 de abril de 2012)
// George Vega Yon (Superintendencia de Pensiones)
// Programa que, en base a expresiones regulares, analiza dofiles linea a linea
// y arroja como resultado una lista en pantalla con los DTA, su ubicacion fisica
// (y en el codigo)
////////////////////////////////////////////////////////////////////////////////
cap program drop doparser
program doparser
	vers 10
	syntax anything(name=archivo) [, Type(string) Export(string)]
	if length("`keep'") == 0 preserve
	clear
	quietly {
		// Lee el dofile
		doread "`archivo'"
			
		// Define ubicacion
		gen str244 location = ""
		local N = _N
		forval i = 1/`N' {
			local test regexm(lineas[`i'] , "^(cd )(.*)")
			if `test' {
				local l = regexr(lineas[`i'] , "^(cd )", "")
			}
			replace location = `"`l'"' if _n == `i'
		}

		// Analiza las lineas en busqueda de DTA files
		gen elemento = regexs(4) if regexm(lineas, "^((sysu|webu|mer|sa|ap|u)[a-z]*)(.* using )?(.*)")
		
		// Reemplazos
		replace elemento = regexr(elemento, ",.*| (in|if) .*", "")
		replace elemento = subinstr(elemento, `"""' , "", .)
		
		// Generando tipo y archivo
		gen type = regexs(1) if regexm(lineas, "^((sysu|webu|mer|sa|ap|u)[a-z]*)([ ]*[:alnum:]*[ ]*)(using)*([ ]*)([:graph:]*)([ ]*)((in|if).*)*")
		gen file = regexr(elemento, "^.*(/|\\)", "")
		
		// Reemplazos
		replace location = subinstr(elemento, file, "",.) if regexm(elemento, "\\|/")
		replace location = "(current do-file dir)" if length(location) == 0

		// Se queda solo con lo que tiene registro
		keep if length(elemento) > 0 & length(type) > 0
		
		// Filtra si el usuario lo pide asi
		if length("`type'") != 0 keep if type == "`type'"
		compress
	}
	list fil typ nl loc
	if length("`export'") != 0 save "`export'", replace
	qui restore
end

cap program drop doread
program doread
// Lee dofiles/adofiles (o cualquiera que se le impute) y lo importa linea por
// linea a Stata
	args archivo
	cap file close archivo
	quietly {
		file open archivo using "`archivo'", r text

		file read archivo linea

		// Genera variable lineas donde se escribira cada lineas
		gen str244 lineas = ""

		// Lee la primera linea y la guarda en la variable lineas
		file read archivo linea
		replace lineas = `"`macval(linea)'"'

		// Lee el resto de las lineas y cierra la conexion
		while r(eof)==0 {
			local nobs = _N + 1
			set obs `nobs'
			file read archivo linea
			replace lineas = `"`macval(linea)'"' if _n == _N
		}
		file close archivo
		doclean
	}
end

cap program drop doclean
program doclean
// para luego eliminar tabulaciones y fusionar lineas partidas (///,
// /* */, ;) 
	quietly {
		// Arregla las lineas que contienen tabulacion
		gen nline = _n + 2
		replace lineas = regexr(lineas,char(9)," ")
		replace lineas = regexr(lineas,char(9)," ")
		replace lineas = regexr(lineas,char(9)," ")
		replace lineas = trim(lineas)


		// En el caso de que existan lineas particionadas por /// o ;
		local N = _N
		forval i = 1/`N' {
			local test = regexm(lineas[`i'], "[ ]///[ ]*.*$")
			local rep = 1
			while `test' {
				replace lineas = regexr(lineas, "[ ]///[ ]*.*$", "") if _n == `i'
				replace lineas = lineas[`i']+" "+lineas[`i' + 1] if _n == `i'
				drop if _n == `i' + 1
				local ++rep
				local test = regexm(lineas[`i'], "[ ]///[ ]*.*$") & !(`rep' >= `N')
			}
		}
		// En el caso de que existan lineas particionadas por /* en una linea */
		local N = _N
		forval i = 1/`N' {
			local test = regexm(lineas[`i'], "/\*.*$") & regexm(lineas[`i' + 1], "\*/.*$")
			local rep = 1
			while `test' {
				replace lineas = regexr(lineas, "/\*.*$", "") if _n == `i'
				replace lineas = regexr(lineas, "^\*/", "") if _n == (`i' + 1)
				replace lineas = lineas[`i']+" "+lineas[`i' + 1] if _n == `i'
				drop if _n == `i' + 1
				local ++rep
				local test = regexm(lineas[`i'], "/\*.*$") & regexm(lineas[`i' + 1], "\*/.*$") & !(`rep' == `N')
			}
		}
		
		// En el caso de que existan lineas particionadas por /* varias */
		local N = _N
		forval i = 1/`N' {
			local test = !(regexm(lineas[`i'], "/\*.*$") & !regexm(lineas[`i' + 1], "\*/.*$"))
			replace lineas = regexr(lineas, "/\*.*$", "") if _n == `i'
			local rep = 0
			while !`test' {
				local ++rep
				if !`test' replace lineas = regexr(lineas, "^\*/", "") if _n == (`i' + 1)
				if !`test' replace lineas = lineas[`i']+" "+lineas[`i' + 1] if _n == `i'
				local test = !regexm(lineas[`i' + 1], "\*/.*$") | `rep' == `N'
				drop if _n == `i' + 1
			}
		}
	}
end
/*
// ejemplos
doparser I:\eugenio\invalidez\codigo\pmutuales.do
doparser I:\modelo_proyeccion_sc\programas\modulo_ma\06_checkea_piden.do
doparser T:/bases/bdsc/muestra_sc/crea_muestras/2_a_muestra_redondeo.do
doparser T:\bases\bdsc\muestra_sc\crea_muestras\1_c_muestra_renta_tope.do
doparser T:/bases/bdsc/muestra_sc/crea_muestras/1_a_crea_base_muestra.do
doparser T:/bases/bdsc/muestra_sc/crea_muestras/1_b_muestra_giro_tope.do
doparser T:/bases/bdsc/muestra_sc/crea_muestras/1_c_muestra_renta_tope.do
doparser T:/bases/bdsc/muestra_sc/crea_muestras/2_a_muestra_redondeo.do
doparser T:/bases/bdsc/muestra_sc/crea_muestras/2_b_muestra_detalles_finales.do
doparser T:/bases/bdsc/muestra_sc/crea_muestras/2_c_largos_registros.do
doparser T:/bases/bdsc/muestra_sc/crea_muestras/3_muestras_a_informatica.do


cd I:\modelo_proyeccion_sc\programas\modulo_ma\programas
doparser 0_distribucion_rama.do , e(resultados)
doparser 0_renta_afil_a.do , e(resultados)
doparser 0_renta_afil_b.do , e(resultados)
doparser 1_cotizantes.do , e(resultados)
doparser 2_ingresos.do , e(resultados)
doparser 3_saldos.do , e(resultados)
doparser 4_tasa.do , e(resultados)
doparser 5_probabilidades_a.do , e(resultados)
doparser 5_probabilidades_b.do , e(resultados)


cd I:\modelo_proyeccion_sc\programas\modulo_ma\
doparser config_modulo_ma.do
doparser 00_simulacion.do
doparser 01_tasas_de_crecimiento.do
doparser 02_probabilidades_y_pondedadores.do, t(merge)
doparser 03_tasas_de_extraccion.do
doparser 04_genera_matrices.do
*/
