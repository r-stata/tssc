// Calculate correlation metric from coefficient vectors
// version 0.5

version 11

mata:
	mata clear
	mata set matastrict on
	void nlcorr(
		real scalar MODVAR
		)
	{

		real rowvector B
		real matrix V0
		real rowvector V1
		string matrix names
		real colvector selector
		real rowvector Mvec
		real matrix BVAR
		real colvector R
		real colvector FR
		real colvector Ratio 
		real colvector SD
		real matrix d1
		real matrix SE
		real matrix Z
		real matrix P
		real scalar R2

		// Get info from Stata
		V0 = st_matrix("_V0")
		V1 = st_matrix("_V1")
		B = st_matrix("e(b)")
		BVAR = diagonal(st_matrix("e(V)"))'
		names = st_matrixcolstripe("e(b)")

		// Keep only used coeficients
		selector = (names[.,2]:!="_cons") :* (!strpos(names[.,2],"o.") :* !strpos(names[.,2],"b."))
		B = select(B, (selector)')
		BVAR = select(BVAR, (selector)')

		// Vectors of constans for element-wise operations
		Mvec = J(1, cols(B), MODVAR)

		// Correlation metric
		R = sqrt( (B:^2 :* V1) :/ ( (B:^2 :* V1) :+ Mvec )) :* sign(B)

		// Fisher Transform of R
		FR = atanh(R)

		// Correlation Ratio
		Ratio = R :/ sqrt(J(rows(R),1,1) :- R:^2)
		
		// Standard error
		d1 = sqrt(V1) :/ sqrt( (B:^2 :* V1) :+ Mvec )
		SE = sqrt(d1 * BVAR' * d1)

		// (Partial) Standard Deviations
		SD = sqrt(V1)
		
		// Z 
		Z = FR :/ SE 
	
		// Prob > |z|
		P = 2 :* normal(-1 :* abs(Z)) 
		
		// R^2
		R2 = (B*V0*B') :/ ( (B*V0*B') :+ MODVAR)
			
		// Return to Stata
		st_matrix("_R",R)
		st_matrix("_FR",FR)
		st_matrix("_Ratio",Ratio)
		st_matrix("_SD",SD)
		st_matrix("_SE",SE)
		st_matrix("_Z",Z)
		st_matrix("_P",P)
		st_numscalar("_R2_L",R2)
	}

	mata mosave nlcorr(), replace
end
