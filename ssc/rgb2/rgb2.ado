/*This ado file generates random data according to the specified distribution.

Author --Jacob Orchard

v1.2
Update 7/29/2016*/

program rgb2, eclass
version 13.0
	if replay() {
		display "Replay not implemented"
	}
	else {
	args varname a b p q 
		confirm name `varname'
		confirm number `a' 
		confirm number `b'
		confirm number `p'
		confirm number `q'
		
		if `p' <=0{
			di as error "Parameter p must be positive"
		}
		if `q' <=0{
			di as error "Parameter q must be positive"
		}
		if 	`a' <= 0{
			di as error "Parameter a must be positive"
		}
		if `b' <= 0{
			di as error "Parameter b must be positive"
		}
		
		quietly mata: rgb2("`varname'",`a',`b',`p',`q')
	}

end

//Mata functions

version 13
mata:
	function rgb2(string myvar, scalar a, scalar b, scalar p, scalar q)
	{
	nobs = st_nobs()
	base = runiform(nobs,1)
	newvar = J(nobs,1,0)
	paravec = a,b,p,q
	
	if (nobs <1000){
	
		for (i=1; i <=nobs; i++){
			newvar[i] = estimategb2(paravec,base[i])
			}
		}
	else{
		cdflist = interpolategb2(paravec)
		
		for (i=1; i <=nobs; i++){
			newvar[i] = nearest_gb2(cdflist,base[i])
			}
	
	}
	
	(void) st_addvar("double", myvar)
	st_store(.,myvar,newvar[.,1])
	}
	end
	
mata:
	function estimategb2(paravec,unifval)
	{
	
		a = paravec[1]
		b = paravec[2]
		p     = paravec[3]
		q     = paravec[4]
		
		S = optimize_init()
		optimize_init_which(S,"min")
		optimize_init_technique(S,"dfp nr")
		optimize_init_evaluator(S,&closestgb2())
		
		//Expected Value (starting value)
		start = b*((exp(lngamma(p+(1/a)))*exp(lngamma(q-(1/a))))/( exp(lngamma(p))*exp(lngamma(q))))
		optimize_init_params(S,start)
		optimize_init_argument(S,1,paravec)
		optimize_init_argument(S,2,unifval)
		_optimize(S)
	    ans    = optimize_result_params(S)
		return(ans)
	
	}
	
end

mata:
	function interpolategb2(paravec)
	{
		cdflist = J(1000,1,0)
		
		for (i=1; i <=1000; i++){
		cdflist[i] = estimategb2(paravec,(i/1000))
		}
	return(cdflist)
    }
end

mata:
	function nearest_gb2(cdflist,unifval)
	{
		nx = 1000*unifval
		intx = floor(nx)
		remx = nx - intx
		next = intx+1
		
		if (intx ==0) {
			closegb2 = cdflist[1]*remx
		}
		else{
			closegb2 = cdflist[intx]*(1-remx) + cdflist[next]*remx
		}
		return(closegb2)
	}
end

mata: 
	function closestgb2(real scalar todo, real rowvector p, paravec,unifval, v,g,H)
	{
	
	v = abs(gb2_cdf(p,paravec)-unifval)
	
	}
	end
	
mata:
function gb2_cdf(matrix y, paravec)
	{
	ones = J(1,cols(y),1)
	a = paravec[1]
	b = paravec[2]
	p = paravec[3]
	q = paravec[4]
	zu = ((y:/b):^(a)):/(ones+(y:/b):^(a))
	F =  ibeta(p,q,zu)
	return(F)
	}
end
	
	
