* version 1.3.0 17Mar2012 MLB
mata 

real matrix function marg_poissoncum (struct margdata scalar data, real matrix x)
{
	real vector res
	real scalar i
	
	res = J(rows(x),1,.)
	for(i=1; i<=rows(x);i++) {
		res[i] = mean(poisson(data.pars[.,1], x[i]),data.fw)
	}
	return(res)
}
mata mlib add lmargdistfit marg_poissoncum()

void function marg_poissonpp(string scalar var, string scalar pvar, 
                             string scalar mu, 
						     string scalar first, string scalar fw, 
						     string scalar touse) {
	struct margdata scalar data
	real matrix x
	
	data.pars = st_data(.,mu, first)
	data.fw = st_data(.,fw, first)
	x = st_data(.,tokens(var),touse)
	
	marg_discr_pp(x, pvar, data, touse, &marg_poissoncum(), 1)
}
mata mlib add lmargdistfit marg_poissonpp()

void function marg_poissonqq(string scalar pvar, string scalar qvar, 
                             string scalar mu, 
						     string scalar first, string scalar fw, 
						     string scalar touse) {
	struct margdata scalar data
	real matrix obsp
	
	data.pars = st_data(.,mu, first)
	data.fw = st_data(.,fw, first)
	obsp = st_data(.,tokens(pvar),touse)

	marg_discr_qq(obsp, qvar, data, touse, &marg_poissoncum(), 1)
	
}
mata mlib add lmargdistfit marg_poissonqq()

end
