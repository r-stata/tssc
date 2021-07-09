capture program drop svarsirf
*! svarirf v1.0.0 GImpavido (gimpavido@imf.org) and Li Tang (ltang@imf.org) 25jul2015
program svarsirf, rclass
	version 10.0
	syntax , [STeps(integer 12) NOSE]

************************* Perform user error checks ****************************
	if "`e(cmd)'" != "svar" {
		di as err "svarsirf only works after svar"
		exit 198
	}
	else {
		if "`e(lrmodel)'" != "" {
			di as err "svarsirf only works for short-run model"
			exit 198
		}
		else {
			if "`e(cns_a)'`e(cns_b)'" == "" {
				di as error "cannot find constraints" /*
					*/ "on A and B matrices specified in svar"
				exit 198
			}
		}
	}
************************* pass ingredients to locals ***************************
	
	local names "`e(depvar_var)'"
	local namelist "A0est Best bvarest Vvarest Sigma_AB"
	mat A0est = e(A)
	mat Best = e(B)
	mat bvarest = e(b_var) 
	mat Vvarest = e(V_var)
	mat Sigma_AB = e(V)
	
***************************** run MATA function ********************************	
	
	mata : m_svarsirf("`namelist'", "`names'", "`steps'", "`nose'")

***************************** add matrix headers *******************************	

	local head = head
	matrix colnames SIRF = `head'
	if "`nose'" == "" {
		matrix colnames SIRFSE = `head'
	}

*********************** return MATA results to STATA ***************************	
	return local head = head
	return matrix SIRF = SIRF
	if "`nose'" == "" {
		return matrix SIRFSE = SIRFSE
	}
end	

********************************* start MATA ***********************************
capture mata mata drop m_svarsirf()
version 10.0
mata:
mata set matastrict on
// m_svarsirf v1.0.0 GImpavido (gimpavido@imf.org) and Li Tang (ltang@imf.org) 25jul2015
void m_svarsirf(															 ///
	string scalar namelist, string scalar names, | 							 ///
	string scalar steps, string scalar nose)
{
	string rowvector				AAA, NAM, head, nse
	real rowvector					b_var
	real matrix 					A0, B, V_var, BB, AA, Psr, SIRF, Q1, Q2, ///
									SSnoc, SSnor, SSr, SS, J, M, MM1, MM2,   ///
									SIGMA_W, SIGMA0, SIGMA_AB, G0, 			 ///
									Q4, SIGMAH, SIRFSE, STP
	numeric scalar					i, j, s, lags, stp, z, cm, cn, rm, rn
	pointer rowvector				A, PHI, THETA, G, MP, MPP
	
	/* start pass the ingredients */
	AAA = tokens(namelist)			// list of matrices
	NAM = tokens(names)				// list of variables in SVAR	
	nse = tokens(nose) 				// option for SE
	stp = strtoreal(steps)			// Step  for SIRF (default =12)	
	
	A0 = st_matrix(AAA[1])
	B = st_matrix(AAA[2])
	b_var = st_matrix(AAA[3])
	V_var = st_matrix(AAA[4])
	SIGMA_AB = st_matrix(AAA[5])
	lags = (cols(b_var)-rows(B))/(rows(B)*cols(B))
	/* end pass the ingredients */
	
	/* start the calculation of SIRF */
	/* rearrange b_var and eliminate cols for constant	*/
	BB = J(rows(B),cols(B)*lags,0)
	for (i = 1; i<=rows(B); i++) {
	cm = 1+(i-1)*(rows(B)*lags+1)
	cn = cm + rows(B)*lags - 1
		BB[i,.] = b_var[|.,cm\.,cn|]
		}
	/* rearrange columns of BB (i) in lag order */
	AA = J(rows(B),lags*cols(B),.)
	for (s = 1; s<=lags; s++) {
		for (i = 1; i<=cols(B); i++) {
			cm = i+(s-1)*rows(B)
			cn = s+(i-1)*lags
			AA[.,cm] = BB[.,cn]
			}
		}

/* 
create structure for the lags of the VAR containing n=steps matrices of 
dimension (rows(B) x cols(B)) by using pointers. These are: a=1 matrix A0; 
p=lag submatrices of BB (A1,....,Ap); and l = steps - p -1 matrices of zeros
*/
	A = J(1,stp+1,NULL) /* structure of the A0... Ap matrices */
	A[1] = &(A0)
	for (s = 1; s <= stp; s++) {
		if (s <= lags) A[s+1] = &AA[|.,1+rows(B)*(s-1)\.,rows(B)*s|]
		else A[s+1] = &J(rows(B),cols(B),0)
		}
		
	Psr = luinv(*A[1])*B
	PHI = J(1,stp+1,NULL)  			// structure of the MA representation
	THETA = J(1,stp+1,NULL)			// structure of the SIRF
	PHI[1] = &(I(rows(B))) 			// contemporaneous MA
	THETA[1] = &(I(rows(B))*Psr) 	// contemporaneous SIRF// s=1,...,step MA and SIRF

	for (s = 1; s <= stp; s++) { 
		PHI[s+1] = &(J(rows(B),cols(B),0))
		for (j = 1; j <= s; j++) {
			PHI[s+1] = &(*PHI[s+1]+*PHI[s-j+1]**A[j+1])
		}
		THETA[s+1] = &(*PHI[s+1]*Psr)
	}
		
	/* gen SIRF matrix */
	SIRF = J(stp+1,rows(B)*cols(B),.)
	for (s = 1; s <= stp+1; s++) {
		for (j = 1; j<=cols(B); j++) {
			for (i = 1; i<=rows(B); i++) {
				z = (i-1)*rows(B)+j
				SIRF[s,z] = (*THETA[s])[j,i]
			}
		}
	}
 
	/* add first column step */
	STP = J(stp+1,1,.)
	for (s = 1; s<=stp+1; s++) {
		STP[s,1] = s-1
	}
	SIRF = STP,SIRF
	/* end the calculation of SIRF */
	
	/* start header matrix */
	/* gen matrix header with the names of "impulse_response" */
	head = J(1,rows(B)*cols(B)+1,"")
	head[1,1] = "Step"
	for (j = 1; j <= cols(B); j++) {
		for (i = 1; i <= rows(B); i++) {
			cm = (i-1)*rows(B)+j+1
			head[1,cm] = NAM[1,i]+":"+NAM[1,j]
		}
	}
	/* end header matrix */
	
	/* start the calculation of asymptotic SE */
	if (nose == "") { 

	/* eliminate cols of const in V_var */
	SSnoc = J(lags*rows(B)^2+rows(B),lags*cols(B)^2,.)
	for (i=1; i <= rows(B); i++) {
		cm = 1+(i-1)*(rows(B)*lags+1)
		cn = cm + rows(B)*lags - 1
		SSnoc[|.,1+(i-1)*rows(B)*lags\.,i*rows(B)*lags|] = V_var[|.,cm\.,cn|]
	}
		
	/* eliminate rows of const in V_var */
	SSnor = J(lags*rows(B)^2,lags*cols(B)^2,.)
	for (j=1; j <= cols(B); j++) {
		rm = 1+(j-1)*(rows(B)*lags+1)
		rn = rm + rows(B)*lags - 1
		SSnor[|1+(j-1)*rows(B)*lags,.\j*rows(B)*lags,.|] = SSnoc[|rm,.\rn,.|]
	}

	/* rearrange columns (i) in lag order */
	z = 1
	SSr = J(lags*rows(B)^2,lags*cols(B)^2,.)
	for (i = 1; i <= rows(B); i++) {
		for (j = 1; j <= cols(B); j++) {
			for (s = 1; s <= lags; s++) {
				SSr[.,i+(j-1)*cols(B)+(s-1)*cols(B)^2] = SSnor[.,z] /* swaps cols */
				z++
			}
		}
	}
		
	/* rearrange rows (j) in lag order */	
	z = 1
	SS = J(lags*rows(B)^2,lags*cols(B)^2,.)
	for (i = 1; i <= rows(B); i++) {
		for (j = 1; j <= cols(B); j++) {
			for (s = 1; s <= lags; s++) {
			SS[i+(j-1)*cols(B)+(s-1)*cols(B)^2,.] = SSr[z,.]  /* swaps rows */
				z++
			}
		}
	}

	/* J matrix */
	J = I(rows(B))
	for (j = 2; j <= lags; j++) {
		J = J,J(rows(B),cols(B),0)
	}
	
	/* M matrix */
	MM1 = *A[2]
	for (j = 2; j <= lags; j++) {
		MM1 = MM1,*A[j+1]
	}
	MM2 = I(rows(B)*(lags-1)),J(rows(B)*(lags-1),cols(B),0)
	M = MM1\MM2
	
	/* SIGMA0 matrix */
	Q1 = (I(rows(B))#luinv(B),-luinv(Psr')#luinv(B))
	Q2 = Psr'#Psr
	SIGMA_W = Q1*SIGMA_AB*Q1'
	SIGMA0 = Q2*SIGMA_W*Q2'
	
	/* G_i matrix */
	G0 = J(rows(B)^2, rows(B)^2*lags, 0)
	
	G = J(1,stp+1,NULL)	// structure of the GI
	G[1] = &(G0)
	
	MP = J(1,stp+1,NULL) // power matrix of M
	MPP = J(1,stp+1,NULL) // power matrix of M'
	MP[1] = &(I(rows(B)*lags))
	MPP[1] = &(I(rows(B)*lags))
	for (i = 2; i <= stp+1; i++) {
		MP[i] = &(*MP[i-1]*M)
		MPP[i] = &(*MPP[i-1]*M')
	}
	
	for (s = 1; s <= stp; s++) { 
		G[s+1] = &(J(rows(B)^2, rows(B)^2*lags, 0))
		for (j = 1; j <= s; j++) {
			G[s+1] = &(*G[s+1]+(Psr'*J**MPP[s-j+1])#(J**MP[j]*J'))
		}
	}

	/* gen SIRF SE matrix */
	for (s = 0; s <= stp; s++) { 
		Q4 = I(rows(B))#(J**MP[s+1]*J')
		SIGMAH = (*G[s+1])*SS*(*G[s+1])'+Q4*SIGMA0*Q4'
		if (s == 0) SIRFSE = (diagonal(cholesky(diag(diagonal(SIGMAH)))))'
		else SIRFSE = SIRFSE \ (diagonal(cholesky(diag(diagonal(SIGMAH)))))'
	}
	
	/* add first column step */
	SIRFSE = STP,SIRFSE
	} // this is the end of the option nose
	/* end the calculation of asymptotic SE */
	
	/* send MATA matrices to STATA */
	if (nose == "") st_matrix("SIRFSE", SIRFSE)	
	st_strscalar("head", invtokens(head, " "))
	st_matrix("SIRF", SIRF)
		
}

end
*********************************** end MATA ***********************************
