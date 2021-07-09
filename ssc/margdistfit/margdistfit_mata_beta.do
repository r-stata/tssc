* version 1.0.0 14Nov2011 MLB
mata 

void function marg_betainvert(string scalar alpha, string scalar beta,
                         string scalar fw, string scalar first,
						 string scalar pobs, string scalar touse, 
						 real scalar l, real scalar u, real scalar e, string scalar Q) {
	
	struct margdata scalar data
	real vector Psubi
	
	data.pars = st_data(.,(alpha, beta), first)
	data.fw = st_data(., fw, first)
	Psubi = st_data(.,pobs, touse)
	
	marg_invert(l, u, e, data, Psubi, &marg_betadens(), &marg_betacum(), Q, e, 1-e)
}
mata mlib add lmargdistfit marg_betainvert()

real matrix function marg_betadens (struct margdata scalar data, real matrix x) 
{
	real vector res
	real scalar i
	
	res = J(rows(x),1,.)
	for(i=1; i<= rows(x); i++) {
		res[i] = mean(betaden(data.pars[.,1], data.pars[.,2], x[i]),data.fw)
	}
	return(res)
}
mata mlib add lmargdistfit marg_betadens()

real matrix function marg_betacum (struct margdata scalar data, real matrix x)
{
	real vector res
	real scalar i
	
	res = J(rows(x),1,.)
	for(i=1; i<=rows(x);i++) {
		res[i] = mean(ibeta(data.pars[.,1], data.pars[.,2], x[i]),data.fw)
	}
	return(res)
}
mata mlib add lmargdistfit marg_betacum()

void function marg_betapp(string scalar var, string scalar pvar, 
                          string scalar alpha, string scalar beta, 
						  string scalar first, string scalar fw, 
						  string scalar touse, real scalar e) {
	struct margdata scalar data
	real scalar i
	real vector lu, t
	real matrix x, hermite
	
	data.pars = st_data(.,(alpha, beta), first)
	data.fw = st_data(.,fw, first)
	x = st_data(.,tokens(var),touse)
	if (e > 1e-12) {
		lu = minmax(x)
		hermite = marg_hermitegen_ac(lu, e, data,&marg_betadens(), &marg_betacum())
	}
	for (i= 1 ; i <= cols(x) ; i++) {
		if (e > 1e-12) {
			x[.,i] = marg_eval_ac(hermite,x[order(x,i),i])
		}
		else {
			t = marg_betacum(data,x[.,i])
			t = t[order(t,1)]
			x[.,i] = t
		}
	}
	st_store(.,tokens(pvar),touse,x)
}
mata mlib add lmargdistfit marg_betapp()

end
