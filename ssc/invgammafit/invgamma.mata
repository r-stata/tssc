// Mata functions NJC 15 December 2006

mata : 

// vector = f(y | alpha, beta)
real invgammaden(real scalar alpha, 
		 real scalar beta, 
		 real colvector y) 
{ 
	if (alpha <= 0) { 
		displayas("error") 
		printf("alpha must be positive\n")
		exit(error(411)) 
	} 

	if (beta <= 0) { 
		displayas("error") 
		printf("beta must be positive\n")
		exit(error(411)) 
	} 

	if (sum(y :<= 0)) { 
		displayas("error") 
		printf("values must be positive\n")
		exit(error(411)) 
	} 
	
	return((y:^(-(alpha + 1)) :* exp(- beta :/ y)) / 
		(beta^(-alpha) * gamma(alpha))) 
}

// variable = f(y | alpha, beta)
void invgammadenvar(real scalar alpha, 
		 real scalar beta, 
		 string scalar varname, 
		 string scalar tousename,
		 string scalar densityname) 
{ 
	real colvector y, density 

	if (alpha <= 0) { 
		displayas("error") 
		printf("alpha must be positive\n")
		exit(error(411)) 
	} 

	if (beta <= 0) { 
		displayas("error") 
		printf("beta must be positive\n")
		exit(error(411)) 
	} 

	y = st_data(., varname, tousename) 

	if (sum(y :<= 0)) { 
		displayas("error") 
		printf("values must be positive\n")
		exit(error(411)) 
	} 

	density = (y:^(-(alpha + 1)) :* exp(- beta :/ y)) / 
		(beta^(-alpha) * gamma(alpha))

	st_addvar("double", densityname)
	st_store(., densityname, tousename, density) 
}


// vector = F(y | alpha, beta)
real invgamma(real scalar alpha, 
	      real scalar beta, 
	      real colvector y) 
{ 
	real colvector dist 

	if (alpha <= 0) { 
		displayas("error") 
		printf("alpha must be positive\n")
		exit(error(411)) 
	} 
	
	if (beta <= 0) { 
		displayas("error") 
		printf("beta must be positive\n")
		exit(error(411)) 
	} 

	if (sum(y :<= 0)) { 
		displayas("error") 
		printf("values must be positive\n")
		exit(error(411)) 
	} 

	dist = 1 :- gammap(alpha, beta :/ y) 
	return(dist)
}

// variable = F(y | alpha, beta)
void invgammavar(real scalar alpha, 
	      real scalar beta, 
	      string scalar varname, 
	      string scalar tousename,
	      string scalar distname) 
{ 
	real colvector y, dist 

	if (alpha <= 0) { 
		displayas("error") 
		printf("alpha must be positive\n")
		exit(error(411)) 
	} 

	if (beta <= 0) { 
		displayas("error") 
		printf("beta must be positive\n")
		exit(error(411)) 
	} 

	y = st_data(., varname, tousename) 

	if (sum(y :<= 0)) { 
		displayas("error") 
		printf("values must be positive\n")
		exit(error(411)) 
	} 

	dist = 1 :- gammap(alpha, beta :/ y) 

	st_addvar("double", distname)
	st_store(., distname, tousename, dist) 
}


// vector = quantile(P | alpha, beta)
real invinvgamma(real scalar alpha, 
	      real scalar beta, 
	      real colvector p) 
{ 
	real colvector y  

	if (alpha <= 0) { 
		displayas("error") 
		printf("alpha must be positive\n")
		exit(error(411)) 
	} 

	if (beta <= 0) { 
		displayas("error") 
		printf("beta must be positive\n")
		exit(error(411)) 
	} 

	if (sum(p :<= 0 :| p :>= 1)) { 
		displayas("error") 
		printf("values must be in (0,1)\n")
		exit(error(498)) 
	} 

	y = beta :/ invgammap(alpha, 1 :- p)
	return(y) 
}

// variable = quantile(P | alpha, beta)
void invinvgammavar(real scalar alpha, 
	      real scalar beta, 
	      string scalar varname, 
	      string scalar tousename,
	      string scalar yname) 
{ 
	real colvector p, y 

	if (alpha <= 0) { 
		displayas("error") 
		printf("alpha must be positive\n")
		exit(error(411)) 
	} 

	if (beta <= 0) { 
		displayas("error") 
		printf("beta must be positive\n")
		exit(error(411)) 
	} 

	p = st_data(., varname, tousename) 

	if (sum(p :<= 0 :| p :>= 1)) { 
		displayas("error") 
		printf("values must be in (0,1)\n")
		exit(error(498)) 
	} 

	y = beta :/ invgammap(alpha, 1 :- p)

	st_addvar("double", yname)
	st_store(., yname, tousename, y) 
}

end 
