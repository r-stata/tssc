* version 1.0.0 14Nov2011 MLB
mata

void function marg_norminvert(string scalar mu, real scalar sd, 
                         string scalar fw, string scalar first,
						 string scalar pobs, string scalar touse, 
						 real scalar l, real scalar u, real scalar e, string scalar Q) {
	
	struct margdata scalar data
	real vector Psubi
	
	data.pars = st_data(.,mu, first)
	data.spar = sd
	data.fw = st_data(.,fw, first)
	Psubi = st_data(.,pobs, touse)
	
	marg_invert(l, u, e, data, Psubi, &marg_normdens(), &marg_normcum(), Q)
}
mata mlib add lmargdistfit marg_norminvert()

real matrix function marg_normdens (struct margdata scalar data, real matrix x) 
{
	real vector res
	real scalar i
	
	res = J(rows(x),1,.)
	for(i=1; i<= rows(x); i++) {
		res[i] = mean(normalden(x[i], data.pars[.,1], data.spar),data.fw)
	}
	return(res)
}
mata mlib add lmargdistfit marg_normdens()

real matrix function marg_normcum (struct margdata scalar data, real matrix x)
{
	real vector res
	real scalar i
	
	res = J(rows(x),1,.)
	for(i=1; i<=rows(x);i++) {
		res[i] = mean( normal((x[i]:-data.pars[.,1]):/data.spar),data.fw)
	}
	return(res)
}
mata mlib add lmargdistfit marg_normcum()

void function marg_normpp(string scalar var, string scalar pvar, 
                          string scalar mu, real scalar sd, 
						  string scalar first, string scalar fw, 
						  string scalar touse, real scalar e) {
	struct margdata scalar data
	real scalar i
	real vector lu, t
	real matrix x, hermite
	
	data.pars = st_data(.,mu, first)
	data.spar = sd
	data.fw = st_data(.,fw, first)
	x = st_data(.,tokens(var),touse)
	if (e > 1e-12) {
		lu = minmax(x)
		hermite = marg_hermitegen_ac(lu, e, data,&marg_normdens(), &marg_normcum())
	}
	for (i= 1 ; i <= cols(x) ; i++) {
		if (e > 1e-12) {
			x[.,i] = marg_eval_ac(hermite,x[order(x,i),i])
		}
		else {
			t = marg_normcum(data,x[.,i])
			t = t[order(t,1)]
			x[.,i] = t
		}
	}
	st_store(.,tokens(pvar),touse,x)
}
mata mlib add lmargdistfit marg_normpp()

end
