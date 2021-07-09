// vers 0.1.1 diciembre 2011, George Vega Yon
capture program drop cuentacot
program cuentacot, nclass sortpreserve
	/* Este programa cuenta número de cotizaciones continuas/descontinuas en un
	periodo establecido para cada uno de los individuos en función de los pará_
	metros establecidos en las opciones del programa.	
	*/
	vers 9
	#delimit ;
	syntax
		varlist (min=2 max=3)
		, [DIScontinuas
		CONTinuas
		CONTEMPleador
		EMPleador
		MENNCont
		MENNDiscont
		Keep
		NCot(integer 12)
		NPer(integer 24)
		NSolic(varname)
		TIpcon(varname)];
	#delimit cr
		
	tokenize `varlist'

	local time_name `1' /* Define la variable de tiempo de referencia */
	local id_per `2' /* Id individuo */
	local id_emp `3' /* Id empleador */
	
	// Para mantener el orden
	tempvar orden
	gen `orden' = _n
	
	cap conf existence `nsolic'
	local exists = _rc
	if (`exists' == 6) { // Verifica la existencia de la variable
		tempvar nsolic
		qui gen byte `nsolic' = .
		local extraper = 0
		sort `orden'
	}
	else {
		// En el caso de que existan solicitudes, se encuentra el N max de solici
		// con la finalidad de, al momento de expandir los datos, agregar tantas
		// observaciones como solicitudes existan.
		tempvar extraper0
		tempvar extraper1
		quietly {
			bysort `nsolic': gen `extraper0' = _N if `nsolic' != .
			egen `extraper1' = max(`extraper0')
		}
		local extraper = `extraper1'
		drop `extraper0' `extraper1'
		sort `orden'
	}
	
	cap conf existence `tipcon'
	local exists = _rc
	if (`exists' == 6) { // Verifica la existencia de la variable
		tempvar tipcon
		gen byte `tipcon' = 1
	}
	
	cap conf existence `id_emp'
	local exists = _rc
	if (`exists' == 6) { // Verifica la existencia de la variable
		tempvar id_emp
		gen byte `id_emp' = 1
	}		

	tempvar tiempo_continuo /* Define la variable de tiempo continuo a utilizar */

	local cuenta_tot cuenta_cot_dis 
	local cuenta_con cuenta_cot_cont
	local cuenta_con_emp cuenta_cot_cont_emp 
	local cuenta_m_en_n_cont cuenta_cot_`ncot'_en_`nper'_cont
	local cuenta_m_en_n_dis cuenta_cot_`ncot'_en_`nper'_dis
	local cuenta_ult_con_emp cuenta_`ncot'_ult_cot_emp 
	
	local cot_cont cotiza_continuas`ncot'
	local cot_m_en_n_cont cot_`ncot'_en_`nper'_cont 
	local cot_m_en_n_dis cot_`ncot'_en_`nper'_dis
	local cot_n_emp_dis cot_`ncot'_emp_dis
	local cot_n_emp_cont cot_`ncot'_emp_cont
	
	local var_cuenta "`cuenta_tot' `cuenta_con' `cuenta_con_emp' `cuenta_m_en_n_cont' `cuenta_m_en_n_dis' `cuenta_ult_con_emp'"
	local var_bool "`cot_cont' `cot_m_en_n_cont' `cot_m_en_n_dis' `cot_n_emp_dis'"

	****************************************************************************
	* Contador de tiempo
	
	dis _newline
	dis _column(4) "Contador de cotizaciones"
	dis _column(4) "Fecha de inicio `c(current_date)' - `c(current_time)'"
	dis _column(4) as text "{hline 30}
	dis _column(4) "Preparando variable de tiempo"
	
	quietly{
		gen `tiempo_continuo' = floor(`time_name'/100)*12
		replace `tiempo_continuo' = `tiempo_continuo' + /* 
			*/ `time_name' - `tiempo_continuo'/12*100

		sort `id_per' `tiempo_continuo' `id_emp' `tipcon' `nsolic', stable
	}
	
	dis _column(6) "Finalizado..."
	
	****************************************************************************

	if (length("`discontinuas'") != 0) {
	* Contador de Cotizaciones discontinuas
	
		dis _column(4) "Calculando cotizaciones discontinuas"	
		
		quietly {
			cap drop `cuenta_tot'
			gen `cuenta_tot' = 1
			by `id_per': replace `cuenta_tot' = `cuenta_tot'[_n - 1] + 1 /*
				 */ *((`tiempo_continuo'[_n] != `tiempo_continuo'[_n - 1]) & ///
				 `nsolic'[_n] == .) if _n > 1
				 
		}
		
		dis _column(6) "Finalizado..."
	}
	
	if (length("`continuas'") != 0) {
	* Contador de Cotizaciones continuas
	
		dis _column(4) "Calculando cotizaciones continuas"	
		
		quietly {		
			cap drop `cuenta_con'
			gen `cuenta_con' = 1
			by `id_per': replace `cuenta_con' = `cuenta_con'[_n - 1] + 1 /*
				*/ * (`tiempo_continuo'[_n - 1] + 1 == `tiempo_continuo'[_n]) /*
				*/ * (`nsolic' == .) if  _n > 1 & ///
				(`tiempo_continuo'[_n] - `tiempo_continuo'[_n - 1] < 2) & ///
				(`nsolic'[_n] != . & `nsolic'[_n - 1] == . | ///
				 `nsolic'[_n] == . & `nsolic'[_n - 1] == . | ///
				 `nsolic'[_n] != . & `nsolic'[_n - 1] != .) & ///
				 (`tipcon'[_n] == `tipcon'[_n - 1])
				
			cap drop `cot_cont'
			gen `cot_cont' = `cuenta_con' >= `ncot'
		}
		
		dis _column(6) "Finalizado..."
	}
		
	****************************************************************************	
	* Contador de Cotizaciones continuas con el mismo empleador

	if (length("`contempleador'") != 0) {
	
		dis _column(4) "Calculando cotizaciones continuas con el mismo empleador"	
		
		quietly {		
			cap drop `cuenta_con_emp'
			
			sort `id_per' `id_emp' `tiempo_continuo', stable

			gen `cuenta_con_emp' = 1
			by `id_per' `id_emp': replace `cuenta_con_emp' = `cuenta_con_emp'[_n - 1] + 1 /*
				*/ * (`tiempo_continuo'[_n - 1] + 1 == `tiempo_continuo'[_n])*(`nsolic' == .) ///
				if  _n > 1 & ///
				(`tiempo_continuo'[_n] - `tiempo_continuo'[_n - 1] < 2) & ///
				(`nsolic'[_n] != . & `nsolic'[_n - 1] == . | ///
				 `nsolic'[_n] == . & `nsolic'[_n - 1] == . | ///
				 `nsolic'[_n] != . & `nsolic'[_n - 1] != .) & ///
				 (`tipcon'[_n] == `tipcon'[_n - 1])
			
			cap drop `cot_n_emp_cont'
			gen byte `cot_n_emp_cont' = `cuenta_con_emp' >= `ncot'
			
			// Vuelve al orden necesario
			sort `id_per' `tiempo_continuo' `id_emp' `tipcon' `nsolic', stable
		}

		dis _column(6) "Finalizado..."		
	}
	
	****************************************************************************
	* Contador de "m" últimas cotizaciones con el mismo empleador
	
	if (length("`empleador'") != 0) {
	
		dis _column(4) "Calculando las `ncot' cotizaciones discontinuas con el mismo empleador"	
			
		quietly {
			cap drop `cuenta_ult_con_emp'
			gen `cuenta_ult_con_emp' = 1
			
			sort `id_per' `id_emp' `tiempo_continuo', stable
			
			by `id_per' `id_emp': replace `cuenta_ult_con_emp' = `cuenta_ult_con_emp'[_n - 1] ///
				+ 1 * (`tiempo_continuo'[_n - 1] != `tiempo_continuo'[_n] & `nsolic'[_n] == .) if _n > 1 & ///
				`tipcon'[_n] == `tipcon'[_n - 1]

			cap drop `cot_n_emp_dis'
			gen byte `cot_n_emp_dis' = `cuenta_ult_con_emp' >= `ncot'		

			// Vuelve al orden necesario
			sort `id_per' `tiempo_continuo' `id_emp' `tipcon' `nsolic', stable			
		}
		
		dis _column(6) "Finalizado..."		
	}
	
	****************************************************************************
	* Contadores Con periodos
	
	local nper2 = `nper' - 1 + `extraper'
	
	if (length("`menncont'") != 0 | length("`menndiscont'") != 0) {
	
		dis _column(4) "Determinando periodos válidos para cuentas en periodos"
		
		quietly {
			forval i = `nper2'(-1)0 {			
				tempvar tiempo_continuo`i'
				by `id_per': gen `tiempo_continuo`i'' = `tiempo_continuo'[_n - `i']
							
				tempvar nsolic`i'
				by `id_per': gen `nsolic`i'' = `nsolic'[_n - `i']
			}

			* Prepara variables para validar últimos periodos
			tempvar ult_periodo_valido
			gen `ult_periodo_valido' = 0

			// Marca de periodos válidos de 0 a `nper'		
			forval i = 1/`nper2' {
				replace `ult_periodo_valido' = `i' if ///
					(`tiempo_continuo0' - `tiempo_continuo`i'') + 1 <= `nper' & ///
					`nsolic' == . & `nsolic`i'' == .
				
			}			
		}
		cap drop ultimo
		gen ultimo = `ult_periodo_valido'
		dis _column(6) "Finalizado..."
	}

	if (length("`menncont'") != 0) {
	
		dis _column(4) "Calculando `ncot' cotizaciones continuas en los últimos `nper' periodos"	
		
		quietly {		
			cap drop `cuenta_m_en_n_cont'
			gen `cuenta_m_en_n_cont' = 1
			
			// Comparando entremedio
			tempvar cuenta_m_en_n_cont2
			gen `cuenta_m_en_n_cont2' = 1

			forval i = `nper2'(-1)1 {
				local j = `i' - 1
				
				// Cuenta de periodos continuos
				replace `cuenta_m_en_n_cont' = (`cuenta_m_en_n_cont' + ///
					(`tiempo_continuo`i'' == `tiempo_continuo`j''- 1))*(`nsolic`j'' == .) if /// 
					`i' <= `ult_periodo_valido'
			
				replace `cuenta_m_en_n_cont2' = max(`cuenta_m_en_n_cont', `cuenta_m_en_n_cont2') if ///
					(`nsolic`j'' == .)
			}
			
			// Reemplaza por el máximo encontrado
			replace `cuenta_m_en_n_cont' = `cuenta_m_en_n_cont2'
			
			// En el caso de que sea multicot
			by `id_per': replace `cuenta_m_en_n_cont' = `cuenta_m_en_n_cont' + ///
				(`tiempo_continuo' == `tiempo_continuo'[_n - 1] & `tiempo_continuo' != `tiempo_continuo'[_n+1])
			
			// En el caso de que sea solicitudes al seguro
			by `id_per': replace `cuenta_m_en_n_cont' = `cuenta_m_en_n_cont'[_n - 1] if `nsolic'[_n] != .
			
			cap drop `cot_m_en_n_cont'
			gen byte `cot_m_en_n_cont' = `cuenta_m_en_n_cont' >= `ncot'
		}
		
		dis _column(6) "Finalizado..."		
	}
	
	if (length("`menndiscont'") != 0) {
		
		dis _column(4) "Calculando `ncot' cotizaciones discontinuas en los últimos `nper' periodos"	
		
		quietly {
			cap drop `cuenta_m_en_n_dis'
			gen `cuenta_m_en_n_dis' = 1
			
			forval i = `nper2'(-1)1 {
				local j = `i' - 1
				replace `cuenta_m_en_n_dis' = `cuenta_m_en_n_dis' + ///
					(`tiempo_continuo`i'' != `tiempo_continuo`j'')*(`nsolic`j'' == .) ///
					if `i' <= `ult_periodo_valido'
			}
			
			// En el caso de que sea multicot
			by `id_per': replace `cuenta_m_en_n_dis' = `cuenta_m_en_n_dis' + ///
				(`tiempo_continuo' == `tiempo_continuo'[_n - 1] & `tiempo_continuo' != `tiempo_continuo'[_n+1])
			
			// En el caso de que sea solicitudes al seguro
			replace `cuenta_m_en_n_dis' = `cuenta_m_en_n_dis'[_n - 1] if `nsolic' != .
			
			cap drop `cot_m_en_n_dis'
			gen byte `cot_m_en_n_dis' = `cuenta_m_en_n_dis' >= `ncot'
		}
		
		dis _column(6) "Finalizado..."		
	}
	
	// Cierre
	
	if (length("`keep'") == 0) {
		cap drop `cuenta_con'
		cap drop `cuenta_m_en_n_cont'
		cap drop `cuenta_m_en_n_dis'
		cap drop `cuenta_ult_con_emp'
	}
	else {
		foreach var of local var_cuenta {
			cap compress `var'
		}
	}
	
	foreach var of local var_bool {
		cap compress `var'
	}
		
	cap la var `cuenta_tot' "Contador de Cotizaciones discontinuas"
	cap la var `cuenta_con' "Contador de Cotizaciones continuas"
	cap la var `cuenta_con_emp' "Contador de Cotizaciones continuas con el mismo empleador"
	cap la var `cuenta_m_en_n_cont' "`ncot' cotizaciones continuas en los últimos `nper' periodos"
	cap la var `cuenta_m_en_n_dis' "`ncot' cotizaciones discontinuas en los últimos `nper' periodos"
	cap la var `cuenta_ult_con_emp' "`ncot' cotizaciones con el mismo empleador en los últimos `nper' periodos"
	cap la var `cot_cont' "1 si observación cuenta con `ncot' cotizaciones continuas."
	cap la var `cot_m_en_n_cont' "1 si observación cuenta con `ncot' cotiza cont. en últ `nper' per"
	cap la var `cot_m_en_n_dis' "1 si observación cuenta con `ncot' cotiza discont. en últ `nper' per"
	cap la var `cot_n_emp_dis' "1 si observación cuenta con `ncot' cotiza discont con el mismo emp en últ `nper' per"
	
	dis _column(4) "Fecha de término `c(current_date)' - `c(current_time)'"
end
