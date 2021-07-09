* version 1.3.0 14May2012 MLB
mata 

real matrix function marg_nb1den (struct margdata scalar data, real matrix x)
{
	real vector res, m
	real scalar i, d
	
	m = exp(ln(data.pars[.,1]) :- data.spar)
	d = exp(data.spar)
	
	res = J(rows(x),1,.)
	
	if (data.spar < -20) {
		for(i=1; i<=rows(x);i++) {
			res[i] = mean( poissonp(data.pars[.,1], x[i]),data.fw)
		}
	}
	else {
		for(i=1; i<=rows(x);i++) {
			res[i] = mean(exp(lngamma(x[i] :+ m) :- lngamma(x[i]+1) :- lngamma(m) :+ data.spar*x[i] :- ln(1 + d):*(x[i] :+m)), data.fw)
		}
	}
	return(res)
}
mata mlib add lmargdistfit marg_nb1den()

void function marg_nb1pp(string scalar var, string scalar pvar, 
                          string scalar mu, real scalar ld,  
						  string scalar first, string scalar fw, 
						  string scalar touse) {
	struct margdata scalar data
	real matrix x
	
	data.pars = st_data(.,(mu), first)
	data.spar = ld
	data.fw = st_data(.,fw, first)
	x = st_data(.,tokens(var),touse)
	
	marg_discr_pp(x, pvar, data, touse, &marg_nb1den(), 0)
}
mata mlib add lmargdistfit marg_nb1pp()

void function marg_nb1qq(string scalar pvar, string scalar qvar, 
                             string scalar mu, real scalar ld, 
						     string scalar first, string scalar fw, 
						     string scalar touse) {
	struct margdata scalar data
	real matrix obsp
	
	data.pars = st_data(.,(mu), first)
	data.spar = ld
	data.fw = st_data(.,fw, first)
	obsp = st_data(.,tokens(pvar),touse)

	marg_discr_qq(obsp, qvar, data, touse, &marg_nb1den(), 0)
	
}
mata mlib add lmargdistfit marg_nb1qq()

end
