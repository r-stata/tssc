version 10.1
mata: mata set matastrict on
mata:
// mf_flipmat 1.0.0  CFBaum 11aug2008
void function mf_flipmat(string scalar name, string scalar horiz)
{
	real matrix X, rs, cs
	X = st_matrix(name)
	rs = st_matrixrowstripe(name)
	cs = st_matrixcolstripe(name)
	if (horiz == "") {
	        X = (rows(X)>1 ? X[rows(X)..1, .] : X)
	        rs = (rows(rs)>1 ? rs[rows(rs)..1, .] : rs)
	}
	else {
	        X = (cols(X)>1 ? X[., cols(X)..1] : X)
	        cs = (rows(cs)>1 ? cs[rows(cs)..1, .] : cs)
	}
	st_matrix(name, X)
	st_matrixcolstripe(name, cs)
	st_matrixrowstripe(name, rs)
}
end

mata: mata mosave mf_flipmat(), dir(PERSONAL) replace
