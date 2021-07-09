
version 10.1
mata: mata set matastrict on
mata: mata clear
// shufstr 1.0.0  CFBaum 11aug2008
mata:
 	void function shufstr(string vector vname)
 	{
	     string matrix S
	     real scalar i
	     st_sview(S, ., vname)
	     for(i = 1; i <= rows(S);  i++) {
 	         S[i, .] = char(jumble(ascii(S[i, .])')')
	     }
 	}
end

mata: mata mosave shufstr(), dir(PERSONAL) replace

