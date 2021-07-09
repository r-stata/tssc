mata: mata clear
mata: mata set matastrict on
version 10.1
mata:
// mf_nneighbor 1.0.0  CFBaum 11aug2008
void function mf_nneighbor(string scalar matchvars,
                           string scalar closest,
                           string scalar response,
                           string scalar match,
                           string scalar touse) 
{
	real matrix X, Z, mc, C, y, ystar
	real colvector ind
	real colvector w
	real colvector d
	real scalar n, k, i, j
	string rowvector vars, v
	st_view(X, ., tokens(matchvars), touse)
// standardize matchvars with mm_meancolvar from moremata
	mc = mm_meancolvar(X)
	Z = ( X :- mc[1, .]) :/ sqrt( mc[2, .]) 
	n = rows(X)
	k = cols(X)
	st_view(C, ., closest, touse)
	st_view(y, ., response, touse)
	st_view(ystar, ., match, touse)

// loop over observations
	for(i = 1; i <= n; i++) {
// loop over matchvars
	    d = J(n, 1, 0)
	    for(j = 1; j <= k; j++) {
	        d = d + ( Z[., j] :- Z[i, j] ) :^2
	    }
	minindex(d, 2, ind, w)
	C[i] = ind[2]
	ystar[i] = y[ind[2]] 
	}
}
end

mata: mata mosave mf_nneighbor(), dir(PERSONAL) replace
