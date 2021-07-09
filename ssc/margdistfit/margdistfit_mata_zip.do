* version 1.3.0 14May2012 MLB
mata 

real matrix function marg_zipden (struct margdata scalar data, real matrix x)
{
	real vector res
	real scalar i
	res = J(rows(x),1,.)
	for(i=1; i<=rows(x);i++) {
		res[i] = mean( (x[i] == 0 ? data.pars[.,2] : J(rows(data.pars[.,2]),1,0) ) :+ (1:-data.pars[.,2]):*poissonp(data.pars[.,1], x[i]),data.fw)
	}
	return(res)
}
mata mlib add lmargdistfit marg_zipden()

void function marg_zippp(string scalar var, string scalar pvar, 
                          string scalar mu, string scalar pr,  
						  string scalar first, string scalar fw, 
						  string scalar touse) {
	struct margdata scalar data
	real matrix x
	
	data.pars = st_data(.,(mu,pr), first)
	data.fw = st_data(.,fw, first)
	x = st_data(.,tokens(var),touse)
	
	marg_discr_pp(x, pvar, data, touse, &marg_zipden(), 0)
}
mata mlib add lmargdistfit marg_zippp()

void function marg_zipqq(string scalar pvar, string scalar qvar, 
                             string scalar mu, string scalar pr, 
						     string scalar first, string scalar fw, 
						     string scalar touse) {
	struct margdata scalar data
	real matrix obsp
	
	data.pars = st_data(.,(mu,pr), first)
	data.fw = st_data(.,fw, first)
	obsp = st_data(.,tokens(pvar),touse)

	marg_discr_qq(obsp, qvar, data, touse, &marg_zipden(), 0)
	
}
mata mlib add lmargdistfit marg_zipqq()

end
