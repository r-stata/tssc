*! eaa_gf0 1.1.0 02Apr2016
*! author arh

version 12.1
mata: 
void eaa_gf0(M, todo, b, lnfj, S, H)
{
	external eaa_X
	external eaa_Y
	external eaa_T
	external eaa_CSID
	external eaa_F
	external eaa_FCOLDUP

	external eaa_np
	external eaa_krhs
	external eaa_kzvs
	external eaa_keaa

	np = eaa_np
	krhs = eaa_krhs
	kzvs = eaa_kzvs
	keaa = eaa_keaa
	
	if (kzvs > 0) {
		external eaa_Z
		Z = eaa_Z,J(np,1,1)
	}	
	
	P = J(np,1,1)

	if (kzvs == 0) {
		A1 = invlogit(b[1,(krhs+1)..cols(b)])
		A0 = invlogit(-b[1,(krhs+1)..cols(b)])
		S = (eaa_F :* A1) :+ ((1:-eaa_F) :* A0)
		C = exp(rowsum(ln(S),1))
	}
	
	i = 1
	for (n=1; n<=np; n++) {

		if (kzvs > 0) {
			A1 = invlogit(Z[n,.]*b[1,(krhs+1)..(krhs+(kzvs+1))]')
			for (k=2; k<=keaa; k++) {
				A1 = A1, invlogit(Z[n,.]*b[1,(krhs+(kzvs+1)*(k-1)+1)..(krhs+(kzvs+1)*k)]')
			}
			A0 = invlogit(-Z[n,.]*b[1,(krhs+1)..(krhs+(kzvs+1))]')
			for (k=2; k<=keaa; k++) {
				A0 = A0, invlogit(-Z[n,.]*b[1,(krhs+(kzvs+1)*(k-1)+1)..(krhs+(kzvs+1)*k)]')
			}			
			S = (eaa_F :* A1) :+ ((1:-eaa_F) :* A0)
			C = exp(rowsum(ln(S),1))
		}
	
		R = J(rows(eaa_F),1,1)

		nc = eaa_T[i,1]
		for (t=1; t<=nc; t++) {
			
			YMAT = eaa_Y[|i,1\(i+eaa_CSID[i,1]-1),cols(eaa_Y)|]'
			XMAT = eaa_X[|i,1\(i+eaa_CSID[i,1]-1),cols(eaa_X)|]'
			
			FB = eaa_FCOLDUP :* b[1,1..krhs]						
			EV = exp(FB*XMAT)			
			EV = (EV :/ rowsum(EV,1)) 
			
			R = R :* rowsum(YMAT :* EV,1)
			
			i = i + eaa_CSID[i,1]
		}

		P[n,1] = colsum(C :* R,1)
	}	
	lnfj = ln(P)
}
end	

exit
