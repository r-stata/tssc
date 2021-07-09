version 10.1
mata: mata set matastrict on
mata:
// aggreg 1.0.0  CFBaum 11aug2008
void aggreg(string scalar vname,
            string scalar newvname,
	        real scalar per,
	        string scalar op,
	        string scalar touse)
	{
	real colvector mult, v1, v2
	real matrix v3
	if (op=="A") {
	     mult = J(per, 1, 1/per)
	}
	else if (op=="S") {
	     mult = J(per, 1, 1)
	}
	else if (op=="F") {
		 mult = J(per, 1, 0)
		 mult[1] = 1
	}
	else if (op=="L") {
	     mult = J(per, 1, 0)
	     mult[per] = 1
	}
	st_view(v1=., ., vname, touse)
	st_view(v2=., ., newvname)
	v3 = colshape(v1', per) * mult
	v2[(1::rows(v3)), ] = v3
	}
end
