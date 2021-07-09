*! version 0.0 updated 02-March-2017
// Update by Marcelo Tyszler (tyszler.jobs@gmail.com):
// 
// Post-estimation function for reg_sandwich
//

capture program drop test_sandwich
program define test_sandwich, eclass byable(recall) sortpreserve
	version 14.2 
	

    set type double
    syntax [varlist(default=none)], [cons]
	
	tempname cluster_list
	
	tempvar Fconstant ///
			 clusternumber ///
			 temp_Ftest ///
			 selectvar ///
			 Q_Ftest

	*verify that this is run after reg_sandwich:

	if e(cmd) !="reg_sandwich" {
		display as error "{it:test_sandwich} can only be used after {it:reg_sandwich}"
		error 301
		exit
	}
	
	* create placeholder for mata selection
	qui: gen `selectvar'=.
	
	* F-test:
	* 
	* The Q statistic needs the definition of C matrix and a c vector
	*
	* p is the number of coefficients (including the constant)
	* q is the number of coefficients to be tested (1 <= q <= p)
	*
	* C is the contrast matrix (q x p) such that:
	*  H0: Cb = c
	*  For example for the test beta_s = 0, would have q=1,  c = 0 and C = [ 0 .. 1 .. 0], where entry s (between 1 and p) is 1 and 0 otherwise
	* 
	*  For the F-test, C will be a (q x p) matrix where entry rs (1 <= r <= q and 1 <= s <=p) will be 1 and 0 otherwise
	*  and c will be a (q x 1) vector of 0s
	*
	*  For example if p = 3, an F test of beta_1 = beta_3 = 0 would have c = [0 0]' and C = [1 0 0; 0 0 1]
		
	
	*count coefficients to be tested, 
	* Simultaneously check if they belong to the list of original coefficients
	*load original variables:
	local x = e(indepvars) 
	local type_VCR = e(type_VCR)
	local constant_used = e(constant_used)
	
	local q_Ftest = 0
	capture confirm existence `varlist' 
	if _rc != 6 {
		foreach current_x in `varlist' {
			* verify coefficient is in the original list
			if strpos("`x'","`current_x'")==0{
				display as error "F-test error: {it:`current_x'} does not belong to the list of coefficients from the {it:robumeta} estimation"
				error 101
				exit
			}
			
			local ++q_Ftest
		}
	}
	* verify constant term:
	* remove leading and trailing whitespace
	if "`cons'" != "" {
		if "`constant_used'" == "0" {
			display as error "Constant was not included in the estimation. It cannot be included in the tests."
			error 101
			exit
		}
		* increment q:
		local ++q_Ftest
	}
	
	* Define C
	local p = 0
    foreach v in `x' {
        local ++p
    }
	
	if "`constant_used'" == "1" {
		* increment q:
		local ++p
	}
	
	matrix `temp_Ftest' = J(1, `p', 0) // C is initialized as a 1 x p matrix of zeros
	mata: C_Ftest = J(`q_Ftest', `p', 0) // C is initialized as a q x p matrix of zeros
	
	if "`constant_used'" == "1" {
		matrix colnames `temp_Ftest' = `x' _cons
	}
	else {
		matrix colnames `temp_Ftest' = `x' 	
	}
	
	local current_row = 1
	capture confirm existence `varlist' 
	if _rc != 6 {
		* for each var listed in ftest, check which column it corresponds to
		foreach current_q in `varlist'{
			local coln = colnumb(`temp_Ftest',"`current_q'")
			mata: C_Ftest[`current_row', `coln'] = 1
			local ++current_row
		}
	}
	
	* If option constant is active, last column needs to be active:
	if "`cons'" != "" {
		mata: C_Ftest[`current_row', `p'] = 1
		local ++current_row
	}
	mata : C_Ftest = sort(C_Ftest, -1..-`p')
	
    * F-test:
	* 
	* To compute the degress of freedom we need P:
	* Psi = (I-Hx)i'*Ai*Wi*Xi*M*C*gs
	*
	* These matrices are needed to compute the terms Psi'*Theta*Ptj:
	*  gs'*C'*M*Xi'*Wi*Ai*(I-Hx)i*Theta*(I-Hx)j'*Aj*Wj*Xj*M*C*gt
	*
	* We saved the "middle" portion, which is independent of C and gs:
	* 
	* Using the fact that Hx = X*M*X'W and
	* (I-X*M*X'*W)i*T*(I-X*M*X'*W)j' = 
	*
	* if i==j
	* Tj - Tj*(Wj*Xj*M*Xj') - (Xj*M*Xj'*W)*Tj + Xj*(M*X'*W*V*W*X*M)*Xj' 
	*
	* For OLS this simplifies to:
	* Tj - Xj*M*Xj'
	*
	* For WLSp, this simplifies to (Dj = I):
	* Tj - Wj*Xj*M*Xj' - Xj*M*Xj'Wj + Xj'MXWWXM*Xj'
	*
	* For WLSa, this simplified to:
	* Tj - Xj*M*Xj
	* 
	*
	* and we call M*Xi'*Wi*Ai*(I-Hx)i*Theta*(I-Hx)j'*Aj*Wj*Xj*M:
	* Pi_Theta_Pi_relevant
	*
	*
	* if i!=j
	* - Ti*Wi*Xi*M*Xj'   - Xi*M*Xj'*Wj*Tj     + Xi*(M*X'*W*T*W*X*M)*Xj'
	*
	* For OLS this simplifies to:
	* - Xi*M*Xj'
	*
	* For WLSp, this simplifies to:
	* - Wi*Xi*M*Xj'   - Xi*M*Xj'*Wj     + Xi*(M*X'*W*W*X*M)*Xj'
	*
	* For WLSa, this simplified to:
	* - Xi*M*Xj' 
	*  
	* For OLS and WLSa we call M*Xi'*Wi*Ai*Xi:
	* Pi_relevant (and ignore the (min) sign, since it will be cancelled out after multiplication)
	*
	* For WLSp we call  M*Xi'*Wi*Ai
	* Pi_Pj_relevant, (this is more efficient to save)
	* 
	* and additionally save M*Xi'*Wi*Ai as PPi
	
	*
	
	local m = e(N_clusters)
	
	if "`type_VCR'" == "WLSp" {

		if "`constant_used'" == "1" {
			quietly : gen double `Fconstant' = 1 if e(sample)
		}
		
		local cluster = e(clustvar)
		capture confirm numeric variable `cluster'
		if _rc==0 {
			* numeric
		   quietly : gen double `clusternumber' = `cluster' if e(sample)
		}
		else {
			* string
			quietly: encode `cluster' if e(sample), gen(`clusternumber') 
		}
		
		quietly sort `clusternumber' `_sortindex'
		qui: tab `clusternumber' if e(sample), matrow(`cluster_list')

		
		local endi = 0
		
		forvalues i = 1/`m'{
 						
			local starti = `endi'+1
			
			if "`e(absorb)'"~=""{
				qui: sum  `x' if e(sample) & `clusternumber' == `cluster_list'[`i',1]
				local endi  =  `starti' + r(N) -1
				mata: X`i' = Ur[`starti'..`endi',1..`p']
			}
			else {

				qui: replace `selectvar' = e(sample) & `clusternumber' == `cluster_list'[`i',1]
				mata: X`i' = .
				
				if "`constant_used'" == "1" {
					mata: st_view(X`i', ., "`x' `Fconstant'","`selectvar'")
		
				}
				else {
					mata: st_view(X`i', ., "`x'","`selectvar'")
				}
				
				mata: st_local("rows_number", strofreal(rows(X`i')))
				local endi  =  `starti' + `rows_number' - 1
			}
			

			mata: PP`i' = Big_PP[`starti'..`endi',1..`p']
			mata: P`i'_relevant = Big_P_relevant[`starti'..`endi',1..`p']'
		}
		
	} 
	
	mata: Omega_Ftest = C_Ftest*MXWTWXM*C_Ftest'

	* Symmetric square root of the Moore-Penrose inverse of Omega_Ftest
	mata: evecs = .
	mata: evals = .
	mata: symeigensystem(Omega_Ftest, evecs, evals)
	mata: sq_Omega_Ftest =  evecs*diag(editmissing(evals:^(1/2),0))*evecs'
	
	mata: matrix_Ftest = invsym(sq_Omega_Ftest)
	
	mata: st_local("Sum_temp_calc2", test_sandwich_ftests("`type_VCR'", `q_Ftest', `m', `p', Big_PThetaP_relevant,  Big_P_relevant,  MXWTWXM,  matrix_Ftest,  C_Ftest))
	
		
	if "`type_VCR'" == "WLSp" {
		forvalues i = 1/`m'{
	
			mata: mata drop X`i'
			mata: mata drop PP`i'
			mata: mata drop P`i'_relevant
		}
	}
			
	* eta needs to be computed according to equation (14):
	* eta = q*(q+1) / [sum(s=1 to q) sum(t=1 to q) Var(d_st)]
	
	local eta_Ftest = (`q_Ftest'*(`q_Ftest'+1))/`Sum_temp_calc2'
		
	* z = Omega^(-1/2)(Cb-c)
	* D = Omega^(-1/2)*C*VR*C'*Omega^(-1/2)
	* Q = z'inv(D)z (equation 6)
	
	mata: b = st_matrix("e(b)")
	mata: V = st_matrix("e(V)")
	
	mata: z_Ftest = invsym(sq_Omega_Ftest)*(C_Ftest*b')
	mata: D_Ftest = invsym(sq_Omega_Ftest)*C_Ftest*V*C_Ftest'*invsym(sq_Omega_Ftest)
	mata: st_matrix("`Q_Ftest'", z_Ftest'*invsym(D_Ftest)*z_Ftest)
	
	* Now we can compute the F-statistic:
	* (eta - q + 1)/(eta*q) * Q  follows F(q, eta - q + 1) distribution
	local F_stat = ((`eta_Ftest' - `q_Ftest' + 1)/(`eta_Ftest'*`q_Ftest'))* `Q_Ftest'[1,1]
	local F_df1 = `q_Ftest'
	local F_df2 = `eta_Ftest' - `q_Ftest' + 1
	
	local F_pvalue = Ftail(`F_df1',`F_df2',`F_stat')
	
	
	* F-test:
	* display some results
	display in b _newline
	display in b  "Small Sample Corrected F-test:" 
	display _col(10) in b  "F(" as result %5.4f `F_df1' "," as result %5.4f `F_df2' ")" _col(30) "=" _col(35) as result  %5.4f `F_stat'
	display _col(10)  "Prob > F" _col(30) "=" _col(35) as result  %5.4f `F_pvalue'
	
	
	* F-test:
	* save some results
	ereturn scalar F_stat = `F_stat'
	ereturn scalar F_df1 = `F_df1'
	ereturn scalar F_df2 = `F_df2'
	ereturn scalar F_pvalue = `F_pvalue'
	ereturn scalar F_eta = `eta_Ftest'	
	
	
	* Clean:
	mata: mata drop sq_Omega_Ftest
	mata: mata drop C_Ftest
	mata: mata drop D_Ftest
	mata: mata drop Omega_Ftest
	mata: mata drop V
	mata: mata drop b
	mata: mata drop evals
	mata: mata drop evecs
	mata: mata drop matrix_Ftest
	mata: mata drop z_Ftest
	

end
