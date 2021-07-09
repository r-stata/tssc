/*This ado file generates random data according to the sgt distribution.

Author --Jacob Orchard

v1.0
Update 7/29/2016*/




program rsgt, eclass
version 13.0
	if replay() {
		display "Replay not implemented"
	}
	else {
	args varname mu lambda sigma p q 
		confirm name `varname'
		confirm number `mu' 
		confirm number `lambda'
		confirm number `sigma'
		confirm number `p'
		confirm number `q'
		
		if `p' <=0{
			di as error "Parameter p must be positive"
		}
		if `q' <=0{
			di as error "Parameter q must be positive"
		}
		if `sigma' <= 0{
			di as error "Parameter sigma must be positive"
		}
		if `lambda' <= -1 | `lambda' >= 1{
			di as error "Parameter lambda must be between -1 and 1."
		}
		
		quietly mata: rsgt("`varname'",`mu',`lambda',`sigma',`p',`q')
	}

end



//Mata functions

version 13
mata:
	function rsgt(string myvar, scalar mu, scalar lambda, scalar sigma, scalar p, scalar q)
	{
	nobs = st_nobs()
	base = runiform(nobs,1)
	newvar = J(nobs,1,0)
	paravec = mu, lambda, sigma,p,q
	
	if (nobs <1000){
	
		for (i=1; i <=nobs; i++){
			newvar[i] = estimatesgt(paravec,base[i])
			}
		}
	else{
		cdflist = interpolatesgt(paravec)
		
		for (i=1; i <=nobs; i++){
			newvar[i] = nearest_sgt(cdflist,base[i])
			}
	
	}
	
	(void) st_addvar("double", myvar)
	st_store(.,myvar,newvar[.,1])
	}
	end
	
mata:
	function estimatesgt(paravec,unifval)
	{
	
		mu      = paravec[1]
		lambda  = paravec[2]
		sigma   = paravec[3]
		p       = paravec[4]
		q       = paravec[5]
		
		S = optimize_init()
		optimize_init_which(S,"min")
		optimize_init_technique(S,"dfp nr")
		optimize_init_evaluator(S,&closestsgt())
		
		//Expected Value (starting value)
		start = mu + (sigma/2)*((q^(1/p)*exp(lngamma(1/p) + lngamma(q-(1/p)) - lngamma(q)))/exp(lngamma(1/p) + lngamma(q-(1/p)) - lngamma(q)))*((1+lambda)^2 -(1-lambda)^2)
		optimize_init_params(S,start)
		optimize_init_argument(S,1,paravec)
		optimize_init_argument(S,2,unifval)
		_optimize(S)
	    ans    = optimize_result_params(S)
		return(ans)
	
	}
	
end

mata:
	function interpolatesgt(paravec)
	{
		cdflist = J(1000,1,0)
		
		for (i=1; i <=1000; i++){
		cdflist[i] = estimatesgt(paravec,(i/1000))
		}
	return(cdflist)
    }
end

mata:
	function nearest_sgt(cdflist,unifval)
	{
		nx = 1000*unifval
		intx = floor(nx)
		remx = nx - intx
		next = intx+1
		
		if (intx ==0) {
			closesgt = cdflist[1]*remx
		}
		else{
			closesgt = cdflist[intx]*(1-remx) + cdflist[next]*remx
		}
		return(closesgt)
	}
end

mata: 
	function closestsgt(real scalar todo, real rowvector p, paravec,unifval, v,g,H)
	{
	
	v = abs(sgt_cdf(p,paravec)-unifval)
	
	}
	end
	
mata:
function sgt_cdf(matrix y, paravec)
	{
	ones = J(1,cols(y),1)
	mu     = paravec[1]
	lambda = paravec[2]
	sigma  = paravec[3]
	p      = paravec[4]
	q      = paravec[5]
	
	
	
	zu = abs(y-mu):^p/(abs(y - mu):^p + q*sigma:^p*(1+lambda*sign(y-mu))^p)
	F = .5*(1-lambda) + .5*(1+lambda*sign(y-mu))*sign(y-mu)*exp(lngamma(1/p) + lngamma(q) - lngamma(1/p+q))*ibeta(1/p,q,zu)
	return(F)
	}
end
	
	

