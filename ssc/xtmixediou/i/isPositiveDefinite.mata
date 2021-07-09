// TEST IF A MATRIX IS POSITIVE DEFINITE
capture mata: mata drop isPositiveDefinite()

mata:
real scalar isPositiveDefinite(real matrix C)
{
	real matrix X
	real rowvector L
	real scalar numberOfeigenvalues, row, tolerance
	X = J(0,0,.)
	L = J(0,0,.)
	
	if (hasmissing(C)==1) {
		isPositiveDef = -1
	}
	else {
		symeigensystem(C, X, L)
		numberOfeigenvalues = cols(L)
		
		tolerance = 0.00000001
		
		isPositiveDef = 1 	// ASSUME THIS IS TRUE AT THE START
		for(row=1; row<=numberOfeigenvalues; row++) {
			if(L[row]<=tolerance | L[row]==.) {
				isPositiveDef = 0
			}
		}
	}
	
	return(isPositiveDef)
	
} 
end
