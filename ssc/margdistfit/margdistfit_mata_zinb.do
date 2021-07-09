* version 1.3.0 14May2012 MLB
mata 

real matrix function marg_zinbden (struct margdata scalar data, real matrix x)
{
	real vector res, pp
	real scalar i, m
	
	m = 1/data.spar
	pp = 1:/(1:+data.spar:*data.pars[.,1])
	
	res = J(rows(x),1,.)
	
	for(i=1; i<=rows(x);i++) {
		res[i] = mean( (x[i] == 0 ? 
					data.pars[.,2] + (1:-data.pars[.,2]):*pp:^m :
					(1:-data.pars[.,2]) :* exp(lngamma(m+x[i]) - lngamma(x[i]+1) - lngamma(m)) :* (pp):^m :* (1:-pp):^x[i] ) , data.fw)
	}

	return(res)
}
mata mlib add lmargdistfit marg_zinbden()

void function marg_zinbpp(string scalar var, string scalar pvar, 
                          string scalar mu, real scalar alpha, string scalar pr,  
						  string scalar first, string scalar fw, 
						  string scalar touse) {
	struct margdata scalar data
	real matrix x
	
	data.pars = st_data(.,(mu, pr), first)
	data.spar = alpha
	data.fw = st_data(.,fw, first)
	x = st_data(.,tokens(var),touse)
	
	marg_discr_pp(x, pvar, data, touse, &marg_zinbden(), 0)
}
mata mlib add lmargdistfit marg_zinbpp()

void function marg_zinbqq(string scalar pvar, string scalar qvar, 
                             string scalar mu, real scalar alpha, string scalar pr, 
						     string scalar first, string scalar fw, 
						     string scalar touse) {
	struct margdata scalar data
	real matrix obsp
	
	data.pars = st_data(.,(mu, pr), first)
	data.spar = alpha
	data.fw = st_data(.,fw, first)
	obsp = st_data(.,tokens(pvar),touse)

	marg_discr_qq(obsp, qvar, data, touse, &marg_zinbden(), 0)
	
}
mata mlib add lmargdistfit marg_zinbqq()

end
