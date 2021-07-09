program poverty_growth 
	version 12
	qui {
	**************************************
	* CONSTANTES DE LA FASE: CRECIMIENTO *
	**************************************
	* Transisción de personas
		* # personas que ENTRAN a adecuado
		local N_adec=0.000936439359609847*$N_total
		* # Personas que SALEN de inadecuado
		local N_inadec=0.00620937998341057*$N_total
		* # Personas que SALEN del desempleo 
		local N_desem=0.00216070894482534*$N_total
		* # Personas que ENTRAN a otros
		local N_otros=0.00743364956862605*$N_total
	* Incremento en los salarios
		* Incremento adecuados
		local W_adec=0.0837184641883627
		* Incremento inadecuados
		local W_inadec=0.100612262980684
		* Incremento desempleados
		local W_desem=0
		* Incremento otros
		local W_otros=0.0411582916046652
	
	************************
	* Transición aleatoria *
	************************
	* Paso 1: Seleccionar aleatoriamente el # de "inadecuados" y "desempleados"
	* que salen de su condición de actividad 
		* Los que salen de inadecuado *
		set seed 12345
		gen var=runiform()
		sort var
		sort inadec, stable
		gen x1=(_n) if inadec==1
		drop var 
		
		gen transicion_2=1 if x1<=`N_inadec'
		drop x1
		sort id
		* Los que salen de desempleo *
		set seed 1234
		gen var=runiform()
		sort var
		sort desem, stable
		gen x1=(_n) if desem==1
		drop var 
		
		replace transicion_2=1 if x1<=`N_desem'
		drop x1
		sort id
	* Paso 2: de entre las personas que salieron en el paso 1, seleccionar
	* de manera aleatoriamente los que pasan a "adecuado" y "otros".
	* Los que entran a adecuado tendrán un identificador = 1, y los que 
	* pasan a otros = 2
		* Los que entran a "otros" 
		set seed 123
		gen var=runiform()
		sort var
		sort transicion_2, stable
		drop var
		gen x1=(_n) if transicion_2==1
		replace transicion_2=2 if x1<=`N_otros'
		drop x1
		sort id
	******************************
	* Generar datos a reemplazar *
	******************************
	* Se necesita generar una variable con la mediana del ingreso de las 
	* personas con empleo adecuado y otros. 
	* Esta mediana será la que debe ser reemplazada en los ingresos totales 
	* de los otros tipos de empleo.
	* Mediana "adecuado"
		_pctile ingrtl [aw=FEXP] ///
			if adec==1 & ingrtl>=0 & ingrtl<999999, p(10(10)90)
		ret li

		gen mediana_adec_2 = r(r5)
	* Mediana "otros"
		_pctile ingrtl [aw=FEXP] ///
			if otros==1 & ingrtl>=0 & ingrtl<999999, p(10(10)90)
		ret li

		gen mediana_otros_2 = r(r5)

	**************************************
	* Estimación de los ingresos totales *
	**************************************
	gen ingresos_est_2 = ingrtl
	* Reemplazamos con la mediana de otros ingresos *
		* Los que pasaron a adecuado
		replace ingresos_est_2=mediana_adec_2 if transicion_2==1
		* Los que pasaron a desempleo
		replace ingresos_est_2=mediana_otros_2 if transicion_2==2
	* Generamos variables de identificación para la nueva CAE *
		* Nuevos adecuados
		gen adec_est_2=adec
		replace adec_est_2=1 if transicion_2==1 & adec==.
		* Nuevos inadecuados
		gen inadec_est_2=inadec
		replace inadec_est_2=. if (transicion_2==1|transicion_2==2) & inadec==1
		* Nuevos desempleados
		gen desem_est_2=desem
		replace desem_est_2=. if (transicion_2==1|transicion_2==2) & desem==1
		* Nuevos otros
		gen otros_est_2=otros
		replace otros_est_2=1 if transicion_2==2 & otros==.
	* Se incrementa el salario de acuerdo a la CAE *
		replace ingresos_est_2=ingresos_est_2*(1+`W_adec') if adec_est_2==1
		replace ingresos_est_2=ingresos_est_2*(1+`W_inadec') if inadec_est_2==1
		replace ingresos_est_2=ingresos_est_2*(1+`W_desem') if desem_est_2==1
		replace ingresos_est_2=ingresos_est_2*(1+`W_otros') if otros_est_2==1
	* Determinar ingreso por hogar *
		bysort idhogar: egen ingr_hogar1=total(ingresos_est_2) ///
			if ingresos_est_2>=0 & ingresos_est_2<999999

		bysort idhogar: egen ingr_hogar_est_2=mean(ingr_hogar1)
		drop ingr_hogar1
	* Determinar ingreso per cápita
		gen ingr_pc_est_2=ingr_hogar_est_2/npersona

	****************************
	* Estimación de la pobreza *
	****************************
	* Variable pobreza
		gen poverty_est_2=1 if ingr_pc_est_2<Lp
		replace poverty_est_2=0 if ingr_pc_est_2>=Lp
		replace poverty_est_2=. if ingr_pc_est_2==.

		svy: tab poverty_est_2 if poverty_est_2==1
		global Pobreza_crecimiento =(`e(N_pop)'/$poblacion_t1)*100
	*Pobreza extrema
		gen extreme_est_2=1 if ingr_pc_est_2<Lpe
		replace extreme_est_2=0 if ingr_pc_est_2>=Lpe
		replace extreme_est_2=. if ingr_pc_est_2==.

		svy: tab extreme_est_2 if extreme_est_2==1
		global Extrema_crecimiento =(`e(N_pop)'/$poblacion_t1)*100
		
		sort id
}

end
