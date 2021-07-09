
program define stgenreg_gaussquad, rclass
	syntax [, N(integer -99) LEGendre CHEB1 CHEB2 HERmite JACobi LAGuerre alpha(real 0) beta(real 0)]
	
    if `n' < 0 {
        display as err "need non-negative number of nodes"
		exit 198
	}
	if wordcount(`"`legendre' `cheb1' `cheb2' `hermite' `jacobi' `laguerre'"') > 1 {
		display as error "You have specified more than one integration option"
		exit 198
	}
	local inttype `legendre'`cheb1'`cheb2'`hermite'`jacobi'`laguerre' 
	if "`inttype'" == "" {
		display as error "You must specify one of the integration type options"
		exit 198
	}

	tempname weights nodes
	mata gq("`weights'","`nodes'")
	return matrix weights = `weights'
	return matrix nodes = `nodes'
end

mata:
	void gq(string scalar weightsname, string scalar nodesname)
{
	n =  strtoreal(st_local("n"))
	inttype = st_local("inttype")
	i = range(1,n,1)'
	i1 = range(1,n-1,1)'
	alpha = strtoreal(st_local("alpha"))
	beta = strtoreal(st_local("beta"))
		
	if(inttype == "legendre") {
		muzero = 2
		a = J(1,n,0)
		b = i1:/sqrt(4 :* i1:^2 :- 1)
	}
	else if(inttype == "cheb1") {
		muzero = pi()
		a = J(1,n,0)
		b = J(1,n-1,0.5)
		b[1] = sqrt(0.5)
    }
	else if(inttype == "cheb2") {
		muzero = pi()/2
		a = J(1,n,0)
		b = J(1,n-1,0.5)
	}
	else if(inttype == "hermite") {
		muzero = sqrt(pi())
		a = J(1,n,0)
		b = sqrt(i1:/2)
	}
	else if(inttype == "jacobi") {
		ab = alpha + beta
		muzero = 2:^(ab :+ 1) :* gamma(alpha + 1) * gamma(beta + 1):/gamma(ab :+ 2)
		a = i
		a[1] = (beta - alpha):/(ab :+ 2)
		i2 = range(2,n,1)'
		abi = ab :+ 2 :* i2
		a[i2] = (beta:^2 :- alpha^2):/(abi :- 2):/abi
		b = i1
        b[1] = sqrt(4 * (alpha + 1) * (beta + 1):/(ab :+ 2):^2:/(ab :+ 3))
        i2 = i1[2..n-1]
        abi = ab :+ 2 :* i2
        b[i2] = sqrt(4 :* i2 :* (i2 :+ alpha) :* (i2 :+ beta) :* (i2 :+ ab):/(abi:^2 :- 1):/abi:^2)
	}
	else if(inttype == "laguerre") {
		a = 2 :* i :- 1 :+ alpha
		b = sqrt(i1 :* (i1 :+ alpha))
		muzero = gamma(alpha :+ 1)
    }

	A= diag(a)
	for(j=1;j<=n-1;j++){
		A[j,j+1] = b[j]
		A[j+1,j] = b[j]
	}
	symeigensystem(A,vec,nodes)
	weights = (vec[1,]:^2:*muzero)'
	weights = weights[order(nodes',1)]
	nodes = nodes'[order(nodes',1)']
	st_matrix(weightsname,weights)
	st_matrix(nodesname,nodes)
}
		
end
