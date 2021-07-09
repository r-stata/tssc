// vers 0.12.06 june 2012, George Vega Yon
cap program drop movavg
program movavg, sortpreserve by(onecall)
	vers 10
	// Define la sintaxis del comando
	#delimit ;
	syntax
		namelist(name=newvar max=1)
		=/exp [if/] // Variable numerica a calular la media movil
		[,LAgs(integer 3) //Numero de periodos a considerar para el calculo
		Replace]; // Determina si se reemplaza o no la variable
	#delimit cr
	
	// Deja las observaciones que se utilizaran
	if length("`if'") != 0 {
		tempvar marca
		tempfile nousar
		gen `marca' = `if'
		
		preserve
		drop if `marca'
		save `nousar', replace
		restore
		drop if !`marca'
	}
	
	// En el caso de que se especifique replace
	if (length("`replace'") > 0) qui cap drop `newvar'
	
	// Genera variable out
	qui mata: st_addvar("float","`newvar'")
	
	// En el caso de que se especifique el BY (actualmente 1 variable)
	if _by() {
		// Genera distancia maxima por cada by
		tempvar bylength
		qui gen `bylength' = 0

		qui replace `bylength' = min((`bylength'[_n - 1] + 1)*(`_byvars' == `_byvars'[_n - 1]), `lags') if _n != 1
				
		qui mata: st_store(. , "`newvar'", movavgm_by(st_data(.,"`exp'"),`lags', st_data(.,"`bylength'")))		
	}
	// Calcula media movil y guarda el resultado en la variable out
	else {		
		mata: st_store(. , "`newvar'", movavgm(st_data(.,"`exp'"),`lags'))
	}
	
	// Pega no usadas
	if length("`if'") != 0 append using `nousar'
end

cap mata: mata drop movavgm()
mata:
real matrix movavgm(real matrix X, real scalar lags)
// Calcula la media movil para cada una de las columnas de la matriz X para
// lags periodos.
{
	// Definicion de variables a utilzar dentro de la funcion. No es necesa
	// rio definirlas, pero ayuda a la velocidad. (Stata sabra que es cada
	// cosa).
	real matrix Y
	real matrix Z
	real matrix W
	real scalar nrow
	real scalar ncol
	real vector div
	
	// Calcula numero de columnas y de filas
	nrow = rows(X)
	ncol = cols(X)
	
	// En este for se suman replicas de la matriz X desfazadas con la finalidad
	// de aplicar la funcion usando matrices en vez de elemento-elemento. Es mas
	// eficiente computacionalmente.
	Y = X
	for (i=1; i<lags; i++) {
		W = ((1..i):*0)'*((1..ncol):*0)
		// Matriz de suma que cuenta con i primeras filas iguales a 0
		Z = W \ X[1..nrow-i,.]
		Y = Y :+ Z
	}
	
	// Calcula un vector de division que dividira cada fila por el numero corres
	// pondiente de elementos sumados. Para la primera fila sera 1 (pues no habi
	// an antes mas elementos, para la segunda 2 (pues habia uno anterior)... el
	// resto se divide por t
	div = ((1..lags), (1..nrow - lags):*0:+lags)
	
	// Calcula el promedio
	Y = Y :/ div'
	return(Y)
}
end

cap mata: mata drop movavgm_by()
mata:
real matrix movavgm_by(real matrix X, real scalar lags, real vector L)
// Calcula la media movil para cada una de las columnas de la matriz X para
// lags periodos.
{
	// Definicion de variables a utilzar dentro de la funcion. No es necesa
	// rio definirlas, pero ayuda a la velocidad. (Stata sabra que es cada
	// cosa).
	real matrix Y
	real matrix Z
	real matrix W
	real scalar nrow
	real scalar ncol
	
	// Calcula numero de columnas y de filas
	nrow = rows(X)
	ncol = cols(X)
	
	// En este for se suman replicas de la matriz X desfazadas con la finalidad
	// de aplicar la funcion usando matrices en vez de elemento-elemento. Es mas
	// eficiente computacionalmente.
	Y = X

	for (i=1; i<lags; i++) {
		W = ((1..i):*0)'*((1..ncol):*0)
		// Matriz de suma que cuenta con i primeras filas iguales a 0
		Z = W \ X[1..nrow-i,.]
		Y = Y :+ Z:*(i:<=L)
	}
		
	// Calcula el promedio
	Y = Y :/ (L:+1)
	return(Y)
}
end
