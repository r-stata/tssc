* version 1.3.0 14May2012 MLB
mata 

real matrix function marg_nb2den (struct margdata scalar data, real matrix x)
{
	real vector res, ia, den
	real scalar i, j
	
	ia = 1:/data.pars[.,2]
	
	res = J(rows(x),1,.)
	den = J(rows(data.pars),1,.)
	for(i=1; i<=rows(x);i++) {
		if ( min(ln(data.pars[.,2])) < -20) {
			for(j=1; j <= rows(data.pars); j++) {
				den[j] = ( ln(data.pars[j,2]) < -20 ? 
						   poissonp(data.pars[j,1], x[i]) :
						   exp(lngamma(x[i] + ia[j]) - lngamma(x[i]+1) - lngamma(ia[j])) * (ia[j]/(ia[j] + data.pars[j,1]))^ia[j] * (data.pars[j,1]/(ia[j] + data.pars[j,1]))^x[i] )
			}
		}
		else {
			den = exp(lngamma(x[i] :+ ia) :- lngamma(x[i]+1) :- lngamma(ia)) :* (ia:/(ia :+ data.pars[.,1])):^ia :* (data.pars[.,1]:/(ia :+ data.pars[.,1])):^x[i] 
		}
		res[i] = mean(den, data.fw)
	}
	return(res)
}
mata mlib add lmargdistfit marg_nb2den()

void function marg_nb2pp(string scalar var, string scalar pvar, 
                          string scalar mu, string scalar alpha,  
						  string scalar first, string scalar fw, 
						  string scalar touse) {
	struct margdata scalar data
	real matrix x
	
	data.pars = st_data(.,(mu,alpha), first)
	data.fw = st_data(.,fw, first)
	x = st_data(.,tokens(var),touse)
	
	marg_discr_pp(x, pvar, data, touse, &marg_nb2den(), 0)
}
mata mlib add lmargdistfit marg_nb2pp()

void function marg_nb2qq(string scalar pvar, string scalar qvar, 
                             string scalar mu, string scalar alpha, 
						     string scalar first, string scalar fw, 
						     string scalar touse) {
	struct margdata scalar data
	real matrix obsp
	
	data.pars = st_data(.,(mu,alpha), first)
	data.fw = st_data(.,fw, first)
	obsp = st_data(.,tokens(pvar),touse)

	marg_discr_qq(obsp, qvar, data, touse, &marg_nb2den(), 0)
	
}
mata mlib add lmargdistfit marg_nb2qq()

end
