version 10.1
mata:
	void avgper(string scalar vname,
                string scalar newvname,
	            real scalar per,
	            string scalar touse)
	{      
    real matrix v1, v2, v3
	st_view(v1=., ., vname, touse)
	st_view(v2=., ., newvname)
	v3 = colshape(v1', per) * J(per, 1, 1/per)
	v2[ (1::rows(v3)), ] = v3
	}
end

