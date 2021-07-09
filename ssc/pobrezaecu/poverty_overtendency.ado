program poverty_overtendency
	version 12
	qui {
			
	********************************************************
	* CONSTANTES DE LA FASE: DECRECIMIENTO SOBRE TENDENCIA *
	********************************************************
	* Transisción de personas
		* # personas que ENTRAN a adecuado
		local N_adec=0.00676653644109957*$N_total
		* # Personas que ENTRAN a inadecuado
		local N_inadec=0.000104330285030853*$N_total
		* # Personas que SALEN del desempleo 
		local N_desem=0.000963556274327383*$N_total
		* # Personas que SALEN de otros
		local N_otros=0.00590731045180304*$N_total
	* Incremento en los salarios
		* Incremento adecuados
		local W_adec=0.0784287692701199
		* Incremento inadecuados
		local W_inadec=0.0929436415158029
		* Incremento desempleados
		local W_desem=0
		* Incremento otros
		local W_otros=0.0265427897770885
	
	************************
	* Transición aleatoria *
	************************
	* Paso 1: Seleccionar aleatoriamente el # de "otros" y "desempleados"
	* que salen de su condición de actividad 
		* Los que salen de otros *
		set seed 12345
		gen var=runiform()
		sort var, stable
		sort otros, stable
		gen x1=(_n) if otros==1
		drop var 
		
		gen transicion_3=1 if x1<=`N_otros'
		drop x1
		sort id
		* Los que salen de desempleo *
		set seed 1234
		gen var=runiform()
		sort var, stable
		sort desem, stable
		gen x1=(_n) if desem==1
		drop var 
		
		replace transicion_3=1 if x1<=`N_desem'
		drop x1
		sort id
	* Paso 2: de entre las personas que salieron en el paso 1, seleccionar
	* de manera aleatoriamente los que pasan a "adecuado" e "inadecuado".
	* Los que entran a adecuado tendrán un identificador = 1, y los que 
	* pasan a inadecuado = 2
		* Los que entran a "inadecuado" 
		set seed 123
		gen var=runiform()
		sort var, stable
		sort transicion_3, stable
		drop var 
		gen x1=(_n) if transicion_3==1
		replace transicion_3=2 if x1<=`N_inadec'
		drop x1
		sort id
	******************************
	* Generar datos a reemplazar *
	******************************
	/* Se necesita generar una variable con la mediana del ingreso de las 
		personas con empleo adecuado e inadecuado. 
		Esta mediana será la que debe ser reemplazada en los ingresos totales 
		de los otros tipos de empleo.*/
	* Mediana "adecuado"
		_pctile ingrtl [aw=FEXP] ///
			if adec==1 & ingrtl>=0 & ingrtl<999999, p(10(10)90)
		ret li

		gen mediana_adec_3 = r(r5)
		
	* Mediana "inadecuado"
		_pctile ingrtl [aw=FEXP] ///
			if inadec==1 & ingrtl>=0 & ingrtl<999999, p(10(10)90)
		ret li

		gen mediana_inadec_3 = r(r5)

	**************************************
	* Estimación de los ingresos totales *
	**************************************
	gen ingresos_est_3 = ingrtl
	* Reemplazamos con la mediana de otros ingresos *
		* Los que pasaron a adecuado
		replace ingresos_est_3=mediana_adec_3 if transicion_3==1
		* Los que pasaron a inadecuado
		replace ingresos_est_3=mediana_inadec_3 if transicion_3==2
	* Generamos variables de identificación para la nueva CAE *
		* Nuevos adecuados
		gen adec_est_3=adec
		replace adec_est_3=1 if transicion_3==1 & adec==.
		* Nuevos inadecuados
		gen inadec_est_3=inadec
		replace inadec_est_3=1 if transicion_3==2 & inadec==.
		* Nuevos desempleados
		gen desem_est_3=desem
		replace desem_est_3=. if (transicion_3==1|transicion_3==2) & desem==1
		* Nuevos otros
		gen otros_est_3=otros
		replace otros_est_3=. if (transicion_3==1|transicion_3==2) & otros==1
	* Se incrementa el salario de acuerdo a la CAE *
		replace ingresos_est_3=ingresos_est_3*(1+`W_adec') if adec_est_3==1
		replace ingresos_est_3=ingresos_est_3*(1+`W_inadec') if inadec_est_3==1
		replace ingresos_est_3=ingresos_est_3*(1+`W_desem') if desem_est_3==1
		replace ingresos_est_3=ingresos_est_3*(1+`W_otros') if otros_est_3==1
	* Determinar ingreso por hogar *
		bysort idhogar: egen ingr_hogar1=total(ingresos_est_3) ///
			if ingresos_est_3>=0 & ingresos_est_3<999999

		bysort idhogar: egen ingr_hogar_est_3=mean(ingr_hogar1)
		drop ingr_hogar1
	* Determinar ingreso per cápita
		gen ingr_pc_est_3=ingr_hogar_est_3/npersona

	****************************
	* Estimación de la pobreza *
	****************************
	* Variable pobreza
		gen poverty_est_3=1 if ingr_pc_est_3<Lp
		replace poverty_est_3=0 if ingr_pc_est_3>=Lp
		replace poverty_est_3=. if ingr_pc_est_3==.

		svy: tab poverty_est_3 if poverty_est_3==1
		global Pobreza_sobre_tendencia =(`e(N_pop)'/$poblacion_t1)*100
	*Pobreza extrema
		gen extreme_est_3=1 if ingr_pc_est_3<Lpe
		replace extreme_est_3=0 if ingr_pc_est_3>=Lpe
		replace extreme_est_3=. if ingr_pc_est_3==.

		svy: tab extreme_est_3 if extreme_est_3==1
		global Extrema_sobre_tendencia =(`e(N_pop)'/$poblacion_t1)*100
		
		sort id
}
end
