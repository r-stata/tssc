// INTERFACE BETWEEN STATA AND MATA; REQUIRED TO ACCESS isPositiveDefinite AND makePositiveDefinite FROM STATA

capture mata: mata drop interfacePD()

mata:
void interfacePD(string matrix stataMatrix) {
	
	real matrix C, Ctilde
	real scalar isPositiveDefinite
	
	C = st_matrix(stataMatrix)
	
	isPositiveDefinite = isPositiveDefinite(C)
	
	
	if (isPositiveDefinite==0) {
		Ctilde = makePositiveDefinite(C)
	}
	else {
		Ctilde = C
	}
	
	st_rclear()
	st_matrix("r(pdMatrix)", Ctilde)
	st_numscalar("r(isPositiveDefinite)", isPositiveDefinite)
}	
end
