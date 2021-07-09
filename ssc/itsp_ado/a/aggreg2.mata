version 10.1
mata: mata clear
mata: mata set matastrict on
mata:
function mf_abs(x) return(abs(x))
function mf_exp(x) return(exp(x))
function mf_log(x) return(log(x))
function mf_sqrt(x) return(sqrt(x))
function mf_iden(x) return(x)

// aggreg2 1.0.0  CFBaum 11aug2008
void aggreg2(string scalar vname,
            string scalar newvname,
            real scalar per,
            string scalar op,
            pointer(real scalar function) scalar f,
            string scalar touse)
{
	real matrix v1, v1t, v2, v3
	real colvector mult
	if (op == "A") {
	     mult = J(per, 1, 1/per)
	}
	else if (op == "S") {
	     mult = J(per, 1, 1)
	}
	else if (op == "F") {
		 mult = J(per, 1, 0)
		 mult[1] = 1
	}
	else if (op == "L") {
	     mult = J(per, 1, 0)
	     mult[per] = 1
	}
	st_view(v1=., ., vname, touse)
	v1t = (*f)(v1)
	st_view(v2=., ., newvname)
	v3 = colshape(v1t', per) * mult
	v2[(1::rows(v3)),] = v3
}
end

mata: mata mosave aggreg2(), dir(PERSONAL) replace