program poverty_undertendency
	version 12
	qui {
	**********************************************
	* CONSTANTES DE LA FASE: DEC. BAJO TENDENCIA *
	**********************************************
	* Transisción de personas
		* # personas que SALEN de adecuado
		local N_adec=0.0122684543691852*$N_total
		* # Personas que ENTRAN a inadecuado
		local N_inadec=0.00941579659105652*$N_total
		* # Personas que ENTRAN al desempleo 
		local N_desem=0.00583656005344337*$N_total
		* # Personas que SALEN de otros
		local N_otros=0.0029839022753147*$N_total
	* Incremento en los salarios
		* Incremento adecuados
		local W_adec=0.0453349626194671
		* Incremento inadecuados
		local W_inadec=0.0494849457530924
		* Incremento desempleados
		local W_desem=0
		* Incremento otros
		local W_otros=0.0533560644355835000
	
	************************
	* Transición aleatoria *
	************************
	* Paso 1: Seleccionar aleatoriamente el # de "adecuados" y "otros" que *
	* salen de su condición de actividad 
		* Los que salen de adecuado *
		set seed 12345
		gen var=runiform()
		sort var, stable
		sort adec, stable
		gen x1=(_n) if adec==1
		drop var 
		
		gen transicion_4=1 if x1<=`N_adec'
		drop x1
		sort id
		* Los que salen de otros *
		set seed 12345
		gen var=runiform()
		sort var, stable
		sort otros, stable
		gen x1=(_n) if otros==1
		drop var 
		
		replace transicion_4=1 if x1<=`N_otros'
		drop x1
		sort id
	* Paso 2: de entre las personas que salieron en el paso 1, seleccionar
	* de manera aleatoriamente los que pasan a "inadecuado" y "desempleo".
	* Los que entran a inadecuado tendrán un identificador = 1, y los que 
	* pasan a desempleo = 2
		* Los que entran a "desempleo" 
		set seed 12345
		gen var=runiform()
		sort var, stable
		sort transicion_4, stable
		drop var 
		gen x1=(_n) if transicion_4==1
		replace transicion_4=2 if x1<=`N_desem'
		drop x1
		sort id
		
	******************************
	* Generar datos a reemplazar *
	******************************
	* Se necesita generar una variable con la mediana del ingreso de las 
	* personas con empleo inadecuado y desempleo. 
	* Esta mediana será la que debe ser reemplazada en los ingresos totales 
	* de los otros tipos de empleo.
	* Mediana "inadecuado"
		_pctile ingrtl [aw=FEXP] ///
			if inadec==1 & ingrtl>=0 & ingrtl<999999, p(10(10)90)
		ret li

		gen mediana_inadec_4 = r(r5)
	* Mediana "desempleo"
		_pctile ingrtl [aw=FEXP] ///
			if desem==1 & ingrtl>=0 & ingrtl<999999, p(10(10)90)
		ret li

		gen mediana_desem_4 = r(r5)
	**************************************
	* Estimación de los ingresos totales *
	**************************************
	gen ingresos_est_4 = ingrtl
	* Reemplazamos con la mediana de otros ingresos *
		* Los que pasaron a inadecuado
		replace ingresos_est_4=mediana_inadec_4 if transicion_4==1
		* Los que pasaron a desempleo
		replace ingresos_est_4=mediana_desem_4 if transicion_4==2
	* Generamos variables de identificación para la nueva CAE *
		* Nuevos adecuados
		gen adec_est_4=adec
		replace adec_est_4=. if (transicion_4==1|transicion_4==2) & adec==1
		* Nuevos inadecuados
		gen inadec_est_4=inadec
		replace inadec_est_4=1 if transicion_4==1 & inadec==.
		* Nuevos desempleados
		gen desem_est_4=desem
		replace desem_est_4=1 if transicion_4==2 & desem==.
		* Nuevos otros
		gen otros_est_4=otros
		replace otros_est_4=. if (transicion_4==1|transicion_4==2) & otros==1
	* Se incrementa el salario de acuerdo a la CAE *
		replace ingresos_est_4=ingresos_est_4*(1+`W_adec') if adec_est_4==1
		replace ingresos_est_4=ingresos_est_4*(1+`W_inadec') if inadec_est_4==1
		replace ingresos_est_4=ingresos_est_4*(1+`W_desem') if desem_est_4==1
		replace ingresos_est_4=ingresos_est_4*(1+`W_otros') if otros_est_4==1
	* Determinar ingreso por hogar *
		bysort idhogar: egen ingr_hogar1=total(ingresos_est_4) ///
			if ingresos_est_4>=0 & ingresos_est_4<999999

		bysort idhogar: egen ingr_hogar_est_4=mean(ingr_hogar1)
		drop ingr_hogar1
	* Determinar ingreso per cápita
		gen ingr_pc_est_4=ingr_hogar_est_4/npersona

	****************************
	* Estimación de la pobreza *
	****************************
	* Variable pobreza
		gen poverty_est_4=1 if ingr_pc_est_4<Lp
		replace poverty_est_4=0 if ingr_pc_est_4>=Lp
		replace poverty_est_4=. if ingr_pc_est_4==.

		svy: tab poverty_est_4 if poverty_est_4==1
		global Pobreza_bajo_tendencia =(`e(N_pop)'/$poblacion_t1)*100
	*Pobreza extrema
		gen extreme_est_4=1 if ingr_pc_est_4<Lpe
		replace extreme_est_4=0 if ingr_pc_est_4>=Lpe
		replace extreme_est_4=. if ingr_pc_est_4==.

		svy: tab extreme_est_4 if extreme_est_4==1
		global Extrema_bajo_tendencia =(`e(N_pop)'/$poblacion_t1)*100
		
		sort id
}

end
