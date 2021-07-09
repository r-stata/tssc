*! version 1.0.0  23jul2018
program raschify, eclass
	version 14
	
	local irt = "`e(cmd2)'" == "irt" & "`e(model1)'" == "1pl"
	local ok = `irt' & `e(irt_k_eq)' == 1
	
	if !`ok' {
		di as err "{bf:raschify} allowed only after irt 1pl"
		exit 198
	}
	
	tempname b V
	mat `b' = e(b)
	mat `V' = e(V)
	
	mata: _raschify("`b'","`V'")
	ereturn repost b=`b' V=`V'
end

mata mata set matastrict on

version 14
mata:

void _raschify(string scalar bs, Vs)
{

	real scalar a, var, dim, mv
	real vector b, ix, jj
	real matrix V, J
	
	b = st_matrix(bs)
	V = st_matrix(Vs)
	
	dim = cols(b)
	
	a = b[1]
	var = a*a

	// transform a's	
	ix = 2*(1..dim/2) :-1
	mv = cols(ix)
	
	// replace a's with 1's
	b[ix] = J(1,cols(ix),1) 
	b[dim] = var
	
	jj = J(1,dim,1)

	jj[ix] = J(1,cols(ix),0)
	J = diag(jj)
	J[dim,dim] = a^2 / mv^2

	J[dim,ix] = J(1,dim/2,2*a/mv)

	V = J*V*J'
	
	st_replacematrix(bs,b)
	st_replacematrix(Vs,V)	
	
	st_global("e(title)","Rasch model")
}

end

exit
