program kappaAux, rclass
syntax varlist(min=2) [if] [in] [, Absolute Wgt(string) Majority(integer -1)]		
preserve	
quietly{
	if `"`if'"'!="" | "`in'"!="" { 
			keep `if' `in'
		}
	tokenize `varlist'
	local nvar : word count `varlist'


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Calculamos Xik, es decir, el número de observ que clasifican a la observación i en la categoría k. Para ello, usamos una columna con cada categoría.
	
	// Creo una columna con los desc: "."
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Cálculo de Pj(k)-> Proporción de veces que el observador j clasifica en la categoría k. (No incluyo ".")
// Para ello calculo las frecuencias absolutas y Nj, donde Pj(k)= freq`k'/Nj para cada categoría.
// Calculo matrices donde guardar frecuencias absolutas:
	forvalues j=1(1)`nvar'{
		tempname freq`j'
		tempname freqC`j'
		tab ``j'', matrow(`freqC`j'') // Almacena las distintas calificaciones de cada observador (columna)
		tab ``j'', matcell(`freq`j'') // Almacena la frecuencia de dichas califices en cada observador
	}

	// Rellena la matriz si alguno no tenia ninguna observación: (todos .)
	forvalues j=1(1)`nvar'{
		capture matrix list `freq`j''
		if _rc!=0{
			local globalLocal = "calific1"	
			matrix `freq`j'' = (0)
			matrix `freqC`j'' = ($`globalLocal')
		}
	}

	// Esto lo hago para poder usar la matriz con seguridad. 
	forvalues j=1(1)`nvar'{
		forvalues i=1(1)$total{
			local globalLocal = "calific`i'"
			if $`globalLocal' != `freqC`j''[`i',1] { 
				local n= `i'-1
				if `i'== 1 {  // Si es el primero
					matrix `freq`j'' = (0 \ `freq`j''[`i'...,1])
					matrix `freqC`j'' = ($`globalLocal' \ `freqC`j''[`i'...,1])
				}
				else if `i'> rowsof(`freq`j'') { 	// Si la matriz se queda pequeña
					matrix `freq`j'' = (`freq`j''[1...,1]\0)
					matrix `freqC`j'' = (`freqC`j''[1...,1] \ $`globalLocal')
				}
				else{
					matrix `freq`j'' = (`freq`j''[1..`n',1] \ 0 \ `freq`j''[`i'...,1])
					matrix `freqC`j'' = (`freqC`j''[1..`n',1] \ $`globalLocal' \ `freqC`j''[`i'...,1])	
				}
				
			} // if	
		}
	}

//Calculo el número de observaciones distintas de "." de cada observador/columna	

	forvalues j=1(1)`nvar'{
		local aux=0
		forvalues i=1(1)`auxN'{
			if (``j''[`i'] != .) {
				local aux = `aux' + 1
			}
		}
		if `aux' > 0 {
			matrix `freq`j''= `freq`j''/`aux'		// Solo considero las que son distintas de "."
		}
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

if `majority' == -1{	// EL acuerdo deseado es por pares o ponderado
	tempfile ficheroCompleto
	save `"`ficheroCompleto'"',replace
	tempfile ficheroPesos
	use $fich2,clear
	rename `1' `2'
	cross using $fich2 // Hace todas las permutaciones posibles.
	save `"`ficheroPesos'"',replace				// DOY POR HECHO QUE SE PUEDE QUITAR
	tempname unoAux
	rename `1' `unoAux'	
	rename `2' `1'
	rename `unoAux' `2'
	local r `1'	
	local c `2'	
	tempvar wij ro co ident

	// Adaptado de la macro de kap.ado
	if "`absolute'"=="" {	/* set k1=# of rows, k2=# of cols */
			local k=$total 
		}

	else {
		capture assert `r'==int(`r') &  `r'>=1
		if _rc { 
			di in red /*
			*/ "`r' and `c' not integers 1, ..., K" _n /*
			*/ "this is required when option absolute is specified"
			exit 498
		}
		summ `r'
		local k = r(max)
	}
	sort `r' `c'
	// Si no hay nada uso por defecto la matriz de pesos identidad:

	if "`wgt'"=="" {
		local wgt = "I"
	}

	gen double `ident'=cond(`r'==`c',1,0)

	if "`wgt'"=="I" | "`wgt'"=="" {		
		gen double `wij'=cond(`r'==`c',1,0) 
	}
	else { 
		if "`absolute'"=="" {
			by `r': gen int `co'=_n
			sort `c' `r'
			by `c': gen int `ro'=_n
			sort `r' `c'
		}
		else {
			gen int `ro' = `r'
			gen int `co' = `c'
		}

		if "`wgt'"=="w" { 
			gen double `wij'=1-abs(`ro'-`co')/(`k'-1)
		}
		else if "`wgt'"=="w2" { 
			gen double `wij'=1-((`ro'-`co')/(`k'-1))^2
		}
		else { 

		/*
		    //Mod AZ start
			local wgt_tmp = trim(substr("`wgt'",(strpos("`wgt'"," ")+1),strlen("`wgt'")))
  			local wgt = trim(substr("`wgt_tmp'",1,(strpos("`wgt_tmp'"," ")-1)))			
			//Mod AZ end
		*/
		
			parse "$`wgt'", parse(" ")	
			if "`1'"!="kapwgt" { 
				noisily di in red /*
					*/"kappawgt `1' not found"
				exit 111
			}
			if ("`absolute'"=="" & `2'!=`k') | ("`absolute'"!="" & `2'<`k') {
				noisily di in red "`1' not `k' x `k'"
				exit 198
			}
			gen double `wij'=.
			mac shift 2
			forvalues i=1(1)`k'{
				forvalues j=1(1)`i'{
					replace `wij'=`1' if  (`ro'==`i' & `co'==`j') |  (`ro'==`j' & `co'==`i')
					macro shift
				}
			}
		}
	
		drop `ro' `co'
	}
	if "`wgt'"!="" & "`wgt'"!="I" { 
		`skip'
		local skip "noisily di"
		noisily di in green "Ratings weighted by:"
		local fin=_N 
		forvalues i=1(1)`fin'{	
			noisily di in ye %9.4f `wij'[`i'] _c 
			if `r'[`i']!=`r'[`i'+1] { 
				noisily di 
			} 
		}
	}
	mkmat `wij'
	mkmat `ident'
	use `ficheroCompleto', replace
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Cálculo de Nc para que solo consideremos aquellas observaciones para las que hay más de un observador.

	local Nc1 =0
	forvalues i=1(1)`auxN'{
		if `desc'[`i']  <=  `nvar' - 2{
			local Nc1= `Nc1' + 1
		}
	}

// Calculamos Po para pairwise agreement con y sin matriz de pesos:
	tempname result suma Po1 observ
	scalar `suma'= 0
	scalar `result'= 0
	forvalues i=1(1) `auxN'{
		scalar `observ'= `nvar'-`desc'[`i']  
		if `observ'>1{
			forvalues k=1(1)$total{
				forvalues j=1(1)$total{
					local globalLoc2 = "calific`k'"
					local globalLocal = "calific`j'"
					local indice= `k'*$total-$total+`j'
					scalar `suma'= `suma'+  `calif$`globalLocal''[`i'] * `calif$`globalLoc2''[`i'] * `wij'[`indice',1]
				}
			}
			scalar `suma'= (`suma' - `observ') /  (`observ' * (`observ' - 1))
			scalar `result'= `result' + `suma'
			scalar `suma'=0
		}
	}

	scalar `Po1' = `result'/`Nc1'
	return scalar prop_o= `Po1'
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Cálculo de Pe para pairwise agreement con y sin pesos

// Calculo el producto para mejorar eficiencia.
	tempname peMatriz
	matrix	`peMatriz'=I(`nvar')
	forvalues l=1(1)`nvar'{
		local maux = `l' + 1
		forvalues m = `maux'(1)`nvar'{
			scalar `suma'=0
			forvalues u=1(1)$total{
			 	forvalues k=1(1)$total{	
 					scalar `suma'= `suma'+ (`freq`l''[`u',1]) * (`freq`m''[`k',1]) *  `wij'[`u'*$total-$total+`k',1]  
				}
			}
			matrix `peMatriz'[`l',`m']=`suma'
		}
	}


	// Cálculo de la parte de sumatorio de la fórmula de Pe.

	tempname res2 res3 
	tempname Pe1
	scalar `Pe1'=0
	forvalues p=1(1)`auxN'{
		scalar `observ'= `nvar' - `desc'[`p']
		if `observ' > 1{
			scalar `res3'=0
			forvalues l=1(1)`nvar'{
				if ``l''[`p'] != . {
					scalar `res2'=0
					local maux = `l' + 1
					forvalues m = `maux'(1)`nvar'{
						if ``m''[`p'] != .{
							scalar `res2'= `res2'+`peMatriz'[`l',`m']
						} // if
					}
					scalar `res3'= `res3' + `res2'
				} 
			}			
			scalar `Pe1'= `Pe1' + (2 / (`observ' * (`observ' - 1)))* `res3'
		}	
	}
  
	scalar `Pe1' = (`Pe1')/`Nc1'
 	return scalar prop_e = `Pe1'
	return scalar kappa = (`Po1'-`Pe1')/(1-`Pe1')
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
} // si majority == -1
				
else {	
// ACUERDO POR MAYORIA
// Cálculo de Nc
	tempname Nc
	scalar `Nc'=0
	forvalues i=1(1)`auxN'{
		if `desc'[`i']  <=  `nvar' - `majority'{
			scalar `Nc'= `Nc' + 1
		}
	}

// Cálculo de PO:

	tempname cont
	tempname totalZ
	scalar `totalZ'=0
	forvalues i=1(1)`auxN'{
		scalar `cont'=0
		forvalues j=1(1)$total{
			local globalLocal = "calific`j'"
			if `calif$`globalLocal''[`i'] >= `majority' { 
				scalar `cont'=1 		
			}
		}
		scalar `totalZ'= `totalZ'+`cont'
	}
	tempname Po1
	scalar `Po1'= `totalZ' / `Nc'		
	return scalar prop_o = `Po1'		
	merge using `"$fPermutacion"'
	

// Calculamos una matriz inversa para ver situacion de las frecuencias.
	tempname inversa
	matrix `inversa' =  `freqC1'
	local contm = rowsof(`freqC1')
	local stringm = ""
	forvalues i=1(1)`contm'{
		local aux= `freqC1'[`i',1]
		local stringm = " `stringm' `aux' " 
	}		
	matrix rownames `inversa' = `stringm'


// Cálculo de Pe
	tempname Pe1
	scalar `Pe1'=0
	tempname producto
	forvalues i=1(1)`auxN'{
		local observados = `nvar' - `desc'[`i']
		if `observados' >= `majority'{
				local recPerm=1 //recorrido de dentro de la  permutacion
				local nObs= "numero`observados'"
				forvalues recPerm=1(1) $`nObs'{	
					scalar `producto'=1
					local despfila=0
					forvalues j=1(1)`nvar'{
						if ``j''[`i']!=. {
							local despfila=`despfila'+1
							local auxind = ``despfila''x`observados'[`recPerm']
							local indice = rownumb(`inversa', "`auxind'")
							scalar `producto'=`producto'* (`freq`j''[    `indice' ,1]) 
						}
					}

					scalar `Pe1' = `Pe1' + `producto'
				}
		}
	}
	scalar `Pe1'= `Pe1'/`Nc'
	return scalar prop_e = `Pe1'
	local kappa= (`Po1'-`Pe1')/(1-`Pe1')
	return scalar kappa= `kappa'
 } // if majority!=-1


} // quietly

end

