*! mixlwtp_gf0 1.1.0 05Apr2016
*! author arh

version 11.1
mata: 
void mixlwtp_gf0(M, todo, b, lnfj, S, H)
{
	external mixlwtp_X
	external mixlwtp_Y
	external mixlwtp_T
	external mixlwtp_CSID
	
	external mixlwtp_nrep
	external mixlwtp_np
	external mixlwtp_kfix
	external mixlwtp_krnd
	external mixlwtp_krln
	external mixlwtp_burn
	external mixlwtp_corr
	external mixlwtp_user

	nrep = mixlwtp_nrep
	np = mixlwtp_np
	kfix = mixlwtp_kfix
	krnd = mixlwtp_krnd
	krln = mixlwtp_krln
	burn = mixlwtp_burn
	corr = mixlwtp_corr
	user = mixlwtp_user

	B = b'

	kall = kfix + krnd
	
	if (kfix > 0) {
		MFIX = B[|1,1\kfix,1|]
		MFIX = MFIX :* J(kfix,nrep,1)	
	}

	MRND = B[|(kfix+1),1\kall,1|]
	
	if (corr == 1) {
		external mixlwtp_ncho
		ncho = mixlwtp_ncho 
		SRND = invvech(B[|(kall+1),1\(kall+ncho),1|]) :* lowertriangle(J(krnd,krnd,1))
	}
	else {
		SRND = diag(B[|(kall+1),1\(kfix+2*krnd),1|])
	}

	if (user == 1) external mixlwtp_USERDRAWS

	P = J(np,1,0)

	i = 1
	for (n=1; n<=np; n++) {
		
		if (user == 1) {
			ERR = invnormal(mixlwtp_USERDRAWS[|1,(1+nrep*(n-1))\krnd,(nrep*n)|])
		}
		else {
			ERR = invnormal(halton(nrep,krnd,(1+burn+nrep*(n-1)))')
		}
	
		if (kfix > 0) BETA = MFIX \ (MRND :+ (SRND*ERR))
		else BETA = MRND :+ (SRND*ERR)
		if (krln > 0) {
			if ((kall-krln) > 0) {
				BETA = BETA[|1,1\(kall-krln),nrep|] \ exp(BETA[|(kall-krln+1),1\kall,nrep|])
			}
			else {
				BETA = exp(BETA)
			}
		}
		R = J(1,nrep,1)

		t = 1
		nc = mixlwtp_T[i,1]
		for (t=1; t<=nc; t++) {

			YMAT = mixlwtp_Y[|i,1\(i+mixlwtp_CSID[i,1]-1),cols(mixlwtp_Y)|]
			XMAT = mixlwtp_X[|i,1\(i+mixlwtp_CSID[i,1]-1),cols(mixlwtp_X)|]

			B1 = BETA[1..(rows(BETA)-1),.] \ J(1,cols(BETA),1)
			B2 = J(rows(XMAT),cols(BETA),1) :* BETA[rows(BETA),.] 

			V = XMAT * B1
			V = B2 :* V

			EV = exp(V) :/ colsum(exp(V),1)
	
			R = R :* colsum(YMAT :* EV,1)

			i = i + mixlwtp_CSID[i,1]
		}
		P[n,1] = mean(R',1)
	}
	lnfj = ln(P)
}
end	

exit




			


