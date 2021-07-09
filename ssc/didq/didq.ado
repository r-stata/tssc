*! version 1.5 17Sep2015
*! authors Ricardo Mora & Iliana Reggio

// V 1.5 correction: cambiamos el nombre del comando a requerimiento de Stata Journal
// V 1.4 correction: convertimos el ado en un eclass file, ponemos labels en las headings de r(beta)
// V 1.3 correction: introducimos opciones Auxiliary y FORCE
// V 1.2 correction: s=s-1 tests, all tests checked with command test
// to do:
// nodynamics option: effect is constant throughout all post-treatment period
// estimations with a range of Parallel-q assumptions

program didq, eclass byable(recall) 
	version 10.1
quietly {
	syntax [varlist(default=none)] [if] [in] [aw fw iw pw],		///
                                         TReated(varname)                       ///
                                         Time(varname)                          ///
					 [					///
                                         Begin(integer 2147483620)	        ///
                                         End(integer  -2147483647)              ///
                                         Q(integer -99)				///
                                         detail					///
					 FF					///
					 STandard				///
                                         LInear					///
					 QUadratic				///
					 CLUSTER(varname) 			///
					 Level(real 95)				///
					 Auxiliary				///
					 FORCE					///
					 ]
	marksample touse
	tempname Post PostD trendD quadD I DIb DIo DIa alpha std_alp tests p_tests p rf info b V cols_a cols_b common beta Vbeta

	if ("`varlist'" == "") {
                  di as err "you must specify a dependent variable"
                  exit 301
            }
        if (`level'>=100 | `level'<=0) {
                  di as err "level must be a percentage"
                  exit
            }
	gettoken depvar controls : varlist

	// depvar must be numeric
	capture confirm numeric `depvar'
                if _rc==7 {
        	di as err "`depvar' must be numeric"
		exit
   		}
	// controls must be numeric
	if "`controls'"!=""{
	foreach v of varlist `controls'    {
		capture confirm numeric `v'
	                if _rc==7 {
	        	di as err "`v' must be numeric"
			exit
   			}
		}
	}

	// time must be integer
	capture confirm numeric variable `time'
                if _rc==7 {
        	di as err "`time' must be integer"
		exit
   		}
	capture confirm byte variable `time'
                if _rc==7 {
		capture confirm int variable `time'
        	        if _rc==7 {
			capture confirm long variable `time'
		                if _rc==7 {
		        	di as err "`time' must be integer"
				exit
	   			}
	   		}
   		}

	// min, max, & begin-end options	
	qui sum `time' if `touse'
		local min=r(min)
		local max=r(max)
	if "`begin'"=="2147483620" & "`end'"=="-2147483647" {
		local begin=`max'
		local end=`max'
		}
	if "`begin'"=="2147483620" & "`end'"!="-2147483647" {
		local begin=`end'
		}
	if "`begin'"!="2147483620" & "`end'"=="-2147483647" {
		local end=`begin'
		}
	// min(time)< begin <= end <= max(time)
	if `min' >= `begin'{
        	di as err "min(`time') must be smaller than BEGIN"
		exit
   		}
	if `begin' > `end' {
        	di as err "END must be at least equal than BEGIN"
		exit
		}
	if `end'>`max' {
        	di as err "max(`time') must be at least equal to END"
		exit
		}
	// diff debe tomar valores entre 1 y el numero de periodos antes del tratamiento: begin - min(time)
		local t0=`begin'-`min'
		local diff=`q'
		if `t0'<`diff'  | `diff'< 0 {
			di in g _col(10) "q must be between 1 and `t0'." _newline _col(10) "Set q=`t0'"
			local diff = `t0'
			}
	// only one model may be specified
	local case : word count `ff' `standard' `linear' `quadratic'
	if `case' >1 {
                  di as err "only one model may be specified"
                  exit 498
	}
	local model "`standard'`linear'`quadratic'"
	if "`model'"!="" & "`detail'"!="" {
                noi di as txt "option {it:detail} only relevant for {it:ff} option"
		local detail ""
		}
	// treated dummy 0 y 1
	qui inspect `treated'  if `touse'
		if r(N_unique)!=2 {
        	di as err "`treated' must be binary"
		exit
		}
		if r(N_0)==0 {
        	di as err "`treated' has no zeros"
		exit
		}
	qui count if `treated'==1 & `touse'
		if r(N)==0 {
	       	di as err "`treated' has no ones"
		exit
		}
	// Model selection
	gen `Post'=`time'>=`begin' & `time'<=`end'
	gen `PostD'=`treated'*`Post'
	gen `trendD'=`treated'*`time'
	gen `quadD'=`treated'*(`time')^2
	local rango = `max'-`min'+1
	forvalues indice = 1/`rango' {
		local anyo=`min'+`indice'-1
		if `indice'> 1 {
			gen `I'`indice'=`time'==`anyo'
			local Is="`Is' I`anyo'"
			if `anyo'<`begin' {
				gen `DIb'`indice'= `treated'*`I'`indice'
				local DIbs="`DIbs' `treated'xI`anyo'"
			}
			if `anyo'>=`begin' & `anyo'<=`end'{
				gen `DIo'`indice'= `treated'*`I'`indice'
				local DIos="`DIos' `treated'xI`anyo'"
			}
			if `anyo'>`end'{
				gen `DIa'`indice'= `treated'*`I'`indice'
				local DIas="`DIas' `treated'xI`anyo'"
			}
		}
	}
	// lista de variables
		// más de un periodo antes, al menos un periodo después
		if `end'<`max' & `min'<`begin'-1 {
			local lista = "`depvar' `DIb'* `DIo'* `treated' `I'* `DIa'*"
			local var_names = "`DIbs' `DIos' `treated' `Is' `DIas'"
			}
		// más de un periodo antes, ningún periodo después
		if `end'==`max' & `min'<`begin' -1 {
			local lista = "`depvar' `DIb'* `DIo'* `treated' `I'*"
			local var_names = "`DIbs' `DIos' `treated' `Is'"
			}
		// un periodo antes, ningún periodo después
		if `end'==`max' & `min'==`begin'-1 {
			local lista = "`depvar' `DIo'* `treated' `I'*"
			local var_names = "DIos' `treated' `Is'"
			}
		// un periodo antes, al menos un periodo después
		if `end'<`max' & `min'==`begin' -1 {
			local lista = "`depvar' `DIo'* `treated' `I'* `DIa'*"
			local var_names = "`DIos' `treated' `Is' `DIas'"
			}
	// standard errors
	if "`cluster'"=="" local rob "robust"
	else local rob "vce(cluster `cluster')"

	// Flexible Model
	reg `lista' `controls' if `touse', `rob'
	local var_names = "`var_names' `controls' _cons"
	mat define cols_b=colsof(e(b))
	if e(rank)<cols_b[1,1] & "`force'"!="force" {
		di as err "X'X matrix in auxiliary regression not invertible"
		exit
		}
	matrix define `b'=e(b)
	matrix define `V'=e(V)
        matrix rownames `V' = `var_names'
        matrix colnames `V' = `var_names'
        matrix colnames `b' = `var_names'
        matrix rownames `b' = `depvar'
	noi mata: _didq(`begin',`end',`diff',`t0',"`alpha'","`std_alp'", "`tests'","`p_tests'", )
		local cols_a=colsof(`alpha')
		matrix `alpha'[1,`cols_a'-1]=`tests'[1,1]
		matrix `std_alp'[1,`cols_a'-1]=`p_tests'[1,1]
	// Standard Models	
	local cols_a = colsof(`alpha')
	if "`model'" == "standard" {
			reg `depvar' `PostD' `treated' `I'* `controls' if `touse', `rob'
			local var_names = "Postx`treated' `treated' `Is' `controls' _cons"
			matrix define `b'=e(b)
			matrix define `V'=e(V)
		        matrix rownames `V' = `var_names'
		        matrix colnames `V' = `var_names'
		        matrix colnames `b' = `var_names'
		        matrix rownames `b' = `depvar'
			matrix define `alpha'=_coef[`PostD'],`tests'[1,1]
			matrix define `std_alp'=_se[`PostD'],`p_tests'[1,1]
			// standard with flexible dynamics
			reg `depvar' `DIo'* `treated' `I'* `controls' if `touse', `rob'
			// testing flexible dynamics
			local rango = `max'-`min'+1
			forvalues indice = 1/`rango' {
				local anyo=`min'+`indice'-1
				if `indice'> 1 {
					if `anyo'>=`begin' & `anyo'< `end'{
						local indice1= `indice' + 1
						test `DIo'`indice'= `DIo'`indice1', accumulate
						}
					}
				}
				scalar `rf'=r(F)
				scalar `p'=chi2tail(r(df),r(F))
				if `rf'==. scalar `rf'=0
				matrix define `alpha'=`alpha',`rf'
				matrix define `std_alp'=`std_alp',`p'
			}

	if "`model'" == "linear" {
			reg `depvar' `PostD' `trendD' `treated' `I'* `controls' if `touse', `rob'
			local var_names = "Postx`treated' trendx`treated' `treated' `Is' `controls' _cons"
			matrix define `b'=e(b)
			matrix define `V'=e(V)
		        matrix rownames `V' = `var_names'
		        matrix colnames `V' = `var_names'
		        matrix colnames `b' = `var_names'
		        matrix rownames `b' = `depvar'
			matrix define `alpha'=_coef[`PostD'],`tests'[2,1]
			matrix define `std_alp'=_se[`PostD'],`p_tests'[2,1]
			// linear with flexible dynamics
			reg `depvar' `DIo'* `trendD' `treated' `I'* `controls' if `touse', `rob'
			// testing flexible dynamics
			local rango = `max'-`min'+1
			forvalues indice = 1/`rango' {
				local anyo=`min'+`indice'-1
				if `indice'> 1 {
					if `anyo'>=`begin' & `anyo'< `end'{
						local indice1= `indice' + 1
						test `DIo'`indice'= `DIo'`indice1', accumulate
						}
					}
				}
				scalar `rf'=r(F)
				scalar `p'=chi2tail(r(df),r(F))
				if `rf'==. scalar `rf'=0
				matrix define `alpha'=`alpha',`rf'
				matrix define `std_alp'=`std_alp',`p'
			}


	if "`model'" == "quadratic" {
			reg `depvar' `PostD' `trendD' `quadD' `treated' `I'* `controls' if `touse', `rob'
			local var_names = "Postx`treated' trendx`treated' trend2x`treated' `treated' `Is' `controls' _cons"
			matrix define `b'=e(b)
			matrix define `V'=e(V)
		        matrix rownames `V' = `var_names'
		        matrix colnames `V' = `var_names'
		        matrix colnames `b' = `var_names'
		        matrix rownames `b' = `depvar'
			matrix define `alpha'=_coef[`PostD'],`tests'[3,1]
			matrix define `std_alp'=_se[`PostD'],`p_tests'[3,1]
			// quadratic with flexible dynamics
			reg `depvar' `DIo'* `trendD' `quadD' `treated' `I'* `controls' if `touse', `rob'
			// testing flexible dynamics
			local rango = `max'-`min'+1
			forvalues indice = 1/`rango' {
				local anyo=`min'+`indice'-1
				if `indice'> 1 {
					if `anyo'>=`begin' & `anyo'< `end'{
						local indice1= `indice' + 1
						test `DIo'`indice'= `DIo'`indice1', accumulate
						}
					}
				}
				scalar `rf'=r(F)
				scalar `p'=chi2tail(r(df),r(F))
				if `rf'==. scalar `rf'=0
				matrix define `alpha'=`alpha',`rf'
				matrix define `std_alp'=`std_alp',`p'
			}
	count if `touse'	
	matrix `info' = (`min',`max',`begin',`end', r(N))
	noi _didq_out, alp(`alpha') stdalp(`std_alp') cluster(`cluster') model(`model')  ///
		controls(`controls') output(`depvar') info(`info') `detail' level(`level')
	local cols_a=colsof(`alpha')
	if "`model'"=="" {
		matrix define `tests'=`alpha'[.,`cols_a'-1..`cols_a']
		matrix define `p_tests'=`std_alp'[.,`cols_a'-1..`cols_a']		
		matrix define `tests'[1,1]=.
		matrix define `p_tests'[1,1]=.
		}
	else {
		matrix define `tests'=`alpha'[.,`cols_a'..`cols_a']
		matrix define `p_tests'=`std_alp'[.,`cols_a'..`cols_a']		
	}
	matrix define `common' =`alpha'[1,`cols_a'-1]
	matrix define `std_alp'=`std_alp'[.,1..`cols_a'-2]
	matrix define `alpha'=`alpha'[.,1..`cols_a'-2]
	matrix define `beta'=`b'
	matrix define `Vbeta'=`V'
	if "`auxiliary'"=="auxiliary" {
	        ereturn post `beta' `Vbeta'
		noi display _newline as txt _col(5) "Auxiliary regression"
		noi ereturn display
		}
	ereturn clear
	ereturn scalar N =`info'[1,5]
	ereturn scalar common_trend =`common'[1,1]
	ereturn matrix p_values = `p_tests'
	ereturn matrix tests = `tests'
	ereturn matrix Vbeta = `V'
	ereturn matrix beta = `b'
	ereturn matrix std_alpha = `std_alp'
	ereturn matrix alpha = `alpha'
	}
end

capture program drop _didq_out
program define _didq_out
	version 10.0
quietly {
	syntax  , ALP(string) STDALP(string) 				 	///
		[detail CLUSTER(string) Model(string) Controls(string)] 		///
		OUTPUT(string)							///
		INFO(string) Level(real)
		tempname b V 
		local periodos= string(`info'[1,1]) + ":" + string(`info'[1,2])
		local cols_a = colsof(`alp')
		local rows_a = rowsof(`alp')
	        if ("`controls'" != "" ) noi dis _col(5) as txt "Conditional " _continue
	        if ("`controls'" == "" ) noi dis _col(5) as txt "Unconditional " _continue
	        if ("`model'" == "" ) noi dis as txt "Fully Flexible Model" 
	        if ("`model'" == "standard" ) noi dis as txt "Standard Model"
	        if ("`model'" == "linear" ) noi dis as txt "Linear Trend Model"
	        if ("`model'" == "quadratic" ) noi dis as txt "Quadratic Trend Model"
		noi dis _col(5) as txt "Output: " in y "`output'"  _continue
		noi dis _col(57) as txt "Number of obs ="  %7s in y string(`info'[1,5],"%7.0f")
		noi dis _col(5) as txt "Sample Period: " in y "`periodos'" _continue
		noi dis _col(47) as txt "H0: Common Pre-dynamics = "  _continue 
		if `alp'[1,`cols_a'-1]!=0 noi dis %~7s in y string(`alp'[1,`cols_a'-1],"%7.4g") _continue
		if `alp'[1,`cols_a'-1]==0 noi dis %~7s in y "  n/a" _continue
		noi dis _newline _col(5) as txt "Treatment Period: " in y `info'[1,3] ":" `info'[1,4] _continue
		if `alp'[1,`cols_a'-1]!=0 {
			noi dis _col(63) as txt "p-value = "  _continue
			noi dis %~7s in y string(`stdalp'[1,`cols_a'-1],"%7.4g") _continue
		}

		// Wide format
		if "`detail'"=="" {
		local range=min(3,`cols_a'-2)
		
		noi dis _newline in g "{hline 13}{c TT}{hline 64}"
		noi dis _col(14)"{c |}" _continue
		local en = 21
			forval j=1(1)`range' { 	
				if "`model'"=="" if `j'<=`range' noi dis as txt _col(`en') "s=`j'" _continue
				else noi dis as txt _col(`en') "All s" _continue
				local en = `en' + 11
			}
		if "`model'"=="" noi dis as txt _col(57) " H0: q=q-1" _continue
		noi dis as txt _col(69) " H0: s=s-1" 
		noi dis "{hline 13}{c +}{hline 64}" _continue
		forval i=1(1)`rows_a' { 	
			if "`model'"=="" noi dis _newline _col(10) in g "q=`i'" _col(14) "{c |}" _continue
			else noi dis _newline _col(7) in g "All q" _col(14) "{c |}" _continue
			local en = 18			
			forval j=1(1)`range' { 	
				noi dis in y _col(`en') %~9s string(`alp'[`i',`j'],"%9.0g") _continue
				local en = `en' + 11
			}
			if `i'>1 noi dis in y _col(58) %~9s string((`alp'[`i',`cols_a'-1]),"%9.0g") _continue
			if `alp'[`i',`cols_a']!=0 noi dis in y _col(71) %~9s string(`alp'[`i',`cols_a'],"%9.0g") _continue
			else noi dis in y _col(71) %~9s "n/a" _continue
			noi dis _newline in g _col(14) "{c |}" _continue
			local en = 18
			forval j=1(1)`range' { 	
				noi dis in y _col(`en') "(" %~6s string(`stdalp'[`i',`j'],"%6.4f") ")" _continue
				local en = `en' + 11
			}
			if `i'>1 noi dis in y _col(58) "[" %~5s string(`stdalp'[`i',`cols_a'-1],"%5.4f") "]" _continue
			if `alp'[`i',`cols_a']!=0 noi dis in y _col(71) "[" %~5s string(`stdalp'[`i',`cols_a'],"%5.4f") "]" _continue
			local i=`i'+1
		}
		noi dis _newline in g "{hline 13}{c BT}{hline 64}"	
		if "`cluster'"=="" noi dis as txt _col(5) "Robust Standard Errors in parenthesis" 
		if "`cluster'"!="" noi dis as txt _col(5) "Std. Err. in parenthesis adjusted for clusters in " in y "`cluster'" 
		if (`rows_a'>1 | `alp'[1,`cols_a']!=0 ) noi dis as txt _col(5) "p-values in brackets"
		}
		// Long format
		else {
		noi dis _newline
		if `rows_a'>1 {
		noi dis _newline as txt _col(30) " H0: q=q-1" _col(60) " H0: s=s-1"
		noi dis in g "{hline 13}{c TT}{hline 64}"
		noi dis as txt _col(14)"{c |}" _col(28) "z" _col(38) "P>|z|" _col(58) "F" _col(68) "Prob>F" 		 
		noi dis "{hline 13}{c +}{hline 64}" _continue
		forval i=1(1)`rows_a' { 	
			noi dis _newline _col(10) in g "q=`i'" _col(14) "{c |}" _continue
			if `i'>1 {
				noi dis in y _col(24) %~9s string(`alp'[`i',`cols_a'-1],"%9.0g") _continue
				noi dis in y _col(36) %~9s string(`stdalp'[`i',`cols_a'-1],"%9.0g") _continue
			}
			if (`cols_a'>3) & ((`info'[1,3]-`info'[1,1])>(`i'-1)) {			
				noi dis in y _col(54) %~9s string(`alp'[`i',`cols_a'],"%9.0g") _continue
				noi dis in y _col(66) %~9s string(`stdalp'[`i',`cols_a'],"%9.0g") _continue
			}
			if "`model'"!="" & (`alp'[`i',`cols_a']!=0) {			
				noi dis in y _col(54) %~9s string(`alp'[`i',`cols_a'],"%9.0g") _continue
				noi dis in y _col(66) %~9s string(`stdalp'[`i',`cols_a'],"%9.0g") _continue
			}
			local i=`i'+1
		}
		noi dis _newline in g "{hline 13}{c BT}{hline 64}"
		}
	
		local cols_b = `cols_a'-2
		local cols_b = `cols_a'-2		
		mat define `b'=J(1,`cols_b',0)
		mat define `V'= I(`cols_b')
		forval j=1(1)`cols_b'{ 	
			local list_names = "`list_names' " + "s=`j' "
		}

		forval i=1(1)`rows_a'{
			noi dis _newline as txt _col(2) " Parallel-`i'"
			mat define `b'_eq`i' =`alp'[`i',1..`cols_b']
			mat define `V'_eq`i' = I(`cols_b')
			forval j=1(1)`cols_b'{ 	
				mat `V'_eq`i'[`j',`j']=(`stdalp'[`i',`j'])^2
			}
			mat colnames `b'_eq`i' = `list_names'
			mat colnames `V'_eq`i' = `list_names'
			mat rownames `V'_eq`i' = `list_names'
			ereturn post `b'_eq`i' `V'_eq`i'
			noi ereturn display, level(`level')
		}
		if "`cluster'"=="" noi dis as txt _col(5) "Robust Standard Errors" 
		if "`cluster'"!="" noi dis as txt _col(5) "Std. Err. adjusted for clusters in " in y "`cluster'" 
		}
	// variable names in e() matrices
	local cols_a_2=`cols_a'-2
	forval j=1(1)`cols_a_2' { 	
		if "`model'"=="" local colnames_alpha = "`colnames_alpha' s=`j'"
		else local colnames_alpha = "All"
	}
	if "`model'"=="" local colnames_alpha = "`colnames_alpha' q=q-1"
	local colnames_alpha = "`colnames_alpha' s=s-1"
	forval i=1(1)`rows_a' { 	
		if "`model'"=="" local rownames_alpha = "`rownames_alpha' q=`i'"
		else local rownames_alpha = "All"
	}
	matrix rownames `alp' = `rownames_alpha'
	matrix rownames `stdalp' = `rownames_alpha'
	matrix colnames `alp' = `colnames_alpha'
	matrix colnames `stdalp' = `colnames_alpha'
	}		
end

********************************************** mata *******************************************************
//cap mata: mata drop _didq_s() _didq()
mata

        void _didq_alphaqs(numeric scalar s, numeric scalar q, numeric vector g , numeric matrix V, numeric scalar a, numeric scalar std, numeric vector delta)
        {
	        real matrix DELTA, deltaS_ast,delta1,coef_a, lt_1
		real scalar deltaq1

		// alpha(q,s)=delta^(q-1)*SUM_{j=1}^{S}(a_sj)*delta_j*g_{t*+j}
		// alpha(q,s)=vec_asj * DELTA * g
		// vec_asj is 1xs vector
		// DELTA is sx(q+s) matrix, each row j containing in the first (q+j) columns the operator
		// 			delta^{q-1}*delta_j
		// g is (q+s)x1 vector of gamma coefficients, last one is gamma_{t*+s}

		// we move down DELTA computing the operators (going from s_ast=1 to s_ast=s-1)
		// when s_ast=s, we compute the last operator and vec_asj

		DELTA = J(s,q+s,0)
		for (s_ast=1; s_ast<=s; s_ast++) {
		deltaS_ast=((-1)*I(q),J(q,s_ast,0))+(J(q,s_ast,0),I(q))
		delta1=(J(1,q+s_ast,0))\((-1)*I(q+s_ast-1),J(q+s_ast-1,1,0))+(J(q+s_ast-1,1,0),I(q+s_ast-1))
		if (s_ast==s) {
			coef_a=I(s)
			lt_1=lowertriangle(J(s,s,1))
			}
			deltaq1=1
			for (i=1; i<=q-1; i++) {
				deltaq1=delta1*deltaq1
			if (s_ast==s) coef_a=coef_a*lt_1
			}
			delta=deltaS_ast*deltaq1
			DELTA[s_ast,1::cols(delta)]=delta[rows(delta),.]
		}  			
		delta=coef_a[rows(coef_a),.]*DELTA
		delta=delta[rows(delta),.]
		a=delta*g[rows(g)-cols(delta)+1::rows(g)]
		std=sqrt(delta*V[rows(g)-cols(delta)+1::rows(g),rows(g)-cols(delta)+1::rows(g)]*delta')
        }

        void _didq(numeric scalar inicio, numeric scalar fin, numeric scalar diff, numeric scalar t0,          ///  
		string scalar a_s, string scalar std_a_s, string scalar t_s, string scalar p_t_s)
        {
	        real matrix V, Var_g, alpha, std_alp, tests, p_tests, R, deltaS_ast,delta1,coef_a, lt_1, delta
		real vector b,gamma
		real scalar S,q,s,a,std,s2,s_ast,deltaq1,rgamma,min_t03
		b=st_matrix("e(b)")
		V=st_matrix("e(V)")
		S = fin-inicio+1
		alpha=J(diff,S+2,0)
		std_alp=J(diff,S+2,0)
		for (q=diff; q>=1; q--) {
		for (s=S; s>=1; s--) {
			gamma=0\b[1::t0+s-1]'
			Var_g=J(1,t0+s,0)\J(t0+s-1,1,0),V[1::t0+s-1,1::t0+s-1]
	        	_didq_alphaqs(s,q,gamma,Var_g,a=.,std=.,delta1=.)
			if (s<S) {
				delta1=delta1,J(1,S-s,0) 
				}
			if (cols(delta1)<t0+S) {
				delta1=J(1,t0+S-cols(delta1),0),delta1
				}

			if (s==S) {
			deltaS_ast=delta1
			}
			else {
				if (s==S-1) {
					R=(deltaS_ast-delta1)
				}
				else {
					R=R\(deltaS_ast-delta1)
				}
			}
			alpha[q,s]=a
			std_alp[q,s]=std
			}
		// standard dynamics for each q: Matrix versions of Wald statistics
		// los p-values van a la última columna de std_alp
		// (Rβ − r)'(RVR')^-1 ( Rβ − r ) 
		if (S>1) {
			gamma=0\b[1::t0+S-1]'
			Var_g=J(1,rows(gamma),0)\(J(rows(gamma)-1,1,0),V[1::t0+S-1,1::t0+S-1])
			F=(R*gamma)'cholinv(R*Var_g*R')*(R*gamma)
			alpha[q,cols(alpha)]=F
			std_alp[q,cols(alpha)]=chi2tail(rows(R),F)
			}
		}
		// equivalence tests		
		if (t0>1) {
		for (q=diff; q>=2; q--) {
			gamma=0\b[1::t0-1]'
			Var_g=J(1,t0,0)\J(t0-1,1,0),V[1::t0-1,1::t0-1]
		        _didq_alphaqs(1,q-1,gamma,Var_g,a=.,std=.,delta1=.)
			alpha[q,cols(alpha)-1]=a
			std_alp[q,cols(alpha)-1]=2*(1-normal(abs(a)/std))			
			}
		}
		// parallel-q and above tests
		tests=J(3,1,0)
		p_tests=J(3,1,0)
		// test for the simultaneous equivalence of Parallel−(q,S) and beyond, where q=1,2,3 (whenever possible)
		b=0,b
		V=J(1,cols(V)+1,0)\(J(cols(V),1,0),V)
		min_t03=min((t0-1,3))
			gamma=b[2::t0]'
			Var_g=V[2::t0,2::t0]
			rgamma=rows(gamma)-1
			delta1=(J(1,rgamma+2,0))\((-1)*I(rgamma+1),J(rgamma+1,1,0))+(J(rgamma+1,1,0),I(rgamma+1))
			for (q=1; q<=min_t03; q++) {
				deltaq=1
				for (i=1; i<=q; i++) {
					deltaq=delta1*deltaq
					}
				R=deltaq[q+1::rows(deltaq),2::cols(deltaq)]
				F=(R*gamma)'cholinv(R*Var_g*R')*(R*gamma)
				tests[q,1]=F
				p_tests[q,1]=chi2tail(rows(R),F)
			}
	st_matrix(a_s,alpha)
	st_matrix(std_a_s,std_alp)
	st_matrix(t_s,tests)
	st_matrix(p_t_s,p_tests)
       }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
end
// **************************************** end of mata ******************************************************

