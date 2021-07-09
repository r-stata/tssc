*! version 0.0.1  22sep2008
*! Authors: Javier Lázaro, Javier Zamora & Víctor Abraira.

/* Clinical Biostatistics Unit, Hospital Ramón y Cajal. Madrid. Spain.
   CIBER de Edidemiología y Salud Pública (CIBERESP). Spain. 

Generalization of the kappa coefficient to allow using 
weights and an explicit agreement 
definition for multiple raters and incomplete designs

*/

program define kappa2, rclass
	version 10, missing
	syntax varlist(min=2 numeric) [if] [in] [, Absolute Wgt(string) Majority(integer -1) Jackknife Tab]
			
preserve	

quietly{
	if `"`if'"'!="" | "`in'"!="" { 
			keep `if' `in'
	}
	tokenize `varlist'
	local nvar : word count `varlist'
	tempfile fich1
	save `fich1', replace
	tempfile fich2
	global fich2="`fich2'"
	keep `1'
	save `fich2',replace
	use "`fich1'",clear
	forvalues i=2(1)`nvar'{
		keep ``i''
		rename ``i'' `1'
		append using `fich2'
		save `fich2',replace	
		use `fich1',clear
	}
 	use "`fich2'",clear
	duplicates drop `1'  ,force 
	keep if `1' != . 
	sort `1'
	save `fich2',replace
	global total= _N //No incluye "."

	if $total < 2{
		noisily display in red "too few rating categories"	
		exit 499
	}
	forvalues i=1(1) $total{
		global calific`i'=`1'[`i']
	}

	use "`fich1'",clear

	tempvar desc
	generate `desc'=0
	forvalues i=1(1)$total{
		local globalLocal = "calific`i'"
		tempvar calif$`globalLocal'
		generate `calif$`globalLocal''= 0
	}	

	local auxN=_N 	
	forvalues i=1(1)`auxN'{
		forvalues j=1(1)`nvar'{

			local aux= ``j''[`i']  
			if `aux'== . {
				replace `desc' = `desc'[`i'] + 1 in `i'
			}	
			else{	
				replace `calif`aux'' = `calif`aux''[`i'] + 1 in `i'
			}	
		}
	}

	local Nc1 =0
	forvalues i=1(1)`auxN'{
		if `desc'[`i']  <=  `nvar' - 2{
			local Nc1= `Nc1' + 1
		}
	}
	if `Nc1'== 0{
		noisily display in red "Is not possible to observe any agreement, because there isn´t any subject classified by more than one observer"	
		exit
	}

// Para comprobar majority
if `majority' != -1 {
	local string = ""
	forvalues i=1(1)$total{
		local globalLocal = "calific`i'"
		local string = "`string' `calif$`globalLocal''"
	}	
	tempname max maxMajority
	egen `max' = rowmax(`string')
	egen `maxMajority' = max(`max')
	local maximo = `maxMajority'[1]
	noisily display ""
	if `maximo' < 2 {
		noisily display in red "Option majority not allowed. Is not possible to observe the majority agreement"
		exit 198
	}
	else if  `majority' > `maximo' {
		noisily display in red " Sorry, the maximum number of subjects observed whom it is able to observe the defined agreement is `maximo'"
		exit 198
	}
	else if `majority' < 2 {
		noisily display in red " Sorry, the minimum number of subjects observed whom it is able to observe the defined agreement is 2"
		exit 198
	}
	else{
		drop if `max' < `majority'
		local num= _N
		noisily display in green " The number of subjects observed whom it is able to observe the defined agreement is `num'"
	}

	use "`fich1'",clear


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	tempfile ficheroCompleto
	save `"`ficheroCompleto'"',replace
	tempname producto
	tempname fichero
	local jotai=`nvar'

// Hacemos todas las permutaciones posibles y generamos dicho fichero
	while `jotai'>=`majority'{		
		tempfile fichero`jotai'
		use `fich2',clear
		rename `1' `1'x`jotai'
		save `"`fichero`jotai''"',replace
		forvalues i=2(1)`jotai'{
			use `fich2',clear
			rename `1' ``i''x`jotai'			//IMPORTANTE: MEJOR PONER NOMBRE TEMPORAL.
			cross using `"`fichero`jotai''"' // Hace todas las permutaciones posibles.
			save `"`fichero`jotai''"',replace
		}

//Calculamos la frecuencia de cada permutación
		forvalues i=1(1)$total{
			local globalLocal = "calific`i'"
			tempvar fper$`globalLocal'		
			generate `fper$`globalLocal''= 0
		}

// Asignamos la cantidad de calificaciones de cada permutación.
		describe, varlist
		tokenize `r(varlist)'
		local guionN=_N
		forvalues i=1(1)`guionN' {
			forvalues j=1(1)`jotai'{	
				local aux= ``j''[`i']  
				replace `fper`aux'' = `fper`aux''[`i'] + 1 in `i'							
			}
		}
		// Procedemos a eliminar las que no cumplan la restricción de acuerdo por mayoría: (Ha de haber un mínimo de majority observaciones iguales)
		// Usaremos una variable temporal que nos indique si el acuerdo en alguna de las observaciones es mayor que majority, para eliminar las que no lo cumpla. IMP!!! Misma duda que siempre!!!

		tempname aux
		tempvar repetida
		generate `repetida'=0
		forvalues j=1(1)$total {
			local globalLocal = "calific`j'"
			forvalues i=1(1)`guionN' {
				if `fper$`globalLocal''[`i']>= `majority'{
					replace `repetida' = 1 in `i'
				}
			}
		}
		drop if `repetida'==0
		drop `repetida'
		forvalues i=1(1)$total{
			local globalLocal = "calific`i'"
			drop `fper$`globalLocal''
		}

		global numero`jotai' = _N
		save `"`fichero`jotai''"',replace
		local jotai=`jotai'-1
		tokenize `varlist'
	}	


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Ahora, vamos a juntar (merge) los ficheros creados con el original (esto lo haremos por eficiencia)

	local jotai=`nvar'
	use `"`fichero`jotai''"', clear
	local jotai=`jotai'-1
	while `jotai'>=`majority'{
		merge using `"`fichero`jotai''"'
		drop _merge
		local jotai=`jotai'-1
	}
	// Juntados los archivos anteriores en uno

	tempfile ficheroPermutacion
	save `"`ficheroPermutacion'"',replace
	global fPermutacion=`"`ficheroPermutacion'"'
} // majority

} // quietly

//////////////////////////////////////////////////////////////////////////////////////////////////

// Llamada:

	quietly use "`fich1'",clear
	if "`tab'"!=""{
		if `nvar' > 2{
			di in red "option tab not allowed with 3 or more raters"
			exit 198
		}
		else{
			noisily tab `varlist'		// En el caso de poner fweight, habría que añadirlo aquí.
		}
	}
	kappaAux `varlist' , majority(`majority') `absolute' wgt(`wgt')
	local kapAgreement= r(kappa)
	local peAgreement = r(prop_e)
	local poAgreement = r(prop_o) 
	tempname resultados
	noisily display ""
	if `majority' != -1 {
		local nombre = "majority_of_`majority'"
	}
	else if "`wgt'"!=""{
		local nombre = "pairwise_we"
	}
	else{
		local nombre = "pairwise"
	}	
	if "`jackknife'" == ""  {
		matrix `resultados'= (`poAgreement', `peAgreement' ,`kapAgreement' ) 
		matrix colnames `resultados' =  Po Pe  K
		matrix rownames `resultados' = `nombre'
		noisily matlist `resultados',cspec(| %14s | %9.0g & %9.0g & %9.0g |) rspec(---)  rowtitle("AGREEMENT") nohalf underscore aligncolnames(center)	
	}
	else  {
		tempname aux
		noisily jknife jk1=r(kappa) , noheader notable : kappaAux `varlist' , majority(`majority') `absolute' wgt(`wgt')
		matrix `aux' = e(b_jk)
		matrix `resultados'= (`poAgreement',`peAgreement',`kapAgreement',`aux'[1,1],_se[jk1],`aux'[1,1]-_se[jk1]*invttail(e(df_r),.025),`aux'[1,1]+_se[jk1]*invttail(e(df_r),.025))
		matrix colnames `resultados' =  Po Pe  K  PJ(K) SE(K)  [95%_Conf  Interval]	 
		matrix rownames `resultados' = `nombre'
		noisily	matlist `resultados',cspec(| %14s | %9.0g & %9.0g & %9.0g & %9.0g & %9.0g & %9.0g &o0 %9.0g |) rspec(---)  rowtitle("AGREEMENT") nohalf underscore aligncolnames(center)
		return matrix results=`resultados'
	}

	local n = _N
	ret scalar N = `n'
	ret scalar prop_e = `peAgreement'
	ret scalar prop_o = `poAgreement'
	ret scalar kappa = `kapAgreement'
	global S_1 `n'
	global S_2 `poAgreement'
	global S_3 `peAgreement'
	global S_4 `kapAgreement'	
/*
	
		ret scalar z = `k'/`se'
	        ret scalar se = `se'
		global S_5 `return(z)'
	*/
// Borramos datos auxiliares almacenados:
	
	macro drop fich2
	forvalues i=1(1) $total{
		macro drop calific`i'
	}
	macro drop fPermutacion
	local jotai=`nvar'
	if `majority' != -1{
		while `jotai'>=`majority'{		
			macro drop global numero`jotai'
			local jotai=`jotai'-1
		}	
	}
	macro drop total

end


