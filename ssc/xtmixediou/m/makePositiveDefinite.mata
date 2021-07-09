capture mata: mata drop makePositiveDefinite()

mata:
real matrix makePositiveDefinite(real matrix C)
{
	real matrix X, Ctilde, matrix_Ldash
	real rowvector L, Ldash
	real scalar numberOfeigenvalues, row
	
	X = J(0,0,.)
	L = J(0,0,.)
	
	symeigensystem(C, X, L)
	
	numberOfeigenvalues = cols(L)
	
	Ldash = L
	for(row=1; row<=numberOfeigenvalues; row++) {
		if(Ldash[row]<=0) {
			Ldash[row] = 0.0000001
		}
	}
	matrix_Ldash = diag(Ldash)
	
	Ctilde = X*matrix_Ldash*X'
	_makesymmetric(Ctilde)
	
	return(Ctilde)
}
end
