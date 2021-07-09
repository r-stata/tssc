program poverty_recovery
	version 12
	qui {
	
	***************************************
	* CONSTANTES DE LA FASE: RECUPERACION *
	***************************************
	* Transisción de personas
		* # personas que ingresan a otros
		local N_otros =0.00673562487116526*$N_total
		* # Personas que dejan el empleo adecuado
		local N_adec =0.000585268188326965*$N_total
		* # Personas que dejan el desempleo 
		local N_desem =0.00504606391811802*$N_total
		* # Personas que dejan el empleo inadecuado
		local N_inadec =0.00110429276472025*$N_total
	* Incremento en los salarios
		* Incremento adecuados
		local W_adec=0.0484658984184229
		* Incremento inadecuados
		local W_inadec=0.0669729880256196
		* Incremento desempleados
		local W_desem=0
		* Incremento otros
		local W_otros=0.121521273004074
	
	********************************************
	* Generar variable aleatoria de transicion *
	********************************************
	* Para los que salen de adecuado *
		* Generar números aleatorios entre 1 y el total de "otros"
		set seed 12345
		gen var=runiform()
		sort var
		
		sort adec, stable
		gen x1=(_n) if adec==1
		drop var 
		
		gen transicion_1=1 if x1<=`N_adec'
		drop x1
		sort id
	* Para los que salen de inadecuado *
		* Generar números aleatorios entre 1 y el total de "otros"
		set seed 1234
		gen var=runiform()
		sort var
		
		sort inadec, stable
		gen x1=(_n) if inadec==1
		drop var 
		
		replace transicion_1=1 if x1<=`N_inadec'
		drop x1
		sort id
	* Para los que salen de desempleo *
		* Generar números aleatorios entre 1 y el total de "otros"
		set seed 123
		gen var=runiform()
		sort var
		
		sort desem, stable
		gen x1=(_n) if desem==1
		drop var 
		
		replace transicion_1=1 if x1<=`N_desem'
		drop x1
		sort id
		
	******************************
	* Generar datos a reemplazar *
	******************************
	* Mediana "otros"
		_pctile ingrtl [aw=FEXP] ///
			if otros==1 & ingrtl>=0 & ingrtl<999999, p(10(10)90)
		ret li
		gen income_1 = `r(r5)'

	**************************************
	* Estimacion de los ingresos totales *
	**************************************
	gen ingresos_est_1 = ingrtl
	* Reemplazamos con la mediana de otros ingresos *
	replace ingresos_est_1=income_1 if transicion_1==1
	* Generamos variables de identificación para la nueva CAE *
		* Nuevos adecuados
		gen adec_est_1=adec
		replace adec_est_1=. if transicion_1==1 & adec==1
		* Nuevos inadecuados
		gen inadec_est_1=inadec
		replace inadec_est_1=. if transicion_1==1 & inadec==1
		* Nuevos desempleados
		gen desem_est_1=desem
		replace desem_est_1=. if transicion_1==1 & desem==1
		* Nuevos otros
		gen otros_est_1=otros
		replace otros_est_1=1 if transicion_1==1 & otros==.
	* Se incrementa el salario de acuerdo a la nueva CAE *
		replace ingresos_est_1=ingresos_est_1*(1+`W_adec') if adec_est_1==1
		replace ingresos_est_1=ingresos_est_1*(1+`W_inadec') if inadec_est_1==1
		replace ingresos_est_1=ingresos_est_1*(1+`W_desem') if desem_est_1==1
		replace ingresos_est_1=ingresos_est_1*(1+`W_otros') if otros_est_1==1
	* Determinar ingreso por hogar *
		bysort idhogar: egen ingr_hogar1=total(ingresos_est_1) ///
			if ingresos_est_1>=0 & ingresos_est_1<999999

		bysort idhogar: egen ingr_hogar_est_1=mean(ingr_hogar1)
		drop ingr_hogar1
	* Determinar ingreso per capita
		gen ingr_pc_est_1=ingr_hogar_est_1/npersona

	****************************
	* Estimacion de la pobreza *
	****************************
	* Variable pobreza
		gen poverty_est_1=1 if ingr_pc_est_1<Lp
		replace poverty_est_1=0 if ingr_pc_est_1>=Lp
		replace poverty_est_1=. if ingr_pc_est_1==.

		svy: tab poverty_est_1 if poverty_est_1==1
		global Pobreza_recuperacion =(`e(N_pop)'/$poblacion_t1)*100
	*Pobreza extrema
		gen extreme_est_1=1 if ingr_pc_est_1<Lpe
		replace extreme_est_1=0 if ingr_pc_est_1>=Lpe
		replace extreme_est_1=. if ingr_pc_est_1==.
		
		svy: tab extreme_est_1 if extreme_est_1==1
		global Extrema_recuperacion =(`e(N_pop)'/$poblacion_t1)*100
		
		sort id
}
end
